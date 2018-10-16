{   Subroutine STRING_CMLINE_REUSE
*
*   Cause the last token read from the command line to be re-used when then
*   next token is requested.
}
module string_cmline_reuse;
define string_cmline_reuse;
%include 'string2.ins.pas';

procedure string_cmline_reuse;         {re-use last token from from command line}

var
  msg_parms:                           {parameters for passing to message}
    array[1..1] of sys_parm_msg_t;

begin
  if cmline_reuse then begin           {re-use flag already set ?}
    sys_msg_parm_vstr (msg_parms[1], cmline_token_last);
    sys_message_parms ('string', 'reuse_reuse', msg_parms, 1);
    sys_bomb;
    end;
  if cmline_next_n <= 1 then begin     {no token to re-use}
    sys_message ('string', 'no_reuse_token');
    sys_bomb;
    end;
  cmline_reuse := true;                {set flag to re-use last token}
  end;
