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
     - computes the prosodic features; is used by both top-level functions 

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
- extended to test performance on Uyghur, by Gerry; very poor results;
  perhaps due to annotation quality
- extended to handle LDC-format data and tasks by Dita and Alfonso
  (but that code is not merged into this)
- coverted to python and shared with Tina etc.
- did cross-language experiments (Dita)

Things to Do: 

- extend to do situation-frame properties
  1. will need to handle LDC-style audio structure
    after creating the concat00X.au files;
  2. will need to parse the annotations ...
     there is code for this in ../../sframes/readSFannotations.m
- test whether cross-segment (broadcast-level) normalization helps [4] (NW)
- test whether mono4 and time helps (NW or Dita)

- add code to automatically assign zeros to nonspeech data, as inferred somehow

- measure time cost, as a multiple of real time, for pitch
  computation, and knn   (NW)

- find a faster pitch tracker (and test quality)  (GC or AN)

- fix the NaNs (this is not hurting kNN; also not NN training since
  such patches are stripped out)    (someone)

- clean up English corpus following English/to-reprocess/Readme [2] (NW - September)




