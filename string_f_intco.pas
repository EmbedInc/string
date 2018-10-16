{   Subroutine STRING_F_INTCO (S, BYTE)
*
*   Return the 3 character octal representation of the value in BYTE in string S.
}
module string_f_intco;
define string_f_intco;
%include '/cognivision_links/dsee_libs/string/string2.ins.pas';

procedure string_f_intco (             {make 3 char octal from character}
  in out  s: univ string_var_arg_t;    {output string}
  in      byte: char);                 {input byte}
  val_param;

var
  im: sys_int_max_t;                   {integer of right format for convert routine}
  stat: sys_err_t;                     {error code}

begin
  im := ord(byte) & 16#FF;             {into format for convert routine}
  string_f_int_max_base (              {make string from integer}
    s,                                 {output string}
    im,                                {input integer}
    8,                                 {number base}
    3,                                 {output field width}
    [string_fi_leadz_k,                {write leading zeros}
     string_fi_unsig_k],               {input number is unsigned}
    stat);
  sys_error_abort (stat, 'string', 'internal', nil, 0);
  end;
