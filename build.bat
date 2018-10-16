@echo off
rem
rem   BUILD [-dbg]
rem
rem   Build everything from the STRING source directory.
rem
setlocal
call godir (cog)source/string
call build_lib
call build_progs
