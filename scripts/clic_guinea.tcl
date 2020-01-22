#
# Define some parameters for GUINEA-PIG
#

#array set gp_param "
#    energy 1500.0
#    particles [expr $match(charge)*1e-10]
#    sigmaz $match(sigma_z)
#    cut_x 400.0
#    cut_y 15.0
#    n_x 128
#    n_y 256
#    do_coherent 1 
#    n_t 1
#    charge_sign -1.0
#    n 200 
#"

#
# Set the minimum energy for lumi_high to 99% of the nominal centre-of-mass
# energy
#

set gp_param(ecm_min) [expr 2.0*$gp_param(energy)*0.99]

proc write_guinea_offset_angle {offset angle} {
    global n_slice gp_param n_total
    set f [open acc.dat w]

    puts $f "\$ACCELERATOR:: default"
    puts $f "\{energy=$gp_param(energy);particles=$gp_param(particles);"
    puts $f "beta_x=20.0;beta_y=0.4;emitt_x=10.0;"
    puts $f "emitt_y=0.04;sigma_z=$gp_param(sigmaz);espread=0.001;dist_z=0;f_rep=5.0;"
    puts $f "n_b=2820;waist_y=0;\}"

    puts $f "\$PARAMETERS:: default"
    puts $f "\{n_x=$gp_param(n_x);n_y=$gp_param(n_y);n_z=$n_slice;"
    puts $f "n_t=$gp_param(n_t);n_m=$n_total;cut_x=$gp_param(cut_x);"
    puts $f "cut_y=$gp_param(cut_y);cut_z=3.0*sigma_z.1;offset_y=0.5*$offset;"
    puts $f "offset_x.1=$offsetx;offset_x.2=$offsetx;"
    puts $f "force_symmetric=0;electron_ratio=0.2;do_photons=1;do_hadrons=0;do_isr=1;"
    puts $f "ecm_min=$gp_param(ecm_min);photon_ratio=0.2;store_hadrons=0;"
    puts $f "do_coherent=$gp_param(do_coherent);grids=0;angle_y=0.5*$angle;rndm_load=0;"
    puts $f "do_pairs=0;track_pairs=0;do_compt=0;photon_ratio=0.2;load_beam=3;"
    puts $f "hist_ee_bins=1010;hist_ee_max=2.02*energy.1;charge_sign=$gp_param(charge_sign);\}"

    puts $f "\$PARAMETERS:: default_1"
    puts $f "\{n_x=$gp_param(n_x);n_y=[expr 4*$gp_param(n_y)];n_z=$n_slice;"
    puts $f "n_t=$gp_param(n_t);n_m=$n_total;cut_x=$gp_param(cut_x);"
    puts $f "cut_y=[expr 4*$gp_param(cut_y)];cut_z=3.0*sigma_z.1;"
    puts $f "offset_y=0.5*$offset;photon_ratio=0.2;"
    puts $f "force_symmetric=0;electron_ratio=0.2;do_photons=1;"
    puts $f "do_coherent=$gp_param(do_coherent);grids=0;angle_y=0.5*$angle;rndm_load=0;"
    puts $f "do_pairs=0;track_pairs=0;do_compt=0;photon_ratio=0.2;load_beam=3;"
    puts $f "hist_ee_bins=1010;hist_ee_max=2.02*energy.1;charge_sign=$gp_param(charge_sign);\}"

    puts $f "\$PARAMETERS:: default0"
    puts $f "\{n_x=$gp_param(n_x);n_y=$gp_param(n_y);n_z=$n_slice;"
    puts $f "n_t=$gp_param(n_t);n_m=$n_total;cut_x=$gp_param(cut_x);"
    puts $f "cut_y=$gp_param(cut_y);cut_z=3.0*sigma_z.1;offset_y=0.5*$offset;"
    puts $f "force_symmetric=0;electron_ratio=0.2;do_photons=1;"
    puts $f "do_coherent=$gp_param(do_coherent);grids=0;angle_y=0.5*$angle;rndm_load=0;"
    puts $f "do_pairs=0;track_pairs=0;do_compt=0;photon_ratio=0.2;load_beam=3;"
    puts $f "hist_ee_bins=1010;hist_ee_max=2.02*energy.1;charge_sign=0;\}"
    close $f
}

