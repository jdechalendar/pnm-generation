function fv = mySphere(R,N,ori)
%% [X,Y,Z] = mySphere(R,N,ori) generate sphere with N points centered at origin ori and with
% radius R
[X_unit,Y_unit,Z_unit] = sphere(N);

% translate origin and scale correctly
X = R*X_unit+ori(1);
Y = R*Y_unit+ori(2);
Z = R*Z_unit+ori(3);
fv = surf2patch(X,Y,Z);
%%