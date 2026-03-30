function missingTargetIds = find_missing_disk_slots(sortedTargetIds,kMaxDisksInEnclosure)
    fullSet = [0:1:kMaxDisksInEnclosure-1] ;
    missingTargetIds = setdiff(fullSet, sortedTargetIds)+1 ; % slot number starts with 1 whereas target Id starts with 0
end