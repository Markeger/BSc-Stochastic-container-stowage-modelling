using PyCall
using Clustering
using JuMP
using Gurobi

include("scenarios_instance_reader.jl")
include("cluster_instance_reader.jl")
include("ship_reader.jl")
include("StochasticModel_2.5.jl")


path = pwd()
py"""
import sys
sys.path.insert(0, $path)
import importlib
"""

# Import the Python module
data_gen = pyimport("data_generation")

# Create loading_lists folder if it doesn't exist
mkpath("loading_lists")
mkpath("log_MIP_5/gurobi_deterministic_logs")
mkpath("log_MIP_5/gurobi_expected_stochastic_logs")
mkpath("log_MIP_5/gurobi_stochastic_logs")
mkpath("data_MIP_5/deterministic")
mkpath("data_MIP_5/expected_stochastic")
mkpath("data_MIP_5/stochastic")


data_file_ship = "Small_ship.txt"
data_ship = read_ship_instance(data_file_ship)
FactorK_O = 10

N = 70000

deg2rad = ["lognormal"]
n_cluster = [10, 20, 30, 40, 50]
ports = [8, 10, 15]
seeds = [12908330, 77804901, 96998883, 76515133]



for p in ports
    for s in seeds
        # Call the function with example arguments
        data_file_port_one, data_file_scenarios = data_gen.test_stochastic(p, "S", nothing, false, s, N, d)

        # Move the created data files to loading_lists folder
        run(`mv $data_file_port_one loading_lists/`)
        run(`mv $data_file_scenarios loading_lists/`)
        data_file_port_one = "loading_lists/" * data_file_port_one
        data_file_scenarios = "loading_lists/" * data_file_scenarios

        data_port_one = read_scenario_instance(data_file_port_one)
        data_file_port_one = nothing

        data_scenarios = read_scenario_instance(data_file_scenarios)
        data_file_stochastic = nothing

        n_scenarios_saved = data_scenarios.n_scenarios

        X_det= hcat(data_scenarios.scenario_vectors...)

        result_det = kmeans(X_det, 1)
        data_deterministic = build_clustered_instances(data_scenarios, result_det)

        result = nothing
        GC.gc(true)

        model_deterministic, x_20_deterministic, x_40_deterministic, z_20_deterministic, z_40_deterministic = build_stochastic_model_2(data_port_one, data_deterministic, data_ship, n_scenarios_saved)

        logfile_det = "log_MIP_5/gurobi_deterministic_logs/gurobi_solve_log_deterministic_S_$(p)_$(N)_$(d)_$(s).txt"
        open(logfile_det, "w") do io
            redirect_stdout(io) do

                set_optimizer_attribute(model_deterministic, "Threads", 1)
                set_optimizer_attribute(model_deterministic, "ConcurrentMIP", 1)
                set_optimizer_attribute(model_deterministic, "MIPGap", 0.05)

                optimize!(model_deterministic)
            end
        end
            
        det_obj = objective_value(model_deterministic)

        # Extract deterministic solution values to free memory
        x_20_det_values = value.(x_20_deterministic)
        x_40_det_values = value.(x_40_deterministic)
        z_20_det_values = value.(z_20_deterministic)
        z_40_det_values = value.(z_40_deterministic)

        # Append the value to a text file (one value per line)
        open("data_MIP_5/deterministic/objective_value_deterministic_comparison_S_$(p)_$(N)_$(d).csv", "a") do io
            println(io, det_obj)
        end

        # Free deterministic model memory
        model_deterministic = nothing
        x_20_deterministic = nothing
        x_40_deterministic = nothing
        z_20_deterministic = nothing
        z_40_deterministic = nothing
        det_obj = nothing
        GC.gc(true)

        X = hcat(data_scenarios.scenario_vectors...)

        for n in n_cluster
            result = kmeans(X, n)
            data_cluster = build_clustered_instances(data_scenarios, result)

            result = nothing
            GC.gc(true)

            model_stochastic, x_20_stochastic, x_40_stochastic, z_20_stochastic, z_40_stochastic = build_stochastic_model_2(data_port_one, data_cluster, data_ship, n_scenarios_saved)

            logfile_expected = "log_MIP_5/gurobi_expected_stochastic_logs/gurobi_solve_log_expected_stochastic_S_$(p)_$(N)_$(n)_$(d)_$(s).txt"
            open(logfile_expected, "w") do io
                redirect_stdout(io) do
                    T_20 = count(x -> x.length == 20, data_deterministic.container_types)
                    T_40 = count(x -> x.length == 40, data_deterministic.container_types)
                    L = data_ship.n_locations
                    P = data_deterministic.n_ports

                    transport_keys = collect(keys(data_deterministic.containers[1]))
                    TR_DEP_1 = [t_idx for (t_idx, (load, discharge)) in enumerate(transport_keys) if load == 1]

                    @constraint(model_stochastic, [tau_20=1:T_20, t=TR_DEP_1, l=1:L], x_20_stochastic[tau_20, t, l] == x_20_det_values[tau_20, t, l])
                    @constraint(model_stochastic, [tau_40=1:T_40, t=TR_DEP_1, l=1:L], x_40_stochastic[tau_40, t, l] == x_40_det_values[tau_40, t, l])

                    @constraint(model_stochastic, [tau_20=1:T_20, t=TR_DEP_1], z_20_stochastic[tau_20, t] == z_20_det_values[tau_20, t])
                    @constraint(model_stochastic, [tau_40=1:T_40, t=TR_DEP_1], z_40_stochastic[tau_40, t] == z_40_det_values[tau_40, t])

                    T_20 = nothing
                    T_40 = nothing
                    L = nothing
                    P = nothing
                    transport_keys = nothing
                    TR_DEP_1 = nothing
                    GC.gc(true)

                    set_optimizer_attribute(model_stochastic, "Threads", 1)
                    set_optimizer_attribute(model_stochastic, "ConcurrentMIP", 1)
                    set_optimizer_attribute(model_stochastic, "MIPGap", 0.05)

                    optimize!(model_stochastic)
                end
            end
                
            expected_stoc_obj = objective_value(model_stochastic)

            # Append the value to a text file (one value per line)
            open("data_MIP_5/expected_stochastic/objective_value_expected_stochastic_comparison_S_$(p)_$(N)_$(n)_$(d).csv", "a") do io
                println(io, expected_stoc_obj)
            end

            model_stochastic = nothing
            expected_stoc_obj = nothing
            GC.gc(true)

            # Now build and solve the stochastic model without fixing deterministic variables
            model_stochastic_unfixed, x_20_stochastic_unfixed, x_40_stochastic_unfixed, z_20_stochastic_unfixed, z_40_stochastic_unfixed = build_stochastic_model_2(data_port_one, data_cluster, data_ship, n_scenarios_saved)

            logfile_stoc = "log_MIP_5/gurobi_stochastic_logs/gurobi_solve_log_stochastic_S_$(p)_$(N)_$(n)_$(d)_$(s).txt"
            open(logfile_stoc, "w") do io
                redirect_stdout(io) do
                    set_optimizer_attribute(model_stochastic_unfixed, "Threads", 1)
                    set_optimizer_attribute(model_stochastic_unfixed, "ConcurrentMIP", 1)
                    set_optimizer_attribute(model_stochastic_unfixed, "MIPGap", 0.05)

                    optimize!(model_stochastic_unfixed)
                end
            end

            stoc_obj = objective_value(model_stochastic_unfixed)

            # Append the value to a text file (one value per line)
            open("data_MIP_5/stochastic/objective_value_stochastic_comparison_S_$(p)_$(N)_$(n)_$(d).csv", "a") do io
                println(io, stoc_obj)
            end

            model_stochastic_unfixed = nothing
            stoc_obj = nothing
            x_20_stochastic_unfixed = nothing
            x_40_stochastic_unfixed = nothing
            z_20_stochastic_unfixed = nothing
            z_40_stochastic_unfixed = nothing
            data_cluster = nothing
            GC.gc(true)
        end

        # Free remaining memory after all clusters for this seed
        x_20_det_values = nothing
        x_40_det_values = nothing
        z_20_det_values = nothing
        z_40_det_values = nothing
        data_deterministic = nothing
        data_stochastic = nothing
        X = nothing
        n_scenarios_saved = nothing
        GC.gc(true)
    end
end
