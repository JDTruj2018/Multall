function [Igv, Rotor, Stator, Chords, AxChords, Staggers, ARs, ARXs, Gaps, MidSpan, SpanWise, Average, N_SEC] = JDT_BLADE_PROFILE(Solidities, RTIP, RHUB, grid2dfile, delimiterIn)

    RAW_INPUT = importdata(grid2dfile, delimiterIn);
    
    RMID = (RTIP + RHUB) / 2;
    HUB_TIP_RATIO = RHUB / RTIP;
    SPAN = RTIP - RHUB;
    
    SOLIDITY_IGV = Solidities(1);
    SOLIDITY_ROTOR = Solidities(2);
    SOLIDITY_STATOR = Solidities(3);
    
    J_TOTAL = 433;
    J_IGV = 146; J_ROTOR = 136; J_STATOR = 151;
    
    J_IGV_LE = 31; J_IGV_TE = 131;

    J_ROTOR_LE = 21; J_ROTOR_TE = 121;

    J_STATOR_LE = 21; J_STATOR_TE = 121;
    
    N_SEC = length(RAW_INPUT) / J_TOTAL;
    SEC_Z = [0; 0.05; 0.10; 0.25; 0.50; 0.75; 0.90; 0.95; 1];
    
    X_IGV_DATA  = zeros(N_SEC, J_IGV);
    Y_IGV_DATA  = zeros(N_SEC, J_IGV);
    TK_IGV_DATA = zeros(N_SEC, J_IGV);
    
    X_ROTOR_DATA = zeros(N_SEC, J_ROTOR);
    Y_ROTOR_DATA = zeros(N_SEC, J_ROTOR);
    TK_ROTOR_DATA = zeros(N_SEC, J_ROTOR);
    
    X_STATOR_DATA = zeros(N_SEC, J_STATOR);
    Y_STATOR_DATA = zeros(N_SEC, J_STATOR);
    TK_STATOR_DATA = zeros(N_SEC, J_STATOR);
    
    for ii = 1:N_SEC
        F_IGV = N_SEC * J_IGV;
        F_ROTOR = F_IGV + N_SEC * J_ROTOR;
        
        START_IGV = (ii - 1) * J_IGV + 1;
        END_IGV   = ii * J_IGV;
        
        START_ROTOR = F_IGV + (ii - 1) * J_ROTOR + 1;
        END_ROTOR = F_IGV + ii * J_ROTOR;
        
        START_STATOR = F_ROTOR + (ii - 1) *  J_STATOR + 1;
        END_STATOR = F_ROTOR + ii * J_STATOR;
        
        X_IGV_DATA(ii, :)  = RAW_INPUT(START_IGV:END_IGV, 2);
        Y_IGV_DATA(ii, :)  = RAW_INPUT(START_IGV:END_IGV, 3);
        TK_IGV_DATA(ii, :) = RAW_INPUT(START_IGV:END_IGV, 4);
        
        X_ROTOR_DATA(ii, :)  = RAW_INPUT(START_ROTOR:END_ROTOR, 2);
        Y_ROTOR_DATA(ii, :)  = RAW_INPUT(START_ROTOR:END_ROTOR, 3);
        TK_ROTOR_DATA(ii, :) = RAW_INPUT(START_ROTOR:END_ROTOR, 4);
        
        X_STATOR_DATA(ii, :)  = RAW_INPUT(START_STATOR:END_STATOR, 2);
        Y_STATOR_DATA(ii, :)  = RAW_INPUT(START_STATOR:END_STATOR, 3);
        TK_STATOR_DATA(ii, :) = RAW_INPUT(START_STATOR:END_STATOR, 4);
    end
    
    IGV_CHORD = zeros(N_SEC, 1);
    ROTOR_CHORD = zeros(N_SEC, 1);
    STATOR_CHORD = zeros(N_SEC, 1);
    X_IGV_AX = zeros(N_SEC, 1);
    X_ROTOR_AX = zeros(N_SEC, 1);
    X_STATOR_AX = zeros(N_SEC, 1);
    
    for SEC = 1:N_SEC
        IGV1 = [X_IGV_DATA(SEC, J_IGV_LE); Y_IGV_DATA(SEC, J_IGV_LE)];
        IGV2 = [X_IGV_DATA(SEC, J_IGV_TE); Y_IGV_DATA(SEC, J_IGV_TE)];
        IGV_CHORD(SEC) = sqrt((IGV2(1) - IGV1(1)) ^ 2 + (IGV2(2) - IGV1(2)) ^ 2);
        
        ROTOR1 = [X_ROTOR_DATA(SEC, J_ROTOR_LE); Y_ROTOR_DATA(SEC, J_ROTOR_LE)];
        ROTOR2 = [X_ROTOR_DATA(SEC, J_ROTOR_TE); Y_ROTOR_DATA(SEC, J_ROTOR_TE)];
        ROTOR_CHORD(SEC) = sqrt((ROTOR2(1) - ROTOR1(1)) ^ 2 + (ROTOR2(2) - ROTOR1(2)) ^ 2);
        
        STATOR1 = [X_STATOR_DATA(SEC, J_STATOR_LE); Y_STATOR_DATA(SEC, J_STATOR_LE)];
        STATOR2 = [X_STATOR_DATA(SEC, J_STATOR_TE); Y_STATOR_DATA(SEC, J_STATOR_TE)];
        STATOR_CHORD(SEC) = sqrt((STATOR2(1) - STATOR1(1)) ^ 2 + (STATOR2(2) - STATOR1(2)) ^ 2);
        
        X_IGV_START = X_IGV_DATA(SEC, J_IGV_LE);
        X_IGV_END   = X_IGV_DATA(SEC, J_IGV_TE);
        X_IGV_AX(SEC)    = X_IGV_END - X_IGV_START;

        X_ROTOR_START = X_ROTOR_DATA(SEC, J_ROTOR_LE);
        X_ROTOR_END   = X_ROTOR_DATA(SEC, J_ROTOR_TE);
        X_ROTOR_AX(SEC)    = X_ROTOR_END - X_ROTOR_START;

        X_STATOR_START = X_STATOR_DATA(SEC, J_STATOR_LE);
        X_STATOR_END   = X_STATOR_DATA(SEC, J_STATOR_TE);
        X_STATOR_AX(SEC)    = X_STATOR_END - X_STATOR_START;
    end
    
    ROTOR_GAP = X_ROTOR_START - X_IGV_END;
    STATOR_GAP = X_STATOR_START - X_ROTOR_END;
    
    STAGGER_IGV = acos(X_IGV_AX ./ IGV_CHORD) .* 180 ./ pi;
    STAGGER_ROTOR = acos(X_ROTOR_AX ./ ROTOR_CHORD) .* 180 ./ pi;
    STAGGER_STATOR = acos(X_STATOR_AX ./ STATOR_CHORD) .* 180 ./ pi;
    
    AR_IGV_CHORD = SPAN ./ IGV_CHORD;
    AR_ROTOR_CHORD = SPAN ./ ROTOR_CHORD;
    AR_STATOR_CHORD = SPAN ./ STATOR_CHORD;
    
    AR_X_IGV_AX = SPAN ./ X_IGV_AX;
    AR_X_ROTOR_AX = SPAN ./ X_ROTOR_AX;
    AR_X_STATOR_AX = SPAN ./ X_STATOR_AX;

    %% Mid-Span Values
    MIDSPAN = (N_SEC - 1) / 2;
    
    MSP_STAGGER_IGV = STAGGER_IGV(MIDSPAN);
    MSP_STAGGER_ROTOR = STAGGER_ROTOR(MIDSPAN);
    MSP_STAGGER_STATOR = STAGGER_STATOR(MIDSPAN);
    
    MSP_IGV_CHORD = IGV_CHORD(MIDSPAN);
    MSP_ROTOR_CHORD = ROTOR_CHORD(MIDSPAN);
    MSP_STATOR_CHORD = STATOR_CHORD(MIDSPAN);
    
    MSP_X_IGV_AX = X_IGV_AX(MIDSPAN);
    MSP_X_ROTOR_AX = X_ROTOR_AX(MIDSPAN);
    MSP_X_STATOR_AX = X_STATOR_AX(MIDSPAN);
    
    MSP_AR_IGV_CHORD = AR_IGV_CHORD(MIDSPAN);
    MSP_AR_ROTOR_CHORD = AR_ROTOR_CHORD(MIDSPAN);
    MSP_AR_STATOR_CHORD = AR_STATOR_CHORD(MIDSPAN);
    
    MSP_AR_X_IGV_AX = AR_X_IGV_AX(MIDSPAN);
    MSP_AR_X_ROTOR_AX = AR_X_ROTOR_AX(MIDSPAN);
    MSP_AR_X_STATOR_AX = AR_X_STATOR_AX(MIDSPAN);
    
    %% Span-Wise Averages
    MIDDLE_Z = zeros(length(SEC_Z) + 1, 1);
    
    for ii = 1:length(MIDDLE_Z)
        if ii == 1
            MIDDLE_Z(ii) = 0;
        elseif ii == length(MIDDLE_Z)
            MIDDLE_Z(ii) = 1;
        else
            MIDDLE_Z(ii) = (SEC_Z(ii) + SEC_Z(ii - 1)) / 2;
        end
    end
    
    SPW_STAGGER_IGV = 0; SPW_STAGGER_ROTOR = 0; SPW_STAGGER_STATOR = 0;
    
    SPW_IGV_CHORD = 0; SPW_ROTOR_CHORD = 0; SPW_STATOR_CHORD = 0;
    
    SPW_X_IGV_AX = 0; SPW_X_ROTOR_AX = 0; SPW_X_STATOR_AX = 0;
    
    SPW_AR_IGV_CHORD = 0; SPW_AR_ROTOR_CHORD = 0; SPW_AR_STATOR_CHORD = 0;
    
    SPW_AR_X_IGV_AX = 0; SPW_AR_X_ROTOR_AX = 0; SPW_AR_X_STATOR_AX = 0;
    
    for ii = 1:N_SEC
        DS = MIDDLE_Z(ii + 1) - MIDDLE_Z(ii);
        
        SPW_STAGGER_IGV = SPW_STAGGER_IGV + STAGGER_IGV(ii) .* DS;
        SPW_STAGGER_ROTOR = SPW_STAGGER_ROTOR + STAGGER_ROTOR(ii) .* DS;
        SPW_STAGGER_STATOR = SPW_STAGGER_STATOR + STAGGER_STATOR(ii) .* DS;
        
        SPW_IGV_CHORD = SPW_IGV_CHORD + IGV_CHORD(ii) .* DS;
        SPW_ROTOR_CHORD = SPW_ROTOR_CHORD + ROTOR_CHORD(ii) .* DS;
        SPW_STATOR_CHORD = SPW_STATOR_CHORD + STATOR_CHORD(ii) .* DS;
        
        SPW_X_IGV_AX = SPW_X_IGV_AX + X_IGV_AX(ii) .* DS;
        SPW_X_ROTOR_AX = SPW_X_ROTOR_AX + X_ROTOR_AX(ii) .* DS;
        SPW_X_STATOR_AX = SPW_X_STATOR_AX + X_STATOR_AX(ii) .* DS;
        
        SPW_AR_IGV_CHORD = SPW_AR_IGV_CHORD + AR_IGV_CHORD(ii) .* DS;
        SPW_AR_ROTOR_CHORD = SPW_AR_ROTOR_CHORD + AR_ROTOR_CHORD(ii) .* DS;
        SPW_AR_STATOR_CHORD = SPW_AR_STATOR_CHORD + AR_STATOR_CHORD(ii) .* DS;
        
        SPW_AR_X_IGV_AX = SPW_AR_X_IGV_AX + AR_X_IGV_AX(ii) .* DS;
        SPW_AR_X_ROTOR_AX = SPW_AR_X_ROTOR_AX + AR_X_ROTOR_AX(ii) .* DS;
        SPW_AR_X_STATOR_AX = SPW_AR_X_STATOR_AX + AR_X_STATOR_AX(ii) .* DS;
    end
    
    %% True Averages
    AVG_IGV_CHORD = mean(IGV_CHORD);
    AVG_ROTOR_CHORD = mean(ROTOR_CHORD);
    AVG_STATOR_CHORD = mean(STATOR_CHORD);
    
    AVG_X_IGV_AX = mean(X_IGV_AX);
    AVG_X_ROTOR_AX = mean(X_ROTOR_AX);
    AVG_X_STATOR_AX = mean(X_STATOR_AX);
    
    AVG_STAGGER_IGV = mean(STAGGER_IGV);
    AVG_STAGGER_ROTOR = mean(STAGGER_ROTOR);
    AVG_STAGGER_STATOR = mean(STAGGER_STATOR);
    
    AVG_AR_IGV_CHORD = mean(AR_IGV_CHORD);
    AVG_AR_ROTOR_CHORD = mean(AR_ROTOR_CHORD);
    AVG_AR_STATOR_CHORD = mean(AR_STATOR_CHORD);
    
    AVG_AR_X_IGV_AX = mean(AR_X_IGV_AX);
    AVG_AR_X_ROTOR_AX = mean(AR_X_ROTOR_AX);
    AVG_AR_X_STATOR_AX = mean(AR_X_STATOR_AX);
    
    %% Calculate Number of Blades
    CIRC_MID = 2 * pi * RMID;
    
    MSP_N_IGV = round(SOLIDITY_IGV * CIRC_MID / MSP_IGV_CHORD, 0);
    MSP_N_ROTOR = round(SOLIDITY_ROTOR * CIRC_MID / MSP_ROTOR_CHORD, 0);
    MSP_N_STATOR = round(SOLIDITY_STATOR * CIRC_MID / MSP_STATOR_CHORD, 0);
    
    SPW_N_IGV = round(SOLIDITY_IGV * CIRC_MID / SPW_IGV_CHORD, 0);
    SPW_N_ROTOR = round(SOLIDITY_ROTOR * CIRC_MID / SPW_ROTOR_CHORD, 0);
    SPW_N_STATOR = round(SOLIDITY_STATOR * CIRC_MID / SPW_STATOR_CHORD, 0);
    
    AVG_N_IGV = round(SOLIDITY_IGV * CIRC_MID / AVG_IGV_CHORD, 0);
    AVG_N_ROTOR = round(SOLIDITY_ROTOR * CIRC_MID / AVG_ROTOR_CHORD, 0);
    AVG_N_STATOR = round(SOLIDITY_STATOR * CIRC_MID / AVG_STATOR_CHORD, 0);
    
    %% Print Output
    fprintf('RTip: %.4f m\tRHub: %.4f m\tRMid: %.4f m\tSpan: %.3f m\tHub-to-Tip Ratio: %.3f\n', RTIP, RHUB, RMID, SPAN, HUB_TIP_RATIO);
    fprintf('Gap IGV - Rotor: %.4f m\tGap Rotor - Stator: %.4f m\n\n', ROTOR_GAP, STATOR_GAP);
    
    fprintf('Mid-Span Approach:\n');
    fprintf('IGV    Blades: %.0f\tIGV    Chord: %.4f m\tIGV    Axial Chord: %.4f m\tIGV    Stagger: %.3f deg\tIGV    AR: %.3f\tIGV    AR(AX): %.3f\n', MSP_N_IGV, MSP_IGV_CHORD, MSP_X_IGV_AX, MSP_STAGGER_IGV, MSP_AR_IGV_CHORD, MSP_AR_X_IGV_AX);
    fprintf('ROTOR  Blades: %.0f\tROTOR  Chord: %.4f m\tROTOR  Axial Chord: %.4f m\tROTOR  Stagger: %.3f deg\tROTOR  AR: %.3f\tROTOR  AR(AX): %.3f\n', MSP_N_ROTOR, MSP_ROTOR_CHORD, MSP_X_ROTOR_AX, MSP_STAGGER_ROTOR, MSP_AR_ROTOR_CHORD, MSP_AR_X_ROTOR_AX);
    fprintf('STATOR Blades: %.0f\tSTATOR Chord: %.4f m\tSTATOR Axial Chord: %.4f m\tSTATOR Stagger: %.3f deg\tSTATOR AR: %.3f\tSTATOR AR(AX): %.3f\n\n', MSP_N_STATOR, MSP_STATOR_CHORD, MSP_X_STATOR_AX, MSP_STAGGER_STATOR, MSP_AR_STATOR_CHORD, MSP_AR_X_STATOR_AX);
    
    fprintf('Span-Wise Average Approach:\n');
    fprintf('IGV    Blades: %.0f\tIGV    Chord: %.4f m\tIGV    Axial Chord: %.4f m\tIGV    Stagger: %.3f deg\tIGV    AR: %.3f\tIGV    AR(AX): %.3f\n', SPW_N_IGV, SPW_IGV_CHORD, SPW_X_IGV_AX, SPW_STAGGER_IGV, SPW_AR_IGV_CHORD, SPW_AR_X_IGV_AX);
    fprintf('ROTOR  Blades: %.0f\tROTOR  Chord: %.4f m\tROTOR  Axial Chord: %.4f m\tROTOR  Stagger: %.3f deg\tROTOR  AR: %.3f\tROTOR  AR(AX): %.3f\n', SPW_N_ROTOR, SPW_ROTOR_CHORD, SPW_X_ROTOR_AX, SPW_STAGGER_ROTOR, SPW_AR_ROTOR_CHORD, SPW_AR_X_ROTOR_AX);
    fprintf('STATOR Blades: %.0f\tSTATOR Chord: %.4f m\tSTATOR Axial Chord: %.4f m\tSTATOR Stagger: %.3f deg\tSTATOR AR: %.3f\tSTATOR AR(AX): %.3f\n\n', SPW_N_STATOR, SPW_STATOR_CHORD, SPW_X_STATOR_AX, SPW_STAGGER_STATOR, SPW_AR_STATOR_CHORD, SPW_AR_X_STATOR_AX);
    
    fprintf('True Average Approach:\n');
    fprintf('IGV    Blades: %.0f\tIGV    Chord: %.4f m\tIGV    Axial Chord: %.4f m\tIGV    Stagger: %.3f deg\tIGV    AR: %.3f\tIGV    AR(AX): %.3f\n', AVG_N_IGV, AVG_IGV_CHORD, AVG_X_IGV_AX, AVG_STAGGER_IGV, AVG_AR_IGV_CHORD, AVG_AR_X_IGV_AX);
    fprintf('ROTOR  Blades: %.0f\tROTOR  Chord: %.4f m\tROTOR  Axial Chord: %.4f m\tROTOR  Stagger: %.3f deg\tROTOR  AR: %.3f\tROTOR  AR(AX): %.3f\n', AVG_N_ROTOR, AVG_ROTOR_CHORD, AVG_X_ROTOR_AX, AVG_STAGGER_ROTOR, AVG_AR_ROTOR_CHORD, AVG_AR_X_ROTOR_AX);
    fprintf('STATOR Blades: %.0f\tSTATOR Chord: %.4f m\tSTATOR Axial Chord: %.4f m\tSTATOR Stagger: %.3f deg\tSTATOR AR: %.3f\tSTATOR AR(AX): %.3f\n', AVG_N_STATOR, AVG_STATOR_CHORD, AVG_X_STATOR_AX, AVG_STAGGER_STATOR, AVG_AR_STATOR_CHORD, AVG_AR_X_STATOR_AX);
    
    %% Z Coordinates
    Z = RHUB + SEC_Z .* SPAN;
    Z_IGV    = repmat(Z, 1, J_IGV_TE - J_IGV_LE + 1);
    Z_ROTOR  = repmat(Z, 1, J_ROTOR_TE - J_ROTOR_LE + 1);
    Z_STATOR = repmat(Z, 1, J_STATOR_TE - J_STATOR_LE + 1);
    
    %% Return Data
    Igv = {repmat(X_IGV_DATA(:, J_IGV_LE:J_IGV_TE), 3, 1), 
        [Y_IGV_DATA(:, J_IGV_LE:J_IGV_TE) - TK_IGV_DATA(:, J_IGV_LE:J_IGV_TE);
        Y_IGV_DATA(:, J_IGV_LE:J_IGV_TE) - 0.5 .* TK_IGV_DATA(:, J_IGV_LE:J_IGV_TE);
        Y_IGV_DATA(:, J_IGV_LE:J_IGV_TE)], 
        repmat(Z_IGV(:, :), 3, 1)};
    
     Rotor = {repmat(X_ROTOR_DATA(:, J_ROTOR_LE:J_ROTOR_TE), 3, 1), 
        [Y_ROTOR_DATA(:, J_ROTOR_LE:J_ROTOR_TE) - TK_ROTOR_DATA(:, J_ROTOR_LE:J_ROTOR_TE);
        Y_ROTOR_DATA(:, J_ROTOR_LE:J_ROTOR_TE) - 0.5 .* TK_ROTOR_DATA(:, J_ROTOR_LE:J_ROTOR_TE);
        Y_ROTOR_DATA(:, J_ROTOR_LE:J_ROTOR_TE)], 
        repmat(Z_ROTOR(:, :), 3, 1)};
     
     Stator = {repmat(X_STATOR_DATA(:, J_STATOR_LE:J_STATOR_TE), 3, 1), 
        [Y_STATOR_DATA(:, J_STATOR_LE:J_STATOR_TE) - TK_STATOR_DATA(:, J_STATOR_LE:J_STATOR_TE);
        Y_STATOR_DATA(:, J_STATOR_LE:J_STATOR_TE) - 0.5 .* TK_STATOR_DATA(:, J_STATOR_LE:J_STATOR_TE);
        Y_STATOR_DATA(:, J_STATOR_LE:J_STATOR_TE)], 
        repmat(Z_STATOR(:, :), 3, 1)};
    
    Chords = [IGV_CHORD'; ROTOR_CHORD'; STATOR_CHORD'];
     
    AxChords = [X_IGV_AX'; X_ROTOR_AX'; X_STATOR_AX'];
    
    Staggers = [STAGGER_IGV'; STAGGER_ROTOR'; STAGGER_STATOR'];
    
    ARs = [AR_IGV_CHORD'; AR_ROTOR_CHORD'; AR_STATOR_CHORD'];
    
    ARXs = [AR_X_IGV_AX'; AR_X_ROTOR_AX'; AR_X_STATOR_AX'];
    
    Gaps = [ROTOR_GAP; STATOR_GAP];
    
    MidSpan = [MSP_N_IGV, MSP_IGV_CHORD, MSP_X_IGV_AX, MSP_STAGGER_IGV, MSP_AR_IGV_CHORD, MSP_AR_X_IGV_AX;
        MSP_N_ROTOR, MSP_ROTOR_CHORD, MSP_X_ROTOR_AX, MSP_STAGGER_ROTOR, MSP_AR_ROTOR_CHORD, MSP_AR_X_ROTOR_AX;
        MSP_N_STATOR, MSP_STATOR_CHORD, MSP_X_STATOR_AX, MSP_STAGGER_STATOR, MSP_AR_STATOR_CHORD, MSP_AR_X_STATOR_AX;    
    ];

    SpanWise = [SPW_N_IGV, SPW_IGV_CHORD, SPW_X_IGV_AX, SPW_STAGGER_IGV, SPW_AR_IGV_CHORD, SPW_AR_X_IGV_AX;
        SPW_N_ROTOR, SPW_ROTOR_CHORD, SPW_X_ROTOR_AX, SPW_STAGGER_ROTOR, SPW_AR_ROTOR_CHORD, SPW_AR_X_ROTOR_AX;
        SPW_N_STATOR, SPW_STATOR_CHORD, SPW_X_STATOR_AX, SPW_STAGGER_STATOR, SPW_AR_STATOR_CHORD, SPW_AR_X_STATOR_AX;
    ];

    Average = [AVG_N_IGV, AVG_IGV_CHORD, AVG_X_IGV_AX, AVG_STAGGER_IGV, AVG_AR_IGV_CHORD, AVG_AR_X_IGV_AX;
        AVG_N_ROTOR, AVG_ROTOR_CHORD, AVG_X_ROTOR_AX, AVG_STAGGER_ROTOR, AVG_AR_ROTOR_CHORD, AVG_AR_X_ROTOR_AX;
        AVG_N_STATOR, AVG_STATOR_CHORD, AVG_X_STATOR_AX, AVG_STAGGER_STATOR, AVG_AR_STATOR_CHORD, AVG_AR_X_STATOR_AX;
        ];
end