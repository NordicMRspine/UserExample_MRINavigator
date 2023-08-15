params = Dict{Symbol,Any}()
params[:subject] = "sub-9031"
params[:slices] = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18]
params[:echoes] = [1,2]
params[:rep] = 0
params[:reconstruct_map] = true
params[:comp_sensit] = true
params[:comp_centerline] = true
params[:trust_SCT] = false
params[:use_centerline] = true
params[:corr_type] = "FFT_unwrap"
params[:FFT_interval] = 35 #70 millimiters
params[:root_path] = "/srv/data/ajaffray/data_nordic_mr_spine/"

params[:lable] = params[:corr_type] * "_rep_" * string(params[:rep])
params[:path_imgData] = params[:root_path] * params[:subject] * "/h5/gre2D_PS_TASCI_2.h5"
params[:path_refData] = params[:root_path] * params[:subject] * "/h5/gre2D_Ref_2.h5"
params[:path_niftiMap] = params[:root_path] * params[:subject] * "/Nifti/gre2D_Ref.nii"
params[:path_centerline] = params[:root_path] * params[:subject] * "/Nifti/"
params[:path_physio] = params[:root_path] * params[:subject] * "/Physiological_trace/belt_reco_rep"
params[:path_sensit] = params[:root_path] * params[:subject] * "/Results/MapEspirit_GRE_0p5.jld2"
params[:path_noise] = params[:root_path] * params[:subject] * "/Results/noisemat.jld2"
params[:path_results] = params[:root_path] * params[:subject] * "/Results/"
file_name = split(params[:path_imgData], "/")
file_name = last(file_name)
file_name = split(file_name, "_2.h5")
params[:file_name] = first(file_name)