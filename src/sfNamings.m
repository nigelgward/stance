
%% mappings from field numbers to field names, for output purposes

function [fieldStdNames, typeStdNames] = sfNamings()
  fieldStdNames = containers.Map(...
      {1,2,3,4,5, 6}, ...
      {'Status', 'Relief', 'Urgency', 'Place', 'Type', 'Gravity'});
  typeStdNames = containers.Map({1,2,3,4,5,6,7,8,9,10,11},  ...
				{'evac', 'food', 'infra', 'med', ...
				 'search', 'shelter', 'utils', 'water', ...
				 'regimechange', 'crimeviolence', 'terrorism'});
end