proc write_guinea_correct {offsetx offsety offdy cuty ny} {
    global n_slice gp_param n_total
    set f [open acc.dat w]
    set offsetnew [expr $offsety + $offdy]

    puts $f "\$ACCELERATOR:: default_clic"
    puts $f "\{energy=$gp_param(energy);particles=$gp_param(particles);"
    puts $f "beta_x=7.0;beta_y=0.068;emitt_x=0.66;"
    puts $f "emitt_y=0.02;sigma_z=$gp_param(sigmaz);espread=0.01;dist_z=0;f_rep=100.0;"
    puts $f "offset_y.1=$offsety;offset_y.2=$offsety;"
    puts $f "offset_x.1=$offsetx;offset_x.2=$offsetx;"
    puts $f "n_b=154;waist_y=0;\}"

    puts $f "\$ACCELERATOR:: default_ilc"
    puts $f "\{energy=$gp_param(energy);particles=$gp_param(particles);"
    puts $f "beta_x=20.0;beta_y=0.4;emitt_x=10.0;"
    puts $f "emitt_y=0.04;sigma_z=$gp_param(sigmaz);espread=0.001;dist_z=0;f_rep=5.0;"
    puts $f "n_b=2820;waist_y=0;\}"

    puts $f "\$PARAMETERS:: default"
    puts $f "\{n_x=$gp_param(n_x);n_y=$gp_param(n_y);n_z=$n_slice;"
    puts $f "n_t=$gp_param(n_t);n_m=$n_total;cut_x=$gp_param(cut_x);"
    puts $f "cut_y=$gp_param(cut_y);cut_z=3.0*sigma_z.1;"
    puts $f "offset_y.1=$offsety;offset_y.2=$offsety;"
    puts $f "offset_x.1=$offsetx;offset_x.2=$offsetx;"
    puts $f "force_symmetric=0;electron_ratio=1.0;do_photons=1;do_isr=$gp_param(do_isr);beam_size=1;"
    puts $f "ecm_min=$gp_param(ecm_min);photon_ratio=1.0;do_muons=0;do_trident=0;"
    puts $f "do_coherent=1;grids=7;rndm_load=0;do_espread=$gp_param(do_espread);"
    puts $f "do_pairs=0;track_pairs=0;store_beam=0;do_compt=0;photon_ratio=0.2;load_beam=3;"
    puts $f "do_hadrons=0;store_hadrons=0;do_jets=0;store_jets=0;store_photons=0;"
    puts $f "hist_ee_bins=1010;hist_ee_max=2.02*energy.1;charge_sign=$gp_param(charge_sign);\}"

    puts $f "\$PARAMETERS:: default_simple"
    puts $f "\{n_x=$gp_param(n_x);n_y=$gp_param(n_y);n_z=$n_slice;"
    puts $f "n_t=$gp_param(n_t);n_m=$n_total;cut_x=$gp_param(cut_x);"
    puts $f "cut_y=$gp_param(cut_y);cut_z=3.0*sigma_z.1;"
    puts $f "offset_y.1=$offsety;offset_y.2=$offsety;"
    puts $f "offset_x.1=$offsetx;offset_x.2=$offsetx;"
    puts $f "force_symmetric=0;electron_ratio=1.0;do_photons=1;do_isr=0;do_lumi=0;beam_size=1;"
    puts $f "ecm_min=$gp_param(ecm_min);do_muons=0;"
#    puts $f "do_coherent=1;grids=7;rndm_load=0;do_espread=0.0;"
    puts $f "do_coherent=1;grids=0;rndm_load=0;do_espread=0.0;"
    puts $f "do_pairs=0;track_pairs=0;store_beam=0;do_compt=0;photon_ratio=0.2;load_beam=3;"
    puts $f "do_hadrons=0;store_hadrons=0;do_jets=0;store_jets=0;store_photons=0;"
    puts $f "hist_ee_bins=134;hist_ee_max=2.01*energy.1;charge_sign=$gp_param(charge_sign);"
    puts $f "do_prod=0; prod_e=0.0; prod_scal=0.0; do_cross=0;do_eloss=1;ext_field=0;\}"

    puts $f "\$PARAMETERS:: default_very-simple"
    puts $f "\{n_x=$gp_param(n_x);n_y=$gp_param(n_y);n_z=$n_slice;"
    puts $f "n_t=$gp_param(n_t);n_m=$n_total;cut_x=$gp_param(cut_x);"
    puts $f "cut_y=$gp_param(cut_y);cut_z=3.0*sigma_z.1;"
    puts $f "offset_y.1=$offsety;offset_y.2=$offsety;"
    puts $f "offset_x.1=$offsetx;offset_x.2=$offsetx;"
    puts $f "force_symmetric=0;electron_ratio=1.0;do_photons=0;do_isr=0;do_lumi=0;beam_size=1;"
    puts $f "ecm_min=$gp_param(ecm_min);photon_ratio=0.0;do_muons=0;"
    puts $f "do_coherent=1;grids=7;rndm_load=0;do_espread=0.0;"
    puts $f "do_pairs=0;track_pairs=0;store_beam=0;do_compt=0;photon_ratio=0.2;load_beam=3;"
    puts $f "do_hadrons=0;store_hadrons=0;do_jets=0;store_jets=0;store_photons=0;"
    puts $f "hist_ee_bins=134;hist_ee_max=2.01*energy.1;charge_sign=$gp_param(charge_sign);"
    puts $f "do_prod=0; prod_e=0.0; prod_scal=0.0; do_cross=0;do_eloss=0;ext_field=0;\}"

    puts $f "\$PARAMETERS:: my_parameters"
    puts $f "\{n_x=$gp_param(n_x);n_y=$gp_param(n_y);n_z=$n_slice;"
    puts $f "n_t=$gp_param(n_t);n_m=$n_total;cut_x=$gp_param(cut_x);"
    puts $f "cut_y=$gp_param(cut_y);cut_z=3.0*sigma_z.1;"
    puts $f "integration_method=1;force_symmetric=0;rndm_save=1; rndm_load=1;"
    puts $f "offset_y.1=$offsety;offset_y.2=$offsety;"
    puts $f "offset_x.1=$offsetx;offset_x.2=$offsetx;"
    puts $f "do_lumi=1; num_lumi=200000; lumi_p=1; store_beam=1;"
    puts $f "electron_ratio=1; do_photons=1; photon_ratio=1;"
#    puts $f "gg_cut=1;"
    puts $f "do_hadrons=1; store_hadrons=1; do_jets=1; store_jets=1; jet_ptmin=0; jet_log=1;"
    puts $f "do_pairs=1; pair_ratio=1; pair_q2=2; track_pairs=1; grids=7; pair_ecut=5; beam_size=1; ext_field=1; do_eloss=1;"
    puts $f "do_espread=1; do_isr=1; do_compt=1; load_beam=1; load_photons=1; do_prod=0;"
    puts $f "do_cross=1;\}"

    puts $f "\$PARAMETERS:: full_simulation"
    puts $f "\{n_x=$gp_param(n_x);n_y=$gp_param(n_y);n_z=$n_slice;"
    puts $f "n_t=$gp_param(n_t);n_m=$n_total;cut_x=$gp_param(cut_x);"
    puts $f "cut_y=$gp_param(cut_y);cut_z=3.0*sigma_z.1;"
    puts $f "offset_y.1=$offsety;offset_y.2=$offsety;"
    puts $f "offset_x.1=$offsetx;offset_x.2=$offsetx;"
    puts $f "force_symmetric=0;electron_ratio=1.0;do_photons=$gp_param(do_photons);do_isr=$gp_param(do_isr);beam_size=1;"
    puts $f "ecm_min=$gp_param(ecm_min);photon_ratio=1.0;do_muons=$gp_param(do_muons);do_trident=$gp_param(do_trident);"
    puts $f "do_coherent=$gp_param(do_coherent);grids=7;rndm_load=0;do_espread=$gp_param(do_espread);"
    puts $f "do_pairs=$gp_param(do_pairs);track_pairs=$gp_param(track_pairs);store_beam=1;do_compt=$gp_param(do_compt);photon_ratio=0.2;load_beam=3;"
    puts $f "do_hadrons=$gp_param(do_hadrons);store_hadrons=1;do_jets=1;store_jets=1;store_photons=1;"
    puts $f "hist_ee_bins=1010;hist_ee_max=2.02*energy.1;charge_sign=$gp_param(charge_sign);\}"

    puts $f "\$PARAMETERS:: grid3_2"
    puts $f "\{n_x=128;n_y=512;n_z=24;"
    puts $f "n_t=5;n_m=$n_total;cut_x=6.0*sigma_x.1;"
    puts $f "cut_y=48.0*sigma_y.1;cut_z=3.0*sigma_z.1;"
    puts $f "offset_y.1=$offsetnew;offset_y.2=$offsetnew;"
    puts $f "offset_x.1=$offsetx;offset_x.2=$offsetx;"
    puts $f "force_symmetric=0;electron_ratio=0.2;do_photons=1;"
    puts $f "ecm_min=$gp_param(ecm_min);photon_ratio=0.2;"
    puts $f "do_coherent=$gp_param(do_coherent);grids=0;rndm_load=0;"
    puts $f "do_pairs=0;track_pairs=0;do_compt=0;photon_ratio=0.2;load_beam=3;"
    puts $f "hist_ee_bins=1010;hist_ee_max=2.02*energy.1;charge_sign=$gp_param(charge_sign);\}"

    puts $f "\$PARAMETERS:: grid_yauto"
    puts $f "\{n_x=128;n_y=512*$ny;n_z=24;"
    puts $f "n_t=5;n_m=$n_total;cut_x=6.0*sigma_x.1;"
    puts $f "cut_y=$cuty*sigma_y.1;cut_z=3.0*sigma_z.1;"
    puts $f "offset_y.1=$offsety;offset_y.2=$offsety;"
    puts $f "offset_x.1=$offsetx;offset_x.2=$offsetx;"
    puts $f "force_symmetric=0;electron_ratio=0.2;do_photons=1;"
    puts $f "ecm_min=$gp_param(ecm_min);photon_ratio=0.2;"
    puts $f "do_coherent=$gp_param(do_coherent);grids=0;rndm_load=0;"
    puts $f "do_pairs=0;track_pairs=0;do_compt=0;photon_ratio=0.2;load_beam=3;"
    puts $f "hist_ee_bins=1010;hist_ee_max=2.02*energy.1;charge_sign=$gp_param(charge_sign);\}"

    puts $f "\$PARAMETERS:: grid3_2ee"
    puts $f "\{n_x=128;n_y=512;n_z=24;"
    puts $f "n_t=5;n_m=$n_total;cut_x=6.0*sigma_x.1;"
    puts $f "cut_y=48.0*sigma_y.1;cut_z=3.0*sigma_z.1;"
    puts $f "offset_y.1=$offsety;offset_y.2=$offsety;"
    puts $f "offset_x.1=$offsetx;offset_x.2=$offsetx;"
    puts $f "force_symmetric=0;electron_ratio=0.2;do_photons=1;"
    puts $f "ecm_min=$gp_param(ecm_min);photon_ratio=0.2;"
    puts $f "do_coherent=$gp_param(do_coherent);grids=0;rndm_load=0;"
    puts $f "do_pairs=0;track_pairs=0;do_compt=0;photon_ratio=0.2;load_beam=3;"
    puts $f "hist_ee_bins=1010;hist_ee_max=2.02*energy.1;charge_sign=1.0;\}"

    puts $f "\$PARAMETERS:: grid_yautoee"
    puts $f "\{n_x=128;n_y=512*$ny;n_z=24;"
    puts $f "n_t=5;n_m=$n_total;cut_x=6.0*sigma_x.1;"
    puts $f "cut_y=$cuty*sigma_y.1;cut_z=3.0*sigma_z.1;"
    puts $f "offset_y.1=$offsety;offset_y.2=$offsety;"
    puts $f "offset_x.1=$offsetx;offset_x.2=$offsetx;"
    puts $f "force_symmetric=0;electron_ratio=0.2;do_photons=1;"
    puts $f "ecm_min=$gp_param(ecm_min);photon_ratio=0.2;"
    puts $f "do_coherent=$gp_param(do_coherent);grids=0;rndm_load=0;"
    puts $f "do_pairs=0;track_pairs=0;do_compt=0;photon_ratio=0.2;load_beam=3;"
    puts $f "hist_ee_bins=1010;hist_ee_max=2.02*energy.1;charge_sign=1.0;\}"

    puts $f "\$PARAMETERS:: default_1"
    puts $f "\{n_x=$gp_param(n_x);n_y=[expr 4*$gp_param(n_y)];n_z=$n_slice;"
    puts $f "n_t=$gp_param(n_t);n_m=$n_total;cut_x=$gp_param(cut_x);"
    puts $f "cut_y=[expr 4*$gp_param(cut_y)];cut_z=3.0*sigma_z.1;"
    puts $f "offset_y.1=$offsety;offset_y.2=$offsety;photon_ratio=0.2;"
    puts $f "force_symmetric=0;electron_ratio=0.2;do_photons=1;"
    puts $f "do_coherent=$gp_param(do_coherent);grids=0;rndm_load=0;"
    puts $f "do_pairs=0;track_pairs=0;do_compt=0;photon_ratio=0.2;load_beam=3;"
    puts $f "hist_ee_bins=1010;hist_ee_max=2.02*energy.1;charge_sign=$gp_param(charge_sign);\}"

    puts $f "\$PARAMETERS:: default0"
    puts $f "\{n_x=$gp_param(n_x);n_y=$gp_param(n_y);n_z=$n_slice;"
    puts $f "n_t=$gp_param(n_t);n_m=$n_total;cut_x=$gp_param(cut_x);"
    puts $f "cut_y=$gp_param(cut_y);cut_z=3.0*sigma_z.1;offset_y.1=$offsety;offset_y.2=$offsety;"
    puts $f "force_symmetric=0;electron_ratio=0.2;do_photons=1;"
    puts $f "do_coherent=$gp_param(do_coherent);grids=0;rndm_load=0;"
    puts $f "do_pairs=0;track_pairs=0;do_compt=0;photon_ratio=0.2;load_beam=3;"
    puts $f "hist_ee_bins=1010;hist_ee_max=2.02*energy.1;charge_sign=0;\}"
    close $f
}

