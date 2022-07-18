% pSAX representation, as introduced and studied in the following papers:
%
%   [1] K. Bountrogiannis, G. Tzagkarakis and P. Tsakalides, 
%   "Distribution  Agnostic Symbolic Representations for Time Series Dimensionality Reduction and Online Anomaly Detection," 
%   in IEEE Transactions on Knowledge and Data Engineering, 2022.
%
%   NOTE: This version scans the dataset and extracts all subsequences,
%   even overlapping ones. This version is basically used for discord detection in [1].
%   For non-overlapping windows, check the other file (cSAX.m).
%
%   The fundamental difference between cSAX.m and cSAX_overlap.m is
%   that cSAX.m treats the dataset as a whole, whereas pSAX_overlap.m
%   treats the dataset as a bunch of separate subsequences.
%
%   Author: Konstantinos Bountrogiannis
%   Contact: kbountrogiannis@gmail.com
%   Date: July 2022

function [str] = cSAX_overlap(data, training_len, win_size, paa_size, normalize)

% Inputs:   data: data :)
%           training_len:   the number of samples used for training
%           win_size:   length of sliding window
%           paa_size:   the size (dimensionality) of the PAA approximation of
%                       the subsequence in the sliding window
%           normalize:  (0 or 1). Option to normalize each subsequence prior to
%                       processing. Normally, this is true (1).
%           
% Output:   str:    A set of cSAX symbolic sequences, each for every data
%                   subsequence


    % We will first create the training set. Note that we treat our dataset
    % as a bunch of seperate subsequences. Therefore, the normalization is
    % performed independently on each subsequence.
    training_PAA = zeros(training_len-win_size+1,paa_size);
    for i = 1 : training_len-win_size+1
        sub_section = data(i:i + win_size -1);
        if normalize
            if std(sub_section)<0.001
                sub_section = sub_section - mean(sub_section);
            else
                sub_section = (sub_section - mean(sub_section))/std(sub_section);
            end
        end
        training_PAA(i,:) = tsPAA(sub_section,paa_size);
    end
    
    % The training will be performed on the PAA sequence. We can
    % concatenate it.
    training_PAA = training_PAA(:)';

    % Mean-Shift clustering
    multi_factor = 4; % Multiplication of the default (optimal) bandwidth. 
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
        alphabet_size = 3;
        cutlines = normal_cutlines(alphabet_size);
    end
    
    str = timeseries2symbol(data, win_size, paa_size, cutlines, normalize, 1) - 1;
            
end