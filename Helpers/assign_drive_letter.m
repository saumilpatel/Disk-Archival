% assign a drive letter for a partition, in DrivePool, partion 2 is the
% primary partition
function [status,output] = assign_drive_letter(drive_num, partition_num, letter)

    cmd = sprintf('powershell "Set-Partition -DiskNumber %d -PartitionNumber %d -NewDriveLetter %s"', drive_num, partition_num, letter) ;
    [status, output] = system(cmd) ;
end