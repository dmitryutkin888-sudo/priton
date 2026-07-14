async function loadJson(url, fallback) {
  try {
    const res = await fetch(url);
    if (!res.ok) return fallback;
    return await res.json();
  } catch (e) {
    return fallback;
  }
}

async function render() {
  const health = await loadJson('/api/v1/client/health', { status: 'offline' });
  const users = await loadJson('/api/v1/users', { data: [], total: 0 });
  const nodes = await loadJson('/api/v1/nodes', { nodes: [] });
  const protocols = await loadJson('/api/v1/protocols', { protocols: [] });
  const logs = await loadJson('/api/v1/logs', { logs: [] });

  document.getElementById('healthBadge').textContent = health.status || 'offline';
  document.getElementById('healthOutput').textContent = JSON.stringify(health, null, 2);
  document.getElementById('usersOutput').textContent = JSON.stringify(users, null, 2);
  document.getElementById('nodesOutput').textContent = JSON.stringify(nodes, null, 2);
  document.getElementById('protocolsOutput').textContent = JSON.stringify(protocols, null, 2);
  document.getElementById('logsOutput').textContent = JSON.stringify(logs, null, 2);
}

render();
