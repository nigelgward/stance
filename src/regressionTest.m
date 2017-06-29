function regressionTest()
  
  %% to run the regression test:
  %%   cd testeng
  %%   regression()

  [results, MSE]=  predEval('audio', 'annotations', 'eng-mono4-testeng-ppm.mat');
  
  %% small-results was created earlier with the same call
  load ('small-results', 'predictions');
  
  permissibleError = 0.1;  % on a scale from 0 to 2
 
  if abs(max(max(results - predictions))) < permissibleError
    fprintf('regression test succeeded: values matched\n');
  else
    fprintf('regression test failed; something changed\n');
  end
  
end
