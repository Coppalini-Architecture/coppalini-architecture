(() => {
  "use strict";
  const referenceQ = [[1, 1], [1, 0]];
  const referenceOmega = [[0, 1], [-1, 0]];
  const multiply = (left, right) => left.map((row) => right[0].map((_, column) =>
    row.reduce((sum, value, index) => sum + value * right[index][column], 0)
  ));
  const subtract = (left, right) => left.map((row, i) => row.map((value, j) => value - right[i][j]));
  const matrixText = (matrix) => `[[${matrix[0].join(", ")}], [${matrix[1].join(", ")}]]`;
  const matches = (left, right) => left.every((row, i) => row.every((value, j) => value === right[i][j]));

  function run() {
    const output = document.querySelector("[data-exact-output]");
    const status = document.querySelector("[data-exact-status]");
    if (!output || !status) return;
    let q, omega;
    try {
      q = JSON.parse(document.querySelector("[data-input-q]").textContent);
      omega = JSON.parse(document.querySelector("[data-input-omega]").textContent);
      const valid = (matrix) => Array.isArray(matrix) && matrix.length === 2 && matrix.every((row) => Array.isArray(row) && row.length === 2 && row.every(Number.isSafeInteger));
      if (!valid(q) || !valid(omega) || !matches(q, referenceQ) || !matches(omega, referenceOmega)) throw new Error("reference mismatch");
    } catch {
      output.textContent = "The displayed inputs could not be matched to CA-ALG-001.";
      status.textContent = "FAIL · the declared input reference was not reproduced.";
      status.classList.toggle("exact-pass", false);
      status.classList.toggle("exact-fail", true);
      return;
    }
    const g = subtract(multiply(q, omega), multiply(omega, q));
    const gSquared = multiply(g, g);
    const trace = g[0][0] + g[1][1];
    const determinant = g[0][0] * g[1][1] - g[0][1] * g[1][0];
    const identitiesMatch = matches(g, [[-2, 1], [1, 2]]) && matches(gSquared, [[5, 0], [0, 5]]) && trace === 0 && determinant === -5;
    output.textContent = [
      `G = [Q, Ω] = ${matrixText(g)}`,
      `G² = ${matrixText(gSquared)}`,
      `tr(G) = ${trace}`,
      `det(G) = ${determinant}`
    ].join("\n");
    const declared = document.querySelector("[data-exact-expected]")?.textContent.trim();
    const passed = identitiesMatch && output.textContent === declared;
    status.textContent = passed
      ? "PASS · this browser run matches all four declared results."
      : "FAIL · this browser run differs from the declared result.";
    status.classList.toggle("exact-pass", passed);
    status.classList.toggle("exact-fail", !passed);
  }
  document.addEventListener("DOMContentLoaded", () => {
    document.querySelector("[data-exact-recompute]")?.addEventListener("click", run);
  });
})();
