#############################################################################
#
# Tuning studies for single beam
#
#############################################################################
set t_1 [clock seconds]

set e_initial 190
set e0 $e_initial

set script_dir /afs/cern.ch/work/j/jogren/TuningStudies/CLIC_FFS_380GeV/SingleBeamTuning_v07_tuned_beams

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
    loadmachine 0
    measure_response 0
    wdisp 0.71
    iterdts 30
    gaindts 0.5
    beam_case 0
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

set machine $beam_case
puts "Machine $machine and beam_case $beam_case UPDATED2"

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

# Load beams from integrated simulation, tuned beams
source $script_dir/scripts/load_beam_updated2.tcl

FirstOrder 1

# Go through lattice file and find indices for different elements:
source $script_dir/scripts/element_indices.tcl

# Measure target dispersion
if { $measure_response } {
   source $script_dir/scripts/measure_nominal_dispersion.tcl
}

# load target dispersion 
source $script_dir/scripts/load_machine_model.tcl

# load knobs
source $script_dir/main/setup_knobs.tcl

# Set same offsets and angles to single particle beams
Octave {
	Bt = placet_get_beam("beam0t");
	Bmean = mean(Bt)

	B0 = placet_get_beam("beam0");
	B1 = placet_get_beam("beam1");
	B2 = placet_get_beam("beam2");

	B0(2:6) = Bmean(2:6);
	B1(2:6) = Bmean(2:6);
	B2(2:6) = Bmean(2:6);
	
	placet_set_beam("beam0", B0);
	placet_set_beam("beam1", B1);
	placet_set_beam("beam2", B2);
}

Octave {
	placet_element_set_attribute("test", BI, "resolution", $bpmres);
}
source $script_dir/scripts/checkStatus.tcl


# Step 1 misalign the machine
#############################################################################
# Procedure for misaligning a machine
proc my_survey { beamline_name } {
   global machine sigma sigmaM sigmaroll sigmak bpmres
   puts " "
   puts "Random misalignment errors"
   Octave {
      randn("seed", ($machine+1) * 234);
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

# Misalign the machine
my_survey "test"

source $script_dir/scripts/checkStatus.tcl

# BBA
##########################################################
source $script_dir/main/beam_based_alignment.tcl
source $script_dir/scripts/checkStatus.tcl

# Align and tune sextupoles (transverse position)
#############################################################################
align_sextupoles_reverse 10
source $script_dir/scripts/checkStatus.tcl

#############################################################################
save_beamline_status "test" /afs/cern.ch/work/j/jogren/TuningStudies/CLIC_FFS_380GeV/SingleBeamTuning_v07_tuned_beams/main/Results/Results_with_misalignments_updated2/machine_status_step1_$beam_case.dat
save_tuning_data /afs/cern.ch/work/j/jogren/TuningStudies/CLIC_FFS_380GeV/SingleBeamTuning_v07_tuned_beams/main/Results/Results_with_misalignments_updated2/tuning_data_step1_$beam_case.dat