# Modified according to the IP CLIC beam parameters of CLIC Note 627
proc write_guinea_offset_angle_xy {offsety offsetx anglex offset angle} {
    global n_slice gp_param n_total
    set offy [ expr 0.5*$offset - $offsety ]
    set f [open acc.dat w]

    puts $f "\$ACCELERATOR:: default"
    puts $f "\{energy=$gp_param(energy);particles=$gp_param(particles);"
    puts $f "beta_x=7.0;beta_y=0.07;emitt_x=0.66;"
#    puts $f "emitt_y=0.02;sigma_z=$gp_param(sigmaz);espread=0.01;dist_z=0;f_rep=150.0;"
#    puts $f "n_b=3120;waist_y=0;\}"
    puts $f "emitt_y=0.02;sigma_z=$gp_param(sigmaz);espread=0.001;dist_z=0;f_rep=50.0;"
    puts $f "n_b=312;waist_y=0;\}"

    puts $f "\$PARAMETERS:: default"
    puts $f "\{n_x=$gp_param(n_x);n_y=$gp_param(n_y);n_z=$n_slice;"
    puts $f "n_t=$gp_param(n_t);n_m=$n_total;cut_x=$gp_param(cut_x);"
#    puts $f "cut_y=$gp_param(cut_y);cut_z=3.0*sigma_z.1;offset_y=0.5*$offset;"
    puts $f "cut_y=$gp_param(cut_y);cut_z=3.0*sigma_z.1;"
    puts $f "offset_y=$offy;"
    puts $f "offset_x.1=$offsetx;offset_x.2=$offsetx;"
    puts $f "force_symmetric=0;electron_ratio=0.2;do_photons=1;"
    puts $f "ecm_min=$gp_param(ecm_min);"
    puts $f "do_coherent=$gp_param(do_coherent);grids=0;angle_y=0.5*$angle;rndm_load=1;angle_x=0.5*$anglex;"
    puts $f "do_pairs=0;track_pairs=0;do_compt=0;photon_ratio=0.2;load_beam=3;store_beam=0;"
    puts $f "hist_ee_bins=1010;hist_ee_max=2.02*energy.1;charge_sign=$gp_param(charge_sign);\}"

    puts $f "\$PARAMETERS:: default_1"
    puts $f "\{n_x=$gp_param(n_x);n_y=[expr 4*$gp_param(n_y)];n_z=$n_slice;"
    puts $f "n_t=$gp_param(n_t);n_m=[expr $n_slice*200 ];cut_x=$gp_param(cut_x);"
    puts $f "cut_y=[expr 4*$gp_param(cut_y)];cut_z=3.0*sigma_z.1;"
    puts $f "offset_y=0.5*$offset;"
    puts $f "force_symmetric=0;electron_ratio=0.2;do_photons=1;"
    puts $f "do_coherent=$gp_param(do_coherent);grids=0;angle_y=0.5*$angle;rndm_load=0;"
    puts $f "do_pairs=0;track_pairs=0;do_compt=0;photon_ratio=0.2;load_beam=3;"
    puts $f "hist_ee_bins=1010;hist_ee_max=2.02*energy.1;charge_sign=$gp_param(charge_sign);\}"

    puts $f "\$PARAMETERS:: default0"
    puts $f "\{n_x=$gp_param(n_x);n_y=$gp_param(n_y);n_z=$n_slice;"
    puts $f "n_t=$gp_param(n_t);n_m=[expr $n_slice*200];cut_x=$gp_param(cut_x);"
    puts $f "cut_y=$gp_param(cut_y);cut_z=3.0*sigma_z.1;offset_y=0.5*$offset;"
    puts $f "force_symmetric=0;electron_ratio=0.2;do_photons=1;"
    puts $f "do_coherent=$gp_param(do_coherent);grids=0;angle_y=0.5*$angle;rndm_load=0;"
    puts $f "do_pairs=0;track_pairs=0;do_compt=0;photon_ratio=0.2;load_beam=3;"
    puts $f "hist_ee_bins=1010;hist_ee_max=2.02*energy.1;charge_sign=0;\}"
    close $f
}

