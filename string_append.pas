{   Module of routines for appending things to the end of existing strings.
}
module string_append;
define string_append;
define string_append1;
define string_appendn;
define string_appends;
define string_append_token;
%include '/cognivision_links/dsee_libs/string/string2.ins.pas';
{
*********************************************************************
*
*   Subroutine STRING_APPEND (S1, S2)
*
*   Append string 2 onto the end of string 1.  The result is put into
*   string 1.
}
procedure string_append (              {append one string onto another}
  in out  s1: univ string_var_arg_t;   {string to append to}
  in      s2: univ string_var_arg_t);  {string that is appended to S1}

var
  nchar: sys_int_machine_t;            {number of characters to copy}
  i, j: sys_int_machine_t;             {scratch integers}

begin
  j := s1.len;                         {init end of string 1 pointer}
  nchar := s2.len;                     {init number of chars to copy}
  if nchar > s1.max-j then nchar:=s1.max-j; {clip to max room left in s1}
  s1.len := j+nchar;                   {update s1 length}
  for i := 1 to nchar do begin         {once for each character}
    j := j+1;                          {point to next position in s1}
    s1.str[j] := s2.str[i];            {copy one character}
    end;                               {done copying all the characters}
  end;
{
*********************************************************************
*
*   Subroutine STRING_APPEND1 (S, CHR)
*
*   Append the character CHR to the end of string S.
}
procedure string_append1 (             {append one char to end of string}
  in out  s: univ string_var_arg_t;    {string to append to}
  in      chr: char);                  {character to append}
  val_param;

begin
  if s.len >= s.max then return;       {no room for another character ?}
  s.len := s.len+1;                    {one more character in string}
  s.str[s.len] := chr;                 {put character at string end}
  end;
{
*********************************************************************
*
*   Subroutine STRING_APPENDN (S, CHARS, N)
*
*   Append N characters to the end of string S.  S is a normal
*   variable length string.  CHARS is just an array of characters.
}
procedure string_appendn (             {append N characters to end of string}
  in out  s: univ string_var_arg_t;    {string to append to}
  in      chars: univ string;          {characters to append to string}
  in      n: string_index_t);          {number of characters to append}
  val_param;

var
  i, j: sys_int_machine_t;             {string indices}
  nc: sys_int_machine_t;               {number of chars to copy}

begin
  nc := s.max-s.len;                   {init to room left in S}
  if nc > n then nc := n;              {nc = num of chars to copy}
  if nc <= 0 then return;              {nothing to append ?}
  j := s.len+1;                        {init S index}
  for i := 1 to nc do begin            {once for each char to copy}
    s.str[j] := chars[i];              {copy one character}
    j := j+1;                          {update put pointer}
    end;                               {back and copy next char}
  s.len := s.len+nc                    {update length of S}
  end;
{
*********************************************************************
*
*   Subroutine STRING_APPENDS (S, CHARS)
*
*   Append the PASCAL STRING in CHARS to the end of the variable length
*   string in S.  The string in S will only be used up to but no including
*   the trailing blanks.
}
procedure string_appends (             {append PASCAL STRING to variable length string}
  in out  s: univ string_var_arg_t;    {string to append to}
  in      chars: string);              {append these chars up to trailing blanks}

var
  vstr: string_var80_t;                {var string copy of CHARS}

begin
  vstr.max := sizeof(vstr.str);        {init local var string}

  string_vstring (vstr, chars, sizeof(chars)); {make var string from CHARS}
  string_append (s, vstr);             {append var string to end of S}
  end;
{
*********************************************************************
*
*   Subroutine STRING_APPEND_TOKEN (STR, TK)
*
*   Append the string in TK to the end of STR in such a way that it would
*   be parsed as a single token by STRING_TOKEN.  STRING_TOKEN would return
*   the original contents of TK, regardless of whether TK contained quotes,
*   apostrophies, or blanks.
}
procedure string_append_token (        {append single token using STRING_TOKEN rules}
  in out  str: univ string_var_arg_t;  {string to append to}
  in      tk: univ string_var_arg_t);  {string to append as individual token}
  val_param;

var
  t: string_var8192_t;                 {tokenized copy of TK}

begin
  t.max := sizeof(t.str);              {init local var string}

  string_token_make (tk, t);           {make individual token of TK in T}
  if                                   {end of existing string is end of previous token ?}
      (str.len > 0) and then
      (str.str[str.len] <> ' ')
      then begin
    string_append1 (str, ' ');         {add separator before new token}
    end;
  string_append (str, t);              {append token to end of string}
  end;
