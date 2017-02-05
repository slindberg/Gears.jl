function depth_first_search{N<:TreeNode}(seed::N; kwargs...)
  stack = Stack(N)

  is_empty()::Bool = isempty(stack)
  next_node!()::N = pop!(stack)
  add_node!(node::N) = push!(stack, node)

  return tree_search(is_empty, next_node!, add_node!, seed; kwargs...)
end
