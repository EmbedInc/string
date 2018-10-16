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

var
  h: win_handle_t;                     {handle to our standard output stream}
  oleft: sys_int_adr_t;                {number of bytes left to write}
  olen: win_dword_t;                   {number of bytes actually written}
  ok: win_bool_t;                      {not WIN_BOOL_FALSE_K on system call success}
  stat: sys_err_t;

begin
  h := GetStdHandle (stdstream_out_k); {get handle to standard output stream}
  if h = handle_invalid_k then begin
    sys_error_none(stat);
    stat.sys := GetLastError;
    sys_error_abort (stat, '', '', nil, 0);
    sys_bomb;
    end;

  oleft := s.len;                      {init number of bytes left to write}
  while oleft > 0 do begin             {loop until all characters written}
    ok := WriteFile (                  {write characters to standard output}
      h,                               {handle to I/O stream}
      s.str,                           {output buffer}
      oleft,                           {number of bytes to write}
      olen,                            {number of bytes actually written}
      nil);                            {no overlap info supplied}
    if ok = win_bool_false_k then begin
      sys_error_none(stat);
      stat.sys := GetLastError;
      sys_error_abort (stat, '', '', nil, 0);
      sys_bomb;
      end;
    oleft := oleft - olen;             {make bytes left to output}
    end;                               {back to write out remaining bytes}

  discard( FlushFileBuffers(h) );      {make sure all output bytes actually sent}
  end;
