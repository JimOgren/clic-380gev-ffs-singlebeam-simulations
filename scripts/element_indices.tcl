Octave {
  IP = placet_get_name_number_list("test", "IP");
  BI = placet_get_number_list("test", "bpm");

  DI = placet_get_number_list("test", "dipole");
  QI = placet_get_number_list("test", "quadrupole");

  MI = placet_get_number_list("test", "multipole");
  MS = placet_element_get_attribute("test", MI, "strength");

  MI = MI(MS != 0);
  MS = placet_element_get_attribute("test", MI, "strength");
  ML = placet_element_get_attribute("test", MI, "length");
  MT = placet_element_get_attribute("test", MI, "type");

  T = placet_element_get_attribute("test", MI, "type");
  
  MIsext = MI(T<4);
  MSsext = placet_element_get_attribute("test", MIsext, "strength");

  MIoct = MI(T==4);
  MSoct = placet_element_get_attribute("test", MIoct, "strength");
}
