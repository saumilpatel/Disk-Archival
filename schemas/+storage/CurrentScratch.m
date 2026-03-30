%{
# table that holds the pointer to current scratch drives
-> storage.Booths                          # booth number
host : varchar(255)                        # full  name of server
sharename : varchar(32)                    # name of the network share
type : enum("Ephys_Behavior","Imaging")    # storage or backup
-----
filesystem : enum("SMB","NFS")             # file system used for netwrok sharing
linux_mnt : varchar(255)                   # mount point in linux
%}

classdef CurrentScratch < dj.Manual
end