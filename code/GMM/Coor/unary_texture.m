function [text_unary] = unary_texture (im_rgb, im_large,loc)
    
    [h,w] = size(im_rgb(:,:,1));

    % get textons from whole image
    [texton] = learn_texton(im_large,loc, 10);
    % get textons from cropped image
    [texton_crop] = learn_texton(im_rgb,[],10);

    % hitogram
    dist = pdist2(texton_crop.fea', texton_crop.C);
    [~,I] = min(dist,[],2);
    fg_prob = texton_crop.cnt(I);   

    dist = pdist2(texton_crop.fea', texton.C);
    [~,I] = min(dist,[],2);
    bg_prob = texton.cnt(I);
    
    text_unary = reshape(log(fg_prob./bg_prob),h,w );
      
end
