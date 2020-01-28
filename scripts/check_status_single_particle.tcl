Octave {
   if (~exist("Lumivec"))
      # initiate vectors
      Lumivec = [];
      LumiPeakvec = [];
      Lmeasvec = [];
      sxvec = [];
      syvec = [];
      sx_core_vec = [];
      sy_core_vec = [];
      Evec = [];
      EwMvec = [];
      misQvec = [];
      misMvec = [];
      wrtbQvec = [];
      wrtbMvec = [];
      multStreng = [];
   end

   if (~exist("Lmeas"))
      Lmeas = 0;
   end


   disp(' ')
   disp('=======================================================')
   [E,B] = placet_test_no_correction("test", "beam0t", "None", 1, 0, IP);
   [L, L0] = get_lumi(B)
   Lumivec = [Lumivec; L];
   LumiPeakvec = [LumiPeakvec; L0];
   Lmeasvec = [Lmeasvec; Lmeas];
   sx = std(B(:,2))
   sy = std(B(:,3))
   sxvec = [sxvec; sx];
   syvec = [syvec; sy];
   [sx_core, sy_core] = get_core_beam_size(B)
   sx_core_vec = [sx_core_vec; sx_core];
   sy_core_vec = [sy_core_vec; sy_core];

   disp(' ')
   disp('Dispersion target WITHOUT multipoles')
   MStemp = placet_element_get_attribute("test", MI, "strength");
   placet_element_set_attribute("test", MI, "strength", complex(0.0,0.0));
   eta_meas_arr = CheckDispersion("test", "beam1", "beam2", $deltae, BI);
   eta_meas = [eta_meas_arr(:,1); eta_meas_arr(:,2)];
   [eta0_arr, eta_meas_arr, abs(eta0_arr - eta_meas_arr)]
   stdE = [sqrt(sum((eta_meas_arr(:,1) - eta0_arr(:,1)).^2)), ...
   sqrt(sum((eta_meas_arr(:,2) - eta0_arr(:,2)).^2))]
   Evec = [Evec; stdE];

   placet_element_set_attribute("test", MI, "strength", complex(MStemp,0.0));
   disp('Dispersion target WITH multipoles')
   eta_meas_arr = CheckDispersion("test", "beam1", "beam2", $deltae, BI);
   eta_meas = [eta_meas_arr(:,1); eta_meas_arr(:,2)];
   [eta1_arr, eta_meas_arr, abs(eta1_arr - eta_meas_arr)]
   stdEwM = [sqrt(sum((eta_meas_arr(:,1) - eta1_arr(:,1)).^2)), ...
   sqrt(sum((eta_meas_arr(:,2) - eta1_arr(:,2)).^2))]
   EwMvec = [EwMvec; stdEwM];

   BPM_RES = placet_element_get_attribute("test", BI(1), "resolution")

   disp(' ')
   disp('Element misalignments')
   disp('Quadrupoles')
   xc = placet_element_get_attribute("test", QI, "x");
   yc = placet_element_get_attribute("test", QI, "y");
   rc = placet_element_get_attribute("test", QI, "roll");
   disp('x_pos - y_pos - roll')
   [xc, yc, rc]
   stdQ = [sqrt(sum(xc.^2)), sqrt(sum(yc.^2)), sqrt(sum(rc.^2))]
   misQvec = [misQvec; stdQ];

   disp(' ')
   disp('Multipoles')
   xc = placet_element_get_attribute("test", MI, "x");
   yc = placet_element_get_attribute("test", MI, "y");
   rc = placet_element_get_attribute("test", MI, "roll");
   disp('x_pos - y_pos - roll')
   [xc, yc, rc]
   stdM = [sqrt(sum(xc.^2)), sqrt(sum(yc.^2)), sqrt(sum(rc.^2))]
   misMvec = [misMvec; stdM];

   disp(' ')
   disp('Misalignment w r t the beam')
   disp('Quadrupoles')
   [stdx, stdy] = checkAlignment("test", "beam0", QI);

   stdQwrt = [stdx, stdy]
   wrtbQvec = [wrtbQvec; stdQwrt];

   disp('Multipoles')
   [stdx, stdy] = checkAlignment("test", "beam0", MI);

   stdMwrt = [stdx, stdy]
   wrtbMvec = [wrtbMvec; stdMwrt];
   MS
   MStemp
   disp('Multipole strengths')
   [MStemp, MS, MStemp-MS]

   multStreng = [multStreng; sqrt(sum((MStemp-MS).^2))];

   Lumivec
   LumiPeakvec
   Lmeasvec
   sxvec
   syvec
   sx_core_vec
   sy_core_vec
   Evec
   EwMvec
   misQvec
   misMvec
   wrtbQvec
   wrtbMvec
   multStreng
   disp('=======================================================')
   disp(' ')
}
