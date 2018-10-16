{   Collection of routines that convert strings to floating point
*   numbers.  The low level routine STRING_T_FPMAX does all the actual
*   conversion.  The remaning routines are various convenient wrappers.
}
module string_t_fp;
define string_t_fp1;
define string_t_fp2;
define string_t_fpm;
define string_t_fpmax;
%include '/cognivision_links/dsee_libs/string/string2.ins.pas';
{
*************************
*
*   Subroutine STRING_T_FP1 (S, FP, STAT)
*
*   Convert string S to single precision floating point number FP.
*   STAT is the completions status code.
}
procedure string_t_fp1 (               {convert string to single precision float}
  in      s: univ string_var_arg_t;    {input string}
  out     fp: sys_fp1_t;               {output floating point number}
  out     stat: sys_err_t);            {completion status code}
  val_param;

var
  fpmax: sys_fp_max_t;

begin
  string_t_fpmax (                     {call low level conversion routine}
    s,                                 {input string}
    fpmax,                             {output floating point number}
    [],                                {additional option flags}
    stat);
  fp := fpmax;
  end;
{
*************************
*
*   Subroutine STRING_T_FP2 (S, FP, STAT)
*
*   Convert string S to double precision floating point number FP.
*   STAT is the completions status code.
}
procedure string_t_fp2 (               {convert string to double precision float}
  in      s: univ string_var_arg_t;    {input string}
  out     fp: sys_fp2_t;               {output floating point number}
  out     stat: sys_err_t);            {completion status code}
  val_param;

var
  fpmax: sys_fp_max_t;

begin
  string_t_fpmax (                     {call low level conversion routine}
    s,                                 {input string}
    fpmax,                             {output floating point number}
    [],                                {additional option flags}
    stat);
  fp := fpmax;
  end;
{
*************************
*
*   Subroutine STRING_T_FPM (S, FP, STAT)
*
*   Convert string S to preferred machine floating point number FP.
*   STAT is the completions status code.
}
procedure string_t_fpm (               {convert string to machine floating point}
  in      s: univ string_var_arg_t;    {input string}
  out     fp: real;                    {output floating point number}
  out     stat: sys_err_t);            {completion status code}
  val_param;

var
  fpmax: sys_fp_max_t;

begin
  string_t_fpmax (                     {call low level conversion routine}
    s,                                 {input string}
    fpmax,                             {output floating point number}
    [],                                {additional option flags}
    stat);
  fp := fpmax;
  end;
{
*************************
*
*   Subroutine STRING_T_FPMAX (S, FP, FLAGS, STAT)
*
*   Convert the string S to the single precision floating point number FP.
*   FLAGS is a set of one-bit options flags.  STAT is the returned completion
*   status.  The supported flags are:
*
*   STRING_TFP_NULL_Z_K
*
*     An empty input string has a value of 0.0.  This flag is mutually
*     exclusive with STRING_TFP_NULL_DEF_K.  By default, an empty input
*     string is a error.
*
*   STRING_TFP_NULL_DEF_K
*
*     An empty input string causes the existing value of FP to not be altered.
*     This flag is mutually exclusive with STRING_TRP_NULL_Z_K.  By default,
*     an empty string is an error.
*
*   STRING_TFP_GROUP_K
*
*     Allow digit grouping in the input number.  By default, digit grouping
*     is not allowed.  In most languages, digits may be grouped into
*     fixed-size groups separated by the grouping character.  In English,
*     digits are grouped in threes separated by commas.  The group size
*     and group separator character is declared in the language descriptor
*     file with the keywords DIGITS_GROUP_SIZE and DIGITS_GROUP_CHAR.
}
procedure string_t_fpmax (             {convert string to max size floating point}
  in      s: univ string_var_arg_t;    {input string}
  in out  fp: sys_fp_max_t;            {output floating point number}
  in      flags: string_tfp_t;         {additional option flags}
  out     stat: sys_err_t);            {completion status code}
  val_param;

