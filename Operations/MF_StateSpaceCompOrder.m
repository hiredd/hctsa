% MF_StateSpaceCompOrder
% 
% Fits state space models using n4sid (from Matlab's System Identification
% Toolbox) of orders 1, 2, ..., maxorder and returns statistics on how the
% goodness of fit changes across this range.
% 
% c.f., MF_CompareAR -- does a similar thing for AR models
% Uses the functions iddata, n4sid, and aic from Matlab's System Identification
% Toolbox
% 
% INPUTS:
% y, the input time series
% maxorder, the maximum model order to consider.
% 

function out = MF_StateSpaceCompOrder(y,maxorder)
% Ben Fulcher, 12/2/2010

% Maximum model order, maxorder (compare models from order 1 up to
%           this)
if nargin < 2 || isempty(maxorder)
    maxorder = 10;
end
% orders = 1:maxorder;

%% Preliminaries
N = length(y); % The length of the time series

% Convert y to time series object
if ~exist('iddata')
    error('System Identification Toolbox needs to be installed');
end
y = iddata(y,[],1);

%% Fit the state space models, returning basic fit statistics as we go
% Initialize statistics -- all within-sample statistics. Could also fit on
% a portion and then predict on another...

% noisevars = zeros(maxorder,1); % Noise variance -- for us the same as
% loss fn
lossfns = zeros(maxorder,1); % Loss function
fpes = zeros(maxorder,1); % Akaike's final prediction error
aics = zeros(maxorder,1); % Akaike's information criterion
% bics = zeros(maxorder,1); % Bayesian information criterion


for k = 1:maxorder
    % Fit the state space model for this order, k
    try
        m = n4sid(y,k);
    catch emsg
        error('Model fitting failed for k = %u',k)
    end
    
    lossfns(k) = m.EstimationInfo.LossFcn;
    fpes(k) = m.EstimationInfo.FPE;
    aics(k) = aic(m);
    
    np = length(m.ParameterVector);
%     bics(k) = aics(k) - 2*np + np*log(N); % scrappy and probably wrong
end

% Optimum model orders
out.minaic = min(aics);
out.aicopt = find(aics == min(aics), 1, 'first');
% out.minbic = min(bics);
% out.bicopt = find(bics == min(bics), 1, 'first');
out.minlossfn = min(lossfns);
out.lossfnopt = find(lossfns == min(lossfns), 1, 'first');

% Parameters at order 2
out.aic2 = aics(2);
% out.bic2 = bics(2);
out.fpe2 = fpes(2);
out.lossfn2 = lossfns(2);

% Curve change summary statistics
out.meandiffaic = mean(diff(aics));
out.maxdiffaic = max(diff(aics));
out.mindiffaic = min(diff(aics));
out.ndownaic = sum(diff(aics) < 0);


end