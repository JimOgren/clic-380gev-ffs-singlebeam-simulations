#############################################################################
# Script that creates 3 single particle beams for BBA: on energy particle
# and +/- deltae energy difference for dispersion measurement. In addition
# a 100,000 macroparticle beam is created for luminosity computations.
# It also has the option of creating multiparticle beams with different
# energies for running BBA with these beams.
#
# Written by Jim Ogren, CERN, 2018-2020
#############################################################################

puts "Creating beams"
set e0 $e_initial
set e2 [expr $e0 * (1.0 + $deltae)]
set e1 [expr $e0 * (1.0 - $deltae)]

set n_slice 1
set n 1
set n_total [expr $n_slice*$n]

make_beam_many beam0 $n_slice $n
exec echo "$e0 0 0 0 0 0" > particles.in
BeamRead -file particles.in -beam beam0
make_beam_many beam1 $n_slice $n
exec echo "$e1 0 0 0 0 0" > particles.in
BeamRead -file particles.in -beam beam1
make_beam_many beam2 $n_slice $n
exec echo "$e2 0 0 0 0 0" > particles.in
BeamRead -file particles.in -beam beam2

set n_slice 50
set n 2000
set n_total [expr $n_slice*$n]

make_beam_many beam0t $n_slice $n

set create_multiparicle_off_energy 1
if { $create_multiparicle_off_energy } {
   make_beam_many_energy beam2t $n_slice $n [expr 1.0 + $deltae]
   make_beam_many_energy beam1t $n_slice $n [expr 1.0 - $deltae]
}
