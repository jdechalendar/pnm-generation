function [bodies,throats,coord,adj] = generateCylThroats(bodies,dist,target, verb)
%%  [bodies,throats,coord,adj] = generateCylThroats(bodies,dist,target)
%   generates cylindrical throats
%   Inputs are:
%       - a set of bodies
%       - a target distribution for the coordination number for the bodies
%       - a target distribution for the throat lengths
%       - a target distribution for the throat radii
%       - a constraint on the minimum throat radius (arbitrary)
%
%   We first generate the connection tree to satify the coordination and
%   throat length distribution targets. We then sample from the target
%   distribution for the throat radii and assign those to the generated
%   links.

%% generate connections
% initialize connection tree
ST=sparse(length(dist),length(dist));
% densify tree based on required coord number
T = densifytree(dist,ST, target.desired_coord, target.throat_len, verb);
%% initialize variables
throats = cell(length(bodies)-1,1);
coord = zeros(length(bodies),1);
adj = eye(length(bodies));
%% choose radii of throats
nThroats = full(sum(sum(T>0)));
fprintf('There should be %i throats at the end\n',nThroats)
rad_throat = zeros(nThroats,1);
for ii = 1:nThroats
    rad_throat(ii) = target.throat_rad(randi(length(target.throat_rad),1));
end
rad_throat = sort(rad_throat);
[startBody,endBody] = find(T);
% compute max throat radii
throatWeights = computeThroatWeights(startBody,endBody,bodies,nThroats);
[~,sortid] = sort(throatWeights);
% assign and check if this is feasible
rad_throat(sortid)=rad_throat;
if any(rad_throat>throatWeights)
    fprintf('There are %.2f%% of chosen throat radii that are too big to fit\n',...
        100*sum(rad_throat>throatWeights)/length(rad_throat))
    probThroats = find(rad_throat>throatWeights);
    rad_throat(probThroats) = 0.8*rad_throat(probThroats);
    fprintf('Making these 80%% of their original size\n')
    if any(rad_throat>throatWeights)
        error('there does not seem to be enough "space" -> try again')
    end
end
%% generate throats
for iThroat = 1:nThroats
    %rad= 5;
    try
        throats{iThroat} = CylThroat(iThroat, rad_throat(iThroat),{bodies{startBody(iThroat)},bodies{endBody(iThroat)}});
    catch ME
        fprintf(printError(ME));
    end
end

% clean failures
throats= throats(~cellfun('isempty',throats));
end

%% function to densify the spanning tree so that the coordination number matches the target distribution
function T = densifytree(dist,ST, target_coord, targetThroatLen, verb)
% define max throat length
maxThroatLen = max(targetThroatLen);
% sort coord target
target_coord = sort(target_coord, 'descend');
% compute a weight for each body
bodyWeights = computeBodyWeights(dist, target_coord(1));
[~,idsort]=sort(bodyWeights, 'ascend');
bodyCoord = zeros(size(target_coord));
% assign coordination numbers to bodies based on their weight
bodyCoord(idsort) = target_coord;

MST_coord = getcoord(ST); % coordinations we already have in the starting tree
todo_coord = bodyCoord-MST_coord;
curr_coord = MST_coord;
if any(todo_coord<0)
    fprintf('Body %i has %i extra connections\n',[find(todo_coord<0) - todo_coord(todo_coord<0)]');
end
fprintf('Starting tree densification process\n');
adj = getadjacency(ST)+eye(size(ST,1));
while sum(todo_coord>0)>1
    % choose a body at random
    ids = find(todo_coord>0);
    iBody = ids(randi(length(ids),1));
    %[~,idsort] = sort(dist(iBody,:),'ascend');
    targetLen = targetThroatLen(randi(length(targetThroatLen),1));
    [sortedDist,idsort] = sort(abs(dist(iBody,:)-targetLen*ones(size(dist(iBody,:)))),'ascend');
    % find who to connect with him
    candidate = 1;
    while adj(idsort(candidate),iBody) || todo_coord(idsort(candidate))<1
        candidate = candidate+1;
        if candidate>size(adj,1)
            warning('Impossible to find a connection for body %i - there are %i remaining coords\n',iBody,sum(todo_coord>0));
            fprintf('Printing the remaining deviations from the target distribution\n');
            fprintf('Body %i has a non-zero todo_coord of %i\n',[find(todo_coord~=0) todo_coord(todo_coord~=0)]');
            break;
        end
    end
    todo_coord(iBody)=todo_coord(iBody)-1; % so that we don't get stuck in the loop if this wasn't successful
    if candidate<=size(adj,1) && dist(iBody,idsort(candidate)) < maxThroatLen
        % store connection
        todo_coord(idsort(candidate))=todo_coord(idsort(candidate))-1;
        curr_coord(iBody) = curr_coord(iBody)+1;
        curr_coord(idsort(candidate)) = curr_coord(idsort(candidate))+1;
        adj(idsort(candidate),iBody)=1;
        adj(iBody,idsort(candidate))=1;
        if verb
            fprintf('Difference with chosen length is %.2f - was %ith closest match\n',sortedDist(candidate),candidate)
            fprintf('Length of throat is %.2f, target was %.2f\n',dist(iBody,idsort(candidate)),targetLen)
        end
    else
        break;
    end
end
T=sparse(tril(adj)-eye(size(adj,1)));
if sum(abs(bodyCoord-getcoord(T)))>0
    fprintf('There are %i deviations from the target distribution\n',sum(abs(bodyCoord-getcoord(T))))
end
end

%% function to get coordination number of a tree
function coord = getcoord(T)
% convert to adjacency matrix
adj = getadjacency(T);
if ~issymmetric(adj)
    error('adjacency matrix must be symmetric')
end
coord = full(sum(adj))';
end

%% function to get weights of bodies based on arbitrary rule
% the weight is the distance of the n-th closest neighbor
function weights = computeBodyWeights(dist,n)
if istril(dist)
    dist=dist+dist';
end
if ~issymmetric(dist)
    error('adjacency matrix must be symmetric')
end
weights=zeros(size(dist,1),1);
for ii = 1:size(dist,1)
    sortedDist = sort(dist(:,ii), 'ascend');
    weights(ii) = sortedDist(n);
end
end

function throatWeights = computeThroatWeights(startBody,endBody,bodies,nThroats)
throatWeights = zeros(nThroats,1);
for kk = 1:nThroats
    throatWeights(kk)= min(bodies{startBody(kk)}.rad,bodies{endBody(kk)}.rad);
end
end


%% function to get the adjacency matrix of the tree
function adj = getadjacency(ST)
% convert to adjacency matrix
ST=+(ST>0);
if istril(ST)
    ST=ST+ST';
end
adj = ST;
end


%%
