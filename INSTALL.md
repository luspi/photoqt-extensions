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

## Distribute a custom build of extensions

PhotoQt verifies any found extension using a cryptographic signature. For this purpose, pre-built extensions are provided that are signed with the project's private RSA key. The corresponding public key is included in PhotoQt.

If the extensions are built independently and to be distributed, then there are two possible solutions for obtaining verified extensions:

1. The recommended way is to sign the verification files after the extensions have been built. To this end, a Python script is provided that simplifies that process. It is called `generate_verification.py` and is located in the `scripts/` subfolder. It takes two possible command line arguments:

      ```
      --private-key [filename]
      --ext-dir [directory]
      ```
The first one specifies the custom private key (required to be specified), and the second one is the location of the extensions directory (parent directory by default). The corresponding public key then needs to be specified when configuring PhotoQt (`-DEXTENSIONS_CUSTOM_PUBLIC_KEY=<public_key>`) which will add that key in addition to the project's public key.

2. Another solution (not recommended) is to disable the verification of the built shared library files in PhotoQt (`-DWITH_EXTENSIONS_LIBRARY_VERIFICATION=OFF`). The remaining files that are validated are text files and do not change in the build process.

The public/private key pair needs to be generated with the RSA algorithm (SHA256). You can generate such a key pair using `openssl` by executing the following two commands:

```
$ openssl genrsa -out private.key 4096
$ openssl rsa -in private.key -pubout -out public.key
```


---

### PhotoQt doesn't find an extension, what should I do?

If PhotoQt is not able to find an extension, there are a few possible reasons why this might be the case:

**The extension does not pass the verification check**  
PhotoQt by default verifies all extensions to help make sure no unknown/untrusted/random code is run by PhotoQt. All official releases of the extension come with the right signature file. If you are either building the latest code snapshot or have modified the extension files, you will need to **disable the verification check** in order for your extension to be loaded. You might have to then also enable the extension from within the settings manager or (if using the integrated interface) from the `Extensions` menu in the menubar.

If PhotoQt still doesn't load the extension, you can try installing the extension through the PhotoQt interface, which will make PhotoQt automatically move the extension to the right location in the filesystem. To do this, follow these steps:

1. Locate the folder of the installed extension.
2. Create a zip archive of this folder.
3. Change the file ending from `zip` to `pqe` (if possible)
4. Run PhotoQt, open the settings manager and go to the `Extensions` tab.
5. Click on `Install extension` and select the zip file created above. PhotoQt will by default only list the files with the `pqe` ending, but you can change the file filter to show all files if it doesn't show up.
6. Confirm that you want to install the extension.
7. Make sure the extension is enabled.

If you are still unable to run the extension, please don't hesitate to (get in touch)[https://gitlab.com/lspies/photoqt/-/issues].

### Can I install some extension without having to compile anything?

It is possible to use QML-only extensions with PhotoQt that do not require for anything to be compiled. To install such an extension, simply copy the extension folder to the location listed at the top of this file. Make sure that the extension is enabled (this can be done from within the settings manager or (if using the integrated interface) from the `Extensions` menu in the menubar.).

Note, this **does not** work with extensions that rely on compiled C++ code!

