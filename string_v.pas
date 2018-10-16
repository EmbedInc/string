{   Function STRING_V (CHAR80)
*
*   Return a variable length string given 80 characters.  The returned
*   string will be the same as the 80 character string with all the
*   trailing blanks removed.  The returned string will have a max length
*   of 80 characters.  The input string is assumed to be either 80 characters
*   long or up to but not including the first zero byte.  This supports
*   C quoted strings.
}
module string_v;
define string_v;
%include '/cognivision_links/dsee_libs/string/string2.ins.pas';

function string_v (                    {convert Pascal STRING to variable string}
  in      char80: string)              {input of STRING data type}
  :string_var80_t;                     {unpadded variable length string}

var
  e: sys_int_machine_t;                {end of string index}
  i: sys_int_machine_t;                {running string index}

label
  last_char;

begin
  string_v.max := sizeof(char80);      {set max size of returned string}
  for e := sizeof(char80) downto 1 do  {scan backwards thru input string}
    if char80[e] <> ' ' then goto last_char; {found last char in input string ?}
{
*   We scanned the whole string and found no non-blank characters.
*   Pass back an empty string.
}
  string_v.len := 0;                   {set length of returned string}
  return;
{
*   E is the index of the last non_blank character in the
*   input string.  Now copy the string.
}
last_char:
  for i := 1 to e do begin             {scan unpadded string}
    if ord(char80[i]) = 0 then begin   {found terminating zero byte ?}
      string_v.len := i-1;             {set returned string length}
      return;
      end;
    string_v.str[i] := char80[i];      {copy one character}
    end;                               {back and copy next character}
  string_v.len := e;                   {set returned string length}
  end;
