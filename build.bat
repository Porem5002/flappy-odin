@echo off

if "%1%" == "clean" (
    echo Cleaning...
    del *.exe
    del *.pdb
) else if "%1%" == "release" (
    echo Building Release Build...
    odin build .\src -o:minimal -subsystem:windows -out:flappy_odin.exe
) else (
    echo Building Debug Build...
    odin build .\src -debug -o:none -out:flappy_odin.exe
)