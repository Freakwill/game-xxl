classdef  DynamicGraph < Graph
    %  Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        start_node
        current_node
        rule   % state -> state
    end
    
    methods
        function obj = DynamicGraph(varargin)
            obj = obj@Graph(varargin{:});
        end
        
        function obj=start(obj)
            obj.current_node=obj.start_node;
            obj.nodes={obj.start_node};
        end
        
        function actions = get_actions(obj, node)
             if nargin<=1
                 node=obj.current_node;
             end
             % get actions of a node
             actions={};
         end
        
        function [newnode, weight] = get_result(obj, action, node)
            % get result of action of a node and the wight
        end
        
        function nodes = next_nodes(obj, node)
            actions = obj.get_actions(node);
            nodes={};
            for k = 1:length(actions)
                newnode=obj.get_result(node, actions{k});
                if ~nodeeq(newnode, node)
                    nodes = [nodes, newnode];
                end
            end
        end
        
        function [nodes, actions, weights] = new_successors(obj, node, flag)
            if nargin<=2, flag=false; % add the new nodes and edges to graph
                if nargin<-1,
                    node = obj.current_node;
                end
            end
            actions = obj.get_actions(node);
            nodes={};
            weights=[];
            for k = 1:length(actions)
                [newnode, weight]=obj.get_result(actions{k}, node);
                if ~obj.isnode(newnode)
                    nodes = [nodes, newnode];
                    weights = [weights, weight];
                end
            end
            if flag
                obj.add_start([{node}, nodes], weights);
            end
        end
        
        function tf = isgoal(obj, node)
            % override it
            tf= isempty(obj.get_actions(node));
        end
        
        function tf = isdead(obj, node)
            if isempty(obj.get_actions(node))
                tf= ~obj.isgoal(node);
            end
        end
        
        function tf = isterminal(obj, node)
            if nargin<=1
                node=obj.current_node;
            end
            tf=isempty(obj.get_actions(node));
        end
        
        function [obj, weight]=execute(obj, action)
            node=obj.current_node;
%             actions=obj.get_actions(node);
%             if ~cellin(action, actions)
%                 error('no such action for current state!');
%             end
            [obj.current_node, weight]=obj.get_result(action,node);
            obj.add_node(obj.current_node);
            obj.add_edge(struct('from', node,'to', obj.current_node,'weight', weight));
        end
        
        function [val, path] = get_value(obj, node)
            % get the optimal path and its value
            % no cycle in graph
            if nargin <= 1,
                node=obj.current_node;
            end
            if obj.isterminal(node)
                val = 0;
                path = {node};
            else
                if obj.isnode(node)
                    edges = obj.outedges(node);
                    if ~isempty(edges)
                        [v, p]=obj.get_value(edges{1}.to);
                        val = edges{1}.weight + v;
                        path = [{node}, edges(1),p];
                        for k= 2:length(edges)
                            [v, p]=obj.get_value(edges{k}.to);
                            newval = edges{k}.weight + v;
                            if val > newval
                                val = newval;
                                path = [{node}, edges(k), p];
                            end
                        end
                    end
                end
                val=0;
                [nodes,actions, weights] = obj.new_successors(node);
                for k=1:length(nodes)
                    [v, p]=obj.get_value(nodes{k});
                    newval = weights(k) + v;
                    if val < newval
                        val = newval;
                        path = [{node}, actions(k), p];
                    end
                end
            end
        end
        
        function obj=clear(obj)
            obj.nodes={};
            obj.edges={};
        end
    end
end

function tf=nodeeq(n1,n2)
if isfield(n1,'id') && isfield(n2,'id')
    tf=strcmpi(n1.id,n2.id);
elseif isfield(n1,'data') && isfield(n2,'data')
    tf = all(all(n1.data==n2.data));
else
    tf = all(all(n1==n2));
end
end