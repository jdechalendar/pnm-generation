function plotThroats(throats, opt)
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
for ii = 1:length(throats)
    % unpack
    myThroat = throats{ii};
    if ~isempty(myThroat)
        new_patch = [];
        for iBody = 1:length(myThroat.bInfo)
            new_patch = combine_patches(myThroat.getPartialPatch(myThroat.bInfo{iBody}.bodyID, 1),new_patch);
        end
    end
    new_cdata = repmat(colOrd(rem(ii,length(colOrd))+1,:),length(new_patch.faces),1);
    [fv,cdata] = combine_patches(new_patch,fv,...
        new_cdata,cdata);
end

if strcmp(opt.color,'same')
    patch('Faces',fv.faces,'Vertices',fv.vertices, ...
        'FaceColor',colOrd(4,:), 'LineStyle', 'none');
else
    patch('Faces',fv.faces,'Vertices',fv.vertices, ...
        'FaceVertexCdata',cdata, 'FaceColor','flat','LineStyle', 'none');
end

view(3)
xlabel('X')
ylabel('Y')
zlabel('Z')
axis tight;
axis equal;
if opt.lighting
    camproj('perspective');
    lighting phong;
    camlight;
end
%%