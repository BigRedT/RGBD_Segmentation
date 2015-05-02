%%  kmeans algorithm for an image
%---input---------------------------------------------------------
%   Y: 2D image
%   k: number of clusters
%   g: number of GMM components
%---output--------------------------------------------------------
%   X: 2D labels
%   GMM: Gaussian mixture model parameters

%function [X GMM]=image_kmeans(Y,k,g)
function [X GMM]=FG_estimate(Y,Y_large,g,loc)
[m n temp]=size(Y_large);
%y=reshape(Y,[m*n 3]);
%x=kmeans(y,k);
%X=reshape(x,[m n]);

[m0, n0, temp0] = size(Y);
X = ones(m,n);
X(loc(2):loc(2)+m0-1,loc(1):loc(1)+n0-1) = 2;

GMM=get_GMM(X,Y_large,g);