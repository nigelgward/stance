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
2. mkdir il8  # create a directory for working on this new language, e.g. il8
3. cd il8
4. mkdir anfiles
5   cp LDC-blah-blah/ANN*/*txt anfiles
6. mkdir aufiles
7.  cp LDC-blah-blah/AUDIO/*flac aufiles  # will take a few minutes
8.  cd aufiles
9.  bash stance/src/flac2audio.sh    # will take a few minutes 
10. rm *flac

C. Matlab
1. edit trainLangDirs in stance/src/sfPredict.m, if needed
2. edit trestLangDirs in ditto to be just il8
3. invoke matlab
4. set paths with addpath: midlevel/src, stance/src, voicebox, jsonlab
5. sfPredict()      # will take a couple hours to compute/cache the pitch

D. Submission
1. send fieldLikelihoods.json to JHU
2. ditto to CMU
3. submit submittable.json to the NIST site


