(() => {
  'use strict';

  const track = document.getElementById('lineage-track');
  if (!track) return;

  const previous = document.getElementById('lineage-prev');
  const next = document.getElementById('lineage-next');
  const position = document.getElementById('lineage-position');
  const dialog = document.getElementById('lineage-dialog');
  const close = document.getElementById('lineage-close');
  const art = document.getElementById('lineage-inspection-art');
  const heading = document.getElementById('lineage-dialog-title');
  const operation = document.getElementById('lineage-operation');
  const equation = document.getElementById('lineage-equation');
  const equationText = document.getElementById('lineage-equation-text');
  const construction = document.getElementById('lineage-construction');
  const scope = document.getElementById('lineage-scope');
  const source = document.getElementById('lineage-source');
  const download = document.getElementById('lineage-download');
  const dialogPrevious = document.getElementById('lineage-dialog-prev');
  const dialogNext = document.getElementById('lineage-dialog-next');
  const reducedMotion = matchMedia('(prefers-reduced-motion: reduce)');
  let cards = [];
  let data = null;
  let active = 0;
  let opener = null;
  let scheduled = 0;

  const pad = (number) => String(number).padStart(2, '0');

  function displayEquation(value) {
    let output = value;
    const fractions = () => {
      const next = output.replace(/\\frac\{([^{}]*)\}\{([^{}]*)\}/g, '($1)/($2)');
      if (next === output) return;
      output = next;
      fractions();
    };
    output = output
      .replace(/\\;/g, ' ')
      .replace(/\\,/g, ' ')
      .replace(/\\qquad/g, '   ')
      .replace(/\\quad/g, ' ')
      .replace(/\\Rightarrow/g, '⇒')
      .replace(/\\wedge/g, '∧')
      .replace(/\\star/g, '⋆')
      .replace(/\\cong/g, '≅')
      .replace(/\\nvdash/g, '⊬')
      .replace(/\\notin/g, '∉')
      .replace(/\\neg/g, '¬')
      .replace(/\\pi/g, 'π')
      .replace(/\\theta/g, 'θ')
      .replace(/\\phi/g, 'φ')
      .replace(/\\mu/g, 'μ')
      .replace(/\\nu/g, 'ν')
      .replace(/\\gamma/g, 'γ')
      .replace(/\\alpha/g, 'α')
      .replace(/\\beta/g, 'β')
      .replace(/\\psi/g, 'ψ')
      .replace(/\\eta/g, 'η')
      .replace(/\\hbar/g, 'ℏ')
      .replace(/\\partial/g, '∂')
      .replace(/\\oint/g, '∮')
      .replace(/\\sum/g, 'Σ')
      .replace(/\\ln/g, 'ln')
      .replace(/\\log/g, 'log')
      .replace(/\\dot\s*/g, '')
      .replace(/\\mathbf\s*([A-Za-z])/g, '$1')
      .replace(/\\hat\s*([A-Za-z])/g, '$1̂')
      .replace(/\\mathrm\{([^}]*)\}/g, '$1')
      .replace(/\\mathbb\{([^}]*)\}/g, '$1')
      .replace(/\\rm\s*([A-Za-z])/g, '$1')
      .replace(/\\sqrt\{([^}]*)\}/g, '√$1')
      .replace(/\\pmod\{([^}]*)\}/g, '(mod $1)')
      .replace(/\\frac([0-9])([0-9])/g, '$1/$2');
    fractions();
    return output
      .replace(/\^\{([^}]*)\}/g, '^($1)')
      .replace(/_\{([^}]*)\}/g, '_($1)')
      .replace(/\\/g, '')
      .replace(/\s{2,}/g, ' ')
      .trim();
  }

  function updatePosition() {
    if (!cards.length) return;
    const box = track.getBoundingClientRect();
    const visible = cards
      .map((card, index) => ({ card, index, rect: card.getBoundingClientRect() }))
      .filter(({ rect }) => rect.left >= box.left - 2 && rect.left < box.right - 10);
    const first = visible[0]?.index ?? 0;
    const last = visible[visible.length - 1]?.index ?? first;
    position.textContent = `${pad(first + 1)}${last > first ? `–${pad(last + 1)}` : ''} / ${pad(cards.length)}`;
    previous.disabled = track.scrollLeft < 2;
    next.disabled = track.scrollLeft >= track.scrollWidth - track.clientWidth - 2;
  }

  function step(direction) {
    if (!cards.length) return;
    const gap = Number.parseFloat(getComputedStyle(track).columnGap) || 16;
    const width = cards[0].getBoundingClientRect().width;
    track.scrollBy({
      left: direction * (width + gap),
      behavior: reducedMotion.matches ? 'instant' : 'smooth'
    });
  }

  function closeDialog() {
    if (dialog?.open) dialog.close();
  }

  function render(index) {
    active = Math.max(0, Math.min(data.cards.length - 1, index));
    const item = data.cards[active];
    const image = document.createElement('img');
    image.src = item.art;
    image.alt = `${item.fullName || item.name}. ${item.operation}. ${item.sentence}`;
    art.replaceChildren(image);
    heading.textContent = item.fullName || item.name;
    operation.textContent = [item.date, item.operation].filter(Boolean).join(' / ');
    equation.textContent = displayEquation(item.equation);
    equationText.textContent = item.equationText;
    construction.textContent = item.construction;
    scope.textContent = item.scope;
    source.replaceChildren();
    for (const record of item.sources) {
      const listItem = document.createElement('li');
      const anchor = document.createElement('a');
      anchor.href = record.url;
      anchor.textContent = record.label;
      anchor.target = '_blank';
      anchor.rel = 'noopener';
      listItem.append(anchor);
      source.append(listItem);
    }
    download.href = item.art;
    download.download = `${item.id}.svg`;
    dialogPrevious.disabled = active === 0;
    dialogNext.disabled = active === data.cards.length - 1;
  }

  function open(index, event) {
    if (event.ctrlKey || event.metaKey || event.shiftKey || event.altKey) return;
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
    button.className = 'lineage-card';
    button.dataset.lineageCard = card.id;
    button.setAttribute('aria-haspopup', 'dialog');
    button.setAttribute('aria-label', `Open ${card.fullName || card.name}: ${card.operation}`);
    image.src = card.art;
    image.alt = `${card.fullName || card.name}. ${card.operation}. ${card.sentence}`;
    hint.className = 'lineage-open-hint';
    hint.textContent = 'Inspect';
    button.append(image, hint);
    button.addEventListener('click', (event) => open(index, event));
    item.append(button);
    return item;
  }

  async function initialise() {
    try {
      const response = await fetch(track.dataset.source, { credentials: 'same-origin' });
      if (!response.ok) throw new Error(`Lineage response ${response.status}`);
      data = await response.json();
      track.replaceChildren(...data.cards.map(build));
      cards = [...track.querySelectorAll('[data-lineage-card]')];
      updatePosition();
      new ResizeObserver(updatePosition).observe(track);
    } catch (error) {
      track.replaceChildren();
      const message = document.createElement('p');
      message.className = 'lineage-load-error';
      message.textContent = 'The lineage record is unavailable in this copy.';
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
    } else if (event.key === 'Home' || event.key === 'End') {
      event.preventDefault();
      track.scrollTo({
        left: event.key === 'Home' ? 0 : track.scrollWidth,
        behavior: reducedMotion.matches ? 'instant' : 'smooth'
      });
    }
  });
  close.addEventListener('click', closeDialog);
  dialog.addEventListener('close', () => opener?.focus({ preventScroll: true }));
  dialog.addEventListener('click', (event) => {
    if (event.target === dialog) closeDialog();
  });
  dialog.addEventListener('keydown', (event) => {
    if (event.key === 'ArrowLeft' && active > 0) {
      event.preventDefault();
      render(active - 1);
    } else if (event.key === 'ArrowRight' && active < data.cards.length - 1) {
      event.preventDefault();
      render(active + 1);
    }
  });
  dialogPrevious.addEventListener('click', () => render(active - 1));
  dialogNext.addEventListener('click', () => render(active + 1));
  initialise();
})();
