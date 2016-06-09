%
% no documenatation, see code
%-

adj = 0;

int_tmp = full(tmp_hazard.intensity);
int_    = full(hazard.intensity);

max_diff = []; %init
t0 = clock;
while etime(clock,t0)<20
    for e_i=1:9
        int_tmp(e_i,:) = max(int_(e_i,:)-(centroids.elevation_m-2),0);
    end
    max_diff(end+1) = abs(max(max(int_ - int_tmp)));
    %fprintf('%2.2f \t',max_diff)
    adj = adj + 0.5;
end