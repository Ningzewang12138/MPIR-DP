function isOneElementDifferent = checkOneElementDifferenceSets(vec1, vec2)
   
    diff1 = setdiff(vec1, vec2);

    diff2 = setdiff(vec2, vec1);
    
    isOneElementDifferent = (length(diff1) ==1 ) && (length(diff2) == 1);
end
