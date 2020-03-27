module string_slen;
define string_slen;
%include 'string2.ins.pas';
{
********************************************************************************
*
*   Function STRING_SLEN (CHARS, MAXLEN)
*
*   Find the string length of a sequence of characters CHARS.  The end of the
*   string is found in one of two ways:
*
*     1  -  If a null (code 0) character is found at or before MAXLEN, then the
*           string is everything preceeding the null.
*
*     2  -  If no null is found, then the length is the string out to MAXLEN
*           without any trailing blanks.
}
function string_slen (                 {find string length of character sequence}
  in      chars: string;               {chars, blank padded or NULL terminated}
  in      maxlen: sys_int_machine_t)   {max possible length of the char sequence}
  :sys_int_machine_t;                  {0-N string length}
  val_param;

var
  ind: sys_int_machine_t;              {string index}

begin
  string_slen := 0;                    {handle special case of 0 or negative MAXLEN}
  if maxlen <= 0 then return;

  for ind := 1 to maxlen do begin      {scan the string}
    if ord(chars[ind]) = 0 then begin  {found terminating NULL ?}
      string_slen := ind - 1;
      return;
      end;
    if chars[ind] <> ' ' then begin    {found new non-blank ?}
      string_slen := ind;              {string goes to at least here}
      end;
    end;                               {back to check next char}
  end;                                 {got to end, return length to last non-blank}
