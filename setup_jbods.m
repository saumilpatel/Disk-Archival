% associate specific slots in jbod enclosure to disks
% assumes two enclosures (A and B) are attached to each backup server

kMaxEncl = 2 ;
kMaxDisksInEnclosure = 60 ;
kMaxSerNumLength = 16 ; % this needs to be found empirically because manufacturers can change their serial number specs, current specs are that both Western Diogital and Seagate have 8 char serial numbers

drivePool = jbod.DrivePool(kMaxEncl, kMaxDisksInEnclosure) ;

% get host name
drivePool =  get_hostname(drivePool) ;

doSave = input('Save results [0=no,1=yes]? ') ;
if isempty(doSave)
    doSave = 0 ;
end

doInit = input('Initialize Disks [0=no,1=yes]? ') ;
if isempty(doInit)
    doInit=false ;
end

doFormat = input('Format disks ? [0=No, 1=Yes] ? ') ;
if isempty(doFormat)
    doFromat = false ;
end


doAddToDrivePool = input('Add to Drive Pool ? [0=No, 1=Yes] ? ') ;
if isempty(doAddToDrivePool)
    doAddToDrivePool = false ;
end

drivePool = get_attached_encl_ports(drivePool) ;

% initialize and make all disks online
if doInit
    drivePool = all_disks_online(drivePool) ;
end

% get info about all the disks
% associate disks with enclosures
drivePool = get_device_list(drivePool) ;

% group by SCSIPort, i.e. by enclosure
drivePool = get_device_list_by_encl(drivePool) ;

% sort by TargetId, get TargetIds first
drivePool = get_sorted_device_list_by_encl(drivePool) ;

% format disks in all enclosures
% selected encl(sel_encl) and slots (sel_slot) must be empty vectors for all encl and slots to
% be processed
if doFormat
    sel_encl = [] ; % one enclosure at a time if selection is necessary for any disk that was missed
    sel_slot = [] ;
    drivePool = format_disks_in_all_encl(drivePool, sel_encl, sel_slot) ;
end

% add formatted disks to drive pool
sel_encl = [] ; % one enclosure at a time if selection is necessary for any disk that was missed
sel_slot = [] ;
if doAddToDrivePool
    drivePool = add_formatted_disk_to_drive_pool(drivePool, sel_encl, sel_slot) ;
end

% find missing disk slots in all enclosures
drivePool = find_missing_disks(drivePool) ;

% save the whole object
if doSave == 1
    fn = sprintf('drivePoolObject_%s', return_hostname(drivePool)) ;
    save(fn, 'drivePool') ;
end

