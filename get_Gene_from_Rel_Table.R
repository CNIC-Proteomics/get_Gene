#######################################
# Created on Mon Dec 10 14:48:22 2018 #
#       author: Andrea Laguillo       #
#           CNIC Proteomics           #
#######################################

#install.packages("data.table")
library(data.table)

# PARAMETERS
filepath <- ("input")      # Set path to input file
output <- ("output")       # Set path to output file

###################################################################################################

# Get data from file
rel_table <- fread(file=filepath, sep="\t", header=TRUE)

# Define function to get GENE
getGeneName <- function(x) {
               gene <- substring(regmatches(x["idinf"],
                                            regexpr("GN=[a-zA-Z0-9]*",
                                                    x["idinf"])), 4)
               if (length(gene) == 0) { # Gene name not found
                 gene <- NA
                }
               return(gene)
               }

# Overwrite second column
rel_table$idinf <- apply(rel_table, 1, getGeneName)

# Remove rows for which there is no Gene name
rel_table <- rel_table[complete.cases(rel_table[,2]),]

# Write to file
fwrite(rel_table, output, sep="\t")
