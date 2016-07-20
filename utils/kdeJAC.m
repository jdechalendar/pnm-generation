function hax = kdeJAC(vec_cell, opt)
%kdeJAC  Plot pdf of multiple vectors using kde function
%   kdeJAC(vec, opt) plots pdf of vectors and prints summary stats
%   Treats NaNs as missing values
%
%   Optional parameter opt is used to pass options:
%   - hfig              :: [99] handle of figure to plot in
%   - plot              :: [1] if 0, just output text
%   - xlim              :: [-0.2 0.2] x-axis limits when plotting
%   - csv_format        :: [0] output using csv format
%   - remove_negative   :: [0] remove negative values
%   - interface         :: index of points we are looking at
%   - kde_npoints       :: number of points to use in estimating the kde
%   - fID_log           :: id to log file
%
%   JAC - Dec 23 2015
%
%   JAC - July 25 2015

% allow for non-cell inputs - in this case the input should be just a
% vector
if ~iscell(vec_cell)
    vec_cell = {vec_cell};
end

% set defaults
if ~exist('opt', 'var')
    opt = struct;
end
if ~isfield(opt, 'hfig')
    opt.hfig = 99;
end
if ~isfield(opt, 'plot')
    opt.plot = 1;
end
if ~isfield(opt, 'xlim')
    minVal= Inf;
    maxVal = -Inf;
    for ii=1:length(vec_cell)
        minVal = min(min(vec_cell{1}),minVal);
        maxVal = max(max(vec_cell{1}),maxVal);
    end
    opt.xlim = [minVal maxVal];
end
if ~isfield(opt, 'csv_format')
    opt.csv_format = 0;
end
if ~isfield(opt, 'remove_negative')
    opt.remove_negative = 0;
end
if ~isfield(opt, 'kde_npoints')
    opt.kde_npoints = 2^8;
end
if ~isfield(opt, 'fID_log')
    opt.fID_log = 1;
end
if ~opt.csv_format
    printRunInfo(opt.fID_log)
else
    %fprintf(opt.fID_log,',N,mean,std,sem,skewness\n');
end
if opt.plot
    figure(opt.hfig); clf
    hold all
end

for ii = 1:length(vec_cell)
    temp = vec_cell{ii};
    if size(temp,2)>size(temp,1); temp=temp'; end;
    for jj = 1:size(temp,2)
        vec = temp(:,jj);
        %% apply filters
        vec(abs(vec)<1e-7)=NaN; % remove arbitrarily small point
        if nanmean(vec)<0; vec=-vec;end;
        if opt.remove_negative; vec(vec<0) = NaN; end;
        if isfield(opt, 'interface') && ~(length(opt.interface)==1&&~opt.interface)
            vec(setdiff((1:length(vec))',opt.interface)) = NaN;
        end
        vec=vec(~isnan(vec));   
        %% get kde estimates
        if ~isempty(vec)
            [~,f,x,~]=kde(vec, opt.kde_npoints);
        else
            fprintf(opt.fID_log, 'Empty vector!\n');
        end
        if opt.plot
            plot(x,f)
            set(gca, 'XLim', opt.xlim)
        end
        %% print summary stats
        if opt.fID_log
            if ~opt.csv_format
                fprintf(opt.fID_log, 'Printing stats for vector %i\n', ii);
                if opt.remove_negative
                    fprintf(opt.fID_log, 'Remove negative option is active\n');
                else
                    fprintf(opt.fID_log, 'Remove negative option is not active\n');
                end
                fprintf(opt.fID_log, 'N\t\t%4g\n', sum(~isnan(vec)));
                fprintf(opt.fID_log, 'Mean\t\t%4g\n', nanmean(vec));
                fprintf(opt.fID_log, 'Std\t\t%4g\n', nanstd(vec));
                fprintf(opt.fID_log, 'SEM\t\t%4g\n', nanstd(vec)/sqrt(sum(~isnan(vec))));
                fprintf(opt.fID_log, 'Skewness\t%4g\n', skewness(vec));
            else
                fprintf(opt.fID_log,'%i,%i,%f,%f,%f,%f\n',...
                    ii,...
                    sum(~isnan(vec)),...
                    nanmean(vec), ...
                    nanstd(vec), ...
                    nanstd(vec)/sqrt(sum(~isnan(vec))), ...
                    skewness(vec));
            end
        end
    end
end
if opt.plot
    hax = gca;
else
    hax = [];
end