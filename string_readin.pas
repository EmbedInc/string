{   Procedure STRING_READIN (S)
*
*   Read the next line from standard input into string S.
*   All trailing blanks are deleted.
*
*   This is the Unix version of this routine.
}
module string_readin;
define string_readin;
%include 'string2.ins.pas';
%include 'string_sys.ins.pas';

procedure string_readin (              {read and unpad next line from standard input}
  in out  s: univ string_var_arg_t);   {output string}

var
  c: char;                             {scratch character}
  n: sys_int_adr_t;                    {number of characters actually read in}
  nblanks: sys_int_machine_t;          {number of blanks read but not written}

label
  next_char;

begin
  s.len := 0;                          {init output buffer to empty}
  nblanks := 0;                        {init to no pending blanks saved up}

next_char:                             {back here each new character to read}
  n := read(                           {read next char from file}
    sys_sys_iounit_stdin_k,            {stream ID for standard input}
    c,                                 {output data buffer}
    1);                                {number of chars to try to read}
  sys_sys_err_abort ('string', 'err_readin', nil, 0, n); {check for hard error}
  if n = 0 then return;                {hit end of file ?}
  if ord(c) = end_of_line then return; {this was the end of line character ?}
  if c = ' '
    then begin                         {this is a blank ?}
      nblanks := nblanks + 1;          {count one more consecutive blank}
      end
    else begin                         {this is a non-blank character ?}
      while nblanks > 0 do begin       {loop to write all pending blanks}
        string_append1 (s, ' ');
        nblanks := nblanks - 1;
        end;
      string_append1 (s, c);           {write new character to end of string}
      end
    ;
  goto next_char;                      {back and read next character from file}
  end;
