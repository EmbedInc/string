{   This include file only declares the routine STRING_CMLINE_SET.   The
*   declaration of this routine is usually written automatically by SST, and
*   therefore usually should NOT be also declared in the source code.
*
*   This file may not be used directly by any STRING source code.  However, it
*   may be used by some low level, possibly system-dependent, code in the SYS
*   library.  Do not delete this file without checking the SYS library first.
}
procedure string_cmline_set (
  val     argc: sys_int_machine_t;     {number of command line arguments}
  val     argv: univ_ptr;              {pointer to array of pointers}
  in      pgname: string);             {null-terminated program name string}
  val_param; extern;
