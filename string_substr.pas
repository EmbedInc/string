{   Subroutine STRING_SUBSTR (S1, ST, EN, S2)
*
*   Extract a substring from a string.  S1 is the string the substring
*   is extracted from.  ST and EN define the start and end range of
*   characters to extract from S1.  The substring range is clipped
*   to the size of string S1, and the maximum length of S2.  The resulting
*   string is put into S2.
}
module string_substr;
define string_substr;
%include '/cognivision_links/dsee_libs/string/string2.ins.pas';

procedure string_substr (              {extract substring from a string}
  in      s1: univ string_var_arg_t;   {input string to extract from}
  in      st: string_index_t;          {start index of substring}
  in      en: string_index_t;          {end index of substring}
  in out  s2: univ string_var_arg_t);  {output substring}
  val_param;

var
  start, ennd: sys_int_machine_t;      {real substring range indices}
  p: sys_int_machine_t;                {put index into S2}
  g: sys_int_machine_t;                {get index into S1}

begin
  start := st;                         {init start of substring range}
  if start < 1 then start := 1;        {clip to start of S2}
  ennd := en;                          {init end of substring range}
  if ennd > s1.len then ennd := s1.len; {clip to end of string in S1}
  if (ennd-start+1) > s2.max then      {substring too big for S2 ?}
    ennd := start+s2.max-1;            {yes, chop off end to fit into S2}
  p := 1;                              {init put pointer into S2}
  for g := start to ennd do begin      {once for each character in substring}
    s2.str[p] := s1.str[g];            {copy one character}
    p := p+1                           {point to where to put next character}
    end;                               {back for next character}
  s2.len := max(p-1, 0);               {set length of output string}
  end;
