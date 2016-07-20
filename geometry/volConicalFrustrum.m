function vol = volConicalFrustrum(R1,R2,h)
% http://mathworld.wolfram.com/ConicalFrustum.html
vol = 1/3*pi*h*(R1^2+R2*R1+R2^2);