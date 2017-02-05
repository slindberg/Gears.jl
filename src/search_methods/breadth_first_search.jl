function breadth_first_search{N<:TreeNode}(seed::N; kwargs...)
  queue = Queue(N)

  is_empty()::Bool = isempty(queue)
  next_node!()::N = dequeue!(queue)
  add_node!(node::N) = enqueue!(queue, node)

  return tree_search(is_empty, next_node!, add_node!, seed; kwargs...)
end
