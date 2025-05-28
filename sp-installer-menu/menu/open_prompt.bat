:: This is used to initialize the bash prompt on Windows.
@ECHO OFF

:: Workaround for
:: https://github.com/conda/conda/issues/14884
set "CONDA_EXE=#PREFIX#\Scripts\conda.exe"
call "#PREFIX#\Scripts\Activate.bat" base
:: Find first Python on path.
FOR /F "tokens=*" %%g IN ('where python') do (
    SET PYPATH=%%g
    goto :endloop
)
:endloop
FOR /F "tokens=*" %%g IN ('python --version') do (SET PYVER=%%g)
ECHO Using %PYVER% from %PYPATH%
ECHO This is Scientific Python #PKG_VERSION#
set WORKDIR=%USERPROFILE%\Documents\scientific-python
if not exist %WORKDIR% mkdir %WORKDIR%
pushd %WORKDIR%
