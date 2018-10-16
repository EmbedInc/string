{   Subroutine STRING_CMLINE_TOKEN_INT (I,STAT)
*
*   Read the next token from the command line and convert it to the integer I.
*   STAT is the completion status code.
}
module string_cmline_token_int;
define string_cmline_token_int;
%include '/cognivision_links/dsee_libs/string/string2.ins.pas';

procedure string_cmline_token_int (    {read next command line token as machine int}
  out     i: univ sys_int_machine_t;   {returned integer value}
  out     stat: sys_err_t);            {completion status code}

var
  token: string_var132_t;              {token read from command line}

begin
  token.max := sizeof(token.str);      {init var string}

  string_cmline_token (token, stat);   {get next token from command line}
  if sys_error(stat) then return;
  string_t_int (token, i, stat);       {convert string to integer}
  end;
