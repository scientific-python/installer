:: Activate environment and change to workdir.
@ECHO OFF
SET "SP_SCRIPTS_DIR=%~dp0..\Scripts"
SET "SP_WORKDIR=%USERPROFILE%\Documents\scientific-python"
:: Workaround for
:: https://github.com/conda/conda/issues/14884
SET "CONDA_EXE=%SP_SCRIPTS_DIR%\conda.exe"
CALL "%SP_SCRIPTS_DIR%\Activate.bat"
if not exist "%SP_WORKDIR%" mkdir "%SP_WORKDIR%"
pushd "%SP_WORKDIR%"

