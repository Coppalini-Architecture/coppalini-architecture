(() => {
  const q = [[1, 1], [1, 0]];
  const omega = [[0, 1], [-1, 0]];

  const multiply = (left, right) => left.map((row) => right[0].map((_, column) =>
    row.reduce((sum, value, index) => sum + value * right[index][column], 0)
  ));
  const subtract = (left, right) => left.map((row, i) => row.map((value, j) => value - right[i][j]));
  const square = (matrix) => multiply(matrix, matrix);
  const matrixText = (matrix) => `[[${matrix[0].join(", ")}], [${matrix[1].join(", ")}]]`;
  const matches = (left, right) => left.every((row, i) => row.every((value, j) => value === right[i][j]));

  function render() {
    const output = document.querySelector("[data-exact-output]");
    const status = document.querySelector("[data-exact-status]");
    if (!output || !status) return;
    const g = subtract(multiply(q, omega), multiply(omega, q));
    const gSquared = square(g);
    const trace = g[0][0] + g[1][1];
    const determinant = g[0][0] * g[1][1] - g[0][1] * g[1][0];
    const passed = matches(g, [[-2, 1], [1, 2]]) && matches(gSquared, [[5, 0], [0, 5]]) && trace === 0 && determinant === -5;
    output.textContent = [
      `G = [Q, Ω] = ${matrixText(g)}`,
      `G² = ${matrixText(gSquared)}`,
      `tr(G) = ${trace}`,
      `det(G) = ${determinant}`
    ].join("\\n");
    status.textContent = passed ? "PASS · direct integer multiplication reproduces the declared result." : "FAILED · the declared result was not reproduced.";
    status.classList.toggle("exact-pass", passed);
  }

  document.addEventListener("DOMContentLoaded", () => {
    document.querySelector("[data-exact-recompute]")?.addEventListener("click", render);
    render();
  });
})();
