{   Routines for manipulating first-in first-out (FIFO) queues.
}
module string_fifo;
define string_fifo_create;
define string_fifo_delete;
define string_fifo_get;
define string_fifo_nempty;
define string_fifo_nfull;
define string_fifo_put;
define string_fifo_putbuf;
define string_fifo_reset;
define string_fifo_lock;
define string_fifo_unlock;
%include 'string2.ins.pas';
{
********************************************************************************
*
*   Subroutine STRING_FIFO_CREATE (MEM, MAXBYTES, FIFO_P)
*
*   Create and initialize a new FIFO.  MEM is the memory context under which any
*   new memory will be allocated.  The FIFO will be configured to be able to
*   hold at least MAXBYTES bytes.  FIFO_P is returned pointing to the new FIFO.
*   The FIFO will be initialized to empty.
}
procedure string_fifo_create (         {create a first in first out (FIFO) byte queue}
  in out  mem: util_mem_context_t;     {context to allocate new memory under}
  in      maxbytes: sys_int_adr_t;     {max bytes the FIFO will be able to hold}
  out     fifo_p: string_fifo_p_t);    {returned pointer to the FIFO}
  val_param;

var
  sz: sys_int_adr_t;                   {total size of the structure}
  maxb: sys_int_adr_t;                 {actual size to configure FIFO to}
  stat: sys_err_t;

begin
  maxb := max(maxbytes, 4);            {make actual bytes FIFO can hold}
  sz := offset(fifo_p^.buf) + maxb*sizeof(fifo_p^.buf[0]); {total memory needed}
  util_mem_grab (sz, mem, true, fifo_p); {allocate memory for the FIFO}

  fifo_p^.mem_p := addr(mem);          {pointer to parent memory context}
  fifo_p^.size := maxb;                {number of bytes the FIFO can hold}
  sys_thread_lock_create (fifo_p^.lock, stat); {create multi-thread interlock}
  sys_error_abort (stat, '', '', nil, 0);
  sys_event_create_bool (fifo_p^.ev_avail); {event to signal when FIFO not empty}
  sys_event_create_bool (fifo_p^.ev_nfull); {event to signal when FIFO not full}
  fifo_p^.nbytes := 0;                 {init the FIFO to empty}
  fifo_p^.putind := 0;                 {init index to write next byte at}
  fifo_p^.getind := 0;                 {init index to read next byte from}

  sys_event_notify_bool (fifo_p^.ev_nfull); {indicate the FIFO is not full now}
  end;
{
********************************************************************************
*
*   Subroutine STRING_FIFO_DELETE (FIFO_P)
*
*   Delete the FIFO pointed to by FIFO_P and deallocate all associated system
*   resources.  FIFO_P will be returned NIL.
}
procedure string_fifo_delete (         {delete FIFO and all its system resources}
  in out  fifo_p: string_fifo_p_t);    {pointer to the FIFO, returned NIL}
  val_param;

var
  mem_p: util_mem_context_p_t;         {points to parent memory context}
  stat: sys_err_t;

begin
  sys_event_del_bool (fifo_p^.ev_avail); {delete the events}
  sys_event_del_bool (fifo_p^.ev_nfull);
  sys_thread_lock_delete (fifo_p^.lock, stat); {delete the multi-thread interlock}

  mem_p := fifo_p^.mem_p;              {get pointer to mem context}
  util_mem_ungrab (fifo_p, mem_p^);    {deallocate the FIFO memory}
  end;
{
********************************************************************************
*
*   Function STRING_FIFO_GET (FIFO)
*
*   Get the next byte from the FIFO.  If no byte is immediately available (the
*   FIFO is empty), then this routine will wait efficiently until a byte is
*   available.
}
function string_fifo_get (             {get next byte from FIFO, blocks until available}
  in out  fifo: string_fifo_t)         {the FIFO}
  :sys_int_machine_t;                  {0-255 byte value}
  val_param;

var
  stat: sys_err_t;

