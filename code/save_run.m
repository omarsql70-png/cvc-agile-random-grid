function save_run(fidRuns, fidCurves, image, mode, opt, seed, out, base_mean)
% SAVE_RUN  Append one run to the runs/curves CSV files.
    fprintf(fidRuns, '%s,%s,%s,%d,%.4f,%.4f,%.4f,%.6f,%.6f,%.6f,%.6f,%d\n', image, mode, opt, seed, ...
        out.params(1), out.params(2), out.params(3), out.search_score, out.indep_mean, out.indep_sd, base_mean, out.evals);
    fprintf(fidCurves, '%s,%s,%s,%d,%s\n', image, mode, opt, seed, sprintf('%.6f;', out.curve));
    fflush(fidRuns); fflush(fidCurves);
end
