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
mkpath("loading_lists_solve_time")
mkpath("solve_times")

data_file_ship = "Small_ship.txt"
data_ship = read_ship_instance(data_file_ship)


FactorK_O = 10

port = [8]
d = "normal"
seed_scenarios = [60618579, 54337087, 70277723, 57162433, 27836244]
n_scenarios = [10, 20, 30, 40, 50, 60, 70, 80, 90, 100]        # Number of scenarios

for p in port
    for n in n_scenarios
        filename = "solve_times/solve_times_S_local_$(p)_$(n).csv"
        if !isfile(filename)
            open(filename, "w") do io
                println(io, "scenario_seed,build_time,solve_time,best_objective")
            end
        end
        for s in seed_scenarios
            println("\nNow calculating for $(p) ports, seed $(s):")
            # Call the function with example arguments
            
            data_file_port_one, data_file_scenarios = data_gen.test_stochastic(p, "S", nothing, false, s, n, d)

            # Move the created data files to loading_lists folder
            run(`mv $data_file_port_one loading_lists_solve_time/`)
            run(`mv $data_file_scenarios loading_lists_solve_time/`)
            data_file_port_one = "loading_lists_solve_time/" * data_file_port_one
            data_file_scenarios = "loading_lists_solve_time/" * data_file_scenarios

            data_port_one = read_scenario_instance(data_file_port_one)
            data_file_port_one = nothing

            data_scenarios = read_scenario_instance(data_file_scenarios)
            data_file_stochastic = nothing

            build_time = @elapsed begin
                model, x_20, x_40, z_20, z_40 = build_stochastic_model_2(data_port_one, data_scenarios, data_ship, data_scenarios.n_scenarios)
            end
                
            x_20 = nothing
            x_40 = nothing
            z_20 = nothing
            z_40 = nothing
            data_F = nothing
            data_cluster = nothing
            GC.gc() # Run garbage collector
                
            set_silent(model)
            set_optimizer_attribute(model, "Threads", 1)
            set_optimizer_attribute(model, "ConcurrentMIP", 1)
            optimize!(model)

            time_val = solve_time(model)
            obj_val = objective_value(model)

            # Append the value to a text file (one value per line)
            open("solve_times/solve_times_S_local_$(p)_$(n).csv", "a") do io
            println(io, "$s,$build_time,$time_val,$obj_val")
            end

            data_port_one = nothing
            data_scenarios = nothing
            model = nothing
            GC.gc(true) # Run a *full* garbage collection to free all memory

            # if time_val > 23*60
            #     break
            # end
        end
    end
end