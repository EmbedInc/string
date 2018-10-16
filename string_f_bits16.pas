{   Subroutine STRING_F_BITS16 (S, BITS)
*
*   Convert the low 16 bits in BITS into a 16 character string of ones or
*   zeroes in S.  The string length is truncated to the maximum of S.
}
module string_f_bits16;
define string_f_bits16;
%include '/cognivision_links/dsee_libs/string/string2.ins.pas';

procedure string_f_bits16 (            {16 digit binary string from 16 bit integer}
  in out  s: univ string_var_arg_t;    {output string}
  in      bits: sys_int_min16_t);      {input integer, uses low 32 bits}
  val_param;

var
  i: sys_int_max_t;                    {integer of right format for convert routine}
  stat: sys_err_t;                     {error code}

begin
  i := bits & 16#FFFF;                 {into format for convert routine}
  string_f_int_max_base (              {make string from integer}
    s,                                 {output string}
    i,                                 {input integer}
    2,                                 {number base}
    16,                                {output field width}
    [string_fi_leadz_k,                {write leading zeros}
     string_fi_unsig_k],               {input number is unsigned}
    stat);
  sys_error_abort (stat, 'string', 'internal', nil, 0);
  end;
