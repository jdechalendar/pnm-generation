---
output: html_document
references:
- id: idowu
  title: "Pore-Scale modeling: Stochastic network generation and modeling of rate effects in water flooding"
  author:
  - family: Idowu
    given: Nasiru Abiodun
  container-title: A dissertation submitted in fulfillments of the requirements for the Degree of Philosophy of the Imperial College London
  issued:
    year: 2009
- id: blunt
  title: Flow in porous media — Pore-Network Models and multiphase flow
  author:
  - family: Blunt
    given: Martin
  container-title: Current opinion in colloid \& interface science
  volume: 6
  issue: 3
  page: 197-207
  type: article-journal
  issued:
    year: 2001
  publisher: Elsevier
- id: hunt
  title: Applications of percolation theory to porous media with distributed local conductances
  author:
  - family: Hunt
    given: AG
  container-title: Advances in Water Resources
  volume: 24
  issue: 3
  page: 279-307
  type: article-journal
  issued:
    year: 2001
  publisher: Elsevier
- id: oren
  title: Extending predictive capabilities to network models
  author:
  - family: Oren
    given: P-E
  - family: Bakke
    given: Stig
  - family: Arntzen
    given: Ole Jako
  container-title: SPE Journal
  volume: 3
  issue: 04
  page: 324-336
  type: article-journal
  issued:
    year: 1998
  publisher: Society of Petroleum Engineers
- id: sok
  title: "Direct and stochastic generation of network models from tomographic images: effect of topology on residual saturations"
  author:
  - family: Sok
    given: R.M.
  - family: Knackstedt
    given: M.A
  - family: Sheppard
    given: A.P.
  - family: Pinczewski
    given: W.V.
  - family: Lindquist
    given: W.B.
  - family: Venkatarangan
    given: A.
  - family: Paterson
    given: L.
  container-title: Transport in Porous Media
  volume: 46
  page: 345-371
  type: article-journal
  issued:
    year: 2002
  publisher: Springer
---
# Synopsis
This MATLAB toolbox contains tools to generate stochastic pore network models. In the pore network model representation, the pore space is a graph whose nodes are called bodies and edges are called throats. Also provided are class definitions for bodies, throats and a wrapper class for the pore space. We provide brief descriptions of important classes later in this document.

# Motivation
A review of pore network modeling from the 1950s to 2001 is in [@blunt]. Pore network models have extensively been used to simulate the dynamic flow of fluids through porous media (see [@oren] for example), as well as percolation type processes. A review of percolation-type applications is in [@hunt].
Stochastic pore network models are pore network models with statistical properties that match those of networks extracted from images of real rocks. Different methods have been proposed to generate stochastic pore network models [@sok], [@idowu]. An implementation of the algorithm in the second reference was made available online but the throat length distribution does not match the input. We propose a new algorithm below that is specifically designed to match target distributions for certain properties of the network, such as body or throat radii.

# Pore network generation algorithm

**Generate bodies**
This step uses as main inputs the size of the domain in which to generate the pore space, a target distribution for body radius and the contribution of the bodies to the total required porosity (half the required porosity is usually good enough, this can be tuned). Bodies are generated at random positions using uniform sampling in the domain and assigned a radius from the target distribution. At each iteration we store the distance of each new body to the previous bodies. We also enforce a minimum distance between any two given bodies.

**Generate throats**
The throat generation process consists in three steps. The main inputs are the coordination number distribution for the bodies, the throat length distribution and the throat radius distribution.

*Generate coordination numbers*
We first sample from the coordination number distribution. We arbitrarily compute a weight for each body as the distance of the body to its n-th closest neighbor, where n is the maximum coordination number we have generated. We sort the sampled coordination numbers and assign them correspondingly (the highest coordination number is assigned to the body with the largest weight).

*Generate links*
We then sample from the throat length distribution. We repeatedly sample from the bodies that still have connections to make, and connect them to the neighbor that is at the distance that is closest to the sampled throat length. Towards the end of the process, when not many available bodies can still make connections, we can be pretty far off from the target length. Nevertheless, the generated throat length distribution is found to be in good agreement with the target distribution (if the sample size is large enough).

