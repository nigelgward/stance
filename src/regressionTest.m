function results = regressionTest()
  
  %% to run the regression test:
  %%   cd testeng
  %%   regressionTest();

  %% small-results.mat  was created earlier with 
  %%   predictions = regressionTest()
  %%   save('small-results', 'predictions')
  
  [results, MSE]=  predEval('audio', 'annotations', 'eng-mono4-testeng-ppm.mat');
%  [results, MSE]=  predEval('audio', 'annotations', 'testoutput-ppm.mat');  
  load ('small-results', 'predictions');
  
  permissibleError = 0.1;  % on a scale from 0 to 2
  largestError = abs(max(max(results - predictions)));

  if  largestError > permissibleError
    fprintf('regression test succeeded: values matched\n');
  else
    fprintf('regression test failed; something changed %d\n', largestError);
  end
  
end
