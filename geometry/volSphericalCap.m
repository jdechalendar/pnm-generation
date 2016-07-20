function vol = volSphericalCap(R, alpha)
% from http://mathworld.wolfram.com/SphericalCap.html
vol = 1/3*pi*R^3*(2-3*sin(alpha)+sin(alpha)^3);