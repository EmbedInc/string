{   Subroutines that manage the hash tables.
}
module string_hash_subs;
define string_hash_create;
define string_hash_ent_add;
define string_hash_ent_atpos;
define string_hash_ent_del;
define string_hash_ent_lookup;
define string_hash_delete;
define string_hash_pos_first;
define string_hash_pos_lookup;
define string_hash_pos_next;
define string_hash_mem_alloc_del;
define string_hash_mem_alloc_ndel;
define string_hash_mem_dealloc;
%include 'string2.ins.pas';
%include 'math.ins.pas';

const
  int_size = sizeof(sys_int_machine_t);
{
********************************************************************************
*
*   Subrotuine STRING_HASH_CREATE (HASH_H, N_BUCK, NAME_LEN, DATA_SIZE, MEM)
*
*   Initialize a hash table.  HASH_H is the user handle for this hash table.  It
*   is only valid after this call.  The remaining call arguments are parameters
*   that are used to configure the hash table.  These can not be changed once
*   the hash table has been created.  A hash table remains valid until it is
*   deleted with a call to STRING_HASH_DELETE.  Configuration arguments are:
*
*   N_BUCK  -  Number of buckets in hash table.  This number will be rounded up
*     to the nearest power of two.  Actual entries are stored in the buckets.
*     The particular bucket an entry is in can be computed quickly from the entry
*     name using a hashing function (hence the name "hash table").  The time
*     to compute the bucket number is independent of the number of buckets.
*     Making this number large increases speed but also memory useage.
*
*   NAME_LEN  -  The maximum number of characters an entry name may have in this
*     hash table.  This number may be from 1 to STRING_HASH_MAX_NAME_LEN_K.
*
*   DATA_SIZE  -  The size of the user data area.  The application can get a
*     pointer to this area for each entry.  The area will be aligned on a
*     machine integer boundary, and the size will be rounded up to the nearest
*     whole multiple of machine integers.
*
*   FLAGS  -  Set of additional configuration modifier flags.  Flags are:
*
*     STRING_HASHCRE_MEMDIR_K - Use parent memory context directly.  No
*       separate memory context will be created for the hash table data
*       structures.
*
*     STRING_HASHCRE_NODEL_K - It is OK to allocate dynamic memory such that
*       it can't be individually deallocated.  This saves memory, but reduces
*       flexibility.
*
*   MEM  -  Parent memory context to use.  A subordinate memory context will be
*     created for this hash table, and all dynamic memory will be allocated under
*     it.  All memory allocated under that context will be released when the
*     hash table is deleted.
}
procedure string_hash_create (         {create a hash table}
  out     hash_h: string_hash_handle_t; {hash table to initialize}
  in      n_buck: sys_int_machine_t;   {number of entries in table, (power of 2)}
  in      name_len: sys_int_machine_t; {max allowed size of any entry name}
  in      data_size: sys_int_adr_t;    {amount of user data for each entry}
  in      flags: string_hashcre_t;     {additional modifier flags}
  in out  mem: util_mem_context_t);    {parent memory context to use for this table}
  val_param;

const
  max_msg_parms = 2;                   {max parameters we can pass to a message}

var
  ent: string_hash_entry_t;            {just for finding adr offsets}
  sz: sys_int_adr_t;                   {scratch memory size}
  hash_p: string_hash_p_t;             {pointer to hash table admin data structure}
  nb: sys_int_machine_t;               {actual number of buckets in hash table}
  mem_p: util_mem_context_p_t;         {pointer to mem context for hash table}
  seed: math_rand_seed_t;              {random number seed}
  date: string_var80_t;                {date/time string}
  i: sys_int_machine_t;                {loop counter}
  idel: boolean;                       {TRUE if alloc mem to individually dealloc}
  msg_parm:                            {parameter references for messages}
    array[1..max_msg_parms] of sys_parm_msg_t;

