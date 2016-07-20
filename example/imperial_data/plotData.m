%% plot the data to check what we are extracting
clear;clc;close all;
PoreData_compressed
throatData_compressed
target.coord = PoreData(:,1);
target.coord_pdf = histc(target.coord,min(target.coord):max(target.coord));
target.throat_rad = throatData(:,1)*1e6; % in microm
target.throat_len = throatData(:,3)*1e6; % in microm
target.pore_rad = PoreData(:,3)*1e6; % in microm

opt.hfig = 1;
figure(opt.hfig);clf
setPlotJAC(opt.hfig, 'graph')
vec{1} = target.pore_rad;
vec{2} = target.throat_rad;
kdeJAC(vec,opt)
legend('bodies', 'throats')
%%
opt.hfig = 1;
figure(opt.hfig);clf
setPlotJAC(opt.hfig, 'graph')
vec = target.throat_len;
kdeJAC(vec,opt)