begin
  while true do begin                  {back here each new attempt to get a byte}
    sys_event_wait (fifo.ev_avail, stat); {wait for byte to become available}
    sys_thread_lock_enter (fifo.lock); {start single threaded access}

    if fifo.nbytes > 0 then begin      {a byte really is available ?}
      string_fifo_get := fifo.buf[fifo.getind]; {get the next byte}
      fifo.getind := fifo.getind + 1;  {bump the read index}
      if fifo.getind >= fifo.size then fifo.getind := 0; {wrap back to buf start}
      fifo.nbytes := fifo.nbytes - 1;  {count one less byte in the FIFO}
      if fifo.nbytes > 0 then begin    {still at least another byte available ?}
        sys_event_notify_bool (fifo.ev_avail);
        end;
      sys_event_notify_bool (fifo.ev_nfull); {FIFO is definitely not full now}
      sys_thread_lock_leave (fifo.lock); {end single threaded access to FIFO}
      return;
      end;

    sys_thread_lock_leave (fifo.lock); {release lock on FIFO}
    end;                               {back to try again}
  end;
{
********************************************************************************
*
*   Function STRING_FIFO_NEMPTY (FIFO)
*
*   Returns the number of new bytes that can fit into the FIFO.  This is the
*   number of bytes that can be written to the FIFO immediately without waiting.
}
function string_fifo_nempty (          {returns how much room is in a FIFO}
  in out  fifo: string_fifo_t)         {the FIFO}
  :sys_int_adr_t;                      {number of additional bytes that can be written}
  val_param;

begin
  sys_thread_lock_enter (fifo.lock);   {start single threaded access}
  string_fifo_nempty := fifo.size - fifo.nbytes;
  sys_thread_lock_leave (fifo.lock);   {release lock on FIFO}
  end;
{
********************************************************************************
*
*   Function STRING_FIFO_NFULL (FIFO)
*
*   Returns the number of bytes in the FIFO.  This is the number of bytes that
*   can be read immediately without waiting.
}
function string_fifo_nfull (           {returns number of bytes in a FIFO}
  in out  fifo: string_fifo_t)         {the FIFO}
  :sys_int_adr_t;                      {number of bytes available to read immediately}
  val_param;

begin
  sys_thread_lock_enter (fifo.lock);   {start single threaded access}
  string_fifo_nfull := fifo.nbytes;
  sys_thread_lock_leave (fifo.lock);   {release lock on FIFO}
  end;
{
********************************************************************************
*
*   Subroutine STRING_FIFO_PUT (FIFO, B)
*
*   Write the byte B to the FIFO.  If there is no room in the FIFO, then this
*   routine waits efficiently until there is.
}
procedure string_fifo_put (            {write byte to FIFO, blocks until room}
  in out  fifo: string_fifo_t;         {the FIFO}
  in      b: int8u_t);                 {the byte to write}
  val_param;

var
  stat: sys_err_t;

label
  retry;

begin
retry:
  sys_thread_lock_enter (fifo.lock);   {start single threaded access}
  if fifo.nbytes >= fifo.size then begin {the FIFO is full ?}
    sys_thread_lock_leave (fifo.lock); {release lock on the FIFO}
    sys_event_wait (fifo.ev_nfull, stat); {wait for room in the FIFO}
    goto retry;
    end;

  fifo.buf[fifo.putind] := b;          {stuff this byte into the buffer}
  fifo.putind := fifo.putind + 1;      {bump the write index}
  if fifo.putind >= fifo.size then fifo.putind := 0; {wrap back to buf start}
  fifo.nbytes := fifo.nbytes + 1;      {count one more byte in the FIFO}
  if fifo.nbytes < fifo.size then begin {still not full ?}
    sys_event_notify_bool (fifo.ev_nfull);
    end;
  sys_event_notify_bool (fifo.ev_avail); {a byte is definitely available now}
  sys_thread_lock_leave (fifo.lock);   {end single threaded access to FIFO}
  end;
{
********************************************************************************
*
*   Subroutine STRING_FIFO_PUTBUF (FIFO, BUF, N)
*
*   Write the N sequential bytes from the buffer BUF into the FIFO.  This
*   routine blocks until all bytes are written.
}
procedure string_fifo_putbuf (         {write buffer of bytes to FIFO, blocks}
  in out  fifo: string_fifo_t;         {the FIFO}
  in      buf: univ string_bytebuf_t;  {buffer of bytes to write}
  in      n: sys_int_machine_t);       {number of bytes to write starting with BUF[0]}
  val_param;

