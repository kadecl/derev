tStart = tic;
Len = 1000;
t_svd = 0;
t_lu = 0;
for i = 1:5
G =rand( Len, Len-1) * rand( Len-1, Len );
tic
x = null( G );
t_svd = t_svd + toc;
tic
[L,U] = lu( G );
temp_x = nullOfU( U );
t_lu = t_lu + toc;

x = x / max(abs(x)); temp_x = temp_x / max(abs(temp_x));
figure
subplot(2,1,1); plot( x );
subplot(2,1,2); plot( temp_x );
l = max( size( x ) );
title( sprintf("%4.2f, %4.2f", norm( x - temp_x )/l, norm( x + temp_x )/l ));
end
disp( t_svd );
disp( t_lu );

%{
1.6522e+03
   53.8757
%}