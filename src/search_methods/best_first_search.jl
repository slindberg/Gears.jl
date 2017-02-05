function best_first_search{N<:TreeNode}(seed::N, cost_fn::Function; kwargs...)
  queue = PriorityQueue(N,AbstractFloat)

  is_empty()::Bool = isempty(queue)
  next_node!()::N = dequeue!(queue)
  add_node!(node::N) = enqueue!(queue, node, cost_fn(node))

  return tree_search(is_empty, next_node!, add_node!, seed; kwargs...)
end
