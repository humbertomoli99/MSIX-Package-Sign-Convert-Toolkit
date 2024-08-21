# Obtener el directorio base de los SDKs de Windows
$windowsKitsPath = "C:\Program Files (x86)\Windows Kits\10\bin"

# Obtener las versiones de SDK disponibles en el sistema
$availableSdks = Get-ChildItem -Directory -Path $windowsKitsPath | Where-Object { $_.Name -match '^\d+\.\d+\.\d+\.\d+$' }

# Verificar si se encontraron SDKs
if ($availableSdks.Count -eq 0) {
    Write-Host "No se encontraron versiones de SDK de Windows instaladas." -ForegroundColor Red
    exit
}

# Filtrar solo los SDKs que contienen signtool.exe
$sdksWithSignTool = @()
foreach ($sdk in $availableSdks) {
    $signtoolPath = Join-Path -Path $sdk.FullName -ChildPath "x64\signtool.exe"
    if (Test-Path $signtoolPath) {
        $sdksWithSignTool += $sdk
    }
}

# Verificar si se encontraron SDKs con signtool.exe
if ($sdksWithSignTool.Count -eq 0) {
    Write-Host "No se encontraron SDKs de Windows que contengan signtool.exe." -ForegroundColor Red
    exit
}

# Mostrar las opciones de SDKs disponibles con signtool.exe con numeración
Write-Host "Se encontraron las siguientes versiones de SDK de Windows que contienen signtool.exe:" -ForegroundColor Cyan
for ($i = 0; $i -lt $sdksWithSignTool.Count; $i++) {
    $sdkVersion = $sdksWithSignTool[$i].Name
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
if (-not [int]::TryParse($sdkIndex, [ref]$sdkIndex) -or $sdkIndex -lt 1 -or $sdkIndex -gt $sdksWithSignTool.Count) {
    Write-Host "Selección no válida. Saliendo del script." -ForegroundColor Red
    exit
}

# Obtener la ruta del SDK seleccionado
$sdkPath = $sdksWithSignTool[$sdkIndex - 1]
$signtoolPath = Join-Path -Path $sdkPath.FullName -ChildPath "x64\signtool.exe"

# Solicitar al usuario que seleccione el archivo .pfx (clave) arrastrándolo a la consola
$keyFile = Read-Host "Arrastre el archivo .pfx a la consola y presione Enter"

# Verificar si el archivo .pfx existe
if (-not (Test-Path $keyFile)) {
    Write-Host "El archivo de clave no se encontró." -ForegroundColor Red
    exit
}

# Obtener el nombre del primer archivo .msix en el directorio del script
$scriptDir = Split-Path -Path $MyInvocation.MyCommand.Path -Parent
$msixFile = Get-ChildItem -Path $scriptDir -Filter *.msix | Select-Object -First 1

# Verificar si se encontró un archivo .msix
if (-not $msixFile) {
    Write-Host "No se encontró ningún archivo .msix en el directorio del script." -ForegroundColor Red
    exit
}

# Construir la ruta del paquete .msixbundle
$bundleFile = $msixFile.FullName -replace '\.msix$', '.msixbundle'

# Solicitar al usuario que seleccione el algoritmo de hash, con SHA256 como default
$hashAlgorithm = Read-Host "Ingrese el algoritmo de hash (presione Enter para usar SHA256)" 
if (-not $hashAlgorithm) {
    $hashAlgorithm = "SHA256"
}

# Intentos de firma con manejo de errores
$maxAttempts = 3
$attempt = 0
$success = $false

while ($attempt -lt $maxAttempts -and -not $success) {
    # Solicitar la contraseña para el archivo .pfx
    $password = Read-Host "Ingrese la contraseña del archivo .pfx (Intento $($attempt + 1) de $maxAttempts)" -AsSecureString
    
    try {
        # Comando para firmar el paquete
        Write-Host "Firmando el paquete con el SDK seleccionado..." -ForegroundColor Cyan
        Start-Process -FilePath $signtoolPath -ArgumentList @("sign", "/fd", $hashAlgorithm, "/a", "/f", $keyFile, "/p", $password, $bundleFile) -NoNewWindow -Wait -ErrorAction Stop
        Write-Host "El paquete ha sido firmado exitosamente." -ForegroundColor Green
        $success = $true
    } catch {
        Write-Host "Error al firmar el paquete: $_. Exception.Message" -ForegroundColor Red
        $attempt++
        if ($attempt -lt $maxAttempts) {
            Write-Host "Intente de nuevo." -ForegroundColor Yellow
        } else {
            Write-Host "Número máximo de intentos alcanzado. Saliendo del script." -ForegroundColor Red
            exit
        }
    }
}
