{   Subroutine STRING_CMLINE_SET (ARGC, ARGV, PGNAME)
*
*   This routine is used to register information about the call arguments that
*   is passed to top level programs.  The call to this routine is automatically
*   inserted at the start of every top level program by SST.  It must not be
*   declared in any inlude file since SST always writes the declaration as
*   if the routine was not already declared.
*
*   ARGC is the number of command line arguments, and ARGV is an array of pointers
*   to null-terminated strings which are the command line arguments.
*
*   This version is for the Microsoft Win32 API.  ARGC and ARGV are ignored,
*   since we use GetCommandLine to read the command line.
}
module string_cmline_set;
define string_cmline_set;
%include 'string2.ins.pas';
%include 'string_sys.ins.pas';

procedure sys_init;                    {init SYS library}
  extern;

procedure util_init;                   {init UTIL library}
  extern;

procedure string_cmline_set (
  val     argc: sys_int_machine_t;     {number of command line arguments}
  val     argv: univ_ptr;              {pointer to array of pointers}
  in      pgname: string);             {null-terminated program name string}

var
  str_p: ^string;                      {pointer to NULL terminated command line str}
  vstr: string_var4_t;                 {scratch var string}
  stat: sys_err_t;

begin
  sys_init;                            {one-time initialization of SYS library}
  util_init;                           {one-time initialization of UTIL library}

  vstr.max := size_char(vstr.str);     {init local var string}

  cmline_token_last.max := size_char(cmline_token_last.str); {init com block var str}
  cmline_token_last.len := 0;
  prog_name.max := size_char(prog_name.str);
  prog_name.len := 0;
  nodename.max := size_char(nodename.str);
  nodename.len := 0;
  vcmline.max := size_char(vcmline.str);
  vcmline.len := 0;

  string_vstring (prog_name, pgname, -1); {save program name in common block}
  progname_set := true;                {indicate PROG_NAME all set}

  str_p := GetCommandLineA;            {get pointer to raw command line string}
  if str_p <> nil then begin
    string_vstring (vcmline, str_p^, -1); {save var string copy of command line}
    end;

  vcmline_parse := 1;                  {init parse index to start of command line}
  string_token (                       {move past first token which is program name}
    vcmline, vcmline_parse, vstr, stat);
  vcmline_parse_start := vcmline_parse; {save parse index for first argument}

  cmline_next_n := 1;                  {next token will be first argument}
  cmline_reuse := false;               {init to not re-use previous token}
  end;
