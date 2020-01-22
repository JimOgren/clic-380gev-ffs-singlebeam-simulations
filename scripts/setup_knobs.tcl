Octave {
  global IPind Sind Oind
  IPind = IP;
  Sind = MIsext;
  Oind = MIoct;
  Lmeas = 0; % initialize luminosity measurement counter

  # Initialize log-files for Luminosity data:
  knobfile = fopen("Tuning_log_pre_alignment.dat","w"); fclose(knobfile);        
  knobfile = fopen("Tuning_log_sextupole_knobs.dat","w"); fclose(knobfile);        
  knobfile = fopen("Tuning_log_octupole_knobs.dat","w"); fclose(knobfile);        
}

# fmin_inverse_parabola
##########################################################
Octave {
  function [x_min, f_min, eval_num] = fmin_inverse_parabola(func, a, b, c, N)
    switch nargin
	case 4
		N = 5;
    end
    X = [ a b c ];
    F = [ feval(func, a) feval(func, b) feval(func, c) ];
    eval_num = 3;
    [f_min, i_min] = min(F);
    x_min = X(i_min);
    for iter = 1:N
      [P,S] = polyfit(X, F, 2);
      if P(1) == 0
        disp("flat function!");
        break
      end
      while P(1) < 0
        disp("bracketing");
        [F, I] = sort(F);
        X = X(I);
        X(3) = X(1) + 1.6180 * (X(1) - X(3));
        F(3) = feval(func, X(3));
        eval_num += 1;
        [P,S] = polyfit(X, F, 2);
      end
      x_vertex = -P(2) / P(1) / 2;
      f_vertex = feval(func, x_vertex);
      eval_num += 1;
      X = [ X x_vertex ];
      F = [ F f_vertex ];
      [F, I] = sort(F);
      X = X(I(1:3));
      F = F(1:3);
      x_min = X(1);
      f_min = F(1);
      X(3) = X(1) + 0.38197 * sign(X(1) - X(2)) * abs(X(1) - X(3));
      F(3) = feval(func, X(3));
      eval_num += 1;
    end
  end
}


# Pre-aligning the sextupoles
##########################################################
foreach axis { x y } {
  foreach knob { 1 2 3 4 5 6 } {
    Octave {
      function move_sextupole${knob}${axis}(x)
        global Sind;
        placet_element_vary_attribute("test", Sind($knob), "$axis", x);
      end

      function L = test_move_sextupole${knob}${axis}(x)
	global IPind;
	move_sextupole${knob}${axis}(+x);
	try
          [E,B] = placet_test_no_correction("test", "beam0t", "None", 1, 0, IPind);
      	  sxrms=std(B(:,2))
      	  syrms=std(B(:,3))
      	  L = -get_lumi(B);
	catch
	  L = -1e29;
	end
        move_sextupole${knob}${axis}(-x);
        printf("test_move_sextupole${knob}${axis}(%g) =  %g\n", x, L);
        # write to file
        knobfile = fopen("Tuning_log_pre_alignment.dat","a");
      	fprintf(knobfile,"${axis} ${knob} %g %g\n", x, L);
      	fclose(knobfile);        
      end
    }
  }
}

# Align sextupoles one-by-one, direction downstream
proc align_sextupoles { range } {
   Octave {
     MStemp = placet_element_get_attribute("test", Sind, "strength");
     placet_element_set_attribute("test", Sind, "strength", 0.0);
   }
   foreach knob { 1 2 3 4 5 6 } {
      Octave {
	Nend = length(Sind);
        placet_element_set_attribute("test", Sind($knob), "strength", MStemp($knob));
      }
      foreach axis { x y } {
        Octave {
          [x, fmin, eval_num] = fmin_inverse_parabola("test_move_sextupole${knob}${axis}", -$range, 0.0, $range, 3);
          move_sextupole${knob}${axis}(x);
          Lmeas += eval_num
        }
      }

      foreach axis { x y } {
        Octave {
          [x, fmin, eval_num] = fmin_inverse_parabola("test_move_sextupole${knob}${axis}", -$range/20, 0.0, $range/20, 5);
          move_sextupole${knob}${axis}(x);
	  Lmeas += eval_num;
        }
      }
   }
}

