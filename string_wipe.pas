module string_wipe;
define string_wipe;
%include 'string2.ins.pas';
{
********************************************************************************
*
*   STRING_WIPE (S)
*
*   Set the string to empty and wipe all characters by setting them to NULL.
*   This completely erases any previous information in the string.
}
procedure string_wipe (                {set string to empty, wipe all chars to NULL}
  in out  s: univ string_var_arg_t);   {string to wipe}
  val_param;

var
  ii: sys_int_machine_t;

begin
  for ii := 1 to s.max do begin
    s.str[ii] := chr(0);
    end;
  s.len := 0;
  end;
