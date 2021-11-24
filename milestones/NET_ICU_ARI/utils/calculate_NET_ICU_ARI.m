function [dpli_dri] = calculate_NET_ICU_ARI(s1vs2, s1vso, s2vso, w1, w2, w3)
% CALCULATE DPLI DRI 3 is the third version of the dpli-dri formula
%
% s1vs2: sedon1 vs sedon2 SIMILARITY matrix
% s1vso: sedon1 vs sedoff SIMILARITY matrix
% s2vso: sedon2 vs sedoff SIMILIARTY matrix
% w1: weight for the s1vs2
% w2: weight for the s1vso
% w3: weight for the s2vso

    dpli_dri = w1*sum(s1vso(:)) + w2*sum(s2vso(:)) - w3*sum(s1vs2(:));
end