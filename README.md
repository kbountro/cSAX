# Clustering SAX (cSAX)
MATLAB implementation of the cSAX time-series symbolic representation. Tested with MATLAB versions R2018b and R2019a.

# Table of Contents
1. [Introduction](#introduction)
2. [Modules Description](#files)
3. [Datasets](#datasets)
4. [Installation and Execution Instructions](#execution)


## Introduction <a name="introduction"></a>
The cSAX (Clustering SAX) [[1]](#1) method is an extension of the well-known SAX [[2]](#2) (Symbolic Aggregate Approximation) for time-series dimensionality reduction. The main contribution of the method is a SAX-based representation oriented for high-level mining tasks that employs the Mean-Shift clustering method for the descritization and is shown to enhance anomaly detection in the lower-dimensional space. The accuracy has been measured for anomaly detection and discord discovery.


## Files Description <a name="files"></a>
This project consists of the following components:

* **cSAX, cSAX_overlap:** Main functions, use whichever suits your application. The cSAX.m transforms the dataset with non-overlapping windows, whereas cSAX_overlap.m transforms every possible subsequence (even overlapping) separately.
* **tsPAA:** (c) 2003, E. Keogh, J. Lin, S. Lonardi, P. Patel, L. Wei. Time-series to PAA approximation. Original file with minor modifications.
* **timeseries2symbol:** (c) 2003, E. Keogh, J. Lin, S. Lonardi, P. Patel, L. Wei. Computes SAX representation of the data. Original file with minor modifications.
* **HGMeanShiftCluster:** The Mean-Shift clustering algorithm. This is a modified version of:  
Mean Shift Clustering (https://www.mathworks.com/matlabcentral/fileexchange/10161-mean-shift-clustering), (c) 2006 Bart Finkston,  
meanshift_matlab (https://github.com/hangong/meanshift_matlab), (c) 2015 Han Gong, University of East Anglia.


## Datasets <a name="datasets"></a>
A large collection of labeled datasets for anomaly detection is available at the NUMENTA library https://github.com/numenta/NAB 
and at the Hexagon ML/UCR Anomaly Detection archive https://www.cs.ucr.edu/~eamonn/time_series_data_2018/ (refer to https://forums.hexagon-ml.com/t/multi-dataset-time-series-anomaly-detection/591/136 to find the labels).


## Installation and Execution Instructions <a name="execution"></a>
1. Download the project's source files.
2. Export as they are to a single folder.
3. Call either cSAX.m or cSAX_overlap.m with the appropriate inputs.


## References
<a id="1">[1]</a> 
K. Bountrogiannis, G. Tzagkarakis and P. Tsakalides, "Distribution Agnostic Symbolic Representations for Time Series Dimensionality Reduction and Online Anomaly Detection," in IEEE Transactions on Knowledge and Data Engineering, doi: 10.1109/TKDE.2022.3174630.

<a id="2">[2]</a> 
J. Lin et al., “Experiencing SAX: A novel symbolic representation of time series”, Data Min. Knowl. Disc., vol. 15, no. 2, pp. 107–144, 2007, doi: 10.1007/s10618-007-0064-z

## License
**This code is released under GPL v.3.0. If you use this code for academic works, please cite the following publication:**

K. Bountrogiannis, G. Tzagkarakis and P. Tsakalides, "Distribution Agnostic Symbolic Representations for Time Series Dimensionality Reduction and Online Anomaly Detection," in IEEE Transactions on Knowledge and Data Engineering, doi: 10.1109/TKDE.2022.3174630.
