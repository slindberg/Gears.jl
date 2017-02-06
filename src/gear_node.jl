@enum CONNECTION on_shaft=1 engaged=2

immutable GearNode <: TreeSearch.TreeNode
  parent::Union{Void,GearNode}
  connection::CONNECTION
  teeth::UInt8
  total_teeth::UInt16
  gear_ratio::Float16
  depth::UInt8
end

# Seed node constructor
function GearNode()
  GearNode(nothing, engaged, 0, 0, 1, 1)
end

# Given a parent geartrain, add then next gear with the given connection,
# calculating the new geartrain's ratio
function GearNode(parent::GearNode, connection::CONNECTION, teeth::Int)
  # When engaged the angular velocity reverses and changes by the ratio of the
  # two gear teeth, when on the same shaft the velocity is the same
  gear_ratio = if connection == engaged
    -parent.gear_ratio * (parent.teeth / teeth)
  else
    parent.gear_ratio
  end

  # Keep track of total teeth in the gear train, it's the transition cost
  total_teeth = parent.total_teeth + teeth

  GearNode(parent, connection, teeth, total_teeth, gear_ratio, parent.depth + 1)
end

# Print the string representation of the gear by default
function Base.show(io::IO, node::GearNode)
  @printf io "%s" to_string(node)
end

# Generate a human-readable form of the geartrain
function to_string(node::GearNode, is_last = true)
  str = if node.parent == nothing
    "-"
  else
    to_string(node.parent, false)
  end

  if node.teeth > 0
    if node.connection == on_shaft
      str *= "-"
    end

    str *= "($(node.teeth))"
  end

  if is_last
    str *= "--"
  end

  return str
end

###
# Define the three required methods for tree-search
###

# Goal state is determined by an error threshold
function TreeSearch.is_goal(node::GearNode, params::GearSearchParams)
  calc_error(node.gear_ratio, params) <= params.ϵ_threshold
end

# The depth is stored on each node to prevent unnecessary traversal
function TreeSearch.get_depth(node::GearNode, params::GearSearchParams)
  node.depth
end

# The transformation functions for a gear node depend on how the gear is
# connected: (1) if the gear is on a shaft, it can be mated with gears within
# a valid range, (2) if the gear is engaged with another gear, any gear can be
# placed on the same shaft, or valid mates can turn the gear into an idler
function TreeSearch.make_children(node::GearNode, params::GearSearchParams)
  if node.connection == engaged
    children = map(params.gears) do teeth
      GearNode(node, on_shaft, teeth)
    end

    # Treat the engaged gear as an idler if its parent is on a shaft
    # and add all possible engaged gears
    if node.parent != nothing && node.parent.connection == on_shaft
      engaged_nodes = map(mates_for(node.teeth, params)) do teeth
        GearNode(node, engaged, teeth)
      end

      append!(children, engaged_nodes)
    end

    children
  else
    map(mates_for(node.teeth, params)) do teeth
      GearNode(node, engaged, teeth)
    end
  end
end

###
# Cost functions
###

# Transition cost approximates the size of gears using the number of teeth in
# the geartrain, incentivizing smaller gears
function transition_cost(node::GearNode)::AbstractFloat
  node.total_teeth
end

# A heuristic must estimate the 'distance' to the goal, in this case a target
# gear ratio. A simple linear distance is inadequate since it over-weights
# ratios over 1. Consider target ratio of 0.5 and 2, which can be achieved
# with the same gearset (and transition cost) simply by reversing it. This
# effect can be normalized by taking the log of ratios before comparing them.
# Then the heuristic becomes the absolute value of the difference between the
# target and current gear ratios:
#
#                     │    ⌈ ω_out ⌉      ⌈ T1     T3 ⌉ │
#              h(n) = │ ln │-------│ - ln │---- * ----│ │
#                     │    ⌊ ω_in  ⌋      ⌊ T2     T4 ⌋ │
#
# Because the heuristic (or e^h(n)) is the distance to the target ratio, which
# can only be achieved by adding an exactly perfect set of gears, it so will
# always underestimate the actual distance to the goal and is therefore
# admissible. Additionally, since it ignores the alternating of directions for
# each new gear pair, an extra idler maybe necessary to achieve the target,
# further underestimating the distance. However, because any given ratio change
# can overshoot the goal by more then its current distance to the goal, the
# estimate is not monotonically decreasing (consistent) and a goal's optimality
# cannot be guaranteed.
function heuristic(node::GearNode, params::GearSearchParams)::AbstractFloat
  # Note that both the target ratio and the current ratio can be negative, which
  # is ignored for the sake of the heuristic
  abs(log(abs((params.ω_out / params.ω_in) / node.gear_ratio)))
end

# The transition cost is expressed in units of gear teeth, but the heuristic
# is an abstract relative distance to the target ratio, so in order to
# produce a meaningful metric, the heuristic must be weighted by an arbitrary
# amount (chosen by trial and error)
function total_cost(node::GearNode, params::GearSearchParams)::AbstractFloat
  transition_cost(node) + 100.0 * heuristic(node, params)
end
