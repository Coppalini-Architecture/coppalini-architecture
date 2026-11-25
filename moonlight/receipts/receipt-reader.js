/* Reader-owned text check. No capture, persistence, clock, or mirror feedback. */
'use strict';
(() => {
  const form = document.querySelector('#receipt-form');
  const kind = document.querySelector('#receipt-kind');
  const text = document.querySelector('#receipt-text');
  const domain = document.querySelector('#receipt-domain');
  const result = document.querySelector('#receipt-result');
  const verdict = document.querySelector('#receipt-verdict');
  const meaning = document.querySelector('#receipt-meaning');
  const exampleButton = document.querySelector('#load-example');

  const meanings = {
    OK: 'The receipt matches the independently recomputed transition.',
    OK_WITH_DELTA: 'The receipt retains a complete, valid difference between recorded and recomputed outputs. Read its delta.',
    INVALID: 'The receipt fails the selected contract. Check its schema, types, canonical values, and complete delta.'
  };
  const domains = {
    harmonizer: 'Exact nearest-sector pull. Input x, h, and kappa use decimal strings.',
    relax: 'One N₂ phase step with Fibonacci contraction. The schedule index k is 2…300; input d is a reduced p/q string in [−1/2, 1/2).'
  };
  const examples = {
    harmonizer: {
      schema: 'CoppaliniArchitecture.MOONLIGHT-Harmonizer-Receipt/v0.1',
      rule: {id: 'nearest_sector_pull', tie: 'half_up', profile: 'plateau_smoothstep'},
      input: {q: 1, x: '5.25', h: '0.5', kappa: '0.5'},
      trace: {x_mod: '21/4', d: '1/4', w: '1/2'},
      recomputed: {s: 5, a: 5, y: '41/8'},
      recorded: {s: 5, a: 5, y: '41/8'},
      checks: {q_preserved: true, address_relation: true},
      delta: [],
      reader: {label: 'example-reader'}
    },
    relax: {
      schema: 'CoppaliniArchitecture.MOONLIGHT-Relax-Receipt/v0.1',
      rule: {id: 'fibonacci_quotient_relax', schedule: 'rho_k=Fib_{k-1}/Fib_k'},
      input: {q: 1, s: 5, a: 5, d: '1/4', k: 10},
      trace: {rho: '34/55', kappa: '21/55', phase_step: 2},
      recomputed: {q: 3, s: 5, a: 279, d: '17/110'},
      recorded: {q: 3, s: 5, a: 279, d: '17/110'},
      checks: {s_preserved: true, address_relation_input: true, address_relation_output: true, non_expansion: true},
      delta: [],
      reader: {label: 'example-reader'}
    }
  };

  function show(status, explanation) {
    result.dataset.state = status;
    verdict.textContent = status;
    meaning.textContent = explanation;
  }

  function resetResult() {
    show('Ready', 'The current text is ready for checking.');
  }

  kind.addEventListener('change', () => {
    domain.textContent = domains[kind.value];
    resetResult();
  });
  text.addEventListener('input', resetResult);
  exampleButton.addEventListener('click', () => {
    text.value = JSON.stringify(examples[kind.value], null, 2);
    show('Ready', 'Example loaded with the declared label example-reader. Select Check receipt to run it.');
  });
  form.addEventListener('submit', event => {
    event.preventDefault();
    const checker = window.MoonlightReceiptCheckers && window.MoonlightReceiptCheckers[kind.value];
    if (!checker || typeof checker.checkText !== 'function') {
      show('Unavailable', 'The checker did not load. Reload the page or use the downloadable Python checker.');
      return;
    }
    try {
      // Pass the original text through lexical validation before any parsing.
      const status = checker.checkText(text.value);
      if (!Object.prototype.hasOwnProperty.call(meanings, status)) {
        show('Unavailable', 'The checker returned an unsupported result.');
        return;
      }
      show(status, meanings[status]);
    } catch (_) {
      show('Unavailable', 'The checker could not complete this read. The entered text is retained.');
    }
  });
})();
