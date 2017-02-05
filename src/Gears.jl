module Gears
  include("TreeSearch.jl")
  import .TreeSearch

  export
    GearNode,
    GearSearchParams,
    calc_error,
    breadth_first_search,
    depth_first_search,
    uniform_cost_search,
    a_star_search

  include("gear_search_params.jl")
  include("gear_node.jl")

  function breadth_first_search(params::GearSearchParams; kwargs...)
    TreeSearch.breadth_first_search(GearNode(); params = params, kwargs...)
  end

  function depth_first_search(params::GearSearchParams; kwargs...)
    TreeSearch.depth_first_search(GearNode(); params = params, kwargs...)
  end

  function uniform_cost_search(params::GearSearchParams; kwargs...)
    TreeSearch.best_first_search(GearNode(), transition_cost; params = params, kwargs...)
  end

  function a_star_search(params::GearSearchParams; kwargs...)
    cost_fn = n -> total_cost(n, params)
    TreeSearch.best_first_search(GearNode(), cost_fn; params = params, kwargs...)
  end
end
