%% 已知两条直线的斜率和截距，求交点坐标
function [x,y]=point_of_two_line(k1,b1,k2,b2)
  x=[];
  y=[];
  if k1==k2&&b1==b2
      disp('chong he');
  elseif k1==k2&&b1~=b2
      disp('wu jiao dian');
  else
     x=(b2-b1)/(k1-k2);
     y=k1*x+b1;
%   disp('x=');
%   disp(x);
%   disp('y=');
%   disp(y);
  end