
function [worstFalseAlarm, worstMiss] = findWorstPreds(preds, target)

  %% Nigel Ward and James Jodoin, UTEP, June 2018
  %%   preds is typically between zero and one
  %%   target is zero or one
  %%   worstFalseAlarm is the index where pred is highest for a target of 0
  %%   worstMiss is the index where pred is lowest for a target of 1

  indicesWherePresent = find(target==1);
  indicesWhereAbsent = find(target==0);
  predsWherePresent = preds(indicesWherePresent);
  predsWhereAbsent = preds(indicesWhereAbsent);
  %% find min. if not present, we're not interested at this point, so set to 999
  modifiedPreds1 = preds;
  modifiedPreds1(indicesWhereAbsent) = 9999;
  [worstMissVal, worstMiss] = min(modifiedPreds1);
  %% symmetrically for max 
  modifiedPreds2 = preds;
  modifiedPreds2(indicesWherePresent) = -9999;
  [worstFalseAlarmVal, worstFalseAlarm] = max(modifiedPreds2);
end


%% findWorstPreds([1 1 .1 .9 0 0], [1 1 1 0 0 0]) should return 4 and 3
