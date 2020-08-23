# mmsl-drug-codes-SAS
 Extracting Multum Lexicon drug codes from RxNorm.

 Many publicly-available health-related datasets in the U.S., e.g., NHANES, MEPS, NAMCS/NHAMCS, etc.. use the proprietary Multum Lexicon drug database to code clinical drugs.

 The U.S. Centers for Disease Control has a public-facing search tool for identifying drug codes located here: https://www2.cdc.gov/drugs/applicationnav1.asp

 However, using this tool to identify tens or hundreds of drugs is cumbersome.

 Fortunately, RxNorm incorporates the Multum Lexicon database, and pulling codes for a list of drugs is relatively easy.

 The SAS code in this repository can be modified for extracting any set of drugs, and assigning other identifiers necessary.

 The drug codes can be found in the CODE column and all start with d followed by a series of 5 numbers

 Also included are example datasets:
 1. antihtn_drug_codes.sas7bdat = A complete (uncurated) list of antihypertensive drugs identified by matching on drug name.
 2. antihtn_drug_codes_curated.sas7bdat = A curated dataset that incorporates additional detailed information extracted from our other project: https://github.com/ssmithm/rxnorm-drug-lists/tree/master/antihypertensive_drugs  and excludes non-antihypertensive drugs (e.g., ophthalmic beta-blockers). 
