#!/bin/bash

masterdir=$1
masksdir=$2
subdir=$3
sub=$4
ses=$5
outdir=$6


HCPdir=$masterdir/HCP_templates
dHCPdir=$masterdir/templateDHCP
maskL=$masksdir/L.annotation.label.gii 
maskR=$masksdir/R.annotation.label.gii 

mkdir $outdir
#CORRECT
echo "Left"
wb_command -label-resample $maskL $HCPdir/S1200.L.sphere.32k_fs_LR.surf.gii $masterdir/dHCP-HCP_registration/L.sphere.reg.surf.gii BARYCENTRIC L.temp.label.gii #-area-surfs $HCPdir/S1200.L.white_MSMAll.32k_fs_LR.surf.gii $dHCPdir/dHCP.week41.L.white.surf.gii

wb_command -label-resample L.temp.label.gii $dHCPdir/dHCP.week41.L.sphere.surf.gii $subdir/sub-${sub}_ses-${ses}_hemi-L_space-dHCP2HCP.87k_sphere.reg.surf.gii BARYCENTRIC $outdir/sub-${sub}_ses-${ses}_87k.L.label.gii #-area-surfs $dHCPdir/dHCP.week41.L.white.surf.gii $subdir/sub-CC00073XX08_ses-27800_hemi-L_space-T2w_wm.surf.gii

rm L.temp.label.gii

echo "Right"
wb_command -label-resample $maskR $HCPdir/S1200.R.sphere.32k_fs_LR.surf.gii $masterdir/dHCP-HCP_registration/R.sphere.reg.surf.gii BARYCENTRIC R.temp.label.gii #-area-surfs $HCPdir/S1200.R.white_MSMAll.32k_fs_LR.surf.gii $dHCPdir/dHCP.week41.R.white.surf.gii

wb_command -label-resample R.temp.label.gii $dHCPdir/dHCP.week41.R.sphere.surf.gii $subdir/sub-${sub}_ses-${ses}_hemi-R_space-dHCP2HCP.87k_sphere.reg.surf.gii BARYCENTRIC $outdir/sub-${sub}_ses-${ses}_87k.R.label.gii #-area-surfs $dHCPdir/dHCP.week41.R.white.surf.gii $subdir/sub-CC00073XX08_ses-27800_hemi-R_space-T2w_wm.surf.gii


rm R.temp.label.gii


cd $outdir
cat $masterdir/roi_upsample/roi_list.txt | tr -d '\r' | while read -r line
do 
roiname=$line
    firstletter=${roiname:0:1} #read first letter to see if left or rigth

   case $roiname in
   ''|\#*) continue ;;         # skip blank lines and lines starting with #
     esac
     
echo "$roiname"
  
    if  [ "$firstletter" = "L" ]
    then
       #convert gifti label.gii to .func.nii only from LEFT
        wb_command -gifti-label-to-roi $outdir/sub-${sub}_ses-${ses}_87k.L.label.gii "$roiname".func.gii -name $roiname
    elif [ "$firstletter" = "R" ]
    then
       #convert gifti label.gii to .func.nii only from LEFT
        wb_command -gifti-label-to-roi $outdir/sub-${sub}_ses-${ses}_87k.R.label.gii "$roiname".func.gii -name $roiname
      
    fi
    
done

#merge rois 
#_visual_areas_left_sections_1-2
wb_command -metric-math "((a+b+c+d+e)>0)" surf_L_VIS_ROI.func.gii \
-var a L_V1_ROI.func.gii \
-var b L_V2_ROI.func.gii \
-var c L_V3_ROI.func.gii \
-var d L_ProS_ROI.func.gii \
-var e L_V4_ROI.func.gii 

#_visual_areas_rigth_sections_1-2
wb_command -metric-math "((a+b+c+d+e)>0)" surf_R_VIS_ROI.func.gii \
-var a R_V1_ROI.func.gii \
-var b R_V2_ROI.func.gii \
-var c R_V3_ROI.func.gii \
-var d R_ProS_ROI.func.gii \
-var e R_V4_ROI.func.gii 

#_premotor_area_left_section_8
wb_command -metric-math "((a+b+c+d+e+f)>0)" surf_L_PreM_ROI.func.gii \
-var a L_6a_ROI.func.gii \
-var b L_6d_ROI.func.gii \
-var c L_FEF_ROI.func.gii \
-var d L_55b_ROI.func.gii \
-var e L_PEF_ROI.func.gii \
-var f L_6r_ROI.func.gii

#_premotor_area_rigth_section_8
wb_command -metric-math "((a+b+c+d+e+f)>0)" surf_R_PreM_ROI.func.gii \
-var a R_6a_ROI.func.gii \
-var b R_6d_ROI.func.gii \
-var c R_FEF_ROI.func.gii \
-var d R_55b_ROI.func.gii \
-var e R_PEF_ROI.func.gii \
-var f R_6r_ROI.func.gii

#_auditory_area_left_section_10
wb_command -metric-math "((a+b+c+d+e)>0)" surf_L_AUD_ROI.func.gii \
-var a L_A1_ROI.func.gii \
-var b L_LBelt_ROI.func.gii \
-var c L_PBelt_ROI.func.gii \
-var d L_RI_ROI.func.gii \
-var e L_MBelt_ROI.func.gii 

#_auditory_area_rigth_section_10
wb_command -metric-math "((a+b+c+d+e)>0)" surf_R_AUD_ROI.func.gii \
-var a R_A1_ROI.func.gii \
-var b R_LBelt_ROI.func.gii \
-var c R_PBelt_ROI.func.gii \
-var d R_RI_ROI.func.gii \
-var e R_MBelt_ROI.func.gii 

#_associative_area_left_section_
wb_command -metric-math "((a+b+c+d+e+f+g+h)>0)" surf_L_ASS_ROI.func.gii \
-var a L_STSda_ROI.func.gii \
-var b L_STSva_ROI.func.gii \
-var c L_STSvp_ROI.func.gii \
-var d L_STSdp_ROI.func.gii \
-var e L_A5_ROI.func.gii \
-var f L_A5_ROI.func.gii \
-var g L_TA2_ROI.func.gii \
-var h L_STGa_ROI.func.gii 

#_associative_area_rigth_section_
wb_command -metric-math "((a+b+c+d+e+f+g+h)>0)" surf_R_ASS_ROI.func.gii \
-var a R_STSda_ROI.func.gii \
-var b R_STSva_ROI.func.gii \
-var c R_STSvp_ROI.func.gii \
-var d R_STSdp_ROI.func.gii \
-var e R_A5_ROI.func.gii \
-var f R_A5_ROI.func.gii \
-var g R_TA2_ROI.func.gii \
-var h R_STGa_ROI.func.gii 

cd $outdir
cat $masterdir/roi_upsample/roi_list.txt | tr -d '\r' | while read -r line
do 
    case $roiname in
   ''|\#*) continue ;;         # skip blank lines and lines starting with #
     esac
     
    rm $outdir/$roiname.func.gii
done













