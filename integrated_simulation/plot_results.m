clear all;
#close all;
more off;
Lumi_tot = [];
iter_tot = [];

# Lumi columns:
# 1 - perfect machine
# 2 - misaligned machine
# 3 - after BBA
# 4 - after sextupole pre-alignment
# 5 - after loading 
# 6 - after sextupole_knobs 5
# 7 - after sextupole_knobs 1
# 8 - after octupole_knobs 10
# 9 - after sextupole_knobs 5
# 10 - after sextupole_knobs 1



# step1
################################################################
L = [];
machines = [];
dir_path = 'Results/Results_with_misalignments_updated2/'
failed = [];
Lumi_meas = 0;

for i = 0:99
  try    
    eval(['load ', dir_path, 'tuning_data_step1_', num2str(i), '.dat']);
    L = [L, Lumivec * 352*50/1e4];
    if isempty(Lumivec)
      L = [L, zeros(4,1)];
    end
    machines = [machines, i];
  catch  
    disp(['machine ', num2str(i), ' failed.']);
    failed = [failed, i];
    L = [L, zeros(4,1)];
  end
end
Lumi_meas += Lmeas


L2 = [];
failed2 = [];

for i = 0:99
  try    
    eval(['load ', dir_path, 'tuning_data_step2_', num2str(i), '.dat']);
    L2 = [L2, Lumivec * 352*50/1e4];
    if isempty(Lumivec)
      L2 = [L2, zeros(6,1)];
    end    
  catch  
    disp(['machine ', num2str(i), ' failed.']);
    failed2 = [failed2, i];
    L2 = [L2, zeros(6,1)];
  end
end
Lumi_meas += Lmeas


L3 = [];
failed3 = [];

for i = 0:99
  try    
    eval(['load ', dir_path, 'tuning_data_step3_', num2str(i), '.dat']);
    L3 = [L3, Lumivec * 352*50/1e4];
    if isempty(Lumivec)
      L3 = [L3, zeros(3,1)];
    end    
  catch  
    disp(['machine ', num2str(i), ' failed.']);
    failed3 = [failed3, i];
    L3 = [L3, zeros(3,1)];
  end
end
Lumi_meas += Lmeas

L = [L; L2; L3];
LumiMachines = [machines', L'];

num_tuned_machines = sum(L(end,:) > 1.5e34)
num_failed_machines = length(failed)

L = sort(L, 2, 'descend');
Luminosities = [machines; L]';

hf = figure("Position", [300 150 800 400]);
hp = plot(machines, Luminosities(:,11), 'b*-', machines, Luminosities(:,14), 'rx-');
hx = xlabel('Beam seed');
hy = ylabel('Luminosity [cm^{-2}s^{-1}]');
hl = legend('Tuning with knobs', 'Q+S Random Walk');
legend(hl, "location", "northeast");
axis([0 100 0 4.5e34]);
set([hx,hy,hl,gca],'Fontsize',13);
set(hp, 'Linewidth',1.5);
grid on;

#print -dpng "-S800,400" Tuning_results_tuned_beams_updated.png
