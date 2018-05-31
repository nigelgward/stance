

function [deltacorr, pranuc] = testLinearModel(features, target, string) 
  model = fitlm(features, target);
  preds = predict(model, features);
  [deltacorr, pranuc] = niceStats(preds, target, ['linear reg ' string]);
end

	  

function [deltaCorr, pranuc] = niceStats(preds, target, string)
  corr = corrcoef(horzcat(preds, target));
  randomPreds = rand(size(preds));
  randomCorr = corrcoef(horzcat(randomPreds, target));
  deltaCorr = corr(1,2) - randomCorr(1,2);

  a = prAuc(preds, target);
  randomA = mean(target);
  %% pranuc = percent reduction in area not under the curve, vs baseline
  pranuc = 1 - ((1-a) / (1.0-randomA));  

  fprintf(' for %37s: deltaCorr %5.3f, pranuc %5.3f   \n', string, deltaCorr, pranuc);
end
