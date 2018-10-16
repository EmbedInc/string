{   Routines that handle BASE64 encoded data.
}
module string_base64;
define string_t_base64;
define string_f_base64;
%include 'string2.ins.pas';

type
  b64chunk_t = array [1 .. 4] of char; {one chunk of BASE64 encoded characters}
{
*****************************************************************************
*
*   Local function ENCODE6 (I6)
*
*   Return the low 6 bits of I6 as a single BASE64 encoded character.
}
function encode6 (                     {encode 6 bits into one BASE64 character}
  in      i6: sys_int_conv6_t)         {low 6 bits will be encoded}
  :char;                               {BASE64 encoded character representing I6}
  val_param; internal;

var
  v: sys_int_conv6_t;                  {the 0-63 integer value to encode}

begin
  v := i6 & 63;                        {extract the 0-63 integer value to encode}

  if (v >= 0) and (v <= 25) then begin {0 - 25, upper case letter ?}
    encode6 := chr(ord('A') + v);
    return;
    end;
  if (v >= 26) and (v <= 51) then begin {26 - 51, lower case letter ?}
    encode6 := chr(ord('a') + v - 26);
    return;
    end;
  if (v >= 52) and (v <= 61) then begin {52 - 61, digit 0-9 ?}
    encode6 := chr(ord('0') + v - 52);
    return;
    end;
  if v = 62 then begin                 {62, "+"}
    encode6 := '+';
    return;
    end;
  encode6 := '/';                      {63, "?"}
  end;
{
*****************************************************************************
*
*   Local subroutine ENCODE24 (I24, SO)
*
*   Encode the 24 bit value in I24 to the 4 character BASE64 string SO.
}
procedure encode24 (                   {encode 24 bits into BASE64 format}
  in      i24: sys_int_conv24_t;       {24 bit input value}
  out     so: b64chunk_t);             {BASE64 output characters}
  val_param; internal;

begin
  so[1] := encode6 (rshft(i24, 18));
  so[2] := encode6 (rshft(i24, 12));
  so[3] := encode6 (rshft(i24, 6));
  so[4] := encode6 (i24);
  end;
{
*****************************************************************************
*
*   Subroutine STRING_T_BASE64 (SI, SO)
*
*   Perform BASE64 encoding of a single string.  SI is the input string
*   in clear text.  SO is returned the value of the input string BASE64
*   encoded.
}
procedure string_t_base64 (            {encode clear text string to BASE64}
  in      si: univ string_var_arg_t;   {input string, clear text}
  out     so: univ string_var_arg_t);  {output string, BASE64 encoded}
  val_param;

var
  ch: b64chunk_t;                      {one chunk of 4 BASE64 encoded characters}
  i24: sys_int_conv24_t;               {binary data for one chunk of BASE64 chars}
  nc: sys_int_machine_t;               {number of input bytes in this chunk}
  il: sys_int_machine_t;               {total number of input bytes remaining}
  p: string_index_t;                   {index of next input string character}
  i: sys_int_machine_t;                {scratch loop counter}

begin
  so.len := 0;                         {init output string to empty}
  i24 := 0;                            {prevent compiler warn about uninit var}

  il := si.len;                        {init num of input bytes left to be processed}
  p := 1;                              {init index of next input string character}
  while il > 0 do begin                {loop until all input bytes exhausted}
    nc := 0;                           {init number of input bytes in this chunk}
    for i := 1 to 3 do begin           {once for each input byte in this chunk}
      i24 := lshft(i24, 8);            {make room for this new input byte}
      if p <= si.len then begin        {an input byte exists for this slot ?}
        i24 := i24 ! ord(si.str[p]);   {merge char into value for this chunk}
        p := p + 1;                    {advance index to next input byte}
        nc := nc + 1;                  {count one more input byte in this chunk}
        end;
      end;                             {back for next input byte in this chunk}
    encode24 (i24, ch);                {encode 24 bit chunk into 4 characters}
    case nc of                         {how many input bytes in this chunk ?}
1:    begin                            {1 input byte in this chunk}
        string_appendn (so, ch, 2);    {2 encoded output characters}
        string_appendn (so, '==', 2);  {2 pad characters}
        return;
        end;
2:    begin                            {2 input bytes in this chunk}
        string_appendn (so, ch, 3);    {3 encoded output characters}
        string_append1 (so, '=');      {1 pad character}
        return;
        end;
