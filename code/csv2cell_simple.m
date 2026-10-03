function C = csv2cell_simple(fname)
% CSV2CELL_SIMPLE  Read a simple comma-separated file (no quoted commas)
% into a cell array of strings, header row removed.
    txt = fileread(fname);
    lines = strsplit(strtrim(txt), "\n");
    C = {};
    for i = 2:numel(lines)
        C(end+1, :) = strsplit(strtrim(lines{i}), ',');
    end
end
