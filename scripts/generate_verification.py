import os
from pathlib import Path
import hashlib

def sha256_checksum(filepath, block_size=65536):
    sha256 = hashlib.sha256()
    with open(filepath, "rb") as f:
        for block in iter(lambda: f.read(block_size), b""):
            sha256.update(block)
    return sha256.hexdigest()

def collect_all_checksums_to_first_subdir(root_dir):

    # Get all subdirectories
    subdirs = [os.path.join(root_dir, d) for d in sorted(os.listdir(root_dir))
               if os.path.isdir(os.path.join(root_dir, d))]

    if not subdirs:
        print("No subdirectories found.")
        return

    output_path = os.path.join(root_dir, "verification.txt")

    consider_these_file_endings = ["qml", "txt", "yml"]
    ignore_files = ["verification.txt", "verification.txt.sig", "CMakeLists.txt"]
    ignore_dirs  = ["build", "cplusplus", ".git"]

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

    # sign manifest
    command = f"openssl dgst -sha256 -sign private_rsa.pem -out {output_path}.sig {output_path}"
    os.popen(command)

    print(f"All checksums written to {output_path} and signed")

if __name__ == "__main__":

    basepath = Path(os.getcwd()).parent.absolute()

    subdirs = [os.path.join(basepath, d) for d in sorted(os.listdir(basepath)) if os.path.isdir(os.path.join(basepath, d))]

    ignore_dirs  = ["build", "cplusplus", ".git"]

    for d in subdirs:
        if d.split("/")[-1] in ignore_dirs:
            continue
        collect_all_checksums_to_first_subdir(d)
