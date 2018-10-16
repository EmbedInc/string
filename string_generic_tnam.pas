{   Subroutine STRING_GENERIC_TNAM (INNAM,EXTENSIONS,TNAM)
*
*   Create the generic tree name of a file given its name and a list
*   of possible extensions.  INNAM is the name of the file.  It can be
*   just a leaf name or an arbitrary tree name.  EXTENSIONS is a PASCAL
*   STRING data type containing a list of possible file name extensions,
*   one of which may be on the end of the name in INNAM.  TNAM is
*   returned as the full tree name of the name in INNAM without the file
*   name extension (if any).  The first file name extension that matches
*   the end of the full treename of the file is the one used, even if
*   subsequent extensions would also have matched.  TNAM is returned
*   the null string on any error.
}
module string_generic_tnam;
define string_generic_tnam;
%include '/cognivision_links/dsee_libs/string/string2.ins.pas';

procedure string_generic_tnam (        {generic tree name from file name and extensions}
  in      innam: univ string_var_arg_t; {input file name (may be tree name)}
  in      extensions: string;          {list of extensions separated by blanks}
  in out  tnam: univ string_var_arg_t); {output tree name without extension}

var
  treenam: string_treename_t;          {full tree name of file name in INNAM}

begin
  treenam.max := sizeof(treenam.str);  {set max var string lengths}
  string_treename (innam, treenam);    {make full treename from input name}
  string_fnam_unextend (treenam, extensions, tnam); {remove file name extension if there}
  end;
