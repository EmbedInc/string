{   Routines that read the next command line token are return it as a
*   floating point number.  All the routines are the same except for the
*   type of floating point number they return.
*
*   Subroutine STRING_CMLINE_TOKEN_FPx (FP,STAT)
*
*   Read the next command line token, convert it to a floating point number,
*   and return the result in FP.  STAT is the returned completion status code.
*   It can indicate end of command line, NULL token, or string conversion error.
}
module string_cmline_token_fp;
define string_cmline_token_fp1;
define string_cmline_token_fpm;
define string_cmline_token_fp2;
%include 'string2.ins.pas';
{
**********************************
*
*   Subroutine STRING_CMLINE_TOKEN_FP1 (FP,STAT)
*
*   Returns single precision floating point number.
}
procedure string_cmline_token_fp1 (    {read next cmd line token as single prec FP}
  out     fp: sys_fp1_t;               {returned floating point value}
  out     stat: sys_err_t);            {completion status code}

var
  fpmax: sys_fp_max_t;                 {FP number for low level conversion routine}
  token: string_var132_t;              {token read from command line}

begin
  token.max := sizeof(token.str);      {init local var string}
  string_cmline_token (token, stat);   {get next token from command line}
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
**********************************
*
*   Subroutine STRING_CMLINE_TOKEN_FPM (FP,STAT)
*
*   Returns machine floating point number.
}
procedure string_cmline_token_fpm (    {read next cmd line token as machine FP}
  out     fp: real;                    {returned floating point value}
  out     stat: sys_err_t);            {completion status code}

var
  fpmax: sys_fp_max_t;                 {FP number for low level conversion routine}
  token: string_var132_t;              {token read from command line}

begin
  token.max := sizeof(token.str);      {init local var string}
  string_cmline_token (token, stat);   {get next token from command line}
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
**********************************
*
*   Subroutine STRING_CMLINE_TOKEN_FP2 (FP,STAT)
*
*   Returns double precision floating point number.
}
procedure string_cmline_token_fp2 (    {read next cmd line token as double prec FP}
  out     fp: sys_fp2_t;               {returned floating point value}
  out     stat: sys_err_t);            {completion status code}

var
  fpmax: sys_fp_max_t;                 {FP number for low level conversion routine}
  token: string_var132_t;              {token read from command line}

begin
  token.max := sizeof(token.str);      {init local var string}
  string_cmline_token (token, stat);   {get next token from command line}
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
