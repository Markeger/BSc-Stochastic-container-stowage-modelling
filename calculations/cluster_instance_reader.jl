struct ClusteredInstances
    n_ports::Int
    n_scenarios::Int
    container_types::Vector{ContainerType}
    containers::Vector{Dict{Tuple{Int,Int}, Vector{Int}}}
    cluster_counts::Vector{Int}
end

function build_clustered_instances(data, result)
    n_ports = data.n_ports
    container_types = data.container_types
    centers = result.centers
    n_scenarios = size(centers, 2)
    n_container_types = length(container_types)
    containers = Vector{Dict{Tuple{Int,Int}, Vector{Int}}}(undef, n_scenarios)

    for cluster_idx in 1:n_scenarios
        center_vec = centers[:, cluster_idx]
        matrices = Vector{Array{Float64,2}}(undef, n_container_types)
        offset = 0
        for c in 1:n_container_types
            matrices[c] = reshape(center_vec[offset+1 : offset+n_ports*n_ports], n_ports, n_ports)
            offset += n_ports * n_ports
        end

        container_dict = Dict{Tuple{Int,Int}, Vector{Int}}()
        for o in 1:n_ports
            for d in 1:n_ports
                if o < d
                    counts = [Int(round(matrices[c][o, d])) for c in 1:n_container_types]
                    container_dict[(o, d)] = counts
                end
            end
        end
        containers[cluster_idx] = container_dict
    end

    cluster_counts = result.counts

    return ClusteredInstances(n_ports, n_scenarios, container_types, containers, cluster_counts)
end