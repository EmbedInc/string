{   Collection of routines that convert floating point numbers to strings.
*   All the conversion is actually done in the low level routine STRING_F_FP.
*   The remaining routines are convenient wrappers.
}
module string_f_fp;
define string_f_fp_free;
define string_f_fp_fixed;
define string_f_fp_ftn;
define string_f_fp;
%include 'string2.ins.pas';
{
************************************
*
*   Subroutine STRING_F_FP_FREE (S,FP,MIN_SIG)
*
*   Convert floating point number FP to string S.
*   MIN_SIG is the minimum required significant digits.
*   The resulting string will be free format.
}
procedure string_f_fp_free (           {free form string from floating point number}
  in out  s: univ string_var_arg_t;    {output string}
  in      fp: sys_fp_max_t;            {input floating point number}
  in      min_sig: sys_int_machine_t); {minimum required significant digits}
  val_param;

var
  stat: sys_err_t;                     {error status code}

begin
  string_f_fp (                        {convert FP number to string}
    s,                                 {output string}
    fp,                                {input floating point number}
    0,                                 {free format for entire number}
    0,                                 {free format for exponent, if used}
    min_sig,                           {minimum required significant digits}
    min_sig + 3,                       {max digits left of point before exp notation}
    0,                                 {minimum digits right of decimal point}
    min_sig + 2,                       {max digits right of pnt before exp notation}
    [string_ffp_exp_eng_k],            {use engineering notation if use exp noation}
    stat);                             {returned completion status}
  sys_error_abort (stat, '', '', nil, 0);
  end;
{
************************************
*
*   Subroutine STRING_F_FP_FIXED (S,FP,DIG_RIGHT)
*
*   Convert floating point number to fixed point string.
*   DIG_RIGHT is the number of digits that are to be right of the decimal point.
}
procedure string_f_fp_fixed (          {fixed point string from floating point num}
  in out  s: univ string_var_arg_t;    {output string}
  in      fp: sys_fp_max_t;            {input floating point number}
  in      dig_right: string_index_t);  {digits to right of decimal point}
  val_param;

var
  stat: sys_err_t;                     {error status code}
  dig_left: sys_int_machine_t;         {max allowed digits left of point}

label
  err;

begin
  dig_left := s.max - dig_right;
  if dig_right > 0 then begin
    dig_left := dig_left - 1;          {one less for decimal point}
    end;
  if fp < 0.0 then begin
    dig_left := dig_left - 1;          {one less for minus sign}
    end;
  if dig_left < 1 then begin
    sys_stat_set (string_subsys_k, string_stat_ffp_no_fmt_k, stat);
    goto err;
    end;
  string_f_fp (                        {convert FP number to string}
    s,                                 {output string}
    fp,                                {input floating point number}
    0,                                 {no field width, use free format}
    0,                                 {free format for exponent, if used}
    0,                                 {minimum required significant digits}
    dig_left,                          {max digits left of point before exp notation}
    dig_right,                         {minimum digits right of decimal point}
    dig_right,                         {max digits right of pnt before exp notation}
    [string_ffp_exp_no_k],             {exponential notation not allowed}
    stat);                             {returned completion status}
err:                                   {jump here if STAT set to error}
  sys_error_abort (stat, '', '', nil, 0);
  end;
{
************************************
*
*   Subroutine STRING_F_FP_FTN (S,FP,FW,DIG_RIGHT)
*
*   Convert floating point number to string.
*   The controls are FORTRAN-like.
}
procedure string_f_fp_ftn (            {string from floating point num, FTN controls}
  in out  s: univ string_var_arg_t;    {output string}
  in      fp: sys_fp_max_t;            {input floating point number}
  in      fw: string_index_t;          {total field width}
  in      dig_right: string_index_t);  {digits to right of decimal point}
  val_param;

var
  stat: sys_err_t;                     {error status code}

