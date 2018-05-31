function testLinearModel(features, target, string) 
  fprintf('testLinearModel for %s\n', string);
  model = fitlm(features, target);
  preds = predict(model, features);
  randomPreds = rand(size(preds));
  niceStats(preds, target, 'linear regression');
  niceStats(randomPreds, target, 'random');
end

	  
function niceStats(preds, target, string)
  corr = corrcoef(horzcat(preds, target));
  fprintf(' for %s: prediction correlations %6.3f   \n', string, corr(1,2));
  a = auc(preds, target);
  fprintf(' for %s: auc %6.3f   \n', string, a);
end
