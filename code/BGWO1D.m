%___________________________________________________________________%
%  Binary Grey Wolf Optimizer (BGWO) - single-pack implementation    %
%  used as the Sprint-4 optimizer of the Agile Color-VC framework    %
%                                                                     %
%  S. Mirjalili, S. M. Mirjalili, A. Lewis, "Grey Wolf Optimizer,"    %
%  Advances in Engineering Software, 69, 46-61, 2014.                 %
%  E. Emary, H. M. Zawbaa, A. E. Hassanien, "Binary grey wolf          %
%  optimization approaches for feature selection," Neurocomputing,   %
%  172, 371-381, 2016 (sigmoid-transfer binarization, Approach 2).    %
%  Original implementation written for this project.                 %
%___________________________________________________________________%
function [Best_pos, Best_score, Convergence_curve, total_evals] = BGWO1D(N, max_iter, nVar, CostFunction, verbose)

    if nargin < 5, verbose = false; end
    dim = nVar;
    X = double(rand(dim, N) <= 0.5);
    Convergence_curve = zeros(1, max_iter);
    Alpha_pos = zeros(dim, 1); Alpha_score = inf;
    Beta_pos  = zeros(dim, 1); Beta_score  = inf;
    Delta_pos = zeros(dim, 1); Delta_score = inf;
    total_evals = 0;

    for iter = 1:max_iter
        for i = 1:N
            f = CostFunction(X(:, i)');
            total_evals = total_evals + 1;
            if f < Alpha_score
                Delta_score = Beta_score;  Delta_pos = Beta_pos;
                Beta_score  = Alpha_score; Beta_pos  = Alpha_pos;
                Alpha_score = f;           Alpha_pos = X(:, i);
            elseif f < Beta_score
                Delta_score = Beta_score;  Delta_pos = Beta_pos;
                Beta_score  = f;           Beta_pos  = X(:, i);
            elseif f < Delta_score
                Delta_score = f;           Delta_pos = X(:, i);
            end
        end

        a = 2 - iter * (2 / max_iter);
        for i = 1:N
            for j = 1:dim
                A1 = 2*a*rand - a; C1 = 2*rand;
                X1 = Alpha_pos(j) - A1 * abs(C1*Alpha_pos(j) - X(j, i));
                A2 = 2*a*rand - a; C2 = 2*rand;
                X2 = Beta_pos(j)  - A2 * abs(C2*Beta_pos(j)  - X(j, i));
                A3 = 2*a*rand - a; C3 = 2*rand;
                X3 = Delta_pos(j) - A3 * abs(C3*Delta_pos(j) - X(j, i));
                Xcont = (X1 + X2 + X3) / 3;
                prob = 1 / (1 + exp(-10 * (Xcont - 0.5)));   % sigmoid transfer
                X(j, i) = double(rand < prob);
            end
        end
        Convergence_curve(iter) = Alpha_score;
        if verbose
            printf('BGWO1D iter %d/%d -> best cost = %.5f\n', iter, max_iter, Alpha_score); fflush(stdout);
        end
    end
    Best_pos = Alpha_pos;
    Best_score = Alpha_score;
end
