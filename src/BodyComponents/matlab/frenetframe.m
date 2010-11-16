function [kappa,tau,T,N,B,s,ds] = frenetframe(X,th)
% [kappa,tau,l,T,N,B] = frenetframe(X,s)
% Compute the Frenet Frame/curvatures of the curve described by the polyline
% in X.
% INPUT: X, a polyline X = [x1,y1,z2; x2,y2,z2; ....; xN,yN,zN]
% th: threshold
% OUTPUT:
% kappa,tau, the (UNSIGNED) curvature and torsion
% T,N,B the Frenet frame
%
%
% NOTE: the FF doesn't always exist, the torsion is not defined
% when kapp = 0, here it gets interpolated;
% and the polyline should be filtered for consecutive
% identical points.
% EXAMPLE:
% t = linspace(0,2*pi,50);
% X3d = [cos(t),sin(t),t];
% frenetframe(X3d); % 1: use better definition of frame

if nargin < 2
th = 0.001
end

T = diff(X); % dX/dt

ds = sqrt(sum(T.*T,2)); % already esnured that no ds is zero
s = cumsum(ds); %

T = T./ds(:,[1,1,1]); % T = dX/ds = dX/dt.*dt/ds =
N = diff(T); % N // dT
T(end,:) = [];
ds(end) = [];
kappa = sqrt(sum(N.*N,2)); % |N|
nkz = find(kappa > -1);

N(nkz,1) = N(nkz,1)./kappa(nkz); % |N| = 1
N(nkz,2) = N(nkz,2)./kappa(nkz);
N(nkz,3) = N(nkz,3)./kappa(nkz);
% should interpolate N otherwise
kappa = kappa./ds; % N = kappa*dT/ds
B = cross(T,N); % B = T x N
nB = sqrt(sum(B.*B,2));
B(nkz,1) = B(nkz,1)./nB(nkz);
B(nkz,2) = B(nkz,2)./nB(nkz);
B(nkz,3) = B(nkz,3)./nB(nkz);
N = cross(B,T); % renormalise Frenet Frame
dB = diff(B); ldB = length(dB);
dB = dB./ds(1:ldB,[1,1,1]); % dB/ds
corr = sum(dB.*B(1:end-1,:),2); % dB perp B
dB = dB - repmat(corr,1,3).*B(1:end-1,:);
kappa(end) = [];
T(end,:) = [];
N(end,:) = [];
ds(end-1:end) = [];
tau = sum(-dB.*N(1:ldB,:),2); % tau = -dB*N/ds = dN*B/ds

kz = find(kappa < th);
t = 1:length(kappa);
t2 = t'; t2(kz) = [];
tau = interp1(t2,tau(t2),t,'pchip',0)';

if nargout == 0
figure
quiver3(X(1:length(B),1),X(1:length(B),2),X(1:length(B),3),B(:,1),B(:,2),B(:,3),0,'g');
hold on
quiver3(X(1:length(T),1),X(1:length(T),2),X(1:length(T),3),T(:,1),T(:,2),T(:,3),0);
quiver3(X(1:length(N),1),X(1:length(N),2),X(1:length(N),3),N(:,1),N(:,2),N(:,3),0,'r');
axis vis3d;
axis off;
box on
end


