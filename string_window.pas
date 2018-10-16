{   Module of routines that convert between system window handles and
*   strings.
*
*   The format of a system window ID string is the same as a system screen
*   ID string followed by one more tokens to identify the window on the screen.
*   The screen ID string must not be empty, and at least one blank must
*   follow it before the window ID string.  The reserved window ID token
*   names are:
*
*     -STDOUT  -  Indicates the window displaying standard output.  This
*       is identified by the WINDOWID environment variable, when present.
*
*     -ROOT  -  Indicates the root window on the screen.
*
*   Additional options may follow the window ID token.  They are:
*
*     -DIR  -  Forces use of this window directly.  The application is not
*       allowed create a subordinate window, and then draw into that.
*
*     -INDIR  -  The indicated window must not be used directly.  The
*       application must always create a subordinate window to draw into.
*       This flag is mutually exclusive with -DIR.  When neither flag
*       is specified, the application may use the window directly or indirectly,
*       as it deems appropriate.
*
*     -NOWM  -  Indicates that an attempt should be made to prevent the
*       window manager from interfering with any newly created windows.
*       Most window managers only interfere with windows that are directly
*       subordinate to the root window.
*
*     -POS x y  -  Implies -INDIR, and specifies the position of the top
*       left corner of the new window with respect to the top left corner
*       of the parent window.
*
*     -SIZE dx dy  -  Implies -INDIR, and specifies the size of the new window.
*
*   A blank or omitted window name indicates default, which is -STDOUT.
*
*   The format of a screen ID string is described in the header comments
*   of file STRING_SCREEN.PAS.
}
module string_window;
define string_f_window;
define string_t_window;
%include '/cognivision_links/dsee_libs/string/string2.ins.pas';

var
  window_stdout: string_var16_t :=
    [str := '-STDOUT', len := 7, max := sizeof(window_stdout.str)];
  window_root: string_var16_t :=
    [str := '-ROOT', len := 5, max := sizeof(window_root.str)];
  flag_dir: string_var16_t :=
    [str := '-DIR', len := 4, max := sizeof(flag_dir.str)];
  flag_indir: string_var16_t :=
    [str := '-INDIR', len := 6, max := sizeof(flag_indir.str)];
  flag_nowm: string_var16_t :=
    [str := '-NOWM', len := 5, max := sizeof(flag_nowm.str)];
  flag_pos: string_var16_t :=
    [str := '-POS', len := 4, max := sizeof(flag_pos.str)];
  flag_size: string_var16_t :=
    [str := '-SIZE', len := 5, max := sizeof(flag_size.str)];
  flag_name: string_var16_t :=
    [str := '-NAME', len := 5, max := sizeof(flag_name.str)];
  flag_icname: string_var16_t :=
    [str := '-ICNMAE', len := 7, max := sizeof(flag_icname.str)];
{
********************************************
*
*   Subroutine STRING_F_WINDOW (S, WINDOW)
*
*   Convert the window handle WINDOW to its string representation in S.
}
procedure string_f_window (            {convert system window handle to a string}
  in out  s: univ string_var_arg_t;    {output string}
  in      window: sys_window_t);       {input handle to the window}
  val_param;

var
  token: string_var32_t;               {scratch token for number conversion}

