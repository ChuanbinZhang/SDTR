function [y, S, evs, cs] = CLR(A0, c, NITER)
% min_{S>=0, S*1=1, F'*F=I}  ||S - A||^2 + r*||S||^2 + 2*lambda*trace(F'*L*F)
% A0: the given affinity matrix
% c: cluster number
% S: learned symmetric similarity matrix
% evs: eigenvalues of learned graph Laplacian in the iterations
% cs: suggested cluster numbers, effective only when the cluster structure is clear

% Ref:
% Feiping Nie, Xiaoqian Wang, Michael I. Jordan, Heng Huang.
% The Constrained Laplacian Rank Algorithm for Graph-Based Clustering.
% The 30th Conference on Artificial Intelligence (\textbf{AAAI}), Phoenix, USA, 2016.

zr = 10e-11;
lambda = 0.1;

if nargin < 3
    NITER = 30;
end

A0 = A0-diag(diag(A0));
num = size(A0,1);
A10 = (A0+A0')/2;
D10 = diag(sum(A10));
L0 = D10 - A10;

% automatically determine the cluster number
[F0, ~, evs]=eig1(L0, num, 0);
a = abs(evs); 
a(a<zr)=eps; 
ad=diff(a);

ad1 = ad./a(2:end); 
ad1(ad1>0.85)=1; 
ad1 = ad1+eps*(1:num-1)'; 
ad1(1)=0; 
ad1 = ad1(1:floor(0.9*end));

[te, cs] = sort(ad1,'descend');
if nargin == 1
    c = cs(1);
end
F = F0(:,1:c);
if sum(evs(1:c)) < zr
    S = A0;
    [clusternum, y]=graphconncomp(sparse(S)); y = y';
    return;
end


for iter = 1:NITER
    dist = pdist2(F, F, 'squaredeuclidean');
    S = zeros(num);
    for i=1:num
        ai = A0(i,:);
        di = dist(i,:);
        ad = ai-0.5*lambda*di;
        S(i,:) = EProjSimplex(ad);
    end
    S = (S+S')/2;
    D = diag(sum(S));
    L = D-S;
    F_old = F;
    [F, ~, ev]=eig1(L, c, 0);
    evs(:,iter+1) = ev;

    fn1 = sum(ev(1:c));
    fn2 = sum(ev(1:c+1));
    if fn1 > zr
        lambda = 2*lambda;
    elseif fn2 < zr
        lambda = lambda/2;  F = F_old;
    else
        break;
    end
end

[clusternum, y]=graphconncomp(sparse(S)); y = y';
