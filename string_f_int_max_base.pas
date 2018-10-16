{   Subroutine STRING_F_INT_MAX_BASE (S, I, BASE, FW, FLAGS, STAT)
*
*   Create the string representation of the integer I in string S.  BASE is the
*   number base to use for string conversion.  The output string is truncated on
*   the right to the maximum size of S.  FW is the field width to use.  FW = 0
*   indicates free format (no padding).  FLAGS are a set of additional option flags
*   that can have the following meaning:
*
*   STRING_FI_LEADZ_K
*
*     Create leading zeros to fill the field width FW.  If the number is signed,
*     then the first character is left for the sign.
*
*   STRING_FI_PLUS_K
*
*     Explicitly create the "+" plus sign when the number is greater than zero.
*     The default is to only create a sign ("-") if the number is less than zero.
*     This option is only meaningful if the number is signed.
*
*   STRING_FI_UNSIG_K
*
*     Declare the input number to be unsigned.  No leading plus or minus sign
*     will be created.  No space will be left or a leading sign if the
*     STRING_FI_LEADZ_K option is specified.
*
*   "0" thru "9" are used for digit value 0-9, and A-Z are used for digit values
*   10-35.  The number base must be in the range from 2-36.
}
module string_f_int_max_base;
define string_f_int_max_base;
%include 'string2.ins.pas';

procedure string_f_int_max_base (      {make string from max integer, base supplied}
  in out  s: univ string_var_arg_t;    {output string, no leading zeros}
  in      i: sys_int_max_t;            {input integer}
  in      base: sys_int_machine_t;     {number base for output string}
  in      fw: string_index_t;          {field width, use 0 for free form}
  in      flags: string_fi_t;          {addtional option flags}
  out     stat: sys_err_t);            {completion status}
  val_param;

var
  v: sys_int_max_t;                    {local copy of integer value}
  t: sys_int_max_t;                    {temp copy of V for finding curr digit}
  d: sys_int_machine_t;                {value of current digit}
  st: string_var80_t;                  {temp local string with digits backwards}
  n: sys_int_machine_t;                {loop counter}
  sign: string_var4_t;                 {leading +,- sign}
  n_fill: sys_int_machine_t;           {number of filler padding characters needed}
  j: sys_int_machine_t;                {scratch integer}

label
  wrote_sign;

