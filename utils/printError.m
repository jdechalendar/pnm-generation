function message = printError(ME)
%printError print error message
%   message = printError(ME) returns a string with the message and call
%   stack from the matlab error structure. This function was written to
%   produce messages in try/catch statements.
%   
%   JAC - Aug 18 2015
message = sprintf('%s\n',ME.message);
for i = 1 : length(ME.stack)
    message = [message sprintf('In: %s at line %i\n', ME.stack(i).name, ME.stack(i).line)];
end
end