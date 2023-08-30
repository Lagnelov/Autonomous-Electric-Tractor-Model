clear 
n=1;
%table inputs before the model start
%percipitation table
Q_pTable=readtable('Percipitation.xlsx');
 Q_pTable=Q_pTable{:,:};
 
 %Inputs, static
Weather_crit=3; %criteria for workability threshold, 3=deToro & standard
FieldEff=0.8; %Field efficiency, i.e how much of the working width can be effetively used. 0.8 is a standard taken from Witney (1988)
v_field =5; %average speed on field, in km/h
ForceCorrVar=0.85; %Constant to adjust the field forces for operations. Force equations used from ASAE(2000) are ~15% too high.
ChangeNo=1;% Number of battery changing stations for BES.
EOL=0.8; %At which fraction the battery is "spent" and should be replaced
BatteryReplacement=0; %Initial numbers of battery replacements. = is standard. Ticks up in simulation.
CyclesIn=0; % Number of cycles at start of model, activated in the model. Only relevant for batteries.
FailRate=29700000; %297; %Rate-of-failure (ROF), calculated as 1/FailRate. If no ROF, extremly high number.
Mass=10550; % mass per vehicle in kg. 3027 is normal for 50kW BEV without batteries, +10 kg/kWh. Diesel 250 kW is 10,800
%Soil=3; %Soil type: 1- sandy loam, 2-loam, 3-clay loam

if Mass>5000
    Compaction=1;
else
    Compaction=0;
end

Fuel=3; % 1=CC, 2=BES, 3=Diesel, 4=H2
%If not BES, BatteryNo=0
%If not CC/BES, Degradation=1

        if Fuel==3
            Degradation=1; %If battery ages. 1=no, 2=yes. Diesel/H2, always 1.
        elseif Fuel ==4
            Degradation=1;
        else
            Degradation=2;
        end

        WorkingHours=10; %Number of hours worked per day, 24 for full autonomy, 10 for manned.

%Inputs, variable 
for TractorNo=[1] %Number of tractors
    for Power=[190] %Vehicle rated power, kW (PV)
        for Charger=30340 %Charger power, kW (Diesel= 30345 kW, H2=1000 kW). If variable, base load.
           for Battery=[537] %Battery energy content, kWh (Diesel(50)= 1315 kWh, Diesel(250)=4684kWh, H2=323 kWh)
              for BatteryNo=1 %Number of extra batteries. Only relevant for BES, else=0.
               for ChargerNo=1 %Number of charger stations
                   for DField=0% static distance from farm to field, 0=en standardmatris
                      for Soil= 3 %[1 2 3] % soil type  1=sandy loam, 2= loam, 3= clay loam
                          
                           for Year=25:1:30 %year, start 1989-2018 (1=1989, 2=1990,  30=2018 etc)(31=Gotland 2016)                       
                    
                       
        %part that changes C-rate (and rate of degradation) depending on charger/battery ratio
       if Charger/Battery<0.5
        C_rate=1;
       elseif (Charger/Battery>=0.5) && (Charger/Battery<2)
         C_rate=2;
      else
         C_rate=3; 
       end
             
     
         %simulation and time              
        tic;
        SimOut=sim('ModelAgriAuto');
        toc;
        
        %pre-work for result presentation
        SoC=SOC(end);
        Days=Days(end);
        Time=Time(end,1:17);
        Energy1=Energy1(end);
        Ttransport=T_transport(end);
        Tweather=T_weather(end);
        Twork=T_work(end);
        T_C=TC(end);
        T_Q=TQ(end);
        Trepair=T_repair (end);
        Qwaitavg=Q_wait_avg(end);
        ChargeNoResult=ChargeNo(end);
        Rest=T_rest(end);
   
          
        %result presentation
        Result(n,:)=[Fuel Year TractorNo Power Charger Battery BatteryNo ChargerNo DField Days Energy1 Qwaitavg Ttransport Tweather Twork T_C T_Q Trepair Rest Time ChargeNoResult WorkingHours];    
        %Result_m_a(:,n)=m_a;
       % WP2(:,n)=[Charge_use];
       % Result_LoadC(:,n)=[LoadC];
       % Result_VarC(:,n)=[VarC];
       % Result_LoadT(:,n)=[LoadT];
       % Result_Timeliness(n,:)=[Prel_Timeliness];
        %Result_SOC(:,n)=[SOC];
        %P_task_result(:,n)=P_task;
        %P_vehicle_result(:,n)=P_vehicle;
        %Work_speed_result(:,n)=Work_speed;
        %Task_no_result(:,n)=Task_no;
        Result_State(:,n)=[State];
        Result_SoCState(:,n)=[SoCState];

        %battery replacement and cycle counter
        if SoC<EOL
            CyclesIn=0;
           BatteryReplacement=(BatteryReplacement+1)*(TractorNo+BatteryNo);
        else
            CyclesIn=CyclesIn+CyclesOut(end);
        end
        
        %ticking up the simulation iteration number.
        n=n+1
                      
                               end
                      end
               end
              end
          
              end
           end
        end 
    end
end









