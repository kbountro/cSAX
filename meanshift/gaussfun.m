function out = gaussfun(x,d,bandWidth)
% approximate Gaussian kernel
% x - value
% d - location
% bandWidth - band width of the kernel
% out - contribtion to the kernel mean
%
% Copyright 2015 Han Gong, University of East Anglia

    ns = 1000; % resolution of kernel approximation
    xs = linspace(0,bandWidth^2,ns+1); % approximate ticks
    kfun = exp(-(xs)/(2*bandWidth^2));
    w = kfun(round(d/bandWidth^2*ns)+1);
    out = sum( bsxfun(@times, x, w ), 2 )/sum(w);
end
