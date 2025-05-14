:: This is used to initialize the bash prompt on Windows.
@ECHO OFF

call #PREFIX#\Scripts\Activate.bat
FOR /F "tokens=*" %%g IN ('python --version') do (SET PYVER=%%g)
FOR /F "tokens=*" %%g IN ('where python') do (SET PYPATH=%%g)

ECHO Using %PYVER% from %PYPATH%
ECHO This is Scientific Python #PKG_VERSION#
