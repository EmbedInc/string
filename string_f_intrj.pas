{   Subroutine STRING_F_INTRJ (S, I, FW, STAT)
*
*   Create the string representation of the machine integer I in the
*   variable length string S.  I will be right justified in a field of
*   width FW.  STAT is the completion status code.  It will be abnormal
*   if FW is too small for the value in I.
}
module string_f_intrj;
define string_f_intrj;
%include '/cognivision_links/dsee_libs/string/string2.ins.pas';

procedure string_f_intrj (             {right-justified string from machine integer}
  in out  s: univ string_var_arg_t;    {output string}
  in      i: sys_int_machine_t;        {input integer}
  in      fw: string_index_t;          {width of output field in string S}
  out     stat: sys_err_t);            {completion code}
  val_param;

var
  im: sys_int_max_t;                   {integer of right format for convert routine}

begin
  im := i;                             {into format for convert routine}
  string_f_int_max_base (              {make string from integer}
    s,                                 {output string}
    im,                                {input integer}
    10,                                {number base}
    fw,                                {output field width in characters}
    [],                                {signed number, no lead zeros or plus}
    stat);
  end;
