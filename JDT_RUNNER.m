clc; close all; clearvars;

SCALE_TYPE = 1;

RE = 200000; PHI = 0.45; RPM_MIN = 3200;

RTIP = 0.2119;     MIT_RTIP = 0.295;
RHUB = 0.1845;     MIT_RHUB = 0.2225;
Solidities = [1.20, 1.20, 1.20];

grid2dfile = '/mnt/clifford/jereddt/Research/01_Workflow/02_Runs/Final_Run/grid2d.dat';
delimiterIn = ' ';

[Igv, Rotor, Stator, Chords, AxChords, Staggers, ARs, ARXs, Gaps, ...
 MidSpan, SpanWise, Average, Sections] = JDT_BLADE_PROFILE(Solidities, RTIP, RHUB, grid2dfile, delimiterIn);

JDT_WRITE_BLADE_COORDINATES(Igv, Rotor, Stator, Sections, 1);
JDT_PLOT_BLADE(Igv, Rotor, Stator, Sections);

if SCALE_TYPE == 0
    Data = MidSpan;
elseif SCALE_TYPE == 1
    Data = SpanWise;
elseif SCALE_TYPE == 2
    Data = Average;
end

RPM = JDT_RPM(MIT_RTIP, MIT_RHUB, RE, PHI, Data);

fprintf('\n\nTo Maintain Current MIT Hub Radius, Must be Operational to: %.0f rpm\n', RPM);

RPMS = [RPM_MIN:100:roundn(RPM, 2)];

% for ii = 1:length(RPMS)
    % [IgvScaled, RotorScale, StatorScaled] = JDT_SCALE(MIT_RTIP, MIT_RHUB, RE, PHI, RPM, Data);
    % JDT_PLOT_BLADE(IgvScaled, RotorScaled, StatorScaled, Sections);
    % JDT_WRITE_BLADE_COORDINATES(IgvScaled, RotorScaled, StatorScaled, Sections, 2);
% end


