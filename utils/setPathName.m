function pathName = setPathName(rootdir)
%setPathName    set the pathName variable
%   pathName = setPathName prompts the user to choose a directory using a
%   GUI
%
%   pathName = setPathName(rootdir) prompts the user to choose a directory
%   using a GUI. Starts at rootdir
%
%   JAC - July 25 2015

if ~exist('rootdir', 'var')
    rootdir=pwd;
end
pathName = uigetdir(rootdir);
if nargout == 0
    disp('WARNING: no path variables were returned')
end