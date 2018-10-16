{   Subroutine STRING_TOKEN_INT (S, P, I, STAT)
*
*   Parse the next token from string S and convert it integer I.  P is the current
*   parse index into string S.  It should be set to 1 to start at the beginning of
*   the string, and will be updated after each call so that the next call gets
*   the next token.  STAT is the completion status code.  It will indicate
*   end of string S, NULL token, and string to integer conversion error.
*
*   The parsing rules are defined by subroutine STRING_TOKEN_COMMASP.
}
module string_token_int;
define string_token_int;
%include '/cognivision_links/dsee_libs/string/string2.ins.pas';

procedure string_token_int (           {get next token and convert to machine integer}
  in      s: univ string_var_arg_t;    {input string}
  in out  p: string_index_t;           {input string parse index, init to 1 at start}
  out     i: sys_int_machine_t;        {output value}
  out     stat: sys_err_t);            {completion status code}
  val_param;

var
  token: string_var132_t;              {our token parsed from S}

begin
  token.max := sizeof(token.str);      {init local var string}

  string_token_commasp (s, p, token, stat); {get next token from S}
  if sys_error(stat) then return;
  if token.len = 0 then begin
    sys_stat_set (string_subsys_k, string_stat_null_tk_k, stat);
    return;                            {return with NULL TOKEN status}
    end;
  string_t_int (token, i, stat);       {convert token to integer}
  end;
