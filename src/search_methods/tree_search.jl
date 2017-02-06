function tree_search{N<:TreeNode}(
  is_empty::Function,
  next_node!::Function,
  add_node!::Function,
  seed::N;
  max_depth::Int = 50,
  params::Union{Void,TreeSearchParams} = nothing
)
  result = TreeSearchResult()
  add_node!(seed)

  while !is_empty()
    node = next_node!()
    result.nodes_visited += 1

    if is_goal(node, params)
      result.goal = node
      break
    end

    if get_depth(node, params) >= max_depth
      continue
    end

    children = make_children(node, params)
    result.branches += length(children)
    result.parent_nodes += 1

    for child = children
      add_node!(child)
    end
  end

  return result
end
