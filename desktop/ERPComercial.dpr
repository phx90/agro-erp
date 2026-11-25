program ERPComercial;

uses
  Vcl.Forms,
  Conexao.Config in 'src\Conexao.Config.pas',
  Conexao.DataModule in 'src\Conexao.DataModule.pas' {dmConexao: TDataModule},
  Comum.Erros in 'src\Comum.Erros.pas',
  Comum.Validacao in 'src\Comum.Validacao.pas',
  Cliente.Model in 'src\Cliente.Model.pas',
  Cliente.Repository in 'src\Cliente.Repository.pas',
  Produto.Model in 'src\Produto.Model.pas',
  Produto.Repository in 'src\Produto.Repository.pas',
  Pedido.Service in 'src\Pedido.Service.pas',
  Financeiro.Service in 'src\Financeiro.Service.pas',
  Form.Principal in 'src\Form.Principal.pas' {frmPrincipal},
  Form.Clientes in 'src\Form.Clientes.pas' {frmClientes},
  Form.Produtos in 'src\Form.Produtos.pas' {frmProdutos},
  Form.Pedidos in 'src\Form.Pedidos.pas' {frmPedidos},
  Form.Financeiro in 'src\Form.Financeiro.pas' {frmFinanceiro};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'ERP Comercial';
  Application.CreateForm(TdmConexao, dmConexao);
  Application.CreateForm(TfrmPrincipal, frmPrincipal);
  Application.Run;
end.
