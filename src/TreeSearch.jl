module TreeSearch
  importall DataStructures

  export
    TreeSearchParams,
    TreeNode,
    TreeSearchResults,
    breadth_first_search,
    depth_first_search,
    best_first_search,
    is_goal,
    get_depth,
    make_children

  abstract TreeNode
  abstract TreeSearchParams

  type TreeSearchResult
    goal::Union{Void,TreeNode}
    nodes_visited::UInt64
    branches::UInt64
  end

  TreeSearchResult() = TreeSearchResult(nothing, 0, 0)

  type NotImplemented <: Exception
    name::String
    args::String
  end

  function Base.show(io::IO, ex::NotImplemented)
    @printf io "Must implement function: %s(%s)" ex.name ex.args
  end

  macro must_implement(name)
    quote
      function $(esc(name))(node::TreeNode, params::TreeSearchParams)
        arg_str = "node::$(typeof(node)), params::$(typeof(params))"
        throw(NotImplemented($(string(name)), arg_str))
      end

      function $(esc(name))(node::TreeNode)
        arg_str = "node::$(typeof(node))"
        throw(NotImplemented($(string(name)), args_str))
      end

      $(esc(name))(node::TreeNode, params::Void) = $(esc(name))(node)
    end
  end

  @must_implement is_goal
  @must_implement get_depth
  @must_implement make_children

  include("search_methods/tree_search.jl")
  include("search_methods/breadth_first_search.jl")
  include("search_methods/depth_first_search.jl")
  include("search_methods/best_first_search.jl")
end
