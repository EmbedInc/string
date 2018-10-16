{   Subroutine STRING_TKPICK_S (TOKEN, TLIST, LEN, PICK)
*
*   Find which token in TLIST matches the token in TOKEN.  TOKEN is a variable length
*   string.  TLIST is a string of length LEN, containing a list of possible matches
*   separated by one or more blanks.  The token in TOKEN may be abbreviated as long
*   as it still results in a unique match from TLIST.  PICK is returned as the token
*   number in TLIST that matched.  The first token is number 1.  PICK is returned
*   as 0 if there was no match at all, and -1 if there were multiple matches.
}
module string_tkpick_s;
define string_tkpick_s;
%include '/cognivision_links/dsee_libs/string/string2.ins.pas';

procedure string_tkpick_s (            {pick legal abbrev from any length token list}
  in      token: univ string_var_arg_t; {to try to pick from list}
  in      tlist: univ string;          {list of valid tokens separated by blanks}
  in      len: string_index_t;         {number of chars in TLIST}
  out     pick: sys_int_machine_t);    {token number 1-N, 0=none, -1=not unique}
  val_param;

var
  tnum: sys_int_machine_t;             {number of current token from TLIST}
  p: string_index_t;                   {TLIST index to fetch next char from}
  i: sys_int_machine_t;                {loop counter}

label
  next_token, finish_token;

begin
  pick := 0;                           {init to no match found}
  tnum := 0;                           {init current TLIST token number}
  p := 0;                              {init TLIST parse pointer}

next_token:                            {jump here to find start of next TLIST token}
  p := p+1;                            {point to next char in TLIST}
  if p > len then return;              {got to end of token list ?}
  if tlist[p] = ' ' then goto next_token; {just pointing to delimiter ?}
  tnum := tnum+1;                      {make new current token number}

  if token.len > (len-p+1) then return; {can't possibly match rest of TLIST ?}
  for i := 1 to token.len do begin     {once for each character in TOKEN}
    if token.str[i] = tlist[p] then begin {this character still matches ?}
      p := p+1;                        {advance to next TLIST char}
      next;                            {back and compare at this char}
      end;
    goto finish_token;                 {didn't match, go on to next token}
    end;                               {back and compare next chars in token}
  if (p > len) or (tlist[p] = ' ')     {exact or abbreviated match ?}
    then begin                         {tokens matched exactly}
      pick := tnum;                    {pass back number of this token}
      return;                          {we have exact match, stop looking}
      end
    else begin                         {matched if TOKEN is only an abbreviation}
      if pick = 0                      {is this the first abbreviated match or not}
        then pick := tnum              {this is only match so far}
        else pick := -1;               {indicate multiple matches}
      end
    ;
finish_token:                          {jump here to skip to end of current token}
  if tlist[p] = ' ' then goto next_token; {found delimiter before next token ?}
  p := p+1;                            {point to next TLIST character}
  if p > len then return;              {got to end of token list ?}
  goto finish_token;                   {back and look for delimiter before new token}
  end;
