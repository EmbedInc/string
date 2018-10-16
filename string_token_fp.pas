{   Routines that parse tokens and return floating point numbers.  All
*   the routines here are the same execpt for the type of floating point
*   number they return.
*
*   Subroutine STRING_TOKEN_FPx (S, P, FP, STAT)
*
*   Parse the next token from the string S and convert it to a
*   floating point number in FP.  P is the parse index into S.
*   It should be initially set to 1 to extract the first token.  It is
*   updated so that successive calls parse successive tokens.
*   STAT is the returned completion status code.  It can indicate
*   end of string, NULL token, and string to floating point
*   conversion error.
*
*   The parsing rules are defined by subroutine STRING_TOKEN_COMMASP.
}
module string_token_fp;
define string_token_fp1;
define string_token_fpm;
define string_token_fp2;
%include '/cognivision_links/dsee_libs/string/string2.ins.pas';
{
**************************
*
*   Subroutine STRING_TOKEN_FP1 (S, P, FP, STAT)
*
*   Returns single precision floating point number.
}
procedure string_token_fp1 (           {parse token and convert to single prec FP}
  in      s: univ string_var_arg_t;    {input string}
  in out  p: string_index_t;           {input string parse index, init to 1 at start}
  out     fp: sys_fp1_t;               {output value}
  out     stat: sys_err_t);            {completion status code}
  val_param;

var
  fpmax: sys_fp_max_t;                 {FP number for low level conversion routine}
  token: string_var132_t;              {token parsed from input string}

begin
  token.max := sizeof(token.str);      {init local var string}
  string_token_commasp (s, p, token, stat); {get next token from input string}
  if sys_error(stat) then return;
  if token.len <= 0 then begin
    sys_stat_set (string_subsys_k, string_stat_null_tk_k, stat);
    return;                            {return with NULL TOKEN status}
    end;
  string_t_fpmax (                     {convert token to max size FP number}
    token,                             {input token}
    fpmax,                             {output floating point number}
    [],                                {no special flags}
    stat);                             {returned completion status code}
  fp := fpmax;                         {return FP number in caller's format}
  end;
{
**************************
*
*   Subroutine STRING_TOKEN_FPM (S, P, FP, STAT)
*
*   Returns machine floating point number.
}
procedure string_token_fpm (           {parse token and convert to machine FP}
  in      s: univ string_var_arg_t;    {input string}
  in out  p: string_index_t;           {input string parse index, init to 1 at start}
  out     fp: real;                    {output value}
  out     stat: sys_err_t);            {completion status code}
  val_param;

var
  fpmax: sys_fp_max_t;                 {FP number for low level conversion routine}
  token: string_var132_t;              {token parsed from input string}

begin
  token.max := sizeof(token.str);      {init local var string}
  string_token_commasp (s, p, token, stat); {get next token from input string}
  if sys_error(stat) then return;
  if token.len <= 0 then begin
    sys_stat_set (string_subsys_k, string_stat_null_tk_k, stat);
    return;                            {return with NULL TOKEN status}
    end;
  string_t_fpmax (                     {convert token to max size FP number}
    token,                             {input token}
    fpmax,                             {output floating point number}
    [],                                {no special flags}
    stat);                             {returned completion status code}
  fp := fpmax;                         {return FP number in caller's format}
  end;
{
**************************
*
*   Subroutine STRING_TOKEN_FP2 (S, P, FP, STAT)
*
*   Returns double precision floating point number.
}
procedure string_token_fp2 (           {parse token and convert to double prec FP}
  in      s: univ string_var_arg_t;    {input string}
  in out  p: string_index_t;           {input string parse index, init to 1 at start}
  out     fp: sys_fp2_t;               {output value}
  out     stat: sys_err_t);            {completion status code}
  val_param;

var
  fpmax: sys_fp_max_t;                 {FP number for low level conversion routine}
  token: string_var132_t;              {token parsed from input string}

begin
  token.max := sizeof(token.str);      {init local var string}
  string_token_commasp (s, p, token, stat); {get next token from input string}
  if sys_error(stat) then return;
  if token.len <= 0 then begin
    sys_stat_set (string_subsys_k, string_stat_null_tk_k, stat);
    return;                            {return with NULL TOKEN status}
    end;
  string_t_fpmax (                     {convert token to max size FP number}
    token,                             {input token}
    fpmax,                             {output floating point number}
    [],                                {no special flags}
    stat);                             {returned completion status code}
  fp := fpmax;                         {return FP number in caller's format}
  end;