otherwise                              {assume all 3 input bytes valid this chunk}
      string_appendn (so, ch, 4);      {4 encoded output characters}
      end;
    il := il - 3;                      {count less input characters left to process}
    end;                               {back to do next chunk}
  end;
{
*****************************************************************************
*
*   Local subroutine DECODE8 (E, D, VALID)
*
*   Decode one BASE64 encoded character.  E is the encoded character.  D
*   is its returned 0 - 63 value.  VALID is returned TRUE when E is a valid
*   BASE64 character representing a 0 to 63 value.  D is returned 0 whenever
*   VALID is returned FALSE.
}
procedure decode8 (                    {decode one BASE64 encoded character}
  in      e: char;                     {BASE64 encoded input character}
  out     d: sys_int_conv6_t;          {returned 6 bit value for this character}
  out     valid: boolean);             {TRUE if E was valid 0 to 63 BASE64 character}
  val_param; internal;

begin
  valid := true;                       {init to input characte is valid}

  if (e >= 'A') and (e <= 'Z') then begin {upper case letter, 0 - 25 ?}
    d := ord(e) - ord('A');
    return;
    end;
  if (e >= 'a') and (e <= 'z') then begin {lower case letter, 26 - 51 ?}
    d := ord(e) - ord('a') + 26;
    return;
    end;
  if (e >= '0') and (e <= '9') then begin {decimal digit, 52 - 61 ?}
    d := ord(e) - ord('0') + 52;
    return;
    end;
  case ord(e) of                       {check for remaining individual cases}
ord('+'): d := 62;
ord('/'): d := 63;
otherwise                              {not a valid BASE64 0-63 character}
    d := 0;
    valid := false;
    end;
  end;
{
*****************************************************************************
*
*   Subroutine STRING_F_BASE64 (SI, SO)
*
*   Perform BASE64 decoding on a single string.  SI is the input string in
*   BASE64 encoded format.  SO is returned the decoded clear text string
*   represented by SI.
*
*   All invalid characters in SI are silently ignored.
}
procedure string_f_base64 (            {decode BASE64 string to clear text}
  in      si: univ string_var_arg_t;   {input string, one BASE64 encoded line}
  out     so: univ string_var_arg_t);  {output string, clear text}
  val_param;

var
  p: string_index_t;                   {input string reading index}
  i24: sys_int_conv24_t;               {value for one BASE64 chunk of 4 chars}
  nc: sys_int_machine_t;               {number of input chars found in curr chunk}
  i6: sys_int_conv6_t;                 {value of one decoded BASE64 character}
  c: char;                             {scratch character}
  valid: boolean;                      {was valid 0-63 BASE64 character}

label
  loop_chunk;

begin
  so.len := 0;                         {init output string to empty}
  p := 1;                              {init input string read index}

loop_chunk:                            {back here each new BASE64 chunk of 4 chars}
  nc := 0;                             {init number of input chars in this chunk}
  while nc < 4 do begin                {loop until get all input chars this chunk}
    if p > si.len then exit;           {input string exhausted ?}
    c := si.str[p];                    {get this input character}
    p := p + 1;                        {advance index to next input character}
    decode8 (c, i6, valid);            {decode this input character}
    if valid
      then begin                       {input char was valid BASE64 0-63}
        i24 := lshft(i24, 6) ! i6;     {merge result of this char into 24 bit value}
        nc := nc + 1;                  {count one more valid input character}
        end
      else begin                       {input char was not valid BASE64 0-63}
        if c = '=' then exit;          {end chunk on special BASE64 pad character}
        end
      ;
    end;                               {back to get next input char this chunk}

  case nc of                           {how many input characters in this chunk ?}
2:  begin                              {2 valid input characters, 12 bits decoded}
      string_append1 (so, chr(rshft(i24, 4) & 255)); {one decoded byte this chunk}
      end;
3:  begin                              {3 valid input characters, 18 bits decoded}
      string_append1 (so, chr(rshft(i24, 10) & 255)); {two decoded bytes this chunk}
      string_append1 (so, chr(rshft(i24, 2) & 255));
      end;
4:  begin                              {full input chunk, 24 bits decoded}
      string_append1 (so, chr(rshft(i24, 16) & 255)); {three decoded bytes this chunk}
      string_append1 (so, chr(rshft(i24, 8) & 255));
      string_append1 (so, chr(i24 & 255));
      goto loop_chunk;                 {back and try to decode another chunk}
      end;
    end;                               {end of number of input chars in chunk cases}
  end;
