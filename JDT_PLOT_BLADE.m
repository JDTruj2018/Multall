function JDT_PLOT_BLADE(Igv, Rotor, Stator, N_SEC, RPM)
    %% Plotting Section Profiles
    fBlades = figure('Name', 'Blade Geometry', 'NumberTitle', 'off');
    figure(fBlades);
    for SEC = 1:N_SEC
        hold on;
        inx = (SEC - 1) * 3 + 1;
        
        plot3(Igv{1}(inx, :),     Igv{2}(inx, :),     Igv{3}(inx, :));
        plot3(Igv{1}(inx + 1, :), Igv{2}(inx + 1, :), Igv{3}(inx + 1, :));
        plot3(Igv{1}(inx + 2, :), Igv{2}(inx + 2, :), Igv{3}(inx + 2, :));
        
        plot3(Rotor{1}(inx, :),     Rotor{2}(inx, :),     Rotor{3}(inx, :));
        plot3(Rotor{1}(inx + 1, :), Rotor{2}(inx + 1, :), Rotor{3}(inx + 1, :));
        plot3(Rotor{1}(inx + 2, :), Rotor{2}(inx + 2, :), Rotor{3}(inx + 2, :));
        
        plot3(Stator{1}(inx, :),     Stator{2}(inx, :),     Stator{3}(inx, :));
        plot3(Stator{1}(inx + 1, :), Stator{2}(inx + 1, :), Stator{3}(inx + 1, :));
        plot3(Stator{1}(inx + 2, :), Stator{2}(inx + 2, :), Stator{3}(inx + 2, :));

        xlabel('x'); ylabel('y'); zlabel('z');
    end
    
    if ~exist('Figures', 'dir')
        mkdir('Figures');
    end
    
    if nargin == 4
        saveas(fBlades, 'Figures/Small-Core-Model.fig')
    elseif nargin == 5
        saveas(fBlades, ['Figures/Scaled-RPM-', num2str(RPM), '.fig'])
    end
    
    close(fBlades);
end