{   Module of STRING library routines that deal with Cognivision messages.
*   All these routines are portable and completely layered on the messages
*   facility in the SYS and FILE libraries.
}
module string_message;
define string_f_message;
define string_f_messaget;
%include '/cognivision_links/dsee_libs/string/string2.ins.pas';
%include '/cognivision_links/dsee_libs/file/file.ins.pas';
{
*********************************************************************
*
*   Function STRING_F_MESSAGET (S, SUBSYS, MSG, PARMS, N_PARMS)
*
*   Similar to  subroutine STRING_F_MESSAGE.  If the message is not found,
*   string S is trahsed and the function returns FALSE.  If the message
*   is found, S is set and the function returns TRUE.  Note also that
*   the SUBSYS and MSG parameters are var strings whereas for subroutine
*   STRING_F_MESSAGE they are regular strings.
}
function string_f_messaget (           {test for msg, expand to string}
  in out  s: univ string_var_arg_t;    {output string, trashed on message not found}
  in      subsys: univ string_var_arg_t; {subsystem name (generic msg file name)}
  in      msg: univ string_var_arg_t;  {message name withing message file}
  in      parms: univ sys_parm_msg_ar_t; {array of parameter descriptors}
  in      n_parms: sys_int_machine_t)  {number of parameters in PARMS}
  :boolean;                            {TRUE if message found and S set}
  val_param;

var
  conn: file_conn_t;                   {handle to open message}
  stat: sys_err_t;

begin
  string_f_messaget := false;          {init to no message returned}
  if (subsys.len <= 0) or (msg.len <= 0) then return; {no message specified ?}

  file_open_read_msg (                 {open the message for reading}
    subsys,                            {generic message file name}
    msg,                               {message name within message file}
    parms,                             {parameters for this message}
    n_parms,                           {number of parameters in PARMS}
    conn,                              {returned handle to message read connection}
    stat);
  if sys_error(stat) then return;      {unable to open message ?}

  file_read_msg (                      {read first line from message}
    conn,                              {handle to message open for read}
    s.max,                             {maximum line width}
    s,                                 {returned message line}
    stat);
  file_close (conn);                   {close connection to message}
  if sys_error(stat) then return;      {error reading message contents ?}

  string_f_messaget := true;           {indicate message read successfully}
  return;                              {normal return point}
  end;
{
*********************************************************************
*
*   Subroutine STRING_F_MESSAGE (S, SUBSYS, MSG, PARMS, N_PARMS)
*
*   Expand a message from a message file into the string S.  If the message
*   is longer than S, then the end of the message will be lost.  For messages
*   with fixed formatting, only the first line will be read.
*   SUBSYS, MSG, PARMS, and N_PARMS are the usual parameters for specifying
*   a message from a message file.  If the message is not found, then
*   the string "Subsystem XXX message YYY" is returned, where XXX is the
*   upper case subsystem name and YYY the upper case message name.
*   If no message was specified (either SUBSYS or MSG is blank), then the
*   empty string is returned.
}
procedure string_f_message (           {expand MSG file message into single string}
  in out  s: univ string_var_arg_t;    {out string, default subsys and msg names}
  in      subsys: string;              {name of subsystem, used to find message file}
  in      msg: string;                 {message name withing subsystem file}
  in      parms: univ sys_parm_msg_ar_t; {array of parameter descriptors}
  in      n_parms: sys_int_machine_t); {number of parameters in PARMS}
  val_param;

var
  gnam: string_leafname_t;             {message file generic name}
  vmsg: string_var80_t;                {name of message within subsystem}

begin
  gnam.max := size_char(gnam.str);     {init local var strings}
  vmsg.max := size_char(vmsg.str);

  string_vstring (gnam, subsys, sizeof(subsys)); {make vstring generic msg fnam}
  string_vstring (vmsg, msg, sizeof(msg)); {make vstring message name}

  if (gnam.len <= 0) or (vmsg.len <= 0) then begin {no message specified ?}
    s.len := 0;                        {pass back empty string}
    return;
    end;

  if string_f_messaget (               {message read successfully ?}
      s,                               {returned string}
      gnam,                            {generic message file name}
      vmsg,                            {message name within message file}
      parms,                           {parameters for this message}
      n_parms)                         {number of parameters in PARMS}
    then return;                       {read message, all done}
{
*   Unable to read the message.  Indicate the message name and subsystem.
}
  string_vstring (s, 'Subsystem '(0), -1);
  string_upcase (gnam);
  string_append (s, gnam);
  string_appends (s, ', message '(0));
  string_upcase (vmsg);
  string_append (s, vmsg);
  end;
