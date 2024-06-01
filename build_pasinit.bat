@echo off
rem
rem   Set up for building a Pascal module.
rem
call build_vars

call src_get %srcdir% %libname%.ins.pas
call src_get %srcdir% %libname%2.ins.pas
call src_get %srcdir% %libname%_sys.ins.pas
call src_get %srcdir% string2.ins.pas
call src_get %srcdir% string4.ins.pas
call src_get %srcdir% string16.ins.pas
call src_get %srcdir% string32.ins.pas
call src_get %srcdir% string80.ins.pas
call src_get %srcdir% string132.ins.pas
call src_get %srcdir% string256.ins.pas
call src_get %srcdir% string8192.ins.pas
call src_get %srcdir% string_leafname.ins.pas
call src_get %srcdir% string_treename.ins.pas

call src_getbase
call src_getfrom sys sys_sys2.ins.pas
call src_getfrom file cogserve.ins.pas
call src_getfrom math math.ins.pas

make_debug debug_switches.ins.pas
call src_builddate "%srcdir%"
