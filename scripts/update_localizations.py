import argparse
from pathlib import Path
from git import Repo
import time
import os
import shutil
import ruamel.yaml
import subprocess

#######################################################

parser = argparse.ArgumentParser(
                    prog='PhotoQt Extensions localization updater',
                    description='This loops over all extensions and fetches the latest translations for each, including updating the manifest files with the relevant translations.',
                    epilog='See https://photoqt.org/extensions for more details.')

parser.add_argument('--ext-dir',
                    default="..",
                    help="The base dir of where to look for the extensions.")

parser.add_argument('--lrelease',
                    default="lrelease",
                    help="Specify path to lrelease executable.")

parser.add_argument('--languages',
                    default="de_DE,es_ES,lt_LT,nl_NL,pl_PL,ru_RU,uk_UA,zh_CN",
                    help="The list of languages to include.")

args = parser.parse_args()

#######################################################
#######################################################

if shutil.which(args.lrelease) == None:
    print(f" !! The lrelease executable was not found: {args.lrelease}")
    print(f" !!  You can specify the executable name/path using the --lrelease flag.")
    exit(0);

#######################################################
#######################################################

repo_url = "https://gitlab.com/lspies/photoqt-extensions-lang"
local_path = Path(f"photoqt-lang-{int(time.time())}")

print(f"> Cloning git repo to folder: {local_path}")
Repo.clone_from(repo_url, local_path, branch="l10n_main", single_branch=True)

all_extensions = []
for (root, dirs, files) in os.walk(local_path):
    for f in files:
        if f.endswith("ts") and "_" not in f:
            all_extensions.append(f.replace(".ts",""))

print(f"> Found extensions: {','.join(all_extensions)}")

#######################################################

# copy the respective ts files
for ext in all_extensions:

    print(f"> Updating ts file for extension {ext}")

    for l in args.languages.split(","):

        lang_path = Path(f"{args.ext_dir}/{ext}/lang")
        lang_path.mkdir(parents=True, exist_ok=True)
        shutil.copy(f"{local_path}/localized/{ext}_{l}.ts", f"{args.ext_dir}/{ext}/lang/")

# find the extensions without shared library file for precompiling the ts file
for ext in all_extensions:
    cpp_folder = Path(f"{args.ext_dir}/{ext}/cplusplus")
    if not cpp_folder.exists():
        print(f"> Pre-compiling ts files for extension {ext}")
        for l in args.languages.split(","):
            subprocess.run([args.lrelease, f"{args.ext_dir}/{ext}/lang/{ext}_{l}.ts"])

#######################################################

# next compose the manifests

for ext in all_extensions:

    print(f"> Adding translations to manifest of extension {ext}")

    # first read original manifest
    yaml = ruamel.yaml.YAML()
    with open(f"{args.ext_dir}/{ext}/manifest.yml") as f:
        master_manifest = yaml.load(f)

    # first remove old translations
    to_remove = []
    for key in master_manifest['about']:
        if key != "name" and "name[" in key:
            to_remove.append(key)
        if key != "longName" and "longName[" in key:
            to_remove.append(key)
        if key != "description" and "description[" in key:
            to_remove.append(key)
    for rem in to_remove:
        del master_manifest['about'][rem]

    pathlist = Path(f"{local_path}/localized/").rglob(f'{ext}*yml')

    yaml.indent(mapping=4, sequence=4, offset=4)
    yaml.width = 9999

    for fn in pathlist:

        with open(fn) as f:
            trans_manifest = yaml.load(f)

        for lang in trans_manifest:

            if 'name' in trans_manifest[lang] and 'name' in trans_manifest[lang]:
                orig = master_manifest['about']['name']
                loca = trans_manifest[lang]['name']
                if orig != loca:
                    master_manifest['about'][f"name[{lang}]"] = loca

            if 'longName' in trans_manifest[lang] and 'longName' in trans_manifest[lang]:
                orig = master_manifest['about']['longName']
                loca = trans_manifest[lang]['longName']
                if orig != loca:
                    master_manifest['about'][f"longName[{lang}]"] = loca

            if 'description' in trans_manifest[lang] and 'description' in trans_manifest[lang]:
                orig = master_manifest['about']['description']
                loca = trans_manifest[lang]['description']
                if orig != loca:
                    master_manifest['about'][f"description[{lang}]"] = loca

        with open(f"{args.ext_dir}/{ext}/manifest.yml", "w") as f:
            yaml.dump(master_manifest, f)

#######################################################
#######################################################

shutil.rmtree(local_path)
