classdef Body
    %%  class Body
    %   A body is assumed to have a spherical shape
    
    %%
    properties
        ID % an ID for the body
        rad % radius of the body
        pos % position of the center of the body
        neighbor_list_throats
    end
    methods
        function obj = Body(ID,r, pos) % constructor
            if nargin>0
                if nargin~=3
                    error('Incorrect number of arguments')
                end
                obj.ID = ID;
                obj.rad=r;
                obj.pos=pos;
            end
        end
        function fv = getPatch(obj,nPts)
            if ~exist('nPts', 'var'); nPts = 10; end; % default value
            fv = mySphere(obj.rad, nPts, obj.pos);
        end
        function vol = getVolume(obj)
            vol = volSphere(obj.rad);
        end
        function neighbor_list_throats = getNeighborThroats(obj)
            % neighbor_list_throats is a list of the neighboring throats
%             neighbor_list_throats = zeros(length(pore.throats),1);
%             for iThroat = 1:length(pore.throats)
%                 if ~isempty(pore.throats{iThroat})
%                     bInfos = [pore.throats{iThroat}.bodyInfo{:}];
%                     if any([bInfos.bodyID] == obj.ID)
%                         neighbor_list_throats(iThroat)=1;
%                     end
%                 end
%             end
%             neighbor_list_throats = find(neighbor_list_throats);
            % JAC - changed July 11, 2016 to avoid looping over throats
            neighbor_list_throats = obj.neighbor_list_throats;
        end
        function [neighbor_list_bodies, dist, throatID] = getNeighborBodies(obj,pore)
            % neighbor_list_bodies is the list of neighboring bodies
            % dist is the list of distances to the neigboring bodies
            % throatID is the list of IDs of the throats to get to the
            % neighboring bodies
            neighbor_list_bodies = [];
            dist = [];
            throatID = [];
            neighbor_list_throats_tmp = obj.getNeighborThroats();
            for iThroat = 1:length(neighbor_list_throats_tmp)
                myThroat = pore.throats{neighbor_list_throats_tmp(iThroat)};
                for iBody = 1:length(myThroat.bodyInfo)
                    if myThroat.bodyInfo{iBody}.bodyID ~= obj.ID
                        neighbor_list_bodies(length(neighbor_list_bodies)+1) = myThroat.bodyInfo{iBody}.bodyID;
                        dist(length(dist)+1) = myThroat.getDistance(obj.ID,myThroat.bodyInfo{iBody}.bodyID);
                        throatID = [throatID neighbor_list_throats_tmp(iThroat)];
                    end
                end
            end
        end
        function vol = getVolNeighbors(obj,pore)
            % volume of the body + available volume in the neighboring
            % throats. The throat with the biggest radius defines the available
            % volume in each throat
            vol = obj.getVolume;
            neighbor_list_throats_tmp = obj.getNeighborThroats();
            [limitingThroatID, ~] = obj.findLimitingThroat(pore);
            rad_max_tube = pore.throats{limitingThroatID}.rad_throat;
            % rad_max is the radius that is filled first
            for iThroat = 1:length(neighbor_list_throats_tmp)
                myThroat = pore.throats{neighbor_list_throats_tmp(iThroat)};
                bInfo = myThroat.getBodyInfo(obj.ID);
                R1 = bInfo.rad_body;
                h = interp1q([myThroat.rad_throat R1]', [bInfo.len_throat 0]', rad_max_tube);
                vol = vol + volConicalFrustrum(R1,rad_max_tube,h);
            end
        end
        function [throatID, rad_int] = findLimitingThroat(obj, pore) % this could be made a bit faster by storing results and only looking the first time
            neighbor_list_throats_tmp = obj.getNeighborThroats();
            rad_interface_lim_neigh = zeros(size(neighbor_list_throats_tmp));
            for iN = 1:length(neighbor_list_throats_tmp)
                rad_interface_lim_neigh(iN) = pore.throats{neighbor_list_throats_tmp(iN)}.getRad_Interface(obj.ID,1); % interface at end of pore
            end
            [rad_int,ind] = max(rad_interface_lim_neigh);
            throatID = neighbor_list_throats_tmp(ind);
        end
    end
end
%%