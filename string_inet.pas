{   Module of routines that manipulate internet-related strings.
}
module string_inet;
define string_f_inetadr;
define string_t_inetadr;
%include '/cognivision_links/dsee_libs/string/string2.ins.pas';
{
*******************************************************************
}
procedure string_f_inetadr (           {binary internet address to dot notation str}
  in out  s: univ string_var_arg_t;    {output string}
  in      adr: sys_inet_adr_node_t);   {input internet node address}
  val_param;

var
  shr: sys_int_machine_t;              {amount to shift right this time}
  i: sys_int_machine_t;                {loop counter}
  token: string_var16_t;

begin
  token.max := sizeof(token.str);      {init local var string}

  s.len := 0;                          {init output string to empty}

  shr := 24;                           {amount to shift right to get first byte}
  for i := 1 to 4 do begin             {once for each byte in internet address}
    string_f_int (token, rshft(adr, shr) & 255); {make string from this byte}
    if s.len > 0 then begin            {this is not first byte ?}
      string_append1 (s, '.');         {add separator after last byte}
      end;
    string_append (s, token);          {append string value for this byte}
    shr := shr - 8;                    {make shift value for next byte}
    end;                               {back to do next byte}
  end;
{
*******************************************************************
}
procedure string_t_inetadr (           {dot notation internet node adr to string}
  in      s: univ string_var_arg_t;    {input string}
  out     adr: sys_inet_adr_node_t;    {output binary internet address}
  out     stat: sys_err_t);            {completion status code}
  val_param;

var
  i: sys_int_machine_t;                {loop counter}
  bval: sys_int_machine_t;             {byte field value}
  p: string_index_t;                   {parse index into string S}
  dpick: sys_int_machine_t;            {delimiter used to end token (unused)}
  token: string_var16_t;               {token parsed from S}

label
  err;

begin
  token.max := sizeof(token.str);      {init local var string}
  p := 1;                              {init input string parse index}
  adr := 0;                            {init returned internet address value}

  for i := 1 to 4 do begin             {once for each byte of address}
    string_token_anyd (                {parse next byte value token from S}
      s,                               {input string}
      p,                               {parse index}
      '.',                             {list of delimiters}
      1,                               {total number of delimiters}
      0,                               {number of repeatable delimiters}
      [],                              {optional modifier flags}
      token,                           {byte value token parsed from S}
      dpick,                           {unused}
      stat);
    if sys_error(stat) then goto err;  {error getting this token ?}

    string_t_int (token, bval, stat);  {try to convert token to integer in BVAL}
    if sys_error(stat) then goto err;
    if (bval < 0) or (bval > 255) then goto err; {value out of range ?}

    adr := lshft(adr, 8) ! bval;       {merge this byte field into accumulated adr}
    end;                               {back to do next byte field}

  if p <= s.len then goto err;         {didn't use up whole input string ?}

  return;                              {return with no error}

err:                                   {an error has occurred}
  sys_stat_set (string_subsys_k, string_stat_bad_inetadr_k, stat);
  sys_stat_parm_vstr (s, stat);
  end;
