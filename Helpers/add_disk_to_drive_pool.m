% add a volume to drive pool
function [status, output] = add_disk_to_drive_pool(drive_pool_path, disk_num)
    if ~isempty(drive_pool_path)
        cmd = sprintf('dpcmd add-poolpart %s %s', get_volume_path(disk_num), drive_pool_path) ;
    else
        cmd = sprintf('dpcmd add-poolpart %s', get_volume_path(disk_num)) ;
    end

    [status, output] = system(cmd) ;
    
    if status ~= 0
        fprintf('Drive %d not added to drive pool %s\n', disk_num, drive_pool_path)
    else
        fprintf('Drive %d added to Drive Pool %s successfully, if this was the first drive, please check the drive pool drive letter created for this pool\n', disk_num, drive_pool_path)
    end
end