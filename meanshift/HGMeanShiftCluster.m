function [clustCent,data2cluster,cluster2dataCell] = HGMeanShiftCluster(dataPts,kernel,multi_factor)
%HGMEANSHIFTCLUSTER performs MeanShift Clustering of data using a chosen kernel
%
% Inputs:   dataPts:        input data, (numDim x numPts)
%           kernel:         kernel type (flat or gaussian)
%           multi_factor:   multiplication factor of default bandwidth
%           
% Output:   clustCent:          is locations of cluster centers (numDim x numClust)
%           data2cluster:       for every data point which cluster it belongs to (numPts)
%           cluster2dataCell:   for every cluster which points are in it (numClust)
%
%
% This is a modified version of:  
% Mean Shift Clustering (https://www.mathworks.com/matlabcentral/fileexchange/10161-mean-shift-clustering), (c) 2006 Bart Finkston,
% meanshift_matlab (https://github.com/hangong/meanshift_matlab), (c) 2015 Han Gong, University of East Anglia.
% 
% The main modification is the addition of the Epanechnikov kernel, along
% with a few minor algorithmic modifications.
%
%   Author: Konstantinos Bountrogiannis
%   Contact: kbountrogiannis@gmail.com
%   Date: July 2022


%*** Check input ****
if nargin < 2
    error('no kernel specified')
end
if nargin < 3
    multi_factor = 1;
end

%**** Initialize stuff ***
[numDim,numPts] = size(dataPts);
numClust = 0;

initPtInds = 1:numPts;
maxPos = max(dataPts,[],2); % biggest size in each dimension
minPos = min(dataPts,[],2); % smallest size in each dimension
boundBox = maxPos-minPos; % bounding box size
sizeSpace = norm(boundBox); % indicator of size of data space

clustCent = []; % center of clust
beenVisited= false(1,numPts); % track if a points been seen already
numInitPts = numPts; % number of points to posibaly use as initilization points
clusterVotes = zeros(1,numPts,'uint16'); % used to resolve conflicts on cluster membership
clustMembsCell = [];

% Get a robust estimate of sigma
sig = min(std(dataPts,0,2),iqr(dataPts)/1.34);
if sig==0
    sig = max(std(dataPts,0,2),iqr(dataPts)/1.34);
end

%*** mean function with the chosen kernel ****
switch kernel
case 'flat' % flat kernel
    C = 2.3449; % optimal bandwidth for Epanechnikov kernel (shadow of Flat kernel)
    bandWidth = sig*C*numPts^(-1/5)+eps;
    neighRadius = bandWidth^2;
    kmean = @(x,dis) mean(x,2);
case 'gaussian' % approximated gaussian kernel
    C = 0.9686;
    bandWidth = multi_factor*sig*C*numPts^(-1/7)+eps*(sig==0);
    neighRadius = (bandWidth)^2;
    kmean = @(x,d) gaussfun(x,d,bandWidth);
case 'epanechnikov' 
    C = 1.5232;
    bandWidth = sig*C*numPts^(-1/7)+eps*(sig==0);
    neighRadius = bandWidth^2;
    kmean = @(x,d) epanechfun(x,d,bandWidth);
otherwise
    error('unknown kernel type');
end

stopThresh = 1e-3*neighRadius; % when mean has converged

while numInitPts
    tempInd = ceil( (numInitPts-1e-6)*rand); % pick a random seed point
    stInd = initPtInds(tempInd); % use this point as start of mean
    myMean = dataPts(:,stInd);  % intilize mean to this points location
    myMembers = []; % points that will get added to this cluster                          
    thisClusterVotes = zeros(1,numPts,'uint16'); % used to resolve conflicts on cluster membership

    while true %loop untill convergence
        sqDistToAll = sum((bsxfun(@minus,myMean,dataPts)).^2,1); % dist squared from mean to all points still active
        
        inInds = find(sqDistToAll < neighRadius); % points within bandWidth
        if isempty(inInds)
            myOldMean = myMean;
        else
            thisClusterVotes(inInds) = thisClusterVotes(inInds)+1; % add a vote for all the in points belonging to this cluster

            myOldMean = myMean; % save the old mean
            myMean = kmean(dataPts(:,inInds),sqDistToAll(inInds)); % compute the new mean
            myMembers = [myMembers inInds]; % add any point within bandWidth to the cluster
            beenVisited(myMembers) = true; % mark that these points have been visited
        end


        %**** if mean doesn't move much stop this cluster ***
        if norm(myMean-myOldMean) <= stopThresh
            %check for merge posibilities
            mergeWith = 0;
            for cN = 1:numClust
                distToOther = norm(myMean-clustCent(:,cN))^2; % distance to old clust max
                if distToOther < neighRadius/2 && numClust>=2 % if its within bandwidth/2 merge new and old
                    mergeWith = cN;
                    break;
                end
            end
            
            if mergeWith > 0 % something to merge
                nc = numel(myMembers); % current cluster's member number
                no = numel(clustMembsCell{mergeWith}); % old cluster's member number
                nw = [nc;no]/(nc+no); % weights for merging mean
                clustMembsCell{mergeWith} = unique([clustMembsCell{mergeWith},myMembers]);   %record which points inside 
                clustCent(:,mergeWith) = myMean*nw(1) + myOldMean*nw(2);
                clusterVotes(mergeWith,:) = clusterVotes(mergeWith,:) + thisClusterVotes;    %add these votes to the merged cluster
            else % it's a new cluster
                numClust = numClust+1; %increment clusters
                clustCent(:,numClust) = myMean; %record the mean  
                clustMembsCell{numClust} = myMembers; %store my members
                clusterVotes(numClust,:) = thisClusterVotes; % creates a new vote
            end

            break;
        end

    end
    
    initPtInds = find(~beenVisited); % we can initialize with any of the points not yet visited
    numInitPts = length(initPtInds); %number of active points in set
end

[~,data2cluster] = max(clusterVotes,[],1); % a point belongs to the cluster with the most votes

%*** If they want the cluster2data cell find it for them
if nargout > 2
    cluster2dataCell = cell(numClust,1);
    for cN = 1:numClust
        myMembers = find(data2cluster == cN);
        cluster2dataCell{cN} = myMembers;
    end
end

end
