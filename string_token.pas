{   Module of routines that deal with tokens within a string.  A token is
*   an individually parseable unit of a string.
}
module string_token;
define string_token_anyd;
define string_token;
define string_token_comma;
define string_token_commasp;
define string_token_make;
define string_token_bool;
%include '/cognivision_links/dsee_libs/string/string2.ins.pas';
{
*********************************************************************
*
*   STRING_TOKEN_ANYD (S, P, DELIM, N_DELIM, N_DELIM_REPT, FLAGS,
*     TOKEN, DELIM_PICK, STAT)
*
*   Extract the next token from string S, and put the result into string TOKEN.
*   P is the parse index into string S.  The first token at or after P is
*   returned.  P is updated so that the next call to any of the STRING_TOKEN
*   routines will read the next token.
*
*   Tokens are separated in S by delimiter characters.  The list of legal
*   delimiter characters is given in DELIM.  N_DELIM indicates the total
*   number of delimiters in DELIM.  The first N_DELIM_REPT delimiters in
*   DELIM may be repeated, the remaining ones may only appear once between
*   tokens.  DELIM_PICK is returned indicating which delimiter identified the
*   end of the token.  DELIM_PICK always refers to the non-repeated delimiter,
*   if both repeated and non-repeated delimiters were present.  DELIM_PICK
*   is returned zero when the end of S ended the token.
*
*   FLAGS may be any combination of the following flags:
*
*     STRING_TKOPT_QUOTEQ_K  -  The token may be a string enclosed in
*       quotes ("...").  TOKEN will be set to the characters between the
*       quotes.  Two consecutive quotes within the string will be translated
*       as one quote.  No additional characters are allowed after the last
*       quote.  In other words, the last quote must be the last character
*       in the input string, or immediately followed by a delimiter.
*
*     STRING_TKOPT_QUOTEA_K  -  Just like STRING_TKOPT_QUOTEQ_K, except
*       that the quote characters are apostrophies ('...').
*
*     STRING_TKOPT_PADSP_K  -  Blanks are padding.  Leading and trailing
*       blanks around the token are stripped.  This flag is only useful
*       when the blank characters is not listed in DELIM as one of the
*       token delimiters.
}
procedure string_token_anyd (          {like STRING_TOKEN, user supplies delimiters}
  in      s: univ string_var_arg_t;    {input string}
  in out  p: string_index_t;           {parse index, init to 1 for start of string}
  in      delim: univ string;          {list of delimiters between tokens}
  in      n_delim: sys_int_machine_t;  {number of delimiters in DELIM}
  in      n_delim_rept: sys_int_machine_t; {first N delimiters that may be repeated}
  in      flags: string_tkopt_t;       {set of option flags}
  out     token: univ string_var_arg_t; {output token parsed from S}
  out     delim_pick: sys_int_machine_t; {index to main delimeter ending token}
  out     stat: sys_err_t);            {completion status code}
  val_param;

type
  parse_k_t = (                        {current parsing state options}
    parse_lead_k,                      {in leading delimiters}
    parse_token_k,                     {reading token characters}
    parse_quote_k,                     {reading chars within quoted string token}
    parse_qend_k,                      {last character was ending quote}
    parse_trailp_k,                    {in trailing padding before delimiters}
    parse_trail_k);                    {in trailing delimiters}

var
  i: sys_int_machine_t;                {scratch integer and loop counter}
  npad: sys_int_machine_t;             {number padding chars not appended to token}
  parse: parse_k_t;                    {current parsing state}
  c: char;                             {current character read from S}
  quote: char;                         {character to end quoted string}

label
  char_next, char_again, err_afterq, got_trail_delim;

begin
  sys_error_none (stat);               {init to no error encountered}
  token.len := 0;                      {init returned token to empty}
  delim_pick := 0;                     {init to no trailing delimiter}
  parse := parse_lead_k;               {init input string parsing state}
  npad := 0;                           {init to no pending pad characters}

char_next:                             {back here for next input string char}
  if p > s.len then begin              {no more characters left in input string ?}
    case parse of                      {some parsing states reqire special handling}
parse_lead_k: begin                    {we never found any token characters}
        sys_stat_set (string_subsys_k, string_stat_eos_k, stat);
        end;
parse_quote_k: begin                   {we were inside a quoted string}
        sys_stat_set (string_subsys_k, string_stat_no_endquote_k, stat);
        end;
      end;
    return;
    end;                               {done handling input string end encountered}
  c := s.str[p];                       {fetch this input string character}
  p := p + 1;                          {update input string parse index}

