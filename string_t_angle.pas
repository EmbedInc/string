{   Convert angle from string to real.
}
module string_t_angle;
define string_t_angle;
%include 'string2.ins.pas';

const
  pi = 3.14159265358979324;            {what it sounds like, don't touch}
  deg_rad = pi / 180.0;                {for converting degrees to radians}
{
********************************************************************************
*
*   Subroutine STRING_T_ANGLE (TK, ANG, STAT)
*
*   Interpret the string in TK as an angle, and return the result in ANG.  ANG
*   is in radians.  The format of TK is:
*
*     <degrees>:<minutes>:<seconds>
*
*   Each value can be an arbitrary floating point number.  MINUTES and SECONDS
*   may be omitted, with their default being 0.  Each colon may be omitted if
*   there is no field to the right.
}
procedure string_t_angle (             {<degrees>:<minutes>:<seconds> to angle}
  in      tk: univ string_var_arg_t;   {input string}
  out     ang: real;                   {resulting angle, radians}
  out     stat: sys_err_t);            {completion status}
  val_param;

var
  tk2: string_var32_t;                 {field parsed from input string}
  deg, min, sec: sys_fp_max_t;         {value of each field in input string}
  p: string_index_t;                   {parse index}
  delim: sys_int_machine_t;            {number of ending delimiter (unused)}
  neg: boolean;                        {TRUE if overall value is negative}

begin
  tk2.max := size_char(tk2.str);       {init local var string}

  ang := 0.0;                          {init returned value}
  p := 1;                              {init input string parse index}
{
*   Process degrees.
}
  string_token_anyd (                  {extract degrees part into TK2}
    tk,                                {input string}
    p,                                 {parse index}
    ':', 1, 1,                         {delimiters list, N delim, first N repeat}
    [],                                {option flags}
    tk2,                               {returned token}
    delim,                             {number of main delimiter used}
    stat);
  if sys_error(stat) then return;

  string_t_fpmax (                     {convert degrees to floating point value}
    tk2,                               {string to convert}
    deg,                               {output value}
    [],                                {option flags}
    stat);
  if sys_error(stat) then return;

  neg := deg < 0.0;                    {angle is negative ?}
{
*   Process minutes.
}
  min := 0.0;                          {init minutes to the default value}

  string_token_anyd (                  {extract minutes part into TK2}
    tk,                                {input string}
    p,                                 {parse index}
    ':', 1, 1,                         {delimiters list, N delim, first N repeat}
    [],                                {option flags}
    tk2,                               {returned token}
    delim,                             {number of main delimiter used}
    stat);

  if not string_eos(stat) then begin   {non-empty minutes field ?}
    if sys_error(stat) then return;    {hard error ?}

    string_t_fpmax (                   {convert minutes to floating point value}
      tk2,                             {string to convert}
      min,                             {output value}
      [],                              {option flags}
      stat);
    if sys_error(stat) then return;
    end;
{
*   Process seconds.
}
  sec := 0.0;                          {init seconds to the default value}

  string_token_anyd (                  {extract seconds part into TK2}
    tk,                                {input string}
    p,                                 {parse index}
    ':', 1, 1,                         {delimiters list, N delim, first N repeat}
    [],                                {option flags}
    tk2,                               {returned token}
    delim,                             {number of main delimiter used}
    stat);

  if not string_eos(stat) then begin   {non-empty seconds field ?}
    if sys_error(stat) then return;    {hard error ?}

    string_t_fpmax (                   {convert seconds to floating point value}
      tk2,                             {string to convert}
      sec,                             {output value}
      [],                              {option flags}
      stat);
    if sys_error(stat) then return;
    end;
{
*   Make sure the input string is exhausted.
}
  while p <= tk.len do begin           {scan to the end of the string}
    if tk.str[p] <> ' ' then begin     {other than blank after last token ?}
      string_substr (tk, p, tk.len, tk2); {get offending token into TK2}
      sys_stat_set (string_subsys_k, string_stat_extra_tk_k, stat); {init error status}
      sys_stat_parm_vstr (tk2, stat);  {add the extraneous characters}
      sys_stat_parm_vstr (tk, stat);   {add the whole original string}
      return;                          {return with error}
      end;
    p := p + 1;                        {advance to next input string char}
    end;
{
*   Combine the values from each of the fields, and return the result in
*   radians.
}
  min := min + (sec / 60.0);           {merge minutes and seconds into MIN}
  min := min / 60.0;                   {convert result to degrees}
  if neg
    then begin                         {overall value is negative}
      deg := deg - min;
      end
    else begin                         {overall value is positive or zero}
      deg := deg + min;
      end
    ;

  ang := deg * deg_rad;                {return result converted to radians}
  end;
