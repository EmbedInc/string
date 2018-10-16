{   System-independent routines for dealing with tree names.
}
module string_treename;
define string_treename_opts;
define string_treename;
define string_treename_machine;
define string_set_nodename;
%include '(cog)source/string/string2.ins.pas';
%include '(cog)source/file/file.ins.pas';
%include '(cog)source/file/cogserve.ins.pas';
{
**********************************************************
*
*   Subroutine STRING_TREENAME_OPTS (INAM, OPTS, TNAM, TSTAT)
*
*   Translate the input pathname INAM into a treename in TNAM.  OPTS is
*   a set of flags that modify the behaviour.  The flags in OPTS may be:
*
*     STRING_TNAMOPT_FLINK_K - For pathnames that resolve to symbolic links, the
*       link will be followed.  The default is to return the name of the link
*       without following it.  Note that links are always followed if they are
*       not that last component of the pathname.
*
*     STRING_TNAMOPT_REMOTE_K - Continue translating the pathname on remote
*       machines, as needed.  By default, the pathname is only translated locally.
*
*     STRING_TNAMOPT_PROC_K - The pathname is to be translated from the point
*       of view of this process.  Certain pathname elements, like "~", are
*       process-specific.  By default, process-specific pathname elements
*       are not translated.
*
*     STRING_TNAMOPT_NATIVE_K - The native file system naming conventions will
*       be used for TNAM.  This flag is neccessary if TNAM is to be passed to
*       local system routines.
*
*   TSTAT indicates the translation status of the name in TNAM.  This routine
*   will set TSTAT to one of the following values:
*
*     STRING_TNSTAT_NATIVE_K - The name was fully translated as requested, and
*       is in native system form.
*
*     STRING_TNSTAT_COG_K - The name was fully translated as requested, and
*       is in Cognivision standard form.
*
*     STRING_TNSTAT_REMOTE_K - The name refers to a file system object that
*       resides on another machine.  Further translation may be required on
*       that machine.
*
*     STRING_TNSTAT_PROC_K - The name starts with a pathname element that must
*       be translated by the process "owning" the name.
*
*   Note that TNAM may be returned with a different node name than expected,
*   even with remote translation disable, for one of the following reasons:
*
*     1 - The path resolves to a file system object on this machine, but
*         this machine is known by more than one name.  In that case, the
*         "preferred" name of this machine will be used.
*
*     2 - The path name resolved to a file system object on another machine,
*         but that file system object can be accesses transparently with native
*         OS calls on this machine.
}
procedure string_treename_opts (       {treename with more control options}
  in      inam: univ string_var_arg_t; {input path name}
  in      opts: string_tnamopt_t;      {set of option flags}
  in out  tnam: univ string_var_arg_t; {output tree name}
  out     tstat: string_tnstat_k_t);   {translation result status}
  val_param;

var
  sinfo: csrv_server_info_t;           {info about remote COGSERVE server}
  conn: file_conn_t;                   {handle to COGSERVE server connection}
  path: string_var8192_t;              {input pathname for additional translation}
  node: string_var132_t;               {name of remote machine to translate on}
  cmd: csrv_cmd_t;                     {buffer for one command to server}
  rsp: csrv_rsp_t;                     {buffer for one response from server}
  i: sys_int_machine_t;                {scratch integer}
  len: sys_int_machine_t;              {string length}
  olen: sys_int_adr_t;                 {amount of data actually read in}
  stat: sys_err_t;

label
  got_local_result, remote_flagged, local, remote, abort;

