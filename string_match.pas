{   Function STRING_MATCH (TOKEN,PATT)
*
*   Determine whether the string TOKEN matches the string PATT up to the
*   length of TOKEN.  If the length of TOKEN is greater than the length of
*   PATT, then the strings do not match.
*
*   If this is used to determine whether a token matches a keyword, then
*   this function allows the token to be abbreviated.  Function
*   STRING_EQUAL forces both string to be identical, and therefore would
*   not allow abbreviation.
}
module string_match;
define string_match;
%include 'string2.ins.pas';

function string_match (                {strings same up to length of TOKEN}
  in      token: univ string_var_arg_t; {string being tested}
  in      patt: univ string_var_arg_t) {pattern which can be abbreviated in TOKEN}
  :boolean;                            {TRUE if strings match}

var
  i: sys_int_machine_t;                {string index}

begin
  string_match := false;               {init to token doesn't match}
  if token.len > patt.len then return; {token too long for pattern ?}
  for i := 1 to token.len do           {loop thru all the characters}
    if token.str[i] <> patt.str[i] then return; {this character not match ?}
  string_match := true;                {all the characters did match}
  end;
