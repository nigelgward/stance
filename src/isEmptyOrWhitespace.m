
function result = isEmptyOrWhitespace(string) 
  if strcmp('', string)
    result = true;
  else
    if all(isstrprop(string, 'wspace'))
    result = true;
    else
      result = false;
    end
  end
end
