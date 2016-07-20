classdef PoreSpace
    %%  class PoreSpace
    %   Wrapper class to store the bodies and throats in a pore space. On
    %   initialization, the constructor also sets the neighbor_list_throats
    %   property for each body. This list contains the IDs of the throats
    %   that neighbor the body. Preallocating in this way makes later
    %   computations faster.
    
    %%
    properties
        bodies
        throats
    end
    methods
        function obj = PoreSpace(bodies, throats) % constructor
            if nargin>1
                obj.bodies = bodies;
                obj.throats = throats;
            end
            obj = obj.reindexThroats();
            obj = obj.setNeighborThroats();
        end
        %%
        plot3D(obj, hfig) % plot the pore space
        plot2Dsection(obj,bodyID, throatID) % plot key variables along the section of a throat
        %%
        function [bodyIDs, throatIDs] = getNeighborThroats(obj, bodyIDlist)
            if ~obj.areNeighbors(bodyIDlist)
                error('the bodies in the list are not 1st order connected')
            end
            % function to get the neighboring throats of a group of bodies
            if length(bodyIDlist)==1
                throatIDs = obj.bodies{bodyIDlist}.getNeighborThroats(obj);
                bodyIDs = bodyIDlist*ones(size(throatIDs));
            else
                error('Haven''t done the multiple body spanning case yet')
            end
        end
        %%
        function conn = areNeighbors(obj, bodyIDlist)
            % this should return a bool determining whether bodies in the list are all neighbors - for use with clusters spanning multiple bodies
            if length(bodyIDlist)==1
                conn = 1;
            else
                error('Haven''t done the multiple body spanning case yet')
            end
        end
        function vol = getVolume(obj)
            vol = 0;
            for iBody = 1:length(obj.bodies)
                vol = vol+ obj.bodies{iBody}.getVolume;
            end
            for iThroat = 1:length(obj.throats)
                vol = vol+ obj.throats{iThroat}.getVolume;
            end
        end
    end
    methods (Access = private) % methods used by the class constructor
        % note that the this function should not be called more than once,
        % which is why it is protected here and can only be called by the
        % constructor
        function obj=setNeighborThroats(obj)
            % function to set the neighbor_list_throats attribute for each
            % body - call this once after creating the pore space as it
            % will make the finding the throats that are neighbors to a
            % body more efficient subsequently. Note that this is not ideal
            % and I would rather use pointers to change this attribute
            % during throat creation, but Matlab does not seem to have
            % pointers.
            for iThroat = 1:length(obj.throats)
                for iBody = 1:length(obj.throats{iThroat}.bInfo)
                    obj.bodies{obj.throats{iThroat}.bInfo{iBody}.bodyID}.neighbor_list_throats = ...
                        [obj.bodies{obj.throats{iThroat}.bInfo{iBody}.bodyID}.neighbor_list_throats obj.throats{iThroat}.ID];
                end
            end
            % checking
            for iBody = 1:length(obj.bodies)
                if length(unique(obj.bodies{iBody}.neighbor_list_throats))~=length(obj.bodies{iBody}.neighbor_list_throats)
                    error('There is a problem')
                end
            end   
        end
        function obj = reindexThroats(obj)
            % we reindex the throats in the PoreSpace object to make
            % accessing them easier. One reason we need to do this is that
            % during throat generation, some throats are discarded as
            % invalid and their index no longer corresponds to their
            % position in the throats array
            for iThroat = 1:length(obj.throats)
                obj.throats{iThroat}.ID = iThroat;
            end
        end
    end
end
%%