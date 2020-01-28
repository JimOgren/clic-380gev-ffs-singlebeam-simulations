#!/bin/bash
# setup placet etc.
source /cvmfs/clicbp.cern.ch/x86_64-slc6-gcc62-opt/setup.sh

placet /afs/cern.ch/work/j/jogren/TuningStudies/CLIC_FFS_380GeV/SingleBeamTuning_v07_tuned_beams/main/singlebeam_updated2_tuning_step1.tcl beam_case $1
