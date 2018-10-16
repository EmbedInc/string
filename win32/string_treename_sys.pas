{   System-dependent routines for resolving tree names.
}
module string_treename_sys;
define string_treename_local;
%include 'string2.ins.pas';
%include 'file.ins.pas';
%include 'string_sys.ins.pas';
{
**********************************************************
*
*   Subroutine STRING_TREENAME_LOCAL (INAM, OPTS, TNAM, TSTAT)
*
*   Translate the input pathname INAM into a treename in TNAM.  This routine
*   only translates names for the local file system.  Links to remote machines
*   are never followed since this can be done in a system-independent
*   routine.  All flags in OPTS not specifically listed as obeyed are ignored.
*   This was done so that OPTS can be passed between successive routines without
*   needing editing.  The obeyed OPTS flags are:
*
*     STRING_TNAMOPT_FLINK_K - For pathnames that resolve to symbolic links, the
*       link will be followed.  The default is to return the name of the link
*       without following it.  Note that links are always followed if they are
*       not the last component of the pathname.
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
*   Note that TNAM may be returned with a different node name than expected
*   for one of the following reasons:
*
*     1 - The path resolves to a file system object on this machine, but
*         this machine is known by more than one name.  In that case, the
*         "preferred" name of this machine will be used.
*
*     2 - The path name resolved to a file system object on another machine,
*         but that file system object can be accesses transparently with native
*         OS calls on this machine.
}
var
  envvar_homedrive: string_var16_t :=  {HOMEDRIVE environment variable name}
    [str := 'HOMEDRIVE', len := 9, max := 16];
  envvar_homepath: string_var16_t :=   {HOMEPATH environment variable name}
    [str := 'HOMEPATH', len := 8, max := 16];

procedure string_treename_local (      {translate pathname on local machine only}
  in      inam: univ string_var_arg_t; {input path name}
  in      opts: string_tnamopt_t;      {set of option flags}
  in out  tnam: univ string_var_arg_t; {output tree name}
  out     tstat: string_tnstat_k_t);   {translation result status}
  val_param;

var
  i: sys_int_machine_t;                {scratch integer and loop counter}
  t: string_var8192_t;                 {current pathname within drive so far}
{
*******************************
*
*   Local subroutine IMPLICIT_CURRDIR
*
*   Set T to indicate the current working directory if there is
*   no accumulated pathname so far (implicitly at current directory).  Since the
*   current directory can only be determined by the owning process, we only
*   try to determine the current directory if the flag STRING_TNAMOPT_PROC_K is
*   set in OPTS.  If it's not, we set the pathname to empty and set TSTAT to
*   STRING_TNSTAT_PROC_K.
}
procedure implicit_currdir;

var
  winlen: win_dword_t;                 {number of chars in string from sys call}

begin
  if t.len > 0 then return;            {we already have explicit path ?}

  if string_tnamopt_proc_k in opts
    then begin                         {pathname is relative to this process ?}
      winlen := GetCurrentDirectoryA ( {get current directory treename}
        t.max,                         {max characters allowed to write}
        t.str);                        {returned path name}
      if winlen = 0 then begin         {system call error}
        sys_sys_error_bomb ('string', 'err_get_working_dir', nil, 0);
        end;
      t.len := winlen;                 {set number of used chars in T}
      if t.str[t.len] = '\' then t.len := t.len - 1; {truncate any trailing "\"}
      end
    else begin                         {pathname is owned by another process}
      tstat := string_tnstat_proc_k;   {need to translate curr dir in owner process}
      t.len := 0;                      {indicate implicit current directory}
      end
    ;
  end;
{
*******************************
*
*   Local subroutine DO_PATHNAME (INAME, OPTS)
*
*   Add the path name elements in INAME to the resulting treename being
*   accumulated in T.  T always ends in a component name, never the component
*   separator "\".
}
procedure do_pathname (                {translate and accumulate pathname}
  in      iname: univ string_var_arg_t; {pathname to translate and add to T}
  in      opts: string_tnamopt_t);     {option flags to use for this translation}
  val_param;

