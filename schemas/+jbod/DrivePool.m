% class DrivePool
% handles creation of StableBit drive pools for jbods attached to a
% computer
% assumes DrivePool from StableBit is already installed
% assumes all jbods are loaded with drives that are not read only
% contains methods that add entries to database, for which, access/authentication
% information should be setup prior to running those methods

classdef DrivePool

    properties
        kMaxEncl = 2 ; % currently 2 per booth, one for ephys and one for eye/markerless video
        kMaxDisksInEnclosure = 60 ;
        kMaxSerNumLength = 16 ; % this needs to be found empirically because manufacturers can change their serial number specs, current specs are that both Western Diogital and Seagate have 8 char serial numbers
        hostname = '' ; % name of the host on which this object is running (e.g. 'at-backupB1')
        drivePoolPaths = [] ; % drive letter paths for drivepools (e.g. 'E:\')
        attached_encl_ports = [] ; % scsi ports of attached JBOD enclosures (e.g. 0)
        deviceList = [] ; % all the disks attached to the computer
        deviceListByEncl = [] ; % all disks in each JBOD enclosure
        sortedDeviceListByEncl = [] ; % all disks in each JBOD enclosure sorted in ascending order of the disk num
        sortedTargetIds = [] ; % all disk numbers in each JBOD enclosure sorted in ascending order
        sortIdx = [] ; % indices into deviceListByEncl to obtain the sorted device list
        missingDiskSlots = [] ; % disk slots that have missing disks in each JBOD
        enclSerialNum = [] ; % serial numbers of the JBOD enclosures, need to find the serial number using web interface in the enclosure
    end


    methods

        function obj = DrivePool(max_enclosures, max_slots)
            obj.kMaxEncl = max_enclosures ;
            obj.kMaxDisksInEnclosure = max_slots ;
        end


        function obj = get_hostname(obj)
            [~, hn] = system('hostname');
            obj.hostname = strtrim(hn);
        end



        function obj = get_attached_encl_ports(obj)
            % list all drives to see what scsi ports are in use
            [~,output] = list_drives() ;
            output % need to look at the list to find the scsi port number corresponding to each JBOD
            
            % the scsi port numbers for jbod enclosures have to be determined ahead of time from Disk
            % Management
            for ii=1:obj.kMaxEncl
                cmd = sprintf('SCSI port number for enclosure %d [%d] ? ', ii, ii-1) ;
                encl_port = input(cmd) ;
                if isempty(encl_port)
                    encl_port = ii - 1 ;
                    fprintf('Enclosure port set to %d\n', ii-1)
                end
                obj.attached_encl_ports = [obj.attached_encl_ports encl_port] ;
            end
        end



        function obj = get_device_list(obj)
            % get info about all the disks
            [status,output] = get_all_disk_info() ;
            if status ~= 0
                fprintf('Info about all disks cannot be obtained, so deviceList is not updated\n')
            else
                fprintf('Info about all disks obtained successfully\n')

                % associate disks with enclosures
                 obj.deviceList = get_enclosures_and_disks(output) ;
            end
        end



        function obj = get_device_list_by_encl(obj)
            % group by SCSIPort, i.e. by enclosure
            obj.deviceListByEncl = get_device_list_by_enclosures(obj.deviceList, obj.attached_encl_ports, obj.kMaxSerNumLength) ;
        end



        function obj = get_sorted_device_list_by_encl(obj)
            % sort by TargetId, get TargetIds first
            [obj.sortedDeviceListByEncl,obj.sortedTargetIds,obj.sortIdx] = get_sorted_device_list_by_encl(obj.deviceListByEncl, obj.attached_encl_ports) ;
        end



        function obj = all_disks_online(obj)
            [initstatus,~,onlinestatus,~] = make_all_disks_online() ;
            if initstatus ~= 0
                fprintf('All disks were not initialized, check in disk management\n')
            end
            if onlinestatus ~= 0
                fprintf('All disks were not made online, check in disk management\n')
            end
        end



        % sel_encl is a one element array which specifies one enclosure at a time if selected disks have
        % to be formatted
        % sel_slot is an array of slot numbers that need to be formatted
        % if sel_encl and sel_slot are empty, all slots are formatted in
        % all enclosures
        function obj = format_disks_in_all_encl(obj, sel_encl, sel_slot)
            for jj=1:obj.kMaxEncl
                if (~isempty(sel_encl) && (jj==sel_encl(1))) || isempty(sel_encl)
                    for ii=1:obj.kMaxDisksInEnclosure  
                        if (~isempty(sel_slot) && ismember(ii,sel_slot)) || isempty(sel_slot)
                            serNum =  get_serial_num(obj.deviceListByEncl, jj, ii) ;
                            disknum = get_disk_num(obj.deviceListByEncl, jj, ii) ;
                            volume_label = sprintf('%s_E%d_S%d_D%d_%s', obj.hostname(end-1:end), jj, ii, disknum, serNum) ;            
                            format_disk(disknum,volume_label) ;
                        end
                    end
                end
            end
        end



        % sel_encl is a one element array which specifies one enclosure at a time if selected volume have
        % to be added to drive pool
        % sel_slot is an array of slot numbers that need to be added to
        % drive pool
        % if sel_encl and sel_slot are empty, all slots in
        % all enclosures are added to drive pool       
        function obj = add_formatted_disk_to_drive_pool(obj, sel_encl, sel_slot)
            for jj=1:obj.kMaxEncl
                if (~isempty(sel_encl) && (jj==sel_encl(1))) || isempty(sel_encl)
                    for ii=obj.kMaxDisksInEnclosure:-1:1
                        if (~isempty(sel_slot) && ismember(ii,sel_slot)) || isempty(sel_slot)
                            disknum = get_disk_num(obj.deviceListByEncl, jj, ii) ;
                            if ~isempty(disknum)  
                                if ii == obj.kMaxDisksInEnclosure
                                    kDrivePoolPath = '' ;
                                elseif ii == obj.kMaxDisksInEnclosure - 1
                                    kDrivePoolPath = input('Drive Pool path that was just created : (in single quotes) ? ') ;
                                end
                                add_disk_to_drive_pool(kDrivePoolPath, disknum) ;
                            end
                        end
                    end
                end
            end
        end



        function obj = find_missing_disks(obj)
            obj.missingDiskSlots = [] ;
            for ii=1:length(obj.attached_encl_ports)
                obj.missingDiskSlots{ii} = find_missing_disk_slots(obj.sortedTargetIds{ii},obj.kMaxDisksInEnclosure) ;
                if ~isempty(obj.missingDiskSlots{ii})
                    fprintf('***************\n')
                    fprintf('Disks in following slots of enclosure %d are missing\n', ii) ;
                    fprintf('***************\n')
                    obj.missingDiskSlots{ii}
                else
                    fprintf('No missing disks in enclosure %d\n', ii) 
                end
            end
        end



        % get enclosure serial numbers iteractively in ascending order of
        % the scsi ids and add therm to database
        % add the enclosures for the machine this code runs on
        function obj = add_all_enclosures_to_database(obj)
            [~, hn] = system('hostname');
            hn = strtrim(hn) ;
            if upper(hn) == upper(obj.hostname)
                for ii = 1 : length(obj.attached_encl_ports)
                    done = false ;
                    while ~done
                        cmd = sprintf('Provide serial number for enclosure attached to scsi port %d (in single quotes) ? ', obj.attached_encl_ports(ii)) ;
                        sernum = input(cmd) ;
                        if ~isempty(sernum)
                            cmd = sprintf('Is the scsci port %d enclosure serial number %s correct [0=No, 1=Yes] ? ', obj.attached_encl_ports(ii), sernum) ;
                            resp = input(cmd) ;
                            if ~isempty(resp) && resp == 1
                                % write to database
                                tp = [] ;
                                cmd = sprintf('servername like "%%%s%%"',obj.hostname) ;
                                tp = fetch(storage.Servers & cmd) ;
                                tp.unit_id = ii ;
                                tp.unit_sernum = sernum ;
                                done = true ;
                                tmp = fetch(storage.Units & tp) ;
                                if isempty(tmp)
                                    tp.scsi_port = obj.attached_encl_ports(ii) ;
                                    tp.num_slots = obj.kMaxDisksInEnclosure ;
                                    insert(storage.Units, tp) ;
                                    fprintf('Enclosure on scsci port %d has been added\n',tp.scsi_port)
                                else
                                    fprintf('This enclosure with SCSI Id %d exists in database\n', tp.scsi_port)
                                end
                            end
                        end
                    end
                end
            else
                fprintf('Hostname in the object is different from this host, encloses are not added\n')
            end
        end



        function obj = add_all_disks_to_database(obj)            
            [~, hn] = system('hostname');
            hn = strtrim(hn) ;
            if upper(hn) == upper(obj.hostname)
                cmd = sprintf('servername like "%%%s%%"',obj.hostname) ;
                key.servername = char(fetch1(storage.Servers & cmd, 'servername')) ;
                key.type = 'backup' ;
                units = fetch(storage.Units & key) ;
                [num_slots, unit_id] = fetchn(storage.Units & key, 'num_slots', 'unit_id') ;
                for ii = 1 : length(units)
                    for jj = 1 : num_slots(ii)
                        tp = units(ii) ;
                        tp.disk_id = get_disk_num(obj.deviceListByEncl, unit_id(ii), jj) ;
                        tp.disk_sernum =  get_serial_num(obj.deviceListByEncl, unit_id(ii), jj) ;
                        tmp = fetch(storage.Disks & tp) ;
                        if isempty(tmp)
                            tp.slot = jj ;
                            tp.size = get_disk_size(tp.disk_id) ;
                            insert(storage.Disks, tp) ;
                            fprintf('Disk %d in enclosure id %d and slot %d has been added\n', tp.disk_id,  unit_id(ii), jj)
                        else
                            fprintf('Tuple for disk in this enclosure %d and slot %d exists in the database, is skipped\n', unit_id(ii), jj)
                        end
                    end
                end
            else
                fprintf('Hostname in the object is different from this host, encloses are not added\n')
            end
        end


        % do this before the new serial number is manually updated using
        % mysql client(e.g. sequel pro on mac)
        function obj = add_replacement_disk_to_db(obj, olddisk_sernum, newdisk_sernum)
            tp = [] ;
            tp.disk_sernum = olddisk_sernum ;
            otp = fetch(storage.Disks & tp) ;
            if ~isempty(otp) && length(otp)==1
                rtp = [] ;
                rtp.old_disk_ser_num = olddisk_sernum ;
                rtp.new_disk_ser_num = newdisk_sernum ;
                insert(storage.Replacements, rtp) ;
            else
                fprintf('Unable to find the original disk in the database, plesase check serial number\n')
            end
        end



        function obj = add_all_volumes_to_database(obj)
            [~, hn] = system('hostname');
            hn = strtrim(hn) ;
            if upper(hn) == upper(obj.hostname)
                cmd = sprintf('servername like "%%%s%%"',obj.hostname) ;
                key.servername = char(fetch1(storage.Servers & cmd, 'servername')) ;
                key.type = 'backup' ;
                units = fetch(storage.Units & key) ;
                for ii=1:length(units)
                    key = units(ii) ;
                    disks = fetch(storage.Disks & key) ;
                    for jj=1:length(disks)
                        tp = disks(jj) ;
                        tp.volumename = get_disk_label(disks(jj).disk_id) ;
                        tp.online = 1 ;
                        tmp = fetch(storage.Volumes & tp) ;
                        if isempty(tmp)
                            insert(storage.Volumes, tp) ;
                            fprintf('Volume on disk %d has been added\n', disks(jj).disk_id) 
                        else
                            fprintf('Tuple for volume in this enclosure %d and disk id %d exists in database\n', units(ii).unit_id, disks(jj).disk_id)
                        end
                    end
                end
            end
        end



        function hostname = return_hostname(obj)
            hostname = obj.hostname ;
        end
        
    end
end