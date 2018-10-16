{   Subroutines for manipulating an ordered list of strings.  A data structure
*   of type STRING_LIST_T is used to maintain state associated with
*   the list of strings.
}
module string_list;
define string_list_copy;
define string_list_init;
define string_list_kill;
define string_list_line_add;
define string_list_str_add;
define string_list_line_del;
define string_list_pos_abs;
define string_list_pos_last;
define string_list_pos_rel;
define string_list_pos_start;
define string_list_trunc;
define string_list_sort;
%include 'string2.ins.pas';
{
********************************************************************************
*
*   Subroutine STRING_LIST_COPY (LIST1, LIST2, MEM)
*
*   Copy all the data from strings list LIST1 to LIST2.  Data is completely
*   copied instead of just referenced.  This subroutine can be used to make a
*   local copy of a strings list so that it can be modified without effecting
*   the original.  It is assumed that LIST2 has NOT been initialized.  If it has
*   been, then STRING_LIST_KILL should be used to deallocate any resources tied
*   up by LIST2 before being used here.  The previous contents of LIST2 is
*   completely lost.  MEM is the parent memory context to use.  A new memory
*   context will be created under MEM, and will be used to allocate any dynamic
*   memory needed.  No state is altered in LIST1.  LIST2 is left positioned at
*   line zero, which is just before the first line in the list.
}
procedure string_list_copy (           {make separate copy of a strings list}
  in      list1: string_list_t;        {handle to input strings list}
  out     list2: string_list_t;        {handle to output strings list}
  in out  mem: util_mem_context_t);    {parent memory context to use}

var
  ent_p: string_chain_ent_p_t;         {pointer to current source chain entry}

begin
  string_list_init (list2, mem);       {init output string lists handle}
  list2.deallocable := list1.deallocable;
  ent_p := list1.first_p;              {point to first input chain entry}

  while ent_p <> nil do begin          {once for each string to copy}
    list2.size := ent_p^.s.max;        {set desired size of this string}
    string_list_line_add (list2);      {create new empty line in output list}
    string_copy (ent_p^.s, list2.str_p^); {copy string from in list to out list}
    ent_p := ent_p^.next_p;            {advance to next input chain entry}
    end;

  list2.size := list1.size;            {set to default size from input list}
  end;
{
********************************************************************************
*
*   Subroutine STRING_LIST_INIT (LIST, MEM)
*
*   Initialize a strings list.  This MUST be done before the strings list is
*   manipulated in any other way.  LIST is the control data block for the
*   strings list.  MEM is the parent memory context to use.  A subordinate
*   memory context will be created internally, and any dynamic memory will be
*   allocated under it.  This subordinate memory context is deleted when the
*   strings list is killed (using the STRING_LIST_KILL subroutine).
*
*   The strings list will be initialized to empty, and the current line number
*   will be set to 0, meaning before the first line.
}
procedure string_list_init (           {init a STRING_LIST_T data structure}
  out     list: string_list_t;         {control block for string list to initialize}
  in out  mem: util_mem_context_t);    {parent memory context to use}

begin
  list.size := 132;
  list.deallocable := true;
  list.n := 0;
  list.curr := 0;
  list.str_p := nil;
  list.first_p := nil;
  list.last_p := nil;
  list.ent_p := nil;
  util_mem_context_get (mem, list.mem_p); {create memory context for any new mem}
  end;
{
********************************************************************************
*
*   Subroutine STRING_LIST_KILL (LIST)
*
*   "Delete" a strings list and deallocate any resources it may have tied up.
*   The only valid operation on the strings list LIST after this call is INIT.
}
procedure string_list_kill (           {delete string, deallocate resources}
  in out  list: string_list_t);        {must be initialized before next use}

begin
  list.n := 0;
  list.curr := 0;
  list.str_p := nil;
  list.first_p := nil;
  list.last_p := nil;
  list.ent_p := nil;
  util_mem_context_del (list.mem_p);   {delete strings and our memory context}
  end;
{
********************************************************************************
*
*   Subroutine STRING_LIST_LINE_ADD (LIST)
*
*   Insert a new line to the strings list directly after the current line.  The
*   new line will be made the current line.
}
procedure string_list_line_add (       {insert new line after curr and make it curr}
  in out  list: string_list_t);        {strings list control block}

const
  max_msg_parms = 2;                   {max parameters we can pass to a message}

var
  ent_p: string_chain_ent_p_t;         {pointer to new chain entry}
  size: sys_int_adr_t;                 {amount of memory needed for new string}
  msg_parm:                            {parameter references for messages}
    array[1..max_msg_parms] of sys_parm_msg_t;

