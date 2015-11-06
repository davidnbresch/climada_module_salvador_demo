
% create movie for salvador TC
% MODULE:
%   salvador_demo
% MODIFICATION HISTORY:
% Lea Mueller, muellele@gmail.com, 20150401, init
%-


country_name = 'El Salvador';
[centroids,entity,entity_future] = climada_create_GDP_entity(country_name,'',1,1);

climada_centroids_plot(centroids)


%save the variables
save([climada_global.system_dir filesep 'centroids_Salvador_10km.mat'], 'centroids');
save([climada_global.data_dir filesep 'entities' filesep 'entity_Salvador_2014_10km.mat'], 'entity');
save([climada_global.data_dir filesep 'entities' filesep 'entity_Salvador_2030_10km.mat'], 'entity_future');

% calculate data for movie
tc_track_529 = tc_track(529);
animation_data_file = [climada_global.data_dir filesep 'results' filesep 'tc_track_529_Salvador_2'];
check_mode= ''; 2; %'';
hazard = climada_event_damage_data_tc(tc_track_529,entity,animation_data_file,0,check_mode);

% save movie
animation_avi_file = [climada_global.data_dir filesep 'results' filesep 'tc_track_529_Salvador_movie_2.avi'];
schematic_tag = 1;
climada_event_damage_animation(animation_data_file,animation_avi_file,schematic_tag)



% climada_event_damage_animation_ge(animation_data_file,google_earth_save,schematic_tag)
