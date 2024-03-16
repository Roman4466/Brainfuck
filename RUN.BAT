@REM @ECHO OFF
@REM TASM cmp.asm
@REM TLINK cmp
@REM rename %1.com __entry.com
@REM del entry.com >nul
@REM rename __entry.com entry.com
@REM echo Testing...
@REM TESTIT
TASM entry.asm
TLINK /t entry.obj
