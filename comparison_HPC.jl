using PyCall
using Clustering
using JuMP
using Gurobi

include("scenarios_instance_reader.jl")
include("cluster_instance_reader.jl")
include("ship_reader.jl")
include("StochasticModel_2.0_simple.jl")
include("DeterministicModel_simple.jl")

# Add the path to your Python file if it's not in the current directory
py"""
import sys
sys.path.insert(0, '/zhome/4c/4/187551/Documents/BSC_project')
import importlib
"""
# Import the Python module (without .py extension)
data_gen = pyimport("data_generation")

# Create loading_lists folder if it doesn't exist
mkpath("loading_lists")
mkpath("gurobi_deterministic_logs")
mkpath("gurobi_expected_stochastic_logs")
mkpath("gurobi_stochastic_logs")
mkpath("data/deterministic")
mkpath("data/expected_stochastic")
mkpath("data/stochastic")

data_file_ship = "Large_ship.txt"
data_ship = read_ship_instance(data_file_ship)
FactorK_O = 10

N = 1000

distribution = ["normal", "lognormal", "uniform"]
n_cluster = [10, 20, 30, 40, 50]
ports = [7, 8, 9, 10]
seeds = [68418150, 12908330, 77804901, 96998883, 76515133]


for d in distribution
    for p in ports
        for s in seeds
            # Call the function with example arguments
            data_file_deterministic, data_file_stochastic = data_gen.test_stochastic(p, "L", nothing, false, s, N, d)

            # Move the created data files to loading_lists folder
            run(`mv $data_file_deterministic loading_lists/`)
            run(`mv $data_file_stochastic loading_lists/`)
            data_file_deterministic = "loading_lists/" * data_file_deterministic
            data_file_stochastic = "loading_lists/" * data_file_stochastic

            data_deterministic = read_scenario_instance(data_file_deterministic)
            data_file_deterministic = nothing

            data_stochastic = read_scenario_instance(data_file_stochastic)
            data_file_stochastic = nothing

            model_deterministic, x_20_deterministic, x_40_deterministic, z_20_deterministic, z_40_deterministic = build_deterministic_model_simple(data_deterministic, data_ship)

            set_silent(model_deterministic)
            set_optimizer_attribute(model_deterministic, "LogFile", "gurobi_deterministic_logs/gurobi_solve_log_deterministic_$(p)_$(N)_$(d)_$(s).txt")
            #set_optimizer_attribute(model, "NodefileStart", 16.0)
            #set_optimizer_attribute(model, "NodefileDir", "/tmp")
            set_optimizer_attribute(model_deterministic, "Threads", 1)
            set_optimizer_attribute(model_deterministic, "ConcurrentMIP", 1)

            optimize!(model_deterministic)
            
            det_obj = objective_value(model_deterministic)

            # Extract deterministic solution values to free memory
            x_20_det_values = value.(x_20_deterministic)
            x_40_det_values = value.(x_40_deterministic)
            z_20_det_values = value.(z_20_deterministic)
            z_40_det_values = value.(z_40_deterministic)

            # Append the value to a text file (one value per line)
            open("data/deterministic/objective_value_deterministic_comparison_L_$(p)_$(N)_$(d).csv", "a") do io
                println(io, det_obj)
            end
            println("Wrote deterministic objective: $det_obj for p=$p, d=$d, s=$s")

            # Free deterministic model memory
            model_deterministic = nothing
            x_20_deterministic = nothing
            x_40_deterministic = nothing
            z_20_deterministic = nothing
            z_40_deterministic = nothing
            det_obj = nothing
            GC.gc(true)

            X = hcat(data_stochastic.scenario_vectors...)
            n_scenarios_saved = data_stochastic.n_scenarios

            for n in n_cluster

                result = kmeans(X, n)
                data_cluster = build_clustered_instances(data_stochastic, result)

                result = nothing
                GC.gc(true)

                # Now build and solve the stochastic model without fixing deterministic variables
                model_stochastic_unfixed, x_20_stochastic_unfixed, x_40_stochastic_unfixed, z_20_stochastic_unfixed, z_40_stochastic_unfixed = build_stochastic_model_2(data_deterministic, data_cluster, data_ship, n_scenarios_saved)

                set_silent(model_stochastic_unfixed)
                set_optimizer_attribute(model_stochastic_unfixed, "LogFile", "gurobi_stochastic_logs/gurobi_solve_log_stochastic_$(p)_$(N)_$(n)_$(d)_$(s).txt")
                set_optimizer_attribute(model_stochastic_unfixed, "Threads", 1)
                set_optimizer_attribute(model_stochastic_unfixed, "ConcurrentMIP", 1)

                optimize!(model_stochastic_unfixed)

                stoc_obj = objective_value(model_stochastic_unfixed)

                # Append the value to a text file (one value per line)
                open("data/stochastic/objective_value_stochastic_comparison_L_$(p)_$(N)_$(n)_$(d).csv", "a") do io
                    println(io, stoc_obj)
                end
                println("Wrote stochastic objective: $stoc_obj for p=$p, n=$n, d=$d, s=$s")

                model_stochastic_unfixed = nothing
                stoc_obj = nothing
                x_20_stochastic_unfixed = nothing
                x_40_stochastic_unfixed = nothing
                z_20_stochastic_unfixed = nothing
                z_40_stochastic_unfixed = nothing
                data_cluster = nothing
                GC.gc(true)

                # Expected stochastic model (fixed)
                model_stochastic_fixed, x_20_stochastic, x_40_stochastic, z_20_stochastic, z_40_stochastic = build_stochastic_model_2(data_deterministic, data_cluster, data_ship, n_scenarios_saved)

                set_silent(model_stochastic_fixed)

                T_20 = count(x -> x.length == 20, data_deterministic.container_types)
                T_40 = count(x -> x.length == 40, data_deterministic.container_types)
                L = data_ship.n_locations
                P = data_deterministic.n_ports

                transport_keys = collect(keys(data_deterministic.containers[1]))
                TR_DEP_1 = [t_idx for (t_idx, (load, discharge)) in enumerate(transport_keys) if load == 1]

                @constraint(model_stochastic_fixed, [tau_20=1:T_20, t=TR_DEP_1, l=1:L], x_20_stochastic[tau_20, t, l] == x_20_det_values[tau_20, t, l])
                @constraint(model_stochastic_fixed, [tau_40=1:T_40, t=TR_DEP_1, l=1:L], x_40_stochastic[tau_40, t, l] == x_40_det_values[tau_40, t, l])

                @constraint(model_stochastic_fixed, [tau_20=1:T_20, t=TR_DEP_1], z_20_stochastic[tau_20, t] == z_20_det_values[tau_20, t])
                @constraint(model_stochastic_fixed, [tau_40=1:T_40, t=TR_DEP_1], z_40_stochastic[tau_40, t] == z_40_det_values[tau_40, t])

                T_20 = nothing
                T_40 = nothing
                L = nothing
                P = nothing
                transport_keys = nothing
                TR_DEP_1 = nothing
                GC.gc(true)

                set_optimizer_attribute(model_stochastic, "LogFile", "gurobi_expected_stochastic_logs/gurobi_solve_log_expected_stochastic_$(p)_$(N)_$(n)_$(d)_$(s).txt")
                #set_optimizer_attribute(model, "NodefileStart", 16.0)
                #set_optimizer_attribute(model, "NodefileDir", "/tmp")
                set_optimizer_attribute(model_stochastic, "Threads", 1)
                set_optimizer_attribute(model_stochastic, "ConcurrentMIP", 1)

                optimize!(model_stochastic)
                
                expected_stoc_obj = objective_value(model_stochastic)

                # Append the value to a text file (one value per line)
                open("data/expected_stochastic/objective_value_expected_stochastic_comparison_L_$(p)_$(N)_$(n)_$(d).csv", "a") do io
                    println(io, expected_stoc_obj)
                end
                println("Wrote expected stochastic objective: $expected_stoc_obj for p=$p, n=$n, d=$d, s=$s")

                                model_stochastic_unfixed = nothing
                stoc_obj = nothing
                x_20_stochastic_fixed = nothing
                x_40_stochastic_fixed = nothing
                z_20_stochastic_fixed = nothing
                z_40_stochastic_fixed = nothing
                expected_stoc_obj = nothing
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
end