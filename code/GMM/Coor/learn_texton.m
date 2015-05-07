function [texton] = learn_texton(im_rgb,loc,k)
% learn texton on singse whole image
    % get LM filter
    F = makeLMfilters;
    mask = ones(size(im_rgb(:,:,1)));
    if ~isempty(loc)
        mask(loc(1):loc(2),loc(3):loc(4)) = 0;
    end

    [fsizeh, fsizew, fnum] = size(F);

    % image preprocess
    im = rgb2gray(im2double(im_rgb)); % gray scale
    im = im - mean(im(:)); % zero-mean
    im = im/std(im(:),1);    % std = 1;
    im = getlargeimage(im,(fsizeh-1)/2,(fsizew-1)/2);

    im_f = zeros(fnum,size(im_rgb,1)*size(im_rgb,2));
    % filter bank
    for i = 1:fnum
        ftmp = F(:,:,i);
        ftmp = ftmp / norm(ftmp(:),1); % L1 normalization
        ftmp = conv2(im, ftmp, 'valid');
        im_f(i,:) = (ftmp(:))';
    end

    % normalize filter response
    for i = 1:size(im_f,2)
        ftmp = im_f(:,i);
        lx = norm(ftmp);
        im_f(:,i) = ftmp*log(1+lx/0.03)/lx;
    end

    % clustering
    %[idx, C] = kmeans(im_f(:,find(mask))',10);
    [idx, C] = litekmeans(im_f(:,find(mask))',k);
    table = tabulate(idx);
    [~, idx0] = sort(table(:,1),'ascend');
    table = table(idx0,:);
    cnt = table(:,2);
    cnt = cnt/sum(cnt);
    texton.C = C;
    texton.cnt = cnt;
    texton.fea = im_f;
end
