{   Routines that append numerical values to the end of a existing string.
}
module string_append_num;
define string_append_bin;
define string_append_eng;
define string_append_fp_fixed;
define string_append_fp_free;
define string_append_hex;
define string_append_ints;
define string_append_intu;
%include 'string2.ins.pas';
{
********************************************************************************
*
*   Subroutine STRING_APPEND_BIN (STR, II, NB)
*
*   Append the binary representation of the integer II to the string STR.  NB is
*   the number of bits.  This is both the number of characters that will be
*   appended and the number of low bits of II that are relevant.  The input
*   value is in the low NB bits of II.
}
procedure string_append_bin (          {append binary integer to string}
  in out  str: univ string_var_arg_t;  {string to append to}
  in      ii: sys_int_machine_t;       {integer value to append in low NB bits}
  in      nb: sys_int_machine_t);      {number of bits, higher bits in II ignored}
  val_param;

var
  ival: sys_int_machine_t;             {input value with unused bits set to 0}
  tk: string_var32_t;                  {the string to append}
  stat: sys_err_t;                     {completion status}

begin
  tk.max := size_char(tk.str);         {init local var string}

  ival := ii & ~lshft(~0, nb);         {make input value with unused bits masked off}
  string_f_int_max_base (              {make the binary string}
    tk,                                {output string}
    ival,                              {input value}
    2,                                 {number base}
    nb,                                {fixed field width}
    [ string_fi_leadz_k,               {write leading zeros}
      string_fi_unsig_k],              {consider the input value to be unsigned}
    stat);

  if not sys_error(stat) then begin
    string_append (str, tk);
    end;
  end;
{
********************************************************************************
*
*   Subroutine STRING_APPEND_ENG (STR, FP, MIN_SIG)
*
*   Append the value of FP in engineering notation to STR.  MIN_SIG is the
*   minimum required number of significant digits.  The exponent of 1000 will be
*   chosen so that 1-3 digits are left of the point.  For exponents with a
*   common one-character abbreviation (like "k" for 1000), the number will be
*   written, followed by a space, followed by the multiple of 1000 abbreviation.
*   For exponents of 1000 outside the named range, the number will be written,
*   followed by "e", followed by the exponent of 1000 multiplier, followed by a
*   space.
}
procedure string_append_eng (          {append number in engineering notation}
  in out  str: univ string_var_arg_t;  {string to append to}
  in      fp: sys_fp_max_t;            {input floating point number}
  in      min_sig: sys_int_machine_t); {min required significant digits}
  val_param;

var
  tk: string_var32_t;                  {number string}
  un: string_var32_t;                  {exponent of 1000 name string}

begin
  tk.max := size_char(tk.str);         {init local var string}

  string_f_fp_eng (                    {make engineering notation strings}
    tk,                                {returned number string}
    fp,                                {the value to convert}
    min_sig,                           {min required significan digits}
    un);                               {power of 1000 units prefix}

  string_append (str, tk);             {append the raw number}
  if un.len <= 0
    then begin                         {no power of 1000 name}
      string_append1 (str, ' ');
      end
    else begin                         {have named power of 1000}
      string_append (str, un);
      end
    ;
  end;
{
********************************************************************************
*
*   Subroutine STRING_APPEND_FP_FIXED (STR, FP, FW, DIG_RIGHT)
*
*   Append the floating point string representation of the FP to the string STR.
*   FW is the fixed number of characters to append.  The floating point string
*   will be padded with leading blanks to fill the field.  The special FW value
*   of 0 indicates to not add any leading blanks.  DIG_RIGHT is the fixed number
*   of digits right of the decimal point.
}
procedure string_append_fp_fixed (     {append fixed-format floating point to string}
  in out  str: univ string_var_arg_t;  {string to append to}
  in      fp: sys_fp_max_t;            {input floating point number}
  in      fw: sys_int_machine_t;       {total field width, 0 for min left of point}
  in      dig_right: sys_int_machine_t); {digits to right of decimal point}
  val_param;

var
  tk: string_var32_t;                  {the string to append}
  ii, jj: sys_int_machine_t;           {scratch integers and loop counters}
  stat: sys_err_t;                     {completion status}

begin
  tk.max := size_char(tk.str);         {init local var string}

  string_f_fp (                        {make string from floating point value}
    tk,                                {output string}
    fp,                                {input value}
    fw,                                {fixed field width for number}
    0,                                 {no fixed field width for exponent}
    0,                                 {min required significant digits}
    12,                                {max digits allowed left of point}
    dig_right, dig_right,              {min and max digits right of point}
    [string_ffp_group_k],              {write digit group characters}
    stat);

  if                                   {"star out" the number on error}
      sys_error(stat) or               {hard error converting to string ?}
      ((fw > 0) and (tk.len > fw))     {field overflow ?}
      then begin
    for ii := 1 to fw do begin
      string_append1 (str, '*');
      end;
    return;
    end;

  if fw > 0 then begin                 {fixed field width ?}
    jj := fw - tk.len;                 {number of leading blanks to add}
    for ii := 1 to jj do begin         {add the leading blanks}
      string_append1 (str, ' ');
      end;
    end;

  string_append (str, tk);             {add the number string}
  end;
{
********************************************************************************
*
*   Subroutine STRING_APPEND_FP_FIXED (STR, FP, MIN_SIG)
*
*   Append the floating point string representation of the FP to the string STR.
*   MIN_SIG is the minimum required number of significant digits in the string
*   representation of FP.
}
procedure string_append_fp_free (      {append free-format floating point to string}
  in out  str: univ string_var_arg_t;  {string to append to}
  in      fp: sys_fp_max_t;            {input floating point number}
  in      min_sig: sys_int_machine_t); {min required significant digits}
  val_param;

