[![](https://img.shields.io/badge/docs-latest-blue.svg)](https://NordicMRspine.github.io/MRINavigator.jl/dev)


# UserExample_MRINavigator
This folder contains example scripts for the [MRINavigator.jl](https://github.com/NordicMRspine/MRINavigator.jl) package.
For installations informations check out the package [documentation](https://NordicMRspine.github.io/MRINavigator.jl/dev).

Example data can be downloaded [here]().


# Example results
1. Images reconstructed without navigator correction.
![nocorr](./docs/nav_nocorr.png)
2. Images reconstructed after applying the [FFT_unwrap](https://nordicmrspine.github.io/MRINavigator.jl/dev/Pipelines/) navigator corection.
![corr](./docs/nav_corr.png)
3. Navigator phase estimates for different slices, displayes with the simulated respiratory belt recording.
![nav](./docs/nav.png)