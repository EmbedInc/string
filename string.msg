/*********************************************
/*
/*   Error messages.
/*
msg err1
  lan english -def
    No token found.  End of input string encountered.
msg err2
  lan english -def                     /* bad string
    String "%p1s" can not be interpreted as an integer.
msg err3                               /* bad string
  lan english -def
    String "%p1s" can not be interpreted as a real number.
msg err4                               /* field width
  lan english -def
    Error on attempt to convert floating point number to string
    representation.  Unable to find a format that satisfies all the
    constraints.
msg err5                               /* string
  lan english -def
    Overflow on converting string "%p1s" to an integer.
msg err6
  lan english -def
    Token is NULL string (contains no characters).
msg err7                               /* number string
  lan english -def
    Encountered "+" or "-" in unsigned number "%p1s".
msg err8                               /* bad string
  lan english -def
    "%p1s" is improper YES/NO specifier.
msg err9                               /* bad string
  lan english -def
    "%p1s" is improper ON/OFF specifier.
msg err10
  lan english -def
    Quoted string token is missing terminating quote.
msg err11
  lan english -def
    Bad syntax for quoted string token.
msg err12                              /* FP string
  lan english -def
    Illegal or inconsistant flags specified for conversion of a
    string to a floating pointer number.  Floating point string
    was "%p1s".
msg err13                              /* field width
  lan english -def
    Fixed field width of %p1i was too small to represent number.
msg err14                              /* offending string
  lan english -def
    Bad string format on attempt to convert a string to another
    representation.  Offending string was "%p1s".
msg err15
  lan english -def
    Illegal extra token encountered.  Token was "%p1s" in string "%p2s".
msg err16
  lan english -def
    String "%p1s" is not a valid internet node address in "dot notation" format.
msg err17
  lan english -def
    Illegal character "%p1s" found at index %p2i after closing quote in string
    %p3s".
msg err18
  lan english -def
    Pathname "%p1s" is not local to this system.
msg err19                              /* bad string
  lan english -def
    "%p1s" is improper TRUE/FALSE specifier.
msg err20
  lan english -def
    Invalid parameter "%p2s" encountered to command "%p1s".
msg err21
  lan english -def
    Error on line %p1i of file "%p2s".
msg err22
  lan english -def
    Error at character %p2i of date/time string "%p1s".
msg err23
  lan english -def
    %p1s is not a hexadecimal character.
msg err24
  lan english -def
    The hexedecimal string does not represent whole bytes (number of
    characters is odd).
msg err25
  lan english -def
    The hexadecimal string is too long.
msg err26
  lan english -def
    %p1i is not a valid value in this context.
msg err27
  lan english -def
    Syntax error in logic analyzer type T1 date/time string "%p1s".
/*
/*********************************************
/*
/*   Messages that do not have status codes.
/*
/*   Messages related to command line parsing.
/*
msg cmline_arg_error
  lan english -def
    Error on trying to read command line argument %p1i.
msg cmline_arg_missing
  lan english -def
    Mandatory command line argument %p1i is missing.
msg cmline_arg1_missing
  lan english -def
    Mandatory command line argument 1 is missing.
msg cmline_arg2_missing
  lan english -def
    Mandatory command line argument 2 is missing.
msg cmline_arg3_missing
  lan english -def
    Mandatory command line argument 3 is missing.
msg cmline_dir_missing
  lan english -def
    No directory name provided on the command line.
msg cmline_extra_token                 /* token name
  lan english -def
    Too many tokens found on command line.  First unexpected token
    was "%p1s".
msg cmline_input_fnam_missing
  lan english -def
    No input file name provided on the command line.
msg cmline_opt_conflict
  lan english -def
    Command line argument "%p1s" conflicts with a previous
    command line argument.
msg cmline_opt_bad                     /* bad option
  lan english -def
    Unrecognized command line option "%p1s" encountered.
msg cmline_opt_err
  lan english -def
    Error occurred on trying to read next command line option.
msg cmline_opt_problem
  lan english -def
    Error occurred on attempt to process command line option "%p1s".
msg cmline_output_fnam_missing
  lan english -def
    No output file name provided on the command line.
msg cmline_parm_bad                    /* bad parameter, option name
  lan english -def
    Bad parameter "%p1s" encountered for command line option "%p2s".
msg cmline_parm_missing                /* option name
  lan english -def
    Missing parameter to command line option "%p1s".
msg cmline_progname_err
  lan english -def
    Error trying to get program name by reading command line argument 0.
msg no_reuse_token
  lan english -def
    STRING_CMLINE_REUSE was called although no token had been
    previously read to re-use.
msg reuse_reuse                        /* token saved for re-use
  lan english -def
    STRING_CMLINE_REUSE was called when token was already
    flagged for re-use.  Token flagged for re-use was "%p1s".
/*
/*   Message related to hash tables.
/*
msg hash_max_name_too_long             /* requested size, mas allowed
  lan english -def
    Max entry name size requested in STRING_HASH_INIT is too big.
    Requested size was %p1i, max allowed value is %p2i.  The upper limit
    on this parameter is controlled by the constant
    STRING_HASH_MAX_NAME_LEN_K defined in STRING.INS.PAS.
/*
/*   Message related to string lists.
/*
msg list_add_past_end
  lan english -def
    ERROR:  Attempt to add a line after the current line of a strings
    list, although the current line was after the end of the list.
    New lines can only be added at the start of the list or immediately
    following a real line.  The current line number is %p1i.  The
    list contains %p2i lines.
msg list_pos_negative
  lan english -def
    ERROR:  Attempt to set current position in strings list to line
    number %p1i.  Legal line numbers are zero or greater.
/*
/*   Other messages.
/*
msg err_at_line
  lan english -def
    The error was encountered on line %p1i of file "%p2s".
msg err_command_bad
  lan english -def
    Command "%p1s" is not recognized.
msg err_parm_bad
  lan english -def
    Invalid parameter "%p1s" to command "%p2s" found.
msg err_parm_extra
  lan english -def
    Extra parameter found.  The first extra parameter was "%p1s".
msg internal
  lan english -def
    STRING library internal error.  Oops.
msg err_get_home
  lan english -def
    Error on attempt to get value of HOME environment variable.
msg err_get_working_dir
  lan english -def
    Error on system call to get working directory pathname.
msg err_readin
  lan english -def
    Error occurred on attempt to read from standard input in subroutine
    STRING_READIN.
msg from_screen_id
  lan english -def
    Error occurred on attempt to convert system screen ID to a string.
msg from_window_id
  lan english -def
    Error occurred on attempt to convert system window ID to a string.
msg to_screen_id
  lan english -def
    Error occurred on attempt to convert a string to a system screen ID.
msg to_window_id
  lan english -def
    Error occurred on attempt to convert a string to a system window ID.
