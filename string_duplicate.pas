module string_duplicate;
define string_duplicate;
%include 'string2.ins.pas';
{
********************************************************************************
*
*   Subroutine STRING_DUPLICATE (INSTR, MEM, IND, STR_P)
*
*   Create a duplicate of the string INSTR.  The memory for the new string will
*   be allocated under the MEM memory context.  When IND is TRUE, the new string
*   can be individually deallocated.  Otherwise, the string is only deallocated
*   when the memory context MEM is deleted.  STR_P is returned pointing to the
*   new string.  It will have the same content as INSTR.  Its maximum size will
*   be the current length of INSTR.
}
procedure string_duplicate (           {create duplicate of existing string}
  in      instr: univ string_var_arg_t; {the string to duplicate}
  in out  mem: util_mem_context_t;     {memory context to allocate string under}
  in      ind: boolean;                {TRUE if need to individually dealloc string}
  out     str_p: string_var_p_t);      {to new string, MAX set to LEN of INSTR}
  val_param;

begin
  string_alloc (instr.len, mem, ind, str_p); {allocate memory for the new string}
  string_copy (instr, str_p^);         {copy existing content into new string}
  end;
