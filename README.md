## VicRoads dataset visualization tools and experimental files

You can find there the associated **data** and experimental files for the 
publication: *Traffic forecasting in complex urban networks: Leveraging big data and machine learning*.

Please cite the following if you use any of the resources here:

> @inproceedings{schimbinschi2015traffic,
>   title={Traffic forecasting in complex urban networks: Leveraging big data and machine learning},
>   author={Schimbinschi, Florin and Nguyen, Xuan Vinh and Bailey, James and Leckie, Chris and Vu, Hai and Kotagiri, Rao},
>   booktitle={Big Data (Big Data), 2015 IEEE International Conference on},
>   pages={1019--1024},
>   year={2015},
>   organization={IEEE}
> }

## Main Files

* `prediction_hi_low.m` -- Trains several models (choose which ones)  and uses them to predict whether the volume will exceed a certain threshold in the immediate time step (15 minutes into the future). 

* `visualize_map.m` -- Use this to visualize data on the map.

Before you can run anything you need to generate the sliding window dataset. Take a look at the script in the util folder that processes the tensor data format.

----------

## Data Set

The folder **tdata** contains the data files.

 * `VolumeData_tensor.mat` -- contains traffic volume data recorded over 6 years
    in the city of Melbourne and surrounding suburbs. 
    The data comes from a network of *1084 sensor loops* embedded under the road. 
    The measurements are taken at a frequency of 15 minutes per day,
    which yields *96 observations per day*.
    The start date for the recordings is the *1st of January 2007*.
    This file was split into 3 parts. Use these commands to merge files:
    > unix : `cat VolumeData_tensor.mat_part_* > VolumeData_tensor.mat`
    > windows : `copy /b VolumeData_tensor.mat_part_* VolumeData_tensor.mat`

 * `centerRoads.mat` -- contains the gps *coordinates* and *direction* for each sensor.
 * `euclidean.mat` -- matrix containing the Euclidean distance between sensors.


## Util

This folder contains the util files necessary for transforming the data 
and the helper files for visualisation.

 * `construct_sliding_dataset.m` -- Processes the original tensorial data by
	transforming it first to a continuous time-series for each sensor, then a
	sliding window is used to generate the response $y$ and predictor $X$ values.
	The data is split (70/30) into training/testing by default.
	A thresold for labeling whether traffic volume is high (1) or low (0) is set
	at the 0.85 quantile and is specific for each sensor. This script is ram hungry.
	Returns a .mat file containing six matrices according to the parameter setup:
	1. `trnDat` -- the predictor variables. Rows contain the concatenated
	sliding windows for each sensor. In total there are $ S \times w $ (the window size).
	2. `trnLbl` -- the response variable (continuous)
	3. `trnLblBin` -- the binary response variable according to the threshold.
	4. `tst*` -- the equivalent for testing data.
 

 * `get_data_slice.m` -- Returns the data slice $X$ and $y$ variables for a 
   specific sensor, as stored by `construct_sliding_dataset.m`.
   
 * `get_closest_idx.m` -- Returns the closest *K* sensors to a query sensor.

 * `plot_google_map.m` -- Helper function for plotting using Google Maps.


**fastAUC** -- fast computation of AUC. Might need recompiling -- read the documentation within.


<a rel="license" href="http://creativecommons.org/licenses/by-nc-sa/4.0/">
<img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by-nc-sa/4.0/88x31.png" />
</a>
