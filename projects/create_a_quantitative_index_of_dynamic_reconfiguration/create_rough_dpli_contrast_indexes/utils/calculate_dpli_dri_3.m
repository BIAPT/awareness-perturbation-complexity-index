function [dpli_dri] = calculate_dpli_dri_3(bvr, bva, rva, w1, w2, w3)
% CALCULATE DPLI DRI 3 is the third version of the dpli-dri formula
%
% bvr: baseline vs recovery SIMILARITY matrix
% bva: baseline vs anesthesia SIMILARITY matrix
% rva: recovery vs anesthesia SIMILIARTY matrix
% w1: weight for the bva
% w2: weight for the rva
% w3: weight for the bvr

    dpli_dri = w1*sum(bva(:)) + w2*sum(rva(:)) - w3*sum(bvr(:));
end