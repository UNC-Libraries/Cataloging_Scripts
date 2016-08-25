Miscellaneous cataloging scripts. Some are used irregularly. Some regularly.

There's no documentation at all for most of these since only one person (me) has used them, but notes on the purpose of each and its usage will be added below as I review/and use the scripts. (It'll probably never be complete, though.)

## bloat_my_notes.rb
PURPOSE: Creates nasty test records with loooong (8000-8999 character) 505 and 520 fields for abusing III Millennium in the service of diagnosing a problem. I can't imagine this is going to be terribly useful to anyone, but there it is...

USAGE:
```
ruby bloat_my_notes.rb inputfile.mrc outputfile.mrc
```

NOTES: 
* Can easily create records that are too long to be encoded into MARC format
* If this happens, it'll thow some error about characters over 100,000 in length
* I got around this by using MarcEdit to remove records with more than 2 505s from my input file

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

