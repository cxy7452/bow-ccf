%linTransform.m
%
%find the parameters for a linear transformation

function [a, b] = linTransform( minX, maxX, newMin, newMax)

%transform from minX -> newMin, and maxX -> newMax
a = (newMax-newMin)/(maxX-minX);
b = newMin-a*minX;