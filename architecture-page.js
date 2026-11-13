(() => {
  const frame = document.querySelector('#architecture-model-frame');
  const title = document.querySelector('[data-architecture-model-title]');
  const scope = document.querySelector('[data-architecture-model-scope]');
  const open = document.querySelector('[data-architecture-model-open]');
  const buttons = [...document.querySelectorAll('[data-architecture-model]')];
  if (!frame || !title || !scope || !open || !buttons.length) return;

  let selected = buttons[0];

  const select = (button) => {
    selected = button;
    buttons.forEach((candidate) => candidate.setAttribute('aria-pressed', String(candidate === button)));
    if (frame.dataset.loadedSrc !== button.dataset.src) {
      frame.src = button.dataset.src;
      frame.dataset.loadedSrc = button.dataset.src;
    }
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
  select(selected);
})();

(() => {
  'use strict';

  const deck = document.querySelector('#lineage-deck');
  if (!deck) return;

  const previous = document.querySelector('#lineage-prev');
  const next = document.querySelector('#lineage-next');
  const position = document.querySelector('#lineage-position');
  const dialog = document.querySelector('#lineage-detail-dialog');
  const close = document.querySelector('#lineage-detail-close');
  const image = document.querySelector('#lineage-detail-image');
  const date = document.querySelector('#lineage-detail-date');
  const title = document.querySelector('#lineage-detail-title');
  const operation = document.querySelector('#lineage-detail-operation');
  const construction = document.querySelector('#lineage-detail-construction');
  const scope = document.querySelector('#lineage-detail-scope');
  const location = document.querySelector('#lineage-detail-location');
  const sources = document.querySelector('#lineage-detail-sources');
  const download = document.querySelector('#lineage-detail-download');
  const dialogPrevious = document.querySelector('#lineage-detail-prev');
  const dialogNext = document.querySelector('#lineage-detail-next');
  const reducedMotion = window.matchMedia?.('(prefers-reduced-motion: reduce)') || { matches: false };

  const escapeHtml = (value = '') => String(value)
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;')
    .replaceAll("'", '&#039;');
  const pad = (value) => String(value).padStart(2, '0');

  let cards = [];
  let activeIndex = 0;
  let opener = null;
  let scheduled = 0;
  let previousOverflow = '';

  const cardElements = () => Array.from(deck.querySelectorAll('[data-lineage-index]'));

  const updatePosition = () => {
    const nodes = cardElements();
    if (!nodes.length) return;

    const computed = getComputedStyle(deck);
    const gap = parseFloat(computed.columnGap || computed.gap) || 16;
    const cardWidth = nodes[0].getBoundingClientRect().width;
    const stepWidth = cardWidth + gap;
    const first = Math.min(nodes.length - 1, Math.max(0, Math.round(deck.scrollLeft / stepWidth)));
    const visibleCount = Math.max(1, Math.floor((deck.clientWidth + gap + 1) / stepWidth));
    const last = Math.min(nodes.length - 1, first + visibleCount - 1);

    position.textContent = `${pad(first + 1)}${last > first ? `–${pad(last + 1)}` : ''} / ${pad(cards.length)}`;
    previous.disabled = deck.scrollLeft < 2;
    next.disabled = deck.scrollLeft >= deck.scrollWidth - deck.clientWidth - 2;
  };

  const schedulePositionUpdate = () => {
    cancelAnimationFrame(scheduled);
    scheduled = requestAnimationFrame(updatePosition);
  };

  const step = (direction) => {
    const first = cardElements()[0];
    if (!first) return;
    const computed = getComputedStyle(deck);
    const gap = parseFloat(computed.columnGap || computed.gap) || 16;
    deck.scrollBy({
      left: direction * (first.getBoundingClientRect().width + gap),
      behavior: reducedMotion.matches ? 'auto' : 'smooth'
    });
  };

  const setDialogCard = (index) => {
    activeIndex = Math.max(0, Math.min(cards.length - 1, index));
    const card = cards[activeIndex];
    if (!card) return;

    const name = card.fullName || card.name;
    image.src = card.art;
    image.alt = `${name} — ${card.operation || 'formal construction'}`;
    date.textContent = card.date || '';
    title.textContent = name;
    operation.textContent = card.operation || '';
    construction.textContent = card.construction || card.sentence || '';
    scope.textContent = card.scope || '';
    location.textContent = card.sourceSection || '';
    sources.innerHTML = (card.sources || []).map((source) => {
      const href = escapeHtml(source.url || '#');
      const label = escapeHtml(source.label || source.url || 'Source record');
      return `<li><a href="${href}" target="_blank" rel="noreferrer">${label} ↗</a></li>`;
    }).join('') || '<li>No primary source record is listed for this card.</li>';
    download.href = card.art;
    download.download = `${card.id || `lineage-${activeIndex + 1}`}.svg`;
    dialogPrevious.disabled = activeIndex === 0;
    dialogNext.disabled = activeIndex === cards.length - 1;
  };

  const showDialog = (index, trigger) => {
    if (!dialog || typeof dialog.showModal !== 'function') return;
    opener = trigger;
    setDialogCard(index);
    if (!dialog.open) {
      previousOverflow = document.body.style.overflow;
      document.body.style.overflow = 'hidden';
      dialog.showModal();
    }
  };

  const renderDeck = () => {
    deck.innerHTML = cards.map((card, index) => {
      const name = card.fullName || card.name;
      return `<li>
        <button type="button" class="lineage-deck-card" data-lineage-index="${index}" aria-label="Open details for ${escapeHtml(name)}">
          <span class="lineage-deck-card__art"><img src="${escapeHtml(card.art)}" alt="${escapeHtml(`${name} construction diagram`)}"></span>
          <span class="lineage-deck-card__copy">
            <span class="lineage-deck-card__date">${escapeHtml(card.date || '')}</span>
            <strong>${escapeHtml(name)}</strong>
            <span class="lineage-deck-card__operation">${escapeHtml(card.operation || '')}</span>
            <span class="lineage-deck-card__sentence">${escapeHtml(card.sentence || '')}</span>
          </span>
          <span class="lineage-deck-card__details">Details</span>
        </button>
      </li>`;
    }).join('');
    updatePosition();
  };

  previous.addEventListener('click', () => step(-1));
  next.addEventListener('click', () => step(1));
  deck.addEventListener('scroll', schedulePositionUpdate, { passive: true });
  deck.addEventListener('click', (event) => {
    const trigger = event.target.closest('[data-lineage-index]');
    if (!trigger) return;
    showDialog(Number(trigger.dataset.lineageIndex), trigger);
  });
  deck.addEventListener('keydown', (event) => {
    if (event.altKey || event.ctrlKey || event.metaKey || event.shiftKey) return;
    if (event.key === 'ArrowRight' || event.key === 'ArrowLeft') {
      event.preventDefault();
      step(event.key === 'ArrowRight' ? 1 : -1);
    }
    if (event.key === 'Home' || event.key === 'End') {
      event.preventDefault();
      deck.scrollTo({ left: event.key === 'Home' ? 0 : deck.scrollWidth, behavior: reducedMotion.matches ? 'auto' : 'smooth' });
    }
  });

  if (window.ResizeObserver) new ResizeObserver(updatePosition).observe(deck);
  else window.addEventListener('resize', updatePosition);

  if (close) close.addEventListener('click', () => dialog.close());
  if (dialog) {
    dialog.addEventListener('click', (event) => {
      if (event.target === dialog) dialog.close();
    });
    dialog.addEventListener('keydown', (event) => {
      if (event.key === 'ArrowLeft' && activeIndex > 0) {
        event.preventDefault();
        setDialogCard(activeIndex - 1);
      }
      if (event.key === 'ArrowRight' && activeIndex < cards.length - 1) {
        event.preventDefault();
        setDialogCard(activeIndex + 1);
      }
    });
    dialog.addEventListener('close', () => {
      document.body.style.overflow = previousOverflow;
      opener?.focus({ preventScroll: true });
    });
  }
  if (dialogPrevious) dialogPrevious.addEventListener('click', () => setDialogCard(activeIndex - 1));
  if (dialogNext) dialogNext.addEventListener('click', () => setDialogCard(activeIndex + 1));

  fetch('formal-lineage-catalog.json')
    .then((response) => {
      if (!response.ok) throw new Error('Lineage catalog unavailable');
      return response.json();
    })
    .then((catalog) => {
      cards = (catalog.cards || []).slice(0, 24);
      renderDeck();
    })
    .catch(() => {
      deck.innerHTML = '<li class="empty-state">The formal lineage catalog could not be loaded in this view.</li>';
    });
})();
