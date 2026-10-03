function [Best_pos, Best_score, Convergence_curve, total_evals] = BRS1D(N, max_iter, nVar, CostFunction, verbose)
% BRS1D  Pure random search over binary chromosomes, same budget
% (N*max_iter evaluations) as the metaheuristics: the null comparator
% that any optimizer must beat to justify its use.
    if nargin < 5, verbose = false; end
    Best_score = inf; Best_pos = zeros(nVar, 1);
    Convergence_curve = zeros(1, max_iter); total_evals = 0;
    for t = 1:max_iter
        for i = 1:N
            x = double(rand(nVar, 1) < 0.5);
            f = CostFunction(x'); total_evals = total_evals + 1;
            if f < Best_score, Best_score = f; Best_pos = x; end
        end
        Convergence_curve(t) = Best_score;
    end
end
