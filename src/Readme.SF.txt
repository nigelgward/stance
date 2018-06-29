To produce Situation Frame Estimates for a new language.

stance/src/Readme.SF.txt

Nigel Ward, UTEP, June 2018

A. Preliminaries
1. install Matlab
2. download matlab packages: midlevel/src, stance/src, voicebox, jsonlab
3. obtain annotated training data, from LDC, and create directories
   as described under B below
4. process all the languages in some way, so the pitch gets computed and cached 

B. New-Language Data Preparation
1. download the language data, decrypt, and uncompress, e.g. LDC-blah-blah
2. mkdir il9  # create a directory for working on this new language, e.g. il9
3. cd il9
4. mkdir anfiles aufiles
5   cp LDC-blah-blah/ANN*/*txt anfiles
6.  cp LDC-blah-blah/AUDIO/*flac aufiles  # will take a few minutes
7.  cd aufiles
8.  bash stance/src/flac2audio.sh    # will take a few minutes 
9. rm *flac

C. Matlab
1. edit trainLangDirs in stance/src/sfPredict.m, if needed
2. edit trestLangDirs in ditto to be just il9 
3. invoke matlab
4. set paths with addpath: midlevel/src, stance/src, voicebox, jsonlab
5. sfPredict(false)      # will take a couple hours to compute/cache the pitch
6. give top50.txt to Dita, to guide native informant work 

D. Serious Submission
1. to JHU, send fieldLikelihoods.json
2. to CMU, ditto
3. submit submittable.json to the NIST site

E. Cheating Submissions
4. find and read the scenario description, and find the location in the entities KB
5. edit outputDummySFs, and run it.
6. submit nilLocDefaultTypes.json, varLocDefaultTypes.json, varLocTweakedTypes.json


