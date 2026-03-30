function setPath
% anatomical areas object's path

warning off MATLAB:dispatcher:nameConflict % turns off warning about name overloading

base = fileparts(mfilename('fullpath'));
addpath(fullfile(base, 'schemas'));
addpath(fullfile(base, 'Helpers'));
currdir = pwd ;
cd 'Z:\home\atlab\monkey' ;
setPath
cd(currdir) ;
