@echo off
setlocal EnableExtensions

set "SCRIPT_DIR=%~dp0"
for %%I in ("%SCRIPT_DIR%..") do set "ROOT=%%~fI"
set "BUILD_SCRIPT=%SCRIPT_DIR%build-windows.bat"
set "DIST_DIR=%ROOT%\dist"
set "PKG_ROOT=%ROOT%\release"
set "PKG_NAME=img2text-portable-windows-x64"
set "PKG_DIR=%PKG_ROOT%\%PKG_NAME%"
set "ZIP_PATH=%PKG_ROOT%\%PKG_NAME%.zip"
set "PKG_ASSETS=%ROOT%\packaging\windows-portable"

if not exist "%BUILD_SCRIPT%" (
  echo Build script not found: %BUILD_SCRIPT%
  exit /b 1
)

echo [INFO] Building runtime files
call "%BUILD_SCRIPT%"
if errorlevel 1 exit /b 1

if not exist "%DIST_DIR%\img2text.exe" (
  echo Runtime binary not found: %DIST_DIR%\img2text.exe
  exit /b 1
)

if not exist "%PKG_ROOT%" mkdir "%PKG_ROOT%"
if exist "%PKG_DIR%" rmdir /s /q "%PKG_DIR%"
mkdir "%PKG_DIR%"

echo [INFO] Copying app files
copy /Y "%DIST_DIR%\img2text.exe" "%PKG_DIR%\img2text.exe" >nul
for %%F in (libgcc_s_seh-1.dll libstdc++-6.dll libwinpthread-1.dll) do (
  if exist "%DIST_DIR%\%%F" copy /Y "%DIST_DIR%\%%F" "%PKG_DIR%\%%F" >nul
)
xcopy "%DIST_DIR%\models" "%PKG_DIR%\models" /E /I /Y >nul
copy /Y "%PKG_ASSETS%\README.txt" "%PKG_DIR%\README.txt" >nul

if exist "%ZIP_PATH%" del /f /q "%ZIP_PATH%"
powershell -NoProfile -ExecutionPolicy Bypass -Command "Compress-Archive -Path '%PKG_DIR%\*' -DestinationPath '%ZIP_PATH%'"
if errorlevel 1 exit /b 1

echo [INFO] Package ready: %ZIP_PATH%
endlocal

