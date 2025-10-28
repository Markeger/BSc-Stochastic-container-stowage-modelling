using JuMP
using Gurobi


function build_deterministic_model_simple(data, release, data_ship)

    # Count amount of 20' and 40' type containers
    T_20 = count(x -> x.length == 20, data.container_types)
    T_40 = count(x -> x.length == 40, data.container_types)

    L = data_ship.n_locations          # Number of locations/blocks
    P = data.n_ports              # Number of ports to visit

    R = release

    LD = data.containers          # The number of container in each leg per container type
    transport_keys = collect(keys(LD))

    TR = length(data.containers)  # Number of transports (sets of loading and discharge ports) #((P-1)*P/2)
    TR_ON = Dict{Int, Vector{Int}}()    # Set of transports on the vessel at departure from port p
    for p in 1:P
        TR_ON[p] = [t_idx for (t_idx, (load, discharge)) in enumerate(keys(LD)) if load <= p < discharge]
    end 
    TR_A = Dict{Int, Vector{Int}}()     # Set of transports that is loading or unloading in port p
    for p in 1:P
        TR_A[p] = [t_idx for (t_idx, (load, discharge)) in enumerate(keys(LD)) if load == p || discharge == p]
    end
    TR_OV = Dict{Int, Vector{Int}}()    # Set of transports thet overstow containers to load or unload in port p
    for p in 1:P
        TR_OV[p] = [t_idx for (t_idx, (load, discharge)) in enumerate(keys(LD)) if load < p < discharge]
    end
    TR_DIS = Dict{Int, Vector{Int}}()   # Set of transporters that discharges at port p
    for p in 1:P
        TR_DIS[p] = [t_idx for (t_idx, (load, discharge)) in enumerate(keys(LD)) if discharge == p]
    end

    C_20 = data_ship.location_TEU_capacity   # TEU capacity of each location
    C_40 = data_ship.location_FEU_capacity   # FEU capacity of each location
    C_R = data_ship.location_reefer_capacity # Number of reefer plugs in each location 

    F_20 = C_R ./ C_20  # Factor for all non-reefer 20' containers
    F_40 = C_R ./ C_40  # Factor for all non-reefer 40' containers

    reefers20 = findall(x -> x.is_reefer == true && x.length == 20, data.container_types)           # List of index for reefercontainers in C_20
    reefers40 = findall(x -> x.is_reefer == true && x.length == 40, data.container_types) .- T_40   # List of index for reefercontainers in C_40

    L_O = data_ship.locations_over           # List of on-deck locations
    L_U = data_ship.locations_under          # List of locations under a given location (0 if the given location is under-deck)

    M = maximum(C_20)+maximum(C_40)


    ###############################
    ###          Model          ###
    ###############################
            
    DeterministicModel_Simple = Model(Gurobi.Optimizer)

    ###############################
    ###        Variabels        ###
    ###############################

    # Amount of containers in each location in each transport
    @variable(DeterministicModel_Simple, x_20[1:T_20, 1:TR, 1:L] >= 0)
    @variable(DeterministicModel_Simple, x_40[1:T_40, 1:TR, 1:L] >= 0)

    # Doeas a location contain overstowage? {no,yes}
    @variable(DeterministicModel_Simple, delta[1:P, 1:L], Bin)

    # The number of hatch overstow containers
    @variable(DeterministicModel_Simple, y_O[1:P, 1:L] >= 0)

    # presence of 20' containers to load or unload? {no,yes}
    @variable(DeterministicModel_Simple, phi[1:P, 1:L], Bin)

    # Continers not loaded
    @variable(DeterministicModel_Simple, z_20[1:T_20, 1:TR] >= 0)
    @variable(DeterministicModel_Simple, z_40[1:T_40, 1:TR] >= 0)


    ###############################
    ###    Objective function   ###
    ###############################

    @objective(DeterministicModel_Simple, Min,
        sum(FactorK_O * y_O[p, l] for p in 1:P, l in 1:L) + 
        sum(z_20[tau_20, t] for tau_20 in 1:T_20, t in 1:TR) +
        sum(z_40[tau_40, t] for tau_40 in 1:T_40, t in 1:TR)
        )


    ###############################
    ###       Constraints       ###
    ###############################

    # Capacity constraint (1)
    @constraint(DeterministicModel_Simple, [p = 1:P, l = 1:L],
        sum(x_20[tau_20, t, l] + R[tau_20, t, l] for tau_20 in 1:T_20, t in TR_ON[p]) + 2 *
        sum(x_40[tau_40, t, l] + R[T_20 + tau_40, t, l] for tau_40 in 1:T_40, t in TR_ON[p])
        <= C_20[l]
        )

    # Reafer capcity constraint (2)
    @constraint(DeterministicModel_Simple, [p = 1:P, l = 1:L],
        sum(x_20[tau_20, t, l] + R[tau_20, t, l] for tau_20 in reefers20, t in TR_ON[p]) + 2 * 
        sum(x_40[tau_40, t, l] + R[T_20 + tau_40, t, l] for tau_40 in reefers40, t in TR_ON[p])
        <= C_R[l]
        )

    # Capacity constraint of 40' (3) (tror det er redundant at laven en for 20' også, da denne falder ind i (1))
    @constraint(DeterministicModel_Simple, [p = 1:P, l = 1:L],
        sum(x_40[tau_40, t, l] + R[T_20 + tau_40, t, l] for tau_40 in 1:T_40, t in TR_ON[p])
        <= C_40[l]
        )

    # Loadlist constraint (4)
    @constraint(DeterministicModel_Simple, [tau_20 = 1:T_20, t = 1:TR], 
        sum(x_20[tau_20, t, l] for l in 1:L) 
        <= LD[transport_keys[t]][tau_20]          # Relaxed to not enclude all containers
        )
    @constraint(DeterministicModel_Simple, [tau_40 = 1:T_40, t = 1:TR], 
        sum(x_40[tau_40, t, l] for l in 1:L) 
        <= LD[transport_keys[t]][T_20 + tau_40]   # Relaxed to not enclude all containers
        )
    # Minimise non-loaded containers constraint
    @constraint(DeterministicModel_Simple, [tau_20 = 1:T_20, t = 1:TR],
        LD[transport_keys[t]][tau_20] -
        sum(x_20[tau_20, t, l] for l in 1:L)
        == z_20[tau_20, t]
        )
    @constraint(DeterministicModel_Simple, [tau_40 = 1:T_40, t = 1:TR],
        LD[transport_keys[t]][T_20 + tau_40] -
        sum(x_40[tau_40, t, l] for l in 1:L)
        == z_40[tau_40, t]
        )

    # Lower containers unload later constraint (8)
    @constraint(DeterministicModel_Simple, [p = 1:P, l in L_O],
        sum(x_20[tau_20, t, i] + R[tau_20, t, l] for t in TR_A[p], tau_20 in 1:T_20, i in L_U if i > 0) +
        sum(x_40[tau_40, t, i] + R[T_20 + tau_40, t, l] for t in TR_A[p], tau_40 in 1:T_40, i in L_U if i > 0)
        <= M * delta[p,l]
        )

    # Counting the overstowage (9)
    @constraint(DeterministicModel_Simple, [p = 1:P, l in L_O], 
        sum(x_20[tau_20, t, l] + R[tau_20, t, l] for tau_20 in 1:T_20, t in TR_OV[p]) +
        sum(x_40[tau_40, t, l] + + R[T_20 + tau_40, t, l] for tau_40 in 1:T_40, t in TR_OV[p]) -
        M*(1 - delta[p,l])
        <= y_O[p,l]
        )
    # Return model and variable references so callers can extract solutions
    return DeterministicModel_Simple, x_20, x_40
end