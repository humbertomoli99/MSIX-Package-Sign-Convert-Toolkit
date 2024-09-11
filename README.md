# Script de Empaquetado y Firma de MSIX

Este conjunto de scripts en PowerShell te permite:

1. **Seleccionar y empaquetar** archivos `.msix` en un paquete `.msixbundle` utilizando la herramienta `makeappx.exe` disponible en los SDKs de Windows instalados.
2. **Firmar** el paquete `.msixbundle` utilizando un certificado `.pfx` y la herramienta `signtool.exe` de los SDKs de Windows.
3. **Convertir** un archivo `.pfx` a una cadena Base64 y guardarlo en un archivo `.txt`.

## Requisitos

- Tener instalado el **SDK de Windows**, el cual incluye las herramientas `makeappx.exe` y `signtool.exe`.
- **PowerShell** versión 5.0 o superior.
- Certificado **.pfx** válido para firmar los paquetes.

## Instrucciones de uso

### Empaquetado de archivos .msix en un MSIXBundle

1. Ejecuta el script en PowerShell.
2. El script detectará los SDKs instalados y te permitirá seleccionar la versión que deseas utilizar. Mostrará los SDKs que contienen la herramienta `makeappx.exe`.
3. Se te pedirá que ingreses la carpeta que contiene los archivos `.msix`. Si no ingresas una ruta, el script creará una carpeta predeterminada en el Escritorio.
4. Asegúrate de que la carpeta seleccionada contenga solo archivos `.msix`. Si hay otros archivos, el script te advertirá.
5. Ingresa un nombre para el archivo de salida del paquete `.msixbundle`. Si no lo ingresas, el script usará el nombre del primer archivo `.msix` en la carpeta.
6. El script empaquetará los archivos `.msix` en un archivo `.msixbundle`.

### Firma del paquete MSIXBundle

1. El script también te permitirá seleccionar los SDKs que contienen la herramienta `signtool.exe`.
2. Selecciona el SDK que deseas utilizar para firmar el paquete.
3. Proporciona el archivo de certificado `.pfx` y la contraseña correspondiente.
4. Elige el algoritmo de hash (por defecto SHA256).
5. El script intentará firmar el paquete hasta un máximo de 3 veces si se ingresan credenciales incorrectas.

### Convertir un archivo .pfx a Base64

1. El script te solicitará que ingreses la ruta del archivo `.pfx` que deseas convertir.
2. Especifica un nombre para el archivo de salida (sin la extensión). Si no lo haces, se usará el mismo nombre que el archivo `.pfx`.
3. El archivo `.pfx` será leído, codificado en Base64 y guardado como un archivo `.txt` en la misma carpeta del `.pfx`.

## Advertencias

- **MSIX Files**: Asegúrate de que la carpeta que seleccionas contenga únicamente archivos `.msix` para evitar problemas de empaquetado.
- **Firma**: Si el paquete no puede ser firmado después de tres intentos, verifica que el archivo `.pfx` y la contraseña sean correctos.
- **Certificados**: Al codificar el certificado `.pfx` en Base64, el archivo resultante contiene información sensible. Asegúrate de almacenar y proteger este archivo adecuadamente.
