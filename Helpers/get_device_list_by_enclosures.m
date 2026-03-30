function deviceListByEncl = get_device_list_by_enclosures(deviceList, attached_encl_ports, kMaxSerNumLength)
    
    scsi_ports = cellfun(@(x) str2num(x.SCSIPort),deviceList,'UniformOutput',true) ;
    deviceListByEncl = [] ;
    for ii=1:length(attached_encl_ports)
        encl_port_idx = find(scsi_ports==attached_encl_ports(ii)) ;
        deviceListByEncl{ii} = deviceList(encl_port_idx) ;

        % exclude DrivePool volume, it is listed as being on scsi id 0, and
        % has a serial number that has curly brackets with serial number substantially longer than hard disks serial numbers - now this can change
        % but for now this is the only distinguishing feature from serial
        % numbers of real hard drives
        tmp = deviceListByEncl{ii} ;
        serNums = cellfun(@(x) x.SerialNumber, tmp, 'UniformOutput', false) ;
        serNumLen = cellfun(@(x) length(x), serNums, 'UniformOutput', true) ;
        idx = find(serNumLen > kMaxSerNumLength) ;
        if ~isempty(idx)
            fprintf('Serial numbers longer in length than maximum of %d were found and are listed below, these disks were removed from the list of disks in each enclosure\n', kMaxSerNumLength)
            for jj = 1: length(idx)
                fprintf('Serial: %s\n', serNums{idx(jj)})
            end
            tmp(idx) = [] ;
        end
        fprintf('\n') ;
        deviceListByEncl{ii} = tmp ;
    end
end