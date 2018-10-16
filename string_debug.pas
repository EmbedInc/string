{   Subroutine STRING_DEBUG (S)
*
*   Print the string contents enclosed in quotes ("), the string length,
*   and the string's maximum allowable length.  This is intended for
*   debug purposes.
}
module string_debug;
define string_debug;
%include 'string2.ins.pas';

procedure string_debug (               {print length, max, and contents of string}
  in      s: univ string_var_arg_t);   {string to print data of}

begin
  writeln ('"', s.str:s.len, '"');
  writeln ('Length = ', s.len, ', Max size = ', s.max, '.');
  end;
