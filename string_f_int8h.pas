{   Subroutine STRING_F_INT8H (S, I)
*
*   Convert 8 bit integer I to a 2 character HEX string in S.  Only
*   the low 8 bits of I are used.
}
module string_f_int8h;
define string_f_int8h;
%include 'string2.ins.pas';

procedure string_f_int8h (             {make HEX string from 8 bit integer}
  in out  s: univ string_var_arg_t;    {output string}
  in      i: sys_int_max_t);           {input integer, uses low 8 bits}
  val_param;

var
  stat: sys_err_t;                     {error code}

begin
  string_f_int_max_base (              {make string from integer}
    s,                                 {output string}
    i & 16#FF,                         {input integer}
    16,                                {number base}
    2,                                 {output field width}
    [string_fi_leadz_k,                {write leading zeros}
     string_fi_unsig_k],               {input number is unsigned}
    stat);
  sys_error_abort (stat, 'string', 'internal', nil, 0);
  end;
