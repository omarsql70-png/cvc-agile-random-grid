%___________________________________________________________________%
%  Binary Dragonfly Algorithm (BDA) - single-swarm variant           %
%  adapted for the Agile Color-VC framework (Sprint-4 comparator)    %
%                                                                     %
%  Original algorithm and equations:                                 %
%  S. Mirjalili, "Dragonfly algorithm: a new meta-heuristic           %
%  optimization technique for solving single-objective, discrete,    %
%  and multi-objective problems", Neural Computing and Applications, %
%  DOI: http://dx.doi.org/10.1007/s00521-015-1920-1                  %
%  Demo source: BDA.m / Levy.m (c) 2015 Seyedali Mirjalili,           %
%  redistributed here under the accompanying BSD license (see        %
%  license.txt); this file is a derivative, adapted from a three-    %
%  population (R/G/B) demo into a single-population optimizer that   %
%  searches ONE chromosome (here: the 24-bit CVC halftone-bias        %
%  vector) rather than three independent, unrelated copies.          %
%___________________________________________________________________%

function [Best_pos, Best_score, Convergence_curve, total_evals] = BDA1D(N, max_iter, nVar, CostFunction, verbose)

    if nargin < 5, verbose = false; end
    total_evals = 0;

    dim = nVar;

    Food_fitness = inf;
    Food_pos = zeros(dim, 1);

    Enemy_fitness = -inf;
    Enemy_pos = zeros(dim, 1);

    % Initialize X and DeltaX
    X = double(rand(dim, N) <= 0.5);
    DeltaX = double(rand(dim, N) <= 0.5);

    Fitness = zeros(1, N);
    Convergence_curve = zeros(1, max_iter);

    for iter = 1:max_iter

        w = 0.9 - iter * ((0.9 - 0.4) / max_iter);

        my_c = 0.1 - iter * ((0.1 - 0) / (max_iter / 2));
        if my_c < 0
            my_c = 0;
        end

        s = 2 * rand * my_c; % Separation weight
        a = 2 * rand * my_c; % Alignment weight
        c = 2 * rand * my_c; % Cohesion weight
        f = 2 * rand;        % Food attraction weight
        e = my_c;            % Enemy distraction weight

        if iter > (3 * max_iter / 4)
            e = 0;
        end

        for i = 1:N
            Fitness(1, i) = CostFunction(X(:, i)');
            total_evals = total_evals + 1;

            if Fitness(1, i) < Food_fitness
                Food_fitness = Fitness(1, i);
                Food_pos = X(:, i);
            end
            if Fitness(1, i) > Enemy_fitness
                Enemy_fitness = Fitness(1, i);
                Enemy_pos = X(:, i);
            end
        end

        for i = 1:N
            neigh_idx = [1:i-1, i+1:N];
            Neighbours_DeltaX = DeltaX(:, neigh_idx);
            Neighbours_X = X(:, neigh_idx);
            neighbours_no = numel(neigh_idx);

            % Separation - Eq. (3.1)
            S = -sum(Neighbours_X - X(:, i), 2);

            % Alignment - Eq. (3.2)
            A = sum(Neighbours_DeltaX, 2) / neighbours_no;

            % Cohesion - Eq. (3.3)
            C_temp = sum(Neighbours_X, 2) / neighbours_no;
            Cc = C_temp - X(:, i);

            % Attraction to food - Eq. (3.4)
            F = Food_pos - X(:, i);

            % Distraction from enemy - Eq. (3.5)
            E = Enemy_pos + X(:, i);

            for j = 1:dim
                DeltaX(j, i) = s*S(j) + a*A(j) + c*Cc(j) + f*F(j) + e*E(j) + w*DeltaX(j, i);
                DeltaX(j, i) = max(min(DeltaX(j, i), 6), -6);

                T = abs(DeltaX(j, i) / sqrt(1 + DeltaX(j, i)^2));  % V3 transfer function, Eq. (3.11)

                if rand < T
                    X(j, i) = ~X(j, i);
                end
            end
        end

        Convergence_curve(iter) = Food_fitness;
        Best_pos = Food_pos;
        Best_score = Food_fitness;
        if verbose
            printf('BDA1D iter %d/%d -> best cost = %.5f\n', iter, max_iter, Food_fitness); fflush(stdout);
        end
    end
end