type
  comptype_k_t = (                     {pathname component type}
    comptype_netroot_k,                {name is at network root}
    comptype_noderoot_k,               {name is at node root}
    comptype_rel_k);                   {relative to current path}

var
  p: sys_int_machine_t;                {parse index into INAME}
  st: sys_int_machine_t;               {start index for current pathname component}
  iname_len: sys_int_machine_t;        {length of INAME with trailing blanks removed}
  t_len_save: string_index_t;          {saved copy of T.LEN}
  comptype: comptype_k_t;              {type of pathname component being parsed}
  no_comp: boolean;                    {no INAME component found yet}
  comp: string_var8192_t;              {current pathname component extracted from input string}
  path: string_treename_t;             {scratch pathname for recursive call}
  lnam: string_leafname_t;             {scratch leafname}

  i, j: sys_int_machine_t;             {scratch integers}
  pick: sys_int_machine_t;             {number of keyword picked from list}
  cmds: string_var8192_t;              {full embedded command string}
  cp: string_index_t;                  {CMDS parse index}
  tk: string_treename_t;               {token parsed from command}
  stat: sys_err_t;                     {completion status}

label
  next_comp, retry_comp, got_comp, have_comp, cmd_end, done_special, abort;

begin
  comp.max := size_char(comp.str);     {init local var strings}
  path.max := size_char(path.str);
  lnam.max := size_char(lnam.str);
  cmds.max := size_char(cmds.str);
  tk.max := size_char(tk.str);

  iname_len := iname.len;              {init unpadded INAME length}
  while (iname_len > 0) and (iname.str[iname_len] = ' ') {find unpadded INAME length}
    do iname_len := iname_len - 1;

  p := 1;                              {init INAME parse index}
  while (p < iname_len) and (iname.str[p] = ' ')
    do p := p + 1;                     {skip over leading blanks}

  no_comp := true;                     {init to no INAME component found yet}
{
*   Loop back here to extract each new pathname component from INAME.  P is the
*   index to the first character of the new component.
}
next_comp:                             {start looking for whole new component}
  comptype := comptype_rel_k;          {init to we are parsing relative name}

