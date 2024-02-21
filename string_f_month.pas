{   Make strings from month numbers.
}
module string_f_month;
define string_f_mon;
define string_f_month;
%include 'string2.ins.pas';

var
  smonth: array[1..12] of string_var4_t := [ {short month names}
    [str := 'Jan', len := 3, max := 4],
    [str := 'Feb', len := 3, max := 4],
    [str := 'Mar', len := 3, max := 4],
    [str := 'Apr', len := 3, max := 4],
    [str := 'May', len := 3, max := 4],
    [str := 'Jun', len := 3, max := 4],
    [str := 'Jul', len := 3, max := 4],
    [str := 'Aug', len := 3, max := 4],
    [str := 'Sep', len := 3, max := 4],
    [str := 'Oct', len := 3, max := 4],
    [str := 'Nov', len := 3, max := 4],
    [str := 'Dec', len := 3, max := 4]];
  fmonth: array[1..12] of string_var16_t := [ {full month names}
    [str := 'January  ', len := 7, max := 16],
    [str := 'February ', len := 8, max := 16],
    [str := 'March    ', len := 5, max := 16],
    [str := 'April    ', len := 5, max := 16],
    [str := 'May      ', len := 3, max := 16],
    [str := 'June     ', len := 4, max := 16],
    [str := 'July     ', len := 4, max := 16],
    [str := 'August   ', len := 6, max := 16],
    [str := 'September', len := 9, max := 16],
    [str := 'October  ', len := 7, max := 16],
    [str := 'November ', len := 8, max := 16],
    [str := 'December ', len := 8, max := 16]];
{
********************************************************************************
*
*   Subroutine STRING_F_MON (MSTR, MONTH)
*
*   Get the 3-character abbreviated month name from the 1-12 month number.  For
*   example MONTH of 1 results in "Jan", and 8 in "Aug".
*
*   The empty string is returned when MONTH is out of range.
}
procedure string_f_mon (               {get 3-char month name, like "Jan" "Feb"}
  in out  mstr: univ string_var_arg_t; {output string}
  in      month: sys_int_machine_t);   {1-12 number of month within year}
  val_param;

begin
  mstr.len := 0;                       {init the returned string to empty}
  if (month < 1) or (month > 12)       {abort on invalid month number}
    then return;

  string_copy (smonth[month], mstr);   {get the short month name}
  end;
{
********************************************************************************
*
*   Subroutine STRING_F_MONTH (MSTR, MONTH)
*
*   Get the full month name from the 1-12 month number.  For example MONTH of 1
*   results in "January", and 8 in "August".
*
*   The empty string is returned when MONTH is out of range.
}
procedure string_f_month (             {get full month name, like "January" "February"}
  in out  mstr: univ string_var_arg_t; {output string}
  in      month: sys_int_machine_t);   {1-12 number of month within year}
  val_param;

begin
  mstr.len := 0;                       {init the returned string to empty}
  if (month < 1) or (month > 12)       {abort on invalid month number}
    then return;

  string_copy (fmonth[month], mstr);   {get the full month name}
  end;
