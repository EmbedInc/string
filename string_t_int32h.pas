{   Subroutine STRING_T_INT32H (S,I,STAT)
*
*   Convert the string S to the integer I.  S is assumed to be in hexadecimal
*   notation.  STAT is the completion status code.
}
module string_t_int32h;
define string_t_int32h;
%include 'string2.ins.pas';

procedure string_t_int32h (            {convert HEX string to 32 bit integer}
  in      s: univ string_var_arg_t;    {input string}
  out     i: sys_int_min32_t;          {output integer, bits will be right justified}
  out     stat: sys_err_t);            {completion status code}

var
  im: sys_int_max_t;                   {raw integer value}

begin
  string_t_int_max_base (              {convert string to raw integer}
    s,                                 {input string}
    16,                                {number base of string}
    [string_ti_unsig_k],               {unsigned number, blank is error}
    im,                                {raw integer value}
    stat);
  if sys_error(stat) then return;
  if (im & 16#FFFFFFFF) = im
    then begin                         {value is within range}
      i := im;                         {pass back final value}
      end
    else begin                         {value is out of range}
      sys_stat_set (string_subsys_k, string_stat_ovfl_i_k, stat);
      sys_stat_parm_vstr (s, stat);
      end
    ;
  end;
