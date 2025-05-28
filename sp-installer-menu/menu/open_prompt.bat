:: This is used to initialize the bash prompt on Windows.
@ECHO OFF

:: Workaround for
:: https://github.com/scientific-python/installer/pull/3#issuecomment-2907866303
set "CONDA_EXE=#PREFIX#\Scripts\conda.exe"
call "#PREFIX#\Scripts\Activate.bat" base
FOR /F "tokens=*" %%g IN ('python --version') do (SET PYVER=%%g)
FOR /F "tokens=*" %%g IN ('where python') do (SET PYPATH=%%g)

ECHO Using %PYVER% from %PYPATH%
ECHO This is Scientific Python #PKG_VERSION#
set WORKDIR=%USERPROFILEDIR%\Documents\scientific-python
if not exist %WORKDIR% mkdir %WORKDIR%
pushd %WORKDIR%
