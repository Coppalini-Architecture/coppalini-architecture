(() => {
  const frame = document.querySelector('#model-frame');
  const title = document.querySelector('[data-model-title]');
  const scope = document.querySelector('[data-model-scope]');
  const open = document.querySelector('[data-model-open]');
  const buttons = [...document.querySelectorAll('[data-model]')];
  if (!frame || !title || !scope || !open || !buttons.length) return;

  const select = (button) => {
    buttons.forEach((candidate) => candidate.setAttribute('aria-pressed', String(candidate === button)));
    frame.src = button.dataset.src;
    frame.title = `Clear Onyx ${button.dataset.title} model`;
    title.textContent = button.dataset.title;
    scope.textContent = button.dataset.scope;
    open.href = button.dataset.src;
    open.textContent = `Open ${button.dataset.title} laboratory`;
  };

  buttons.forEach((button, index) => {
    button.setAttribute('aria-pressed', String(index === 0));
    button.addEventListener('click', () => select(button));
  });
})();
