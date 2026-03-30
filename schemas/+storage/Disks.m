%{
# details of disk in a jbod unit
-> storage.Units
disk_id : int                      # some identifier of the disk in a jbod unit
disk_sernum : varchar(255)         # serial number of the disk in a jbod unit
-----
slot : int                         # slot in the jbod unit
size : float                      # size in terra bytes
ts = CURRENT_TIMESTAMP : timestamp # tuple insertion time
%}

classdef Disks < dj.Manual
end