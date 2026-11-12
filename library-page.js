(() => {
  const papers = Array.isArray(window.ARCHIVE_PAPERS) ? window.ARCHIVE_PAPERS : [];
  const maps = Array.isArray(window.ARCHIVE_MAPS) ? window.ARCHIVE_MAPS : [];
  const details = window.ARCHIVE_DETAILS || {};
  const catalog = document.querySelector('#paper-catalog');
  const records = document.querySelector('#record-catalog');
  const search = document.querySelector('#paper-search');
  const status = document.querySelector('#catalog-status');
  const empty = document.querySelector('#catalog-empty');
  const controls = Array.from(document.querySelectorAll('[data-filter]'));
  const dialog = document.querySelector('#paper-detail-dialog');
  const detailClose = document.querySelector('#paper-detail-close');
  const detailCover = document.querySelector('#paper-detail-cover');
  const detailCode = document.querySelector('#paper-detail-code');
  const detailTitle = document.querySelector('#paper-detail-title');
  const detailStatus = document.querySelector('#paper-detail-status');
  const detailSummary = document.querySelector('#paper-detail-summary');
  const detailRole = document.querySelector('#paper-detail-role');
  const detailConnections = document.querySelector('#paper-detail-connections');
  const detailLinks = document.querySelector('#paper-detail-links');
  let detailOpener = null;

  const labels = {
    physical: 'Physical closure',
    current: 'Current synthesis',
    principal: 'Principle papers',
    basis: 'Language Mechanics',
    supporting: 'Supporting constructions',
    kernel: 'Earlier five-paper kernel'
  };
  const order = ['physical', 'current', 'principal', 'basis', 'supporting', 'kernel'];
  let activeFilter = 'all';

  const escapeHtml = (value = '') => String(value)
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;')
    .replaceAll("'", '&#039;');

  const initialHash = window.location.hash.slice(1);
  if (Object.hasOwn(labels, initialHash)) activeFilter = initialHash;

  const matchesFilter = (paper) => {
    if (activeFilter === 'all') return true;
    if (activeFilter === 'principal') return paper.section === 'principal' || paper.principal === true;
    return paper.section === activeFilter;
  };

  const matchesSearch = (paper, term) => {
    if (!term) return true;
    return [paper.code, paper.title, paper.status, paper.summary]
      .filter(Boolean)
      .join(' ')
      .toLocaleLowerCase()
      .includes(term);
  };

  const linkMarkup = (href, label) => {
    const external = /^https?:\/\//i.test(href);
    const download = /↓/.test(label);
    const attrs = [external ? 'target="_blank" rel="noreferrer"' : '', download ? 'download' : ''].filter(Boolean).join(' ');
    return `<a href="${escapeHtml(href)}" ${attrs}>${escapeHtml(label)}</a>`;
  };

  const coverMarkup = (paper, className, alt = '') => {
    if (paper.cover) return `<img src="${escapeHtml(paper.cover)}" alt="${escapeHtml(alt)}">`;
    return `<span class="${className}__placeholder">${escapeHtml(paper.code || paper.title)}</span>`;
  };

  const detailFor = (paper) => details[paper.id] || {
    role: `This document belongs to the ${labels[paper.section] || 'Library'} shelf and carries its declared comparison into the larger dependency chain.`,
    connections: [paper.summary]
  };

  const cardMarkup = (paper) => {
    const cover = paper.cover
      ? `<a class="paper-cover" href="${escapeHtml(paper.pdf)}" aria-label="Read ${escapeHtml(paper.title)}"><img src="${escapeHtml(paper.cover)}" alt=""></a>`
      : `<a class="paper-cover placeholder" href="${escapeHtml(paper.pdf)}" aria-label="Read ${escapeHtml(paper.title)}">${escapeHtml(paper.code || paper.title)}</a>`;
    const links = [
      `<button class="paper-details" type="button" data-paper-details="${escapeHtml(paper.id)}">Details</button>`,
      linkMarkup(paper.pdf, 'Read PDF'),
      ...(paper.links || []).map(([href, label]) => linkMarkup(href, label))
    ].join('');
    return `<article class="paper-card">
      ${cover}
      <div class="paper-card__body">
        <p class="paper-card__code">${escapeHtml(paper.code || labels[paper.section] || 'Paper')}</p>
        <h3><a href="${escapeHtml(paper.pdf)}">${escapeHtml(paper.title)}</a></h3>
        <p class="paper-card__status">${escapeHtml(paper.status || '')}</p>
        <p class="paper-card__summary">${escapeHtml(paper.summary || '')}</p>
        <div class="paper-links">${links}</div>
      </div>
    </article>`;
  };

  const renderPaperDetails = (paper, opener) => {
    if (!dialog || typeof dialog.showModal !== 'function') {
      window.location.assign(paper.pdf);
      return;
    }
    const detail = detailFor(paper);
    detailOpener = opener;
    detailCover.innerHTML = coverMarkup(paper, 'paper-detail-cover', `Cover artwork for ${paper.title}`);
    detailCode.textContent = paper.code || labels[paper.section] || 'Paper';
    detailTitle.textContent = paper.title;
    detailStatus.textContent = paper.status || '';
    detailSummary.textContent = paper.summary || '';
    detailRole.textContent = detail.role || '';
    detailConnections.innerHTML = (detail.connections || []).map((item) => `<li>${escapeHtml(item)}</li>`).join('');
    detailLinks.innerHTML = [
      linkMarkup(paper.pdf, 'Read PDF'),
      ...(paper.links || []).map(([href, label]) => linkMarkup(href, label))
    ].join('');
    dialog.showModal();
  };

  const bindDetailButtons = () => {
    catalog.querySelectorAll('[data-paper-details]').forEach((button) => {
      button.addEventListener('click', () => {
        const paper = papers.find((entry) => entry.id === button.dataset.paperDetails);
        if (paper) renderPaperDetails(paper, button);
      });
    });
  };

  const renderPapers = () => {
    const term = search.value.trim().toLocaleLowerCase();
    const filtered = papers.filter((paper) => matchesFilter(paper) && matchesSearch(paper, term));
    const sections = activeFilter === 'all' ? order : [activeFilter];

    catalog.innerHTML = sections.map((section) => {
      const items = filtered.filter((paper) => {
        if (activeFilter === 'principal') return paper.section === 'principal' || paper.principal === true;
        return paper.section === section;
      });
      if (!items.length) return '';
      return `<section class="catalog-section" aria-labelledby="shelf-${section}">
        <div class="catalog-heading"><h2 id="shelf-${section}">${labels[section]}</h2><span>${String(items.length).padStart(2, '0')} entries</span></div>
        <div class="paper-grid">${items.map(cardMarkup).join('')}</div>
      </section>`;
    }).join('');

    status.textContent = `Showing ${filtered.length} ${filtered.length === 1 ? 'entry' : 'entries'}`;
    empty.hidden = filtered.length !== 0;
    controls.forEach((button) => button.setAttribute('aria-pressed', String(button.dataset.filter === activeFilter)));
    bindDetailButtons();
  };

  const renderMaps = () => {
    const groups = new Map();
    maps.forEach(([group, number, subject, type, version]) => {
      if (!groups.has(group)) groups.set(group, []);
      groups.get(group).push({ number, subject, type, version });
    });
    records.innerHTML = Array.from(groups.entries()).map(([group, items]) => `<section class="record-group" aria-label="${escapeHtml(group)}">
      <h3>${escapeHtml(group)}</h3>
      ${items.map((item) => `<article class="record-card">
        <span class="record-card__num">MAP ${escapeHtml(item.number)}</span>
        <h4>${escapeHtml(item.subject)}</h4>
        ${item.type ? `<p>${escapeHtml(item.type)}</p>` : ''}
        ${item.version ? `<p class="record-card__meta">${escapeHtml(item.version)}</p>` : ''}
      </article>`).join('')}
    </section>`).join('');
  };

  controls.forEach((button) => button.addEventListener('click', () => {
    activeFilter = button.dataset.filter;
    renderPapers();
  }));
  search.addEventListener('input', renderPapers);

  if (detailClose) detailClose.addEventListener('click', () => dialog.close());
  if (dialog) {
    dialog.addEventListener('click', (event) => {
      if (event.target === dialog) dialog.close();
    });
    dialog.addEventListener('close', () => detailOpener?.focus({ preventScroll: true }));
  }

  renderPapers();
  renderMaps();
})();
