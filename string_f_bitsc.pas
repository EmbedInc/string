{   Subroutine STRING_F_BITSC (S, BITS)
*
*   Make 8 digit binary string from the bits in the character BITS.  The string
*   will be truncated on the right to the maximum length of S.
}
module string_f_bitsc;
define string_f_bitsc;
%include '/cognivision_links/dsee_libs/string/string2.ins.pas';

procedure string_f_bitsc (             {make 8 digit binary string from character}
  in out  s: univ string_var_arg_t;    {output string}
  in      bits: char);                 {input byte}
  val_param;

var
  i: sys_int_max_t;                    {integer of right format for convert routine}
  stat: sys_err_t;                     {error code}

begin
  i := ord(bits) & 16#FF;              {into format for convert routine}
  string_f_int_max_base (              {make string from integer}
    s,                                 {output string}
    i,                                 {input integer}
    2,                                 {number base}
    8,                                 {output field width}
    [string_fi_leadz_k,                {write leading zeros}
     string_fi_unsig_k],               {input number is unsigned}
    stat);
  sys_error_abort (stat, 'string', 'internal', nil, 0);
  end;
