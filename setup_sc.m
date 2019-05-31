function [po_model,tspan] = setup_sc(x0i,channel_type,measure_type,prepulse,x0i_c,plt,sf,r)

% SETUP_SC   Sets up conditions and runs sc_err.
%    [po_model,tspan] = setup_sc(x0i,channel_type,measure_type,prepulse,x0i_c,plt,sf,r)
%
%    x0i = initial transition states (1-6 if no cdf, 7-14 if cdf)
%    channel_type = 'ca','ba','ca_efb'
%    measure_type = 'po','poo','fl','ot'
%    prepulse = 'nopre','pre'
%    x0i_c = transition states not to be changed by fminsearch
%    plt = option to plot results (0 for no plot, 1 to plot) - optional
%    sf = starting fractions (i.e. fraction in C2) - optional
%    r = resampling ratio for Euler integration (default is 1) - optional

if ~exist('plt','var')
    plt = 0;
end
if isequal(measure_type,'fl')
    tlim = [0 100];
    fl = 1;
elseif isequal(measure_type,'ot')
    tlim = [0 10];
    fl = -1;
else
    tlim = [0 25];
    fl = 0;
end
if isequal(channel_type,'ca')
    cadf = 1;
    i_x = 7:16;
else
    cadf = 0;
    i_x = 1:6;
end
if ~exist('plt','var')
    plt = 0;
end

if exist('sf','var')
    [c2f,hpof,c2fba,pocfba,flcfba,pocfca,flcfca,pocfbca,flcfbca] = deal(sf.c2f,sf.hpof,sf.c2fba,sf.pocfba,sf.flcfba,sf.pocfca,sf.flcfca,sf.pocfbca,sf.flcfbca);
else
    c2f = .85;
    hpof = .4;
    c2fba = .8;
    pocfba = .932; % P(o) correction factor for EFa Ba++ (based on FL @ 100 msec)
    flcfba = .988; % FL correction factor for EFa Ba++ (based on FL @ 150 msec)
    pocfca = .916; % P(o) correction factor for EFa Ca++ (based on FL @ 100 msec)
    flcfca = .931; % FL correction factor for EFa Ca++ (based on FL @ 150 msec)
    pocfbca = .984; % P(o) correction factor for EFb Ca++ (based on FL @ 100 msec)
    flcfbca = .998; % FL correction factor for EFb Ca++ (based on FL @ 150 msec)
end

if ~exist('r','var'), r = 1; end


switch lower(channel_type)
    case 'ca'
        switch lower(measure_type)
            case 'po'
                switch lower(prepulse)
                    case 'nopre'
                        y0 = [pocfca*[1-c2f c2f]*(1-hpof) 0 0 0 pocfca*[1-c2f c2f]*(hpof) 0 0 0];
                    case 'pre'
                        y0 = [0 0 0 0 0 pocfca*[1-c2f c2f] 0 0 0];
                end
            case 'poo'
                switch lower(prepulse)
                    case 'nopre'
                        y0 = [0 0 0 0 1-hpof 0 0 0 0 hpof];
                    case 'pre'
                        y0 = [0 0 0 0 0 0 0 0 0 1];
                end
            case 'fl'
                switch lower(prepulse)
                    case 'nopre'
                        y0 = [flcfca*[1-c2f c2f]*(1-hpof) 0 0 0 flcfca*[1-c2f c2f]*(hpof) 0 0 0];
                    case 'pre'
                        y0 = [0 0 0 0 0 flcfca*[1-c2f c2f] 0 0 0];
                end
            case 'ot'
                y0 = [0 0 0 0 0 0 0 0 0 1];
        end
    case 'ba'
        switch lower(measure_type)
            case 'po'
                y0 = [pocfba*[1-c2fba c2fba] 0 0 0 0 0 0 0 0];
            case 'poo'
                y0 = [0 0 0 0 1 0 0 0 0 0];
            case 'fl'
                y0 = [flcfba*[1-c2fba c2fba] 0 0 0 0 0 0 0 0];
            case 'ot'
                y0 = [0 0 0 0 1 0 0 0 0 0];
        end
    case 'ca_efb'
        switch lower(measure_type)
            case 'po'
                y0 = [pocfbca*[1-c2f c2f] 0 0 0 0 0 0 0 0];
            case 'poo'
                y0 = [0 0 0 0 1 0 0 0 0 0];
            case 'fl'
                y0 = [flcfbca*[1-c2f c2f] 0 0 0 0 0 0 0 0];
            case 'ot'
                y0 = [0 0 0 0 1 0 0 0 0 0];
        end
        
end

%load it in
time = load(['t_' measure_type '.txt']);
ind=find(time>=tlim(1)&time<=tlim(2));
tspan=time(ind);
if plt >= 1
    tspan = time;
    [po_model] = sc_run(x0i,y0,tspan,cadf,fl,i_x,x0i_c,r);
    plot(time,po_model(:,5)+po_model(:,10),'r','linewidth',1)
    title([measure_type ' for ' channel_type ', ' prepulse],'verticalalignment','middle','interpreter','none')
    if isequal(measure_type,'poo'), axis([0 150 0 .2]); end
    if isequal(measure_type,'po')
        if isequal(channel_type,'ca'), axis([0 150 0 .2]);
        else axis([0 150 0 .1]);
        end
    end
    if isequal(measure_type,'fl'), axis([0 200 0 1]); end
    if isequal(measure_type,'ot'), axis([0 10 0 1]); end
    if ~isequal(channel_type,'ca') | isequal(prepulse,'nopre') & ~isequal(measure_type,'ot')
        set(gca,'xticklabel',[])
    end
else
    [po_model] = sc_run(x0i,y0,tspan,cadf,fl,i_x,x0i_c,r);
end









function y = sc_run(x0i,y0,tspan,cadf,fl,i_x,x0i_c,r)

% SC_RUN   Sets up transition variables and runs CAMODEL.
%    [err,y] = sc_run(x0i,y0,tspan,cadf,fl,i_x,x0i_c,r)
%
%    Given x0i that correspond to the indices i_x of the 14 transition
%    rates used to construct the M matrix, x0i_c (optional) that
%    correspond to the remaining variables, y0 that is the initial
%    conditions, tspan to be used by camodel, cadf (1 for cdf, 0 for none),
%    and fl (1 for fl, which allows no transitions out of open states, 0
%    for no fl), runs camodel to generate y (state variables over time) and
%    err (squared error between what the model returns as the open
%    probability over time and po, which is the actual data).


if exist('i_x','var')
    % i_x specifies which x0(i) should be used.
    x0 = zeros(1,16);
    x0(i_x) = x0i;
else
    x0 = x0i;
end
if exist('x0i_c','var')
    % x0i_c specifies additional x0 that are constants that you don't want
    % fminsearch to modify.
    z=1:16;
    z(i_x)=0;
    x0(find(z~=0)) = x0i_c;
end
if ~exist('r','var'), r = 1; end


if cadf == 0
    x0(13) = 0; % O1 -> O2
end
if fl == 1
    x0(13) = 0; % O1 -> O2
    x0(6) = 0; % O1 -> C4
    x0(12) = 0; % O2 -> C8
%     x0(14) = 0; % O2 -> O1
    x0(14) = 0; % inactivation
end
if fl == -1 % for open times
    x0(5) = 0; % C4 -> O1
    x0(11) = 0; % C8 -> O2
end


[t,y] = camodel(x0,y0,tspan,r);


return
















