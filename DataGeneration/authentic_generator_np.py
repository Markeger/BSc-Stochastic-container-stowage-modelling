"""
Author: Jaike van Twiller
Year: 2025
Paper: https://arxiv.org/abs/2504.04469 (Note: code will be part of a revised version, not in paper yet)
"""

import numpy as np
import random
from scipy.stats import truncnorm


class DemandGenerator:
    """
    Class to generate transport matrices (OD matrices) for container vessel stowage planning.

    Generates "authentic" expected OD matrices that meet target utilization per loading port,
    supports multiple cargo types with shares, and can produce randomized scenario realizations.

    Authentic instances of Ding & Chou (2015): https://www.sciencedirect.com/science/article/pii/S0377221715002660.
    """

    def __init__(self,
              P: int,
              C: int,
              target_utils: list,
              current_port: int = 1,
              include_current_port: bool = True,
              current_port_ld: list = None,
              middle_leg: int = None,
              loading_only: bool = False,
              sparsity: float = 0.3,
              perturb: float = 0.2,
              cargo_shares: list = None,
          #    include_reefer: bool = True,
              distribution: str = "poisson",
              cv_demand: float = 1.0,
              seed: int = None):
        """
        Initializes the demand generator with vessel and cargo parameters.

        Parameters
        ----------
        P : int
            Total number of ports.
        C : int
            Total vessel capacity (number of containers that can be carried).
        target_utils : list of float
            Target utilization fractions per loading port.
        middle_leg : int, optional
            Index separating loading and discharging ports. Defaults to P // 2 if None.
        loading_only : bool, optional
            If True, loading ports only ship to discharging ports. Defaults to False.
        sparsity : float, optional
            Probability of zeroing an OD pair in the matrix, in [0, 1]. Defaults to 0.3.
        perturb : float, optional
            Fractional perturbation applied to matrix entries, in [0, 1]. Defaults to 0.2.
        cargo_shares : list, optional
            Shares for each cargo type (will be normalized). If None, uniform shares used.
        include_reefer : bool, optional
            Whether to include reefer cargo types. Defaults to True.
        distribution : str, optional
            Distribution used for randomization ("poisson", "neg_binomial", "lognormal",
            "normal", "uniform"). Defaults to "poisson".
        cv_demand : float, optional
            Coefficient of variation of distribution. Common values are {0.5,1.0,1.5}, but in (0, \inf). Defaults to 1.0.
        seed : int, optional
            Random seed for reproducibility. Defaults to None.
        """
        self.P = int(P)
        self.C = int(C)
        self.target_utils = np.array(target_utils, dtype=float)
        self.current_port = int(current_port)
        self.include_current_port = bool(include_current_port)
        self.current_port_ld = current_port_ld
        # Enforce: current_port_ld is not allowed if include_current_port is True
        if self.current_port_ld is not None and self.include_current_port:
            raise ValueError("current_port_ld cannot be used when include_current_port=True. Set include_current_port=False to use current_port_ld.")
        # Determine the starting port index for demand generation
        if self.include_current_port:
            self.start_port = self.current_port - 1  # 0-based index
        else:
            self.start_port = self.current_port      # 0-based index
        self.middle_leg = (middle_leg if middle_leg is not None else (self.P // 2))
        self.loading_only = bool(loading_only)
        self.sparsity = float(sparsity)
        self.perturb = float(perturb)
        self.distribution = distribution
        self.cv_demand = cv_demand
        self.seed = seed
        if seed is not None:
            np.random.seed(seed)
            random.seed(seed)

        # --- Define cargo categories ---
        
        """
        Costum cargo type for our project. Not part of Jaikes.
        """

        cargo_types = [
            ("20ft", 3.0, "DC"), ("20ft", 9.0, "DC"), ("20ft", 14.0, "DC"), ("20ft", 21.0, "DC"), ("20ft", 27.0, "DC"), ("20ft", 30.0, "DC"), ("20ft", 33.0, "DC"),
            ("20ft", 14.0, "RC"), ("20ft", 21.0, "RC"), ("20ft", 27.0, "RC"), ("20ft", 30.0, "RC"), ("20ft", 33.0, "RC"),
            ("40ft", 3.0, "DC"), ("40ft", 9.0, "DC"), ("40ft", 14.0, "DC"), ("40ft", 21.0, "DC"), ("40ft", 27.0, "DC"),
            ("40ft", 14.0, "RC"), ("40ft", 21.0, "RC"), ("40ft", 27.0, "RC"),
            ("40ft", 3.0, "HC"), ("40ft", 9.0, "HC"), ("40ft", 14.0, "HC"), ("40ft", 21.0, "HC"), ("40ft", 27.0, "HC"),
            ("40ft", 14.0, "HR"), ("40ft", 21.0, "HR"), ("40ft", 27.0, "HR")
        ]
        self.cargo_types = cargo_types
        K = len(cargo_types)

        self.weight = np.array([weight for _, weight, _ in cargo_types], dtype=float)

        # --- Process shares ---
        if cargo_shares is None:
            shares = np.full(K, 1.0 / K, dtype=float)  # uniform
        elif isinstance(cargo_shares, dict):
            shares = np.array([cargo_shares.get(ct, 0.0) for ct in cargo_types], dtype=float)
        else:
            shares = np.array(cargo_shares, dtype=float)
            if shares.shape[0] != K:  # stricter check
                raise ValueError(f"cargo_shares must have length {K}, got {shares.shape[0]}")

        # Clamp negatives, normalize, fallback uniform if needed
        shares = np.maximum(shares, 0.0)
        ssum = shares.sum()
        self.shares = shares / ssum if ssum > 0 else np.full(K, 1.0 / K, dtype=float)

        # --- TEU mapping ---
        self.teu = np.array([1 if size == "20ft" else 2 for size, *_ in cargo_types], dtype=int)
        self.mean_teu = float(np.sum(self.shares * self.teu))

    def __call__(self, *args, **kwargs):
        expected_demand, std_demand = self._generate_moments()
        random_demand = self._generate(expected_demand, std_demand, n_scenarios=5)
        return {"expected_demand": expected_demand,
                "random_demand": random_demand}

    # ---------- Partition helper ----------
    def _random_integer_partition(self, v: int, b: int):
        """
        Randomly partition integer v into b nonnegative integers (Ding & Chou, 2015).
        Returns a list of length b summing to v.
        """
        v = int(max(0, v))
        b = int(max(1, b))
        if b == 1:
            return [v]
        # Use combinatorial random composition via random cut points
        y = list(range(1, v + b))
        for i in range(b - 1):
            j = random.randint(i, v + b - 2)
            y[i], y[j] = y[j], y[i]
        y[:b - 1] = sorted(y[:b - 1])
        x = [y[0] - 1]
        for i in range(1, b - 1):
            x.append(y[i] - y[i - 1] - 1)
        x.append(v + b - 1 - y[b - 2])
        # ensure integer type
        return [int(xx) for xx in x]
    
    # ---------- Single load list generater ----------
    def generate_loading_list(self):
        """
        Generate a single scenario loading list for the current port.
        Returns a dict mapping cargo_type -> OD matrix (P x P), with only current_port as POL.
        If loading_only is True and current_port >= middle_leg, returns all zeros.
        """
        loading_matrix = {}
        # If loading_only and current_port >= middle_leg, return empty
        if self.loading_only and self.current_port >= self.middle_leg:
            for ctype in self.cargo_types:
                loading_matrix[ctype] = np.zeros((self.P, self.P), dtype=int)
            return loading_matrix

        # Otherwise, generate demand for current_port as POL
        for k, ctype in enumerate(self.cargo_types):
            C_k = max(0, int(round(self.C * self.shares[k]))) / self.mean_teu
            mat = np.zeros((self.P, self.P), dtype=int)
            pol = self.current_port - 1
            if self.loading_only:
                dest_start = self.middle_leg
            else:
                dest_start = pol + 1
            b = self.P - dest_start
            if b > 0:
                # Use the same partition logic as in _generate_authentic_matrix
                v = int(round(self.target_utils[pol] * C_k))
                partition = self._random_integer_partition(v, b)
                # Apply sparsity and perturbation
                for idx in range(b):
                    if random.random() < self.sparsity:
                        partition[idx] = 0
                    if partition[idx] > 0 and self.perturb > 0:
                        delta = int(round(partition[idx] * random.uniform(-self.perturb, self.perturb)))
                        partition[idx] = max(partition[idx] + delta, 0)
                # Apply distribution if not deterministic
                if self.distribution == "poisson":
                    partition = np.random.poisson(partition)
                elif self.distribution == "neg_binomial":
                    # Use mean=partition, variance=partition*(1+cv^2), r=mean^2/(var-mean), p=r/(r+mean)
                    mean = np.array(partition, dtype=float)
                    cv = self.cv_demand if hasattr(self, 'cv_demand') else 1.0
                    var = mean + (cv**2) * mean**2
                    r = np.where(var > mean, mean**2 / (var - mean + 1e-8), 1.0)
                    p = np.where(mean > 0, r / (r + mean), 1.0)
                    partition = np.random.negative_binomial(r, p).astype(int)
                elif self.distribution == "lognormal":
                    # Use mean=partition, std=partition*cv
                    mean = np.array(partition, dtype=float)
                    cv = self.cv_demand if hasattr(self, 'cv_demand') else 1.0
                    sigma = np.sqrt(np.log(1 + (cv**2)))
                    mu = np.log(mean + 1e-8) - 0.5 * sigma**2
                    partition = np.random.lognormal(mu, sigma).astype(int)
                elif self.distribution == "normal":
                    std = np.sqrt(np.abs(partition))
                    partition = np.random.normal(partition, std).clip(min=0).astype(int)
                elif self.distribution == "uniform":
                    partition = np.random.uniform(0, 2 * np.array(partition)).astype(int)
                # else: keep as is for deterministic
                mat[pol, dest_start:] = np.array(partition, dtype=int)
            loading_matrix[ctype] = mat
        return loading_matrix

    # ---------- Matrix generation ----------
    def _generate_authentic_matrix(self, P=None, C=None, target_utils=None, current_port_ld=None):
        """
        Generate an authentic transport matrix that attempts to meet target utilization per loading port (Ding & Chou, 2015).

        Returns a P x P integer numpy array.
        """
        P = int(self.P if P is None else P)
        C = int(self.C if C is None else C)
        tutils = (self.target_utils if target_utils is None else np.array(target_utils, dtype=float))
        current_port_ld = self.current_port_ld if current_port_ld is None else current_port_ld

        T = np.zeros((P, P), dtype=int)

        middle_leg = self.middle_leg
        # determine number of loading rows to process
        n_loading = (middle_leg if self.loading_only else P - 1)

        if len(tutils) != n_loading:
            raise ValueError(f"target_utils length ({len(tutils)}) must equal expected loading rows ({n_loading}).")

        # If current_port_ld is a dict of cargo_type -> OD matrix, sum onboard for each loading port
        onboard_list = None
        if current_port_ld is not None:
            if isinstance(current_port_ld, dict):
                # For each loading port i, sum all cargo types' row i
                onboard_list = []
                for i in range(n_loading):
                    onboard_i = 0
                    for arr in current_port_ld.values():
                        # Only sum the row for the loading port (i), and only for destinations after i
                        onboard_i += int(np.sum(arr[i, i+1:]))
                    onboard_list.append(onboard_i)
            else:
                # Assume it's a list/array of onboard values
                if len(current_port_ld) != n_loading:
                    raise ValueError(f"current_port_ld length ({len(current_port_ld)}) must equal expected loading rows ({n_loading}).")
                onboard_list = [int(x) for x in current_port_ld]

        for i in range(n_loading):
            dest_start = (middle_leg if self.loading_only else i + 1)
            b = P - dest_start
            if b <= 0:
                continue

            # compute target containers for this row i (subtract already assigned to later dest cols)
            assigned_so_far = np.sum(T[:i, dest_start:]) if i > 0 else 0
            # Use onboard_list if available
            if onboard_list is not None:
                onboard = onboard_list[i]
            else:
                onboard = 0
            v = int(round(tutils[i] * C)) - int(assigned_so_far) - onboard
            v = max(v, 0)

            # partition
            partition = self._random_integer_partition(v, b)

            # apply sparsity: zero out some OD pairs
            for idx in range(b):
                if random.random() < self.sparsity:
                    partition[idx] = 0

            # renormalize to match v (if possible)
            s = int(sum(partition))
            if s > 0:
                scaled = np.array([int(round(x * v / s)) for x in partition])
                diff = v - scaled.sum()

                if diff > 0:
                    # add 1 to the first `diff` largest fractional parts
                    frac = np.array(partition) * v / s - scaled
                    idx = np.argsort(-frac)[:diff]
                    scaled[idx] += 1
                elif diff < 0:
                    # subtract 1 from the first `-diff` largest (non-zero) cells
                    frac = scaled - np.array(partition) * v / s
                    idx = np.argsort(-frac)[: -diff]
                    for i2 in idx:
                        if scaled[i2] > 0:
                            scaled[i2] -= 1
            else:
                # all zeros due to sparsity or v==0; if v>0 force a random dest to hold v
                if v > 0:
                    idx0 = random.randint(0, b - 1)
                    partition[idx0] = v

            # apply perturbation (fractional +/-): otherwise it is a deterministic fit to target utils
            for idx in range(b):
                if partition[idx] > 0 and self.perturb > 0:
                    delta = int(round(partition[idx] * random.uniform(-self.perturb, self.perturb)))
                    partition[idx] = max(partition[idx] + delta, 0)

            T[i, dest_start:] = np.array(partition, dtype=int)

        return T

    def _generate_moments(self):
        """
        Generate OD matrices for multiple cargo types.

        Returns:
            T_multi: dict mapping cargo_type tuple -> OD matrix (numpy array)
            cargo_types: list of cargo_type tuples
        """
        expected_demand = {}
        for k, ctype in enumerate(self.cargo_types):
            # allocate capacity (at least 0)
            C_k = max(0, int(round(self.C * self.shares[k]))) / self.mean_teu
            # generate full zero matrix
            full_matrix = np.zeros((self.P, self.P), dtype=int)
            # generate demand for the selected block
            block_matrix = self._generate_authentic_matrix(P=self.P, C=C_k, target_utils=self.target_utils, current_port_ld=self.current_port_ld)
            # fill only the relevant block (from start_port to end)
            s = self.start_port
            full_matrix[s:, s:] = block_matrix[s:, s:]
            expected_demand[ctype] = full_matrix

        # Std_demand = self.cv_demand * expected_demand
        std_demand = { ctype: self.cv_demand * expected_demand[ctype] for ctype in self.cargo_types}
        return expected_demand, std_demand

    # ---------- Randomization / scenario generation ----------
    def _generate(self, expected_val: dict, std_val: dict, n_scenarios: int = 10,  seed: int = None):
        """
        Take expected OD matrices (per cargo type) and randomize into scenarios.

        Parameters
        ----------
        expected_val : dict
            Mapping cargo_type -> expected OD numpy array
        std_val : dict
            Mapping cargo_type -> stddev OD numpy array
        n_scenarios : int
            Number of scenarios to generate
        seed : int
            Optional seed for random draws (overrides instance seed for this call)

        Returns
        -------
        scenarios : list of dicts
            Each element is a dict mapping cargo_type -> randomized OD numpy array
        """
        if seed is not None:
            np.random.seed(seed)
            random.seed(seed)
        elif self.seed is not None:
            np.random.seed(self.seed)
            random.seed(self.seed)

        scenarios = []
        for s in range(int(n_scenarios)):
            scenario = {}
            for ctype, T_exp in expected_val.items():
                if self.distribution == "poisson":
                    T_rand = np.random.poisson(T_exp)

                elif self.distribution == "normal":
                    # todo: normal is biased to clipping => 0, hence samples have higher sample mean than its expected value
                    T_rand = np.random.normal(T_exp, std_val[ctype]).clip(min=0).astype(int)

                elif self.distribution == "uniform":
                    # Uniform in [0, 2*mean]
                    low = 0
                    high = 2*T_exp
                    T_rand = np.random.uniform(low=low, high=high, size=T_exp.shape)

                else:
                    raise ValueError(f"Unknown distribution: {self.distribution}")
                scenario[ctype] = np.round(T_rand).astype(int)
            scenarios.append(scenario)

        return scenarios


# ---------------- Example usage ----------------
if __name__ == "__main__":
    P = 6
    C = 20000
    loading_only = True
    middle_leg = P // 2

    # Make sure the lengths match the voyage length P
    if loading_only:
        target_utils = [0.6, 0.8, 1.0] # length = P//2
    else:
        target_utils = [0.6, 0.8, 1.0, 0.8, 0.6]  # length = P-1

    # slight randomization to target utils (example)
    target_utils = np.array(target_utils) * np.random.uniform(0.9, 1.1, size=len(target_utils))

    dg = DemandGenerator(
        P=P,
        C=C,
        target_utils=target_utils,
        middle_leg=middle_leg,
        loading_only=loading_only,
        sparsity=0.25,
        perturb=0.15,
    #   include_reefer=True,
        distribution="poisson",
        seed=42
    )

    expected_demand, std_demand = dg._generate_moments()
    demand = dg._generate(expected_demand, std_demand)
    cargo_sample = list(expected_demand.keys())[0]
    print("--------------------")
    print(f"Scenario 0 – Cargo type: {cargo_sample}")
    print(f"OD matrix shape: {demand[0][cargo_sample].shape}")
    print("OD matrix:\n", demand[0][cargo_sample])
    print(f"Total containers for this cargo type: {demand[0][cargo_sample].sum()}")

    # Analyze target vs actual utilizations
    def onboard_transports(ports: int, pol: int) -> np.array:
        """List of cargo groups that are onboard after port `pol`"""
        on_board = [(i, j) for i in range(ports) for j in range(ports) if i <= pol and j > pol]
        return np.array(on_board)

    ob_demand = []
    ob_teus = []
    transport_indices = [(i, j) for i in range(P) for j in range(P) if i < j]
    for pol in range(P - 1):
        ob = 0
        ob_teu = 0
        for (i, j) in onboard_transports(P, pol):
            k = 0
            for key in dg.cargo_types:
                ob += demand[0][key][i, j]
                ob_teu += demand[0][key][i, j] * dg.teu[k]
                k += 1
        ob_demand.append(ob)
        ob_teus.append(ob_teu)

    print("--------------------")
    print(f"Onboard demand per port: {ob_demand}")
    print(f"Onboard TEU per port: {ob_teus}")
    actual_utils = np.array(ob_teus) / C
    print("Target utilizations:", target_utils)
    print(f"Actual utilizations: {actual_utils}")
