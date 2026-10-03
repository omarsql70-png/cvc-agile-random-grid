function [fr, fc] = open_results(outdir, prefix)
% OPEN_RESULTS  Open runs/curves CSVs in append mode, writing headers once.
    f1 = fullfile(outdir, [prefix '_runs.csv']); f2 = fullfile(outdir, [prefix '_curves.csv']);
    new1 = ~exist(f1, 'file'); new2 = ~exist(f2, 'file');
    fr = fopen(f1, 'a'); fc = fopen(f2, 'a');
    if new1, fprintf(fr, 'image,mode,optimizer,seed,p_C,p_M,p_Y,search_score,indep_mean,indep_sd,baseline_indep_mean,evals\n'); end
    if new2, fprintf(fc, 'image,mode,optimizer,seed,curve\n'); end
end
