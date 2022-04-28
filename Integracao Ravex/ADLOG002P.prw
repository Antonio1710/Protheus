#INCLUDE "protheus.ch"
#INCLUDE "apwebsrv.ch"

/* ===============================================================================
WSDL Location    http://app.ravex.com.br/sivirafull/Service.asmx?WSDL
Gerado em        05/12/20 13:03:32
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _HBOPSYP ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSsivirafullWebService

@history Chamado 67991  - Everson       - 27/04/2022 - Foi necessário gerar uma nova classe para contemplar as atualizações do webservice.
------------------------------------------------------------------------------- */

WSCLIENT WSsivirafullWebService

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD CompletarViagem
	WSMETHOD RetornarColetasRealizadas
	WSMETHOD Autenticar
	WSMETHOD ImportarViagem
	WSMETHOD ImportarVendedor
	WSMETHOD ImportarGerente
	WSMETHOD ImportarSupervisor
	WSMETHOD ImportarPromotor
	WSMETHOD ImportarMotorista
	WSMETHOD ImportarVeiculo
	WSMETHOD GravarLog
	WSMETHOD ImportarCliente
	WSMETHOD ImportarTransportadora
	WSMETHOD ImportarProduto
	WSMETHOD RetornarViagemDevolucao
	WSMETHOD CancelarViagem
	WSMETHOD ConsultaIndicadores
	WSMETHOD ImportarRoteiroViagem
	WSMETHOD RetornarAnomalias
	WSMETHOD RetornarNFsEntregues
	WSMETHOD RetornarEntregasRealizadas
	WSMETHOD ListarCustosAdicionaisAprovadosPorViagem
	WSMETHOD ListarAlteracaoValorModalidadeCustoAdicionalPorViagem
	WSMETHOD RetornarQuantidadePernoitesAprovadasPorViagem
	WSMETHOD RetornarAnomaliasRegistradas
	WSMETHOD ListarViagensFinalizadas
	WSMETHOD RetornarStatusVeiculo
	WSMETHOD ConsultarPlacaDisponivel
	WSMETHOD ImportarPedidos
	WSMETHOD RetornarRoteiros
	WSMETHOD ListarModalidadesDeCustoAdicional
	WSMETHOD ListarTiposDeCustoAdicional
	WSMETHOD ImportarViagemFaturada
	WSMETHOD ImportarViagemPlanejada
	WSMETHOD CancelarViagemPlanejada
	WSMETHOD IndisponibilizarVeiculo
	WSMETHOD IndisponibilizarMotorista
	WSMETHOD DisponibilizarVeiculo
	WSMETHOD DisponibilizarMotorista
	WSMETHOD IntegrarClienteCompleto
	WSMETHOD IntegrarJanelaAtendimento
	WSMETHOD IntegrarTabelaFrete

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   cLogin                    AS string
	WSDATA   cSenha                    AS string
	WSDATA   oWSViagem                 AS sivirafullWebService_Viagem
	WSDATA   oWSCompletarViagemResult  AS sivirafullWebService_Retorno
	WSDATA   nIdViagem                 AS int
	WSDATA   cIdentificador            AS string
	WSDATA   oWSRetornarColetasRealizadasResult AS sivirafullWebService_RetornoViagem
	WSDATA   oWSAutenticarResult       AS sivirafullWebService_Retorno
	WSDATA   oWSImportarViagemResult   AS sivirafullWebService_Retorno
	WSDATA   oWSVendedor               AS sivirafullWebService_Pessoa
	WSDATA   oWSImportarVendedorResult AS sivirafullWebService_Retorno
	WSDATA   oWSGerente                AS sivirafullWebService_Pessoa
	WSDATA   oWSImportarGerenteResult  AS sivirafullWebService_Retorno
	WSDATA   oWSSupervisor             AS sivirafullWebService_Pessoa
	WSDATA   oWSImportarSupervisorResult AS sivirafullWebService_Retorno
	WSDATA   oWSPromotor               AS sivirafullWebService_Pessoa
	WSDATA   oWSImportarPromotorResult AS sivirafullWebService_Retorno
	WSDATA   oWSMotorista              AS sivirafullWebService_Motorista
	WSDATA   oWSImportarMotoristaResult AS sivirafullWebService_Retorno
	WSDATA   oWSVeiculo                AS sivirafullWebService_Veiculo
	WSDATA   oWSImportarVeiculoResult  AS sivirafullWebService_Retorno
	WSDATA   cTexto                    AS string
	WSDATA   cArquivo                  AS string
	WSDATA   oWSCliente                AS sivirafullWebService_Cliente
	WSDATA   oWSImportarClienteResult  AS sivirafullWebService_Retorno
	WSDATA   oWSTransportadora         AS sivirafullWebService_Transportadora
	WSDATA   oWSImportarTransportadoraResult AS sivirafullWebService_Retorno
	WSDATA   oWSProduto                AS sivirafullWebService_Produto
	WSDATA   oWSImportarProdutoResult  AS sivirafullWebService_Retorno
	WSDATA   ccnpjEmissor              AS string
	WSDATA   lviagemFechadas           AS boolean
	WSDATA   lviagensCanceladas        AS boolean
	WSDATA   nperiodoHoras             AS int
	WSDATA   oWSRetornarViagemDevolucaoResult AS sivirafullWebService_ArrayOfRetornoDevolucao
	WSDATA   cCnpj                     AS string
	WSDATA   cAnomalia                 AS string
	WSDATA   oWSCancelarViagemResult   AS sivirafullWebService_Retorno
	WSDATA   nIdUnidade                AS int
	WSDATA   cTipoRetorno              AS string
	WSDATA   ccnpjTransportadora       AS string
	WSDATA   cInicioPeriodo            AS dateTime
	WSDATA   cFimPeriodo               AS dateTime
	WSDATA   oWSConsultaIndicadoresResult AS sivirafullWebService_ArrayOfIndicadores
	WSDATA   oWSRoteiro                AS sivirafullWebService_RoteiroViagem
	WSDATA   oWSImportarRoteiroViagemResult AS sivirafullWebService_Retorno
	WSDATA   oWSRetornarAnomaliasResult AS sivirafullWebService_ArrayOfAnomalia
	WSDATA   oWSRetornarNFsEntreguesResult AS sivirafullWebService_ArrayOfNotaEntregue
	WSDATA   oWSRetornarEntregasRealizadasResult AS sivirafullWebService_ViagemRetorno
	WSDATA   oWSListarCustosAdicionaisAprovadosPorViagemResult AS sivirafullWebService_ArrayOfRetornoCustoAdicional
	WSDATA   oWSListarAlteracaoValorModalidadeCustoAdicionalPorViagemResult AS sivirafullWebService_ArrayOfRetornoAlteracaoValorModalidade
	WSDATA   oWSRetornarQuantidadePernoitesAprovadasPorViagemResult AS sivirafullWebService_RetornoPernoiteAprovada
	WSDATA   oWSRetornarAnomaliasRegistradasResult AS sivirafullWebService_ViagemRetorno
	WSDATA   nPeriodoMinutos           AS int
	WSDATA   oWSListarViagensFinalizadasResult AS sivirafullWebService_ArrayOfViagemFinalizada
	WSDATA   cPlaca                    AS string
	WSDATA   oWSRetornarStatusVeiculoResult AS sivirafullWebService_StatusVeiculo
	WSDATA   oWSConsultarPlacaDisponivelResult AS sivirafullWebService_StatusVeiculo
	WSDATA   oWSPedidos                AS sivirafullWebService_ArrayOfPedido
	WSDATA   oWSImportarPedidosResult  AS sivirafullWebService_Retorno
	WSDATA   oWSFiltro                 AS sivirafullWebService_FiltroRoteiro
	WSDATA   oWSRetornarRoteirosResult AS sivirafullWebService_ArrayOfRoteiro
	WSDATA   oWSListarModalidadesDeCustoAdicionalResult AS sivirafullWebService_ArrayOfModalidadeCustoAdicional
	WSDATA   oWSListarTiposDeCustoAdicionalResult AS sivirafullWebService_ArrayOfTipoCustoAdicional
	WSDATA   oWSImportarViagemFaturadaResult AS sivirafullWebService_Retorno
	WSDATA   oWSViagemPlanejada        AS sivirafullWebService_ViagemPlanejada
	WSDATA   oWSImportarViagemPlanejadaResult AS sivirafullWebService_Retorno
	WSDATA   oWSCancelarViagemPlanejadaResult AS sivirafullWebService_Retorno
	WSDATA   oWSIndisponibilizarVeiculoResult AS sivirafullWebService_Retorno
	WSDATA   cCpf                      AS string
	WSDATA   oWSIndisponibilizarMotoristaResult AS sivirafullWebService_Retorno
	WSDATA   oWSDisponibilizarVeiculoResult AS sivirafullWebService_Retorno
	WSDATA   oWSDisponibilizarMotoristaResult AS sivirafullWebService_Retorno
	WSDATA   oWSIntegrarClienteCompletoResult AS sivirafullWebService_Retorno
	WSDATA   oWSJanela                 AS sivirafullWebService_JanelaAtendimento
	WSDATA   oWSIntegrarJanelaAtendimentoResult AS sivirafullWebService_Retorno
	WSDATA   oWSTabelaFrete            AS sivirafullWebService_Frete
	WSDATA   oWSIntegrarTabelaFreteResult AS sivirafullWebService_Retorno

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSsivirafullWebService
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Cï¿½digo-Fonte Client atual requer os executï¿½veis do Protheus Build [7.00.191205P-20211019] ou superior. Atualize o Protheus ou gere o Cï¿½digo-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSsivirafullWebService
	::oWSViagem          := sivirafullWebService_VIAGEM():New()
	::oWSCompletarViagemResult := sivirafullWebService_RETORNO():New()
	::oWSRetornarColetasRealizadasResult := sivirafullWebService_RETORNOVIAGEM():New()
	::oWSAutenticarResult := sivirafullWebService_RETORNO():New()
	::oWSImportarViagemResult := sivirafullWebService_RETORNO():New()
	::oWSVendedor        := sivirafullWebService_PESSOA():New()
	::oWSImportarVendedorResult := sivirafullWebService_RETORNO():New()
	::oWSGerente         := sivirafullWebService_PESSOA():New()
	::oWSImportarGerenteResult := sivirafullWebService_RETORNO():New()
	::oWSSupervisor      := sivirafullWebService_PESSOA():New()
	::oWSImportarSupervisorResult := sivirafullWebService_RETORNO():New()
	::oWSPromotor        := sivirafullWebService_PESSOA():New()
	::oWSImportarPromotorResult := sivirafullWebService_RETORNO():New()
	::oWSMotorista       := sivirafullWebService_MOTORISTA():New()
	::oWSImportarMotoristaResult := sivirafullWebService_RETORNO():New()
	::oWSVeiculo         := sivirafullWebService_VEICULO():New()
	::oWSImportarVeiculoResult := sivirafullWebService_RETORNO():New()
	::oWSCliente         := sivirafullWebService_CLIENTE():New()
	::oWSImportarClienteResult := sivirafullWebService_RETORNO():New()
	::oWSTransportadora  := sivirafullWebService_TRANSPORTADORA():New()
	::oWSImportarTransportadoraResult := sivirafullWebService_RETORNO():New()
	::oWSProduto         := sivirafullWebService_PRODUTO():New()
	::oWSImportarProdutoResult := sivirafullWebService_RETORNO():New()
	::oWSRetornarViagemDevolucaoResult := sivirafullWebService_ARRAYOFRETORNODEVOLUCAO():New()
	::oWSCancelarViagemResult := sivirafullWebService_RETORNO():New()
	::oWSConsultaIndicadoresResult := sivirafullWebService_ARRAYOFINDICADORES():New()
	::oWSRoteiro         := sivirafullWebService_ROTEIROVIAGEM():New()
	::oWSImportarRoteiroViagemResult := sivirafullWebService_RETORNO():New()
	::oWSRetornarAnomaliasResult := sivirafullWebService_ARRAYOFANOMALIA():New()
	::oWSRetornarNFsEntreguesResult := sivirafullWebService_ARRAYOFNOTAENTREGUE():New()
	::oWSRetornarEntregasRealizadasResult := sivirafullWebService_VIAGEMRETORNO():New()
	::oWSListarCustosAdicionaisAprovadosPorViagemResult := sivirafullWebService_ARRAYOFRETORNOCUSTOADICIONAL():New()
	::oWSListarAlteracaoValorModalidadeCustoAdicionalPorViagemResult := sivirafullWebService_ARRAYOFRETORNOALTERACAOVALORMODALIDADE():New()
	::oWSRetornarQuantidadePernoitesAprovadasPorViagemResult := sivirafullWebService_RETORNOPERNOITEAPROVADA():New()
	::oWSRetornarAnomaliasRegistradasResult := sivirafullWebService_VIAGEMRETORNO():New()
	::oWSListarViagensFinalizadasResult := sivirafullWebService_ARRAYOFVIAGEMFINALIZADA():New()
	::oWSRetornarStatusVeiculoResult := sivirafullWebService_STATUSVEICULO():New()
	::oWSConsultarPlacaDisponivelResult := sivirafullWebService_STATUSVEICULO():New()
	::oWSPedidos         := sivirafullWebService_ARRAYOFPEDIDO():New()
	::oWSImportarPedidosResult := sivirafullWebService_RETORNO():New()
	::oWSFiltro          := sivirafullWebService_FILTROROTEIRO():New()
	::oWSRetornarRoteirosResult := sivirafullWebService_ARRAYOFROTEIRO():New()
	::oWSListarModalidadesDeCustoAdicionalResult := sivirafullWebService_ARRAYOFMODALIDADECUSTOADICIONAL():New()
	::oWSListarTiposDeCustoAdicionalResult := sivirafullWebService_ARRAYOFTIPOCUSTOADICIONAL():New()
	::oWSImportarViagemFaturadaResult := sivirafullWebService_RETORNO():New()
	::oWSViagemPlanejada := sivirafullWebService_VIAGEMPLANEJADA():New()
	::oWSImportarViagemPlanejadaResult := sivirafullWebService_RETORNO():New()
	::oWSCancelarViagemPlanejadaResult := sivirafullWebService_RETORNO():New()
	::oWSIndisponibilizarVeiculoResult := sivirafullWebService_RETORNO():New()
	::oWSIndisponibilizarMotoristaResult := sivirafullWebService_RETORNO():New()
	::oWSDisponibilizarVeiculoResult := sivirafullWebService_RETORNO():New()
	::oWSDisponibilizarMotoristaResult := sivirafullWebService_RETORNO():New()
	::oWSIntegrarClienteCompletoResult := sivirafullWebService_RETORNO():New()
	::oWSJanela          := sivirafullWebService_JANELAATENDIMENTO():New()
	::oWSIntegrarJanelaAtendimentoResult := sivirafullWebService_RETORNO():New()
	::oWSTabelaFrete     := sivirafullWebService_FRETE():New()
	::oWSIntegrarTabelaFreteResult := sivirafullWebService_RETORNO():New()
Return

WSMETHOD RESET WSCLIENT WSsivirafullWebService
	::cLogin             := NIL 
	::cSenha             := NIL 
	::oWSViagem          := NIL 
	::oWSCompletarViagemResult := NIL 
	::nIdViagem          := NIL 
	::cIdentificador     := NIL 
	::oWSRetornarColetasRealizadasResult := NIL 
	::oWSAutenticarResult := NIL 
	::oWSImportarViagemResult := NIL 
	::oWSVendedor        := NIL 
	::oWSImportarVendedorResult := NIL 
	::oWSGerente         := NIL 
	::oWSImportarGerenteResult := NIL 
	::oWSSupervisor      := NIL 
	::oWSImportarSupervisorResult := NIL 
	::oWSPromotor        := NIL 
	::oWSImportarPromotorResult := NIL 
	::oWSMotorista       := NIL 
	::oWSImportarMotoristaResult := NIL 
	::oWSVeiculo         := NIL 
	::oWSImportarVeiculoResult := NIL 
	::cTexto             := NIL 
	::cArquivo           := NIL 
	::oWSCliente         := NIL 
	::oWSImportarClienteResult := NIL 
	::oWSTransportadora  := NIL 
	::oWSImportarTransportadoraResult := NIL 
	::oWSProduto         := NIL 
	::oWSImportarProdutoResult := NIL 
	::ccnpjEmissor       := NIL 
	::lviagemFechadas    := NIL 
	::lviagensCanceladas := NIL 
	::nperiodoHoras      := NIL 
	::oWSRetornarViagemDevolucaoResult := NIL 
	::cCnpj              := NIL 
	::cAnomalia          := NIL 
	::oWSCancelarViagemResult := NIL 
	::nIdUnidade         := NIL 
	::cTipoRetorno       := NIL 
	::ccnpjTransportadora := NIL 
	::cInicioPeriodo     := NIL 
	::cFimPeriodo        := NIL 
	::oWSConsultaIndicadoresResult := NIL 
	::oWSRoteiro         := NIL 
	::oWSImportarRoteiroViagemResult := NIL 
	::oWSRetornarAnomaliasResult := NIL 
	::oWSRetornarNFsEntreguesResult := NIL 
	::oWSRetornarEntregasRealizadasResult := NIL 
	::oWSListarCustosAdicionaisAprovadosPorViagemResult := NIL 
	::oWSListarAlteracaoValorModalidadeCustoAdicionalPorViagemResult := NIL 
	::oWSRetornarQuantidadePernoitesAprovadasPorViagemResult := NIL 
	::oWSRetornarAnomaliasRegistradasResult := NIL 
	::nPeriodoMinutos    := NIL 
	::oWSListarViagensFinalizadasResult := NIL 
	::cPlaca             := NIL 
	::oWSRetornarStatusVeiculoResult := NIL 
	::oWSConsultarPlacaDisponivelResult := NIL 
	::oWSPedidos         := NIL 
	::oWSImportarPedidosResult := NIL 
	::oWSFiltro          := NIL 
	::oWSRetornarRoteirosResult := NIL 
	::oWSListarModalidadesDeCustoAdicionalResult := NIL 
	::oWSListarTiposDeCustoAdicionalResult := NIL 
	::oWSImportarViagemFaturadaResult := NIL 
	::oWSViagemPlanejada := NIL 
	::oWSImportarViagemPlanejadaResult := NIL 
	::oWSCancelarViagemPlanejadaResult := NIL 
	::oWSIndisponibilizarVeiculoResult := NIL 
	::cCpf               := NIL 
	::oWSIndisponibilizarMotoristaResult := NIL 
	::oWSDisponibilizarVeiculoResult := NIL 
	::oWSDisponibilizarMotoristaResult := NIL 
	::oWSIntegrarClienteCompletoResult := NIL 
	::oWSJanela          := NIL 
	::oWSIntegrarJanelaAtendimentoResult := NIL 
	::oWSTabelaFrete     := NIL 
	::oWSIntegrarTabelaFreteResult := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSsivirafullWebService
Local oClone := WSsivirafullWebService():New()
	oClone:_URL          := ::_URL 
	oClone:cLogin        := ::cLogin
	oClone:cSenha        := ::cSenha
	oClone:oWSViagem     :=  IIF(::oWSViagem = NIL , NIL ,::oWSViagem:Clone() )
	oClone:oWSCompletarViagemResult :=  IIF(::oWSCompletarViagemResult = NIL , NIL ,::oWSCompletarViagemResult:Clone() )
	oClone:nIdViagem     := ::nIdViagem
	oClone:cIdentificador := ::cIdentificador
	oClone:oWSRetornarColetasRealizadasResult :=  IIF(::oWSRetornarColetasRealizadasResult = NIL , NIL ,::oWSRetornarColetasRealizadasResult:Clone() )
	oClone:oWSAutenticarResult :=  IIF(::oWSAutenticarResult = NIL , NIL ,::oWSAutenticarResult:Clone() )
	oClone:oWSImportarViagemResult :=  IIF(::oWSImportarViagemResult = NIL , NIL ,::oWSImportarViagemResult:Clone() )
	oClone:oWSVendedor   :=  IIF(::oWSVendedor = NIL , NIL ,::oWSVendedor:Clone() )
	oClone:oWSImportarVendedorResult :=  IIF(::oWSImportarVendedorResult = NIL , NIL ,::oWSImportarVendedorResult:Clone() )
	oClone:oWSGerente    :=  IIF(::oWSGerente = NIL , NIL ,::oWSGerente:Clone() )
	oClone:oWSImportarGerenteResult :=  IIF(::oWSImportarGerenteResult = NIL , NIL ,::oWSImportarGerenteResult:Clone() )
	oClone:oWSSupervisor :=  IIF(::oWSSupervisor = NIL , NIL ,::oWSSupervisor:Clone() )
	oClone:oWSImportarSupervisorResult :=  IIF(::oWSImportarSupervisorResult = NIL , NIL ,::oWSImportarSupervisorResult:Clone() )
	oClone:oWSPromotor   :=  IIF(::oWSPromotor = NIL , NIL ,::oWSPromotor:Clone() )
	oClone:oWSImportarPromotorResult :=  IIF(::oWSImportarPromotorResult = NIL , NIL ,::oWSImportarPromotorResult:Clone() )
	oClone:oWSMotorista  :=  IIF(::oWSMotorista = NIL , NIL ,::oWSMotorista:Clone() )
	oClone:oWSImportarMotoristaResult :=  IIF(::oWSImportarMotoristaResult = NIL , NIL ,::oWSImportarMotoristaResult:Clone() )
	oClone:oWSVeiculo    :=  IIF(::oWSVeiculo = NIL , NIL ,::oWSVeiculo:Clone() )
	oClone:oWSImportarVeiculoResult :=  IIF(::oWSImportarVeiculoResult = NIL , NIL ,::oWSImportarVeiculoResult:Clone() )
	oClone:cTexto        := ::cTexto
	oClone:cArquivo      := ::cArquivo
	oClone:oWSCliente    :=  IIF(::oWSCliente = NIL , NIL ,::oWSCliente:Clone() )
	oClone:oWSImportarClienteResult :=  IIF(::oWSImportarClienteResult = NIL , NIL ,::oWSImportarClienteResult:Clone() )
	oClone:oWSTransportadora :=  IIF(::oWSTransportadora = NIL , NIL ,::oWSTransportadora:Clone() )
	oClone:oWSImportarTransportadoraResult :=  IIF(::oWSImportarTransportadoraResult = NIL , NIL ,::oWSImportarTransportadoraResult:Clone() )
	oClone:oWSProduto    :=  IIF(::oWSProduto = NIL , NIL ,::oWSProduto:Clone() )
	oClone:oWSImportarProdutoResult :=  IIF(::oWSImportarProdutoResult = NIL , NIL ,::oWSImportarProdutoResult:Clone() )
	oClone:ccnpjEmissor  := ::ccnpjEmissor
	oClone:lviagemFechadas := ::lviagemFechadas
	oClone:lviagensCanceladas := ::lviagensCanceladas
	oClone:nperiodoHoras := ::nperiodoHoras
	oClone:oWSRetornarViagemDevolucaoResult :=  IIF(::oWSRetornarViagemDevolucaoResult = NIL , NIL ,::oWSRetornarViagemDevolucaoResult:Clone() )
	oClone:cCnpj         := ::cCnpj
	oClone:cAnomalia     := ::cAnomalia
	oClone:oWSCancelarViagemResult :=  IIF(::oWSCancelarViagemResult = NIL , NIL ,::oWSCancelarViagemResult:Clone() )
	oClone:nIdUnidade    := ::nIdUnidade
	oClone:cTipoRetorno  := ::cTipoRetorno
	oClone:ccnpjTransportadora := ::ccnpjTransportadora
	oClone:cInicioPeriodo := ::cInicioPeriodo
	oClone:cFimPeriodo   := ::cFimPeriodo
	oClone:oWSConsultaIndicadoresResult :=  IIF(::oWSConsultaIndicadoresResult = NIL , NIL ,::oWSConsultaIndicadoresResult:Clone() )
	oClone:oWSRoteiro    :=  IIF(::oWSRoteiro = NIL , NIL ,::oWSRoteiro:Clone() )
	oClone:oWSImportarRoteiroViagemResult :=  IIF(::oWSImportarRoteiroViagemResult = NIL , NIL ,::oWSImportarRoteiroViagemResult:Clone() )
	oClone:oWSRetornarAnomaliasResult :=  IIF(::oWSRetornarAnomaliasResult = NIL , NIL ,::oWSRetornarAnomaliasResult:Clone() )
	oClone:oWSRetornarNFsEntreguesResult :=  IIF(::oWSRetornarNFsEntreguesResult = NIL , NIL ,::oWSRetornarNFsEntreguesResult:Clone() )
	oClone:oWSRetornarEntregasRealizadasResult :=  IIF(::oWSRetornarEntregasRealizadasResult = NIL , NIL ,::oWSRetornarEntregasRealizadasResult:Clone() )
	oClone:oWSListarCustosAdicionaisAprovadosPorViagemResult :=  IIF(::oWSListarCustosAdicionaisAprovadosPorViagemResult = NIL , NIL ,::oWSListarCustosAdicionaisAprovadosPorViagemResult:Clone() )
	oClone:oWSListarAlteracaoValorModalidadeCustoAdicionalPorViagemResult :=  IIF(::oWSListarAlteracaoValorModalidadeCustoAdicionalPorViagemResult = NIL , NIL ,::oWSListarAlteracaoValorModalidadeCustoAdicionalPorViagemResult:Clone() )
	oClone:oWSRetornarQuantidadePernoitesAprovadasPorViagemResult :=  IIF(::oWSRetornarQuantidadePernoitesAprovadasPorViagemResult = NIL , NIL ,::oWSRetornarQuantidadePernoitesAprovadasPorViagemResult:Clone() )
	oClone:oWSRetornarAnomaliasRegistradasResult :=  IIF(::oWSRetornarAnomaliasRegistradasResult = NIL , NIL ,::oWSRetornarAnomaliasRegistradasResult:Clone() )
	oClone:nPeriodoMinutos := ::nPeriodoMinutos
	oClone:oWSListarViagensFinalizadasResult :=  IIF(::oWSListarViagensFinalizadasResult = NIL , NIL ,::oWSListarViagensFinalizadasResult:Clone() )
	oClone:cPlaca        := ::cPlaca
	oClone:oWSRetornarStatusVeiculoResult :=  IIF(::oWSRetornarStatusVeiculoResult = NIL , NIL ,::oWSRetornarStatusVeiculoResult:Clone() )
	oClone:oWSConsultarPlacaDisponivelResult :=  IIF(::oWSConsultarPlacaDisponivelResult = NIL , NIL ,::oWSConsultarPlacaDisponivelResult:Clone() )
	oClone:oWSPedidos    :=  IIF(::oWSPedidos = NIL , NIL ,::oWSPedidos:Clone() )
	oClone:oWSImportarPedidosResult :=  IIF(::oWSImportarPedidosResult = NIL , NIL ,::oWSImportarPedidosResult:Clone() )
	oClone:oWSFiltro     :=  IIF(::oWSFiltro = NIL , NIL ,::oWSFiltro:Clone() )
	oClone:oWSRetornarRoteirosResult :=  IIF(::oWSRetornarRoteirosResult = NIL , NIL ,::oWSRetornarRoteirosResult:Clone() )
	oClone:oWSListarModalidadesDeCustoAdicionalResult :=  IIF(::oWSListarModalidadesDeCustoAdicionalResult = NIL , NIL ,::oWSListarModalidadesDeCustoAdicionalResult:Clone() )
	oClone:oWSListarTiposDeCustoAdicionalResult :=  IIF(::oWSListarTiposDeCustoAdicionalResult = NIL , NIL ,::oWSListarTiposDeCustoAdicionalResult:Clone() )
	oClone:oWSImportarViagemFaturadaResult :=  IIF(::oWSImportarViagemFaturadaResult = NIL , NIL ,::oWSImportarViagemFaturadaResult:Clone() )
	oClone:oWSViagemPlanejada :=  IIF(::oWSViagemPlanejada = NIL , NIL ,::oWSViagemPlanejada:Clone() )
	oClone:oWSImportarViagemPlanejadaResult :=  IIF(::oWSImportarViagemPlanejadaResult = NIL , NIL ,::oWSImportarViagemPlanejadaResult:Clone() )
	oClone:oWSCancelarViagemPlanejadaResult :=  IIF(::oWSCancelarViagemPlanejadaResult = NIL , NIL ,::oWSCancelarViagemPlanejadaResult:Clone() )
	oClone:oWSIndisponibilizarVeiculoResult :=  IIF(::oWSIndisponibilizarVeiculoResult = NIL , NIL ,::oWSIndisponibilizarVeiculoResult:Clone() )
	oClone:cCpf          := ::cCpf
	oClone:oWSIndisponibilizarMotoristaResult :=  IIF(::oWSIndisponibilizarMotoristaResult = NIL , NIL ,::oWSIndisponibilizarMotoristaResult:Clone() )
	oClone:oWSDisponibilizarVeiculoResult :=  IIF(::oWSDisponibilizarVeiculoResult = NIL , NIL ,::oWSDisponibilizarVeiculoResult:Clone() )
	oClone:oWSDisponibilizarMotoristaResult :=  IIF(::oWSDisponibilizarMotoristaResult = NIL , NIL ,::oWSDisponibilizarMotoristaResult:Clone() )
	oClone:oWSIntegrarClienteCompletoResult :=  IIF(::oWSIntegrarClienteCompletoResult = NIL , NIL ,::oWSIntegrarClienteCompletoResult:Clone() )
	oClone:oWSJanela     :=  IIF(::oWSJanela = NIL , NIL ,::oWSJanela:Clone() )
	oClone:oWSIntegrarJanelaAtendimentoResult :=  IIF(::oWSIntegrarJanelaAtendimentoResult = NIL , NIL ,::oWSIntegrarJanelaAtendimentoResult:Clone() )
	oClone:oWSTabelaFrete :=  IIF(::oWSTabelaFrete = NIL , NIL ,::oWSTabelaFrete:Clone() )
	oClone:oWSIntegrarTabelaFreteResult :=  IIF(::oWSIntegrarTabelaFreteResult = NIL , NIL ,::oWSIntegrarTabelaFreteResult:Clone() )
Return oClone

// WSDL Method CompletarViagem of Service WSsivirafullWebService