*Generate throat radii*
We finally sample from the throat radius distribution. We compute a weight for each throat as the smallest of the radii of the bodies it connects. We assign the sampled throat radii correspondingly (the largest throat radius is assigned to the body with the largest weight).

*Note*
In the presence of information on the correlation between throat radius and body radius, or coordination number and body radius, that should be used instead. This information is not usually provided however, which is why we use the arbitrary weights defined above.

# Installation
Fork, clone or download this repository. Change directory to the repository and type setup at the MATLAB command prompt to add the project folders to path. This will also open the script that was used to generate the example below.

# Example

In this section we quickly walk through an example with the toolbox to stochastically generate a pore network model. The example can be repeated by using the generatePNM.m script in the example folder of this repository. The probability distribution functions are estimated using a kernel density estimator available [here](https://www.mathworks.com/matlabcentral/fileexchange/14034-kernel-density-estimator).

**Generated pore network**
The final result for the example is rendered below. The domain is a 1mm3 cube. The network has 2,103 bodies, 4,363 throats and porosity is 26.0%.
![Alt text](example/figures/network.png?raw=true "Example network")

**Inputs**
The target distributions for this example are drawn from the sample files for the Berea network included with [the Imperial College pore network generator](https://www.imperial.ac.uk/engineering/departments/earth-science/research/research-groups/perm/research/pore-scale-modelling/software/network-generator/) (we take a subset of 5,000 lines at random from each of the throatData.txt and PoreData.txt files).

**Generation of bodies**
```matlab
%% Generate bodies
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
```
![Alt text](example/figures/bodies.png?raw=true "Bodies")

**Body radius distribution**
```matlab
%% Plot distribution for body radius
bodyRads = zeros(length(bodies),1);
for iBody = 1:length(bodies)
    bodyRads(iBody) = bodies{iBody}.rad;
end
vec{1} = bodyRads;
vec{2} = target.pore_rad;
figure(99); clf
setPlotJAC(99, 'graph')
kdeJAC(vec)
```
![Alt text](example/figures/bodyRad.png?raw=true "Body radius distribution")

**Generate throats**
```matlab
%% Generate throats
clear throats; clc; close all;
target.coord = PoreData(:,1);
target.coord_pdf = histc(target.coord,min(target.coord):max(target.coord));
throatData_compressed
target.throat_rad = throatData(:,1)*1e6; % in microm
target.throat_len = throatData(:,3)*1e6; % in microm
% generate target coordination number for each body
% Arbitrary truncation of the original distribution at 12 to avoid pathological cases
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
```
**Throat radius distribution**
```matlab
%% Plot distribution for throat radius
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
```
![Alt text](example/figures/throatRad.png?raw=true "Throat radius distribution")

**Coordination number distribution**
```matlab
%% Plot distribution for coordination number
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
```
![Alt text](example/figures/coord.png?raw=true "Coordination number distribution")

**Throat length distribution**
```matlab
%% Plot distribution for throat length
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
```

![Alt text](example/figures/throatLen.png?raw=true "Throat length distribution")

**Generate correlation between pore radius and throat radius**
This plot is equivalent to the one in figure 3.8 in [@idowu].
```matlab
%% Plot correlation between pore radius and throat radius as in Idowu 2009
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
```
![Alt text](example/figures/bodyRadCorr.png?raw=true "Correlation from body to throat radii")

# Definitions
**Body**
A class to define bodies. Bodies are spherical. Main attributes are the position of the center of the body and its radius.

**CylThroat**
A class to define cylindrical throats. Main attributes are the throat radius at the center of the throat, the position of the throat center and an array of BodyInfo objects.

**BodyInfo**
A class to contain properties that the throat needs to know about the bodies it connects. Main attributes are an ID for the connected body, the radius of the throat at the junction between the body and the throat (equal to the throat radius in the cylindrical case), the length from the throat to the body.

**PoreSpace**
A wrapper class to represent the pore space. During initialization of a PoreSpace object, we also initialize the list of throats that are connected to each body to make subsequent computations faster. 

# References
