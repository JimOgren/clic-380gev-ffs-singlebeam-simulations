#############################################################################
#
# Tuning studies for single beam
#
# Written by Jim Ogren, CERN, 2018-2020
#
#############################################################################
global guinea_exec
set run_on_lxplus 1

if { $run_on_lxplus } {
   set script_dir /afs/cern.ch/work/j/jogren/TuningStudies/CLIC_FFS_380GeV/Clean_scripts/clic-380gev-ffs-singlebeam-simulations
   set guinea_exec /afs/cern.ch/eng/sl/clic-code/lx64slc5/guinea-pig/bin/guinea-old
} else {
   set script_dir /home/jim/GIT/clic-380gev-ffs-singlebeam-simulations
   set guinea_exec /home/jim/bin/guinea
}

if {![file exist $script_dir]} {
    puts "script_dir path does not exist!"
    exit
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

# Track and compute luminosity of perfect machine
#############################################################################
Octave {
   [E,B] = placet_test_no_correction("test", "beam0t", "None", 1, 0, IP);
   [L, L0] = get_lumi(B);
   Lumi = L*352*50/1e4;
   LumiPeak = L0*352*50/1e4;
   L0_over_L = L0/L;

   B_cut = cut_distribution(B,3);
   sx_rms = 1e3*std(B_cut(:,2));
   sy_rms = 1e3*std(B_cut(:,3));

   printf("\nPerfect machine:\n")
   printf("Lumi \t\t= %10.3g cm^-2s^-1\n", Lumi)
   printf("Lumi_peak \t= %10.3g cm^-2s^-1\n", LumiPeak)
   printf("L0_over_L \t= %10.3g\n", L0_over_L)
   printf("sx \t\t= %10.3g nm\n", sx_rms)
   printf("sy \t\t= %10.3g nm\n", sy_rms)
}
