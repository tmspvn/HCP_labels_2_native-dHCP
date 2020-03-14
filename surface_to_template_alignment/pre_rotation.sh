#!/bin/bash

#mirtk needs to be compiled in a subfolder(Build) of itself. the bin file then is in the bin folder under Build
#~/MIRTK/Build/bin/mirtk

in_volume=$1
in_sphere=$2
vol_template=$3
surf_transform=$4
out_dof=$5
out_sphere=$6

out_doftxt=$(echo $out_dof | sed 's/\.dof/\.txt/g')

echo newnames $out_dof $out_doftxt $intermediate_sphere

#echo /vol/medic01/users/ecr05/software/MIRTK/BUILD/bin/mirtk register $vol_template $in_volume  -model Rigid -sim NMI -bins 64 -dofout $out_dof

#this part is done once(one reg per both hemi)
if [ ! -f $out_doftxt ]; then
    ~/MIRTK/Build/bin/mirtk register $vol_template $in_volume  -model Rigid -sim NMI -bins 64 -dofout $out_dof

    ~/MIRTK/Build/bin/mirtk convert-dof $out_dof  $out_doftxt -target $vol_template -source $in_volume -output-format flirt
else
    echo "dof exists!"
fi


#this part is done once per hemisphere
intermediate_sphere=$(echo $in_sphere | sed 's/.surf.gii/tmp_rot.surf.gii/g')

wb_command -surface-apply-affine $in_sphere $out_doftxt $intermediate_sphere

wb_command -surface-modify-sphere  $intermediate_sphere 100 $intermediate_sphere -recenter

wb_command -surface-apply-affine $intermediate_sphere  $surf_transform  $out_sphere

wb_command -surface-modify-sphere  $out_sphere 100 $out_sphere -recenter
rm $intermediate_sphere


