array set gp_param "
   energy 190.0
   particles [expr $match(charge)*1e-10]
   sigmaz $match(sigma_z)
   cut_x 400.0
   cut_y 20.0
   n_x 128
   n_y 256
   do_coherent 0
   do_muons 0
   do_trident 0
   do_pairs 0
   track_pairs 0
   do_compt 0
   do_hadrons 0
   do_espread 0
   do_photons 0
   do_isr 0
   do_lumi 0
   n_t 1
   charge_sign -1.0
   ecm_min [expr 2.0*$e0*0.99]"

source $script_dir/scripts/clic_guinea.tcl

proc run_guinea {off angle} {
   global gp_param guinea_exec
   set res [exec grid]
   set yoff [expr -0.5*([lindex $res 2]+[lindex $res 3])]
   set xoff [expr -0.5*([lindex $res 0]+[lindex $res 1])]
   set tx $gp_param(cut_x)
   set ty $gp_param(cut_y)
   if {[lindex $res 1]-[lindex $res 0]>2.0*$tx} {
      set gp_param(cut_x) [expr 0.5*([lindex $res 1]-[lindex $res 0])]
   }
   if {[lindex $res 3]-[lindex $res 2]>2.0*$ty} {
      set gp_param(cut_y) [expr 0.5*([lindex $res 3]-[lindex $res 2])]
   }

   write_guinea_correct $xoff $yoff 0 0 0

   if { ![ file exist $guinea_exec] } {
      set guinea_exec guinea
      puts "Check Guinea exec path!"
   }


   if {[catch {exec $guinea_exec default_clic default_simple result.out}]} {
      puts "Guine-pig failed. Most likely due to wrong grid size"
      return {0.0 0.0}
   } else {
      set gp_param(cut_x) $tx
      set gp_param(cut_y) $ty
      return [get_results result.out]
   }
}

proc get_lumi_2 {electron,positron} {
   exec cp $electron "electron.ini"
   exec cp $positron "positron.ini"
   set res [run_guinea 0.0 0.0]
   set lumi_total [lindex \$res 0]
   set lumi_peak [lindex \$res 1]

   puts "lumi_total $lumi_total"
   puts "lumi_peak $lumi_peak"
}

Octave {
   function [L, Lpeak] = get_lumi(B)
      if nargin==0
         IP = placet_get_name_number_list("test", "IP");
         [E,B] = placet_test_no_correction("test", "beam0t", "None", 1, 0, IP);
      end
      save_beam("electron.ini", B);
      save_beam("positron.ini", B);
      Tcl_Eval("set res [run_guinea 0.0 0.0]");
      Tcl_Eval("set lumi_total [lindex \$res 0]");
      Tcl_Eval("set lumi_peak [lindex \$res 1]");
      L = str2num(Tcl_GetVar("lumi_total"));
      Lpeak = str2num(Tcl_GetVar("lumi_peak"));
   end
}
