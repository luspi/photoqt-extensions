# PhotoQt Extensions

This repository provides a set of official extensions for PhotoQt. They provide additional functionality and features that are not part of the basic feature set of PhotoQt (https://photoqt.org).

Some of the extensions can simply be put into the right place and will be picked up by PhotoQt automatically. Others need to some C++ code to be compiled before everything is put into the right place. More detailed instructions can be found in the `INSTALL` file.

Certain packages/installers for PhotoQt also automatically install the relevant extensions.

Visit its official website at https://photoqt.org/extensions

## Installing an extension

See the INSTALL.md file for instruction on how to install an extension.

## Distributing the extensions

PhotoQt verifies any extension to ensure that no random code is executed by PhotoQt. However, extensions that live in a system location cannot be written to or changed without privileged access already. Thus, if someone has the privilege to write to that location already, then there is no need to have any application execute code as it can be done directly. Thus, for distributing the extensions, **no particular signing and/or verification is necessary IF** the target location is the default system location (for example `/usr/lib/PhotoQt/extensions/` where the `/usr/lib/` prefix is not a hardcoded prefix but is based on the actual system.

For any other location that is searched by PhotoQt (see `INSTALL.md` for more details), the extensions need to be *either* signed with a custom key that was added to PhotoQt at compile time (see below) *or* shared-library verification needs to be disabled for PhotoQt at compile time. Otherwise, the extension will show up as 'failed' extension, though it can still be explicitely trusted by the user and used.

**If needed after all, this is the procedure for signing an extension:**

The key needs to be a private RSA key, which has to be used to sign an extension *after* the corresponding shared library has been created. The public key corresponding to that private key then needs to be added to PhotoQt during configuration using `-DEXTENSIONS_CUSTOM_PUBLIC_KEY=<public_key>`.

To help with signing the extensions, a Python script is provided that simplifies that process. It is called `generate_verification.py` and is located in the `scripts/` subfolder. It accepts the following command line arguments:

```
--private-key [filename]
--ext-dir [directory]
--skip-libraries
```

The first one specifies the custom private key (required to be specified), and the second one is the location of the extensions directory (parent directory by default). The corresponding public key then needs to be specified when configuring PhotoQt (`-DEXTENSIONS_CUSTOM_PUBLIC_KEY=<public_key>`) which will add that key in addition to the project's public key. The last flag instructs the Python script to not include any library file object in the verification process.

**If it is not possible to sign the extensions after they have been built**, it is also possible to exclude the shared libraries from the verification process in PhotoQt altogether. This is not recommended though, as there then would be no security guarantees possible for such a shared library. Nonetheless, to achieve this, configure PhotoQt with the `-DWITH_EXTENSIONS_LIBRARY_VERIFICATION=OFF` flag.

The public/private key pair needs to be generated with the RSA algorithm (SHA256). You can generate such a key pair using `openssl` by executing the following two commands:

```
$ openssl genrsa -out private.key 4096
$ openssl rsa -in private.key -pubout -out public.key
```

Note that it is always possible to manually trust an extensions that failed the verification check by granting it the "trusted" status in the settings manager.

## How to contribute an extension

Contributing an extensions is not difficult, and detailed instructions will follow shortly.

## License

The PhotoQt Extensions are released under the [GPLv2](http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt) (or later) license.
