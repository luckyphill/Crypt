[r_max, r_min, r_mean] = phase_plot({'eesM'}, 0.9:0.1:1.4, 'CellStiffness');
eesM_ratio = r_max./r_mean;

[r_max, r_min, r_mean] = phase_plot({'Mvf'}, [0.5,0.55,0.6,0.65,0.675,0.7,0.8,0.9], 'ContactInhibition');
Mvf_ratio = r_max./r_mean;

[r_max, r_min, r_mean] = phase_plot({'msM'}, 0.7:0.1:1.1, 'MembraneStiffness');
msM_ratio = r_max./r_mean;

[r_max, r_min, r_mean] = phase_plot({'cctM'}, 0.7:0.1:1.1, 'CycleTime');
cctM_ratio = r_max./r_mean;

[r_max, r_min, r_mean] = phase_plot({'wtM'}, 0.5:0.1:1.1, 'GrowthTime');
wtM_ratio = r_max./r_mean;

[r_max, r_min, r_mean] = phase_plot({'Mnp'}, 12:18, 'ProliferationZone');
Mnp_ratio = r_max./r_mean;

[r_max, r_min, r_mean] = phase_plot({'cct', 'wtM'}, 0.5:0.1:1.1, 'ScaledCycleTime');
cctM_wtM_ratio = r_max./r_mean;
