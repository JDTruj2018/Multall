function JDT_WRITE_BLADE_COORDINATES(Igv, Rotor, Stator, N_SEC, scaleflag, RPM)

    if scaleflag == 1 && nargin <= 5
        if ~exist('Geometry', 'dir')
            mkdir('Geometry');
        end
        fIGV = fopen('Geometry/igv.csv', 'w');
        fROTOR = fopen('Geometry/rotor.csv', 'w');
        fSTATOR = fopen('Geometry/stator.csv', 'w');
        
    elseif scaleflag == 2 && nargin == 6
        if ~exist(['Geometry-', num2str(RPM)], 'dir')
            mkdir(['Geometry-', num2str(RPM)]);
        end
        
        fIGV = fopen(['Geometry-', num2str(RPM), '/igv-scaled.csv'], 'w');
        fROTOR = fopen(['Geometry-', num2str(RPM), '/rotor-scaled.csv'], 'w');
        fSTATOR = fopen(['Geometry-', num2str(RPM), '/stator-scaled.csv'], 'w');
        
    else
        fprintf('Error: Invalid Scale Flag');
        
    end
    
    HEADER = {'SECTION', 'X', 'Y', 'Z'};
    
    headerFmt = '%s,%s,%s,%s';
    numFmt = '%.0f,%.4f,%.4f,%.4f';
    
    fprintf(fIGV, [headerFmt, '\n'], HEADER{1}, HEADER{2}, HEADER{3}, HEADER{4});
    fprintf(fROTOR, [headerFmt, '\n'], HEADER{1}, HEADER{2}, HEADER{3}, HEADER{4});
    fprintf(fSTATOR, [headerFmt, '\n'], HEADER{1}, HEADER{2}, HEADER{3}, HEADER{4});
    
    for ii = 1:N_SEC 
        inx = (ii - 1) * 3 + 1;
        
        for jj = 1:size(Igv{1}, 2)
            fprintf(fIGV, [numFmt, '\n'], ii, Igv{1}(inx, jj), Igv{2}(inx + 1, jj), Igv{3}(inx + 1, jj));
            fprintf(fROTOR, [numFmt, '\n'], ii, Rotor{1}(inx, jj), Rotor{2}(inx + 1, jj), Rotor{3}(inx + 1, jj));
            fprintf(fSTATOR, [numFmt, '\n'], ii, Stator{1}(inx, jj), Stator{2}(inx + 1, jj), Stator{3}(inx + 1, jj));
        end
        
    end
    
    fclose(fIGV);
    fclose(fROTOR);
    fclose(fSTATOR);
end