begin
  if list.curr > list.n then begin     {on a virtual line past end of list ?}
    sys_msg_parm_int (msg_parm[1], list.curr);
    sys_msg_parm_int (msg_parm[2], list.n);
    sys_message_bomb ('string', 'list_add_past_end', msg_parm, 2);
    end;

  size := sizeof(ent_p^) - sizeof(ent_p^.s) + {amount of mem needed for new string}
    string_size(list.size);
  util_mem_grab (size, list.mem_p^, list.deallocable, ent_p); {grab mem for new line}
  ent_p^.s.max := list.size;           {init new string to empty}
  ent_p^.s.len := 0;
  ent_p^.prev_p := list.ent_p;         {point new entry to predecessor}

  if list.ent_p = nil
    then begin                         {there is no previous line ?}
      ent_p^.next_p := list.first_p;
      list.first_p := ent_p;
      end
    else begin                         {there is at least one previous line}
      ent_p^.next_p := list.ent_p^.next_p; {point new entry to successor}
      end
    ;

  if ent_p^.next_p <> nil
    then begin                         {there IS a successor line}
      ent_p^.next_p^.prev_p := ent_p;
      end
    else begin                         {there is NO successor line}
      list.last_p := ent_p;
      end
    ;

  if ent_p^.prev_p <> nil
    then begin                         {there IS a previous line}
      ent_p^.prev_p^.next_p := ent_p;
      end
    else begin                         {there is NOT a previous line}
      list.first_p := ent_p;
      end
    ;

  list.n := list.n + 1;                {one more line in this list}
  list.curr := list.curr + 1;          {indicate new line is current}
  list.ent_p := ent_p;                 {set pointer to new current line}
  list.str_p := univ_ptr(addr(list.ent_p^.s)); {set address of current line}
  end;
{
********************************************************************************
*
*   Subroutine STRING_LIST_STR_ADD (LIST, STR)
*
*   Add a complete string to the list LIST.  A new line will be created after
*   the current line, then made current.  The length of the new line will be the
*   length of STR, and its contents will be copied from STR.
}
procedure string_list_str_add (        {add new string after curr, make curr}
  in out  list: string_list_t;         {list to add entry to}
  in      str: univ string_var_arg_t); {string to set entry to, will be this size}
  val_param;

begin
  list.size := str.len;                {set size to make new list entries}
  string_list_line_add (list);         {create new list entry, make it current}
  string_copy (str, list.str_p^);      {initialize the new line with the string STR}
  end;
{
********************************************************************************
*
*   Subroutine STRING_LIST_LINE_DEL (LIST, FORWARD)
*
*   Delete the current line in the strings list LIST.  If FORWARD is TRUE, then
*   the new current line becomes the line after the one deleted, otherwise it
*   becomes the line before the one deleted.  This routine has no effect if the
*   current line does not exist.
*
*   The line is always removed from the list, but the memory is only released if
*   DEALLOCABLE is set to TRUE.
}
procedure string_list_line_del (       {delete curr line in strings list}
  in out  list: string_list_t;         {strings list control block}
  in      forward: boolean);           {TRUE makes next line curr, FALSE previous}
  val_param;

var
  old_ent_p: string_chain_ent_p_t;     {saved pointer to old list entry}
  fwd: boolean;                        {TRUE if really go forward}

begin
  if list.ent_p = nil then return;     {nothing to delete ?}
  old_ent_p := list.ent_p;             {save pointer to entry that will be deleted}
  fwd := forward;                      {init direction for new current line}

  if list.ent_p^.prev_p = nil
    then begin                         {deleting first line in list}
      list.first_p := list.ent_p^.next_p;
      end
    else begin                         {there is a previous line}
      list.ent_p^.prev_p^.next_p := list.ent_p^.next_p;
      end
    ;
  if list.ent_p^.next_p = nil
    then begin                         {deleting last line in list}
      list.last_p := list.ent_p^.prev_p;
      fwd := false;                    {definately not making following line current}
      end
    else begin                         {there is a following line}
      list.ent_p^.next_p^.prev_p := list.ent_p^.prev_p;
      end
    ;
  if fwd
    then begin                         {following line is new current line}
      list.ent_p := list.ent_p^.next_p;
      end
    else begin                         {previous line is new current line}
      list.ent_p := list.ent_p^.prev_p;
      list.curr := list.curr - 1;      {line number of new current line}
      end
    ;
  if list.ent_p = nil
    then begin                         {we are before first line}
      list.str_p := nil;               {indicate no current line}
      end
    else begin                         {we are at a real line}
      list.str_p := univ_ptr(addr(list.ent_p^.s));
      end
    ;
  list.n := list.n - 1;                {one less line in list}

  if list.deallocable then begin       {lines can be individually deallocated ?}
    util_mem_ungrab (old_ent_p, list.mem_p^); {deallocate mem for deleted line}
    end;
  end;
{
********************************************************************************
*
*   Subroutine STRING_LIST_POS_ABS (LIST, N)
*
*   Position to the absolute line number N in the strings list LIST.  The first
*   line is numbered 1.  It is possible to be at "line" 0.  This is really the
*   position before the first line.  It is permissible to position to a line
*   past the end of the list.  In that case STR_P will be NIL, but CURR will
*   indicate the number of the line, if it existed.
}
procedure string_list_pos_abs (        {set new current line number in strings list}
  in out  list: string_list_t;         {strings list control block}
  in      n: sys_int_machine_t);       {number of new current line, first = 1}
  val_param;

