# Función para escribir mensajes en color
function Write-ColorMessage {
    param (
        [string]$message,
        [ConsoleColor]$color
    )
    $originalColor = $Host.UI.RawUI.ForegroundColor
    $Host.UI.RawUI.ForegroundColor = $color
    Write-Host $message
    $Host.UI.RawUI.ForegroundColor = $originalColor
}

# Ruta del ejecutable signtool
$signtoolPath = "C:\Program Files (x86)\Windows Kits\10\bin\10.0.22621.0\x64\signtool.exe"

# Obtener el directorio del script
$scriptDir = Split-Path -Path $MyInvocation.MyCommand.Path -Parent

# Definir rutas predeterminadas
$defaultPackageFolder = Join-Path -Path $scriptDir -ChildPath "AppPackages"

# Crear la carpeta predeterminada si no existe
if (-Not (Test-Path $defaultPackageFolder)) {
    Write-ColorMessage "La carpeta '$defaultPackageFolder' no existe. Se creará automáticamente." -color Yellow
    New-Item -Path $defaultPackageFolder -ItemType Directory | Out-Null
    Write-ColorMessage "Por favor, arrastre los archivos MSIX a la carpeta '$defaultPackageFolder' y presione cualquier tecla para continuar..." -color Yellow
    [void][System.Console]::ReadKey($true)
}

# Solicitar al usuario la carpeta de entrada
Write-Host "Por favor, ingrese la ruta de la carpeta que contiene los archivos MSIX (deje vacío para usar la carpeta predeterminada '$defaultPackageFolder')."
$inputFolder = Read-Host "Ruta de la carpeta de entrada"

# Usar la ruta predeterminada si el usuario no proporciona una
if ([string]::IsNullOrWhiteSpace($inputFolder)) {
    $inputFolder = $defaultPackageFolder
}

# Verificar si la carpeta existe
if (-Not (Test-Path $inputFolder)) {
    Write-ColorMessage "Error: La carpeta '$inputFolder' no se encontró." -color Red
    Write-Host "Presiona cualquier tecla para salir..."
    [void][System.Console]::ReadKey($true)
    exit
}

# Verificar que solo hay archivos MSIX en la carpeta
$files = Get-ChildItem -Path $inputFolder -Filter *.msix
if ($files.Count -eq 0) {
    Write-ColorMessage "Error: La carpeta '$inputFolder' no contiene archivos MSIX." -color Red
    Write-Host "Presiona cualquier tecla para salir..."
    [void][System.Console]::ReadKey($true)
    exit
}

# Obtener el primer archivo MSIX
$firstMsixFile = $files[0]
$baseFileName = [System.IO.Path]::GetFileNameWithoutExtension($firstMsixFile.FullName)
$defaultBundlePath = Join-Path -Path $inputFolder -ChildPath "$baseFileName.msixbundle"

# Solicitar al usuario el nombre del archivo de paquete
Write-Host "Por favor, ingrese el nombre del archivo MSIXBundle que desea crear (deje vacío para usar la ruta predeterminada '$defaultBundlePath')."
$bundlePath = Read-Host "Nombre del archivo MSIXBundle"

# Usar la ruta predeterminada si el usuario no proporciona una
if ([string]::IsNullOrWhiteSpace($bundlePath)) {
    $bundlePath = $defaultBundlePath
}

# Solicitar al usuario la ruta del archivo de certificado
Write-Host "Por favor, ingrese la ruta del archivo de certificado PFX (deje vacío para arrastrar el archivo a la terminal)."
Write-Host "Arrastre el archivo PFX a la terminal y presione Enter."
$certPath = Read-Host "Ruta del archivo PFX"

# Verificar si el archivo de certificado existe
if (-Not (Test-Path $certPath)) {
    Write-ColorMessage "Error: El archivo de certificado '$certPath' no se encontró." -color Red
    Write-Host "Presiona cualquier tecla para salir..."
    [void][System.Console]::ReadKey($true)
    exit
}

# Solicitar al usuario la contraseña del certificado
$certPassword = Read-Host "Contraseña del certificado PFX" -AsSecureString

# Convertir la contraseña a una cadena de texto para el comando
$certPasswordText = [System.Net.NetworkCredential]::new([string]::Empty, $certPassword).Password

# Solicitar el algoritmo de hash
Write-Host "Por favor, ingrese el algoritmo de hash para firmar el paquete (deje vacío para usar el valor predeterminado 'SHA256')."
$hashAlgorithm = Read-Host "Algoritmo de hash"

# Usar el valor predeterminado si el usuario no proporciona uno
if ([string]::IsNullOrWhiteSpace($hashAlgorithm)) {
    $hashAlgorithm = "SHA256"
}

# Imprimir los valores para depuración
Write-ColorMessage "Firmando el paquete MSIXBundle con los siguientes valores:" -color Green
Write-ColorMessage "Ruta del archivo MSIXBundle: $bundlePath" -color Green
Write-ColorMessage "Ruta del archivo de certificado: $certPath" -color Green
Write-ColorMessage "Contraseña del certificado: [PROPORCIONADA]" -color Green
Write-ColorMessage "Algoritmo de hash: $hashAlgorithm" -color Green

# Ejecutar el comando signtool y manejar errores
try {
    & $signtoolPath sign /fd $hashAlgorithm /a /f $certPath /p $certPasswordText $bundlePath
    Write-ColorMessage "El paquete MSIXBundle se firmó con éxito." -color Green
} catch {
    Write-ColorMessage "Error: No se pudo firmar el paquete MSIXBundle." -color Red
} finally {
    Write-Host "Presiona cualquier tecla para salir..."
    [void][System.Console]::ReadKey($true)
}
