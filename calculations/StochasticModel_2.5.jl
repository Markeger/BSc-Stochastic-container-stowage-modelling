using JuMP
using Gurobi

function build_stochastic_model_2(data_CP, data_omega, data_ship, N_scenarios)

    # --- same preprocessing as before ---
    T_20 = count(x -> x.length == 20, data_CP.container_types)
    T_40 = count(x -> x.length == 40, data_CP.container_types)

    L = data_ship.n_locations
    P = data_CP.n_ports
    pc = 1

    N_sce = N_scenarios
    N = data_omega.n_scenarios
    
    # Set C_count = 1 if data_omega.cluster_counts does not exist (when no clustering has been done)
    if hasproperty(data_omega, :cluster_counts)
        C_count = data_omega.cluster_counts
    else
        C_count = ones(Int, N)
    end

    LD = data_CP.containers
    transport_keys = collect(keys(LD[1]))
    omgea = data_omega.containers

    TR = length(LD[1])
    TR_ON = Dict{Int, Vector{Int}}()
    for p in 1:P
        TR_ON[p] = [t_idx for (t_idx, (load, discharge)) in enumerate(keys(LD[1])) if load <= p < discharge]
    end
    TR_A = Dict{Int, Vector{Int}}()
    for p in 1:P
        TR_A[p] = [t_idx for (t_idx, (load, discharge)) in enumerate(keys(LD[1])) if load == p || discharge == p]
    end
    TR_OV = Dict{Int, Vector{Int}}()
    for p in 1:P
        TR_OV[p] = [t_idx for (t_idx, (load, discharge)) in enumerate(keys(LD[1])) if load < p < discharge]
    end
    TR_DIS = Dict{Int, Vector{Int}}()
    for p in 1:P
        TR_DIS[p] = [t_idx for (t_idx, (load, discharge)) in enumerate(keys(LD[1])) if discharge == p]
    end

    TR_DEP = Dict{Int, Vector{Int}}()
    for p in pc
        TR_DEP[p] = [t_idx for (t_idx, (load, discharge)) in enumerate(keys(LD[1])) if load == p]
    end
    TR_FU = Dict{Int, Vector{Int}}()
    for p in pc
        TR_FU[p] = [t_idx for (t_idx, (load, discharge)) in enumerate(keys(LD[1])) if load > p]
    end

    C_20 = data_ship.location_TEU_capacity
    C_40 = data_ship.location_FEU_capacity
    C_R  = data_ship.location_reefer_capacity

    reefers20 = findall(x -> x.is_reefer == true && x.length == 20, data_CP.container_types)
    reefers40 = findall(x -> x.is_reefer == true && x.length == 40, data_CP.container_types) .- T_40

    L_O = data_ship.locations_over
    L_U = data_ship.locations_under

    M = maximum(C_20) + maximum(C_40)

    ###############################
    ###          Model          ###
    ###############################
    model = Model(Gurobi.Optimizer)

    ###############################
    ###        Variables        ###
    ###############################

    # Current port (deterministic) - keep as before (no scenario index)
    @variable(model, x_20[1:T_20, TR_DEP[pc], 1:L] >= 0)
    @variable(model, x_40[1:T_40, TR_DEP[pc], 1:L] >= 0)

    # Future transports - SCENARIO indexed (s = 1:N)
    @variable(model, s_20[1:N, 1:T_20, TR_FU[pc], 1:L] >= 0)
    @variable(model, s_40[1:N, 1:T_40, TR_FU[pc], 1:L] >= 0)

    # Overstow indicators and quantities per scenario (overstow depends on future realizations)
    @variable(model, delta[1:N, 1:P, 1:L], Bin)
    @variable(model, y_O[1:N, 1:P, 1:L] >= 0)

    # Current-port not loaded (deterministic)
    @variable(model, z_20[1:T_20, TR_DEP[pc]] >= 0)
    @variable(model, z_40[1:T_40, TR_DEP[pc]] >= 0)

    # Future-port not-loaded (per scenario)
    @variable(model, q_20[1:N, 1:T_20, TR_FU[pc]] >= 0)
    @variable(model, q_40[1:N, 1:T_40, TR_FU[pc]] >= 0)


    ###############################
    ###    Objective function   ###
    ###############################

    det_cost = sum(z_20[tau_20, t] for tau_20 in 1:T_20, t in TR_DEP[pc]) +
               sum(z_40[tau_40, t] for tau_40 in 1:T_40, t in TR_DEP[pc])

    scen_cost = (
        sum((C_count[i]/N_sce) * FactorK_O * y_O[i, p, l] for i in 1:N, p in 1:P, l in 1:L) +
        sum((C_count[i]/N_sce) * q_20[i, tau_20, t] for i in 1:N, tau_20 in 1:T_20, t in TR_FU[pc]) +
        sum((C_count[i]/N_sce) * q_40[i, tau_40, t] for i in 1:N, tau_40 in 1:T_40, t in TR_FU[pc])
    )

    @objective(model, Min, det_cost + scen_cost)


    ###############################
    ###       Constraints       ###
    ###############################

    # Capacity constraints --- per scenario for future parts.
    # For each scenario i, port p and location l we need feasibility given deterministic x_20/x_40 and scenario s_20/s_40.
    @constraint(model, [i = 1:N, p = 1:P, l = 1:L],
        sum(x_20[tau_20, t, l] for tau_20 in 1:T_20, t in intersect(TR_ON[p], TR_DEP[pc])) + 2 *
        sum(x_40[tau_40, t, l] for tau_40 in 1:T_40, t in intersect(TR_ON[p], TR_DEP[pc])) +
        sum(s_20[i, tau_20, t, l] for tau_20 in 1:T_20, t in intersect(TR_ON[p], TR_FU[pc])) + 2 *
        sum(s_40[i, tau_40, t, l] for tau_40 in 1:T_40, t in intersect(TR_ON[p], TR_FU[pc]))
        <= C_20[l]
    )

    # Reefer capacity per scenario
    @constraint(model, [i = 1:N, p = 1:P, l = 1:L],
        sum(x_20[tau_20, t, l] for tau_20 in reefers20, t in intersect(TR_ON[p], TR_DEP[pc])) + 2 *
        sum(x_40[tau_40, t, l] for tau_40 in reefers40, t in intersect(TR_ON[p], TR_DEP[pc])) +
        sum(s_20[i, tau_20, t, l] for tau_20 in reefers20, t in intersect(TR_ON[p], TR_FU[pc])) + 2 *
        sum(s_40[i, tau_40, t, l] for tau_40 in reefers40, t in intersect(TR_ON[p], TR_FU[pc]))
        <= C_R[l]
    )

    # 40' capacity per scenario
    @constraint(model, [i = 1:N, p = 1:P, l = 1:L],
        sum(x_40[tau_40, t, l] for tau_40 in 1:T_40, t in intersect(TR_ON[p], TR_DEP[pc])) +
        sum(s_40[i, tau_40, t, l] for tau_40 in 1:T_40, t in intersect(TR_ON[p], TR_FU[pc]))
        <= C_40[l]
    )

    # Loadlist constraints for current port (deterministic)
    @constraint(model, [tau_20 = 1:T_20, t = TR_DEP[pc]],
        sum(x_20[tau_20, t, l] for l in 1:L) <= LD[1][transport_keys[t]][tau_20]
    )
    @constraint(model, [tau_40 = 1:T_40, t = TR_DEP[pc]],
        sum(x_40[tau_40, t, l] for l in 1:L) <= LD[1][transport_keys[t]][T_20 + tau_40]
    )
    @constraint(model, [tau_20 = 1:T_20, t = TR_DEP[pc]],
        LD[1][transport_keys[t]][tau_20] - sum(x_20[tau_20, t, l] for l in 1:L) == z_20[tau_20, t]
    )
    @constraint(model, [tau_40 = 1:T_40, t = TR_DEP[pc]],
        LD[1][transport_keys[t]][T_20 + tau_40] - sum(x_40[tau_40, t, l] for l in 1:L) == z_40[tau_40, t]
    )

    # Loadlist constraints for future transports - per scenario
    @constraint(model, [i = 1:N, tau_20 = 1:T_20, t = TR_FU[pc]],
        sum(s_20[i, tau_20, t, l] for l in 1:L) <= omgea[i][transport_keys[t]][tau_20]
    )
    @constraint(model, [i = 1:N, tau_40 = 1:T_40, t = TR_FU[pc]],
        sum(s_40[i, tau_40, t, l] for l in 1:L) <= omgea[i][transport_keys[t]][T_20 + tau_40]
    )
    @constraint(model, [i = 1:N, tau_20 = 1:T_20, t = TR_FU[pc]],
        omgea[i][transport_keys[t]][tau_20] - sum(s_20[i, tau_20, t, l] for l in 1:L) == q_20[i, tau_20, t]
    )
    @constraint(model, [i = 1:N, tau_40 = 1:T_40, t = TR_FU[pc]],
        omgea[i][transport_keys[t]][T_20 + tau_40] - sum(s_40[i, tau_40, t, l] for l in 1:L) == q_40[i, tau_40, t]
    )

    # Lower containers unload later constraint per scenario (8)
    @constraint(model, [i = 1:N, p = 1:P, l in L_O],
        sum(x_20[tau_20, t, n] for t in intersect(TR_A[p], TR_DEP[pc]), tau_20 in 1:T_20, n in L_U[i] if n > 0) +
        sum(x_40[tau_40, t, n] for t in intersect(TR_A[p], TR_DEP[pc]), tau_40 in 1:T_40, n in L_U[i] if n > 0) +
        sum(s_20[i, tau_20, t, n] for t in intersect(TR_A[p], TR_FU[pc]), tau_20 in 1:T_20, n in L_U[i] if n > 0) +
        sum(s_40[i, tau_40, t, n] for t in intersect(TR_A[p], TR_FU[pc]), tau_40 in 1:T_40, n in L_U[i] if n > 0)
        <= M * delta[i, p, l]
    )

    # Counting the overstowage (9) per scenario
    @constraint(model, [i = 1:N, p = 1:P, l in L_O],
        sum(x_20[tau_20, t, l] for tau_20 in 1:T_20, t in intersect(TR_OV[p], TR_DEP[pc])) +
        sum(x_40[tau_40, t, l] for tau_40 in 1:T_40, t in intersect(TR_OV[p], TR_DEP[pc])) +
        sum(s_20[i, tau_20, t, l] for tau_20 in 1:T_20, t in intersect(TR_OV[p], TR_FU[pc])) +
        sum(s_40[i, tau_40, t, l] for tau_40 in 1:T_40, t in intersect(TR_OV[p], TR_FU[pc])) -
        M*(1 - delta[i, p, l])
        <= y_O[i, p, l]
    )

    return model, x_20, x_40, z_20, z_40
end
