{   Module of routines that perform simple pathname manipulation.
}
module string_pathname;
define string_generic_fnam;
define string_pathname_join;
define string_pathname_split;
%include 'string2.ins.pas';
%include 'string_sys.ins.pas';
{
*******************************************************************
*
*   Subroutine STRING_GENERIC_FNAM (INNAM, EXTENSIONS, FNAM)
*
*   Create the generic file name of a file given its pathname and a list
*   of possible extensions.  INNAM is the pathname of the file.  It can be
*   just a leaf name or an arbitrary tree name.  EXTENSIONS is a PASCAL
*   STRING data type containing a list of possible file name extensions,
*   one of which may be on the end of the pathname in INNAM.  FNAM is
*   returned as the file name from INNAM without the previous directory
*   names (if any) and the without the file name extension (if any).
*   The first file name extension that matches the end of INNAM is used,
*   even if subsequent extensions would also have matched.
}
procedure string_generic_fnam (        {generic leaf name from file name and extensions}
  in      innam: univ string_var_arg_t; {input file name (may be tree name)}
  in      extensions: string;          {list of extensions separated by blanks}
  in out  fnam: univ string_var_arg_t); {output file name without extension}

var
  lnam: string_leafname_t;             {leaf name before extension removed}
  unused: string_var4_t;               {unused var string call argument}

begin
  lnam.max := sizeof(lnam.str);        {init local var strings}
  unused.max := sizeof(unused.str);

  string_pathname_split (innam, unused, lnam); {extract leaf name}
  string_fnam_unextend (lnam, extensions, fnam); {remove extension, if present}
  end;
{
*******************************************************************
*
*   Subroutine STRING_PATHNAME_JOIN (DNAM, LNAM, TNAM)
*
*   Make treename from an arbitrary directory name and leaf name.
*   DNAM is arbitrary directory name.  LNAM is the leaf name.
*   TNAM is the output combined tree name.
}
procedure string_pathname_join (       {join directory and leaf name together}
  in      dnam: univ string_treename_t; {arbitrary directory name}
  in      lnam: univ string_leafname_t; {leaf name}
  out     tnam: univ string_treename_t); {joined treename}

var
  i: sys_int_machine_t;

begin
  string_copy (dnam, tnam);            {copy directory name into path name}
  string_unpad (tnam);                 {remove any trailing spaces}
  for i := 1 to tnam.len do begin      {translate all "/" to "\"}
    if tnam.str[i] = '/' then tnam.str[i] := '\';
    end;
  if not (tnam.str[tnam.len] = '\')
    then string_append1 (tnam, '\');   {append slash delimiter}
  string_append (tnam, lnam);          {append leafname}
  end;
{
*******************************************************************
*
*   Subroutine STRING_PATHNAME_SPLIT (TNAM, DNAM, LNAM)
*
*   Split arbitrary pathname into its directory name and leaf name.
*   TNAM is the arbitrary path name.  DNAM is the output directory name.
*   LNAM is the output leaf name.
*
*   When TNAM specifies a directory with no parent, then DNAM will be the
*   same directory as TNAM, and LNAM will be "." to indicate the same directory.
}
procedure string_pathname_split (      {make dir. and leaf name from arbitrary path name}
  in      tnam: univ string_treename_t; {arbitrary path name to split}
  out     dnam: univ string_treename_t; {directory name}
  out     lnam: univ string_leafname_t); {leaf name}

var
  i: sys_int_machine_t;                {loop index}
  tl: string_index_t;                  {virtual TNAM length}

label
  next_char;

begin
  if tnam.len <= 0 then begin          {input pathname is empty ?}
    string_vstring (dnam, '..', 2);    {pass back directory name}
    string_vstring (lnam, '.', 1);     {pass back leaf name}
    return;
    end;

  tl := tnam.len;                      {init to use full TNAM string}
  for i := tnam.len downto 1 do begin  {look for last separator character}
    case tnam.str[i] of                {what character is here ?}
{
*   Found path down character.
}
'\', '/': begin
  if
      (i = 1) or                       {at node root ?}
      ((i = 2) and ((tnam.str[1] = '\') or (tnam.str[1] = '/'))) {at network root ?}
      then begin
    string_substr (tnam, 1, i, dnam);  {directory is the root directory}
    if tl > i
      then begin                       {we were given a directory below the root}
        string_substr (tnam, i + 1, tl, lnam); {extract leaf name}
        end
      else begin                       {we were given only the root directory}
        string_vstring (lnam, '.', 1);
        end
      ;
    return;
    end;

  if i = tl then begin                 {this is trailing character}
    tl := tl - 1;                      {pretend character isn't there}
    goto next_char;                    {back for next loop character}
    end;

  string_substr (tnam, 1, i - 1, dnam); {extract directory before separator}
  string_substr (tnam, i + 1, tl, lnam); {extract leaf name after separator}

  if (i > 1) and then (tnam.str[i - 1] = ':') then begin {actually at drive root ?}
    string_append1 (dnam, '\');        {indicate drive root directory}
    end;
  return;
  end;
{
*   Found end of drive name.
}
':': begin
  string_substr (tnam, 1, i, dnam);    {drive name becomes directory name}
  string_append1 (dnam, '\');          {indicate drive root directory}
  if i = tl
    then begin                         {no path follows drive name}
      string_vstring (lnam, '.', 1);   {indicate in same directory}
      end
    else begin                         {a path follows drive name}
      string_substr (tnam, i + 1, tl, lnam); {get path after drive name}
      end
    ;
  return;
  end;

      end;                             {end of special character cases}
next_char:                             {jump here to advance to next char in loop}
    end;                               {back to examine previous input string char}
{
*   No separator character was found in input pathname.  TNAM must be the leafname
*   of an object in the current directory.
}
  string_substr (tnam, 1, tl, lnam);   {leafname is just input pathname}
  if (tl = 1) and (tnam.str[1] = '.')
    then begin                         {TNAM is really current directory}
      string_vstring (dnam, '..', 2);
      end
    else begin                         {TNAM is object within current directory}
      string_vstring (dnam, '.', 1);
      end
    ;
  end;