proc write_guinea_all {offset angle waist1 waist2} {
    global n_slice gp_param n_total
    set f [open acc.dat w]

    puts $f "\$ACCELERATOR:: default"
    puts $f "\{energy=$gp_param(energy);particles=$gp_param(particles);"
    puts $f "beta_x=8.0;beta_y=0.15;emitt_x=0.68;"
    puts $f "emitt_y=0.02;sigma_z=$gp_param(sigmaz);espread=0.001;dist_z=0;f_rep=120.0;"
    puts $f "n_b=190;waist_y.1=$waist1;waist_y.2=$waist2;\}"

    puts $f "\$PARAMETERS:: default"
    puts $f "\{n_x=$gp_param(n_x);n_y=$gp_param(n_y);n_z=$n_slice;"
    puts $f "n_t=$gp_param(n_t);n_m=$n_total;cut_x=$gp_param(cut_x);"
    puts $f "cut_y=$gp_param(cut_y);cut_z=3.0*sigma_z.1;offset_y=0.5*$offset;"
    puts $f "force_symmetric=0;electron_ratio=0.2;do_photons=1;"
    puts $f "ecm_min=$gp_param(ecm_min);"
    puts $f "do_coherent=$gp_param(do_coherent);grids=0;angle_y=0.5*$angle;rndm_load=0;"
    puts $f "do_pairs=0;track_pairs=0;do_compt=0;photon_ratio=0.2;load_beam=3;"
    puts $f "hist_ee_bins=1010;hist_ee_max=2.02*energy.1;charge_sign=$gp_param(charge_sign);\}"

    puts $f "\$PARAMETERS:: default_1"
    puts $f "\{n_x=$gp_param(n_x);n_y=[expr 4*$gp_param(n_y)];n_z=$n_slice;"
    puts $f "n_t=$gp_param(n_t);n_m=$n_slice*$n;cut_x=$gp_param(cut_x);"
    puts $f "cut_y=[expr 4*$gp_param(cut_y)];cut_z=3.0*sigma_z.1;"
    puts $f "offset_y=0.5*$offset;"
    puts $f "force_symmetric=0;electron_ratio=0.2;do_photons=1;"
    puts $f "do_coherent=$gp_param(do_coherent);grids=0;angle_y=0.5*$angle;"
    puts $f "do_pairs=0;track_pairs=0;do_compt=0;photon_ratio=0.2;load_beam=3;"
    puts $f "hist_ee_bins=1010;hist_ee_max=2.02*energy.1;charge_sign=$gp_param(charge_sign);\}"

    puts $f "\$PARAMETERS:: default0"
    puts $f "\{n_x=$gp_param(n_x);n_y=$gp_param(n_y);n_z=$n_slice;"
    puts $f "n_t=$gp_param(n_t);n_m=$n_slice*$n;cut_x=$gp_param(cut_x);"
    puts $f "cut_y=$gp_param(cut_y);cut_z=3.0*sigma_z.1;offset_y=0.5*$offset;"
    puts $f "force_symmetric=0;electron_ratio=0.2;do_photons=1;"
    puts $f "do_coherent=$gp_param(do_coherent);grids=0;angle_y=0.5*$angle;"
    puts $f "do_pairs=0;track_pairs=0;do_compt=0;photon_ratio=0.2;load_beam=3;"
    puts $f "hist_ee_bins=1010;hist_ee_max=2.02*energy.1;charge_sign=0;\}"
    close $f
}

