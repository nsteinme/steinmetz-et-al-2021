% shankData(sh) structures include the following fields (for shank sh):
% rsp1, rsp2 - mean spike count response to each of the 112 natural images on day1 & day2
% rspPSTH1, rspPSTH2 - mean PSTH (across all presentations and all images) of each unit on day1 & day2
% ch - the closest channel of each unit (i.e. channel with largest spike waveform) 
% ch_xcoords, ch_ycoords - X & Y coordinates of each of the recorded 96 channels on a shank

clear all
figure;
for exmpl = 1:2 % 2 examples (1 day apart and 3 weeks apart)
  
  switch exmpl
    case 1
      load data_fig4D
    case 2
      load data_fig4E
  end
  
  subplot(1, 2, exmpl); hold on
  offset = 0;  
  for sh = 1:numel(shankData) % loop on shanks    
    matching = NaN(numel(shankData(sh).ch), 2);
    for u = 1:numel(shankData(sh).ch) % loop on units on the present shank
      
      % calculate the distance of the present unit from all other units on the shank
      distances = sqrt((shankData(sh).ch_xcoords(shankData(sh).ch(u)) - shankData(sh).ch_xcoords(shankData(sh).ch)).^2 + ...
        (shankData(sh).ch_ycoords(shankData(sh).ch(u)) - shankData(sh).ch_ycoords(shankData(sh).ch)).^2);
      
      % find the closest neighbour:
      distances(u) = NaN;
      [~, neighbInd] = min(distances);
      
      % calculate similarity of self responses (combination of correlation of
      % spike counts across all natural images and correlation of mean PSTH across time)
      similarityScoreSelf = corr(shankData(sh).rsp1(u, :)', shankData(sh).rsp2(u, :)') + ...
        corr(shankData(sh).rspPSTH1(u, :)', shankData(sh).rspPSTH2(u, :)');
      
      similarityScoreNeighbour = corr(shankData(sh).rsp1(u, :)', shankData(sh).rsp2(neighbInd, :)') + ...
        corr(shankData(sh).rspPSTH1(u, :)', shankData(sh).rspPSTH2(neighbInd, :)');
      
      if similarityScoreSelf > similarityScoreNeighbour
        matching(u, :) = [u u];
      else
        matching(u, :) = [u neighbInd];
      end
    end % loop on units
    
    % plot the matching, applying random permutation to improve visibility of mismatches
    rp = randperm(numel(shankData(sh).ch));
    plot(rp(matching(:, 1))+offset, rp(matching(:, 2))+offset, 'o', 'MarkerEdgeColor', 'none', 'MarkerFaceColor', 'r', 'MarkerSize', 3)        
    offset = offset + numel(shankData(sh).ch);
  end % loop on shanks
      
  % plot limits of individual shanks
  t = 0;
  for sh = 1:numel(shankData) 
    h = fill([t t+numel(shankData(sh).ch) t+numel(shankData(sh).ch) t],  ...
      [t t t+numel(shankData(sh).ch) t+numel(shankData(sh).ch)], 'g', ...
      'FaceColor', 0.25*[1 1 1], ...
      'FaceAlpha', 0.15, 'LineStyle', 'none');    
    t = t+numel(shankData(sh).ch);
  end
  
  axis square
end % loop on two examples

subplot(1, 2, 1)
xlabel('Unit index (day 14)')
ylabel('Index of best match (day 15)')
subplot(1, 2, 2)
xlabel('Unit index (day 15)')
ylabel('Index of best match (day 36)')
