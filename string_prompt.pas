{   Subroutine STRING_PROMPT (S)
*
*   Write the string S to standard output without a newline following.  This
*   may be useful when prompting the user for interactive input.
}
module string_prompt;
define string_prompt;
%include 'string2.ins.pas';
%include 'string_sys.ins.pas';

procedure string_prompt (              {string to standard output without newline}
  in      s: univ string_var_arg_t);   {prompt string to write}

begin
  write (s.str:s.len);                 {write prompt to buffer}
  sys_sys_flush (sys_sys_iounit_stdout_k); {force-write any buffered data}
  end;
