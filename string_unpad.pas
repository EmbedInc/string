{   Subroutine STRING_UNPAD (S)
*
*   Delete all the trailing spaces from string S.
}
module string_unpad;
define string_unpad;
%include 'string2.ins.pas';

procedure string_unpad (               {delete all trailing spaces from string}
  in out  s: univ string_var_arg_t);   {string}

var
  i: sys_int_machine_t;                {index into string}

begin
  for i := s.len downto 1 do begin     {scan all characters backwards}
    if s.str[i] = ' '                  {is this a blank character ?}
      then next                        {still haven't hit non-blank}
      else begin                       {this was a non-blank}
        s.len := i;                    {set new string length}
        return;                        {all done}
        end;                           {done with non_blank}
    end;                               {back and do next character}
  s.len := 0;                          {only blanks, null string}
  end;
