using PyPlot, MRINavigator, MRIFiles, MRIReco, FileIO, MAT, Setfield, CSV, DataFrames, Images

include("config.jl")

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
selectSlice!(acqData, params[:slices], nav, nav_time)

@info "read ref data"
# read reference data
rawMap = RawAcquisitionData(ISMRMRDFile(params[:path_refData]))
OrderSlices!(rawMap)
acqMap = AcquisitionData(rawMap, estimateProfileCenter=true)

@info "sensemaps"
## compute or load the coil sensitivity map
if params[:comp_sensit]
    CompResizeSaveSensit(acqMap, acqData, params[:path_sensit])
end

#Load coil sensitivity
sensit = FileIO.load(params[:path_sensit], "sensit")
sensit = reshape(sensit[:,:,params[:slices],:],(size(sensit,1), size(sensit,2),
    size(params[:slices],1), size(sensit,4)))

# Load centerline (ON LINUX: file is centerline.csv, ON WINDOWS AND MAC: is centerline.nii.csv)
centerline = nothing
if params[:use_centerline] == true
    try
        run(`cat /etc/os-release`, wait = true)
    catch e
        if isa(e, ProcessFailedException)
            centerline = CSV.read(params[:path_centerline] * "centerline.nii.csv", DataFrame, header=false)
        else
            centerline = CSV.read(params[:path_centerline] * "centerline.csv", DataFrame, header=false)
        end
    end
    centerline = centerline.Column1
    centerline = centerline[params[:slices]]
end

#Load trace
trace = nothing
if params[:corr_type] == "FFT_unwrap"
    trace = read(matopen(params[:path_physio] * string(params[:rep]+1) * ".mat"), "data")
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
# plot the first echo of the image
Echo = 1
Rows = floor(Int, sqrt(size(img,3)))
dispimg = mosaicview(abs.(img[:,:,:,Echo]), nrow = Rows)
imshow(dispimg, cmap = "gray")
ax = gca()
ax[:xaxis][:set_visible](false)
ax[:yaxis][:set_visible](false)
gcf()

