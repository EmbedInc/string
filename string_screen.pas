{   Module of routines that convert between system screen handles
*   and strings.
*
*   The string format of a complete system screen identifier is:
*
*   <machine name>:<server ID>.<screen ID>
*
*   Empty or fields indicate to use default values.
*   The string may be truncated before or after any punctuation, where all
*   fields to the right are empty, indicating default.  Thus "" is the
*   same as ":.".  The special machine name "-PROC" identifies the machine
*   running this process.  The default machine is the one on which standard
*   output is ultimately routed for display.  The server and screen IDs
*   default to the server and screen where standard output is ultimately
*   displayed.  If standard output is not displayed on any of the
*   available choices, then the default is for the "first" server or
*   screen.
*
*   No blanks are allowed between fields or around the punctuation characters,
*   although the entire string may have trailing blanks.
*   If a field contains blanks or any of the punctuation characters, then
*   it must be enclosed in quotes ("") or apostrophies ('').  The ":"
*   after the machine name may be repeated once.  Thus "joe:1" is the
*   same as "joe::1".
*
*   This syntax is compatable with how the X-window system identifies a
*   screen on Posix systems.
}
module string_screen;
define string_f_screen;
define string_t_screen;
%include '/cognivision_links/dsee_libs/string/string2.ins.pas';

var
  machine_proc: string_var16_t :=      {spec name for machine running this process}
    [str := '-PROC', len := 5, max := sizeof(machine_proc.str)];
{
********************************************
*
*   Subroutine STRING_F_SCREEN (S, SCREEN)
*
*   Convert the screen handle SCREEN to is string representation in S.
}
procedure string_f_screen (            {convert system screen handle to a string}
  in out  s: univ string_var_arg_t;    {output string}
  in      screen: sys_screen_t);       {input handle to the screen}
  val_param;

var
  token: string_var32_t;               {scratch token for number conversion}

label
  done_machine_name, done_server_name, done_screen_name;

begin
  token.max := sizeof(token.str);      {init local var string}
  s.len := 0;                          {init output string to empty}
{
*   Write machine name.
}
  if sys_scrflag_stdout_k in screen.flags {default machine name ?}
    then goto done_machine_name;
  if sys_scrflag_proc_k in screen.flags then begin {machine running this process ?}
    goto done_machine_name;
    end;
  string_copy (screen.machine, s);     {copy explicitly specified machine name}
done_machine_name:                     {done filling in machine name}
  string_append1 (s, ':');             {add separator after machine name}
{
*   Write server ID.
}
  if                                   {write blank server name ?}
      (sys_scrflag_servdef_k in screen.flags) or
      (sys_scrflag_stdout_k in screen.flags)
    then goto done_server_name;
  string_f_int (token, screen.server); {make server ID number string}
  string_append (s, token);            {add server ID number to output string}
done_server_name:                      {done filling in server name}
  string_append1 (s, '.');             {add separator after server ID}
{
*   Write screen ID.
}
  if                                   {write blank screen name ?}
      (sys_scrflag_scrdef_k in screen.flags) or
      (sys_scrflag_stdout_k in screen.flags)
    then goto done_screen_name;
  string_f_int (token, screen.screen); {make screen ID number string}
  string_append (s, token);            {add screen ID number to output string}
done_screen_name:
  end;
{
********************************************
*
*   Subroutine STRING_T_SCREEN (S, SCREEN, STAT)
*
*   Convert the string representation of a screen identifier in S to a screen
*   handle in SCREEN.
}
procedure string_t_screen (            {convert string to system screen ID}
  in      s: univ string_var_arg_t;    {input string}
  out     screen: sys_screen_t;        {returned handle to the screen}
  out     stat: sys_err_t);            {completion status code}

type
  pstate_k_t = (                       {current parsing state}
    pstate_quote_k,                    {within quoted string}
    pstate_mach_k,                     {within machine name token}
    pstate_colon_k,                    {in colon(s) after machine name}
    pstate_serv_k,                     {within server name token}
    pstate_scr_k,                      {within screen ID token}
    pstate_aft_k);                     {after screen ID token}

var
  p: string_index_t;                   {parse index and string index for loop}
  pstate: pstate_k_t;                  {current input string parsing state}
  pstate_old: pstate_k_t;              {old parse state when inside quote}
  c: char;                             {current character being parsed}
  qchar: char;                         {character to end current quote}
  token: string_leafname_t;            {scratch token extracted from input string}

label
  reparse;
{
********************
*
*   Local function QUOTE
*
*   Check for start of a quoted string.  If found, return TRUE, save the
*   old parse state, and set the current parse state for inside quoted string.
*   No state is changed if not currently within quoted string.
}
function quote: boolean;               {TRUE if just entered quoted string}

