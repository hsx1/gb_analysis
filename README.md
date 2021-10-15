# Functions for Data Analysis of second level data of the GB project

## Descriptions

Performs second level analysis using the SwE toolbox (Guillaume et al., 2014) for data, derived from a specific longitudinal, intervention study.

## Usage

1. Connect to compute server and open new linux screen to run analysis and log output.

```console
screen -dmS screenname -L -Logfile filepath/filename.log
```

2. Start matlab without GUI

```console
matlab -nodisplay -nodesktop
```

3. In case the folder is not added to your Path for Matlab, change the working directory to the folder.

```matlab
cd("path/gb_analysis")
```

4. Before starting the analysis, select preset to run or use `select` as preset to select configuration manually via a GUI. 

```matlab
help gb_config
```

5. Start to run the analysis with the seleced preset. 
    - It is advised to enable parallel processing.
    - View function function documentation for more details.
    - _Internal note when using MPI servers_: each model may run between half an hour and several hours. 

```matlab
gb_config(...)
```

## Dependencies

1. [Matlab R2021a](https://de.mathworks.com/products/matlab.html?s_tid=srchtitle_matlab_1)
1. [SPM12](https://www.fil.ion.ucl.ac.uk/spm/software/spm12/) (Ashburner et al., 2014)
1. [SwE-toolbox-2.2.2](https://github.com/NISOx-BDI/SwE-toolbox/releases/tag/v2.2.2) (Guillaume et al., 2014)

## Prerequisits (!)

1. Finished preprocessed first level contrasts
1. CSV file containing relevant information for model defintion 

## Example

Estimation of all possible models that are not estimated yet or where estimation was interrupted before results could be obtained with parallel processing.

```matlab
gb_config("all", "estimate", true)
```

## Note 

- Example csv with simulated data will be uploaded soon!
- Example MRI data cannot referenced/shared before publication


## References

Ashburner, J., Barnes, G., Chen, C., Daunizeau, J., Flandin, G., Friston, K. & Penny, W … (2014). Spm12 manual. Wellcome Trust Centre for Neu-roimaging, London, UK, 2464

Guillaume, B., Hua, X., Thompson, P. M., Waldorp, L., & Nichols, T. E.(2014). Fast and accurate modelling of longitudinal and repeated mea-sures neuroimaging data. NeuroImage, 94, 287–302. doi: [10.1016/j.neuroimage.2014.03.029](https://doi.org/10.1016/j.neuroimage.2014.03.029)