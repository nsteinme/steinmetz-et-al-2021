
clear all
close all
clc

%please enter your data directory after extracting data.zip 
processed_folder = '\\169.254.103.43\haeslerlab\users\cagatay\np2_paper\collab\processed';

% please enter directory in case you would like to print some figures
figure_folder =  'E:\local\users\cagatay\np2_paper\';

%% seperate over weeks

experiments = list_files(processed_folder,'*.mat');

dpw = 7;
ndays = 60;
nweeks = ceil(ndays/dpw);

time_start = 3;
comb_norm_amp = [];
comb_norm_date = [];
comb_eg_bin = [];
comb_exp = [];
nanimals = length(experiments);
for ie = 1:nanimals
    clear dat
    all_date = [];
    all_bin = [];
    all_amp = [];
    all_exp = [];
    
    load(experiments{ie});
    
    tmp_amp = populate_amp(dat);
    find_nan = arrayfun(@(x)sum(isnan(tmp_amp{x})),1:length(tmp_amp),'UniformOutput',false);
    nan_idx = logical(~vertcat(find_nan{:}));
    if isempty(nan_idx)
        nan_idx = ones(length(tmp_amp),1);
    end
    all_amp = horzcat(tmp_amp{nan_idx});
    norm_amp = all_amp./sum(all_amp);
    
    tmp_exp = populate_exp(dat,ie);
    all_exp = tmp_exp(nan_idx);
    
    tmp_date = populate_date(dat);
    all_date = tmp_date(nan_idx);
    norm_date = all_date-min(all_date)+time_start;
    
    eg_bin = dat(1).hist_bin{:};
    
    comb_norm_amp = [norm_amp,comb_norm_amp];
    comb_eg_bin = [eg_bin,comb_eg_bin];
    comb_norm_date = [norm_date; comb_norm_date];
    comb_exp = [all_exp;comb_exp];
    
    
end

%% mean over the days in a week

[sorted_days, day_idx] = sort(comb_norm_date);
sorted_amp = comb_norm_amp(:,day_idx);


week_amp = nan(size(sorted_amp,1),nweeks);
week_ste = nan(size(sorted_amp,1),nweeks);
week_std = nan(size(sorted_amp,1),nweeks);
week_samp = [];
for iw=0:nweeks-1
    week_idx = find(sorted_days<=(iw+1).*dpw& sorted_days>iw.*dpw);
    week_samp = [week_samp,length(week_idx)];
    week_amp(:,iw+1)= mean(sorted_amp(:,week_idx),2);
    week_ste(:,iw+1) = std(sorted_amp(:,week_idx)')./sqrt(length(week_idx));
    week_std(:,iw+1) = std(sorted_amp(:,week_idx)');
end

%% plot week mean distributions

printfigure = 0; % change to 1 in case you would like to print the figure
clf,
ccol = copper(nweeks);
ax = [];
ax = subplot(1,1,1);
tmpx = 1:nweeks;
for iw = 1:nweeks
    plot(comb_eg_bin(:,iw),week_amp(:,iw),'color',ccol(iw,:),'linewidth',1),hold on
end

set(ax(:),'box','off','ticklength',get(ax(end),'ticklength').*3,...
    'tickdir','out','fontsize',7,'fontname','arial',...
    'linewidth',0.5,'xscale','log',...
    'xlim',[75 300])


colormap(ccol);
custom_bar = colorbar;
a = custom_bar.Position;
set(custom_bar,...
    'xtick',[0 0.5 1],...
    'xticklabel',[min(tmpx) floor(mean(tmpx)) max(tmpx)],...
    'position',[a(1)+0.1 a(2)+0.05 0.03 0.3]);


set(gcf,'papersize',[2.5,2*1],'paperposition',[0,0,2.5,2*1],'renderer','Painters')
figure_name = sprintf('%s%s%s%s%s',...
    figure_folder,...
    filesep,...
    'figures\amplitude\',...
    'week_mean',...
    '.pdf');
if printfigure
    print(gcf,'-dpdf','-loose',figure_name)
end