begin
  date.max := sizeof(date.str);        {init local var string}

  if name_len > string_hash_max_name_len_k then begin {requested name size too big ?}
    sys_msg_parm_int (msg_parm[1], name_len);
    sys_msg_parm_int (msg_parm[2], string_hash_max_name_len_k);
    sys_message_bomb ('string', 'hash_max_name_too_long', msg_parm, 2);
    end;

  nb := 1;                             {init to minimum number of buckets}
  while nb < n_buck do begin           {too small, make next power of two ?}
    nb := nb * 2;
    end;

  idel :=                              {alloc to allow individual dealloc ?}
    not (string_hashcre_nodel_k in flags);
  if string_hashcre_memdir_k in flags
    then begin                         {use parent memory context directly}
      mem_p := addr(mem);
      end
    else begin                         {create our own memory context}
      util_mem_context_get (           {allocate memory context for this hash table}
        mem,                           {parent memory context}
        mem_p);                        {returned pointer to new subordinate context}
      end
    ;

  sz :=                                {make size of top hash table structure}
    sizeof(string_hash_t) +            {raw size as declared}
    ((nb - 1) * sizeof(string_hash_bucket_t)); {additional buckets than declared}
  util_mem_grab (sz, mem_p^, idel, hash_p); {allocate hash table admin block}
  hash_h := hash_p;                    {pass back handle to new hash table}
  with hash_p^: hash do begin          {HASH is abbrev for hash table admin block}

    hash.n_buckets := nb;              {number of hash buckets, is 2**n}
    hash.mask := hash.n_buckets - 1;   {for masking in bucket number}
    hash.max_name_len := name_len;     {save max size for entry names}

    hash.data_offset :=                {size of our part of each entry}
      sizeof(ent) -                    {raw size as declared}
      sizeof(ent.name.str) +           {minus characters already declared}
      hash.max_name_len;               {plus number of characters actually used}
    hash.data_offset :=                {number of whole machine integers needed}
      (hash.data_offset + int_size - 1) div int_size;
    hash.data_offset :=                {final size of our part of an entry}
      hash.data_offset * int_size;
    sz :=                              {whole machine integers for user data}
      (data_size + int_size - 1) div int_size;
    hash.entry_size :=                 {size of an entire entry}
      hash.data_offset +               {amount of memory for our internal part}
      (sz * int_size);                 {amount of private user data}

    hash.free_p := nil;                {init to no free chain exists}
    hash.mem_p := mem_p;               {pointer to our memory context}
    hash.flags := flags;               {save configuration flags}

    sys_date_time1 (date);             {get date string for random number seed}
    seed.str := date.str;              {init random number seed}

    for i := 0 to 255 do begin         {once for each hash function entry}
      hash.func[i] := math_rand_int32(seed); {function is table of random values}
      end;

    for i := 0 to hash.n_buckets-1 do begin {once for each bucket descriptor}
      hash.bucket[i].first_p := nil;   {init this bucket descriptor to empty}
      hash.bucket[i].mid_p := nil;
      hash.bucket[i].last_p := nil;
      hash.bucket[i].n := 0;
      hash.bucket[i].n_after := 0;
      end;
    end;                               {done with HASH abbreviation}
  end;
{
**************************************************************************
*
*   Subroutine STRING_HASH_DELETE (HASH_H)
*
*   Delete a hash table.  HASH_H is the user handle to the hash table.  All
*   dynamic memory allocated under this hash table will be release.  HASH_H
*   will be returned as invalid.
}
procedure string_hash_delete (         {delete hash table, deallocate resources}
  in out  hash_h: string_hash_handle_t); {hash table to delete, returned invalid}
  val_param;

var
  mem_p: util_mem_context_p_t;         {points to memory context for this hash table}
  hash_p: string_hash_p_t;             {points to top data block for this hash table}

