classdef  BaseNode
    %  Summary of this class goes here
    %   Detailed explanation goes here

    properties
        id='';
        data=[];
        successors={};
        predecessors={};
    end

    methods
        function obj = BaseNode(id, data, successors, predecessors)
            obj.id = id;
            obj.data = data;
            obj.successors = successors;
            obj.predecessors = predecessors;
        end

        function obj = next(obj)
            % body
        end
    end
end 