function [ stateProbabilityProcess, expectedCostProcess ] = reRouteEvaluation( posRouteInterp, posSensor, posWeapon, rangeSensor, rangeWeapon,...
		outsideTransitionIntensity, sensorTransitionIntensity, weaponTransitionIntensity, stateCost, transitionCost, timeStep )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    %基本参数的数量
    nWayPoint = length(posRouteInterp);
    nSensor = length(posSensor);
    [~,nWeapon] = size(posWeapon);
    %转移矩阵
    transitionIntensity = zeros(5,5);
    %状态瞬时表
    stateProbabilityProcess = zeros(5,nWayPoint);
    %对应状态代价
    expectedCostProcess = zeros(1,nWayPoint);
    %初始状态
    stateProbability=[1,0,0,0,0]';
    expectedCost =0;
    for point =1:nWayPoint
        flagInsideSensor =zeros(nSensor,1);
        
        %检查无人机是否在雷达范围内
        for j =1:nSensor
        dist = norm(posRouteInterp(point,:) - posSensor(:,j)');    
        if dist < rangeSensor(j)
            flagInsideSensor(j) = 1;
        end
        end
        %检查无人机是否在攻击雷达范围内
        flagInsideWeapon = zeros(nWeapon,1);
        for j=1:nWeapon
           dist =norm(posRouteInterp(point,:) - posWeapon(:,j)');
           if dist < rangeWeapon(j)
           flagInsideWeapon(j) =1;
           end
        end
        %无人机在雷达和攻击雷达范围外面,转移矩阵不变
        if(sum(flagInsideSensor)==0 && sum(flagInsideWeapon)==0)
            transitionIntensity = outsideTransitionIntensity;
        %无人机在攻击雷达范围内则不考虑探测雷达
        elseif (sum(flagInsideWeapon)>0)
                %计算重叠区域雷达的序号
                sequence = find(flagInsideWeapon);
                %考虑雷达重叠区域
                if sum(flagInsideWeapon) >1
                    lambdaUD = weaponTransitionIntensity(1,2,sequence(1));
                    lambdaDT = weaponTransitionIntensity(2,3,sequence(1));
                    lambdaDU = weaponTransitionIntensity(2,1,sequence(1));
                    lambdaTD = weaponTransitionIntensity(3,2,sequence(1));
                    lambdaTE = weaponTransitionIntensity(3,4,sequence(1));
                    lambdaET = weaponTransitionIntensity(4,3,sequence(1));
                    lambdaEH = weaponTransitionIntensity(4,5,sequence(1));
                    for j=2:numel(sequence)
                        lambdaUD =lambdaUD + weaponTransitionIntensity(1,2,sequence(j));
                        lambdaDT = lambdaDT + weaponTransitionIntensity(2,3,sequence(j));
                        lambdaDU = 1 / (1 / lambdaDU + 1 / weaponTransitionIntensity(2,1,sequence(j)) - 1 / (lambdaDU + weaponTransitionIntensity(2,1,sequence(j))));
                        lambdaTD = 1 / (1 / lambdaTD + 1 / weaponTransitionIntensity(3,2,sequence(j)) - 1 / (lambdaTD + weaponTransitionIntensity(3,2,sequence(j))));
                    	lambdaTE = max(lambdaTE, weaponTransitionIntensity(3,4,sequence(j)));
                    	lambdaET = min(lambdaET, weaponTransitionIntensity(4,3,sequence(j)));
                    	lambdaEH = max(lambdaEH, weaponTransitionIntensity(4,5,sequence(j)));
                      
                    end
                    transitionIntensity =[
                    -lambdaUD, lambdaUD, 0, 0, 0;
					lambdaDU, -(lambdaDU + lambdaDT), lambdaDT, 0, 0;
					0, lambdaTD, -(lambdaTD + lambdaTE), lambdaTE, 0;
					0, 0, lambdaET, -(lambdaET + lambdaEH), lambdaEH;
					0, 0, 0, 0, 0
                    ];
               else
               %单个攻击雷达区域
               transitionIntensity = weaponTransitionIntensity(:,:,sequence(1));
                end
        %无人机在探测雷达范围内
        else
            sequence = find(flagInsideSensor);
            if sum(flagInsideSensor)>1
                lambdaUD = sensorTransitionIntensity(1,2,sequence(1));
                lambdaDT = sensorTransitionIntensity(2,3,sequence(1));
                lambdaDU = sensorTransitionIntensity(2,1,sequence(1));
                lambdaTD = sensorTransitionIntensity(3,2,sequence(1));
                lambdaTE = sensorTransitionIntensity(3,4,sequence(1));
                lambdaET = sensorTransitionIntensity(4,3,sequence(1));
                lambdaEH = sensorTransitionIntensity(4,5,sequence(1));
                for j=2:numel(sequence)
                    lambdaUD =lambdaUD + sensorTransitionIntensity(1,2,sequence(j));
                    lambdaDT = lambdaDT + sensorTransitionIntensity(2,3,sequence(j));
                    lambdaDU = 1 / (1 / lambdaDU + 1 / sensorTransitionIntensity(2,1,sequence(j)) - 1 / (lambdaDU + sensorTransitionIntensity(2,1,sequence(j))));
                    lambdaTD = 1 / (1 / lambdaTD + 1 / sensorTransitionIntensity(3,2,sequence(j)) - 1 / (lambdaTD + sensorTransitionIntensity(3,2,sequence(j))));
                    lambdaTE = max(lambdaTE, sensorTransitionIntensity(3,4,sequence(j)));
                    lambdaET = min(lambdaET, sensorTransitionIntensity(4,3,sequence(j)));
                    lambdaEH = max(lambdaEH, sensorTransitionIntensity(4,5,sequence(j)));
                end
                %更新转移矩阵
                transitionIntensity =[
                    -lambdaUD, lambdaUD, 0, 0, 0;
                    lambdaDU, -(lambdaDU + lambdaDT), lambdaDT, 0, 0;
                    0, lambdaTD, -(lambdaTD + lambdaTE), lambdaTE, 0;
                    0, 0, lambdaET, -(lambdaET + lambdaEH), lambdaEH;
                    0, 0, 0, 0, 0];
                %单个探测雷达区域
            else
                transitionIntensity = sensorTransitionIntensity(:,:,sequence(1));
            end
        end
        %计算航路中每个点的代价值
        [stateProbability,expectedCost]=reRecursionSolver(stateProbability, expectedCost, transitionIntensity, stateCost, transitionCost, timeStep);
        stateProbabilityProcess(:, point) = stateProbability;
        expectedCostProcess(point) = expectedCost;
    end
    
    

end

