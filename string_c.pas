{   Module of routines that deal with C-style string issues.
}
module string_c;
define string_t_c;
define string_terminate_null;
%include '/cognivision_links/dsee_libs/string/string2.ins.pas';
{
**********************************************************************
*
*   Subroutine STRING_T_C (VSTR, CSTR, CSTR_LEN)
*
*   Convert the var string VSTR to the C-style string CSTR.  CSTR_LEN is the
*   maximum number of characters (including the NULL terminator) we may write
*   into CSTR.  CSTR will always be NULL terminated.  If the input string
*   contains more thatn CSTR_LEN-1 characters only the first LEN-1 characters
*   are copied and the NULL terminator is written to the last character position.
}
procedure string_t_c (                 {convert var string to C-style NULL term str}
  in      vstr: univ string_var_arg_t; {input var string}
  out     cstr: univ string;           {returned null terminated C string}
  in      cstr_len: sys_int_machine_t); {max characters allowed to write into CSTR}
  val_param;

var
  n: sys_int_machine_t;                {number of characters to really copy}
  i: sys_int_machine_t;                {loop counter}

begin
  if cstr_len <= 0 then return;        {nothing to do ?}
  n := max(0, min(vstr.len, cstr_len - 1)); {make number of chars to actually copy}

  for i := 1 to n do begin             {copy the text characters}
    cstr[i] := vstr.str[i];
    end;

  cstr[n + 1] := chr(0);               {add NULL terminator to end of string}
  end;
{
**********************************************************************
*
*   Subroutine STRING_TERMINATE_NULL (S)
*
*   Insure that the body of S is NULL terminated, as compatible with C-style
*   strings.  Is S is not filled to its maximum number of characters, then the
*   NULL is added after the last character without the var string length being
*   effected.  If S is at its maximum length, then the last character is replaced
*   by the NULL, and the var string length is decremented by one.
}
procedure string_terminate_null (      {insure .STR field is null-terminated}
  in out  s: univ string_var_arg_t);   {hidden NULL will be added after string body}

begin
  if s.max <= 0 then return;           {nothing we can do ?}

  if s.len < s.max
    then begin                         {S is not at its maximum length}
      s.str[s.len + 1] := chr(0);      {put NULL terminator after last character}
      end
    else begin                         {S is already maxed out}
      s.str[s.max] := chr(0);          {stomp on last character to become NULL}
      s.len := s.max - 1;              {indicate number of real string chars left}
      end
    ;
  end;
