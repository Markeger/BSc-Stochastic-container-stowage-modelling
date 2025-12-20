import os
import re
import sys
import csv

def extract_gap(file_path):
    """
    Extract the gap percentage from a Gurobi log file.
    """
    try:
        with open(file_path, 'r') as f:
            content = f.read()
        # Search for the line containing "gap" followed by percentage
        match = re.search(r'gap (\d+\.\d+)%', content)
        if match:
            return match.group(1)
        else:
            return None
    except Exception as e:
        print(f"Error reading {file_path}: {e}")
        return None

def extract_objective(file_path):
    """
    Extract the best objective value from a Gurobi log file.
    """
    try:
        with open(file_path, 'r') as f:
            content = f.read()
        # Search for the line containing "Best objective"
        match = re.search(r'Best objective ([\d.e+-]+)', content)
        if match:
            return match.group(1)
        else:
            return None
    except Exception as e:
        print(f"Error reading {file_path}: {e}")
        return None
    
def extract_solve_time(file_path):
    """
    Extract the solve time in seconds from a Gurobi log file.
    """
    try:
        with open(file_path, 'r') as f:
            content = f.read()
        # Search for the line containing "in X.XX seconds"
        match = re.search(r'in (\d+\.\d+) seconds', content)
        if match:
            return match.group(1)
        else:
            return None
    except Exception as e:
        print(f"Error reading {file_path}: {e}")
        return None
    

def main():
    directory = "/Users/konggullerod/Documents/Dokumenter/Skole - DTU/7. Semester/Bachelor projekt/Step 2/gurobi_expected_stochastic_logs"
    seeds = [68418150, 12908330, 77804901, 96998883, 76515133]
    P_values = [8, 10, 15]
    distributions = ["normal", "lognormal", "uniform"]
    n_values = [10, 20, 30, 40, 50]
    
    for p in P_values:
        for d in distributions:
            if d == "normal":
                N = 40000
            elif d == "lognormal":
                N = 70000
            else:  # uniform
                N = 15000
            for n in n_values:
                data = []
                for s in seeds:  # Husk at ændre dette for andre løsninger!!!
                    filename = f"gurobi_solve_log_expected_stochastic_S_{p}_{N}_{n}_{d}_{s}.txt"
                    file_path = os.path.join(directory, filename)
                    if os.path.exists(file_path):
                        gap = extract_gap(file_path)
                        objective = extract_objective(file_path)
                        solve_time = extract_solve_time(file_path)
                        if gap and objective and solve_time:
                            data.append([s, gap, objective, solve_time])
                        else:
                            print(f"Could not extract data from {filename}")
                    else:
                        print(f"File {filename} not found")
                
                # Create CSV for this combination
                csv_filename = os.path.join(directory, f"data_EEV_S_{p}_{N}_{n}_{d}.csv")
                with open(csv_filename, 'w', newline='') as csvfile:
                    writer = csv.writer(csvfile)
                    writer.writerow(["scenario_seed", "mip_gap", "best_objective", "solve_time"])
                    for row in data:
                        writer.writerow(row)
                print(f"Created {csv_filename} with {len(data)} entries")

if __name__ == "__main__":
    main()
