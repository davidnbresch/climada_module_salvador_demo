function centroids = salvador_vegetation(centroids)

module_data_dir=[fileparts(fileparts(mfilename('fullpath'))) filesep 'data'];

soil_type_file = [module_data_dir filesep 'system' filesep 'vegetacion.shp'];
soil_type_shapes = climada_shaperead(soil_type_file,0);

centroids.LAI = zeros(size(centroids.centroid_ID));

t0 = clock;
format_str = '%s';
mod_step        = 10;
for shape_i = 1:length(soil_type_shapes)
    
    [soil_type_shapes(shape_i).X,soil_type_shapes(shape_i).Y] =...
        utm2ll(soil_type_shapes(shape_i).X,soil_type_shapes(shape_i).Y);
    
    % progress mgmt
    if mod(shape_i,mod_step) ==0
        
        t_elapsed       = etime(clock,t0)/shape_i;
        n_remaining     = length(soil_type_shapes)-shape_i;
        t_projected_sec = t_elapsed*n_remaining;
        if t_projected_sec<60
            msgstr = sprintf('processing land use, est. %3.0f sec left (%i/%i shapes)',t_projected_sec, shape_i,length(soil_type_shapes));
        else
            msgstr = sprintf('processing land use, est. %3.1f min left (%i/%i shapes)',t_projected_sec/60, shape_i,length(soil_type_shapes));
        end
        fprintf(format_str,msgstr);
        format_str = [repmat('\b',1,length(msgstr)) '%s'];
    end
    
    
    [in] = inpolygon(centroids.lon,centroids.lat,...
        soil_type_shapes(shape_i).X,soil_type_shapes(shape_i).Y);
    centroids.LAI(in) = soil_type_shapes(shape_i).NO_CATEGOR;
end

cat_lookup = [      20	3	0.214285714
                    19	4	0.285714286
                    18	5	0.357142857
                    14	14	0.999999999
                    25	13	0.928571429
                    21	Inf	NaN
                    3	3	0.214285714
                    27	7	0.5
                    5	8	0.571428571
                    8	6	0.428571429
                    26	7	0.5
                    7	9	0.642857143
                    23	11	0.785714286
                    1	10	0.714285714 ];

for cat_i = 1:length(cat_lookup)
    centroids.LAI(centroids.LAI == cat_lookup(cat_i,1)) = cat_lookup(cat_i,3);
end

fprintf(format_str,sprintf('processing land use took %2.0f seconds\n',etime(clock,t0)))