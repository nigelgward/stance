h:/nigel/ppm/src/README.txt
see also ../doc/UTEP-prosody-overview.doc

Nigel Ward, UTEP, June 2017

This file overviews the software components, and then lists what remains to be done 



There are two top-level functions:

makePPM
- which creates a prosody-properties mapping file 
prosprop
- which uses a ppm file to classify a new input


prosodizeCorpus
- is used by both to compute the prosodic features 

normalizeCorpus
- is used by prosprop, to normalize new segments using
  means and standard deviations previously computed over
  the training data

patchwiseKnn
- is the actual estimator, called by prosprop

prepForKnn
- concatenates things in a prosodized corpus, for fast search etc.

readStanceAnnotations
- reads a directory full of annotations

readStanceSpreadsheet
- reads on csv file 


Done:
- basic framework [24]
- deskchecking, rewriting [4]
- test on a small dataset, debug [4]
- test on large data (training on only one Chev file)
  6 minutes to run 800 segments, overall MSE 0.59 
- test on large data (training on all files, leave one out.
  141 minutes, overall MSE 0.28, per stance:
   0.60  0.44  0.39  0.03  0.06  0.05  0.09  0.06  0.48  0.26  0.27  0.43  0.29  0.45
   which is similar to, and slightly better than the mono1 original result, hooray!
   While worse that Jason's latest results, it's a different set of files
   (see comments in  english/to-reprocess/Readme.txt)
- code to write raw (frame-level) features; just pass in 0 insted of mono4.fss  [4]
- extend to handle Turkish annotations, and increase parsing robustness [8]
- created a small regression test for English [1] 
- saved results of large English test [2]
- release on Github [2]

Remaining:
- create Mandarin ppm and test, to test workflow (Gerry) [4]
- add code to support use of an Keras-trained neural network (Gerry) [8]

- extend to handle LDC-style audio structure, on Uyghur [3]

- record time, as a multiple of real time, for pitch computation, and knn
- redo for Turkish, to fix paper [2]
  clean Turkish data ("warning very long" problem)
  kappas, presence-of-stance statistics,
  baseline performance, human performance, 
  number of segments, total minutes

- test performance on Uyghur stance   [3]
- test whether cross-segment (broadcast-level) normalization helps [4] 

- import comments from Jason's readme [1] 

- extend to handle situation-type annotations, Appen-format [8]
- redo last year's Uyghur experiments [10]

- second code review [2] 
- clean up English corpus following english/to-reprocess/Readme [2] 
- create good ppm files for all and release [1] 

- transfer to Dita for cross-language use [1]

- add python wrappper with Ivan [2] 
- tranfer to Tina, NCC, USC [3]

- prep to handle August data, w/ Dita (normalization; native-speaker judgments)

- write quarterly 9 [6]
- write request for 2 years funding [6]

- August evaluation [4]
- prepare interspeech talk [8]


