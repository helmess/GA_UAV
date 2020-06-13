function [ a,b,t ] = Constrain( alpha,beta,T,model)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    a = max(alpha,model.alpha_min);
    a = min(alpha,model.alpha_max);
    b = max(beta,model.beta_min);
    b = min(beta,model.beta_max);
    
    t = max(T,model.Tmin);
    t = min(T,model.Tmax);
    
end

