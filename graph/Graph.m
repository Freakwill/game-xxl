classdef Graph
    %  Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        nodes={};
        edges={};
        haxes=0;
    end
    
    methods
        function obj = Graph(nodes, edges)
            if nargin<=1
                edges={};
                if nargin==0
                    nodes={};
                end
            end
            obj.nodes = nodes;
            obj.edges = edges;
        end
        
        function n=size(obj)
            n=length(obj.edges);
        end
        
        function n=order(obj)
            n=length(obj.nodes);
        end
        
        function tf = isnode(obj, node)
            tf=false;
            for k =1:length(obj.nodes)
                if nodeeq(node, obj.nodes{k})
                    tf=true;
                end
            end
        end
        
        function tf = isedge(obj, edge)
            tf=false;
            for k =1:length(obj.edges)
                if nodeeq(edge.from, obj.edges{k}.from) && nodeeq(edge.to, obj.edges{k}.to)
                    tf=true;
                end
            end
        end
        
        function obj = add_node(obj, node)
            % add a node or some nodes to graph
            if iscell(node)
                for k = 1:length(node)
                    obj=obj.add_node(node{k});
                end
            else
                if ~obj.isnode(node)
                    obj.nodes = [obj.nodes, node];
                end
                % obj=obj.add_edge({edge.from, edge.to});
            end
        end
        
        function obj = add_edge(obj, edge)
            % add a edge or some edges to graph (including the nodes of edges)
            if iscell(edge)
                for k = 1:length(edge)
                    obj=obj.add_edge(edge{k});
                end
            else
                if ~obj.isedge(edge)
                    obj.edges = [obj.edges, edge];
                end
                obj=obj.add_node({edge.from, edge.to});
            end
        end
        
        function obj = add_star(obj, star, weights)
            % add a star (out-star)
            L=length(star);
            if nargin<=2
                weights = ones(1,L-1);
            else
                if isscalar(weights)
                    weights = weights * ones(1,L-1);
                end
            end
            obj=obj.add_node(star);
            for k=2:L
                edge=struct('from',star{1},'to',star{k},'weight',weights(k-1));
                obj=obj.add_edge(edge);
            end
        end
        
        function obj = add_instar(obj, star, weight)
            % add in-star
            L=length(star);
            if nargin<=2
                weight = ones(1,L-1);
            else
                if isscalar(weight)
                    weight = weight * ones(1,L-1);
                end
            end
            obj=obj.add_node(star);
            for k=1:L-1
                edge=struct('from',star{k},'to',star{L},'weight',weight(k));
                obj=obj.add_edge(edge);
            end
        end
        
        function nodes = successors(obj, node, except)
            if nargin<=2
                except={};
            end
            nodes={};
            if iscell(node)
                for k =1:length(node)
                    nodes=[nodes, obj.successors(node{k},except)];
                end
            else
                for k = 1:obj.size()
                    edge = obj.edges{k};
                    if nodeeq(edge.from, node) && ~nodein(edge.to, except)
                        nodes=[nodes, edge.to];
                    end
                end
            end
        end
        
        function nodes = predecessors(obj, node, except)
            if nargin<=2
                except={};
            end
            nodes={};
            if iscell(node)
                for k =1:length(node)
                    nodes=[nodes, obj.predecessors(node{k}, except)];
                end
            else
                for k = 1:obj.size()
                    edge = obj.edges{k};
                    if nodeeq(edge.to, node)&& ~nodein(edge.from, except)
                        nodes=[nodes, edge.from];
                    end
                end
            end
        end
        
        function nodes= neighbours(obj, node, except)
            if nargin<=2
                except={};
            end
            nodes= [obj.predecessors(node, except),obj.successors(node, except)];
        end
        
        function edges = inedges(obj, node, except)
            if nargin<=2
                except={};
            end
            edges={};
            if iscell(node)
                for k =1:length(node)
                    edges=[egdes, obj.inedges(node{k}, except)];
                end
            else
                for k = 1:obj.size()
                    edge = obj.edges{k};
                    if nodeeq(edge.to, node) && ~nodein(edge.from, except)
                        edges=[edges, edge];
                    end
                end
            end
        end
        
        function edges = outedges(obj, node, except)
            if nargin<=2
                except={};
            end
            edges={};
            if iscell(node)
                for k =1:length(node)
                    edges=[egdes, obj.outedges(node{k}, except)];
                end
            else
                for k = 1:obj.size()
                    edge = obj.edges{k};
                    if nodeeq(edge.from, node)&& ~nodein(edge.to, except)
                        edges=[edges, edge];
                    end
                end
            end
        end
        
        function obj = set_edge(obj, edge,varargin)
            for k = 1:obj.size()
                if nodeeq(obj.edges{k}.from,edge.from) && nodeeq(obj.edges{k}.to,edge.to)
                    for j=1:2:length(varargin)-1
                        obj.edges{k}.(varargin{j})=varargin{j+1};
                    end
                end
            end
        end
        
        function obj = set_node(obj, node,varargin)
            for k = 1:length(obj.nodes)
                if nodeeq(obj.nodes{k},node)
                    for j=1:2:length(varargin)-1
                        obj.nodes{k}.(varargin{j})=varargin{j+1};
                    end
                end
            end
        end
        
        function edges = alledges(obj, node)
            edges={};
            if iscell(node)
                for k =1:length(node)
                    edges=[egdes, obj.alledges(node{k})];
                end
            else
                for k = 1:obj.size()
                    edge = obj.edges{k};
                    if nodeeq(edge.from, node) || nodeeq(edge.to, node)
                        edges=[edges, edge];
                    end
                end
            end
        end
        
        function tf = isterminal(obj, node)
            if nargin<=1
                node=obj.current_node;
            end
            tf= isempty(obj.successors(node));
        end
        
        function tf = isinitial(obj, node)
            tf= isempty(obj.predecessors(node));
        end
        
        function obj=minus(obj, node)
            if iscell(node)
                for k=1:length(node)
                    obj=obj-node{k};
                end
            else
                for k = 1:length(obj.nodes)
                    if nodeeq(obj.nodes{k}, node)
                        obj.nodes(k)=[];break;
                    end
                end
                del=[];
                for k = 1:obj.size()
                    edge = obj.edges{k};
                    if nodeeq(edge.from, node) || nodeeq(edge.to, node)
                        del=[del,k];
                    end
                end
                obj.edges(del)=[];
            end
        end
        
        function tf=isconnected(obj, start, terminal, exclude)
            if nargin<=3
                exclude={start};
            end
            if nodeeq(start, terminal)
                tf=true;
            else
                tf=false;
                nodes=obj.neighbours(start);
                for k=1:length(nodes)
                    node=nodes{k};
                    if ~nodein(node, exclude)
                        node=nodes{k};
                        exclude = [exclude,node];
                        if obj.isconnected(node, terminal, exclude)
                            tf = true;
                            return;
                        end
                    end
                end
            end
        end
                
        function [tree,htree]=deeptree(obj,start,demo)
            if nargin==2
                demo=false;
            end
            if demo
                obj.draw();
                htree=[];
                text('Parent',obj.haxes,'Position',start.crd,'String','1','Color','r','FontSize',16);
                no=1;
            end
            current_node=start;
            current_list={start};
            nodes={start};
            while true
                current_node = current_list{end};
                edges = obj.outedges(current_node);
                flag = true;
                for k = 1:length(edges)
                    edge = edges{k};
                    if ~nodein(edge.to, nodes)
                        current_node=edge.to;
                        current_list=[current_list, current_node];
                        nodes=[nodes, current_node];
                        flag = false;
                        if demo
                            no = no +1;
                            text('Parent',obj.haxes,'Position',current_node.crd,'String',sprintf('%d', no),'Color','r','FontSize',16);
                            htree=[htree,line('Parent',obj.haxes,'XData',[edge.from.crd(1),current_node.crd(1)],'YData',[edge.from.crd(2),current_node.crd(2)],'Color','r')];
                            pause(1)
                        end
                        break;
                    end
                end
                if flag
                    current_list(end)=[];
                end
            end
        end
        
