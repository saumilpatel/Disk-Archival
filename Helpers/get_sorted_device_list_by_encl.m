function [sortedDeviceListByEncl,sortedTargetIds,sortIdx] = get_sorted_device_list_by_encl(deviceListByEncl, attached_encl_ports)
    targetIds = [] ;
    sortedTargetIds = [] ;
    sortIdx = [] ;
    for ii=1:length(attached_encl_ports)
        targetIds{ii} = cellfun(@(x) str2num(x.SCSITargetId), deviceListByEncl{ii}, 'UniformOutput', true) ;
        [sortedTargetIds{ii},sortIdx{ii}] = sort(targetIds{ii}, 'ascend') ;
        sortedDeviceListByEncl{ii} =  deviceListByEncl{ii}(sortIdx{ii}) ;
    end
end