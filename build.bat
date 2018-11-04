@echo off
rem
rem   Build everything from this source directory.
rem
setlocal
call godir "(cog)source/string"

call build_lib
call build_progs
