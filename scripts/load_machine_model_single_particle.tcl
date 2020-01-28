Octave {
   fname =  '$script_dir/matrices/Dispersion_model_sr_${sr}_deltae_${deltae}.dat';
   try
      eval(["load ", fname]);
   catch
      disp(['Failed to load ', fname])
   end
}