proc get_lumi {name} {
    set l [exec grep lumi_fine= $name]
    set i1 [expr [string last "=" $l]+1]
    set i2 [expr [string last ";" $l]-1]
    return [string range $l $i1 $i2]
}

proc get_lumi_ee {name} {
    set l [exec grep lumi_ee= $name]
    set i1 [expr [string last "=" $l]+1]
    set i2 [expr [string last ";" $l]-1]
    return [string range $l $i1 $i2]
}


proc get_lumi_high {name} {
    set l [exec grep lumi_ee_high= $name]
    set i1 [expr [string last "=" $l]+1]
    set i2 [expr [string last ";" $l]-1]
    return [string range $l $i1 $i2]
}


proc get_lumi_null {name} {
    set l [exec cat $name | grep lumi_fine= ]
    set i1 [expr [string last "=" $l]+1]
    set i2 [expr [string last ";" $l]-1]
#    exec gunzip -c $name.gz > tr
#    exec ~/gp/gpv tr lumi_ee
    exec ~/gp/gpv default lumi_ee
    set f [open lumi_ee.dat r]
    set sum 0.0
    for {set i 0} {$i<995} {incr i} {
	gets $f line
	gets $f line
	set dl [lindex $line 1]
	set sum [expr $sum+$dl]
    }
    set sum1 0.0
    for { } {$i<1010} {incr i} {
	gets $f line
	gets $f line
	set dl [lindex $line 1]
	set sum [expr $sum+$dl]
	set sum1 [expr $sum1+$dl]
    }
    return "$sum1"
#    return [string range $l $i1 $i2]
}

