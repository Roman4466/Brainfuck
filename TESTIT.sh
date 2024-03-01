#!/bin/bash

# Equivalent to "@ECHO OFF" in batch scripts
exec >test.res 2>&1

# Create or clear test.res
>test.res

# Append to test.res
echo "=== test1.b ===" >>test.res
./entry test1.b >>test.res

# Appending a blank line
echo >>test.res
echo "=== test2.b ===" >>test.res
echo "abcde" | ./entry test2.b >>test.res

echo >>test.res
echo "=== test3.b ===" >>test.res
echo "58􊌩1" | ./entry test3.b >>test.res

echo >>test.res
echo "=== test4.b ===" >>test.res
./entry test4.b >>test.res

# Use 'diff' instead of 'fc' for binary comparison, if needed. Adjust as necessary.
# diff -q test.res test.ok

# If test.ok is a text file and you want to compare ignoring whitespace:
diff test.res test.ok
