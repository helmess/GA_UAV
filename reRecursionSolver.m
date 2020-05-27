function [currentStateProbability, currentExpectedCost] = reRecursionSolver(...
    previousStateProbability, previousExpectedCost, previousTransitionIntensity, stateCost, transitionCost, deltaT)
%
% Input
% previousStateProbability - previous state probability vector (U D T E H)
% previousExpectedCost - previous expected cost
% previousTransitionIntensity - previous transition intensity matrix (lambda(i,j) i,j = [U D T E H])
% stateCost - state cost vector (U D T E H)
% transitionCost - transition cost matrix (c(i,j) i,j = [U D T E H])
% deltaT - time step
%
% Output
% currentStateProbability - current state probability vector (U D T E H)
% currentExpectedCost - current expected cost
%

X_previous = [previousStateProbability; previousExpectedCost];

XiU_previous = stateCost(1) + previousTransitionIntensity(1, :)*transitionCost(1, :).' - previousTransitionIntensity(1, 1)*transitionCost(1, 1);
XiD_previous = stateCost(2) + previousTransitionIntensity(2, :)*transitionCost(2, :).' - previousTransitionIntensity(2, 2)*transitionCost(2, 2);
XiT_previous = stateCost(3) + previousTransitionIntensity(3, :)*transitionCost(3, :).' - previousTransitionIntensity(3, 3)*transitionCost(3, 3);
XiE_previous = stateCost(4) + previousTransitionIntensity(4, :)*transitionCost(4, :).' - previousTransitionIntensity(4, 4)*transitionCost(4, 4);
XiH_previous = stateCost(5) + previousTransitionIntensity(5, :)*transitionCost(5, :).' - previousTransitionIntensity(5, 5)*transitionCost(5, 5);

A_previous = [previousTransitionIntensity.', zeros(5, 1); XiU_previous XiD_previous, XiT_previous, XiE_previous, XiH_previous, 0];

expA_previous = zeros(6, 6);
% Taylor expansion order can be modified
for ii = 0:16
    expA_previous = expA_previous + (A_previous*deltaT)^ii/factorial(ii);
end

x_current = expA_previous*X_previous;
currentStateProbability = x_current(1:5);
currentExpectedCost = x_current(6);

end




