{   Subroutine STRING_PROGNAME (PNAME)
*
*   Return the name of the top level program running this process.
}
module string_progname;
define string_progname;
%include '/cognivision_links/dsee_libs/string/string2.ins.pas';
%include '/cognivision_links/dsee_libs/string/string_sys.ins.pas';

procedure string_progname (            {get name of program}
  in out  pname: univ string_var_arg_t); {returned string containing program name}

var
  s: string_leafname_t;                {scratch string}

begin
  s.max := sizeof(s.str);              {init local var string}

  if not progname_set then begin       {PROG_NAME not set to program name yet ?}
    prog_name.max := sizeof(prog_name.str); {init PROG_NAME var string}
    string_vstring (s, cmline_argp_p^[0]^, -1); {make var string of argument 0}
    string_generic_fnam (s, ''(0), prog_name); {prog name is leafname of argument 0}
    progname_set := true;              {PROG_NAME is now all set}
    end;

  string_copy (prog_name, pname);      {pass back program name string}
  end;
