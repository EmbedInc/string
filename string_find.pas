{   Subroutine STRING_FIND (TOKEN,S,I)
*
*   Search for the substring TOKEN in the string S.  I is set to the first character
*   position in S of the substring.  If the substring is not found in S, then
*   I is set to zero.
}
module string_find;
define string_find;
%include '/cognivision_links/dsee_libs/string/string2.ins.pas';

procedure string_find (                {find substring in a reference string}
  in      token: univ string_var_arg_t; {substring to look for}
  in      s: univ string_var_arg_t;    {string to look for substring in}
  out     i: string_index_t);          {substring start index, 0 = not found}

var
  j, k: sys_int_machine_t;             {loop counters}

label
  next_j;

begin
  for j := 1 to s.len-token.len+1 do begin {once for each possible start character}
    for k := 1 to token.len do begin   {once for each character in substring}
      if s.str[j+k-1] <> token.str[k]  {found a mismatch ?}
        then goto next_j;              {try at next S char position}
      end;                             {back and try next char at this position}
    i := j;                            {found substring, it starts here}
    return;                            {pass back start index to substring}
next_j:
    end;                               {back and try next character position}

  i := 0;                              {indicate substring not found}
  end;
