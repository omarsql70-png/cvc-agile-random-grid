function tf = run_done(fname, image, mode, opt, seed)
% RUN_DONE  True if this run is already recorded in fname (resumable runs).
    tf = false;
    if ~exist(fname, 'file'), return; end
    key = sprintf('%s,%s,%s,%d,', image, mode, opt, seed);
    tf = ~isempty(strfind(fileread(fname), key));
end