var
  tk: string_var32_t;                  {the string to append}
  stat: sys_err_t;                     {completion status}

begin
  tk.max := size_char(tk.str);         {init local var string}

  string_f_fp (                        {make string from floating point value}
    tk,                                {output string}
    fp,                                {input value}
    0,                                 {no fixed field width for number}
    0,                                 {no fixed field width for exponent}
    min_sig,                           {min required significant digits}
    min_sig + 6,                       {max digits allowed left of point}
    0, 6,                              {min and max digits right of point}
    [ string_ffp_exp_eng_k,            {exponent always multiple of 3}
      string_ffp_group_k],             {write digit group characters}
    stat);

  string_append (str, tk);
  end;
{
********************************************************************************
*
*   Subroutine STRING_APPEND_HEX (STR, II, NB)
*
*   Append the hexadecimal (base 16) representation of the integer in the low NB
*   bits of II to the string STR.  The appended string will (NB + 3) div 4
*   characters long.
}
procedure string_append_hex (          {append hexadecimal integer to string}
  in out  str: univ string_var_arg_t;  {string to append to}
  in      ii: sys_int_machine_t;       {integer value to append in low NB bits}
  in      nb: sys_int_machine_t);      {number of bits, higher bits in II ignored}
  val_param;

var
  ival: sys_int_machine_t;             {input value with unused bits set to 0}
  tk: string_var32_t;                  {the string to append}
  stat: sys_err_t;                     {completion status}

begin
  tk.max := size_char(tk.str);         {init local var string}

  ival := ii & ~lshft(~0, nb);         {make input value with unused bits masked off}
  string_f_int_max_base (              {make the binary string}
    tk,                                {output string}
    ival,                              {input value}
    16,                                {number base}
    (nb + 3) div 4,                    {fixed field width}
    [ string_fi_leadz_k,               {write leading zeros}
      string_fi_unsig_k],              {consider the input value to be unsigned}
    stat);

  if not sys_error(stat) then begin
    string_append (str, tk);
    end;
  end;
{
********************************************************************************
*
*   Subroutine STRING_APPEND_INTS (STR, II, FW)
*
*   Append the decimal integer representation of the signed value II to the
*   string STR.  FW is the fixed field width to use.  Leading blanks will be
*   added to fill the field as necessary.  The special FW value of 0 causes as
*   many digits as necessary but without leading zeros or blanks to be appended
*   to STR.
}
procedure string_append_ints (         {append signed decimal integer to string}
  in out  str: univ string_var_arg_t;  {string to append to}
  in      ii: sys_int_machine_t;       {integer value to append}
  in      fw: sys_int_machine_t);      {fixed field width, or 0 for min required}
  val_param;

var
  tk: string_var32_t;                  {the string to append}
  jj: sys_int_machine_t;               {scratch integer and loop counter}
  stat: sys_err_t;                     {completion status}

begin
  tk.max := size_char(tk.str);         {init local var string}

  string_f_int_max_base (              {make the binary string}
    tk,                                {output string}
    ii,                                {input value}
    10,                                {number base}
    fw,                                {fixed field width, 0 for free form}
    [],                                {no additional modifiers}
    stat);

  if                                   {"star out" the number on error}
      sys_error(stat) and              {hard error converting to string ?}
      (fw > 0)                         {need to fill fixed field ?}
      then begin
    for jj := 1 to fw do begin
      string_append1 (str, '*');
      end;
    return;
    end;

  if not sys_error(stat) then begin
    string_append (str, tk);
    end;
  end;
{
********************************************************************************
*
*   Subroutine STRING_APPEND_INTS (STR, II, FW)
*
*   Append the decimal integer representation of the unsigned value II to the
*   string STR.  FW is the fixed field width to use.  Leading blanks will be
*   added to fill the field as necessary.  The special FW value of 0 causes as
*   many digits as necessary but without leading zeros or blanks to be appended
*   to STR.
}
procedure string_append_intu (         {append unsigned decimal integer to string}
  in out  str: univ string_var_arg_t;  {string to append to}
  in      ii: sys_int_machine_t;       {integer value to append}
  in      fw: sys_int_machine_t);      {fixed field width, or 0 for min required}
  val_param;

var
  tk: string_var32_t;                  {the string to append}
  jj: sys_int_machine_t;               {scratch integer and loop counter}
  stat: sys_err_t;                     {completion status}

begin
  tk.max := size_char(tk.str);         {init local var string}

  string_f_int_max_base (              {make the binary string}
    tk,                                {output string}
    ii,                                {input value}
    10,                                {number base}
    fw,                                {fixed field width, 0 for free form}
    [string_fi_unsig_k],               {the input number is unsigned}
    stat);

  if                                   {"star out" the number on error}
      sys_error(stat) and              {hard error converting to string ?}
      (fw > 0)                         {need to fill fixed field ?}
      then begin
    for jj := 1 to fw do begin
      string_append1 (str, '*');
      end;
    return;
    end;

  if not sys_error(stat) then begin
    string_append (str, tk);
    end;
  end;
