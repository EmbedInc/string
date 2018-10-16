{   Subroutine STRING_T_INT_MAX (S,VAL,STAT)
*
*   Convert the string S to the integer VAL.  VAL is the largest integer that we
*   can represent with this machine/compiler.  STAT is the completion status code.
}
module string_t_int_max;
define string_t_int_max;
%include 'string2.ins.pas';

procedure string_t_int_max (           {convert string to max size integer}
  in      s: univ string_var_arg_t;    {input string}
  out     val: sys_int_max_t;          {output integer}
  out     stat: sys_err_t);            {completion status code}

var
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
        val,                           {raw integer value}
        stat);
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
    val,                               {raw integer value}
    stat);
  end;
