using Gears

gears = [ 11, 23, 31, 47, 59, 71, 83, 97, 109, 127 ]
ω_in = 100.0
ω_out = 0.0
ϵ_threshold = 0.025
mesh_distance = 30
max_depth = 10

methods = [
  "Breadth First Search" => breadth_first_search,
  "Depth First Search" => depth_first_search,
  "Uniform Cost Search" => uniform_cost_search,
  "A*" => a_star_search
]

let io = STDOUT
# open("results.out", "w") do io
  for ω_out = [ -117.0, 77.0, 377.0, -20.0, -2345.0, 2.0 ]
    params = GearSearchParams(gears, ω_in, ω_out, ϵ_threshold, mesh_distance)
    options = [ :max_depth => max_depth ]

    @printf io "Target: %.0f -> %.0f\n\n" ω_in ω_out

    for (name, method) in methods
      (result, seconds, bytes) = @timed method(params; options...)

      goal = result.goal
      @printf io "* Method           : %s\n" name
      if goal != nothing
        @printf io "* Goal             : %s\n" goal
        @printf io "* ω out            : %.2f\n" ω_in * goal.gear_ratio
        @printf io "* Error            : %.2f%%\n" 100.0 * calc_error(goal.gear_ratio, params)
        @printf io "* Transition Cost  : %s\n" goal.total_teeth
      else
        @printf io "* Goal             : not found\n"
      end
      @printf io "* Nodes Evaluated  : %d\n" result.nodes_visited
      @printf io "* Branching Factor : %.2f\n" result.branches / result.parent_nodes
      @printf io "* Elapsed Time     : %.5fs\n" seconds
      @printf io "* Memory Usage     : %.0f%s\n\n" bytes/(bytes >= 1e6 ? 1e6 : 1e3) bytes >= 1e6 ? 'M' : 'K'
    end
  end
end
