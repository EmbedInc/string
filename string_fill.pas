{   Subroutine STRING_FILL (S)
*
*   Fill the string S with blanks, out to its maximum allowable
*   length.  The length of string S is not altered.  This is useful
*   when using s.str directly instead of as part of a variable
*   length string.
}
module string_fill;
define string_fill;
%include 'string2.ins.pas';

procedure string_fill (                {fill unused string space with blanks}
  in out  s: univ string_var_arg_t);   {string to fill, length not altered}

var
  i: sys_int_machine_t;                {string index}

begin
  for i := s.len+1 to s.max do         {once for each unused char}
    s.str[i] := ' ';                   {write one blank}
  end;
