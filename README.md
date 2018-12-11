# get_Gene
A series of R scripts for extracting gene names from various file formats.

### get_Gene_from_IDq

R script that extracts Gene names from the FASTA identifiers for each row in an IDq file, checking for redundancies from a user-defined species. 
If no redundancy for that species is found, the original Gene name from the FASTA identifier will be returned.
If redundancies for that species are found, the Gene name for the first redundancy will be returned. If there is no Gene name, or if the Gene name is of type LOC*, the original Gene name will be returned.
Rows where no Gene name is found are removed.

### get_Gene_from_Rel_Table

R script that extracts Gene names from the FASTA identifiers for each row in the file.
