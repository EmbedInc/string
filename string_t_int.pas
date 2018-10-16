{   Subroutine STRING_T_INT (S,VAL,STAT)
*
*   Convert string in S to the machine integer VAL.  STAT is the completion
*   status code.  The input integer has the format bb#nnnn, where BB stands
*   for the number base, and NN is the integer in that number base.  If
*   bb# is omitted, base ten is assumed.  Base ten is always used for the BB
*   string.
}
module string_t_int;
define string_t_int;
%include 'string2.ins.pas';

procedure string_t_int (               {convert string to machine integer}
  in      s: univ string_var_arg_t;    {input string}
  out     val: sys_int_machine_t;      {output integer}
  out     stat: sys_err_t);            {completion status code}

var
  im: sys_int_max_t;                   {raw integer value}
  base: sys_int_max_t;                 {number base for conversion}
  str: string_var80_t;                 {scratch string}
  i: sys_int_machine_t;                {scratch integer and loop counter}

begin
  for i := 2 to s.len - 1 do begin     {scan for "#" character, if any}
    if s.str[i] = '#' then begin       {found "#" separating base and digits ?}
{
*   The input number if of the form <base>#<digits>.  I is the string index of
*   the "#" separator character in S.
}
      str.max := sizeof(str.str);      {init local var string}
      string_substr (s, 1, i - 1, str); {extract number base string}
      string_t_int_max_base (          {convert number base string}
        str,                           {input string}
        10,                            {number base of string}
        [string_ti_unsig_k],           {unsigned number, blank is error}
        base,                          {returned integer value}
        stat);
      if sys_error(stat) then return;

      string_substr (s, i + 1, s.len, str); {extract digits string}
      string_t_int_max_base (          {convert string to integer}
        str,                           {input string}
        base,                          {number base of string}
        [],                            {signed number, blank is error}
        im,                            {raw integer value}
        stat);
      if sys_error(stat) then return;
      val := im;                       {pass back final value}
      return;
      end;                             {done handling <base>#<digits> format}
    end;                               {back and check next S char for "#"}
{
*   No "#" found in input number.  Default to base ten.
}
  string_t_int_max_base (              {convert string to raw integer}
    s,                                 {input string}
    10,                                {number base of string}
    [],                                {signed number, blank is error}
    im,                                {raw integer value}
    stat);
  if sys_error(stat) then return;
  val := im;                           {pass back final value}
  end;
