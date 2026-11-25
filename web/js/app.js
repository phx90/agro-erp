const moeda = new Intl.NumberFormat('pt-BR', { style: 'currency', currency: 'BRL' });
const data = new Intl.DateTimeFormat('pt-BR', { timeZone: 'UTC' });

let pedidos = [];

function $(id) {
  return document.getElementById(id);
}

function escapar(texto) {
  const div = document.createElement('div');
  div.textContent = texto ?? '';
  return div.innerHTML;
}

function formatarData(iso) {
  return data.format(new Date(iso));
}

function somar(lista, campo) {
  return lista.reduce((total, item) => total + Number(item[campo] || 0), 0);
}

function nomeMes(anoMes) {
  const [ano, mes] = anoMes.split('-');
  const nome = new Date(Date.UTC(ano, mes - 1, 1))
    .toLocaleDateString('pt-BR', { month: 'short', timeZone: 'UTC' })
    .replace('.', '');
  return `${nome}/${ano}`;
}

function renderizarIndicadores(dados) {
  const vencidos = dados.titulos.filter(t => t.dias_atraso > 0);
  $('kpi-receber').textContent = moeda.format(somar(dados.titulos, 'saldo'));
  $('kpi-vencido').textContent = moeda.format(somar(vencidos, 'saldo'));

  // a view já vem ordenada por mês, o último é o mais recente
  const ultimoMes = dados.resumo[dados.resumo.length - 1];
  if (!ultimoMes) {
    $('kpi-vendido').textContent = moeda.format(0);
    $('kpi-ticket').textContent = moeda.format(0);
    return;
  }

  $('kpi-vendido').textContent = moeda.format(ultimoMes.total_vendido);
  $('kpi-vendido').title = `Referente a ${nomeMes(ultimoMes.mes)}`;
  $('kpi-ticket').textContent = moeda.format(ultimoMes.ticket_medio);
}

function pedidoPassaNoFiltro(pedido, busca, status) {
  if (status && pedido.status !== status) {
    return false;
  }

  if (!busca) {
    return true;
  }

  const alvo = `${pedido.cliente} ${pedido.cidade}`.toLowerCase();
  return alvo.includes(busca);
}

function renderizarPedidos() {
  const busca = $('filtro-busca').value.trim().toLowerCase();
  const status = $('filtro-status').value;
  const filtrados = pedidos.filter(p => pedidoPassaNoFiltro(p, busca, status));

  if (filtrados.length === 0) {
    $('tabela-pedidos').innerHTML = '<tr><td colspan="7" class="vazio">Nenhum pedido encontrado.</td></tr>';
    return;
  }

  $('tabela-pedidos').innerHTML = filtrados.map(p => `
    <tr>
      <td>${p.id}</td>
      <td>${formatarData(p.data_pedido)}</td>
      <td>${escapar(p.cliente)}</td>
      <td>${escapar(p.cidade)}/${escapar(p.uf)}</td>
      <td>${p.qtd_itens}</td>
      <td class="num">${moeda.format(p.valor_total)}</td>
      <td><span class="status status-${escapar(p.status)}">${escapar(p.status)}</span></td>
    </tr>`).join('');
}

function renderizarEstoque(itens) {
  if (itens.length === 0) {
    $('lista-estoque').innerHTML = '<li class="vazio">Tudo acima do mínimo.</li>';
    return;
  }

  $('lista-estoque').innerHTML = itens.map(i => `
    <li>
      <span>
        ${escapar(i.descricao)}
        <span class="detalhe">${escapar(i.codigo)} · mínimo ${i.estoque_minimo} ${escapar(i.unidade)}</span>
      </span>
      <span class="atrasado">${i.estoque_atual} ${escapar(i.unidade)}</span>
    </li>`).join('');
}

function descreverVencimento(titulo) {
  if (titulo.dias_atraso > 0) {
    return `<span class="atrasado">${titulo.dias_atraso} dias em atraso</span>`;
  }

  return `vence ${formatarData(titulo.vencimento)}`;
}

function renderizarTitulos(titulos) {
  if (titulos.length === 0) {
    $('lista-titulos').innerHTML = '<li class="vazio">Nenhum título em aberto.</li>';
    return;
  }

  $('lista-titulos').innerHTML = titulos.slice(0, 8).map(t => `
    <li>
      <span>
        ${escapar(t.cliente)}
        <span class="detalhe">Pedido ${t.pedido_id}, parcela ${t.parcela} · ${descreverVencimento(t)}</span>
      </span>
      <strong>${moeda.format(t.saldo)}</strong>
    </li>`).join('');
}

async function obterDados() {
  try {
    const dados = await Api.carregarTudo();
    $('aviso-demo').classList.add('oculto');
    return dados;
  } catch (erro) {
    console.warn('Usando dados de exemplo:', erro.message);
    $('aviso-demo').classList.remove('oculto');
    return DADOS_DEMO;
  }
}

async function carregar() {
  const dados = await obterDados();

  pedidos = dados.pedidos;
  renderizarIndicadores(dados);
  renderizarPedidos();
  renderizarEstoque(dados.estoqueCritico);
  renderizarTitulos(dados.titulos);
}

$('filtro-busca').addEventListener('input', renderizarPedidos);
$('filtro-status').addEventListener('change', renderizarPedidos);
$('btn-atualizar').addEventListener('click', carregar);

carregar();
