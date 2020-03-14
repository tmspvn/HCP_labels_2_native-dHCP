#!/bin/bash

# script to align native surfaces with template space & resample native surfaces with template topology 
# output: native giftis resampled with template topology
#edited version by Tommaso Pavan , Oldenburg uni 

Usage() {
    echo "align_to_template.sh <masterdir> <topdir> <subjid> <session> <template volume> <template sphere> <template  data> <pre_rotation> <outdir>  <config>"
    echo " script to align native surfaces with template space & resample native surfaces with template topology "
    echo " input args: "
    echo " masterdir: top directory where label2native is located "
    echo " topdir: top directory where subject directories are located "
    echo " subjid : subject id "
    echo " session: subject scan session "
    echo " template volume: template T2 volume " #FROM dHCP first template Shun et al.(there are the volumetric and surface(bozak et al.))
    echo " template sphere: template sphere.surf.gii (with wildcard %hemi% in place of hemisphere) "
    echo " template anat: template anatomy file i.e. white or midthickness.surf.gii (with wildcard %hemi% in place of hemisphere) "
    echo " template data : template sulc.shape.gii (with wildcard %hemi% in place of hemisphere) "
    echo " pre_rotation : txt file containing rotational transform between MNI and FS_LR space (i.e. file rotational_transforms/week40_toFS_LR_rot.%hemi%.txt  ) "
    echo " config : base config file "
    echo "output: 1) surface registrations; 2)  native giftis resampled with template topology "
}

if [ "$#" -lt 10  ]; then
echo "$#" 
   Usage
   exit
fi


masterdir=$1;shift
topdir=$1;shift
subjid=$1;shift
session=$1;shift
templatevolume=$1;shift
templatesphere=$1;shift
templateanat=$1;shift
templatedata=$1;shift
pre_rotation=$1;shift
config=$1; shift


outdir=$topdir/sub-$subjid/ses-$session/anat/int_transforms
mkdir $outdir #make output directory
mkdir -p $outdir $outdir/volume_dofs $outdir/surface_transforms
#outputs /volume_dofs/: {subjid}-${session}.dof
#outputs /surface_transforms/: 


# define paths to variables
#sub-CC00073XX08_ses-27800_desc-restore_T2w.nii.gz
native_volume=${topdir}/sub-${subjid}/ses-$session/anat/sub-${subjid}_ses-${session}_desc-restore_T2w.nii.gz 

# native(T2w) spheres
#sub-CC00073XX08_ses-27800_hemi-L_space-T2w_sphere.surf.gii
native_sphereL=${topdir}/sub-${subjid}/ses-$session/anat/sub-${subjid}_ses-${session}_hemi-L_space-T2w_sphere.surf.gii
native_sphereR=${topdir}/sub-${subjid}/ses-$session/anat/sub-${subjid}_ses-${session}_hemi-R_space-T2w_sphere.surf.gii

echo native spheres $native_sphere_L $native_sphere_R

# native spheres rotated into FS_LR space 
#INTERNAL OUTPUT NAMES OF pre_rotation.sh. NOT ACTUAL INPUT
native_rot_sphereL=${topdir}/sub-${subjid}/ses-$session/anat/int_transforms/sub-${subjid}_ses-${session}_L_sphere.rot.surf.gii
native_rot_sphereR=${topdir}/sub-${subjid}/ses-$session/anat/int_transforms/sub-${subjid}_ses-${session}_R_sphere.rot.surf.gii


# native(T2w) data
#sub-CC00073XX08_ses-27800_hemi-L_space-T2w_sulc.shape.gii
native_dataL=${topdir}/sub-${subjid}/ses-$session/anat/sub-${subjid}_ses-${session}_hemi-L_space-T2w_sulc.shape.gii
native_dataR=${topdir}/sub-${subjid}/ses-$session/anat/sub-${subjid}_ses-${session}_hemi-R_space-T2w_sulc.shape.gii

# pre-rotations(made with estimate_pre_rotaton.sh)
pre_rotationL=$(echo ${pre_rotation} |  sed "s/%hemi%/L/g")
pre_rotationR=$(echo ${pre_rotation} |  sed "s/%hemi%/R/g")


echo "1-rotate left and right hemispheres into approximate alignment with MNI space"
# rotate left and right hemispheres into approximate alignment with MNI space
#echo ${SURF2TEMPLATE}/surface_to_template_alignment/pre_rotation.sh $native_volume $native_sphereL $templatevolume $pre_rotationL $outdir/volume_dofs/${subjid}-${session}.dof ${native_rot_sphereL}
$masterdir/surface_to_template_alignment/pre_rotation.sh $native_volume $native_sphereL $templatevolume $pre_rotationL $outdir/volume_dofs/${subjid}-${session}.dof ${native_rot_sphereL}
$masterdir/surface_to_template_alignment/pre_rotation.sh $native_volume $native_sphereR $templatevolume $pre_rotationR $outdir/volume_dofs/${subjid}-${session}.dof ${native_rot_sphereR}



# run msm non linear alignment to template for left and right hemispheres
echo "2-run msm non linear alignment to template for left and right hemispheres"
for hemi in L R; do
    
    refmesh=$(echo $templatesphere | sed "s/%hemi%/$hemi/g")
    refdata=$(echo $templatedata | sed "s/%hemi%/$hemi/g")

    if [ "$hemi" == "L" ]; then
       inmesh=$native_rot_sphereL
       indata=$native_dataL
       outname=$outdir/surface_transforms/sub-${subjid}_ses-${session}_hemi-L_space-dHCP2HCP.87k_ #replaced left with hemi-L_space-dHCP_..

    else
       inmesh=$native_rot_sphereR
       indata=$native_dataR
       outname=$outdir/surface_transforms/sub-${subjid}_ses-${session}_hemi-R_space-dHCP2HCP.87k_ #..and right with hemi-R_space-dHCP_
    fi

    if [ ! -f ${outname}sphere.reg.surf.gii ]; then
	# msm  --conf=${config}  --inmesh=${inmesh}  --refmesh=${refmesh} --indata=${indata} --refdata=${refdata} --out=${outname} --verbose
    echo "running msm on $hemi hemi.. "
	 $masterdir/msm_hocr/msm_hocr --conf=${config}  --inmesh=${inmesh}  --refmesh=${refmesh} --indata=${indata} --refdata=${refdata} --out=${outname} 
    fi

    #copy from internat registrations folder to main anat folder.
    cp ${outname}sphere.reg.surf.gii ${topdir}/sub-${subjid}/ses-$session/anat/
    
done





