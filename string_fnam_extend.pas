{   Subroutine STRING_FNAM_EXTEND (INNAM,EXTENSION,OFNAM)
*
*   Make extended file name.  INNAM contains a file name that may have
*   an extension on it.  EXTENSION is a PASCAL STRING with the
*   name of one extension.  OFNAM is returned as the file name
*   in INNAM guaranteed to have the extension on it.
}
module string_fnam_extend;
define string_fnam_extend;
%include 'string2.ins.pas';

procedure string_fnam_extend (         {make filename with extension}
  in      innam: univ string_var_arg_t; {input file name (may already have extension)}
  in      extension: string;           {file name extension}
  in out  ofnam: univ string_var_arg_t); {output file name that will have extension}

var
  op: sys_int_machine_t;               {pointer into OFNAM}
  ep: sys_int_machine_t;               {pointer into EXTENSION}
  copy_ext: string_var80_t;            {copy of EXTENSION}

label
  no_ext;

begin
  copy_ext.max := sizeof(copy_ext.str); {init local var string}
  string_vstring (copy_ext, extension, sizeof(extension)); {make var string ext}
  string_copy (innam, ofnam);          {copy input file name to output}

  op := ofnam.len + 1 - copy_ext.len;  {point to first char of extension (if there)}
  if op <= 1 then goto no_ext;         {OFNAM smaller than extension ?}
  for ep := 1 to copy_ext.len do begin {once for each character in extension}
    if ofnam.str[op] <> copy_ext.str[ep] {end of OFNAM not match extension ?}
      then goto no_ext;                {OFNAM does not have extension on it}
    op := op + 1;                      {on to next OFNAM character}
    end;                               {back and check next char in extension}
  return;                              {OFNAM has extension, nothing to do}

no_ext:                                {OFNAM doesn't have extension, add it on}
  string_append (ofnam, copy_ext);     {append file name extension to end}
  end;
