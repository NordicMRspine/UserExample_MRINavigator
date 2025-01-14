[![](https://img.shields.io/badge/docs-latest-blue.svg)](https://NordicMRspine.github.io/MRINavigator.jl/dev)


# UserExample_MRINavigator
This folder contains example scripts for the [MRINavigator.jl](https://github.com/NordicMRspine/MRINavigator.jl) package. The package documentation can be found [here](https://NordicMRspine.github.io/MRINavigator.jl/dev).

An example dataset acquired on a phantom can be downloaded [here](https://doi.org/10.5281/zenodo.10731729). When the download is complete extract to your local folder.

## Installation
To use some package functionalities, external software are required. Specifically: [Spinal Cord Toolbox](https://spinalcordtoolbox.com/stable/) and [FSLeyes](https://open.win.ox.ac.uk/pages/fsl/fsleyes/fsleyes/userdoc/install.html).

The example data consists of a folder named **sub01** containing the files and folder structure needed to run the example scripts. This can be installed in any parent directory of your choice.

This example scripts directory also needs to be installed in a location of your choice. There are two main options to do this:
1. Open a terminal or command prompt and navigate to the desired directory, then clone the repository using Git:
    ```
    git clone https://github.com/NordicMRspine/UserExample_MRINavigator.git
    ```
2. Click the green **Code** button at the top right of this webpage, then select **Download ZIP**. Once the download is completed extract its contents into your desired directory.

Once the code is installed, select the Julia environment in which you want to run it. It is recommended to create a new environment in the folder where the code is located. To install all the packages listed in the Manifest.toml file, you can use the Pkg.instantiate function. Follow these steps:
1. Open the Julia REPL.
2. Activate your environment:
    ```
    using Pkg
    Pkg.activate("path/to/environment")
    ```
3. Install all the packages running:
    ```
    Pkg.instantiate()
    ```

Before running the script open the **config.jl** file and insert the path of the parent directory of the example data in line 14 (assigning it to `params[:root_path]`). 
Add the folder separation symbol (`/` for macOS/Linux or `\` for Windows) at the end of the path. This indicates that the path refers to a folder and not a file.
Additional input parameters can be modified in the **config.jl** file.

The example scripts ([Example_compact.jl](https://github.com/NordicMRspine/UserExample_MRINavigator/blob/slice_echo_selection/Example_compact.jl), 
[Example_semiCompact.jl](https://github.com/NordicMRspine/UserExample_MRINavigator/blob/slice_echo_selection/Example_semiCompact.jl), and 
[Example_complete.jl](https://github.com/NordicMRspine/UserExample_MRINavigator/blob/slice_echo_selection/Example_complete.jl)) can be run now.

## Example results
The following example results can be obtained running the user example scripts contained in this folder on the available [phantom data](https://doi.org/10.5281/zenodo.10731729).
1. Images reconstructed without navigator correction (`params[:corr_type] = "none"` in the [parameters dictionary](https://nordicmrspine.github.io/MRINavigator.jl/dev/GettingStarted/#The-parameters-dictionary)).

![nocorr](./docs/nav_nocorr.png)

2. Images reconstructed after applying the [FFT_unwrap](https://nordicmrspine.github.io/MRINavigator.jl/dev/Pipelines/) navigator correction (`params[:corr_type] = "FFT_unwrap"`).

![corr](./docs/nav_corr.png)

3. Navigator phase estimates for different slices obtained with the FFT_unwrap approach, displayed with the simulated respiratory belt recording.

![nav](./docs/nav.png)

The figures were generated on a machine running macOS Sonoma 14.5 (Apple M1 Max chip).

## Acknowledgement
The authors thank the ISMRM Reproducible Research Study Group for conducting a code review of the code (package version 0.1.1, user exaple version 0.0.1). The scope of the code review covered only the code’s ease of download, quality of documentation, and ability to run, but did not consider scientific accuracy or code efficiency.