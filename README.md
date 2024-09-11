# MSIX Packaging and Signing Script

This set of PowerShell scripts allows you to:

1. **Select and package** `.msix` files into a `.msixbundle` package using the `makeappx.exe` tool available in the installed Windows SDKs.
2. **Sign** the `.msixbundle` package using a `.pfx` certificate and the `signtool.exe` tool from the Windows SDKs.
3. **Convert** a `.pfx` file to a Base64 string and save it to a `.txt` file.

## Requirements

- Have the **Windows SDK** installed, which includes the `makeappx.exe` and `signtool.exe` tools.
- **PowerShell** version 5.0 or higher.
- Valid **.pfx** certificate to sign the packages.

## Instructions for use

### Packaging .msix files into an MSIXBundle

1. Run the script in PowerShell.
2. The script will detect the installed SDKs and allow you to select the version you want to use. It will display the SDKs that contain the `makeappx.exe` tool.
3. You will be prompted to enter the folder that contains the `.msix` files. If you do not enter a path, the script will create a default folder on the Desktop.
4. Make sure that the selected folder contains only `.msix` files. If there are other files, the script will warn you.
5. Enter a name for the output file of the `.msixbundle` package. If you do not enter a name, the script will use the name of the first `.msix` file in the folder.
6. The script will package the `.msix` files into a `.msixbundle` file.

### Signing the MSIXBundle

1. The script will also allow you to select SDKs that contain the `signtool.exe` tool.
2. Select the SDK you want to use to sign the package.
3. Provide the `.pfx` certificate file and the corresponding password.
4. Choose the hash algorithm (default SHA256).
5. The script will attempt to sign the package up to a maximum of 3 times if incorrect credentials are entered.

### Converting a .pfx file to Base64

1. The script will prompt you to enter the path of the `.pfx` file you want to convert.
2. Specify a name for the output file (without the extension). If you don't, the same name as the `.pfx` file will be used.
3. The `.pfx` file will be read, Base64 encoded, and saved as a `.txt` file in the same folder as the `.pfx`.

## Warnings

- **MSIX Files**: Make sure the folder you select contains only `.msix` files to avoid packaging issues.
- **Signing**: If the package cannot be signed after three attempts, verify that the `.pfx` file and password are correct.
- **Certificates**: When Base64 encoding the `.pfx` certificate, the resulting file contains sensitive information. Make sure to store and protect this file appropriately.
