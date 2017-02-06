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

for ω_out = [ -117.0, 77.0, 377.0, -20.0, -2345.0, 2.0 ]
  params = GearSearchParams(gears, ω_in, ω_out, ϵ_threshold, mesh_distance)
  options = [ :max_depth => max_depth ]

  @printf "Target: %.0f -> %.0f\n\n" ω_in ω_out

  for (name, method) in methods
    (result, seconds, bytes) = @timed method(params; options...)

    goal = result.goal
    @printf("* Method           : %s\n", name)
    if goal != nothing
      @printf "* Goal             : %s\n" goal
      @printf "* ω out            : %.2f\n" ω_in * goal.gear_ratio
      @printf "* Error            : %.2f%%\n" 100.0 * calc_error(goal.gear_ratio, params)
      @printf "* Transition Cost  : %s\n" goal.total_teeth
    else
      println("* Goal             : not found")
    end
    @printf "* Nodes Evaluated  : %d\n" result.nodes_visited
    @printf "* Branching Factor : %.2f\n" result.branches / result.parent_nodes
    @printf "* Elapsed Time     : %.5fs\n" seconds
    @printf "* Memory Usage     : %.0f%s\n\n" bytes/(bytes >= 1e6 ? 1e6 : 1e3) bytes >= 1e6 ? 'M' : 'K'
  end
end
