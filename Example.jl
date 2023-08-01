using PyPlot, MRINavigator, MRIFiles, MRIReco, FileIO, MATLAB, MAT, Setfield, CSV, DataFrames, Images

@info "Reco and Save"
# reconstruct and save in nifti the refence data
include("config.jl")
if params[:reconstruct_map] == true
    ReconstructSaveMap(params[:path_niftiMap], params[:path_refData])
end

@info "Find SC Centerline"
# find the spinal cord centerline on the reconstructed reference data
if params[:comp_SCT] == true
    callSCT(params)
end

@info "Load first rep"
# load the first repetition, slice and echo and save the noise acquisition for optimal results
# the noise acquisition is saved in the first repetition only
rawData = RawAcquisitionData(ISMRMRDFile(params[:path_imgData]),
        slice = 0, contrast = 0, repetition = 0)
noisemat = ExtractNoiseData!(rawData)
FileIO.save(params[:path_noise],"noisemat",noisemat)
        
@info "Load Raw"
# load raw data
rawData = RawAcquisitionData(ISMRMRDFile(params[:path_imgData]),
        repetition = params[:rep])

if params[:rep] != 0
    for ii = 1:length(rawData.profiles)
        rawData = @set rawData.profiles[ii].head.idx.repetition = 0
    end
else
    ExtractNoiseData!(rawData) # remove the noise acquisition
end

@info "load noise"
# load noise nacquisition
noisemat = FileIO.load(params[:path_noise], "noisemat")

OrderSlices!(rawData)
ReverseBipolar!(rawData)
RemoveRef!(rawData)

(nav, nav_time) = ExtractNavigator(rawData)
nav_time = nav_time .* 2.5 # seconds from beginning of the day

@info "convert data and adjust"
# convert to acquisitionData (note: the estimateProfileCenter flag is set to true)
acqData = AcquisitionData(rawData, estimateProfileCenter=true)
CopyTE!(rawData, acqData)
AdjustSubsampleIndices!(acqData)
acqData = convertUndersampledData(acqData)

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

    sensit = CompSensit(acqMap, 0.12)
    sensit = ResizeSensit(sensit, acqMap, acqData)

    #Save coil sensitivity
    FileIO.save(params[:path_sensit],"sensit",sensit)
end

#Load coil sensitivity
sensit = FileIO.load(params[:path_sensit], "sensit")
sensit = reshape(sensit[:,:,params[:slices],:],(size(sensit,1), size(sensit,2),
    size(params[:slices],1), size(sensit,4)))

# Load centerline (ON LINUX: file is centerline.csv, ON WINDOWS: is centerline.nii.csv)
centerline = nothing
if params[:use_SCT] == true
    centerline = CSV.read(params[:path_centerline] * "centerline.csv", DataFrame, header=false)
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
    output = NavCorr!(nav[:,:,:,params[:slices]], acqData, params, addData)
end

@info "recon"
## Reconstruct the data
img = Reconstruct(acqData, sensit, noisemat)