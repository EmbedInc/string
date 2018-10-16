{   Subroutine STRING_WRITE (S)
*
*   Write the contents of string S to standard output.  The output line will be
*   terminated after the string is written.
}
module string_WRITE;
define string_write;
%include 'string2.ins.pas';

procedure string_write (               {write string to standard output, close line}
  in      s: univ string_var_arg_t);   {string to write}

type
  long_str_t = array[1..30000] of char;

var
  long_p: ^long_str_t;

begin
  long_p := univ_ptr(addr(s.str));
  writeln (long_p^:s.len);
  end;
