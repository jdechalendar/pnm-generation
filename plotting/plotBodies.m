function plotBodies(bodies, opt)
%%

%%
%% set defaults
if ~exist('opt', 'var')
    opt = struct;
end
if ~isfield(opt, 'hfig')
    opt.hfig = 1;
end
if ~isfield(opt, 'color')
    opt.color = 'same';
end
if ~isfield(opt, 'lighting')
    opt.lighting= 1;
end

figure(opt.hfig);
setPlotJAC(1, 'fullscreen')
colOrd = colorPalette('');
fv = [];
cdata = [];
for ii = 1:length(bodies)
    new_patch = bodies{ii}.getPatch;
    new_cdata = repmat(colOrd(rem(ii,length(colOrd))+1,:),length(new_patch.faces),1);
    [fv,cdata] = combine_patches(new_patch,fv,...
        new_cdata,cdata);
end

if strcmp(opt.color,'same')
	patch('Faces',fv.faces,'Vertices',fv.vertices, ...
    	'FaceColor',colOrd(1,:), 'LineStyle', 'none');
else
	patch('Faces',fv.faces,'Vertices',fv.vertices, ...
    	'FaceVertexCdata',cdata, 'FaceColor','flat','LineStyle', 'none');
end

view(3)
axis equal
xlabel('X')
ylabel('Y')
zlabel('Z')
if opt.lighting
    camproj('perspective');
    lighting phong;
    camlight;
end
%%
