function plot3D(obj, hfig)
% plot the stick and ball diagram for the network
if ~exist('hfig','var')
    hfig = 1;
end
figure(hfig); clf
setPlotJAC(hfig, 'hugeFont')
hold on
view(3)
xlabel('X (\mu m)')
ylabel('Y (\mu m)')
zlabel('Z (\mu m)')
colOrd = colorPalette('');
%% plot bodies
for iN =1:length(obj.bodies)
    % unpack
    fv = obj.bodies{iN}.getPatch;
    patch('Faces',fv.faces,'Vertices',fv.vertices, ...
        'FaceColor',colOrd(1,:),'LineStyle',':');
%     pos = obj.bodies{iN}.pos;
%     text(pos(1),...
%         pos(2),...
%         pos(3),...
%         ['b' num2str(iN)], 'FontSize', 20)
end

%% plot vertices as cylinders
for iV = 1:length(obj.throats)
    % unpack
    myThroat = obj.throats{iV};
    if ~isempty(myThroat)
        fv = [];
        for iBody = 1:length(myThroat.bInfo)
            fv = combine_patches(myThroat.getPartialPatch(myThroat.bInfo{iBody}.bodyID, 1),fv);
        end
        patch('Faces',fv.faces,'Vertices',fv.vertices, ...
            'FaceColor',colOrd(4,:), 'LineStyle',':');
    end
end
alpha 0.3
axis equal