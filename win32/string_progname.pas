{   Subroutine STRING_PROGNAME (PNAME)
*
*   Return the name of the top level program running this process.
*
*   This version is for any OS where we are given the entire command line and
*   parse it ourselves, and where the first token on that command line is
*   the program name.
}
module string_progname;
define string_progname;
%include '/cognivision_links/dsee_libs/string/string2.ins.pas';
%include '/cognivision_links/dsee_libs/string/string_sys.ins.pas';

procedure string_progname (            {get name of program}
  in out  pname: univ string_var_arg_t); {returned string containing program name}

var
  s: string_leafname_t;                {scratch string}
  p: string_index_t;                   {scartch parse index}
  stat: sys_err_t;

begin
  s.max := sizeof(s.str);              {init local var string}

  if not progname_set then begin       {PROG_NAME not set to program name yet ?}
    prog_name.max := sizeof(prog_name.str); {init PROG_NAME var string}
    p := 1;                            {set for getting first token on command line}
    string_token (vcmline, p, s, stat); {try to parse command name token}
    string_downcase (s);
    string_generic_fnam (s, '.exe .com'(0), prog_name); {make generic prog name}
    progname_set := true;              {PROG_NAME is now all set}
    end;

  string_copy (prog_name, pname);      {pass back program name string}
  end;
