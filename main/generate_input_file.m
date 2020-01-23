FID = fopen("input.txt","w");
for mach = 1:10
   fprintf(FID,"%i\n", mach);
end
fclose(FID);