begin
  token.max := sizeof(token.str);      {init local var string}

  string_f_screen (s, window.screen);  {init string with screen ID}
  string_append1 (s, ' ');             {add separator before window ID token}

  if sys_winflag_stdout_k in window.flags
    then begin                         {window ID is -STDOUT}
      string_append (s, window_stdout);
      end
    else begin                         {window ID is actual window number}
      if window.window = -1
        then begin                     {root window}
          string_append (s, window_root);
          end
        else begin                     {explicit window number}
          string_f_int (token, window.window); {make window ID string}
          string_append (s, token);
          end
        ;
      end
    ;
  string_append1 (s, ' ');

  if sys_winflag_dir_k in window.flags then begin
    string_append (s, flag_dir);
    string_append1 (s, ' ');
    end;

  if sys_winflag_indir_k in window.flags then begin
    string_append (s, flag_indir);
    string_append1 (s, ' ');
    end;

  if sys_winflag_nowm_k in window.flags then begin
    string_append (s, flag_nowm);
    string_append1 (s, ' ');
    end;

  if sys_winflag_pos_k in window.flags then begin
    string_append (s, flag_pos);
    string_append1 (s, ' ');
    string_f_int (token, window.pos_x);
    string_append (s, token);
    string_append1 (s, ' ');
    string_f_int (token, window.pos_y);
    string_append (s, token);
    string_append1 (s, ' ');
    end;

  if sys_winflag_size_k in window.flags then begin
    string_append (s, flag_size);
    string_append1 (s, ' ');
    string_f_int (token, window.size_x);
    string_append (s, token);
    string_append1 (s, ' ');
    string_f_int (token, window.size_y);
    string_append (s, token);
    string_append1 (s, ' ');
    end;

  if sys_winflag_name_k in window.flags then begin
    string_append (s, flag_name);
    string_appendn (s, ' "', 2);
    string_append (s, window.name_wind);
    string_appendn (s, '" ', 2);
    end;

  if sys_winflag_icname_k in window.flags then begin
    string_append (s, flag_icname);
    string_appendn (s, ' "', 2);
    string_append (s, window.name_icon);
    string_appendn (s, '" ', 2);
    end;
  end;
{
********************************************
*
*   Subroutine STRING_T_WINDOW (S, WINDOW, STAT)
*
*   Convert the string representation of a system window handle in S to
*   the system window handle WINDOW.
}
procedure string_t_window (            {convert string to system window handle}
  in      s: univ string_var_arg_t;    {input string}
  out     window: sys_window_t;        {returned handle to the window}
  out     stat: sys_err_t);            {completion status code}

type
  pstate_k_t = (                       {current parse state}
    pstate_bef_k,                      {before screen ID token}
    pstate_tok_k,                      {in screen ID token}
    pstate_quote_k);                   {within quoted string}

var
  pick: sys_int_machine_t;             {number of token picked from list}
  p: string_index_t;                   {parse index into S}
  pstate: pstate_k_t;                  {current parse state}
  qchar: char;                         {character to end quoted string}
  c: char;                             {current character being parsed}
  token: string_leafname_t;            {scratch token extracted from S}

label
  parse_again, got_screen_token, loop;

begin
  token.max := sizeof(token.str);      {init local var string}
  sys_error_none (stat);               {init to no errors}
{
*   Extract the screen ID string into TOKEN.  P will be left as a valid parse
*   index following the screen ID string.
}
  token.len := 0;                      {init screen ID string}
  p := 1;                              {init input string parse index}
  if s.len <= 0 then goto got_screen_token; {input string is empty ?}
  pstate := pstate_bef_k;              {init to curr parse state is start of string}
  for p := 1 to s.len do begin         {scan to end of screen ID token}
    c := s.str[p];                     {extract character being parsed}
parse_again:                           {back here to re-parse with same input char}
    case pstate of
pstate_bef_k: begin                    {we are before start of screen ID token}
        if c = ' ' then next;          {ignore this trailing blank char}
        pstate := pstate_tok_k;        {we are now within token}
        goto parse_again;              {re-process same char with new state}
        end;
