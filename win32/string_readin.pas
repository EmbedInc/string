{   Procedure STRING_READIN (S)
*
*   Read the next line from standard input into string S.
*   All trailing blanks are deleted.
*
*   This version is for the Microsoft Win32 API.
}
module string_readin;
define string_readin;
%include 'string2.ins.pas';
%include 'string_sys.ins.pas';

const
  bufsz = 1024;                        {max bytes the input buffer can hold}
  buflast = bufsz - 1;                 {last valid BUF array index}

var
  buf: array[0..buflast] of int8u_t;   {buffer of previously-read bytes}
  nbuf: sys_int_machine_t := 0;        {number of bytes in BUF}
  bufnext: sys_int_machine_t;          {index of next byte to read from buffer}

procedure string_readin (              {read and unpad next line from standard input}
  in out  s: univ string_var_arg_t);   {output string}

const
  max_msg_parms = 1;                   {max parameters we can pass to a message}
  cr = chr(13);                        {carriage return character}

var
  h: win_handle_t;                     {handle to system I/O connection}
  c: char;                             {scratch character}
  n: win_dword_t;                      {number of characters actually read in}
  nblanks: sys_int_machine_t;          {number of blanks read but not written}
  ok: win_bool_t;                      {not WIN_BOOL_FALSE_K on system call success}
  ovl: overlap_t;                      {state used during overlapped I/O}
  msg_parm:                            {parameter references for messages}
    array[1..max_msg_parms] of sys_parm_msg_t;
  stat: sys_err_t;

label
  abort_winerr, next_char, leave;

begin
  sys_error_none (stat);               {init STAT to indicate no error}

  h := GetStdHandle (stdstream_in_k);  {get handle to standard input I/O connection}
  if h = handle_invalid_k then begin
    sys_msg_parm_int (msg_parm[1], stdstream_in_k);
    sys_sys_error_bomb ('file', 'open_stream', msg_parm, 1);
    end;

  ovl.offset := 0;
  ovl.offset_high := 0;
  ovl.event_h := CreateEventA (        {create event for overalpped I/O}
    nil,                               {no security attributes supplied}
    win_bool_true_k,                   {no automatic event reset on successful wait}
    win_bool_false_k,                  {init event to not triggered}
    nil);                              {no name supplied}
  if ovl.event_h = handle_none_k then begin {error creating event ?}
abort_winerr:
    stat.sys := GetLastError;
    sys_error_abort (stat, '', '', nil, 0);
    sys_bomb;
    end;

  s.len := 0;                          {init output buffer to empty}
  nblanks := 0;                        {init to no pending blanks saved up}

next_char:                             {back here each new character to read}
  while nbuf = 0 do begin              {wait for something to be read into the buffer}
    ok := ReadFile (                   {try to read another chunk into the buffer}
      h,                               {system I/O connection handle}
      buf,                             {input buffer}
      bufsz,                           {number of bytes to read}
      n,                               {number of bytes actually read in}
      addr(ovl));                      {pointer to overlapped I/O state}
    if ok = win_bool_false_k then begin {system call failed ?}
      if GetLastError <> err_io_pending_k then begin {hard error ?}
        sys_sys_error_bomb ('string', 'err_readin', nil, 0);
        end;
      ok := GetOverlappedResult (      {wait for I/O to complete}
        h,                             {handle that I/O is pending on}
        ovl,                           {overlapped I/O state}
        n,                             {number of bytes transferred}
        win_bool_true_k);              {wait for I/O to complete}
      if ok = win_bool_false_k then goto abort_winerr;
      end;
    if n = 0 then goto leave;          {hit end of file ?}
    nbuf := n;                         {update number of bytes now in the buffer}
    bufnext := 0;                      {init index of next byte to read from buffer}
    end;

  c := chr(buf[bufnext]);              {fetch this byte from the buffer}
  bufnext := bufnext + 1;              {advance the buffer read index}
  nbuf := nbuf - 1;                    {count one less byte in the buffer}

  if ord(c) = end_of_line then goto leave; {hit end of line character ?}

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

leave:                                 {common exit point}
  discard( CloseHandle(ovl.event_h) ); {deallocate I/O completion event}
  if (s.len > 0) and (s.str[s.len] = cr) then begin {string ends with CR ?}
    s.len := s.len - 1;                {truncate trailing CR character}
    end;
  end;
