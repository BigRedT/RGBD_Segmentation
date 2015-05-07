function [im_large] = getlargeimage(image,h_size,w_size)
    [h,w] = size(image);

    A = image(1:h_size,:);
    A = flip(A);
    %A = zeros(h_size,w);
    B = image(h-h_size+1:h,:);
    B = flip(B);
    %B = zeros(h_size,w);
    image = [A;image; B];
    
    C = image(:,1:w_size);
    C = flip(C,2);
    %C = zeros(h+h_size*2,w_size);
    D = image(:,w-w_size+1:w);
    D = flip(D,2);
    %D = zeros(h+h_size*2,w_size);
    im_large = [C image D];
end