{   Subroutine STRING_FNAM_UNEXTEND (INNAM,EXTENSIONS,OFNAM)
*
*   Make a file name without a file name extension.  INNAM is the original
*   file name that may have an extension on the end.  EXTENSIONS is a
*   PASCAL string containing a list of all the valid extensions separated
*   by blanks.  OFNAM is returned the file name in INNAM without the file
*   name extension.  If INNAM did not have any of the extensions listed in
*   EXTENSIONS, then OFNAM is just INNAM.  INNAM and OFNAM are allowed to resolve
*   to the same storage locations.
}
module string_fnam_unextend;
define string_fnam_unextend;
%include 'string2.ins.pas';

procedure string_fnam_unextend (       {remove filename extension if there}
  in      innam: univ string_var_arg_t; {input file name (OK if no extension)}
  in      extensions: string;          {list of extensions separated by blanks}
  in out  ofnam: univ string_var_arg_t); {output file name that will not have extension}

var
  xs, xe: sys_int_machine_t;           {substring start,end of COPY_EXT}
  epnt: sys_int_machine_t;             {char pointer into COPY_EXT}
  fpnt: sys_int_machine_t;             {char pointer into INNAM}
  copy_ext: string_var80_t;            {list of file name extensions}

label
  next_ext, start_ext, end_ext;

begin
  copy_ext.max := sizeof(copy_ext.str); {init local var string}
  string_vstring (copy_ext, extensions, sizeof(extensions)); {make var string ext}
  xe := -1;                            {init end of previous extension}

next_ext:                              {back here each new extension in COPY_EXT}
  for xs := xe+2 to copy_ext.len do begin {scan forward for next extension}
    if copy_ext.str[xs] <> ' ' then goto start_ext; {found start of a new extension ?}
    end;                               {back and try next character}
  string_copy (innam, ofnam);          {none of the extensions matched, copy directly}
  return;

start_ext:                             {found new extension, XS points to first char}
  for xe := xs+1 to copy_ext.len do begin {scan forward for end of this extension}
    if copy_ext.str[xe] = ' ' then goto end_ext; {found char after extension ?}
    end;                               {back and try next character}
  xe := copy_ext.len + 1;              {we hit end, point to char after extension}
end_ext:                               {XE points to char after this extension}
  xe := xe-1;                          {this extension is now at XS to XE}
  fpnt := innam.len;                   {init pointer to last char in INNAM}
  for epnt := xe downto xs do begin    {scan backwards thru extension}
    if fpnt < 1 then goto next_ext;    {ran out of file name before extension ?}
    if innam.str[fpnt] <> copy_ext.str[epnt] {file name doesn't match extension ?}
      then goto next_ext;              {go try next extension}
    fpnt := fpnt-1;                    {point to previous character in tree name}
    end;                               {back and check previous character}
  ofnam.len := 0;                      {init output file name}
  string_appendn (ofnam, innam.str, fpnt); {copy up to FPNT chars from INNAM to OFNAM}
  return;
  end;
