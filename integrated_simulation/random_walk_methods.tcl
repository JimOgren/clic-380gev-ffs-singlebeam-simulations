# RANDOM WALK METHODS
#############################################################################
#############################################################################
Octave {
	global sel mov TEMP
	sel = 1;
	mov = 1;
	TEMP = [];

	# Move sextupoles and quadrupoles
	###################################
	function [] = move_sq(x)
		global sel mov
      MIsext = [48 59 70 79 210 220];
      QI = [2 6 10 14 18 22 37 41 45 51 55 63 67 76 82 97 112 127 214 224];
      ind = [MIsext, MIsext, QI, QI]';
      dir = [repmat("x", 6,1);repmat("y", 6,1);repmat("x", 20,1);repmat("y", 20,1)];
		s_temp = [];
		for i=1:length(sel)
			s_temp = [s_temp; placet_element_get_attribute("test", ind(sel(i)), dir(sel(i)))];
		end

		for i = 1:length(sel)
			placet_element_set_attribute("test",  ind(sel(i)), dir(sel(i)), s_temp(i) + x*mov(i));
		end
	end
}


# Procedure: random walk pairs maximizer
#############################################################################
#############################################################################
proc random_walk_sq { subset } {
	set NumOfPoints 9
	set MaxIterations 300
	set count 1
   set flag 1
   set Lmax 0
   set Llim 1e35
   set range 0.2

	Octave {
		printf("\n=================================================================\n")
		printf("=================================================================\n\n")
      printf("Starting Sextupole and Quadrupole Random Walk\n\n");
      printf("=================================================================\n")
      # check starting condition:
		[E,B] = placet_test_no_correction("test", "beam0t", "None", 1, 0, IPind);
		L = get_lumi(B);
		printf("Lumi =  %g\n\n", L);
   }

	while {$flag} {
		Octave {
			# Set random direction:
			sel = [];
			for j = 1:$subset
				temp = randi(52);
				if sum(temp==sel) < 1
					sel = [sel; temp];
				end
			end
			mov = randn(size(sel));


			Res = [];
			xvec = linspace(-$range, $range, $NumOfPoints);
			for jk=1:length(xvec)
				move_sq(+xvec(jk));

				# track:
				[E,B] = placet_test_no_correction("test", "beam0t", "None", 1, 0, IPind);
				L = get_lumi(B);
				printf("x = %g; Lumi =  %g\n", xvec(jk), L);
				Res = [Res; xvec(jk), L];
				move_sq(-xvec(jk));
			end

			# make parabolic fit:
			#Y = Res(:,2);
			#xfit = linspace(xvec(1),xvec(end),200);
			#A = [ones(size(xvec')), xvec', (xvec').^2];
			#kfit = pinv(A)*Y;
			#yfit = kfit(1) + kfit(2)*xfit + kfit(3)*xfit.^2;
			#[ymax, ii] = max(yfit);
			#xmax = xfit(ii);

			# find maximum:
			[ymax, ii] = max(Res(:,2));
			xmax = xvec(ii);
			disp(["Max value from fit = ", num2str(ymax), " at x = ", num2str(xmax)]);

			move_sq(xmax);
			Tcl_Eval(["set Lmax ", num2str(ymax)]);


			# plot
			if 0
				figure;
				hold on;
				plot(Res(:,1), Y, 'b*');
				plot(xfit, yfit, 'k', 'linewidth', 1.5);
				plot(xmax, ymax, 'rd', 'markersize', 15, 'markerfacecolor', 'r');
				plot([xmax, xmax], [min(Y), max(Y)], 'k--');
				hold off;
				pause(5);
				close all;
			end
		}

		set count [expr $count+$NumOfPoints]
		puts "count = $count. Lmax = $Lmax"

		Octave {
			if ($count > $MaxIterations || $Lmax > $Llim )
				Tcl_Eval("set flag 0");
			end
		}
	}

	Octave {
		printf("=================================================================\n\n")
		printf("Exiting sextupole and quadrupole random walk...\n");
		printf("Total count = %i; Lmax = %g; \n", $count, $Lmax);
		printf("=================================================================\n")
		printf("=================================================================\n")
	}
	return $count
}
