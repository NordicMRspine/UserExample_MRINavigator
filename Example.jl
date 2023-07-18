using PyPlot, MRINavigator, MRIFiles, MRIReco, FileIO, MATLAB, MAT, Setfield, CSV, DataFrames, Images

# reconstruct and save in nifti the refence data
include("config.jl")
if params[:reconstruct_map] == true
    params = updateparams()
    ReconstructSaveMap(params[:path_niftiMap], params[:path_refData])
end

# find the spinal cord centerline on the reconstructed reference data
if params[:comp_SCT] == true
    callSCT(params)
end

        
# read raw data
rawData = RawAcquisitionData(ISMRMRDFile(params[:path_imgData]),
        slice = params[:slices], contrast = params[:echoes], repetition = params[:rep])

if params[:rep] != 0
    for ii = 1:length(rawData.profiles)
        rawData = @set rawData.profiles[ii].head.idx.repetition = 0
    end
end

OrderSlices!(rawData)
if params[:rep] == 0
    # load the first repetition and save the noise acquisition for optimal results in the subsequent reps
    noisemat = ExtractNoiseData!(rawData)
    FileIO.save(params[:path_noise],"noisemat",noisemat)
else
    # the noise acquisition is saved in the first repetition only
    noisemat = FileIO.load(params[:path_noise], "noisemat")
end
ReverseBipolar!(rawData)
RemoveRef!(rawData, params[:slices], params[:echoes])

(nav, nav_time) = ExtractNavigator(rawData, params[:slices])
nav_time = nav_time .* 2.5 # seconds from beginning of the day

# convert to acquisitionData (note: the estimateProfileCenter flag is set to true)
acqData = AcquisitionData(rawData, estimateProfileCenter=true)
CopyTE!(rawData, acqData)
AdjustSubsampleIndices!(acqData)
acqData = convertUndersampledData(acqData)

# read reference data
rawMap = RawAcquisitionData(ISMRMRDFile(params[:path_refData]))
OrderSlices!(rawMap)
acqMap = AcquisitionData(rawMap, estimateProfileCenter=true)

## compute or load the coil sensitivity map
if params[:comp_sensit]

    sensit = CompSensit(acqMap, 0.12)
    sensit = ResizeSensit(sensit, acqMap, acqData)

    #Save coil sensitivity
    FileIO.save(params[:path_sensit],"sensit",sensit)
end

# Load centerline
centerline = nothing
if params[:use_SCT] == true
    centerline = CSV.read(params[:path_centerline] * "centerline.nii.csv", DataFrame, header=false)
    centerline = centerline.Column1
end

#Load trace
trace = nothing
if params[:corr_type] == "FFT_unwrap"
    trace = read(matopen(params[:path_physio] * string(params[:rep]+1) * ".mat"), "data")
end

# Navigator correction
if params[:corr_type] != "none"
    addData = additionalNavInput(noisemat, rawData, acqData, acqMap, nav_time, trace, centerline)
    output = NavCorr!(nav, acqData, params, addData)
end

## Reconstruct the data
img = Reconstruct(acqData, sensit, noisemat)