# Obtener el directorio del script
$scriptDir = Split-Path -Path $MyInvocation.MyCommand.Path -Parent
# Definir la carpeta de entrada por defecto
$defaultFolder = Join-Path -Path $scriptDir -ChildPath "AppPackages"

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

# Advertencia sobre la carpeta de entrada
Write-ColorMessage "ADVERTENCIA: La carpeta de entrada debe contener únicamente archivos .msix que desees empaquetar." -color Yellow
Write-ColorMessage "Cualquier otro archivo o subdirectorio en esta carpeta puede causar errores en la creación del paquete MSIXBundle." -color Yellow
Write-Host ""

# Solicitar al usuario que asigne una carpeta para los paquetes
Write-Host "Por favor, ingrese la ruta de la carpeta que contiene los archivos .msix para empaquetar (se recomienda usar 'AppPackages' en el directorio del script)."
Write-Host "Por defecto, la carpeta recomendada es: $defaultFolder"
$inputFolder = Read-Host "Ruta de la carpeta"

# Si el usuario no ingresa una ruta, usar la carpeta por defecto 'AppPackages'
if ([string]::IsNullOrWhiteSpace($inputFolder)) {
    $inputFolder = $defaultFolder
    # Crear la carpeta si no existe
    if (-Not (Test-Path $inputFolder)) {
        New-Item -Path $inputFolder -ItemType Directory | Out-Null
        Write-ColorMessage "La carpeta '$inputFolder' no existía y ha sido creada. Por favor, arrastre los archivos .msix a esta carpeta antes de continuar." -color Green
        Write-Host "Presiona cualquier tecla para continuar después de haber movido los archivos .msix a la carpeta '$inputFolder'..."
        [void][System.Console]::ReadKey($true)
    } else {
        Write-ColorMessage "Usando la carpeta por defecto: $inputFolder" -color Green
    }
}

# Verificar que la carpeta contiene únicamente archivos .msix
$filesToPack = Get-ChildItem -Path $inputFolder -Filter *.msix -File
$otherFiles = Get-ChildItem -Path $inputFolder -File | Where-Object { $_.Extension -ne ".msix" }

if ($otherFiles.Count -gt 0) {
    Write-ColorMessage "ADVERTENCIA: La carpeta '$inputFolder' contiene archivos que no son .msix. Asegúrate de que la carpeta contenga únicamente archivos .msix para evitar errores." -color Yellow
    Write-ColorMessage "Archivos no .msix encontrados:" -color Yellow
    $otherFiles | ForEach-Object { Write-ColorMessage $_.FullName -color Yellow }
    Write-Host "Presiona cualquier tecla para salir..."
    [void][System.Console]::ReadKey($true)
    exit
}

# Solicitar al usuario el nombre del archivo de salida
Write-Host "Por favor, ingrese el nombre base para el archivo de salida (ejemplo: 'MiPaquete.msixbundle')."
$outputBundleName = Read-Host "Nombre del archivo de salida"

# Si el usuario no ingresa un nombre, usar el nombre del primer archivo .msix
if ([string]::IsNullOrWhiteSpace($outputBundleName)) {
    if ($filesToPack.Count -eq 0) {
        Write-ColorMessage "No se encontraron archivos .msix en la carpeta de entrada. No se puede determinar el nombre del archivo de salida." -color Red
        Write-Host "Presiona cualquier tecla para salir..."
        [void][System.Console]::ReadKey($true)
        exit
    }
    $outputBundleName = [System.IO.Path]::GetFileNameWithoutExtension($filesToPack[0].Name) + ".msixbundle"
    Write-ColorMessage "No se ingresó un nombre de archivo. Usando el nombre del primer archivo .msix para el archivo de salida: $outputBundleName" -color Green
}

# Quitar comillas dobles del outputBundleName usando regex
$outputBundle = [System.IO.Path]::Combine($inputFolder, $outputBundleName -replace '"', '')
Write-ColorMessage "El archivo de salida (sin comillas dobles) es: $outputBundle" -color Green

# Imprimir las rutas para depuración
Write-ColorMessage "La ruta del folder de contenido es: $inputFolder" -color Green
Write-ColorMessage "El archivo de salida es: $outputBundle" -color Green

# Ruta del ejecutable makeappx
$makeAppxPath = "C:\Program Files (x86)\Windows Kits\10\bin\10.0.22621.0\x64\makeappx.exe"

# Ejecutar el comando makeappx y manejar errores
try {
    & $makeAppxPath bundle /d $inputFolder /p $outputBundle
    Write-ColorMessage "El paquete MSIXBundle se creó con éxito." -color Green
} catch {
    Write-ColorMessage "Error: No se pudo crear el paquete MSIXBundle." -color Red
} finally {
    Write-Host "Presiona cualquier tecla para salir..."
    [void][System.Console]::ReadKey($true)
}
