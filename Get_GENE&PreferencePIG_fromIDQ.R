#######################################
# Created on Wed Dec  5 11:22:15 2018 #
#       author: Andrea Laguillo       #
#######################################

#install.packages("data.table")
library(data.table)

# PARAMETERS
filepath <- ("input")           # Set path to ID-q file
output <- ("output")            # Set path to output file
get_pig_redundancies <- 1       # 0 for NO PIG only GET GENE from FASTAProteinDescription, 1 for YES-PIG and GET GENE

###################################################################################################

# Get data from FASTA file
IDq <- fread(file = filepath, sep="\t", header=TRUE)

# Define function to get Gene name
getGeneName <- function(x) {
               if (is.na(x["Preference_Pig"])) {
                 gene <- substring(regmatches(x["FASTAProteinDescription"],
                                              regexpr("GN=[a-zA-Z0-9]*",
                                                      x["FASTAProteinDescription"])), 4)
                 if (length(gene) == 0) {
                   gene <- "Not Found"
                 }
                 gene <- toString(gene)
                 return(gene)
               }
               else {
                 if (x["Preference_Pig"] != "No") {
                 gene <- substring(regmatches(x["Preference_Pig"],
                                              regexpr("GN=[a-zA-Z0-9]*",
                                                      x["Preference_Pig"])), 4)
                 if (length(gene) == 0) {
                   gene <- "Not Found"
                 }
                 gene <- toString(gene)
                 return(gene)
                 }
                 else {
                   gene <- substring(regmatches(x["FASTAProteinDescription"],
                                                regexpr("GN=[a-zA-Z0-9]*",
                                                        x["FASTAProteinDescription"])), 4)
                   if (length(gene) == 0) {
                     gene <- "Not Found"
                   }
                   gene <- toString(gene)
                   return(gene)
                 }
               }
               } 

# Define function to find Pig redundancies
getPigRedundancies <- function(x) {
                      header <- x["FASTAProteinDescription"]
                      h_species <- substring(regmatches(x["FASTAProteinDescription"],
                                                        regexpr("OS=[a-zA-Z0-9]*",
                                                                x["FASTAProteinDescription"])), 4)
                      if (h_species == "Homo"){
                        redundancies <- x["Redundances"]
                        redundancies <- strsplit(redundancies, " -- ")
                        for (i in redundancies[[1]]){
                          r_species <- substring(regmatches(i, regexpr("OS=[a-zA-Z0-9]*",
                                                                    i)), 4)
                          if (r_species == "Sus"){
                            return(as.character(i))
                            break
                          }
                        }
                      }
                      return("No")
                      }

# Create new columns
IDq[, c("Preference_Pig", "Gene")] <- NA
IDq$Preference_Pig <- as.character(IDq$Preference_Pig)
IDq$Gene <- as.character(IDq$Gene)

if (get_pig_redundancies == 0) {
  IDq$Gene <- apply(IDq, 1, getGeneName) 
  IDq$Preference_Pig <- NULL
}
if (get_pig_redundancies == 1) {
  IDq$Preference_Pig <- apply(IDq, 1, getPigRedundancies)
  IDq$Gene <- apply(IDq, 1, getGeneName)
}

# Write to file
fwrite(IDq, output, sep="\t")