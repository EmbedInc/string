{   Subroutine STRING_F_INT16H (S, I)
*
*   Convert 16 bit integer I to a 4 character HEX string in S.
}
module string_f_int16h;
define string_f_int16h;
%include '/cognivision_links/dsee_libs/string/string2.ins.pas';

procedure string_f_int16h (            {make HEX string from 16 bit integer}
  in out  s: univ string_var_arg_t;    {output string}
  in      i: sys_int_min16_t);         {input integer, uses low 16 bits}
  val_param;

var
  im: sys_int_max_t;                   {integer of right format for convert routine}
  stat: sys_err_t;                     {error code}

begin
  im := i & 16#FFFF;                   {into format for convert routine}
  string_f_int_max_base (              {make string from integer}
    s,                                 {output string}
    im,                                {input integer}
    16,                                {number base}
    4,                                 {output field width}
    [string_fi_leadz_k,                {write leading zeros}
     string_fi_unsig_k],               {input number is unsigned}
    stat);
  sys_error_abort (stat, 'string', 'internal', nil, 0);
  end;
