%{
# details of volume on a disk in jbod
-> storage.Disks
volumename : varchar(255)          # name of the volume
-----
online = 1 : tinyint               # 1 if volume is online in the unit
ts = CURRENT_TIMESTAMP : timestamp # tuple insertion time
%}

classdef Volumes < dj.Manual
end