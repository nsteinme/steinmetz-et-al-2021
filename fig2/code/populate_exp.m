function [exp] = populate_exp(dat,ie)

% keyboard
[ndates,nprobes] = size(dat);
exp = [];
for id = 1:ndates
    for ip = 1:nprobes
        nsessions =length(dat(id,ip).hist_amp); 
        exp = [exp;repmat(ie,nsessions,1)];
    end
end

end