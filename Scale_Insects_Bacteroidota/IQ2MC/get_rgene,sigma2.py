#!/usr/bin/env python3

"""
Estimate rgene_gamma and sigma2_gamma priors for MCMCTree from an ML tree.

The script:
1. Reads an IQ-TREE / MCMCTree Newick tree.
2. Removes calibration annotations.
3. Calculates root-to-tip distances.
4. Estimates:
   - rgene_gamma from mean substitution rate
   - sigma2_gamma from empirical rate variation

MCMCTree parameterization:
Gamma mean = alpha / beta
"""

import re
import os
import statistics
from io import StringIO
from Bio import Phylo


# ============================================================
# USER SETTINGS
# ============================================================

TREE_FILE_PATH = "host.treefile"

# Root age in MCMCTree time units
EXPECTED_ROOT_AGE = 3.0

# rgene_gamma shape parameter
RGENE_ALPHA = 2.0

# sigma2_gamma shape parameter
SIGMA2_ALPHA = 1.0

# ============================================================


def clean_newick(tree_string):
    """
    Remove IQ-TREE/MCMCTree annotations.
    """

    tree = tree_string.strip().splitlines()[0]

    # Remove calibration annotations such as '>1.21'
    tree = re.sub(r"'[^']*'", "", tree)

    # Remove node support values
    tree = re.sub(r"\)([0-9eE.+\-\/_]+):", "):", tree)

    return tree


def root_to_tip_distances(tree):

    distances = []

    for tip in tree.get_terminals():
        distances.append(tree.distance(tree.root, tip))

    return distances


def main():

    if not os.path.exists(TREE_FILE_PATH):
        print(f"ERROR: Cannot find {TREE_FILE_PATH}")
        return

    with open(TREE_FILE_PATH) as f:
        raw_tree = f.read()

    cleaned = clean_newick(raw_tree)

    tree = Phylo.read(StringIO(cleaned), "newick")

    tip_dists = root_to_tip_distances(tree)


    # --------------------------------------------------------
    # Root-to-tip statistics
    # --------------------------------------------------------

    mean_d = statistics.mean(tip_dists)
    median_d = statistics.median(tip_dists)
    sd_d = statistics.stdev(tip_dists)

    cv = sd_d / mean_d


    # --------------------------------------------------------
    # rgene_gamma
    # --------------------------------------------------------

    mean_rate = mean_d / EXPECTED_ROOT_AGE
    median_rate = median_d / EXPECTED_ROOT_AGE

    rgene_beta_mean = RGENE_ALPHA / mean_rate
    rgene_beta_median = RGENE_ALPHA / median_rate


    # --------------------------------------------------------
    # sigma2_gamma
    # --------------------------------------------------------

    # Approximate rate variance from root-to-tip variation
    sigma2 = cv ** 2

    sigma2_beta = SIGMA2_ALPHA / sigma2


    # --------------------------------------------------------
    # Output
    # --------------------------------------------------------

    print()
    print("=" * 75)
    print("          IQ2MC MCMCTree PRIOR ESTIMATOR")
    print("=" * 75)

    print(f"Tree file                 : {TREE_FILE_PATH}")
    print(f"Number of taxa            : {len(tip_dists)}")

    print()
    print("Root-to-tip distances")
    print("-" * 75)

    print(f"Mean                      : {mean_d:.6f}")
    print(f"Median                    : {median_d:.6f}")
    print(f"SD                        : {sd_d:.6f}")
    print(f"CV                        : {cv:.3f}")


    print()
    print(f"Root age                  : {EXPECTED_ROOT_AGE:.3f}")


    print()
    print("Estimated substitution rate")
    print("-" * 75)

    print(f"Mean rate                 : {mean_rate:.6e}")
    print(f"Median rate               : {median_rate:.6e}")


    print()
    print("Suggested rgene_gamma")
    print("-" * 75)

    print(
        f"Mean-based                : "
        f"rgene_gamma = {RGENE_ALPHA:g} {rgene_beta_mean:.2f} 1"
    )

    print(
        f"Median-based              : "
        f"rgene_gamma = {RGENE_ALPHA:g} {rgene_beta_median:.2f} 1"
    )


    print()
    print("Suggested sigma2_gamma")
    print("-" * 75)

    print(f"Estimated rate variance    : {sigma2:.3f}")

    print(
        f"sigma2_gamma              : "
        f"{SIGMA2_ALPHA:g} {sigma2_beta:.2f} 1"
    )


    print()
    print("Recommended MCMCTree settings")
    print("-" * 75)

    print(
        f"rgene_gamma  = {RGENE_ALPHA:g} {rgene_beta_mean:.2f} 1"
    )

    print(
        f"sigma2_gamma = {SIGMA2_ALPHA:g} {sigma2_beta:.2f} 1"
    )


    print()
    print("Note:")
    print("sigma2_gamma is an empirical estimate from root-to-tip")
    print("rate variation and should be evaluated by sensitivity tests.")


    print("=" * 75)


if __name__ == "__main__":
    main()
