function [predictions, MSEs] =  predEval(aufileloc, annotationsDir, ppmfile)
 
  %% Nigel Ward, UTEP, June 2017
  %% see ../doc/UTEP-prosody-overview.docx
  %% called from the top level, to predict and then evaluate the predictions

  [predictions, blvals, propertyNames] = prosprop(aufileloc, annotationsDir, ppmfile, 100, 'l'); % every 100 ms is reasonable
%%    [predictions, blvals, propertyNames] = prosprop(aufileloc, annotationsDir, ppmfile, 200,''); % without the -l flag this is a cheating experiment if the test=train
  save('resultsForRegTest', 'predictions');    % for regression testing 

  [annotations, ~] = getAnnotations(aufileloc, annotationsDir); 
  actual = concatenateTargets(annotations);
  baselinePreds = repmat(blvals, size(actual, 1), 1);
  %% for MSE eval dithering is not necessary, but for AUC it is 
  %% varies greatly, in terms of the AUC this gives, from run to run
  baselinePreds = baselinePreds + 0.1 * (rand(size(baselinePreds))-.5);

  printRows(actual, 'actual');
  printRows(predictions, 'predictions');

  if allBoolean(actual)
    AUCs = computeAUCs(predictions, actual, propertyNames);
    baselineAUCs = computeAUCs(baselinePreds, actual, propertyNames);
    showResultQuality(propertyNames, AUCs, baselineAUCs, 'AUC');
  else
    MSEs = computeMSEs(predictions, actual);
    baselineMSEs = computeMSEs(baselinePreds, actual);  
    showResultQuality(propertyNames, MSEs, baselineMSEs, 'MSE');
  end
end

function isBoolean = allBoolean(matrix)
  countOfZerosAndOnes = sum(sum(matrix==0)) + sum(sum(matrix==1));
  numberOfElements = size(matrix, 1) * size(matrix, 2);
  isBoolean = (countOfZerosAndOnes == numberOfElements);
end



function MSEs = computeMSEs(predictions, actual);
  difference = actual - predictions;
  MSEs = mean(difference .* difference);
end


function aucs = computeAUCs(preds, actual, propertyNames)
  aucs = zeros(1, length(propertyNames));
  for i = 1:length(propertyNames)
    predSlice = preds(:,i);
    actualSlice = actual(:,i);
    actualSlice(actualSlice < 1) = 0;
    areaUnderTheCurve = prAuc(predSlice, actualSlice);  % formerly auc()
    aucs(i) = areaUnderTheCurve;
  end
end


function showResultQuality(propertyNames, vals, baselineVals, metric)
  fprintf(' %s: preds, baseline\n', metric);
  for i = 1:length(propertyNames) 
    fprintf('%2d %14s  ', i, propertyNames{i});
    fprintf(' %.3f  %.3f\n', vals(i), baselineVals(i));
  end
  valMean = mean(vals(~isnan(vals)));
  bvalMean = mean(baselineVals(~isnan(baselineVals)));
  fprintf('Overall %s: %.3f %.3f\n', metric, valMean, bvalMean);
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


