{   Subroutine STRING_CMLINE_END_ABORT
*
*   Print appropriate message and abort if there are any more unread tokens left
*   on the command line.
}
module string_CMLINE_END_ABORT;
define string_cmline_end_abort;
%include '/cognivision_links/dsee_libs/string/string2.ins.pas';

procedure string_cmline_end_abort;     {abort if unread tokens left on command line}

var
  token: string_var32_t;               {for trying to read next command line token}
  stat: sys_err_t;
  msg_parms:                           {references parameters passed to message}
    array[1..1] of sys_parm_msg_t;

begin
  token.max := sizeof(token.str);      {init var string}

  string_cmline_token (token, stat);   {try to read next command line token}
  if string_eos(stat) then return;     {really did hit end of command line ?}

  sys_error_abort (stat, 'string', 'cmline_opt_err', nil, 0); {some other error ?}

  sys_msg_parm_vstr (msg_parms[1], token);
  sys_message_parms ('string', 'cmline_extra_token', msg_parms, 1);
  sys_bomb;
  end;
