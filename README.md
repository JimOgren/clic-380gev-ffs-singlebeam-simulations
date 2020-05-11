# CLIC 380GeV FFS SingleBeam Simulations

### CLIC FFS Simulations
These scripts simulates tuning procedures for the final-focus system (FFS) of the Compact Linear Collider (CLIC) particle accelerator. It is based on single-particle simulations for beam-based alignment (BBA) followed by sextupole alignment and knobs tuning based on a 1e5 multi-particle simulation. The luminosity is evaluated in a full beam-beam simulation. Only a single side of the FFS system and the beam is mirrored before the beam-beam simulation.

### Running the full simulation
The full simulation is defined in three steps. To run the whole thing:
1) run /main/run_singlebeam_BBA.sh
2) run /main/run_singlebeam_tuning_step1.sh
3) run /main/run_singlebeam_tuning_step2.sh

### Requirements
You need to have the tracking code PLACET and the beam-beam code GUINEA-PIG installed.

### Publication:
The results were presented in the report:\
"Tuning of the CLIC 380 GeV Final-Focus System with Static Imperfections", CERN-ACC-2018-0055, CLIC-Note-1141, 2018.

Written by Jim Ogren, 2018-2020, CERN, Geneva, Switzerland. 
