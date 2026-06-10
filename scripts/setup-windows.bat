@echo off
setlocal EnableExtensions

set "SCRIPT_DIR=%~dp0"
for %%I in ("%SCRIPT_DIR%..") do set "ROOT=%%~fI"
set "CARGO_BIN=%USERPROFILE%\.cargo\bin"
set "RUSTUP_INIT=%ROOT%\rustup-init.exe"

echo [INFO] Checking Windows build prerequisites
where git >nul 2>nul || (
  echo Git is not installed or not available in PATH.
  exit /b 1
)

where gcc >nul 2>nul || (
  echo Warning: gcc was not found in PATH. A MinGW-w64 GCC toolchain is recommended for this Windows build path.
)

if not exist "%CARGO_BIN%\rustup.exe" (
  echo [INFO] rustup not found. Downloading installer...
  powershell -NoProfile -ExecutionPolicy Bypass -Command "Invoke-WebRequest -Uri 'https://win.rustup.rs/x86_64' -OutFile '%RUSTUP_INIT%'"
  if errorlevel 1 exit /b 1
  echo [INFO] Installing Rust stable GNU toolchain
  "%RUSTUP_INIT%" -y --default-toolchain stable-gnu
  if errorlevel 1 exit /b 1
)

set "PATH=%CARGO_BIN%;%PATH%"
echo [INFO] Ensuring GNU toolchain is available
rustup toolchain install stable-x86_64-pc-windows-gnu
if errorlevel 1 exit /b 1
rustup default stable-x86_64-pc-windows-gnu
if errorlevel 1 exit /b 1

echo [INFO] Environment ready
rustc -V
cargo -V
where gcc

endlocal

