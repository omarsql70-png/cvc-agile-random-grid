%___________________________________________________________________%
%  Binary Harris Hawks Optimization (BHHO) - single-population        %
%  comparator for the Sprint-4 optimizer of the Agile Color-VC        %
%  framework.                                                         %
%                                                                     %
%  A. A. Heidari, S. Mirjalili, H. Faris, I. Aljarah, M. Mafarja,     %
%  H. Chen, "Harris hawks optimization: Algorithm and applications," %
%  Future Generation Computer Systems, 97, 849-872, 2019.             %
%                                                                     %
%  Revision 2 (corrects the first comparator version):               %
%   * hawks move in the CONTINUOUS box [0,1]^d exactly as in the      %
%     original HHO equations, and are binarized only for evaluation   %
%     (bit = x >= 0.5). The first version re-binarized after every    %
%     difference-form update, which drove chromosomes towards all-zero %
%     bit strings (the [-80,...] boundary).                           %
%   * rapid-dive candidates Y/Z that were evaluated and accepted are   %
%     the ones kept (no re-sampling), and they update the rabbit.      %
%   * a hard evaluation budget (max_evals) gives every optimizer the   %
%     same number of fitness calls.                                   %
%  Original implementation written for this project.                 %
%___________________________________________________________________%
function [Best_pos, Best_score, Convergence_curve, total_evals] = BHHO1D(N, max_iter, nVar, CostFunction, verbose, max_evals)

    if nargin < 5, verbose = false; end
    if nargin < 6, max_evals = N * max_iter; end
    dim = nVar; LB = 0; UB = 1;
    X = rand(dim, N);
    Fitness = inf(1, N);
    Convergence_curve = nan(1, max_iter);
    Rabbit_pos = zeros(dim, 1); Rabbit_score = inf;
    total_evals = 0;
    bin = @(v) double(v >= 0.5);

    for t = 1:max_iter
        for i = 1:N
            if total_evals >= max_evals, break; end
            Fitness(i) = CostFunction(bin(X(:, i))'); total_evals = total_evals + 1;
            if Fitness(i) < Rabbit_score, Rabbit_score = Fitness(i); Rabbit_pos = X(:, i); end
        end
        if total_evals >= max_evals
            Convergence_curve(t:end) = Rabbit_score; break;
        end

        X_mean = mean(X, 2);
        E1 = 2 * (1 - t / max_iter);
        for i = 1:N
            E = E1 * (2 * rand() - 1);
            if abs(E) >= 1                                   % exploration, Eq. (1)
                if rand() >= 0.5
                    Xr = X(:, randi(N));
                    Xn = Xr - rand() * abs(Xr - 2 * rand() * X(:, i));
                else
                    Xn = (Rabbit_pos - X_mean) - rand() * (LB + rand() * (UB - LB));
                end
            else
                r = rand(); J = 2 * (1 - rand());
                if r >= 0.5 && abs(E) >= 0.5                 % soft besiege, Eq. (4)
                    Xn = (Rabbit_pos - X(:, i)) - E * abs(J * Rabbit_pos - X(:, i));
                elseif r >= 0.5                              % hard besiege, Eq. (6)
                    Xn = Rabbit_pos - E * abs(Rabbit_pos - X(:, i));
                else                                         % rapid dives, Eqs. (10)-(13)
                    if abs(E) >= 0.5
                        Y = Rabbit_pos - E * abs(J * Rabbit_pos - X(:, i));
                    else
                        Y = Rabbit_pos - E * abs(J * Rabbit_pos - X_mean);
                    end
                    Y = min(max(Y, LB), UB);
                    Z = min(max(Y + rand(dim, 1) .* Levy(dim)', LB), UB);
                    Xn = X(:, i);
                    if total_evals + 2 <= max_evals
                        fY = CostFunction(bin(Y)'); fZ = CostFunction(bin(Z)'); total_evals = total_evals + 2;
                        if fY < Rabbit_score, Rabbit_score = fY; Rabbit_pos = Y; end
                        if fZ < Rabbit_score, Rabbit_score = fZ; Rabbit_pos = Z; end
                        if fY < Fitness(i) && fY <= fZ
                            Xn = Y; Fitness(i) = fY;
                        elseif fZ < Fitness(i)
                            Xn = Z; Fitness(i) = fZ;
                        end
                    end
                end
            end
            X(:, i) = min(max(Xn, LB), UB);
        end
        Convergence_curve(t) = Rabbit_score;
        if verbose
            printf('BHHO1D iter %d/%d -> best cost = %.5f (evals %d)\n', t, max_iter, Rabbit_score, total_evals); fflush(stdout);
        end
    end
    Best_pos = bin(Rabbit_pos);
    Best_score = Rabbit_score;
end
