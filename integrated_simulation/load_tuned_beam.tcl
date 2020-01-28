# Load beam
Octave {
   disp("\nLoading beam from integrated simulation")

   disp('Loading beam${beam_case}')
   load $script_dir/beams/tuned_beams/beam-${beam_case}.dat;
   BeamIn = beam_${beam_case};
   placet_set_beam("beam0t", BeamIn);
}
