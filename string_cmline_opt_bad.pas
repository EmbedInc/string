{   Subroutine STRING_CMLINE_OPT_BAD
*
*   The last token read from the command line was an unrecognized command line
*   option.  Print appropriate message and bomb program.
}
module string_CMLINE_OPT_BAD;
define string_cmline_opt_bad;
%include '/cognivision_links/dsee_libs/string/string2.ins.pas';

procedure string_cmline_opt_bad;       {indicate last cmd line token was bad}
  options (noreturn);

var
  msg_parm:                            {parameter references for message}
    array[1..1] of sys_parm_msg_t;

begin
  sys_msg_parm_vstr (msg_parm[1], cmline_token_last);
  sys_message_bomb ('string', 'cmline_opt_bad', msg_parm, 1);
  end;
