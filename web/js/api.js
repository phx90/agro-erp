const Api = (() => {
  async function buscar(recurso) {
    const controle = new AbortController();
    const timer = setTimeout(() => controle.abort(), CONFIG.timeoutMs);

    try {
      const resposta = await fetch(`${CONFIG.apiUrl}/${recurso}`, { signal: controle.signal });
      if (!resposta.ok) {
        throw new Error(`A API respondeu ${resposta.status} em /${recurso}`);
      }

      const json = await resposta.json();
      return json.items;
    } finally {
      clearTimeout(timer);
    }
  }

  async function carregarTudo() {
    const [pedidos, estoqueCritico, titulos, resumo] = await Promise.all([
      buscar('pedidos'),
      buscar('estoque-critico'),
      buscar('titulos-abertos'),
      buscar('resumo')
    ]);

    return { pedidos, estoqueCritico, titulos, resumo };
  }

  return { carregarTudo };
})();
