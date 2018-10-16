{   Procedure STRING_VSTRING (S, IN_STR, IN_LEN)
*
*   Convert a Pascal, C, or FORTRAN string into the variable length string S.
*   IN_STR is the raw input string.  It must be either null terminated (as
*   built-in strings are in C) or padded with blanks (as built-in strings are
*   in Pascal and FORTRAN.  IN_LEN is storage length of IN_STR.  This is how
*   far out blanks must extend if the string contains no null terminator.
*
*   If IN_LEN is negative, then the input string MUST be null-terminated.
*   This indicates that the string length is not known.
}
module string_vstring;
define string_vstring;
%include '/cognivision_links/dsee_libs/string/string2.ins.pas';

procedure string_vstring (             {make var string from Pascal, C or FTN string}
  in out  s: univ string_var_arg_t;    {var string to fill in}
  in      in_str: univ string;         {source string characters}
  in      in_len: string_index_t);     {storage length of IN_STR}
  val_param;

var
  i: sys_int_machine_t;                {loop counter}
  limit: sys_int_machine_t;            {end of string search limit}
  blanks_pending: sys_int_machine_t;   {number of blanks read but not copied yet}

begin
  s.len := 0;                          {init output string to empty}
  if s.len >= s.max then return;       {output string already full ?}
  if in_len < 0                        {determine input string scanning limit}
    then limit := lastof(limit)
    else limit := in_len;
  i := 1;                              {init index to first input string character}
  blanks_pending := 0;                 {init to no pending blanks exist}

  while i <= limit do begin            {once for each character up to the limit}
    if in_str[i] = ' '
      then begin                       {this input character is another blank}
        blanks_pending := blanks_pending + 1; {count one more pending blank}
        end
      else begin                       {this input char is non-blank}
        while blanks_pending > 0 do begin
          s.len := s.len + 1;          {one more character in output string}
          s.str[s.len] := ' ';         {write this output string character}
          if s.len >= s.max then return; {output string completely full ?}
          blanks_pending := blanks_pending - 1; {one less unwritten blank}
          end;
        if ord(in_str[i]) = 0 then return; {hit null terminating character ?}
        s.len := s.len + 1;            {one more character in output string}
        s.str[s.len] := in_str[i];     {copy input string char to output string}
        if s.len >= s.max then return; {output string completely full ?}
        end
      ;
    i := i + 1;                        {advance to next input string character}
    end;                               {back and process this new input string char}
  end;