begin
  path.max := size_char(path.str);     {init local var strings}
  node.max := size_char(node.str);

  string_treename_local (              {translate locally as far as possible}
    inam,                              {input pathname}
    opts,                              {translation option flags}
    tnam,                              {returned treename}
    tstat);                            {translation status of TNAM}
{
*   TNAM and TSTAT have just been set by the latest local translation attempt
*   on this machine.
}
got_local_result:
  if                                   {all done ?}
      (tstat <> string_tnstat_remote_k) or {remote translation not required ?}
      (not (string_tnamopt_remote_k in opts)) {remote translation not enabled ?}
    then return;
{
*   Extract remote machine name from TNAM into NODE.
}
remote_flagged:                        {remote translation flagged as needed}
  node.len := 0;                       {init extracted machine name to empty}
  i := 1;                              {init parse index}
  while (i <= tnam.len) and then (tnam.str[i] = '/') {skip leading "/" chars}
    do i := i + 1;
  while                                {loop until first "/" after tnam name}
      (i <= tnam.len) and then (tnam.str[i] <> '/')
      do begin
    if node.len >= node.max then exit; {no room for additional chars ?}
    node.len := node.len + 1;          {append this char to end of NODE}
    node.str[node.len] := tnam.str[i];
    i := i + 1;                        {advance to next TNAM character}
    end;                               {back for next char from TNAM}

  if not nodename_set then string_set_nodename; {make sure our machine name is set}
  if not string_equal (node, nodename) {translate not on this machine ?}
    then goto remote;
{
*   Further translation is needed on our machine.  This means some remote machine
*   bounced it back to us.
}
  string_copy (tnam, path);            {old output becomes new input}

