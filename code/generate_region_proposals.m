function region_proposals = generate_region_proposals(I, params, plotFlag)
%%
% Input:
%        I: w x h x 3 color image
%        params: initialized in runThis
%	 plotFlag: [optional] set true, to visualize boxes
% Output:
%        regions: [n x 6] array, each row [x1 y1 w h x2 y2], I(y1:y2, x1:x2) is region
%%

if nargin < 3
	plotFlag = false;
end

[opts, model] = get_model_opts();

disp('** Generating edge boxes **');
tic, bbs=edgeBoxes(I,model,opts); toc

%threshold by score
bbs = bbs(1:params.score_threshold_num, :);

bbs = [bbs, bbs(:, 1) + bbs(:, 3), bbs(:, 2) + bbs(:, 4)];

id = 1;
region_proposals = [];
region_proposals(end+1, :) = bbs(id, :);

%TODO(aditya): threshold by intersection over union
region_proposals(end+1:end+params.num_regions-1,:) = bbs(id+1:id+params.num_regions-1, :);

if plotFlag == true
	figure(1);
	title('Detected Regions');
	cVec = 'bgrcmykbgrcmykbgrcmykbgrcmyk'; cVec = [cVec cVec];
	imshow(I);
	for i = [1:size(region_proposals,1)]
		hold on;
		rectangle('Position', region_proposals(i, 1:4), 'EdgeColor', cVec(i));
	end
	
	figure(2);
	nRows = floor((size(region_proposals, 1)-1)/5) + 1;
	for i = [1:size(region_proposals,1)]
		subplot(nRows, 5, i);
		imshow( I( round(region_proposals(i,2)):round(region_proposals(i,7)), round(region_proposals(i,1)):round(region_proposals(i,6)), :) );
	end
	
end

end

function [opts, model] = get_model_opts()
	addpath(genpath('third_party/toolbox/'));
	addpath(genpath('third_party/edge_boxes/release/'));

	%% load pre-trained edge detection model and set opts (see edgesDemo.m)
	model=load('models/forest/modelBsds'); model=model.model;
	model.opts.multiscale=0; model.opts.sharpen=2; model.opts.nThreads=4;

	%% set up opts for edgeBoxes (see edgeBoxes.m)
	opts = edgeBoxes;
	opts.alpha = .65;     % step size of sliding window search
	opts.beta  = .75;     % nms threshold for object proposals
	opts.minScore = .01;  % min score of boxes to detect
	opts.maxBoxes = 1e4;  % max number of boxes to detect
end
