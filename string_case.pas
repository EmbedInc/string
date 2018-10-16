{   Module of routines that deal with character upper/lower case issues.
}
module string_case;
define string_upcase_char;
define string_downcase_char;
define string_upcase;
define string_downcase;
define string_char_printable;
%include '/cognivision_links/dsee_libs/string/string2.ins.pas';
{
*********************************************************************
*
*   Function STRING_UPCASE_CHAR (C)
*
*   Return the upper case version of C.
}
function string_upcase_char (          {make upper case version of char}
  in      c: char)                     {character to return upper case of}
  :char;                               {always upper case}
  val_param;

begin
  if (c >= 'a') and (c <= 'z')
    then begin                         {input character is lower case}
      string_upcase_char := chr(ord(c) - ord('a') + ord('A'));
      end
    else begin                         {input char is already upper case}
      string_upcase_char := c;
      end
    ;
  end;
{
*********************************************************************
*
*   Function STRING_DOWNCASE_CHAR (C)
*
*   Return the lower case version of C.
}
function string_downcase_char (        {make lower case version of char}
  in      c: char)                     {character to return lower case of}
  :char;                               {always lower case}
  val_param;

begin
  if (c >= 'A') and (c <= 'Z')
    then begin                         {input character is upper case}
      string_downcase_char := chr(ord(c) - ord('A') + ord('a'));
      end
    else begin                         {input char is already lower case}
      string_downcase_char := c;
      end
    ;
  end;
{
*********************************************************************
*
*   Subroutine STRING_UPCASE (S)
*
*   Convert all the lower case alphabetic characters in string S
*   to their corresponding upper case characters.
}
procedure string_upcase (              {convert all lower case chars to upper case}
  in out  s: univ string_var_arg_t);   {string to upcase}

var
  i: sys_int_machine_t;                {loop counter}
  c: char;

begin
  for i := 1 to s.len do begin         {once for each character in string}
    c := s.str[i];                     {fetch this string character}
    if (c >= 'a') and (c <= 'z') then begin {this is a lower case character ?}
      s.str[i] := chr(ord(c) - ord('a') + ord('A'));
      end;
    end;                               {back and do next character}
  end;
{
*********************************************************************
*
*   Subroutine STRING_DOWNCASE (S)
*
*   Convert all the upper case alphabetic characters in string S
*   to their corresponding lower case characters.
}
procedure string_downcase (            {change all upper case chars to lower case}
  in out  s: univ string_var_arg_t);   {string to convert in place}

var
  i: sys_int_machine_t;                {loop counter}
  c: char;

begin
  for i := 1 to s.len do begin         {once for each character in string}
    c := s.str[i];                     {fetch this string character}
    if (c >= 'A') and (c <= 'Z') then begin {this is an upper case character ?}
      s.str[i] := chr(ord(c) - ord('A') + ord('a'));
      end;
    end;                               {back and do next character}
  end;
{
*********************************************************************
*
*   Function STRING_CHAR_PRINTABLE (C)
*
*   Returns TRUE if C is a normal printable character, FALSE if it is a
*   control character.  Note that space is a printable character.
}
function string_char_printable (       {test whether character is normal printable}
  in      c: char)                     {character to test}
  :boolean;                            {TRUE if printable, FALSE if control char}
  val_param;

begin
  string_char_printable := (c >= ' ') and (c <= '~');
  end;
