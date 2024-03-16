@REM @ECHO OFF
@REM TASM cmp.asm
@REM TLINK cmp
@REM rename %1.com __entry.com
@REM del entry.com >nul
@REM rename __entry.com entry.com
@REM echo Testing...
@REM TESTIT
@REM echo === test1.b ===
@REM entry test1.b 
TASM entry.asm
TLINK /t entry.obj
@REM tasm /zi entry.asm
@REM tlink /v/3 entry.obj
@REM td entry.exe test1.b