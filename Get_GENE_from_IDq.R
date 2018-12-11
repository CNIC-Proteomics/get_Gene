#######################################
# Created on Wed Dec  5 11:22:15 2018 #
#       author: Andrea Laguillo       #
#           CNIC Proteomics           #
#######################################

#install.packages("data.table")
#install.packages("rlist")
#install.packages("tidyr")
library(data.table)
library(rlist)
library(tidyr)

# PARAMETERS
filepath <- ("input")               # Set path to ID-q file
output <- ("output")                # Set path to output file
get_species_redundancies <- 1       # 0 for NO redundancies only GET GENE, 1 for YES redundancies and GET GENE
preference_species <- "Sus scrofa"  # Set species (as it appears on ID-q file) to check for redundancies,
                                    # ignored if get_species_redundancies set to 0

###################################################################################################

# Get data from FASTA file
IDq <- fread(file=filepath, sep="\t", header=TRUE)

# Define function to get Gene name
getGeneName <- function(x, preference_species=NA) {
               if (is.na(x["Preference_Species"])) { # Not looking at redundancies
                 gene <- substring(regmatches(x["FASTAProteinDescription"],
                                              regexpr("GN=[a-zA-Z0-9]*",
                                                      x["FASTAProteinDescription"])), 4)
                 if (length(gene) == 0) {
                   gene <- NA
                 }
                 gene <- toString(gene)
                 return(gene)
               }
               else {
                 if (x["Preference_Species"] != "No") { # Redundacy found for that species
                   gene <- substring(regmatches(x["Preference_Species"],
                                              regexpr("GN=[a-zA-Z0-9]*",
                                                      x["Preference_Species"])), 4)
                   procedence <- preference_species
                   gene <- paste(gene, procedence, sep=",")
                   if (length(gene) == 0) { # Gene not found
                     # Get from original column instead
                     gene <- substring(regmatches(x["FASTAProteinDescription"],
                                                regexpr("GN=[a-zA-Z0-9]*",
                                                        x["FASTAProteinDescription"])), 4)
                     if (length(gene) == 0) {
                       gene <- NA
                       return(gene)
                     }
                     procedence <- "Homo sapiens"
                     gene <- paste(gene, procedence, sep=",")
                   }
                   if (substring(gene, 1, 3) == "LOC") { # Gene is LOC*
                     # Get from original column instead
                     gene <- substring(regmatches(x["FASTAProteinDescription"],
                                                  regexpr("GN=[a-zA-Z0-9]*",
                                                          x["FASTAProteinDescription"])), 4)
                     if (length(gene) == 0) {
                       gene <- NA
                       return(gene)
                     }
                     procedence <- "Homo sapiens"
                     gene <- paste(gene, procedence, sep=",")
                   }
                   #gene <- toString(gene)
                   return(gene)
                   }
                 else { # Redundacy not found for that species
                   gene <- substring(regmatches(x["FASTAProteinDescription"],
                                                regexpr("GN=[a-zA-Z0-9]*",
                                                        x["FASTAProteinDescription"])), 4)
                   if (length(gene) == 0) {
                     gene <- NA
                     return(gene)
                   }
                   #gene <- toString(gene)
                   procedence <- substring(regmatches(x["FASTAProteinDescription"],
                                                      regexpr("OS=[a-zA-Z0-9]* [a-zA-Z0-9]*",
                                                              x["FASTAProteinDescription"])), 4)
                   gene <- paste(gene, procedence, sep=",")
                   return(gene)
                 }
               }
               } 

# Define function to find Species redundancies
getSpeciesRedundancies <- function(x, preference_species) {
                      header <- x["FASTAProteinDescription"]
                      h_species <- substring(regmatches(x["FASTAProteinDescription"],
                                                        regexpr("OS=[a-zA-Z0-9]* [a-zA-Z0-9]*",
                                                                x["FASTAProteinDescription"])), 4)
                      if (h_species == "Homo sapiens"){
                        redundancies <- x["Redundances"]
                        redundancies <- strsplit(redundancies, " -- ")
                        for (i in redundancies[[1]]){
                          r_species <- substring(regmatches(i, regexpr("OS=[a-zA-Z0-9]* [a-zA-Z0-9]*",
                                                                    i)), 4)
                          if (r_species == preference_species){
                            return(as.character(i))
                            break
                          }
                        }
                      }
                      return("No")
                      }

# Create new columns
IDq[, c("Preference_Species", "Gene")] <- NA
IDq$Preference_Species <- as.character(IDq$Preference_Species)
IDq$Gene <- as.character(IDq$Gene)

if (get_species_redundancies == 0) {
  IDq$Gene <- apply(IDq, 1, getGeneName) 
  IDq$Preference_Species <- NULL
}
if (get_species_redundancies == 1) {
  IDq$Preference_Species <- apply(IDq, 1, getSpeciesRedundancies, preference_species)
  IDq$Gene <- apply(IDq, 1, getGeneName, preference_species)
  #TODO: separate last column
  IDq <- IDq%>% separate(Gene, c("Gene", "Procedence"), sep=",")
}

# Remove rows for which there is no Gene name
IDq <- IDq[complete.cases(IDq[,"Gene"]),]

column_name <- gsub(" ", "_", preference_species)
column_name <- paste("Redundancy_", column_name, sep="")
names(IDq)[names(IDq) == "Preference_Species"] <- column_name

# Write to file
fwrite(IDq, output, sep="\t")