# Align sextupoles one-by-one, direction upstream
proc align_sextupoles_reverse { range } {
   Octave {
     MStemp = placet_element_get_attribute("test", Sind, "strength");
     placet_element_set_attribute("test", Sind, "strength", 0.0);
   }
   foreach knob { 6 5 4 3 2 1 } {
      Octave {
	Nend = length(Sind);
        placet_element_set_attribute("test", Sind($knob), "strength", MStemp($knob));
      }
      foreach axis { x y } {
        Octave {
          [x, fmin, eval_num] = fmin_inverse_parabola("test_move_sextupole${knob}${axis}", -$range, 0.0, $range, 3);
          move_sextupole${knob}${axis}(x);
          Lmeas += eval_num
        }
      }

      foreach axis { x y } {
        Octave {
          [x, fmin, eval_num] = fmin_inverse_parabola("test_move_sextupole${knob}${axis}", -$range/20, 0.0, $range/20, 5);
          move_sextupole${knob}${axis}(x);
	  Lmeas += eval_num;
        }
      }
   }
}

# Load Knobs-file
##########################################################
Octave {
  load 'Knobs_sr_${sr}.dat'
  global Knobs_sext Knobs_oct;
  Knobs_sext = Knobs_sextupole;
  Knobs_oct = Knobs_octupole;
}

# Sextupole 1st order knobs
##########################################################
foreach axis { x y } {
  foreach knob { 1 2 3 4 5 6 } {
    Octave {
      function vary_sextupole_knob${knob}${axis}(x)
        global Knobs_sext;
        Knobs_sext.V${axis};
        knobs = x * Knobs_sext.V${axis}(:,$knob);
        placet_element_vary_attribute("test", Knobs_sext.I${axis}, "$axis", knobs);
      end

      function L = test_sextupole_knob${knob}${axis}(x)
	global IPind;
        vary_sextupole_knob${knob}${axis}(+x);
        [E,B] = placet_test_no_correction("test", "beam0t", "None", 1, 0, IPind);
      	sxrms=std(B(:,2))
      	syrms=std(B(:,3))
        L = -get_lumi(B);

        vary_sextupole_knob${knob}${axis}(-x);
        printf("test_sextupole_knob${knob}${axis}(%g) =  %g\n", x, L);
        # write to file
        knobfile = fopen("Tuning_log_sextupole_knobs.dat","a");
      	fprintf(knobfile,"${axis} ${knob} %g %g\n", x, L);
      	fclose(knobfile);  
      end
    }
  }
}

proc sextupole_knobs { range } {
  foreach axis { x y } {
    foreach knob { 1 2 3 4 5 6 } {
      Octave {
        [x, fmin, eval_num] = fmin_inverse_parabola("test_sextupole_knob${knob}${axis}", -$range, 0.0, $range);
        vary_sextupole_knob${knob}${axis}(x);
        Lmeas += eval_num;
      }
    }
  }
  Octave {
     # mark end of scan
     knobfile = fopen("Tuning_log_sextupole_knobs.dat","a");
     fprintf(knobfile,"======\n", x, L);
     fclose(knobfile);  
  }
}

# Octupole 1st order knobs
##########################################################
foreach axis { x y } {
  foreach knob { 1 2 } {
    Octave {
      function vary_octupole_knob${knob}${axis}(x)
        global Knobs_oct;
        Knobs_oct.V${axis};
        knobs = x * Knobs_oct.V${axis}(:,$knob);
        placet_element_vary_attribute("test", Knobs_oct.I${axis}, "$axis", knobs);
      end

      function L = test_octupole_knob${knob}${axis}(x)
	global IPind;
        vary_octupole_knob${knob}${axis}(+x);
        [E,B] = placet_test_no_correction("test", "beam0t", "None", 1, 0, IPind);
      	sxrms=std(B(:,2))
      	syrms=std(B(:,3))
        L = -get_lumi(B);

        vary_octupole_knob${knob}${axis}(-x);
        printf("test_octupole_knob${knob}${axis}(%g) =  %g\n", x, L);
        # write to file
        knobfile = fopen("Tuning_log_octupole_knobs.dat","a");
      	fprintf(knobfile,"${axis} ${knob} %g %g\n", x, L);
      	fclose(knobfile);  
      end
    }
  }
}

proc octupole_knobs { range } {
  foreach axis { x y } {
    foreach knob { 1 2 } {
      Octave {
        [x, fmin, eval_num] = fmin_inverse_parabola("test_octupole_knob${knob}${axis}", -$range, 0.0, $range);
        vary_octupole_knob${knob}${axis}(x);
        Lmeas += eval_num;
      }
    }
  }
  Octave {
     # mark end of scan
     knobfile = fopen("Tuning_log_octupole_knobs.dat","a");
     fprintf(knobfile,"======\n", x, L);
     fclose(knobfile);  
  }
}


