{   Collection of routines that convert floating point numbers to strings.
*   All the conversion is actually done in the low level routine STRING_F_FP.
*   The remaining routines are convenient wrappers.
}
module string_f_fp_eng;
define string_f_fp_eng;
%include '(cog)lib/string2.ins.pas';

var
  umult: array[-5 .. 5] of char := [   {unit multiplier for each power of 1000}
    'f',                               {femto}
    'p',                               {pico}
    'n',                               {nano}
    'u',                               {micro}
    'm',                               {milli}
    ' ',                               {unity, no name}
    'k',                               {kilo}
    'M',                               {Mega}
    'G',                               {Giga}
    'T',                               {Tera}
    'P'];                              {Peta}
{
********************************************************************************
*
*   Subroutine STRING_F_FP_ENG (S, FP, SIG, UN)
*
*   Convert the floating point number FP into engineering notation.  S is
*   returned the decimal value with 1 to 3 digits left of the point and SIG
*   significant digits.  UN is returned the units multiplier.  The possible
*   units multipliers are:
*
*     P  -  Peta, 10**15
*     T  -  Tera, 10**12
*     G  -  Giga, 10**9
*     M  -  Mega, 10**6
*     k  -  kilo, 10**3
*        -  empty string, 1
*     m  -  milli, 10**-3
*     u  -  micro, 10**-6
*     n  -  nano, 10**-9
*     p  -  pico, 10**-12
*     f  -  femto, 10**-15
*
*   If the value is outside this range, then "eXX" is appended to the number in
*   S and UN is set to the empty string.  XX will be a multiple of 3 postive or
*   negative integer.
}
procedure string_f_fp_eng (            {engineering notation string from floating point}
  in out  s: univ string_var_arg_t;    {output string, always 1-3 digits left of point}
  in      fp: sys_fp_max_t;            {input floating point number}
  in      sig: sys_int_machine_t;      {minimum significant digits required}
  out     un: univ string_var_arg_t);  {units prefix, like M K m u p, etc}
  val_param;

var
  fs: string_var32_t;                  {raw numbered engineering notation string}
  p: string_index_t;                   {string parse index}
  tk: string_var32_t;                  {scratch string}
  c: char;                             {scratch character}
  e: sys_int_machine_t;                {exponent value}
  stat: sys_err_t;                     {completion status}

label
  err;

begin
  fs.max := size_char(fs.str);         {init local var strings}
  tk.max := size_char(tk.str);
  un.len := 0;                         {init returned units name string to empty}

  string_f_fp (                        {make raw engineering string from FP number}
    fs,                                {returned string}
    fp,                                {floating point value to convert}
    0,                                 {no fixed field width, use free format}
    0,                                 {use free format for exponent}
    sig,                               {minimum significant digits required}
    3,                                 {max allowed digits left of point}
    0,                                 {min required digits right of point}
    sig,                               {max allowed digits right of point}
    [ string_ffp_exp_k,                {always use exponential notation}
      string_ffp_exp_eng_k],           {engineering notation (exponent mult of 3)}
    stat);
  if sys_error(stat) then begin        {unable to conver to string (shouldn't happen)}
err:                                   {jump here on any error}
    string_vstring (s, '****', 4);     {return starred out value}
    return;
    end;
{
*   FS contains the string in numeric engineering format, XXXeYY.  Extract the
*   mantissa part (XXX) into the return string S, and set E to the exponent
*   value (YY).
}
  p := 1;                              {init parse index into FS}
  s.len := 0;                          {init returned mantissa string to empty}
  while true do begin                  {search forward for the "e"}
    if p > fs.len then exit;           {hit end of string ?}
    c := fs.str[p];                    {get this character}
    p := p + 1;                        {advance to next source character}
    if (c = 'e') or (c = 'E') then exit; {hit end of mantissa delimiter ?}
    string_append1 (s, c);             {copy this mantissa character to output string}
    end;

  tk.len := 0;                         {init extracted exponent string}
  while p <= fs.len do begin           {loop over exponent part of combined string}
    string_append1 (tk, fs.str[p]);    {copy this exponent character to TK}
    p := p + 1;                        {advance to next source characer}
    end;
  string_t_int_max_base (              {convert exponent string to ineteger}
    tk,                                {string to convert}
    10,                                {input string radix}
    [string_ti_null_z_k],              {empty input string returns 0}
    e,                                 {returned integer}
    stat);
  if sys_error(stat) then goto err;
{
*   Intepret the exponent value in E to the units multiplier prefix.  If the
*   exponent is outside the range of the units multipliers, then append it to
*   the returned number instead and return nothing for the units multiplier.
}
  if e = 0 then return;                {special case of unity multiplier ?}

  e := e div 3;                        {make UMULT index}
  if (e > 5) or (e < -5) then begin    {outside the name multiplier range ?}
    string_copy (fs, s);               {return the raw numeric engineering notations string}
    return;
    end;

  string_append1 (un, umult[e]);       {return the selected units multiplier name}
  end;
