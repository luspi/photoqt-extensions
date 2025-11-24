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

    ignore_files = ["verification.txt", "verification.txt.sig", "CMakeLists.txt"]
    ignore_dirs  = ["build", "cplusplus", ".git"]

    with open(output_path, "w", encoding="utf-8") as out_file:
        for dirpath, dirnames, filenames in os.walk(root_dir):
            for filename in filenames:
                if filename in ignore_files or "/build" in dirpath or "/cplusplus" in dirpath:
                    continue
                print(dirpath)

                filepath = os.path.join(dirpath, filename)
                try:
                    checksum = sha256_checksum(filepath)
                    rel_path = os.path.relpath(filepath, root_dir)
                    out_file.write(f"{rel_path}:{checksum}\n")
                except (OSError, PermissionError) as e:
                    print(f"Skipping {filepath}: {e}")

    # sign manifest
    command = f"openssl dgst -sha256 -sign private_rsa.pem -out {output_path}.sig {output_path}"
    os.popen(command)

    print(f"All checksums written to {output_path} and signed")

if __name__ == "__main__":

    basepath = Path(os.getcwd()).parent.absolute()

    subdirs = [os.path.join(basepath, d) for d in sorted(os.listdir(basepath)) if os.path.isdir(os.path.join(basepath, d))]

    for d in subdirs:
        collect_all_checksums_to_first_subdir(d)
