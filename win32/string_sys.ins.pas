{   Private include file for system-dependent routines in STRING library.
*
*   This version is for the Microsoft Win32 API.  We access the command line
*   with a call to GetCommandLine, which returns a pointer to a null-terminated
*   string.  We parse individual tokens ourselves, using the rules for
*   STRING_TOKEN.
}
%include '/cognivision_links/dsee_libs/sys/sys_sys2.ins.pas';

var (string_sys)
  vcmline: string_var8192_t;           {saved var string copy of command line}
  vcmline_parse: string_index_t;       {VCMLINE parse index}
  vcmline_parse_start: string_index_t; {parse index for start of cmline argument}
