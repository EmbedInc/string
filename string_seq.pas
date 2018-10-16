{   Routines that handle sequential numbers, like could be used for serial
*   numbers.
*
*   The format of serial number files is described in the SEQUENCE documentation
*   file.
}
module string_seq;
define string_seq_get;
define string_seq_set;
%include 'string2.ins.pas';
%include 'file.ins.pas';
{
********************************************************************************
*
*   Local function STRING_SEQ_READ (FNAM, DEF, EXISTED, CONN, STAT)
*
*   Open a sequence file for exclusive acces and returns the existing sequence
*   number.  FNAM is the sequence file name.  The ".seq" filel name suffix may
*   be omitted in FNAM.  DEF is the default sequence number to report if the
*   sequence file did not previously exist.  EXISTED is returned TRUE if the
*   file previously existed and false otherwise.  If the file did not previously
*   exist then a empty file is created.  The DEF value is not written to the
*   file, only used as the function value when the file did not previously exist
*   or was empty.  On success, CONN is returned the connection to the file.  The
*   file will be open for binary read and write.
*
*   The file is left open with exclusive access to this process.  The subroutine
*   STRING_SEQ_WRITE can be used to update the sequence number and close the
*   file.
}
function string_seq_read (             {read sequence file and leave open}
  in      fnam: univ string_var_arg_t; {sequential number file name, ".seq" optional}
  in      def: sys_int_max_t;          {default seq number when file not exist or empty}
  out     existed: boolean;            {file previously existed and was non-empty}
  out     conn: file_conn_t;           {returned connection to the sequence file}
  out     stat: sys_err_t)             {returned completion status}
  :sys_int_max_t;                      {sequence number from file}
  val_param;

const
  retry_sec = 0.100;                   {seconds to wait between retries when file busy}
  retry_max = 300;                     {maximum number of times to try until give up}

var
  ntry: sys_int_machine_t;             {number of attempts to open serial number file}
  tk: string_var80_t;                  {serial number file string}
  p: string_index_t;                   {scratch string index}
  sz: sys_int_adr_t;                   {scratch memory size}
  seq: sys_int_max_t;                  {original sequence number}

label
  retry, abort;