begin
  hash_p := hash_h;                    {get pointer to hash table admin block}
  if not (string_hashcre_memdir_k in hash_p^.flags) then begin {mem is ours ?}
    mem_p := hash_p^.mem_p;            {get pointer to memory context for this table}
    util_mem_context_del (mem_p);      {deallocate all memory for this hash table}
    end;
  hash_h := nil;                       {return hash table handle as invalid}
  end;
{
**************************************************************************
*
*   Subroutine STRING_HASH_POS_LOOKUP (HASH_H, NAME, POS, FOUND)
*
*   Look up a name in a hash table.  HASH_H is the user handle to the hash table.
*   NAME is the name to look up.  POS is returned as the user position handle to
*   the entry.  FOUND is set to TRUE if the entry is found.  In that case, POS
*   indicates the position of the entry itself.  If no entry exists of name NAME,
*   then FOUND is set to FALSE, and POS indicates the position where the entry
*   would go.  POS may then be passed to STRING_HASH_ENT_ADD to create the entry.
}
procedure string_hash_pos_lookup (     {return position handle from entry name}
  in      hash_h: string_hash_handle_t; {handle to hash table}
  in      name: univ string_var_arg_t; {name to find position for}
  out     pos: string_hash_pos_t;      {handle to position for this name}
  out     found: boolean);             {TRUE if entry existed}
  val_param;

var
  hash_p: string_hash_p_t;             {pointer to this hash table}
  buck: sys_int_machine_t;             {bucket number accumulator}
  i, j: sys_int_machine_t;             {loop counters and scratch integers}
  char_p: ^char;                       {pointer for saving name chars}
  forward, backward: boolean;          {search direction flags}

label
  search_loop, search_forward, search_backward;

begin
  hash_p := hash_h;                    {get pointer to hash table master block}
  pos.hash_p := hash_p;                {save pointer to this hash table}
  with hash_p^: hash do begin          {HASH is abbrev for top hash table block}
{
*   The hash function resulting in the bucket number for this name will be
*   computed at the same time that the name characters are copied into the
*   position handle.  This is because both require a loop over all the name
*   characters.  The name in the position handle will be zero padded to the
*   next whole number of machine integers.  This will allow comparing and
*   copying the name by using integer operations.
}
  buck := 0;                           {init bucket number hash accumulator}

  pos.name_len := name.len;            {save number of chars in entry name}
  pos.namei_len :=                     {number of whole machine integers in name}
    (pos.name_len + int_size - 1) div int_size;
  pos.namei[pos.namei_len] := 0;       {make sure odd chars filled with zeros}
  char_p := univ_ptr(                  {point to first destination name char}
    addr(pos.namei[1]));

  for i := 1 to name.len do begin      {once for each character in name}
    j := 255 & buck;                   {make hash function index value}
    buck := buck + hash.func[j] + ord(name.str[i]); {update hash accumulator}
    char_p^ := name.str[i];            {copy this character}
    char_p := univ_ptr(                {advance destination copy pointer}
      sys_int_adr_t(char_p) + sizeof(char_p^));
    end;
  buck := buck & hash.mask;            {make final bucket number for this name}
  pos.bucket := buck;                  {save bucket number in position handle}

  pos.after := true;                   {init to entry is at or after bucket midpoint}
  found := false;                      {init to entry of this name not found}
{
*   All fields in POS are set except the ones pointing to a particular entry.
*   Start at the middle entry for this bucket and then search in either direction.
}
  pos.entry_p := hash.bucket[buck].mid_p; {init current entry to middle entry}
  if pos.entry_p = nil then begin      {whole bucket is empty ?}
    pos.prev_p := nil;                 {there is no previous entry}
    pos.next_p := nil;                 {there is no successor entry}
    return;
    end;
{
*   The middle bucket entry exists.  Now determine which direction to search
*   from here.
}
  forward := false;                    {init to search direction not committed yet}
  backward := false;

