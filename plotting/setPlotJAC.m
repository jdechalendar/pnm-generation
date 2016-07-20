function setPlotJAC(hfig, style)
%setPlotJAC   set custom figure parameters
%   setPlotJAC(hfig, style) sets the figure parameters using one of the
%   predefined styles:
%   - fullscreen
%   - halfscreen
%   - right
%   - graph
%   - hugeFont
%
%   JAC - Aug 25 2015

%% set defaults
if ~exist('style', 'var')
    style = 'fullscreen';
end

switch style
    case 'fullscreen'
        set(hfig, 'Color', [1 1 1], ...
            'units', 'normalized', ...
            'position', [-0.00347222 0.00444444 1 0.888889])
        set(0,'DefaultLineLineWidth',2,'DefaultAxesLineWidth',.5);
    case 'halfscreen'
        set(hfig, 'Color', [1 1 1], ...
            'units', 'normalized', ...
            'position', [0 0.00444444 0.5 0.888889])
    case 'right'
        set(hfig, 'Color', [1 1 1], ...
            'units', 'normalized', ...
            'position', [0.5 0.00444444 0.5 0.888889])
    case 'graph' % to make traditional 2D plots
        set(hfig, 'Color', [1 1 1], ...
            'units', 'normalized', ...
            'position', [0.15 0.1 0.7 0.7])
        set(0,'DefaultLineLineWidth',2,'DefaultAxesLineWidth',.5);
        set(0,'DefaultAxesTickDir','out','DefaultAxesTickLength',[.012 .012]);
        set(0,'DefaultTextFontSize', 30);
        %         set(0,'DefaultTextFont', 'Arial');
        set(0,'DefaultAxesFontSize', 30);
        %         set(0,'DefaultAxesFont', 'Arial');
        %         colOrd = [...
        %             1.0 0.6 0.4
        %             0.5 1.0 0.5
        %             0.0 0.6 1.0
        %             0.6 0.6 0.6
        %             1.0 1.0 0.0
        %             0.4 1.0 1.0
        %             1.0 0.4 0.0
        %             0.0 0.8 0.4
        %             0.4 0.0 1.0
        %             1.0 0.0 0.4
        %             0.4 0.8 0.0
        %             ];
        colOrd = colorPalette(''); % this returns the default color palette
        set(0,'DefaultAxesColorOrder', colOrd)
        set(hfig, 'PaperPositionMode', 'auto');
    case 'Graph' % same as graph with bigger font
        set(hfig, 'Color', [1 1 1], ...
            'units', 'normalized', ...
            'position', [0.15 0.1 0.7 0.7])
        set(0,'DefaultLineLineWidth',2,'DefaultAxesLineWidth',.5);
        set(0,'DefaultAxesTickDir','out','DefaultAxesTickLength',[.012 .012]);
        set(0,'DefaultTextFontSize', 46);
        set(0,'DefaultAxesFontSize', 46);
        colOrd = colorPalette(''); % this returns the default color palette
        set(0,'DefaultAxesColorOrder', colOrd)
        set(hfig, 'PaperPositionMode', 'auto');
    case 'Graph2' % same as Graph with color scheme inverted
        set(hfig, 'Color', [1 1 1], ...
            'units', 'normalized', ...
            'position', [0.15 0.1 0.7 0.7])
        set(0,'DefaultLineLineWidth',2,'DefaultAxesLineWidth',.5);
        set(0,'DefaultAxesTickDir','out','DefaultAxesTickLength',[.012 .012]);
        set(0,'DefaultTextFontSize', 46);
        set(0,'DefaultAxesFontSize', 46);
        colOrd = colorPalette(''); % this returns the default color palette
        colOrd = flipud(colOrd);
        set(0,'DefaultAxesColorOrder', colOrd)
        set(hfig, 'PaperPositionMode', 'auto');
    case 'graphG' % to make traditional 2D plots
        set(hfig, 'Color', [1 1 1], ...
            'units', 'normalized', ...
            'position', [0.15 0.1 0.7 0.7])
        set(0,'DefaultLineLineWidth',2,'DefaultAxesLineWidth',.5);
        set(0,'DefaultAxesTickDir','out','DefaultAxesTickLength',[.012 .012]);
        set(0,'DefaultTextFontSize', 20);
        %         set(0,'DefaultTextFont', 'Arial');
        set(0,'DefaultAxesFontSize', 20);
        colOrd = colorPalette('gray'); % this returns the default color palette
        set(0,'DefaultAxesColorOrder', colOrd)
    case 'hugeFont'
        set(hfig, 'Color', [1 1 1], ...
            'units', 'normalized', ...
            'position', [0.15 0.1 0.7 0.7])
        set(0,'DefaultLineLineWidth',2,'DefaultAxesLineWidth',.5);
        set(0,'DefaultAxesTickDir','out','DefaultAxesTickLength',[.012 .012]);
        set(0,'DefaultTextFontSize', 30);
        %         set(0,'DefaultTextFont', 'Arial');
        set(0,'DefaultAxesFontSize', 30);
        colOrd = colorPalette(''); % this returns the default color palette
        set(0,'DefaultAxesColorOrder', colOrd)
    otherwise
        error('I don''t know this style')
end
end