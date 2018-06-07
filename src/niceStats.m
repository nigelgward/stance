
function [cc, pranuc, p] = niceStats(preds, target, string)
  corr = corrcoef(horzcat(preds, target));
  cc = corr(1,2);

  %% a = prAuc(preds, target);
  %% randomA = mean(target);
  %% pranuc = percent reduction in area not under the curve, vs baseline
  %% pranuc = 1 - ((1-a) / (1.0-randomA));  

  pranuc = auc(preds, target);  %% for now, use ROC-AUC rather than PR-PRANUC

  p = separation(preds, target);

  %% fprintf(' for %37s: correlation %.3f, pranuc %.2f, p by t-test %5.3f   \n', ...
  %%	  string, cc, pranuc, p);
end


%% returns the p-value according to the t test; always enormously small, so not useful
function p = separation(predictions, target) 
  positiveIndices = find(target==1);
  negativeIndices = find(target==0);
  [h,p] = ttest2(predictions(negativeIndices), predictions(positiveIndices));
end
