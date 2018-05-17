function [predictions, MSE] =  predEval(aufileloc, annotationsDir, ppmfile)
 
  %% Nigel Ward, UTEP, June 2017
  %% see ../doc/UTEP-prosody-overview.docx
  %% called from the top level, to predict and then evaluate the predictions

  %% predictions = prosprop(aufileloc, annotationsDir, ppmfile, 10, '');
  [predictions, blvals] = prosprop(aufileloc, annotationsDir, ppmfile, 100, 'l');

  [annotations, ~] = getAnnotations(aufileloc, annotationsDir); 
  actual = concatenateTargets(annotations);

  MSE = comparePropVals(predictions, actual, 'Predictions', true);
  comparePropVals(repmat(blvals, size(actual, 1), 1), actual, 'Baseline', false);  
end


%------------------------------------------------------------------
function MSE = comparePropVals(predictions, actual, title, printAll)

  if printAll
    printRows(actual, 'Annotations');
    printRows(predictions, title);
  end 

  difference = actual - predictions;
  MSE = mean(difference .* difference);
  
  fprintf('\n');
  printRow(sprintf('MSE for %s', title), MSE);
  fprintf('overall MSE is %.2f\n', mean(MSE));
  save('small-results', 'predictions');    % for regression testing 
end

%------------------------------------------------------------------
  function printRows(matrix, title)
		  fprintf('%s\n', title);
  for i = 1:size(matrix, 1)
    printRow(sprintf('%.2d ', i), matrix(i,:));
  end
end

%------------------------------------------------------------------
function printRow(name, values)
  fprintf(name);
  for i = 1:length(values)
    fprintf(' %.2f ', values(i));
  end
  fprintf('\n');
end

%------------------------------------------------------------------
function actual = concatenateTargets(annotations)
  nsegments = length(annotations);
  nproperties = length(annotations{1}.props);

  actual = zeros(nsegments, nproperties);
  for i = 1:nsegments
    actual(i,:) = annotations{i}.props;
  end
end

%------------------------------------------------------------------
%% test with
%%   cd testeng
%%   predEval('audio', 'annotations', 'smalltest-ppm.mat');
%% Note that for this the training data is in the test data,
%%  so can obtain 100% if omit the leave-one-out flat, 'l' when calling prosprop

%% larger test
%%  cd english
%%  predEval('audio', /annotation', 'ppmfiles/English-ppm.mat'); % takes 2 hours

%% Turkish test
%% cd turkish


