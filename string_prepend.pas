{   Routines to add to the beginning of var strings.
}
module string_prepend;
define string_prependn;
define string_prepend;
%include 'string2.ins.pas';
{
********************************************************************************
*
*   Subroutine STRING_PREPENDN (STR, CHARS, N)
*
*   Prepend the N characters of STR to the var string VSTR.
}
procedure string_prependn (            {add N chars to start of string}
  in out  str: univ string_var_arg_t;  {string to add chars to front of}
  in      chars: string;               {characters to add}
  in      n: sys_int_machine_t);       {number of characters to add}
  val_param;

var
  nwr: sys_int_machine_t;              {number of chars to write to front of string}
  sind: sys_int_machine_t;             {STR index}

begin
  nwr := min(str.max, n);              {make number of chars to write at front}
  if nwr <= 0 then return;             {no chars to write, nothing to do ?}
  str.len := min(str.max, str.len + nwr); {make resulting string length}
{
*   Shift the existing characters right to make room for the new characters.
}
  sind := str.len - nwr;               {init read index of the shift}
  while sind > 0 do begin              {shift existing chars to make room for new}
    str.str[sind + nwr] := str.str[sind]; {shift this char over}
    sind := sind - 1;                  {to next char}
    end;
{
*   Copy the new characters to the front of the string.
}
  for sind := 1 to nwr do begin        {once for each chara to copy}
    str.str[sind] := chars[sind];      {copy this char}
    end;                               {back for next char}
  end;
{
********************************************************************************
*
*   Subroutine STRING_PREPEND (STR, ADD)
*
*   Add string ADD to the front of string STR.
}
procedure string_prepend (             {add one string to front of another}
  in out  str: univ string_var_arg_t;  {the string to add to the front of}
  in      add: univ string_var_arg_t); {the string to add}
  val_param;

begin
  string_prependn (str, add.str, add.len);
  end;
{
********************************************************************************
*
*   Subroutine STRING_PREPENDS (STR, CHARS)
*
*   Add the string in CHARS up to the NULL or trailing blanks to the front of
*   STR.
}
procedure string_prepends (            {add Pascal string to front of var string}
  in out  str: univ string_var_arg_t;  {string to prepend to}
  in      chars: string);              {chars up to NULL or trailing blanks}
  val_param;

var
  slen: sys_int_machine_t;             {length of string to prepend}

begin
  slen := string_slen (chars, size_char(chars)); {find length of string to prepend}
  string_prependn (str, chars, slen);  {prepend it}
  end;
