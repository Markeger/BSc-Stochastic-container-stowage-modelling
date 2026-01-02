from authentic_generator_np import DemandGenerator
import numpy as np

# Fixed cargo types to ensure consistency
cargo_types = [
    ("20ft", 3.0, "DC"), ("20ft", 9.0, "DC"), ("20ft", 14.0, "DC"), ("20ft", 21.0, "DC"), ("20ft", 27.0, "DC"), ("20ft", 30.0, "DC"), ("20ft", 33.0, "DC"),
    ("20ft", 14.0, "RC"), ("20ft", 21.0, "RC"), ("20ft", 27.0, "RC"), ("20ft", 30.0, "RC"), ("20ft", 33.0, "RC"),
    ("40ft", 3.0, "DC"), ("40ft", 9.0, "DC"), ("40ft", 14.0, "DC"), ("40ft", 21.0, "DC"), ("40ft", 27.0, "DC"),
    ("40ft", 14.0, "RC"), ("40ft", 21.0, "RC"), ("40ft", 27.0, "RC"),
    ("40ft", 3.0, "HC"), ("40ft", 9.0, "HC"), ("40ft", 14.0, "HC"), ("40ft", 21.0, "HC"), ("40ft", 27.0, "HC"),
    ("40ft", 14.0, "HR"), ("40ft", 21.0, "HR"), ("40ft", 27.0, "HR")
]

def test_stochastic(p, size, middle_leg, loading_only, seed, n_scenarios, distribution):
    '''
    input:
    p:            (Int)       Amount of ports.
    size:         (String)    "S", "M" or "L".
    middle_leg:   (Int)       Last port to include loading.
    loading_only: (Boolean)   True/False
    seed:         (Int)       
    n_scenarios:  (Int)       Number of scenarios.
    distribution: (String)    "normal", "poisson", "neg_binomial", "lognormal" or "uniform".
    '''

    # Set vessel capacity based on size
    if size == "S":
        C = 7476
    elif size == "M":
        C = 11394
    elif size == "L":
        C = 17385
    elif size == "mini":
        C = 100
    else:
        raise ValueError("size must be 'S', 'M', 'L' or 'mini'")

    # Set target_utils length based on loading_only
    if loading_only:
        target_utils = np.ones(p // 2) * 0.95
    else:
        target_utils = np.ones(p - 1) * 0.95

    # Adjust target_utils for stochastic since include_current_port=False
    if loading_only:
        target_utils_adjusted = target_utils[1:] if len(target_utils) > 1 else target_utils
    else:
        target_utils_adjusted = target_utils[1:]

    # Generate port 1 LD for stochastic
    dg = DemandGenerator(
        P=p,
        C=C,
        target_utils=np.ones(1) * 0.90,  # This is correct for current_port LD
        current_port=1,
        include_current_port=True,
        middle_leg=middle_leg,
        loading_only=loading_only,
        sparsity=0.0,
        perturb=0.1,
        distribution=distribution,
        seed=seed
    )

    loading_list = dg.generate_loading_list()

    # Generate moments for stochastic scenarios
    dg = DemandGenerator(
        P=p,
        C=C,
        target_utils=target_utils_adjusted,  # This is correct for current_port LD
        current_port=1,
        include_current_port=False,
        current_port_ld=loading_list,
        middle_leg=middle_leg,
        loading_only=loading_only,
        sparsity=0.0,
        perturb=0.1,
        distribution=distribution,
        seed=seed
    )

    mean_demand, std_demand = dg._generate_moments()

    # Generate scenarios
    dg = DemandGenerator(
        P=p,
        C=C,
        target_utils=target_utils_adjusted,
        current_port=1,
        include_current_port=False,
        current_port_ld=loading_list,
        middle_leg=None,
        loading_only=loading_only,
        sparsity=0.0,
        perturb=0.3,
        distribution=distribution,
        seed=seed
    )

    scenarios = dg._generate(mean_demand, std_demand, n_scenarios=n_scenarios)

    # Export loading_list to a .txt file
    FileName_Port_One = f"{size}_port_one_{p}_{loading_only}_{middle_leg}_{distribution}_{seed}.txt"
    with open(FileName_Port_One, "w") as f:
        f.write(f"{p} 1\n")
        for ctype in cargo_types:
            size_val, weight, ctype_str = ctype
            size_int = int(str(size_val).replace('ft', ''))
            f.write(f"{size_int} {weight} {ctype_str}\n")
        for ctype in dg.cargo_types:
            matrix = loading_list[ctype]
            for row in matrix:
                f.write(" ".join(str(int(x)) for x in row) + "\n")
    print(f"LD exported to {FileName_Port_One}")

    # Data file name, automatically set based on number of ports and scenarios
    FileName_Scenarios = f"{size}_scenarios_{p}_{n_scenarios}_{loading_only}_{middle_leg}_{distribution}_{seed}.txt"
    with open(FileName_Scenarios, "w") as f:
        f.write(f"{p} {n_scenarios}\n")
        for ctype in cargo_types:
            size_val, weight, ctype_str = ctype
            size_int = int(str(size_val).replace('ft', ''))
            f.write(f"{size_int} {weight} {ctype_str}\n")
        for scenario in scenarios:
            for ctype in dg.cargo_types:
                matrix = scenario[ctype]
                for row in matrix:
                    f.write(" ".join(str(int(x)) for x in row) + "\n")
    print(f"Scenarios exported to {FileName_Scenarios}")
    return FileName_Port_One, FileName_Scenarios