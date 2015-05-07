function [im_large] = getlargeimage2(image,h_size,w_size)
    [h,w] = size(image);

    A = image(1,:);
    A = repmat(A,h_size,1);
    B = image(end,:);
    B = repmat(B,h_size,1);
    image = [A;image; B];
    
    C = image(:,1);
    C = repmat(C,1,w_size);
    D = image(:,end);
    D = repmat(D,1,w_size);
    im_large = [C image D];
end