WSMETHOD CompletarViagem WSSEND cLogin,cSenha,oWSViagem WSRECEIVE oWSCompletarViagemResult WSCLIENT WSsivirafullWebService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<CompletarViagem xmlns="http://app.ravex.com.br/sivirafull/Service.asmx">'
cSoap += WSSoapValue("Login", ::cLogin, cLogin , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("Senha", ::cSenha, cSenha , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("Viagem", ::oWSViagem, oWSViagem , "Viagem", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</CompletarViagem>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://app.ravex.com.br/sivirafull/Service.asmx/CompletarViagem",; 
	"DOCUMENT","http://app.ravex.com.br/sivirafull/Service.asmx",,,; 
	"http://app.ravex.com.br/sivirafull/Service.asmx")

::Init()
::oWSCompletarViagemResult:SoapRecv( WSAdvValue( oXmlRet,"_COMPLETARVIAGEMRESPONSE:_COMPLETARVIAGEMRESULT","Retorno",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method RetornarColetasRealizadas of Service WSsivirafullWebService

WSMETHOD RetornarColetasRealizadas WSSEND cLogin,cSenha,nIdViagem,cIdentificador WSRECEIVE oWSRetornarColetasRealizadasResult WSCLIENT WSsivirafullWebService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<RetornarColetasRealizadas xmlns="http://app.ravex.com.br/sivirafull/Service.asmx">'
cSoap += WSSoapValue("Login", ::cLogin, cLogin , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("Senha", ::cSenha, cSenha , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("IdViagem", ::nIdViagem, nIdViagem , "int", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("Identificador", ::cIdentificador, cIdentificador , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</RetornarColetasRealizadas>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://app.ravex.com.br/sivirafull/Service.asmx/RetornarColetasRealizadas",; 
	"DOCUMENT","http://app.ravex.com.br/sivirafull/Service.asmx",,,; 
	"http://app.ravex.com.br/sivirafull/Service.asmx")

::Init()
::oWSRetornarColetasRealizadasResult:SoapRecv( WSAdvValue( oXmlRet,"_RETORNARCOLETASREALIZADASRESPONSE:_RETORNARCOLETASREALIZADASRESULT","RetornoViagem",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method Autenticar of Service WSsivirafullWebService

WSMETHOD Autenticar WSSEND cLogin,cSenha WSRECEIVE oWSAutenticarResult WSCLIENT WSsivirafullWebService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<Autenticar xmlns="http://app.ravex.com.br/sivirafull/Service.asmx">'
cSoap += WSSoapValue("Login", ::cLogin, cLogin , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("Senha", ::cSenha, cSenha , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</Autenticar>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://app.ravex.com.br/sivirafull/Service.asmx/Autenticar",; 
	"DOCUMENT","http://app.ravex.com.br/sivirafull/Service.asmx",,,; 
	"http://app.ravex.com.br/sivirafull/Service.asmx")

::Init()
::oWSAutenticarResult:SoapRecv( WSAdvValue( oXmlRet,"_AUTENTICARRESPONSE:_AUTENTICARRESULT","Retorno",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method ImportarViagem of Service WSsivirafullWebService

WSMETHOD ImportarViagem WSSEND cLogin,cSenha,oWSViagem WSRECEIVE oWSImportarViagemResult WSCLIENT WSsivirafullWebService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ImportarViagem xmlns="http://app.ravex.com.br/sivirafull/Service.asmx">'
cSoap += WSSoapValue("Login", ::cLogin, cLogin , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("Senha", ::cSenha, cSenha , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("Viagem", ::oWSViagem, oWSViagem , "Viagem", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</ImportarViagem>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://app.ravex.com.br/sivirafull/Service.asmx/ImportarViagem",; 
	"DOCUMENT","http://app.ravex.com.br/sivirafull/Service.asmx",,,; 
	"http://app.ravex.com.br/sivirafull/Service.asmx")

::Init()
::oWSImportarViagemResult:SoapRecv( WSAdvValue( oXmlRet,"_IMPORTARVIAGEMRESPONSE:_IMPORTARVIAGEMRESULT","Retorno",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method ImportarVendedor of Service WSsivirafullWebService

WSMETHOD ImportarVendedor WSSEND cLogin,cSenha,oWSVendedor WSRECEIVE oWSImportarVendedorResult WSCLIENT WSsivirafullWebService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ImportarVendedor xmlns="http://app.ravex.com.br/sivirafull/Service.asmx">'
cSoap += WSSoapValue("Login", ::cLogin, cLogin , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("Senha", ::cSenha, cSenha , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("Vendedor", ::oWSVendedor, oWSVendedor , "Pessoa", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</ImportarVendedor>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://app.ravex.com.br/sivirafull/Service.asmx/ImportarVendedor",; 
	"DOCUMENT","http://app.ravex.com.br/sivirafull/Service.asmx",,,; 
	"http://app.ravex.com.br/sivirafull/Service.asmx")

::Init()
::oWSImportarVendedorResult:SoapRecv( WSAdvValue( oXmlRet,"_IMPORTARVENDEDORRESPONSE:_IMPORTARVENDEDORRESULT","Retorno",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method ImportarGerente of Service WSsivirafullWebService

WSMETHOD ImportarGerente WSSEND cLogin,cSenha,oWSGerente WSRECEIVE oWSImportarGerenteResult WSCLIENT WSsivirafullWebService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ImportarGerente xmlns="http://app.ravex.com.br/sivirafull/Service.asmx">'
cSoap += WSSoapValue("Login", ::cLogin, cLogin , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("Senha", ::cSenha, cSenha , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("Gerente", ::oWSGerente, oWSGerente , "Pessoa", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</ImportarGerente>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://app.ravex.com.br/sivirafull/Service.asmx/ImportarGerente",; 
	"DOCUMENT","http://app.ravex.com.br/sivirafull/Service.asmx",,,; 
	"http://app.ravex.com.br/sivirafull/Service.asmx")

::Init()
::oWSImportarGerenteResult:SoapRecv( WSAdvValue( oXmlRet,"_IMPORTARGERENTERESPONSE:_IMPORTARGERENTERESULT","Retorno",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method ImportarSupervisor of Service WSsivirafullWebService

WSMETHOD ImportarSupervisor WSSEND cLogin,cSenha,oWSSupervisor WSRECEIVE oWSImportarSupervisorResult WSCLIENT WSsivirafullWebService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ImportarSupervisor xmlns="http://app.ravex.com.br/sivirafull/Service.asmx">'
cSoap += WSSoapValue("Login", ::cLogin, cLogin , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("Senha", ::cSenha, cSenha , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("Supervisor", ::oWSSupervisor, oWSSupervisor , "Pessoa", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</ImportarSupervisor>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://app.ravex.com.br/sivirafull/Service.asmx/ImportarSupervisor",; 
	"DOCUMENT","http://app.ravex.com.br/sivirafull/Service.asmx",,,; 
	"http://app.ravex.com.br/sivirafull/Service.asmx")

::Init()
::oWSImportarSupervisorResult:SoapRecv( WSAdvValue( oXmlRet,"_IMPORTARSUPERVISORRESPONSE:_IMPORTARSUPERVISORRESULT","Retorno",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method ImportarPromotor of Service WSsivirafullWebService

WSMETHOD ImportarPromotor WSSEND cLogin,cSenha,oWSPromotor WSRECEIVE oWSImportarPromotorResult WSCLIENT WSsivirafullWebService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ImportarPromotor xmlns="http://app.ravex.com.br/sivirafull/Service.asmx">'
cSoap += WSSoapValue("Login", ::cLogin, cLogin , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("Senha", ::cSenha, cSenha , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("Promotor", ::oWSPromotor, oWSPromotor , "Pessoa", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</ImportarPromotor>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://app.ravex.com.br/sivirafull/Service.asmx/ImportarPromotor",; 
	"DOCUMENT","http://app.ravex.com.br/sivirafull/Service.asmx",,,; 
	"http://app.ravex.com.br/sivirafull/Service.asmx")

::Init()
::oWSImportarPromotorResult:SoapRecv( WSAdvValue( oXmlRet,"_IMPORTARPROMOTORRESPONSE:_IMPORTARPROMOTORRESULT","Retorno",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method ImportarMotorista of Service WSsivirafullWebService

WSMETHOD ImportarMotorista WSSEND cLogin,cSenha,oWSMotorista WSRECEIVE oWSImportarMotoristaResult WSCLIENT WSsivirafullWebService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ImportarMotorista xmlns="http://app.ravex.com.br/sivirafull/Service.asmx">'
cSoap += WSSoapValue("Login", ::cLogin, cLogin , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("Senha", ::cSenha, cSenha , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("Motorista", ::oWSMotorista, oWSMotorista , "Motorista", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</ImportarMotorista>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://app.ravex.com.br/sivirafull/Service.asmx/ImportarMotorista",; 
	"DOCUMENT","http://app.ravex.com.br/sivirafull/Service.asmx",,,; 
	"http://app.ravex.com.br/sivirafull/Service.asmx")

::Init()
::oWSImportarMotoristaResult:SoapRecv( WSAdvValue( oXmlRet,"_IMPORTARMOTORISTARESPONSE:_IMPORTARMOTORISTARESULT","Retorno",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method ImportarVeiculo of Service WSsivirafullWebService

WSMETHOD ImportarVeiculo WSSEND cLogin,cSenha,oWSVeiculo WSRECEIVE oWSImportarVeiculoResult WSCLIENT WSsivirafullWebService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ImportarVeiculo xmlns="http://app.ravex.com.br/sivirafull/Service.asmx">'
cSoap += WSSoapValue("Login", ::cLogin, cLogin , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("Senha", ::cSenha, cSenha , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("Veiculo", ::oWSVeiculo, oWSVeiculo , "Veiculo", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</ImportarVeiculo>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://app.ravex.com.br/sivirafull/Service.asmx/ImportarVeiculo",; 
	"DOCUMENT","http://app.ravex.com.br/sivirafull/Service.asmx",,,; 
	"http://app.ravex.com.br/sivirafull/Service.asmx")

::Init()
::oWSImportarVeiculoResult:SoapRecv( WSAdvValue( oXmlRet,"_IMPORTARVEICULORESPONSE:_IMPORTARVEICULORESULT","Retorno",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method GravarLog of Service WSsivirafullWebService

WSMETHOD GravarLog WSSEND cLogin,cSenha,cTexto,cArquivo WSRECEIVE NULLPARAM WSCLIENT WSsivirafullWebService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GravarLog xmlns="http://app.ravex.com.br/sivirafull/Service.asmx">'
cSoap += WSSoapValue("Login", ::cLogin, cLogin , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("Senha", ::cSenha, cSenha , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("Texto", ::cTexto, cTexto , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("Arquivo", ::cArquivo, cArquivo , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</GravarLog>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://app.ravex.com.br/sivirafull/Service.asmx/GravarLog",; 
	"DOCUMENT","http://app.ravex.com.br/sivirafull/Service.asmx",,,; 
	"http://app.ravex.com.br/sivirafull/Service.asmx")

::Init()

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method ImportarCliente of Service WSsivirafullWebService

WSMETHOD ImportarCliente WSSEND cLogin,cSenha,oWSCliente WSRECEIVE oWSImportarClienteResult WSCLIENT WSsivirafullWebService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ImportarCliente xmlns="http://app.ravex.com.br/sivirafull/Service.asmx">'
cSoap += WSSoapValue("Login", ::cLogin, cLogin , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("Senha", ::cSenha, cSenha , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("Cliente", ::oWSCliente, oWSCliente , "Cliente", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</ImportarCliente>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://app.ravex.com.br/sivirafull/Service.asmx/ImportarCliente",; 
	"DOCUMENT","http://app.ravex.com.br/sivirafull/Service.asmx",,,; 
	"http://app.ravex.com.br/sivirafull/Service.asmx")

::Init()
::oWSImportarClienteResult:SoapRecv( WSAdvValue( oXmlRet,"_IMPORTARCLIENTERESPONSE:_IMPORTARCLIENTERESULT","Retorno",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method ImportarTransportadora of Service WSsivirafullWebService

WSMETHOD ImportarTransportadora WSSEND cLogin,cSenha,oWSTransportadora WSRECEIVE oWSImportarTransportadoraResult WSCLIENT WSsivirafullWebService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ImportarTransportadora xmlns="http://app.ravex.com.br/sivirafull/Service.asmx">'
cSoap += WSSoapValue("Login", ::cLogin, cLogin , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("Senha", ::cSenha, cSenha , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("Transportadora", ::oWSTransportadora, oWSTransportadora , "Transportadora", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</ImportarTransportadora>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://app.ravex.com.br/sivirafull/Service.asmx/ImportarTransportadora",; 
	"DOCUMENT","http://app.ravex.com.br/sivirafull/Service.asmx",,,; 
	"http://app.ravex.com.br/sivirafull/Service.asmx")

::Init()
::oWSImportarTransportadoraResult:SoapRecv( WSAdvValue( oXmlRet,"_IMPORTARTRANSPORTADORARESPONSE:_IMPORTARTRANSPORTADORARESULT","Retorno",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method ImportarProduto of Service WSsivirafullWebService

WSMETHOD ImportarProduto WSSEND cLogin,cSenha,oWSProduto WSRECEIVE oWSImportarProdutoResult WSCLIENT WSsivirafullWebService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ImportarProduto xmlns="http://app.ravex.com.br/sivirafull/Service.asmx">'
cSoap += WSSoapValue("Login", ::cLogin, cLogin , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("Senha", ::cSenha, cSenha , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("Produto", ::oWSProduto, oWSProduto , "Produto", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</ImportarProduto>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://app.ravex.com.br/sivirafull/Service.asmx/ImportarProduto",; 
	"DOCUMENT","http://app.ravex.com.br/sivirafull/Service.asmx",,,; 
	"http://app.ravex.com.br/sivirafull/Service.asmx")

::Init()
::oWSImportarProdutoResult:SoapRecv( WSAdvValue( oXmlRet,"_IMPORTARPRODUTORESPONSE:_IMPORTARPRODUTORESULT","Retorno",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method RetornarViagemDevolucao of Service WSsivirafullWebService

WSMETHOD RetornarViagemDevolucao WSSEND cLogin,cSenha,ccnpjEmissor,lviagemFechadas,lviagensCanceladas,nperiodoHoras WSRECEIVE oWSRetornarViagemDevolucaoResult WSCLIENT WSsivirafullWebService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<RetornarViagemDevolucao xmlns="http://app.ravex.com.br/sivirafull/Service.asmx">'
cSoap += WSSoapValue("Login", ::cLogin, cLogin , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("Senha", ::cSenha, cSenha , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("cnpjEmissor", ::ccnpjEmissor, ccnpjEmissor , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("viagemFechadas", ::lviagemFechadas, lviagemFechadas , "boolean", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("viagensCanceladas", ::lviagensCanceladas, lviagensCanceladas , "boolean", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("periodoHoras", ::nperiodoHoras, nperiodoHoras , "int", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</RetornarViagemDevolucao>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://app.ravex.com.br/sivirafull/Service.asmx/RetornarViagemDevolucao",; 
	"DOCUMENT","http://app.ravex.com.br/sivirafull/Service.asmx",,,; 
	"http://app.ravex.com.br/sivirafull/Service.asmx")

::Init()
::oWSRetornarViagemDevolucaoResult:SoapRecv( WSAdvValue( oXmlRet,"_RETORNARVIAGEMDEVOLUCAORESPONSE:_RETORNARVIAGEMDEVOLUCAORESULT","ArrayOfRetornoDevolucao",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method CancelarViagem of Service WSsivirafullWebService

WSMETHOD CancelarViagem WSSEND cLogin,cSenha,nIdViagem,cIdentificador,cCnpj,cAnomalia WSRECEIVE oWSCancelarViagemResult WSCLIENT WSsivirafullWebService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<CancelarViagem xmlns="http://app.ravex.com.br/sivirafull/Service.asmx">'
cSoap += WSSoapValue("Login", ::cLogin, cLogin , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("Senha", ::cSenha, cSenha , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("IdViagem", ::nIdViagem, nIdViagem , "int", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("Identificador", ::cIdentificador, cIdentificador , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("Cnpj", ::cCnpj, cCnpj , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("Anomalia", ::cAnomalia, cAnomalia , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</CancelarViagem>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://app.ravex.com.br/sivirafull/Service.asmx/CancelarViagem",; 
	"DOCUMENT","http://app.ravex.com.br/sivirafull/Service.asmx",,,; 
	"http://app.ravex.com.br/sivirafull/Service.asmx")

::Init()
::oWSCancelarViagemResult:SoapRecv( WSAdvValue( oXmlRet,"_CANCELARVIAGEMRESPONSE:_CANCELARVIAGEMRESULT","Retorno",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method ConsultaIndicadores of Service WSsivirafullWebService

WSMETHOD ConsultaIndicadores WSSEND cLogin,cSenha,nIdUnidade,cTipoRetorno,ccnpjTransportadora,cInicioPeriodo,cFimPeriodo WSRECEIVE oWSConsultaIndicadoresResult WSCLIENT WSsivirafullWebService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ConsultaIndicadores xmlns="http://app.ravex.com.br/sivirafull/Service.asmx">'
cSoap += WSSoapValue("Login", ::cLogin, cLogin , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("Senha", ::cSenha, cSenha , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("IdUnidade", ::nIdUnidade, nIdUnidade , "int", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("TipoRetorno", ::cTipoRetorno, cTipoRetorno , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("cnpjTransportadora", ::ccnpjTransportadora, ccnpjTransportadora , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("InicioPeriodo", ::cInicioPeriodo, cInicioPeriodo , "dateTime", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("FimPeriodo", ::cFimPeriodo, cFimPeriodo , "dateTime", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</ConsultaIndicadores>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://app.ravex.com.br/sivirafull/Service.asmx/ConsultaIndicadores",; 
	"DOCUMENT","http://app.ravex.com.br/sivirafull/Service.asmx",,,; 
	"http://app.ravex.com.br/sivirafull/Service.asmx")

::Init()
::oWSConsultaIndicadoresResult:SoapRecv( WSAdvValue( oXmlRet,"_CONSULTAINDICADORESRESPONSE:_CONSULTAINDICADORESRESULT","ArrayOfIndicadores",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method ImportarRoteiroViagem of Service WSsivirafullWebService

WSMETHOD ImportarRoteiroViagem WSSEND cLogin,cSenha,oWSRoteiro WSRECEIVE oWSImportarRoteiroViagemResult WSCLIENT WSsivirafullWebService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ImportarRoteiroViagem xmlns="http://app.ravex.com.br/sivirafull/Service.asmx">'
cSoap += WSSoapValue("Login", ::cLogin, cLogin , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("Senha", ::cSenha, cSenha , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("Roteiro", ::oWSRoteiro, oWSRoteiro , "RoteiroViagem", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</ImportarRoteiroViagem>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://app.ravex.com.br/sivirafull/Service.asmx/ImportarRoteiroViagem",; 
	"DOCUMENT","http://app.ravex.com.br/sivirafull/Service.asmx",,,; 
	"http://app.ravex.com.br/sivirafull/Service.asmx")

::Init()
::oWSImportarRoteiroViagemResult:SoapRecv( WSAdvValue( oXmlRet,"_IMPORTARROTEIROVIAGEMRESPONSE:_IMPORTARROTEIROVIAGEMRESULT","Retorno",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method RetornarAnomalias of Service WSsivirafullWebService

WSMETHOD RetornarAnomalias WSSEND cLogin,cSenha,ccnpjEmissor,lviagemFechadas,lviagensCanceladas,nperiodoHoras WSRECEIVE oWSRetornarAnomaliasResult WSCLIENT WSsivirafullWebService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<RetornarAnomalias xmlns="http://app.ravex.com.br/sivirafull/Service.asmx">'
cSoap += WSSoapValue("Login", ::cLogin, cLogin , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("Senha", ::cSenha, cSenha , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("cnpjEmissor", ::ccnpjEmissor, ccnpjEmissor , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("viagemFechadas", ::lviagemFechadas, lviagemFechadas , "boolean", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("viagensCanceladas", ::lviagensCanceladas, lviagensCanceladas , "boolean", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("periodoHoras", ::nperiodoHoras, nperiodoHoras , "int", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</RetornarAnomalias>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://app.ravex.com.br/sivirafull/Service.asmx/RetornarAnomalias",; 
	"DOCUMENT","http://app.ravex.com.br/sivirafull/Service.asmx",,,; 
	"http://app.ravex.com.br/sivirafull/Service.asmx")

::Init()
::oWSRetornarAnomaliasResult:SoapRecv( WSAdvValue( oXmlRet,"_RETORNARANOMALIASRESPONSE:_RETORNARANOMALIASRESULT","ArrayOfAnomalia",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method RetornarNFsEntregues of Service WSsivirafullWebService

WSMETHOD RetornarNFsEntregues WSSEND cLogin,cSenha,ccnpjEmissor,lviagemFechadas,nperiodoHoras WSRECEIVE oWSRetornarNFsEntreguesResult WSCLIENT WSsivirafullWebService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<RetornarNFsEntregues xmlns="http://app.ravex.com.br/sivirafull/Service.asmx">'
cSoap += WSSoapValue("Login", ::cLogin, cLogin , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("Senha", ::cSenha, cSenha , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("cnpjEmissor", ::ccnpjEmissor, ccnpjEmissor , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("viagemFechadas", ::lviagemFechadas, lviagemFechadas , "boolean", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("periodoHoras", ::nperiodoHoras, nperiodoHoras , "int", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</RetornarNFsEntregues>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://app.ravex.com.br/sivirafull/Service.asmx/RetornarNFsEntregues",; 
	"DOCUMENT","http://app.ravex.com.br/sivirafull/Service.asmx",,,; 
	"http://app.ravex.com.br/sivirafull/Service.asmx")

::Init()
::oWSRetornarNFsEntreguesResult:SoapRecv( WSAdvValue( oXmlRet,"_RETORNARNFSENTREGUESRESPONSE:_RETORNARNFSENTREGUESRESULT","ArrayOfNotaEntregue",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method RetornarEntregasRealizadas of Service WSsivirafullWebService

WSMETHOD RetornarEntregasRealizadas WSSEND cLogin,cSenha,nIdViagem,cIdentificador WSRECEIVE oWSRetornarEntregasRealizadasResult WSCLIENT WSsivirafullWebService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<RetornarEntregasRealizadas xmlns="http://app.ravex.com.br/sivirafull/Service.asmx">'
cSoap += WSSoapValue("Login", ::cLogin, cLogin , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("Senha", ::cSenha, cSenha , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("IdViagem", ::nIdViagem, nIdViagem , "int", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("Identificador", ::cIdentificador, cIdentificador , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</RetornarEntregasRealizadas>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://app.ravex.com.br/sivirafull/Service.asmx/RetornarEntregasRealizadas",; 
	"DOCUMENT","http://app.ravex.com.br/sivirafull/Service.asmx",,,; 
	"http://app.ravex.com.br/sivirafull/Service.asmx")

::Init()
::oWSRetornarEntregasRealizadasResult:SoapRecv( WSAdvValue( oXmlRet,"_RETORNARENTREGASREALIZADASRESPONSE:_RETORNARENTREGASREALIZADASRESULT","ViagemRetorno",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method ListarCustosAdicionaisAprovadosPorViagem of Service WSsivirafullWebService

WSMETHOD ListarCustosAdicionaisAprovadosPorViagem WSSEND cLogin,cSenha,cIdentificador,nIdViagem WSRECEIVE oWSListarCustosAdicionaisAprovadosPorViagemResult WSCLIENT WSsivirafullWebService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ListarCustosAdicionaisAprovadosPorViagem xmlns="http://app.ravex.com.br/sivirafull/Service.asmx">'
cSoap += WSSoapValue("Login", ::cLogin, cLogin , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("Senha", ::cSenha, cSenha , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("Identificador", ::cIdentificador, cIdentificador , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("IdViagem", ::nIdViagem, nIdViagem , "int", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</ListarCustosAdicionaisAprovadosPorViagem>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://app.ravex.com.br/sivirafull/Service.asmx/ListarCustosAdicionaisAprovadosPorViagem",; 
	"DOCUMENT","http://app.ravex.com.br/sivirafull/Service.asmx",,,; 
	"http://app.ravex.com.br/sivirafull/Service.asmx")

::Init()
::oWSListarCustosAdicionaisAprovadosPorViagemResult:SoapRecv( WSAdvValue( oXmlRet,"_LISTARCUSTOSADICIONAISAPROVADOSPORVIAGEMRESPONSE:_LISTARCUSTOSADICIONAISAPROVADOSPORVIAGEMRESULT","ArrayOfRetornoCustoAdicional",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method ListarAlteracaoValorModalidadeCustoAdicionalPorViagem of Service WSsivirafullWebService

WSMETHOD ListarAlteracaoValorModalidadeCustoAdicionalPorViagem WSSEND cLogin,cSenha,cIdentificador,nIdViagem WSRECEIVE oWSListarAlteracaoValorModalidadeCustoAdicionalPorViagemResult WSCLIENT WSsivirafullWebService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ListarAlteracaoValorModalidadeCustoAdicionalPorViagem xmlns="http://app.ravex.com.br/sivirafull/Service.asmx">'
cSoap += WSSoapValue("Login", ::cLogin, cLogin , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("Senha", ::cSenha, cSenha , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("Identificador", ::cIdentificador, cIdentificador , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("IdViagem", ::nIdViagem, nIdViagem , "int", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</ListarAlteracaoValorModalidadeCustoAdicionalPorViagem>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://app.ravex.com.br/sivirafull/Service.asmx/ListarAlteracaoValorModalidadeCustoAdicionalPorViagem",; 
	"DOCUMENT","http://app.ravex.com.br/sivirafull/Service.asmx",,,; 
	"http://app.ravex.com.br/sivirafull/Service.asmx")

::Init()
::oWSListarAlteracaoValorModalidadeCustoAdicionalPorViagemResult:SoapRecv( WSAdvValue( oXmlRet,"_LISTARALTERACAOVALORMODALIDADECUSTOADICIONALPORVIAGEMRESPONSE:_LISTARALTERACAOVALORMODALIDADECUSTOADICIONALPORVIAGEMRESULT","ArrayOfRetornoAlteracaoValorModalidade",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method RetornarQuantidadePernoitesAprovadasPorViagem of Service WSsivirafullWebService

WSMETHOD RetornarQuantidadePernoitesAprovadasPorViagem WSSEND cLogin,cSenha,cIdentificador,nIdViagem WSRECEIVE oWSRetornarQuantidadePernoitesAprovadasPorViagemResult WSCLIENT WSsivirafullWebService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<RetornarQuantidadePernoitesAprovadasPorViagem xmlns="http://app.ravex.com.br/sivirafull/Service.asmx">'
cSoap += WSSoapValue("Login", ::cLogin, cLogin , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("Senha", ::cSenha, cSenha , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("Identificador", ::cIdentificador, cIdentificador , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("IdViagem", ::nIdViagem, nIdViagem , "int", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</RetornarQuantidadePernoitesAprovadasPorViagem>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://app.ravex.com.br/sivirafull/Service.asmx/RetornarQuantidadePernoitesAprovadasPorViagem",; 
	"DOCUMENT","http://app.ravex.com.br/sivirafull/Service.asmx",,,; 
	"http://app.ravex.com.br/sivirafull/Service.asmx")

::Init()
::oWSRetornarQuantidadePernoitesAprovadasPorViagemResult:SoapRecv( WSAdvValue( oXmlRet,"_RETORNARQUANTIDADEPERNOITESAPROVADASPORVIAGEMRESPONSE:_RETORNARQUANTIDADEPERNOITESAPROVADASPORVIAGEMRESULT","RetornoPernoiteAprovada",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method RetornarAnomaliasRegistradas of Service WSsivirafullWebService

WSMETHOD RetornarAnomaliasRegistradas WSSEND cLogin,cSenha,nIdViagem,cIdentificador WSRECEIVE oWSRetornarAnomaliasRegistradasResult WSCLIENT WSsivirafullWebService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<RetornarAnomaliasRegistradas xmlns="http://app.ravex.com.br/sivirafull/Service.asmx">'
cSoap += WSSoapValue("Login", ::cLogin, cLogin , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("Senha", ::cSenha, cSenha , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("IdViagem", ::nIdViagem, nIdViagem , "int", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("Identificador", ::cIdentificador, cIdentificador , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</RetornarAnomaliasRegistradas>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://app.ravex.com.br/sivirafull/Service.asmx/RetornarAnomaliasRegistradas",; 
	"DOCUMENT","http://app.ravex.com.br/sivirafull/Service.asmx",,,; 
	"http://app.ravex.com.br/sivirafull/Service.asmx")

::Init()
::oWSRetornarAnomaliasRegistradasResult:SoapRecv( WSAdvValue( oXmlRet,"_RETORNARANOMALIASREGISTRADASRESPONSE:_RETORNARANOMALIASREGISTRADASRESULT","ViagemRetorno",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method ListarViagensFinalizadas of Service WSsivirafullWebService

WSMETHOD ListarViagensFinalizadas WSSEND cLogin,cSenha,nPeriodoMinutos WSRECEIVE oWSListarViagensFinalizadasResult WSCLIENT WSsivirafullWebService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ListarViagensFinalizadas xmlns="http://app.ravex.com.br/sivirafull/Service.asmx">'
cSoap += WSSoapValue("Login", ::cLogin, cLogin , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("Senha", ::cSenha, cSenha , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("PeriodoMinutos", ::nPeriodoMinutos, nPeriodoMinutos , "int", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</ListarViagensFinalizadas>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://app.ravex.com.br/sivirafull/Service.asmx/ListarViagensFinalizadas",; 
	"DOCUMENT","http://app.ravex.com.br/sivirafull/Service.asmx",,,; 
	"http://app.ravex.com.br/sivirafull/Service.asmx")

::Init()
::oWSListarViagensFinalizadasResult:SoapRecv( WSAdvValue( oXmlRet,"_LISTARVIAGENSFINALIZADASRESPONSE:_LISTARVIAGENSFINALIZADASRESULT","ArrayOfViagemFinalizada",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method RetornarStatusVeiculo of Service WSsivirafullWebService

WSMETHOD RetornarStatusVeiculo WSSEND cLogin,cSenha,cPlaca WSRECEIVE oWSRetornarStatusVeiculoResult WSCLIENT WSsivirafullWebService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<RetornarStatusVeiculo xmlns="http://app.ravex.com.br/sivirafull/Service.asmx">'
cSoap += WSSoapValue("Login", ::cLogin, cLogin , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("Senha", ::cSenha, cSenha , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("Placa", ::cPlaca, cPlaca , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</RetornarStatusVeiculo>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://app.ravex.com.br/sivirafull/Service.asmx/RetornarStatusVeiculo",; 
	"DOCUMENT","http://app.ravex.com.br/sivirafull/Service.asmx",,,; 
	"http://app.ravex.com.br/sivirafull/Service.asmx")

::Init()
::oWSRetornarStatusVeiculoResult:SoapRecv( WSAdvValue( oXmlRet,"_RETORNARSTATUSVEICULORESPONSE:_RETORNARSTATUSVEICULORESULT","StatusVeiculo",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method ConsultarPlacaDisponivel of Service WSsivirafullWebService

WSMETHOD ConsultarPlacaDisponivel WSSEND cLogin,cSenha,cPlaca WSRECEIVE oWSConsultarPlacaDisponivelResult WSCLIENT WSsivirafullWebService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ConsultarPlacaDisponivel xmlns="http://app.ravex.com.br/sivirafull/Service.asmx">'
cSoap += WSSoapValue("Login", ::cLogin, cLogin , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("Senha", ::cSenha, cSenha , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("Placa", ::cPlaca, cPlaca , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</ConsultarPlacaDisponivel>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://app.ravex.com.br/sivirafull/Service.asmx/ConsultarPlacaDisponivel",; 
	"DOCUMENT","http://app.ravex.com.br/sivirafull/Service.asmx",,,; 
	"http://app.ravex.com.br/sivirafull/Service.asmx")

::Init()
::oWSConsultarPlacaDisponivelResult:SoapRecv( WSAdvValue( oXmlRet,"_CONSULTARPLACADISPONIVELRESPONSE:_CONSULTARPLACADISPONIVELRESULT","StatusVeiculo",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method ImportarPedidos of Service WSsivirafullWebService

WSMETHOD ImportarPedidos WSSEND cLogin,cSenha,oWSPedidos WSRECEIVE oWSImportarPedidosResult WSCLIENT WSsivirafullWebService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ImportarPedidos xmlns="http://app.ravex.com.br/sivirafull/Service.asmx">'
cSoap += WSSoapValue("Login", ::cLogin, cLogin , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("Senha", ::cSenha, cSenha , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("Pedidos", ::oWSPedidos, oWSPedidos , "ArrayOfPedido", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</ImportarPedidos>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://app.ravex.com.br/sivirafull/Service.asmx/ImportarPedidos",; 
	"DOCUMENT","http://app.ravex.com.br/sivirafull/Service.asmx",,,; 
	"http://app.ravex.com.br/sivirafull/Service.asmx")

::Init()
::oWSImportarPedidosResult:SoapRecv( WSAdvValue( oXmlRet,"_IMPORTARPEDIDOSRESPONSE:_IMPORTARPEDIDOSRESULT","Retorno",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method RetornarRoteiros of Service WSsivirafullWebService

WSMETHOD RetornarRoteiros WSSEND cLogin,cSenha,oWSFiltro WSRECEIVE oWSRetornarRoteirosResult WSCLIENT WSsivirafullWebService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<RetornarRoteiros xmlns="http://app.ravex.com.br/sivirafull/Service.asmx">'
cSoap += WSSoapValue("Login", ::cLogin, cLogin , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("Senha", ::cSenha, cSenha , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("Filtro", ::oWSFiltro, oWSFiltro , "FiltroRoteiro", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</RetornarRoteiros>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://app.ravex.com.br/sivirafull/Service.asmx/RetornarRoteiros",; 
	"DOCUMENT","http://app.ravex.com.br/sivirafull/Service.asmx",,,; 
	"http://app.ravex.com.br/sivirafull/Service.asmx")

::Init()
::oWSRetornarRoteirosResult:SoapRecv( WSAdvValue( oXmlRet,"_RETORNARROTEIROSRESPONSE:_RETORNARROTEIROSRESULT","ArrayOfRoteiro",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method ListarModalidadesDeCustoAdicional of Service WSsivirafullWebService

WSMETHOD ListarModalidadesDeCustoAdicional WSSEND cLogin,cSenha WSRECEIVE oWSListarModalidadesDeCustoAdicionalResult WSCLIENT WSsivirafullWebService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ListarModalidadesDeCustoAdicional xmlns="http://app.ravex.com.br/sivirafull/Service.asmx">'
cSoap += WSSoapValue("Login", ::cLogin, cLogin , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("Senha", ::cSenha, cSenha , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</ListarModalidadesDeCustoAdicional>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://app.ravex.com.br/sivirafull/Service.asmx/ListarModalidadesDeCustoAdicional",; 
	"DOCUMENT","http://app.ravex.com.br/sivirafull/Service.asmx",,,; 
	"http://app.ravex.com.br/sivirafull/Service.asmx")

::Init()
::oWSListarModalidadesDeCustoAdicionalResult:SoapRecv( WSAdvValue( oXmlRet,"_LISTARMODALIDADESDECUSTOADICIONALRESPONSE:_LISTARMODALIDADESDECUSTOADICIONALRESULT","ArrayOfModalidadeCustoAdicional",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method ListarTiposDeCustoAdicional of Service WSsivirafullWebService

WSMETHOD ListarTiposDeCustoAdicional WSSEND cLogin,cSenha WSRECEIVE oWSListarTiposDeCustoAdicionalResult WSCLIENT WSsivirafullWebService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ListarTiposDeCustoAdicional xmlns="http://app.ravex.com.br/sivirafull/Service.asmx">'
cSoap += WSSoapValue("Login", ::cLogin, cLogin , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("Senha", ::cSenha, cSenha , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</ListarTiposDeCustoAdicional>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://app.ravex.com.br/sivirafull/Service.asmx/ListarTiposDeCustoAdicional",; 
	"DOCUMENT","http://app.ravex.com.br/sivirafull/Service.asmx",,,; 
	"http://app.ravex.com.br/sivirafull/Service.asmx")

::Init()
::oWSListarTiposDeCustoAdicionalResult:SoapRecv( WSAdvValue( oXmlRet,"_LISTARTIPOSDECUSTOADICIONALRESPONSE:_LISTARTIPOSDECUSTOADICIONALRESULT","ArrayOfTipoCustoAdicional",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method ImportarViagemFaturada of Service WSsivirafullWebService

WSMETHOD ImportarViagemFaturada WSSEND cLogin,cSenha,oWSViagem WSRECEIVE oWSImportarViagemFaturadaResult WSCLIENT WSsivirafullWebService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ImportarViagemFaturada xmlns="http://app.ravex.com.br/sivirafull/Service.asmx">'
cSoap += WSSoapValue("Login", ::cLogin, cLogin , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("Senha", ::cSenha, cSenha , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("Viagem", ::oWSViagem, oWSViagem , "Viagem", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</ImportarViagemFaturada>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://app.ravex.com.br/sivirafull/Service.asmx/ImportarViagemFaturada",; 
	"DOCUMENT","http://app.ravex.com.br/sivirafull/Service.asmx",,,; 
	"http://app.ravex.com.br/sivirafull/Service.asmx")

::Init()
::oWSImportarViagemFaturadaResult:SoapRecv( WSAdvValue( oXmlRet,"_IMPORTARVIAGEMFATURADARESPONSE:_IMPORTARVIAGEMFATURADARESULT","Retorno",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method ImportarViagemPlanejada of Service WSsivirafullWebService

WSMETHOD ImportarViagemPlanejada WSSEND cLogin,cSenha,oWSViagemPlanejada WSRECEIVE oWSImportarViagemPlanejadaResult WSCLIENT WSsivirafullWebService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ImportarViagemPlanejada xmlns="http://app.ravex.com.br/sivirafull/Service.asmx">'
cSoap += WSSoapValue("Login", ::cLogin, cLogin , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("Senha", ::cSenha, cSenha , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("ViagemPlanejada", ::oWSViagemPlanejada, oWSViagemPlanejada , "ViagemPlanejada", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</ImportarViagemPlanejada>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://app.ravex.com.br/sivirafull/Service.asmx/ImportarViagemPlanejada",; 
	"DOCUMENT","http://app.ravex.com.br/sivirafull/Service.asmx",,,; 
	"http://app.ravex.com.br/sivirafull/Service.asmx")

::Init()
::oWSImportarViagemPlanejadaResult:SoapRecv( WSAdvValue( oXmlRet,"_IMPORTARVIAGEMPLANEJADARESPONSE:_IMPORTARVIAGEMPLANEJADARESULT","Retorno",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method CancelarViagemPlanejada of Service WSsivirafullWebService

WSMETHOD CancelarViagemPlanejada WSSEND cLogin,cSenha,nIdViagem,cIdentificador,cAnomalia WSRECEIVE oWSCancelarViagemPlanejadaResult WSCLIENT WSsivirafullWebService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<CancelarViagemPlanejada xmlns="http://app.ravex.com.br/sivirafull/Service.asmx">'
cSoap += WSSoapValue("Login", ::cLogin, cLogin , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("Senha", ::cSenha, cSenha , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("IdViagem", ::nIdViagem, nIdViagem , "int", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("Identificador", ::cIdentificador, cIdentificador , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("Anomalia", ::cAnomalia, cAnomalia , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</CancelarViagemPlanejada>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://app.ravex.com.br/sivirafull/Service.asmx/CancelarViagemPlanejada",; 
	"DOCUMENT","http://app.ravex.com.br/sivirafull/Service.asmx",,,; 
	"http://app.ravex.com.br/sivirafull/Service.asmx")

::Init()
::oWSCancelarViagemPlanejadaResult:SoapRecv( WSAdvValue( oXmlRet,"_CANCELARVIAGEMPLANEJADARESPONSE:_CANCELARVIAGEMPLANEJADARESULT","Retorno",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method IndisponibilizarVeiculo of Service WSsivirafullWebService

WSMETHOD IndisponibilizarVeiculo WSSEND cLogin,cSenha,cCnpjTransportadora,cPlaca WSRECEIVE oWSIndisponibilizarVeiculoResult WSCLIENT WSsivirafullWebService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<IndisponibilizarVeiculo xmlns="http://app.ravex.com.br/sivirafull/Service.asmx">'
cSoap += WSSoapValue("Login", ::cLogin, cLogin , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("Senha", ::cSenha, cSenha , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CnpjTransportadora", ::cCnpjTransportadora, cCnpjTransportadora , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("Placa", ::cPlaca, cPlaca , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</IndisponibilizarVeiculo>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://app.ravex.com.br/sivirafull/Service.asmx/IndisponibilizarVeiculo",; 
	"DOCUMENT","http://app.ravex.com.br/sivirafull/Service.asmx",,,; 
	"http://app.ravex.com.br/sivirafull/Service.asmx")

::Init()
::oWSIndisponibilizarVeiculoResult:SoapRecv( WSAdvValue( oXmlRet,"_INDISPONIBILIZARVEICULORESPONSE:_INDISPONIBILIZARVEICULORESULT","Retorno",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method IndisponibilizarMotorista of Service WSsivirafullWebService

WSMETHOD IndisponibilizarMotorista WSSEND cLogin,cSenha,cCnpjTransportadora,cCpf WSRECEIVE oWSIndisponibilizarMotoristaResult WSCLIENT WSsivirafullWebService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<IndisponibilizarMotorista xmlns="http://app.ravex.com.br/sivirafull/Service.asmx">'
cSoap += WSSoapValue("Login", ::cLogin, cLogin , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("Senha", ::cSenha, cSenha , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CnpjTransportadora", ::cCnpjTransportadora, cCnpjTransportadora , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("Cpf", ::cCpf, cCpf , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</IndisponibilizarMotorista>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://app.ravex.com.br/sivirafull/Service.asmx/IndisponibilizarMotorista",; 
	"DOCUMENT","http://app.ravex.com.br/sivirafull/Service.asmx",,,; 
	"http://app.ravex.com.br/sivirafull/Service.asmx")

::Init()
::oWSIndisponibilizarMotoristaResult:SoapRecv( WSAdvValue( oXmlRet,"_INDISPONIBILIZARMOTORISTARESPONSE:_INDISPONIBILIZARMOTORISTARESULT","Retorno",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method DisponibilizarVeiculo of Service WSsivirafullWebService

WSMETHOD DisponibilizarVeiculo WSSEND cLogin,cSenha,cCnpjTransportadora,cPlaca WSRECEIVE oWSDisponibilizarVeiculoResult WSCLIENT WSsivirafullWebService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<DisponibilizarVeiculo xmlns="http://app.ravex.com.br/sivirafull/Service.asmx">'
cSoap += WSSoapValue("Login", ::cLogin, cLogin , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("Senha", ::cSenha, cSenha , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CnpjTransportadora", ::cCnpjTransportadora, cCnpjTransportadora , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("Placa", ::cPlaca, cPlaca , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</DisponibilizarVeiculo>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://app.ravex.com.br/sivirafull/Service.asmx/DisponibilizarVeiculo",; 
	"DOCUMENT","http://app.ravex.com.br/sivirafull/Service.asmx",,,; 
	"http://app.ravex.com.br/sivirafull/Service.asmx")

::Init()
::oWSDisponibilizarVeiculoResult:SoapRecv( WSAdvValue( oXmlRet,"_DISPONIBILIZARVEICULORESPONSE:_DISPONIBILIZARVEICULORESULT","Retorno",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method DisponibilizarMotorista of Service WSsivirafullWebService

WSMETHOD DisponibilizarMotorista WSSEND cLogin,cSenha,cCnpjTransportadora,cCpf WSRECEIVE oWSDisponibilizarMotoristaResult WSCLIENT WSsivirafullWebService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<DisponibilizarMotorista xmlns="http://app.ravex.com.br/sivirafull/Service.asmx">'
cSoap += WSSoapValue("Login", ::cLogin, cLogin , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("Senha", ::cSenha, cSenha , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CnpjTransportadora", ::cCnpjTransportadora, cCnpjTransportadora , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("Cpf", ::cCpf, cCpf , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</DisponibilizarMotorista>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://app.ravex.com.br/sivirafull/Service.asmx/DisponibilizarMotorista",; 
	"DOCUMENT","http://app.ravex.com.br/sivirafull/Service.asmx",,,; 
	"http://app.ravex.com.br/sivirafull/Service.asmx")

::Init()
::oWSDisponibilizarMotoristaResult:SoapRecv( WSAdvValue( oXmlRet,"_DISPONIBILIZARMOTORISTARESPONSE:_DISPONIBILIZARMOTORISTARESULT","Retorno",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method IntegrarClienteCompleto of Service WSsivirafullWebService

WSMETHOD IntegrarClienteCompleto WSSEND cLogin,cSenha,oWSCliente WSRECEIVE oWSIntegrarClienteCompletoResult WSCLIENT WSsivirafullWebService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<IntegrarClienteCompleto xmlns="http://app.ravex.com.br/sivirafull/Service.asmx">'
cSoap += WSSoapValue("Login", ::cLogin, cLogin , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("Senha", ::cSenha, cSenha , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("Cliente", ::oWSCliente, oWSCliente , "Cliente", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</IntegrarClienteCompleto>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://app.ravex.com.br/sivirafull/Service.asmx/IntegrarClienteCompleto",; 
	"DOCUMENT","http://app.ravex.com.br/sivirafull/Service.asmx",,,; 
	"http://app.ravex.com.br/sivirafull/Service.asmx")

::Init()
::oWSIntegrarClienteCompletoResult:SoapRecv( WSAdvValue( oXmlRet,"_INTEGRARCLIENTECOMPLETORESPONSE:_INTEGRARCLIENTECOMPLETORESULT","Retorno",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method IntegrarJanelaAtendimento of Service WSsivirafullWebService

WSMETHOD IntegrarJanelaAtendimento WSSEND cLogin,cSenha,cCliente,oWSJanela WSRECEIVE oWSIntegrarJanelaAtendimentoResult WSCLIENT WSsivirafullWebService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<IntegrarJanelaAtendimento xmlns="http://app.ravex.com.br/sivirafull/Service.asmx">'
cSoap += WSSoapValue("Login", ::cLogin, cLogin , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("Senha", ::cSenha, cSenha , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("Cliente", ::cCliente, cCliente , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("Janela", ::oWSJanela, oWSJanela , "JanelaAtendimento", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</IntegrarJanelaAtendimento>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://app.ravex.com.br/sivirafull/Service.asmx/IntegrarJanelaAtendimento",; 
	"DOCUMENT","http://app.ravex.com.br/sivirafull/Service.asmx",,,; 
	"http://app.ravex.com.br/sivirafull/Service.asmx")

::Init()
::oWSIntegrarJanelaAtendimentoResult:SoapRecv( WSAdvValue( oXmlRet,"_INTEGRARJANELAATENDIMENTORESPONSE:_INTEGRARJANELAATENDIMENTORESULT","Retorno",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method IntegrarTabelaFrete of Service WSsivirafullWebService

WSMETHOD IntegrarTabelaFrete WSSEND cLogin,cSenha,oWSTabelaFrete WSRECEIVE oWSIntegrarTabelaFreteResult WSCLIENT WSsivirafullWebService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<IntegrarTabelaFrete xmlns="http://app.ravex.com.br/sivirafull/Service.asmx">'
cSoap += WSSoapValue("Login", ::cLogin, cLogin , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("Senha", ::cSenha, cSenha , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("TabelaFrete", ::oWSTabelaFrete, oWSTabelaFrete , "Frete", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</IntegrarTabelaFrete>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://app.ravex.com.br/sivirafull/Service.asmx/IntegrarTabelaFrete",; 
	"DOCUMENT","http://app.ravex.com.br/sivirafull/Service.asmx",,,; 
	"http://app.ravex.com.br/sivirafull/Service.asmx")

::Init()
::oWSIntegrarTabelaFreteResult:SoapRecv( WSAdvValue( oXmlRet,"_INTEGRARTABELAFRETERESPONSE:_INTEGRARTABELAFRETERESULT","Retorno",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure Viagem

WSSTRUCT sivirafullWebService_Viagem
	WSDATA   cIdentificador            AS string OPTIONAL
	WSDATA   cEstimativaInicio         AS dateTime
	WSDATA   cEstimativaFim            AS dateTime
	WSDATA   nIdCliente                AS int
	WSDATA   nIdEmbarcador             AS int
	WSDATA   nIdUnidade                AS int
	WSDATA   cCNPJUnidade              AS string OPTIONAL
	WSDATA   nIdCooperativa            AS int
	WSDATA   nIdTransportadora         AS int
	WSDATA   cCodigoOrigem             AS string OPTIONAL
	WSDATA   cOrigem                   AS string OPTIONAL
	WSDATA   cCodigoDestino            AS string OPTIONAL
	WSDATA   cDestino                  AS string OPTIONAL
	WSDATA   nTemperaturaMinima        AS int
	WSDATA   nTemperaturaMaxima        AS int
	WSDATA   cProduto                  AS string OPTIONAL
	WSDATA   cObservacoes              AS string OPTIONAL
	WSDATA   cMotorista                AS string OPTIONAL
	WSDATA   cPlaca                    AS string OPTIONAL
	WSDATA   cFoneMotorista            AS string OPTIONAL
	WSDATA   cTipo                     AS string OPTIONAL
	WSDATA   nPeso                     AS decimal
	WSDATA   nValor                    AS decimal
	WSDATA   nCubagem                  AS decimal
	WSDATA   nViagemPrioritaria        AS int
	WSDATA   cNumeroOrdemCarregamento  AS string OPTIONAL
	WSDATA   nKmEstimado               AS decimal
	WSDATA   nQtdCaixas                AS int
	WSDATA   lPossuiOrdemEspecial      AS boolean
	WSDATA   cInicioCarregamento       AS dateTime
	WSDATA   cFimCarregamento          AS dateTime
	WSDATA   cInicioPreFrio            AS dateTime
	WSDATA   nDivisaoEmpresarial       AS int
	WSDATA   cTipoVeiculo              AS string OPTIONAL
	WSDATA   cComputarIndicador        AS string OPTIONAL
	WSDATA   cCodigoRota               AS string OPTIONAL
	WSDATA   cCodigoTabelaFrete        AS string OPTIONAL
	WSDATA   oWSTabelaFrete            AS sivirafullWebService_Frete OPTIONAL
	WSDATA   nIdRoteirizador           AS int
	WSDATA   nIdProjeto                AS int
	WSDATA   nDiasEmRota               AS int
	WSDATA   oWSEntregas               AS sivirafullWebService_ArrayOfEntrega OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT sivirafullWebService_Viagem
	::Init()
Return Self

WSMETHOD INIT WSCLIENT sivirafullWebService_Viagem
Return

WSMETHOD CLONE WSCLIENT sivirafullWebService_Viagem
	Local oClone := sivirafullWebService_Viagem():NEW()
	oClone:cIdentificador       := ::cIdentificador
	oClone:cEstimativaInicio    := ::cEstimativaInicio
	oClone:cEstimativaFim       := ::cEstimativaFim
	oClone:nIdCliente           := ::nIdCliente
	oClone:nIdEmbarcador        := ::nIdEmbarcador
	oClone:nIdUnidade           := ::nIdUnidade
	oClone:cCNPJUnidade         := ::cCNPJUnidade
	oClone:nIdCooperativa       := ::nIdCooperativa
	oClone:nIdTransportadora    := ::nIdTransportadora
	oClone:cCodigoOrigem        := ::cCodigoOrigem
	oClone:cOrigem              := ::cOrigem
	oClone:cCodigoDestino       := ::cCodigoDestino
	oClone:cDestino             := ::cDestino
	oClone:nTemperaturaMinima   := ::nTemperaturaMinima
	oClone:nTemperaturaMaxima   := ::nTemperaturaMaxima
	oClone:cProduto             := ::cProduto
	oClone:cObservacoes         := ::cObservacoes
	oClone:cMotorista           := ::cMotorista
	oClone:cPlaca               := ::cPlaca
	oClone:cFoneMotorista       := ::cFoneMotorista
	oClone:cTipo                := ::cTipo
	oClone:nPeso                := ::nPeso
	oClone:nValor               := ::nValor
	oClone:nCubagem             := ::nCubagem
	oClone:nViagemPrioritaria   := ::nViagemPrioritaria
	oClone:cNumeroOrdemCarregamento := ::cNumeroOrdemCarregamento
	oClone:nKmEstimado          := ::nKmEstimado
	oClone:nQtdCaixas           := ::nQtdCaixas
	oClone:lPossuiOrdemEspecial := ::lPossuiOrdemEspecial
	oClone:cInicioCarregamento  := ::cInicioCarregamento
	oClone:cFimCarregamento     := ::cFimCarregamento
	oClone:cInicioPreFrio       := ::cInicioPreFrio
	oClone:nDivisaoEmpresarial  := ::nDivisaoEmpresarial
	oClone:cTipoVeiculo         := ::cTipoVeiculo
	oClone:cComputarIndicador   := ::cComputarIndicador
	oClone:cCodigoRota          := ::cCodigoRota
	oClone:cCodigoTabelaFrete   := ::cCodigoTabelaFrete
	oClone:oWSTabelaFrete       := IIF(::oWSTabelaFrete = NIL , NIL , ::oWSTabelaFrete:Clone() )
	oClone:nIdRoteirizador      := ::nIdRoteirizador
	oClone:nIdProjeto           := ::nIdProjeto
	oClone:nDiasEmRota          := ::nDiasEmRota
	oClone:oWSEntregas          := IIF(::oWSEntregas = NIL , NIL , ::oWSEntregas:Clone() )
Return oClone

WSMETHOD SOAPSEND WSCLIENT sivirafullWebService_Viagem
	Local cSoap := ""
	cSoap += WSSoapValue("Identificador", ::cIdentificador, ::cIdentificador , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("EstimativaInicio", ::cEstimativaInicio, ::cEstimativaInicio , "dateTime", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("EstimativaFim", ::cEstimativaFim, ::cEstimativaFim , "dateTime", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("IdCliente", ::nIdCliente, ::nIdCliente , "int", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("IdEmbarcador", ::nIdEmbarcador, ::nIdEmbarcador , "int", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("IdUnidade", ::nIdUnidade, ::nIdUnidade , "int", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CNPJUnidade", ::cCNPJUnidade, ::cCNPJUnidade , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("IdCooperativa", ::nIdCooperativa, ::nIdCooperativa , "int", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("IdTransportadora", ::nIdTransportadora, ::nIdTransportadora , "int", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CodigoOrigem", ::cCodigoOrigem, ::cCodigoOrigem , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Origem", ::cOrigem, ::cOrigem , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CodigoDestino", ::cCodigoDestino, ::cCodigoDestino , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Destino", ::cDestino, ::cDestino , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("TemperaturaMinima", ::nTemperaturaMinima, ::nTemperaturaMinima , "int", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("TemperaturaMaxima", ::nTemperaturaMaxima, ::nTemperaturaMaxima , "int", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Produto", ::cProduto, ::cProduto , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Observacoes", ::cObservacoes, ::cObservacoes , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Motorista", ::cMotorista, ::cMotorista , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Placa", ::cPlaca, ::cPlaca , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("FoneMotorista", ::cFoneMotorista, ::cFoneMotorista , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Tipo", ::cTipo, ::cTipo , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Peso", ::nPeso, ::nPeso , "decimal", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Valor", ::nValor, ::nValor , "decimal", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Cubagem", ::nCubagem, ::nCubagem , "decimal", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ViagemPrioritaria", ::nViagemPrioritaria, ::nViagemPrioritaria , "int", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("NumeroOrdemCarregamento", ::cNumeroOrdemCarregamento, ::cNumeroOrdemCarregamento , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("KmEstimado", ::nKmEstimado, ::nKmEstimado , "decimal", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("QtdCaixas", ::nQtdCaixas, ::nQtdCaixas , "int", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("PossuiOrdemEspecial", ::lPossuiOrdemEspecial, ::lPossuiOrdemEspecial , "boolean", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("InicioCarregamento", ::cInicioCarregamento, ::cInicioCarregamento , "dateTime", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("FimCarregamento", ::cFimCarregamento, ::cFimCarregamento , "dateTime", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("InicioPreFrio", ::cInicioPreFrio, ::cInicioPreFrio , "dateTime", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("DivisaoEmpresarial", ::nDivisaoEmpresarial, ::nDivisaoEmpresarial , "int", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("TipoVeiculo", ::cTipoVeiculo, ::cTipoVeiculo , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ComputarIndicador", ::cComputarIndicador, ::cComputarIndicador , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CodigoRota", ::cCodigoRota, ::cCodigoRota , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CodigoTabelaFrete", ::cCodigoTabelaFrete, ::cCodigoTabelaFrete , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("TabelaFrete", ::oWSTabelaFrete, ::oWSTabelaFrete , "Frete", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("IdRoteirizador", ::nIdRoteirizador, ::nIdRoteirizador , "int", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("IdProjeto", ::nIdProjeto, ::nIdProjeto , "int", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("DiasEmRota", ::nDiasEmRota, ::nDiasEmRota , "int", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Entregas", ::oWSEntregas, ::oWSEntregas , "ArrayOfEntrega", .F. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

// WSDL Data Structure Retorno

WSSTRUCT sivirafullWebService_Retorno
	WSDATA   nId                       AS int
	WSDATA   cMensagem                 AS string OPTIONAL
	WSDATA   cIdentificador            AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT sivirafullWebService_Retorno
	::Init()
Return Self

WSMETHOD INIT WSCLIENT sivirafullWebService_Retorno
Return

WSMETHOD CLONE WSCLIENT sivirafullWebService_Retorno
	Local oClone := sivirafullWebService_Retorno():NEW()
	oClone:nId                  := ::nId
	oClone:cMensagem            := ::cMensagem
	oClone:cIdentificador       := ::cIdentificador
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT sivirafullWebService_Retorno
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::nId                :=  WSAdvValue( oResponse,"_ID","int",NIL,"Property nId as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cMensagem          :=  WSAdvValue( oResponse,"_MENSAGEM","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cIdentificador     :=  WSAdvValue( oResponse,"_IDENTIFICADOR","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure RetornoViagem

WSSTRUCT sivirafullWebService_RetornoViagem
	WSDATA   nIdViagem                 AS int
	WSDATA   cIdentificador            AS string OPTIONAL
	WSDATA   nIdEmbarcador             AS int
	WSDATA   cCnpjUnidade              AS string OPTIONAL
	WSDATA   nIdUnidade                AS int
	WSDATA   cPlaca                    AS string OPTIONAL
	WSDATA   cInicio                   AS dateTime
	WSDATA   cFim                      AS dateTime
	WSDATA   cInicioDescarga           AS dateTime
	WSDATA   cFimDescarga              AS dateTime
	WSDATA   nCodigoStatus             AS int
	WSDATA   cStatus                   AS string OPTIONAL
	WSDATA   oWSAnomalias              AS sivirafullWebService_ArrayOfRetornoAnomalia OPTIONAL
	WSDATA   oWSEntregas               AS sivirafullWebService_ArrayOfRetornoEntrega OPTIONAL
	WSDATA   oWSColetas                AS sivirafullWebService_ArrayOfRetornoColeta OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT sivirafullWebService_RetornoViagem
	::Init()
Return Self

WSMETHOD INIT WSCLIENT sivirafullWebService_RetornoViagem
Return

WSMETHOD CLONE WSCLIENT sivirafullWebService_RetornoViagem
	Local oClone := sivirafullWebService_RetornoViagem():NEW()
	oClone:nIdViagem            := ::nIdViagem
	oClone:cIdentificador       := ::cIdentificador
	oClone:nIdEmbarcador        := ::nIdEmbarcador
	oClone:cCnpjUnidade         := ::cCnpjUnidade
	oClone:nIdUnidade           := ::nIdUnidade
	oClone:cPlaca               := ::cPlaca
	oClone:cInicio              := ::cInicio
	oClone:cFim                 := ::cFim
	oClone:cInicioDescarga      := ::cInicioDescarga
	oClone:cFimDescarga         := ::cFimDescarga
	oClone:nCodigoStatus        := ::nCodigoStatus
	oClone:cStatus              := ::cStatus
	oClone:oWSAnomalias         := IIF(::oWSAnomalias = NIL , NIL , ::oWSAnomalias:Clone() )
	oClone:oWSEntregas          := IIF(::oWSEntregas = NIL , NIL , ::oWSEntregas:Clone() )
	oClone:oWSColetas           := IIF(::oWSColetas = NIL , NIL , ::oWSColetas:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT sivirafullWebService_RetornoViagem
	Local oNode13
	Local oNode14
	Local oNode15
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::nIdViagem          :=  WSAdvValue( oResponse,"_IDVIAGEM","int",NIL,"Property nIdViagem as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cIdentificador     :=  WSAdvValue( oResponse,"_IDENTIFICADOR","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nIdEmbarcador      :=  WSAdvValue( oResponse,"_IDEMBARCADOR","int",NIL,"Property nIdEmbarcador as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cCnpjUnidade       :=  WSAdvValue( oResponse,"_CNPJUNIDADE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nIdUnidade         :=  WSAdvValue( oResponse,"_IDUNIDADE","int",NIL,"Property nIdUnidade as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cPlaca             :=  WSAdvValue( oResponse,"_PLACA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cInicio            :=  WSAdvValue( oResponse,"_INICIO","dateTime",NIL,"Property cInicio as s:dateTime on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cFim               :=  WSAdvValue( oResponse,"_FIM","dateTime",NIL,"Property cFim as s:dateTime on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cInicioDescarga    :=  WSAdvValue( oResponse,"_INICIODESCARGA","dateTime",NIL,"Property cInicioDescarga as s:dateTime on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cFimDescarga       :=  WSAdvValue( oResponse,"_FIMDESCARGA","dateTime",NIL,"Property cFimDescarga as s:dateTime on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::nCodigoStatus      :=  WSAdvValue( oResponse,"_CODIGOSTATUS","int",NIL,"Property nCodigoStatus as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cStatus            :=  WSAdvValue( oResponse,"_STATUS","string",NIL,NIL,NIL,"S",NIL,NIL) 
	oNode13 :=  WSAdvValue( oResponse,"_ANOMALIAS","ArrayOfRetornoAnomalia",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode13 != NIL
		::oWSAnomalias := sivirafullWebService_ArrayOfRetornoAnomalia():New()
		::oWSAnomalias:SoapRecv(oNode13)
	EndIf
	oNode14 :=  WSAdvValue( oResponse,"_ENTREGAS","ArrayOfRetornoEntrega",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode14 != NIL
		::oWSEntregas := sivirafullWebService_ArrayOfRetornoEntrega():New()
		::oWSEntregas:SoapRecv(oNode14)
	EndIf
	oNode15 :=  WSAdvValue( oResponse,"_COLETAS","ArrayOfRetornoColeta",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode15 != NIL
		::oWSColetas := sivirafullWebService_ArrayOfRetornoColeta():New()
		::oWSColetas:SoapRecv(oNode15)
	EndIf
Return

// WSDL Data Structure Pessoa

WSSTRUCT sivirafullWebService_Pessoa
	WSDATA   cCargo                    AS string OPTIONAL
	WSDATA   cCelular                  AS string OPTIONAL
	WSDATA   cCodigo                   AS string OPTIONAL
	WSDATA   cEmail                    AS string OPTIONAL
	WSDATA   cFone                     AS string OPTIONAL
	WSDATA   cNome                     AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT sivirafullWebService_Pessoa
	::Init()
Return Self

WSMETHOD INIT WSCLIENT sivirafullWebService_Pessoa
Return

WSMETHOD CLONE WSCLIENT sivirafullWebService_Pessoa
	Local oClone := sivirafullWebService_Pessoa():NEW()
	oClone:cCargo               := ::cCargo
	oClone:cCelular             := ::cCelular
	oClone:cCodigo              := ::cCodigo
	oClone:cEmail               := ::cEmail
	oClone:cFone                := ::cFone
	oClone:cNome                := ::cNome
Return oClone

WSMETHOD SOAPSEND WSCLIENT sivirafullWebService_Pessoa
	Local cSoap := ""
	cSoap += WSSoapValue("Cargo", ::cCargo, ::cCargo , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Celular", ::cCelular, ::cCelular , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Codigo", ::cCodigo, ::cCodigo , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Email", ::cEmail, ::cEmail , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Fone", ::cFone, ::cFone , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Nome", ::cNome, ::cNome , "string", .F. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

// WSDL Data Structure Motorista

WSSTRUCT sivirafullWebService_Motorista
	WSDATA   cApelido                  AS string OPTIONAL
	WSDATA   cNome                     AS string OPTIONAL
	WSDATA   cEndereco                 AS string OPTIONAL
	WSDATA   cComplemento              AS string OPTIONAL
	WSDATA   cCep                      AS string OPTIONAL
	WSDATA   cCidade                   AS string OPTIONAL
	WSDATA   cEstado                   AS string OPTIONAL
	WSDATA   cRG                       AS string OPTIONAL
	WSDATA   cCPF                      AS string OPTIONAL
	WSDATA   cCNH                      AS string OPTIONAL
	WSDATA   cCategoria                AS string OPTIONAL
	WSDATA   cTelefoneCasa             AS string OPTIONAL
	WSDATA   cCelular                  AS string OPTIONAL
	WSDATA   cEmail                    AS string OPTIONAL
	WSDATA   cDataAdmissao             AS dateTime
	WSDATA   cDataDemissao             AS dateTime
	WSDATA   lAtivo                    AS boolean
	WSDATA   cLicencaMotoristaVencimento AS dateTime
	WSDATA   cDataLicenca              AS dateTime
	WSDATA   cNomePai                  AS string OPTIONAL
	WSDATA   cNomeMae                  AS string OPTIONAL
	WSDATA   nTempoServico             AS int
	WSDATA   cDataValidadeCNH          AS dateTime
	WSDATA   cTelefoneTrabalho         AS string OPTIONAL
	WSDATA   cCnpjTransportadora       AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT sivirafullWebService_Motorista
	::Init()
Return Self

WSMETHOD INIT WSCLIENT sivirafullWebService_Motorista
Return

WSMETHOD CLONE WSCLIENT sivirafullWebService_Motorista
	Local oClone := sivirafullWebService_Motorista():NEW()
	oClone:cApelido             := ::cApelido
	oClone:cNome                := ::cNome
	oClone:cEndereco            := ::cEndereco
	oClone:cComplemento         := ::cComplemento
	oClone:cCep                 := ::cCep
	oClone:cCidade              := ::cCidade
	oClone:cEstado              := ::cEstado
	oClone:cRG                  := ::cRG
	oClone:cCPF                 := ::cCPF
	oClone:cCNH                 := ::cCNH
	oClone:cCategoria           := ::cCategoria
	oClone:cTelefoneCasa        := ::cTelefoneCasa
	oClone:cCelular             := ::cCelular
	oClone:cEmail               := ::cEmail
	oClone:cDataAdmissao        := ::cDataAdmissao
	oClone:cDataDemissao        := ::cDataDemissao
	oClone:lAtivo               := ::lAtivo
	oClone:cLicencaMotoristaVencimento := ::cLicencaMotoristaVencimento
	oClone:cDataLicenca         := ::cDataLicenca
	oClone:cNomePai             := ::cNomePai
	oClone:cNomeMae             := ::cNomeMae
	oClone:nTempoServico        := ::nTempoServico
	oClone:cDataValidadeCNH     := ::cDataValidadeCNH
	oClone:cTelefoneTrabalho    := ::cTelefoneTrabalho
	oClone:cCnpjTransportadora  := ::cCnpjTransportadora
Return oClone

WSMETHOD SOAPSEND WSCLIENT sivirafullWebService_Motorista
	Local cSoap := ""
	cSoap += WSSoapValue("Apelido", ::cApelido, ::cApelido , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Nome", ::cNome, ::cNome , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Endereco", ::cEndereco, ::cEndereco , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Complemento", ::cComplemento, ::cComplemento , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Cep", ::cCep, ::cCep , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Cidade", ::cCidade, ::cCidade , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Estado", ::cEstado, ::cEstado , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("RG", ::cRG, ::cRG , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CPF", ::cCPF, ::cCPF , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CNH", ::cCNH, ::cCNH , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Categoria", ::cCategoria, ::cCategoria , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("TelefoneCasa", ::cTelefoneCasa, ::cTelefoneCasa , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Celular", ::cCelular, ::cCelular , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Email", ::cEmail, ::cEmail , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("DataAdmissao", ::cDataAdmissao, ::cDataAdmissao , "dateTime", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("DataDemissao", ::cDataDemissao, ::cDataDemissao , "dateTime", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Ativo", ::lAtivo, ::lAtivo , "boolean", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("LicencaMotoristaVencimento", ::cLicencaMotoristaVencimento, ::cLicencaMotoristaVencimento , "dateTime", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("DataLicenca", ::cDataLicenca, ::cDataLicenca , "dateTime", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("NomePai", ::cNomePai, ::cNomePai , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("NomeMae", ::cNomeMae, ::cNomeMae , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("TempoServico", ::nTempoServico, ::nTempoServico , "int", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("DataValidadeCNH", ::cDataValidadeCNH, ::cDataValidadeCNH , "dateTime", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("TelefoneTrabalho", ::cTelefoneTrabalho, ::cTelefoneTrabalho , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CnpjTransportadora", ::cCnpjTransportadora, ::cCnpjTransportadora , "string", .F. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

// WSDL Data Structure Veiculo

WSSTRUCT sivirafullWebService_Veiculo
	WSDATA   cNomeMotorista            AS string OPTIONAL
	WSDATA   cPlaca                    AS string OPTIONAL
	WSDATA   nTipoVeiculo              AS int
	WSDATA   cModelo                   AS string OPTIONAL
	WSDATA   nAnoModelo                AS int
	WSDATA   nAnoFabricacao            AS int
	WSDATA   nOdometroInicial          AS decimal
	WSDATA   cObservacao               AS string OPTIONAL
	WSDATA   cFrota                    AS string OPTIONAL
	WSDATA   cCnpjTransportadora       AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT sivirafullWebService_Veiculo
	::Init()
Return Self

WSMETHOD INIT WSCLIENT sivirafullWebService_Veiculo
Return

WSMETHOD CLONE WSCLIENT sivirafullWebService_Veiculo
	Local oClone := sivirafullWebService_Veiculo():NEW()
	oClone:cNomeMotorista       := ::cNomeMotorista
	oClone:cPlaca               := ::cPlaca
	oClone:nTipoVeiculo         := ::nTipoVeiculo
	oClone:cModelo              := ::cModelo
	oClone:nAnoModelo           := ::nAnoModelo
	oClone:nAnoFabricacao       := ::nAnoFabricacao
	oClone:nOdometroInicial     := ::nOdometroInicial
	oClone:cObservacao          := ::cObservacao
	oClone:cFrota               := ::cFrota
	oClone:cCnpjTransportadora  := ::cCnpjTransportadora
Return oClone

WSMETHOD SOAPSEND WSCLIENT sivirafullWebService_Veiculo
	Local cSoap := ""
	cSoap += WSSoapValue("NomeMotorista", ::cNomeMotorista, ::cNomeMotorista , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Placa", ::cPlaca, ::cPlaca , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("TipoVeiculo", ::nTipoVeiculo, ::nTipoVeiculo , "int", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Modelo", ::cModelo, ::cModelo , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("AnoModelo", ::nAnoModelo, ::nAnoModelo , "int", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("AnoFabricacao", ::nAnoFabricacao, ::nAnoFabricacao , "int", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("OdometroInicial", ::nOdometroInicial, ::nOdometroInicial , "decimal", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Observacao", ::cObservacao, ::cObservacao , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Frota", ::cFrota, ::cFrota , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CnpjTransportadora", ::cCnpjTransportadora, ::cCnpjTransportadora , "string", .F. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

// WSDL Data Structure Cliente

WSSTRUCT sivirafullWebService_Cliente
	WSDATA   cCodigo                   AS string OPTIONAL
	WSDATA   cTipoPessoa               AS string OPTIONAL
	WSDATA   cCNPJCPF                  AS string OPTIONAL
	WSDATA   cRGInscricao              AS string OPTIONAL
	WSDATA   cNome                     AS string OPTIONAL
	WSDATA   cRazaoSocial              AS string OPTIONAL
	WSDATA   cTelefone                 AS string OPTIONAL
	WSDATA   cEmail                    AS string OPTIONAL
	WSDATA   cResponsavel              AS string OPTIONAL
	WSDATA   cEndereco                 AS string OPTIONAL
	WSDATA   cComplemento              AS string OPTIONAL
	WSDATA   cBairro                   AS string OPTIONAL
	WSDATA   cCidade                   AS string OPTIONAL
	WSDATA   cEstado                   AS string OPTIONAL
	WSDATA   cPais                     AS string OPTIONAL
	WSDATA   cCep                      AS string OPTIONAL
	WSDATA   nLatitude                 AS decimal
	WSDATA   nLongitude                AS decimal
	WSDATA   nRaioEntrega              AS decimal
	WSDATA   nTempoEntrega             AS int
	WSDATA   cRegiao                   AS string OPTIONAL
	WSDATA   cPreRota                  AS string OPTIONAL
	WSDATA   cNegocio                  AS string OPTIONAL
	WSDATA   cCodigoTabelaFrete        AS string OPTIONAL
	WSDATA   oWSGradeAtendimento       AS sivirafullWebService_JanelaAtendimento OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT sivirafullWebService_Cliente
	::Init()
Return Self

WSMETHOD INIT WSCLIENT sivirafullWebService_Cliente
Return

WSMETHOD CLONE WSCLIENT sivirafullWebService_Cliente
	Local oClone := sivirafullWebService_Cliente():NEW()
	oClone:cCodigo              := ::cCodigo
	oClone:cTipoPessoa          := ::cTipoPessoa
	oClone:cCNPJCPF             := ::cCNPJCPF
	oClone:cRGInscricao         := ::cRGInscricao
	oClone:cNome                := ::cNome
	oClone:cRazaoSocial         := ::cRazaoSocial
	oClone:cTelefone            := ::cTelefone
	oClone:cEmail               := ::cEmail
	oClone:cResponsavel         := ::cResponsavel
	oClone:cEndereco            := ::cEndereco
	oClone:cComplemento         := ::cComplemento
	oClone:cBairro              := ::cBairro
	oClone:cCidade              := ::cCidade
	oClone:cEstado              := ::cEstado
	oClone:cPais                := ::cPais
	oClone:cCep                 := ::cCep
	oClone:nLatitude            := ::nLatitude
	oClone:nLongitude           := ::nLongitude
	oClone:nRaioEntrega         := ::nRaioEntrega
	oClone:nTempoEntrega        := ::nTempoEntrega
	oClone:cRegiao              := ::cRegiao
	oClone:cPreRota             := ::cPreRota
	oClone:cNegocio             := ::cNegocio
	oClone:cCodigoTabelaFrete   := ::cCodigoTabelaFrete
	oClone:oWSGradeAtendimento  := IIF(::oWSGradeAtendimento = NIL , NIL , ::oWSGradeAtendimento:Clone() )
Return oClone

WSMETHOD SOAPSEND WSCLIENT sivirafullWebService_Cliente
	Local cSoap := ""
	cSoap += WSSoapValue("Codigo", ::cCodigo, ::cCodigo , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("TipoPessoa", ::cTipoPessoa, ::cTipoPessoa , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CNPJCPF", ::cCNPJCPF, ::cCNPJCPF , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("RGInscricao", ::cRGInscricao, ::cRGInscricao , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Nome", ::cNome, ::cNome , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("RazaoSocial", ::cRazaoSocial, ::cRazaoSocial , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Telefone", ::cTelefone, ::cTelefone , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Email", ::cEmail, ::cEmail , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Responsavel", ::cResponsavel, ::cResponsavel , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Endereco", ::cEndereco, ::cEndereco , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Complemento", ::cComplemento, ::cComplemento , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Bairro", ::cBairro, ::cBairro , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Cidade", ::cCidade, ::cCidade , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Estado", ::cEstado, ::cEstado , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Pais", ::cPais, ::cPais , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Cep", ::cCep, ::cCep , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Latitude", ::nLatitude, ::nLatitude , "decimal", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Longitude", ::nLongitude, ::nLongitude , "decimal", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("RaioEntrega", ::nRaioEntrega, ::nRaioEntrega , "decimal", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("TempoEntrega", ::nTempoEntrega, ::nTempoEntrega , "int", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Regiao", ::cRegiao, ::cRegiao , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("PreRota", ::cPreRota, ::cPreRota , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Negocio", ::cNegocio, ::cNegocio , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CodigoTabelaFrete", ::cCodigoTabelaFrete, ::cCodigoTabelaFrete , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("GradeAtendimento", ::oWSGradeAtendimento, ::oWSGradeAtendimento , "JanelaAtendimento", .F. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

// WSDL Data Structure Transportadora

WSSTRUCT sivirafullWebService_Transportadora
	WSDATA   cNome                     AS string OPTIONAL
	WSDATA   cNomeFantasia             AS string OPTIONAL
	WSDATA   cCNPJ                     AS string OPTIONAL
	WSDATA   cEndereco                 AS string OPTIONAL
	WSDATA   cComplemento              AS string OPTIONAL
	WSDATA   cCEP                      AS string OPTIONAL
	WSDATA   cCidade                   AS string OPTIONAL
	WSDATA   cEstado                   AS string OPTIONAL
	WSDATA   cFone                     AS string OPTIONAL
	WSDATA   cFax                      AS string OPTIONAL
	WSDATA   cCelular                  AS string OPTIONAL
	WSDATA   cFone2                    AS string OPTIONAL
	WSDATA   cEmail                    AS string OPTIONAL
	WSDATA   cSkype                    AS string OPTIONAL
	WSDATA   cEmail2                   AS string OPTIONAL
	WSDATA   cEmailsPanico             AS string OPTIONAL
	WSDATA   cObservacoes              AS string OPTIONAL
	WSDATA   cWebsite                  AS string OPTIONAL
	WSDATA   lUnidade                  AS boolean
	WSDATA   lCooperativa              AS boolean
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT sivirafullWebService_Transportadora
	::Init()
Return Self

WSMETHOD INIT WSCLIENT sivirafullWebService_Transportadora
Return

WSMETHOD CLONE WSCLIENT sivirafullWebService_Transportadora
	Local oClone := sivirafullWebService_Transportadora():NEW()
	oClone:cNome                := ::cNome
	oClone:cNomeFantasia        := ::cNomeFantasia
	oClone:cCNPJ                := ::cCNPJ
	oClone:cEndereco            := ::cEndereco
	oClone:cComplemento         := ::cComplemento
	oClone:cCEP                 := ::cCEP
	oClone:cCidade              := ::cCidade
	oClone:cEstado              := ::cEstado
	oClone:cFone                := ::cFone
	oClone:cFax                 := ::cFax
	oClone:cCelular             := ::cCelular
	oClone:cFone2               := ::cFone2
	oClone:cEmail               := ::cEmail
	oClone:cSkype               := ::cSkype
	oClone:cEmail2              := ::cEmail2
	oClone:cEmailsPanico        := ::cEmailsPanico
	oClone:cObservacoes         := ::cObservacoes
	oClone:cWebsite             := ::cWebsite
	oClone:lUnidade             := ::lUnidade
	oClone:lCooperativa         := ::lCooperativa
Return oClone

WSMETHOD SOAPSEND WSCLIENT sivirafullWebService_Transportadora
	Local cSoap := ""
	cSoap += WSSoapValue("Nome", ::cNome, ::cNome , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("NomeFantasia", ::cNomeFantasia, ::cNomeFantasia , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CNPJ", ::cCNPJ, ::cCNPJ , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Endereco", ::cEndereco, ::cEndereco , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Complemento", ::cComplemento, ::cComplemento , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CEP", ::cCEP, ::cCEP , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Cidade", ::cCidade, ::cCidade , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Estado", ::cEstado, ::cEstado , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Fone", ::cFone, ::cFone , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Fax", ::cFax, ::cFax , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Celular", ::cCelular, ::cCelular , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Fone2", ::cFone2, ::cFone2 , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Email", ::cEmail, ::cEmail , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Skype", ::cSkype, ::cSkype , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Email2", ::cEmail2, ::cEmail2 , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("EmailsPanico", ::cEmailsPanico, ::cEmailsPanico , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Observacoes", ::cObservacoes, ::cObservacoes , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Website", ::cWebsite, ::cWebsite , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Unidade", ::lUnidade, ::lUnidade , "boolean", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Cooperativa", ::lCooperativa, ::lCooperativa , "boolean", .T. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

// WSDL Data Structure Produto

WSSTRUCT sivirafullWebService_Produto
	WSDATA   cCodigo                   AS string OPTIONAL
	WSDATA   cDescricao                AS string OPTIONAL
	WSDATA   nPeso                     AS decimal
	WSDATA   nCubagem                  AS decimal
	WSDATA   nValor                    AS decimal
	WSDATA   cUnidade                  AS string OPTIONAL
	WSDATA   nStatus                   AS int
	WSDATA   cAclimatacao              AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT sivirafullWebService_Produto
	::Init()
Return Self

WSMETHOD INIT WSCLIENT sivirafullWebService_Produto
Return

WSMETHOD CLONE WSCLIENT sivirafullWebService_Produto
	Local oClone := sivirafullWebService_Produto():NEW()
	oClone:cCodigo              := ::cCodigo
	oClone:cDescricao           := ::cDescricao
	oClone:nPeso                := ::nPeso
	oClone:nCubagem             := ::nCubagem
	oClone:nValor               := ::nValor
	oClone:cUnidade             := ::cUnidade
	oClone:nStatus              := ::nStatus
	oClone:cAclimatacao         := ::cAclimatacao
Return oClone

WSMETHOD SOAPSEND WSCLIENT sivirafullWebService_Produto
	Local cSoap := ""
	cSoap += WSSoapValue("Codigo", ::cCodigo, ::cCodigo , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Descricao", ::cDescricao, ::cDescricao , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Peso", ::nPeso, ::nPeso , "decimal", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Cubagem", ::nCubagem, ::nCubagem , "decimal", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Valor", ::nValor, ::nValor , "decimal", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Unidade", ::cUnidade, ::cUnidade , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Status", ::nStatus, ::nStatus , "int", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Aclimatacao", ::cAclimatacao, ::cAclimatacao , "string", .F. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

// WSDL Data Structure ArrayOfRetornoDevolucao

WSSTRUCT sivirafullWebService_ArrayOfRetornoDevolucao
	WSDATA   oWSRetornoDevolucao       AS sivirafullWebService_RetornoDevolucao OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT sivirafullWebService_ArrayOfRetornoDevolucao
	::Init()
Return Self

WSMETHOD INIT WSCLIENT sivirafullWebService_ArrayOfRetornoDevolucao
	::oWSRetornoDevolucao  := {} // Array Of  sivirafullWebService_RETORNODEVOLUCAO():New()
Return

WSMETHOD CLONE WSCLIENT sivirafullWebService_ArrayOfRetornoDevolucao
	Local oClone := sivirafullWebService_ArrayOfRetornoDevolucao():NEW()
	oClone:oWSRetornoDevolucao := NIL
	If ::oWSRetornoDevolucao <> NIL 
		oClone:oWSRetornoDevolucao := {}
		aEval( ::oWSRetornoDevolucao , { |x| aadd( oClone:oWSRetornoDevolucao , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT sivirafullWebService_ArrayOfRetornoDevolucao
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_RETORNODEVOLUCAO","RetornoDevolucao",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSRetornoDevolucao , sivirafullWebService_RetornoDevolucao():New() )
			::oWSRetornoDevolucao[len(::oWSRetornoDevolucao)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ArrayOfIndicadores

WSSTRUCT sivirafullWebService_ArrayOfIndicadores
	WSDATA   oWSIndicadores            AS sivirafullWebService_Indicadores OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT sivirafullWebService_ArrayOfIndicadores
	::Init()
Return Self

WSMETHOD INIT WSCLIENT sivirafullWebService_ArrayOfIndicadores
	::oWSIndicadores       := {} // Array Of  sivirafullWebService_INDICADORES():New()
Return

WSMETHOD CLONE WSCLIENT sivirafullWebService_ArrayOfIndicadores
	Local oClone := sivirafullWebService_ArrayOfIndicadores():NEW()
	oClone:oWSIndicadores := NIL
	If ::oWSIndicadores <> NIL 
		oClone:oWSIndicadores := {}
		aEval( ::oWSIndicadores , { |x| aadd( oClone:oWSIndicadores , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT sivirafullWebService_ArrayOfIndicadores
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_INDICADORES","Indicadores",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSIndicadores , sivirafullWebService_Indicadores():New() )
			::oWSIndicadores[len(::oWSIndicadores)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure RoteiroViagem

WSSTRUCT sivirafullWebService_RoteiroViagem
	WSDATA   cIdentificador            AS string OPTIONAL
	WSDATA   cPlaca                    AS string OPTIONAL
	WSDATA   oWSCoordenadas            AS sivirafullWebService_ArrayOfCoordenadaRoteiro OPTIONAL
	WSDATA   cObservacoes              AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT sivirafullWebService_RoteiroViagem
	::Init()
Return Self

WSMETHOD INIT WSCLIENT sivirafullWebService_RoteiroViagem
Return

WSMETHOD CLONE WSCLIENT sivirafullWebService_RoteiroViagem
	Local oClone := sivirafullWebService_RoteiroViagem():NEW()
	oClone:cIdentificador       := ::cIdentificador
	oClone:cPlaca               := ::cPlaca
	oClone:oWSCoordenadas       := IIF(::oWSCoordenadas = NIL , NIL , ::oWSCoordenadas:Clone() )
	oClone:cObservacoes         := ::cObservacoes
Return oClone

WSMETHOD SOAPSEND WSCLIENT sivirafullWebService_RoteiroViagem
	Local cSoap := ""
	cSoap += WSSoapValue("Identificador", ::cIdentificador, ::cIdentificador , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Placa", ::cPlaca, ::cPlaca , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Coordenadas", ::oWSCoordenadas, ::oWSCoordenadas , "ArrayOfCoordenadaRoteiro", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Observacoes", ::cObservacoes, ::cObservacoes , "string", .F. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

// WSDL Data Structure ArrayOfAnomalia

WSSTRUCT sivirafullWebService_ArrayOfAnomalia
	WSDATA   oWSAnomalia               AS sivirafullWebService_Anomalia OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT sivirafullWebService_ArrayOfAnomalia
	::Init()
Return Self

WSMETHOD INIT WSCLIENT sivirafullWebService_ArrayOfAnomalia
	::oWSAnomalia          := {} // Array Of  sivirafullWebService_ANOMALIA():New()
Return

WSMETHOD CLONE WSCLIENT sivirafullWebService_ArrayOfAnomalia
	Local oClone := sivirafullWebService_ArrayOfAnomalia():NEW()
	oClone:oWSAnomalia := NIL
	If ::oWSAnomalia <> NIL 
		oClone:oWSAnomalia := {}
		aEval( ::oWSAnomalia , { |x| aadd( oClone:oWSAnomalia , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT sivirafullWebService_ArrayOfAnomalia
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_ANOMALIA","Anomalia",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSAnomalia , sivirafullWebService_Anomalia():New() )
			::oWSAnomalia[len(::oWSAnomalia)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ArrayOfNotaEntregue

WSSTRUCT sivirafullWebService_ArrayOfNotaEntregue
	WSDATA   oWSNotaEntregue           AS sivirafullWebService_NotaEntregue OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT sivirafullWebService_ArrayOfNotaEntregue
	::Init()
Return Self

WSMETHOD INIT WSCLIENT sivirafullWebService_ArrayOfNotaEntregue
	::oWSNotaEntregue      := {} // Array Of  sivirafullWebService_NOTAENTREGUE():New()
Return

WSMETHOD CLONE WSCLIENT sivirafullWebService_ArrayOfNotaEntregue
	Local oClone := sivirafullWebService_ArrayOfNotaEntregue():NEW()
	oClone:oWSNotaEntregue := NIL
	If ::oWSNotaEntregue <> NIL 
		oClone:oWSNotaEntregue := {}
		aEval( ::oWSNotaEntregue , { |x| aadd( oClone:oWSNotaEntregue , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT sivirafullWebService_ArrayOfNotaEntregue
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_NOTAENTREGUE","NotaEntregue",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSNotaEntregue , sivirafullWebService_NotaEntregue():New() )
			::oWSNotaEntregue[len(::oWSNotaEntregue)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ViagemRetorno

WSSTRUCT sivirafullWebService_ViagemRetorno
	WSDATA   nIdViagem                 AS int
	WSDATA   cIdentificador            AS string OPTIONAL
	WSDATA   nIdEmbarcador             AS int
	WSDATA   cCnpjUnidade              AS string OPTIONAL
	WSDATA   nIdUnidade                AS int
	WSDATA   cPlaca                    AS string OPTIONAL
	WSDATA   cInicio                   AS dateTime
	WSDATA   cFim                      AS dateTime
	WSDATA   nCodigoStatus             AS int
	WSDATA   cStatus                   AS string OPTIONAL
	WSDATA   cInicioDescarga           AS dateTime
	WSDATA   cFimDescarga              AS dateTime
	WSDATA   cMotivo                   AS string OPTIONAL
	WSDATA   cCodigoMotivo             AS string OPTIONAL
	WSDATA   cDataPernoite             AS dateTime
	WSDATA   cDataAprovacaoPernoite    AS dateTime
	WSDATA   nQdtePernoites            AS int
	WSDATA   nQdteTripulantes          AS int
	WSDATA   cCnpjTransportador        AS string OPTIONAL
	WSDATA   cTransportador            AS string OPTIONAL
	WSDATA   cResponsavelUnidade       AS string OPTIONAL
	WSDATA   oWSAnomalias              AS sivirafullWebService_ArrayOfRetornoAnomalia OPTIONAL
	WSDATA   oWSEntregas               AS sivirafullWebService_ArrayOfRetornoEntrega OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT sivirafullWebService_ViagemRetorno
	::Init()
Return Self

WSMETHOD INIT WSCLIENT sivirafullWebService_ViagemRetorno
Return

WSMETHOD CLONE WSCLIENT sivirafullWebService_ViagemRetorno
	Local oClone := sivirafullWebService_ViagemRetorno():NEW()
	oClone:nIdViagem            := ::nIdViagem
	oClone:cIdentificador       := ::cIdentificador
	oClone:nIdEmbarcador        := ::nIdEmbarcador
	oClone:cCnpjUnidade         := ::cCnpjUnidade
	oClone:nIdUnidade           := ::nIdUnidade
	oClone:cPlaca               := ::cPlaca
	oClone:cInicio              := ::cInicio
	oClone:cFim                 := ::cFim
	oClone:nCodigoStatus        := ::nCodigoStatus
	oClone:cStatus              := ::cStatus
	oClone:cInicioDescarga      := ::cInicioDescarga
	oClone:cFimDescarga         := ::cFimDescarga
	oClone:cMotivo              := ::cMotivo
	oClone:cCodigoMotivo        := ::cCodigoMotivo
	oClone:cDataPernoite        := ::cDataPernoite
	oClone:cDataAprovacaoPernoite := ::cDataAprovacaoPernoite
	oClone:nQdtePernoites       := ::nQdtePernoites
	oClone:nQdteTripulantes     := ::nQdteTripulantes
	oClone:cCnpjTransportador   := ::cCnpjTransportador
	oClone:cTransportador       := ::cTransportador
	oClone:cResponsavelUnidade  := ::cResponsavelUnidade
	oClone:oWSAnomalias         := IIF(::oWSAnomalias = NIL , NIL , ::oWSAnomalias:Clone() )
	oClone:oWSEntregas          := IIF(::oWSEntregas = NIL , NIL , ::oWSEntregas:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT sivirafullWebService_ViagemRetorno
	Local oNode22
	Local oNode23
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::nIdViagem          :=  WSAdvValue( oResponse,"_IDVIAGEM","int",NIL,"Property nIdViagem as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cIdentificador     :=  WSAdvValue( oResponse,"_IDENTIFICADOR","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nIdEmbarcador      :=  WSAdvValue( oResponse,"_IDEMBARCADOR","int",NIL,"Property nIdEmbarcador as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cCnpjUnidade       :=  WSAdvValue( oResponse,"_CNPJUNIDADE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nIdUnidade         :=  WSAdvValue( oResponse,"_IDUNIDADE","int",NIL,"Property nIdUnidade as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cPlaca             :=  WSAdvValue( oResponse,"_PLACA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cInicio            :=  WSAdvValue( oResponse,"_INICIO","dateTime",NIL,"Property cInicio as s:dateTime on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cFim               :=  WSAdvValue( oResponse,"_FIM","dateTime",NIL,"Property cFim as s:dateTime on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::nCodigoStatus      :=  WSAdvValue( oResponse,"_CODIGOSTATUS","int",NIL,"Property nCodigoStatus as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cStatus            :=  WSAdvValue( oResponse,"_STATUS","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cInicioDescarga    :=  WSAdvValue( oResponse,"_INICIODESCARGA","dateTime",NIL,"Property cInicioDescarga as s:dateTime on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cFimDescarga       :=  WSAdvValue( oResponse,"_FIMDESCARGA","dateTime",NIL,"Property cFimDescarga as s:dateTime on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cMotivo            :=  WSAdvValue( oResponse,"_MOTIVO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cCodigoMotivo      :=  WSAdvValue( oResponse,"_CODIGOMOTIVO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cDataPernoite      :=  WSAdvValue( oResponse,"_DATAPERNOITE","dateTime",NIL,"Property cDataPernoite as s:dateTime on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cDataAprovacaoPernoite :=  WSAdvValue( oResponse,"_DATAAPROVACAOPERNOITE","dateTime",NIL,"Property cDataAprovacaoPernoite as s:dateTime on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::nQdtePernoites     :=  WSAdvValue( oResponse,"_QDTEPERNOITES","int",NIL,"Property nQdtePernoites as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nQdteTripulantes   :=  WSAdvValue( oResponse,"_QDTETRIPULANTES","int",NIL,"Property nQdteTripulantes as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cCnpjTransportador :=  WSAdvValue( oResponse,"_CNPJTRANSPORTADOR","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cTransportador     :=  WSAdvValue( oResponse,"_TRANSPORTADOR","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cResponsavelUnidade :=  WSAdvValue( oResponse,"_RESPONSAVELUNIDADE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	oNode22 :=  WSAdvValue( oResponse,"_ANOMALIAS","ArrayOfRetornoAnomalia",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode22 != NIL
		::oWSAnomalias := sivirafullWebService_ArrayOfRetornoAnomalia():New()
		::oWSAnomalias:SoapRecv(oNode22)
	EndIf
	oNode23 :=  WSAdvValue( oResponse,"_ENTREGAS","ArrayOfRetornoEntrega",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode23 != NIL
		::oWSEntregas := sivirafullWebService_ArrayOfRetornoEntrega():New()
		::oWSEntregas:SoapRecv(oNode23)
	EndIf
Return

// WSDL Data Structure ArrayOfRetornoCustoAdicional

WSSTRUCT sivirafullWebService_ArrayOfRetornoCustoAdicional
	WSDATA   oWSRetornoCustoAdicional  AS sivirafullWebService_RetornoCustoAdicional OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT sivirafullWebService_ArrayOfRetornoCustoAdicional
	::Init()
Return Self

WSMETHOD INIT WSCLIENT sivirafullWebService_ArrayOfRetornoCustoAdicional
	::oWSRetornoCustoAdicional := {} // Array Of  sivirafullWebService_RETORNOCUSTOADICIONAL():New()
Return

WSMETHOD CLONE WSCLIENT sivirafullWebService_ArrayOfRetornoCustoAdicional
	Local oClone := sivirafullWebService_ArrayOfRetornoCustoAdicional():NEW()
	oClone:oWSRetornoCustoAdicional := NIL
	If ::oWSRetornoCustoAdicional <> NIL 
		oClone:oWSRetornoCustoAdicional := {}
		aEval( ::oWSRetornoCustoAdicional , { |x| aadd( oClone:oWSRetornoCustoAdicional , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT sivirafullWebService_ArrayOfRetornoCustoAdicional
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_RETORNOCUSTOADICIONAL","RetornoCustoAdicional",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSRetornoCustoAdicional , sivirafullWebService_RetornoCustoAdicional():New() )
			::oWSRetornoCustoAdicional[len(::oWSRetornoCustoAdicional)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ArrayOfRetornoAlteracaoValorModalidade

WSSTRUCT sivirafullWebService_ArrayOfRetornoAlteracaoValorModalidade
	WSDATA   oWSRetornoAlteracaoValorModalidade AS sivirafullWebService_RetornoAlteracaoValorModalidade OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT sivirafullWebService_ArrayOfRetornoAlteracaoValorModalidade
	::Init()
Return Self

WSMETHOD INIT WSCLIENT sivirafullWebService_ArrayOfRetornoAlteracaoValorModalidade
	::oWSRetornoAlteracaoValorModalidade := {} // Array Of  sivirafullWebService_RETORNOALTERACAOVALORMODALIDADE():New()
Return

WSMETHOD CLONE WSCLIENT sivirafullWebService_ArrayOfRetornoAlteracaoValorModalidade
	Local oClone := sivirafullWebService_ArrayOfRetornoAlteracaoValorModalidade():NEW()
	oClone:oWSRetornoAlteracaoValorModalidade := NIL
	If ::oWSRetornoAlteracaoValorModalidade <> NIL 
		oClone:oWSRetornoAlteracaoValorModalidade := {}
		aEval( ::oWSRetornoAlteracaoValorModalidade , { |x| aadd( oClone:oWSRetornoAlteracaoValorModalidade , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT sivirafullWebService_ArrayOfRetornoAlteracaoValorModalidade
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_RETORNOALTERACAOVALORMODALIDADE","RetornoAlteracaoValorModalidade",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSRetornoAlteracaoValorModalidade , sivirafullWebService_RetornoAlteracaoValorModalidade():New() )
			::oWSRetornoAlteracaoValorModalidade[len(::oWSRetornoAlteracaoValorModalidade)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure RetornoPernoiteAprovada

WSSTRUCT sivirafullWebService_RetornoPernoiteAprovada
	WSDATA   cIdentificador            AS string OPTIONAL
	WSDATA   cCodigoMotivo             AS string OPTIONAL
	WSDATA   cMotivo                   AS string OPTIONAL
	WSDATA   nQdtePernoites            AS int
	WSDATA   nQdteTripulantes          AS int
	WSDATA   cDataPernoite             AS dateTime
	WSDATA   cDataAprovacaoPernoite    AS dateTime
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT sivirafullWebService_RetornoPernoiteAprovada
	::Init()
Return Self

WSMETHOD INIT WSCLIENT sivirafullWebService_RetornoPernoiteAprovada
Return

WSMETHOD CLONE WSCLIENT sivirafullWebService_RetornoPernoiteAprovada
	Local oClone := sivirafullWebService_RetornoPernoiteAprovada():NEW()
	oClone:cIdentificador       := ::cIdentificador
	oClone:cCodigoMotivo        := ::cCodigoMotivo
	oClone:cMotivo              := ::cMotivo
	oClone:nQdtePernoites       := ::nQdtePernoites
	oClone:nQdteTripulantes     := ::nQdteTripulantes
	oClone:cDataPernoite        := ::cDataPernoite
	oClone:cDataAprovacaoPernoite := ::cDataAprovacaoPernoite
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT sivirafullWebService_RetornoPernoiteAprovada
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cIdentificador     :=  WSAdvValue( oResponse,"_IDENTIFICADOR","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cCodigoMotivo      :=  WSAdvValue( oResponse,"_CODIGOMOTIVO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cMotivo            :=  WSAdvValue( oResponse,"_MOTIVO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nQdtePernoites     :=  WSAdvValue( oResponse,"_QDTEPERNOITES","int",NIL,"Property nQdtePernoites as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nQdteTripulantes   :=  WSAdvValue( oResponse,"_QDTETRIPULANTES","int",NIL,"Property nQdteTripulantes as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cDataPernoite      :=  WSAdvValue( oResponse,"_DATAPERNOITE","dateTime",NIL,"Property cDataPernoite as s:dateTime on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cDataAprovacaoPernoite :=  WSAdvValue( oResponse,"_DATAAPROVACAOPERNOITE","dateTime",NIL,"Property cDataAprovacaoPernoite as s:dateTime on SOAP Response not found.",NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure ArrayOfViagemFinalizada

WSSTRUCT sivirafullWebService_ArrayOfViagemFinalizada
	WSDATA   oWSViagemFinalizada       AS sivirafullWebService_ViagemFinalizada OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT sivirafullWebService_ArrayOfViagemFinalizada
	::Init()
Return Self

WSMETHOD INIT WSCLIENT sivirafullWebService_ArrayOfViagemFinalizada
	::oWSViagemFinalizada  := {} // Array Of  sivirafullWebService_VIAGEMFINALIZADA():New()
Return

WSMETHOD CLONE WSCLIENT sivirafullWebService_ArrayOfViagemFinalizada
	Local oClone := sivirafullWebService_ArrayOfViagemFinalizada():NEW()
	oClone:oWSViagemFinalizada := NIL
	If ::oWSViagemFinalizada <> NIL 
		oClone:oWSViagemFinalizada := {}
		aEval( ::oWSViagemFinalizada , { |x| aadd( oClone:oWSViagemFinalizada , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT sivirafullWebService_ArrayOfViagemFinalizada
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_VIAGEMFINALIZADA","ViagemFinalizada",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSViagemFinalizada , sivirafullWebService_ViagemFinalizada():New() )
			::oWSViagemFinalizada[len(::oWSViagemFinalizada)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure StatusVeiculo

WSSTRUCT sivirafullWebService_StatusVeiculo
	WSDATA   cPlaca                    AS string OPTIONAL
	WSDATA   cStatus                   AS string OPTIONAL
	WSDATA   nCodigoStatus             AS int
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT sivirafullWebService_StatusVeiculo
	::Init()
Return Self

WSMETHOD INIT WSCLIENT sivirafullWebService_StatusVeiculo
Return

WSMETHOD CLONE WSCLIENT sivirafullWebService_StatusVeiculo
	Local oClone := sivirafullWebService_StatusVeiculo():NEW()
	oClone:cPlaca               := ::cPlaca
	oClone:cStatus              := ::cStatus
	oClone:nCodigoStatus        := ::nCodigoStatus
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT sivirafullWebService_StatusVeiculo
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cPlaca             :=  WSAdvValue( oResponse,"_PLACA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cStatus            :=  WSAdvValue( oResponse,"_STATUS","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nCodigoStatus      :=  WSAdvValue( oResponse,"_CODIGOSTATUS","int",NIL,"Property nCodigoStatus as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
Return

// WSDL Data Structure ArrayOfPedido

WSSTRUCT sivirafullWebService_ArrayOfPedido
	WSDATA   oWSPedido                 AS sivirafullWebService_Pedido OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT sivirafullWebService_ArrayOfPedido
	::Init()
Return Self

WSMETHOD INIT WSCLIENT sivirafullWebService_ArrayOfPedido
	::oWSPedido            := {} // Array Of  sivirafullWebService_PEDIDO():New()
Return

WSMETHOD CLONE WSCLIENT sivirafullWebService_ArrayOfPedido
	Local oClone := sivirafullWebService_ArrayOfPedido():NEW()
	oClone:oWSPedido := NIL
	If ::oWSPedido <> NIL 
		oClone:oWSPedido := {}
		aEval( ::oWSPedido , { |x| aadd( oClone:oWSPedido , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT sivirafullWebService_ArrayOfPedido
	Local cSoap := ""
	aEval( ::oWSPedido , {|x| cSoap := cSoap  +  WSSoapValue("Pedido", x , x , "Pedido", .F. , .F., 0 , NIL, .F.,.F.)  } ) 
Return cSoap

// WSDL Data Structure FiltroRoteiro

WSSTRUCT sivirafullWebService_FiltroRoteiro
	WSDATA   nIdRoteiro                AS int
	WSDATA   cUnidade                  AS string OPTIONAL
	WSDATA   cPlaca                    AS string OPTIONAL
	WSDATA   lPeriodoEstimativa        AS boolean
	WSDATA   cInicial                  AS dateTime
	WSDATA   cFinal                    AS dateTime
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT sivirafullWebService_FiltroRoteiro
	::Init()
Return Self

WSMETHOD INIT WSCLIENT sivirafullWebService_FiltroRoteiro
Return

WSMETHOD CLONE WSCLIENT sivirafullWebService_FiltroRoteiro
	Local oClone := sivirafullWebService_FiltroRoteiro():NEW()
	oClone:nIdRoteiro           := ::nIdRoteiro
	oClone:cUnidade             := ::cUnidade
	oClone:cPlaca               := ::cPlaca
	oClone:lPeriodoEstimativa   := ::lPeriodoEstimativa
	oClone:cInicial             := ::cInicial
	oClone:cFinal               := ::cFinal
Return oClone

WSMETHOD SOAPSEND WSCLIENT sivirafullWebService_FiltroRoteiro
	Local cSoap := ""
	cSoap += WSSoapValue("IdRoteiro", ::nIdRoteiro, ::nIdRoteiro , "int", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Unidade", ::cUnidade, ::cUnidade , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Placa", ::cPlaca, ::cPlaca , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("PeriodoEstimativa", ::lPeriodoEstimativa, ::lPeriodoEstimativa , "boolean", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Inicial", ::cInicial, ::cInicial , "dateTime", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Final", ::cFinal, ::cFinal , "dateTime", .T. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

// WSDL Data Structure ArrayOfRoteiro

WSSTRUCT sivirafullWebService_ArrayOfRoteiro
	WSDATA   oWSRoteiro                AS sivirafullWebService_Roteiro OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT sivirafullWebService_ArrayOfRoteiro
	::Init()
Return Self

WSMETHOD INIT WSCLIENT sivirafullWebService_ArrayOfRoteiro
	::oWSRoteiro           := {} // Array Of  sivirafullWebService_ROTEIRO():New()
Return

WSMETHOD CLONE WSCLIENT sivirafullWebService_ArrayOfRoteiro
	Local oClone := sivirafullWebService_ArrayOfRoteiro():NEW()
	oClone:oWSRoteiro := NIL
	If ::oWSRoteiro <> NIL 
		oClone:oWSRoteiro := {}
		aEval( ::oWSRoteiro , { |x| aadd( oClone:oWSRoteiro , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT sivirafullWebService_ArrayOfRoteiro
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_ROTEIRO","Roteiro",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSRoteiro , sivirafullWebService_Roteiro():New() )
			::oWSRoteiro[len(::oWSRoteiro)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ArrayOfModalidadeCustoAdicional

WSSTRUCT sivirafullWebService_ArrayOfModalidadeCustoAdicional
	WSDATA   oWSModalidadeCustoAdicional AS sivirafullWebService_ModalidadeCustoAdicional OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT sivirafullWebService_ArrayOfModalidadeCustoAdicional
	::Init()
Return Self

WSMETHOD INIT WSCLIENT sivirafullWebService_ArrayOfModalidadeCustoAdicional
	::oWSModalidadeCustoAdicional := {} // Array Of  sivirafullWebService_MODALIDADECUSTOADICIONAL():New()
Return

WSMETHOD CLONE WSCLIENT sivirafullWebService_ArrayOfModalidadeCustoAdicional
	Local oClone := sivirafullWebService_ArrayOfModalidadeCustoAdicional():NEW()
	oClone:oWSModalidadeCustoAdicional := NIL
	If ::oWSModalidadeCustoAdicional <> NIL 
		oClone:oWSModalidadeCustoAdicional := {}
		aEval( ::oWSModalidadeCustoAdicional , { |x| aadd( oClone:oWSModalidadeCustoAdicional , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT sivirafullWebService_ArrayOfModalidadeCustoAdicional
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_MODALIDADECUSTOADICIONAL","ModalidadeCustoAdicional",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSModalidadeCustoAdicional , sivirafullWebService_ModalidadeCustoAdicional():New() )
			::oWSModalidadeCustoAdicional[len(::oWSModalidadeCustoAdicional)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ArrayOfTipoCustoAdicional

WSSTRUCT sivirafullWebService_ArrayOfTipoCustoAdicional
	WSDATA   oWSTipoCustoAdicional     AS sivirafullWebService_TipoCustoAdicional OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT sivirafullWebService_ArrayOfTipoCustoAdicional
	::Init()
Return Self

WSMETHOD INIT WSCLIENT sivirafullWebService_ArrayOfTipoCustoAdicional
	::oWSTipoCustoAdicional := {} // Array Of  sivirafullWebService_TIPOCUSTOADICIONAL():New()
Return

WSMETHOD CLONE WSCLIENT sivirafullWebService_ArrayOfTipoCustoAdicional
	Local oClone := sivirafullWebService_ArrayOfTipoCustoAdicional():NEW()
	oClone:oWSTipoCustoAdicional := NIL
	If ::oWSTipoCustoAdicional <> NIL 
		oClone:oWSTipoCustoAdicional := {}
		aEval( ::oWSTipoCustoAdicional , { |x| aadd( oClone:oWSTipoCustoAdicional , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT sivirafullWebService_ArrayOfTipoCustoAdicional
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_TIPOCUSTOADICIONAL","TipoCustoAdicional",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSTipoCustoAdicional , sivirafullWebService_TipoCustoAdicional():New() )
			::oWSTipoCustoAdicional[len(::oWSTipoCustoAdicional)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ViagemPlanejada

WSSTRUCT sivirafullWebService_ViagemPlanejada
	WSDATA   nId                       AS int
	WSDATA   cIdentificador            AS string OPTIONAL
	WSDATA   cDataCriacao              AS dateTime
	WSDATA   cDataEstimada             AS dateTime
	WSDATA   cCodigoRota               AS string OPTIONAL
	WSDATA   nIdVeiculo                AS int
	WSDATA   nPesoTotal                AS decimal
	WSDATA   nPesoLiquidoTotal         AS decimal
	WSDATA   nCubagemTotal             AS decimal
	WSDATA   nValorTotal               AS decimal
	WSDATA   nQtdCaixas                AS int
	WSDATA   nQtdEntregas              AS int
	WSDATA   cDataConfirmacao          AS dateTime
	WSDATA   cObservacoes              AS string OPTIONAL
	WSDATA   nKmEstimado               AS decimal
	WSDATA   nIdEmbarcador             AS int
	WSDATA   nIdUnidade                AS int
	WSDATA   nIdCooperativa            AS int
	WSDATA   nIdTransportadora         AS int
	WSDATA   nStatus                   AS int
	WSDATA   cPlaca                    AS string OPTIONAL
	WSDATA   cCNPJUnidade              AS string OPTIONAL
	WSDATA   cOrdemEmbarque            AS string OPTIONAL
	WSDATA   cDoca                     AS string OPTIONAL
	WSDATA   oWSEntregas               AS sivirafullWebService_ArrayOfEntregaPlanejada OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT sivirafullWebService_ViagemPlanejada
	::Init()
Return Self

WSMETHOD INIT WSCLIENT sivirafullWebService_ViagemPlanejada
Return

WSMETHOD CLONE WSCLIENT sivirafullWebService_ViagemPlanejada
	Local oClone := sivirafullWebService_ViagemPlanejada():NEW()
	oClone:nId                  := ::nId
	oClone:cIdentificador       := ::cIdentificador
	oClone:cDataCriacao         := ::cDataCriacao
	oClone:cDataEstimada        := ::cDataEstimada
	oClone:cCodigoRota          := ::cCodigoRota
	oClone:nIdVeiculo           := ::nIdVeiculo
	oClone:nPesoTotal           := ::nPesoTotal
	oClone:nPesoLiquidoTotal    := ::nPesoLiquidoTotal
	oClone:nCubagemTotal        := ::nCubagemTotal
	oClone:nValorTotal          := ::nValorTotal
	oClone:nQtdCaixas           := ::nQtdCaixas
	oClone:nQtdEntregas         := ::nQtdEntregas
	oClone:cDataConfirmacao     := ::cDataConfirmacao
	oClone:cObservacoes         := ::cObservacoes
	oClone:nKmEstimado          := ::nKmEstimado
	oClone:nIdEmbarcador        := ::nIdEmbarcador
	oClone:nIdUnidade           := ::nIdUnidade
	oClone:nIdCooperativa       := ::nIdCooperativa
	oClone:nIdTransportadora    := ::nIdTransportadora
	oClone:nStatus              := ::nStatus
	oClone:cPlaca               := ::cPlaca
	oClone:cCNPJUnidade         := ::cCNPJUnidade
	oClone:cOrdemEmbarque       := ::cOrdemEmbarque
	oClone:cDoca                := ::cDoca
	oClone:oWSEntregas          := IIF(::oWSEntregas = NIL , NIL , ::oWSEntregas:Clone() )
Return oClone

WSMETHOD SOAPSEND WSCLIENT sivirafullWebService_ViagemPlanejada
	Local cSoap := ""
	cSoap += WSSoapValue("Id", ::nId, ::nId , "int", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Identificador", ::cIdentificador, ::cIdentificador , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("DataCriacao", ::cDataCriacao, ::cDataCriacao , "dateTime", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("DataEstimada", ::cDataEstimada, ::cDataEstimada , "dateTime", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CodigoRota", ::cCodigoRota, ::cCodigoRota , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("IdVeiculo", ::nIdVeiculo, ::nIdVeiculo , "int", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("PesoTotal", ::nPesoTotal, ::nPesoTotal , "decimal", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("PesoLiquidoTotal", ::nPesoLiquidoTotal, ::nPesoLiquidoTotal , "decimal", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CubagemTotal", ::nCubagemTotal, ::nCubagemTotal , "decimal", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ValorTotal", ::nValorTotal, ::nValorTotal , "decimal", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("QtdCaixas", ::nQtdCaixas, ::nQtdCaixas , "int", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("QtdEntregas", ::nQtdEntregas, ::nQtdEntregas , "int", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("DataConfirmacao", ::cDataConfirmacao, ::cDataConfirmacao , "dateTime", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Observacoes", ::cObservacoes, ::cObservacoes , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("KmEstimado", ::nKmEstimado, ::nKmEstimado , "decimal", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("IdEmbarcador", ::nIdEmbarcador, ::nIdEmbarcador , "int", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("IdUnidade", ::nIdUnidade, ::nIdUnidade , "int", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("IdCooperativa", ::nIdCooperativa, ::nIdCooperativa , "int", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("IdTransportadora", ::nIdTransportadora, ::nIdTransportadora , "int", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Status", ::nStatus, ::nStatus , "int", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Placa", ::cPlaca, ::cPlaca , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CNPJUnidade", ::cCNPJUnidade, ::cCNPJUnidade , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("OrdemEmbarque", ::cOrdemEmbarque, ::cOrdemEmbarque , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Doca", ::cDoca, ::cDoca , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Entregas", ::oWSEntregas, ::oWSEntregas , "ArrayOfEntregaPlanejada", .F. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

// WSDL Data Structure JanelaAtendimento

WSSTRUCT sivirafullWebService_JanelaAtendimento
	WSDATA   cCodigo                   AS string OPTIONAL
	WSDATA   cNome                     AS string OPTIONAL
	WSDATA   cRegionalVenda            AS string OPTIONAL
	WSDATA   cUnidade                  AS string OPTIONAL
	WSDATA   oWSAtendimentoDiario      AS sivirafullWebService_ArrayOfGradeDiaria OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT sivirafullWebService_JanelaAtendimento
	::Init()
Return Self

WSMETHOD INIT WSCLIENT sivirafullWebService_JanelaAtendimento
Return

WSMETHOD CLONE WSCLIENT sivirafullWebService_JanelaAtendimento
	Local oClone := sivirafullWebService_JanelaAtendimento():NEW()
	oClone:cCodigo              := ::cCodigo
	oClone:cNome                := ::cNome
	oClone:cRegionalVenda       := ::cRegionalVenda
	oClone:cUnidade             := ::cUnidade
	oClone:oWSAtendimentoDiario := IIF(::oWSAtendimentoDiario = NIL , NIL , ::oWSAtendimentoDiario:Clone() )
Return oClone

WSMETHOD SOAPSEND WSCLIENT sivirafullWebService_JanelaAtendimento
	Local cSoap := ""
	cSoap += WSSoapValue("Codigo", ::cCodigo, ::cCodigo , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Nome", ::cNome, ::cNome , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("RegionalVenda", ::cRegionalVenda, ::cRegionalVenda , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Unidade", ::cUnidade, ::cUnidade , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("AtendimentoDiario", ::oWSAtendimentoDiario, ::oWSAtendimentoDiario , "ArrayOfGradeDiaria", .F. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

// WSDL Data Structure Frete

WSSTRUCT sivirafullWebService_Frete
	WSDATA   cCodigo                   AS string OPTIONAL
	WSDATA   cNome                     AS string OPTIONAL
	WSDATA   cTipoVeiculo              AS string OPTIONAL
	WSDATA   cPerfil                   AS string OPTIONAL
	WSDATA   nValorPernoite            AS decimal
	WSDATA   nValorDiaria              AS decimal
	WSDATA   nQtdeDiaria               AS int
	WSDATA   nValorDescarga            AS decimal
	WSDATA   nValorAdicionalEntrega    AS decimal
	WSDATA   nValorPedagio             AS decimal
	WSDATA   nValorAjudante            AS decimal
	WSDATA   nValorChapa               AS decimal
	WSDATA   nValorKm                  AS decimal
	WSDATA   nFranquiaKm               AS decimal
	WSDATA   nValorKmExcedente         AS decimal
	WSDATA   nValorCombustivel         AS decimal
	WSDATA   nValor                    AS decimal
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT sivirafullWebService_Frete
	::Init()
Return Self

WSMETHOD INIT WSCLIENT sivirafullWebService_Frete
Return

WSMETHOD CLONE WSCLIENT sivirafullWebService_Frete
	Local oClone := sivirafullWebService_Frete():NEW()
	oClone:cCodigo              := ::cCodigo
	oClone:cNome                := ::cNome
	oClone:cTipoVeiculo         := ::cTipoVeiculo
	oClone:cPerfil              := ::cPerfil
	oClone:nValorPernoite       := ::nValorPernoite
	oClone:nValorDiaria         := ::nValorDiaria
	oClone:nQtdeDiaria          := ::nQtdeDiaria
	oClone:nValorDescarga       := ::nValorDescarga
	oClone:nValorAdicionalEntrega := ::nValorAdicionalEntrega
	oClone:nValorPedagio        := ::nValorPedagio
	oClone:nValorAjudante       := ::nValorAjudante
	oClone:nValorChapa          := ::nValorChapa
	oClone:nValorKm             := ::nValorKm
	oClone:nFranquiaKm          := ::nFranquiaKm
	oClone:nValorKmExcedente    := ::nValorKmExcedente
	oClone:nValorCombustivel    := ::nValorCombustivel
	oClone:nValor               := ::nValor
Return oClone

WSMETHOD SOAPSEND WSCLIENT sivirafullWebService_Frete
	Local cSoap := ""
	cSoap += WSSoapValue("Codigo", ::cCodigo, ::cCodigo , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Nome", ::cNome, ::cNome , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("TipoVeiculo", ::cTipoVeiculo, ::cTipoVeiculo , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Perfil", ::cPerfil, ::cPerfil , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ValorPernoite", ::nValorPernoite, ::nValorPernoite , "decimal", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ValorDiaria", ::nValorDiaria, ::nValorDiaria , "decimal", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("QtdeDiaria", ::nQtdeDiaria, ::nQtdeDiaria , "int", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ValorDescarga", ::nValorDescarga, ::nValorDescarga , "decimal", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ValorAdicionalEntrega", ::nValorAdicionalEntrega, ::nValorAdicionalEntrega , "decimal", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ValorPedagio", ::nValorPedagio, ::nValorPedagio , "decimal", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ValorAjudante", ::nValorAjudante, ::nValorAjudante , "decimal", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ValorChapa", ::nValorChapa, ::nValorChapa , "decimal", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ValorKm", ::nValorKm, ::nValorKm , "decimal", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("FranquiaKm", ::nFranquiaKm, ::nFranquiaKm , "decimal", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ValorKmExcedente", ::nValorKmExcedente, ::nValorKmExcedente , "decimal", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ValorCombustivel", ::nValorCombustivel, ::nValorCombustivel , "decimal", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Valor", ::nValor, ::nValor , "decimal", .T. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

// WSDL Data Structure ArrayOfEntrega

WSSTRUCT sivirafullWebService_ArrayOfEntrega
	WSDATA   oWSEntrega                AS sivirafullWebService_Entrega OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT sivirafullWebService_ArrayOfEntrega
	::Init()
Return Self

WSMETHOD INIT WSCLIENT sivirafullWebService_ArrayOfEntrega
	::oWSEntrega           := {} // Array Of  sivirafullWebService_ENTREGA():New()
Return

WSMETHOD CLONE WSCLIENT sivirafullWebService_ArrayOfEntrega
	Local oClone := sivirafullWebService_ArrayOfEntrega():NEW()
	oClone:oWSEntrega := NIL
	If ::oWSEntrega <> NIL 
		oClone:oWSEntrega := {}
		aEval( ::oWSEntrega , { |x| aadd( oClone:oWSEntrega , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT sivirafullWebService_ArrayOfEntrega
	Local cSoap := ""
	aEval( ::oWSEntrega , {|x| cSoap := cSoap  +  WSSoapValue("Entrega", x , x , "Entrega", .F. , .F., 0 , NIL, .F.,.F.)  } ) 
Return cSoap

// WSDL Data Structure ArrayOfRetornoAnomalia

WSSTRUCT sivirafullWebService_ArrayOfRetornoAnomalia
	WSDATA   oWSRetornoAnomalia        AS sivirafullWebService_RetornoAnomalia OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT sivirafullWebService_ArrayOfRetornoAnomalia
	::Init()
Return Self

WSMETHOD INIT WSCLIENT sivirafullWebService_ArrayOfRetornoAnomalia
	::oWSRetornoAnomalia   := {} // Array Of  sivirafullWebService_RETORNOANOMALIA():New()
Return

WSMETHOD CLONE WSCLIENT sivirafullWebService_ArrayOfRetornoAnomalia
	Local oClone := sivirafullWebService_ArrayOfRetornoAnomalia():NEW()
	oClone:oWSRetornoAnomalia := NIL
	If ::oWSRetornoAnomalia <> NIL 
		oClone:oWSRetornoAnomalia := {}
		aEval( ::oWSRetornoAnomalia , { |x| aadd( oClone:oWSRetornoAnomalia , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT sivirafullWebService_ArrayOfRetornoAnomalia
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_RETORNOANOMALIA","RetornoAnomalia",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSRetornoAnomalia , sivirafullWebService_RetornoAnomalia():New() )
			::oWSRetornoAnomalia[len(::oWSRetornoAnomalia)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ArrayOfRetornoEntrega

WSSTRUCT sivirafullWebService_ArrayOfRetornoEntrega
	WSDATA   oWSRetornoEntrega         AS sivirafullWebService_RetornoEntrega OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT sivirafullWebService_ArrayOfRetornoEntrega
	::Init()
Return Self

WSMETHOD INIT WSCLIENT sivirafullWebService_ArrayOfRetornoEntrega
	::oWSRetornoEntrega    := {} // Array Of  sivirafullWebService_RETORNOENTREGA():New()
Return

WSMETHOD CLONE WSCLIENT sivirafullWebService_ArrayOfRetornoEntrega
	Local oClone := sivirafullWebService_ArrayOfRetornoEntrega():NEW()
	oClone:oWSRetornoEntrega := NIL
	If ::oWSRetornoEntrega <> NIL 
		oClone:oWSRetornoEntrega := {}
		aEval( ::oWSRetornoEntrega , { |x| aadd( oClone:oWSRetornoEntrega , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT sivirafullWebService_ArrayOfRetornoEntrega
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_RETORNOENTREGA","RetornoEntrega",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSRetornoEntrega , sivirafullWebService_RetornoEntrega():New() )
			::oWSRetornoEntrega[len(::oWSRetornoEntrega)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ArrayOfRetornoColeta

WSSTRUCT sivirafullWebService_ArrayOfRetornoColeta
	WSDATA   oWSRetornoColeta          AS sivirafullWebService_RetornoColeta OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT sivirafullWebService_ArrayOfRetornoColeta
	::Init()
Return Self

WSMETHOD INIT WSCLIENT sivirafullWebService_ArrayOfRetornoColeta
	::oWSRetornoColeta     := {} // Array Of  sivirafullWebService_RETORNOCOLETA():New()
Return

WSMETHOD CLONE WSCLIENT sivirafullWebService_ArrayOfRetornoColeta
	Local oClone := sivirafullWebService_ArrayOfRetornoColeta():NEW()
	oClone:oWSRetornoColeta := NIL
	If ::oWSRetornoColeta <> NIL 
		oClone:oWSRetornoColeta := {}
		aEval( ::oWSRetornoColeta , { |x| aadd( oClone:oWSRetornoColeta , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT sivirafullWebService_ArrayOfRetornoColeta
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_RETORNOCOLETA","RetornoColeta",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSRetornoColeta , sivirafullWebService_RetornoColeta():New() )
			::oWSRetornoColeta[len(::oWSRetornoColeta)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure RetornoDevolucao

WSSTRUCT sivirafullWebService_RetornoDevolucao
	WSDATA   nTipoRetorno              AS int
	WSDATA   cSenhaControle            AS string OPTIONAL
	WSDATA   cCodigoMotivo             AS string OPTIONAL
	WSDATA   cMotivo                   AS string OPTIONAL
	WSDATA   cNumeroViagem             AS string OPTIONAL
	WSDATA   cCNPJUnidade              AS string OPTIONAL
	WSDATA   cNumeroNF                 AS string OPTIONAL
	WSDATA   cPlaca                    AS string OPTIONAL
	WSDATA   nIdViagem                 AS int
	WSDATA   oWSItensDevolvidos        AS sivirafullWebService_ArrayOfItemDevolucao OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT sivirafullWebService_RetornoDevolucao
	::Init()
Return Self

WSMETHOD INIT WSCLIENT sivirafullWebService_RetornoDevolucao
Return

WSMETHOD CLONE WSCLIENT sivirafullWebService_RetornoDevolucao
	Local oClone := sivirafullWebService_RetornoDevolucao():NEW()
	oClone:nTipoRetorno         := ::nTipoRetorno
	oClone:cSenhaControle       := ::cSenhaControle
	oClone:cCodigoMotivo        := ::cCodigoMotivo
	oClone:cMotivo              := ::cMotivo
	oClone:cNumeroViagem        := ::cNumeroViagem
	oClone:cCNPJUnidade         := ::cCNPJUnidade
	oClone:cNumeroNF            := ::cNumeroNF
	oClone:cPlaca               := ::cPlaca
	oClone:nIdViagem            := ::nIdViagem
	oClone:oWSItensDevolvidos   := IIF(::oWSItensDevolvidos = NIL , NIL , ::oWSItensDevolvidos:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT sivirafullWebService_RetornoDevolucao
	Local oNode10
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::nTipoRetorno       :=  WSAdvValue( oResponse,"_TIPORETORNO","int",NIL,"Property nTipoRetorno as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cSenhaControle     :=  WSAdvValue( oResponse,"_SENHACONTROLE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cCodigoMotivo      :=  WSAdvValue( oResponse,"_CODIGOMOTIVO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cMotivo            :=  WSAdvValue( oResponse,"_MOTIVO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cNumeroViagem      :=  WSAdvValue( oResponse,"_NUMEROVIAGEM","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cCNPJUnidade       :=  WSAdvValue( oResponse,"_CNPJUNIDADE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cNumeroNF          :=  WSAdvValue( oResponse,"_NUMERONF","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cPlaca             :=  WSAdvValue( oResponse,"_PLACA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nIdViagem          :=  WSAdvValue( oResponse,"_IDVIAGEM","int",NIL,"Property nIdViagem as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	oNode10 :=  WSAdvValue( oResponse,"_ITENSDEVOLVIDOS","ArrayOfItemDevolucao",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode10 != NIL
		::oWSItensDevolvidos := sivirafullWebService_ArrayOfItemDevolucao():New()
		::oWSItensDevolvidos:SoapRecv(oNode10)
	EndIf
Return

// WSDL Data Structure Indicadores

WSSTRUCT sivirafullWebService_Indicadores
	WSDATA   nTripId                   AS int
	WSDATA   nEfetividadeNF            AS decimal
	WSDATA   nDevolucao                AS decimal
	WSDATA   nReentrega                AS decimal
	WSDATA   nViagensAprovadasFrio     AS decimal
	WSDATA   nHomologacao              AS decimal
	WSDATA   nLargada                  AS decimal
	WSDATA   cMotivo                   AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT sivirafullWebService_Indicadores
	::Init()
Return Self

WSMETHOD INIT WSCLIENT sivirafullWebService_Indicadores
Return

WSMETHOD CLONE WSCLIENT sivirafullWebService_Indicadores
	Local oClone := sivirafullWebService_Indicadores():NEW()
	oClone:nTripId              := ::nTripId
	oClone:nEfetividadeNF       := ::nEfetividadeNF
	oClone:nDevolucao           := ::nDevolucao
	oClone:nReentrega           := ::nReentrega
	oClone:nViagensAprovadasFrio := ::nViagensAprovadasFrio
	oClone:nHomologacao         := ::nHomologacao
	oClone:nLargada             := ::nLargada
	oClone:cMotivo              := ::cMotivo
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT sivirafullWebService_Indicadores
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::nTripId            :=  WSAdvValue( oResponse,"_TRIPID","int",NIL,"Property nTripId as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nEfetividadeNF     :=  WSAdvValue( oResponse,"_EFETIVIDADENF","decimal",NIL,"Property nEfetividadeNF as s:decimal on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nDevolucao         :=  WSAdvValue( oResponse,"_DEVOLUCAO","decimal",NIL,"Property nDevolucao as s:decimal on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nReentrega         :=  WSAdvValue( oResponse,"_REENTREGA","decimal",NIL,"Property nReentrega as s:decimal on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nViagensAprovadasFrio :=  WSAdvValue( oResponse,"_VIAGENSAPROVADASFRIO","decimal",NIL,"Property nViagensAprovadasFrio as s:decimal on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nHomologacao       :=  WSAdvValue( oResponse,"_HOMOLOGACAO","decimal",NIL,"Property nHomologacao as s:decimal on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nLargada           :=  WSAdvValue( oResponse,"_LARGADA","decimal",NIL,"Property nLargada as s:decimal on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cMotivo            :=  WSAdvValue( oResponse,"_MOTIVO","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure ArrayOfCoordenadaRoteiro

WSSTRUCT sivirafullWebService_ArrayOfCoordenadaRoteiro
	WSDATA   oWSCoordenadaRoteiro      AS sivirafullWebService_CoordenadaRoteiro OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT sivirafullWebService_ArrayOfCoordenadaRoteiro
	::Init()
Return Self

WSMETHOD INIT WSCLIENT sivirafullWebService_ArrayOfCoordenadaRoteiro
	::oWSCoordenadaRoteiro := {} // Array Of  sivirafullWebService_COORDENADAROTEIRO():New()
Return

WSMETHOD CLONE WSCLIENT sivirafullWebService_ArrayOfCoordenadaRoteiro
	Local oClone := sivirafullWebService_ArrayOfCoordenadaRoteiro():NEW()
	oClone:oWSCoordenadaRoteiro := NIL
	If ::oWSCoordenadaRoteiro <> NIL 
		oClone:oWSCoordenadaRoteiro := {}
		aEval( ::oWSCoordenadaRoteiro , { |x| aadd( oClone:oWSCoordenadaRoteiro , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT sivirafullWebService_ArrayOfCoordenadaRoteiro
	Local cSoap := ""
	aEval( ::oWSCoordenadaRoteiro , {|x| cSoap := cSoap  +  WSSoapValue("CoordenadaRoteiro", x , x , "CoordenadaRoteiro", .F. , .F., 0 , NIL, .F.,.F.)  } ) 
Return cSoap

// WSDL Data Structure Anomalia

WSSTRUCT sivirafullWebService_Anomalia
	WSDATA   nTipoRetorno              AS int
	WSDATA   cSenhaControle            AS string OPTIONAL
	WSDATA   cCodigoMotivo             AS string OPTIONAL
	WSDATA   cMotivo                   AS string OPTIONAL
	WSDATA   nIdSetor                  AS int
	WSDATA   cSetor                    AS string OPTIONAL
	WSDATA   nIdArea                   AS int
	WSDATA   cArea                     AS string OPTIONAL
	WSDATA   cObservacao               AS string OPTIONAL
	WSDATA   nIdUsuario                AS int
	WSDATA   nIdOperador               AS int
	WSDATA   cLoginUsuario             AS string OPTIONAL
	WSDATA   cOperador                 AS string OPTIONAL
	WSDATA   cNumeroViagem             AS string OPTIONAL
	WSDATA   cCNPJUnidade              AS string OPTIONAL
	WSDATA   cNumeroNF                 AS string OPTIONAL
	WSDATA   cSerieNF                  AS string OPTIONAL
	WSDATA   cPlaca                    AS string OPTIONAL
	WSDATA   nIdViagem                 AS int
	WSDATA   lDevolucaoContabil        AS boolean
	WSDATA   oWSItensDevolvidos        AS sivirafullWebService_ArrayOfItemAnomalia OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT sivirafullWebService_Anomalia
	::Init()
Return Self

WSMETHOD INIT WSCLIENT sivirafullWebService_Anomalia
Return

WSMETHOD CLONE WSCLIENT sivirafullWebService_Anomalia
	Local oClone := sivirafullWebService_Anomalia():NEW()
	oClone:nTipoRetorno         := ::nTipoRetorno
	oClone:cSenhaControle       := ::cSenhaControle
	oClone:cCodigoMotivo        := ::cCodigoMotivo
	oClone:cMotivo              := ::cMotivo
	oClone:nIdSetor             := ::nIdSetor
	oClone:cSetor               := ::cSetor
	oClone:nIdArea              := ::nIdArea
	oClone:cArea                := ::cArea
	oClone:cObservacao          := ::cObservacao
	oClone:nIdUsuario           := ::nIdUsuario
	oClone:nIdOperador          := ::nIdOperador
	oClone:cLoginUsuario        := ::cLoginUsuario
	oClone:cOperador            := ::cOperador
	oClone:cNumeroViagem        := ::cNumeroViagem
	oClone:cCNPJUnidade         := ::cCNPJUnidade
	oClone:cNumeroNF            := ::cNumeroNF
	oClone:cSerieNF             := ::cSerieNF
	oClone:cPlaca               := ::cPlaca
	oClone:nIdViagem            := ::nIdViagem
	oClone:lDevolucaoContabil   := ::lDevolucaoContabil
	oClone:oWSItensDevolvidos   := IIF(::oWSItensDevolvidos = NIL , NIL , ::oWSItensDevolvidos:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT sivirafullWebService_Anomalia
	Local oNode21
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::nTipoRetorno       :=  WSAdvValue( oResponse,"_TIPORETORNO","int",NIL,"Property nTipoRetorno as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cSenhaControle     :=  WSAdvValue( oResponse,"_SENHACONTROLE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cCodigoMotivo      :=  WSAdvValue( oResponse,"_CODIGOMOTIVO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cMotivo            :=  WSAdvValue( oResponse,"_MOTIVO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nIdSetor           :=  WSAdvValue( oResponse,"_IDSETOR","int",NIL,"Property nIdSetor as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cSetor             :=  WSAdvValue( oResponse,"_SETOR","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nIdArea            :=  WSAdvValue( oResponse,"_IDAREA","int",NIL,"Property nIdArea as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cArea              :=  WSAdvValue( oResponse,"_AREA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cObservacao        :=  WSAdvValue( oResponse,"_OBSERVACAO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nIdUsuario         :=  WSAdvValue( oResponse,"_IDUSUARIO","int",NIL,"Property nIdUsuario as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nIdOperador        :=  WSAdvValue( oResponse,"_IDOPERADOR","int",NIL,"Property nIdOperador as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cLoginUsuario      :=  WSAdvValue( oResponse,"_LOGINUSUARIO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cOperador          :=  WSAdvValue( oResponse,"_OPERADOR","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cNumeroViagem      :=  WSAdvValue( oResponse,"_NUMEROVIAGEM","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cCNPJUnidade       :=  WSAdvValue( oResponse,"_CNPJUNIDADE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cNumeroNF          :=  WSAdvValue( oResponse,"_NUMERONF","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cSerieNF           :=  WSAdvValue( oResponse,"_SERIENF","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cPlaca             :=  WSAdvValue( oResponse,"_PLACA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nIdViagem          :=  WSAdvValue( oResponse,"_IDVIAGEM","int",NIL,"Property nIdViagem as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::lDevolucaoContabil :=  WSAdvValue( oResponse,"_DEVOLUCAOCONTABIL","boolean",NIL,"Property lDevolucaoContabil as s:boolean on SOAP Response not found.",NIL,"L",NIL,NIL) 
	oNode21 :=  WSAdvValue( oResponse,"_ITENSDEVOLVIDOS","ArrayOfItemAnomalia",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode21 != NIL
		::oWSItensDevolvidos := sivirafullWebService_ArrayOfItemAnomalia():New()
		::oWSItensDevolvidos:SoapRecv(oNode21)
	EndIf
Return

// WSDL Data Structure NotaEntregue

WSSTRUCT sivirafullWebService_NotaEntregue
	WSDATA   cIdentificador            AS string OPTIONAL
	WSDATA   nIdViagem                 AS int
	WSDATA   cPlaca                    AS string OPTIONAL
	WSDATA   cNotaFiscal               AS string OPTIONAL
	WSDATA   nSerie                    AS int
	WSDATA   cInicioEntrega            AS dateTime
	WSDATA   cConclusaoEntrega         AS dateTime
	WSDATA   lEntregaManual            AS boolean
	WSDATA   nIdOperador               AS int
	WSDATA   cOperador                 AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT sivirafullWebService_NotaEntregue
	::Init()
Return Self

WSMETHOD INIT WSCLIENT sivirafullWebService_NotaEntregue
Return

WSMETHOD CLONE WSCLIENT sivirafullWebService_NotaEntregue
	Local oClone := sivirafullWebService_NotaEntregue():NEW()
	oClone:cIdentificador       := ::cIdentificador
	oClone:nIdViagem            := ::nIdViagem
	oClone:cPlaca               := ::cPlaca
	oClone:cNotaFiscal          := ::cNotaFiscal
	oClone:nSerie               := ::nSerie
	oClone:cInicioEntrega       := ::cInicioEntrega
	oClone:cConclusaoEntrega    := ::cConclusaoEntrega
	oClone:lEntregaManual       := ::lEntregaManual
	oClone:nIdOperador          := ::nIdOperador
	oClone:cOperador            := ::cOperador
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT sivirafullWebService_NotaEntregue
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cIdentificador     :=  WSAdvValue( oResponse,"_IDENTIFICADOR","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nIdViagem          :=  WSAdvValue( oResponse,"_IDVIAGEM","int",NIL,"Property nIdViagem as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cPlaca             :=  WSAdvValue( oResponse,"_PLACA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cNotaFiscal        :=  WSAdvValue( oResponse,"_NOTAFISCAL","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nSerie             :=  WSAdvValue( oResponse,"_SERIE","int",NIL,"Property nSerie as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cInicioEntrega     :=  WSAdvValue( oResponse,"_INICIOENTREGA","dateTime",NIL,"Property cInicioEntrega as s:dateTime on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cConclusaoEntrega  :=  WSAdvValue( oResponse,"_CONCLUSAOENTREGA","dateTime",NIL,"Property cConclusaoEntrega as s:dateTime on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::lEntregaManual     :=  WSAdvValue( oResponse,"_ENTREGAMANUAL","boolean",NIL,"Property lEntregaManual as s:boolean on SOAP Response not found.",NIL,"L",NIL,NIL) 
	::nIdOperador        :=  WSAdvValue( oResponse,"_IDOPERADOR","int",NIL,"Property nIdOperador as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cOperador          :=  WSAdvValue( oResponse,"_OPERADOR","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure RetornoCustoAdicional

WSSTRUCT sivirafullWebService_RetornoCustoAdicional
	WSDATA   nId                       AS int
	WSDATA   lPrevisto                 AS boolean
	WSDATA   nValorAprovado            AS decimal
	WSDATA   cUrlImagem                AS string OPTIONAL
	WSDATA   cTipoCustoAdicional       AS string OPTIONAL
	WSDATA   nCodigoStatus             AS int
	WSDATA   cStatus                   AS string OPTIONAL
	WSDATA   cCodigoModalidade         AS string OPTIONAL
	WSDATA   cModalidade               AS string OPTIONAL
	WSDATA   cIdentificador            AS string OPTIONAL
	WSDATA   cUsuarioAprovador         AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT sivirafullWebService_RetornoCustoAdicional
	::Init()
Return Self

WSMETHOD INIT WSCLIENT sivirafullWebService_RetornoCustoAdicional
Return

WSMETHOD CLONE WSCLIENT sivirafullWebService_RetornoCustoAdicional
	Local oClone := sivirafullWebService_RetornoCustoAdicional():NEW()
	oClone:nId                  := ::nId
	oClone:lPrevisto            := ::lPrevisto
	oClone:nValorAprovado       := ::nValorAprovado
	oClone:cUrlImagem           := ::cUrlImagem
	oClone:cTipoCustoAdicional  := ::cTipoCustoAdicional
	oClone:nCodigoStatus        := ::nCodigoStatus
	oClone:cStatus              := ::cStatus
	oClone:cCodigoModalidade    := ::cCodigoModalidade
	oClone:cModalidade          := ::cModalidade
	oClone:cIdentificador       := ::cIdentificador
	oClone:cUsuarioAprovador    := ::cUsuarioAprovador
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT sivirafullWebService_RetornoCustoAdicional
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::nId                :=  WSAdvValue( oResponse,"_ID","int",NIL,"Property nId as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::lPrevisto          :=  WSAdvValue( oResponse,"_PREVISTO","boolean",NIL,"Property lPrevisto as s:boolean on SOAP Response not found.",NIL,"L",NIL,NIL) 
	::nValorAprovado     :=  WSAdvValue( oResponse,"_VALORAPROVADO","decimal",NIL,"Property nValorAprovado as s:decimal on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cUrlImagem         :=  WSAdvValue( oResponse,"_URLIMAGEM","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cTipoCustoAdicional :=  WSAdvValue( oResponse,"_TIPOCUSTOADICIONAL","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nCodigoStatus      :=  WSAdvValue( oResponse,"_CODIGOSTATUS","int",NIL,"Property nCodigoStatus as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cStatus            :=  WSAdvValue( oResponse,"_STATUS","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cCodigoModalidade  :=  WSAdvValue( oResponse,"_CODIGOMODALIDADE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cModalidade        :=  WSAdvValue( oResponse,"_MODALIDADE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cIdentificador     :=  WSAdvValue( oResponse,"_IDENTIFICADOR","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cUsuarioAprovador  :=  WSAdvValue( oResponse,"_USUARIOAPROVADOR","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure RetornoAlteracaoValorModalidade

WSSTRUCT sivirafullWebService_RetornoAlteracaoValorModalidade
	WSDATA   nId                       AS int
	WSDATA   cCodigoModalidade         AS string OPTIONAL
	WSDATA   cModalidade               AS string OPTIONAL
	WSDATA   nValor                    AS decimal
	WSDATA   cCodigoEntrega            AS string OPTIONAL
	WSDATA   cIdentificador            AS string OPTIONAL
	WSDATA   cUsuarioAprovador         AS string OPTIONAL
	WSDATA   cUrlImagem                AS string OPTIONAL
	WSDATA   cPdf                      AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT sivirafullWebService_RetornoAlteracaoValorModalidade
	::Init()
Return Self

WSMETHOD INIT WSCLIENT sivirafullWebService_RetornoAlteracaoValorModalidade
Return

WSMETHOD CLONE WSCLIENT sivirafullWebService_RetornoAlteracaoValorModalidade
	Local oClone := sivirafullWebService_RetornoAlteracaoValorModalidade():NEW()
	oClone:nId                  := ::nId
	oClone:cCodigoModalidade    := ::cCodigoModalidade
	oClone:cModalidade          := ::cModalidade
	oClone:nValor               := ::nValor
	oClone:cCodigoEntrega       := ::cCodigoEntrega
	oClone:cIdentificador       := ::cIdentificador
	oClone:cUsuarioAprovador    := ::cUsuarioAprovador
	oClone:cUrlImagem           := ::cUrlImagem
	oClone:cPdf                 := ::cPdf
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT sivirafullWebService_RetornoAlteracaoValorModalidade
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::nId                :=  WSAdvValue( oResponse,"_ID","int",NIL,"Property nId as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cCodigoModalidade  :=  WSAdvValue( oResponse,"_CODIGOMODALIDADE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cModalidade        :=  WSAdvValue( oResponse,"_MODALIDADE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nValor             :=  WSAdvValue( oResponse,"_VALOR","decimal",NIL,"Property nValor as s:decimal on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cCodigoEntrega     :=  WSAdvValue( oResponse,"_CODIGOENTREGA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cIdentificador     :=  WSAdvValue( oResponse,"_IDENTIFICADOR","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cUsuarioAprovador  :=  WSAdvValue( oResponse,"_USUARIOAPROVADOR","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cUrlImagem         :=  WSAdvValue( oResponse,"_URLIMAGEM","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cPdf               :=  WSAdvValue( oResponse,"_PDF","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure ViagemFinalizada

WSSTRUCT sivirafullWebService_ViagemFinalizada
	WSDATA   nIdViagem                 AS int
	WSDATA   cIdentificador            AS string OPTIONAL
	WSDATA   cDataFinalizacao          AS dateTime
	WSDATA   cPlaca                    AS string OPTIONAL
	WSDATA   cCnpjTransportadora       AS string OPTIONAL
	WSDATA   lPossuiEntregaRealizada   AS boolean
	WSDATA   lPossuiAnomaliaRegistrada AS boolean
	WSDATA   lPossuiSolicitacaoPernoiteAprovada AS boolean
	WSDATA   lPossuiCustoAdicionalAprovado AS boolean
	WSDATA   lPossuiAlteracaoDeValorPorModalidade AS boolean
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT sivirafullWebService_ViagemFinalizada
	::Init()
Return Self

WSMETHOD INIT WSCLIENT sivirafullWebService_ViagemFinalizada
Return

WSMETHOD CLONE WSCLIENT sivirafullWebService_ViagemFinalizada
	Local oClone := sivirafullWebService_ViagemFinalizada():NEW()
	oClone:nIdViagem            := ::nIdViagem
	oClone:cIdentificador       := ::cIdentificador
	oClone:cDataFinalizacao     := ::cDataFinalizacao
	oClone:cPlaca               := ::cPlaca
	oClone:cCnpjTransportadora  := ::cCnpjTransportadora
	oClone:lPossuiEntregaRealizada := ::lPossuiEntregaRealizada
	oClone:lPossuiAnomaliaRegistrada := ::lPossuiAnomaliaRegistrada
	oClone:lPossuiSolicitacaoPernoiteAprovada := ::lPossuiSolicitacaoPernoiteAprovada
	oClone:lPossuiCustoAdicionalAprovado := ::lPossuiCustoAdicionalAprovado
	oClone:lPossuiAlteracaoDeValorPorModalidade := ::lPossuiAlteracaoDeValorPorModalidade
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT sivirafullWebService_ViagemFinalizada
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::nIdViagem          :=  WSAdvValue( oResponse,"_IDVIAGEM","int",NIL,"Property nIdViagem as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cIdentificador     :=  WSAdvValue( oResponse,"_IDENTIFICADOR","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cDataFinalizacao   :=  WSAdvValue( oResponse,"_DATAFINALIZACAO","dateTime",NIL,"Property cDataFinalizacao as s:dateTime on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cPlaca             :=  WSAdvValue( oResponse,"_PLACA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cCnpjTransportadora :=  WSAdvValue( oResponse,"_CNPJTRANSPORTADORA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::lPossuiEntregaRealizada :=  WSAdvValue( oResponse,"_POSSUIENTREGAREALIZADA","boolean",NIL,"Property lPossuiEntregaRealizada as s:boolean on SOAP Response not found.",NIL,"L",NIL,NIL) 
	::lPossuiAnomaliaRegistrada :=  WSAdvValue( oResponse,"_POSSUIANOMALIAREGISTRADA","boolean",NIL,"Property lPossuiAnomaliaRegistrada as s:boolean on SOAP Response not found.",NIL,"L",NIL,NIL) 
	::lPossuiSolicitacaoPernoiteAprovada :=  WSAdvValue( oResponse,"_POSSUISOLICITACAOPERNOITEAPROVADA","boolean",NIL,"Property lPossuiSolicitacaoPernoiteAprovada as s:boolean on SOAP Response not found.",NIL,"L",NIL,NIL) 
	::lPossuiCustoAdicionalAprovado :=  WSAdvValue( oResponse,"_POSSUICUSTOADICIONALAPROVADO","boolean",NIL,"Property lPossuiCustoAdicionalAprovado as s:boolean on SOAP Response not found.",NIL,"L",NIL,NIL) 
	::lPossuiAlteracaoDeValorPorModalidade :=  WSAdvValue( oResponse,"_POSSUIALTERACAODEVALORPORMODALIDADE","boolean",NIL,"Property lPossuiAlteracaoDeValorPorModalidade as s:boolean on SOAP Response not found.",NIL,"L",NIL,NIL) 
Return

// WSDL Data Structure Pedido

WSSTRUCT sivirafullWebService_Pedido
	WSDATA   cNumero                   AS string OPTIONAL
	WSDATA   cOrdemCarregamento        AS string OPTIONAL
	WSDATA   nSequenciaProgramada      AS int
	WSDATA   nIdOperadorLogistico      AS int
	WSDATA   nIdEmbarcador             AS int
	WSDATA   nIdRemetente              AS int
	WSDATA   nIdUnidade                AS int
	WSDATA   cEstimativaEntrega        AS dateTime
	WSDATA   cCnpjRemetente            AS string OPTIONAL
	WSDATA   cDataPedido               AS dateTime
	WSDATA   cCnpjUnidade              AS string OPTIONAL
	WSDATA   cCnpjCliente              AS string OPTIONAL
	WSDATA   cNomeCliente              AS string OPTIONAL
	WSDATA   cEnderecoCliente          AS string OPTIONAL
	WSDATA   cCepCliente               AS string OPTIONAL
	WSDATA   cBairroCliente            AS string OPTIONAL
	WSDATA   cCidadeCliente            AS string OPTIONAL
	WSDATA   cEstadoCliente            AS string OPTIONAL
	WSDATA   nLatitudeCliente          AS double
	WSDATA   nLongitudeCliente         AS double
	WSDATA   nValorPedido              AS double
	WSDATA   nPesoLiquido              AS double
	WSDATA   nPesoBruto                AS double
	WSDATA   nCubagem                  AS double
	WSDATA   nQtdeVolumes              AS int
	WSDATA   nQtdeCaixas               AS int
	WSDATA   cObservacoes              AS string OPTIONAL
	WSDATA   lReentrega                AS boolean
	WSDATA   oWSItens                  AS sivirafullWebService_ArrayOfItemPedido OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT sivirafullWebService_Pedido
	::Init()
Return Self

WSMETHOD INIT WSCLIENT sivirafullWebService_Pedido
Return

WSMETHOD CLONE WSCLIENT sivirafullWebService_Pedido
	Local oClone := sivirafullWebService_Pedido():NEW()
	oClone:cNumero              := ::cNumero
	oClone:cOrdemCarregamento   := ::cOrdemCarregamento
	oClone:nSequenciaProgramada := ::nSequenciaProgramada
	oClone:nIdOperadorLogistico := ::nIdOperadorLogistico
	oClone:nIdEmbarcador        := ::nIdEmbarcador
	oClone:nIdRemetente         := ::nIdRemetente
	oClone:nIdUnidade           := ::nIdUnidade
	oClone:cEstimativaEntrega   := ::cEstimativaEntrega
	oClone:cCnpjRemetente       := ::cCnpjRemetente
	oClone:cDataPedido          := ::cDataPedido
	oClone:cCnpjUnidade         := ::cCnpjUnidade
	oClone:cCnpjCliente         := ::cCnpjCliente
	oClone:cNomeCliente         := ::cNomeCliente
	oClone:cEnderecoCliente     := ::cEnderecoCliente
	oClone:cCepCliente          := ::cCepCliente
	oClone:cBairroCliente       := ::cBairroCliente
	oClone:cCidadeCliente       := ::cCidadeCliente
	oClone:cEstadoCliente       := ::cEstadoCliente
	oClone:nLatitudeCliente     := ::nLatitudeCliente
	oClone:nLongitudeCliente    := ::nLongitudeCliente
	oClone:nValorPedido         := ::nValorPedido
	oClone:nPesoLiquido         := ::nPesoLiquido
	oClone:nPesoBruto           := ::nPesoBruto
	oClone:nCubagem             := ::nCubagem
	oClone:nQtdeVolumes         := ::nQtdeVolumes
	oClone:nQtdeCaixas          := ::nQtdeCaixas
	oClone:cObservacoes         := ::cObservacoes
	oClone:lReentrega           := ::lReentrega
	oClone:oWSItens             := IIF(::oWSItens = NIL , NIL , ::oWSItens:Clone() )
Return oClone

WSMETHOD SOAPSEND WSCLIENT sivirafullWebService_Pedido
	Local cSoap := ""
	cSoap += WSSoapValue("Numero", ::cNumero, ::cNumero , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("OrdemCarregamento", ::cOrdemCarregamento, ::cOrdemCarregamento , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("SequenciaProgramada", ::nSequenciaProgramada, ::nSequenciaProgramada , "int", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("IdOperadorLogistico", ::nIdOperadorLogistico, ::nIdOperadorLogistico , "int", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("IdEmbarcador", ::nIdEmbarcador, ::nIdEmbarcador , "int", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("IdRemetente", ::nIdRemetente, ::nIdRemetente , "int", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("IdUnidade", ::nIdUnidade, ::nIdUnidade , "int", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("EstimativaEntrega", ::cEstimativaEntrega, ::cEstimativaEntrega , "dateTime", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CnpjRemetente", ::cCnpjRemetente, ::cCnpjRemetente , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("DataPedido", ::cDataPedido, ::cDataPedido , "dateTime", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CnpjUnidade", ::cCnpjUnidade, ::cCnpjUnidade , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CnpjCliente", ::cCnpjCliente, ::cCnpjCliente , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("NomeCliente", ::cNomeCliente, ::cNomeCliente , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("EnderecoCliente", ::cEnderecoCliente, ::cEnderecoCliente , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CepCliente", ::cCepCliente, ::cCepCliente , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("BairroCliente", ::cBairroCliente, ::cBairroCliente , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CidadeCliente", ::cCidadeCliente, ::cCidadeCliente , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("EstadoCliente", ::cEstadoCliente, ::cEstadoCliente , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("LatitudeCliente", ::nLatitudeCliente, ::nLatitudeCliente , "double", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("LongitudeCliente", ::nLongitudeCliente, ::nLongitudeCliente , "double", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ValorPedido", ::nValorPedido, ::nValorPedido , "double", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("PesoLiquido", ::nPesoLiquido, ::nPesoLiquido , "double", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("PesoBruto", ::nPesoBruto, ::nPesoBruto , "double", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Cubagem", ::nCubagem, ::nCubagem , "double", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("QtdeVolumes", ::nQtdeVolumes, ::nQtdeVolumes , "int", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("QtdeCaixas", ::nQtdeCaixas, ::nQtdeCaixas , "int", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Observacoes", ::cObservacoes, ::cObservacoes , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Reentrega", ::lReentrega, ::lReentrega , "boolean", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Itens", ::oWSItens, ::oWSItens , "ArrayOfItemPedido", .F. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

// WSDL Data Structure Roteiro

WSSTRUCT sivirafullWebService_Roteiro
	WSDATA   nId                       AS int
	WSDATA   cOrigem                   AS string OPTIONAL
	WSDATA   cDestino                  AS string OPTIONAL
	WSDATA   cIdentificadorRota        AS string OPTIONAL
	WSDATA   cPrevisaoInicio           AS dateTime
	WSDATA   cDataRoteirizacao         AS dateTime
	WSDATA   nIdRota                   AS int
	WSDATA   cPlaca                    AS string OPTIONAL
	WSDATA   cPlacaCarreta             AS string OPTIONAL
	WSDATA   cPlacaTreminhao           AS string OPTIONAL
	WSDATA   cMotorista                AS string OPTIONAL
	WSDATA   cCpfMotorista             AS string OPTIONAL
	WSDATA   nKmEstimado               AS decimal
	WSDATA   nTempoEstimado            AS decimal
	WSDATA   cCnpjUnidade              AS string OPTIONAL
	WSDATA   cTipo                     AS string OPTIONAL
	WSDATA   oWSPedidos                AS sivirafullWebService_ArrayOfItemRoteiro OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT sivirafullWebService_Roteiro
	::Init()
Return Self

WSMETHOD INIT WSCLIENT sivirafullWebService_Roteiro
Return

WSMETHOD CLONE WSCLIENT sivirafullWebService_Roteiro
	Local oClone := sivirafullWebService_Roteiro():NEW()
	oClone:nId                  := ::nId
	oClone:cOrigem              := ::cOrigem
	oClone:cDestino             := ::cDestino
	oClone:cIdentificadorRota   := ::cIdentificadorRota
	oClone:cPrevisaoInicio      := ::cPrevisaoInicio
	oClone:cDataRoteirizacao    := ::cDataRoteirizacao
	oClone:nIdRota              := ::nIdRota
	oClone:cPlaca               := ::cPlaca
	oClone:cPlacaCarreta        := ::cPlacaCarreta
	oClone:cPlacaTreminhao      := ::cPlacaTreminhao
	oClone:cMotorista           := ::cMotorista
	oClone:cCpfMotorista        := ::cCpfMotorista
	oClone:nKmEstimado          := ::nKmEstimado
	oClone:nTempoEstimado       := ::nTempoEstimado
	oClone:cCnpjUnidade         := ::cCnpjUnidade
	oClone:cTipo                := ::cTipo
	oClone:oWSPedidos           := IIF(::oWSPedidos = NIL , NIL , ::oWSPedidos:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT sivirafullWebService_Roteiro
	Local oNode17
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::nId                :=  WSAdvValue( oResponse,"_ID","int",NIL,"Property nId as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cOrigem            :=  WSAdvValue( oResponse,"_ORIGEM","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cDestino           :=  WSAdvValue( oResponse,"_DESTINO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cIdentificadorRota :=  WSAdvValue( oResponse,"_IDENTIFICADORROTA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cPrevisaoInicio    :=  WSAdvValue( oResponse,"_PREVISAOINICIO","dateTime",NIL,"Property cPrevisaoInicio as s:dateTime on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cDataRoteirizacao  :=  WSAdvValue( oResponse,"_DATAROTEIRIZACAO","dateTime",NIL,"Property cDataRoteirizacao as s:dateTime on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::nIdRota            :=  WSAdvValue( oResponse,"_IDROTA","int",NIL,"Property nIdRota as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cPlaca             :=  WSAdvValue( oResponse,"_PLACA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cPlacaCarreta      :=  WSAdvValue( oResponse,"_PLACACARRETA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cPlacaTreminhao    :=  WSAdvValue( oResponse,"_PLACATREMINHAO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cMotorista         :=  WSAdvValue( oResponse,"_MOTORISTA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cCpfMotorista      :=  WSAdvValue( oResponse,"_CPFMOTORISTA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nKmEstimado        :=  WSAdvValue( oResponse,"_KMESTIMADO","decimal",NIL,"Property nKmEstimado as s:decimal on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nTempoEstimado     :=  WSAdvValue( oResponse,"_TEMPOESTIMADO","decimal",NIL,"Property nTempoEstimado as s:decimal on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cCnpjUnidade       :=  WSAdvValue( oResponse,"_CNPJUNIDADE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cTipo              :=  WSAdvValue( oResponse,"_TIPO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	oNode17 :=  WSAdvValue( oResponse,"_PEDIDOS","ArrayOfItemRoteiro",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode17 != NIL
		::oWSPedidos := sivirafullWebService_ArrayOfItemRoteiro():New()
		::oWSPedidos:SoapRecv(oNode17)
	EndIf
Return

// WSDL Data Structure ModalidadeCustoAdicional

WSSTRUCT sivirafullWebService_ModalidadeCustoAdicional
	WSDATA   nId                       AS int
	WSDATA   cCodigo                   AS string OPTIONAL
	WSDATA   cNome                     AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT sivirafullWebService_ModalidadeCustoAdicional
	::Init()
Return Self

WSMETHOD INIT WSCLIENT sivirafullWebService_ModalidadeCustoAdicional
Return

WSMETHOD CLONE WSCLIENT sivirafullWebService_ModalidadeCustoAdicional
	Local oClone := sivirafullWebService_ModalidadeCustoAdicional():NEW()
	oClone:nId                  := ::nId
	oClone:cCodigo              := ::cCodigo
	oClone:cNome                := ::cNome
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT sivirafullWebService_ModalidadeCustoAdicional
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::nId                :=  WSAdvValue( oResponse,"_ID","int",NIL,"Property nId as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cCodigo            :=  WSAdvValue( oResponse,"_CODIGO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cNome              :=  WSAdvValue( oResponse,"_NOME","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure TipoCustoAdicional

WSSTRUCT sivirafullWebService_TipoCustoAdicional
	WSDATA   nId                       AS int
	WSDATA   cNome                     AS string OPTIONAL
	WSDATA   cDescricao                AS string OPTIONAL
	WSDATA   cCodigo                   AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT sivirafullWebService_TipoCustoAdicional
	::Init()
Return Self

WSMETHOD INIT WSCLIENT sivirafullWebService_TipoCustoAdicional
Return

WSMETHOD CLONE WSCLIENT sivirafullWebService_TipoCustoAdicional
	Local oClone := sivirafullWebService_TipoCustoAdicional():NEW()
	oClone:nId                  := ::nId
	oClone:cNome                := ::cNome
	oClone:cDescricao           := ::cDescricao
	oClone:cCodigo              := ::cCodigo
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT sivirafullWebService_TipoCustoAdicional
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::nId                :=  WSAdvValue( oResponse,"_ID","int",NIL,"Property nId as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cNome              :=  WSAdvValue( oResponse,"_NOME","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cDescricao         :=  WSAdvValue( oResponse,"_DESCRICAO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cCodigo            :=  WSAdvValue( oResponse,"_CODIGO","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure ArrayOfEntregaPlanejada

WSSTRUCT sivirafullWebService_ArrayOfEntregaPlanejada
	WSDATA   oWSEntregaPlanejada       AS sivirafullWebService_EntregaPlanejada OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT sivirafullWebService_ArrayOfEntregaPlanejada
	::Init()
Return Self

WSMETHOD INIT WSCLIENT sivirafullWebService_ArrayOfEntregaPlanejada
	::oWSEntregaPlanejada  := {} // Array Of  sivirafullWebService_ENTREGAPLANEJADA():New()
Return

WSMETHOD CLONE WSCLIENT sivirafullWebService_ArrayOfEntregaPlanejada
	Local oClone := sivirafullWebService_ArrayOfEntregaPlanejada():NEW()
	oClone:oWSEntregaPlanejada := NIL
	If ::oWSEntregaPlanejada <> NIL 
		oClone:oWSEntregaPlanejada := {}
		aEval( ::oWSEntregaPlanejada , { |x| aadd( oClone:oWSEntregaPlanejada , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT sivirafullWebService_ArrayOfEntregaPlanejada
	Local cSoap := ""
	aEval( ::oWSEntregaPlanejada , {|x| cSoap := cSoap  +  WSSoapValue("EntregaPlanejada", x , x , "EntregaPlanejada", .F. , .F., 0 , NIL, .F.,.F.)  } ) 
Return cSoap

// WSDL Data Structure ArrayOfGradeDiaria

WSSTRUCT sivirafullWebService_ArrayOfGradeDiaria
	WSDATA   oWSGradeDiaria            AS sivirafullWebService_GradeDiaria OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT sivirafullWebService_ArrayOfGradeDiaria
	::Init()
Return Self

WSMETHOD INIT WSCLIENT sivirafullWebService_ArrayOfGradeDiaria
	::oWSGradeDiaria       := {} // Array Of  sivirafullWebService_GRADEDIARIA():New()
Return

WSMETHOD CLONE WSCLIENT sivirafullWebService_ArrayOfGradeDiaria
	Local oClone := sivirafullWebService_ArrayOfGradeDiaria():NEW()
	oClone:oWSGradeDiaria := NIL
	If ::oWSGradeDiaria <> NIL 
		oClone:oWSGradeDiaria := {}
		aEval( ::oWSGradeDiaria , { |x| aadd( oClone:oWSGradeDiaria , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT sivirafullWebService_ArrayOfGradeDiaria
	Local cSoap := ""
	aEval( ::oWSGradeDiaria , {|x| cSoap := cSoap  +  WSSoapValue("GradeDiaria", x , x , "GradeDiaria", .F. , .F., 0 , NIL, .F.,.F.)  } ) 
Return cSoap

// WSDL Data Structure Entrega

WSSTRUCT sivirafullWebService_Entrega
	WSDATA   nSequencia                AS short
	WSDATA   cCodigo                   AS string OPTIONAL
	WSDATA   cReferencia               AS string OPTIONAL
	WSDATA   nLatitude                 AS decimal
	WSDATA   nLongitude                AS decimal
	WSDATA   cEstimativaInicio         AS dateTime
	WSDATA   cEstimativaFim            AS dateTime
	WSDATA   nPeso                     AS decimal
	WSDATA   nCubagem                  AS decimal
	WSDATA   nValor                    AS decimal
	WSDATA   cEndereco                 AS string OPTIONAL
	WSDATA   cBairro                   AS string OPTIONAL
	WSDATA   cCidade                   AS string OPTIONAL
	WSDATA   cTipoCliente              AS string OPTIONAL
	WSDATA   nQtdCaixas                AS int
	WSDATA   nTempoEntrega             AS int
	WSDATA   cIniRecebManha            AS string OPTIONAL
	WSDATA   cFimRecebManha            AS string OPTIONAL
	WSDATA   cIniRecebTarde            AS string OPTIONAL
	WSDATA   cFimRecebTarde            AS string OPTIONAL
	WSDATA   lColeta                   AS boolean
	WSDATA   cRegional                 AS string OPTIONAL
	WSDATA   oWSNotasFiscais           AS sivirafullWebService_ArrayOfNotaFiscal OPTIONAL
	WSDATA   oWSGradeAtendimento       AS sivirafullWebService_JanelaAtendimento OPTIONAL
	WSDATA   cCodigoGradeAtendimento   AS string OPTIONAL
	WSDATA   cRegionalVenda            AS string OPTIONAL
	WSDATA   oWSCustosAdicionaisPrevistos AS sivirafullWebService_ArrayOfCustoAdicionalPrevisto OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT sivirafullWebService_Entrega
	::Init()
Return Self

WSMETHOD INIT WSCLIENT sivirafullWebService_Entrega
Return

WSMETHOD CLONE WSCLIENT sivirafullWebService_Entrega
	Local oClone := sivirafullWebService_Entrega():NEW()
	oClone:nSequencia           := ::nSequencia
	oClone:cCodigo              := ::cCodigo
	oClone:cReferencia          := ::cReferencia
	oClone:nLatitude            := ::nLatitude
	oClone:nLongitude           := ::nLongitude
	oClone:cEstimativaInicio    := ::cEstimativaInicio
	oClone:cEstimativaFim       := ::cEstimativaFim
	oClone:nPeso                := ::nPeso
	oClone:nCubagem             := ::nCubagem
	oClone:nValor               := ::nValor
	oClone:cEndereco            := ::cEndereco
	oClone:cBairro              := ::cBairro
	oClone:cCidade              := ::cCidade
	oClone:cTipoCliente         := ::cTipoCliente
	oClone:nQtdCaixas           := ::nQtdCaixas
	oClone:nTempoEntrega        := ::nTempoEntrega
	oClone:cIniRecebManha       := ::cIniRecebManha
	oClone:cFimRecebManha       := ::cFimRecebManha
	oClone:cIniRecebTarde       := ::cIniRecebTarde
	oClone:cFimRecebTarde       := ::cFimRecebTarde
	oClone:lColeta              := ::lColeta
	oClone:cRegional            := ::cRegional
	oClone:oWSNotasFiscais      := IIF(::oWSNotasFiscais = NIL , NIL , ::oWSNotasFiscais:Clone() )
	oClone:oWSGradeAtendimento  := IIF(::oWSGradeAtendimento = NIL , NIL , ::oWSGradeAtendimento:Clone() )
	oClone:cCodigoGradeAtendimento := ::cCodigoGradeAtendimento
	oClone:cRegionalVenda       := ::cRegionalVenda
	oClone:oWSCustosAdicionaisPrevistos := IIF(::oWSCustosAdicionaisPrevistos = NIL , NIL , ::oWSCustosAdicionaisPrevistos:Clone() )
Return oClone

WSMETHOD SOAPSEND WSCLIENT sivirafullWebService_Entrega
	Local cSoap := ""
	cSoap += WSSoapValue("Sequencia", ::nSequencia, ::nSequencia , "short", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Codigo", ::cCodigo, ::cCodigo , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Referencia", ::cReferencia, ::cReferencia , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Latitude", ::nLatitude, ::nLatitude , "decimal", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Longitude", ::nLongitude, ::nLongitude , "decimal", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("EstimativaInicio", ::cEstimativaInicio, ::cEstimativaInicio , "dateTime", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("EstimativaFim", ::cEstimativaFim, ::cEstimativaFim , "dateTime", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Peso", ::nPeso, ::nPeso , "decimal", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Cubagem", ::nCubagem, ::nCubagem , "decimal", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Valor", ::nValor, ::nValor , "decimal", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Endereco", ::cEndereco, ::cEndereco , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Bairro", ::cBairro, ::cBairro , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Cidade", ::cCidade, ::cCidade , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("TipoCliente", ::cTipoCliente, ::cTipoCliente , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("QtdCaixas", ::nQtdCaixas, ::nQtdCaixas , "int", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("TempoEntrega", ::nTempoEntrega, ::nTempoEntrega , "int", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("IniRecebManha", ::cIniRecebManha, ::cIniRecebManha , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("FimRecebManha", ::cFimRecebManha, ::cFimRecebManha , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("IniRecebTarde", ::cIniRecebTarde, ::cIniRecebTarde , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("FimRecebTarde", ::cFimRecebTarde, ::cFimRecebTarde , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Coleta", ::lColeta, ::lColeta , "boolean", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Regional", ::cRegional, ::cRegional , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("NotasFiscais", ::oWSNotasFiscais, ::oWSNotasFiscais , "ArrayOfNotaFiscal", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("GradeAtendimento", ::oWSGradeAtendimento, ::oWSGradeAtendimento , "JanelaAtendimento", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CodigoGradeAtendimento", ::cCodigoGradeAtendimento, ::cCodigoGradeAtendimento , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("RegionalVenda", ::cRegionalVenda, ::cRegionalVenda , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CustosAdicionaisPrevistos", ::oWSCustosAdicionaisPrevistos, ::oWSCustosAdicionaisPrevistos , "ArrayOfCustoAdicionalPrevisto", .F. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

// WSDL Data Structure RetornoAnomalia

WSSTRUCT sivirafullWebService_RetornoAnomalia
	WSDATA   cDataHoraOcorrencia       AS dateTime
	WSDATA   cDataHoraAceite           AS dateTime
	WSDATA   nTipoRetorno              AS int
	WSDATA   cSenhaControle            AS string OPTIONAL
	WSDATA   cCodigoMotivo             AS string OPTIONAL
	WSDATA   cMotivo                   AS string OPTIONAL
	WSDATA   nIdSetor                  AS int
	WSDATA   cSetor                    AS string OPTIONAL
	WSDATA   nIdArea                   AS int
	WSDATA   cArea                     AS string OPTIONAL
	WSDATA   cObservacao               AS string OPTIONAL
	WSDATA   nIdUsuario                AS int
	WSDATA   nIdOperador               AS int
	WSDATA   cLoginUsuario             AS string OPTIONAL
	WSDATA   cOperador                 AS string OPTIONAL
	WSDATA   cNumeroNF                 AS string OPTIONAL
	WSDATA   cSerieNF                  AS string OPTIONAL
	WSDATA   lDevolucaoContabil        AS boolean
	WSDATA   nLatitude                 AS decimal
	WSDATA   nLongitude                AS decimal
	WSDATA   oWSItensDevolvidos        AS sivirafullWebService_ArrayOfItemAnomalia OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT sivirafullWebService_RetornoAnomalia
	::Init()
Return Self

WSMETHOD INIT WSCLIENT sivirafullWebService_RetornoAnomalia
Return

WSMETHOD CLONE WSCLIENT sivirafullWebService_RetornoAnomalia
	Local oClone := sivirafullWebService_RetornoAnomalia():NEW()
	oClone:cDataHoraOcorrencia  := ::cDataHoraOcorrencia
	oClone:cDataHoraAceite      := ::cDataHoraAceite
	oClone:nTipoRetorno         := ::nTipoRetorno
	oClone:cSenhaControle       := ::cSenhaControle
	oClone:cCodigoMotivo        := ::cCodigoMotivo
	oClone:cMotivo              := ::cMotivo
	oClone:nIdSetor             := ::nIdSetor
	oClone:cSetor               := ::cSetor
	oClone:nIdArea              := ::nIdArea
	oClone:cArea                := ::cArea
	oClone:cObservacao          := ::cObservacao
	oClone:nIdUsuario           := ::nIdUsuario
	oClone:nIdOperador          := ::nIdOperador
	oClone:cLoginUsuario        := ::cLoginUsuario
	oClone:cOperador            := ::cOperador
	oClone:cNumeroNF            := ::cNumeroNF
	oClone:cSerieNF             := ::cSerieNF
	oClone:lDevolucaoContabil   := ::lDevolucaoContabil
	oClone:nLatitude            := ::nLatitude
	oClone:nLongitude           := ::nLongitude
	oClone:oWSItensDevolvidos   := IIF(::oWSItensDevolvidos = NIL , NIL , ::oWSItensDevolvidos:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT sivirafullWebService_RetornoAnomalia
	Local oNode21
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cDataHoraOcorrencia :=  WSAdvValue( oResponse,"_DATAHORAOCORRENCIA","dateTime",NIL,"Property cDataHoraOcorrencia as s:dateTime on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cDataHoraAceite    :=  WSAdvValue( oResponse,"_DATAHORAACEITE","dateTime",NIL,"Property cDataHoraAceite as s:dateTime on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::nTipoRetorno       :=  WSAdvValue( oResponse,"_TIPORETORNO","int",NIL,"Property nTipoRetorno as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cSenhaControle     :=  WSAdvValue( oResponse,"_SENHACONTROLE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cCodigoMotivo      :=  WSAdvValue( oResponse,"_CODIGOMOTIVO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cMotivo            :=  WSAdvValue( oResponse,"_MOTIVO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nIdSetor           :=  WSAdvValue( oResponse,"_IDSETOR","int",NIL,"Property nIdSetor as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cSetor             :=  WSAdvValue( oResponse,"_SETOR","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nIdArea            :=  WSAdvValue( oResponse,"_IDAREA","int",NIL,"Property nIdArea as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cArea              :=  WSAdvValue( oResponse,"_AREA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cObservacao        :=  WSAdvValue( oResponse,"_OBSERVACAO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nIdUsuario         :=  WSAdvValue( oResponse,"_IDUSUARIO","int",NIL,"Property nIdUsuario as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nIdOperador        :=  WSAdvValue( oResponse,"_IDOPERADOR","int",NIL,"Property nIdOperador as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cLoginUsuario      :=  WSAdvValue( oResponse,"_LOGINUSUARIO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cOperador          :=  WSAdvValue( oResponse,"_OPERADOR","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cNumeroNF          :=  WSAdvValue( oResponse,"_NUMERONF","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cSerieNF           :=  WSAdvValue( oResponse,"_SERIENF","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::lDevolucaoContabil :=  WSAdvValue( oResponse,"_DEVOLUCAOCONTABIL","boolean",NIL,"Property lDevolucaoContabil as s:boolean on SOAP Response not found.",NIL,"L",NIL,NIL) 
	::nLatitude          :=  WSAdvValue( oResponse,"_LATITUDE","decimal",NIL,"Property nLatitude as s:decimal on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nLongitude         :=  WSAdvValue( oResponse,"_LONGITUDE","decimal",NIL,"Property nLongitude as s:decimal on SOAP Response not found.",NIL,"N",NIL,NIL) 
	oNode21 :=  WSAdvValue( oResponse,"_ITENSDEVOLVIDOS","ArrayOfItemAnomalia",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode21 != NIL
		::oWSItensDevolvidos := sivirafullWebService_ArrayOfItemAnomalia():New()
		::oWSItensDevolvidos:SoapRecv(oNode21)
	EndIf
Return

// WSDL Data Structure RetornoEntrega

WSSTRUCT sivirafullWebService_RetornoEntrega
	WSDATA   cNotaFiscal               AS string OPTIONAL
	WSDATA   nSerie                    AS int
	WSDATA   cInicioEntrega            AS dateTime
	WSDATA   cConclusaoEntrega         AS dateTime
	WSDATA   nLatitude                 AS decimal
	WSDATA   nLongitude                AS decimal
	WSDATA   lEntregaManual            AS boolean
	WSDATA   nTipoEntrega              AS int
	WSDATA   nIdOperador               AS int
	WSDATA   cOperador                 AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT sivirafullWebService_RetornoEntrega
	::Init()
Return Self

WSMETHOD INIT WSCLIENT sivirafullWebService_RetornoEntrega
Return

WSMETHOD CLONE WSCLIENT sivirafullWebService_RetornoEntrega
	Local oClone := sivirafullWebService_RetornoEntrega():NEW()
	oClone:cNotaFiscal          := ::cNotaFiscal
	oClone:nSerie               := ::nSerie
	oClone:cInicioEntrega       := ::cInicioEntrega
	oClone:cConclusaoEntrega    := ::cConclusaoEntrega
	oClone:nLatitude            := ::nLatitude
	oClone:nLongitude           := ::nLongitude
	oClone:lEntregaManual       := ::lEntregaManual
	oClone:nTipoEntrega         := ::nTipoEntrega
	oClone:nIdOperador          := ::nIdOperador
	oClone:cOperador            := ::cOperador
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT sivirafullWebService_RetornoEntrega
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cNotaFiscal        :=  WSAdvValue( oResponse,"_NOTAFISCAL","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nSerie             :=  WSAdvValue( oResponse,"_SERIE","int",NIL,"Property nSerie as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cInicioEntrega     :=  WSAdvValue( oResponse,"_INICIOENTREGA","dateTime",NIL,"Property cInicioEntrega as s:dateTime on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cConclusaoEntrega  :=  WSAdvValue( oResponse,"_CONCLUSAOENTREGA","dateTime",NIL,"Property cConclusaoEntrega as s:dateTime on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::nLatitude          :=  WSAdvValue( oResponse,"_LATITUDE","decimal",NIL,"Property nLatitude as s:decimal on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nLongitude         :=  WSAdvValue( oResponse,"_LONGITUDE","decimal",NIL,"Property nLongitude as s:decimal on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::lEntregaManual     :=  WSAdvValue( oResponse,"_ENTREGAMANUAL","boolean",NIL,"Property lEntregaManual as s:boolean on SOAP Response not found.",NIL,"L",NIL,NIL) 
	::nTipoEntrega       :=  WSAdvValue( oResponse,"_TIPOENTREGA","int",NIL,"Property nTipoEntrega as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nIdOperador        :=  WSAdvValue( oResponse,"_IDOPERADOR","int",NIL,"Property nIdOperador as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cOperador          :=  WSAdvValue( oResponse,"_OPERADOR","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure RetornoColeta

WSSTRUCT sivirafullWebService_RetornoColeta
	WSDATA   cCodigo                   AS string OPTIONAL
	WSDATA   cNumero                   AS string OPTIONAL
	WSDATA   cNome                     AS string OPTIONAL
	WSDATA   cTipo                     AS string OPTIONAL
	WSDATA   nSequencia                AS int
	WSDATA   nLatitude                 AS decimal
	WSDATA   nLongitude                AS decimal
	WSDATA   cInicioColeta             AS dateTime
	WSDATA   cConclusaoColeta          AS dateTime
	WSDATA   nTemperatura              AS decimal
	WSDATA   cInformacaoExtra          AS string OPTIONAL
	WSDATA   nQuantidade               AS decimal
	WSDATA   nCodigoStatus             AS int
	WSDATA   cStatus                   AS string OPTIONAL
	WSDATA   cAcondicionadoEm          AS string OPTIONAL
	WSDATA   oWSItensColetados         AS sivirafullWebService_ArrayOfItemColeta OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT sivirafullWebService_RetornoColeta
	::Init()
Return Self

WSMETHOD INIT WSCLIENT sivirafullWebService_RetornoColeta
Return

WSMETHOD CLONE WSCLIENT sivirafullWebService_RetornoColeta
	Local oClone := sivirafullWebService_RetornoColeta():NEW()
	oClone:cCodigo              := ::cCodigo
	oClone:cNumero              := ::cNumero
	oClone:cNome                := ::cNome
	oClone:cTipo                := ::cTipo
	oClone:nSequencia           := ::nSequencia
	oClone:nLatitude            := ::nLatitude
	oClone:nLongitude           := ::nLongitude
	oClone:cInicioColeta        := ::cInicioColeta
	oClone:cConclusaoColeta     := ::cConclusaoColeta
	oClone:nTemperatura         := ::nTemperatura
	oClone:cInformacaoExtra     := ::cInformacaoExtra
	oClone:nQuantidade          := ::nQuantidade
	oClone:nCodigoStatus        := ::nCodigoStatus
	oClone:cStatus              := ::cStatus
	oClone:cAcondicionadoEm     := ::cAcondicionadoEm
	oClone:oWSItensColetados    := IIF(::oWSItensColetados = NIL , NIL , ::oWSItensColetados:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT sivirafullWebService_RetornoColeta
	Local oNode16
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cCodigo            :=  WSAdvValue( oResponse,"_CODIGO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cNumero            :=  WSAdvValue( oResponse,"_NUMERO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cNome              :=  WSAdvValue( oResponse,"_NOME","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cTipo              :=  WSAdvValue( oResponse,"_TIPO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nSequencia         :=  WSAdvValue( oResponse,"_SEQUENCIA","int",NIL,"Property nSequencia as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nLatitude          :=  WSAdvValue( oResponse,"_LATITUDE","decimal",NIL,"Property nLatitude as s:decimal on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nLongitude         :=  WSAdvValue( oResponse,"_LONGITUDE","decimal",NIL,"Property nLongitude as s:decimal on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cInicioColeta      :=  WSAdvValue( oResponse,"_INICIOCOLETA","dateTime",NIL,"Property cInicioColeta as s:dateTime on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cConclusaoColeta   :=  WSAdvValue( oResponse,"_CONCLUSAOCOLETA","dateTime",NIL,"Property cConclusaoColeta as s:dateTime on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::nTemperatura       :=  WSAdvValue( oResponse,"_TEMPERATURA","decimal",NIL,"Property nTemperatura as s:decimal on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cInformacaoExtra   :=  WSAdvValue( oResponse,"_INFORMACAOEXTRA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nQuantidade        :=  WSAdvValue( oResponse,"_QUANTIDADE","decimal",NIL,"Property nQuantidade as s:decimal on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nCodigoStatus      :=  WSAdvValue( oResponse,"_CODIGOSTATUS","int",NIL,"Property nCodigoStatus as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cStatus            :=  WSAdvValue( oResponse,"_STATUS","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cAcondicionadoEm   :=  WSAdvValue( oResponse,"_ACONDICIONADOEM","string",NIL,NIL,NIL,"S",NIL,NIL) 
	oNode16 :=  WSAdvValue( oResponse,"_ITENSCOLETADOS","ArrayOfItemColeta",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode16 != NIL
		::oWSItensColetados := sivirafullWebService_ArrayOfItemColeta():New()
		::oWSItensColetados:SoapRecv(oNode16)
	EndIf
Return

// WSDL Data Structure ArrayOfItemDevolucao

WSSTRUCT sivirafullWebService_ArrayOfItemDevolucao
	WSDATA   oWSItemDevolucao          AS sivirafullWebService_ItemDevolucao OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT sivirafullWebService_ArrayOfItemDevolucao
	::Init()
Return Self

WSMETHOD INIT WSCLIENT sivirafullWebService_ArrayOfItemDevolucao
	::oWSItemDevolucao     := {} // Array Of  sivirafullWebService_ITEMDEVOLUCAO():New()
Return

WSMETHOD CLONE WSCLIENT sivirafullWebService_ArrayOfItemDevolucao
	Local oClone := sivirafullWebService_ArrayOfItemDevolucao():NEW()
	oClone:oWSItemDevolucao := NIL
	If ::oWSItemDevolucao <> NIL 
		oClone:oWSItemDevolucao := {}
		aEval( ::oWSItemDevolucao , { |x| aadd( oClone:oWSItemDevolucao , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT sivirafullWebService_ArrayOfItemDevolucao
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_ITEMDEVOLUCAO","ItemDevolucao",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSItemDevolucao , sivirafullWebService_ItemDevolucao():New() )
			::oWSItemDevolucao[len(::oWSItemDevolucao)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure CoordenadaRoteiro

WSSTRUCT sivirafullWebService_CoordenadaRoteiro
	WSDATA   nLatitude                 AS decimal
	WSDATA   nLongitude                AS decimal
	WSDATA   nOrderm                   AS int
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT sivirafullWebService_CoordenadaRoteiro
	::Init()
Return Self

WSMETHOD INIT WSCLIENT sivirafullWebService_CoordenadaRoteiro
Return

WSMETHOD CLONE WSCLIENT sivirafullWebService_CoordenadaRoteiro
	Local oClone := sivirafullWebService_CoordenadaRoteiro():NEW()
	oClone:nLatitude            := ::nLatitude
	oClone:nLongitude           := ::nLongitude
	oClone:nOrderm              := ::nOrderm
Return oClone

WSMETHOD SOAPSEND WSCLIENT sivirafullWebService_CoordenadaRoteiro
	Local cSoap := ""
	cSoap += WSSoapValue("Latitude", ::nLatitude, ::nLatitude , "decimal", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Longitude", ::nLongitude, ::nLongitude , "decimal", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Orderm", ::nOrderm, ::nOrderm , "int", .T. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

// WSDL Data Structure ArrayOfItemAnomalia

WSSTRUCT sivirafullWebService_ArrayOfItemAnomalia
	WSDATA   oWSItemAnomalia           AS sivirafullWebService_ItemAnomalia OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT sivirafullWebService_ArrayOfItemAnomalia
	::Init()
Return Self

WSMETHOD INIT WSCLIENT sivirafullWebService_ArrayOfItemAnomalia
	::oWSItemAnomalia      := {} // Array Of  sivirafullWebService_ITEMANOMALIA():New()
Return

WSMETHOD CLONE WSCLIENT sivirafullWebService_ArrayOfItemAnomalia
	Local oClone := sivirafullWebService_ArrayOfItemAnomalia():NEW()
	oClone:oWSItemAnomalia := NIL
	If ::oWSItemAnomalia <> NIL 
		oClone:oWSItemAnomalia := {}
		aEval( ::oWSItemAnomalia , { |x| aadd( oClone:oWSItemAnomalia , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT sivirafullWebService_ArrayOfItemAnomalia
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_ITEMANOMALIA","ItemAnomalia",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSItemAnomalia , sivirafullWebService_ItemAnomalia():New() )
			::oWSItemAnomalia[len(::oWSItemAnomalia)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ArrayOfItemPedido

WSSTRUCT sivirafullWebService_ArrayOfItemPedido
	WSDATA   oWSItemPedido             AS sivirafullWebService_ItemPedido OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT sivirafullWebService_ArrayOfItemPedido
	::Init()
Return Self

WSMETHOD INIT WSCLIENT sivirafullWebService_ArrayOfItemPedido
	::oWSItemPedido        := {} // Array Of  sivirafullWebService_ITEMPEDIDO():New()
Return

WSMETHOD CLONE WSCLIENT sivirafullWebService_ArrayOfItemPedido
	Local oClone := sivirafullWebService_ArrayOfItemPedido():NEW()
	oClone:oWSItemPedido := NIL
	If ::oWSItemPedido <> NIL 
		oClone:oWSItemPedido := {}
		aEval( ::oWSItemPedido , { |x| aadd( oClone:oWSItemPedido , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT sivirafullWebService_ArrayOfItemPedido
	Local cSoap := ""
	aEval( ::oWSItemPedido , {|x| cSoap := cSoap  +  WSSoapValue("ItemPedido", x , x , "ItemPedido", .F. , .F., 0 , NIL, .F.,.F.)  } ) 
Return cSoap

// WSDL Data Structure ArrayOfItemRoteiro

WSSTRUCT sivirafullWebService_ArrayOfItemRoteiro
	WSDATA   oWSItemRoteiro            AS sivirafullWebService_ItemRoteiro OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT sivirafullWebService_ArrayOfItemRoteiro
	::Init()
Return Self

WSMETHOD INIT WSCLIENT sivirafullWebService_ArrayOfItemRoteiro
	::oWSItemRoteiro       := {} // Array Of  sivirafullWebService_ITEMROTEIRO():New()
Return

WSMETHOD CLONE WSCLIENT sivirafullWebService_ArrayOfItemRoteiro
	Local oClone := sivirafullWebService_ArrayOfItemRoteiro():NEW()
	oClone:oWSItemRoteiro := NIL
	If ::oWSItemRoteiro <> NIL 
		oClone:oWSItemRoteiro := {}
		aEval( ::oWSItemRoteiro , { |x| aadd( oClone:oWSItemRoteiro , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT sivirafullWebService_ArrayOfItemRoteiro
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_ITEMROTEIRO","ItemRoteiro",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSItemRoteiro , sivirafullWebService_ItemRoteiro():New() )
			::oWSItemRoteiro[len(::oWSItemRoteiro)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure EntregaPlanejada

WSSTRUCT sivirafullWebService_EntregaPlanejada
	WSDATA   nId                       AS int
	WSDATA   cDataCriacao              AS dateTime
	WSDATA   cCodigoCliente            AS string OPTIONAL
	WSDATA   nIdReferencia             AS int
	WSDATA   nPesoTotal                AS decimal
	WSDATA   nPesoLiquidoTotal         AS decimal
	WSDATA   nCubagemTotal             AS decimal
	WSDATA   nValorTotal               AS decimal
	WSDATA   nQtdCaixas                AS int
	WSDATA   nSequencia                AS int
	WSDATA   cObservacoes              AS string OPTIONAL
	WSDATA   nStatus                   AS int
	WSDATA   cEstimativaInicio         AS dateTime
	WSDATA   cEstimativaFim            AS dateTime
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT sivirafullWebService_EntregaPlanejada
	::Init()
Return Self

WSMETHOD INIT WSCLIENT sivirafullWebService_EntregaPlanejada
Return

WSMETHOD CLONE WSCLIENT sivirafullWebService_EntregaPlanejada
	Local oClone := sivirafullWebService_EntregaPlanejada():NEW()
	oClone:nId                  := ::nId
	oClone:cDataCriacao         := ::cDataCriacao
	oClone:cCodigoCliente       := ::cCodigoCliente
	oClone:nIdReferencia        := ::nIdReferencia
	oClone:nPesoTotal           := ::nPesoTotal
	oClone:nPesoLiquidoTotal    := ::nPesoLiquidoTotal
	oClone:nCubagemTotal        := ::nCubagemTotal
	oClone:nValorTotal          := ::nValorTotal
	oClone:nQtdCaixas           := ::nQtdCaixas
	oClone:nSequencia           := ::nSequencia
	oClone:cObservacoes         := ::cObservacoes
	oClone:nStatus              := ::nStatus
	oClone:cEstimativaInicio    := ::cEstimativaInicio
	oClone:cEstimativaFim       := ::cEstimativaFim
Return oClone

WSMETHOD SOAPSEND WSCLIENT sivirafullWebService_EntregaPlanejada
	Local cSoap := ""
	cSoap += WSSoapValue("Id", ::nId, ::nId , "int", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("DataCriacao", ::cDataCriacao, ::cDataCriacao , "dateTime", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CodigoCliente", ::cCodigoCliente, ::cCodigoCliente , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("IdReferencia", ::nIdReferencia, ::nIdReferencia , "int", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("PesoTotal", ::nPesoTotal, ::nPesoTotal , "decimal", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("PesoLiquidoTotal", ::nPesoLiquidoTotal, ::nPesoLiquidoTotal , "decimal", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CubagemTotal", ::nCubagemTotal, ::nCubagemTotal , "decimal", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ValorTotal", ::nValorTotal, ::nValorTotal , "decimal", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("QtdCaixas", ::nQtdCaixas, ::nQtdCaixas , "int", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Sequencia", ::nSequencia, ::nSequencia , "int", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Observacoes", ::cObservacoes, ::cObservacoes , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Status", ::nStatus, ::nStatus , "int", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("EstimativaInicio", ::cEstimativaInicio, ::cEstimativaInicio , "dateTime", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("EstimativaFim", ::cEstimativaFim, ::cEstimativaFim , "dateTime", .T. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

// WSDL Data Structure GradeDiaria

WSSTRUCT sivirafullWebService_GradeDiaria
	WSDATA   nDiaSemana                AS int
	WSDATA   cTipoAtendimento          AS string OPTIONAL
	WSDATA   nPeriodo                  AS int
	WSDATA   cInicio                   AS dateTime
	WSDATA   cTermino                  AS dateTime
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT sivirafullWebService_GradeDiaria
	::Init()
Return Self

WSMETHOD INIT WSCLIENT sivirafullWebService_GradeDiaria
Return

WSMETHOD CLONE WSCLIENT sivirafullWebService_GradeDiaria
	Local oClone := sivirafullWebService_GradeDiaria():NEW()
	oClone:nDiaSemana           := ::nDiaSemana
	oClone:cTipoAtendimento     := ::cTipoAtendimento
	oClone:nPeriodo             := ::nPeriodo
	oClone:cInicio              := ::cInicio
	oClone:cTermino             := ::cTermino
Return oClone

WSMETHOD SOAPSEND WSCLIENT sivirafullWebService_GradeDiaria
	Local cSoap := ""
	cSoap += WSSoapValue("DiaSemana", ::nDiaSemana, ::nDiaSemana , "int", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("TipoAtendimento", ::cTipoAtendimento, ::cTipoAtendimento , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Periodo", ::nPeriodo, ::nPeriodo , "int", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Inicio", ::cInicio, ::cInicio , "dateTime", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Termino", ::cTermino, ::cTermino , "dateTime", .T. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

// WSDL Data Structure ArrayOfNotaFiscal

WSSTRUCT sivirafullWebService_ArrayOfNotaFiscal
	WSDATA   oWSNotaFiscal             AS sivirafullWebService_NotaFiscal OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT sivirafullWebService_ArrayOfNotaFiscal
	::Init()
Return Self

WSMETHOD INIT WSCLIENT sivirafullWebService_ArrayOfNotaFiscal
	::oWSNotaFiscal        := {} // Array Of  sivirafullWebService_NOTAFISCAL():New()
Return

WSMETHOD CLONE WSCLIENT sivirafullWebService_ArrayOfNotaFiscal
	Local oClone := sivirafullWebService_ArrayOfNotaFiscal():NEW()
	oClone:oWSNotaFiscal := NIL
	If ::oWSNotaFiscal <> NIL 
		oClone:oWSNotaFiscal := {}
		aEval( ::oWSNotaFiscal , { |x| aadd( oClone:oWSNotaFiscal , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT sivirafullWebService_ArrayOfNotaFiscal
	Local cSoap := ""
	aEval( ::oWSNotaFiscal , {|x| cSoap := cSoap  +  WSSoapValue("NotaFiscal", x , x , "NotaFiscal", .F. , .F., 0 , NIL, .F.,.F.)  } ) 
Return cSoap

// WSDL Data Structure ArrayOfCustoAdicionalPrevisto

WSSTRUCT sivirafullWebService_ArrayOfCustoAdicionalPrevisto
	WSDATA   oWSCustoAdicionalPrevisto AS sivirafullWebService_CustoAdicionalPrevisto OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT sivirafullWebService_ArrayOfCustoAdicionalPrevisto
	::Init()
Return Self

WSMETHOD INIT WSCLIENT sivirafullWebService_ArrayOfCustoAdicionalPrevisto
	::oWSCustoAdicionalPrevisto := {} // Array Of  sivirafullWebService_CUSTOADICIONALPREVISTO():New()
Return

WSMETHOD CLONE WSCLIENT sivirafullWebService_ArrayOfCustoAdicionalPrevisto
	Local oClone := sivirafullWebService_ArrayOfCustoAdicionalPrevisto():NEW()
	oClone:oWSCustoAdicionalPrevisto := NIL
	If ::oWSCustoAdicionalPrevisto <> NIL 
		oClone:oWSCustoAdicionalPrevisto := {}
		aEval( ::oWSCustoAdicionalPrevisto , { |x| aadd( oClone:oWSCustoAdicionalPrevisto , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT sivirafullWebService_ArrayOfCustoAdicionalPrevisto
	Local cSoap := ""
	aEval( ::oWSCustoAdicionalPrevisto , {|x| cSoap := cSoap  +  WSSoapValue("CustoAdicionalPrevisto", x , x , "CustoAdicionalPrevisto", .F. , .F., 0 , NIL, .F.,.F.)  } ) 
Return cSoap

// WSDL Data Structure ArrayOfItemColeta

WSSTRUCT sivirafullWebService_ArrayOfItemColeta
	WSDATA   oWSItemColeta             AS sivirafullWebService_ItemColeta OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT sivirafullWebService_ArrayOfItemColeta
	::Init()
Return Self

WSMETHOD INIT WSCLIENT sivirafullWebService_ArrayOfItemColeta
	::oWSItemColeta        := {} // Array Of  sivirafullWebService_ITEMCOLETA():New()
Return

WSMETHOD CLONE WSCLIENT sivirafullWebService_ArrayOfItemColeta
	Local oClone := sivirafullWebService_ArrayOfItemColeta():NEW()
	oClone:oWSItemColeta := NIL
	If ::oWSItemColeta <> NIL 
		oClone:oWSItemColeta := {}
		aEval( ::oWSItemColeta , { |x| aadd( oClone:oWSItemColeta , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT sivirafullWebService_ArrayOfItemColeta
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_ITEMCOLETA","ItemColeta",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSItemColeta , sivirafullWebService_ItemColeta():New() )
			::oWSItemColeta[len(::oWSItemColeta)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ItemDevolucao

WSSTRUCT sivirafullWebService_ItemDevolucao
	WSDATA   cCodigo                   AS string OPTIONAL
	WSDATA   nQtdeDevolvida            AS decimal
	WSDATA   nValorDevolvido           AS decimal
	WSDATA   nPesoBrutoDevolvido       AS decimal
	WSDATA   nPesoLiquidoDevolvido     AS decimal
	WSDATA   nCubagemDevolida          AS decimal
	WSDATA   cNFDevolucao              AS string OPTIONAL
	WSDATA   cSerieNFDevolucao         AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT sivirafullWebService_ItemDevolucao
	::Init()
Return Self

WSMETHOD INIT WSCLIENT sivirafullWebService_ItemDevolucao
Return

WSMETHOD CLONE WSCLIENT sivirafullWebService_ItemDevolucao
	Local oClone := sivirafullWebService_ItemDevolucao():NEW()
	oClone:cCodigo              := ::cCodigo
	oClone:nQtdeDevolvida       := ::nQtdeDevolvida
	oClone:nValorDevolvido      := ::nValorDevolvido
	oClone:nPesoBrutoDevolvido  := ::nPesoBrutoDevolvido
	oClone:nPesoLiquidoDevolvido := ::nPesoLiquidoDevolvido
	oClone:nCubagemDevolida     := ::nCubagemDevolida
	oClone:cNFDevolucao         := ::cNFDevolucao
	oClone:cSerieNFDevolucao    := ::cSerieNFDevolucao
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT sivirafullWebService_ItemDevolucao
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cCodigo            :=  WSAdvValue( oResponse,"_CODIGO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nQtdeDevolvida     :=  WSAdvValue( oResponse,"_QTDEDEVOLVIDA","decimal",NIL,"Property nQtdeDevolvida as s:decimal on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nValorDevolvido    :=  WSAdvValue( oResponse,"_VALORDEVOLVIDO","decimal",NIL,"Property nValorDevolvido as s:decimal on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nPesoBrutoDevolvido :=  WSAdvValue( oResponse,"_PESOBRUTODEVOLVIDO","decimal",NIL,"Property nPesoBrutoDevolvido as s:decimal on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nPesoLiquidoDevolvido :=  WSAdvValue( oResponse,"_PESOLIQUIDODEVOLVIDO","decimal",NIL,"Property nPesoLiquidoDevolvido as s:decimal on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nCubagemDevolida   :=  WSAdvValue( oResponse,"_CUBAGEMDEVOLIDA","decimal",NIL,"Property nCubagemDevolida as s:decimal on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cNFDevolucao       :=  WSAdvValue( oResponse,"_NFDEVOLUCAO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cSerieNFDevolucao  :=  WSAdvValue( oResponse,"_SERIENFDEVOLUCAO","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure ItemAnomalia

WSSTRUCT sivirafullWebService_ItemAnomalia
	WSDATA   cCodigo                   AS string OPTIONAL
	WSDATA   nQtdeDevolvida            AS decimal
	WSDATA   nPesoBrutoDevolvido       AS decimal
	WSDATA   nPesoLiquidoDevolvido     AS decimal
	WSDATA   cNFDevolucao              AS string OPTIONAL
	WSDATA   cSerieNFDevolucao         AS string OPTIONAL
	WSDATA   cCodigoMotivoItem         AS string OPTIONAL
	WSDATA   cMotivoItem               AS string OPTIONAL
	WSDATA   nIdSetor                  AS int
	WSDATA   cSetor                    AS string OPTIONAL
	WSDATA   nIdArea                   AS int
	WSDATA   cArea                     AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT sivirafullWebService_ItemAnomalia
	::Init()
Return Self

WSMETHOD INIT WSCLIENT sivirafullWebService_ItemAnomalia
Return

WSMETHOD CLONE WSCLIENT sivirafullWebService_ItemAnomalia
	Local oClone := sivirafullWebService_ItemAnomalia():NEW()
	oClone:cCodigo              := ::cCodigo
	oClone:nQtdeDevolvida       := ::nQtdeDevolvida
	oClone:nPesoBrutoDevolvido  := ::nPesoBrutoDevolvido
	oClone:nPesoLiquidoDevolvido := ::nPesoLiquidoDevolvido
	oClone:cNFDevolucao         := ::cNFDevolucao
	oClone:cSerieNFDevolucao    := ::cSerieNFDevolucao
	oClone:cCodigoMotivoItem    := ::cCodigoMotivoItem
	oClone:cMotivoItem          := ::cMotivoItem
	oClone:nIdSetor             := ::nIdSetor
	oClone:cSetor               := ::cSetor
	oClone:nIdArea              := ::nIdArea
	oClone:cArea                := ::cArea
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT sivirafullWebService_ItemAnomalia
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cCodigo            :=  WSAdvValue( oResponse,"_CODIGO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nQtdeDevolvida     :=  WSAdvValue( oResponse,"_QTDEDEVOLVIDA","decimal",NIL,"Property nQtdeDevolvida as s:decimal on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nPesoBrutoDevolvido :=  WSAdvValue( oResponse,"_PESOBRUTODEVOLVIDO","decimal",NIL,"Property nPesoBrutoDevolvido as s:decimal on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nPesoLiquidoDevolvido :=  WSAdvValue( oResponse,"_PESOLIQUIDODEVOLVIDO","decimal",NIL,"Property nPesoLiquidoDevolvido as s:decimal on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cNFDevolucao       :=  WSAdvValue( oResponse,"_NFDEVOLUCAO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cSerieNFDevolucao  :=  WSAdvValue( oResponse,"_SERIENFDEVOLUCAO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cCodigoMotivoItem  :=  WSAdvValue( oResponse,"_CODIGOMOTIVOITEM","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cMotivoItem        :=  WSAdvValue( oResponse,"_MOTIVOITEM","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nIdSetor           :=  WSAdvValue( oResponse,"_IDSETOR","int",NIL,"Property nIdSetor as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cSetor             :=  WSAdvValue( oResponse,"_SETOR","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nIdArea            :=  WSAdvValue( oResponse,"_IDAREA","int",NIL,"Property nIdArea as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cArea              :=  WSAdvValue( oResponse,"_AREA","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure ItemPedido

WSSTRUCT sivirafullWebService_ItemPedido
	WSDATA   cCodigo                   AS string OPTIONAL
	WSDATA   cDescricao                AS string OPTIONAL
	WSDATA   cUnidade                  AS string OPTIONAL
	WSDATA   nQuantidade               AS double
	WSDATA   nCubagem                  AS double
	WSDATA   nPesoLiquido              AS double
	WSDATA   nPesoBruto                AS double
	WSDATA   nValorUnitario            AS double
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT sivirafullWebService_ItemPedido
	::Init()
Return Self

WSMETHOD INIT WSCLIENT sivirafullWebService_ItemPedido
Return

WSMETHOD CLONE WSCLIENT sivirafullWebService_ItemPedido
	Local oClone := sivirafullWebService_ItemPedido():NEW()
	oClone:cCodigo              := ::cCodigo
	oClone:cDescricao           := ::cDescricao
	oClone:cUnidade             := ::cUnidade
	oClone:nQuantidade          := ::nQuantidade
	oClone:nCubagem             := ::nCubagem
	oClone:nPesoLiquido         := ::nPesoLiquido
	oClone:nPesoBruto           := ::nPesoBruto
	oClone:nValorUnitario       := ::nValorUnitario
Return oClone

WSMETHOD SOAPSEND WSCLIENT sivirafullWebService_ItemPedido
	Local cSoap := ""
	cSoap += WSSoapValue("Codigo", ::cCodigo, ::cCodigo , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Descricao", ::cDescricao, ::cDescricao , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Unidade", ::cUnidade, ::cUnidade , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Quantidade", ::nQuantidade, ::nQuantidade , "double", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Cubagem", ::nCubagem, ::nCubagem , "double", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("PesoLiquido", ::nPesoLiquido, ::nPesoLiquido , "double", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("PesoBruto", ::nPesoBruto, ::nPesoBruto , "double", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ValorUnitario", ::nValorUnitario, ::nValorUnitario , "double", .T. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

// WSDL Data Structure ItemRoteiro

WSSTRUCT sivirafullWebService_ItemRoteiro
	WSDATA   nId                       AS int
	WSDATA   cNumeroPedido             AS string OPTIONAL
	WSDATA   nIdEmbarcador             AS int
	WSDATA   nIdUNidade                AS int
	WSDATA   nIdRemetente              AS int
	WSDATA   cBaseCarregamento         AS string OPTIONAL
	WSDATA   cOrdemCarregamento        AS string OPTIONAL
	WSDATA   cCodigoCliente            AS string OPTIONAL
	WSDATA   nSequencia                AS int
	WSDATA   oWSCompartimentos         AS sivirafullWebService_ArrayOfItemRoteiroCompartimento OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT sivirafullWebService_ItemRoteiro
	::Init()
Return Self

WSMETHOD INIT WSCLIENT sivirafullWebService_ItemRoteiro
Return

WSMETHOD CLONE WSCLIENT sivirafullWebService_ItemRoteiro
	Local oClone := sivirafullWebService_ItemRoteiro():NEW()
	oClone:nId                  := ::nId
	oClone:cNumeroPedido        := ::cNumeroPedido
	oClone:nIdEmbarcador        := ::nIdEmbarcador
	oClone:nIdUNidade           := ::nIdUNidade
	oClone:nIdRemetente         := ::nIdRemetente
	oClone:cBaseCarregamento    := ::cBaseCarregamento
	oClone:cOrdemCarregamento   := ::cOrdemCarregamento
	oClone:cCodigoCliente       := ::cCodigoCliente
	oClone:nSequencia           := ::nSequencia
	oClone:oWSCompartimentos    := IIF(::oWSCompartimentos = NIL , NIL , ::oWSCompartimentos:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT sivirafullWebService_ItemRoteiro
	Local oNode10
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::nId                :=  WSAdvValue( oResponse,"_ID","int",NIL,"Property nId as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cNumeroPedido      :=  WSAdvValue( oResponse,"_NUMEROPEDIDO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nIdEmbarcador      :=  WSAdvValue( oResponse,"_IDEMBARCADOR","int",NIL,"Property nIdEmbarcador as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nIdUNidade         :=  WSAdvValue( oResponse,"_IDUNIDADE","int",NIL,"Property nIdUNidade as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nIdRemetente       :=  WSAdvValue( oResponse,"_IDREMETENTE","int",NIL,"Property nIdRemetente as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cBaseCarregamento  :=  WSAdvValue( oResponse,"_BASECARREGAMENTO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cOrdemCarregamento :=  WSAdvValue( oResponse,"_ORDEMCARREGAMENTO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cCodigoCliente     :=  WSAdvValue( oResponse,"_CODIGOCLIENTE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nSequencia         :=  WSAdvValue( oResponse,"_SEQUENCIA","int",NIL,"Property nSequencia as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	oNode10 :=  WSAdvValue( oResponse,"_COMPARTIMENTOS","ArrayOfItemRoteiroCompartimento",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode10 != NIL
		::oWSCompartimentos := sivirafullWebService_ArrayOfItemRoteiroCompartimento():New()
		::oWSCompartimentos:SoapRecv(oNode10)
	EndIf
Return

// WSDL Data Structure NotaFiscal

WSSTRUCT sivirafullWebService_NotaFiscal
	WSDATA   nSequencia                AS short
	WSDATA   cNumero                   AS string OPTIONAL
	WSDATA   nSerie                    AS int
	WSDATA   cTipoOperacao             AS string OPTIONAL
	WSDATA   cReferencia               AS string OPTIONAL
	WSDATA   cEstimativaInicio         AS dateTime
	WSDATA   cEstimativaFim            AS dateTime
	WSDATA   nPeso                     AS decimal
	WSDATA   nPesoLiquido              AS decimal
	WSDATA   nCubagem                  AS decimal
	WSDATA   nValor                    AS decimal
	WSDATA   cObservacoes              AS string OPTIONAL
	WSDATA   cCodigoVendedor           AS string OPTIONAL
	WSDATA   cCodigoPromotor           AS string OPTIONAL
	WSDATA   cCodigoSupervisor         AS string OPTIONAL
	WSDATA   cCodigoGerente            AS string OPTIONAL
	WSDATA   cIdVendedor               AS string OPTIONAL
	WSDATA   cNomeVendedor             AS string OPTIONAL
	WSDATA   cFoneVendedor             AS string OPTIONAL
	WSDATA   cEmailVendedor            AS string OPTIONAL
	WSDATA   cNomeSupervisor           AS string OPTIONAL
	WSDATA   cFoneSupervisor           AS string OPTIONAL
	WSDATA   cEmailSupervisor          AS string OPTIONAL
	WSDATA   cIdPromotor               AS string OPTIONAL
	WSDATA   cNomePromotor             AS string OPTIONAL
	WSDATA   cFonePromotor             AS string OPTIONAL
	WSDATA   cEmailPromotor            AS string OPTIONAL
	WSDATA   cIdGerente                AS string OPTIONAL
	WSDATA   cNomeGerente              AS string OPTIONAL
	WSDATA   cFoneGerente              AS string OPTIONAL
	WSDATA   cEmailGerente             AS string OPTIONAL
	WSDATA   cProjeto                  AS string OPTIONAL
	WSDATA   nIdProjeto                AS int
	WSDATA   nPrioridade               AS int
	WSDATA   oWSItens                  AS sivirafullWebService_ArrayOfItem OPTIONAL
	WSDATA   nDivisaoEmpresarial       AS int
	WSDATA   cNumeroOrdem              AS string OPTIONAL
	WSDATA   nQtdCaixas                AS int
	WSDATA   lOrdemEspecial            AS boolean
	WSDATA   nNumeroPedido             AS int
	WSDATA   cIdentificadorPedido      AS string OPTIONAL
	WSDATA   nRemetente                AS int
	WSDATA   cCNPJRemetente            AS string OPTIONAL
	WSDATA   cNumeroCTE                AS string OPTIONAL
	WSDATA   nValorCTE                 AS decimal
	WSDATA   cDataEmissaoCTE           AS dateTime
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT sivirafullWebService_NotaFiscal
	::Init()
Return Self

WSMETHOD INIT WSCLIENT sivirafullWebService_NotaFiscal
Return

WSMETHOD CLONE WSCLIENT sivirafullWebService_NotaFiscal
	Local oClone := sivirafullWebService_NotaFiscal():NEW()
	oClone:nSequencia           := ::nSequencia
	oClone:cNumero              := ::cNumero
	oClone:nSerie               := ::nSerie
	oClone:cTipoOperacao        := ::cTipoOperacao
	oClone:cReferencia          := ::cReferencia
	oClone:cEstimativaInicio    := ::cEstimativaInicio
	oClone:cEstimativaFim       := ::cEstimativaFim
	oClone:nPeso                := ::nPeso
	oClone:nPesoLiquido         := ::nPesoLiquido
	oClone:nCubagem             := ::nCubagem
	oClone:nValor               := ::nValor
	oClone:cObservacoes         := ::cObservacoes
	oClone:cCodigoVendedor      := ::cCodigoVendedor
	oClone:cCodigoPromotor      := ::cCodigoPromotor
	oClone:cCodigoSupervisor    := ::cCodigoSupervisor
	oClone:cCodigoGerente       := ::cCodigoGerente
	oClone:cIdVendedor          := ::cIdVendedor
	oClone:cNomeVendedor        := ::cNomeVendedor
	oClone:cFoneVendedor        := ::cFoneVendedor
	oClone:cEmailVendedor       := ::cEmailVendedor
	oClone:cNomeSupervisor      := ::cNomeSupervisor
	oClone:cFoneSupervisor      := ::cFoneSupervisor
	oClone:cEmailSupervisor     := ::cEmailSupervisor
	oClone:cIdPromotor          := ::cIdPromotor
	oClone:cNomePromotor        := ::cNomePromotor
	oClone:cFonePromotor        := ::cFonePromotor
	oClone:cEmailPromotor       := ::cEmailPromotor
	oClone:cIdGerente           := ::cIdGerente
	oClone:cNomeGerente         := ::cNomeGerente
	oClone:cFoneGerente         := ::cFoneGerente
	oClone:cEmailGerente        := ::cEmailGerente
	oClone:cProjeto             := ::cProjeto
	oClone:nIdProjeto           := ::nIdProjeto
	oClone:nPrioridade          := ::nPrioridade
	oClone:oWSItens             := IIF(::oWSItens = NIL , NIL , ::oWSItens:Clone() )
	oClone:nDivisaoEmpresarial  := ::nDivisaoEmpresarial
	oClone:cNumeroOrdem         := ::cNumeroOrdem
	oClone:nQtdCaixas           := ::nQtdCaixas
	oClone:lOrdemEspecial       := ::lOrdemEspecial
	oClone:nNumeroPedido        := ::nNumeroPedido
	oClone:cIdentificadorPedido := ::cIdentificadorPedido
	oClone:nRemetente           := ::nRemetente
	oClone:cCNPJRemetente       := ::cCNPJRemetente
	oClone:cNumeroCTE           := ::cNumeroCTE
	oClone:nValorCTE            := ::nValorCTE
	oClone:cDataEmissaoCTE      := ::cDataEmissaoCTE
Return oClone

WSMETHOD SOAPSEND WSCLIENT sivirafullWebService_NotaFiscal
	Local cSoap := ""
	cSoap += WSSoapValue("Sequencia", ::nSequencia, ::nSequencia , "short", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Numero", ::cNumero, ::cNumero , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Serie", ::nSerie, ::nSerie , "int", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("TipoOperacao", ::cTipoOperacao, ::cTipoOperacao , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Referencia", ::cReferencia, ::cReferencia , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("EstimativaInicio", ::cEstimativaInicio, ::cEstimativaInicio , "dateTime", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("EstimativaFim", ::cEstimativaFim, ::cEstimativaFim , "dateTime", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Peso", ::nPeso, ::nPeso , "decimal", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("PesoLiquido", ::nPesoLiquido, ::nPesoLiquido , "decimal", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Cubagem", ::nCubagem, ::nCubagem , "decimal", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Valor", ::nValor, ::nValor , "decimal", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Observacoes", ::cObservacoes, ::cObservacoes , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CodigoVendedor", ::cCodigoVendedor, ::cCodigoVendedor , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CodigoPromotor", ::cCodigoPromotor, ::cCodigoPromotor , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CodigoSupervisor", ::cCodigoSupervisor, ::cCodigoSupervisor , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CodigoGerente", ::cCodigoGerente, ::cCodigoGerente , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("IdVendedor", ::cIdVendedor, ::cIdVendedor , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("NomeVendedor", ::cNomeVendedor, ::cNomeVendedor , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("FoneVendedor", ::cFoneVendedor, ::cFoneVendedor , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("EmailVendedor", ::cEmailVendedor, ::cEmailVendedor , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("NomeSupervisor", ::cNomeSupervisor, ::cNomeSupervisor , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("FoneSupervisor", ::cFoneSupervisor, ::cFoneSupervisor , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("EmailSupervisor", ::cEmailSupervisor, ::cEmailSupervisor , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("IdPromotor", ::cIdPromotor, ::cIdPromotor , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("NomePromotor", ::cNomePromotor, ::cNomePromotor , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("FonePromotor", ::cFonePromotor, ::cFonePromotor , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("EmailPromotor", ::cEmailPromotor, ::cEmailPromotor , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("IdGerente", ::cIdGerente, ::cIdGerente , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("NomeGerente", ::cNomeGerente, ::cNomeGerente , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("FoneGerente", ::cFoneGerente, ::cFoneGerente , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("EmailGerente", ::cEmailGerente, ::cEmailGerente , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Projeto", ::cProjeto, ::cProjeto , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("IdProjeto", ::nIdProjeto, ::nIdProjeto , "int", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Prioridade", ::nPrioridade, ::nPrioridade , "int", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Itens", ::oWSItens, ::oWSItens , "ArrayOfItem", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("DivisaoEmpresarial", ::nDivisaoEmpresarial, ::nDivisaoEmpresarial , "int", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("NumeroOrdem", ::cNumeroOrdem, ::cNumeroOrdem , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("QtdCaixas", ::nQtdCaixas, ::nQtdCaixas , "int", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("OrdemEspecial", ::lOrdemEspecial, ::lOrdemEspecial , "boolean", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("NumeroPedido", ::nNumeroPedido, ::nNumeroPedido , "int", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("IdentificadorPedido", ::cIdentificadorPedido, ::cIdentificadorPedido , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Remetente", ::nRemetente, ::nRemetente , "int", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CNPJRemetente", ::cCNPJRemetente, ::cCNPJRemetente , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("NumeroCTE", ::cNumeroCTE, ::cNumeroCTE , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ValorCTE", ::nValorCTE, ::nValorCTE , "decimal", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("DataEmissaoCTE", ::cDataEmissaoCTE, ::cDataEmissaoCTE , "dateTime", .T. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

// WSDL Data Structure CustoAdicionalPrevisto

WSSTRUCT sivirafullWebService_CustoAdicionalPrevisto
	WSDATA   nValorUnitario            AS decimal
	WSDATA   nValorTotal               AS decimal
	WSDATA   cCodigoTipoCustoAdicional AS string OPTIONAL
	WSDATA   cCodigoModalidadeDeCustoAdicional AS string OPTIONAL
	WSDATA   nModalidadeDeCustoAdicionalId AS int
	WSDATA   nTipoCustoAdicionalId     AS int
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT sivirafullWebService_CustoAdicionalPrevisto
	::Init()
Return Self

WSMETHOD INIT WSCLIENT sivirafullWebService_CustoAdicionalPrevisto
Return

WSMETHOD CLONE WSCLIENT sivirafullWebService_CustoAdicionalPrevisto
	Local oClone := sivirafullWebService_CustoAdicionalPrevisto():NEW()
	oClone:nValorUnitario       := ::nValorUnitario
	oClone:nValorTotal          := ::nValorTotal
	oClone:cCodigoTipoCustoAdicional := ::cCodigoTipoCustoAdicional
	oClone:cCodigoModalidadeDeCustoAdicional := ::cCodigoModalidadeDeCustoAdicional
	oClone:nModalidadeDeCustoAdicionalId := ::nModalidadeDeCustoAdicionalId
	oClone:nTipoCustoAdicionalId := ::nTipoCustoAdicionalId
Return oClone

WSMETHOD SOAPSEND WSCLIENT sivirafullWebService_CustoAdicionalPrevisto
	Local cSoap := ""
	cSoap += WSSoapValue("ValorUnitario", ::nValorUnitario, ::nValorUnitario , "decimal", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ValorTotal", ::nValorTotal, ::nValorTotal , "decimal", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CodigoTipoCustoAdicional", ::cCodigoTipoCustoAdicional, ::cCodigoTipoCustoAdicional , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CodigoModalidadeDeCustoAdicional", ::cCodigoModalidadeDeCustoAdicional, ::cCodigoModalidadeDeCustoAdicional , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ModalidadeDeCustoAdicionalId", ::nModalidadeDeCustoAdicionalId, ::nModalidadeDeCustoAdicionalId , "int", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("TipoCustoAdicionalId", ::nTipoCustoAdicionalId, ::nTipoCustoAdicionalId , "int", .T. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

// WSDL Data Structure ItemColeta

WSSTRUCT sivirafullWebService_ItemColeta
	WSDATA   cCodigo                   AS string OPTIONAL
	WSDATA   nQuantidade               AS decimal
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT sivirafullWebService_ItemColeta
	::Init()
Return Self

WSMETHOD INIT WSCLIENT sivirafullWebService_ItemColeta
Return

WSMETHOD CLONE WSCLIENT sivirafullWebService_ItemColeta
	Local oClone := sivirafullWebService_ItemColeta():NEW()
	oClone:cCodigo              := ::cCodigo
	oClone:nQuantidade          := ::nQuantidade
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT sivirafullWebService_ItemColeta
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cCodigo            :=  WSAdvValue( oResponse,"_CODIGO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nQuantidade        :=  WSAdvValue( oResponse,"_QUANTIDADE","decimal",NIL,"Property nQuantidade as s:decimal on SOAP Response not found.",NIL,"N",NIL,NIL) 
Return

// WSDL Data Structure ArrayOfItemRoteiroCompartimento

WSSTRUCT sivirafullWebService_ArrayOfItemRoteiroCompartimento
	WSDATA   oWSItemRoteiroCompartimento AS sivirafullWebService_ItemRoteiroCompartimento OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT sivirafullWebService_ArrayOfItemRoteiroCompartimento
	::Init()
Return Self

WSMETHOD INIT WSCLIENT sivirafullWebService_ArrayOfItemRoteiroCompartimento
	::oWSItemRoteiroCompartimento := {} // Array Of  sivirafullWebService_ITEMROTEIROCOMPARTIMENTO():New()
Return

WSMETHOD CLONE WSCLIENT sivirafullWebService_ArrayOfItemRoteiroCompartimento
	Local oClone := sivirafullWebService_ArrayOfItemRoteiroCompartimento():NEW()
	oClone:oWSItemRoteiroCompartimento := NIL
	If ::oWSItemRoteiroCompartimento <> NIL 
		oClone:oWSItemRoteiroCompartimento := {}
		aEval( ::oWSItemRoteiroCompartimento , { |x| aadd( oClone:oWSItemRoteiroCompartimento , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT sivirafullWebService_ArrayOfItemRoteiroCompartimento
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_ITEMROTEIROCOMPARTIMENTO","ItemRoteiroCompartimento",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSItemRoteiroCompartimento , sivirafullWebService_ItemRoteiroCompartimento():New() )
			::oWSItemRoteiroCompartimento[len(::oWSItemRoteiroCompartimento)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ArrayOfItem

WSSTRUCT sivirafullWebService_ArrayOfItem
	WSDATA   oWSItem                   AS sivirafullWebService_Item OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT sivirafullWebService_ArrayOfItem
	::Init()
Return Self

WSMETHOD INIT WSCLIENT sivirafullWebService_ArrayOfItem
	::oWSItem              := {} // Array Of  sivirafullWebService_ITEM():New()
Return

WSMETHOD CLONE WSCLIENT sivirafullWebService_ArrayOfItem
	Local oClone := sivirafullWebService_ArrayOfItem():NEW()
	oClone:oWSItem := NIL
	If ::oWSItem <> NIL 
		oClone:oWSItem := {}
		aEval( ::oWSItem , { |x| aadd( oClone:oWSItem , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT sivirafullWebService_ArrayOfItem
	Local cSoap := ""
	aEval( ::oWSItem , {|x| cSoap := cSoap  +  WSSoapValue("Item", x , x , "Item", .F. , .F., 0 , NIL, .F.,.F.)  } ) 
Return cSoap

// WSDL Data Structure ItemRoteiroCompartimento

WSSTRUCT sivirafullWebService_ItemRoteiroCompartimento
	WSDATA   cCarreta                  AS string OPTIONAL
	WSDATA   nCompartimento            AS int
	WSDATA   nQuantidade               AS double
	WSDATA   cCodigoProduto            AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT sivirafullWebService_ItemRoteiroCompartimento
	::Init()
Return Self

WSMETHOD INIT WSCLIENT sivirafullWebService_ItemRoteiroCompartimento
Return

WSMETHOD CLONE WSCLIENT sivirafullWebService_ItemRoteiroCompartimento
	Local oClone := sivirafullWebService_ItemRoteiroCompartimento():NEW()
	oClone:cCarreta             := ::cCarreta
	oClone:nCompartimento       := ::nCompartimento
	oClone:nQuantidade          := ::nQuantidade
	oClone:cCodigoProduto       := ::cCodigoProduto
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT sivirafullWebService_ItemRoteiroCompartimento
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cCarreta           :=  WSAdvValue( oResponse,"_CARRETA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nCompartimento     :=  WSAdvValue( oResponse,"_COMPARTIMENTO","int",NIL,"Property nCompartimento as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nQuantidade        :=  WSAdvValue( oResponse,"_QUANTIDADE","double",NIL,"Property nQuantidade as s:double on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cCodigoProduto     :=  WSAdvValue( oResponse,"_CODIGOPRODUTO","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure Item

WSSTRUCT sivirafullWebService_Item
	WSDATA   nSequencia                AS int
	WSDATA   cCodigo                   AS string OPTIONAL
	WSDATA   cDescricao                AS string OPTIONAL
	WSDATA   cUnidade                  AS string OPTIONAL
	WSDATA   nQuantidade               AS decimal
	WSDATA   nValorUnitario            AS decimal
	WSDATA   nPesoUnitario             AS decimal
	WSDATA   nPesoTotalBruto           AS decimal
	WSDATA   nPesoTotalLiquido         AS decimal
	WSDATA   nPesoLiquidoUnitario      AS decimal
	WSDATA   nCubagemUnitaria          AS decimal
	WSDATA   cLote                     AS string OPTIONAL
	WSDATA   cValidoAte                AS dateTime
	WSDATA   cFabricadoEm              AS dateTime
	WSDATA   nDiasValidade             AS int
	WSDATA   cAclimatacao              AS string OPTIONAL
	WSDATA   nPrioridade               AS int
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT sivirafullWebService_Item
	::Init()
Return Self

WSMETHOD INIT WSCLIENT sivirafullWebService_Item
Return

WSMETHOD CLONE WSCLIENT sivirafullWebService_Item
	Local oClone := sivirafullWebService_Item():NEW()
	oClone:nSequencia           := ::nSequencia
	oClone:cCodigo              := ::cCodigo
	oClone:cDescricao           := ::cDescricao
	oClone:cUnidade             := ::cUnidade
	oClone:nQuantidade          := ::nQuantidade
	oClone:nValorUnitario       := ::nValorUnitario
	oClone:nPesoUnitario        := ::nPesoUnitario
	oClone:nPesoTotalBruto      := ::nPesoTotalBruto
	oClone:nPesoTotalLiquido    := ::nPesoTotalLiquido
	oClone:nPesoLiquidoUnitario := ::nPesoLiquidoUnitario
	oClone:nCubagemUnitaria     := ::nCubagemUnitaria
	oClone:cLote                := ::cLote
	oClone:cValidoAte           := ::cValidoAte
	oClone:cFabricadoEm         := ::cFabricadoEm
	oClone:nDiasValidade        := ::nDiasValidade
	oClone:cAclimatacao         := ::cAclimatacao
	oClone:nPrioridade          := ::nPrioridade
Return oClone

WSMETHOD SOAPSEND WSCLIENT sivirafullWebService_Item
	Local cSoap := ""
	cSoap += WSSoapValue("Sequencia", ::nSequencia, ::nSequencia , "int", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Codigo", ::cCodigo, ::cCodigo , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Descricao", ::cDescricao, ::cDescricao , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Unidade", ::cUnidade, ::cUnidade , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Quantidade", ::nQuantidade, ::nQuantidade , "decimal", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ValorUnitario", ::nValorUnitario, ::nValorUnitario , "decimal", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("PesoUnitario", ::nPesoUnitario, ::nPesoUnitario , "decimal", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("PesoTotalBruto", ::nPesoTotalBruto, ::nPesoTotalBruto , "decimal", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("PesoTotalLiquido", ::nPesoTotalLiquido, ::nPesoTotalLiquido , "decimal", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("PesoLiquidoUnitario", ::nPesoLiquidoUnitario, ::nPesoLiquidoUnitario , "decimal", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CubagemUnitaria", ::nCubagemUnitaria, ::nCubagemUnitaria , "decimal", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Lote", ::cLote, ::cLote , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ValidoAte", ::cValidoAte, ::cValidoAte , "dateTime", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("FabricadoEm", ::cFabricadoEm, ::cFabricadoEm , "dateTime", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("DiasValidade", ::nDiasValidade, ::nDiasValidade , "int", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Aclimatacao", ::cAclimatacao, ::cAclimatacao , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Prioridade", ::nPrioridade, ::nPrioridade , "int", .T. , .F., 0 , NIL, .F.,.F.) 
Return cSoap
