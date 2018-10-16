{   Subroutine STRING_WRITE_BLANK
*
*   Write a blank line to standard output.
}
module string_WRITE_BLANK;
define string_write_blank;
%include 'string2.ins.pas';

procedure string_write_blank;          {write blank line to standard output}

var
  s: string_var4_t;

begin
  s.max := sizeof(s.str);
  s.len := 0;
  string_write (s);
  end;
