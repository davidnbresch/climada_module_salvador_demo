
% create hazard Landslide (distance intenstiy) 
%  - based on hazard LS soil depth


%% create test entity
% lon = linspace(min(hazard.lon),max(hazard.lon),20);
% lat = linspace(min(hazard.lat),max(hazard.lat),20);
lon = linspace(-89.18,-89.08,30);
lat = linspace(13.65,13.74,30);
[lon lat] = meshgrid(lon,lat);
entity.assets.lon = lon(:)';
entity.assets.lat = lat(:)';
% set random asset values
entity.assets.Value = rand(size(entity.assets.lon))*10;


%% load Gilles basis landslide hazard
salvador_data_dir = ['\\CHRB1065.CORP.GWPNET.COM\homes\X\S3BXXW\Documents\lea\climada_git\climada_modules\salvador_demo\data'];
load([salvador_data_dir filesep 'hazards' filesep 'MS_hazard_050715'])
% % hazard_ori = hazard;
% % 
% % hazard.intensity = abs(hazard_ori.intensity);
% % hazard.intensity = sum(hazard.intensity);
% n_events = 220;
% hazard.intensity   = hazard.intensity(1:n_events,:);
% hazard.orig_event_count = n_events;
% hazard.event_ID    = 1:n_events;
% hazard.event_count = n_events;

figure
climada_hazard_plot_hr(hazard,1,'',[-2 2]);


%% transform basis hazard to distance hazard
% profile on
climada_global.waitbar = 0;
% transform basis hazard to distance hazard
cutoff = 1000;
hazard_distance = climada_hazard_encode_distance(hazard,entity,cutoff);
hazard_distance.peril_ID = 'LS';

% profile report
% profile off


%% create test figure, event 1
e_i = 4800;
figure
climada_hazard_plot_hr(hazard_distance,e_i,'',[0 cutoff]);
hold on
indx = abs(full(hazard.intensity(e_i,:)))>0;
plot(hazard.lon(indx), hazard.lat(indx),'sk')
plot(entity.assets.lon, entity.assets.lat,'xb')

e_i = 1;
figure
plotclr(hazard_distance.lon, hazard_distance.lat, hazard_distance.distance_m(e_i,:),'',20,1,'','',flipud(jet));
hold on
indx = abs(full(hazard.intensity(e_i,:)))>0;
plot(hazard.lon(indx), hazard.lat(indx),'sk')

% hazard stats
hazard_stats = climada_hazard_stats(hazard_distance,5:5:15);


%%


