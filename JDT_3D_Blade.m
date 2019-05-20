clearvars;
close all;
clc;

IGV_SUCTION = '3D_Geometry/IGV_Suction.dat';
IGV_PRESSURE = '3D_Geometry/IGV_Pressure.dat';

ROTOR_SUCTION = '3D_Geometry/ROTOR_Suction.dat';
ROTOR_PRESSURE = '3D_Geometry/ROTOR_Pressure.dat';

STATOR_SUCTION = '3D_Geometry/STATOR_Suction.dat';
STATOR_PRESSURE = '3D_Geometry/STATOR_Pressure.dat';

LIST = {IGV_SUCTION, ROTOR_SUCTION, STATOR_SUCTION, IGV_PRESSURE, ROTOR_PRESSURE, STATOR_PRESSURE};

delimiterIn = ' ';

figure(1)
hold on;

for ii = 1:length(LIST)
    RAW_INPUT = importdata(LIST{ii}, delimiterIn);
    Data = RAW_INPUT.data';
    
    X = Data(:, 1:size(Data, 2) / 3);
    X = X(:);
    
    Y = Data(:, size(Data, 2) / 3 + 1:2*size(Data, 2) / 3);
    Y = Y(:);
    
    Z = Data(:, 2*size(Data, 2) / 3 + 1:3*size(Data, 2) / 3);
    Z = Z(:);
    
    plot3(X, Y, Z, 'o');
    
end