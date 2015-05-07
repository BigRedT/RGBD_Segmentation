function [coor_unary] = runCoorRFUnary(color_unary,im_depth, loc)
    
    mask = zeros(size(im_depth));
    mask(loc(1):loc(2), loc(3):loc(4)) = 1;
    [h,w] = size(im_depth);

    % get word coor
    [pcloud, distance] = depthToCloud(im_depth);
    pcloud = reshape(pcloud,[h*w,3]);
    pc_crop = pcloud((~~mask(:)),:);
    pc = pcloud((~mask(:)),:); 
    
    fea = [pc_crop;pc];
    % 1:foreground, 2:background
    label = [ones(size(pc_crop,1),1);2*ones(size(pc,1),1)];
    cf = color_unary(~~mask); cf = cf-min(cf(:)); cf = cf/(max(cf(:)));
    cb = color_unary(~mask); cb = cb-min(cb(:)); cb = cb/(max(cb(:)));
    W = [cf;1-cb];
    
    % param
    param.dWts = W';
    param.M = 299;
    param.F1 = 3;
    param.H = 2;
    param.maxDepth = 5;
    param.minChild = 10;
    
    forest = forestTrain( fea, label, param);
    
    % apply random forest classifier
    [hs,ps] = forestApply( single(pcloud), forest);
    
    
    coor_unary = reshape(ps(:,1),h,w);
    
    coor_unary = coor_unary(loc(1):loc(2),loc(3):loc(4));
    %subplot(1,2,1);imagesc(coor_unary);
    %subplot(1,2,2);imagesc(im_depth(loc(1):loc(2),loc(3):loc(4))); pause;

end