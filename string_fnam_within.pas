module string_fnam_within;
define string_fnam_within;
%include 'string2.ins.pas';
{
********************************************************************************
*
*   Function STRING_FNAM_WITHIN (FNAM, DIR, WPATH)
*
*   Determines whether the file name FNAM references a system object within the
*   directory tree DIR.  If so, the function returns TRUE and WPATH is set to
*   the path of the FNAM object within DIR.  If not, the function returns FALSE
*   and WPATH is set to the absolute pathname expansion of FNAM.
}
function string_fnam_within (          {check for file within a directory}
  in      fnam: univ string_var_arg_t; {the file to check}
  in      dir: univ string_var_arg_t;  {directory to check for file being within}
  in out  wpath: univ string_var_arg_t) {returned path within DIR}
  :boolean;                            {FNAM is within DIR tree}
  val_param;

var
  rdir: string_treename_t;             {remaining directory pathname}
  tfnam: string_treename_t;            {absolute pathname of FNAM}
  path: string_treename_t;             {path within remaining directory}
  lnam: string_treename_t;             {one pathname component}
  tnam: string_treename_t;             {scratch treename}

begin
  rdir.max := size_char(rdir.str);     {init local var strings}
  tfnam.max := size_char(tfnam.str);
  path.max := size_char(path.str);
  lnam.max := size_char(lnam.str);
  tnam.max := size_char(tnam.str);
  string_fnam_within := false;         {init to FNAM not within DIR}

  string_treename (fnam, tfnam);       {save absolute path of FNAM}
  string_copy (tfnam, rdir);           {init remaining directory path}
  path.len := 0;                       {init pathname within remaining dir}

  while true do begin                  {loop until path found to be within DIR}
    string_copy (rdir, tnam);          {make temp copy of current dir path}
    string_pathname_split (tnam, rdir, lnam); {break into dir and leaf}
    if string_equal (rdir, tnam) then begin {hit file system root ?}
      string_treename (fnam, wpath);   {return absolute pathname of input file}
      return;
      end;

    string_append1 (lnam, '/');        {update path within dir}
    string_prepend (path, lnam);

    string_copy (dir, lnam);           {build test pathname}
    string_append1 (lnam, '/');
    string_append (lnam, path);
    string_treename (lnam, tnam);      {make absolute result}
    if string_equal (tnam, tfnam) then begin {PATH is directly within DIR ?}
      string_copy (path, wpath);       {return path within dir}
      string_fnam_within := true;      {FNAM is within DIR}
      return;
      end;
    end;                               {back for one level up in path}
  end;
