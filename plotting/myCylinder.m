function fv = myCylinder(R,N,ori,x,h)
%% [X Y Z] = myCylinder(R,N,ori,x,h) forms the cylinder with origin ori, axis x and length h
% based on the generator curve in the vector R. The cylinder has N points along
% the circumference

% generate unit cylinder along z-axis using matlab function
[X_unit,Y_unit,Z_unit] = cylinder(R,N);

% find rotation matrix
u1 = [0 0 1];
u2=x/norm(x);
M=vrrotvec2mat(vrrotvec(u2,u1));

% rotate scaled points
pts_rot = [X_unit(:) Y_unit(:) h*Z_unit(:)]*M;

% reassemble
X_rot = reshape(pts_rot(:,1),size(X_unit));
Y_rot = reshape(pts_rot(:,2),size(Y_unit));
Z_rot = reshape(pts_rot(:,3),size(Z_unit));

% translate origin
X = X_rot+ori(1);
Y = Y_rot+ori(2);
Z = Z_rot+ori(3);

fv = surf2patch(X,Y,Z);
%%