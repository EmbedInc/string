{   Subroutine STRING_EOS(STAT)
*
*   Return TRUE if STAT is indicating "end of string".
}
module string_eos;
define string_eos;
%include 'string2.ins.pas';

function string_eos (                  {test for END OF STRING status}
  in out  stat: sys_err_t)             {status code, reset to no error on EOS}
  :boolean;                            {TRUE if STAT indicated END OF STRING}

begin
  if
      stat.err and
      (stat.subsys = string_subsys_k) and
      (stat.code = string_stat_eos_k)
    then begin                         {IS end of string condition}
      string_eos := true;
      sys_error_none (stat);
      end
    else begin                         {is NOT end of string condition}
      string_eos := false;
      end
    ;
  end;
