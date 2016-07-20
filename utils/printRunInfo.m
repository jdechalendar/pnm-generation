function printRunInfo(fID, headerStr)
%printRunInfo   Print some information about the current run
%
% JAC - Aug 20 2015

if ~exist('headerStr', 'var')
    headerStr = '';
end

call_stack = dbstack;
tabbing = '';
for i=1:length(call_stack)-1
    tabbing = [tabbing '    '];
end
fprintf(fID,'\n%s***************************************\n', tabbing);
% print the name of the function that called this one
fprintf(fID,'%sLog from function %s\n', tabbing, call_stack(2).name);

fprintf(fID,'%sThe date stamp is: %s\n', tabbing, datestr(now));
fprintf(fID, headerStr);
fprintf(fID,'%sJAC - jdechale@stanford.edu\n', tabbing);
fprintf(fID,'%s***************************************\n', tabbing);