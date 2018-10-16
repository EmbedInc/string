{   Subroutine STRING_TKPICKM (TOKEN,TLIST,TNUM);
*
*   Pick a token from a list of tokens.  TOKEN is the token
*   against which the tokens in the list are matched.  TLIST
*   contains a list of tokens, separated by spaces.  TNUM is
*   returned as the number of the token in TLIST that TOKEN
*   did match.  The first token in TLIST is number 1.  TOKEN
*   must not contain any leading or trailing blanks, or it
*   will never match.
*
*   TOKEN may be abbreviated and will match the first pattern from
*   TLIST that is the same up to the length of TOKEN.  If you
*   want to force TOKEN to be an exact match, use the routine
*   STRING_TKPICK.
}
module string_tkpickm;
define string_tkpickm;
%include '/cognivision_links/dsee_libs/string/string2.ins.pas';

procedure string_tkpickm (             {pick abbreviatable token from list}
  in      token: univ string_var_arg_t; {token}
  in      tlist: univ string_var_arg_t; {list of tokens separated by spaces}
  out     tnum: sys_int_machine_t);    {token number of match (0=no match)}

var
  patt: string_var132_t;               {current pattern parsed from TLIST}
  p: string_index_t;                   {parse index for TLIST}
  stat: sys_err_t;

label
  next_patt, no_match;

begin
  patt.max := sizeof(patt.str);        {init local var string}
  p := 1;                              {init parse pointer}
  tnum := 0;                           {init token number in TLIST}

next_patt:                             {back here for next TLIST pattern}
  string_token (tlist, p, patt, stat); {get next pattern to match against}
  if string_eos(stat) then goto no_match; {got to end of list and nothing matched ?}
  tnum := tnum+1;                      {make new token number}
  if string_match (token, patt)        {does it match this token ?}
    then return                        {yes, we found the match}
    else goto next_patt;               {no, go try next token}

no_match:                              {didn't match any of the tokens}
  tnum := 0;                           {indicate no match}
  end;
