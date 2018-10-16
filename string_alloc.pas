{   Subroutine STRING_ALLOC (LEN, MEM, IND, STR_P)
*
*   Allocate memory for a new var string.  LEN is the length of the new var
*   string in characters.  MEM is the handle to the parent memory context.
*   When IND is true, then the string will be allocated in such a way that
*   it can be individually deallocated.  Otherwise, it may only be possible
*   to deallocate the string when the whole memory context is deallocated.
*   STR_P is the returned pointer to the start of the new var string.
*   The MAX field will be set to LEN, and the LEN field will be set to 0.
}
module string_ALLOC;
define string_alloc;
%include '/cognivision_links/dsee_libs/string/string2.ins.pas';

procedure string_alloc (               {allocate a string given its size in chars}
  in      len: string_index_t;         {number of characters needed in the string}
  in out  mem: util_mem_context_t;     {memory context to allocate string under}
  in      ind: boolean;                {TRUE if need to individually dealloc string}
  out     str_p: univ_ptr);            {pointer to var string.  MAX, LEN filled in}
  val_param;

var
  vstr_p: string_var_p_t;              {pointer to new string}

begin
  util_mem_grab (                      {allocate memory for new var string}
    string_size(len),                  {amount of memory needed for this string}
    mem,                               {context under which to allocate memory}
    ind,                               {TRUE if need to individually deallocate str}
    vstr_p);                           {returned pointer to the new string}
  vstr_p^.max := len;                  {init new var string}
  vstr_p^.len := 0;
  str_p := vstr_p;                     {pass back pointer to new string}
  end;
