{   Function STRING_EQUAL (TOKEN,PATT)
*
*   Determine if the two strings are identical.  The length of the two
*   strings must be the same, and all characters of the strings must
*   match.  The max allowable length of the strings does not matter.
*
*   If this is used for token matching, then the token must match the
*   entire pattern.  Subroutine STRING_MATCH allows matches up to the
*   end of the token, where the token length can be smaller than the
*   pattern length.
}
module string_equal;
define string_equal;
%include 'string2.ins.pas';

function string_equal (                {check for string same (lengths equal)}
  in      token: univ string_var_arg_t; {first string}
  in      patt: univ string_var_arg_t) {second string}
  :boolean;                            {true if strings are equal}

var
  i: sys_int_machine_t;                {string index}

begin
  string_equal := false;               {init to token doesn't match}
  if token.len <> patt.len then return; {strings not of same length}
  for i := 1 to token.len do           {loop thru all the characters}
    if token.str[i] <> patt.str[i] then return; {this character not match ?}
  string_equal := true;                {all the characters did match}
  end;
