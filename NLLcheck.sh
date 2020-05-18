#!/bin/bash

EXEC="./borexino_NLL"
platform="gpu"
mode="validation"
#platform="cpu"
#mode="production"
function validate_fitter {
  local ref_path=$BXGOOSTATS_ROOT/$1
  local exe=$2
  local input=$3
  local hname=$4
  local cfg=$5
  local icc=$6
  local log=$7
  #gdb --args $exe $input $hname $ref_path/$cfg $ref_path/$icc 
  $exe ${ref_path}/$input $hname $ref_path/$cfg $ref_path/$icc 2>&1 &>check_tmp
  if [ $? -eq 0 ]; then
    echo OK
  else
    echo FAIL
    exit
  fi
  if [ "$mode" = 'production' ]; then
    mv NLL_CHECK_${platform}.root $ref_path
    mv check_tmp $ref_path/${log}
  else
    ./NLLCheckTest ${ref_path}/NLL_CHECK_cpu.root cpu NLL_CHECK_${platform}.root ${platform} 2e-12
    #vimdiff check_tmp $ref_path/$log
  fi
}
# charge complementary test
function check_charge {
  validate_fitter bitwiseCheck/charge_complementary_fit_onMC \
    $EXEC check_charge.root c11sub standard_fitoptions.cfg  standard_species_list.icc official_NLL_check_comp
}
# npmts_dt1 single fit, no dark noise convolution
function check_npmt_nodn_nomask_onMC {
  validate_fitter bitwiseCheck/npmt_single_fit_nodn_nomask_onMC \
    $EXEC ${bxdata}/NLLcheckInput/npmt_single_fit_noDarkNoiseConvolution/histos_standard_0-0.root \
    total_npmts_dt1 standard_fitoptions_npmt.cfg species_list_analytical.icc official_NLL_check_single_npmt_nodn_nomask_onMC
}
function check_npmt_nodn_nomask_onData {
  validate_fitter bitwiseCheck/npmt_single_fit_nodn_nomask_onData \
    $EXEC ${bxdata}/input/archive_2017_03_27/PeriodAll_FVBe7_TFCDD.root \
    pp/final_npmts_dt1_pp fitoptions_nodn_nomask.cfg species_list.icc official_NLL_check_single_npmt_nodn_nomask
}
function check_npmt_dn_nomask {
  validate_fitter bitwiseCheck/npmt_single_fit_dn_nomask_onData \
    $EXEC ${bxdata}/input/archive_2017_03_27/PeriodAll_FVBe7_TFCDD.root \
    pp/final_npmts_dt1_pp fitoptions_dn_nomask.cfg species_list.icc official_NLL_check_single_npmt_dn_nomask
}
function check_npmt_nodn_mask_onData {
  validate_fitter bitwiseCheck/npmt_single_fit_nodn_mask_onData \
    $EXEC ${bxdata}/input/archive_2017_03_27/PeriodAll_FVBe7_TFCDD.root \
    pp/final_npmts_dt1_pp fitoptions.cfg species_list.icc official_NLL_check_single_npmt_nodn_mask_onData
}
function check_npmt_dn_mask_single_nll {
  validate_fitter bitwiseCheck/npmt_single_fit_dn_mask_onData/single_species \
    $EXEC ${bxdata}/input/PeriodAll_FVBe7_TFCDD.root \
    pp/final_npmts_dt1_pp fitoptions.cfg xac official_NLL_check_single_npmt_dn_mask_xac
}
function check_npmt_dn_mask_onData {
  validate_fitter bitwiseCheck/npmt_single_fit_dn_mask_onData \
    $EXEC PeriodAll_FVBe7_TFCDD.root \
    pp/final_npmts_dt1_pp_0 fitoptions.cfg species_list.icc official_NLL_check_single_npmt_dn-newsun
}
function check_MV {
  validate_fitter bitwiseCheck/MVfit \
    $EXEC PeriodAll_FVBe7_TFCDD.root \
    pp/final_npmts_dt1_pp_0 fitoptions_mv.cfg species_list_MV.icc cpu_NLL_check
}
function check_npmt_dn_nomask_single {
local EXEC="./borexino_convolution"
  rm gpu_convolution_check_tmp 2>/dev/null
  #for sp in xa{a..j}; do
  for sp in xac; do
    $EXEC ${bxdata}/input/PeriodAll_FVBe7_TFCDD.root pp/final_npmts_dt1_pp bitwiseCheck/npmt_single_fit_dn_nomask_onData/fitoptions_dn_nomask.cfg bitwiseCheck/npmt_single_fit_dn_nomask_onData/single_species/$sp 2>&1 | tee gpu_convolution_check_tmp_$sp
    rm core.*
    sed -i '/^full/,/^ FIRST/{/^full/!{/^ FIRST/!d}}' gpu_convolution_check_tmp_$sp
    sed -i '0,/^x1.*x2.*x3.*/s//=============================THIS IS THE START===========================\n&/' gpu_convolution_check_tmp_$sp
    vimdiff gpu_convolution_check_tmp_$sp bitwiseCheck/npmt_single_fit_dn_nomask_onData/single_species/official_convolution_check_single_npmt_dn_nomask_$sp
  done
}
function check_npmt_dn_mask_single {
local EXEC="./borexino_convolution"
  rm gpu_convolution_check_tmp 2>/dev/null
  $EXEC ${bxdata}/input/PeriodAll_FVBe7_TFCDD.root pp/final_npmts_dt1_pp bitwiseCheck/npmt_single_fit_dn_mask_onData/fitoptions.cfg bitwiseCheck/npmt_single_fit_dn_nomask_onData/single_species/xac 2>&1 | tee gpu_convolution_check_tmp_xac
  sed -i '/^full/,/^ FIRST/{/^full/!{/^ FIRST/!d}}' gpu_convolution_check_tmp_xac
  sed -i '0,/^x1.*x2.*x3.*/s//=============================THIS IS THE START===========================\n&/' gpu_convolution_check_tmp_xac
  vimdiff gpu_convolution_check_tmp_xac bitwiseCheck/npmt_single_fit_dn_mask_onData/official_convolution_check_single_npmt_dn_mask_xac
}
function check_npmt_dn_nomask_convolution_onData {
local EXEC="./borexino_convolution"
  rm gpu_convolution_check_tmp 2>/dev/null
  $EXEC ${bxdata}/input/archive_2017_03_27/PeriodAll_FVBe7_TFCDD.root pp/final_npmts_dt1_pp bitwiseCheck/npmt_single_fit_dn_nomask_onData/fitoptions_dn_nomask.cfg bitwiseCheck/npmt_single_fit_dn_mask_onData/species_list.icc 2>&1 | tee gpu_convolution_check_tmp
  rm core.*
  sed -i '/^full/,/^ FIRST/{/^full/!{/^ FIRST/!d}}' gpu_convolution_check_tmp
  sed -i '0,/^x1.*x2.*x3.*/s//=============================THIS IS THE START===========================\n&/' gpu_convolution_check_tmp
  vimdiff gpu_convolution_check_tmp bitwiseCheck/npmt_single_fit_dn_nomask_onData/official_convolution_check_single_npmt_dn_nomask
}
function check_npmt_nodn_nomask_rpf_onData {
local EXEC="./borexino_RPF"
  rm gpu_rpf_check_tmp 2>/dev/null
  $EXEC ${bxdata}/input/archive_2017_03_27/PeriodAll_FVBe7_TFCDD.root pp/final_npmts_dt1_pp bitwiseCheck/npmt_single_fit_nodn_nomask_onData/fitoptions_nodn_nomask.cfg bitwiseCheck/npmt_single_fit_dn_mask_onData/species_list.icc 2>&1 | tee gpu_rpf_check_tmp
  vimdiff gpu_rpf_check_tmp bitwiseCheck/npmt_single_fit_nodn_nomask_onData/official_rpf_check
}
function check_npmt_nodn_nomask_qch_onData {
local EXEC="./borexino_Quenching"
  rm gpu_qch_check_tmp 2>/dev/null
  $EXEC ${bxdata}/input/archive_2017_03_27/PeriodAll_FVBe7_TFCDD.root pp/final_npmts_dt1_pp bitwiseCheck/npmt_single_fit_nodn_nomask_onData/fitoptions_nodn_nomask.cfg bitwiseCheck/npmt_single_fit_nodn_nomask_onData/Be7.icc 2>&1 | tee gpu_qch_check_tmp
  cat gpu_qch_check_tmp | tac | sed '/FIRST/,$d' | tac > gpu_qch_check_tmp_tmp
  sort -k 2 -g gpu_qch_check_tmp_tmp > gpu_qch_check_tmp
  cat bitwiseCheck/npmt_single_fit_nodn_nomask_onData/official_qch_check | tac | sed '/MINIMIZE/,$d' | tac > cpu_qch_check_tmp
  vimdiff gpu_qch_check_tmp cpu_qch_check_tmp
}
function check_npmt_dn_mask_ext_onData {
  #rm gpu_NLL_check_tmp
  #$EXEC ${bxdata}/input/archive_20170324_formalvalidation/PeriodAll_FVBe7_TFCDD.root pp/final_npmts_dt1_pp bitwiseCheck/npmt_single_fit_ext_onData/fitoptions_ext.cfg bitwiseCheck/npmt_single_fit_ext_onData/species_list_ext.icc 2>&1 | tee gpu_NLL_check_tmp 
  #rm core.*
  #sed -i '/^full/,/^ FIRST/{/^full/!{/^ FIRST/!d}}' gpu_NLL_check_tmp
  #grep -v "^ Default:Major" gpu_NLL_check_tmp > /tmp/gpu
  #cat /tmp/gpu>gpu_NLL_check_tmp
  #grep -v "^ Bi210" gpu_NLL_check_tmp > /tmp/gpu; mv /tmp/gpu gpu_NLL_check_tmp
  #vimdiff gpu_NLL_check_tmp bitwiseCheck/npmt_single_fit_ext_onData/official_NLL_check
  for sp in xaa xaj; do
    $EXEC ${bxdata}/input/archive_20170324_formalvalidation/PeriodAll_FVBe7_TFCDD.root pp/final_npmts_dt1_pp bitwiseCheck/npmt_single_fit_ext_onData/fitoptions_ext.cfg bitwiseCheck/npmt_single_fit_ext_onData/${sp}.icc 2>&1 | tee gpu_NLL_check_tmp_${sp}
    rm core.*
    grep -v "^ Ext" gpu_NLL_check_tmp_${sp} > /tmp/gpu; mv /tmp/gpu gpu_NLL_check_tmp_${sp}
    grep -v "^ C14" gpu_NLL_check_tmp_${sp} > /tmp/gpu; mv /tmp/gpu gpu_NLL_check_tmp_${sp}
    sed -i '/^full/,/^ FIRST/{/^full/!{/^ FIRST/!d}}' gpu_NLL_check_tmp_${sp}
    vimdiff gpu_NLL_check_tmp_${sp} bitwiseCheck/npmt_single_fit_ext_onData/official_NLL_check_${sp}
  done
}



