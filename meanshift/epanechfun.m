function out = epanechfun(x,d,bandWidth)

    a = 2;
    ns = round(1000); % resolution of kernel approximation
    xs = linspace(0,a*bandWidth^2,ns+1); % approximate ticks
    
    kfun = max(0,(1 - (xs)/(bandWidth^2)));
    w = kfun(round(d/(a*bandWidth^2)*ns)+1);
    out = sum( bsxfun(@times, x, w ), 2 )/sum(w);
end