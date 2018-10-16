{   Subroutine STRING_CMLINE_TOKEN (TOKEN, STAT)
*
*   Fetch the next token from the command line.  STRING_CMLINE_INIT must have been
*   called once before this routine.  If STRING_CMLINE_REUSE was called since the
*   last call to this routine, then the last token will be returned again.
*
*   This version is for any operating system where we are given the entire
*   command line as one string, then parse it ourselves.
}
module string_cmline_token;
define string_cmline_token;
%include '/cognivision_links/dsee_libs/string/string2.ins.pas';
%include '/cognivision_links/dsee_libs/string/string_sys.ins.pas';

procedure string_cmline_token (        {get next token from command line}
  in out  token: univ string_var_arg_t; {returned token}
  out     stat: sys_err_t);            {completion status, used to signal end}

begin
  if cmline_reuse
    then begin                         {return the same token as last time}
      cmline_reuse := false;           {reset to read fresh token next time}
      if cmline_last_eos then begin    {EOS was returned for the last token ?}
        sys_stat_set (string_subsys_k, string_stat_eos_k, stat);
        return;                        {return with end of string status}
        end;
      sys_error_none (stat);           {init to no error}
      end
    else begin                         {return the next token from the command line}
      if cmline_next_n = 1 then begin  {getting first token on command line ?}
        vcmline_parse := vcmline_parse_start; {reset to get first argument next}
        end;
      string_token (                   {extract next token from command line string}
        vcmline,                       {input string}
        vcmline_parse,                 {VCMLINE parse index}
        cmline_token_last,             {returned token string}
        stat);
      cmline_last_eos :=               {remember if hit end of string}
        stat.err and
        (stat.subsys = string_subsys_k) and
        (stat.code = string_stat_eos_k);
      cmline_next_n := cmline_next_n + 1; {update number of next command line token}
      end
    ;
  string_copy (cmline_token_last, token); {return token to caller}
  end;
