function [] = phaseDiagramTVL()
%% (0) Request user input through GUI
    promptCell = {'Component 1', 'Component 2', 'Pressure [mmHg]'};
    userInfoCell = inputdlg(promptCell, 'phaseDiagramTVL Inputs', [1 1 1]);
    fields = {'c1', 'c2', 'p'};
    userInfoStruct = cell2struct(userInfoCell, fields);
    comp1 = userInfoStruct.c1;
    comp2 = userInfoStruct.c2;
    P = str2double(userInfoStruct.p);
%% (1) Initialize variables and arrays
    components = readvars('antoinesCoefficients.xlsx', 'Range', 'A2:A147');
    [matA, matB, matC] = readvars('antoinesCoefficients.xlsx', 'Range', 'B2:D147');
    A1 = 0; B1 = 0; C1 = 0;
    A2 = 0; B2 = 0; C2 = 0;
    found1 = false; found2 = false;
    numPts = 100;
    liqFract1 = zeros(1, numPts); liqFract2 = zeros(1, numPts);
    vapFract1 = zeros(1, numPts); vapFract2 = zeros(1, numPts);
%% (2) Linear search for comp1 and comp2
    for i = 1:length(components)
        if ~found1 && strcmpi(comp1,components(i))
            A1 = matA(i);
            B1 = matB(i);
            C1 = matC(i);
            found1 = true;
        end 
        if ~found2 && strcmpi(comp2,components(i))
            A2 = matA(i);
            B2 = matB(i);
            C2 = matC(i);
            found2 = true;
        end
    end
 %% (3) Error handling of non-existent components
    if ~found1 || ~found2
        if ~found1 && found2
            msgbox("Component 1 not found.", "Error");
        elseif ~found2 && found1
            msgbox("Component 2 not found.", "Error");
        else
            msgbox("Component 1 and Component 2 not found.", "Error");
        end
        disp("Quitting program...");
        return;
    end
 %% (4) Calculation of saturation temperature @P (user-input)
    tSat1 = (B1 / (A1 - log10(P))) - C1;
    tSat2 = (B2 / (A2 - log10(P))) - C2;
 %% (5) Calculation of vapor/liquid fractions @each linearly spaced temp.
    temps = linspace(tSat1, tSat2, numPts);
    for i = 1:numPts
        currentTemp = temps(i);
        % calculation of saturation pressure at a given currentTemp
        pSat1 = 10^(A1 - (B1 / (currentTemp + C1)));
        pSat2 = 10^(A2 - (B2 / (currentTemp + C2)));
        % Rearrangement of bubble point pressure eq to solve for liquid
        % mole fraction
        liqFract1(i) = (P - pSat2) / (pSat1 - pSat2);
        liqFract2(i) = 1 - liqFract1(i);
        % Rearrangement of Raoult's Law to solve for vapor mole fraction
        vapFract1(i) = (liqFract1(i)*pSat1) / P;
        vapFract2(i) = 1 - vapFract1(i);
    end
 %% (6) Creation of phase diagram
    figureDesc = "T vs. XY Phase Diagram of a " + comp1 + " + " + comp2 + " mixture @P = " + P + " mmHg";
    figure('Name', figureDesc)
    plot(liqFract1, temps)
    hold on
    plot(vapFract1, temps)
    title(figureDesc)
    ylabel('Temperature T [�C]')
    xlabel("x " + comp1 + ", y " + comp1 + " [mol/mol]")
    xlim([0, 1])
    grid on
    grid minor
    return;
end