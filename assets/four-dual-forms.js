(() => {
  'use strict';

  const track = document.getElementById('four-forms-track');
  if (!track) return;

  const previous = document.getElementById('four-forms-prev');
  const next = document.getElementById('four-forms-next');
  const position = document.getElementById('four-forms-position');
  const dialog = document.getElementById('four-forms-dialog');
  const close = document.getElementById('four-forms-close');
  const art = document.getElementById('four-forms-art');
  const heading = document.getElementById('four-forms-dialog-title');
  const operation = document.getElementById('four-forms-operation');
  const equation = document.getElementById('four-forms-equation');
  const relation = document.getElementById('four-forms-relation');
  const result = document.getElementById('four-forms-result');
  const links = document.getElementById('four-forms-links');
  const reducedMotion = matchMedia('(prefers-reduced-motion: reduce)');
  let data;
  let cards = [];
  let active = 0;
  let opener = null;
  let scheduled = 0;

  const pad = (n) => String(n).padStart(2, '0');

  function updatePosition() {
    if (!cards.length) return;
    const viewport = track.getBoundingClientRect();
    const visible = cards
      .map((card, index) => ({ index, rect: card.getBoundingClientRect() }))
      .filter(({ rect }) => rect.left >= viewport.left - 2 && rect.left < viewport.right - 10);
    const first = visible[0]?.index ?? 0;
    const last = visible.at(-1)?.index ?? first;
    position.textContent = `${pad(first + 1)}${last > first ? `–${pad(last + 1)}` : ''} / ${pad(cards.length)}`;
    previous.disabled = track.scrollLeft < 2;
    next.disabled = track.scrollLeft >= track.scrollWidth - track.clientWidth - 2;
  }

  function step(direction) {
    const card = cards[0];
    if (!card) return;
    const gap = Number.parseFloat(getComputedStyle(track).columnGap) || 16;
    track.scrollBy({
      left: direction * (card.getBoundingClientRect().width + gap),
      behavior: reducedMotion.matches ? 'instant' : 'smooth'
    });
  }

  function render(index) {
    active = Math.max(0, Math.min(data.cards.length - 1, index));
    const item = data.cards[active];
    const image = document.createElement('img');
    image.src = item.art;
    image.alt = `${item.title} cover`;
    art.replaceChildren(image);
    heading.textContent = item.title;
    operation.textContent = item.operation;
    equation.textContent = item.equation;
    relation.textContent = item.relation;
    result.textContent = item.result;
    links.replaceChildren();
    for (const source of item.links) {
      const anchor = document.createElement('a');
      anchor.href = source.url;
      anchor.textContent = source.label;
      if (source.url.startsWith('https://')) {
        anchor.target = '_blank';
        anchor.rel = 'noopener';
      }
      links.append(anchor);
    }
  }

  function open(index, event) {
    event.preventDefault();
    if (typeof dialog?.showModal !== 'function') return;
    opener = cards[index];
    render(index);
    dialog.showModal();
  }

  function build(card, index) {
    const item = document.createElement('li');
    const button = document.createElement('button');
    const image = document.createElement('img');
    const hint = document.createElement('span');
    button.type = 'button';
    button.className = 'four-forms-card';
    button.setAttribute('aria-haspopup', 'dialog');
    button.setAttribute('aria-label', `Inspect ${card.title}: ${card.operation}`);
    image.src = card.art;
    image.alt = `${card.title} cover`;
    hint.className = 'four-forms-open-hint';
    hint.textContent = 'Inspect';
    button.append(image, hint);
    button.addEventListener('click', (event) => open(index, event));
    item.append(button);
    return item;
  }

  async function initialise() {
    try {
      const response = await fetch(track.dataset.source, { credentials: 'same-origin' });
      if (!response.ok) throw new Error(`Four Dual Forms response ${response.status}`);
      data = await response.json();
      track.replaceChildren(...data.cards.map(build));
      cards = [...track.querySelectorAll('.four-forms-card')];
      updatePosition();
      new ResizeObserver(updatePosition).observe(track);
    } catch (error) {
      track.replaceChildren();
      const message = document.createElement('p');
      message.className = 'four-forms-load-error';
      message.textContent = 'The four-form record is unavailable in this copy.';
      track.append(message);
    }
  }

  previous.addEventListener('click', () => step(-1));
  next.addEventListener('click', () => step(1));
  track.addEventListener('scroll', () => {
    cancelAnimationFrame(scheduled);
    scheduled = requestAnimationFrame(updatePosition);
  }, { passive: true });
  track.addEventListener('keydown', (event) => {
    if (event.altKey || event.ctrlKey || event.metaKey || event.shiftKey) return;
    if (event.key === 'ArrowRight' || event.key === 'ArrowLeft') {
      event.preventDefault();
      step(event.key === 'ArrowRight' ? 1 : -1);
    }
  });
  close.addEventListener('click', () => dialog.close());
  dialog.addEventListener('close', () => opener?.focus({ preventScroll: true }));
  dialog.addEventListener('click', (event) => {
    if (event.target === dialog) dialog.close();
  });
  initialise();
})();
