@echo off
setlocal EnableExtensions

set "SCRIPT_DIR=%~dp0"
for %%I in ("%SCRIPT_DIR%..") do set "ROOT=%%~fI"
set "DIST_MODELS=%ROOT%\dist\models"
set "CACHE_MODELS=%USERPROFILE%\.cache\ocrs"

set "DET_FILE=text-detection.rten"
set "REC_FILE=text-recognition.rten"
set "DET_URL=https://ocrs-models.s3-accelerate.amazonaws.com/text-detection.rten"
set "REC_URL=https://ocrs-models.s3-accelerate.amazonaws.com/text-recognition.rten"
set "DET_SHA256=F15CFB56BD02C4BF478A20343986504A1F01E1665C2B3A0AD66340F054B1B5CA"
set "REC_SHA256=E484866D4CCE403175BD8D00B128FEB08AB42E208DE30E42CD9889D8F1735A6E"

if not exist "%DIST_MODELS%" mkdir "%DIST_MODELS%"

call :ensure_model "%DET_FILE%" "%DET_URL%" "%DET_SHA256%"
if errorlevel 1 exit /b 1
call :ensure_model "%REC_FILE%" "%REC_URL%" "%REC_SHA256%"
if errorlevel 1 exit /b 1

echo [INFO] Offline models are ready in %DIST_MODELS%
endlocal
exit /b 0

:ensure_model
set "NAME=%~1"
set "URL=%~2"
set "EXPECTED_HASH=%~3"
set "DEST=%DIST_MODELS%\%NAME%"
set "CACHE=%CACHE_MODELS%\%NAME%"

if exist "%DEST%" (
  call :verify_hash "%DEST%" "%EXPECTED_HASH%"
  if not errorlevel 1 goto :eof
)

if exist "%CACHE%" (
  copy /Y "%CACHE%" "%DEST%" >nul
  if errorlevel 1 exit /b 1
  call :verify_hash "%DEST%" "%EXPECTED_HASH%"
  if not errorlevel 1 goto :eof
)

echo Downloading %NAME% ...
curl.exe -L "%URL%" -o "%DEST%"
if errorlevel 1 exit /b 1
call :verify_hash "%DEST%" "%EXPECTED_HASH%"
if errorlevel 1 exit /b 1
goto :eof

:verify_hash
set "FILE=%~1"
set "EXPECTED=%~2"
for /f %%H in ('powershell -NoProfile -Command "(Get-FileHash -Algorithm SHA256 -Path '%FILE%').Hash"') do set "ACTUAL=%%H"
if /I "%ACTUAL%"=="%EXPECTED%" (
  exit /b 0
)
echo SHA256 mismatch for %FILE%
echo Expected: %EXPECTED%
echo Actual  : %ACTUAL%
exit /b 1

