classdef  Game < DynamicGraph
    %  Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        rows
        cols
        colors
        template='½»»» (%d, %d) Óë (%d, %d)';
        init_form
        symbols = 'ABCDEFGHIJKL';
        N = 7;
    end
    
    methods
        function obj = Game(rows, cols, haxes, varargin)
            obj = obj@DynamicGraph(varargin{:});
            obj.rows = rows;
            obj.cols = cols;
            obj.haxes = haxes;
        end
        
        function s=action2str(obj, action)
            s=sprintf(obj.template, action(1,1),action(1,2),action(2,1),action(2,2));
        end
        
        function obj=init(obj) 
            obj.nodes={};
            obj.current_node=struct('id','start','data',randi([1, obj.N],obj.rows,obj.cols));
            obj.init_form=obj.current_node;
        end
        
        function obj=reset(obj) 
            obj.nodes={};
            obj.current_node=obj.init_form;
        end
        
        function [obj,v]=start(obj)
            [start,v]=eliminate(obj.current_node.data);
            obj.start_node=struct('id','start','data',start);
            obj.nodes={obj.start_node};
            obj.current_node=obj.start_node;
        end
        
        function actions = get_actions(obj, node)
            if nargin<=1
                node=obj.current_node;
            end
            actions={};
            data=node.data;
            for i=1:obj.rows
                for j=1:obj.cols-1
                    if data(i,j)~=0 && data(i,j+1)~=0 && data(i,j)~=data(i,j+1)
                        data(i,[j,j+1])=data(i,[j+1,j]);
                        if ~isterminal(data)
                            actions=[actions,[i,j;i,j+1]];
                        end
                        data(i,[j,j+1])=data(i,[j+1,j]);
                    end
                end
            end
            for j=1:obj.cols
                for i=1:obj.rows-1
                    if data(i,j)~=0 && data(i+1,j)~=0 && data(i,j)~=data(i+1,j)
                        data([i,i+1],j)=data([i+1,i],j);
                        if ~isterminal(data),
                            actions=[actions,[i,j;i+1,j]];
                        end
                        data([i,i+1],j)=data([i+1,i],j);
                    end
                end
            end
        end
        
        function [newnode, score] = get_result(obj, action, node)
            % get result of action of a node and the wight
            % action should be in obj.get_actions(node)
            if nargin<=2
                node=obj.current_node;
            end
            data = node.data;
            tmp = data(action(1,1),action(1,2));
            data(action(1,1),action(1,2)) = data(action(2,1),action(2,2));
            data(action(2,1),action(2,2))=tmp;
            [data, score]=eliminate(data);
            newnode = struct('data',data);
        end
        
%         function [nodes, scores] = new_successors(obj, node)
%             actions={};
%             data=node.data;
%             for i=1:obj.rows
%                 for j=1:obj.cols-1
%                     if data(i,j)~=0 && data(i,j)~=data(i,j+1)
%                         data(i,[j,j+1])=data(i,[j+1,j]);
%                         [rdata, score]=eliminate(data);
%                         if score>0
%                             actions=[actions,[i,j;i,j+1]];
%                             scores=[scores,score];
%                             nodes=[nodes, struct('data',rdata)];
%                         end
%                         data(i,[j,j+1])=data(i,[j+1,j]);
%                     end
%                 end
%             end
%             
%             for j=1:obj.cols
%                 for i=1:obj.rows-1
%                     if data(i,j)~=0 && data(i,j)~=data(i+1,j)
%                         data([i,i+1],j)=data([i+1,i],j);
%                         [rdata, score]=eliminate(data);
%                         if score>0
%                             actions=[actions,[i,j;i+1,j]];
%                             scores=[scores,score];
%                             nodes=[nodes, struct('data',rdata)];
%                         end
%                         data([i,i+1],j)=data([i+1,i],j);
%                     end
%                 end
%             end
%         end
        
        function [obj,score]=execute(obj, action)
            A=obj.current_node.data;
            t=A(action(1,1),action(1,2));
            A(action(1,1),action(1,2))=A(action(2,1),action(2,2));
            A(action(2,1),action(2,2))=t;
            [obj.current_node.data, score]=eliminate(A);
        end
        
        function tf = is_goal(obj)
            tf=isterminal(obj.current_node.data);
        end
        
        function bg=draw_bg(obj)
            xlim=[0,obj.rows];
            ylim=[0, obj.rows];
            set(obj.haxes,'XLim',xlim,'YLim',ylim,'YDir','reverse','XTick',[],'YTick',[]);
            bg=linegrid(0:obj.cols, 0:obj.rows, obj.haxes);
        end
        
        function ht=draw_text(obj, node)
            if nargin==1
                node=obj.current_node;
            end
            ht=zeros(obj.rows,obj.cols);
            for i=1:obj.rows
                for j=1:obj.cols
                    if node.data(i,j)~=0
                        ht(i,j)=text('Parent',obj.haxes,'String', obj.symbols(node.data(i,j)),'Position',[j,i]-0.5,'FontSize',20, 'Color', 'b');
                    else
                        ht(i,j)=text('Parent',obj.haxes,'String','');
                    end
                end
            end
        end
        
        function obj = eliminate(obj)
            % body
        end
    end
end

function tf=isterminal(A)
[m,n]=size(A);
tf=true;
for i=1:m
    j=1;
    while j<=n-2
        if A(i,j)~=0 && A(i,j+1)==A(i,j)
            if A(i,j+2)==A(i,j)
                tf=false;return
            else
                j=j+2;
            end
        else
            j=j+1;
        end
    end
end
for j=1:n
    i=1;
    while i<=m-2
        if A(i,j)~=0 && A(i+1,j)==A(i,j)
            if A(i+2,j)==A(i,j)
                tf=false;return
            else
                i=i+2;
            end
        else
            i=i+1;
        end
    end
end
end