# Define the ContainerType struct (copy from instance_reader.jl if not already present)
struct ContainerType
    length::Int64
    weight::Float64
    cargo_type::String # Expected values: DC, HC, RC, HR
    height::Float64
    is_reefer::Bool
    is_HC::Bool
end
# Instance reader for scenario .txt files exported from Python generator


struct ScenarioInstance
    n_ports::Int
    n_scenarios::Int
    container_types::Vector{ContainerType}
    scenarios::Vector{Vector{Array{Int,2}}} # scenarios[scen][ctype] = matrix
    containers::Dict{Tuple{Int,Int}, Vector{Int}}
end



function read_scenario_instance(filename::String)
    file = open(filename)
    n_ports, n_scenarios = parse.(Int, split(readline(file)))
    n_container_types = 28  # fixed for this format
    container_types_raw = Tuple{Int, Float64, String}[]
    for i in 1:n_container_types
        vals = split(readline(file))
        push!(container_types_raw, (parse(Int, vals[1]), parse(Float64, vals[2]), vals[3]))
    end
    # Unfold container_types into ContainerType objects
    container_types = ContainerType[]
    for (length, weight, typ) in container_types_raw
        height = 2.62
        is_reefer = false
        is_HC = false
        if typ == "HC" || typ == "HR"
            height = 2.92
            is_HC = true
        end
        if typ == "HR" || typ == "RC"
            is_reefer = true
        end
        push!(container_types, ContainerType(length, weight, typ, height, is_reefer, is_HC))
    end

    # Read all scenario matrices
    scenarios = Vector{Vector{Array{Int,2}}}()
    n_rows = n_ports
    n_cols = n_ports
    for s in 1:n_scenarios
        matrices = Vector{Array{Int,2}}()
        for c in 1:n_container_types
            mat = Array{Int,2}(undef, n_rows, n_cols)
            for r in 1:n_rows
                row_vals = parse.(Int, split(readline(file)))
                mat[r, :] = row_vals
            end
            push!(matrices, mat)
        end
        push!(scenarios, matrices)
    end
    close(file)

    # Build containers dictionary: (origin, dest) => [count for each type, aggregated over all scenarios]
    containers = Dict{Tuple{Int,Int}, Vector{Int}}()
    for o in 1:n_ports
        for d in 1:n_ports
            if o < d
                # For each container type, sum over all scenarios
                counts = Int[]
                for c in 1:n_container_types
                    vals = [scenarios[s][c][o,d] for s in 1:n_scenarios]
                    append!(counts, vals)
                end
                containers[(o,d)] = counts
            end
        end
    end

    return ScenarioInstance(n_ports, n_scenarios, container_types, scenarios, containers)
end

