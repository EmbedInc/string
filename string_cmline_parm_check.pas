{   Subroutine STRING_CMLINE_PARM_CHECK (STAT,OPT)
*
*   Check for error on processing parameter to command line option OPT.  STAT
*   is the status code indicating the status of processing the parameter.
}
module string_CMLINE_PARM_CHECK;
define string_cmline_parm_check;
%include '/cognivision_links/dsee_libs/string/string2.ins.pas';

procedure string_cmline_parm_check (   {check for bad parameter to cmd line option}
  in      stat: sys_err_t;             {status code for reading or using parm}
  in      opt: univ string_var_arg_t); {name of cmd line option parm belongs to}

var
  msg_parm:                            {references to parameters for messages}
    array[1..2] of sys_parm_msg_t;

begin
  if not sys_error(stat) then return;

  sys_msg_parm_vstr (msg_parm[1], cmline_token_last);
  sys_msg_parm_vstr (msg_parm[2], opt);
  sys_error_print (stat, 'string', 'cmline_parm_bad', msg_parm, 2);
  sys_bomb;
  end;
