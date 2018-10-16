{   Convert between strings and a date/time.
}
module string_date;
%include 'string2.ins.pas';
define string_t_date1;
{
********************************************************************************
*
*   Subroutine STRING_T_DATE1 (S, LOCAL, DATE, STAT)
*
*   Convert the string S to the date/time DATE.  The complete format for the
*   input string is "YYYY/MM/DD.HH:MM:SS", where the seconds field (SS) may
*   be floating point.  Any of the fields after the year may be omitted, in
*   which case they default to the earliest time within the range specified by
*   the fields to the left.  LOCAL of TRUE causes the string to be interpret as
*   a local time, otherwise it is interpreted as coordinate universal time.
}
procedure string_t_date1 (             {make date/time from string}
  in      s: univ string_var_arg_t;    {input string, YYYY/MM/DD.HH:MM:SS.SSS}
  in      local: boolean;              {interpret as local time, not coor univ}
  out     date: sys_date_t;            {returned date/time, filled in for local time}
  out     stat: sys_err_t);            {returned completion status}
  val_param;

var
  pick: sys_int_machine_t;             {number of delimiter picked from list}
  tk: string_var80_t;                  {token parsed from input string}
  p: string_index_t;                   {input string parse index}

label
  have_date, err_at_p;

begin
  tk.max := size_char(tk.str);         {init local var string}

  p := 1;                              {init S parse index}
  string_token_anyd (                  {extract year number field}
    s, p,                              {input string and parse index}
    '/', 1,                            {list of token delimiters}
    0,                                 {first N delimiters that may be repeated}
    [],                                {no special opions}
    tk,                                {parsed token}
    pick,                              {index to terminating delimiter found}
    stat);
  if sys_error(stat) then return;
  if tk.len < 1 then goto err_at_p;    {year can't be the empty string}
  string_t_int (tk, date.year, stat);  {convert year string to integer}
  if sys_error(stat) then return;

  date.month := 0;                     {init remaining fields to their defaults}
  date.day := 0;
  date.hour := 0;
  date.minute := 0;
  date.second := 0;
  date.sec_frac := 0.0;

  string_token_anyd (                  {extract month number field}
    s, p,                              {input string and parse index}
    '/', 1,                            {list of token delimiters}
    0,                                 {first N delimiters that may be repeated}
    [],                                {no special opions}
    tk,                                {parsed token}
    pick,                              {index to terminating delimiter found}
    stat);
  if string_eos(stat) then goto have_date;
  if sys_error(stat) then return;
  string_t_int (tk, date.month, stat);
  if sys_error(stat) then return;
  date.month := date.month - 1;

  string_token_anyd (                  {extract day number field}
    s, p,                              {input string and parse index}
    '.', 1,                            {list of token delimiters}
    0,                                 {first N delimiters that may be repeated}
    [],                                {no special opions}
    tk,                                {parsed token}
    pick,                              {index to terminating delimiter found}
    stat);
  if string_eos(stat) then goto have_date;
  if sys_error(stat) then return;
  string_t_int (tk, date.day, stat);
  if sys_error(stat) then return;
  date.day := date.day - 1;

  string_token_anyd (                  {extract hour number field}
    s, p,                              {input string and parse index}
    ':', 1,                            {list of token delimiters}
    0,                                 {first N delimiters that may be repeated}
    [],                                {no special opions}
    tk,                                {parsed token}
    pick,                              {index to terminating delimiter found}
    stat);
  if string_eos(stat) then goto have_date;
  if sys_error(stat) then return;
  string_t_int (tk, date.hour, stat);
  if sys_error(stat) then return;

  string_token_anyd (                  {extract minute number field}
    s, p,                              {input string and parse index}
    ':', 1,                            {list of token delimiters}
    0,                                 {first N delimiters that may be repeated}
    [],                                {no special opions}
    tk,                                {parsed token}
    pick,                              {index to terminating delimiter found}
    stat);
  if string_eos(stat) then goto have_date;
  if sys_error(stat) then return;
  string_t_int (tk, date.minute, stat);
  if sys_error(stat) then return;

  string_substr (s, p, s.len, tk);     {get remainder of input string into TK}
  if tk.len < 1 then goto have_date;
  string_t_fpm (tk, date.sec_frac, stat); {convert to floating point seconds}
  if sys_error(stat) then return;
  date.second := trunc(date.sec_frac); {extract whole seconds}
  date.sec_frac := date.sec_frac - date.second; {remove whole seconds from fraction}
{
*   The year thru seconds fields of DATE have been filled in.
}
have_date:                             {DATE is all filled in}
  if local
    then begin                         {interpret as a local time}
      sys_timezone_here (              {get info about the current time zone}
        date.tzone_id,                 {time zone ID}
        date.hours_west,               {hours west of coordinated universal time}
        date.daysave);                 {daylight savings time strategy}
      date.daysave_on := true;         {allow daylight savings time offset}
      end
    else begin                         {interpret as coordinated universal time}
      date.tzone_id := sys_tzone_cut_k; {set time zone ID}
      date.hours_west := 0.0;
      date.daysave := sys_daysave_no_k; {never apply daylight savings time}
      date.daysave_on := false;
      end
    ;
  sys_date_clean (date, date);         {make all the fields legal and consistant}
  return;                              {return with the resulting date/time}
{
*   A error was encountered in the input string at character position P.
}
err_at_p:
  sys_stat_set (string_subsys_k, string_stat_date_bad_k, stat);
  sys_stat_parm_vstr (s, stat);
  sys_stat_parm_int (p, stat);
  end;                                 {return with error status}
