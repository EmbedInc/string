{   Module of routines for comparing strings with each other.
}
module string_compare;
define string_compare_opts;
define string_compare;
%include '/cognivision_links/dsee_libs/string/string2.ins.pas';
{
********************************************************************************
*
*   Function STRING_COMPARE_OPTS (S1, S2, OPTS)
*
*   Determine the relative dictionary positions of two strings.  The function
*   value will be -1 if S1 comes before S2, 0 if both strings are identical, and
*   +1 if S1 comes after S2.  The ASCII collating sequence is used.  Upper case
*   letters are collated immediately before their lower case versions.  For
*   example, the following characters are in order: A, a, B, b, C, c.
*
*   OPTS allows some control over the collating sequence from that described
*   above.  OPTS can be combinations of the following flags, although some flags
*   are mutually exclusive with others.  Results are undefined if mutually
*   exclusive flags are used.  The flags are:
*
*     STRING_COMP_NCASE_K  -  Upper and lower case letters are equal.
*
*     STRING_COMP_LCASE_K  -  A lower case letter comes immediately before
*       the upper case of the same letter, for example: a, A, b, B, c, C.  The
*       default is for upper case letters to come immediately before its lower
*       case counterpart.
*
*     STRING_COMP_NUM_K  -  Numeric fields are compare by their numeric value,
*       not by the character string collating sequence.  A numeric field is one
*       or more successive decimal digits (0-9).  If both strings have such a
*       field up to a point where they are still equal, then the strings are
*       compared based on the integer value of the numeric fields.  This means
*       that leading zeros are ignored.  If the numeric field from both strings
*       has the same value but are different lengths, then the shorter is
*       considered to be before the longer.  Without this flag, the ascending
*       order of some example strings is:
*
*         a0003, a004, a04, a10, a2
*
*       With this flag, the ascending order is:
*
*         a2, a0003, a04, a004, a10
}
function string_compare_opts (         {compares strings, collate sequence control}
  in      s1: univ string_var_arg_t;   {input string 1}
  in      s2: univ string_var_arg_t;   {input string 2}
  in      opts: string_comp_t)         {option flags for collating seqence, etc}
  :sys_int_machine_t;                  {-1 = (s1<s2), 0 = (s1=s2), 1 = (s1>s2)}
  val_param;

var
  p1, p2: string_index_t;              {parse index for each string}
  c1, c2: char;                        {characters from S1 and S2, respectively}
  p1n, p2n: string_index_t;            {parse index into numeric field}
  uc1, uc2: char;                      {upper case copies of C1 and C2}
  nlen1, nlen2: sys_int_machine_t;     {length of numeric fields from strings 1 and 2}
  rlen1, rlen2: sys_int_machine_t;     {remaining length of numeric fields}

label
  nonum, before, after;

