{   Subroutine STRING_T_BITSC (S, BITS, STAT)
*
*   Convert the string in S to the 8 bit CHAR in BITS.  STAT is the completion
*   status code.
}
module string_t_bitsc;
define string_t_bitsc;
%include 'string2.ins.pas';

procedure string_t_bitsc (             {convert 8 digit binary string to character}
  in      s: univ string_var_arg_t;    {input string}
  out     bits: char;                  {output character}
  out     stat: sys_err_t);            {completion status code}

var
  im: sys_int_max_t;                   {raw integer value}

begin
  string_t_int_max_base (              {convert string to raw integer}
    s,                                 {input string}
    2,                                 {number base of string}
    [],                                {signed number, blank is error}
    im,                                {raw integer value}
    stat);
  if sys_error(stat) then return;

  if (im >= -128) and (im <= 127)
    then begin                         {value is within range}
      bits := chr(im);                 {pass back result}
      end
    else begin                         {value is out of range}
      sys_stat_set (string_subsys_k, string_stat_ovfl_i_k, stat);
      sys_stat_parm_vstr (s, stat);
      end
    ;
  end;
