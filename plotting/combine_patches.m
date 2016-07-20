function [fv,cdata, indexList]=combine_patches(fv1,fv2,cdata1,cdata2, indexList1, indexList2)
%combine_patches Combine two patches.
%
%   [fv,cdata, indexList]=combine_patches(fv1,fv2,cdata1,cdata2,
%   indexList1, indexList2) combines the patches fv1 and fv2, as well as
%   some color data for each patch, and an index list for each mesh.
%
%   Usage: This can be used inside a for loop, where a new patch is
%   prepended at each iteration.
%   Example: simply combine patches in a for loop:
%   fv=[];
%   for ii = 1:n
%       new_patch = generateNewPatch; % up to you how you generate your patches
%       fv = combine_patches(new_patch,fv);
%   end
%   patch(fv);
%
%   JAC - Jan 19 2016

%%
if ~isempty(fv2)
    nv1=length(fv1.vertices);
    fv.vertices=[fv1.vertices;fv2.vertices];
    fv.faces=[fv1.faces; fv2.faces+nv1];
    if exist('cdata1', 'var')
        cdata = [cdata1;cdata2];
    else
        cdata = [];
    end
    if exist('indexList1', 'var')
        indexList = [indexList1;indexList2+nv1];
    else
        indexList = [];
    end
else % only one input - usually happens when calling this function inside a for loop.
    %The first time around there is nothing in the second element
    fv = fv1;
    if exist('cdata1', 'var')
        cdata = cdata1;
    else
        cdata = [];
    end
    if exist('indexList1', 'var')
        indexList = indexList1;
    else
        indexList = [];
    end
end
%%