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
}
module string_cmline_set;
define string_cmline_set;
%include 'string2.ins.pas';
%include 'string_sys.ins.pas';

procedure string_cmline_set (
  val     argc: sys_int_machine_t;     {number of command line arguments}
  in      argv: cmline_argp_t;         {array of pointers to argument strings}
  in      pgname: string);             {null-terminated program name string}

begin
  cmline_n_args := argc;               {save values in common block for later use}
  cmline_argp_p := addr(argv);

  prog_name.max := sizeof(prog_name.str); {init var string in common block}
  string_vstring (prog_name, pgname, -1); {save program name in common block}
  progname_set := true;                {indicate PROG_NAME all set}
  end;
