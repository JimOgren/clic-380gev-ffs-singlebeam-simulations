# Load beam
Octave {
   disp("\nLoading beam from integrated simulation")

   if $beam_case == 8
      disp('Loading beam with ey = 8 nm (end of main linac)')
      load $script_dir/beams/beam_start_of_FFS_ey8nm_1e5.dat
      BeamIn = beam;
   elseif $beam_case == 20
      disp('Loading beam with ey = 20 nm (end of main linac)')
      load $script_dir/beams/beam_start_of_FFS_ey20nm_1e5.dat
      BeamIn = beam;
   elseif $beam_case == 30
      disp('Loading beam with ey = 30 nm (end of main linac)')
      load $script_dir/beams/beam_start_of_FFS_ey30nm_1e5.dat
      BeamIn = beam;
   else
      disp("\nUnknown beam_case. Cannot load beam.\n");
   end
   disp(' ')
}

if { $create_multiparicle_off_energy } {
   Octave {
      placet_set_beam("beam0t", BeamIn);
      BeamIn2 = BeamIn;
      BeamIn2(:,1) = BeamIn2(:,1) + $deltae*ones(size(BeamIn2(:,1)))*mean(BeamIn(:,1));
      placet_set_beam("beam2t", BeamIn2);

      BeamIn1 = BeamIn;
      BeamIn1(:,1) = BeamIn1(:,1) - $deltae*ones(size(BeamIn1(:,1)))*mean(BeamIn(:,1));
      placet_set_beam("beam1t", BeamIn1);
   }
}
