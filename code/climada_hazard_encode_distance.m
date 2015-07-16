function hazard = climada_hazard_encode_distance(hazard,entity,cutoff)
% climada
% MODULE:
%   salvador_demo
% NAME:
%   climada_hazard_encode_distance
% PURPOSE:
%   Convert landslide hazard intensity (landslide depth(m))
%   into distance between an asset and the nearest centroid with nonzero
%   intensity. Distance is transformed into intensity in the form of (y = mx+b), 
%   which means increasing intensity with increasing damage, 
%   intensity = 1 - 1/cutoff * distance_m
%   Minimum distance is set to  1m, which translates into the maximum intensity 1.
%   The lat/lon coordinates of the hazard are overwritten by the asset
%   lat/lon coordinates
%   A default distance cutoff, when it can be assumed that no asset is
%   affected anymore is introduced at 1000 m.
% CALLING SEQUENCE:
%   hazard = hazard_distance_convert(hazard,entity,cutoff)
% EXAMPLE:
%   hazard = hazard_distance_convert(hazard,entity,250)
% INPUTS:
%   hazard: landslide hazard structure, intensity given as meters soildepth
%   entity: climada entity structure, with .assets.lon and .assets.lat
% OPTIONAL INPUT PARAMETERS:
%   cutoff: default 1000m, can be set to other value
% OUTPUTS:
%   hazard: a climada structure with lat/lon that equal the entity.assets.lat/lon
%           and intensity as 1-1/cutoff*distance_m (-)
% MODIFICATION HISTORY:
% Jacob Anz, j.anz@gmx.net, 20150708, initial
% Lea Mueller, muellele@gmail.com, 20150713, intensity as 1-1/cutoff*distance_m instead of distance

% init global variables
global climada_global
if ~climada_init_vars,return;end % init/import global variables

% poor man's version to check arguments
if ~exist('hazard',     'var'), hazard = []; end
if ~exist('entity',     'var'), entity = []; end
if ~exist('cutoff',     'var'), cutoff = []; end

if isempty(hazard),hazard = climada_hazard_load; end % prompt for and load hazard, if empty
if isempty(entity),entity = climada_entity_load; end % prompt for and load entity, if empty
% set cutoff value, default is 1000m, all values exceeding this treshold will be set to 0
if isempty(cutoff), cutoff = 1000; end

if isempty(hazard),return; end
if isempty(entity),return; end
hazard = climada_hazard2octave(hazard); % Octave compatibility for -v7.3 mat-files

    
%get hazard structure
hazard_distance = hazard;

% overwrite lon and lat with entity lon/lats
hazard_distance.lon        = entity.assets.lon;
hazard_distance.lat        = entity.assets.lat;
hazard_distance.intensity  = sparse(hazard.event_count, numel(entity.assets.lon));
hazard_distance.distance_m = sparse(hazard.event_count, numel(entity.assets.lon));
hazard_distance.cutoff_m   = cutoff;
hazard_distance.comment    = 'intensity, as tranformed distance, y = 1-1/cutoff*distance_m';
hazard_distance.units      = '-';
hazard_distance.centroid_ID = 1:length(entity.assets.lon);
hazard_distance.peril_ID   = 'LS';

% init intensity matrix where we will fill in all the intensity values (y =mx+b, with x = distance_m)
intensity_matrix = zeros(hazard.event_count, numel(entity.assets.lon));

% remove fields that are not needed anymore
if isfield(hazard_distance,'source'          ), hazard_distance = rmfield(hazard_distance,'source'          ); end
if isfield(hazard_distance,'deposit'         ), hazard_distance = rmfield(hazard_distance,'deposit'         ); end
if isfield(hazard_distance,'slide_ID'        ), hazard_distance = rmfield(hazard_distance,'slide_ID'        ); end
if isfield(hazard_distance,'factor_of_safety'), hazard_distance = rmfield(hazard_distance,'factor_of_safety'); end


% sparse to full matrix
intensity_full = full(hazard.intensity);

% % find nonzero elements
% [event_indx,location_indx,s] = find(hazard.intensity);
   
% init watibar
msgstr   = sprintf('Encoding hazard to hazard distance');
mod_step = 10;
if climada_global.waitbar
    fprintf('%s (updating waitbar every 100th event)\n',msgstr);
    h        = waitbar(0,msgstr);
    set(h,'Name','Encoding hazard to hazard distance');
else
    fprintf('%s (waitbar suppressed)\n',msgstr);
    format_str='%s';
end
    
%loop over all events
for i=1:length(hazard_distance.event_ID)
    
    %find nonzero values
    nonzero_indx = find(intensity_full(i,:));

    if ~isempty(nonzero_indx)               
        % create array that contain longitude information in the first
        % column and latitude in the second column, works independent of
        % original lon/lat dimension
        hazard_lon_lat = [reshape(hazard.lon(nonzero_indx),numel(nonzero_indx),1) reshape(hazard.lat(nonzero_indx),numel(nonzero_indx),1)];
        entity_lon_lat = [reshape(entity.assets.lon,numel(entity.assets.lon),1) reshape(entity.assets.lat,numel(entity.assets.lat),1)];
        % find closest hazard centroid and calculate distance in meters to it
        %[indx_, distance_m] = knnsearch(hazard_lon_lat,entity_lon_lat,'Distance',@climada_geo_distance_2); 
        [~, distance_m] = knnsearch(hazard_lon_lat,entity_lon_lat,'Distance',@climada_geo_distance_2); 
              
        %set minimum distance to 1m
        distance_min = 1;
        distance_m(distance_m<=distance_min) = 0;  
       
        % transform distance to an intensity in the form of (y = mx+b), which means 
        % increasing intensity with increasing damage,  
        intensity = 1 - 1./cutoff * distance_m;
        
        %apply cutoff, set all exceeding values to 0
        intensity(distance_m>=cutoff) = 0;   
        
        %new hazard with distance and lon/lat at asset location
        intensity_matrix(i,:) = intensity;
        
        % the progress management
        if mod(i,mod_step)==0
            mod_step = 100;
            if climada_global.waitbar
                waitbar(i/length(hazard_distance.event_ID),h,msgstr); % update waitbar
            else
                msgstr = sprintf('%i/%i hazard events',i,length(hazard_distance.event_ID));
                fprintf(format_str,msgstr); % write progress to stdout
                format_str = [repmat('\b',1,length(msgstr)) '%s']; % back to begin of line
            end
        end
        
    end

end
    

if climada_global.waitbar
    close(h) % dispose waitbar
else
    fprintf(format_str,''); % move carriage to begin of line
end

% write into hazard structure
hazard_distance.intensity = sparse(intensity_matrix);

% calculate distance as well (in meters)
hazard_distance.distance_m = sparse((1 - hazard_distance.intensity) .*cutoff);

    
% overwrite hazard with hazard_distance
hazard = hazard_distance;







% if plot_on
%     figure
%     scatter3(entity.assets.lon,entity.assets.lat,entity.assets.Value/max(entity.assets.Value),'.')
%     hold on
%     scatter3(hazard_distance.lon', hazard_distance.lat',hazard_distance.intensity(1,:),'*')
%     %set 0 to Nan, plots only the first event
%     testhaz=hazard.intensity(1,:);
%     testhaz(testhaz==0)=nan;
%     scatter3(hazard.lon,hazard.lat,testhaz,'.')
%     legend('assets','distance','muslide location','assets','distance');
%     sprintf('done');
% end


%%
%hazard_distance.intensity=sparse(hazard_distance.intensity);

