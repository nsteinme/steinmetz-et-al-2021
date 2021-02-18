function [new_date] = populate_date(dat)

% keyboard
[ndates,nprobes] = size(dat);
new_date = [];
for id = 1:ndates
    for ip = 1:nprobes
        nsessions =length(dat(id,ip).hist_amp); 
        new_date = [new_date;repmat(dat(id,ip).date,nsessions,1)];
    end
end

end