const
  max_msg_parms = 1;                   {max parameters we can pass to a message}

var
  i: sys_int_machine_t;                {loop counter}
  msg_parm:                            {parameter references for messages}
    array[1..max_msg_parms] of sys_parm_msg_t;

begin
  if n < 0 then begin                  {some idiot requested negative line number ?}
    sys_msg_parm_int (msg_parm[1], n);
    sys_message_bomb ('string', 'list_pos_negative', msg_parm, 1)
    end;

  if (n = 0) or (n > list.n) then begin {going to a non-existant line ?}
    list.curr := n;
    list.str_p := nil;
    list.ent_p := nil;
    return;
    end;

  list.ent_p := list.first_p;          {init to being at first line}
  for i := 2 to n do begin             {once for each time to advance one line}
    list.ent_p := list.ent_p^.next_p;  {advance to next line}
    end;

  list.curr := n;                      {indicate number of new current line}
  list.str_p := univ_ptr(addr(list.ent_p^.s));
  end;
{
********************************************************************************
*
*   Subroutine STRING_LIST_POS_LAST (LIST)
*
*   Set the current position in the strings list LIST to the last line.
}
procedure string_list_pos_last (       {position to last line, 0 if none there}
  in out  list: string_list_t);        {strings list control block}

begin
  if list.last_p = nil
    then begin                         {no lines exist}
      list.ent_p := nil;
      list.curr := 0;
      list.str_p := nil;
      end
    else begin                         {at least one line exists}
      list.ent_p := list.last_p;       {make last line current}
      list.curr := list.n;
      list.str_p := univ_ptr(addr(list.ent_p^.s));
      end
    ;
  end;
{
********************************************************************************
*
*   Subroutine STRING_LIST_POS_REL (LIST, N_FWD)
*
*   Move a relative position in the strings list LIST.  N_FWD is the number of
*   lines to move forward.  It may be negative to indicate moving towards the
*   start of the list.  If no line exists at the new position, then STR_P will
*   be NIL.  CURR will be the line number, if the line existed, except that CURR
*   will never be less than zero.
}
procedure string_list_pos_rel (        {move forward/backward in strings list}
  in out  list: string_list_t;         {strings list control block}
  in      n_fwd: sys_int_machine_t);   {lines to move forwards, may be negative}
  val_param;

var
  pos: sys_int_machine_t;              {actual position to move to}
  fwd: sys_int_machine_t;              {amount to really move}
  i: sys_int_machine_t;                {loop counter}

begin
  if list.first_p = nil then return;   {no lines exist, no place to move to ?}

  pos := max(0, list.curr + n_fwd);    {make number of new target line}

  if pos = 0 then begin                {going to before first line ?}
    list.curr := 0;                    {indicate new current position}
    list.ent_p := nil;
    list.str_p := nil;
    return;
    end;

  if pos > list.n then begin           {going to after last line ?}
    list.curr := pos;                  {indicate number of line if it existed}
    list.str_p := nil;                 {indicate no line here}
    list.ent_p := nil;
    return;
    end;
{
*   The target line really does exist, although we may not currently be on
*   a real line.
}
  fwd := pos - list.curr;              {number of lines to really move}
  if fwd >= 0
    then begin                         {moving forward}
      if list.ent_p = nil then begin   {not currently at a line ?}
        list.ent_p := list.first_p;    {start at first line}
        fwd := fwd - 1;                {one less line to go}
        end;
      for i := 1 to fwd do begin       {once for each line to move forward}
        list.ent_p := list.ent_p^.next_p;
        end;
      end
    else begin                         {moving backward}
      if list.ent_p = nil then begin   {not currently at a real line ?}
        list.ent_p := list.last_p;     {start at the last line}
        fwd := pos - list.n;           {update how many lines need to move}
        end;
      for i := -1 downto fwd do begin  {once for each line to move backward}
        list.ent_p := list.ent_p^.prev_p;
        end
      end
    ;

  list.curr := pos;                    {indicate number of new current line}
  list.str_p := univ_ptr(addr(list.ent_p^.s));
  end;
{
********************************************************************************
*
*   Subroutine STRING_LIST_POS_START (LIST)
*
*   Position to before the first line in the string list LIST.
}
procedure string_list_pos_start (      {position to before first line in list}
  in out  list: string_list_t);        {strings list control block}

