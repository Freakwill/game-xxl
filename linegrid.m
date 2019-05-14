function hs=linegrid(x,y,parent)
% grid of lines
if nargin==2,parent=gca;
end
if length(x)==1
    x = 0:x;
end
if length(y)==1
    y = 0:y;
end
N=length(x);
for k=1:N
    hs(k)=line('Parent',parent,'XData',[x(k),x(k)],'YData',[y(1),y(end)]);
end

for l=1:length(y)
    hs(N+l)=line('Parent',parent,'XData',[x(1),x(end)],'YData',[y(l),y(l)]);
end