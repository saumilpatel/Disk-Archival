% catalog all disks in the system by specifying the range of disk numbers
tic

kMaxBooths = 3 ;
kPartitionNumber = 2 ; % in all drives in drive pool, the partion where files are stored is fixed

booth = input('Booth number [eg 1] ? ') ;
assert(booth <= kMaxBooths, 'Booth number out of range\n') ;

% check the disk management gui in the system to determine the range
% 1 to 120 for booth 1
% 0 to 119 for booth 2
% 0 to 119 for booth 3
disk_id_range_low = input('Lowest disk number [eg 0] ? ') ;
disk_id_range_high = input('Highest disk number [eg 120] ? ') ;

disk_id_range = [disk_id_range_low:disk_id_range_high] ; % in some systems it can be 0 thru 119 and in some 1 thru 120 - note there are two JBOD units connected per system

for ii=1:length(disk_id_range)
    disk_id = disk_id_range(ii) ;
    catalog_drive(booth, disk_id, kPartitionNumber) ;
    fprintf('******************************************************\n')
    fprintf('Processed Disk Number %d for booth %d\n', disk_id, booth) ;
    fprintf('******************************************************\n')
end

toc