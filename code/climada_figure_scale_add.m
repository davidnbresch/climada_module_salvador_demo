function climada_figure_scale_add(gca,top_corner,right_corner)
% add figure scale to a figure 
% MODULE:
%   salvador demo
% NAME:
%   climada_figure_scale_add
% PURPOSE:
%   Add figure scale to a figure, in km
% CALLING SEQUENCE:
%   climada_figure_scale_add(gca,top_corner,right_corner)
% EXAMPLE:
%   climada_figure_scale_add
% INPUTS: 
% OPTIONAL INPUT PARAMETERS:
%   gca            : get current axis
%   top_corner     : position of scale in the figure, default is 2, scale
%                    is positioned on second y-grid from the top
%   right_corner   : position of scale in the figure, default is 1, scale
%                    is positioned on first x-grid from the right
% OUTPUTS:      
%   scale with km information appears on the current axis
% MODIFICATION HISTORY:
% Lea Mueller, muellele@gmail.com, 20150724, init
%-


global climada_global
if ~climada_init_vars,return;end % init/import global variables

% poor man's version to check arguments
if ~exist('gca'         ,'var'),gca          = []; end
if ~exist('top_corner'  ,'var'),top_corner   = []; end
if ~exist('right_corner','var'),right_corner = []; end

if isempty(gca),gca; end
if isempty(top_corner)  ,top_corner   = 2; end
if isempty(right_corner),right_corner = 1; end


xticks = get(gca, 'xtick');
yticks = get(gca, 'ytick');
plot(xticks(end-right_corner:end-(right_corner-1)), ones(2,1)*yticks(end-top_corner),'-k','linewidth',3)
scale_text = sprintf('%2.1f km', climada_geo_distance(xticks(1),yticks(end),xticks(2),yticks(end))/1000);
text(mean(xticks(end-right_corner:end-(right_corner-1))), yticks(end-top_corner),scale_text,'verticalalignment','bottom','HorizontalAlignment','center','fontsize',14)




