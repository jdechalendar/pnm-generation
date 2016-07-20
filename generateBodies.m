function [bodies,dist] = generateBodies(maxBodies,target,plotBod,tolFails)
%%  [bodies,dist] = generateBodies(maxBodies,target,plotBod,tolFails)
%   generates a set of 

%% unpack target size
if length(target.size)==1
    target.size= target.size*ones(3,1);
end
x_network = target.size(1);
y_network = target.size(2);
z_network = target.size(3);

% initialize variables
cnt_fail = zeros(maxBodies,1);
bodies = cell(1,maxBodies);
dist = zeros(maxBodies);
vol = 0;
poro = 0;
iBody = 1;

fprintf('Generating bodies\n')
% start body creation loop
while iBody < maxBodies && poro<target.porosity
    % generate radius for Body by selecting at random in target distribution
    r_pore = target.pore_rad(randi(length(target.pore_rad),1));
%     if r_pore>target.minRadBody
        cont = 1;
%     else
%         % if we are smaller than minRadBody don't bother generating this
%         % one
%         cont = 0;
%     end
    % loop to find position of new body such that it fits requirements
    while cont
        cont = 0;
        % generate position at random
        pos = [rand(1)*x_network rand(1)*y_network rand(1)*z_network];
        % generate a candidate based at this position
        candidateBody = Body(iBody, r_pore, pos);
        % test whether candidate fits requirements
        dist(iBody,:) = zeros(1,maxBodies);
        fail = 0;
        for jBody = 1:iBody-1
            %dist(iBody,jBody) = norm(candidateBody.pos-bodies{jBody}.pos)-bodies{jBody}.rad-candidateBody.rad;
            dist(iBody,jBody) = norm(candidateBody.pos-bodies{jBody}.pos);
            if dist(iBody,jBody)-bodies{jBody}.rad-candidateBody.rad<target.minSphereDist; fail = 1; break; end;
        end
        if fail
            % record number of fails
            cnt_fail(iBody) = cnt_fail(iBody)+1;
            % try again
            cont =1;
        else
            % store the new body - update global variables
            bodies{iBody} = candidateBody;
            vol = vol + bodies{iBody}.getVolume;
            poro = vol/(x_network*y_network*z_network);
            iBody = iBody + 1;
        end
        % check number of fails - if too high, try another radius
        if cnt_fail(iBody)>tolFails; fprintf('Too many fails for body %i\n',iBody); cont=0; end;
    end
end
fprintf('Done generating %i bodies\n', iBody)

% reshape bodies array to remove empty entries
bodies = bodies(~cellfun('isempty',bodies));

% also reshape distance matrix
dist = dist(1:iBody-1,1:iBody-1);
dist = dist+dist';

% plot bodies and summary stats
if plotBod && ~isempty(bodies)
    opt.color = '';
    plotBodies(bodies,opt)
end
fprintf('Porosity is %.2f %% \n', poro)
%%