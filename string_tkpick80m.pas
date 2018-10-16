{   Subroutine STRING_TKPICK80M (TOKEN,CHARS,TNUM);
*
*   Pick a token from a list of tokens.  TOKEN is the token
*   against which the tokens in the list are matched.  CHARS
*   contains a list of tokens, separated by spaces.  TNUM is
*   returned as the number of the token in CHARS that TOKEN
*   did match.  The first token in CHARS is number 1.  TOKEN
*   must not contain any leading or trailing blanks, or it
*   will never match.  CHARS is not a variable length string,
*   but an array of CHAR, 80 long.
*
*   The string in TOKEN may be abbreviated.  If you want an exact
*   match, use STRING_TKPICK80.
}
module string_tkpick80m;
define string_tkpick80m;
%include 'string2.ins.pas';

procedure string_tkpick80m (           {pick abbreviatable token from list}
  in out  token: univ string_var_arg_t; {token}
  in      chars: string;               {list of tokens separated by spaces}
  out     tnum: sys_int_machine_t);    {token number of match (0=no match)}

var
  tlist: string_var80_t;               {token list in var string format}

begin
  tlist.max := sizeof(tlist.str);      {init local var string}
  string_vstring (tlist, chars, sizeof(chars)); {make var string token list}
  string_tkpickm (token, tlist, tnum);
  end;
