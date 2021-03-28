function [L,U,P,sgn,rank] = myRank( A, myEps )

switch nargin
    case 1
        myEps  = 1.0e-13;
end        

[r,c] = size( A );
P = eye(r,r);
L = vpa(zeros(r,r));
U = vpa(A);
sgn = 1;
rank = min(r,c);

for i=1:rank %�s�Ɨ�̂������������Ƃ����Ӗ��D
    % search max pivot
    % ����findmax�Ƃ���k������������͂�
    maxval = abs( U(i,i) );
    maxpos = i;
    for j=i+1:c
        % i��ɂ����āAi�s�ȍ~�Ő�Βl���ő�̏ꏊ��T���A
        % ���̃C���f�b�N�X�� maxpos �Ɋi�[
        if (maxval < abs(U(i,j)))
            maxpos = j;
        end
    end
    
    % �����N�������Ă���ꍇ�̑Ώ�
    if maxval < myEps
        rank = i-1;
        fprintf( "rank(A) = %d\n", rank );
        warning( "input matrix is  singular" )
        return
    end
    
    % row exchange
    if( maxpos ~= i )
        % U, P, L �̂��ꂼ��ŁA����̍s����
        vec_exchange = [i,j];
        P(vec_exchange,:) = P(vec_exchange([2,1]),:);
        U(vec_exchange,:) = U(vec_exchange([2,1]),:);
        L(vec_exchange,:) = L(vec_exchange([2,1]),:);
        % https://jp.mathworks.com/matlabcentral/answers/493271-swapping-rows-in-a-matrix
        % sg �̕����𔽓]
        sgn = sgn * -1;
    end
    
    % elimination
    pivot = U(i,i);
    if( abs( pivot ) < myEps )
        return;
    end
    
    for j=i+1:r
        L(j,i) = U(j,i) / pivot;
        U(j,:) = U(j,:) - L(j,i) * U(i,:);
    end
    
end
% �s�����̂Ƃ��Ɏז��ɂȂ�̂ŁAL �̑Ίp�v�f(1)��
% �Ō�ɕt������B(P�̍s�������H�v����΁A�ŏ�����
% �Ίp�v�f��1�����Ă������Ƃ��\)
L = L + eye(r,r);

end
