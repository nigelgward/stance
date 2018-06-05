

function [cc, pranuc] = testLinearModel(features, target, string) 
  warning('off', 'stats:LinearModel:RankDefDesignMat');  % useful for preliminary test on tiny datasets
  model = fitlm(features, target);
  warning('on', 'stats:LinearModel:RankDefDesignMat')
  preds = predict(model, features);
  [cc, pranuc] = niceStats(preds, target, ['linear reg ' string]);
end

	  
