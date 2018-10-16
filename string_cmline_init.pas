{   Subroutine STRING_CMLINE_INIT
*
*   Initialize before reading tokens from the command line.  This MUST be called
*   before any other STRING_CMLINE routines.
}
module string_cmline_init;
define string_cmline_init;
%include '/cognivision_links/dsee_libs/string/string2.ins.pas';

procedure string_cmline_init;          {init command line parsing for this program}

begin
  cmline_token_last.max := sizeof(cmline_token_last.str); {init var string}
  cmline_next_n := 1;                  {number of next token to read from cmd line}
  cmline_reuse := false;               {init to not re-use last token}
  cmline_last_eos := false;            {init to EOS not returned for last cmline tk}
  end;