begin
  list.curr := 0;
  list.str_p := nil;
  list.ent_p := nil;
  end;
{
********************************************************************************
*
*   Subroutine STRING_LIST_TRUNC (LIST)
*
*   Truncate the strings list LIST after the current line.  Note that if the
*   current position is before the first line (such as after a call to
*   STRING_LIST_POS_START), then this deletes all lines in the strings list.
*   This routine has no effect if positioned after the last line in the list.
}
procedure string_list_trunc (          {truncate strings list after current line}
  in out  list: string_list_t);        {strings list control block}

var
  ent_p: string_chain_ent_p_t;         {pointer to current chain entry}
  next_p: string_chain_ent_p_t;        {pointer to next chain entry after curr}

begin
  if list.curr >= list.n then return;  {no lines to delete ?}

  if list.ent_p = nil
    then begin                         {curr pos is before first line}
      ent_p := list.first_p;
      list.first_p := nil;             {there will be no first line}
      end
    else begin                         {curr pos is at a real line}
      ent_p := list.ent_p^.next_p;
      end
    ;                                  {ENT_P points to first entry to delete}
  if ent_p = nil then return;          {nothing to delete ?}
  if ent_p^.prev_p <> nil then begin   {there is a previous entry ?}
    ent_p^.prev_p^.next_p := nil;      {previous entry is now end of chain}
    end;

  while ent_p <> nil do begin          {once for each chain entry to delete}
    next_p := ent_p^.next_p;           {save address of next entry in chain}
    util_mem_ungrab (ent_p, list.mem_p^); {delete current chain entry}
    ent_p := next_p;                   {advance to next entry in chain}
    end;                               {back and process this new entry}

  list.n := list.curr;                 {current line is now last line}
  list.last_p := list.ent_p;
  end;
{
********************************************************************************
*
*   Subroutine STRING_LIST_SORT (LIST, OPTS)
*
*   Sorts the strings in the strings list LIST.  OPTS contains a set of option
*   flags that control the collating sequence.
}
procedure string_list_sort (           {sort strings in a strings list}
  in out  list: string_list_t;         {strings list control block}
  in      opts: string_comp_t);        {option flags for collating seqence, etc}
  val_param;

var
  start_p: string_chain_ent_p_t;       {pointer to current sort start entry}
  best_p: string_chain_ent_p_t;        {pointer to current best value found}
  curr_p: string_chain_ent_p_t;        {pointer to current entry being tested}

label
  loop;

begin
  start_p := list.first_p;             {init to starting with first list entry}

loop:                                  {outer loop}
  if start_p = nil then return;        {nothing left to sort ?}
  best_p := start_p;                   {init best found so far is first entry}
  curr_p := start_p^.next_p;           {init pointer to entry to compare to}
  while curr_p <> nil do begin         {once for each entry to compare to}
    if string_compare_opts (curr_p^.s, best_p^.s, opts) < 0 {found better entry ?}
        then begin
      best_p := curr_p;                {update pointer to best entry so far}
      end;
    curr_p := curr_p^.next_p;          {advance to next entry in list}
    end;                               {back to check out this new entry}
{
*   START_P is pointing to the entry to set this time.  BEST_P is pointing to the
*   entry that should be moved to just before START_P.
}
  if best_p = start_p then begin       {no need to move anything ?}
    start_p := start_p^.next_p;        {advance to next entry to start at}
    goto loop;
    end;
{
*   Remove the entry at BEST_P from the list.  This is guaranteed to never be the
*   first entry.
}
  best_p^.prev_p^.next_p := best_p^.next_p;
  if best_p^.next_p = nil
    then begin                         {removing last entry in the list}
      list.last_p := best_p^.prev_p;
      end
    else begin                         {removing not-last list entry}
      best_p^.next_p^.prev_p := best_p^.prev_p;
      end
    ;
{
*   Insert the entry at BEST_P immediately before the entry at START_P.
}
  best_p^.prev_p := start_p^.prev_p;
  best_p^.next_p := start_p;
  start_p^.prev_p := best_p;
  if best_p^.prev_p = nil
    then begin                         {inserting at start of list}
      list.first_p := best_p;
      end
    else begin                         {inserting at not-start of list}
      best_p^.prev_p^.next_p := best_p;
      end
    ;
  goto loop;                           {back for next pass thru remaining list}
  end;
