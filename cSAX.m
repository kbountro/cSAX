%   cSAX representation, as introduced and studied in:
%
%   [1] K. Bountrogiannis, G. Tzagkarakis and P. Tsakalides, 
%   "Distribution  Agnostic Symbolic Representations for Time Series Dimensionality Reduction and Online Anomaly Detection," 
%   in IEEE Transactions on Knowledge and Data Engineering, 2022.
%
%   NOTE: the dataset is scanned with non-overlapping windows. If you want to 
%   scan the dataset and extract all subsequences, even overlapping ones,
%   check the other file (cSAX_overlapping). 
%
%   The fundamental difference between cSAX.m and cSAX_overlap.m is
%   that cSAX.m treats the dataset as a whole, whereas cSAX_overlap.m
%   treats the dataset as a bunch of separate subsequences.
%
%   Author: Konstantinos Bountrogiannis
%   Contact: kbountrogiannis@gmail.com
%   Date: July 2022

function [str] = cSAX(data, training_len, dim_ratio, normalize)

% Inputs:   data: data :)
%           training_len:   the number of samples used for density estimation
%           dim_ratio:  dimensionality reduction ratio. For example, if
%                       dim_ratio is 1/3, then every 3 samples of the
%                       dataset will be mapped to 1 symbol in the symbolic
%                       sequence.
%           normalize:  (0 or 1). Option to normalize each subsequence prior to
%                       processing. Normally, this is true (1).
%           
% Output:   str:    cSAX symbolic sequence.
%

    % First, remove the remainder of the dataset, such that it fits exactly.
    data_len = length(data);
    data_nseg = floor(dim_ratio*data_len);
    data_len = data_len - mod(data_len,data_nseg);
    data = data(1:data_len);
    % Do the same for the training set.
    training_nseg = floor(dim_ratio*training_len);
    training_len = training_len - mod(training_len,training_nseg);
    training_set = data(1:training_len); % Note that we opt to train on the first section of our data.

    % We will first normalize our data. Notice that we treat our dataset
    % (and the training set) as a whole, not as seperate subsequences.
    if normalize
        if std(training_set) <0.001
            data = data - mean(data);
            training_set = training_set - mean(training-set);
        else
            data = (data-mean(data))/std(data);
            training_set = (training_set-mean(training_set))/std(training_set);
        end
    end
    
    % The training will be performed on the PAA sequence
    training_PAA = tsPAA(training_set,training_nseg);

    % Mean-Shift clustering
    multi_factor = 1; % Multiplication of the default (optimal) bandwidth. 
    % multi_factor is normally equal to '1', but experimentally works better 
    % with '4' for HOT-SAX, since it benefits from smaller alphabet size.
    [clusters,paa2cluster,~] = HGMeanShiftCluster(training_PAA,'gaussian',multi_factor);
    
    % In the rare case where multi_factor is too large, search for a better
    % value. Note that this is completely heuristic and is useful only if
    % you need to test many datasets without worrying about the few that
    % might have very low variance.
    while length(clusters)<2 && multi_factor>0.5
        multi_factor = multi_factor/2;
        [clusters,paa2cluster,~] = HGMeanShiftCluster(training_PAA,'gaussian',multi_factor);
    end
    
    if length(clusters)>1
        cutlines = clusters(1:end-1)+diff(clusters)/2;
    else % If everything else fails, rollback to SAX
        alphabet_size = 10;
        cutlines = normal_cutlines(alphabet_size);
    end
    
    % Discretization as usual, but with the learned cutlines
    str = timeseries2symbol(data, data_len, data_nseg, cutlines, normalize, 1) - 1;
    str = reshape(str,[1,data_nseg]);
            
end

