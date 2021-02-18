%%

clear all
close all
clc

%please enter your data directory after extracting data.zip 
processed_folder = '\\169.254.103.43\haeslerlab\users\cagatay\np2_paper\collab\processed';

% please enter directory in case you would like to print some figures
figure_folder =  'E:\local\users\cagatay\np2_paper\';
%% linear fit

printfigure = 0;

tp = list_files(processed_folder,'*.mat');
mm = 1;
clf,
ax = [];
lab_list = {'haesler','hantman','lee','moser','o_keefe','carandini'};
clabs = lines(6);
time_start = 3;
ev_corr = [];
yield_corr = [];
ev_slope = [];
yield_slope = [];
c_sig = [];
for ii = 1:length(tp)
    load(tp{ii});
    [ndays,nprobes] = size(dat);
    
    for ip = 1:nprobes
        ax(1) = subplot(2,1,1);
        dd = vertcat(dat(:,ip).date);
        
        
        tmpx = dd-min(dd)+time_start ;
        tmpy = vertcat(dat(:,ip).mev);
        idx = ~isnan(tmpx)&~isnan(tmpy)&tmpx<=60;
        
        
        log_tmpy = log10(tmpy);
        lab_id = find(strcmp(dat(1,ip).lab,lab_list));
        plot1 = plot(tmpx(idx),log_tmpy(idx),'-o','color',clabs(lab_id,:),'markersize',mm,...
            'markerfacecolor',clabs(lab_id,:),...
            'markeredgecolor','none',...
            'linewidth',0.5);hold on,
        plot1.Color(4) = .15;

        
        p1 = polyfit(tmpx(idx),log_tmpy(idx),1);
        ev_slope = [ev_slope,p1(1)];
        c_sig = [c_sig;clabs(lab_id,:)];
        plot(tmpx(idx),polyval(p1,tmpx(idx)),'color',clabs(lab_id,:))
        

        [R,P]=corrcoef(tmpx(idx),log_tmpy(idx));
        ev_corr = [ev_corr,P(2,1)];
        ylabel('Total firing rate (sp/s)')
        xlabel('Days since implantation')
        set(ax(end),'ylim',[0 5])
        
        ax(2) = subplot(2,1,2);
        
        dd = vertcat(dat(:,ip).date);
        tmpx = dd-min(dd)+time_start;
        tmpy = vertcat(dat(:,ip).mgood);
        idx = ~isnan(tmpx)&~isnan(tmpy);
               
        log_tmpy = log10(tmpy);
        dat(:,ip).name;
        lab_id = find(strcmp(dat(1,ip).lab,lab_list));
        plot2 = plot(tmpx(idx),log_tmpy(idx),'-o','color',clabs(lab_id,:),'markersize',mm,...
            'markerfacecolor',clabs(lab_id,:),...
            'markeredgecolor','none',...
            'linewidth',0.5);hold on
        plot2.Color(4) = .15;
        
        p1 = polyfit(tmpx(idx),log_tmpy(idx),1);
        yield_slope = [yield_slope,p1(1)];
        plot(tmpx(idx),polyval(p1,tmpx(idx)),'color',clabs(lab_id,:))
        
        [R,P]=corrcoef(tmpx(idx),log_tmpy(idx));
        yield_corr = [yield_corr,P(2,1)];
        
        ylabel('Cluster count')
        xlabel('Days since implantation')
        set(ax(end),'ylim',[0 3])  
        
    end
    
end

tmp_tick = [0,1,2,3,4,5];
cell_tick ={};
for it = 1:length(tmp_tick)
    cell_tick{it} = num2str(tmp_tick(it),'10^%d');
end


set(ax(:),'box','off','ticklength',get(ax(end),'ticklength').*3,...
    'tickdir','out','fontsize',7,'fontname','arial',...
    'linewidth',0.5,'yscale','linear','ygrid','off','ytick',tmp_tick,...
    'yticklabel',cell_tick,'xlim',[2 61])

set(gcf,'papersize',[2.5,2*2],'paperposition',[0,0,2.5,2*2])

figure_name = sprintf('%s%s%s%s%2.0f%s',figure_folder,filesep,'figures\','event_rates_median',rem(now,1)*1000,'.pdf');
if printfigure
    print(gcf,'-dpdf','-loose',figure_name)
end

%% slope and significance

printfigure = 0;
mm=10;
clf
ax = [];

ax(1) = subplot(2,1,1);
[vv,idx] = sort(ev_slope);
sorted_p = ev_corr(idx);
p_idx = sorted_p<=0.05;
tt = 1:length(vv);
c_sorted = c_sig(idx,:);
scatter(tt,vv,ones(1,length(tt)).*mm,c_sorted),hold on
scatter(tt(p_idx),vv(p_idx),ones(1,sum(p_idx)).*mm,c_sorted(p_idx,:),'filled')
plot([0,length(idx)],[0 0],'--','color',[0.5,0.5,0.5])

ax(2) = subplot(2,1,2);
[vv,idx2] = sort(yield_slope);
sorted_p = yield_corr(idx);
p_idx = sorted_p<=0.05;
tt = 1:length(vv);
c_sorted = c_sig(idx,:);
scatter(tt,vv,ones(1,length(tt)).*mm,c_sorted),hold on
scatter(tt(p_idx),vv(p_idx),ones(1,sum(p_idx)).*mm,c_sorted(p_idx,:),'filled')
plot([0,length(idx)],[0 0],'--','color',[0.5,0.5,0.5])

ylabel('slope')
xlabel('#experiments')

set(ax(:),'box','off','ticklength',get(ax(end),'ticklength').*3,...
    'tickdir','out','fontsize',7,'fontname','arial',...
    'linewidth',0.5,'ylim',[-0.025 0.025])

set(gcf,'papersize',[1.5,2*2],'paperposition',[0,0,1.5,2*2])

figure_name = sprintf('%s%s%s%s%2.0f%s',figure_folder,filesep,'figures\','event_rates_linear_fit',rem(now,1)*1000,'.pdf');
if printfigure
    print(gcf,'-dpdf','-loose',figure_name)
end
