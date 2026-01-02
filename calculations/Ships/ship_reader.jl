
# Struct describing a ship instance (without port/container info)
struct ShipInstance
    n_bays::Int64
    n_locations::Int64
    n_bins::Int64
    locations_over::Vector{Int64}
    locations_under::Vector{Int64}
    locations_over_in_bay::Vector{Vector{Int64}}
    location_bay::Vector{Int64}
    location_TEU_capacity::Vector{Int64}
    location_FEU_capacity::Vector{Int64}
    location_reefer_capacity::Vector{Int64}
    location_weight_capacity::Vector{Float64}
    location_lcg::Vector{Float64}
    location_vcg::Vector{Float64}
    location_tcg::Vector{Float64}
    bay_bins::Vector{Vector{Int64}}
    bay_lightship_weight::Vector{Float64}
    bay_lcg::Vector{Float64}
    bay_vcg::Vector{Float64}
    bay_tcg::Vector{Float64}
    bay_min_shear::Vector{Float64}
    bay_max_shear::Vector{Float64}
    bay_max_bending::Vector{Float64}
end

# Reader function for ship files (no port/container info)
function read_ship_instance(filename::String)
	file = open(filename)
	n_bays, n_locations, n_bins = parse.(Int64, split(readline(file)))
	locations_over = parse.(Int64, split(readline(file)))
	locations_under = parse.(Int64, split(readline(file)))
	locations_over_in_bay = Vector{Vector{Int64}}()
	for b in 1:n_bays
		vals = parse.(Int64, split(readline(file)))
		if lastindex(vals) > 1
			push!(locations_over_in_bay, vals[2:end])
		else
			push!(locations_over_in_bay, Int64[])
		end
	end
	location_bay = parse.(Int64, split(readline(file)))
	location_TEU_capacity = parse.(Int64, split(readline(file)))
	location_FEU_capacity = parse.(Int64, split(readline(file)))
	location_reefer_capacity = parse.(Int64, split(readline(file)))
	location_weight_capacity = parse.(Float64, split(readline(file)))
	location_lcg = parse.(Float64, split(readline(file)))
	location_vcg = parse.(Float64, split(readline(file)))
	location_tcg = parse.(Float64, split(readline(file)))
	bay_bins = Vector{Vector{Int64}}()
	for b in 1:n_bins
		push!(bay_bins, parse.(Int64, split(readline(file))))
	end
	bay_lightship_weight = parse.(Float64, split(readline(file)))
	bay_lcg = parse.(Float64, split(readline(file)))
	bay_vcg = parse.(Float64, split(readline(file)))
	bay_tcg = parse.(Float64, split(readline(file)))
	bay_min_shear = parse.(Float64, split(readline(file)))
	bay_max_shear = parse.(Float64, split(readline(file)))
	bay_max_bending = parse.(Float64, split(readline(file)))
	close(file)
	return ShipInstance(
		n_bays,
		n_locations,
		n_bins,
		locations_over,
		locations_under,
		locations_over_in_bay,
		location_bay,
		location_TEU_capacity,
		location_FEU_capacity,
		location_reefer_capacity,
		location_weight_capacity,
		location_lcg,
		location_vcg,
		location_tcg,
		bay_bins,
		bay_lightship_weight,
		bay_lcg,
		bay_vcg,
		bay_tcg,
		bay_min_shear,
		bay_max_shear,
		bay_max_bending
	)
end
