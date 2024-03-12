using PyPlot, MRINavigator, MRIFiles, MRIReco, FileIO, MAT, Setfield, CSV, DataFrames, Images

include("config.jl")

# double click enter after checking centerline position to proceed
(output, img) = runNavPipeline(params::Dict{Symbol, Any})

@info "display recon"
# plot the last echo of the image
img = reshape(img, (size(img,1), size(img,2), size(img,3), size(img,4)))
img = img[:,:,:,end:end]
img = permutedims(img, (2,1,3,4))
img = reverse(img, dims = 1)
Rows = ceil(Int, sqrt(size(img,3)))
figure()
dispimg = mosaicview(abs.(img[:,:,:]), nrow = Rows)
imshow(dispimg, cmap = "gray", vmax = 9e-7, aspect = "equal")
ax = gca()
ax[:xaxis][:set_visible](false)
ax[:yaxis][:set_visible](false)
gcf()

@info "display navigator estimates"
# plot the navigator estimates and respiratory trace recording
figure()
x = (output.nav_time[:,:] .- output.nav_time[1,1])/1000
p = plot((output.trace_time .- output.nav_time[1,1])/1000, output.trace_aligned, ".", markersize = 2 , color = "k")
p = plot(x, output.navigator[1,1,:,:], linewidth=2.0)
#legend(["belt trace", "slice 1", "slice 2", "slice 3", "slice 4"],loc=4)
xlabel("Time [s]")
ylabel("Phase variations [rad]")
gcf()