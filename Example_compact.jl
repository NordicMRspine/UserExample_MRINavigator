using PyPlot, MRINavigator, MRIFiles, MRIReco, FileIO, MAT, Setfield, CSV, DataFrames, Images

include("config.jl")

(nav_output, img) = runNavPipeline(params::Dict{Symbol, Any})

@info "display recon"
# plot the first echo of the image
Echo = 1
Rows = floor(Int, sqrt(size(img,3)))
dispimg = mosaicview(abs.(img[:,:,:,Echo]), nrow = Rows)
imshow(dispimg, cmap = "gray")
ax = gca()
ax[:xaxis][:set_visible](false)
ax[:yaxis][:set_visible](false)
gcf()