#
# get 
#

proc get_lumi_coh {name} {
    set l [exec cat $name | grep coherent.sumeng ]
    set i1 [expr [string last "=" $l]+1]
    set i2 [expr [string last ";" $l]-1]
    return [expr -1.0*[string range $l $i1 $i2]]
}

proc get_angle {name} {
    set l [exec grep "bpm_vx\.1=" $name]
    set i1 [expr [string first "=" $l]+1]
    set i2 [expr [string first ";" $l]-1]
    set v1x [string range $l $i1 $i2]
    set l [exec grep "bpm_vx\.2=" $name]
    set i1 [expr [string first "=" $l]+1]
    set i2 [expr [string first ";" $l]-1]
    set v2x [string range $l $i1 $i2]
    set l [exec grep "bpm_vy\.1=" $name]
    set i1 [expr [string first "=" $l]+1]
    set i2 [expr [string first ";" $l]-1]
    set v1y [string range $l $i1 $i2]
    set l [exec grep "bpm_vy\.2=" $name]
    set i1 [expr [string first "=" $l]+1]
    set i2 [expr [string first ";" $l]-1]
    set v2y [string range $l $i1 $i2]
    return "[expr 0.5*($v1x-$v2x)] [expr 0.5*($v1y-$v2y)]"
}

