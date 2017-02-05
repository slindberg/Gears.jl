immutable GearSearchParams <: TreeSearch.TreeSearchParams
  gears::Array{Int,1}
  ω_in::AbstractFloat
  ω_out::AbstractFloat
  ϵ_threshold::AbstractFloat
  mesh_distance::Int
end

# Calculate the error in the given gear ratio
function calc_error(gear_ratio::AbstractFloat, params::GearSearchParams)
  abs((params.ω_out - params.ω_in * gear_ratio) / (params.ω_out - params.ω_in))
end

# Return a list of valid gear teeth that can mesh with the given gear
function mates_for(teeth, params::GearSearchParams)
  filter(mate -> abs(teeth - mate) <= params.mesh_distance, params.gears)
end
