%% example script to run the toolbox
%% 0. Set pathname (to print results)
pathNm=setPathName;
mkdir(fullfile(pathNm,'figures'))
%% 1.1 Generate bodies
% Note that this step is the longest one
clear bodies;clc;close all;
PoreData_compressed % load data from Imperial college
target.pore_rad = PoreData(:,3)*1e6; % in microm
plotBod = 1; % set this to 0 to not plot bodies at the end of the generation process
maxPores = 10000;
target.size = 1000;
target.minSphereDist = 5; %  note that this is throat length as defined by the distance between spheres, not the distance between the two centers
target.porosity = 0.1;
% Optional: set a minimum body radius (0 if none)
% Generally not such a good idea
target.minRadBody = 0;
if target.minRadBody>0; target.pore_rad(target.pore_rad<target.minRadBody)=target.minRadBody; end;
tolFails=500;
tic;
[bodies,dist] = generateBodies(maxPores,target,plotBod,tolFails);
t=toc; fprintf('Generating bodies took %.2f seconds\n', t);
%title('Pore body radii')
%print(1, fullfile(pathNm,'figures', 'bodies.png'), '-dpng')
%% 1.2 Plot distribution for body radius
bodyRads = zeros(length(bodies),1);
for iBody = 1:length(bodies)
    bodyRads(iBody) = bodies{iBody}.rad;
end
vec{1} = bodyRads;
vec{2} = target.pore_rad;
figure(99); clf
setPlotJAC(99, 'graph')
kdeJAC(vec)
legend('generated','original')
%title('Pore body radii')
%print(99, fullfile(pathNm,'figures', 'bodyRad.png'), '-dpng')
%% 2.1 Generate throats
% Note that this process does not work every time - if the sample is deemed
% too difficult, the process will abort. If there are more than a couple
% aborts in a row, regenerating the bodies usually helps.
clear throats; clc; close all;
target.coord = PoreData(:,1);
target.coord_pdf = histc(target.coord,min(target.coord):max(target.coord));
throatData_compressed
target.throat_rad = throatData(:,1)*1e6; % in microm
target.throat_len = throatData(:,3)*1e6; % in microm
% generate target coordination number for each body
% Arbitrary truncation of the original distribution at 12 to avoid
% pathological cases
target.maxCoord = 12;
target.desired_coord = zeros(length(bodies),1);
for ii=1:length(bodies)
    target.desired_coord(ii) = min(target.coord(randi(length(target.coord),1)),target.maxCoord);
end
% Optional: choose minimum throat rad - set to zero if no constraint
% Generally not such a good idea
target.minRadThroat = 0; 
if target.minRadThroat>0; target.throat_rad(target.throat_rad<target.minRadThroat)=target.minRadThroat; end;
verb = 1;
tic;
[bodies,throats,coord,adj] = generateCylThroats(bodies,dist,target, verb);
t=toc; fprintf('Generating throats took %.2f seconds\n', t);
%% 2.2 Plot distribution for throat radius
throatRads = zeros(length(throats),1);
for iThroat = 1:length(throats)
        throatRads(iThroat)=throats{iThroat}.rad_throat;
end
vec{1} = throatRads;
vec{2} = target.throat_rad;
figure(99); clf
setPlotJAC(99, 'graph')
opt.kde_npoints=2^9;
kdeJAC(vec,opt)
legend('generated','original')
%title('Pore throat radii')
%print(99, fullfile(pathNm,'figures', 'throatRad.png'), '-dpng')
%% 2.3 Plot distribution for coordination number
adjtest = zeros(length(bodies));
for iThroat = 1:length(throats)
    adjtest(throats{iThroat}.bInfo{1}.bodyID,throats{iThroat}.bInfo{2}.bodyID)=...
        adjtest(throats{iThroat}.bInfo{1}.bodyID,throats{iThroat}.bInfo{2}.bodyID)+1;
end
adjtest=adjtest+adjtest';
coordtest = zeros(length(bodies),1);
for ii = 1:length(bodies)
    coordtest(ii) = sum(adjtest(ii,:));
end
vec{1} = coordtest;
vec{2} = target.coord;
figure(99); clf
setPlotJAC(99, 'graph')
opt.kde_npoints = 2^7;
kdeJAC(vec, opt)
legend('generated','original')
%title('Coordination number')
%print(99, fullfile(pathNm,'figures', 'coord.png'), '-dpng')
%% 2.5 Plot distribution for throat length
throatLength = zeros(length(throats),1);
for iThroat=1:length(throats)
    throatLength(iThroat)=throats{iThroat}.bInfo{1}.len_throat ...
        + throats{iThroat}.bInfo{2}.len_throat ...
        + bodies{throats{iThroat}.bInfo{1}.bodyID}.rad ...
        + bodies{throats{iThroat}.bInfo{2}.bodyID}.rad;
end
%hist(throatLength)
vec{1} = throatLength;
vec{2} = target.throat_len;
figure(99); clf
setPlotJAC(99, 'graph')
kdeJAC(vec)
legend('generated','original')
%title('Throat lengths')
%print(99, fullfile(pathNm,'figures', 'throatLen.png'), '-dpng')
%% 2.5 Plot results so far - throats and bodies
figure(1); clf
opt.color = 'same';
opt.lighting = 0;
plotBodies(bodies,opt);
opt.lighting = 1;
plotThroats(throats,opt);
%print(1, fullfile(pathNm,'figures', 'network.png'), '-dpng')
%% 3.1 Generate pore space object
tic;
pore = PoreSpace(bodies, throats);
t=toc; fprintf('Generating pore space took %.2f seconds\n', t);
%pore.plot3D;
%% 3.2 Plot correlation between pore radius and throat radius as in Idowu 2009
corr = zeros(length(pore.bodies),2);
for iBody = 1:length(pore.bodies)
    neighbor_throats = pore.bodies{iBody}.getNeighborThroats;
    neighbor_rads = zeros(length(neighbor_throats),1);
    for iThroat = 1:length(neighbor_throats)
        neighbor_rads(iThroat)=pore.throats{neighbor_throats(iThroat)}.rad_throat;
    end
    corr(iBody,1)=pore.bodies{iBody}.rad;
    corr(iBody,2)=mean(neighbor_rads);
end
figure(1); clf
setPlotJAC(1, 'graph')
hold all
plot(corr(:,1),corr(:,2), '.', 'MarkerSize', 10)
plot([1 100],[1 100], 'k')
set(gca, 'xlim', [1 100])
set(gca, 'ylim', [1 100])
set(gca, 'Xscale', 'log')
set(gca, 'Yscale', 'log')
axis square
ylabel('Average radius of connecting throats')
xlabel('Pore body radius')
print(1, fullfile(pathNm,'figures', 'bodyRadCorr.png'), '-dpng')
%% 3.3 Output final porosity
vol = pore.getVolume;
poro = vol/target.size^3;
fprintf('Final porosity is %.4f\n', poro)
%% 4. Save pore space for future use
save(fullfile(pathNm, ['pore' datestr(now) '.mat']), 'pore')