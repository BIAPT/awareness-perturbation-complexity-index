function [dpli_dri] = calculate_dpli_dri_1(bvr, bva, rva, w1, w2)
% CALCULATE DPLI DRI 1 is the first attempt at calculating the dpli-dri
% which uses division
%
% bvr: baseline vs recovery SIMILARITY matrix
% bva: baseline vs anesthesia SIMILARITY matrix
% rva: recovery vs anesthesia SIMILIARTY matrix
% w1: weight for the bva
% w2: weight for the rva

    dpli_dri = sum(bvr(:)) / (w1*(sum(bva(:))) + w2*(sum(rva(:))));
end