#############################################################################
#
# Tuning studies for single beam
#
# Step 0: beam-based alignment
#
# Written by Jim Ogren, CERN, 2018-2020
#
#############################################################################
set t_1 [clock seconds]
global guinea_exec
set run_on_lxplus 1

if { $run_on_lxplus } {
   set script_dir /afs/cern.ch/work/j/jogren/TuningStudies/CLIC_FFS_380GeV/Clean_scripts/clic-380gev-ffs-singlebeam-simulations
   set guinea_exec /afs/cern.ch/eng/sl/clic-code/lx64slc5/guinea-pig/bin/guinea-old
} else {
   set script_dir /home/jim/GIT/clic-380gev-ffs-singlebeam-simulations
   set guinea_exec /home/jim/bin/guinea
}

set res_dir $script_dir/main/Results
set save_dir $res_dir/Results_BBA

# Check if folders exist
if {![file exist $script_dir]} {
   puts "script_dir path does not exist!"
   exit
}

if {![file exist $res_dir]} {
   exec bash -c "mkdir -p $res_dir"
}
if {![file exist $save_dir]} {
   exec bash -c "mkdir -p $save_dir"
}

set e_initial 190
set e0 $e_initial
#############################################################################
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
   loadmachine 0
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
source $script_dir/scripts/calc_lumi.tcl

# load lattice and create beams
source $script_dir/scripts/load_lattice.tcl
source $script_dir/scripts/create_beams.tcl

# Load beams from integrated simulation
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

# Load BBA methods
source $script_dir/scripts/beam_based_alignment.tcl

# Procedure for misaligning the machine
#############################################################################
# Procedure for misaligning a machine
proc my_survey { beamline_name } {
   global machine sigma sigmaM sigmaroll sigmak bpmres
   puts " "
   puts "Random misalignment errors"
   Octave {
      randn("seed", $machine * 234);
      placet_element_set_attribute("$beamline_name", DI, "strength_x", 0.0);
      placet_element_set_attribute("$beamline_name", DI, "strength_y", 0.0);
      placet_element_set_attribute("$beamline_name", BI, "resolution", $bpmres);
      placet_element_set_attribute("$beamline_name", BI, "x", randn(size(BI)) * $sigma);
      placet_element_set_attribute("$beamline_name", BI, "y", randn(size(BI)) * $sigma);
      placet_element_set_attribute("$beamline_name", QI, "x", randn(size(QI)) * $sigma);
      placet_element_set_attribute("$beamline_name", QI, "y", randn(size(QI)) * $sigma);
      placet_element_set_attribute("$beamline_name", MI, "x", randn(size(MI)) * $sigmaM);
      placet_element_set_attribute("$beamline_name", MI, "y", randn(size(MI)) * $sigmaM);
      placet_element_set_attribute("$beamline_name", DI, "roll",randn(size(DI)) * $sigmaroll);
      placet_element_set_attribute("$beamline_name", QI, "roll",randn(size(QI)) * $sigmaroll);
      placet_element_set_attribute("$beamline_name", BI, "roll",randn(size(BI)) * $sigmaroll);
      placet_element_set_attribute("$beamline_name", MI, "roll",randn(size(MI)) * $sigmaroll);

      QIK=placet_element_get_attribute("$beamline_name", QI, "strength");
      QIKE=QIK.+QIK.*(randn(size(QI)) * $sigmak)';
      MIK=placet_element_get_attribute("$beamline_name", MI, "strength");
      MIKE=MIK.+MIK.*(randn(size(MI)) * $sigmak)';

      placet_element_set_attribute("$beamline_name", QI, "strength", QIKE);
      placet_element_set_attribute("$beamline_name", MI, "strength", MIKE);
   }
}

# Start simulation
#############################################################################
# Step 0: check status of perfect machine
source $script_dir/scripts/check_status.tcl

# Misalign the machine
my_survey "test"

# Check status of misaligned machine and save beamline
source $script_dir/scripts/check_status.tcl
save_beamline_status "test" $save_dir/machine_status_misaligned_$machine.dat

# Run BBA
run_beam_based_alignment_multiparticle
source $script_dir/scripts/check_status.tcl

# Save beamline and tuning data
save_beamline_status "test" $save_dir/machine_status_$machine.dat
save_tuning_data $save_dir/tuning_data_$machine.dat $t_1
