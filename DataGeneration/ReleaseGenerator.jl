using Random

function create_release(data_CP, data_ship; release_fraction = 0.80)
    """
    Input
        data_CP:            Demand information. The demand amount of each container type, for each transport.
        data_ship:          Ship information. Size, locations, capacities, constraints, etc.
        release_fraction:   Fraction of placed containers to remove (0.0–1.0).

    Output
        R:   3-dimensional array. R[container_type, transport, location]
             Includes all transports, but only those departing from port 1 will have containers placed.
    """

    L = data_ship.n_locations
    C_20 = data_ship.location_TEU_capacity
    C_40 = data_ship.location_FEU_capacity
    C_R  = data_ship.location_reefer_capacity

    container_types = data_CP.container_types
    LD = data_CP.containers                # Dict{Tuple{Int,Int}, Vector{Int}}
    transport_keys = collect(keys(LD))     # all transports
    P = length(transport_keys)
    T = length(container_types)

    used_20 = zeros(Int, L)
    used_40 = zeros(Int, L)
    used_reefer = zeros(Int, L)

    # Output array
    R = zeros(Int, T, P, L)

    for (p_idx, trans) in enumerate(transport_keys)
        # Only place containers for transports departing from port 1
        if trans[1] != 1
            continue
        end

        counts = LD[trans]  # demand for each container type
        for t_idx in 1:T
            n_to_place = counts[t_idx]
            t = container_types[t_idx]

            for _ in 1:n_to_place
                placed = false
                for l in 1:L
                    feasible = true

                    if t.is_reefer && used_reefer[l] >= C_R[l]
                        feasible = false
                    elseif t.length == 20
                        if used_20[l] + 1 + 2 * used_40[l] > C_20[l]
                            feasible = false
                        end
                    elseif t.length == 40
                        if used_40[l] + 1 > C_40[l] || used_20[l] + 2 * (used_40[l] + 1) > C_20[l]
                            feasible = false
                        end
                    end

                    if feasible
                        # Place container
                        if t.length == 20
                            used_20[l] += 1
                        else
                            used_40[l] += 1
                        end
                        if t.is_reefer
                            used_reefer[l] += 1
                        end
                        R[t_idx, p_idx, l] += 1
                        placed = true
                        break
                    end
                end
                # skip container if no feasible location (no overflow)
            end
        end
    end

    # Randomly delete placed continers
    total = sum(R)
    n_release = Int(round(release_fraction * total))

    all_indices = findall(R .> 0)
    release_indices = randperm(length(all_indices))[1:min(n_release, length(all_indices))]

    for idx in release_indices
        (t, p, l) = Tuple(all_indices[idx])  # convert CartesianIndex -> Tuple
        R[t, p, l] -= 1

        # Update used capacities
        t_type = container_types[t]
        if t_type.length == 20
            used_20[l] -= 1
        else
            used_40[l] -= 1
        end
        if t_type.is_reefer
            used_reefer[l] -= 1
        end
    end

    return R
end