var
  nleft: sys_int_machine_t;            {number of bytes left to write}
  bufind: sys_int_machine_t;           {BUF index to get next byte from}
  nchunk: sys_int_machine_t;           {number of bytes left in current chunk}
  ii: sys_int_machine_t;               {scratch loop counter}
  stat: sys_err_t;

label
  retry;

begin
  if n <= 0 then return;               {nothing to do ?}
  bufind := 0;                         {init BUF index to get next byte from}
  nleft := n;                          {init number of bytes left to copy}

retry:                                 {back here to try another chunk of bytes}
  sys_thread_lock_enter (fifo.lock);   {acquire exclusive access to the FIFO}
  nchunk := min(nleft, fifo.size - fifo.nbytes); {size of chunk to copy this time}
  if nchunk > 0 then begin             {can copy at least one byte now ?}
    for ii := 1 to nchunk do begin     {back here each byte of this chunk}
      fifo.buf[fifo.putind] := buf[bufind]; {copy this byte into the FIFO}
      bufind := bufind + 1;            {bump the source buffer index}
      fifo.putind := fifo.putind + 1;  {bump the write index}
      if fifo.putind >= fifo.size then fifo.putind := 0; {wrap back to buf start}
      end;                             {back to copy next byte}
    fifo.nbytes := fifo.nbytes + nchunk; {update number of bytes in the FIFO}
    nleft := nleft - nchunk;           {update number of bytes left to do}
    sys_event_notify_bool (fifo.ev_avail); {a byte is definitely available now}
    if fifo.nbytes < fifo.size then begin {still not full ?}
      sys_event_notify_bool (fifo.ev_nfull);
      end;
    end;
  sys_thread_lock_leave (fifo.lock);   {release lock on the FIFO}

  if nleft <= 0 then return;           {all done ?}
  sys_event_wait (fifo.ev_nfull, stat); {wait for room in FIFO indication}
  goto retry;                          {go back and try to write another chunk}
  end;                                 {back to try to write next chunk}
{
********************************************************************************
*
*   Subroutine STRING_FIFO_RESET (FIFO)
*
*   Reset the FIFO to empty.  Any data currently in the FIFO will be lost.
}
procedure string_fifo_reset (          {reset a FIFO to empty, existing data discarded}
  in out  fifo: string_fifo_t);        {the FIFO to reset}
  val_param;

begin
  sys_thread_lock_enter (fifo.lock);   {start single threaded access}
  fifo.nbytes := 0;                    {indicate FIFO is empty}
  fifo.putind := 0;                    {reset write index}
  fifo.getind := 0;                    {reset read index}
  sys_event_notify_bool (fifo.ev_nfull); {the FIFO is definitely not full now}
  sys_thread_lock_leave (fifo.lock);   {release lock on FIFO}
  end;
{
********************************************************************************
*
*   Subroutine STRING_FIFO_LOCK (FIFO)
*
*   Acquire exclusive access to the FIFO structure.  This prevents other threads
*   from accessing it if they all also lock the FIFO before accessing it.  All
*   the routines here lock the FIFO before access, and are therefore
*   multi-thread safe.
*
*   Applications should generally not access fields in the FIFO directly.  This
*   routine may be useful to protect other data that is associated with the
*   FIFO.  However, FIFO accesses will be held off until the lock is realeased.
}
procedure string_fifo_lock (           {acquire exclusive access to a FIFO}
  in out  fifo: string_fifo_t);        {the FIFO}
  val_param;

begin
  sys_thread_lock_enter (fifo.lock);
  end;
{
********************************************************************************
*
*   Subroutine STRING_FIFO_UNLOCK (FIFO)
*
*   Release the exclusive lock on the FIFO that was acquired with
*   STRING_FIFO_LOCK.
}
procedure string_fifo_unlock (         {release exclusive access to a FIFO}
  in out  fifo: string_fifo_t);        {the FIFO}
  val_param;

begin
  sys_thread_lock_leave (fifo.lock);
  end;
