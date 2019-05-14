function [A, score]=eliminate(A)
score=0;
[m,n]=size(A);
while true
    nscore=0;
    B=zeros(m,n);
    for i=1:m
        j=1;
        while j<=n-2
            if A(i,j)~=0
                if A(i,j+1)==A(i,j)
                    if A(i,j+2)==A(i,j)
                        k=3;
                        while j+k<=n && A(i,j)==A(i,j+k)
                            k=k+1;
                        end
                        B(i,j:j+k-1)=1;
                        j=j+k;
                        nscore=nscore + k; % k -> score
                    else
                        j=j+2;
                    end
                else
                    j=j+1;
                end
            else
                j=j+1;
            end
        end
    end
    
    for j=1:n
        i=1;
        while i<=m-2
            if A(i,j)~=0
                if A(i+1,j)==A(i,j)
                    if A(i+2,j)==A(i,j)
                        k=3;
                        while i+k<=m && A(i,j)==A(i+k,j)
                            k=k+1;
                        end
                        B(i:i+k-1,j)=1;
                        i=i+k;
                        nscore=nscore + k; % k -> score
                    else
                        i=i+2;
                    end
                else
                    i=i+1;
                end
            else
                i=i+1;
            end
        end
    end
    if nscore > 0
        A(B==1)=0;
        A=dropdown(A);
        score = score + nscore;
    else
        return
    end
end