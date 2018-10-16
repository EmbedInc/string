{   Convert between strings and portable time values.
}
module string_time;
%include 'string2.ins.pas';
define string_t_time1;
{
********************************************************************************
*
*   Subroutine STRING_T_TIME1 (S, LOCAL, TIME, STAT)
*
*   Convert the string S to the time T.  The string is interpreted as a local
*   time when LOCAL is TRUE, otherwise as a coordinated universal time.
}
procedure string_t_time1 (             {make time from string}
  in      s: univ string_var_arg_t;    {input string, YYYY/MM/DD.HH:MM:SS.SSS}
  in      local: boolean;              {interpret as local time, not coor univ}
  out     time: sys_clock_t;           {returned absolute time}
  out     stat: sys_err_t);            {returned completion status}
  val_param;

var
  date: sys_date_t;                    {intermediate date/time descriptor}

begin
  string_t_date1 (                     {convert the string to its expanded date/time}
    s,                                 {the input string}
    local,                             {select local versus coordinate universal time}
    date,                              {returned expanded date/time}
    stat);
  if sys_error(stat) then return;

  time := sys_clock_from_date (date);  {convert to absolute time}
  end;
