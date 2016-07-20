classdef BodyInfo
    %%  class BodyInfo
    %   to store stuff about the neighboring body that the throat needs to know
    %
    
    %%
    properties
        % NB the following properties are set when the pore space is initialized
        bodyID % this is the ID of the body in the pore object
        rad_body % this is the radius of the throat near the body
        len_throat % this is the length of the throat - not the distance between the throat and body centers
        pos % this is the position of the base of the conical frustrum - not the body position
        phiWall % this is the angle of the cone - must be between 0 and 90 deg-theta
        direction % from center of throat pointing towards the body
    end
    methods
        function obj = BodyInfo(bodyID)
            if nargin>0
                obj.bodyID = bodyID;
            end
        end
    end
end
%%