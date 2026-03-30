%{
# details of files on a volume in jbod
-> storage.Volumes
filename : varchar(1500)           # name of the file
-----
created : varchar(64)              # data and time of creation
modified : varchar(64)             # date and time of last modification
size : double                      # size in giga bytes
ts = CURRENT_TIMESTAMP : timestamp # tuple insertion time
%}

classdef Files < dj.Manual
end