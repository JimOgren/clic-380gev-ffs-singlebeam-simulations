# If running on lxplus or HTCondor, uncomment to setup placet etc.:
source /cvmfs/clicbp.cern.ch/x86_64-slc6-gcc62-opt/setup.sh

mkdir -p temp_run
cd temp_run
cp ../singlebeam_tuning_step2.tcl .
placet singlebeam_tuning_step2.tcl beam_case $1
