{   Subroutine STRING_PAD (S)
*
*   Pad the string S with blanks, out to its maximum allowable
*   length.  The new length of S will be its maximum length.
}
module string_pad;
define string_pad;
%include '/cognivision_links/dsee_libs/string/string2.ins.pas';

procedure string_pad (                 {extend string to max length by adding blanks}
  in out  s: univ string_var_arg_t);   {string}

var
  i: sys_int_machine_t;                {string index}

begin
  for i := s.len+1 to s.max do         {once for each unused char}
    s.str[i] := ' ';                   {write one blank}
  s.len := s.max;                      {set S to its maximum length}
  end;