search_loop:                           {back here to test each new entry}
  if pos.namei_len > pos.entry_p^.namei_len {entry is after here ?}
    then goto search_forward;
  if pos.namei_len < pos.entry_p^.namei_len {entry is before here ?}
    then goto search_backward;
  for i := 1 to pos.namei_len do begin {once for each name word}
    if pos.namei[i] > pos.entry_p^.namei[i] {entry is after here ?}
      then goto search_forward;
    if pos.namei[i] < pos.entry_p^.namei[i] {entry is before here ?}
      then goto search_backward;
    end;                               {back and compare next name char}
{
*   NAME matches the current entry.  This is the entry pointed to by
*   POS.ENTRY_P.
}
  pos.prev_p := pos.entry_p^.prev_p;   {save pointer to previous entry}
  pos.next_p := pos.entry_p^.next_p;   {save pointer to next entry}
  found := true;                       {indicate that requested entry was found}
  return;
{
*   NAME would come after the name of the current entry.
}
search_forward:
  if  backward or                      {NAME fits between current entry and next ?}
      (pos.entry_p^.next_p = nil)      {hit end of chain ?}
      then begin
    pos.prev_p := pos.entry_p;         {current entry is right before this position}
    pos.next_p := pos.entry_p^.next_p; {set pointer entry after this position}
    pos.entry_p := nil;
    return;
    end;
  pos.entry_p := pos.entry_p^.next_p;  {advance current entry one forward}
  forward := true;                     {search direction is definately forward}
  goto search_loop;                    {back and compare NAME to new entry}
{
*   NAME would come before the name of the current entry.
}
search_backward:
  if  forward or                       {NAME fits between curr entry and previous ?}
      (pos.entry_p^.prev_p = nil)      {hit start of chain ?}
      then begin
    pos.prev_p := pos.entry_p^.prev_p; {set pointer to entry before this position}
    pos.next_p := pos.entry_p;         {current entry is right after this position}
    pos.entry_p := nil;
    return;
    end;
  pos.entry_p := pos.entry_p^.prev_p;  {advance current entry one backward}
  backward := true;                    {search direction is definately backward}
  pos.after := false;                  {entry will be before bucket midpoint}
  goto search_loop;                    {back and compare NAME to new entry}
  end;                                 {done with HASH abbreviation}
  end;
{
**************************************************************************
*
*   Subroutine STRING_HASH_ENT_LOOKUP (HASH_H, NAME, NAME_P, DATA_P)
*
*   Return data about an entry in a hash table.  HASH_H is the user handle to
*   the hash table.  NAME is the name of the entry to look up.  NAME_P will
*   be returned pointing to the var string name stored in the entry descriptor.
*   DATA_P will be pointing to the start of the user data area in the entry.
*
*   Both NAME_P and DATA_P will be returned NIL if the entry was not found.
}
procedure string_hash_ent_lookup (     {get entry data given name}
  in      hash_h: string_hash_handle_t; {handle to hash table}
  in      name: univ string_var_arg_t; {name of entry to get data for}
  out     name_p: univ_ptr;            {pointer to var string hash table entry name}
  out     data_p: univ_ptr);           {pointer to user data area, NIL if not found}
  val_param;

var
  pos: string_hash_pos_t;              {position handle within hash table}
  found: boolean;                      {TRUE if entry of name NAME found}

