% A wrapper function for testing and timing iterative methods for
% inverting a matrix - 2015 - Robert M. Gower
% InvRand Copyright (C) 2016, Robert Gower 
function [M, output] = invert_matrix(Prob, iter_func, boot_func, iter,test,options )
tic;
M = boot_func(Prob.A,options);  %M = full(M);
times(1) = toc;
Ident = speye(size(Prob.A));
%Asqr = A^(1/2);
if(options.factored)
    initial_error= norm(Ident -M'*Prob.A*M,'fro');
    %initial_error= norm(Ident -M*(M')*A,'fro');
else
    initial_error= norm(Ident -M*Prob.A,'fro');
end
errors(1) = 1;
if(~isfield(options,'max_time'))
    options.max_time = 60*10; % 10 minutes
end
for i = 1:iter
    if (mod(i,30)==1)
        display(options.name);
        fprintf('-------------------\n'); fprintf('It | Error%%   |  Time   \n'); fprintf('-------------------\n');
    end
    fprintf('%3.0d  | %3.2f%%   |  %3.4f \n',i,100*errors(i),times(i) );
    tic;
    M = iter_func(Prob.A,M,options);
    times(i+1)= times(i) +  toc;
    if (~isempty(test))
        if(options.factored)
            errors(i+1)= norm(Ident -M'*Prob.A*M,'fro')/initial_error;
            %errors(i+1) = norm(Ident -M*(M')*A,'fro')/initial_error;
        else
            errors(i+1) = norm(Ident -M*Prob.A,'fro')/initial_error;
        end
        if(errors(i+1)/100 < 10^(-4))
            output.fail =0;
            break;
        end
        if(isnan(errors(i+1)))
            output.fail =1;
            return;
        end
        if(isinf(errors(i+1)))
            output.fail =1;
            return;
        end
    end
    if(times(i+1) >options.max_time )
        output.fail ='times_up';
        break;
    end
end
if(i==iter) output.fail ='max_iter';  end %#ok<SEPEX>
if (~isempty(test)) fprintf('%3.0d  | %3.2f%%  |  %3.4f \n',i,100*errors(i+1),times(i+1) ); end %#ok<SEPEX>
clear M;
M =0;
output.flopsperiter = options.flopsperiter;
output.times = [ 0 times];
output.errors = [1 errors];
output.name = options.name;
end
