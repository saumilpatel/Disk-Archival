%{
# disk replacement details
old_disk_ser_num : varchar(255)         # old serial number of the disk
new_disk_ser_num : varchar(255)         # new serial number of the disk
-----
ts = CURRENT_TIMESTAMP : timestamp # tuple insertion time
%}

classdef Replacements < dj.Manual
end