type
  state_k_t = (                        {current state in parsing input string}
    state_man_bef_k,                   {before mantissa and its sign}
    state_man_left_k,                  {in mantissa, left of decimal point}
    state_man_right_k,                 {in mantissa, right of decimal point}
    state_exp_bef_k,                   {before start of exponent value}
    state_exp_k);                      {in exponent}

var
  man: sys_fp_max_t;                   {unsigned mantissa value}
  pwten: sys_fp_max_t;                 {current power of ten}
  mult: sys_fp_max_t;                  {mult factor resulting from exponent}
  lang_p: sys_lang_p_t;                {pointer to info about current language}
  p: sys_int_machine_t;                {input string parse index}
  man_exp: sys_int_machine_t;          {implied exponent in mantissa value}
  man_sign: sys_fp_max_t;              {1.0 or -1.0 mantissa sign}
  exp: sys_int_machine_t;              {unsigned power of 10 exponent value}
  group_n: sys_int_machine_t;          {number of chars in current group}
  state: state_k_t;                    {current input string parse state}
  exp_pos: boolean;                    {TRUE if exponent is positive}
  group_hard: boolean;                 {TRUE if in hard group}
  group_sep: boolean;                  {TRUE if any group separator char found}
  man_dec: boolean;                    {mantissa decimal point was found}

label
  string_bad, found_nonblank, digit_man, next_char, loop_exp;

