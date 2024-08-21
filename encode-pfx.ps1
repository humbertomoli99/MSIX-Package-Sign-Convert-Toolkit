# Define la ruta al archivo .pfx
$pfxFilePath = "C:\Users\humbe\OneDrive\Escritorio\TrackSave-WinUI_Key.pfx"

# Lee el archivo .pfx en un array de bytes
$pfxBytes = [System.IO.File]::ReadAllBytes($pfxFilePath)

# Convierte el array de bytes a una cadena Base64
$base64String = [System.Convert]::ToBase64String($pfxBytes)

# Guarda la cadena Base64 en un archivo de texto
$base64FilePath = "C:\Users\humbe\OneDrive\Escritorio\TrackSave-WinUI_Key.txt"
[System.IO.File]::WriteAllText($base64FilePath, $base64String)

Write-Output "El archivo Base64 ha sido guardado en $base64FilePath"