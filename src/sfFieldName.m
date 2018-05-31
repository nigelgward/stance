
function fieldString = sfFieldName(i)
  [fieldStdNames, typeStdNames] = sfNamings();
  if i <= length(fieldStdNames)
    fieldString = fieldStdNames(i);
  else
    fieldString = typeStdNames(i-6);
  end
end
