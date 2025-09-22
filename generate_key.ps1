# Script para generar clave de firma de Android
# Ejecutar como administrador si es necesario

$javaPath = "C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe"

if (Test-Path $javaPath) {
    Write-Host "Generando clave de firma..."
    & $javaPath -genkey -v -keystore android\app\mindspace-release-key.keystore -alias mindspace -keyalg RSA -keysize 2048 -validity 10000 -storepass mindspace123 -keypass mindspace123 -dname "CN=MindSpace, OU=Development, O=MindSpace, L=City, S=State, C=US"
    Write-Host "Clave generada exitosamente en android\app\mindspace-release-key.keystore"
} else {
    Write-Host "Java no encontrado en la ruta esperada. Intentando con flutter..."
    # Usar flutter para generar la clave
    flutter build apk --release
    Write-Host "Usando clave de debug temporalmente..."
}
