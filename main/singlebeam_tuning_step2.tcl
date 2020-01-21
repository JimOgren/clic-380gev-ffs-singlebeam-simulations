#############################################################################
#
# Tuning studies for single beam
#
#############################################################################
ParallelThreads -num 4

set t_1 [clock seconds]

set e_initial 190
set e0 $e_initial

set script_dir /afs/cern.ch/work/j/jogren/TuningStudies/CLIC_FFS_380GeV/SingleBeamTuning_v03
#set script_dir /home/jogren/cernbox/TuningStudies/CLIC_FFS_380GeV/SingleBeamTuning_v03

if {![file exist $script_dir]} {
    puts "script_dir path does not exist"
    set script_dir [pwd]/..
}

# command-line options
# sr          : synchrotron radiation on/off
# sigma       : misalignment in um
# sigmaM      : misalignment for multipoles in um
# sigmak      : relative magnetic strength errors
# sigmaroll   : roll misalignment in urad
# bpmres      : bpm resolution in um
# deltae      : energy difference for dfs
# machine     : machine seed
# loadmachine : load machine status from file on/off
# dfsmeasure  : to measure nominal dispersion and create model file
# wdisp       : gain for dispersion target steering (dts)
# iterdts     : number of dts iterations
# gaindts     : gain for dts
# beam_case   : which beam to load: 8, 20, 30 (vertical emittance)

array set args {
    sr 1
    sigma 10.0
    sigmaM 10.0
    sigmak 1e-4
    sigmaroll 100.0
    bpmres 0.020
    deltae 0.001
    machine 1
    loadmachine 1
    measure_response 0
    wdisp 0.71
    iterdts 30
    gaindts 0.5
    beam_case 20
}

array set args $argv
set sigma $args(sigma)
set sigmaM $args(sigmaM)
set sigmak $args(sigmak)
set sigmaroll $args(sigmaroll)
set bpmres $args(bpmres)
set deltae $args(deltae)
set sr $args(sr)
set machine $args(machine)
set loadmachine $args(loadmachine)
set measure_response $args(measure_response)
set wdisp $args(wdisp)
set iterdts $args(iterdts)
set gaindts $args(gaindts)
set beam_case $args(beam_case)


#############################################################################
# load header files:
source $script_dir/scripts/make_beam.tcl
source $script_dir/scripts/wake_calc.tcl
source $script_dir/scripts/octave_functions.tcl
source $script_dir/main/beam_parameters.tcl

# load lattice and create beams
source $script_dir/main/loadlattice.tcl
source $script_dir/main/createbeams.tcl
source $script_dir/scripts/calc_lumi.tcl

# Load beam from integrated simulation
source $script_dir/scripts/load_beam.tcl

FirstOrder 1

# Go through lattice file and find indices for different elements:
source $script_dir/scripts/element_indices.tcl

# Measure target dispersion
if { $measure_response } {
   source $script_dir/scripts/measure_nominal_dispersion.tcl
}
# load target dispersion 
source $script_dir/scripts/load_machine_model.tcl

# Load file with tuning procedures
source setup_knobs.tcl

# Step 1 load machine after tuning
#############################################################################
load_beamline_status "test" /afs/cern.ch/work/j/jogren/TuningStudies/CLIC_FFS_380GeV/SingleBeamTuning_v03/main/Results_ey${beam_case}nm/Results_tuning_step1/machine_status_$machine.dat
source $script_dir/scripts/checkStatus.tcl

# Tune octupoles and re-tune sextupoles (transverse position)
#############################################################################
octupole_knobs 10
source $script_dir/scripts/checkStatus.tcl
octupole_knobs 5
source $script_dir/scripts/checkStatus.tcl
sextupole_knobs 1
source $script_dir/scripts/checkStatus.tcl

#############################################################################
save_beamline_status "test" machine_status_$machine.dat
save_tuning_data tuning_data_$machine.dat $t_1

