#!/bin/bash

#--flags--
A="1"
B="1"
#---------

# directories
master=/mnt/c/users/salvi/desktop/labels2native_master #master directory
subs_toppath=/mnt/c/users/salvi/desktop


# subject IDs
subjid=CC00073XX08
session=27800


#dHCP templates
template_volume=$master/templateDHCP/ga40_template_t2.nii.gz #or ga41_
template_sphere=$master/templateDHCP/dHCP.week40.%hemi%.sphere.surf.gii
template_anat=$master/templateDHCP/dHCP.week40.%hemi%.midthickness.surf.gii
template_data=$master/templateDHCP/dHCP.week40.%hemi%.sulc.shape.gii

#MNI->dHCP template prerotation
pre_rotation=$master/rotational_transforms/week40_toFS_LR_rot.%hemi%.txt
config=$master/configs/config_subject_to_40_week_template_relaxedaffine #or:
                                                    #config_prerotation_basemsm
                                                    #config_prerotationHOCR 
                                                    #config_subject_to_40_week_template_relaxedaffine
                                                    #config_subject_to_40_week_template

if [ "$A" == "1" ]; then

    echo "registration"
    $master/surface_to_template_alignment/align_to_template.sh $master $subs_toppath $subjid $session $template_volume $template_sphere $template_anat $template_data $pre_rotation $config 
    
fi

if [ "$B" == "1" ]; then

    echo "upscaling"
    #masks
    #masks name should be changed inside the script
    maskdir=$master/space-hcp_roi
    subdir=$subs_toppath/sub-${subjid}/ses-${session}/anat

    #output
    outdir=$subdir/native_space_roi

    $master/roi_upsample/roi_upsample.sh $master $maskdir $subdir $subjid $session $outdir

fi

echo "done"

