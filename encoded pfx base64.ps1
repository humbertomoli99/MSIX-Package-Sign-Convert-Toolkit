# Solicitar la ruta del archivo PFX
$pfxPath = Read-Host "Introduce la ruta completa del archivo PFX"

# Comprobar si el archivo existe
if (-not (Test-Path -Path $pfxPath)) {
    Write-Host "El archivo PFX no se encontró en la ruta especificada. Inténtalo de nuevo."
    exit
}

# Solicitar el nombre del archivo de salida
$outputName = Read-Host "Introduce el nombre del archivo de salida (sin extensión) o presiona Enter para usar el mismo nombre que el archivo PFX"

# Obtener el nombre del archivo PFX original sin extensión
$certName = [System.IO.Path]::GetFileNameWithoutExtension($pfxPath)

# Si no se especifica un nombre, usar el nombre del archivo PFX
if (-not $outputName) {
    $outputName = $certName
}

# Añadir la extensión .txt automáticamente
$outputName += ".txt"

# Construir la ruta completa del archivo de salida
$outputPath = Join-Path -Path (Split-Path $pfxPath) -ChildPath $outputName

# Leer el archivo PFX en bytes
$pfxBytes = [System.IO.File]::ReadAllBytes($pfxPath)

# Codificar los bytes en Base64
$base64EncodedPfx = [Convert]::ToBase64String($pfxBytes)

# Mostrar un mensaje al usuario
Write-Host "Codificando el archivo '$certName' en formato Base64..."

# Escribir la cadena Base64 en el archivo de salida
[System.IO.File]::WriteAllText($outputPath, $base64EncodedPfx)

# Informar al usuario del éxito de la operación
Write-Host "Certificado '$certName' exportado correctamente a Base64."
Write-Host "Archivo guardado como '$outputName' en la misma carpeta del archivo PFX."

# Confirmar finalización
Write-Host "Proceso completado con éxito."

# Prevenir que el terminal se cierre automáticamente
Read-Host "Presiona Enter para cerrar el terminal"
