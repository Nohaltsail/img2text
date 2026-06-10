@echo off
setlocal EnableExtensions

set "SCRIPT_DIR=%~dp0"
for %%I in ("%SCRIPT_DIR%..") do set "ROOT=%%~fI"
set "DIST_EXE=%ROOT%\dist\img2text.exe"
set "MODEL_PROFILE=%IMG2TEXT_MODEL_PROFILE%"
if "%MODEL_PROFILE%"=="" set "MODEL_PROFILE=default"
set "STRONG_DET=%ROOT%\dist\models\strong\text-detection.rten"
set "STRONG_REC=%ROOT%\dist\models\strong\text-recognition.rten"
set "IMAGE_PATH=%~1"
shift

if "%IMAGE_PATH%"=="" (
  echo Usage: scripts\run-windows.bat ^<image-path^> [ocr-args...]
  exit /b 1
)

if not exist "%DIST_EXE%" (
  echo Binary not found: %DIST_EXE%
  echo Run scripts\build-windows.bat first.
  exit /b 1
)

if /I "%MODEL_PROFILE%"=="strong" if exist "%STRONG_DET%" if exist "%STRONG_REC%" (
  "%DIST_EXE%" "%IMAGE_PATH%" --detect-model "%STRONG_DET%" --rec-model "%STRONG_REC%" %*
  exit /b %errorlevel%
)

"%DIST_EXE%" "%IMAGE_PATH%" %*
exit /b %errorlevel%

