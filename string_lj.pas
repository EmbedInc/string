{   Subroutine STRING_LJ (S)
*
*   Left justify string S by removing leading spaces.
}
module string_lj;
define string_lj;
%include '/cognivision_links/dsee_libs/string/string2.ins.pas';

procedure string_lj (                  {left justify string by removing leading spaces}
  in out  s: univ string_var_arg_t);   {string}

var
  i, j, k: sys_int_machine_t;          {index into string}

begin
  for i := 1 to s.len do begin         {scan all characters backwards}
    if s.str[i] = ' '                  {is this a blank character ?}
      then next                        {still haven't hit non-blank}
      else begin                       {this was a non-blank}
        k := 0;
        for j := i to s.len do begin
          k := k + 1;                  {increment new location of character}
          s.str[k] := s.str[j];        {move character to new location}
          end;
        s.len := s.len - (i - 1);      {set new string length}
        return;                        {all done}
        end                            {done with non_blank}
      ;
    end;                               {back and do next character}
  s.len := 0;                          {only blanks, null string}
  end;
