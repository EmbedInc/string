{   String conversion to/from special logic analyzer CSV file fields.
}
module string_csvana;
define string_t_csvana_t1;
%include 'string2.ins.pas';
{
********************************************************************************
*
*   Subroutine STRING_T_CSVANA_T1 (S, T, STAT)
*
*   Convert a logic analyzer CSV file time string type 1 to a time value.  The
*   string format is:
*
*     YYYY-MM-DDTHH:MM:SS.SSSSSSSSS+hh:mm
*
*   For example:
*
*     2022-11-09T13:59:33.190233300+00:00
*
*   The fields are:
*
*     YYYY  -  Year.
*
*     MM  -  01 to 12 month.
*
*     DD  -  01 to 31 day.
*
*     T  -  Literal "T".
*
*     HH  -  Hour within day.
*
*     MM  -  Minute within hour.
*
*     SS.SSSSSSSSS  -  Seconds within minutes.
*
*     hh:mm  -  Time zone offset in hours and minutes from coor univ time.
*
*   Some flexibility in the length of the above fields is allowed.  This routine
*   was written to work with examples of this time format, without any specs.
*   It is therefore unclear what variations from the examples are allowed.
*
*   This format was found in CSV files produced by a particular logica analyzer.
*   The make and model of this analyzer is unknown.
}
procedure string_t_csvana_t1 (         {interpret logic analyzer type 1 time format}
  in      s: univ string_var_arg_t;    {input string, YYY-MM-DDTHH:MM:SS.SSS+hh:mm}
  out     t: sys_clock_t;              {resulting absolute time}
  out     stat: sys_err_t);            {completion status}
  val_param;

var
  p: string_index_t;                   {parse index}
  tk: string_var32_t;                  {token parsed from input string}
  d: sys_int_machine_t;                {number of delimiter picked from list}
  ii: sys_int_machine_t;               {scratch integer}
  r: double;                           {scratch floating point}
  date: sys_date_t;                    {date/time descriptor}

label
  have_date, err;

begin
  tk.max := size_char(tk.str);         {init local var string}
  p := 1;                              {init parse index into input string}

  string_token_anyd (                  {get year}
    s, p, '-', 1, 0, [], tk, d, stat);
  if sys_error(stat) then goto err;
  string_t_int (tk, date.year, stat);
  if sys_error(stat) then goto err;

  string_token_anyd (                  {get month}
    s, p, '-', 1, 0, [], tk, d, stat);
  if sys_error(stat) then goto err;
  string_t_int (tk, ii, stat);
  if sys_error(stat) then goto err;
  date.month := ii - 1;

  string_token_anyd (                  {get day}
    s, p, 'T', 1, 0, [], tk, d, stat);
  if sys_error(stat) then goto err;
  string_t_int (tk, ii, stat);
  if sys_error(stat) then goto err;
  date.day := ii - 1;

  string_token_anyd (                  {get hour}
    s, p, ':', 1, 0, [], tk, d, stat);
  if sys_error(stat) then goto err;
  string_t_int (tk, date.hour, stat);
  if sys_error(stat) then goto err;

  string_token_anyd (                  {get minute}
    s, p, ':', 1, 0, [], tk, d, stat);
  if sys_error(stat) then goto err;
  string_t_int (tk, date.minute, stat);
  if sys_error(stat) then goto err;

  string_token_anyd (                  {get seconds}
    s, p, '+', 1, 0, [], tk, d, stat);
  if sys_error(stat) then goto err;
  string_t_fp2 (tk, r, stat);
  if sys_error(stat) then goto err;
  date.second := trunc(r);
  date.sec_frac := r - date.second;

  date.hours_west := 0.0;              {init to default time zone data}
  date.tzone_id := sys_tzone_other_k;
  date.daysave := sys_daysave_no_k;
  date.daysave_on := false;

  string_token_anyd (                  {get timezone hours offset}
    s, p, ':', 1, 0, [], tk, d, stat);
  if string_eos(stat) then goto have_date;
  if sys_error(stat) then goto err;
  string_t_fpm (tk, date.hours_west, stat);
  if sys_error(stat) then goto err;

  string_token (s, p, tk, stat);       {get timezone additional minutes offset}
  if string_eos(stat) then goto have_date;
  if sys_error(stat) then goto err;
  string_t_fp2 (tk, r, stat);
  if sys_error(stat) then goto err;
  date.hours_west := date.hours_west + (r / 60.0);

  string_token (s, p, tk, stat);       {no more tokens allowed in input string}
  if string_eos(stat) then goto have_date;
  if sys_error(stat) then goto err;

have_date:                             {DATE is all filled in}
  t := sys_clock_from_date (date);     {make absolute time from date/time}
  return;                              {normal return point, no error}

err:                                   {error interpreting logic analyzer date string}
  sys_stat_set (string_subsys_k, string_stat_bad_csvana_t1_k, stat);
  sys_stat_parm_vstr (s, stat);
  end;