begin
  tk.max := size_char(tk.str);         {init local var string}

  string_seq_read := def;              {init to return default value}
  existed := false;                    {init to file didn't previously exist or was empty}
  ntry := 0;                           {init number of attempts to open serial file}

retry:                                 {back here if serial number file busy}
  file_open_bin (                      {try to open serial number file}
    fnam, '.seq'(0),                   {file name}
    [file_rw_read_k, file_rw_write_k], {open for both read and write access}
    conn,                              {returned connection to the file}
    stat);
  if file_inuse(stat) then begin       {file is in use ?}
    ntry := ntry + 1;                  {count one more attempt to open file}
    if ntry > retry_max then begin     {return with in use status}
      sys_stat_set (file_subsys_k, file_stat_inuse_k, stat);
      sys_stat_parm_vstr (conn.tnam, stat);
      return;
      end;
    sys_wait (retry_sec);              {wait a little while}
    goto retry;                        {back and try again}
    end;
  if sys_error(stat) then return;      {hard error ?}

  file_read_bin (conn, sizeof(tk.str), tk.str, sz, stat); {read the serial num file}
  discard( file_eof(stat) );           {empty file is not error}
  discard( file_eof_partial(stat) );   {end of file before end of TK is not error}
  if sys_error(stat) then goto abort;  {hard error ?}

  tk.len := (sz * sys_bits_adr_k) div sys_bits_char_k; {set character string length}
  for p := 1 to tk.len do begin        {scan forwards thru string}
    if ord(tk.str[p]) >= 32 then next; {this is not a control character ?}
    tk.len := p - 1;                   {truncate string before this control char}
    exit;                              {no point looking further}
    end;

  if tk.len = 0 then begin             {file empty or didn't previously exist ?}
    return;
    end;

  string_t_int_max (tk, seq, stat);    {convert string to integer representation}
  if sys_error(stat) then goto abort;
  string_seq_read := seq;              {pass back current sequence number}
  existed := true;                     {indicate file previously existed}
  return;

abort:                                 {exit point with file open, STAT already set}
  file_close (conn);
  end;
{
********************************************************************************
*
*   Local subroutine STRING_SEQ_WRITE (CONN, SEQ, STAT)
*
*   Write the sequence number SEQ to the file open on CONN, and close the file.
*   The file is assumed to be open for binary read and write exclusive to this
*   process.  The file is intended to be opened with STRING_SEQ_READ.
}
procedure string_seq_write (           {write seq number to file, close the file}
  in out  conn: file_conn_t;           {connection to file, returned closed}
  in      seq: sys_int_max_t;          {sequence number to write to the file}
  out     stat: sys_err_t);            {returned completion status}
  val_param;

var
  tk: string_var80_t;                  {serial number file string}
  sz: sys_int_adr_t;                   {memory size}

label
  abort;

begin
  tk.max := size_char(tk.str);         {init local var string}

  string_f_int_max (tk, seq);          {make string from sequence number}
  file_pos_start (conn, stat);         {reset to start of serial number file}
  if sys_error(stat) then goto abort;
  string_append1 (tk, chr(13));        {add CRLF end of line sequence}
  string_append1 (tk, chr(10));
  sz :=                                {number of machine addresses to hold string}
    (tk.len * sys_bits_char_k + sys_bits_char_k - 1) div sys_bits_adr_k;
  file_write_bin (tk.str, conn, sz, stat); {write serial number to the file}
{
*   Common exit point.  If returninig with error, STAT must already be set to
*   indicate the error.
}
abort:
  file_close (conn);                   {close the file, let other processes use it}
  end;
{
********************************************************************************
*
*   Function STRING_SEQ_GET (FNAM, INCR, FIRST, FLAGS, STAT)
*
*   Read and update a sequence number file as one atomic operation.  The
*   function value is the original sequence number by default, and the new
*   sequence number if the STRING_SEQ_AFTER_K flag is in FLAGS.  INCR is added
*   to the original value, with the result written back to the file.  If the
*   file does not exist or is empty, then FIRST is used as the initial value.
*   The original value plus INCR is written to the file in all cases.  The file
*   will therefore always exist after this call.
}
function string_seq_get (              {get new unique sequential number}
  in      fnam: univ string_var_arg_t; {sequential number file name, ".seq" optional}
  in      incr: sys_int_max_t;         {amount to increment the sequence number by}
  in      first: sys_int_max_t;        {initial value if file not exist}
  in      flags: string_seq_t;         {modifier flags}
  out     stat: sys_err_t)             {returned completion status}
  :sys_int_max_t;                      {returned sequential number}
  val_param;

var
  conn: file_conn_t;                   {connection to the serial number file}
  seq: sys_int_max_t;                  {original sequence number}
  newseq: sys_int_max_t;               {new sequence number}
  existed: boolean;                    {sequence file previously existed}

begin
  string_seq_get := 0;                 {arbitrary value to return on error}
  seq := string_seq_read (             {read existing seq number, leave file open}
    fnam, first, existed, conn, stat);
  if sys_error(stat) then return;

  newseq := seq + incr;                {make new sequence number}
  if string_seq_after_k in flags
    then begin                         {return new sequence number}
      string_seq_get := newseq;
      end
    else begin                         {return original sequence number}
      string_seq_get := seq;
      end
    ;

  string_seq_write (conn, newseq, stat); {update sequence number in file, close file}
  end;
{
********************************************************************************
*
*   STRING_SEQ_SET (FNAM, NEWSEQ, COND, RESULT, STAT)
*
*   Set the sequence number in the sequence number file FNAM to the value
*   NEWSEQ, depending on the conditions in COND.  The sequence number file is
*   created if it does not exist.  COND is a set of flags indicating conditions
*   under which the sequence number should be changed.  The conditions for all
*   specified flags must be true for the sequence number to be set to NEWSEQ.
*   When no flags are specified, the sequence number is always set.  The
*   individual COND flags are:
*
*     FLAG_SEQCOND_GT_K  -  Only update if NEWSEQ is greater than the current
*       sequence number.
*
*     FLAG_SEQCOND_LT_K  -  Only update if NEWSEQ is less than the current
*       sequence number.
*
*   RESULT is retuned the final sequence number in the sequence number file.
}
procedure string_seq_set (             {set sequence number to new value}
  in      fnam: univ string_var_arg_t; {sequence number file name, ".seq" optional}
  in      newseq: sys_int_max_t;       {new sequence number to set to}
  in      cond: string_seqcond_t;      {optional set of condition flags}
  out     result: sys_int_max_t;       {final resulting sequence number}
  out     stat: sys_err_t);            {returned completion status}
  val_param;

var
  conn: file_conn_t;                   {connection to sequence number file}
  seq: sys_int_max_t;                  {original sequence number}
  existed: boolean;                    {sequence number file previously existed}

label
  update, noupdate;

begin
  seq :=                               {read sequence file and leave open}
    string_seq_read (fnam, newseq, existed, conn, stat);
  result := seq;                       {init to result is original value}
  if sys_error(stat) then return;

  if not existed then goto update;     {always write if file just created}
  if string_seqcond_gt_k in cond then begin
    if newseq <= seq then goto noupdate;
    end;
  if string_seqcond_lt_k in cond then begin
    if newseq >= seq then goto noupdate;
    end;

update:                                {write the new sequence number}
  string_seq_write (conn, newseq, stat); {write new sequence number, close file}
  result := newseq;
  return;

noupdate:                              {don't update sequence number in file}
  file_close (conn);                   {close the sequence number file}
  end;