retry_comp:                            {try again to find a component}
  st := p;                             {save index to first char of component}

  if p > iname_len then begin          {exhausted INAME ?}
    if no_comp or (t.len = 0) then begin {only have implicit pathname ?}
      case comptype of                 {where are we in naming hierarchy}
  comptype_netroot_k,                  {set return name to machine root}
  comptype_noderoot_k: begin
          sys_sys_rootdir (t);         {get root directory of this machine}
          t.len := t.len - 1;          {truncate trailing "\"}
          end;
  comptype_rel_k: begin                {get current working directory}
          implicit_currdir;            {set T to current working directory name}
          if tstat <> string_tnstat_native_k {need to return with special condition ?}
            then goto abort;
          end;
        end;
      end;                             {done handling implicit pathname}
    return;
    end;                               {done handling end of INAME}

  comp.len := 0;                       {init this pathname component to empty}
  while p <= iname_len do begin        {scan remaining chars in INAME}

    case iname.str[p] of               {check for special handling char}
'/', '\': begin                        {separator between components}
        p := p + 1;                    {make index of first char in next component}
        if comp.len > 0 then goto got_comp; {we have a complete pathname component}
        if no_comp then begin          {we are before first component ?}
          case comptype of             {promote the component type by one}
comptype_noderoot_k: begin
              comptype := comptype_netroot_k;
              end;
comptype_rel_k: begin
              comptype := comptype_noderoot_k;
              end;
            end;
          end;                         {end of separator before first component}
        goto retry_comp;               {try again with new component type}
        end;
      end;                             {end of special character cases}

    if comp.len < comp.max then begin  {this is just another component character}
      comp.len := comp.len + 1;
      comp.str[comp.len] := iname.str[p];
      end;
    p := p + 1;                        {advance to next character in this component}
    end;                               {back and process this new character}
{
*   The next pathname component has been extracted into COMP.
}
got_comp:
  no_comp := false;                    {at least one component has been found now}

have_comp:                             {pathname component to add is in COMP}
  if comp.len = 0 then goto next_comp;
  {
  *   Check for ":", which indicates string preceeding it is a drive name.
  }
  for i := 1 to comp.len do begin      {scan characters in this component}
    if comp.str[i] = ':' then begin    {drive letter terminator is at I ?}
      string_substr (comp, 1, i, t);   {replace accumulated path with drive name}
      string_upcase (t);               {drive names are always upper case}
      i := i + 1;                      {go to first char after drive name}
      while (i <= comp.len) and ((comp.str[i] = '/') or (comp.str[i] = '\'))
        do i := i + 1;                 {delete leading component delimiters}
      for j := i to comp.len do begin  {shift remaining component string to start}
        comp.str[j-i+1] := comp.str[j];
        end;
      comp.len := comp.len - i + 1;
      goto have_comp;                  {back to process "new" pathname component}
      end;                             {done handling drive name}
    end;

  case comp.str[1] of                  {check for special case component syntaxes}

'.': begin                             {could be current or parent directory}
      if comp.len = 1 then goto retry_comp; {current directory ?}
      if                               {parent directory ?}
          (comp.len = 2) and then
          (comp.str[2] = '.')
          then begin
        case comptype of               {ignore for component types can't go up from}
comptype_netroot_k,
comptype_noderoot_k: begin
            goto retry_comp;
            end;
          end;                         {end of component type cases}
        implicit_currdir;              {resolve implicit current directory if needed}
        if tstat <> string_tnstat_native_k {need to return with special condition ?}
          then goto abort;
        if t.str[t.len] = ':' then begin {going to machine root from drive root ?}
          t.len := 0;                  {next component starts at machine root}
          comptype := comptype_noderoot_k;
          goto retry_comp;             {get next component with new COMPTYPE setting}
          end;
        while t.str[t.len] <> '\'      {look for last "\" in accumulated tree name}
          do t.len := t.len - 1;
        t.len := t.len - 1;            {delete trailing "\"}
        goto next_comp;                {back for next pathname component}
        end;                           {done handling component is parent directory}
      end;

'~': begin                             {could be user's home directory}
      if comp.len <> 1 then goto done_special; {not just "~" symbol ?}
      if not (string_tnamopt_proc_k in opts) then begin {we don't own pathname ?}
        t.len := 0;                    {path name so far is irrelevant}
        tstat := string_tnstat_proc_k; {need to be translated by owning process}
        goto abort;                    {return with special condition}
        end;
      sys_envvar_get (envvar_homedrive, t, stat); {get HOMEDRIVE value, like "C:"}
      if sys_error(stat) then begin
        sys_sys_rootdir (t);           {default to machine root directory}
        end;
      if t.str[t.len] = '\' then t.len := t.len - 1; {truncate any trailing "\"}
      sys_envvar_get (envvar_homepath, path, stat);
      if not sys_error(stat) then begin {successfully got home directory path name ?}
        do_pathname (                  {resolve home directory pathname}
          path,                        {path to resolve after home drive name}
          [ string_tnamopt_flink_k,    {follow all links}
            string_tnamopt_proc_k]     {PATH is relative to this process}
          );
        if tstat <> string_tnstat_native_k then goto abort; {special condition ?}
        end;
      goto next_comp;
      end;

'(': begin                             {embedded command}
      cmds.len := 0;                   {init command string to empty}
      for i := 2 to comp.len do begin  {scan remaining characters this component}
        if comp.str[i] = ')'           {found end of command string character ?}
          then goto cmd_end;
        if cmds.len < cmds.max then begin {room for one more character ?}
          cmds.len := cmds.len + 1;    {append this char to end of command name}
          cmds.str[cmds.len] := comp.str[i];
          end;
        end;                           {back for next cmds char in INAME}
      goto done_special;               {")" missing, not a command ?}
cmd_end:                               {I is COMP char of command end ")"}
      lnam.len := comp.len - i;        {leafname length after command}
      for j := 1 to comp.len do begin  {copy component remainder into COMP}
        lnam.str[j] := comp.str[i + j];
        end;
      {
      *   The command string inside the parenthesis is in CMDS, and the remaining
      *   pathname component after the command is in LNAM.
      }
      cp := 1;                         {init command parse index}
      string_token (cmds, cp, tk, stat); {get command name from command string}
      if sys_error(stat) then goto done_special;
      string_upcase (tk);              {make upper case for keyword matching}
      string_tkpick80 (tk,             {pick command name from list}
        'COG EVAR VAR',
        pick);                         {number of keyword picked from list}
      case pick of
1:      begin                          {(COG)pathname}
          if cp <= tk.len then goto done_special; {unexpected command parameter ?}
          string_terminate_null (lnam); {make sure LNAM.STR is null terminated}
          sys_cognivis_dir (lnam.str, path); {get Cognivis dir path}
          do_pathname (path, opts);    {add on expanded Cognivis directory path}
          if tstat <> string_tnstat_native_k then goto abort; {special condition ?}
          end;
2:      begin                          {(EVAR)envvar}
          if cp <= tk.len then goto done_special; {unexpected command parameter ?}
          if lnam.len <= 0 then goto next_comp; {ignore if no environment var name given}
          if not (string_tnamopt_proc_k in opts) then begin {we don't own pathname ?}
            tstat := string_tnstat_proc_k; {need to be translated by owning process}
            goto abort;                    {return with special condition}
            end;
          sys_envvar_get (lnam, comp, stat); {get environment variable value}
          if sys_error(stat) then comp.len := 0; {envvar not found same as empty string}
          goto have_comp;              {pathname component to process is in COMP}
          end;
3:      begin                          {(VAR envvar)pathname}
          string_token (cmds, cp, tk, stat); {get environment variable name}
          if sys_error(stat) then goto done_special;
          if cp <= tk.len then goto done_special; {unexpected additional parameter ?}
          if tk.len <= 0 then begin    {no envvar same as empty envvar}
            string_copy (lnam, comp);  {resolved component is path after command}
            goto have_comp;
            end;
          if not (string_tnamopt_proc_k in opts) then begin {we don't own pathname ?}
            tstat := string_tnstat_proc_k; {need to be translated by owning process}
            goto abort;                {return with special condition}
            end;
          sys_envvar_get (tk, comp, stat); {resolved component start with envvar value}
          if sys_error(stat) then comp.len := 0; {not exist same as empty string}
          string_append (comp, lnam);  {add pathname component after envvar expansion}
          goto have_comp;              {resolved pathname component is in COMP}
          end;

otherwise                              {unrecognized command}
        goto done_special;             {don't treat as special component}
        end;                           {end of command cases}
      goto next_comp;                  {back to do next input pathname component}
      end;                             {end of imbedded command case}
    end;                               {done handling special case component names}

done_special:                          {definately done with special handling}
{
*   All special syntax in this pathname component, if any, have been resolved and
*   the result is in COMP.
*
*   Now add this input pathname component to the end of the accumulated treename.
}
  case comptype of                     {where does component fit into hierarchy ?}

comptype_netroot_k: begin              {component is at network root (machine name)}
      string_downcase (comp);          {we always list machine names in lower case}
      if not nodename_set then string_set_nodename; {make sure NODENAME is all set}
      if string_equal (comp, nodename) then begin {this is our machine name ?}
        sys_sys_rootdir (t);           {go to machine root directory}
        t.len := t.len - 1;            {truncate trailing "\"}
        goto next_comp;
        end;                           {end of node name was this machine}
      t.len := 1;                      {set T to just "/"}
      t.str[1] := '/';                 {additional path will be set by ABORT code}
      tstat := string_tnstat_remote_k; {further translation must be on remmote node}
      goto abort;                      {return with special condition}
      end;                             {end of component is machine name case}

comptype_noderoot_k: begin             {component is at machine root}
      sys_sys_rootdir (t);             {go to machine root directory}
      t.len := t.len - 1;              {truncate trailing "\"}
      end;

comptype_rel_k: begin                  {component is relative to existing path}
      implicit_currdir;                {make sure we have explicit existing path}
      if tstat <> string_tnstat_native_k {need to return with special condition ?}
        then goto abort;
      end;
    end;                               {end of special handling component type cases}

  t_len_save := t.len;                 {save length of T before adding on component}
  if t.len >= t.max then return;       {punt if overflowed T}
  t.len := t.len + 1;                  {append "\" separator to T}
  t.str[t.len] := '\';
  string_append (t, comp);             {append this pathname component}
{
*   The new pathname component has been added to T.  T_LEN_SAVE is
*   the length value for T before the pathname was added.  Now check for the
*   new treename being a symbolic link if links are supposed to be followed
*   at this point.
}
  if                                   {follow if it's a link ?}
      (string_tnamopt_flink_k in opts) or {link following is enabled ?}
      (p <= iname_len)                 {this is not the last pathname component ?}
      then begin
    file_link_resolve (t, path, stat); {try to read file as a symbolic link}
    if not sys_error(stat) then begin  {actually got symbolic link value ?}
      t.len := t_len_save;             {restore T to before link name added}
      do_pathname (                    {append link expansion to existing path}
        path,                          {pathname to translate}
        opts + [string_tnamopt_flink_k]); {follow any subordinate links}
      if tstat <> string_tnstat_native_k {special condition occurred ?}
        then goto abort;               {fix up pathname and leave}
      end;
    end;                               {done handling symbolic link}

  goto next_comp;                      {back for next input name component}
{
*   A condition has arisen that prevents us from further processing the input
*   pathname.  TSTAT is already set to indicate what the condition is.  We now
*   append the unused part of INAME, starting with the current component, to
*   the path accumulated so far in T.
}
abort:
  if t.len >= t.max then return;       {punt if overflowed T}
  i := iname_len - st + 1;             {number of chars in remaining path}
  if (t.len > 0) and (st <= iname_len) then begin {need separator ?}
    t.len := t.len + 1;                {append "/" separator to T}
    t.str[t.len] := '/';
    end;
  while i > 0 do begin                 {loop until remaining path exhausted}
    if t.len >= t.max then return;     {punt if overflowed T}
    t.len := t.len + 1;                {apppend this component name character to T}
    if iname.str[st] = '\'             {translate any "\" to "/"}
      then t.str[t.len] := '/'
      else t.str[t.len] := iname.str[st];
    st := st + 1;                      {advance source char index}
    i := i - 1;                        {one less character to copy}
    end;                               {back for next char in remaining path}
  end;
{
*******************************
*
*   Start of main routine.
}
begin
  t.max := size_char(t.str);           {init local var string}

  t.len := 0;                          {init to no accumulated path on drive}
  tstat := string_tnstat_native_k;     {init to returning full native pathname}
  do_pathname (inam, opts);            {process info from input pathname}

  if tstat = string_tnstat_native_k then begin {we have a native pathname ?}
    if string_tnamopt_native_k in opts
      then begin                       {native pathname was requested ?}
        if t.str[t.len] = ':' then begin {pathname is raw drive name}
          string_append1 (t, '\');     {indicate root directory on drive}
          end;
        end
      else begin                       {translate to Cognivision naming rules}
        tnam.len := 0;                 {init returned treename to empty}
        string_appendn (tnam, '//', 2); {path starts at network root}
        if not nodename_set then string_set_nodename; {make sure NODENAME is all set}
        string_append (tnam, nodename); {add machine name}
        string_append1 (tnam, '/');    {add separator after machine name}
        for i := 1 to t.len do begin   {once for each character in remaining path}
          if t.str[i] = '\'
            then string_append1 (tnam, '/') {translate "\" to "/"}
            else string_append1 (tnam, t.str[i]);
          end;                         {back for next character from T}
        tstat := string_tnstat_cog_k;  {indicate Cognivision naming rules used}
        return;
        end                            {done handling Cognivision naming requested}
      ;
    end;                               {done handling T was raw native pathname}

  string_copy (t, tnam);               {pass back final translated string}
  end;
