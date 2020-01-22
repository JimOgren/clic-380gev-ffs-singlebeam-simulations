Octave {
   fname =  '$script_dir/matrices/Dispersion_model_sr_${sr}_deltae_${deltae}_ey_${beam_case}.dat';
   try
      eval(["load ", fname]);
   catch
      disp(['Failed to load ', fname])
   end
}
