{   Subroutine STRING_LEN (S)
*
*   Set the length of the string.  The string is assumed to be padded up to
*   its maximum length with blanks, and that its length is set to garbage.
*   The string length will be set to just include the last non-blank character.
*
*   WARNING:  Don't use this subroutine unless the entire string array (not just
*     the part up to array.len) has a padded string in it.  Otherwise the
*     resulting string can have garbage on the end.
}
module string_len;
define string_len;
%include 'string2.ins.pas';

procedure string_len (                 {set length by unpadding max length string}
  in out  s: univ string_var_arg_t);   {string}

var
  i: sys_int_machine_t;                {index into string}

begin
  for i := s.max downto 1 do begin     {scan all characters backwards}
    if s.str[i] = ' '                  {is this a blank character ?}
      then next                        {still haven't hit non-blank}
      else begin                       {this was a non-blank}
        s.len := i;                    {set new string length}
        return;                        {all done}
        end;                           {done with non_blank}
    end;                               {back and do next character}
  s.len := 0;                          {only blanks, null string}
  end;
