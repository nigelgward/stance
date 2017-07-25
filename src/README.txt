h:/nigel/ppm/src/README.txt
see also ../doc/UTEP-prosody-overview.doc

Nigel Ward, UTEP, June 2017

This file
- overviews the software components
- describes the three training/testing scenarios
- lists what remains to be done 


There are two top-level functions:
   makePPM
      - which creates a prosody-properties mapping file 
   prosprop
     - which uses a ppm file to classify a new input

And two driver functions: 
   predEval
   regressionTest

Various important functions
   nprosodizeCorpus
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
     - reads one csv file 

There are three training/testing scenarios:
  1. Training data and test data are in separate directories.
     This is the main use case, and what the customers will use.
  2. Test data is each file in turn; training is all the rest.
     (Leave one out).  This is for experimentation and tuning, mostly 
     because the stance-annotated data is quite small.  This is done
     in prosprop if the leaveOneOut flag is true.
  3. Pseudo-Random splits.  This is required because training 900
     neural nets takes too long.  So we use as test data every 10th
     broadcast, and use as training data all the rest.  This is also done
     in prosprop (not yet implemented).

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
- extend to handle Turkish or Uyghur annotations, and increase parsing robustness [8]
- created a small regression test for English [1] 
- saved results of large English test [2]
- release on Github [2]
- created Mandarin ppm and tested, to test workflow (Gerry) [4]
- add code to support use of an Keras-trained neural network (Gerry) [8]

Critical Path:
- test performance on Uyghur stance (Gerry) [3]
- and test Uyghur trained on Turkish (Gerry) [3]

- determine the best hidden-layer size for small data,
  for now the Uyghur; later the suprise languages (Gerry) [8]

- prep to handle August data
  - code review on Dita's annotation format [1]

- August evaluation [4]
- prepare Interspeech talk [8]  (NW)


Nice to have for August eval 

- merge in Gerry's changes to parse Uyghur
- Gerry makes modifications to handle 80:20 and 90:10 data splits
- merge in modifications to the main codebase

- import comments from Jason's readme [1]   (NW)

- extend to do situation-type inference, Uyghur first  (NW)
  1. will need to handle LDC-style audio structure
    after creating the concat00X.au files;
    getSegInfo has code fragments for this 
  2. will need to revive the parsing of annotations, (NW and Dita)
     both native-speaker judgments and Appen-style JSON files 
- test whether cross-segment (broadcast-level) normalization helps [4] (NW)
- test whether mono4 and time helps (NW or Dita)


Other August Tasks

- add comments to Keras code, test, and release (Gerry) [4]
  and release Matlab with option to dump to .mat file for this

- measure time cost, as a multiple of real time, for pitch
  computation, and knn   (NW)

- find a faster pitch tracker (and test quality)  (GC or AN)

- redo for Turkish, to fix paper [2]     (NW) 
  clean Turkish data ("warning very long" problem)
  kappas, presence-of-stance statistics,
  baseline performance, human performance, 
  number of segments, total minutes

September

- fix the NaNs (this is not hurting kNN; also not NN training since
  such patches are stripped out)    (someone)

- clean up English corpus following English/to-reprocess/Readme [2] (NW - September)
- create good ppm files for all languages and release [1]  (NW - September)
- debug the NaNs for music    (NW or GC - September)

- transfer to Dita for cross-language use [1] (NW - September)

- add python wrappper with Ivan [2] (IG - September)
- tranfer to Tina, NCC, USC [3]  (IG - September)


