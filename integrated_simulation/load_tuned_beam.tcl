# Load beam
Octave {
   disp("\nLoading beam from integrated simulation - UPDATED2")

   disp('Loading beam${beam_case}')
   load /afs/cern.ch/work/j/jogren/TuningStudies/CLIC_FFS_380GeV/tuned_beams_updated2/beam-${beam_case}.dat;
   BeamIn = beam_${beam_case};
   placet_set_beam("beam0t", BeamIn);
}
