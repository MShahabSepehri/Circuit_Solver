function [] = Circuit_solver(address, R_address)
    
    syms s t
    
    nElements = 0; %Number of passive elements
    nV = 0; %independent voltage sources
    nElements = 0; %independent current sources
    nNodes = 0; %nodes
    nVSVC = 0; %voltage controlled voltage sources
    nVSCC = 0; %voltage controlled current sources
    nCSVC = 0; %current controlled voltage sources
    nCSCC = 0; %current controlled current sources
    nL = 0; %inductors
    new_variables = 0;
    new_variables_eqns = 0;
    
    fileID = fopen(address,'r');
    
    data = textscan(fileID, '%s %s %s %s %s');


    for i=1:length(data{1})
        Element = data{1}{i};
        switch(Element(1))
            case{'L','V','VSCC','VSVC'}
                new_variables = new_variables + 1;
            case{'ML'}%mutual inductor
                new_variables = new_variables + 2;
        end
        nNodes = max(str2num(data{3}{(i)}),str2num(data{3}{(i)})) + 1;%finding number of nodes
    end%finding how many variables we need
    
    A = zeros(nNodes + new_variables)*s;%factors' matrix
    B = zeros(nNodes + new_variables,1)*s;%A*(variables' matrix) = B
    dlength = length(data{1});


    for i=1:dlength
        Element = data{1}{i};
        
        switch(Element(1))
            case{'R'}
                nElements = nElements + 1;
                dElement(nElements).Type = data{1}{i};
                dElement(nElements).Name = data{2}{i};
                dElement(nElements).Node1 = str2num(data{3}{i}) + 1;%we dont use str2double because we expect an integer
                dElement(nElements).Node2 = str2num(data{4}{i}) + 1;
                dElement(nElements).Value = str2double(data{5}{i});
                A(dElement(nElements).Node1,dElement(nElements).Node2) = A(dElement(nElements).Node1,dElement(nElements).Node2) - 1./dElement(nElements).Value;
                A(dElement(nElements).Node2,dElement(nElements).Node1) = A(dElement(nElements).Node2,dElement(nElements).Node1) - 1./dElement(nElements).Value;
                A(dElement(nElements).Node1,dElement(nElements).Node1) = A(dElement(nElements).Node1,dElement(nElements).Node1) + 1./dElement(nElements).Value;
                A(dElement(nElements).Node2,dElement(nElements).Node2) = A(dElement(nElements).Node2,dElement(nElements).Node2) + 1./dElement(nElements).Value;
            case{'C'}
                nElements = nElements + 1;
                dElement(nElements).Type = data{1}{i};
                dElement(nElements).Name = data{2}{i};
                dElement(nElements).Node1 = str2num(data{3}{i}) + 1;%we dont use str2double because we expect an integer
                dElement(nElements).Node2 = str2num(data{4}{i}) + 1;
                dElement(nElements).Value = str2double(data{5}{i});
                A(dElement(nElements).Node1,dElement(nElements).Node2) = A(dElement(nElements).Node1,dElement(nElements).Node2) - dElement(nElements).Value.*s;
                A(dElement(nElements).Node2,dElement(nElements).Node1) = A(dElement(nElements).Node2,dElement(nElements).Node1) - dElement(nElements).Value.*s;
                A(dElement(nElements).Node1,dElement(nElements).Node1) = A(dElement(nElements).Node1,dElement(nElements).Node1) + dElement(nElements).Value.*s;
                A(dElement(nElements).Node2,dElement(nElements).Node2) = A(dElement(nElements).Node2,dElement(nElements).Node2) + dElement(nElements).Value.*s;
            case{'L'}
                nElements = nElements + 1;
                dElement(nElements).Type = data{1}{i};
                new_variables_eqns = new_variables_eqns + 1;
                dElement(nElements).Name = data{2}{i};
                dElement(nElements).Node1 = str2num(data{3}{i}) + 1;
                dElement(nElements).Node2 = str2num(data{4}{i}) + 1;
                dElement(nElements).Value = str2double(data{5}{i});
                dElement(nElements).new_variables = new_variables_eqns;%to knew wich parameter in matrix is this eleman's current
                A(dElement(nElements).Node1,nNodes + new_variables_eqns) = A(dElement(nElements).Node1,nNodes + new_variables_eqns) + 1;
                A(dElement(nElements).Node2,nNodes + new_variables_eqns) = A(dElement(nElements).Node2,nNodes + new_variables_eqns) - 1;
                %adding new equasion
                A(nNodes + new_variables_eqns,dElement(nElements).Node1) = -s;
                A(nNodes + new_variables_eqns,dElement(nElements).Node2) = s;
                A(nNodes + new_variables_eqns,nNodes + new_variables_eqns) = 1;
            case{'V'}%independent voltage source
                syms V(s)
                nElements = nElements + 1;
                new_variables_eqns = new_variables_eqns + 1;
                dElement(nElements).Type = data{1}{i};
                dElement(nElements).Name = data{2}{i};
                dElement(nElements).Node1 = str2num(data{3}{i}) + 1;
                dElement(nElements).Node2 = str2num(data{4}{i}) + 1;
                dElement(nElements).Value = eval('@t',data{5}{i});
                dElement(nElements).new_variables = new_variables_eqns;
                V(s) = dElement(nElements).Value;
                B(nNodes + new_variables_eqns) = laplace(V,s);
                A(dElement(nElements).Node1,nNodes + new_variables_eqns) = A(dElement(nElements).Node1,nNodes + new_variables_eqns) + 1;
                A(dElement(nElements).Node2,nNodes + new_variables_eqns) = A(dElement(nElements).Node2,nNodes + new_variables_eqns) - 1;
                %adding new equasion
                A(nNodes + new_variables_eqns,dElement(nElements).Node1) = 1;
                A(nNodes + new_variables_eqns,dElement(nElements).Node2) = -1;
            case{'I'}%independent current source
                syms I(s)
                nElements = nElements + 1;
                dElement(nElements).Type = data{1}{i};
                dElement(nElements).Name = data{2}{i};
                dElement(nElements).Node1 = str2num(data{3}{i}) + 1;
                dElement(nElements).Node2 = eval('@t',data{4}{i}) + 1;
                dElement(nElements).Value = str2double(data{5}{i});
                I(s) = dElement(nElements).Value;
                B(dElement(nElements).Node1) = B(dElement(nElements).Node1) - laplace(I,s);
                B(dElement(nElements).Node2) = B(dElement(nElements).Node2) + laplace(I,s);
            case{'ML'}%mutual inductor
                nElements = nElements + 1;
                new_variables_eqns = new_variables_eqns + 2;
                dElement(nElements).Type = data{1}{i};
                dElement(nElements).Name = data{2}{i};
                dElement(nElements).Node1 = str2num(data{3}{i}) + 1;
                dElement(nElements).Node2 = str2num(data{4}{i}) + 1;
                dElement(nElements).Node3 = str2num(data{5}{i}) + 1;
                dElement(nElements).Node4 = str2num(data{6}{i}) + 1;
                dElement(nElements).L11 = str2double(data{7}{i});
                dElement(nElements).L12 = str2double(data{8}{i});
                dElement(nElements).L21 = str2double(data{9}{i});
                dElement(nElements).L22 = str2double(data{10}{i});
                dElement(nElements).new_variables = new_variables_eqns;
                L = [dElement(nElements).L11.*s,dElement(nElements).L12.*s;dElement(nElements).L21.*s,dElement(nElements).L22.*s];
                Q = inv(L);
                A(dElement(nElements).Node1,nNodes + new_variables_eqns - 1) = A(dElement(nElements).Node1,nNodes + new_variables_eqns - 1) + 1;
                A(dElement(nElements).Node2,nNodes + new_variables_eqns - 1) = A(dElement(nElements).Node2,nNodes + new_variables_eqns - 1) - 1;
                A(dElement(nElements).Node3,nNodes + new_variables_eqns) = A(dElement(nElements).Node3,nNodes + new_variables_eqns) + 1;
                A(dElement(nElements).Node4,nNodes + new_variables_eqns) = A(dElement(nElements).Node4,nNodes + new_variables_eqns) - 1;
                %adding new equasion
                A(nNodes + new_variables_eqns - 1,dElement(nElements).Node1) = Q(1);
                A(nNodes + new_variables_eqns - 1,dElement(nElements).Node2) = -Q(1);
                A(nNodes + new_variables_eqns - 1,dElement(nElements).Node3) = Q(2);
                A(nNodes + new_variables_eqns - 1,dElement(nElements).Node4) = -Q(2);
                A(nNodes + new_variables_eqns,dElement(nElements).Node1) = Q(3);
                A(nNodes + new_variables_eqns,dElement(nElements).Node2) = -Q(3);
                A(nNodes + new_variables_eqns,dElement(nElements).Node3) = Q(4);
                A(nNodes + new_variables_eqns,dElement(nElements).Node4) = -Q(4);
            case{'VSVC'}%voltage controlled voltage sources
                nElements = nElements + 1;
                new_variables_eqns = new_variables_eqns + 1;
                dElement(nElements).Type = data{1}{i};
                dElement(nElements).Name = data{2}{i};
                dElement(nElements).Node1 = str2num(data{3}{i}) + 1;
                dElement(nElements).Node2 = str2num(data{4}{i}) + 1;%next two lines are about the voltage that control the source
                dElement(nElements).Node3 = str2num(data{5}{i}) + 1;
                dElement(nElements).Node4 = str2num(data{6}{i}) + 1;
                dElement(nElements).Gain = str2double(data{7}{i});
                dElement(nElements).new_variables = new_variables_eqns;
                A(dElement(nElements).Node1,nNodes + new_variables_eqns) = A(dElement(nElements).Node1,nNodes + new_variables_eqns) - 1;
                A(dElement(nElements).Node2,nNodes + new_variables_eqns) = A(dElement(nElements).Node2,nNodes + new_variables_eqns) + 1;
                %adding new equasion
                A(nNodes + new_variables_eqns,dElement(nElements).Node1) = 1;
                A(nNodes + new_variables_eqns,dElement(nElements).Node2) = -1;
                A(nNodes + new_variables_eqns,dElement(nElements).Node3) = -dElement(nElements).Gain;
                A(nNodes + new_variables_eqns,dElement(nElements).Node4) = dElement(nElements).Gain;
            case{'CSVC'}%voltage controlled current sources
                nElements = nElements + 1;
                dElement(nElements).Type = data{1}{i};
                dElement(nElements).Name = data{2}{i};
                dElement(nElements).Node1 = str2num(data{3}{i}) + 1;
                dElement(nElements).Node2 = str2num(data{4}{i}) + 1;%next two lines are about the voltage that control the source
                dElement(nElements).Node3 = str2num(data{5}{i}) + 1;
                dElement(nElements).Node4 = str2num(data{6}{i}) + 1;
                dElement(nElements).Gain = str2double(data{7}{i});
                A(dElement(nElements).Node1,dElement(nElements).Node3) = A(dElement(nElements).Node1,dElement(nElements).Node3) + dElement(nElements).Gain;
                A(dElement(nElements).Node1,dElement(nElements).Node4) = A(dElement(nElements).Node1,dElement(nElements).Node4) - dElement(nElements).Gain;
                A(dElement(nElements).Node2,dElement(nElements).Node3) = A(dElement(nElements).Node2,dElement(nElements).Node3) - dElement(nElements).Gain;
                A(dElement(nElements).Node2,dElement(nElements).Node4) = A(dElement(nElements).Node2,dElement(nElements).Node4) + dElement(nElements).Gain;
%for last two elements we just set an equatoin of VSCC's current in this loop 
            case{'VSCC'}%current controlled voltage sources
                nElements = nElements + 1;
                new_variables_eqns = new_variables_eqns + 1;
                dElement(nElements).Type = data{1}{i};
                dElement(nElements).Name = data{2}{i};
                dElement(nElements).Node1 = str2num(data{3}{i}) + 1;
                dElement(nElements).Node2 = str2num(data{4}{i}) + 1;%next line are about the current that control the source
                dElement(nElements).Branch = str2num(data{5}{i});%branch that control the source
                dElement(nElements).Gain = str2double(data{7}{i});
                dElement(nElements).new_variables = new_variables_eqns;
                A(dElement(nElements).Node1,nNodes + new_variables_eqns) = A(dElement(nElements).Node1,nNodes + new_variables_eqns) + 1;
                A(dElement(nElements).Node2,nNodes + new_variables_eqns) = A(dElement(nElements).Node2,nNodes + new_variables_eqns) - 1;
                if(dElement(nElements).Branch == 'ML')
                    dElement(nElements).ml = str2num(data{8}{i});%determinaning which branch of mutual inductore
                end
            case{'CSCC'}%current controlled current sources
                nElements = nElements + 1;
                dElement(nElements).Type = data{1}{i};
                dElement(nElements).Name = data{2}{i};
                dElement(nElements).Node1 = str2num(data{3}{i}) + 1;
                dElement(nElements).Node2 = str2num(data{4}{i}) + 1;%next line are about the current that control the source
                dElement(nElements).Branch = str2num(data{5}{i});
                dElement(nElements).Gain = str2double(data{7}{i});
                if(dElement(nElements).Branch == 'ML')
                    dElement(nElements).ml = str2num(data{8}{i});%determinaning which branch of mutual inductore
                end
        end
    end
    
    for i=1:dlength%setting remaining equation for last two elements
        Element = data{1}{i};
        nElements = nElements + 1;
        switch(Element(1))
            case{'CSCC'}
                switch(dElement(dElement(nElements).Branch).Name)
                    case{'R'}
                    A(dElement(nElements).Node1,dElement(dElement(nElements).Branch).Node1) = A(dElement(nElements).Node1,dElement(dElement(nElements).Branch).Node1) + dElement(nElements).Gain./(dElement(dElement(nElements).Branch).Value);
                    A(dElement(nElements).Node1,dElement(dElement(nElements).Branch).Node2) = A(dElement(nElements).Node1,dElement(dElement(nElements).Branch).Node2) - dElement(nElements).Gain./(dElement(dElement(nElements).Branch).Value);
                    A(dElement(nElements).Node2,dElement(dElement(nElements).Branch).Node1) = A(dElement(nElements).Node2,dElement(dElement(nElements).Branch).Node1) - dElement(nElements).Gain./(dElement(dElement(nElements).Branch).Value);
                    A(dElement(nElements).Node2,dElement(dElement(nElements).Branch).Node2) = A(dElement(nElements).Node2,dElement(dElement(nElements).Branch).Node2) + dElement(nElements).Gain./(dElement(dElement(nElements).Branch).Value);
                    case{'C'}
                    A(dElement(nElements).Node1,dElement(dElement(nElements).Branch).Node1) = A(dElement(nElements).Node1,dElement(dElement(nElements).Branch).Node1) + dElement(nElements).Gain.*(dElement(dElement(nElements).Branch).Value).*s;
                    A(dElement(nElements).Node1,dElement(dElement(nElements).Branch).Node2) = A(dElement(nElements).Node1,dElement(dElement(nElements).Branch).Node2) - dElement(nElements).Gain.*(dElement(dElement(nElements).Branch).Value).*s;
                    A(dElement(nElements).Node2,dElement(dElement(nElements).Branch).Node1) = A(dElement(nElements).Node2,dElement(dElement(nElements).Branch).Node1) - dElement(nElements).Gain.*(dElement(dElement(nElements).Branch).Value).*s;
                    A(dElement(nElements).Node2,dElement(dElement(nElements).Branch).Node2) = A(dElement(nElements).Node2,dElement(dElement(nElements).Branch).Node2) + dElement(nElements).Gain.*(dElement(dElement(nElements).Branch).Value).*s;
                    case{'V','L'}
                        A(dElement(nElements).Node1,nNodes + dElement(dElement(nElements).Branch).new_variables) = A(dElement(nElements).Node1,nNodes + dElement(dElement(nElements).Branch).new_variables) + dElement(nElements).Gain;
                        A(dElement(nElements).Node2,nNodes + dElement(dElement(nElements).Branch).new_variables) = A(dElement(nElements).Node2,nNodes + dElement(dElement(nElements).Branch).new_variables) + dElement(nElements).Gain;
                    case{'ML'}
                        switch(dElement(nElements).ml)
                            case{1}
                                Cur = dElement(dElement(nElements).Branch).new_variables - 1;
                            case{2}
                                Cur = dElement(dElement(nElements).Branch).new_variables;
                        end
                        A(dElement(nElements).Node1,nNodes + Cur) = A(dElement(nElements).Node1,nNodes + Cur) + dElement(nElements).Gain;
                        A(dElement(nElements).Node2,nNodes + Cur) = A(dElement(nElements).Node2,nNodes + Cur) - dElement(nElements).Gain;
                end
            case{'VSCC'}
                A(nNodes + new_variables_eqns,dElement(nElements).Node1) = 1;
                A(nNodes + new_variables_eqns,dElement(nElements).Node2) = -1;
                switch(dElement(dElement(nElements).Branch).Name)
                    case{'R'}
                        A(nNodes + dElement(nElements).new_variables,(dElement(dElement(nElements).Branch).Node1)) = -dElement(nElements).Gain./(dElement(dElement(nElements).Branch).Value);
                        A(nNodes + dElement(nElements).new_variables,(dElement(dElement(nElements).Branch).Node2)) = +dElement(nElements).Gain./(dElement(dElement(nElements).Branch).Value);
                    case{'C'}
                        A(nNodes + dElement(nElements).new_variables,(dElement(dElement(nElements).Branch).Node1)) = -dElement(nElements).Gain.*(dElement(dElement(nElements).Branch).Value).*s;
                        A(nNodes + dElement(nElements).new_variables,(dElement(dElement(nElements).Branch).Node2)) = +dElement(nElements).Gain.*(dElement(dElement(nElements).Branch).Value).*s;
                    case{'V','L'}
                        A(nNodes + dElement(nElements).new_variables,nNodes + dElement(dElement(nElements).Branch).new_variables) = -dElement(nElements).Gain;
                    case{'ML'}
                        switch(dElement(nElements).ml)
                            case{1}
                                A(nNodes + dElement(nElements).new_variables,nNodes + dElement(dElement(nElements).Branch).new_variables - 1) = -dElement(nElements).Gain;
                            case{2}
                                A(nNodes + dElement(nElements).new_variables,nNodes + dElement(dElement(nElements).Branch).new_variables) = -dElement(nElements).Gain;
                        end
                end
        end
    end
    
    fclose(fileID);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    SA = A(2:end,2:end);
    SB = B(2:end);%deleting ground
    Sol = (inv(SA))*SB;
    CSol = zeros(nNodes + new_variables,1).*s;
    CSol(1) = 0;
    CSol(2:end,1) = Sol;%%adding ground
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fileID = fopen(R_address,'w');
    printer = 0;
    for i=1:dlength
        printer = printer + 1;
        name = (dElement(i).Name);
        switch(dElement(i).Type)
            case{'R'}
                syms V(s) I(s)
                V(s) = CSol(dElement(i).Node1) - CSol(dElement(i).Node2);
                voltage(t) = ilaplace(V,t);
                current(t) = voltage./(dElement(i).Value);
                power = voltage.*current;
                fprintf(fileID,'%s\r\t%s\r\t%s\r\t%s\r\n',name,voltage,current,power);
            case{'C'}
                syms V(s) I(s)
                V(s) = CSol(dElement(i).Node1) - CSol(dElement(i).Node2);
                voltage(t) = ilaplace(V,t);
                I(s) = (V(s).*(dElement(i).Value).*s);
                current(t) = ilaplace(I,t);
                power = voltage.*current;
                fprintf(fileID,'%s\r\t%s\r\t%s\r\t%s\r\n',name,voltage,current,power);
            case{'L'}
                syms V(s) I(s)
                V(s) = CSol(dElement(i).Node1) - CSol(dElement(i).Node2);
                I(s) = CSol(dElement(i).new_variables + nNodes);
                voltage(t) = ilaplace(V,t);
                current(t) = ilaplace(I,t);
                power = voltage.*current;
                fprintf(fileID,'%s\r\t%s\r\t%s\r\t%s\r\n',name,voltage,current,power);
            case{'V'}
                syms V(s) I(s)
                I(s) = CSol(dElement(i).new_variables + nNodes);
                voltage(t) = dElement(i).Value;
                current(t) = ilaplace(I,t);
                power = voltage.*current;
                fprintf(fileID,'%s\r\t%s\r\t%s\r\t%s\r\n',name,voltage,current,power);
            case{'I'}
                syms V(s) I(s)
                V(s) = (CSol(dElement(i).Node1) - CSol(dElement(i).Node2));
                voltage(t) = ilaplace(V,t);
                current(t) = dElement(i).Value;
                power = voltage.*current;
                fprintf(fileID,'%s\r\t%s\r\t%s\r\t%s\r\n',name,voltage,current,power);
            case{'ML'}
                syms V1(s) I1(s) V2(s) I2(s)
                V1(s) = (CSol(dElement(i).Node1) - CSol(dElement(i).Node2));
                V2(s) = (CSol(dElement(i).Node3) - CSol(dElement(i).Node4));
                I1(s) = CSol(dElement(i).new_variables - 1 + nNodes);
                I2(s) = CSol(dElement(i).new_variables + nNodes);
                voltage1(t) = ilaplace(V1,t);
                voltage2(t) = ilaplace(V2,t);
                current1(t) = ilaplace(I1,t);
                current2(t) = ilaplace(I2,t);
                power = voltage1.*current1 + voltage2.*current2;
                fprintf(fileID,'%s\r\t%s\r\t%s\r\t%s\r\t%s\r\t%s\r\n',name,voltage1,voltage2,current1,current2,power);
            case{'VSVC'}
                syms V(s) I(s)
                V(s) = (CSol(dElement(i).Node1) - CSol(dElement(i).Node2));
                I(s) = CSol(dElement(i).new_variables + nNodes);
                voltage(t) = ilaplace(V,t);
                current(t) = ilaplace(I,t);
                power = voltage.*current;
                fprintf(fileID,'%s\r\t%s\r\t%s\r\t%s\r\n',name,voltage,current,power);
            case{'CSVC'}
                syms V(s) I(s)
                V(s) = (CSol(dElement(i).Node1) - CSol(dElement(i).Node2));
                I(s) = CSol(dElement(i).Gain.*(CSol(dElement(i).Node3) - CSol(dElement(i).Node4)));
                voltage(t) = ilaplace(V,t);
                current(t) = ilaplace(I,t);
                power = voltage.*current;
                fprintf('%s\r\t%s\r\t%s\r\t%s\r\n',name,voltage,current,power);
            case{'VSCC'}
                syms V(s) I(s)
                V(s) = (CSol(dElement(i).Node1) - CSol(dElement(i).Node2));
                I(s) = CSol(dElement(i).new_variables + nNodes);
                voltage(t) = ilaplace(V,t);
                current(t) = ilaplace(I,t);
                power = voltage.*current;
                fprintf(fileID,'%s\r\t%s\r\t%s\r\t%s\r\n',name,voltage,current,power);
            case{'CSCC'}
                syms V(s) I(s)
                V(s) = (CSol(dElement(i).Node1) - CSol(dElement(i).Node2));
                switch(dElement(dElement(i).Branch).Name)
                    case{'R'}
                        I(s) = (dElement(i).Gain.*(CSol(dElement(dElement(i).Branch).Node1) - CSol(dElement(dElement(i).Branch).Node2))./(dElement(i).Value));
                        fprintf(fileID,'%s\r\t%s\r\t%s\r\t%s\r\n',name,voltage,current,power);
                    case{'C'}
                        I(s) = (dElement(i).Gain.*CSol((dElement(dElement(i).Branch).Node1) - CSol(dElement(dElement(i).Branch).Node2)).*(dElement(i).Value).*s);
                        fprintf(fileID,'%s\r\t%s\r\t%s\r\t%s\r\n',name,voltage,current,power);
                    case{'V','L'}
                        I(s) = (dElement(i).Gain.*CSol(dElement(dElement(i).Branch).new_variables + nNodes));
                        fprintf(fileID,'%s\r\t%s\r\t%s\r\t%s\r\n',name,voltage,current,power);
                    case{'ML'}
                        switch(dElement(i).ml)
                            case{1}
                                I(s) = (dElement(i).Gain.*CSol(dElement(dElement(i).Branch).new_variables - 1 + nNodes));
                                fprintf(fileID,'%s\r\t%s\r\t%s\r\t%s\r\n',name,voltage,current,power);
                            case{2}
                                I(s) = (dElement(i).Gain.*CSol(dElement(dElement(i).Branch).new_variables));
                                fprintf(fileID,'%s\r\t%s\r\t%s\r\t%s\r\n',name,voltage,current,power);
                        end
                end
                voltage(t) = ilaplace(V,t);
                current(t) = ilaplace(I,t);
                power = voltage.*current;
        end
            
    end
    fclose(fileID);

end