function [new_amp] = populate_amp(dat)

% keyboard
[ndates,nprobes] = size(dat);
new_amp = [];
for id = 1:ndates
    for ip = 1:nprobes      
        tmp_amp = dat(id,ip).hist_amp;
        new_amp = [new_amp;tmp_amp'];
    end
end

end