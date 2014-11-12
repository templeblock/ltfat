function [AF,BF]=wpfbtbounds(wt,varargin)
%WPFBTBOUNDS Frame bounds of WPFBT
%   Usage: fcond=wpfbtbounds(wt,L);
%          [A,B]=wpfbtbounds(wt,L);
%           ... =wpfbtbounds(wt);
%
%   `wpfbtbounds(wt,L)` calculates the ratio $B/A$ of the frame bounds
%   of the wavelet packet filterbank specified by *wt* for a system of length
%   *L*. The ratio is a measure of the stability of the system.
%
%   `wpfbtbounds(wt)` does the same, except *L* is chosen to be the next 
%   compatible length bigger than the longest filter from the identical
%   filterbank.
%
%   `[A,B]=wpfbtbounds(...)` returns the lower and upper frame bounds
%   explicitly.
%
%   See |wfbt| for explanation of parameter *wt*. 
%
%   Additionally, the function accepts the following flags:
%
%   `'intsqrt'`(default),`'intnoscale'`, `'intscale'`
%       The filters in the filterbank tree are scaled to reflect the
%       behavior of |wpfbt| and |iwpfbt| with the same flags.
%
%   See also: wpfbt, filterbankbounds

% AUTHOR: Zdenek Prusa


complainif_notenoughargs(nargin,1,'WPFBTBOUNDS');

definput.keyvals.L = [];
definput.flags.interscaling = {'intsqrt', 'intscale', 'intnoscale'};
[flags,~,L]=ltfatarghelper({'L'},definput,varargin);

wt = wfbtinit({'strict',wt},'nat');

if ~isempty(L)
   if L~=wfbtlength(L,wt)
       error(['%s: Specified length L is incompatible with the length of ' ...
              'the time shifts.'],upper(mfilename));
   end;
end


for ii=1:numel(wt.nodes)
   a = wt.nodes{ii}.a;
   assert(all(a==a(1)),sprintf(['%s: One of the basic wavelet ',...
                                'filterbanks is not uniform.'],...
                                upper(mfilename)));
end

% Do the equivalent filterbank using multirate identity property
[gmultid,amultid] = wpfbt2filterbank(wt,flags.interscaling);

if isempty(L)
   L = wfbtlength(max(cellfun(@(gEl) numel(gEl.h),gmultid)),wt);  
end

% Do the equivalent uniform filterbank
[gu,au] = nonu2ufilterbank(gmultid,amultid);

if nargout<2
   AF = filterbankbounds(gu,au,L);
elseif nargout == 2
   [AF, BF] = filterbankbounds(gu,au,L);
end
