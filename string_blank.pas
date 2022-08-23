module string_blank;
define string_nblanks;
%include 'string2.ins.pas';
{
********************************************************************************
*
*   Subroutine STRING_NBLANKS (N)
*
*   Write N blanks to standard output.  Nothing is done when N is 0 or less.
}
procedure string_nblanks (             {write N blanks to STDOUT}
  in      n: sys_int_machine_t);       {number of blanks to write, nothing for <= 0}
  val_param;

begin
  if n <= 0 then return;               {nothing to do ?}
  write (' ':n);                       {write the blanks}
  end;
