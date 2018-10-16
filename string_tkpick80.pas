{   Subroutine STRING_TKPICK80 (TOKEN,CHARS,TNUM);
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
*   TOKEN must contain the exact full token as in CHARS for
*   a valid match.  Use STRING_TKPICK80M if you want to be able
*   to abbreviate tokens.
}
module string_tkpick80;
define string_tkpick80;
%include 'string2.ins.pas';

procedure string_tkpick80 (            {pick unabbreviated token from list}
  in      token: univ string_var_arg_t; {token}
  in      chars: string;               {list of tokens separated by spaces}
  out     tnum: sys_int_machine_t);    {token number of match (0=no match)}

var
  tlist: string_var80_t;               {token list in var string format}

begin
  tlist.max := sizeof(tlist.str);      {init local var string}
  string_vstring (tlist, chars, sizeof(chars)); {make var string token list}
  string_tkpick (token, tlist, tnum);
  end;
