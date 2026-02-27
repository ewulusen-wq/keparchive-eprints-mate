(function(){
  'use strict';

  function collectMetaFromElement(el){
    // Try data- attributes first
    const ds = el.dataset || {};
    const meta = {};
    if(ds.photographer) meta.photographer = ds.photographer;
    if(ds.location) meta.location = ds.location;
    if(ds.event_name) meta.event_name = ds.event_name;
    if(ds.institute) meta.institute = ds.institute;
    if(ds.year) meta.year = ds.year;
    if(ds.published) meta.published = ds.published;

    // Fallback: try to find elements by heuristic class names
    if(!meta.photographer){
      const node = el.querySelector('.photographer, .ep_field_photographer');
      if(node) meta.photographer = node.textContent.trim();
    }
    if(!meta.location){
      const node = el.querySelector('.location, .ep_field_location');
      if(node) meta.location = node.textContent.trim();
    }
    if(!meta.event_name){
      const node = el.querySelector('.event, .ep_field_event_name');
      if(node) meta.event_name = node.textContent.trim();
    }
    if(!meta.institute){
      const node = el.querySelector('.institute, .ep_field_institute, .ep_field_divisions');
      if(node) meta.institute = node.textContent.trim();
    }
    if(!meta.year){
      const node = el.querySelector('.year, .ep_field_date, .ep_field_eprint_year');
      if(node) meta.year = (node.textContent||'').trim().match(/\d{4}/); if(Array.isArray(meta.year)) meta.year = meta.year[0];
    }
    if(!meta.published){
      const node = el.querySelector('.status, .ep_field_status');
      if(node) meta.published = /publ/i.test(node.textContent) ? 'Published' : 'Unpublished';
    }
    return meta;
  }

  function buildFacets(results){
    const counts = {
      photographer: new Map(),
      location: new Map(),
      event_name: new Map(),
      institute: new Map(),
      year: new Map(),
      published: new Map()
    };

    results.forEach(r => {
      const meta = collectMetaFromElement(r);
      if(meta.photographer) counts.photographer.set(meta.photographer, (counts.photographer.get(meta.photographer)||0)+1);
      if(meta.location) counts.location.set(meta.location, (counts.location.get(meta.location)||0)+1);
      if(meta.event_name) counts.event_name.set(meta.event_name, (counts.event_name.get(meta.event_name)||0)+1);
      if(meta.institute) counts.institute.set(meta.institute, (counts.institute.get(meta.institute)||0)+1);
      if(meta.year) counts.year.set(meta.year, (counts.year.get(meta.year)||0)+1);
      if(meta.published) counts.published.set(meta.published, (counts.published.get(meta.published)||0)+1);
      // store parsed meta on element for filtering
      r.__facets = meta;
    });
    return counts;
  }

  function renderFacetList(title, map, key){
    if(map.size===0) return '';
    // sort by count desc
    const items = Array.from(map.entries()).sort((a,b)=>b[1]-a[1]);
    let html = `<div class="mb-3"><h6 class="fw-semibold">${title}</h6><ul class="list-unstyled">`;
    items.forEach(([val,count])=>{
      const safeVal = val.replace(/"/g,'&quot;');
      html += `<li><a href="#" class="facet-item" data-facet="${key}" data-value="${encodeURIComponent(val)}">${val} <span class="text-muted">(${count})</span></a></li>`;
    });
    html += '</ul></div>';
    return html;
  }

  function applyFilters(results, active){
    const activeKeys = Object.keys(active);
    results.forEach(r=>{
      let show = true;
      const meta = r.__facets || {};
      for(const k of activeKeys){
        const sel = active[k];
        if(!sel) continue;
        const val = meta[k] || '';
        if(!val) { show=false; break; }
        if(val.toString()!==sel.toString()) { show=false; break; }
      }
      r.style.display = show ? '' : 'none';
    });
  }

  function createSidebar(counts, resultsContainer){
    const wrapper = document.createElement('aside');
    wrapper.id = 'facetsSidebar';
    wrapper.className = 'col-md-3 mb-4';
    const inner = document.createElement('div');
    inner.className = 'p-3 bg-light rounded';
    inner.innerHTML = '<h5>Szűrők</h5><div id="facetsContent">';
    inner.innerHTML += renderFacetList('Fotós', counts.photographer, 'photographer');
    inner.innerHTML += renderFacetList('Helyszín', counts.location, 'location');
    inner.innerHTML += renderFacetList('Esemény neve', counts.event_name, 'event_name');
    inner.innerHTML += renderFacetList('Intézet', counts.institute, 'institute');
    inner.innerHTML += renderFacetList('Év', counts.year, 'year');
    inner.innerHTML += renderFacetList('Publikált', counts.published, 'published');
    inner.innerHTML += '</div><div><button id="clearFacets" class="btn btn-sm btn-secondary">Töröl</button></div>';
    wrapper.appendChild(inner);

    // bind clicks
    wrapper.addEventListener('click', function(e){
      const a = e.target.closest('.facet-item');
      if(a){
        e.preventDefault();
        const facet = a.dataset.facet;
        const val = decodeURIComponent(a.dataset.value);
        activeFilters[facet] = val;
        applyFilters(window.__maeFacetResults, activeFilters);
      }
      const clear = e.target.closest('#clearFacets');
      if(clear){
        e.preventDefault();
        for(const k in activeFilters) delete activeFilters[k];
        applyFilters(window.__maeFacetResults, activeFilters);
      }
    });

    return wrapper;
  }

  let activeFilters = {};

  function initFacets(){
    const results = Array.from(document.querySelectorAll('.ep_search_result'));
    if(results.length===0) return;
    window.__maeFacetResults = results.map(r=>{
      // make sure we have block container (the > div we styled)
      return r;
    });
    const counts = buildFacets(window.__maeFacetResults);

    // restructure page: find results container and wrap into columns
    const pageContent = document.querySelector('.ep_tm_page_content') || document.querySelector('#main_content');
    if(!pageContent) return;

    // create row
    const row = document.createElement('div');
    row.className = 'row';
    const sidebarCol = document.createElement('div');
    sidebarCol.className = 'col-md-3 mb-4';
    const resultsCol = document.createElement('div');
    resultsCol.className = 'col-md-9';

    // move existing direct children that are results into resultsCol
    const searchResults = document.querySelector('.ep_search_results');
    if(!searchResults) return;
    resultsCol.appendChild(searchResults);

    const sidebar = createSidebar(counts, resultsCol);
    row.appendChild(sidebar);
    row.appendChild(resultsCol);

    // replace current content (append row after page title)
    const title = pageContent.querySelector('.ep_tm_pagetitle') || pageContent.querySelector('h1');
    if(title && title.parentNode){
      // insert row after title
      title.parentNode.insertBefore(row, title.nextSibling);
    } else {
      pageContent.insertBefore(row, pageContent.firstChild);
    }

    // ensure facet clicks work
    applyFilters(window.__maeFacetResults, activeFilters);
  }

  document.addEventListener('DOMContentLoaded', function(){
    try{ initFacets(); }catch(e){ console.error('facets init', e); }
  });
})();