begin
  st.max := sizeof(st.str);            {init local var strings}
  sign.max := sizeof(sign.str);

  st.len := 0;                         {init number of characters generated}
  s.len := 0;                          {init number of characters returned}
  sys_error_none (stat);               {init to no error}
  v := i;                              {init internal magnitude of number to use}
  if not (string_fi_unsig_k in flags) then begin {input number is signed ?}
    v := abs(i);
    end;
{
*   Some input numbers may have a larger magnitude than can be represented
*   in a signed number the compiler lets us do math on.  Therefore the first
*   digit will be treated differently.  Extracting a digit is really doing an
*   integer divide with a remainder.  We can view the number as being twice
*   itself shifted right one, plus the value of the low bit that gets lost
*   (either 0 or 1).  In this way, we can do one divide, and still reconstruct
*   the correct quotient and remainder.  Once this is done to extract the first
*   digit, the remaining value is guaranteed to be within range of our math
*   capability, and can be processed normally.
}
  d := v & 1;                          {init remainder to low bit that will get lost}
  v := rshft(v, 1);                    {"half" of original number, can be mathed}
  t := v div base;                     {get quotient of the shifted number}
  d := d + 2*(v - (t * base));         {accumulate remainder of the two halfs}
  v := t * 2;                          {combine quotient of both halfs}
  if d >= base then begin              {overflow remainder into quotient ?}
    d := d - base;                     {wrap remainder}
    v := v + 1;                        {add excess remainder back into quotient}
    end;
  st.len := st.len + 1;                {one more character in output string}
  if d <= 9
    then begin                         {digit is in 0-9 range}
      st.str[st.len] := chr(ord('0') + d);
      end
    else begin                         {digit is in 10-35 range}
      st.str[st.len] := chr(ord('A') + d - 10);
      end
    ;
{
*   Extract successive digits from the number.  These are created in least
*   significant to most significant order.
}
  while v <> 0 do begin                {keep looping until only leading zeros left}
    t := v div base;                   {make value left after this digit}
    d := v - (t * base);               {0 to base-1 value of this digit}
    v := t;                            {update to value with this digit removed}
    st.len := st.len + 1;              {one more character in output string}
    if d <= 9
      then begin                       {digit is in 0-9 range}
        st.str[st.len] := chr(ord('0') + d);
        end
      else begin                       {digit is in 10-35 range}
        st.str[st.len] := chr(ord('A') + d - 10);
        end
      ;
    end;                               {back and create next digit}

  if st.len = 0 then begin             {no digits created, value was zero ?}
    st.len := 1;
    st.str[1] := '0';                  {raw digits string is one zero character}
    end;
{
*   The raw digits with no spaces, leading zeros, or sign are in ST in reverse
*   order.
*
*   Set SIGN to the +- sign character if any.  This may be either "+", "-", space,
*   or null string.
}
  sign.str[1] := ' ';                  {init to no sign character at all}
  sign.len := 0;

  if not (string_fi_unsig_k in flags) then begin {input number is signed ?}
    if i < 0 then begin                {need minus sign ?}
      sign.str[1] := '-';
      sign.len := 1;
      end;
    if (i > 0) and (string_fi_plus_k in flags) then begin {need plus sign ?}
      sign.str[1] := '+';
      sign.len := 1;
      end;
    end;
{
*   If a fixed field size is specified, pad the output string with either leading
*   zeros or spaces.
}
  if fw <> 0 then begin                {result is right justified in fixed field ?}
    n_fill := fw - sign.len - st.len;  {number of filler characters needed}
    if n_fill < 0 then begin           {field too small error ?}
      sys_stat_set (string_subsys_k, string_stat_fw_too_sml_k, stat);
      n := fw;                         {convert field width number to right format}
      sys_stat_parm_int (n, stat);     {pass field width to error message}
      s.len := 0;
      while (s.len < s.max) and (s.len < fw) do begin {return all "***" field}
        s.len := s.len + 1;
        s.str[s.len] := '*';
        end;
      return;                          {return with error}
      end;
    if string_fi_leadz_k in flags
      then begin                       {fill with leading zeros}
        string_append (s, sign);       {write +- sign, if exists}
        for n := 1 to n_fill do begin  {once for each padding character}
          if s.len >= s.max then return; {output string full ?}
          s.len := s.len + 1;          {make room for this character}
          s.str[s.len] := '0';         {write this leading zero character}
          end;                         {back for next leading zero character}
        goto wrote_sign;               {output string already has sign}
        end                            {done handling padding with leading zeros}
      else begin                       {fill field with spaces before number}
        for n := 1 to n_fill do begin  {once for each padding character}
          if s.len >= s.max then return; {output string full ?}
          s.len := s.len + 1;          {make room for this character}
          s.str[s.len] := ' ';         {write this leading space character}
          end;                         {back for next leading space character}
        end                            {done handling padding with leading spaces}
      ;                                {done padding output to fill fixed field}
    end;                               {done handling fixed-sized output field}
  string_append (s, sign);             {write +- sign, if exists}
wrote_sign:                            {sign now definately part of output string}
{
*   All that is left now is to append the raw output digits to S.  These are
*   sitting in S in reverse order.
}
  j := s.len + 1;                      {save index of next character to write to}
  s.len := min(s.max, s.len + st.len); {set length of final output string}
  for n := j to s.len do begin         {once for each character to copy}
    s.str[n] := st.str[st.len];        {copy this character}
    st.len := st.len - 1;              {make index for next character to copy}
    end;                               {back and copy next character}
  end;