proc get_angle_coh {name} {
    set l [exec grep "bpm_vx_coh\.1=" $name]
    set i1 [expr [string first "=" $l]+1]
    set i2 [expr [string first ";" $l]-1]
    set v1x [string range $l $i1 $i2]
    set l [exec grep "bpm_vx_coh\.2=" $name]
    set i1 [expr [string first "=" $l]+1]
    set i2 [expr [string first ";" $l]-1]
    set v2x [string range $l $i1 $i2]
    set l [exec grep "bpm_vy_coh\.1=" $name]
    set i1 [expr [string first "=" $l]+1]
    set i2 [expr [string first ";" $l]-1]
    set v1y [string range $l $i1 $i2]
    set l [exec grep "bpm_vy_coh\.2=" $name]
    set i1 [expr [string first "=" $l]+1]
    set i2 [expr [string first ";" $l]-1]
    set v2y [string range $l $i1 $i2]
    return "[expr 0.5*($v1x-$v2x)] [expr 0.5*($v1y-$v2y)]"
}


proc get_miss {name} {
    return [expr 0.5*([get_var $name "out.1"]+[get_var $name "out.2"])]
#    set l [exec grep "out\.1=" $name]
#    set i1 [expr [string first "=" $l]+1]
#    set i2 [expr [string first ";" $l]-1]
#    set v1 [string range $l $i1 $i2]
#    set l [exec grep "out\.2=" $name]
#    set i1 [expr [string first "=" $l]+1]
#    set i2 [expr [string first ";" $l]-1]
#    set v2 [string range $l $i1 $i2]
#    return [expr 0.5*($v1+$v2)]
}