begin
  string_f_fp (                        {convert FP number to string}
    s,                                 {output string}
    fp,                                {input floating point number}
    fw,                                {field width}
    0,                                 {free format for exponent, if used}
    0,                                 {minimum required significant digits}
    fw,                                {max digits left of point before exp notation}
    dig_right,                         {minimum digits right of decimal point}
    fw,                                {max digits right of pnt before exp notation}
    [string_ffp_exp_no_k],             {exponential notation not allowed}
    stat);                             {returned completion status}
  sys_error_abort (stat, '', '', nil, 0);
  end;
{
************************************
*
*   Subroutine STRING_F_FP (S, FP, FW_MAN, FW_EXP, MIN_SIG,
*     MIN_RIGHT, MAX_LEFT, MAX_RIGHT, FLAGS, STAT)
*
*   Convert a floating point number to a string.  The arguments are:
*
*     S
*
*       Output string.
*
*     FP
*
*       Input floating point number.  This is always the maximum precision
*       supported by the machine.
*
*     FW
*
*       Total field width.  A value of zero specifies free format.  The resulting
*       string is right justified within the field if the number is smaller
*       than the field width.  The number is padded on the left with either
*       blanks or zeros, depending on other options.  Field width constraints
*       may cause exponential notation to be used.  It is then an error if
*       exponential notation can not fit within the field, or is not allowed.
*
*     FW_EXP
*
*       Field width for exponent.  A value of zero specifies free format.
*       This field width only applies if an exponent is written.
*
*     MIN_SIG
*
*       Minimum required number of significant digits.
*
*     MIN_RIGHT
*
*       Minimum required digits to the right of the decimal point.  This
*       only applies when fixed point notation is used.
*
*     MAX_LEFT
*
*       Maximum allowed digits to the left of the decimal point.  This
*       limit is used to decide whether exponential notation is necessary.
*       The value has no effect once exponential notation is chosen.
*
*     MAX_RIGHT
*
*       Maximum allowed digits to the right of the decimal point.  This
*       limit is used to decide whether exponential notation is necessary.
*       The value has no effect once exponential notation is chosen.
*
*     FLAGS
*
*       This is a set of individual flags that can modify the default behavior.
*       The supported flag values are:
*
*       STRING_FFP_EXP_NO_K  -  Prohibit exponential notation.  The default is
*         to use exponential notation only when needed to satisfy constraints
*         imposed by the call arguments.
*
*       STRING_FFP_EXP_K  -  Require exponential notation.  The default is
*         to use exponential notation only when needed to satisfy constraints
*         imposed by the call arguments.
*
*       STRING_FFP_EXP_ENG_K  -  Use engineering notation, if exponential notation
*         is used.  The default exponent can be any value supported by the
*         floating point format.  This flag forces the exponent to be a multiple
*         of 3.
*
*       STRING_FFP_POINT_K  -  Force the decimal point to be written, even
*         if no mantissa digits are written to its right.
*
*       STRING_FFP_NZ_BEF_K  -  Don't write zero before decimal point if
*         it would be the only digit before the point.
*
*       STRING_FFP_Z_AFT_K  -  Write one zero after the decimal point, if
*         no digits would otherwise be written to the right of the point.
*         This only applies if exponential notation is used, since the
*         MIN_RIGHT value otherwise controls this behaviour.
*
*       STRING_FFP_LEADZ_K  -  Pad final number on the left with leading zeros
*         to completely fill the specified field.
*
*       STRING_FFP_PLUS_MAN_K  -  Write a plus sign in front of the mantissa
*         if it is greater than zero.
*
*       STRING_FFP_PLUS_EXP_K  -  Write a plus sign in front of the exponent
*         if it is greater than zero.
*
*       STRING_FFP_GROUP_K  -  Separate digits into groups according to the
*         current language.  In English, a comma is written between every
*         third digit.
*
*     STAT
*
*       Completion status code.  The output string is set to the empty string
*       if an error is returned.  An error results when all the various
*       constraints specified by the call arguments can not be met.
*
*   NOTES:
*
*     1 - Parts of the output string depend on the current language.  These
*       are the decimal "point" ('.' in English), the digit grouping character
*       ("," in English) and the digit grouping size (3 in English).
*
*     2 - The exponent is preceeded by "e", unless eliminating this character
*       makes the difference between allowing the number to fit or not fit
*       into the field.  This is what most FORTRAN compilers do when writing
*       floating point numbers, and is also compatible with the STRING
*       library routines that convert from strings to floating point numbers.
*
*     3 - The flags STRING_FFP_LEADZ_K and STRING_FFP_GROUP_K are not intended
*       to be used together with fixed field formatting (FW > 0).  While
*       this is not an error, grouping in the extra leading zeros is undefined.
}
procedure string_f_fp (                {make string from FP number, full features}
  in out  s: univ string_var_arg_t;    {output string}
  in      fp: sys_fp_max_t;            {input floating point number}
  in      fw: string_index_t;          {total field width, use 0 for free form}
  in      fw_exp: string_index_t;      {exp field width when used, 0 = free form}
  in      min_sig: sys_int_machine_t;  {minimum required total significant digits}
  in      max_left: sys_int_machine_t; {max allowed digits left of point}
  in      min_right: sys_int_machine_t; {min required digits right of point}
  in      max_right: sys_int_machine_t; {max allowed digits right of point}
  in      flags: string_ffp_t;         {additional option flags}
  out     stat: sys_err_t);            {completion status code}
  val_param;

