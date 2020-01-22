#############################################################################
#
# Tuning studies for single beam
#
# Step 0: beam-based alignment
#
# Written by Jim Ogren, CERN, 2018-2020
#
#############################################################################
global guinea_exec
set run_on_lxplus 0

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
   bpmres 0.020
   deltae 0.001
   beam_case 20
}

array set args $argv
set bpmres $args(bpmres)
set deltae $args(deltae)
set sr $args(sr)
set beam_case $args(beam_case)


#############################################################################
# load header files:
source $script_dir/scripts/make_beam.tcl
source $script_dir/scripts/wake_calc.tcl
#source $script_dir/scripts/octave_functions.tcl
source $script_dir/main/beam_parameters.tcl
source $script_dir/scripts/calc_lumi.tcl

# load lattice and create beams
source $script_dir/scripts/load_lattice.tcl
source $script_dir/scripts/create_beams.tcl

FirstOrder 1

# Go through lattice file and find indices for different elements:
source $script_dir/scripts/element_indices.tcl

# Sextupole knobs (transverse position)
#############################################################################
set offset 1
Octave {
   disp('Turn OFF octupoles')
   MO = placet_element_get_attribute("test", MIoct, "strength");
   placet_element_set_attribute("test", MIoct, "strength", 0.0);
}

Octave {
   KBI = MIsext';
   Knobs.I = [ KBI; KBI ];
   Knobs.L = [ repmat("x", length(KBI), 1); repmat("y", length(KBI), 1) ];
   Knobs.K = zeros(15,length(Knobs.I));
   [E,B] = placet_test_no_correction("test", "beam0t", "None", 1, 0, IP);
   S = std(B(:,[ 1 2 3 5 6 ]));
   sizeX = S(2)
   sizeY = S(3)
   get_lumi(B)
   Lumi_peak = Tcl_GetVar("lumi_peak")
   Lumi_total = Tcl_GetVar("lumi_total")

   for k = 1:length(Knobs.I)
      tempVal = placet_element_get_attribute("test", Knobs.I(k), Knobs.L(k));
      placet_element_set_attribute("test", Knobs.I(k), Knobs.L(k), tempVal+$offset);
      [E,B] = placet_test_no_correction("test", "beam0t", "None", 1, 0, IP);
      sizeX_temp = std(B(:,2))
      sizeY_temp = std(B(:,3))
      Cov = cov(B(:,[ 1 2 3 5 6 ]));

      placet_element_set_attribute("test", Knobs.I(k), Knobs.L(k), tempVal);
      [E,B] = placet_test_no_correction("test", "beam0t", "None", 1, 0, IP);
      sizeX_temp = std(B(:,2))
      sizeY_temp = std(B(:,3))

      Cov -= cov(B(:,[ 1 2 3 5 6 ]));
      Cov /= $offset
      index = 1;
      for i = 1:5
         for j = i:5
            Knobs.K(index++,k) = Cov(i,j)/(S(i)*S(j));
         end
      end
   end

   [U,S,V] = svd(Knobs.K);
   Knobs.S = diag(S);
   Knobs.V = V;

   Knobs.Ix = KBI;
   [Ux,Sx,Vx] = svd(Knobs.K(:,1:length(KBI)));
   Knobs.Sx = diag(Sx);
   Knobs.Vx = Vx;

   Knobs.Iy = KBI;
   [Uy,Sy,Vy] = svd(Knobs.K(:,length(KBI)+1:2*length(KBI)));
   Knobs.Sy = diag(Sy);
   Knobs.Vy = Vy;

   N = rows(Knobs.K);
   if S(end) / S(1) / N < eps
      warning("some singular values might be too small!")
   end

   Knobs_sextupole = Knobs;
   clear Knobs;
}

Octave {
   disp('Turn ON octupoles')
   placet_element_set_attribute("test", MIoct, "strength", MO);
}

# Octupole knobs (transverse position)
#######################################################################
Octave {
   KBI = MIoct';
   Knobs.I = [ KBI; KBI ];
   Knobs.L = [ repmat("x", length(KBI), 1); repmat("y", length(KBI), 1) ];
   Knobs.K = zeros(15,length(Knobs.I));
   [E,B] = placet_test_no_correction("test", "beam0t", "None", 1, 0, IP);
   S = std(B(:,[ 1 2 3 5 6 ]));
   sizeX = S(2)
   sizeY = S(3)
   get_lumi(B)
   Lumi_peak = Tcl_GetVar("lumi_peak")
   Lumi_total = Tcl_GetVar("lumi_total")

   for k = 1:length(Knobs.I)
      tempVal = placet_element_get_attribute("test", Knobs.I(k), Knobs.L(k));
      placet_element_set_attribute("test", Knobs.I(k), Knobs.L(k), tempVal+$offset);
      [E,B] = placet_test_no_correction("test", "beam0t", "None", 1, 0, IP);
      sizeX_temp = std(B(:,2))
      sizeY_temp = std(B(:,3))
      Cov = cov(B(:,[ 1 2 3 5 6 ]));

      placet_element_set_attribute("test", Knobs.I(k), Knobs.L(k), tempVal);
      [E,B] = placet_test_no_correction("test", "beam0t", "None", 1, 0, IP);
      sizeX_temp = std(B(:,2))
      sizeY_temp = std(B(:,3))

      Cov -= cov(B(:,[ 1 2 3 5 6 ]));
      Cov /= $offset
      index = 1;
      for i = 1:5
         for j = i:5
            Knobs.K(index++,k) = Cov(i,j)/(S(i)*S(j));
         end
      end
   end

   [U,S,V] = svd(Knobs.K);
   Knobs.S = diag(S);
   Knobs.V = V;

   Knobs.Ix = KBI;
   [Ux,Sx,Vx] = svd(Knobs.K(:,1:length(KBI)));
   Knobs.Sx = diag(Sx);
   Knobs.Vx = Vx;

   Knobs.Iy = KBI;
   [Uy,Sy,Vy] = svd(Knobs.K(:,length(KBI)+1:2*length(KBI)));
   Knobs.Sy = diag(Sy);
   Knobs.Vy = Vy;

   N = rows(Knobs.K);
   if S(end) / S(1) / N < eps
      warning("some singular values might be too small!")
   end

   Knobs_octupole = Knobs;
   clear Knobs;
}

Octave {
   save -text $script_dir/matrices/Knobs_sr_${sr}.dat Knobs_sextupole Knobs_octupole
}
