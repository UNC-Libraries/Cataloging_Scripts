Miscellaneous cataloging scripts. Some are used irregularly. Some regularly. Some of them were never finished. Whee...

There's no documentation at all for most of these since only one person (me) has used them, but notes on the purpose of each and its usage will be added below as I review/and use the scripts.

The ones with information below are finished. 

## afro_americana_796_extract.rb
PURPOSE:

USAGE:
```
.
```

NOTES:
* .

## afro_americana_797_extract.rb
PURPOSE:

USAGE:
```
.
```

NOTES:
* .

## analyze_010_data.rb
PURPOSE:

USAGE:
```
.
```

NOTES:
* .

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

## check_character_encoding.rb
PURPOSE:
Creates two new .mrc files in the same location as the input file. One of the new files will have _UTF8.mrc on the end and the other will have _MARC8.mrc on the end. Writes each record from the input file to the appropriate new file based on the value of LDR/09 and provides a count of records in each encoding. 

USAGE:
```
ruby check_character_encoding.rb path_to/mrc_file.mrc
```

## check_sersol_urls.rb
PURPOSE:

USAGE:
```
.
```

NOTES:
* .

## count_records.rb
PURPOSE:

USAGE:
```
.
```

NOTES:
* .

## eresourcify_300s.rb
PURPOSE:

USAGE:
```
.
```

NOTES:
* .

## extract_by_field_value.rb
PURPOSE:

USAGE:
```
.
```

NOTES:
* .

## extract_records_by_indicator.rb
PURPOSE:

USAGE:
```
.
```

NOTES:
* .

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

## find_unique_recs_in_each.rb
PURPOSE:

USAGE:
```
.
```

NOTES:
* .

## get_856u_from_MARC.rb
PURPOSE:

USAGE:
```
.
```

NOTES:
* .

## get_field_counts_and_cumul_lengths.pl
PURPOSE:

USAGE:
```
.
```

NOTES:
* .

## get_recs_not_matching_mill_URLs.rb
PURPOSE:

USAGE:
```
.
```

NOTES:
* .

## holdings_link_checker.rb
PURPOSE:

USAGE:
```
.
```

NOTES:
* .

## marc_field_length.rb
PURPOSE:

USAGE:
```
.
```

NOTES:
* .

## marc_to_spreadsheet.rb
PURPOSE:

USAGE:
```
.
```

NOTES:
* .

## oecd_compare.rb
PURPOSE:

USAGE:
```
.
```

NOTES:
* .

## oecd_xplor.rb
PURPOSE:

USAGE:
```
.
```

NOTES:
* .

## repeated_column_normalizer.rb
PURPOSE:

USAGE:
```
.
```

NOTES:
* .

## retro_record_gather.rb
PURPOSE:

USAGE:
```
.
```

NOTES:
* .

## sersol_dedupe_the_dupes.rb
PURPOSE:

USAGE:
```
.
```

NOTES:
* .

## shift_record_ids.rb
PURPOSE:
Testing a nasty III bug. Will have limited other use unless you really want to mess stuff up. It takes an input .mrc file and updates all the 001 values so that Record 1's 001 is assigned to Record 2, Record 2's 001 is assigned to Record 3, and so on. The 001 of the last record in the file is assigned to Record 1. 

USAGE:
```
ruby shift_record_ids.rb path-to-mrc-file.mrc output-path.mrc
```

## split_by_record_type.rb
PURPOSE:

USAGE:
```
.
```

NOTES:
* .

## split_mrc_based_on_773.rb
PURPOSE:

USAGE:
```
.
```

NOTES:
* .

## springer_dupe_id.rb
PURPOSE:

USAGE:
```
.
```

NOTES:
* .

## springer_overlay_catcher.rb
PURPOSE:

USAGE:
```
.
```

NOTES:
* .

## sql_export_exploder.rb
PURPOSE:

USAGE:
```
.
```

NOTES:
* .

## stat_code_mill_output_cleaner.rb
PURPOSE:

USAGE:
```
.
```

NOTES:
* .

## tab_delim_field_splitter.rb
PURPOSE:

USAGE:
```
.
```

NOTES:
* .

## to_776.rb
PURPOSE:

USAGE:
```
.
```

NOTES:
* .

## update_a_with_b.rb
PURPOSE:

USAGE:
```
.
```

NOTES:
* .
