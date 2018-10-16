{   Subroutine STRING_T_INT_MAX_BASE (S, BASE, FLAGS, VAL, STAT)
*
*   Convert string S to integer VAL.  BASE is the number base of string S.
*   It must be in the range of 2 to 36.  STAT is the completion status code.
*   It is set to BAD_INT if conversion was not possible.  FLAGS is a set of
*   independent flags.  They are:
*
*   STRING_TI_UNSIG_K
*
*     Declare VAL to be an unsigned number.  If VAL were 8 bits, for example,
*     then this flag would cause it to have a range of 0 to 255 instead of
*     -128 to 127.  Any signs, plus or minus, are illegal for an unsigned number.
*
*   STRING_TI_NULL_Z_K
*
*     Blank input string has a value of zero.  By default, a blank input string
*     is an error.  This flag may not be used together with STRING_TI_NULL_DEF_K.
*
*   STRING_TI_NULL_DEF_K
*
*     Blank input string is being used to select default in the calling program,
*     and therefore will not cause VAL to be altered.  By default, a blank input
*     string is an error.  This flag may not be used together with
*     STRING_TI_NULL_Z_K.
*
*   "0" thru "9" are required for digit values 0-9.  "A" thru "Z" are used
*   for digit values 10-35.  These letters may be upper or lower case.
}
module string_t_int_max_base;
define string_t_int_max_base;
%include 'string2.ins.pas';

procedure string_t_int_max_base (      {convert string to max int with full features}
  in      s: univ string_var_arg_t;    {input string}
  in      base: sys_int_machine_t;     {number base of input string}
  in      flags: string_ti_t;          {additional option flags}
  in out  val: sys_int_max_t;          {output integer}
  out     stat: sys_err_t);            {completion status code}
  val_param;

var
  sign_val: sys_int_machine_t;         {+1 or -1 sign value}
  sign_exists: boolean;                {TRUE if sign found}
  p, p2: sys_int_machine_t;            {parse indicies for S}
  i: sys_int_machine_t;                {loop counter}
  v: sys_int_max_t;                    {local number value accumulator}
  d: sys_int_machine_t;                {0-35 digit value}

label
  done_sign, int_error, sign_error;

begin
  sys_error_none (stat);               {init to no error}
{
*   Skip over leading blanks and check for + or - sign.
}
  sign_val := 1;                       {default sign value}
  sign_exists := false;                {init to no sign found}

  for p := 1 to s.len do begin         {once for each possible leading char}
    case s.str[p] of
' ':  begin
        next;                          {skip over leading blanks}
        end;
'+':  begin
        if
            sign_exists or             {already found a previous sign ?}
            (string_ti_unsig_k in flags) {supposed to be unsigned number ?}
          then goto sign_error;
        sign_exists := true;
        end;
'-':  begin
        if
            sign_exists or             {already found a previous sign ?}
            (string_ti_unsig_k in flags) {supposed to be unsigned number ?}
          then goto sign_error;
        sign_val := -1;
        sign_exists := true;
        end;
otherwise
      goto done_sign;                  {p is index of first digit}
      end;                             {done with character type cases}
    end;                               {back and process next character}
{
*   No digit characters were found.
}
  if string_ti_null_def_k in flags     {don't alter VAL on no digits ?}
    then return;
  if string_ti_null_z_k in flags then begin {no digits means zero ?}
    val := 0;
    return;
    end;
  goto int_error;                      {otherwise no digits is an error}

done_sign:                             {SIGN_VAL, SIGN_EXISTS, P all set}
{
*   P is the index into S for the first character that is not a space or a sign.
*   Scan backwards and set P2 to the index of the last non-blank character.
}
  p2 := s.len;                         {init index of last non-blank char in S}
  while s.str[p2] = ' ' do             {loop backwards looking for last non-blank}
    p2 := p2 - 1;
{
*   P and P2 are the indicies into S of the first and last digit characters,
*   assuming legal syntax in S.  There is guaranteed to be at least one digit.
}
  v := 0;                              {starting number value before first digit}
  for i := p to p2 do begin            {once for each digit character}
    if (s.str[i] >= '0') and (s.str[i] <= '9') then begin
      d := ord(s.str[i]) - ord('0')
      end
    else if (s.str[i] >= 'A') and (s.str[i] <= 'Z') then begin
      d := ord(s.str[i]) - ord('A') + 10;
      end
    else if (s.str[i] >= 'a') and (s.str[i] <= 'z') then begin
      d := ord(s.str[i]) - ord('a') + 10;
      end
    else goto int_error;               {not a valid digit character ?}
    if d >= base then goto int_error;  {digit value is out of range ?}
    d := d * sign_val;                 {take sign of number into account}
{
*   D is the properly signed value of this digit.
}
    v := (v * base) + d;               {shift up old number and add in new digit}
    end;                               {back and handle next input digit}
  val := v;                            {pass back final integer value}
  return;                              {return with no error}

int_error:                             {error interpreting string as integer}
  sys_stat_set (string_subsys_k, string_stat_bad_int_k, stat);
  sys_stat_parm_vstr (s, stat);
  return;

sign_error:                            {found sign (+-) when shouldn't be any}
  sys_stat_set (string_subsys_k, string_stat_sign_k, stat);
  sys_stat_parm_vstr (s, stat);
  return;

  end;
