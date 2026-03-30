% disk_num is the number listed in disk management (starts with 0), slot_num is the slot in
% the jbod (starts with 1)
function disk_num = get_disk_num(deviceListByEncl, encl_id, slot_num)
    
    deviceList = deviceListByEncl{encl_id} ;
    targetIds = cellfun(@(x) str2num(x.SCSITargetId), deviceList, 'UniformOutput', true) ;
    targetIdIdx = find(targetIds == slot_num-1) ;
    disk_num = [] ;
    if isempty(targetIdIdx)
        fprintf('Missing disk in slot %d\n', slot_num) 
    else
        disk_num_txt = deviceList{targetIdIdx}.DeviceID ;
        token = 'DRIVE' ;
        idx = strfind(disk_num_txt, token) ;
        if ~isempty(idx)
            disk_num = sscanf(disk_num_txt(idx+length(token):end), '%d') ;
        else
            fprintf('DeviceId does not contain the token DRIVE\n')
        end
    end        
end