begin
  p1 := 1;                             {start parsing each string at its start}
  p2 := 1;
  while (p1 <= s1.len) and (p2 <= s2.len) do begin {abort if at end of one string}
    if string_comp_num_k in opts
      then begin                       {need to compare numeric fields numerically}
        nlen1 := 0;                    {init length of numeric field from string 1}
        p1n := p1;                     {save parse index at start of numeric field}
        repeat                         {search forware for end of numeric field}
          c1 := s1.str[p1];            {fetch this character}
          p1 := p1 + 1;                {advance to next character}
          if (c1 < '0') or (c1 > '9') then exit; {this character is not a digit ?}
          nlen1 := nlen1 + 1;          {count one more digit in numeric field}
          until p1 > s1.len;
        nlen2 := 0;                    {init length of numeric field from string 2}
        p2n := p2;                     {save parse index at start of numeric field}
        repeat                         {search forware for end of numeric field}
          c2 := s2.str[p2];            {fetch this character}
          p2 := p2 + 1;                {advance to next character}
          if (c2 < '0') or (c2 > '9') then exit; {this character is not a digit ?}
          nlen2 := nlen2 + 1;          {count one more digit in numeric field}
          until p2 > s2.len;
        if (nlen1 = 0) or (nlen2 = 0)  {no numeric fields to compare ?}
          then goto nonum;
        {
        *   The current position in each string is the start of a numeric field,
        *   and numeric interpretation of numeric fields is enabled.  NLEN1 and
        *   NLEN2 is the length of the numeric field in each string.  Both are
        *   guaranteed to be at least 1.  P1 and P2 contain the indexes of where
        *   to continue comparing the strings should the numeric fields be
        *   equal.  P1 and P2 may indicate the first character past the end of
        *   their strings.  P1N and P2N are the parse indexes to the start of
        *   numeric fields.
        }
        rlen1 := nlen1;
        repeat                         {strip leading 0s from numeric field 1}
          if s1.str[p1n] <> '0' then exit;
          p1n := p1n + 1;
          rlen1 := rlen1 - 1;
          until rlen1 = 0;
        rlen2 := nlen2;
        repeat                         {strip leading 0s from numeric field 2}
          if s2.str[p2n] <> '0' then exit;
          p2n := p2n + 1;
          rlen2 := rlen2 - 1;
          until rlen2 = 0;
        if rlen1 < rlen2 then goto before; {compare based on number of non-zero digits}
        if rlen1 > rlen2 then goto after;
        while rlen1 > 0 do begin       {compare the digits}
          c1 := s1.str[p1n];           {fetch each character}
          c2 := s2.str[p2n];
          if c1 < c2 then goto before; {check for definite mismatch}
          if c1 > c2 then goto after;
          p1n := p1n + 1;              {characters are equal, advance to next}
          p2n := p2n + 1;
          rlen1 := rlen1 - 1;          {once less digit position to compare}
          end;
        if nlen1 < nlen2 then goto before; {numeric fields equal, compare field sizes}
        if nlen1 > nlen2 then goto after;
        next;                          {numeric fields totally equal, continue afterwards}
        end
      else begin                       {no numeric comparison}
        c1 := s1.str[p1];              {fetch character from string 1}
        p1 := p1 + 1;
        c2 := s2.str[p2];              {fetch character from string 2}
        p2 := p2 + 1;
        end
      ;
nonum:                                 {skip here if not comparing numeric fields}
{
*   C1 and C2 are the characters fetched from each string to compare.  P1 and P2
*   are the indexes of the next characters.
}
    if c1 = c2 then next;              {no difference, go on to next char}
    uc1 := c1;                         {make upper case char from string 1}
    if (uc1 >= 'a') and (uc1 <= 'z')
      then uc1 := chr(ord(uc1) - ord('a') + ord('A'));
    uc2 := c2;                         {make upper case char from string 2}
    if (uc2 >= 'a') and (uc2 <= 'z')
      then uc2 := chr(ord(uc2) - ord('a') + ord('A'));
    if uc1 < uc2 then goto before;
    if uc1 > uc2 then goto after;
    if string_comp_ncase_k in opts then next; {case-insensitive ?}
    if string_comp_lcase_k in opts then begin {lower case letter before upper same ?}
      if c1 > c2 then goto before;
      goto after;
      end;
    if c1 < c2 then goto before;
    goto after;
    end;                               {back to compare next char in both strings}
{
*   The strings are equal up to the length of the shortest string.
}
  if s1.len < s2.len then goto before; {shorter strings come first}
  if s1.len > s2.len then goto after;
  string_compare_opts := 0;            {indicate strings are truly identical}
  return;

before:                                {s1 comes before s2}
  string_compare_opts := -1;
  return;

after:                                 {s1 comes after s2}
  string_compare_opts := 1;
  end;
{
********************************************************************************
*
*   Function STRING_COMPARE (S1, S2)
*
*   Determine the relative dictionary positions of two strings.  The
*   function value will be -1 if S1 comes before S2, 0 if both strings
*   are identical, and +1 if S1 comes after S2.  The ASCII collating
*   sequence is used.  Upper case letters are collated immediately before
*   their lower case versions.  For example, the following characters
*   are in order: A, a, B, b, C, c.
}
function string_compare (              {compares string relative dictionary positions}
  in      s1: univ string_var_arg_t;   {input string 1}
  in      s2: univ string_var_arg_t)   {input string 2}
  :sys_int_machine_t;                  {-1 = (s1<s2), 0 = (s1=s2), 1 = (s1>s2)}

begin
  string_compare := string_compare_opts (s1, s2, []);
  end;
