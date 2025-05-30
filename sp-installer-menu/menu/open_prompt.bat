:: Start a CMD command prompt.
@ECHO OFF
CALL "%~dp0#PKG_NAME#_activate.bat"
:: Find first Python on path.
FOR /F "tokens=*" %%g IN ('where python') do (
    SET PYPATH=%%g
    goto :endloop
)
:endloop
FOR /F "tokens=*" %%g IN ('python --version') do (SET PYVER=%%g)
ECHO Using %PYVER% from %PYPATH%
ECHO This is Scientific Python #PKG_VERSION#
