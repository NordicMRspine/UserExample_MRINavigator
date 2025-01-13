using PyPlot, MRINavigator, MRIFiles, MRIReco, FileIO, MAT, Setfield, CSV, DataFrames, Images

include("config.jl")

# double click enter after checking centerline position to proceed
findCenterline(params)
saveNoise(params[:path_imgData], params[:path_noise]::String)
rawData = loadRawData(params)

@info "load noise"
# load noise nacquisition
noisemat = FileIO.load(params[:path_noise], "noisemat")

@info "Extract navigator data. The time stamps are accurate only for Siemens data."
@info "The navigaotr extraction is effective only if the navigator profile was acquired after the first image profile."
(nav, nav_time) = ExtractNavigator(rawData)
nav_time = nav_time .* 2.5 # seconds from beginning of the day (Siemens data only)

acqData = convertRawToAcq(rawData)

# slice and echo selection on acquisition data
selectEcho!(acqData, params[:echoes])
(nav, nav_time) = selectSlice!(acqData, params[:slices], nav, nav_time)

@info "read ref data"
# read reference data
rawMap = RawAcquisitionData(ISMRMRDFile(params[:path_refData]))
OrderSlices!(rawMap)
acqMap = AcquisitionData(rawMap, estimateProfileCenter=true)

@info "sensemaps"
## compute or load the coil sensitivity map
if params[:comp_sensit]
    CompResizeSaveSensit(acqMap, acqData, params[:path_sensit], params[:mask_thresh])
end

#Load coil sensitivity
sensit = FileIO.load(params[:path_sensit], "sensit")
if !isnothing(params[:slices])
    sensit = reshape(sensit[:,:,params[:slices],:],(size(sensit,1), size(sensit,2),
        size(params[:slices],1), size(sensit,4)))
end

# Load centerline (ON LINUX: file is centerline.csv, ON WINDOWS AND MAC: is centerline.nii.csv)
centerline = nothing
if params[:use_centerline] == true
    if isfile(params[:path_centerline] * "centerline.nii.csv")
        centerline = CSV.read(params[:path_centerline] * "centerline.nii.csv", DataFrame, header=false)
    else
        centerline = CSV.read(params[:path_centerline] * "centerline.csv", DataFrame, header=false)
    end
    centerline = centerline.Column1
    if !isnothing(params[:slices])
        centerline = centerline[params[:slices]]
    end
end

#Load trace
trace = nothing
if params[:corr_type] == "FFT_unwrap"
    trace = read(matopen(params[:path_physio]), "data")
end

@info "nav corr"
# Navigator correction
if params[:corr_type] != "none"
    addData = additionalNavInput(noisemat, rawData, acqData, acqMap, nav_time, trace, centerline)
    output = NavCorr!(nav, acqData, params, addData)
end

@info "recon"
## Reconstruct the data
img = Reconstruct(acqData, sensit, noisemat)


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