const
  max_dig = 18;                        {max digits to calculate for mantissa}
  exp_chunk_n = 6;                     {exp increment for exponent chunk}
  exp_chunk_val = 1.0e6;               {mult factor for exponent chunk}
  exp_chunk_max = 1.0e3;               {max allowed mantissa value when using chunks}
  exp_chunk_min = 1.0e-3;              {min allowed mantissa value when using chunks}

var
  man: sys_fp_max_t;                   {mantissa magnitude}
  exp: sys_int_machine_t;              {magnitude of exponent}
  dig_first: sys_int_machine_t;        {MAN_DIG index to first digit}
  dig_last: sys_int_machine_t;         {MAN_DIG index to last digit}
  dig_left, dig_right: sys_int_machine_t; {digits to left and right of decimal point}
  dig_start: sys_int_machine_t;        {MAN_DIG index to first digit to write}
  lang_p: sys_lang_p_t;                {pointer to data about current language}
  i, j: sys_int_machine_t;             {scratch integers}
  pad_n: sys_int_machine_t;            {number of padding characters needed}
  group_phase: sys_int_machine_t;      {may write group char when get to zero}
  man_dig:                             {mantissa digit values 0-9}
    array[0..max_dig] of sys_int_conv5_t;
  estr: string_var32_t;                {exponent field string}
  man_sign: boolean;                   {TRUE if mantissa has leading sign}
  man_sign_c: char;                    {mantissa sign character if MAN_SIGN true}
  c: char;                             {scratch character}
  write_point: boolean;                {TRUE if write decimal point}
  zero: boolean;                       {TRUE if input value was zero}
  man_neg: boolean;                    {TRUE if mantissa negative}
  error: boolean;                      {TRUE if subroutine found hard error}

label
  done_digits, reformat, done_format;
{
****************************************
*
*   Local subroutine FORMAT
*
*   Decide how the output number will be formatted.  The raw mantissa digits
*   are in MAN_DIG from DIG_FIRST to DIG_LAST.  EXP is the power of ten exponent.
*   It is the correct value if the decimal point is written between the
*   first and second digits.
*
*   This subroutine will set the following global variables:
*
*     DIG_LEFT  -  Digits to write left of the decimal point.
*
*     DIG_RIGHT  -  Digits to write right of the decimal point.
*
*     DIG_START  -  MAN_DIG index to first digit to write.  This may be
*       less than DIG_FIRST, in which case it indicates leading zeros.
*
*     PAD_N  -  Number of padding characters needed.
*
*     ESTR  -  Exponent field string in reverse order.  This string starts with
*       the "e", if used.  This string is of zero length if exponential
*       notation is not used.
*
*     ERROR  -  TRUE if hard error occurred.  In that case STAT is set
*       to the error code.  STAT is not altered when ERROR is TRUE.
}
procedure format;

var
  w: sys_int_machine_t;                {min field width needed}
  i: sys_int_machine_t;                {scratch integer}
  e: sys_int_machine_t;                {exponent value as written}
  d: sys_int_machine_t;                {digit value}
  esign_c: char;                       {exponent sign character}
  esign: boolean;                      {TRUE if exponent sign is written}

label
  use_exp, err_no_fmt;

