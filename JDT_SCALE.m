function [IgvScaled, RotorScaled, StatorScaled] = JDT_SCALE(Solidities, MIT_RTIP, RE, PHI, RPM, Data, Igv, Rotor, Stator)
    RPM_MIN = 1600;
    PHI_0425 = 0.425; PHI_0590 = 0.590;
    MIT_RE_1600_425 = 50000; MIT_RE_1600_590 = 72500;
    MIT_LEGACY_CHORD = 0.038;
    
    MIT_RE_1600 = MIT_RE_1600_425 + (MIT_RE_1600_590 - MIT_RE_1600_425) * ((PHI - PHI_0425) / (PHI_0590 - PHI_0425));
    
    MIT_RE_1600_NEW = RE / (RPM / RPM_MIN);
    
    FACTOR = MIT_RE_1600_NEW / MIT_RE_1600;
    
    CHORD_ROTOR = MIT_LEGACY_CHORD * FACTOR;

    UNSCALED_CHORD_IGV = Data(1, 2); 
    UNSCALED_CHORD_ROTOR = Data(2, 2); 
    UNSCALED_CHORD_STATOR = Data(3, 2);
    
    AR_IGV = Data(1, 5); AR_ROTOR = Data(2, 5); AR_STATOR = Data(3, 5);
    
    NEW_RTIP = MIT_RTIP;
    NEW_SPAN = CHORD_ROTOR * AR_ROTOR;
    NEW_RHUB = NEW_RTIP - NEW_SPAN;
    NEW_RMID = (NEW_RTIP + NEW_RHUB) / 2;
    
    CHORD_IGV = NEW_SPAN / AR_IGV;
    CHORD_STATOR = NEW_SPAN / AR_STATOR;
    
    CIRC = 2 * pi * NEW_RMID;
    
    SOLIDITY_IGV = Solidities(1);
    SOLIDITY_ROTOR = Solidities(2);
    SOLIDITY_STATOR = Solidities(3);
    
    PITCH_IGV = CHORD_IGV / SOLIDITY_IGV;
    PITCH_ROTOR = CHORD_ROTOR / SOLIDITY_ROTOR;
    PITCH_STATOR = CHORD_STATOR / SOLIDITY_STATOR;
    
    N_IGV = round(CIRC / PITCH_IGV, 0);
    N_ROTOR = round(CIRC / PITCH_ROTOR, 0);
    N_STATOR = round(CIRC / PITCH_STATOR, 0);
    
    IGV_FACTOR = CHORD_IGV / UNSCALED_CHORD_IGV;
    ROTOR_FACTOR = CHORD_ROTOR / UNSCALED_CHORD_ROTOR;
    STATOR_FACTOR = CHORD_STATOR / UNSCALED_CHORD_STATOR;
    
    SPAN_FACTOR = NEW_SPAN / (Igv{3}(end) - Igv{3}(1));
    
    Igv{3} = Igv{3} - Igv{3}(1);
    Rotor{3} = Rotor{3} - Rotor{3}(1);
    Stator{3} = Stator{3} - Stator{3}(1);
    
    IgvScaled = {Igv{1} .* IGV_FACTOR; Igv{2} .* IGV_FACTOR; (Igv{3} .* SPAN_FACTOR) + NEW_RHUB};
    RotorScaled = {Rotor{1} .* ROTOR_FACTOR; Rotor{2} .* ROTOR_FACTOR; (Rotor{3} .* SPAN_FACTOR) + NEW_RHUB};
    StatorScaled = {Stator{1} .* STATOR_FACTOR; Stator{2} .* STATOR_FACTOR; (Stator{3} .* SPAN_FACTOR) + NEW_RHUB};
    
    fprintf('RE: %.0f\tPHI: %.2f\tRPM: %.0f\tNew Hub Radius: %.4f m\n', RE, PHI, RPM, NEW_RHUB);
    fprintf('N_IGV: %.0f blades\tN_ROTOR: %.0f blades\tN_STATOR: %.0f blades\n', N_IGV, N_ROTOR, N_STATOR);
    fprintf('Blade Geometry Scaled by a Factor of %.3f\n\n', SPAN_FACTOR);
end

