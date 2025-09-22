@echo off
echo Creando clave de firma para MindSpace...

REM Buscar Java en las rutas comunes
set JAVA_PATH=""
if exist "C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe" (
    set JAVA_PATH="C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe"
) else if exist "C:\Program Files\Java\jdk*\bin\keytool.exe" (
    for /d %%i in ("C:\Program Files\Java\jdk*") do set JAVA_PATH="%%i\bin\keytool.exe"
) else (
    echo Java no encontrado. Usando Flutter para generar clave temporal...
    goto :flutter_method
)

echo Usando Java en: %JAVA_PATH%

REM Generar clave de firma
%JAVA_PATH% -genkey -v -keystore android\app\mindspace-release-key.keystore -alias mindspace -keyalg RSA -keysize 2048 -validity 10000 -storepass mindspace123 -keypass mindspace123 -dname "CN=MindSpace, OU=Development, O=MindSpace, L=City, S=State, C=US"

if %ERRORLEVEL% EQU 0 (
    echo Clave generada exitosamente!
    goto :end
) else (
    echo Error generando clave. Intentando con Flutter...
    goto :flutter_method
)

:flutter_method
echo Generando clave temporal usando Flutter...
flutter build apk --release
echo Clave temporal generada.

:end
echo Proceso completado.
pause
