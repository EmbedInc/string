{   Subroutine STRING_CMLINE_TOKEN (TOKEN, STAT)
*
*   Fetch the next token from the command line.  STRING_CMLINE_INIT must have been
*   called once before this routine.  If STRING_CMLINE_REUSE was called since the
*   last call to this routine, then the last token will be returned again.
}
module string_cmline_token;
define string_cmline_token;
%include 'string2.ins.pas';
%include 'string_sys.ins.pas';

procedure string_cmline_token (        {get next token from command line}
  in out  token: univ string_var_arg_t; {returned token}
  out     stat: sys_err_t);            {completion status, used to signal end}

begin
  sys_error_none (stat);               {init to no error}

  if not cmline_reuse then begin       {need to read new token from system ?}
    if cmline_next_n >= cmline_n_args then begin {no more command line args ?}
      sys_stat_set (string_subsys_k, string_stat_eos_k, stat);
      token.len := 0;
      cmline_token_last.len := 0;      {the last token is now the empty token}
      return;                          {return with END OF STRING status}
      end;
    string_vstring (                   {copy command line arg into local buffer}
      cmline_token_last,               {var string top copy arg into}
      cmline_argp_p^[cmline_next_n]^,  {null terminated string to copy from}
      -1);                             {indicate max string length not known}
    cmline_next_n := cmline_next_n + 1; {make arg number for next time}
    end;                               {new arg is sitting in CMLINE_TOKEN_LAST}

  string_copy (cmline_token_last, token); {return token to caller}
  cmline_reuse := false;               {init to read fresh token next time}
  end;