%         function tree=deeptree(obj,start)
%             if nargin==1
%                 start=obj.nodes{1};
%             end
%             
%             edges=obj.outedges(start);
%             if isempty(edges);
%                 tree=Graph({start});
%                 return;
%             end
%             edge=edges{1};
%             next=edge.to;
%             sub=obj-start;
%             tree = sub.deeptree(next);
%             for k=2:length(edges)
%                 if ~tree.isnode(edges{k}.to)
%                     tree=tree.add_edge(edges{k});
%                 end
%             end
%             tree = tree.add_edge(edge);
%         end
        
        function [tree,htree]=widetree(obj, start, demo)
            if nargin==2
                demo=false;
            end
            if demo
                obj.draw();
                htree=[];
                text('Parent',obj.haxes,'Position',start.crd,'String','1','Color','r','FontSize',16);
                no=1;
            end
            current_nodes={start};
            nodes={start};
            tree=Graph(nodes);
            while true
                new_nodes={};
                flag=true;
                no = no+1;
                for k=1:length(current_nodes)
                    current_node=current_nodes{k};
                    edges=obj.outedges(current_node);
                    for i=1:length(edges)
                        edge=edges{i};
                        if ~nodein(edge.to, nodes)
                            tree=tree.add_edge(edge);
                            nodes=[nodes,edge.to];
                            new_nodes=[new_nodes, edge.to];
                            flag=false;
                            if demo
                                text('Parent',obj.haxes,'Position',edge.to.crd,'String',sprintf('%d', no),'Color','r','FontSize',16);
                                htree=[htree,line('Parent',obj.haxes,'XData',[edge.from.crd(1),edge.to.crd(1)],'YData',[edge.from.crd(2),edge.to.crd(2)],'Color','r')];
                                pause(.3)
                            end
                        end
                    end
                    if demo
                        pause(1);
                    end
                end
                if flag
                    break;
                else
                    current_nodes=new_nodes;
                end
            end
        end
        
        function [tree,htree]=kruskal(obj, demo)
            if nargin==1
                demo=false;
            end
            N=length(obj.nodes);
            if N==1;
                tree=Graph(obj.nodes);
                return
            end
            for k = 1:obj.size
                w(k)=obj.edges{k}.weight;
            end
            [w,ind]=sort(w); edges=obj.edges(ind); edge=edges{1};
            tree=Graph();tree = tree.add_edge(edge);
            n=1;
            if demo
                obj.draw();
                htree=line('Parent',obj.haxes,'XData',[edge.from.crd(1), edge.to.crd(1)],'YData',[edge.from.crd(2), edge.to.crd(2)],'Color','r','LineWidth',2);
                pause(1)
            end
            fprintf('%s-%s %d:%d\n',edge.from.id, edge.to.id,n,N)
            for k = 2:obj.size
                edge=edges{k};
                if ~tree.isnode(edge.to) || ~tree.isnode(edge.from) || ~tree.isconnected(edge.to, edge.from)
                    tree.isnode(edge.to)
                    tree.isnode(edge.from)
                    tree.isconnected(edge.to, edge.from)
                    tree = tree.add_edge(edge);
                    n=n+1;
                    if demo
                        htree=[htree,line('Parent',obj.haxes,'XData',[edge.from.crd(1), edge.to.crd(1)],'YData',[edge.from.crd(2), edge.to.crd(2)],'Color','r','LineWidth',2)];
                        pause(1)
                    end
                    fprintf('%s-%s %d:%d\n',edge.from.id, edge.to.id,n,N)
                    if n==N-1
                        return;
                    end
                end
            end
        end
       
        function [val, path] = get_value(obj, node)
            % get the optimal path and its value
            % no cycle in graph
            if obj.isterminal(node)
                val = 0;
                path = {};
            else
                edges = obj.outedges(node);
                [v, p]=obj.get_value(edges{1}.to);
                val = edges{1}.weight + v;
                path = [{edges{1}},p];
                for k= 2:length(edges)
                    [v, p]=obj.get_value(edges{k}.to);
                    newval = edges{k}.weight + v;
                    if val > newval
                        val = newval;
                        path = [edges(k),p];
                    end
                end
            end
        end
        
        function [val, path] = get_value2(obj, node)
            % get the optimal path and its value
            if isinitial(obj, node)
                val = 0;
                path = {};
            else
                edges = obj.inedges(node);
                [v, p]=obj.get_value2(edges{1}.from);
                val = v+edges{1}.weight;
                path = [p,edges{1}];
                for k= 2:length(edges)
                    [v, p]=obj.get_value2(edges{k}.from);
                    newval = v + edges{k}.weight;
                    if val > newval
                        val = newval;
                        path = [p,edges{k}];
                    end
                end
            end
        end
        
        function [paths, hlabel]=dijkstra(obj, start, demo)
            % Dijkstra Algrithom
            % find the shortest path from start to others
            if nargin==2,demo=false;
            end
            Plist={start};             % start is labeled by P
            if demo
                obj.draw();
                hlabel=text('Parent',obj.haxes,'Position',start.crd,'String','P','Color','r','FontSize',16);
                hp=[];
                pause(1)
            end
            paths = {struct('node',start,'length',0,'path',start)};
            
            Tlist={};
            current_nodes ={start};
            current_paths={start};
            current_value=0;
            while true
                for i=1:length(current_nodes)
                    current=current_nodes{i};
                    current_path=current_paths{i};
                    edges = obj.outedges(current);
                    for k = 1:length(edges)
                        e = edges{k};
                        n = e.to;
                        if ~nodein(n, Plist)
                            ind=0;
                            for k=1:length(paths)
                                if nodeeq(paths{k}.node, n)
                                    ind=k;break
                                end
                            end
                            if ind ~= 0
                                if paths{k}.length>current_value + e.weight
                                    paths{k}.path=[current_path, n];
                                    paths{k}.length = current_value + e.weight;
                                end
                            else
                                paths = [paths, struct('node',n,'length',current_value + e.weight,'path',[current_path, n])];
                            end
                            % n is labeled by T
                            Tlist=[Tlist, n];
                            if demo
                                hlabel=[hlabel, text('Parent',obj.haxes,'Position',n.crd,'String','T','Color','g','FontSize',16)];
                                hp=[hp,line('Parent',obj.haxes,'XData',[current.crd(1),n.crd(1)],'YData',[current.crd(2),n.crd(2)],'Color','g','LineWidth',3,'LineStyle','--')];
                                pause(.1)
                            end
                        end
                    end
                end
                if isempty(Tlist)
                    return;
                end
                v=[];
                last={};
                ps={};
                for t=1:length(Tlist)
                    for k=1:length(paths)
                        if nodeeq(paths{k}.node, Tlist{t})
                            v=[v,paths{k}.length];
                            last=[last,paths{k}.path(end-1)];
                            ps=[ps,paths{k}.path];
                            break
                        end
                    end
                end
                [vm,k]=min(v);ks=find(vm==v);
                for k=ks
                    pause(.5)
                    hp=[hp,line('Parent',obj.haxes,'XData',[last{k}.crd(1),Tlist{k}.crd(1)],'YData',[last{k}.crd(2),Tlist{k}.crd(2)],'Color','r','LineWidth',3)];
                    hlabel=[hlabel, text('Parent',obj.haxes,'Position',Tlist{k}.crd,'String','P','Color','r','FontSize',16)];
                    pause(1)
                end
                current_nodes=Tlist(ks);
                current_paths=ps(ks);
                Plist=[Plist, Tlist(ks)];    % ns{k} is labeled by P
                Tlist(ks)=[];
                % delete(hp(ks));hp(ks)=[];
                current_value=vm;
            end
        end

        
        function [he, hn, hw]=draw(obj, haxes)
            if nargin==1
                haxes=obj.haxes;
                if isempty(haxes);
                    haxes=gca;
                end
            end
            X=[]; Y=[];
            for k=1:length(obj.nodes)
                node=obj.nodes{k};
                X=[X,node.crd(1)];
                Y=[Y,node.crd(2)];
            end
            a = min(X); b= max(X);
            dx = (b - a)/20;
            c = min(Y); d= max(Y);
            dy = (d - c)/20;
            set(haxes,'XLim',[a-dx,b+dx],'YLim',[c-dy,d+dy]);
            % need field crd: coordinate of node
            he=[];hn=[];hw=[];
            % draw edges
            for k=1:obj.size()
                edge = obj.edges{k};
                fromnode = edge.from;
                tonode = edge.to;
                he=[he,line('Parent',haxes,'XData',[fromnode.crd(1),tonode.crd(1)],'YData',[fromnode.crd(2),tonode.crd(2)],'Marker','o','Color','b')];
                if isfield(edge,'weight')
                    hw=[hw,text('Parent',haxes,'String',num2str(edge.weight),'Position',(fromnode.crd*2+tonode.crd)/3,'FontSize',14,'Color','k')];
                end
            end
            % draw nodes
            for k=1:length(obj.nodes)
                node=obj.nodes{k};
                hn=[hn,text('Parent',haxes,'String',node.id,'Position',node.crd,'FontSize',18,'Color','b')];
            end
        end
    end
    
   methods (Static=true)
        function g=fromstages(stages, N, policies)
            % stages -> graph
            g=Graph();
            n=length(stages);
            M=max(N);
            from=(1:N(1))/(N(1)+1)*(M-1);
            for k=1:n-1
                p=policies{k};
                [r,c]=size(p);
                edges={};
                for i=1:r
                    for j=1:c
                        if N(k+1)==M,
                            to=0:(M-1);
                        else
                            to=(1:N(k+1))/(N(k+1)+1)*(M-1);
                        end
                        if p(i,j)~=inf
                            edge=struct('from',struct('id',sprintf('%s_%d',stages{k},i),'crd',[k,from(i)]),'to',struct('id',sprintf('%s_%d',stages{k+1},j),'crd',[k+1,to(j)]),'weight',p(i,j));
                            edges=[edges, edge];
                        end
                    end
                end
                g=g.add_edge(edges);
                from=to;
            end
       end
   end
end

function tf=nodeeq(n1,n2)
try
    tf=strcmpi(n1.id,n2.id);
catch
    tf = all(all(n1.data==n2.data));
end
end

function tf=nodein(n1,nlist)
tf = false;
for k=1:length(nlist)
    if nodeeq(n1,nlist{k})
        tf = true;
    end
end
end