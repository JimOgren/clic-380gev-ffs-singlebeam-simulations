close all
clear all
L = [];
machines = [];
dir_path = 'Results/Results_step1/'
failed = [];
Lumi_meas = 0;

for i = 1:10
  eval(['load ', dir_path, 'tuning_data_', num2str(i), '.dat']);
  try    
    eval(['load ', dir_path, 'tuning_data_', num2str(i), '.dat']);
    L = [L, Lumivec * 352*50/1e4];
    if isempty(Lumivec)
      L = [L, zeros(3,1)];
    end
    machines = [machines, i];
  catch  
    disp(['machine ', num2str(i), ' failed.']);
    failed = [failed, i];
  end
end
Lumi_meas += Lmeas

L2 = [];
dir_path = 'Results/Results_step2/'
failed2 = [];

for i = 1:10
  try    
    eval(['load ', dir_path, 'tuning_data_', num2str(i), '.dat']);
    L2 = [L2, Lumivec * 352*50/1e4];
    if isempty(Lumivec)
      L2 = [L2, zeros(3,1)];
    end    
  catch  
    disp(['machine ', num2str(i), ' failed.']);
    failed2 = [failed2, i];
  end
end
Lumi_meas += Lmeas

L = [L; L2];
LumiMachines = [machines', L'];
break
sort(L(end,:), 'descend');
num_tuned_machines = sum(L(end,:) > 1.5e34)
num_failed_machines = length(failed)

L = sort(L, 2, 'descend');
Luminosities = [machines; L]';

hf = figure("Position", [300   150   759   535]);
hp = plot(machines, Luminosities(:,2), 'gd--', machines, Luminosities(:,4), 'b*-', ...
      machines, Luminosities(:,end), 'rx-');
hx = xlabel('Machine number');
hy = ylabel('Luminosity [1.5e34 cm^{-2}s^{-1}]');
hl = legend('BBA + align sextupoles', 'Sextupole knobs', 'Octupole knobs');
legend(hl, "location", "northeastoutside");
set([hx,hy,hl,gca],'Fontsize',13);
set(hp, 'Linewidth',1.5);
