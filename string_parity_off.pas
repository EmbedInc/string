{   Subroutine STRING_PARITY_OFF (S)
*
*   Turn the parity bit off for each byte in the string.
}
module string_parity_off;
define string_parity_off;
%include 'string2.ins.pas';

procedure string_parity_off (          {turn parity bits off for all chars in string}
  in out  s: univ string_var_arg_t);   {string}

var
  i: sys_int_machine_t;                {loop counter}

begin
  for i := 1 to s.len do begin         {once for each character in string}
    s.str[i] := chr(ord(s.str[i]) & 8#177); {mask off high bit of byte}
    end;                               {back for next character}
  end;
