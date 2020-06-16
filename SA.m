function [ global_chromosome ] = SA( chromosome,model )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    global_chromosome=chromosome;
    H=100;
    while H>95
    for it=1:2
    new_chromosome= chromosome;
    alpha =chromosome.alpha;
    beta =chromosome.beta;
    T =chromosome.T;
    for i=1:model.dim
       u =rand;
       yi = H *(u-0.5)*((1+1/H)^(abs(2*u -1)) -1 );
       alpha(i) =alpha(i) +  yi*(model.alpha_max -model.alpha_min);
       beta(i) = beta(i) + yi*(model.beta_max -model.beta_min);
       T(i) =T(i)+ yi*(model.Tmax -model.Tmin);
       if alpha(i)<model.alpha_min || alpha(i)>model.alpha_max
            alpha(i) = (rand*2 -1)*model.alpha_max;
       end
       if beta(i)<model.beta_min || beta(i)>model.beta_max
            beta(i) = (rand*2 -1)*model.beta_max;
       end
       if T(i)<model.Tmin || T(i)>model.Tmax
             T(i)=(rand*(2*model.Tmax)-model.Tmax)*0.1+ model.Tmax;
       end
    end
    alpha =reshape(alpha,model.dim,1);
    beta =reshape(beta,model.dim,1);
    T =reshape(T,1,model.dim);
    new_chromosome.alpha =alpha;
    new_chromosome.beta =beta;
    new_chromosome.T =T;
    [new_chromosome.pos] = Angel2Pos(new_chromosome,model);
    [new_chromosome.cost,new_chromosome.sol] = FitnessFunction(new_chromosome,model);
    d_fitness =new_chromosome.cost - chromosome.cost;
    if d_fitness<0
       %接受新解
       chromosome =  new_chromosome;
    else
        if rand > exp((d_fitness)/H)
           %接受新解
            chromosome =  new_chromosome; 
        end
    end
    if chromosome.cost < global_chromosome.cost
        global_chromosome =chromosome;
    end
    end
    H =H-1;
    end


end

