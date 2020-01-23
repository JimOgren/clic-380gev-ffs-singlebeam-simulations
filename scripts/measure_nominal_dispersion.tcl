puts " "
puts "\nMeasuring nominal dispersion profile"
Octave {
   # Measure nominal dispersion with and without multipoles active
   disp("Measuring with multipoles OFF...")
   placet_element_set_attribute("test", MI, "strength", complex(0.0,0.0));
   eta0_arr = MeasureDispersion("test", "beam1t", "beam2t", $deltae, BI);
   eta0 = [eta0_arr(:,1); eta0_arr(:,2)];

   disp("Measuring with multipoles ON...")
   placet_element_set_attribute("test", MI, "strength", complex(MS,0.0));
   eta1_arr = MeasureDispersion("test", "beam1t", "beam2t", $deltae, BI);
   eta1 = [eta1_arr(:,1); eta1_arr(:,2)];

   save -text $script_dir/matrices/Dispersion_model_sr_${sr}_deltae_${deltae}_ey_${beam_case}.dat eta0_arr eta0 eta1_arr eta1
}
