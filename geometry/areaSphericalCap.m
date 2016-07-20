function A = areaSphericalCap(R, alpha)
% from http://mathworld.wolfram.com/SphericalCap.html with a=R*cos(alpha)
% and h = R*(1-sin(alpha)) -- A = pi*(a^2+h^2)
A = pi*R^2*(cos(alpha)^2+(1-sin(alpha))^2);
