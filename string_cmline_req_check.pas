{   Subroutine STRING_CMLINE_REQ_CHECK (STAT)
*
*   Check for errors after attempting to read a required argument from the
*   command line.  STAT is the status returned when the command line argument
*   was read.
}
module string_cmline_req_check;
define string_cmline_req_check;
%include 'string2.ins.pas';

procedure string_cmline_req_check (    {test err after reading required cmd line arg}
  in      stat: sys_err_t);            {status code from getting command line arg}

var
  stat2: sys_err_t;                    {local copy of STAT}
  msg_parm:                            {parameters for messages}
    array[1..1] of sys_parm_msg_t;

begin
  if not sys_error(stat) then return;  {no error reading command line argument ?}

  stat2 := stat;                       {make STAT copy that STRING_EOS can alter}
  if string_eos(stat2) then begin      {hit end of command line ?}
    sys_msg_parm_int (msg_parm[1], cmline_next_n - 1);
    sys_message_bomb ('string', 'cmline_arg_missing', msg_parm, 1);
    end;

  sys_msg_parm_int (msg_parm[1], cmline_next_n - 1);
  sys_error_print (stat, 'string', 'cmline_arg_error', msg_parm, 1);
  sys_bomb;
  end;
