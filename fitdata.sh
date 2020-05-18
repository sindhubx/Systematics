#!/bin/bash

# MC fit
function TAUP_MC_nhits {
  ./borexino archive/TAUP_MC_nhits/v100_pepMZ_nhits_CMV_0690.root pp/final_nhits_pp_0 \
    archive/TAUP_MC_nhits/fitoptions.cfg archive/TAUP_MC_nhits/species_list.icc  \
    "montecarlo_spectra_file=archive/TAUP_MC_nhits/TAUP_pep_emin1_masked_d970.root" | tee log
}

# ana npmts_dt1 fit
function TAUP_ana_npmts_dt1 {
  ./borexino archive/TAUP_ana_npmts_dt1/v100_pepMZ_npmts_dt1_CMV_0690.root pp/final_npmts_dt1_pp_0 \
    archive/TAUP_ana_npmts_dt1/fitoptions.cfg archive/TAUP_ana_npmts_dt1/species_list.icc  \
    "force_dn_after_mask=true force_subtracted_mask=true" | tee log
}

# ana charge fit
function TAUP_ana_charge {
  ./borexino archive/TAUP_charge/v100_pepMZ_charge_CMV_0690.root pp/geometrical_correction/final_charge_pp_geo_0 \
    archive/TAUP_charge/fitoptions.cfg archive/TAUP_charge/species_list.icc \
    "montecarlo_spectra_file=archive/TAUP_charge/TAUP_pep_emin1_masked_d970.root" | tee log
}

# simultaneous fit
function simultaneous_fit {
  #./borexino archive/simultaneous_fit/PABC.list | tee log
  ./borexino PABC.list | tee log
}

# mlp fit
function mlp_fit {
  ./borexino archive/mlp_fit/v400_PFull_pepMI_charge_CMVMLP_cee8.root pp/geometrical_correction/final_charge_pp_geo_0_b \
    archive/mlp_fit/fitoptions.cfg archive/mlp_fit/species_list.icc | tee log
}

TAUP_MC_nhits
#TAUP_ana_npmts_dt1
#TAUP_ana_charge
#simultaneous_fit
#mlp_fit
