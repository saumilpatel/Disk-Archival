% assumes setup_jbods is run and DrivePool object is saved prior to running this script

% load the DrivePool object
[~, hn] = system('hostname');
hn = strtrim(hn) ;
fn = sprintf('drivePoolObject_%s', hn) ;
load(fn, 'drivePool') ; % drivePool is the instantiated DrivePool object



% insert enclosure serial number for this server
output = input('Add all enclosures [0=No, 1=Yes] ?') ;
if output == 1
    drivePool = add_all_enclosures_to_database(drivePool) ;
end

% insert all disks information for this server
output = input('Add all disks [0=No, 1=Yes] ?') ;
if output == 1
    drivePool = add_all_disks_to_database(drivePool) ;
end

% insert all volumes for this server
output = input('Add all volumes [0=No, 1=Yes] ?') ;
if output == 1
    drivePool = add_all_volumes_to_database(drivePool) ;
end