begin
  if (c <> '''') and (c <> '"') then begin {this char is not start of quoted str ?}
    quote := false;
    return;
    end;
  pstate_old := pstate;                {save old parse state}
  pstate := pstate_quote_k;            {parse state is now within quoted string}
  qchar := c;                          {save character that will end quoted string}
  quote := true;
  end;
{
********************
*
*   Start of main routine.
}
begin
  token.max := sizeof(token.str);      {init local var string}

  sys_error_none(stat);                {init to no errors}
  screen.machine.max := sizeof(screen.machine.str); {init to all default values}
  screen.machine.len := 0;
  screen.server := 0;
  screen.screen := 0;
  screen.flags :=
    [sys_scrflag_servdef_k, sys_scrflag_scrdef_k];

  token.len := 0;                      {init to no token accumulated yet}
  pstate := pstate_mach_k;             {init to parsing machine name token}
  for p := 1 to s.len do begin         {loop thru all the characters in S}
    c := s.str[p];                     {extract character being parsed}
reparse:                               {back here to re-process same input char}
    case pstate of

pstate_quote_k: begin                  {we are within a quoted string}
        if c = qchar then begin        {this character ends the quoted string ?}
          pstate := pstate_old;        {restore old parsing state}
          next;
          end;
        string_append1 (token, c);     {add this character to end of current token}
        end;

pstate_mach_k: begin                   {we are parsing machine name token}
        if quote then next;            {check for start of quoted string}
        case c of
':':      pstate := pstate_colon_k;    {now parsing colors after machine name}
' ':      pstate := pstate_aft_k;      {now after whole string}
otherwise
          string_append1 (token, c);   {append this char to accumulated token}
          if p < s.len then next;      {not end of token, all done with this char ?}
          end;
        if token.len <= 0 then next;   {use default for machine name ?}
        string_copy (token, screen.machine); {set machine name}
        string_upcase (token);         {make upper case for keyword matching}
        if string_equal(token, machine_proc) then begin {special machine name ?}
          string_upcase (screen.machine); {keyword always stored upper case}
          screen.flags := screen.flags +
            [sys_scrflag_proc_k];
          end;
        token.len := 0;                {all done with this token}
        end;

pstate_colon_k: begin                  {we are parsing colon(s) after machine name}
        if c <> ':' then begin         {first character past colons ?}
          pstate := pstate_serv_k;
          goto reparse;                {back and re-process the same input char}
          end;
        end;

pstate_serv_k: begin                   {we are parsing server ID token}
        if quote then next;            {check for start of quoted string}
        case c of
'.':      pstate := pstate_scr_k;      {now parsing screen ID string}
' ':      pstate := pstate_aft_k;      {now after whole string}
otherwise
          string_append1 (token, c);   {append this char to accumulated token}
          if p < s.len then next;      {not end of token, all done with this char ?}
          end;
        if token.len <= 0 then next;   {use default server ID ?}
        string_t_int (token, screen.server, stat); {interpret server ID number}
        if sys_error(stat) then return;
        screen.flags := screen.flags - {remove default server flag}
          [sys_scrflag_servdef_k];
        token.len := 0;                {all done with this token}
        end;

pstate_scr_k: begin                    {we are parsing screen ID token}
        if quote then next;            {check for start of quoted string}
        case c of
' ':      pstate := pstate_aft_k;      {now after whole string}
otherwise
          string_append1 (token, c);   {append this char to accumulated token}
          if p < s.len then next;      {not end of token, all done with this char ?}
          end;
        if token.len <= 0 then next;   {use default screen ID ?}
        string_t_int (token, screen.screen, stat); {interpret screen ID number}
        if sys_error(stat) then return;
        screen.flags := screen.flags - {remove default screen flag}
          [sys_scrflag_scrdef_k];
        token.len := 0;                {all done with this token}
        end;

pstate_aft_k: begin                    {we are parsing trailing blanks to whole str}
        if c <> ' ' then begin         {found something other than trailing blank ?}
          sys_stat_set (string_subsys_k, string_stat_extra_tk_k, stat);
          string_substr (s, p, s.len, token); {extract extraneous characters}
          string_unpad (token);        {no need to complain about trailing blanks}
          sys_stat_parm_vstr (token, stat);
          sys_stat_parm_vstr (s, stat);
          return;                      {return with error}
          end;
        end;
      end;                             {end of parsing state cases}
    end;                               {back and process next input string character}
{
*   All done parsing the input string.  Check for abnormal end of string.
}
  if pstate = pstate_quote_k then begin {ended in middle of a quote ?}
    sys_stat_set (string_subsys_k, string_stat_no_endquote_k, stat);
    return;
    end;
{
*   Check for whether the STDOUT flag can be set.
}
  if
      (screen.machine.len = 0) and     {machine name defaulted ?}
      (sys_scrflag_servdef_k in screen.flags) and {server ID defaulted ?}
      (sys_scrflag_scrdef_k in screen.flags) {screen ID defaulted ?}
      then begin
    screen.flags := [sys_scrflag_stdout_k];
    end;
  end;