pstate_tok_k: begin                    {we are parsing the token outside of a quote}
        if c = ' ' then begin          {hit blank after screen ID token ?}
          goto got_screen_token;
          end;
        if (c = '''') or (c = '"') then begin {quote character ?}
          pstate := pstate_quote_k;    {we are now within quoted string}
          qchar := c;                  {save character to exit quote string state}
          end;
        end;
pstate_quote_k: begin                  {we are inside a quoted string}
        if c = qchar then begin        {hit end of quoted string ?}
          pstate := pstate_tok_k;      {back to regular token state}
          end;
        end;
      end;                             {end of parse state cases}
    if token.len < token.max then begin {room left in TOKEN ?}
      token.len := token.len + 1;      {one more character for TOKEN}
      token.str[token.len] := c;       {stuff character into screen ID token}
      end;
    end;                               {back and check previous input string char}
got_screen_token:                      {screen ID string is in TOKEN}
  string_t_screen (token, window.screen, stat); {interpret screen ID string}
  if sys_error(stat) then return;
{
*   Init remainder of window descriptor, then process the window ID tokens.
*   These tokens start at index P in string S.
}
  window.window := 0;
  window.pos_x := 0;
  window.pos_y := 0;
  window.size_x := 0;
  window.size_y := 0;
  window.name_wind.max := sizeof(window.name_wind.str);
  window.name_wind.len := 0;
  window.name_icon.max := sizeof(window.name_icon.str);
  window.name_icon.len := 0;
  window.flags := [sys_winflag_stdout_k, sys_winflag_indir_k];

loop:                                  {back here each new window ID token}
  string_token (s, p, token, stat);    {get next token from input string}
  if string_eos(stat) then return;     {hit end of input string ?}
  string_upcase (token);               {make upper case for token matching}
  string_tkpick80 (token,
    '-STDOUT -ROOT -DIR -INDIR -NOWM -POS -SIZE -NAME -ICNAME',
    pick);
  case pick of
{
*   -STDOUT
}
1: begin
  window.flags := window.flags + [sys_winflag_stdout_k];
  window.flags := window.flags + [sys_winflag_indir_k];
  window.flags := window.flags - [sys_winflag_dir_k];
  end;
{
*   -ROOT
}
2: begin
  window.flags := window.flags - [sys_winflag_stdout_k];
  window.window := -1;
  window.flags := window.flags + [sys_winflag_indir_k];
  window.flags := window.flags - [sys_winflag_dir_k];
  end;
{
*   -DIR
}
3: begin
  window.flags := window.flags + [sys_winflag_dir_k];
  window.flags := window.flags - [sys_winflag_indir_k];
  end;
{
*   -INDIR
}
4: begin
  window.flags := window.flags + [sys_winflag_indir_k];
  window.flags := window.flags - [sys_winflag_dir_k];
  end;
{
*   -NOWM
}
5: begin
  window.flags := window.flags + [sys_winflag_nowm_k];
  end;
{
*   -POS x y
}
6: begin
  window.flags := window.flags + [sys_winflag_indir_k];
  window.flags := window.flags - [sys_winflag_dir_k];
  window.flags := window.flags + [sys_winflag_pos_k];
  string_token_int (s, p, window.pos_x, stat);
  if sys_error(stat) then return;
  string_token_int (s, p, window.pos_y, stat);
  if sys_error(stat) then return;
  end;
{
*   -SIZE x y
}
7: begin
  window.flags := window.flags + [sys_winflag_indir_k];
  window.flags := window.flags - [sys_winflag_dir_k];
  window.flags := window.flags + [sys_winflag_size_k];
  string_token_int (s, p, window.size_x, stat);
  if sys_error(stat) then return;
  string_token_int (s, p, window.size_y, stat);
  if sys_error(stat) then return;
  end;
{
*   -NAME window_name
}
8: begin
  string_token (s, p, window.name_wind, stat);
  window.flags := window.flags + [sys_winflag_name_k];
  end;
{
*   -ICNAME icon_name
}
9: begin
  string_token (s, p, window.name_icon, stat);
  window.flags := window.flags + [sys_winflag_icname_k];
  end;
{
*   The token is not one of the special keywords.  It must therefore be
*   a hard window ID number.
}
otherwise
    string_t_int (token, window.window, stat);
    if sys_error(stat) then return;
    window.flags := window.flags - [sys_winflag_stdout_k];
    window.flags := window.flags - [sys_winflag_dir_k];
    window.flags := window.flags - [sys_winflag_indir_k];
    end;
  goto loop;                           {back and process next input string token}
  end;
