function [ alpha,beta,T ] = Mutation( chromosome,model )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
    %浮点数变异
    %x(t+1) = x(t) + k*(xmax-x(t))*r,r%2=0
    %x(t+1) = x(t) - k*(x(t)-xmin)*r,r%2=1
    %k是变异常数(0,1)，r是随机数假设是[0,1]
    if model.mutation_prob>rand
    r = randi(10,1,1);
    k = 0.1;
    if mod(r,2) ==1
    alpha = chromosome.alpha - k*(chromosome.alpha - model.alpha_min)*r/10;
    beta =  chromosome.beta - k*(chromosome.beta - model.beta_min)*r/10;
    T = chromosome.T - k*(chromosome.T - model.Tmin)*r/10;
    else
    alpha = chromosome.alpha + k*(model.alpha_max - chromosome.alpha)*r/10;
    beta =  chromosome.beta + k*(model.beta_max-chromosome.beta )*r/10;
    T = chromosome.T + k*(model.Tmax - chromosome.T)*r/10;
    end
    else
        alpha =chromosome.alpha;
        beta = chromosome.beta;
        T = chromosome.T;
    end
    
end

