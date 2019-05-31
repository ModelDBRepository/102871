function [t,y] = camodel(x,y0,tspan,r)

% CAMODEL   Two-state gating model with CDF
%   [t,y] = camodel(x0,y0,tspan,r)
%
%   Given initial state x0, gating parameters y0, time interval or time
%   points tspan, and cadf (1 = CDF, 0 = no facilitation), returns system
%   output t and y.
%
%   This function is based on the following state model:
% 
% C1 - C2 - C3 - C4 - O1
% C5 - C6 - C7 - C8 - O2
%
% 1: C1, 2: C2, 3: C3, 4: C4, 5: O1, 6: C5, 7: C6, 8: C7, 9: C8, 10: O2
%
% r is the upsampling ratio for tspan

if ~exist('r','var'), r = 1; end

t_r = interp1(1:length(tspan),tspan, ...
    1:1/r:length(tspan),'linear','extrap'); % resampled time

x = abs(x);

k.k12 = x(1); % C1 -> C2
k.k23 = x(2); % C2 -> C3
k.k34 = x(3); % C3 -> C4
k.k43 = x(4); % C4 -> C3
k.k45 = x(5); % C4 -> O1
k.k54 = x(6); % O1 -> C4

k.k67 = x(7); % C5 -> C6
k.k78 = x(8); % C6 -> C7
k.k89 = x(9); % C7 -> C8
k.k98 = x(10); % C8 -> C7
k.k90 = x(11); % C8 -> O2
k.k09 = x(12); % O2 -> C8

k.k50 = x(13); % O1 -> O2

%k.kd = Ca++ dissociation leading to C5 -> C1, C6 -> C2, C7 -> C3 C8 -> C4
k.kd = 0;
k.i = x(14); % inactivation

% transition rates that govern O1 -> O2 transition
alpha = x(15);
beta = x(16);


%    1: C1     2: C2     3: C3      4: C4        5: O1      6: C5       7: C6         8: C7        9: C8        10: O2          
M = [-k.k12      0         0          0              0        k.kd         0            0             0            0;             
      k.k12   -(k.k23)     0          0              0          0         k.kd          0             0            0;              
        0       k.k23   -(k.k34)    k.k43            0          0           0         k.kd            0            0;              
        0        0         k.k34   -(k.k43+k.k45)  k.k54        0           0           0          k.kd            0;              
        0        0         0         k.k45 -(k.k54+0+k.i)   0           0           0             0            0;              
        0        0         0          0              0    -(k.k67+k.kd)     0           0             0            0;              
        0        0         0          0              0       k.k67  -(k.k78+k.kd)       0             0            0;              
        0        0         0          0              0          0        k.k78   -(k.k89+k.kd)     k.k98           0;              
        0        0         0          0              0          0           0         k.k89  -(k.k98+k.k90+k.kd)  k.k09;           
        0        0         0          0           0.0         0           0           0          k.k90      -(k.k09+k.i);];    

NTS = 1; TS=0;
y0 = [y0, NTS, TS];
y = zeros(length(t_r),length(y0));
y(1,:)=y0;
y=y';
for i = 2:length(t_r)
    Mupdate = M;
    Mupdate(5,5) = Mupdate(5,5) - k.k50*(y(12,i-1)^4);
    Mupdate(10,5) = Mupdate(10,5) + k.k50*(y(12,i-1)^4);
    if sum(y(1:5,i-1))==0
        dy = [Mupdate*y(1:10,i-1); 0; 0];
    else
        dy = [Mupdate*y(1:10,i-1); (beta*y(12,i-1)-alpha*y(11,i-1))*y(5,i-1)/sum(y(1:5,i-1)); (-beta*y(12,i-1)+alpha*y(11,i-1))*y(5,i-1)/sum(y(1:5,i-1))];
    end
    y(:,i)= y(:,i-1)+dy*(t_r(i)-t_r(i-1));
end

y_temp = interp1(t_r,y',tspan,'linear','extrap')';

y=y_temp(1:10,:)'; t=tspan;
return