local:                                 {pathname so far is in PATH}
  string_treename_local (              {translate pathname locally}
    path,                              {input pathname}
    opts,                              {translation option flags}
    tnam,                              {returned treename}
    tstat);                            {translation status of TNAM}
  goto got_local_result;               {done with local translation}
{
*   Further translation is needed on a remote machine.  The remote machine name
*   is in NODE, the pathname so far is in TNAM.
}
remote:
  csrv_connect (node, conn, sinfo, stat); {try to connect to remote server}
  if sys_error(stat) then return;      {can't go any further ?}

  cmd.cmd := csrv_cmd_tnam_k;          {fill in TNAM command packet}
  len := min(size_char(cmd.tnam.path), tnam.len); {number of chars to send}
  cmd.tnam.len := len;
  for i := 1 to len do begin           {once for each character to pass to server}
    cmd.tnam.path[i] := tnam.str[i];
    end;
  cmd.tnam.opts := [];                 {set the translation option flags}
  if string_tnamopt_flink_k in opts
    then cmd.tnam.opts := cmd.tnam.opts + [csrv_tnamopt_flink_k];
  if sinfo.flip then begin             {flip multi-byte values, if needed}
    sys_order_flip (cmd.cmd, sizeof(cmd.cmd));
    sys_order_flip (cmd.tnam.len, sizeof(cmd.tnam.len));
    end;

  file_write_inetstr (                 {send TNAM command to server}
    cmd,                               {output buffer}
    conn,                              {handle to server connection}
    offset(cmd.tnam.path) + sizeof(cmd.tnam.path[1])*len, {data size}
    stat);
  if sys_error(stat) then goto abort;

  file_read_inetstr (                  {read fixed length TNAM response from server}
    conn,                              {handle to server connection}
    offset(rsp.tnam.tnam),             {amount of data to read}
    [],                                {wait for data}
    rsp,                               {input buffer}
    olen,                              {amount of data actually read}
    stat);
  if sys_error(stat) then goto abort;

  if sinfo.flip then begin             {flip multi-byte values, if needed}
    sys_order_flip (rsp.rsp, sizeof(rsp.rsp));
    sys_order_flip (rsp.tnam.len, sizeof(rsp.tnam.len));
    end;
  if rsp.rsp <> csrv_rsp_tnam_k then goto abort; {wrong response from server ?}

  file_read_inetstr (                  {read variable length string from server}
    conn,                              {handle to server connection}
    rsp.tnam.len*sizeof(rsp.tnam.tnam[1]), {amount of data to read}
    [],                                {wait for data}
    rsp.tnam.tnam,                     {input buffer}
    olen,                              {amount of data actually read}
    stat);
  if sys_error(stat) then goto abort;
  file_close (conn);                   {close connection to the server}

  case rsp.tnam.tstat of               {what is status of translated name ?}
csrv_tnstat_cog_k: begin               {we have full result in Cognivision format}
      tstat := string_tnstat_cog_k;
      end;
csrv_tnstat_remote_k: begin            {additional remote translation is needed}
      string_vstring (tnam, rsp.tnam.tnam, rsp.tnam.len); {translated name into TNAM}
      goto remote_flagged;
      end;
csrv_tnstat_proc_k: begin              {translation is needed by owning process}
      if string_tnamopt_proc_k in opts then begin {we are the owning process ?}
        string_vstring (path, rsp.tnam.tnam, rsp.tnam.len); {copy result into PATH}
        goto local;                    {translate again locally}
        end;
      tstat := string_tnstat_proc_k;
      end;
otherwise
    return;                            {punt on unexpected value from server}
    end;

  string_vstring (tnam, rsp.tnam.tnam, rsp.tnam.len); {final treename into TNAM}
  return;                              {return with final result}
{
*   Jump here on hard error while server connection open.
}
abort:
  file_close (conn);                   {close connection to server}
  end;                                 {return with translation as far as it got}
{
**********************************************************
*
*   Subroutine STRING_TREENAME (INAM, TNAM)
*
*   Make full treename in TNAM from arbitrary pathname in INAM.  This routine will
*   return the name in local OS format whenever possible.  Symbolic links are
*   followed, and the pathname is assumed to be relative to this process.
*
*   NOTE: This is a simplified wrapper around STRING_TREENAME_OPTS.  This version
*   is backwards compatible with the old version of STRING_TREENAME that was
*   system-specific and did all the work itself.
}
procedure string_treename (            {make full treename from arbitrary path name}
  in      inam: univ string_var_arg_t; {input arbitrary path name}
  in out  tnam: univ string_var_arg_t); {output full tree name}

var
  tstat: string_tnstat_k_t;            {unused}

begin
  string_treename_opts (               {call general routine to do the work}
    inam,                              {input pathname}
    [ string_tnamopt_flink_k,          {follow symbolic links}
      string_tnamopt_remote_k,         {translate on remote machines as needed}
      string_tnamopt_proc_k,           {pathname is relative to this process}
      string_tnamopt_native_k],        {use native file naming whenever possible}
    tnam,                              {returned treename}
    tstat);                            {returned TNAM translation status}
  end;
{
**********************************************************
*
*   Procedure STRING_TREENAME_MACHINE (TNAM, MACHINE)
*
*   Extract the machine name from a treename in Cognivision format.  This format
*   is //<machine name>/<path on machine>.  Results are not defined if
*   TNAM is not in this format.
}
procedure string_treename_machine (    {get machine name from Cognivision treename}
  in      tnam: univ string_var_arg_t; {treename in Cognivis format, //<name>/<path>}
  out     machine: univ string_var_arg_t); {just the machine name from TNAM}

var
  i: sys_int_machine_t;                {string index}

begin
  machine.len := 0;                    {init extracted machine name to empty}
  i := 1;                              {init parse index}
  while (i <= tnam.len) and then (tnam.str[i] = '/') {skip leading "/" chars}
    do i := i + 1;
  while                                {loop until first "/" after tnam name}
      (i <= tnam.len) and then (tnam.str[i] <> '/')
      do begin
    if machine.len >= machine.max then return; {no room for additional chars ?}
    machine.len := machine.len + 1;    {append this char to end of NODE}
    machine.str[machine.len] := tnam.str[i];
    i := i + 1;                        {advance to next TNAM character}
    end;                               {back for next char from TNAM}
  end;
{
**********************************************************
*
*   Subroutine STRING_SET_NODENAME
*
*   Explicitly set the NODENAME string.  This is the lower case name of the machine
*   we are running on.
}
procedure string_set_nodename;         {set NODENAME and NODENAME_SET in com block}

begin
  nodename.max := sizeof(nodename.str);

  sys_node_name (nodename);
  string_downcase (nodename);
  nodename_set := true;
  end;
