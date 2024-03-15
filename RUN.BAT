@ECHO OFF
TASM cmp.asm
TLINK cmp
rename %1.com __entry.com
del entry.com >nul
rename __entry.com entry.com
echo Testing...
TESTIT
@REM echo === test1.b ===
@REM entry test1.b 
@REM tasm entry.asm
@REM tlink /t entry