proc centre_each {} {

    set sumx 0.0
    set sumy 0.0
    set sumxp 0.0
    set sumyp 0.0
    set n 0

    set f1 [open electron.ini r]
    gets $f1 l
    while {![eof $f1]} {
        set sumx [expr $sumx+[lindex $l 1]]
        set sumy [expr $sumy+[lindex $l 2]]
        set sumxp [expr $sumxp+[lindex $l 4]]
        set sumyp [expr $sumyp+[lindex $l 5]]
        incr n
        gets $f1 l
    }
    close $f1

    set x0 [expr $sumx/$n]
    set y0 [expr $sumy/$n]
    set xp0 [expr $sumxp/$n]
    set yp0 [expr $sumyp/$n]

    puts "e> $x0 $y0 $xp0 $yp0"
    exec cp electron.ini tmp.ini
    set f1 [open tmp.ini r]
    set f2 [open electron.ini w]
    gets $f1 l
    while {![eof $f1]} {
        puts $f2 "[lindex $l 0] [expr [lindex $l 1]-$x0] [expr [lindex $l 2]-$y0] [lindex $l 3] [expr [lindex $l 4]-$xp0] [expr [lindex $l 5]-$yp0]"
        gets $f1 l
    }
    close $f1
    close $f2

    set sumx 0.0
    set sumy 0.0
    set sumxp 0.0
    set sumyp 0.0
    set n 0

    set f1 [open positron.ini r]
    gets $f1 l
    while {![eof $f1]} {
        set sumx [expr $sumx+[lindex $l 1]]
        set sumy [expr $sumy+[lindex $l 2]]
        set sumxp [expr $sumxp+[lindex $l 4]]
        set sumyp [expr $sumyp+[lindex $l 5]]
        incr n
        gets $f1 l
    }
    close $f1

    set x0 [expr $sumx/$n]
    set y0 [expr $sumy/$n]
    set xp0 [expr $sumxp/$n]
    set yp0 [expr $sumyp/$n]

    puts "p> $x0 $y0 $xp0 $yp0"
    exec cp positron.ini tmp.ini
    set f1 [open tmp.ini r]
    set f2 [open positron.ini w]
    gets $f1 l
    while {![eof $f1]} {
        puts $f2 "[lindex $l 0] [expr [lindex $l 1]-$x0] [expr [lindex $l 2]-$y0] [lindex $l 3] [expr [lindex $l 4]-$xp0] [expr [lindex $l 5]-$yp0]"
        gets $f1 l
    }
    close $f1
    close $f2
}

proc centre_each_position {} {

    set sumx 0.0
    set sumy 0.0
    set n 0

    set f1 [open electron.ini r]
    gets $f1 l
    while {![eof $f1]} {
        set sumx [expr $sumx+[lindex $l 1]]
        set sumy [expr $sumy+[lindex $l 2]]
        incr n
        gets $f1 l
    }
    close $f1

    set x0 [expr $sumx/$n]
    set y0 [expr $sumy/$n]

    puts "e> $x0 $y0"
    exec cp electron.ini tmp.ini
    set f1 [open tmp.ini r]
    set f2 [open electron.ini w]
    gets $f1 l
    while {![eof $f1]} {
        puts $f2 "[lindex $l 0] [expr [lindex $l 1]-$x0] [expr [lindex $l 2]-$y0] [lindex $l 3] [lindex $l 4] [lindex $l 5]"
        gets $f1 l
    }
    close $f1
    close $f2

    set sumx 0.0
    set sumy 0.0
    set n 0

    set f1 [open positron.ini r]
    gets $f1 l
    while {![eof $f1]} {
        set sumx [expr $sumx+[lindex $l 1]]
        set sumy [expr $sumy+[lindex $l 2]]
        incr n
        gets $f1 l
    }
    close $f1

    set x0 [expr $sumx/$n]
    set y0 [expr $sumy/$n]

    puts "p> $x0 $y0"
    exec cp positron.ini tmp.ini
    set f1 [open tmp.ini r]
    set f2 [open positron.ini w]
    gets $f1 l
    while {![eof $f1]} {
        puts $f2 "[lindex $l 0] [expr [lindex $l 1]-$x0] [expr [lindex $l 2]-$y0] [lindex $l 3] [lindex $l 4] [lindex $l 5]"
        gets $f1 l
    }
    close $f1
    close $f2
}

#source $scripts/minimise.tcl

proc get_var {name var} {
    set l [exec grep $var $name]
    set l2 [string range $l [expr [string first $var $l]+[string length $var]+1] end]
    set i [string first ";" $l2]
    if {$i} {
        set l2 [string range $l2 0 [expr $i-1]]
    }
    return $l2
}

proc get_results {name} {
    return "[get_lumi_ee $name] [get_lumi_high $name] [get_lumi_coh $name] [get_angle $name] [get_miss $name]"
}

proc get_results2 {name} {
    set luminosity [expr [get_lumi_ee $name]*2820.0*5.0/10000.0]
    return "$luminosity [get_lumi $name] [get_lumi_high $name] [get_lumi_ee $name] [get_angle $name] [get_miss $name]"
}

#Luminosity for CLIC:
proc get_results3 {name} {
#    set luminosity [expr [get_lumi_ee $name]*220.0*150.0/10000.0]
    set luminosity [expr [get_lumi_high $name]*50.0*312.0/10000.0]
    return "$luminosity [get_angle $name] [get_angle_coh $name]"
}