begin
  sys_error_none (stat);               {init to not error}
  if                                   {illegal combination of flags ?}
      [string_tfp_null_z_k, string_tfp_null_def_k] <= flags
      then begin
    sys_stat_set (string_subsys_k, string_stat_tfp_bad_k, stat); {set error code}
    sys_stat_parm_vstr (s, stat);      {pass back string trying to convert}
    return;                            {return with error}
    end;
  for p := 1 to s.len do begin         {scan string looking for first non-blank}
    if s.str[p] <> ' ' then goto found_nonblank;
    end;
{
*   The input string is either empty or all blank.
}
  if string_tfp_null_def_k in flags then return; {blank means don't touch FP ?}
  if string_tfp_null_z_k in flags then begin {blank means pass back zero ?}
    fp := 0.0;
    return;
    end;
string_bad:                            {end up here if input string not FP number}
  sys_stat_set (string_subsys_k, string_stat_bad_real_k, stat); {set error status code}
  sys_stat_parm_vstr (s, stat);        {pass back offending string}
  return;                              {return with error}
{
*   P is the parse index to the first non-blank character in the input string.
}
found_nonblank:
  man := 0.0;                          {init mantissa value}
  man_exp := 0;                        {init exponent implied in mantissa value}
  man_sign := 1.0;                     {init mantissa sign}
  exp := 0;                            {init exponent value}
  exp_pos := true;                     {init exponent sign}
  group_n := 0;                        {init number characters in current group}
  group_hard := false;                 {init to no hard groups found}
  group_sep := false;                  {init to no group separator chars found}
  man_dec := false;                    {init to no mantissa decimal point was found}
  state := state_man_bef_k;            {init input string parsing state}
  sys_langp_curr_get (lang_p);         {get pointer to current language info}

  repeat                               {loop back here for each new input character}
    case s.str[p] of                   {what kind of character is it ?}
{
*   This input string character is a minus sign.
}
'-': begin                             {minus sign}
  case state of
state_man_bef_k: begin                 {minus sign before mantissa}
      state := state_man_left_k;       {now definately in the mantissa}
      man_sign := -1.0;                {indicate mantissa is negative}
      end;
state_man_left_k,
state_man_right_k,                     {minus sign while in mantissa}
state_exp_bef_k: begin                 {minus sign just before exponent}
      state := state_exp_k;            {now definately in exponent}
      exp_pos := false;                {indicate exponent is negative}
      end;
otherwise
    goto string_bad;
    end;
  end;                                 {done with minus sign}
{
*   This input string character is a plus sign.
}
'+': begin                             {plus sign}
  case state of
state_man_bef_k: begin                 {plus sign before mantissa}
      state := state_man_left_k;       {now definately in the mantissa}
      end;
state_man_left_k,
state_man_right_k,                     {plus sign while in mantissa}
state_exp_bef_k: begin                 {plus sign just before exponent}
      state := state_exp_k;            {now definately in the exponent}
      end;
otherwise
    goto string_bad;
    end;
  end;                                 {done with plus sign}
{
*   This input string character is a digit.
}
'0', '1', '2', '3', '4', '5', '6', '7', '8', '9': begin {0-9 digit}
  case state of
state_man_bef_k,
state_man_left_k: begin                {this is next digit left of point in mantissa}
      state := state_man_left_k;       {now definately in the mantissa}
digit_man:                             {jump here for common mantissa digit code}
      man := (man * 10.0) +            {add in this digit}
        (ord(s.str[p]) - ord('0'));
      group_n := group_n + 1;          {one more character in this group}
      end;
state_man_right_k: begin               {this is next digit right of pnt in mantissa}
      man_exp := man_exp - 1;          {update exponent to correct mantissa value}
      goto digit_man;                  {to common code to process mantissa digit}
      end;
state_exp_bef_k,
state_exp_k: begin                     {this is next digit in exponent}
      state := state_exp_k;            {now definately inside the exponent}
      exp := (exp * 10) +              {add in this digit to exponent value}
        (ord(s.str[p]) - ord('0'));
      end;
otherwise
    goto string_bad;
    end;
  end;                                 {done with digit}
{
*   This input string character signifies the start of the exponent.
}
'E', 'e', 'D', 'd': begin
  case state of
state_man_left_k,
state_man_right_k: begin               {currently parsing the mantissa}
      state := state_exp_bef_k;        {we are now just before the mantissa}
      end;
otherwise
    goto string_bad;
    end;
  end;
{
*   This input string character is a space.  This is only allowed at the end
*   of the number.  The whole rest of the input string must be spaces.
}
' ': begin
  p := p + 1;                          {advance to next input string character}
  while p <= s.len do begin            {scan reset of input string}
    if s.str[p] <> ' ' then goto string_bad; {found other than a space ?}
    p := p + 1;                        {advance to next input string character}
    end;
  end;
{
*   The input string character is not one of the hard-wired special characters
*   we recognize.  Now check for the the "soft" special characters.  These
*   are a function of the current language.
}
otherwise
{
*   Check for the decimal "point" character.
}
  if s.str[p] = lang_p^.decimal then begin {this is decimal "point" character ?}
    case state of
state_man_bef_k,
state_man_left_k: begin                {we are parsing left side of mantissa}
        state := state_man_right_k;    {now definately in right side of mantissa}
        if
            group_sep and              {group separator characters were used ?}
            (group_n <> lang_p^.digits_group_n) {current group not the right size ?}
          then goto string_bad;        {this is a syntax error}
        group_n := 0;                  {decimal point starts a new group}
        group_hard := true;            {the new group definately start here}
        group_sep := false;            {init to no separator characters found}
        man_dec := true;               {remember mantissa decimal point was found}
        end;
otherwise
      goto string_bad;
    end;
    goto next_char;
  end;
{
*   Check for the group separator character ("," in English).
}
  if s.str[p] = lang_p^.digits_group_c then begin {group separator character ?}
    if not (string_tfp_group_k in flags) {separator characters not allowed ?}
      then goto string_bad;            {this is a syntax error}
    case state of
state_man_left_k,
state_man_right_k: begin               {only allowed in the mantissa}
        if group_n > lang_p^.digits_group_n {current group too big ?}
          then goto string_bad;
        if
            group_hard and             {this group has a hard size ?}
            (group_n <> lang_p^.digits_group_n) {current group not right size ?}
          then goto string_bad;
        group_n := 0;                  {start a new group}
        group_hard := true;
        group_sep := true;             {a separator char was definately used}
        end;
otherwise
      goto string_bad;
      end;
    goto next_char;
    end;
{
*   Unexpected input string character.
}
  goto string_bad;

      end;                             {end of input string character cases}
next_char:                             {jump here to advance to next input char}
    p := p + 1;                        {advance parse index to next character}
    until p > s.len;                   {back to process next input string character}
{
*   The end of the input string has been reached.
*   Now check the last mantissa group for validity.  The relevant variables are:
*
*     GROUP_N  -  number of digits in the last group.
*     LANG_P^.DIGITS_GROUP_N  -  Number of digits required in a whole group.
*     GROUP_SEP  -  TRUE if a group separator character was found.
*     MAN_DEC  -  TRUE if last group is to right of decimal point.
}
  if group_sep then begin              {group separator characters were used ?}
    if man_dec
      then begin                       {mantissa ended right of decimal point}
        if (group_n < 1) or (group_n > lang_p^.digits_group_n) {bad size group ?}
          then goto string_bad;
        end
      else begin                       {mantissa was a whole number without dec pnt}
        if group_n <> lang_p^.digits_group_n {group not correct size ?}
          then goto string_bad;
        end
      ;
    end;                               {done checking for correct digit grouping}
{
*   Done dealing with input string syntax issues.  Now compute the final
*   floating point value from the individual pieces.  The variable which
*   hold the values resulting from parsing the input string are:
*
*   MAN
*
*     Unsigned mantissa raw value.  This contains the value as if the
*     decimal point was at the end of the mantissa, not where it really
*     appreared.
*
*   MAN_EXP
*
*     The mantissa implied "exponent" value.  This contains the power of 10
*     exponent that when applied to MAN would result in the true mantissa
*     magnitude.  This is also -1 times the number of digits found to the
*     right of the decimal point.
*
*   MAN_SIGN
*
*     Mantissa sign.  This is either 1.0 or -1.0.
*
*   EXP
*
*     Unsigned exponent magnitude.
*
*   EXP_POS
*
*     Indicates exponent sign.  Is TRUE if exponent is positive, FALSE
*     if negative.
}
  if exp_pos
    then begin                         {exponent value is EXP}
      exp := exp + man_exp;            {add in correction for decimal point}
      if exp < 0 then begin            {this changes sign of effective exponent ?}
        exp := -exp;                   {restore EXP to exponent magnitude}
        exp_pos := false;              {indicate exponent is -EXP}
        end;
      end
    else begin                         {exponent value is -EXP}
      exp := exp - man_exp;            {add in correction for decimal point}
      end
    ;
{
*   EXP and EXP_POS have been updated to take into account the placement of the
*   decimal point within the mantissa.
}
  pwten := 10.0;                       {init power of ten for first EXP bit}
  mult := 1.0;                         {init mult factor resulting from EXP}
loop_exp:                              {back here until all EXP bits used}
  if (exp & 1) <> 0 then begin         {current bit is set ?}
    mult := mult * pwten;              {accumulate this power of ten}
    end;
  exp := rshft(exp, 1);                {shift next bit into position}
  if exp <> 0 then begin               {still some bits left ?}
    pwten := sqr(pwten);               {make power of ten for next bit}
    if                                 {prevent underflow of MULT}
        (not exp_pos) and
        (man > 1.0) and
        (mult > man)
        then begin
      man := man / mult;               {use multiplier accumulated so far}
      mult := 1.0;                     {reset multiplier to empty}
      end;
    goto loop_exp;                     {back to process next EXP bit}
    end;
{
*   The multiplier factor represented by the exponent magnitude is in MULT.
*   Now apply this factor, taking the signs into account, to obtain the
*   final floating point value.
}
  if exp_pos
    then begin                         {exponent value is positive}
      fp := man_sign * man * mult;
      end
    else begin                         {exponent value is negative}
      fp := man_sign * man / mult;
      end
    ;
  end;
