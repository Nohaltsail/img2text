@echo off
setlocal EnableExtensions

set "SCRIPT_DIR=%~dp0"
for %%I in ("%SCRIPT_DIR%..") do set "ROOT=%%~fI"
set "CARGO_BIN=%USERPROFILE%\.cargo\bin"
set "SOURCE_DIR=%ROOT%\vendor\ocrs"
set "DIST_DIR=%ROOT%\dist"
set "TARGET_EXE=%SOURCE_DIR%\target\release\ocrs.exe"
set "OUTPUT_EXE=%DIST_DIR%\img2text.exe"
set "FETCH_MODELS=%SCRIPT_DIR%fetch-models-windows.bat"

if not exist "%SOURCE_DIR%" (
  echo Upstream source not found: %SOURCE_DIR%
  exit /b 1
)

set "PATH=%CARGO_BIN%;%PATH%"
where cargo >nul 2>nul || (
  echo Cargo not found. Run scripts\setup-windows.bat first.
  exit /b 1
)

echo [INFO] Building ocrs release binary
pushd "%SOURCE_DIR%"
cargo build -p ocrs-cli --release
if errorlevel 1 (
  popd
  exit /b 1
)
popd

if not exist "%DIST_DIR%" mkdir "%DIST_DIR%"
copy /Y "%TARGET_EXE%" "%OUTPUT_EXE%" >nul
if errorlevel 1 exit /b 1

call "%FETCH_MODELS%"
if errorlevel 1 exit /b 1

rem Copy MinGW runtime DLLs to improve portability of GNU-target binary.
call :copy_dll libgcc_s_seh-1.dll
call :copy_dll libstdc++-6.dll
call :copy_dll libwinpthread-1.dll

if exist "%ROOT%\models\strong\text-detection.rten" if exist "%ROOT%\models\strong\text-recognition.rten" (
  if not exist "%DIST_DIR%\models\strong" mkdir "%DIST_DIR%\models\strong"
  copy /Y "%ROOT%\models\strong\text-detection.rten" "%DIST_DIR%\models\strong\text-detection.rten" >nul
  copy /Y "%ROOT%\models\strong\text-recognition.rten" "%DIST_DIR%\models\strong\text-recognition.rten" >nul
)

echo [INFO] Binary ready: %OUTPUT_EXE%
endlocal
exit /b 0

:copy_dll
set "DLL_NAME=%~1"
for /f "delims=" %%P in ('where %DLL_NAME% 2^>nul') do (
  copy /Y "%%P" "%DIST_DIR%\%DLL_NAME%" >nul
  exit /b 0
)
exit /b 0

