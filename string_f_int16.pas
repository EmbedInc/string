{   Subroutine STRING_F_INT16 (S, I)
*
*   Create the string representation of the integer I in the
*   variable length string S.  The least number of characters
*   possible are used to represent the integer.
}
module string_f_int16;
define string_f_int16;
%include '/cognivision_links/dsee_libs/string/string2.ins.pas';

procedure string_f_int16 (             {make string from 16 bit integer}
  in out  s: univ string_var_arg_t;    {output string}
  in      i: sys_int_min16_t);         {input integer, uses low 16 bits}
  val_param;

var
  im: sys_int_max_t;                   {integer of right format for convert routine}
  stat: sys_err_t;                     {error code}

begin
  im := i;                             {into format for convert routine}
  string_f_int_max_base (              {make string from integer}
    s,                                 {output string}
    im,                                {input integer}
    10,                                {number base}
    0,                                 {use free format, no fixed field width}
    [],                                {signed number, no lead zeros or plus}
    stat);
  sys_error_abort (stat, 'string', 'internal', nil, 0);
  end;
