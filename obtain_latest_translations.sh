#!/bin/bash

lrelexe="lrelease"
if [ $# -eq 1 ]
then
    lrelexe="$1"
fi

rm -rf photoqt-extensions-lang
git clone -b l10n_main https://gitlab.com/lspies/photoqt-extensions-lang

langs=(de_DE es_ES lt_LT nl_NL pl_PL ru_RU uk_UA zh_CN)
nolib=(FloatingNavigation MapCurrent QuickActions)

for ext in CropImage ExportImage FloatingNavigation Histogram ImgurCom MapCurrent QuickActions ScaleImage Wallpaper
do

    for l in "${langs[@]}"
    do

        mkdir -p "$ext"/lang
        cp photoqt-extensions-lang/localized/"$ext"_"$l".ts "$ext"/lang/

    done

done

# THESE DON'T BUILD ANYTHING AND MUST BE CONVERTED TO QM FILES MANUALLY
for ext in FloatingNavigation MapCurrent QuickActions
do

    for l in "${langs[@]}"
    do

        eval "$lrelexe $ext/lang/"$ext"_$l.ts"

    done

done
