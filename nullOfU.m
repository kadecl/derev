function x = nullOfU( U )
% n行n列のrank n-1 上三角行列のゼロ空間を求める

[m,n] = size( U );
if( m ~= n )
    warning( 'input matrix is not square' )
end

x = zeros( m,1 );
x(m) = 1;

for i=m-1:-1:1
    x(i) = -U(i,i+1:m) * x(i+1:m) / U(i,i);
end

end