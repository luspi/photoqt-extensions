#
#
# NO NEED TO CALL MANUALLY
#
# This script is called automatically from the script
# obtain_latest_translations.sh
#
#
import ruamel.yaml
from pathlib import Path

for ext in ['CropImage', 'ExportImage', 'FloatingNavigation', 'Histogram',
            'ImgurCom', 'MapCurrent', 'QuickActions', 'ScaleImage', 'Wallpaper']:

    print(f"Working on {ext}")

    # first read original manifest
    yaml = ruamel.yaml.YAML()
    with open(f"../{ext}/manifest.yml") as f:
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

    pathlist = Path("./photoqt-extensions-lang/localized/").rglob(f'{ext}*yml')

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

        with open(f"../{ext}/manifest.yml", "w") as f:
            yaml.dump(master_manifest, f)