char_again:                            {jump here with new parse state, same char}
  case parse of                        {go to different code for each parse state}
{
*   We are in repeatable delimiters before token.
}
parse_lead_k: begin
  if (string_tkopt_padsp_k in flags) and (c = ' ') {leading blank padding ?}
    then goto char_next;
  for i := 1 to n_delim_rept do begin  {once for each repeatable delimiter}
    if c = delim[i] then goto char_next; {found another repeatable delimiter ?}
    end;
  if                                   {check for token is quoted string}
      ((string_tkopt_quoteq_k in flags) and (c = '"')) or
      ((string_tkopt_quotea_k in flags) and (c = ''''))
      then begin
    parse := parse_quote_k;            {we are now parsing a quoted string}
    quote := c;                        {save character that will end quote}
    goto char_next;                    {back and process next input character}
    end;
  parse := parse_token_k;              {assume C is first token character}
  goto char_again;                     {re-evaluate this char with new parse mode}
  end;
{
*   We are in non-quoted token.
}
parse_token_k: begin
  for i := 1 to n_delim do begin       {once for each of the delimiters}
    if c = delim[i] then begin         {C is a delimiter character ?}
      parse := parse_trail_k;          {now in trailing delimiters after token}
      goto got_trail_delim;            {go process trailing delimiter}
      end;
    end;                               {back and check next delimiter character}
  if (string_tkopt_padsp_k in flags) and (c = ' ') then begin {possible pad character ?}
    npad := npad + 1;
    goto char_next;
    end;
  for i := 1 to npad do begin          {any previous pads were real token chars}
    string_append1 (token, ' ');
    end;
  npad := 0;                           {reset to no pending pad characters}
  string_append1 (token, c);           {not delimiter, add to token}
  end;
{
*   We are in quoted string token.  QUOTE is the quote close character.
}
parse_quote_k: begin
  if c = quote then begin              {found closing quote character ?}
    parse := parse_qend_k;             {next char will be right after close quote}
    goto char_next;                    {back and process next input string char}
    end;
  string_append1 (token, c);           {add character to token}
  end;
{
*   C is the first character following the closing quote character.
}
parse_qend_k: begin
  if c = quote then begin              {C is second of two consecutive quote chars ?}
    string_append1 (token, c);         {two consecutive quotes translate as one}
    parse := parse_quote_k;            {back to within quoted string}
    goto char_next;                    {back and process next input string char}
    end;
  for i := 1 to n_delim do begin       {once for each of the delimiters}
    if c = delim[i] then begin         {C is a delimiter character ?}
      parse := parse_trail_k;          {now in trailing delimiters after token}
      goto got_trail_delim;            {go process trailing delimiter}
      end;
    end;                               {back and check next delimiter character}
  if (string_tkopt_padsp_k in flags) and (c = ' ') then begin {trailing pad character ?}
    parse := parse_trailp_k;
    goto char_next;
    end;
err_afterq:                            {illegal character found after closed quote}
  sys_stat_set (                       {found illegal character after close quote}
    string_subsys_k, string_stat_after_quote_k, stat);
  sys_stat_parm_char (c, stat);        {offending character}
  sys_stat_parm_int (p - 1, stat);     {index of offending character}
  sys_stat_parm_vstr (s, stat);        {string containing error}
  return;
  end;
{
*   In trailing pad characters after token body but before ending delimiters.
*   This state is only possible if the token was quoted.
}
parse_trailp_k: begin
  for i := 1 to n_delim do begin       {once for each of the delimiters}
    if c = delim[i] then begin         {C is a delimiter character ?}
      parse := parse_trail_k;          {now in trailing delimiters after token}
      goto got_trail_delim;            {go process trailing delimiter}
      end;
    end;                               {back and check next delimiter character}
  if c = ' ' then goto char_next;      {another pad character ?}
  goto err_afterq;                     {illegal character after closed quote}
  end;
{
*   We are in trailing delimiters after token.  At least one repeating delimiter
*   has already been found.
}
parse_trail_k: begin
  for i := 1 to n_delim do begin       {once for each of the delimiters}
    if c = delim[i] then goto got_trail_delim; {C is a delimiter ?}
    end;                               {back and check C against next delimiter}
  if (string_tkopt_padsp_k in flags) and (c = ' ') then begin {trailing pad character ?}
    goto char_next;                    {skip this character}
    end;
  p := p - 1;                          {restart next time with this character}
  return;                              {return with only repeating trail delim found}

got_trail_delim:                       {C is delimiter, I is DELIM index}
  if i > n_delim_rept then begin       {this is a non-repeating delimiter ?}
    delim_pick := i;                   {indicate which delimiter ended token}
    return;
    end;
  if delim_pick = 0 then begin         {no previous delimiter logged ?}
    delim_pick := i;                   {save index to first delimiter}
    end;
  end;
{
*   Done handling the current character, advance to next.
}
    end;                               {end of parse state cases}
  goto char_next;                      {back to process next input string character}
  end;
{
*********************************************************************
*
*   Subroutine STRING_TOKEN (S, P, TOKEN, STAT)
*
*   Extract the next token from string S into TOKEN.  This routine works
*   like STRING_TOKEN_ANYD, except that space is the only delimiter, and
*   strings within quotes ("...") and apostrophies ('...') are handled as
*   whole tokens.
}
procedure string_token (               {get next token from string, blank delimeters}
  in      s: univ string_var_arg_t;    {input string}
  in out  p: string_index_t;           {parse index, init to 1 for start of string}
  out     token: univ string_var_arg_t; {output token, null string after last token}
  out     stat: sys_err_t);            {completion status code}
  val_param;

var
  i: sys_int_machine_t;

begin
  string_token_anyd (                  {parse token with arbitrary delimiters}
    s,                                 {input string}
    p,                                 {input string parse index, will be updated}
    ' ',                               {list of delimiter characters}
    1,                                 {total number of delimiters}
    1,                                 {number of repeating delimiters}
    [string_tkopt_quoteq_k, string_tkopt_quotea_k], {enable special quote handling}
    token,                             {returned token}
    i,                                 {index of terminating delimiter (unused)}
    stat);                             {returned completion status code}
  end;
{
*********************************************************************
*
*   Subroutine STRING_TOKEN_COMMA (S, P, TOKEN, STAT)
*
*   Extract the next token from string S into TOKEN.  Tokens are only
*   delimited by commas, may be quoted, and may have leading and trailing
*   spaces which will be stripped.
}
procedure string_token_comma (         {like string_token, using blanks and commas}
  in      s: univ string_var_arg_t;    {input string}
  in out  p: string_index_t;           {parse index, init to 1 for start of string}
  out     token: univ string_var_arg_t; {output token}
  out     stat: sys_err_t);            {completion status code}
  val_param;

var
  i: sys_int_machine_t;

begin
  string_token_anyd (                  {parse token with arbitrary delimiters}
    s,                                 {input string}
    p,                                 {input string parse index, will be updated}
    ',',                               {list of delimiter characters}
    1,                                 {total number of delimiters}
    0,                                 {number of repeating delimiters}
    [ string_tkopt_quoteq_k,           {enable "" quotes}
      string_tkopt_quotea_k,           {enable '' quotes}
      string_tkopt_padsp_k],           {strip space padding characters}
    token,                             {returned token}
    i,                                 {index of terminating delimiter (unused)}
    stat);                             {returned completion status code}
  end;
{
*********************************************************************
*
*   Subroutine STRING_TOKEN_COMMASP (S, P, TOKEN, STAT)
*
*   Extract the next token from string S into TOKEN.  A token is delimited by
*   a single comma or multiple spaces.  Leading and trailing spaces surrouinding
*   the token will be stripped.
}
procedure string_token_commasp (       {get token, 1 comma or N blank delimiters}
  in      s: univ string_var_arg_t;    {input string}
  in out  p: string_index_t;           {parse index, init to 1 for start of string}
  out     token: univ string_var_arg_t; {output token}
  out     stat: sys_err_t);            {completion status code}
  val_param;

var
  i: sys_int_machine_t;

begin
  string_token_anyd (                  {parse token with arbitrary delimiters}
    s,                                 {input string}
    p,                                 {input string parse index, will be updated}
    ' ,', 2,                           {list of delimiter characters}
    1,                                 {number of repeating delimiters}
    [ string_tkopt_quoteq_k,           {enable "" quotes}
      string_tkopt_quotea_k],          {enable '' quotes}
    token,                             {returned token}
    i,                                 {index of terminating delimiter (unused)}
    stat);                             {returned completion status code}
  end;
{
*********************************************************************
*
*   Subroutine STRING_TOKEN_MAKE (STR, TK)
*
*   Create a single parseable token from the input string STR.  If
*   TK is surrounded with blanks and added to a string, then STRING_TOKEN
*   will parse it as one entity and return the value in STR.  This works
*   regardless of whether STR contains, blanks, quotes, etc.  TK may be
*   returned enclosed in quotes or apostrophies as approriate.  In general,
*   as little modification to STR is made as possible in converting it to
*   a single token.
}
procedure string_token_make (          {make individual token from input string}
  in      str: univ string_var_arg_t;  {input string}
  in out  tk: univ string_var_arg_t);  {will be parsed as one token by STRING_TOKEN}
  val_param;

type
  spch_k_t = (                         {types of special characters we care about}
    spch_q1_k,                         {quote type 1, real quote}
    spch_q2_k,                         {quote type 2, apostrophie}
    spch_sp_k);                        {space}
  spch_t = set of spch_k_t;

var
  i: sys_int_machine_t;                {scratch integer and loop counter}
  spch: spch_t;                        {types of special chars in input string}
  c: char;
  q: char;                             {enclosing quote character}

label
  nomod;

begin
  if str.len <= 0 then begin           {input string is empty ?}
    string_vstring (tk, '""', 2);
    return;
    end;
{
*   Check for which type of special characters are present in the input
*   string.
}
  spch := [];                          {init to no special characters present}
  for i := 1 to str.len do begin       {scan the whole input string}
    c := str.str[i];                   {fetch this input string character}
    if c = '"' then begin              {found quote ?}
      spch := spch + [spch_q1_k];
      next;
      end;
    if c = '''' then begin             {found apostrophie ?}
      spch := spch + [spch_q2_k];
      next;
      end;
    if c = ' ' then begin              {found blank ?}
      spch := spch + [spch_sp_k];
      end;
    end;                               {back to check next input string character}
{
*   SPCH contains flags for each type of character in the input string that
*   we have to handle specially.
*
*   Check for whether the input string can be passed back without modification.
*   This is only true if it contains no blanks and doesn't start with any kind
*   of quote.
}
  if spch = [] then begin              {no special characters at all to deal with ?}
nomod:                                 {jump here to pass back unmodified string}
    string_copy (str, tk);             {pass back unmodified input string}
    return;
    end;

  if
      (str.str[1] <> '"') and (str.str[1] <> '''') and {doesn't start with a quote ?}
      (not (spch_sp_k in spch))        {doesn't contain any blanks ?}
    then goto nomod;
{
*   The input string must be passed back as a quoted string.
}
  if spch_q1_k in spch                 {decide which kind of quote to use}
    then begin                         {input string contains quote}
      if spch_q2_k in spch
        then q := '"'                  {both present, pick quote}
        else q := '''';                {pick the one not present}
      end
    else begin                         {no quote in input string}
      q := '"';                        {pick quote}
      end
    ;

  string_vstring (tk, q, 1);           {init output string with starting quote}

  for i := 1 to str.len do begin       {once for each input string character}
    c := str.str[i];                   {fetch this input string character}
    if c = q then begin                {this is the quote char we are using ?}
      string_append1 (tk, c);          {cause quote char to be written twice}
      end;
    if tk.len >= tk.max then return;   {no room for another char in output string ?}
    tk.len := tk.len + 1;              {one more char in output string}
    tk.str[tk.len] := c;               {copy input string char to output string}
    end;                               {back for next input string char}

  string_append1 (tk, q);              {add closing quote to output string}
  end;
{
*********************************************************************
*
*   Subroutine STRING_TOKEN_BOOL (S, P, FLAGS, T, STAT)
*
*   Parse the next token from string S, convert it to a boolean value, and
*   return the result in T.  P is the parse index into string S, and indicates
*   the first character of S to start looking for the token at.  P is
*   updated so that the next call will find the next token.
*
*   FLAGS selects which keywords are allowed to select the TRUE/FALSE values.
*   FLAGS can be any combination of the following:
*
*     STRING_TFTYPE_TF_K  -  TRUE, FALSE
*     STRING_TFTYPE_YESNO_K  -  YES, NO
*     STRING_TFTYPE_ONOFF_K  -  ON, OFF
*
*   The keywords are always case-insensitive.
}
procedure string_token_bool (          {parse token and convert to boolean}
  in      s: univ string_var_arg_t;    {input string}
  in out  p: string_index_t;           {input string parse index, init to 1 at start}
  in      flags: string_tftype_t;      {selects which T/F types are allowed}
  out     t: boolean;                  {TRUE: true, yes, on, FALSE: false, no, off}
  out     stat: sys_err_t);            {completion status code}
  val_param;

var
  tk: string_var80_t;                  {the token}

begin
  tk.max := size_char(tk.str);         {init local var string}

  string_token (s, p, tk, stat);       {parse the token into TK}
  if sys_error(stat) then return;

  string_t_bool (                      {convert the token to a boolean value}
    tk,                                {input string}
    flags,                             {option flags}
    t,                                 {returned boolean value}
    stat);
  end;
