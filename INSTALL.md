# Installing an extension for PhotoQt

There are a few different ways you can install an extension, depending on the extension and what you want to have.

Once installed, PhotoQt will look for extensions in a few different places. On **Linux** these are:

1. ~/.local/share/PhotoQt/extensions
2. /usr/lib/PhotoQt/extensions

On **Windows** the search paths are:

1. C:/Users/\[username\]/AppData/Roaming/PhotoQt/extensions
2. C:/Program Files/PhotoQt/extensions (or wherever else the photoqt.exe executable is located that you are running)

The order of search paths is important, because if an extension with the same id exists in both search paths, then only the first one will be loaded and the second will be ignored. Thus it is possible to "override" an extension with an updated/modified version.

## Building all extensions

In order to install all the extensions, you can do so by following these steps:

1. *mkdir build && cd build/*

2. *cmake -DCMAKE\_INSTALL\_PREFIX=/usr/lib/PhotoQt/extensions ..*

    \# You can disable individual extensions by specifying `-DBUILD_<extension_id>=OFF`

    \# On windows, replace the path above with `C:/Users/\[username\]/AppData/Roaming/PhotoQt/extensions`

3. *make*

    \# This will compile all necessary C++ code and integrate all provided translations.

4. *make install*

Now, (re)-start PhotoQt and it should automatically find and load the extensions. By default, all official extensions are enabled and ready to be used.

### PhotoQt doesn't find an extension, what should I do?

If PhotoQt is not able to find an extension, there are a few possible reasons why this might be the case:

**The extension does not pass the verification check**  
PhotoQt by default verifies all extensions to help make sure no unknown/untrusted/random code is run by PhotoQt. All official releases of the extension come with the right signature file. If you are either building the latest code snapshot or have modified the extension files, you likely will need to manually trust an extension from within the settings manager.

If PhotoQt still doesn't load the extension, you can try installing the extension through the PhotoQt interface, which will make PhotoQt automatically move the extension to the right location in the filesystem. To do this, follow these steps:

1. Locate the folder of the installed extension.
2. Create a zip archive of this folder.
3. Change the file ending from `zip` to `pqe` (if possible)
4. Run PhotoQt, open the settings manager and go to the `Extensions` tab.
5. Click on `Install extension` and select the zip file created above. PhotoQt will by default only list the files with the `pqe` ending, but you can change the file filter to show all files if it doesn't show up.
6. Confirm that you want to install the extension.
7. If it fails the verification check but you trust the source, you can manually grant the "trusted" status to the extension.
8. Enable the extension.

If you are still unable to run the extension, please don't hesitate to (get in touch)[https://gitlab.com/lspies/photoqt/-/issues].

### Can I install some extension without having to compile anything?

It is possible to use QML-only extensions with PhotoQt that do not require for anything to be compiled. To install such an extension, simply copy the extension folder to the location listed at the top of this file. If the extension is not signed or has changed since, grant it the "trusted" status in the settings manager before enabling it.

Note, this **does not** work with extensions that rely on compiled C++ code!

