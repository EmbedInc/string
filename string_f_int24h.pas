{   Subroutine STRING_F_INT24H (S, I)
*
*   Convert 24 bit integer I to a 6 character HEX string in S.  Only
*   the low 24 bits of I are used.
}
module string_f_int24h;
define string_f_int24h;
%include 'string2.ins.pas';

procedure string_f_int24h (            {make HEX string from 24 bit integer}
  in out  s: univ string_var_arg_t;    {output string}
  in      i: sys_int_max_t);           {input integer, uses low 24 bits}
  val_param;

var
  stat: sys_err_t;                     {error code}

begin
  string_f_int_max_base (              {make string from integer}
    s,                                 {output string}
    i & 16#FFFFFF,                     {input integer}
    16,                                {number base}
    6,                                 {output field width}
    [string_fi_leadz_k,                {write leading zeros}
     string_fi_unsig_k],               {input number is unsigned}
    stat);
  sys_error_abort (stat, 'string', 'internal', nil, 0);
  end;
