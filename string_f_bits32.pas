{   Subroutine STRING_F_BITS32 (S, BITS)
*
*   Convert the 32 bit word in BITS into a 32 character string of ones or
*   zeroes in S.  The string length is truncated to the maximum
*   of S.
}
module string_f_bits32;
define string_f_bits32;
%include 'string2.ins.pas';

procedure string_f_bits32 (            {32 digit binary string from 32 bit integer}
  in out  s: univ string_var_arg_t;    {output string}
  in      bits: sys_int_min32_t);      {input integer, uses low 32 bits}
  val_param;

var
  i: sys_int_max_t;                    {integer of right format for convert routine}
  stat: sys_err_t;                     {error code}

begin
  i := bits & 16#FFFFFFFF;             {into format for convert routine}
  string_f_int_max_base (              {make string from integer}
    s,                                 {output string}
    i,                                 {input integer}
    2,                                 {number base}
    32,                                {output field width}
    [string_fi_leadz_k,                {write leading zeros}
     string_fi_unsig_k],               {input number is unsigned}
    stat);
  sys_error_abort (stat, 'string', 'internal', nil, 0);
  end;