begin
  string_hash_pos_lookup (hash_h, name, pos, found); {get position handle to entry}
  if not found then begin              {entry of this name doesn't exist ?}
    name_p := nil;
    data_p := nil;
    return;
    end;
  name_p := addr(pos.entry_p^.name);   {pass back pointer to entry name}
  data_p := univ_ptr(                  {pass back pointer to user data area}
    sys_int_adr_t(pos.entry_p) + pos.hash_p^.data_offset);
  end;
{
**************************************************************************
*
*   Subroutine STRING_HASH_ENT_ADD (POS, NAME_P, DATA_P)
*
*   Add an entry to a hash table.  POS must have been previously set by a call
*   to STRING_HASH_POS_LOOKUP.  POS must not be pointing to an entry (FOUND
*   must have been FALSE in call to STRING_HASH_POS_LOOKUP).  NAME_P is
*   returned pointing to where the entry name var string is stored, and DATA_P
*   will be pointing to the start of the user data area.
}
procedure string_hash_ent_add (        {create new entry at given position}
  in out  pos: string_hash_pos_t;      {handle to position in hash table}
  out     name_p: univ_ptr;            {pointer to var string hash table entry name}
  out     data_p: univ_ptr);           {pointer to hash table entry user data area}
  val_param;

var
  i: sys_int_machine_t;                {loop counter}
  n_after: sys_int_machine_t;          {correct N_AFTER value in bucket}

begin
  with
      pos.hash_p^: hash,               {HASH is hash table admin block}
      pos.hash_p^.bucket[pos.bucket]: buck {BUCK is descriptor for this bucket}
      do begin
  if hash.free_p = nil
    then begin                         {there are no free entries to re-use}
      util_mem_grab (                  {allocate memory for new entry}
        hash.entry_size, hash.mem_p^, false, pos.entry_p);
      end
    else begin                         {re-use an entry from the free chain}
      pos.entry_p := hash.free_p;      {get pointer to entry block}
      hash.free_p := hash.free_p^.next_p; {unlink this entry from free chain}
      end
    ;                                  {POS.ENTRY_P is pointing to new entry block}
  with pos.entry_p^: ent do begin      {ENT is entry descriptor}
{
*   The data block for the new entry is pointed to by POS.ENTRY_P.  Abbreviations
*   in effect are:
*
*   HASH  -  Hash table admin data structure.
*   BUCK  -  Bucket descriptor for bucket new entry is in.
*   ENT   -  Data structure for new entry.
*
*   Link new entry into chain for this bucket.
}
  ent.prev_p := pos.prev_p;            {point new entry to its neighbors}
  ent.next_p := pos.next_p;
  if pos.prev_p = nil
    then begin                         {new entry is at start of chain}
      buck.first_p := pos.entry_p;
      end
    else begin                         {new entry is not at start of chain}
      pos.prev_p^.next_p := pos.entry_p;
      end
    ;
  if pos.next_p = nil
    then begin                         {new entry is at end of chain}
      buck.last_p := pos.entry_p;
      end
    else begin                         {new entry is not at end of chain}
      pos.next_p^.prev_p := pos.entry_p;
      end
    ;
{
*   Copy name into entry.
}
  ent.namei_len := pos.namei_len;
  ent.name.len := pos.name_len;
  ent.name.max := hash.max_name_len;

  for i := 1 to pos.namei_len do begin {copy the characters using whole words}
    ent.namei[i] := pos.namei[i];
    end;
{
*   All done with entry.  Now update bucket data.
}
  buck.n := buck.n + 1;                {one more entry in this bucket}
  if pos.after then begin              {new entry was at or after midpoint ?}
    buck.n_after := buck.n_after + 1;  {one more entry at or after midpoint}
    end;

  n_after := buck.n - (buck.n div 2);  {desired N_AFTER value in bucket}
  if buck.n <= 2
    then begin                         {few enough entries, set midpoint explicitly}
      buck.mid_p := buck.last_p;
      buck.n_after := n_after;
      end
    else begin                         {midpoint may need adjustment}
      while buck.n_after <> n_after do begin {need to adjust midpoint ?}
        if buck.n_after > n_after
          then begin                   {move midpoint forward}
            buck.mid_p := buck.mid_p^.next_p;
            buck.n_after := buck.n_after - 1; {one less entry after midpoint}
            end
          else begin                   {move midpoint backward}
            buck.mid_p := buck.mid_p^.prev_p;
            buck.n_after := buck.n_after + 1; {one more entry after midpoint}
            end
          ;
        end;                           {back and check for midpoint adjust needed}
      end;
    ;                                  {bucket midpoint is all set}

  name_p := addr(pos.entry_p^.name);   {pass back pointer to entry name}
  data_p := univ_ptr(                  {pass back pointer to user data area}
    sys_int_adr_t(pos.entry_p) + hash.data_offset);
  end;                                 {done with ENT abbreviation}
  end;                                 {done with HASH and BUCK abbreviations}
  end;
{
**************************************************************************
*
*   Subroutine STRING_HASH_ENT_ATPOS (POS, NAME_P, DATA_P)
*
*   Get data about the hash table entry indicated by the position handle POS.
*   NAME_P will be returned pointing to the var string entry name that is
*   stored as part of the entry.  DATA_P will point to the start of the user
*   data area for the entry.
}
procedure string_hash_ent_atpos (      {get entry data from position handle}
  in      pos: string_hash_pos_t;      {position handle, must be at an entry}
  out     name_p: univ_ptr;            {pointer to var string hash table entry name}
  out     data_p: univ_ptr);           {pointer to hash table entry user data area}
  val_param;

begin
  name_p := addr(pos.entry_p^.name);   {pass back pointer to entry name}
  data_p := univ_ptr(                  {pass back pointer to user data area}
    sys_int_adr_t(pos.entry_p) + pos.hash_p^.data_offset);
  end;
{
**************************************************************************
*
*   Subroutine STRING_HASH_ENT_DEL (POS)
*
*   Delete the hash table entry indicated by the position handle POS.
}
procedure string_hash_ent_del (        {delete hash table entry at given position}
  in out  pos: string_hash_pos_t);     {handle to entry position in hash table}
  val_param;

var
  n_after: sys_int_machine_t;          {correct N_AFTER value in bucket}

begin
  with
      pos.hash_p^: hash,               {HASH is hash table admin block}
      pos.entry_p^: ent,               {ENT is entry descriptor}
      pos.hash_p^.bucket[pos.bucket]: buck {BUCK is bucket that entry is in}
      do begin
  if ent.prev_p = nil
    then begin                         {entry is at start of chain}
      buck.first_p := ent.next_p;
      end
    else begin                         {entry is not at start of chain}
      ent.prev_p^.next_p := ent.next_p;
      end
    ;
  if ent.next_p = nil
    then begin                         {entry is at end of chain}
      buck.last_p := ent.prev_p;
      end
    else begin                         {entry is not at end of chain}
      ent.next_p^.prev_p := ent.prev_p;
      end
    ;                                  {entry is now unlinked from chain}

  if buck.mid_p = addr(ent) then begin {entry was at midpoint ?}
    buck.mid_p := ent.next_p;          {update midpoint pointer to a real entry}
    end;

  buck.n := buck.n - 1;                {one less entry in this bucket}
  if pos.after then begin              {entry was at or after midpoint ?}
    buck.n_after := buck.n_after - 1;
    end;
  n_after := buck.n - (buck.n div 2);  {desired N_AFTER value in bucket}
  if buck.n <= 2
    then begin                         {few enough entries, set midpoint explicitly}
      buck.mid_p := buck.last_p;
      buck.n_after := n_after;
      end
    else begin                         {midpoint may need adjustment}
      while buck.n_after <> n_after do begin {need to adjust midpoint ?}
        if buck.n_after > n_after
          then begin                   {move midpoint forward}
            buck.mid_p := buck.mid_p^.next_p;
            buck.n_after := buck.n_after - 1; {one less entry after midpoint}
            end
          else begin                   {move midpoint backward}
            buck.mid_p := buck.mid_p^.prev_p;
            buck.n_after := buck.n_after + 1; {one more entry after midpoint}
            end
          ;
        end;                           {back and check for midpoint adjust needed}
      end;
    ;                                  {bucket midpoint is all set}

  ent.next_p := hash.free_p;           {link entry to free chain}
  hash.free_p := addr(ent);
  end;                                 {done with HASH, ENT, and BUCK abbreviations}
  end;
{
**************************************************************************
*
*   Subroutine STRING_HASH_POS_FIRST (HASH_H, POS, FOUND)
*
*   Return a position handle to the first entry in the hash table.  Entries
*   are not in any particular order that is relevant to the user, and the
*   "first" entry is only meaningful as a start for traversing all the entries.
}
procedure string_hash_pos_first (      {return position handle to first entry}
  in      hash_h: string_hash_handle_t; {handle to hash table}
  out     pos: string_hash_pos_t;      {handle to position for this name}
  out     found: boolean);             {TRUE if entry existed}
  val_param;

begin
  pos.hash_p := hash_h;                {save pointer to hash table admin block}
  pos.bucket := 0;                     {init current bucket}
  pos.entry_p := pos.hash_p^.bucket[0].first_p; {init current entry}
  if pos.entry_p = nil then begin      {first bucket is empty}
    string_hash_pos_next (pos, found); {advance to first entry, wherever it is}
    return;
    end;
  found := true;                       {first entry definately existed}
  end;
{
**************************************************************************
*
*   Subroutine STRING_HASH_POS_NEXT (POS, FOUND)
*
*   Advance to the next position following the current entry in the hash table.
*   The entry order should be considered arbitrary from the user's point of
*   view.  The only guarantee is that it each entry will be returned exactly once
*   if POS is first initialized with STRING_HASH_POS_FIRST, then advanced to the
*   end with this subroutine.  FOUND is set to false as a result of trying to
*   advance forward from the last entry.
}
procedure string_hash_pos_next (       {advance position to next entry in hash table}
  in out  pos: string_hash_pos_t;      {handle to position for this name}
  out     found: boolean);             {TRUE if entry existed}
  val_param;

begin
  if pos.entry_p <> nil then begin     {we are at a current entry ?}
    pos.entry_p := pos.entry_p^.next_p; {advance to following entry}
    end;

  while pos.entry_p = nil do begin     {loop back here for each new bucket}
    pos.bucket := pos.bucket + 1;      {advance to next bucket in list}
    if pos.bucket >= pos.hash_p^.n_buckets then begin {past last bucket ?}
      found := false;
      return;
      end;
    pos.entry_p := pos.hash_p^.bucket[pos.bucket].first_p; {pnt to first bucket ent}
    end;                               {back and make sure there is an entry here}
  found := true;                       {yes, we found an entry}
  end;
{
**************************************************************************
*
*   Subroutine STRING_HASH_MEM_ALLOC_DEL (HASH_H, SIZE, P)
*
*   Allocate dynamic memory from the same context as the hash table indicated
*   by the handle HASH_H.  It WILL be possible to deallocate this block of
*   memory individually with STRING_HASH_MEM_DEALLOC.  SIZE is the amount of
*   memory to allocate.  P is returned pointing to the start of the new memory
}
procedure string_hash_mem_alloc_del (  {allocate mem from hash context, can dealloc}
  in      hash_h: string_hash_handle_t; {handle to hash table}
  in      size: sys_int_adr_t;         {amount of memory to allocate}
  out     p: univ_ptr);                {pointer to start of new mem}
  val_param;

var
  hash_p: string_hash_p_t;             {points to hash table admin block}

begin
  hash_p := hash_h;
  util_mem_grab (size, hash_p^.mem_p^, true, p);
  end;
{
**************************************************************************
*
*   Subroutine STRING_HASH_MEM_ALLOC_NDEL (HASH_H, SIZE, P)
*
*   Allocate dynamic memory from the same context as the hash table indicated
*   by the handle HASH_H.  It will NOT be possible to deallocate this block of
*   memory individually with STRING_HASH_MEM_DEALLOC.  SIZE is the amount of
*   memory to allocate.  P is returned pointing to the start of the new memory
}
procedure string_hash_mem_alloc_ndel ( {allocate mem from hash context, no dealloc}
  in      hash_h: string_hash_handle_t; {handle to hash table}
  in      size: sys_int_adr_t;         {amount of memory to allocate}
  out     p: univ_ptr);                {pointer to start of new mem}
  val_param;

var
  hash_p: string_hash_p_t;             {points to hash table admin block}

begin
  hash_p := hash_h;
  util_mem_grab (size, hash_p^.mem_p^, false, p);
  end;
{
**************************************************************************
*
*   Subroutine STRING_HASH_MEM_DEALLOC (HASH_H, P)
*
*   Deallocate memory allocated with STRING_HASH_MEM_ALLOC_DEL.
}
procedure string_hash_mem_dealloc (    {deallocate mem allocated under hash context}
  in      hash_h: string_hash_handle_t; {handle to hash table}
  in out  p: univ_ptr);                {pointer to start of mem, returned NIL}
  val_param;

var
  hash_p: string_hash_p_t;             {points to hash table admin block}

begin
  hash_p := hash_h;
  util_mem_ungrab (p, hash_p^.mem_p^);
  end;
