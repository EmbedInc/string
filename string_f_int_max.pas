{   Subroutine STRING_F_INT_MAX (S, I)
*
*   Make the string representation of integer I in string S.  The string will be
*   truncated on the right to the maximum size of S.
}
module string_f_int_max;
define string_f_int_max;
%include '/cognivision_links/dsee_libs/string/string2.ins.pas';

procedure string_f_int_max (           {make string from largest available integer}
  in out  s: univ string_var_arg_t;    {output string}
  in      i: sys_int_max_t);           {input integer}
  val_param;

var
  stat: sys_err_t;                     {error code}

begin
  string_f_int_max_base (              {make string from integer}
    s,                                 {output string}
    i,                                 {input integer}
    10,                                {number base}
    0,                                 {use free format, no fixed field width}
    [],                                {signed number, no lead zeros or plus}
    stat);
  sys_error_abort (stat, 'string', 'internal', nil, 0);
  end;
