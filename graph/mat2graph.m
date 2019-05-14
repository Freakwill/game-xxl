function g=mat2graph(A,crd)

n=size(A,1);

if nargin==1;
    for k=1:n
        nodes{k}=struct('id',sprintf('v%d',k));
    end
else
    for k=1:n
        nodes{k}=struct('id',sprintf('v%d',k),'crd',crd(:,k));
    end
end
edges={};
for i=1:n
    for j=1:n
        if A(i,j)~=inf
            edges=[edges,struct('from',nodes{i},'to',nodes{j},'weight',A(i,j))];
        end
    end
end

g=Graph(nodes,edges);