begin
  error := false;                      {init to no error finding a format}
  estr.len := 0;                       {init to exponential notation not used}
  pad_n := 0;                          {init to no padding characters}
  write_point := false;                {init to not write decimal point}
  dig_start := dig_first;              {init first digit written is first real digit}

  if string_ffp_exp_k in flags         {exponential notation explicitly requested ?}
    then goto use_exp;
  dig_left := max(0, exp + 1);         {min required digits left of point}
  if (fw > 0) or (min_sig = 0)
    then begin                         {fixed field or no min significant digits req}
      dig_right := min_right;
      end
    else begin                         {need to worry about min significant digits}
      dig_right := max(min_right, min_sig - exp - 1);
      end
    ;
  if not (string_ffp_nz_bef_k in flags) then begin {always put at least 0 before pnt}
    i := max(dig_left, 1);             {make new DIG_LEFT value}
    dig_left := i;
    end;
  dig_start := dig_first + exp - dig_left + 1;
  if dig_left > max_left               {too many digits left of point ?}
    then goto use_exp;
  if dig_right > max_right             {too many digits right of point ?}
    then goto use_exp;
{
*   The format for fixed point, if used, has been decided.  DIG_LEFT
*   and DIG_RIGHT are the number of digits to write to the left and right
*   of the decimal point.  Now add up all the characters (not just digits)
*   to see whether this format fits within the maximum field width requirement.
*   Exponential notation will be tried if it doesn't.
}
  w := dig_left + dig_right;           {init min field width to digits}
  if                                   {will write decimal point ?}
      (dig_right > 0) or               {there are digits to right of point ?}
      (string_ffp_point_k in flags)    {decimal point explicitly requested ?}
      then begin
    w := w + 1;                        {add one character for decimal point}
    write_point := true;               {remember decimal point is to be written}
    end;

  if fw <= 0 then return;              {free format, no field width contraints ?}

  if                                   {will write leading sign ?}
      man_neg or                       {mantissa is negative ?}
      (string_ffp_plus_man_k in flags) {sign requested even if positive ?}
      then begin
    w := w + 1;
    end;
  if string_ffp_group_k in flags then begin {digits will be grouped ?}
    w := w +                           {count number of group characters needed}
      ((dig_left - 1) div lang_p^.digits_group_n) + {group chars left of point}
      ((dig_right - 1) div lang_p^.digits_group_n); {group chars right of point}
    end;
  if w > fw then goto use_exp;         {no room for minimum mantissa size}
  pad_n := fw - w;                     {indicate number of padding characters needed}
  return;
{
*   Fixed point notation can not be used.  Decide on formatting for exponential
*   notation.
}
use_exp:
  if string_ffp_exp_no_k in flags      {exponential notation explicitly prohibited ?}
    then goto err_no_fmt;
  dig_start := dig_first;              {reset index of first digit to write}
  if string_ffp_exp_eng_k in flags
    then begin                         {engineering notation, exp is multiple of 3}
      if exp >= 0
        then begin                     {EXP is positive}
          dig_left := (exp mod 3) + 1;
          end
        else begin                     {EXP is negative}
          dig_left := 3 - ((-1 - exp) mod 3);
          end
        ;
      end
    else begin                         {scientific notation, exp is multiple of 1}
      dig_left := 1;
      end
    ;                                  {DIG_LEFT all set}
  dig_right := max(0, min_sig - dig_left); {digits needed right of point}
  if string_ffp_z_aft_k in flags then begin {always want 1 digit on right ?}
    dig_right := max(dig_right, 1);
    end;
{
*   The format for the mantissa has been decided.  DIG_RIGHT and
*   DIG_LEFT indicate the digits to the left and right of the
*   decimal point.  Now calculate the minimum neccessary field with for the
*   mantissa in W.
}
  w := dig_left + dig_right;           {init min field width to digits}
  if                                   {will write decimal point ?}
      (dig_right > 0) or               {there are digits to right of point ?}
      (string_ffp_point_k in flags)    {decimal point explicitly requested ?}
      then begin
    w := w + 1;                        {add one character for decimal point}
    write_point := true;               {remember decimal point is to be written}
    end;
  if                                   {will write leading sign ?}
      man_neg or                       {mantissa is negative ?}
      (string_ffp_plus_man_k in flags) {sign requested even if positive ?}
      then begin
    w := w + 1;
    end;
  if string_ffp_group_k in flags then begin {digits will be grouped ?}
    w := w +                           {count number of group characters needed}
      ((dig_left - 1) div lang_p^.digits_group_n) + {group chars left of point}
      ((dig_right - 1) div lang_p^.digits_group_n); {group chars right of point}
    end;
{
*   Now create the full exponent string.  The characters will be put into
*   ESTR in reverse order.
}
  estr.len := 0;                       {init exponent string to empty}
  e := exp - dig_left + 1;             {exponent value to actually write}
  i := abs(e);                         {make exponent magnitude for making digits}
  while i <> 0 do begin                {keep looping until extracted all the digits}
    d := i mod 10;                     {get value of this digit}
    estr.len := estr.len + 1;          {count one more character in string}
    estr.str[estr.len] := chr(d + ord('0')); {stuff digit character into string}
    i := (i - d) div 10;               {remove digit from exp, get ready for next}
    end;                               {back and extract next exponent digit}
  if estr.len <= 0 then begin          {no digits created (exp value = 0) ?}
    estr.len := 1;
    estr.str[1] := '0';
    end;

  esign := false;                      {init to no sign in front of exponent}
  if e >= 0
    then begin                         {written exponent value is positive}
      if string_ffp_plus_exp_k in flags then begin {need plus sign ?}
        esign_c := '+';
        esign := true;
        end;
      end
    else begin                         {written exponent value is negative}
      esign_c := '-';
      esign := true;
      end
    ;                                  {done deciding exponent sign}

  if fw_exp > 0                        {check for fixed size exp field required}
{
*   The minimum exponent digits are in ESTR, and ESIGN is TRUE if a
*   leading sign is to be written.  In that case, ESIGN_C is the sign
*   character.
*
*   Determine exponent field formatting when the exponent field size
*   has been explicitly specified.
}
    then begin
      if estr.len >= fw_exp            {minimum possible exponent field too large ?}
        then goto err_no_fmt;
      if fw_exp > estr.max             {full exp field won't fit into string ?}
        then goto err_no_fmt;
      i := fw_exp - estr.len;          {init number of characters left to add}
      if esign then i := i - 1;        {count one less for sign}
      if i > 0 then i := i - 1;        {count one less for "e", if possible}
      while i > 0 do begin             {loop once for each leading zero to add}
        estr.len := estr.len + 1;      {one more character in exponent string}
        estr.str[estr.len] := '0';     {add on one more leading zero}
        i := i - 1;                    {account for added zero}
        end;
      if esign then begin              {need to add leading sign to exponent ?}
        estr.len := estr.len + 1;      {one more character in exponent string}
        estr.str[estr.len] := esign_c; {add on leading sign}
        end;
      if estr.len < fw_exp then begin  {room for exponent indicator symbol ?}
        estr.len := estr.len + 1;      {one more character in exponent string}
        estr.str[estr.len] := 'e';     {add on exponent indicator symbol}
        end;
      end
{
*   Determine the exponent field formatting when the exponent field is
*   free format.
}
    else begin                         {exponent field is free format}
      if esign then begin              {need to add leading sign to exponent ?}
        estr.len := estr.len + 1;      {one more character in exponent string}
        if estr.len > estr.max then goto err_no_fmt;
        estr.str[estr.len] := esign_c; {add on leading sign}
        end;
      if                               {add on exponent indicator symbol ?}
          (not esign) or               {no sign, exponent indicator required ?}
          (fw <= 0) or                 {no field width contraints ?}
          ((estr.len + w) < fw)        {would fit anyway ?}
          then begin
        estr.len := estr.len + 1;      {one more character in exponent string}
        if estr.len > estr.max then goto err_no_fmt;
        estr.str[estr.len] := 'e';
        end;
      end
    ;
{
*   The exponent field string is completely finished.  The characters are
*   in ESTR in reverse order.  Now check the final fit.
}
  if fw > 0 then begin                 {whole string has fixed size ?}
    pad_n := fw - w - estr.len;        {number of padding characters needed}
    if pad_n < 0 then goto err_no_fmt; {mantissa plus exponent too big ?}
    end;
  return;                              {return indicating exponent formatting}
{
*   No format could be found that satisfies all the constraints.
}
err_no_fmt:
  sys_stat_set (string_subsys_k, string_stat_ffp_no_fmt_k, stat); {set error status}
  error := true;                       {indicate error to caller}
  end;
{
****************************************
*
*   Start of main routine.
}
begin
  estr.max := sizeof(estr.str);        {init local var string}
  s.len := 0;                          {init output string to empty}
  sys_error_none (stat);               {init to no error}
  sys_langp_curr_get (lang_p);         {get pointer to data about current language}

  man := fp;                           {make local copy of input number}
  if man < 0
    then begin                         {input number is negative}
      man := -man;
      man_neg := true;
      end
    else begin                         {input number is zero or positive}
      man_neg := false;
      end
    ;
{
*   Get the mantissa roughly in the range near 1.0.
}
  exp := 0;                            {init exponent value}
  zero := false;                       {init to input value was not zero}
  if man <= 0.0 then begin             {mantissa essentially zero ?}
    man_dig[0] := 0;                   {indicate one zero digit present}
    dig_first := 0;
    dig_last := 0;
    zero := true;                      {set flag indicating value is zero}
    goto done_digits;                  {all done finding raw digits}
    end;
  if man >= 1.0
    then begin                         {mantissa is too big}
      while man >= exp_chunk_max do begin {loop until within rough range}
        man := man / exp_chunk_val;
        exp := exp + exp_chunk_n;
        end;
      end
    else begin                         {mantissa may be too small}
      while man < exp_chunk_min do begin {loop until within rough range}
        man := man * exp_chunk_val;
        exp := exp - exp_chunk_n;
        end;
      end
    ;
{
*   Adjust the exponent more finely to put the mantissa value just below 1.0.
}
  while man < 0.1 do begin
    man := man * 10.0;
    exp := exp - 1;
    end;
  while man >= 1.0 do begin
    man := man / 10.0;
    exp := exp + 1;
    end;
{
*   MAN is the mantissa magnitude that has been scaled to be as large as possible
*   while still being below 1.0.  EXP is the power of ten exponent value
*   valid for the scaled mantissa.  MAN_NEG is true if the overall value
*   is negative.
}
  for dig_last := 0 to max_dig do begin {once for each digit to create}
    j := trunc(man);                   {make this digit}
    man_dig[dig_last] := j;            {store this digit}
    man := man - j;                    {remove digit from number}
    man := man * 10.0;                 {get ready for next digit}
    end;
  dig_first := 0;                      {set index of first digit in array}
  dig_last := max_dig;                 {set index of last digit in array}
  while                                {look for first non-zero digit}
      (dig_first < dig_last) and
      (man_dig[dig_first] = 0)
      do begin
    dig_first := dig_first + 1;        {skip over this zero digit}
    exp := exp - 1;                    {adjust exponent accordingly}
    end;
done_digits:                           {all done creating raw digits}
{
*   The raw digits are in the MAN_DIG array from entries DIG_FIRST to DIG_LAST.
*   It is guaranteed that the first digit is either less than 9, or there is
*   one available entry in MAN_DIG before DIG_FIRST.  This is important because
*   the number may be incremented by rounding.
*
*   Now determine formatting.  A subroutine is called to determine DIG_LEFT,
*   DIG_RIGHT, etc. for the current set of digits.  Once the used digits
*   have been determined, the number is rounded.  The formatting and rounding
*   process is repeated if an extra digit is created by the rounding process
}
reformat:                              {back here to reformat after rounding}
  format;                              {do first pass formatting}
  if error then return;                {no suitable format could be found ?}

  if zero then goto done_format;       {don't try to round zero value}
  i := dig_left + dig_right + dig_start; {first index after last digit to write}
  i := min(i, max_dig);                {clip to last digit actually created}
  if i < dig_first                     {no digit exists here to round ?}
    then goto done_format;
  dig_last := i - 1;                   {index to last valid digit after rounding}
  if man_dig[i] >= 5 then begin        {round up the least significant digit ?}
    man_dig[i-1] := man_dig[i-1] + 1;  {carry into last digit that will be used}
    man_dig[i] := 0;                   {prevent this round from happening again}
    end;
  for j := dig_last downto dig_first do begin {scan least to most significant digits}
    if man_dig[j] > 9 then begin       {this digit overflowed ?}
      man_dig[j] := man_dig[j] - 10;
      man_dig[j-1] := man_dig[j-1] + 1; {carry 1 into next digit}
      end;
    end;
  if                                   {rounding created another digit ?}
      (dig_first > 0) and
      ((man_dig[dig_first-1]) <> 0)
      then begin
    dig_first := dig_first - 1;        {first digit is newly created digit}
    exp := exp + 1;                    {adjust exponent accordingly}
    goto reformat;                     {back and recompute formatting}
    end;
done_format:                           {all done getting formatting info}
{
*   Most of the formatting issues have been decided.  Now write the actual
*   characters of the returned string.
}
  if man_neg
    then begin                         {mantissa is negative}
      man_sign := true;
      man_sign_c := '-';
      end
    else begin                         {mantissa is positive}
      if string_ffp_plus_man_k in flags
        then begin                     {plus sign requested}
          man_sign := true;
          man_sign_c := '+';
          end
        else begin                     {no sign needed}
          man_sign := false;
          end
        ;
      end
    ;                                  {done setting MAN_SIGN and MAN_SIGN_C}
{
*   Write sign and padding.
}
  if string_ffp_leadz_k in flags
    then begin                         {pad with zeros}
      if man_sign then begin           {need to write sign ?}
        string_append1 (s, man_sign_c);
        end;
      while pad_n > 0 do begin         {once for each padding character}
        string_append1 (s, '0');       {add on this padding character}
        pad_n := pad_n - 1;            {one less padding character left to go}
        end;
      end
    else begin                         {pad with spaces}
      while pad_n > 0 do begin         {once for each padding character}
        string_append1 (s, ' ');       {add on this padding character}
        pad_n := pad_n - 1;            {one less padding character left to go}
        end;
      if man_sign then begin           {need to write sign ?}
        string_append1 (s, man_sign_c);
        end;
      end
    ;
{
*   Write the digits and group characters to the left of the decimal point.
}
  i := dig_start;                      {init index for next digit to write}
  group_phase :=                       {initial phase into writing group characters}
    ((dig_left - 1) mod lang_p^.digits_group_n) + 1;
  for j := 1 to dig_left do begin      {write digits left of decimal point}
    if (i >= dig_first) and (i <= dig_last)
      then begin                       {this is a real digit from digits array}
        c := chr(man_dig[i] + ord('0'));
        end
      else begin                       {outside of real digits, substitute zero}
        c := '0';
        end
      ;
    string_append1 (s, c);             {add this digit to output string}
    i := i + 1;                        {advance index for next digit to write}
    if j >= dig_left then exit;        {this was last digit to left of point ?}
    group_phase := group_phase - 1;    {one more character into current group}
    if group_phase <= 0 then begin     {this last character ended a group ?}
      group_phase := lang_p^.digits_group_n; {reset group phase}
      if string_ffp_group_k in flags then begin {write digits in groups specified ?}
        string_append1 (s, lang_p^.digits_group_c); {write group separator character}
        end;
      end;
    end;                               {back for next digit before decimal point}
{
*   Write decimal point, if present.
}
  if write_point then begin            {supposed to write decimal point ?}
    string_append1 (s, lang_p^.decimal); {write the decimal point}
    end;
{
*   Write the digits and group characters to the right of the decimal point.
}
  group_phase := lang_p^.digits_group_n; {init phase into digit group}
  for j := 1 to dig_right do begin     {write digits right of decimal point}
    if (i >= dig_first) and (i <= dig_last)
      then begin                       {this is a real digit from digits array}
        c := chr(man_dig[i] + ord('0'));
        end
      else begin                       {outside of real digits, substitute zero}
        c := '0';
        end
      ;
    string_append1 (s, c);             {add this digit to output string}
    if j >= dig_right then exit;       {this was last digit to right of point ?}
    i := i + 1;                        {advance index for next digit to write}
    group_phase := group_phase - 1;    {one more character into current group}
    if group_phase <= 0 then begin     {this last character ended a group ?}
      group_phase := lang_p^.digits_group_n; {reset group phase}
      if string_ffp_group_k in flags then begin {write digits in groups specified ?}
        string_append1 (s, lang_p^.digits_group_c); {write group separator character}
        end;
      end;
    end;                               {back for next digit before decimal point}
{
*   Write exponent, if present.  The exponent string is stored backwards in ESTR.
}
  for j := estr.len downto 1 do begin  {scan exponent string backwards}
    string_append1 (s, estr.str[j]);
    end;
  end;
