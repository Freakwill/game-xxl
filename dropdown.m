function B=dropdown(A)
[m,n]=size(A);
B=zeros(m,n);
for j=1:n
    k=m;
    for i=m:-1:1
        if A(i,j)~=0
            B(k,j)=A(i,j);
            k=k-1;
        end
    end
end