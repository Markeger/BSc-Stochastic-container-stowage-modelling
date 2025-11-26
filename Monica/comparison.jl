using PyCall
using Clustering
using JuMP
using Gurobi

include("scenarios_instance_reader.jl")
include("cluster_instance_reader.jl")
include("ship_reader.jl")
include("StochasticModel_2.0_Simple.jl")
include("DeterministicModel_Simple.jl")

# Add the path to your Python file if it's not in the current directory
py"""
import sys
sys.path.insert(0, "Insert directory to python file "daya_generation.py"") ################# HUSK AT INDSÆTTE DIRECTORY HER!!!!!!
import importlib
"""
# Import the Python module (without .py extension)
data_gen = pyimport("data_generation")


data_file_ship = "Large_Ship.txt"
data_ship = read_ship_instance(data_file_ship)
FactorK_O = 10
distribution = "normal"
N = 1000

ports = [6, 7, 8, 9, 10]
seeds = [68418150, 12908330, 77804901, 96998883, 76515133, 76359216, 37838767, 22601606, 75800918, 27547138]

for p in ports
    for s in seeds
        # Call the function with example arguments
        data_file_deterministic, data_file_stochastic = data_gen.test_stochastic(p, "L", nothing, false, s, N, distribution)

        data_deterministic = read_scenario_instance(data_file_deterministic)
        data_file_deterministic = nothing

        data_stochastic = read_scenario_instance(data_file_stochastic)
        data_file_stochastic = nothing

        model_deterministic, x_20_deterministic, x_40_deterministic, z_20_deterministic, z_40_deterministic = build_deterministic_model_simple(data_deterministic, data_ship)

        set_silent(model_deterministic)
        set_optimizer_attribute(model_deterministic, "LogFile", "gurobi_solve_log_deterministic_$(p)_$(N)_$(distribution)_$(s).txt")
        #set_optimizer_attribute(model, "NodefileStart", 16.0)
        #set_optimizer_attribute(model, "NodefileDir", "/tmp")
        set_optimizer_attribute(model_deterministic, "Threads", 1)
        set_optimizer_attribute(model_deterministic, "ConcurrentMIP", 1)

        optimize!(model_deterministic)
        
        det_obj = objective_value(model_deterministic)
        det_time = solve_time(model_deterministic)

        # Append the value to a text file (one value per line)
        open("objective_value_deterministic_L_$(p)_$(N)_$(distribution).csv", "a") do io
            println(io, det_obj)
        end

        # Append the value to a text file (one value per line)
        open("solve_times_deterministic_comparison_L_$(p)_$(N)_$(distribution).csv", "a") do io
            println(io, det_time)
        end

        n_clusters = 20

        X = hcat(data_stochastic.scenario_vectors...)
        result = kmeans(X, n_clusters)
        data_cluster = build_clustered_instances(data_stochastic, result)

        X = nothing
        result = nothing
        n_scenarios_saved = data_stochastic.n_scenarios
        data_stochastic = nothing
        det_obj = nothing
        det_time = nothing
        model_deterministic = nothing
        GC.gc(true)

        model_stochastic, x_20_stochastic, x_40_stochastic, z_20_stochastic, z_40_stochastic = build_stochastic_model_2(data_deterministic, data_cluster, data_ship, n_scenarios_saved)

        set_silent(model_stochastic)

        T_20 = count(x -> x.length == 20, data_deterministic.container_types)
        T_40 = count(x -> x.length == 40, data_deterministic.container_types)
        L = data_ship.n_locations
        P = data_deterministic.n_ports

        transport_keys = collect(keys(data_deterministic.containers[1]))
        TR_DEP_1 = [t_idx for (t_idx, (load, discharge)) in enumerate(transport_keys) if load == 1]

        @constraint(model_stochastic, [tau_20=1:T_20, t=TR_DEP_1, l=1:L], x_20_stochastic[tau_20, t, l] == value(x_20_deterministic[tau_20, t, l]))
        @constraint(model_stochastic, [tau_40=1:T_40, t=TR_DEP_1, l=1:L], x_40_stochastic[tau_40, t, l] == value(x_40_deterministic[tau_40, t, l]))

        @constraint(model_stochastic, [tau_20=1:T_20, t=TR_DEP_1], z_20_stochastic[tau_20, t] == value(z_20_deterministic[tau_20, t]))
        @constraint(model_stochastic, [tau_40=1:T_40, t=TR_DEP_1], z_40_stochastic[tau_40, t] == value(z_40_deterministic[tau_40, t]))

        T_20 = nothing
        T_40 = nothing
        L = nothing
        P = nothing
        transport_keys = nothing
        TR_DEP_1 = nothing
        x_20_deterministic = nothing
        x_40_deterministic = nothing
        z_20_deterministic = nothing
        z_40_deterministic = nothing
        model_deterministic = nothing
        data_deterministic = nothing
        data_cluster = nothing
        n_scenarios_saved = nothing
        GC.gc(true)

        set_optimizer_attribute(model_stochastic, "LogFile", "gurobi_solve_log_stochastic_$(p)_$(N)_$(distribution)_$(s).txt")
        #set_optimizer_attribute(model, "NodefileStart", 16.0)
        #set_optimizer_attribute(model, "NodefileDir", "/tmp")
        set_optimizer_attribute(model_stochastic, "Threads", 1)
        set_optimizer_attribute(model_stochastic, "ConcurrentMIP", 1)

        optimize!(model_stochastic)

        stoc_obj = objective_value(model_stochastic)
        stoc_time = solve_time(model_stochastic)

        # Append the value to a text file (one value per line)
        open("objective_value_stochastic_L_$(p)_$(N)_$(distribution).csv", "a") do io
            println(io, stoc_obj)
        end

        # Append the value to a text file (one value per line)
        open("solve_times_stochastic_comparison_L_$(p)_$(N)_$(distribution).csv", "a") do io
            println(io, stoc_time)
        end

        model_stochastic = nothing
        stoc_obj = nothing
        stoc_time = nothing
        x_20_stochastic = nothing
        x_40_stochastic = nothing
        z_20_stochastic = nothing
        z_40_stochastic = nothing
        GC.gc(true)
    end
end