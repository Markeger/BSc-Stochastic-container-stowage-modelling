using Plots
using JuMP
using StatsPlots
using Statistics

include("scenarios_instance_reader.jl")
include("ship_reader.jl")
include("ReleaseGenerator.jl")
include("StochasticModel_Simple.jl")

data_file_ship = "Small_ship.txt"
data_ship = read_ship_instance(data_file_ship)

FactorK_O = 10

t = [Float64[] for _ in 1:6]
ports = [5, 6, 7, 8, 9, 10]
seed = 98364998
n_scenarios = [25, 50, 75, 100, 125, 150, 175, 200]     # Number of scenarios

colors = [:blue, :deepskyblue, :cyan, :orange, :orangered, :red]

plt = plot()

for (i, p) in enumerate(ports)
    data_file = "/Users/konggullerod/Documents/Dokumenter/Skole - DTU/7. Semester/Bachelor projekt/Model/Stochastic_Data/Mixed_Voyage/Small_ship/S_S_$(p)_CP_False_None_$(seed).txt"
    data_CP = read_scenario_instance(data_file)
    R = create_release(data_CP, data_ship; release_fraction = 0.80)

    for n in n_scenarios
        data_file = "/Users/konggullerod/Documents/Dokumenter/Skole - DTU/7. Semester/Bachelor projekt/Model/Stochastic_Data/Mixed_Voyage/Small_ship/S_S_$(p)_$(n)_False_None_$(seed).txt"
        data_F = read_scenario_instance(data_file)

        println("\nRunning ", n, " scenarios.")

        model, x_20, x_40 = build_stochastic_model_simple(data_CP, R, data_F, data_ship)
        set_silent(model)
        optimize!(model)
        println("Time: ", solve_time(model))
        push!(t[i], solve_time(model))

        if solve_time(model) > 50*60
            break
        end
    end

    labels = string.(5:60)

    plot!(plt, n_scenarios[1:length(t[i])], (t[i] ./ 60), color=:gray)
    scatter!(plt, n_scenarios[1:length(t[i])], (t[i] ./ 60), marker=(:circle,5), color=colors[i], label="$(p) Ports")
end

display(plt)
savefig("SamletScatterplot_MixedVoyage.png")