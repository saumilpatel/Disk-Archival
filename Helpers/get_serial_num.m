% scsi target id is slot id - 1
function serialNum = get_serial_num(deviceListByEncl, encl_id, slot_id)
    serialNum = '' ;
    devList = deviceListByEncl{encl_id} ;
    targetIds = cellfun(@(x) str2num(x.SCSITargetId), devList, 'UniformOutput', true) ;
    idx = find(targetIds == slot_id-1) ;
    if ~isempty(idx)
        serialNum = devList{idx}.SerialNumber ;
    end   
end