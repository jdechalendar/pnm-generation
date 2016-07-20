classdef CylThroat
    %%  class cylThroat
    %
    %   Cylindrical Throat - a class to contain cylindrical throat objects.
    %   This class is mainly used to visualize networks - and was not
    %   designed for simulation purposes like the ConThroat class.
    %   The main difference with the ConThroat class is in the setRad_TB
    %   function. The radius of the throat is now the same everywhere.
    
    %%
    properties
        ID % an ID for the throat
        rad_throat % radius of throat at center
        bInfo % array to contain information about the neighboring bodies
        pos % position of center of throat
    end
    methods
        function obj = CylThroat(ID, rad, bodies, pos) % constructor
            % if you do not provide a position, we try to set it automatically
            if nargin>2
                obj.ID = ID;
                checkRad(obj,rad,bodies); % basic check that radius is valid
                obj.rad_throat = rad;
                % set position of throat if not provided
                if nargin==3
                    if length(bodies)==2
                        % in the middle between the two spheres
                        dir = (bodies{1}.pos-bodies{2}.pos)/norm(bodies{1}.pos-bodies{2}.pos);
                        pt1 = bodies{1}.pos-bodies{1}.rad*dir;
                        pt2 = bodies{2}.pos+bodies{2}.rad*dir;
                        pos = mean([pt1;pt2]);
                    elseif length(bodies)==1; error('If there is only one body a throat position must be supplied!');
                    else% if more than two bodies are connected by this throat
                        % first approx use barycenter of bodies
                        % note that this doesn't always work, you could get
                        % a point inside one of the bodies in the
                        % pathological case
                        % if this starts happening, I could use the
                        % barycenter between the pairwise positions as
                        % defined by the previous case
                        bodArray = [bodies{:}];
                        pos = mean(reshape([bodArray.pos], 3, length(bodies))');
                    end
                    
                end
                % basic check
                if length(pos)~=3; error('pos must have 3 coordinates'); end;
                obj.pos = pos;                    
                
                % set information about neighboring bodies
                obj.bInfo=cell(length(bodies),1);
                for iBody = 1:length(bodies)
                    % set throat properties that depend on the neighboring
                    % bodies
                    obj.bInfo{iBody}=BodyInfo(bodies{iBody}.ID);
                    obj.bInfo{iBody}.rad_body = setRad_TB(obj);
                    obj.bInfo{iBody}.len_throat = setLengthThroat(obj,bodies{iBody});
                    obj.bInfo{iBody}.direction = setDirThroat(obj,bodies{iBody});
                    obj.bInfo{iBody}.phiWall = calculatePhi(obj,bodies{iBody});
                    obj.bInfo{iBody}.pos = setbInfoPos(obj,bodies{iBody}, iBody);
                end
            end
        end
        function bInfo = getbInfo(obj,bodyID)
            bInfo = [];
            for iBody = 1:length(obj.bInfo)
                if obj.bInfo{iBody}.bodyID == bodyID
                    bInfo = obj.bInfo{iBody};
                end
            end
            if isempty(bInfo)
                error('Unexpected case');
            end
        end
        function phi = getPhi(obj,bodyID)
            phi = obj.getbInfo(bodyID).bInfo.phiWall;
        end
        function rad_TB = getRad_TB(obj,bodyID)
            rad_TB = obj.getbInfo(bodyID).rad_body;
        end
        function vol = getVolume(obj)
            vol = 0;
            for iBody = 1:length(obj.bInfo)
                vol = vol+volConicalFrustrum(obj.bInfo{iBody}.rad_body, ...
                    obj.rad_throat, ...
                    obj.bInfo{iBody}.len_throat);
            end
        end
        function fv = getPartialPatch(obj,bodyID, pos1d, nPts)
            curr_bInfo = obj.getbInfo(bodyID);
            if ~exist('nPts', 'var'); nPts = 50; end; % default value
            start_cylinder = curr_bInfo.pos;
            R_generator=[curr_bInfo.rad_body, ...
                obj.getRad_Tube(bodyID,pos1d)];
            fv = myCylinder(R_generator,nPts,start_cylinder, curr_bInfo.direction, curr_bInfo.len_throat*pos1d);
        end
        function rad = getRad_Tube(obj, bodyID,pos1d)
            if pos1d>1 ||pos1d<0;error('Pos1d should be in [0,1]'); end;
            curr_bInfo = obj.getbInfo(bodyID);
            rad = interp1q([0 1]',[curr_bInfo.rad_body obj.rad_throat]', pos1d);
        end
        function rad = getRad_Interface(obj,bodyID, pos1d, theta)
            rad = obj.getRad_Tube(bodyID,pos1d)/(cos(theta+obj.getPhi(bodyID)));
        end
        function dist = getDistance(obj, bodyID1, bodyID2)
            if length(obj.bInfo)<2; error('cannot call this method if throat only has one body'); end;
            dist = obj.getbInfo(bodyID1).len_throat + obj.getbInfo(bodyID2).len_throat;
        end
    end
    methods (Access = private) % methods used by the class constructor
        function checkRad(obj,rad,bodies)
            for iBody = 1:length(bodies)
                if bodies{iBody}.rad<rad
                    error('Radius of throat %i is bigger than that of connecting body %i',obj.ID,bodies{iBody}.ID)
                end
            end
        end
        function len = setLengthThroat(obj,body)
            len = norm(body.pos-obj.pos) - body.rad;
            if len<0
                error('Throat %i has a negative length: %.2f\n',obj.ID, len)
            end
        end
        function rad = setRad_TB(obj)
            % NOTE: this function is the major difference between the CylThroat and
            % the ConThroat class
            rad = obj.rad_throat; % the radius of the throat is constant in the cylindrical throat case
        end
        function dir = setDirThroat(obj,body)
            dir = obj.pos-body.pos;
            dir = dir/norm(dir);
        end
        function phi = calculatePhi(obj,bod)
            phi = atan((bod.rad-obj.rad_throat)/(norm(bod.pos-obj.pos)));
            if phi<0.001
                error('Throat %i: Body %i - phi (aspect ratio) cannot be negative: %.2f',obj.ID,bod.ID, phi)
            end
        end
        function pos = setbInfoPos(obj, body, iBody)
            pos = body.pos+obj.bInfo{iBody}.direction*body.rad;
        end
    end 
end
%%