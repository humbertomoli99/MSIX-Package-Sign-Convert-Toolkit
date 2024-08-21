# Obtener el directorio base de los SDKs de Windows
$windowsKitsPath = "C:\Program Files (x86)\Windows Kits\10\bin"

# Obtener las versiones de SDK disponibles en el sistema
$availableSdks = Get-ChildItem -Directory -Path $windowsKitsPath | Where-Object { $_.Name -match '^\d+\.\d+\.\d+\.\d+$' }

# Verificar si se encontraron SDKs
if ($availableSdks.Count -eq 0) {
    Write-Host "No se encontraron versiones de SDK de Windows instaladas." -ForegroundColor Red
    exit
}

# Filtrar solo los SDKs que contienen makeappx.exe
$sdksWithMakeAppx = @()
foreach ($sdk in $availableSdks) {
    $makeappxPath = Join-Path -Path $sdk.FullName -ChildPath "x64\makeappx.exe"
    if (Test-Path $makeappxPath) {
        $sdksWithMakeAppx += $sdk
    }
}

# Verificar si se encontraron SDKs con makeappx.exe
if ($sdksWithMakeAppx.Count -eq 0) {
    Write-Host "No se encontraron SDKs de Windows que contengan makeappx.exe." -ForegroundColor Red
    exit
}

# Mostrar las opciones de SDKs disponibles con makeappx.exe con numeración
Write-Host "Se encontraron las siguientes versiones de SDK de Windows que contienen makeappx.exe:" -ForegroundColor Cyan
for ($i = 0; $i -lt $sdksWithMakeAppx.Count; $i++) {
    $sdkVersion = $sdksWithMakeAppx[$i].Name
    if ($sdkVersion -match '^10\.0\.(\d+)\.0$') {
        if ($matches[1] -lt 22000) {
            Write-Host "$($i + 1). $sdkVersion - Windows 10 SDK" -ForegroundColor Green
        } else {
            Write-Host "$($i + 1). $sdkVersion - Windows 11 SDK" -ForegroundColor Yellow
        }
    }
}

# Pedir al usuario que seleccione una versión del SDK usando el número correspondiente
$sdkIndex = Read-Host "Seleccione el número de la versión de SDK que desea utilizar"

# Verificar si el usuario ingresó un número válido
if (-not [int]::TryParse($sdkIndex, [ref]$sdkIndex) -or $sdkIndex -lt 1 -or $sdkIndex -gt $sdksWithMakeAppx.Count) {
    Write-Host "Selección no válida. Saliendo del script." -ForegroundColor Red
    exit
}

# Obtener la ruta del SDK seleccionado
$sdkPath = $sdksWithMakeAppx[$sdkIndex - 1]
$makeappxPath = Join-Path -Path $sdkPath.FullName -ChildPath "x64\makeappx.exe"

# Solicitar al usuario el nombre de la carpeta que contiene los archivos .msix
$inputFolder = Read-Host "Ingrese la ruta de la carpeta que contiene los archivos .msix para empaquetar"

# Verificar que la carpeta contiene únicamente archivos .msix
$filesToPack = Get-ChildItem -Path $inputFolder -Filter *.msix -File
$otherFiles = Get-ChildItem -Path $inputFolder -File | Where-Object { $_.Extension -ne ".msix" }

if ($otherFiles.Count -gt 0) {
    Write-Host "ADVERTENCIA: La carpeta '$inputFolder' contiene archivos que no son .msix. Asegúrate de que la carpeta contenga únicamente archivos .msix para evitar errores." -ForegroundColor Yellow
    Write-Host "Archivos no .msix encontrados:" -ForegroundColor Yellow
    $otherFiles | ForEach-Object { Write-Host $_.FullName -ForegroundColor Yellow }
    Write-Host "Presiona cualquier tecla para salir..."
    [void][System.Console]::ReadKey($true)
    exit
}

# Solicitar al usuario el nombre del archivo de salida
$outputBundleName = Read-Host "Ingrese el nombre base para el archivo de salida (ejemplo: 'MiPaquete.msixbundle')"

# Si el usuario no ingresa un nombre, usar el nombre del primer archivo .msix
if ([string]::IsNullOrWhiteSpace($outputBundleName)) {
    if ($filesToPack.Count -eq 0) {
        Write-Host "No se encontraron archivos .msix en la carpeta de entrada. No se puede determinar el nombre del archivo de salida." -ForegroundColor Red
        Write-Host "Presiona cualquier tecla para salir..."
        [void][System.Console]::ReadKey($true)
        exit
    }
    $outputBundleName = [System.IO.Path]::GetFileNameWithoutExtension($filesToPack[0].Name) + ".msixbundle"
    Write-Host "No se ingresó un nombre de archivo. Usando el nombre del primer archivo .msix para el archivo de salida: $outputBundleName" -ForegroundColor Green
}

# Quitar comillas dobles del outputBundleName usando regex
$outputBundle = [System.IO.Path]::Combine($inputFolder, $outputBundleName -replace '"', '')
Write-Host "El archivo de salida (sin comillas dobles) es: $outputBundle" -ForegroundColor Green

# Imprimir las rutas para depuración
Write-Host "La ruta del folder de contenido es: $inputFolder" -ForegroundColor Green
Write-Host "El archivo de salida es: $outputBundle" -ForegroundColor Green

# Ejecutar el comando makeappx y manejar errores
try {
    & $makeappxPath bundle /d $inputFolder /p $outputBundle
    Write-Host "El paquete MSIXBundle se creó con éxito." -ForegroundColor Green
} catch {
    Write-Host "Error: No se pudo crear el paquete MSIXBundle." -ForegroundColor Red
} finally {
    Write-Host "Presiona cualquier tecla para salir..."
    [void][System.Console]::ReadKey($true)
}
