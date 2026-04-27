import os
from pathlib import Path
import argparse

# create hashes of protected files
import hashlib

# sign the verification file with a given private key
from cryptography.hazmat.primitives import hashes, serialization
from cryptography.hazmat.primitives.asymmetric import padding

#######################################################

parser = argparse.ArgumentParser(
                    prog='PhotoQt Extensions verification generator',
                    description='This loops over all the files of an extension, generates the verification hashes and finally signs that files with the provided private key. Note that this private key has to match the public key that is provided to PhotoQt at compile time.',
                    epilog='See https://photoqt.org/extensions for more details.')

parser.add_argument('--private-key',
                    required=True,
                    help="The private ed25519 key to use for signing the verification files.")
parser.add_argument('--ext-dir',
                    default="..",
                    help="The base dir of where to look for the extensions.")
parser.add_argument('--skip-libraries',
                    action="store_true",
                    help="Don't include the generated shared library in the verification process.")

args = parser.parse_args()

#######################################################

# create a sha256 checksum hash for the provided file path
def sha256_checksum(filepath):
    sha256 = hashlib.sha256()
    with open(filepath, "rb") as f:
        # 65536 is the block size
        for block in iter(lambda: f.read(65536), b""):
            sha256.update(block)
    return sha256.hexdigest()

# collect all checksums and write them to a file
def collect_checksums(root_dir):

    # Get all subdirectories
    subdirs = [os.path.join(root_dir, d) for d in sorted(os.listdir(root_dir))
               if os.path.isdir(os.path.join(root_dir, d))]

    if not subdirs:
        print("No subdirectories found.")
        return

    output_path = os.path.join(root_dir, "verification.txt")

    consider_these_file_endings = ["qml", "txt", "yml"]
    if not args.skip_libraries:
        consider_these_file_endings.append("so")
        consider_these_file_endings.append("dll")
    ignore_files = ["verification.txt", "verification.txt.sig", "CMakeLists.txt"]
    ignore_dirs  = ["build", "cplusplus", ".git", ".qtcreator"]

    # we first create a map of everything to always have the same sorting
    mapOfAll = dict()
    for dirpath, dirnames, filenames in os.walk(root_dir):
            for filename in filenames:
                if filename in ignore_files:
                    continue
                skip = False
                for d in ignore_dirs:
                    if d in dirpath:
                        skip = True
                        break
                if skip:
                    continue
                suffix = filename.split(".")[-1].lower()
                if suffix not in consider_these_file_endings:
                    continue

                filepath = os.path.join(dirpath, filename)
                try:
                    checksum = sha256_checksum(filepath)
                    rel_path = os.path.relpath(filepath, root_dir).replace("\\", "/")   # the replace is needed when run on Windows
                    mapOfAll[rel_path] = checksum
                except (OSError, PermissionError) as e:
                    print(f"Skipping {filepath}: {e}")

    listFiles = list(mapOfAll.keys())
    listFiles.sort()

    with open(output_path, "w", encoding="utf-8") as out_file:
        for f in listFiles:
            out_file.write(f"{f}:{mapOfAll[f]}\n")

    print(f"   > Verification file created at {output_path}.")

    return output_path

# sign the provided verification file
def sign_verification(path):

    # load provided private key
    with open(args.private_key, "rb") as key_file:
        private_key = serialization.load_pem_private_key(key_file.read(), password=None)

    # read the file to sign (binary mode)
    with open(path, "rb") as f:
        data = f.read()

    # sign the data (SHA256 + RSA, PKCS#1 v1.5 padding (OpenSSL default))
    signature = private_key.sign(data, padding.PKCS1v15(),  hashes.SHA256())

    # write signature file
    with open(f"{path}.sig", "wb") as sig_file:
        sig_file.write(signature)

    print(f"   > Verification file signed.")

#################################################################

if __name__ == "__main__":

    # make sure the provided path is the absolute directory
    basepath = Path(args.ext_dir).absolute().resolve()

    # get a list of all subdirectories
    subdirs = [os.path.join(basepath, d) for d in sorted(os.listdir(basepath)) if os.path.isdir(os.path.join(basepath, d))]

    # we ignore:
    # - the build directories
    # - the C++ sourse files
    # - any CMake scripts
    # - the scripts subdirectory containing, e.g., this script
    # - any git stuff
    # - local config stuff added by QtCreator
    ignore_dirs  = ["build", "cplusplus", "CMake", "scripts", ".git", ".qtcreator"]

    # loop over all dirs
    for d in subdirs:

        # ignoring this directory
        if d.split("/")[-1] in ignore_dirs:
            continue

        print(f"* Processing extension located at {d}.")

        # generate and sign verification
        sign_verification(collect_checksums(d))
