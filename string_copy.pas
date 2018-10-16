{   Subroutine STRING_COPY (S1,S2)
*
*   Copy the contents of string S1 into string S2.  This is different
*   from doing a pascal assignment statement in several ways.  First,
*   only the string itself and not the unused characters past the end
*   of the string are copied.  Second, the two strings need not have
*   the same max length.  In this case pascal would not allow one to
*   be assigned to the other.
*
*   If the length of S1 is longer than the max length of S2, then the
*   string in S2 is truncated.
}
module string_copy;
define string_copy;
%include 'string2.ins.pas';

procedure string_copy (                {copy one string into another}
  in      s1: univ string_var_arg_t;   {input string}
  in out  s2: univ string_var_arg_t);  {output string}

var
  n: sys_int_machine_t;                {number of chars to copy}
  i: sys_int_machine_t;                {string index}

begin
  n := s1.len;                         {init number of chars to copy}
  if n > s2.max then n := s2.max;      {truncate to S2 max length}
  for i := 1 to n do                   {once for each character}
    s2.str[i] := s1.str[i];            {copy a character}
  s2.len := n;                         {set length of string in S2}
  end;
