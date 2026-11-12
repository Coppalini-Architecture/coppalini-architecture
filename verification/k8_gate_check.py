#!/usr/bin/env python3
"""Exact finite witness for the public K8 address gate."""

from itertools import combinations


VERTICES = ("∞", 0, 1, 2, 3, 4, 5, 6)


def edge(a, b):
    return frozenset((a, b))


def matching(r):
    return {edge("∞", r)} | {
        edge((r + offset) % 7, (r - offset) % 7)
        for offset in (1, 2, 3)
    }


def main():
    all_edges = {edge(a, b) for a, b in combinations(VERTICES, 2)}
    factorization = [matching(r) for r in range(7)]
    factor_edges = set().union(*factorization)

    assert len(VERTICES) == 8
    assert len(all_edges) == 28
    assert len(factorization) == 7
    assert all(len(m) == 4 for m in factorization)
    assert all(set().union(*m) == set(VERTICES) for m in factorization)
    assert sum(len(m) for m in factorization) == len(factor_edges)
    assert factor_edges == all_edges

    print("K8 gate exact witness")
    print("PASS K8.1  eight addressed vertices")
    print("PASS K8.2  twenty-eight unordered pairs")
    print("PASS K8.3  seven perfect matchings")
    print("PASS K8.4  matching factorization partitions E(K8)")
    print("ALL K8 GATE CHECKS PASSED")


if __name__ == "__main__":
    main()
