source $script_dir/scripts/clic_basic_single.tcl
source $script_dir/scripts/clic_beam.tcl

set scale 1.0

set synrad $sr
set quad_synrad $sr
set mult_synrad $sr
set sbend_synrad $sr

SetReferenceEnergy $e0


set lattices_file $script_dir/lattices/ffs_clic380gev_l6m_bx8_disp60.tcl
puts "Load lattice file: $lattices_file"
source $lattices_file

# Add BPM at IP, drift and BPM on other side
Bpm -name "IP"
Drift -name "D0" -length 6.016752
Bpm
BeamlineSet -name test

# Slice the sbends for more accurate sr in tracking
Octave {
   SI = placet_get_number_list("test", "sbend");
   placet_element_set_attribute("test", SI, "thin_lens", int32(100));
}
