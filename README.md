Miscellaneous cataloging scripts. Some are used irregularly. Some regularly.

There's no documentation at all for most of these since only one person (me) has used them, but notes on the purpose of each and its usage will be added below as I review/and use the scripts. (It'll probably never be complete, though.)

## find_a_minus_b.rb
PURPOSE: Creates a file containing the MARC records that exist in file a, but not in file b

USAGE:
```
ruby find_a_minus_b.rb inputfilea inputfileb outputfile
```

NOTES:
* all input and output files must be raw MARC (.mrc, .dat, etc.) files
* comparison is based on value of 001 field---it does not compare entire records against one another

## find_recs_in_both_files.rb
PURPOSE: Creates a file containing the MARC records that exist in BOTH input files

USAGE:
```
ruby find_recs_in_both_files.rb inputfilea inputfileb outputfile
```

NOTES:
* all input and output files must be raw MARC (.mrc, .dat, etc.) files
* comparison is based on value of 001 field---it does not compare entire records against one another

