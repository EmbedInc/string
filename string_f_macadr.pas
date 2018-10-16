{   Subroutine STRING_F_MACADR (S, MACADR)
*
*   Create the standard "dash" string representation of the ethernet MAC
*   address in MACADR.
}
module string_f_macadr;
define string_f_macadr;
%include 'string2.ins.pas';

procedure string_f_macadr (            {make string from ethernet MAC address}
  in out  s: univ string_var_arg_t;    {output string}
  in      macadr: sys_macadr_t);       {input MAC address}
  val_param;

var
  i: sys_int_machine_t;                {loop counter}
  tk: string_var16_t;                  {sratch token}
  stat: sys_err_t;                     {completion status}

begin
  tk.max := size_char(tk.str);         {init local var string}

  s.len := 0;                          {init return string to emtpy}

  for i := 5 downto 0 do begin         {once for each byte in the MAC address}
    if s.len <> 0 then begin           {not first byte ?}
      string_append1 (s, '-');         {add dash separator after previous byte}
      end;
    string_f_int_max_base (            {make HEX string from this byte}
      tk,                              {output string}
      macadr[i],                       {input integer}
      16,                              {radix}
      2,                               {field width}
      [ string_fi_leadz_k,             {write leading zeros to fill field}
        string_fi_unsig_k],            {input number is unsigned}
      stat);
    string_append (s, tk);
    end;
  end;