if [ x$(pwd -P)/data == x$bxdata ]; then 
  make nll VERBOSE=1 || exit
fi

## validated
######## DN conv check
## precision on Tot: 1e-13
#check_npmt_dn_nomask_single
### precision on Tot: 1e-13
#check_npmt_dn_mask_single
######### Quenching check
### precision on npmts <1e-15
#check_npmt_nodn_nomask_qch_onData

######### NLL check
### precision on log(L) <1e-10
check_charge
##### precision on log(L) 1e-15, tot 4e-16
#check_npmt_nodn_nomask_onMC
##### precision on log(L) 6e-15, tot 4e-15 from 0.5
#check_npmt_nodn_nomask_onData
##### precision on log(L): 6e-15. on Tot: 8e-15
#check_npmt_dn_nomask
##### precision on log(L): 1e-15. on Tot: 1e-14
#check_npmt_nodn_mask_onData
##### precision on log(L): 1e-14. on Tot: 1e-14
#check_npmt_dn_mask_single_nll
##### precision on log(L): 1e-14. on Tot: 1e-14
check_npmt_dn_mask_onData
### precision: Tot 1e-7
check_MV

# working now

# failed

#dropped
#check_npmt_dn_nomask_convolution_onData
#check_npmt_dn_mask_ext_onData
