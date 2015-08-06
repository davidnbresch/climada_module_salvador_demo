function shapes = climada_shape_selector(fig,N,hold_shapes,min_dist_frac,smooth_factor)
% select shapes
% NAME:
%   climada_shape_selector
% PURPOSE:
%   Select one or multiple areas in a figure by drawing one or multiple polygons. 
%   Coordinates of polygons are saved in shapes.X and shapes.Y
% CALLING SEQUENCE:
%   shapes = climada_shape_selector(fig,N,hold_shapes,min_dist_frac)
% EXAMPLE:
%   shapes = climada_shape_selector(2,5,1,0.01)
%   shapes = climada_shape_selector
% INPUTS:
% OPTIONAL INPUT PARAMETERS:
%   fig:    figure handle of figure in which you want to select shapes.
%           if not given, existing figure with smallest handle number is
%           chosen. If no figures exist, climada_plot_world_borders is
%           called
%   N:      number of shapes you wish to draw
%   hold_shapes:    whether to keep plot of shapes on figure or remove
%                   them. Remove by default (=0)
%   min_dist_frac:  radius of circle within which a click would close the
%                   polygon (default = 2% of axis lims)
% OUTPUTS:
%   shapes:     structure array with fields X and Y defining the coordinates
% MODIFICATION HISTORY:
% Gilles Stassen, gillesstassen@hotmail.com, 20150729 init
%-

shapes = struct([]);

global climada_global

if ~climada_init_vars,  return; end % init/import global variables
if ~exist('fig','var'),  fig = []; end
if ~exist('N',  'var'),  N   = 1; end
if ~exist('hold_shapes',  'var'),  hold_shapes   = 1; end
if ~exist('min_dist_frac',  'var'),  min_dist_frac   = 0.02; end
if ~exist('smooth_factor',  'var'),  smooth_factor   = 1; end

% get handles of all existing figures
figs = findall(0,'Type','Figure');

if isempty(figs) && isempty(fig)
    % no existing figures, use default figure world borders.
    climada_plot_world_borders;
    axis equal
    axis tight
    fig = findall(0,'Type','Figure');
elseif isempty(fig)
    % get existing figure with lowest number if no handle supplied as input
    fig = min(figs);
elseif ~ismember(fig,figs)
    % if fig handle specified in argument does not exist
    cprintf([1 0 0], 'ERROR: figure %i does not exist\n',fig)
    return
end

figure(fig)
hold on

% store old title, and set temporary title with instructions
title_str=get(get(gca,'Title'),'String');
title_fsz = get(get(gca,'Title'),'FontSize');
title_ang = get(get(gca,'Title'),'FontAngle');
title(sprintf('Select %i polygons:',N),'FontSize',14,'FontAngle','Italic')

p = []; % init
% The try-catch block is to avoid permanent lines on plot when something 
% goes wrong & should be commented out when developing function.
try 
    for n = 1:N
        S = 0;
        [X, Y] = ginput(1);
        
        % define radius of min dist as fraction of extent of exes
        [x_lim] = get(gca,'XLim');
        [y_lim] = get(gca,'YLim');
        
        x_buffer = min_dist_frac * abs(diff(x_lim));
        y_buffer = min_dist_frac * abs(diff(y_lim));
        
        min_dist = sqrt(x_buffer^2 + y_buffer^2);
        
        % draw circle with radius min_dist
        ang_res =   0:0.01:2*pi;
        x_circ  =   min_dist*cos(ang_res);
        y_circ  =   min_dist*sin(ang_res);
        circ(n) =   plot(X+x_circ,Y+y_circ,'color','r','linewidth',2);
        
        dist = inf; % init
        
        % loop until user clicks inside circle centered on origin
        while dist > min_dist
            [X(end+1), Y(end+1)] = ginput(1);
            if ismember(X(end),X(1:end-1))
                X(end) = X(end)*1.00000000001; % small shift
            end
            if ismember(Y(end),Y(1:end-1))
                Y(end) = Y(end)*1.00000000001; % small shift
            end
            % parameterise distance along curve
            S(end+1) = S(end) + sqrt((X(end)-X(end-1))^2 + (Y(end) - Y(end-1))^2);
            
            % plot segment
            p(end+1) = plot(X(end-1:end), Y(end-1:end),'color','r','linewidth',2);
            dist = sqrt((X(end)-X(1))^2 + (Y(end) - Y(1))^2);
        end
        X = [X X(1)];
        Y = [Y Y(1)];
        S(end+1) = S(end) + sqrt((X(end)-X(end-1))^2 + (Y(end) - Y(end-1))^2);
        p(end+1) = plot(X, Y,'color','r','linewidth',2);
        
        % smooth out polygon using interp1 according to distance
        % parameterisation.
        if smooth_factor >1
            X_ = []; Y_ = []; Sq =[];
            for i = 1:length(S)-1
                Sq(end+1:end+smooth_factor) = linspace(S(i),S(i+1),smooth_factor);
            end
            X_ = interp1(S,X,Sq,'spline');
            Y_ = interp1(S,Y,Sq,'spline');
            
            X = X_; Y = Y_; clear X_ Y_
            p(end+1) = plot(X, Y,'color','b','linewidth',2);
        end
        
        shapes(n).X = X; clear X
        shapes(n).Y = Y; clear Y
    end
    pause(2)
catch
    % something went wrong, code does not get stuck, but continues to delete lines on plot
    cprintf([1 0 0],'ERROR: aborting\n') 
end

% delete circle
if exist('circ','var')
    for c_i = 1:length(circ)
        delete(circ(c_i))
    end
end

% delete lines
if exist('p','var') && ~hold_shapes
    for p_i = 1:length(p)
        delete(p(p_i))
    end
end

% restore title
title(title_str,'Fontsize',title_fsz,'FontAngle',title_ang)

return