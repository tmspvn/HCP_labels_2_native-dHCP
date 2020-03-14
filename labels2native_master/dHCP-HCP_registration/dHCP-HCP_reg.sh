#!/bin/bash

#the script run msm registration between the dHCP template and the HCP template using folding as the feature
path=/mnt/c/users/salvi/desktop/dHCP_template_alignment-master
age=41
dHCPdir=$path/templateDHCP
HCPdir=$path/HCP_templates
outdir=$path/dHCP-HCP_registration
config=$path/configs/config_prerotation

for hemi in L R; do 

    if [ "$hemi" == "L" ]; then
       insphere=$dHCPdir/dHCP.week${age}.L.sphere.surf.gii
       refsphere=$HCPdir/S1200.L.sphere.32k_fs_LR.surf.gii
       insulc=$dHCPdir/dHCP.week${age}.L.sulc.shape.gii
       refsulc=$HCPdir/sep_S1200.L.sulc_MSMAll.32k_fs_LR.shape.gii

    else
       insphere=$dHCPdir/dHCP.week${age}.R.sphere.surf.gii
       refsphere=$HCPdir/S1200.R.sphere.32k_fs_LR.surf.gii
       insulc=$dHCPdir/dHCP.week${age}.R.sulc.shape.gii
       refsulc=$HCPdir/sep_S1200.R.sulc_MSMAll.32k_fs_LR.shape.gii

    fi
    echo "running MSM on $hemi hemi.."
     # msm registration
    $path/msm_hocr/msm_hocr --conf=${config} --inmesh=$insphere --refmesh=$refsphere --indata=$insulc --refdata=$refsulc --out=$outdir/$hemi. 
    echo "..done"
done






#-------------------------------------------------------------

# wb_command -cifti-separate S1200.sulc_MSMAll.32k_fs_LR.dscalar.nii COLUMN -metric CORTEX_LEFT sep_S1200.L.sulc_MSMAll.32k_fs_LR.shape.gii -metric CORTEX_RIGHT sep_S1200.R.sulc_MSMAll.32k_fs_LR.shape.gii

