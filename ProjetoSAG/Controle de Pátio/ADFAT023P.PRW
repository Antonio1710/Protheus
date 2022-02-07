#INCLUDE "protheus.ch"
#INCLUDE "apwebsrv.ch"

/* ===============================================================================
WSDL Location    \tmptdsvpnbn051\WS_GUARDIAN_PLUS.wsdl
Gerado em        09/09/19 10:16:11
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function ADFAT023P ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSWS_GUARDIAN
------------------------------------------------------------------------------- */

WSCLIENT WSWS_GUARDIAN

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD ImportaTicketPreCadastro
	WSMETHOD CadastraTicket
	WSMETHOD CadastraTicketGuardian
	WSMETHOD AlteraTicketGuardian
	WSMETHOD ObtemVersaoWS
	WSMETHOD ExportaTicketPeriodo
	WSMETHOD ExportaTicketsMarcados
	WSMETHOD ConfirmaLeituraTicketsMarcados
	WSMETHOD IdentificaVeiculoNoPonto
	WSMETHOD SimulaPesagemAvulsaSemAutomacao
	WSMETHOD AcionaCancela
	WSMETHOD EnviaMensagemDisplay
	WSMETHOD ConsultaPedidoDeExecucao
	WSMETHOD DadosDoTicket_G4
	WSMETHOD EnviaMensagem_G4
	WSMETHOD AcionaCancela_G4
	WSMETHOD CapturaPeso_G4
	WSMETHOD CapturaPeso
	WSMETHOD ExportaTicketParametro
	WSMETHOD ManutencaoTicket
	WSMETHOD TrocaFluxoTicket
	WSMETHOD RemontaFluxo
	WSMETHOD ConsultaLogAplicacao
	WSMETHOD ConsultaMovimentoOCR
	WSMETHOD ConsultaLogPerifericos
	WSMETHOD RefazUltimaOperacao
	WSMETHOD RefazUltimaOperacaoII
	WSMETHOD CancelaUltimaOperacaoAtiva
	WSMETHOD RefazUltimaOperacaoAtiva
	WSMETHOD ConsultaIntervencoesManuaisTicket
	WSMETHOD ConsultarLogAuditoria
	WSMETHOD ConsultaTicketsPorPeriodo
	WSMETHOD ExportaVeiculosQuePossamTerPassadoSemPesarPelaBalanca
	WSMETHOD RetornaVeiculosQuePossamTerPassadoSemPesarPelaBalanca
	WSMETHOD ConfirmaVeiculosQuePossamTerPassadoSemPesarPelaBalanca
	WSMETHOD IdentificaVagao
	WSMETHOD ConfirmaTicketUnico
	WSMETHOD ExportaTicketUnico
	WSMETHOD SolicitaFotoAvulsa
	WSMETHOD SolicitaRetornoFotoAvulsa

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   oWSDadosTicket            AS WS_GUARDIAN_PreCadastro
	WSDATA   cproduto                  AS string
	WSDATA   ccodigo                   AS string
	WSDATA   lImportaTicketPreCadastroResult AS boolean
	WSDATA   nErro                     AS int
	WSDATA   cErroMSG                  AS string
	WSDATA   lCadastraTicketResult     AS boolean
	WSDATA   oWSCadastraTicketGuardianResult AS WS_GUARDIAN_Ticket
	WSDATA   oWSCfgAlteracao           AS WS_GUARDIAN_ConfiguracaoAlteracao
	WSDATA   oWSAlteraTicketGuardianResult AS WS_GUARDIAN_Ticket
	WSDATA   cObtemVersaoWSResult      AS string
	WSDATA   cdataInicial              AS dateTime
	WSDATA   cdataFinal                AS dateTime
	WSDATA   oWSExportaTicketPeriodoResult AS WS_GUARDIAN_ArrayOfTicket
	WSDATA   oWSExportaTicketsMarcadosResult AS WS_GUARDIAN_ArrayOfTicket
	WSDATA   cPontoControle            AS string
	WSDATA   cticketCodigo             AS string
	WSDATA   cticketPlaca              AS string
	WSDATA   cticketTAG                AS string
	WSDATA   clado                     AS string
	WSDATA   nIdentificaVeiculoNoPontoResult AS int
	WSDATA   nTempoValidadePesoBom     AS int
	WSDATA   nTimeoutLeitura           AS int
	WSDATA   cComando                  AS string
	WSDATA   nAcionaCancelaResult      AS int
	WSDATA   nPosicao                  AS int
	WSDATA   cMensagem                 AS string
	WSDATA   nTempo                    AS int
	WSDATA   nEnviaMensagemDisplayResult AS int
	WSDATA   nID                       AS int
	WSDATA   nConsultaPedidoDeExecucaoResult AS int
	WSDATA   cSenha                    AS string
	WSDATA   oWSTicketEntrada          AS WS_GUARDIAN_ImportaTicketG4
	WSDATA   oWSTicketSaida            AS WS_GUARDIAN_ExportaTicketG4
	WSDATA   cTerminal                 AS string
	WSDATA   nEndereco                 AS int
	WSDATA   cCodigoRedeSpider         AS string
	WSDATA   cMensagemDisplay          AS string
	WSDATA   cTeminal                  AS string
	WSDATA   nPeso                     AS float
	WSDATA   cPontoDeControle          AS string
	WSDATA   csegmentoInicial          AS string
	WSDATA   csegmentoFinal            AS string
	WSDATA   oWSExportaTicketParametroResult AS WS_GUARDIAN_ArrayOfTicket
	WSDATA   nnumOperacao              AS int
	WSDATA   lManutencaoTicketResult   AS boolean
	WSDATA   cfluxoCodigo              AS string
	WSDATA   lTrocaFluxoTicketResult   AS boolean
	WSDATA   lRemontaFluxoResult       AS boolean
	WSDATA   ncategoria                AS int
	WSDATA   ntipo                     AS int
	WSDATA   csistemaDeIntegracao      AS string
	WSDATA   oWSConsultaLogAplicacaoResult AS WS_GUARDIAN_ArrayOfLogAplicacao
	WSDATA   cplacaOCR                 AS string
	WSDATA   cpontoControleDesc        AS string
	WSDATA   cusuarioNome              AS string
	WSDATA   oWSConsultaMovimentoOCRResult AS WS_GUARDIAN_ArrayOfTicket
	WSDATA   cOperadorLogin            AS string
	WSDATA   cBalancaDesc              AS string
	WSDATA   ncategoriaLog             AS int
	WSDATA   oWSConsultaLogPerifericosResult AS WS_GUARDIAN_ArrayOfLogPeriferico
	WSDATA   lRefazUltimaOperacaoResult AS boolean
	WSDATA   lRefazUltimaOperacaoIIResult AS boolean
	WSDATA   nSaiErro                  AS int
	WSDATA   cSaiErroMSG               AS string
	WSDATA   lCancelaUltimaOperacaoAtivaResult AS boolean
	WSDATA   lRefazUltimaOperacaoAtivaResult AS boolean
	WSDATA   oWSConsultaIntervencoesManuaisTicketResult AS SCHEMA
	WSDATA   oWSlogIN                  AS WS_GUARDIAN_ConsultaLogAuditoriaIN
	WSDATA   oWSConsultarLogAuditoriaResult AS WS_GUARDIAN_ArrayOfConsultaLogAuditoriaOUT
	WSDATA   oWSConsultaTicketsPorPeriodoResult AS WS_GUARDIAN_ArrayOfTicket
	WSDATA   oWSExportaVeiculosQuePossamTerPassadoSemPesarPelaBalancaResult AS WS_GUARDIAN_ArrayOfHistoricoPassagem
	WSDATA   cdataInicio               AS dateTime
	WSDATA   cdataFim                  AS dateTime
	WSDATA   oWSRetornaVeiculosQuePossamTerPassadoSemPesarPelaBalancaResult AS WS_GUARDIAN_ArrayOfHistoricoPassagem
	WSDATA   lConfirmaVeiculosQuePossamTerPassadoSemPesarPelaBalancaResult AS boolean
	WSDATA   oWSinfoCarregamento       AS WS_GUARDIAN_InformaCarregamento
	WSDATA   nIdentificaVagaoResult    AS int
	WSDATA   nSequencialTicket         AS int
	WSDATA   cnomeSistema              AS string
	WSDATA   lFalhou                   AS boolean
	WSDATA   lConfirmaTicketUnicoResult AS boolean
	WSDATA   lcompleta                 AS boolean
	WSDATA   lSincronizacao            AS boolean
	WSDATA   oWSExportaTicketUnicoResult AS WS_GUARDIAN_Ticket
	WSDATA   ccodigoPontoControle      AS string
	WSDATA   cposicaoCamera            AS string
	WSDATA   ccaminhoFoto              AS string
	WSDATA   cnomeFoto                 AS string
	WSDATA   nSolicitaFotoAvulsaResult AS int
	WSDATA   nidSolicitacaoAvulsa      AS int
	WSDATA   oWSSolicitaRetornoFotoAvulsaResult AS WS_GUARDIAN_RetornoFotoAvulsa

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSWS_GUARDIAN
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.131227A-20171213 NG] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
If val(right(GetWSCVer(),8)) < 1.040504
	UserException("O Código-Fonte Client atual requer a versão de Lib para WebServices igual ou superior a ADVPL WSDL Client 1.040504. Atualize o repositório ou gere o Código-Fonte novamente utilizando o repositório atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSWS_GUARDIAN
	::oWSDadosTicket     := WS_GUARDIAN_PRECADASTRO():New()
	::oWSCadastraTicketGuardianResult := WS_GUARDIAN_TICKET():New()
	::oWSCfgAlteracao    := WS_GUARDIAN_CONFIGURACAOALTERACAO():New()
	::oWSAlteraTicketGuardianResult := WS_GUARDIAN_TICKET():New()
	::oWSExportaTicketPeriodoResult := WS_GUARDIAN_ARRAYOFTICKET():New()
	::oWSExportaTicketsMarcadosResult := WS_GUARDIAN_ARRAYOFTICKET():New()
	::oWSTicketEntrada   := WS_GUARDIAN_IMPORTATICKETG4():New()
	::oWSTicketSaida     := WS_GUARDIAN_EXPORTATICKETG4():New()
	::oWSExportaTicketParametroResult := WS_GUARDIAN_ARRAYOFTICKET():New()
	::oWSConsultaLogAplicacaoResult := WS_GUARDIAN_ARRAYOFLOGAPLICACAO():New()
	::oWSConsultaMovimentoOCRResult := WS_GUARDIAN_ARRAYOFTICKET():New()
	::oWSConsultaLogPerifericosResult := WS_GUARDIAN_ARRAYOFLOGPERIFERICO():New()
	::oWSConsultaIntervencoesManuaisTicketResult := NIL 
	::oWSlogIN           := WS_GUARDIAN_CONSULTALOGAUDITORIAIN():New()
	::oWSConsultarLogAuditoriaResult := WS_GUARDIAN_ARRAYOFCONSULTALOGAUDITORIAOUT():New()
	::oWSConsultaTicketsPorPeriodoResult := WS_GUARDIAN_ARRAYOFTICKET():New()
	::oWSExportaVeiculosQuePossamTerPassadoSemPesarPelaBalancaResult := WS_GUARDIAN_ARRAYOFHISTORICOPASSAGEM():New()
	::oWSRetornaVeiculosQuePossamTerPassadoSemPesarPelaBalancaResult := WS_GUARDIAN_ARRAYOFHISTORICOPASSAGEM():New()
	::oWSinfoCarregamento := WS_GUARDIAN_INFORMACARREGAMENTO():New()
	::oWSExportaTicketUnicoResult := WS_GUARDIAN_TICKET():New()
	::oWSSolicitaRetornoFotoAvulsaResult := WS_GUARDIAN_RETORNOFOTOAVULSA():New()
Return

WSMETHOD RESET WSCLIENT WSWS_GUARDIAN
	::oWSDadosTicket     := NIL 
	::cproduto           := NIL 
	::ccodigo            := NIL 
	::lImportaTicketPreCadastroResult := NIL 
	::nErro              := NIL 
	::cErroMSG           := NIL 
	::lCadastraTicketResult := NIL 
	::oWSCadastraTicketGuardianResult := NIL 
	::oWSCfgAlteracao    := NIL 
	::oWSAlteraTicketGuardianResult := NIL 
	::cObtemVersaoWSResult := NIL 
	::cdataInicial       := NIL 
	::cdataFinal         := NIL 
	::oWSExportaTicketPeriodoResult := NIL 
	::oWSExportaTicketsMarcadosResult := NIL 
	::cPontoControle     := NIL 
	::cticketCodigo      := NIL 
	::cticketPlaca       := NIL 
	::cticketTAG         := NIL 
	::clado              := NIL 
	::nIdentificaVeiculoNoPontoResult := NIL 
	::nTempoValidadePesoBom := NIL 
	::nTimeoutLeitura    := NIL 
	::cComando           := NIL 
	::nAcionaCancelaResult := NIL 
	::nPosicao           := NIL 
	::cMensagem          := NIL 
	::nTempo             := NIL 
	::nEnviaMensagemDisplayResult := NIL 
	::nID                := NIL 
	::nConsultaPedidoDeExecucaoResult := NIL 
	::cSenha             := NIL 
	::oWSTicketEntrada   := NIL 
	::oWSTicketSaida     := NIL 
	::cTerminal          := NIL 
	::nEndereco          := NIL 
	::cCodigoRedeSpider  := NIL 
	::cMensagemDisplay   := NIL 
	::cTeminal           := NIL 
	::nPeso              := NIL 
	::cPontoDeControle   := NIL 
	::csegmentoInicial   := NIL 
	::csegmentoFinal     := NIL 
	::oWSExportaTicketParametroResult := NIL 
	::nnumOperacao       := NIL 
	::lManutencaoTicketResult := NIL 
	::cfluxoCodigo       := NIL 
	::lTrocaFluxoTicketResult := NIL 
	::lRemontaFluxoResult := NIL 
	::ncategoria         := NIL 
	::ntipo              := NIL 
	::csistemaDeIntegracao := NIL 
	::oWSConsultaLogAplicacaoResult := NIL 
	::cplacaOCR          := NIL 
	::cpontoControleDesc := NIL 
	::cusuarioNome       := NIL 
	::oWSConsultaMovimentoOCRResult := NIL 
	::cOperadorLogin     := NIL 
	::cBalancaDesc       := NIL 
	::ncategoriaLog      := NIL 
	::oWSConsultaLogPerifericosResult := NIL 
	::lRefazUltimaOperacaoResult := NIL 
	::lRefazUltimaOperacaoIIResult := NIL 
	::nSaiErro           := NIL 
	::cSaiErroMSG        := NIL 
	::lCancelaUltimaOperacaoAtivaResult := NIL 
	::lRefazUltimaOperacaoAtivaResult := NIL 
	::oWSConsultaIntervencoesManuaisTicketResult := NIL 
	::oWSlogIN           := NIL 
	::oWSConsultarLogAuditoriaResult := NIL 
	::oWSConsultaTicketsPorPeriodoResult := NIL 
	::oWSExportaVeiculosQuePossamTerPassadoSemPesarPelaBalancaResult := NIL 
	::cdataInicio        := NIL 
	::cdataFim           := NIL 
	::oWSRetornaVeiculosQuePossamTerPassadoSemPesarPelaBalancaResult := NIL 
	::lConfirmaVeiculosQuePossamTerPassadoSemPesarPelaBalancaResult := NIL 
	::oWSinfoCarregamento := NIL 
	::nIdentificaVagaoResult := NIL 
	::nSequencialTicket  := NIL 
	::cnomeSistema       := NIL 
	::lFalhou            := NIL 
	::lConfirmaTicketUnicoResult := NIL 
	::lcompleta          := NIL 
	::lSincronizacao     := NIL 
	::oWSExportaTicketUnicoResult := NIL 
	::ccodigoPontoControle := NIL 
	::cposicaoCamera     := NIL 
	::ccaminhoFoto       := NIL 
	::cnomeFoto          := NIL 
	::nSolicitaFotoAvulsaResult := NIL 
	::nidSolicitacaoAvulsa := NIL 
	::oWSSolicitaRetornoFotoAvulsaResult := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSWS_GUARDIAN
Local oClone := WSWS_GUARDIAN():New()
	oClone:_URL          := ::_URL 
	oClone:oWSDadosTicket :=  IIF(::oWSDadosTicket = NIL , NIL ,::oWSDadosTicket:Clone() )
	oClone:cproduto      := ::cproduto
	oClone:ccodigo       := ::ccodigo
	oClone:lImportaTicketPreCadastroResult := ::lImportaTicketPreCadastroResult
	oClone:nErro         := ::nErro
	oClone:cErroMSG      := ::cErroMSG
	oClone:lCadastraTicketResult := ::lCadastraTicketResult
	oClone:oWSCadastraTicketGuardianResult :=  IIF(::oWSCadastraTicketGuardianResult = NIL , NIL ,::oWSCadastraTicketGuardianResult:Clone() )
	oClone:oWSCfgAlteracao :=  IIF(::oWSCfgAlteracao = NIL , NIL ,::oWSCfgAlteracao:Clone() )
	oClone:oWSAlteraTicketGuardianResult :=  IIF(::oWSAlteraTicketGuardianResult = NIL , NIL ,::oWSAlteraTicketGuardianResult:Clone() )
	oClone:cObtemVersaoWSResult := ::cObtemVersaoWSResult
	oClone:cdataInicial  := ::cdataInicial
	oClone:cdataFinal    := ::cdataFinal
	oClone:oWSExportaTicketPeriodoResult :=  IIF(::oWSExportaTicketPeriodoResult = NIL , NIL ,::oWSExportaTicketPeriodoResult:Clone() )
	oClone:oWSExportaTicketsMarcadosResult :=  IIF(::oWSExportaTicketsMarcadosResult = NIL , NIL ,::oWSExportaTicketsMarcadosResult:Clone() )
	oClone:cPontoControle := ::cPontoControle
	oClone:cticketCodigo := ::cticketCodigo
	oClone:cticketPlaca  := ::cticketPlaca
	oClone:cticketTAG    := ::cticketTAG
	oClone:clado         := ::clado
	oClone:nIdentificaVeiculoNoPontoResult := ::nIdentificaVeiculoNoPontoResult
	oClone:nTempoValidadePesoBom := ::nTempoValidadePesoBom
	oClone:nTimeoutLeitura := ::nTimeoutLeitura
	oClone:cComando      := ::cComando
	oClone:nAcionaCancelaResult := ::nAcionaCancelaResult
	oClone:nPosicao      := ::nPosicao
	oClone:cMensagem     := ::cMensagem
	oClone:nTempo        := ::nTempo
	oClone:nEnviaMensagemDisplayResult := ::nEnviaMensagemDisplayResult
	oClone:nID           := ::nID
	oClone:nConsultaPedidoDeExecucaoResult := ::nConsultaPedidoDeExecucaoResult
	oClone:cSenha        := ::cSenha
	oClone:oWSTicketEntrada :=  IIF(::oWSTicketEntrada = NIL , NIL ,::oWSTicketEntrada:Clone() )
	oClone:oWSTicketSaida :=  IIF(::oWSTicketSaida = NIL , NIL ,::oWSTicketSaida:Clone() )
	oClone:cTerminal     := ::cTerminal
	oClone:nEndereco     := ::nEndereco
	oClone:cCodigoRedeSpider := ::cCodigoRedeSpider
	oClone:cMensagemDisplay := ::cMensagemDisplay
	oClone:cTeminal      := ::cTeminal
	oClone:nPeso         := ::nPeso
	oClone:cPontoDeControle := ::cPontoDeControle
	oClone:csegmentoInicial := ::csegmentoInicial
	oClone:csegmentoFinal := ::csegmentoFinal
	oClone:oWSExportaTicketParametroResult :=  IIF(::oWSExportaTicketParametroResult = NIL , NIL ,::oWSExportaTicketParametroResult:Clone() )
	oClone:nnumOperacao  := ::nnumOperacao
	oClone:lManutencaoTicketResult := ::lManutencaoTicketResult
	oClone:cfluxoCodigo  := ::cfluxoCodigo
	oClone:lTrocaFluxoTicketResult := ::lTrocaFluxoTicketResult
	oClone:lRemontaFluxoResult := ::lRemontaFluxoResult
	oClone:ncategoria    := ::ncategoria
	oClone:ntipo         := ::ntipo
	oClone:csistemaDeIntegracao := ::csistemaDeIntegracao
	oClone:oWSConsultaLogAplicacaoResult :=  IIF(::oWSConsultaLogAplicacaoResult = NIL , NIL ,::oWSConsultaLogAplicacaoResult:Clone() )
	oClone:cplacaOCR     := ::cplacaOCR
	oClone:cpontoControleDesc := ::cpontoControleDesc
	oClone:cusuarioNome  := ::cusuarioNome
	oClone:oWSConsultaMovimentoOCRResult :=  IIF(::oWSConsultaMovimentoOCRResult = NIL , NIL ,::oWSConsultaMovimentoOCRResult:Clone() )
	oClone:cOperadorLogin := ::cOperadorLogin
	oClone:cBalancaDesc  := ::cBalancaDesc
	oClone:ncategoriaLog := ::ncategoriaLog
	oClone:oWSConsultaLogPerifericosResult :=  IIF(::oWSConsultaLogPerifericosResult = NIL , NIL ,::oWSConsultaLogPerifericosResult:Clone() )
	oClone:lRefazUltimaOperacaoResult := ::lRefazUltimaOperacaoResult
	oClone:lRefazUltimaOperacaoIIResult := ::lRefazUltimaOperacaoIIResult
	oClone:nSaiErro      := ::nSaiErro
	oClone:cSaiErroMSG   := ::cSaiErroMSG
	oClone:lCancelaUltimaOperacaoAtivaResult := ::lCancelaUltimaOperacaoAtivaResult
	oClone:lRefazUltimaOperacaoAtivaResult := ::lRefazUltimaOperacaoAtivaResult
	oClone:oWSlogIN      :=  IIF(::oWSlogIN = NIL , NIL ,::oWSlogIN:Clone() )
	oClone:oWSConsultarLogAuditoriaResult :=  IIF(::oWSConsultarLogAuditoriaResult = NIL , NIL ,::oWSConsultarLogAuditoriaResult:Clone() )
	oClone:oWSConsultaTicketsPorPeriodoResult :=  IIF(::oWSConsultaTicketsPorPeriodoResult = NIL , NIL ,::oWSConsultaTicketsPorPeriodoResult:Clone() )
	oClone:oWSExportaVeiculosQuePossamTerPassadoSemPesarPelaBalancaResult :=  IIF(::oWSExportaVeiculosQuePossamTerPassadoSemPesarPelaBalancaResult = NIL , NIL ,::oWSExportaVeiculosQuePossamTerPassadoSemPesarPelaBalancaResult:Clone() )
	oClone:cdataInicio   := ::cdataInicio
	oClone:cdataFim      := ::cdataFim
	oClone:oWSRetornaVeiculosQuePossamTerPassadoSemPesarPelaBalancaResult :=  IIF(::oWSRetornaVeiculosQuePossamTerPassadoSemPesarPelaBalancaResult = NIL , NIL ,::oWSRetornaVeiculosQuePossamTerPassadoSemPesarPelaBalancaResult:Clone() )
	oClone:lConfirmaVeiculosQuePossamTerPassadoSemPesarPelaBalancaResult := ::lConfirmaVeiculosQuePossamTerPassadoSemPesarPelaBalancaResult
	oClone:oWSinfoCarregamento :=  IIF(::oWSinfoCarregamento = NIL , NIL ,::oWSinfoCarregamento:Clone() )
	oClone:nIdentificaVagaoResult := ::nIdentificaVagaoResult
	oClone:nSequencialTicket := ::nSequencialTicket
	oClone:cnomeSistema  := ::cnomeSistema
	oClone:lFalhou       := ::lFalhou
	oClone:lConfirmaTicketUnicoResult := ::lConfirmaTicketUnicoResult
	oClone:lcompleta     := ::lcompleta
	oClone:lSincronizacao := ::lSincronizacao
	oClone:oWSExportaTicketUnicoResult :=  IIF(::oWSExportaTicketUnicoResult = NIL , NIL ,::oWSExportaTicketUnicoResult:Clone() )
	oClone:ccodigoPontoControle := ::ccodigoPontoControle
	oClone:cposicaoCamera := ::cposicaoCamera
	oClone:ccaminhoFoto  := ::ccaminhoFoto
	oClone:cnomeFoto     := ::cnomeFoto
	oClone:nSolicitaFotoAvulsaResult := ::nSolicitaFotoAvulsaResult
	oClone:nidSolicitacaoAvulsa := ::nidSolicitacaoAvulsa
	oClone:oWSSolicitaRetornoFotoAvulsaResult :=  IIF(::oWSSolicitaRetornoFotoAvulsaResult = NIL , NIL ,::oWSSolicitaRetornoFotoAvulsaResult:Clone() )
Return oClone

// WSDL Method ImportaTicketPreCadastro of Service WSWS_GUARDIAN

WSMETHOD ImportaTicketPreCadastro WSSEND oWSDadosTicket,cproduto,ccodigo WSRECEIVE lImportaTicketPreCadastroResult,nErro,cErroMSG WSCLIENT WSWS_GUARDIAN
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ImportaTicketPreCadastro xmlns="http://toledobrasil.com.br/WS_Guardian">'
cSoap += WSSoapValue("DadosTicket", ::oWSDadosTicket, oWSDadosTicket , "PreCadastro", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("produto", ::cproduto, cproduto , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("codigo", ::ccodigo, ccodigo , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</ImportaTicketPreCadastro>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://toledobrasil.com.br/WS_Guardian/ImportaTicketPreCadastro",; 
	"DOCUMENT","http://toledobrasil.com.br/WS_Guardian",,,; 
	"http://infind.toledobrasil.com.br/WS_GUARDIAN/WS_GUARDIAN_PLUS.asmx")

::Init()
::lImportaTicketPreCadastroResult :=  WSAdvValue( oXmlRet,"_IMPORTATICKETPRECADASTRORESPONSE:_IMPORTATICKETPRECADASTRORESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 
::nErro              :=  WSAdvValue( oXmlRet,"_IMPORTATICKETPRECADASTRORESPONSE:_ERRO:TEXT","int",NIL,NIL,NIL,NIL,NIL,NIL) 
::cErroMSG           :=  WSAdvValue( oXmlRet,"_IMPORTATICKETPRECADASTRORESPONSE:_ERROMSG:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method CadastraTicket of Service WSWS_GUARDIAN

WSMETHOD CadastraTicket WSSEND oWSDadosTicket,cproduto,ccodigo WSRECEIVE lCadastraTicketResult,nErro,cErroMSG WSCLIENT WSWS_GUARDIAN
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<CadastraTicket xmlns="http://toledobrasil.com.br/WS_Guardian">'
cSoap += WSSoapValue("DadosTicket", ::oWSDadosTicket, oWSDadosTicket , "PreCadastro", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("produto", ::cproduto, cproduto , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("codigo", ::ccodigo, ccodigo , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</CadastraTicket>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://toledobrasil.com.br/WS_Guardian/CadastraTicket",; 
	"DOCUMENT","http://toledobrasil.com.br/WS_Guardian",,,; 
	"http://infind.toledobrasil.com.br/WS_GUARDIAN/WS_GUARDIAN_PLUS.asmx")

::Init()
::lCadastraTicketResult :=  WSAdvValue( oXmlRet,"_CADASTRATICKETRESPONSE:_CADASTRATICKETRESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 
::nErro              :=  WSAdvValue( oXmlRet,"_CADASTRATICKETRESPONSE:_ERRO:TEXT","int",NIL,NIL,NIL,NIL,NIL,NIL) 
::cErroMSG           :=  WSAdvValue( oXmlRet,"_CADASTRATICKETRESPONSE:_ERROMSG:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method CadastraTicketGuardian of Service WSWS_GUARDIAN

WSMETHOD CadastraTicketGuardian WSSEND oWSDadosTicket WSRECEIVE oWSCadastraTicketGuardianResult,nErro,cErroMSG WSCLIENT WSWS_GUARDIAN
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<CadastraTicketGuardian xmlns="http://toledobrasil.com.br/WS_Guardian">'
cSoap += WSSoapValue("DadosTicket", ::oWSDadosTicket, oWSDadosTicket , "PreCadastro", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</CadastraTicketGuardian>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://toledobrasil.com.br/WS_Guardian/CadastraTicketGuardian",; 
	"DOCUMENT","http://toledobrasil.com.br/WS_Guardian",,,; 
	"http://infind.toledobrasil.com.br/WS_GUARDIAN/WS_GUARDIAN_PLUS.asmx")

::Init()
::oWSCadastraTicketGuardianResult:SoapRecv( WSAdvValue( oXmlRet,"_CADASTRATICKETGUARDIANRESPONSE:_CADASTRATICKETGUARDIANRESULT","Ticket",NIL,NIL,NIL,NIL,NIL,NIL) )
::nErro              :=  WSAdvValue( oXmlRet,"_CADASTRATICKETGUARDIANRESPONSE:_ERRO:TEXT","int",NIL,NIL,NIL,NIL,NIL,NIL) 
::cErroMSG           :=  WSAdvValue( oXmlRet,"_CADASTRATICKETGUARDIANRESPONSE:_ERROMSG:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method AlteraTicketGuardian of Service WSWS_GUARDIAN

WSMETHOD AlteraTicketGuardian WSSEND oWSDadosTicket,oWSCfgAlteracao WSRECEIVE oWSAlteraTicketGuardianResult,nErro,cErroMSG WSCLIENT WSWS_GUARDIAN
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<AlteraTicketGuardian xmlns="http://toledobrasil.com.br/WS_Guardian">'
cSoap += WSSoapValue("DadosTicket", ::oWSDadosTicket, oWSDadosTicket , "PreCadastro", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CfgAlteracao", ::oWSCfgAlteracao, oWSCfgAlteracao , "ConfiguracaoAlteracao", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</AlteraTicketGuardian>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://toledobrasil.com.br/WS_Guardian/AlteraTicketGuardian",; 
	"DOCUMENT","http://toledobrasil.com.br/WS_Guardian",,,; 
	"http://infind.toledobrasil.com.br/WS_GUARDIAN/WS_GUARDIAN_PLUS.asmx")

::Init()
::oWSAlteraTicketGuardianResult:SoapRecv( WSAdvValue( oXmlRet,"_ALTERATICKETGUARDIANRESPONSE:_ALTERATICKETGUARDIANRESULT","Ticket",NIL,NIL,NIL,NIL,NIL,NIL) )
::nErro              :=  WSAdvValue( oXmlRet,"_ALTERATICKETGUARDIANRESPONSE:_ERRO:TEXT","int",NIL,NIL,NIL,NIL,NIL,NIL) 
::cErroMSG           :=  WSAdvValue( oXmlRet,"_ALTERATICKETGUARDIANRESPONSE:_ERROMSG:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method ObtemVersaoWS of Service WSWS_GUARDIAN

WSMETHOD ObtemVersaoWS WSSEND cproduto,ccodigo WSRECEIVE cObtemVersaoWSResult WSCLIENT WSWS_GUARDIAN
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ObtemVersaoWS xmlns="http://toledobrasil.com.br/WS_Guardian">'
cSoap += WSSoapValue("produto", ::cproduto, cproduto , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("codigo", ::ccodigo, ccodigo , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</ObtemVersaoWS>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://toledobrasil.com.br/WS_Guardian/ObtemVersaoWS",; 
	"DOCUMENT","http://toledobrasil.com.br/WS_Guardian",,,; 
	"http://infind.toledobrasil.com.br/WS_GUARDIAN/WS_GUARDIAN_PLUS.asmx")

::Init()
::cObtemVersaoWSResult :=  WSAdvValue( oXmlRet,"_OBTEMVERSAOWSRESPONSE:_OBTEMVERSAOWSRESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method ExportaTicketPeriodo of Service WSWS_GUARDIAN

WSMETHOD ExportaTicketPeriodo WSSEND cdataInicial,cdataFinal,cproduto,ccodigo WSRECEIVE oWSExportaTicketPeriodoResult,nErro,cErroMSG WSCLIENT WSWS_GUARDIAN
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ExportaTicketPeriodo xmlns="http://toledobrasil.com.br/WS_Guardian">'
cSoap += WSSoapValue("dataInicial", ::cdataInicial, cdataInicial , "dateTime", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("dataFinal", ::cdataFinal, cdataFinal , "dateTime", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("produto", ::cproduto, cproduto , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("codigo", ::ccodigo, ccodigo , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</ExportaTicketPeriodo>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://toledobrasil.com.br/WS_Guardian/ExportaTicketPeriodo",; 
	"DOCUMENT","http://toledobrasil.com.br/WS_Guardian",,,; 
	"http://infind.toledobrasil.com.br/WS_GUARDIAN/WS_GUARDIAN_PLUS.asmx")

::Init()
::oWSExportaTicketPeriodoResult:SoapRecv( WSAdvValue( oXmlRet,"_EXPORTATICKETPERIODORESPONSE:_EXPORTATICKETPERIODORESULT","ArrayOfTicket",NIL,NIL,NIL,NIL,NIL,NIL) )
::nErro              :=  WSAdvValue( oXmlRet,"_EXPORTATICKETPERIODORESPONSE:_ERRO:TEXT","int",NIL,NIL,NIL,NIL,NIL,NIL) 
::cErroMSG           :=  WSAdvValue( oXmlRet,"_EXPORTATICKETPERIODORESPONSE:_ERROMSG:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method ExportaTicketsMarcados of Service WSWS_GUARDIAN

WSMETHOD ExportaTicketsMarcados WSSEND NULLPARAM WSRECEIVE oWSExportaTicketsMarcadosResult,nErro,cErroMSG WSCLIENT WSWS_GUARDIAN
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ExportaTicketsMarcados xmlns="http://toledobrasil.com.br/WS_Guardian">'
cSoap += "</ExportaTicketsMarcados>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://toledobrasil.com.br/WS_Guardian/ExportaTicketsMarcados",; 
	"DOCUMENT","http://toledobrasil.com.br/WS_Guardian",,,; 
	"http://infind.toledobrasil.com.br/WS_GUARDIAN/WS_GUARDIAN_PLUS.asmx")

::Init()
::oWSExportaTicketsMarcadosResult:SoapRecv( WSAdvValue( oXmlRet,"_EXPORTATICKETSMARCADOSRESPONSE:_EXPORTATICKETSMARCADOSRESULT","ArrayOfTicket",NIL,NIL,NIL,NIL,NIL,NIL) )
::nErro              :=  WSAdvValue( oXmlRet,"_EXPORTATICKETSMARCADOSRESPONSE:_ERRO:TEXT","int",NIL,NIL,NIL,NIL,NIL,NIL) 
::cErroMSG           :=  WSAdvValue( oXmlRet,"_EXPORTATICKETSMARCADOSRESPONSE:_ERROMSG:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method ConfirmaLeituraTicketsMarcados of Service WSWS_GUARDIAN

WSMETHOD ConfirmaLeituraTicketsMarcados WSSEND NULLPARAM WSRECEIVE nErro,cErroMSG WSCLIENT WSWS_GUARDIAN
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ConfirmaLeituraTicketsMarcados xmlns="http://toledobrasil.com.br/WS_Guardian">'
cSoap += "</ConfirmaLeituraTicketsMarcados>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://toledobrasil.com.br/WS_Guardian/ConfirmaLeituraTicketsMarcados",; 
	"DOCUMENT","http://toledobrasil.com.br/WS_Guardian",,,; 
	"http://infind.toledobrasil.com.br/WS_GUARDIAN/WS_GUARDIAN_PLUS.asmx")

::Init()
::nErro              :=  WSAdvValue( oXmlRet,"_CONFIRMALEITURATICKETSMARCADOSRESPONSE:_ERRO:TEXT","int",NIL,NIL,NIL,NIL,NIL,NIL) 
::cErroMSG           :=  WSAdvValue( oXmlRet,"_CONFIRMALEITURATICKETSMARCADOSRESPONSE:_ERROMSG:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method IdentificaVeiculoNoPonto of Service WSWS_GUARDIAN

WSMETHOD IdentificaVeiculoNoPonto WSSEND cPontoControle,cticketCodigo,cticketPlaca,cticketTAG,clado WSRECEIVE nIdentificaVeiculoNoPontoResult,nErro,cErroMSG WSCLIENT WSWS_GUARDIAN
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<IdentificaVeiculoNoPonto xmlns="http://toledobrasil.com.br/WS_Guardian">'
cSoap += WSSoapValue("PontoControle", ::cPontoControle, cPontoControle , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("ticketCodigo", ::cticketCodigo, cticketCodigo , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("ticketPlaca", ::cticketPlaca, cticketPlaca , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("ticketTAG", ::cticketTAG, cticketTAG , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("lado", ::clado, clado , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</IdentificaVeiculoNoPonto>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://toledobrasil.com.br/WS_Guardian/IdentificaVeiculoNoPonto",; 
	"DOCUMENT","http://toledobrasil.com.br/WS_Guardian",,,; 
	"http://infind.toledobrasil.com.br/WS_GUARDIAN/WS_GUARDIAN_PLUS.asmx")

::Init()
::nIdentificaVeiculoNoPontoResult :=  WSAdvValue( oXmlRet,"_IDENTIFICAVEICULONOPONTORESPONSE:_IDENTIFICAVEICULONOPONTORESULT:TEXT","int",NIL,NIL,NIL,NIL,NIL,NIL) 
::nErro              :=  WSAdvValue( oXmlRet,"_IDENTIFICAVEICULONOPONTORESPONSE:_ERRO:TEXT","int",NIL,NIL,NIL,NIL,NIL,NIL) 
::cErroMSG           :=  WSAdvValue( oXmlRet,"_IDENTIFICAVEICULONOPONTORESPONSE:_ERROMSG:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method SimulaPesagemAvulsaSemAutomacao of Service WSWS_GUARDIAN

WSMETHOD SimulaPesagemAvulsaSemAutomacao WSSEND cPontoControle,cticketCodigo,cticketPlaca,cticketTAG,clado,nTempoValidadePesoBom,nTimeoutLeitura,cproduto,ccodigo WSRECEIVE nErro,cErroMSG WSCLIENT WSWS_GUARDIAN
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<SimulaPesagemAvulsaSemAutomacao xmlns="http://toledobrasil.com.br/WS_Guardian">'
cSoap += WSSoapValue("PontoControle", ::cPontoControle, cPontoControle , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("ticketCodigo", ::cticketCodigo, cticketCodigo , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("ticketPlaca", ::cticketPlaca, cticketPlaca , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("ticketTAG", ::cticketTAG, cticketTAG , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("lado", ::clado, clado , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("TempoValidadePesoBom", ::nTempoValidadePesoBom, nTempoValidadePesoBom , "int", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("TimeoutLeitura", ::nTimeoutLeitura, nTimeoutLeitura , "int", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("produto", ::cproduto, cproduto , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("codigo", ::ccodigo, ccodigo , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</SimulaPesagemAvulsaSemAutomacao>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://toledobrasil.com.br/WS_Guardian/SimulaPesagemAvulsaSemAutomacao",; 
	"DOCUMENT","http://toledobrasil.com.br/WS_Guardian",,,; 
	"http://infind.toledobrasil.com.br/WS_GUARDIAN/WS_GUARDIAN_PLUS.asmx")

::Init()
::nErro              :=  WSAdvValue( oXmlRet,"_SIMULAPESAGEMAVULSASEMAUTOMACAORESPONSE:_ERRO:TEXT","int",NIL,NIL,NIL,NIL,NIL,NIL) 
::cErroMSG           :=  WSAdvValue( oXmlRet,"_SIMULAPESAGEMAVULSASEMAUTOMACAORESPONSE:_ERROMSG:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method AcionaCancela of Service WSWS_GUARDIAN

WSMETHOD AcionaCancela WSSEND cPontoControle,cLado,cComando WSRECEIVE nAcionaCancelaResult,nErro,cErroMSG WSCLIENT WSWS_GUARDIAN
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<AcionaCancela xmlns="http://toledobrasil.com.br/WS_Guardian">'
cSoap += WSSoapValue("PontoControle", ::cPontoControle, cPontoControle , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("Lado", ::cLado, cLado , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("Comando", ::cComando, cComando , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</AcionaCancela>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://toledobrasil.com.br/WS_Guardian/AcionaCancela",; 
	"DOCUMENT","http://toledobrasil.com.br/WS_Guardian",,,; 
	"http://infind.toledobrasil.com.br/WS_GUARDIAN/WS_GUARDIAN_PLUS.asmx")

::Init()
::nAcionaCancelaResult :=  WSAdvValue( oXmlRet,"_ACIONACANCELARESPONSE:_ACIONACANCELARESULT:TEXT","int",NIL,NIL,NIL,NIL,NIL,NIL) 
::nErro              :=  WSAdvValue( oXmlRet,"_ACIONACANCELARESPONSE:_ERRO:TEXT","int",NIL,NIL,NIL,NIL,NIL,NIL) 
::cErroMSG           :=  WSAdvValue( oXmlRet,"_ACIONACANCELARESPONSE:_ERROMSG:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method EnviaMensagemDisplay of Service WSWS_GUARDIAN

WSMETHOD EnviaMensagemDisplay WSSEND cPontoControle,nPosicao,cMensagem,nTempo WSRECEIVE nEnviaMensagemDisplayResult,nErro,cErroMSG WSCLIENT WSWS_GUARDIAN
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<EnviaMensagemDisplay xmlns="http://toledobrasil.com.br/WS_Guardian">'
cSoap += WSSoapValue("PontoControle", ::cPontoControle, cPontoControle , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("Posicao", ::nPosicao, nPosicao , "int", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("Mensagem", ::cMensagem, cMensagem , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("Tempo", ::nTempo, nTempo , "int", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</EnviaMensagemDisplay>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://toledobrasil.com.br/WS_Guardian/EnviaMensagemDisplay",; 
	"DOCUMENT","http://toledobrasil.com.br/WS_Guardian",,,; 
	"http://infind.toledobrasil.com.br/WS_GUARDIAN/WS_GUARDIAN_PLUS.asmx")

::Init()
::nEnviaMensagemDisplayResult :=  WSAdvValue( oXmlRet,"_ENVIAMENSAGEMDISPLAYRESPONSE:_ENVIAMENSAGEMDISPLAYRESULT:TEXT","int",NIL,NIL,NIL,NIL,NIL,NIL) 
::nErro              :=  WSAdvValue( oXmlRet,"_ENVIAMENSAGEMDISPLAYRESPONSE:_ERRO:TEXT","int",NIL,NIL,NIL,NIL,NIL,NIL) 
::cErroMSG           :=  WSAdvValue( oXmlRet,"_ENVIAMENSAGEMDISPLAYRESPONSE:_ERROMSG:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method ConsultaPedidoDeExecucao of Service WSWS_GUARDIAN

WSMETHOD ConsultaPedidoDeExecucao WSSEND nID WSRECEIVE nConsultaPedidoDeExecucaoResult,nErro,cErroMSG WSCLIENT WSWS_GUARDIAN
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ConsultaPedidoDeExecucao xmlns="http://toledobrasil.com.br/WS_Guardian">'
cSoap += WSSoapValue("ID", ::nID, nID , "int", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</ConsultaPedidoDeExecucao>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://toledobrasil.com.br/WS_Guardian/ConsultaPedidoDeExecucao",; 
	"DOCUMENT","http://toledobrasil.com.br/WS_Guardian",,,; 
	"http://infind.toledobrasil.com.br/WS_GUARDIAN/WS_GUARDIAN_PLUS.asmx")

::Init()
::nConsultaPedidoDeExecucaoResult :=  WSAdvValue( oXmlRet,"_CONSULTAPEDIDODEEXECUCAORESPONSE:_CONSULTAPEDIDODEEXECUCAORESULT:TEXT","int",NIL,NIL,NIL,NIL,NIL,NIL) 
::nErro              :=  WSAdvValue( oXmlRet,"_CONSULTAPEDIDODEEXECUCAORESPONSE:_ERRO:TEXT","int",NIL,NIL,NIL,NIL,NIL,NIL) 
::cErroMSG           :=  WSAdvValue( oXmlRet,"_CONSULTAPEDIDODEEXECUCAORESPONSE:_ERROMSG:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method DadosDoTicket_G4 of Service WSWS_GUARDIAN

WSMETHOD DadosDoTicket_G4 WSSEND cSenha,oWSTicketEntrada WSRECEIVE oWSTicketSaida,nErro,cMensagem WSCLIENT WSWS_GUARDIAN
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<DadosDoTicket_G4 xmlns="http://toledobrasil.com.br/WS_Guardian">'
cSoap += WSSoapValue("Senha", ::cSenha, cSenha , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("TicketEntrada", ::oWSTicketEntrada, oWSTicketEntrada , "ImportaTicketG4", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</DadosDoTicket_G4>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://toledobrasil.com.br/WS_Guardian/DadosDoTicket_G4",; 
	"DOCUMENT","http://toledobrasil.com.br/WS_Guardian",,,; 
	"http://infind.toledobrasil.com.br/WS_GUARDIAN/WS_GUARDIAN_PLUS.asmx")

::Init()
::oWSTicketSaida:SoapRecv( WSAdvValue( oXmlRet,"_DADOSDOTICKET_G4RESPONSE:_TICKETSAIDA","ExportaTicketG4",NIL,NIL,NIL,NIL,NIL,NIL) )
::nErro              :=  WSAdvValue( oXmlRet,"_DADOSDOTICKET_G4RESPONSE:_ERRO:TEXT","int",NIL,NIL,NIL,NIL,NIL,NIL) 
::cMensagem          :=  WSAdvValue( oXmlRet,"_DADOSDOTICKET_G4RESPONSE:_MENSAGEM:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method EnviaMensagem_G4 of Service WSWS_GUARDIAN

WSMETHOD EnviaMensagem_G4 WSSEND cSenha,cTerminal,nEndereco,cCodigoRedeSpider,cMensagemDisplay,nTempo WSRECEIVE nErro,cMensagem WSCLIENT WSWS_GUARDIAN
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<EnviaMensagem_G4 xmlns="http://toledobrasil.com.br/WS_Guardian">'
cSoap += WSSoapValue("Senha", ::cSenha, cSenha , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("Terminal", ::cTerminal, cTerminal , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("Endereco", ::nEndereco, nEndereco , "int", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CodigoRedeSpider", ::cCodigoRedeSpider, cCodigoRedeSpider , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("MensagemDisplay", ::cMensagemDisplay, cMensagemDisplay , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("Tempo", ::nTempo, nTempo , "int", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</EnviaMensagem_G4>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://toledobrasil.com.br/WS_Guardian/EnviaMensagem_G4",; 
	"DOCUMENT","http://toledobrasil.com.br/WS_Guardian",,,; 
	"http://infind.toledobrasil.com.br/WS_GUARDIAN/WS_GUARDIAN_PLUS.asmx")

::Init()
::nErro              :=  WSAdvValue( oXmlRet,"_ENVIAMENSAGEM_G4RESPONSE:_ERRO:TEXT","int",NIL,NIL,NIL,NIL,NIL,NIL) 
::cMensagem          :=  WSAdvValue( oXmlRet,"_ENVIAMENSAGEM_G4RESPONSE:_MENSAGEM:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method AcionaCancela_G4 of Service WSWS_GUARDIAN

WSMETHOD AcionaCancela_G4 WSSEND cSenha,cTerminal,cLado,cComando WSRECEIVE nErro,cMensagem WSCLIENT WSWS_GUARDIAN
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<AcionaCancela_G4 xmlns="http://toledobrasil.com.br/WS_Guardian">'
cSoap += WSSoapValue("Senha", ::cSenha, cSenha , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("Terminal", ::cTerminal, cTerminal , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("Lado", ::cLado, cLado , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("Comando", ::cComando, cComando , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</AcionaCancela_G4>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://toledobrasil.com.br/WS_Guardian/AcionaCancela_G4",; 
	"DOCUMENT","http://toledobrasil.com.br/WS_Guardian",,,; 
	"http://infind.toledobrasil.com.br/WS_GUARDIAN/WS_GUARDIAN_PLUS.asmx")

::Init()
::nErro              :=  WSAdvValue( oXmlRet,"_ACIONACANCELA_G4RESPONSE:_ERRO:TEXT","int",NIL,NIL,NIL,NIL,NIL,NIL) 
::cMensagem          :=  WSAdvValue( oXmlRet,"_ACIONACANCELA_G4RESPONSE:_MENSAGEM:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method CapturaPeso_G4 of Service WSWS_GUARDIAN

WSMETHOD CapturaPeso_G4 WSSEND cSenha,cTeminal WSRECEIVE nPeso,nErro,cMensagem WSCLIENT WSWS_GUARDIAN
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<CapturaPeso_G4 xmlns="http://toledobrasil.com.br/WS_Guardian">'
cSoap += WSSoapValue("Senha", ::cSenha, cSenha , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("Teminal", ::cTeminal, cTeminal , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</CapturaPeso_G4>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://toledobrasil.com.br/WS_Guardian/CapturaPeso_G4",; 
	"DOCUMENT","http://toledobrasil.com.br/WS_Guardian",,,; 
	"http://infind.toledobrasil.com.br/WS_GUARDIAN/WS_GUARDIAN_PLUS.asmx")

::Init()
::nPeso              :=  WSAdvValue( oXmlRet,"_CAPTURAPESO_G4RESPONSE:_PESO:TEXT","float",NIL,NIL,NIL,NIL,NIL,NIL) 
::nErro              :=  WSAdvValue( oXmlRet,"_CAPTURAPESO_G4RESPONSE:_ERRO:TEXT","int",NIL,NIL,NIL,NIL,NIL,NIL) 
::cMensagem          :=  WSAdvValue( oXmlRet,"_CAPTURAPESO_G4RESPONSE:_MENSAGEM:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method CapturaPeso of Service WSWS_GUARDIAN

WSMETHOD CapturaPeso WSSEND cPontoDeControle,nTempoValidadePesoBom,nTimeoutLeitura,cproduto,ccodigo,csegmentoInicial,csegmentoFinal WSRECEIVE nPeso,nErro,cMensagem WSCLIENT WSWS_GUARDIAN
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<CapturaPeso xmlns="http://toledobrasil.com.br/WS_Guardian">'
cSoap += WSSoapValue("PontoDeControle", ::cPontoDeControle, cPontoDeControle , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("TempoValidadePesoBom", ::nTempoValidadePesoBom, nTempoValidadePesoBom , "int", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("TimeoutLeitura", ::nTimeoutLeitura, nTimeoutLeitura , "int", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("produto", ::cproduto, cproduto , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("codigo", ::ccodigo, ccodigo , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("segmentoInicial", ::csegmentoInicial, csegmentoInicial , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("segmentoFinal", ::csegmentoFinal, csegmentoFinal , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</CapturaPeso>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://toledobrasil.com.br/WS_Guardian/CapturaPeso",; 
	"DOCUMENT","http://toledobrasil.com.br/WS_Guardian",,,; 
	"http://infind.toledobrasil.com.br/WS_GUARDIAN/WS_GUARDIAN_PLUS.asmx")

::Init()
::nPeso              :=  WSAdvValue( oXmlRet,"_CAPTURAPESORESPONSE:_PESO:TEXT","float",NIL,NIL,NIL,NIL,NIL,NIL) 
::nErro              :=  WSAdvValue( oXmlRet,"_CAPTURAPESORESPONSE:_ERRO:TEXT","int",NIL,NIL,NIL,NIL,NIL,NIL) 
::cMensagem          :=  WSAdvValue( oXmlRet,"_CAPTURAPESORESPONSE:_MENSAGEM:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method ExportaTicketParametro of Service WSWS_GUARDIAN

WSMETHOD ExportaTicketParametro WSSEND cticketCodigo,cticketPlaca,cticketTAG,cproduto,ccodigo WSRECEIVE oWSExportaTicketParametroResult,nErro,cErroMSG WSCLIENT WSWS_GUARDIAN
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ExportaTicketParametro xmlns="http://toledobrasil.com.br/WS_Guardian">'
cSoap += WSSoapValue("ticketCodigo", ::cticketCodigo, cticketCodigo , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("ticketPlaca", ::cticketPlaca, cticketPlaca , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("ticketTAG", ::cticketTAG, cticketTAG , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("produto", ::cproduto, cproduto , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("codigo", ::ccodigo, ccodigo , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</ExportaTicketParametro>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://toledobrasil.com.br/WS_Guardian/ExportaTicketParametro",; 
	"DOCUMENT","http://toledobrasil.com.br/WS_Guardian",,,; 
	"http://infind.toledobrasil.com.br/WS_GUARDIAN/WS_GUARDIAN_PLUS.asmx")

::Init()
::oWSExportaTicketParametroResult:SoapRecv( WSAdvValue( oXmlRet,"_EXPORTATICKETPARAMETRORESPONSE:_EXPORTATICKETPARAMETRORESULT","ArrayOfTicket",NIL,NIL,NIL,NIL,NIL,NIL) )
::nErro              :=  WSAdvValue( oXmlRet,"_EXPORTATICKETPARAMETRORESPONSE:_ERRO:TEXT","int",NIL,NIL,NIL,NIL,NIL,NIL) 
::cErroMSG           :=  WSAdvValue( oXmlRet,"_EXPORTATICKETPARAMETRORESPONSE:_ERROMSG:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method ManutencaoTicket of Service WSWS_GUARDIAN

WSMETHOD ManutencaoTicket WSSEND cticketCodigo,cticketPlaca,cticketTAG,nnumOperacao,cproduto,ccodigo WSRECEIVE lManutencaoTicketResult WSCLIENT WSWS_GUARDIAN
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ManutencaoTicket xmlns="http://toledobrasil.com.br/WS_Guardian">'
cSoap += WSSoapValue("ticketCodigo", ::cticketCodigo, cticketCodigo , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("ticketPlaca", ::cticketPlaca, cticketPlaca , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("ticketTAG", ::cticketTAG, cticketTAG , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("numOperacao", ::nnumOperacao, nnumOperacao , "int", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("produto", ::cproduto, cproduto , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("codigo", ::ccodigo, ccodigo , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</ManutencaoTicket>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://toledobrasil.com.br/WS_Guardian/ManutencaoTicket",; 
	"DOCUMENT","http://toledobrasil.com.br/WS_Guardian",,,; 
	"http://infind.toledobrasil.com.br/WS_GUARDIAN/WS_GUARDIAN_PLUS.asmx")

::Init()
::lManutencaoTicketResult :=  WSAdvValue( oXmlRet,"_MANUTENCAOTICKETRESPONSE:_MANUTENCAOTICKETRESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method TrocaFluxoTicket of Service WSWS_GUARDIAN

WSMETHOD TrocaFluxoTicket WSSEND cticketCodigo,cticketPlaca,cticketTAG,cfluxoCodigo,cproduto,ccodigo WSRECEIVE lTrocaFluxoTicketResult WSCLIENT WSWS_GUARDIAN
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<TrocaFluxoTicket xmlns="http://toledobrasil.com.br/WS_Guardian">'
cSoap += WSSoapValue("ticketCodigo", ::cticketCodigo, cticketCodigo , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("ticketPlaca", ::cticketPlaca, cticketPlaca , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("ticketTAG", ::cticketTAG, cticketTAG , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("fluxoCodigo", ::cfluxoCodigo, cfluxoCodigo , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("produto", ::cproduto, cproduto , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("codigo", ::ccodigo, ccodigo , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</TrocaFluxoTicket>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://toledobrasil.com.br/WS_Guardian/TrocaFluxoTicket",; 
	"DOCUMENT","http://toledobrasil.com.br/WS_Guardian",,,; 
	"http://infind.toledobrasil.com.br/WS_GUARDIAN/WS_GUARDIAN_PLUS.asmx")

::Init()
::lTrocaFluxoTicketResult :=  WSAdvValue( oXmlRet,"_TROCAFLUXOTICKETRESPONSE:_TROCAFLUXOTICKETRESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method RemontaFluxo of Service WSWS_GUARDIAN

WSMETHOD RemontaFluxo WSSEND cticketCodigo,cticketPlaca,cticketTAG,cfluxoCodigo,cproduto,ccodigo WSRECEIVE lRemontaFluxoResult WSCLIENT WSWS_GUARDIAN
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<RemontaFluxo xmlns="http://toledobrasil.com.br/WS_Guardian">'
cSoap += WSSoapValue("ticketCodigo", ::cticketCodigo, cticketCodigo , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("ticketPlaca", ::cticketPlaca, cticketPlaca , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("ticketTAG", ::cticketTAG, cticketTAG , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("fluxoCodigo", ::cfluxoCodigo, cfluxoCodigo , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("produto", ::cproduto, cproduto , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("codigo", ::ccodigo, ccodigo , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</RemontaFluxo>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://toledobrasil.com.br/WS_Guardian/RemontaFluxo",; 
	"DOCUMENT","http://toledobrasil.com.br/WS_Guardian",,,; 
	"http://infind.toledobrasil.com.br/WS_GUARDIAN/WS_GUARDIAN_PLUS.asmx")

::Init()
::lRemontaFluxoResult :=  WSAdvValue( oXmlRet,"_REMONTAFLUXORESPONSE:_REMONTAFLUXORESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method ConsultaLogAplicacao of Service WSWS_GUARDIAN

WSMETHOD ConsultaLogAplicacao WSSEND cdataInicial,cdataFinal,ncategoria,ntipo,csistemaDeIntegracao,cproduto,ccodigo WSRECEIVE oWSConsultaLogAplicacaoResult,nErro,cErroMSG WSCLIENT WSWS_GUARDIAN
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ConsultaLogAplicacao xmlns="http://toledobrasil.com.br/WS_Guardian">'
cSoap += WSSoapValue("dataInicial", ::cdataInicial, cdataInicial , "dateTime", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("dataFinal", ::cdataFinal, cdataFinal , "dateTime", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("categoria", ::ncategoria, ncategoria , "int", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("tipo", ::ntipo, ntipo , "int", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("sistemaDeIntegracao", ::csistemaDeIntegracao, csistemaDeIntegracao , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("produto", ::cproduto, cproduto , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("codigo", ::ccodigo, ccodigo , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</ConsultaLogAplicacao>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://toledobrasil.com.br/WS_Guardian/ConsultaLogAplicacao",; 
	"DOCUMENT","http://toledobrasil.com.br/WS_Guardian",,,; 
	"http://infind.toledobrasil.com.br/WS_GUARDIAN/WS_GUARDIAN_PLUS.asmx")

::Init()
::oWSConsultaLogAplicacaoResult:SoapRecv( WSAdvValue( oXmlRet,"_CONSULTALOGAPLICACAORESPONSE:_CONSULTALOGAPLICACAORESULT","ArrayOfLogAplicacao",NIL,NIL,NIL,NIL,NIL,NIL) )
::nErro              :=  WSAdvValue( oXmlRet,"_CONSULTALOGAPLICACAORESPONSE:_ERRO:TEXT","int",NIL,NIL,NIL,NIL,NIL,NIL) 
::cErroMSG           :=  WSAdvValue( oXmlRet,"_CONSULTALOGAPLICACAORESPONSE:_ERROMSG:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method ConsultaMovimentoOCR of Service WSWS_GUARDIAN

WSMETHOD ConsultaMovimentoOCR WSSEND cticketCodigo,cticketPlaca,cticketTAG,cplacaOCR,cdataInicial,cdataFinal,cpontoControleDesc,cusuarioNome,cproduto,ccodigo WSRECEIVE oWSConsultaMovimentoOCRResult,nErro,cErroMSG WSCLIENT WSWS_GUARDIAN
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ConsultaMovimentoOCR xmlns="http://toledobrasil.com.br/WS_Guardian">'
cSoap += WSSoapValue("ticketCodigo", ::cticketCodigo, cticketCodigo , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("ticketPlaca", ::cticketPlaca, cticketPlaca , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("ticketTAG", ::cticketTAG, cticketTAG , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("placaOCR", ::cplacaOCR, cplacaOCR , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("dataInicial", ::cdataInicial, cdataInicial , "dateTime", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("dataFinal", ::cdataFinal, cdataFinal , "dateTime", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("pontoControleDesc", ::cpontoControleDesc, cpontoControleDesc , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("usuarioNome", ::cusuarioNome, cusuarioNome , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("produto", ::cproduto, cproduto , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("codigo", ::ccodigo, ccodigo , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</ConsultaMovimentoOCR>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://toledobrasil.com.br/WS_Guardian/ConsultaMovimentoOCR",; 
	"DOCUMENT","http://toledobrasil.com.br/WS_Guardian",,,; 
	"http://infind.toledobrasil.com.br/WS_GUARDIAN/WS_GUARDIAN_PLUS.asmx")

::Init()
::oWSConsultaMovimentoOCRResult:SoapRecv( WSAdvValue( oXmlRet,"_CONSULTAMOVIMENTOOCRRESPONSE:_CONSULTAMOVIMENTOOCRRESULT","ArrayOfTicket",NIL,NIL,NIL,NIL,NIL,NIL) )
::nErro              :=  WSAdvValue( oXmlRet,"_CONSULTAMOVIMENTOOCRRESPONSE:_ERRO:TEXT","int",NIL,NIL,NIL,NIL,NIL,NIL) 
::cErroMSG           :=  WSAdvValue( oXmlRet,"_CONSULTAMOVIMENTOOCRRESPONSE:_ERROMSG:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method ConsultaLogPerifericos of Service WSWS_GUARDIAN

WSMETHOD ConsultaLogPerifericos WSSEND cOperadorLogin,cBalancaDesc,cdataInicial,cdataFinal,ncategoriaLog,cproduto,ccodigo WSRECEIVE oWSConsultaLogPerifericosResult WSCLIENT WSWS_GUARDIAN
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ConsultaLogPerifericos xmlns="http://toledobrasil.com.br/WS_Guardian">'
cSoap += WSSoapValue("OperadorLogin", ::cOperadorLogin, cOperadorLogin , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("BalancaDesc", ::cBalancaDesc, cBalancaDesc , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("dataInicial", ::cdataInicial, cdataInicial , "dateTime", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("dataFinal", ::cdataFinal, cdataFinal , "dateTime", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("categoriaLog", ::ncategoriaLog, ncategoriaLog , "int", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("produto", ::cproduto, cproduto , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("codigo", ::ccodigo, ccodigo , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</ConsultaLogPerifericos>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://toledobrasil.com.br/WS_Guardian/ConsultaLogPerifericos",; 
	"DOCUMENT","http://toledobrasil.com.br/WS_Guardian",,,; 
	"http://infind.toledobrasil.com.br/WS_GUARDIAN/WS_GUARDIAN_PLUS.asmx")

::Init()
::oWSConsultaLogPerifericosResult:SoapRecv( WSAdvValue( oXmlRet,"_CONSULTALOGPERIFERICOSRESPONSE:_CONSULTALOGPERIFERICOSRESULT","ArrayOfLogPeriferico",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method RefazUltimaOperacao of Service WSWS_GUARDIAN

WSMETHOD RefazUltimaOperacao WSSEND cticketCodigo,cticketPlaca,cticketTAG,cproduto,ccodigo WSRECEIVE lRefazUltimaOperacaoResult WSCLIENT WSWS_GUARDIAN
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<RefazUltimaOperacao xmlns="http://toledobrasil.com.br/WS_Guardian">'
cSoap += WSSoapValue("ticketCodigo", ::cticketCodigo, cticketCodigo , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("ticketPlaca", ::cticketPlaca, cticketPlaca , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("ticketTAG", ::cticketTAG, cticketTAG , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("produto", ::cproduto, cproduto , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("codigo", ::ccodigo, ccodigo , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</RefazUltimaOperacao>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://toledobrasil.com.br/WS_Guardian/RefazUltimaOperacao",; 
	"DOCUMENT","http://toledobrasil.com.br/WS_Guardian",,,; 
	"http://infind.toledobrasil.com.br/WS_GUARDIAN/WS_GUARDIAN_PLUS.asmx")

::Init()
::lRefazUltimaOperacaoResult :=  WSAdvValue( oXmlRet,"_REFAZULTIMAOPERACAORESPONSE:_REFAZULTIMAOPERACAORESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method RefazUltimaOperacaoII of Service WSWS_GUARDIAN

WSMETHOD RefazUltimaOperacaoII WSSEND cticketCodigo,cticketPlaca,cticketTAG,cproduto,ccodigo WSRECEIVE lRefazUltimaOperacaoIIResult,nSaiErro,cSaiErroMSG WSCLIENT WSWS_GUARDIAN
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<RefazUltimaOperacaoII xmlns="http://toledobrasil.com.br/WS_Guardian">'
cSoap += WSSoapValue("ticketCodigo", ::cticketCodigo, cticketCodigo , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("ticketPlaca", ::cticketPlaca, cticketPlaca , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("ticketTAG", ::cticketTAG, cticketTAG , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("produto", ::cproduto, cproduto , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("codigo", ::ccodigo, ccodigo , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</RefazUltimaOperacaoII>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://toledobrasil.com.br/WS_Guardian/RefazUltimaOperacaoII",; 
	"DOCUMENT","http://toledobrasil.com.br/WS_Guardian",,,; 
	"http://infind.toledobrasil.com.br/WS_GUARDIAN/WS_GUARDIAN_PLUS.asmx")

::Init()
::lRefazUltimaOperacaoIIResult :=  WSAdvValue( oXmlRet,"_REFAZULTIMAOPERACAOIIRESPONSE:_REFAZULTIMAOPERACAOIIRESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 
::nSaiErro           :=  WSAdvValue( oXmlRet,"_REFAZULTIMAOPERACAOIIRESPONSE:_SAIERRO:TEXT","int",NIL,NIL,NIL,NIL,NIL,NIL) 
::cSaiErroMSG        :=  WSAdvValue( oXmlRet,"_REFAZULTIMAOPERACAOIIRESPONSE:_SAIERROMSG:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method CancelaUltimaOperacaoAtiva of Service WSWS_GUARDIAN

WSMETHOD CancelaUltimaOperacaoAtiva WSSEND cticketCodigo,cticketPlaca,cticketTAG WSRECEIVE lCancelaUltimaOperacaoAtivaResult,nSaiErro,cSaiErroMSG WSCLIENT WSWS_GUARDIAN
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<CancelaUltimaOperacaoAtiva xmlns="http://toledobrasil.com.br/WS_Guardian">'
cSoap += WSSoapValue("ticketCodigo", ::cticketCodigo, cticketCodigo , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("ticketPlaca", ::cticketPlaca, cticketPlaca , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("ticketTAG", ::cticketTAG, cticketTAG , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</CancelaUltimaOperacaoAtiva>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://toledobrasil.com.br/WS_Guardian/CancelaUltimaOperacaoAtiva",; 
	"DOCUMENT","http://toledobrasil.com.br/WS_Guardian",,,; 
	"http://infind.toledobrasil.com.br/WS_GUARDIAN/WS_GUARDIAN_PLUS.asmx")

::Init()
::lCancelaUltimaOperacaoAtivaResult :=  WSAdvValue( oXmlRet,"_CANCELAULTIMAOPERACAOATIVARESPONSE:_CANCELAULTIMAOPERACAOATIVARESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 
::nSaiErro           :=  WSAdvValue( oXmlRet,"_CANCELAULTIMAOPERACAOATIVARESPONSE:_SAIERRO:TEXT","int",NIL,NIL,NIL,NIL,NIL,NIL) 
::cSaiErroMSG        :=  WSAdvValue( oXmlRet,"_CANCELAULTIMAOPERACAOATIVARESPONSE:_SAIERROMSG:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method RefazUltimaOperacaoAtiva of Service WSWS_GUARDIAN

WSMETHOD RefazUltimaOperacaoAtiva WSSEND cticketCodigo,cticketPlaca,cticketTAG WSRECEIVE lRefazUltimaOperacaoAtivaResult,nSaiErro,cSaiErroMSG WSCLIENT WSWS_GUARDIAN
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<RefazUltimaOperacaoAtiva xmlns="http://toledobrasil.com.br/WS_Guardian">'
cSoap += WSSoapValue("ticketCodigo", ::cticketCodigo, cticketCodigo , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("ticketPlaca", ::cticketPlaca, cticketPlaca , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("ticketTAG", ::cticketTAG, cticketTAG , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</RefazUltimaOperacaoAtiva>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://toledobrasil.com.br/WS_Guardian/RefazUltimaOperacaoAtiva",; 
	"DOCUMENT","http://toledobrasil.com.br/WS_Guardian",,,; 
	"http://infind.toledobrasil.com.br/WS_GUARDIAN/WS_GUARDIAN_PLUS.asmx")

::Init()
::lRefazUltimaOperacaoAtivaResult :=  WSAdvValue( oXmlRet,"_REFAZULTIMAOPERACAOATIVARESPONSE:_REFAZULTIMAOPERACAOATIVARESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 
::nSaiErro           :=  WSAdvValue( oXmlRet,"_REFAZULTIMAOPERACAOATIVARESPONSE:_SAIERRO:TEXT","int",NIL,NIL,NIL,NIL,NIL,NIL) 
::cSaiErroMSG        :=  WSAdvValue( oXmlRet,"_REFAZULTIMAOPERACAOATIVARESPONSE:_SAIERROMSG:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method ConsultaIntervencoesManuaisTicket of Service WSWS_GUARDIAN

WSMETHOD ConsultaIntervencoesManuaisTicket WSSEND cticketCodigo,cticketPlaca,cticketTAG,cOperadorLogin,cdataInicial,cdataFinal,cproduto,ccodigo WSRECEIVE oWSConsultaIntervencoesManuaisTicketResult WSCLIENT WSWS_GUARDIAN
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ConsultaIntervencoesManuaisTicket xmlns="http://toledobrasil.com.br/WS_Guardian">'
cSoap += WSSoapValue("ticketCodigo", ::cticketCodigo, cticketCodigo , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("ticketPlaca", ::cticketPlaca, cticketPlaca , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("ticketTAG", ::cticketTAG, cticketTAG , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("OperadorLogin", ::cOperadorLogin, cOperadorLogin , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("dataInicial", ::cdataInicial, cdataInicial , "dateTime", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("dataFinal", ::cdataFinal, cdataFinal , "dateTime", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("produto", ::cproduto, cproduto , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("codigo", ::ccodigo, ccodigo , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</ConsultaIntervencoesManuaisTicket>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://toledobrasil.com.br/WS_Guardian/ConsultaIntervencoesManuaisTicket",; 
	"DOCUMENT","http://toledobrasil.com.br/WS_Guardian",,,; 
	"http://infind.toledobrasil.com.br/WS_GUARDIAN/WS_GUARDIAN_PLUS.asmx")

::Init()
::oWSConsultaIntervencoesManuaisTicketResult :=  WSAdvValue( oXmlRet,"_CONSULTAINTERVENCOESMANUAISTICKETRESPONSE","SCHEMA",NIL,NIL,NIL,"O",NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method ConsultarLogAuditoria of Service WSWS_GUARDIAN

WSMETHOD ConsultarLogAuditoria WSSEND oWSlogIN,cproduto,ccodigo WSRECEIVE oWSConsultarLogAuditoriaResult WSCLIENT WSWS_GUARDIAN
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ConsultarLogAuditoria xmlns="http://toledobrasil.com.br/WS_Guardian">'
cSoap += WSSoapValue("logIN", ::oWSlogIN, oWSlogIN , "ConsultaLogAuditoriaIN", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("produto", ::cproduto, cproduto , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("codigo", ::ccodigo, ccodigo , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</ConsultarLogAuditoria>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://toledobrasil.com.br/WS_Guardian/ConsultarLogAuditoria",; 
	"DOCUMENT","http://toledobrasil.com.br/WS_Guardian",,,; 
	"http://infind.toledobrasil.com.br/WS_GUARDIAN/WS_GUARDIAN_PLUS.asmx")

::Init()
::oWSConsultarLogAuditoriaResult:SoapRecv( WSAdvValue( oXmlRet,"_CONSULTARLOGAUDITORIARESPONSE:_CONSULTARLOGAUDITORIARESULT","ArrayOfConsultaLogAuditoriaOUT",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method ConsultaTicketsPorPeriodo of Service WSWS_GUARDIAN

WSMETHOD ConsultaTicketsPorPeriodo WSSEND cdataInicial,cdataFinal,cproduto,ccodigo WSRECEIVE oWSConsultaTicketsPorPeriodoResult,nErro,cErroMSG WSCLIENT WSWS_GUARDIAN
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ConsultaTicketsPorPeriodo xmlns="http://toledobrasil.com.br/WS_Guardian">'
cSoap += WSSoapValue("dataInicial", ::cdataInicial, cdataInicial , "dateTime", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("dataFinal", ::cdataFinal, cdataFinal , "dateTime", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("produto", ::cproduto, cproduto , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("codigo", ::ccodigo, ccodigo , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</ConsultaTicketsPorPeriodo>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://toledobrasil.com.br/WS_Guardian/ConsultaTicketsPorPeriodo",; 
	"DOCUMENT","http://toledobrasil.com.br/WS_Guardian",,,; 
	"http://infind.toledobrasil.com.br/WS_GUARDIAN/WS_GUARDIAN_PLUS.asmx")

::Init()
::oWSConsultaTicketsPorPeriodoResult:SoapRecv( WSAdvValue( oXmlRet,"_CONSULTATICKETSPORPERIODORESPONSE:_CONSULTATICKETSPORPERIODORESULT","ArrayOfTicket",NIL,NIL,NIL,NIL,NIL,NIL) )
::nErro              :=  WSAdvValue( oXmlRet,"_CONSULTATICKETSPORPERIODORESPONSE:_ERRO:TEXT","int",NIL,NIL,NIL,NIL,NIL,NIL) 
::cErroMSG           :=  WSAdvValue( oXmlRet,"_CONSULTATICKETSPORPERIODORESPONSE:_ERROMSG:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method ExportaVeiculosQuePossamTerPassadoSemPesarPelaBalanca of Service WSWS_GUARDIAN

WSMETHOD ExportaVeiculosQuePossamTerPassadoSemPesarPelaBalanca WSSEND NULLPARAM WSRECEIVE oWSExportaVeiculosQuePossamTerPassadoSemPesarPelaBalancaResult,nErro,cErroMSG WSCLIENT WSWS_GUARDIAN
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ExportaVeiculosQuePossamTerPassadoSemPesarPelaBalanca xmlns="http://toledobrasil.com.br/WS_Guardian">'
cSoap += "</ExportaVeiculosQuePossamTerPassadoSemPesarPelaBalanca>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://toledobrasil.com.br/WS_Guardian/ExportaVeiculosQuePossamTerPassadoSemPesarPelaBalanca",; 
	"DOCUMENT","http://toledobrasil.com.br/WS_Guardian",,,; 
	"http://infind.toledobrasil.com.br/WS_GUARDIAN/WS_GUARDIAN_PLUS.asmx")

::Init()
::oWSExportaVeiculosQuePossamTerPassadoSemPesarPelaBalancaResult:SoapRecv( WSAdvValue( oXmlRet,"_EXPORTAVEICULOSQUEPOSSAMTERPASSADOSEMPESARPELABALANCARESPONSE:_EXPORTAVEICULOSQUEPOSSAMTERPASSADOSEMPESARPELABALANCARESULT","ArrayOfHistoricoPassagem",NIL,NIL,NIL,NIL,NIL,NIL) )
::nErro              :=  WSAdvValue( oXmlRet,"_EXPORTAVEICULOSQUEPOSSAMTERPASSADOSEMPESARPELABALANCARESPONSE:_ERRO:TEXT","int",NIL,NIL,NIL,NIL,NIL,NIL) 
::cErroMSG           :=  WSAdvValue( oXmlRet,"_EXPORTAVEICULOSQUEPOSSAMTERPASSADOSEMPESARPELABALANCARESPONSE:_ERROMSG:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method RetornaVeiculosQuePossamTerPassadoSemPesarPelaBalanca of Service WSWS_GUARDIAN

WSMETHOD RetornaVeiculosQuePossamTerPassadoSemPesarPelaBalanca WSSEND cdataInicio,cdataFim WSRECEIVE oWSRetornaVeiculosQuePossamTerPassadoSemPesarPelaBalancaResult,nErro,cErroMSG WSCLIENT WSWS_GUARDIAN
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<RetornaVeiculosQuePossamTerPassadoSemPesarPelaBalanca xmlns="http://toledobrasil.com.br/WS_Guardian">'
cSoap += WSSoapValue("dataInicio", ::cdataInicio, cdataInicio , "dateTime", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("dataFim", ::cdataFim, cdataFim , "dateTime", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</RetornaVeiculosQuePossamTerPassadoSemPesarPelaBalanca>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://toledobrasil.com.br/WS_Guardian/RetornaVeiculosQuePossamTerPassadoSemPesarPelaBalanca",; 
	"DOCUMENT","http://toledobrasil.com.br/WS_Guardian",,,; 
	"http://infind.toledobrasil.com.br/WS_GUARDIAN/WS_GUARDIAN_PLUS.asmx")

::Init()
::oWSRetornaVeiculosQuePossamTerPassadoSemPesarPelaBalancaResult:SoapRecv( WSAdvValue( oXmlRet,"_RETORNAVEICULOSQUEPOSSAMTERPASSADOSEMPESARPELABALANCARESPONSE:_RETORNAVEICULOSQUEPOSSAMTERPASSADOSEMPESARPELABALANCARESULT","ArrayOfHistoricoPassagem",NIL,NIL,NIL,NIL,NIL,NIL) )
::nErro              :=  WSAdvValue( oXmlRet,"_RETORNAVEICULOSQUEPOSSAMTERPASSADOSEMPESARPELABALANCARESPONSE:_ERRO:TEXT","int",NIL,NIL,NIL,NIL,NIL,NIL) 
::cErroMSG           :=  WSAdvValue( oXmlRet,"_RETORNAVEICULOSQUEPOSSAMTERPASSADOSEMPESARPELABALANCARESPONSE:_ERROMSG:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method ConfirmaVeiculosQuePossamTerPassadoSemPesarPelaBalanca of Service WSWS_GUARDIAN

WSMETHOD ConfirmaVeiculosQuePossamTerPassadoSemPesarPelaBalanca WSSEND NULLPARAM WSRECEIVE lConfirmaVeiculosQuePossamTerPassadoSemPesarPelaBalancaResult,nErro,cErroMSG WSCLIENT WSWS_GUARDIAN
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ConfirmaVeiculosQuePossamTerPassadoSemPesarPelaBalanca xmlns="http://toledobrasil.com.br/WS_Guardian">'
cSoap += "</ConfirmaVeiculosQuePossamTerPassadoSemPesarPelaBalanca>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://toledobrasil.com.br/WS_Guardian/ConfirmaVeiculosQuePossamTerPassadoSemPesarPelaBalanca",; 
	"DOCUMENT","http://toledobrasil.com.br/WS_Guardian",,,; 
	"http://infind.toledobrasil.com.br/WS_GUARDIAN/WS_GUARDIAN_PLUS.asmx")

::Init()
::lConfirmaVeiculosQuePossamTerPassadoSemPesarPelaBalancaResult :=  WSAdvValue( oXmlRet,"_CONFIRMAVEICULOSQUEPOSSAMTERPASSADOSEMPESARPELABALANCARESPONSE:_CONFIRMAVEICULOSQUEPOSSAMTERPASSADOSEMPESARPELABALANCARESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 
::nErro              :=  WSAdvValue( oXmlRet,"_CONFIRMAVEICULOSQUEPOSSAMTERPASSADOSEMPESARPELABALANCARESPONSE:_ERRO:TEXT","int",NIL,NIL,NIL,NIL,NIL,NIL) 
::cErroMSG           :=  WSAdvValue( oXmlRet,"_CONFIRMAVEICULOSQUEPOSSAMTERPASSADOSEMPESARPELABALANCARESPONSE:_ERROMSG:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method IdentificaVagao of Service WSWS_GUARDIAN

WSMETHOD IdentificaVagao WSSEND oWSinfoCarregamento WSRECEIVE nIdentificaVagaoResult WSCLIENT WSWS_GUARDIAN
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<IdentificaVagao xmlns="http://toledobrasil.com.br/WS_Guardian">'
cSoap += WSSoapValue("infoCarregamento", ::oWSinfoCarregamento, oWSinfoCarregamento , "InformaCarregamento", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</IdentificaVagao>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://toledobrasil.com.br/WS_Guardian/IdentificaVagao",; 
	"DOCUMENT","http://toledobrasil.com.br/WS_Guardian",,,; 
	"http://infind.toledobrasil.com.br/WS_GUARDIAN/WS_GUARDIAN_PLUS.asmx")

::Init()
::nIdentificaVagaoResult :=  WSAdvValue( oXmlRet,"_IDENTIFICAVAGAORESPONSE:_IDENTIFICAVAGAORESULT:TEXT","int",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method ConfirmaTicketUnico of Service WSWS_GUARDIAN

WSMETHOD ConfirmaTicketUnico WSSEND nSequencialTicket,cnomeSistema,lFalhou,cproduto,ccodigo WSRECEIVE lConfirmaTicketUnicoResult WSCLIENT WSWS_GUARDIAN
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ConfirmaTicketUnico xmlns="http://toledobrasil.com.br/WS_Guardian">'
cSoap += WSSoapValue("SequencialTicket", ::nSequencialTicket, nSequencialTicket , "int", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("nomeSistema", ::cnomeSistema, cnomeSistema , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("Falhou", ::lFalhou, lFalhou , "boolean", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("produto", ::cproduto, cproduto , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("codigo", ::ccodigo, ccodigo , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</ConfirmaTicketUnico>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://toledobrasil.com.br/WS_Guardian/ConfirmaTicketUnico",; 
	"DOCUMENT","http://toledobrasil.com.br/WS_Guardian",,,; 
	"http://infind.toledobrasil.com.br/WS_GUARDIAN/WS_GUARDIAN_PLUS.asmx")

::Init()
::lConfirmaTicketUnicoResult :=  WSAdvValue( oXmlRet,"_CONFIRMATICKETUNICORESPONSE:_CONFIRMATICKETUNICORESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method ExportaTicketUnico of Service WSWS_GUARDIAN

WSMETHOD ExportaTicketUnico WSSEND lcompleta,cnomeSistema,lSincronizacao,cproduto,ccodigo WSRECEIVE oWSExportaTicketUnicoResult WSCLIENT WSWS_GUARDIAN
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ExportaTicketUnico xmlns="http://toledobrasil.com.br/WS_Guardian">'
cSoap += WSSoapValue("completa", ::lcompleta, lcompleta , "boolean", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("nomeSistema", ::cnomeSistema, cnomeSistema , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("Sincronizacao", ::lSincronizacao, lSincronizacao , "boolean", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("produto", ::cproduto, cproduto , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("codigo", ::ccodigo, ccodigo , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</ExportaTicketUnico>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://toledobrasil.com.br/WS_Guardian/ExportaTicketUnico",; 
	"DOCUMENT","http://toledobrasil.com.br/WS_Guardian",,,; 
	"http://infind.toledobrasil.com.br/WS_GUARDIAN/WS_GUARDIAN_PLUS.asmx")

::Init()
::oWSExportaTicketUnicoResult:SoapRecv( WSAdvValue( oXmlRet,"_EXPORTATICKETUNICORESPONSE:_EXPORTATICKETUNICORESULT","Ticket",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method SolicitaFotoAvulsa of Service WSWS_GUARDIAN

WSMETHOD SolicitaFotoAvulsa WSSEND ccodigoPontoControle,cposicaoCamera,ccaminhoFoto,cnomeFoto,cproduto,ccodigo WSRECEIVE nSolicitaFotoAvulsaResult,lErro,cErroMSG WSCLIENT WSWS_GUARDIAN
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<SolicitaFotoAvulsa xmlns="http://toledobrasil.com.br/WS_Guardian">'
cSoap += WSSoapValue("codigoPontoControle", ::ccodigoPontoControle, ccodigoPontoControle , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("posicaoCamera", ::cposicaoCamera, cposicaoCamera , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("caminhoFoto", ::ccaminhoFoto, ccaminhoFoto , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("nomeFoto", ::cnomeFoto, cnomeFoto , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("produto", ::cproduto, cproduto , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("codigo", ::ccodigo, ccodigo , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</SolicitaFotoAvulsa>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://toledobrasil.com.br/WS_Guardian/SolicitaFotoAvulsa",; 
	"DOCUMENT","http://toledobrasil.com.br/WS_Guardian",,,; 
	"http://infind.toledobrasil.com.br/WS_GUARDIAN/WS_GUARDIAN_PLUS.asmx")

::Init()
::nSolicitaFotoAvulsaResult :=  WSAdvValue( oXmlRet,"_SOLICITAFOTOAVULSARESPONSE:_SOLICITAFOTOAVULSARESULT:TEXT","int",NIL,NIL,NIL,NIL,NIL,NIL) 
::lErro              :=  WSAdvValue( oXmlRet,"_SOLICITAFOTOAVULSARESPONSE:_ERRO:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 
::cErroMSG           :=  WSAdvValue( oXmlRet,"_SOLICITAFOTOAVULSARESPONSE:_ERROMSG:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method SolicitaRetornoFotoAvulsa of Service WSWS_GUARDIAN

WSMETHOD SolicitaRetornoFotoAvulsa WSSEND nidSolicitacaoAvulsa,cproduto,ccodigo WSRECEIVE oWSSolicitaRetornoFotoAvulsaResult WSCLIENT WSWS_GUARDIAN
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<SolicitaRetornoFotoAvulsa xmlns="http://toledobrasil.com.br/WS_Guardian">'
cSoap += WSSoapValue("idSolicitacaoAvulsa", ::nidSolicitacaoAvulsa, nidSolicitacaoAvulsa , "int", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("produto", ::cproduto, cproduto , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("codigo", ::ccodigo, ccodigo , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</SolicitaRetornoFotoAvulsa>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://toledobrasil.com.br/WS_Guardian/SolicitaRetornoFotoAvulsa",; 
	"DOCUMENT","http://toledobrasil.com.br/WS_Guardian",,,; 
	"http://infind.toledobrasil.com.br/WS_GUARDIAN/WS_GUARDIAN_PLUS.asmx")

::Init()
::oWSSolicitaRetornoFotoAvulsaResult:SoapRecv( WSAdvValue( oXmlRet,"_SOLICITARETORNOFOTOAVULSARESPONSE:_SOLICITARETORNOFOTOAVULSARESULT","RetornoFotoAvulsa",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure PreCadastro

WSSTRUCT WS_GUARDIAN_PreCadastro
	WSDATA   cCodigo                   AS string OPTIONAL
	WSDATA   cPlacaCarreta             AS string OPTIONAL
	WSDATA   cPlacaVeiculo             AS string OPTIONAL
	WSDATA   oWSTransportadora         AS WS_GUARDIAN_TransportadoraIntegracao OPTIONAL
	WSDATA   oWSEmissor                AS WS_GUARDIAN_EmissorIntegracao OPTIONAL
	WSDATA   oWSMotorista              AS WS_GUARDIAN_MotoristaIntegracao OPTIONAL
	WSDATA   oWSItem                   AS WS_GUARDIAN_ArrayOfItemIntegracao OPTIONAL
	WSDATA   oWSDocumentos             AS WS_GUARDIAN_ArrayOfDocumento OPTIONAL
	WSDATA   cObservacao               AS string OPTIONAL
	WSDATA   cDataPesagem              AS dateTime OPTIONAL
	WSDATA   oWSFatoresCorrecao        AS WS_GUARDIAN_ArrayOfListaFatoresCorrecaoTicket OPTIONAL
	WSDATA   oWSCamposAdicionais       AS WS_GUARDIAN_ArrayOfCampoAdicionalTicket OPTIONAL
	WSDATA   cTagAssociado             AS string OPTIONAL
	WSDATA   cUnidadeAposConversao     AS string OPTIONAL
	WSDATA   cTipoVeiculo              AS string OPTIONAL
	WSDATA   lAceitaPesoLiquidoZero    AS boolean OPTIONAL
	WSDATA   nPesoAlvo                 AS decimal OPTIONAL
	WSDATA   nCorte                    AS decimal OPTIONAL
	WSDATA   nDosagemLenta             AS decimal OPTIONAL
	WSDATA   nPesoBruto                AS decimal OPTIONAL
	WSDATA   nTara                     AS decimal OPTIONAL
	WSDATA   nPesoBrutoOrigem          AS double  OPTIONAL
	WSDATA   nPesoMinimoOrigem         AS double  OPTIONAL
	WSDATA   nPesoMaximoOrigem         AS double  OPTIONAL
	WSDATA   nPesoTotalOrigem          AS double  OPTIONAL
	WSDATA   cFluxo                    AS string OPTIONAL
	WSDATA   nTipoDoFatorDeCorrecao    AS int    OPTIONAL
	WSDATA   cOperacaoDaPesagemInicial AS string OPTIONAL
	WSDATA   cPerifericoDaPesagemInicial AS string OPTIONAL
	WSDATA   nPesoDaPesagemInicial     AS double OPTIONAL
	WSDATA   cDataDaPesagemInicial     AS dateTime OPTIONAL
	WSDATA   oWSEmbalagensTicket       AS WS_GUARDIAN_ArrayOfEmbalagensTicket OPTIONAL
	WSDATA   cUsuario                  AS string OPTIONAL
	WSDATA   cReferenciaIntegracao     AS string OPTIONAL
	WSDATA   nNumeroTotalCompatimentos AS int OPTIONAL
	WSDATA   nTipoIdentificacaoCompartimento AS int OPTIONAL
	WSDATA   lMarcardoParaCancelar     AS boolean OPTIONAL
	WSDATA   lOCRMarcardoParaNaoValida AS boolean OPTIONAL
	WSDATA   nNumeroConteineres        AS int OPTIONAL
	WSDATA   oWSConteineres            AS WS_GUARDIAN_ArrayOfConteinerVO OPTIONAL
	WSDATA   oWSPontosDoFluxo          AS WS_GUARDIAN_ArrayOfPontoDoFluxo OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WS_GUARDIAN_PreCadastro
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WS_GUARDIAN_PreCadastro
Return

WSMETHOD CLONE WSCLIENT WS_GUARDIAN_PreCadastro
	Local oClone := WS_GUARDIAN_PreCadastro():NEW()
	oClone:cCodigo              := ::cCodigo
	oClone:cPlacaCarreta        := ::cPlacaCarreta
	oClone:cPlacaVeiculo        := ::cPlacaVeiculo
	oClone:oWSTransportadora    := IIF(::oWSTransportadora = NIL , NIL , ::oWSTransportadora:Clone() )
	oClone:oWSEmissor           := IIF(::oWSEmissor = NIL , NIL , ::oWSEmissor:Clone() )
	oClone:oWSMotorista         := IIF(::oWSMotorista = NIL , NIL , ::oWSMotorista:Clone() )
	oClone:oWSItem              := IIF(::oWSItem = NIL , NIL , ::oWSItem:Clone() )
	oClone:oWSDocumentos        := IIF(::oWSDocumentos = NIL , NIL , ::oWSDocumentos:Clone() )
	oClone:cObservacao          := ::cObservacao
	oClone:cDataPesagem         := ::cDataPesagem
	oClone:oWSFatoresCorrecao   := IIF(::oWSFatoresCorrecao = NIL , NIL , ::oWSFatoresCorrecao:Clone() )
	oClone:oWSCamposAdicionais  := IIF(::oWSCamposAdicionais = NIL , NIL , ::oWSCamposAdicionais:Clone() )
	oClone:cTagAssociado        := ::cTagAssociado
	oClone:cUnidadeAposConversao := ::cUnidadeAposConversao
	oClone:cTipoVeiculo         := ::cTipoVeiculo
	oClone:lAceitaPesoLiquidoZero := ::lAceitaPesoLiquidoZero
	oClone:nPesoAlvo            := ::nPesoAlvo
	oClone:nCorte               := ::nCorte
	oClone:nDosagemLenta        := ::nDosagemLenta
	oClone:nPesoBruto           := ::nPesoBruto
	oClone:nTara                := ::nTara
	oClone:nPesoBrutoOrigem     := ::nPesoBrutoOrigem
	oClone:nPesoMinimoOrigem    := ::nPesoMinimoOrigem
	oClone:nPesoMaximoOrigem    := ::nPesoMaximoOrigem
	oClone:nPesoTotalOrigem     := ::nPesoTotalOrigem
	oClone:cFluxo               := ::cFluxo
	oClone:nTipoDoFatorDeCorrecao := ::nTipoDoFatorDeCorrecao
	oClone:cOperacaoDaPesagemInicial := ::cOperacaoDaPesagemInicial
	oClone:cPerifericoDaPesagemInicial := ::cPerifericoDaPesagemInicial
	oClone:nPesoDaPesagemInicial := ::nPesoDaPesagemInicial
	oClone:cDataDaPesagemInicial := ::cDataDaPesagemInicial
	oClone:oWSEmbalagensTicket  := IIF(::oWSEmbalagensTicket = NIL , NIL , ::oWSEmbalagensTicket:Clone() )
	oClone:cUsuario             := ::cUsuario
	oClone:cReferenciaIntegracao := ::cReferenciaIntegracao
	oClone:nNumeroTotalCompatimentos := ::nNumeroTotalCompatimentos
	oClone:nTipoIdentificacaoCompartimento := ::nTipoIdentificacaoCompartimento
	oClone:lMarcardoParaCancelar := ::lMarcardoParaCancelar
	oClone:lOCRMarcardoParaNaoValida := ::lOCRMarcardoParaNaoValida
	oClone:nNumeroConteineres   := ::nNumeroConteineres
	oClone:oWSConteineres       := IIF(::oWSConteineres = NIL , NIL , ::oWSConteineres:Clone() )
	oClone:oWSPontosDoFluxo     := IIF(::oWSPontosDoFluxo = NIL , NIL , ::oWSPontosDoFluxo:Clone() )
Return oClone

WSMETHOD SOAPSEND WSCLIENT WS_GUARDIAN_PreCadastro
	Local cSoap := ""
	cSoap += WSSoapValue("Codigo", ::cCodigo, ::cCodigo , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("PlacaCarreta", ::cPlacaCarreta, ::cPlacaCarreta , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("PlacaVeiculo", ::cPlacaVeiculo, ::cPlacaVeiculo , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Transportadora", ::oWSTransportadora, ::oWSTransportadora , "TransportadoraIntegracao", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Emissor", ::oWSEmissor, ::oWSEmissor , "EmissorIntegracao", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Motorista", ::oWSMotorista, ::oWSMotorista , "MotoristaIntegracao", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Item", ::oWSItem, ::oWSItem , "ArrayOfItemIntegracao", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Documentos", ::oWSDocumentos, ::oWSDocumentos , "ArrayOfDocumento", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Observacao", ::cObservacao, ::cObservacao , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("DataPesagem", ::cDataPesagem, ::cDataPesagem , "dateTime", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("FatoresCorrecao", ::oWSFatoresCorrecao, ::oWSFatoresCorrecao , "ArrayOfListaFatoresCorrecaoTicket", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CamposAdicionais", ::oWSCamposAdicionais, ::oWSCamposAdicionais , "ArrayOfCampoAdicionalTicket", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("TagAssociado", ::cTagAssociado, ::cTagAssociado , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("UnidadeAposConversao", ::cUnidadeAposConversao, ::cUnidadeAposConversao , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("TipoVeiculo", ::cTipoVeiculo, ::cTipoVeiculo , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("AceitaPesoLiquidoZero", ::lAceitaPesoLiquidoZero, ::lAceitaPesoLiquidoZero , "boolean", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("PesoAlvo", ::nPesoAlvo, ::nPesoAlvo , "decimal", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Corte", ::nCorte, ::nCorte , "decimal", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("DosagemLenta", ::nDosagemLenta, ::nDosagemLenta , "decimal", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("PesoBruto", ::nPesoBruto, ::nPesoBruto , "decimal", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Tara", ::nTara, ::nTara , "decimal", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("PesoBrutoOrigem", ::nPesoBrutoOrigem, ::nPesoBrutoOrigem , "double", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("PesoMinimoOrigem", ::nPesoMinimoOrigem, ::nPesoMinimoOrigem , "double", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("PesoMaximoOrigem", ::nPesoMaximoOrigem, ::nPesoMaximoOrigem , "double", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("PesoTotalOrigem", ::nPesoTotalOrigem, ::nPesoTotalOrigem , "double", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Fluxo", ::cFluxo, ::cFluxo , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("TipoDoFatorDeCorrecao", ::nTipoDoFatorDeCorrecao, ::nTipoDoFatorDeCorrecao , "int", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("OperacaoDaPesagemInicial", ::cOperacaoDaPesagemInicial, ::cOperacaoDaPesagemInicial , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("PerifericoDaPesagemInicial", ::cPerifericoDaPesagemInicial, ::cPerifericoDaPesagemInicial , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("PesoDaPesagemInicial", ::nPesoDaPesagemInicial, ::nPesoDaPesagemInicial , "double", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("DataDaPesagemInicial", ::cDataDaPesagemInicial, ::cDataDaPesagemInicial , "dateTime", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("EmbalagensTicket", ::oWSEmbalagensTicket, ::oWSEmbalagensTicket , "ArrayOfEmbalagensTicket", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Usuario", ::cUsuario, ::cUsuario , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ReferenciaIntegracao", ::cReferenciaIntegracao, ::cReferenciaIntegracao , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("NumeroTotalCompatimentos", ::nNumeroTotalCompatimentos, ::nNumeroTotalCompatimentos , "int", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("TipoIdentificacaoCompartimento", ::nTipoIdentificacaoCompartimento, ::nTipoIdentificacaoCompartimento , "int", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("MarcardoParaCancelar", ::lMarcardoParaCancelar, ::lMarcardoParaCancelar , "boolean", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("OCRMarcardoParaNaoValida", ::lOCRMarcardoParaNaoValida, ::lOCRMarcardoParaNaoValida , "boolean", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("NumeroConteineres", ::nNumeroConteineres, ::nNumeroConteineres , "int", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Conteineres", ::oWSConteineres, ::oWSConteineres , "ArrayOfConteinerVO", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("PontosDoFluxo", ::oWSPontosDoFluxo, ::oWSPontosDoFluxo , "ArrayOfPontoDoFluxo", .F. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

// WSDL Data Structure Ticket

WSSTRUCT WS_GUARDIAN_Ticket
	WSDATA   nSequencial               AS int
	WSDATA   cCodigo                   AS string OPTIONAL
	WSDATA   cPlacaCarreta             AS string OPTIONAL
	WSDATA   oWSTransportadora         AS WS_GUARDIAN_ETransportadora OPTIONAL
	WSDATA   oWSEmissor                AS WS_GUARDIAN_EEmissor OPTIONAL
	WSDATA   oWSItem                   AS WS_GUARDIAN_ArrayOfEItem OPTIONAL
	WSDATA   oWSItemTicket             AS WS_GUARDIAN_ArrayOfItemTicket OPTIONAL
	WSDATA   oWSDocumentos             AS WS_GUARDIAN_ArrayOfDocumento OPTIONAL
	WSDATA   cObservacao               AS string OPTIONAL
	WSDATA   cDataPesagem              AS dateTime
	WSDATA   oWSFatoresCorrecao        AS WS_GUARDIAN_ArrayOfListaFatoresCorrecaoTicket OPTIONAL
	WSDATA   oWSCamposAdicionais       AS WS_GUARDIAN_ArrayOfCampoAdicionalTicket OPTIONAL
	WSDATA   cTagAssociado             AS string OPTIONAL
	WSDATA   nEstado                   AS int
	WSDATA   nFluxoTicket              AS int
	WSDATA   nCalculoFatorCorrecao     AS int
	WSDATA   nTipoOperacao             AS int
	WSDATA   nTipoFatorCorrecao        AS int
	WSDATA   oWSOperacaoTicket         AS WS_GUARDIAN_ArrayOfOperacaoTicket OPTIONAL
	WSDATA   oWSReimpressaoTicket      AS WS_GUARDIAN_ArrayOfReimpressoesTicket OPTIONAL
	WSDATA   oWSEmbalagensTicket       AS WS_GUARDIAN_ArrayOfEEmbalagensTicket OPTIONAL
	WSDATA   oWSFluxoTicketSequencia   AS WS_GUARDIAN_ArrayOfFluxoTicketSequencia OPTIONAL
	WSDATA   cCodigoEmissor            AS string OPTIONAL
	WSDATA   cCodigoTransportadora     AS string OPTIONAL
	WSDATA   cCodigoCalculoFatorCorrecao AS string OPTIONAL
	WSDATA   cCodigoFluxoTicket        AS string OPTIONAL
	WSDATA   nSequencialDiario         AS int
	WSDATA   nEstadoAguardando         AS int
	WSDATA   lPesagemManual            AS boolean
	WSDATA   lPesagemEmContingencia    AS boolean
	WSDATA   oWSIntegracoesOCR         AS WS_GUARDIAN_ArrayOfIntegracaoOCR OPTIONAL
	WSDATA   cMensagemRetornoWebMetodo AS string OPTIONAL
	WSDATA   lSincronizado             AS boolean
	WSDATA   nDiferencaOrigem          AS decimal
	WSDATA   lBloqueiaBotoeira         AS boolean
	WSDATA   lPesagemFerroviaria       AS boolean
	WSDATA   cReferenciaIntegracao     AS string OPTIONAL
	WSDATA   nNumeroTotalCompartimentos AS int
	WSDATA   nTipoIdentificacaoCompartimento AS int
	WSDATA   lMarcardoParaCancelar     AS boolean
	WSDATA   lOCRMarcardoParaNaoValida AS boolean
	WSDATA   nNumeroConteineres        AS int
	WSDATA   oWSConteineres            AS WS_GUARDIAN_ArrayOfConteinerVO OPTIONAL
	WSDATA   nPesoBruto                AS decimal 
	WSDATA   nTara                     AS decimal
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WS_GUARDIAN_Ticket
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WS_GUARDIAN_Ticket
Return

WSMETHOD CLONE WSCLIENT WS_GUARDIAN_Ticket
	Local oClone := WS_GUARDIAN_Ticket():NEW()
	oClone:nSequencial          := ::nSequencial
	oClone:cCodigo              := ::cCodigo
	oClone:cPlacaCarreta        := ::cPlacaCarreta
	oClone:oWSTransportadora    := IIF(::oWSTransportadora = NIL , NIL , ::oWSTransportadora:Clone() )
	oClone:oWSEmissor           := IIF(::oWSEmissor = NIL , NIL , ::oWSEmissor:Clone() )
	oClone:oWSItem              := IIF(::oWSItem = NIL , NIL , ::oWSItem:Clone() )
	oClone:oWSItemTicket        := IIF(::oWSItemTicket = NIL , NIL , ::oWSItemTicket:Clone() )
	oClone:oWSDocumentos        := IIF(::oWSDocumentos = NIL , NIL , ::oWSDocumentos:Clone() )
	oClone:cObservacao          := ::cObservacao
	oClone:cDataPesagem         := ::cDataPesagem
	oClone:oWSFatoresCorrecao   := IIF(::oWSFatoresCorrecao = NIL , NIL , ::oWSFatoresCorrecao:Clone() )
	oClone:oWSCamposAdicionais  := IIF(::oWSCamposAdicionais = NIL , NIL , ::oWSCamposAdicionais:Clone() )
	oClone:cTagAssociado        := ::cTagAssociado
	oClone:nEstado              := ::nEstado
	oClone:nFluxoTicket         := ::nFluxoTicket
	oClone:nCalculoFatorCorrecao := ::nCalculoFatorCorrecao
	oClone:nTipoOperacao        := ::nTipoOperacao
	oClone:nTipoFatorCorrecao   := ::nTipoFatorCorrecao
	oClone:oWSOperacaoTicket    := IIF(::oWSOperacaoTicket = NIL , NIL , ::oWSOperacaoTicket:Clone() )
	oClone:oWSReimpressaoTicket := IIF(::oWSReimpressaoTicket = NIL , NIL , ::oWSReimpressaoTicket:Clone() )
	oClone:oWSEmbalagensTicket  := IIF(::oWSEmbalagensTicket = NIL , NIL , ::oWSEmbalagensTicket:Clone() )
	oClone:oWSFluxoTicketSequencia := IIF(::oWSFluxoTicketSequencia = NIL , NIL , ::oWSFluxoTicketSequencia:Clone() )
	oClone:cCodigoEmissor       := ::cCodigoEmissor
	oClone:cCodigoTransportadora := ::cCodigoTransportadora
	oClone:cCodigoCalculoFatorCorrecao := ::cCodigoCalculoFatorCorrecao
	oClone:cCodigoFluxoTicket   := ::cCodigoFluxoTicket
	oClone:nSequencialDiario    := ::nSequencialDiario
	oClone:nEstadoAguardando    := ::nEstadoAguardando
	oClone:lPesagemManual       := ::lPesagemManual
	oClone:lPesagemEmContingencia := ::lPesagemEmContingencia
	oClone:oWSIntegracoesOCR    := IIF(::oWSIntegracoesOCR = NIL , NIL , ::oWSIntegracoesOCR:Clone() )
	oClone:cMensagemRetornoWebMetodo := ::cMensagemRetornoWebMetodo
	oClone:lSincronizado        := ::lSincronizado
	oClone:nDiferencaOrigem     := ::nDiferencaOrigem
	oClone:lBloqueiaBotoeira    := ::lBloqueiaBotoeira
	oClone:lPesagemFerroviaria  := ::lPesagemFerroviaria
	oClone:cReferenciaIntegracao := ::cReferenciaIntegracao
	oClone:nNumeroTotalCompartimentos := ::nNumeroTotalCompartimentos
	oClone:nTipoIdentificacaoCompartimento := ::nTipoIdentificacaoCompartimento
	oClone:lMarcardoParaCancelar := ::lMarcardoParaCancelar
	oClone:lOCRMarcardoParaNaoValida := ::lOCRMarcardoParaNaoValida
	oClone:nNumeroConteineres   := ::nNumeroConteineres
	oClone:oWSConteineres       := IIF(::oWSConteineres = NIL , NIL , ::oWSConteineres:Clone() )
	oClone:nPesoBruto           := ::nPesoBruto
	oClone:nTara                := ::nTara
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WS_GUARDIAN_Ticket
	Local oNode4
	Local oNode5
	Local oNode6
	Local oNode7
	Local oNode8
	Local oNode11
	Local oNode12
	Local oNode19
	Local oNode20
	Local oNode21
	Local oNode22
	Local oNode31
	Local oNode43
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::nSequencial        :=  WSAdvValue( oResponse,"_SEQUENCIAL","int",NIL,"Property nSequencial as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cCodigo            :=  WSAdvValue( oResponse,"_CODIGO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cPlacaCarreta      :=  WSAdvValue( oResponse,"_PLACACARRETA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	oNode4 :=  WSAdvValue( oResponse,"_TRANSPORTADORA","ETransportadora",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode4 != NIL
		::oWSTransportadora := WS_GUARDIAN_ETransportadora():New()
		::oWSTransportadora:SoapRecv(oNode4)
	EndIf
	oNode5 :=  WSAdvValue( oResponse,"_EMISSOR","EEmissor",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode5 != NIL
		::oWSEmissor := WS_GUARDIAN_EEmissor():New()
		::oWSEmissor:SoapRecv(oNode5)
	EndIf
	oNode6 :=  WSAdvValue( oResponse,"_ITEM","ArrayOfEItem",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode6 != NIL
		::oWSItem := WS_GUARDIAN_ArrayOfEItem():New()
		::oWSItem:SoapRecv(oNode6)
	EndIf
	oNode7 :=  WSAdvValue( oResponse,"_ITEMTICKET","ArrayOfItemTicket",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode7 != NIL
		::oWSItemTicket := WS_GUARDIAN_ArrayOfItemTicket():New()
		::oWSItemTicket:SoapRecv(oNode7)
	EndIf
	oNode8 :=  WSAdvValue( oResponse,"_DOCUMENTOS","ArrayOfDocumento",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode8 != NIL
		::oWSDocumentos := WS_GUARDIAN_ArrayOfDocumento():New()
		::oWSDocumentos:SoapRecv(oNode8)
	EndIf
	::cObservacao        :=  WSAdvValue( oResponse,"_OBSERVACAO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cDataPesagem       :=  WSAdvValue( oResponse,"_DATAPESAGEM","dateTime",NIL,"Property cDataPesagem as s:dateTime on SOAP Response not found.",NIL,"S",NIL,NIL) 
	oNode11 :=  WSAdvValue( oResponse,"_FATORESCORRECAO","ArrayOfListaFatoresCorrecaoTicket",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode11 != NIL
		::oWSFatoresCorrecao := WS_GUARDIAN_ArrayOfListaFatoresCorrecaoTicket():New()
		::oWSFatoresCorrecao:SoapRecv(oNode11)
	EndIf
	oNode12 :=  WSAdvValue( oResponse,"_CAMPOSADICIONAIS","ArrayOfCampoAdicionalTicket",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode12 != NIL
		::oWSCamposAdicionais := WS_GUARDIAN_ArrayOfCampoAdicionalTicket():New()
		::oWSCamposAdicionais:SoapRecv(oNode12)
	EndIf
	::cTagAssociado      :=  WSAdvValue( oResponse,"_TAGASSOCIADO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nEstado            :=  WSAdvValue( oResponse,"_ESTADO","int",NIL,"Property nEstado as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nFluxoTicket       :=  WSAdvValue( oResponse,"_FLUXOTICKET","int",NIL,"Property nFluxoTicket as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nCalculoFatorCorrecao :=  WSAdvValue( oResponse,"_CALCULOFATORCORRECAO","int",NIL,"Property nCalculoFatorCorrecao as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nTipoOperacao      :=  WSAdvValue( oResponse,"_TIPOOPERACAO","int",NIL,"Property nTipoOperacao as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nTipoFatorCorrecao :=  WSAdvValue( oResponse,"_TIPOFATORCORRECAO","int",NIL,"Property nTipoFatorCorrecao as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	oNode19 :=  WSAdvValue( oResponse,"_OPERACAOTICKET","ArrayOfOperacaoTicket",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode19 != NIL
		::oWSOperacaoTicket := WS_GUARDIAN_ArrayOfOperacaoTicket():New()
		::oWSOperacaoTicket:SoapRecv(oNode19)
	EndIf
	oNode20 :=  WSAdvValue( oResponse,"_REIMPRESSAOTICKET","ArrayOfReimpressoesTicket",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode20 != NIL
		::oWSReimpressaoTicket := WS_GUARDIAN_ArrayOfReimpressoesTicket():New()
		::oWSReimpressaoTicket:SoapRecv(oNode20)
	EndIf
	oNode21 :=  WSAdvValue( oResponse,"_EMBALAGENSTICKET","ArrayOfEEmbalagensTicket",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode21 != NIL
		::oWSEmbalagensTicket := WS_GUARDIAN_ArrayOfEEmbalagensTicket():New()
		::oWSEmbalagensTicket:SoapRecv(oNode21)
	EndIf
	oNode22 :=  WSAdvValue( oResponse,"_FLUXOTICKETSEQUENCIA","ArrayOfFluxoTicketSequencia",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode22 != NIL
		::oWSFluxoTicketSequencia := WS_GUARDIAN_ArrayOfFluxoTicketSequencia():New()
		::oWSFluxoTicketSequencia:SoapRecv(oNode22)
	EndIf
	::cCodigoEmissor     :=  WSAdvValue( oResponse,"_CODIGOEMISSOR","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cCodigoTransportadora :=  WSAdvValue( oResponse,"_CODIGOTRANSPORTADORA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cCodigoCalculoFatorCorrecao :=  WSAdvValue( oResponse,"_CODIGOCALCULOFATORCORRECAO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cCodigoFluxoTicket :=  WSAdvValue( oResponse,"_CODIGOFLUXOTICKET","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nSequencialDiario  :=  WSAdvValue( oResponse,"_SEQUENCIALDIARIO","int",NIL,"Property nSequencialDiario as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nEstadoAguardando  :=  WSAdvValue( oResponse,"_ESTADOAGUARDANDO","int",NIL,"Property nEstadoAguardando as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::lPesagemManual     :=  WSAdvValue( oResponse,"_PESAGEMMANUAL","boolean",NIL,"Property lPesagemManual as s:boolean on SOAP Response not found.",NIL,"L",NIL,NIL) 
	::lPesagemEmContingencia :=  WSAdvValue( oResponse,"_PESAGEMEMCONTINGENCIA","boolean",NIL,"Property lPesagemEmContingencia as s:boolean on SOAP Response not found.",NIL,"L",NIL,NIL) 
	oNode31 :=  WSAdvValue( oResponse,"_INTEGRACOESOCR","ArrayOfIntegracaoOCR",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode31 != NIL
		::oWSIntegracoesOCR := WS_GUARDIAN_ArrayOfIntegracaoOCR():New()
		::oWSIntegracoesOCR:SoapRecv(oNode31)
	EndIf
	::cMensagemRetornoWebMetodo :=  WSAdvValue( oResponse,"_MENSAGEMRETORNOWEBMETODO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::lSincronizado      :=  WSAdvValue( oResponse,"_SINCRONIZADO","boolean",NIL,"Property lSincronizado as s:boolean on SOAP Response not found.",NIL,"L",NIL,NIL) 
	::nDiferencaOrigem   :=  WSAdvValue( oResponse,"_DIFERENCAORIGEM","decimal",NIL,"Property nDiferencaOrigem as s:decimal on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::lBloqueiaBotoeira  :=  WSAdvValue( oResponse,"_BLOQUEIABOTOEIRA","boolean",NIL,"Property lBloqueiaBotoeira as s:boolean on SOAP Response not found.",NIL,"L",NIL,NIL) 
	::lPesagemFerroviaria :=  WSAdvValue( oResponse,"_PESAGEMFERROVIARIA","boolean",NIL,"Property lPesagemFerroviaria as s:boolean on SOAP Response not found.",NIL,"L",NIL,NIL) 
	::cReferenciaIntegracao :=  WSAdvValue( oResponse,"_REFERENCIAINTEGRACAO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nNumeroTotalCompartimentos :=  WSAdvValue( oResponse,"_NUMEROTOTALCOMPARTIMENTOS","int",NIL,"Property nNumeroTotalCompartimentos as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nTipoIdentificacaoCompartimento :=  WSAdvValue( oResponse,"_TIPOIDENTIFICACAOCOMPARTIMENTO","int",NIL,"Property nTipoIdentificacaoCompartimento as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::lMarcardoParaCancelar :=  WSAdvValue( oResponse,"_MARCARDOPARACANCELAR","boolean",NIL,"Property lMarcardoParaCancelar as s:boolean on SOAP Response not found.",NIL,"L",NIL,NIL) 
	::lOCRMarcardoParaNaoValida :=  WSAdvValue( oResponse,"_OCRMARCARDOPARANAOVALIDA","boolean",NIL,"Property lOCRMarcardoParaNaoValida as s:boolean on SOAP Response not found.",NIL,"L",NIL,NIL) 
	::nNumeroConteineres :=  WSAdvValue( oResponse,"_NUMEROCONTEINERES","int",NIL,"Property nNumeroConteineres as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	oNode43 :=  WSAdvValue( oResponse,"_CONTEINERES","ArrayOfConteinerVO",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode43 != NIL
		::oWSConteineres := WS_GUARDIAN_ArrayOfConteinerVO():New()
		::oWSConteineres:SoapRecv(oNode43)
	EndIf
	::nPesoBruto         :=  WSAdvValue( oResponse,"_PESOBRUTO","decimal",NIL,"Property nPesoBruto as s:decimal on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nTara              :=  WSAdvValue( oResponse,"_TARA","decimal",NIL,"Property nTara as s:decimal on SOAP Response not found.",NIL,"N",NIL,NIL) 
Return

// WSDL Data Structure ConfiguracaoAlteracao

WSSTRUCT WS_GUARDIAN_ConfiguracaoAlteracao
	WSDATA   lIgnoraTransportadora     AS boolean
	WSDATA   lIgnoraEmissor            AS boolean
	WSDATA   lIgnoraItens              AS boolean
	WSDATA   lIgnoraMotorista          AS boolean
	WSDATA   lIgnoraDocumentos         AS boolean
	WSDATA   lIgnoraCamposAdicionais   AS boolean
	WSDATA   lIgnoraFatorCorrecao      AS boolean
	WSDATA   lIgnoraConteineres        AS boolean
	WSDATA   lIgnoraFluxo              AS boolean
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WS_GUARDIAN_ConfiguracaoAlteracao
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WS_GUARDIAN_ConfiguracaoAlteracao
Return

WSMETHOD CLONE WSCLIENT WS_GUARDIAN_ConfiguracaoAlteracao
	Local oClone := WS_GUARDIAN_ConfiguracaoAlteracao():NEW()
	oClone:lIgnoraTransportadora := ::lIgnoraTransportadora
	oClone:lIgnoraEmissor       := ::lIgnoraEmissor
	oClone:lIgnoraItens         := ::lIgnoraItens
	oClone:lIgnoraMotorista     := ::lIgnoraMotorista
	oClone:lIgnoraDocumentos    := ::lIgnoraDocumentos
	oClone:lIgnoraCamposAdicionais := ::lIgnoraCamposAdicionais
	oClone:lIgnoraFatorCorrecao := ::lIgnoraFatorCorrecao
	oClone:lIgnoraConteineres   := ::lIgnoraConteineres
	oClone:lIgnoraFluxo         := ::lIgnoraFluxo
Return oClone

WSMETHOD SOAPSEND WSCLIENT WS_GUARDIAN_ConfiguracaoAlteracao
	Local cSoap := ""
	cSoap += WSSoapValue("IgnoraTransportadora", ::lIgnoraTransportadora, ::lIgnoraTransportadora , "boolean", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("IgnoraEmissor", ::lIgnoraEmissor, ::lIgnoraEmissor , "boolean", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("IgnoraItens", ::lIgnoraItens, ::lIgnoraItens , "boolean", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("IgnoraMotorista", ::lIgnoraMotorista, ::lIgnoraMotorista , "boolean", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("IgnoraDocumentos", ::lIgnoraDocumentos, ::lIgnoraDocumentos , "boolean", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("IgnoraCamposAdicionais", ::lIgnoraCamposAdicionais, ::lIgnoraCamposAdicionais , "boolean", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("IgnoraFatorCorrecao", ::lIgnoraFatorCorrecao, ::lIgnoraFatorCorrecao , "boolean", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("IgnoraConteineres", ::lIgnoraConteineres, ::lIgnoraConteineres , "boolean", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("IgnoraFluxo", ::lIgnoraFluxo, ::lIgnoraFluxo , "boolean", .T. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

// WSDL Data Structure ArrayOfTicket

WSSTRUCT WS_GUARDIAN_ArrayOfTicket
	WSDATA   oWSTicket                 AS WS_GUARDIAN_Ticket OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WS_GUARDIAN_ArrayOfTicket
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WS_GUARDIAN_ArrayOfTicket
	::oWSTicket            := {} // Array Of  WS_GUARDIAN_TICKET():New()
Return

WSMETHOD CLONE WSCLIENT WS_GUARDIAN_ArrayOfTicket
	Local oClone := WS_GUARDIAN_ArrayOfTicket():NEW()
	oClone:oWSTicket := NIL
	If ::oWSTicket <> NIL 
		oClone:oWSTicket := {}
		aEval( ::oWSTicket , { |x| aadd( oClone:oWSTicket , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WS_GUARDIAN_ArrayOfTicket
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_TICKET","Ticket",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSTicket , WS_GUARDIAN_Ticket():New() )
			::oWSTicket[len(::oWSTicket)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ImportaTicketG4

WSSTRUCT WS_GUARDIAN_ImportaTicketG4
	WSDATA   oWSDocumentosDoTicket     AS WS_GUARDIAN_ArrayOfImportaDocumentoDoTicketG4 OPTIONAL
	WSDATA   oWSItensDoTicket          AS WS_GUARDIAN_ArrayOfImportaItemDoTicketG4 OPTIONAL
	WSDATA   nChave                    AS int
	WSDATA   cSequencial               AS string OPTIONAL
	WSDATA   cPlacaCarreta             AS string OPTIONAL
	WSDATA   cPlacaVeiculo             AS string OPTIONAL
	WSDATA   cNumTransp                AS string OPTIONAL
	WSDATA   cCodTransportadora        AS string OPTIONAL
	WSDATA   cCodEmissor               AS string OPTIONAL
	WSDATA   cRazSocTrans              AS string OPTIONAL
	WSDATA   cRazSocEmissor            AS string OPTIONAL
	WSDATA   nFatCorrecao              AS float
	WSDATA   nFatConversao             AS float
	WSDATA   cUnidadeAposConversao     AS string OPTIONAL
	WSDATA   nPesoTotDoc               AS float
	WSDATA   nPesoBrutoDoc             AS float
	WSDATA   nFatCorrecao1             AS float
	WSDATA   nFatCorrecao2             AS float
	WSDATA   nFatCorrecao3             AS float
	WSDATA   nFatCorrecao4             AS float
	WSDATA   nFatCorrecao5             AS float
	WSDATA   nFatCorrecao6             AS float
	WSDATA   cDtHrPreEntrada           AS dateTime
	WSDATA   cOpPreEntrada             AS string OPTIONAL
	WSDATA   cMemoObs                  AS string OPTIONAL
	WSDATA   nQtdeTara1                AS int
	WSDATA   nPesoTara1                AS float
	WSDATA   cTipoTara1                AS string OPTIONAL
	WSDATA   nQtdeTara2                AS int
	WSDATA   nPesoTara2                AS float
	WSDATA   cTipoTara2                AS string OPTIONAL
	WSDATA   nQtdeTara3                AS int
	WSDATA   nPesoTara3                AS float
	WSDATA   cTipoTara3                AS string OPTIONAL
	WSDATA   nQtdeTara4                AS int
	WSDATA   nPesoTara4                AS float
	WSDATA   cTipoTara4                AS string OPTIONAL
	WSDATA   nQtdeTara5                AS int
	WSDATA   nPesoTara5                AS float
	WSDATA   cTipoTara5                AS string OPTIONAL
	WSDATA   nQtdeTara6                AS int
	WSDATA   nPesoTara6                AS float
	WSDATA   cTipoTara6                AS string OPTIONAL
	WSDATA   cCampoUsu1                AS string OPTIONAL
	WSDATA   cCampoUsu2                AS string OPTIONAL
	WSDATA   cCampoUsu3                AS string OPTIONAL
	WSDATA   cCampoUsu4                AS string OPTIONAL
	WSDATA   cCampoUsu5                AS string OPTIONAL
	WSDATA   cCampoUsu6                AS string OPTIONAL
	WSDATA   cCampoUsu7                AS string OPTIONAL
	WSDATA   cCampoUsu8                AS string OPTIONAL
	WSDATA   cCampoUsu9                AS string OPTIONAL
	WSDATA   cCampoUsu10               AS string OPTIONAL
	WSDATA   nPesoLiqCorrUsu           AS float
	WSDATA   nCodRota                  AS int
	WSDATA   nPtRetRota                AS int
	WSDATA   cVeicTipo                 AS string OPTIONAL
	WSDATA   nPesoTaraDoc              AS float
	WSDATA   nNumCompart               AS int
	WSDATA   cDpyCompart               AS string OPTIONAL
	WSDATA   cTmpVeicExt               AS string OPTIONAL
	WSDATA   cPtoDesc                  AS string OPTIONAL
	WSDATA   nDosaAlvo                 AS int
	WSDATA   nDosaLenta                AS int
	WSDATA   nDosaCorte                AS int
	WSDATA   nVfyMws                   AS int
	WSDATA   cBackReg                  AS string OPTIONAL
	WSDATA   cBalToUse                 AS string OPTIONAL
	WSDATA   cDescDocTot               AS string OPTIONAL
	WSDATA   nPesoInicial              AS float
	WSDATA   cOpPesoInicial            AS string OPTIONAL
	WSDATA   cDtHrPesoInicial          AS dateTime
	WSDATA   cBalPesoInicial           AS string OPTIONAL
	WSDATA   cFlag                     AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WS_GUARDIAN_ImportaTicketG4
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WS_GUARDIAN_ImportaTicketG4
Return

WSMETHOD CLONE WSCLIENT WS_GUARDIAN_ImportaTicketG4
	Local oClone := WS_GUARDIAN_ImportaTicketG4():NEW()
	oClone:oWSDocumentosDoTicket := IIF(::oWSDocumentosDoTicket = NIL , NIL , ::oWSDocumentosDoTicket:Clone() )
	oClone:oWSItensDoTicket     := IIF(::oWSItensDoTicket = NIL , NIL , ::oWSItensDoTicket:Clone() )
	oClone:nChave               := ::nChave
	oClone:cSequencial          := ::cSequencial
	oClone:cPlacaCarreta        := ::cPlacaCarreta
	oClone:cPlacaVeiculo        := ::cPlacaVeiculo
	oClone:cNumTransp           := ::cNumTransp
	oClone:cCodTransportadora   := ::cCodTransportadora
	oClone:cCodEmissor          := ::cCodEmissor
	oClone:cRazSocTrans         := ::cRazSocTrans
	oClone:cRazSocEmissor       := ::cRazSocEmissor
	oClone:nFatCorrecao         := ::nFatCorrecao
	oClone:nFatConversao        := ::nFatConversao
	oClone:cUnidadeAposConversao := ::cUnidadeAposConversao
	oClone:nPesoTotDoc          := ::nPesoTotDoc
	oClone:nPesoBrutoDoc        := ::nPesoBrutoDoc
	oClone:nFatCorrecao1        := ::nFatCorrecao1
	oClone:nFatCorrecao2        := ::nFatCorrecao2
	oClone:nFatCorrecao3        := ::nFatCorrecao3
	oClone:nFatCorrecao4        := ::nFatCorrecao4
	oClone:nFatCorrecao5        := ::nFatCorrecao5
	oClone:nFatCorrecao6        := ::nFatCorrecao6
	oClone:cDtHrPreEntrada      := ::cDtHrPreEntrada
	oClone:cOpPreEntrada        := ::cOpPreEntrada
	oClone:cMemoObs             := ::cMemoObs
	oClone:nQtdeTara1           := ::nQtdeTara1
	oClone:nPesoTara1           := ::nPesoTara1
	oClone:cTipoTara1           := ::cTipoTara1
	oClone:nQtdeTara2           := ::nQtdeTara2
	oClone:nPesoTara2           := ::nPesoTara2
	oClone:cTipoTara2           := ::cTipoTara2
	oClone:nQtdeTara3           := ::nQtdeTara3
	oClone:nPesoTara3           := ::nPesoTara3
	oClone:cTipoTara3           := ::cTipoTara3
	oClone:nQtdeTara4           := ::nQtdeTara4
	oClone:nPesoTara4           := ::nPesoTara4
	oClone:cTipoTara4           := ::cTipoTara4
	oClone:nQtdeTara5           := ::nQtdeTara5
	oClone:nPesoTara5           := ::nPesoTara5
	oClone:cTipoTara5           := ::cTipoTara5
	oClone:nQtdeTara6           := ::nQtdeTara6
	oClone:nPesoTara6           := ::nPesoTara6
	oClone:cTipoTara6           := ::cTipoTara6
	oClone:cCampoUsu1           := ::cCampoUsu1
	oClone:cCampoUsu2           := ::cCampoUsu2
	oClone:cCampoUsu3           := ::cCampoUsu3
	oClone:cCampoUsu4           := ::cCampoUsu4
	oClone:cCampoUsu5           := ::cCampoUsu5
	oClone:cCampoUsu6           := ::cCampoUsu6
	oClone:cCampoUsu7           := ::cCampoUsu7
	oClone:cCampoUsu8           := ::cCampoUsu8
	oClone:cCampoUsu9           := ::cCampoUsu9
	oClone:cCampoUsu10          := ::cCampoUsu10
	oClone:nPesoLiqCorrUsu      := ::nPesoLiqCorrUsu
	oClone:nCodRota             := ::nCodRota
	oClone:nPtRetRota           := ::nPtRetRota
	oClone:cVeicTipo            := ::cVeicTipo
	oClone:nPesoTaraDoc         := ::nPesoTaraDoc
	oClone:nNumCompart          := ::nNumCompart
	oClone:cDpyCompart          := ::cDpyCompart
	oClone:cTmpVeicExt          := ::cTmpVeicExt
	oClone:cPtoDesc             := ::cPtoDesc
	oClone:nDosaAlvo            := ::nDosaAlvo
	oClone:nDosaLenta           := ::nDosaLenta
	oClone:nDosaCorte           := ::nDosaCorte
	oClone:nVfyMws              := ::nVfyMws
	oClone:cBackReg             := ::cBackReg
	oClone:cBalToUse            := ::cBalToUse
	oClone:cDescDocTot          := ::cDescDocTot
	oClone:nPesoInicial         := ::nPesoInicial
	oClone:cOpPesoInicial       := ::cOpPesoInicial
	oClone:cDtHrPesoInicial     := ::cDtHrPesoInicial
	oClone:cBalPesoInicial      := ::cBalPesoInicial
	oClone:cFlag                := ::cFlag
Return oClone

WSMETHOD SOAPSEND WSCLIENT WS_GUARDIAN_ImportaTicketG4
	Local cSoap := ""
	cSoap += WSSoapValue("DocumentosDoTicket", ::oWSDocumentosDoTicket, ::oWSDocumentosDoTicket , "ArrayOfImportaDocumentoDoTicketG4", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ItensDoTicket", ::oWSItensDoTicket, ::oWSItensDoTicket , "ArrayOfImportaItemDoTicketG4", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Chave", ::nChave, ::nChave , "int", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Sequencial", ::cSequencial, ::cSequencial , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("PlacaCarreta", ::cPlacaCarreta, ::cPlacaCarreta , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("PlacaVeiculo", ::cPlacaVeiculo, ::cPlacaVeiculo , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("NumTransp", ::cNumTransp, ::cNumTransp , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CodTransportadora", ::cCodTransportadora, ::cCodTransportadora , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CodEmissor", ::cCodEmissor, ::cCodEmissor , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("RazSocTrans", ::cRazSocTrans, ::cRazSocTrans , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("RazSocEmissor", ::cRazSocEmissor, ::cRazSocEmissor , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("FatCorrecao", ::nFatCorrecao, ::nFatCorrecao , "float", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("FatConversao", ::nFatConversao, ::nFatConversao , "float", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("UnidadeAposConversao", ::cUnidadeAposConversao, ::cUnidadeAposConversao , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("PesoTotDoc", ::nPesoTotDoc, ::nPesoTotDoc , "float", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("PesoBrutoDoc", ::nPesoBrutoDoc, ::nPesoBrutoDoc , "float", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("FatCorrecao1", ::nFatCorrecao1, ::nFatCorrecao1 , "float", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("FatCorrecao2", ::nFatCorrecao2, ::nFatCorrecao2 , "float", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("FatCorrecao3", ::nFatCorrecao3, ::nFatCorrecao3 , "float", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("FatCorrecao4", ::nFatCorrecao4, ::nFatCorrecao4 , "float", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("FatCorrecao5", ::nFatCorrecao5, ::nFatCorrecao5 , "float", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("FatCorrecao6", ::nFatCorrecao6, ::nFatCorrecao6 , "float", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("DtHrPreEntrada", ::cDtHrPreEntrada, ::cDtHrPreEntrada , "dateTime", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("OpPreEntrada", ::cOpPreEntrada, ::cOpPreEntrada , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("MemoObs", ::cMemoObs, ::cMemoObs , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("QtdeTara1", ::nQtdeTara1, ::nQtdeTara1 , "int", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("PesoTara1", ::nPesoTara1, ::nPesoTara1 , "float", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("TipoTara1", ::cTipoTara1, ::cTipoTara1 , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("QtdeTara2", ::nQtdeTara2, ::nQtdeTara2 , "int", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("PesoTara2", ::nPesoTara2, ::nPesoTara2 , "float", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("TipoTara2", ::cTipoTara2, ::cTipoTara2 , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("QtdeTara3", ::nQtdeTara3, ::nQtdeTara3 , "int", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("PesoTara3", ::nPesoTara3, ::nPesoTara3 , "float", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("TipoTara3", ::cTipoTara3, ::cTipoTara3 , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("QtdeTara4", ::nQtdeTara4, ::nQtdeTara4 , "int", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("PesoTara4", ::nPesoTara4, ::nPesoTara4 , "float", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("TipoTara4", ::cTipoTara4, ::cTipoTara4 , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("QtdeTara5", ::nQtdeTara5, ::nQtdeTara5 , "int", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("PesoTara5", ::nPesoTara5, ::nPesoTara5 , "float", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("TipoTara5", ::cTipoTara5, ::cTipoTara5 , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("QtdeTara6", ::nQtdeTara6, ::nQtdeTara6 , "int", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("PesoTara6", ::nPesoTara6, ::nPesoTara6 , "float", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("TipoTara6", ::cTipoTara6, ::cTipoTara6 , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CampoUsu1", ::cCampoUsu1, ::cCampoUsu1 , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CampoUsu2", ::cCampoUsu2, ::cCampoUsu2 , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CampoUsu3", ::cCampoUsu3, ::cCampoUsu3 , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CampoUsu4", ::cCampoUsu4, ::cCampoUsu4 , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CampoUsu5", ::cCampoUsu5, ::cCampoUsu5 , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CampoUsu6", ::cCampoUsu6, ::cCampoUsu6 , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CampoUsu7", ::cCampoUsu7, ::cCampoUsu7 , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CampoUsu8", ::cCampoUsu8, ::cCampoUsu8 , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CampoUsu9", ::cCampoUsu9, ::cCampoUsu9 , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CampoUsu10", ::cCampoUsu10, ::cCampoUsu10 , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("PesoLiqCorrUsu", ::nPesoLiqCorrUsu, ::nPesoLiqCorrUsu , "float", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CodRota", ::nCodRota, ::nCodRota , "int", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("PtRetRota", ::nPtRetRota, ::nPtRetRota , "int", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("VeicTipo", ::cVeicTipo, ::cVeicTipo , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("PesoTaraDoc", ::nPesoTaraDoc, ::nPesoTaraDoc , "float", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("NumCompart", ::nNumCompart, ::nNumCompart , "int", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("DpyCompart", ::cDpyCompart, ::cDpyCompart , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("TmpVeicExt", ::cTmpVeicExt, ::cTmpVeicExt , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("PtoDesc", ::cPtoDesc, ::cPtoDesc , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("DosaAlvo", ::nDosaAlvo, ::nDosaAlvo , "int", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("DosaLenta", ::nDosaLenta, ::nDosaLenta , "int", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("DosaCorte", ::nDosaCorte, ::nDosaCorte , "int", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("VfyMws", ::nVfyMws, ::nVfyMws , "int", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("BackReg", ::cBackReg, ::cBackReg , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("BalToUse", ::cBalToUse, ::cBalToUse , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("DescDocTot", ::cDescDocTot, ::cDescDocTot , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("PesoInicial", ::nPesoInicial, ::nPesoInicial , "float", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("OpPesoInicial", ::cOpPesoInicial, ::cOpPesoInicial , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("DtHrPesoInicial", ::cDtHrPesoInicial, ::cDtHrPesoInicial , "dateTime", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("BalPesoInicial", ::cBalPesoInicial, ::cBalPesoInicial , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Flag", ::cFlag, ::cFlag , "string", .F. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

// WSDL Data Structure ExportaTicketG4

WSSTRUCT WS_GUARDIAN_ExportaTicketG4
	WSDATA   nChave                    AS int
	WSDATA   cSequencial               AS string OPTIONAL
	WSDATA   cPlacaCarreta             AS string OPTIONAL
	WSDATA   cPlacaVeiculo             AS string OPTIONAL
	WSDATA   cSttFim                   AS string OPTIONAL
	WSDATA   cStatus                   AS string OPTIONAL
	WSDATA   cStatusIntegracao         AS string OPTIONAL
	WSDATA   cNumTransp                AS string OPTIONAL
	WSDATA   cCodTransportadora        AS string OPTIONAL
	WSDATA   cCodEmissor               AS string OPTIONAL
	WSDATA   cCodItem                  AS string OPTIONAL
	WSDATA   cRecExp                   AS string OPTIONAL
	WSDATA   nSeqRecExp                AS int
	WSDATA   cDescrStt                 AS string OPTIONAL
	WSDATA   cDescRecExp               AS string OPTIONAL
	WSDATA   cRazSocTrans              AS string OPTIONAL
	WSDATA   cRazSocEmissor            AS string OPTIONAL
	WSDATA   cDescricaoItem            AS string OPTIONAL
	WSDATA   nPesoInicial              AS float
	WSDATA   cOpPesoInicial            AS string OPTIONAL
	WSDATA   cDtHrPesoInicial          AS dateTime
	WSDATA   cBalPesoInicial           AS string OPTIONAL
	WSDATA   nPesoFinal                AS float
	WSDATA   cOpPesoFinal              AS string OPTIONAL
	WSDATA   cDtHrPesoFinal            AS dateTime
	WSDATA   cBalPesoFinal             AS string OPTIONAL
	WSDATA   nPesoLiquido              AS float
	WSDATA   nFatCorrecao              AS float
	WSDATA   nFatConversao             AS float
	WSDATA   nLiquidoCorrigido         AS float
	WSDATA   cUnidadeAposConversao     AS string OPTIONAL
	WSDATA   nPesoTotDoc               AS float
	WSDATA   nPesoBrutoDoc             AS float
	WSDATA   nDifOrigemRealPc          AS float
	WSDATA   nDifOrigemRealKg          AS float
	WSDATA   nDifBrutoPc               AS float
	WSDATA   nDifBrutoKg               AS float
	WSDATA   nPesoLiquido1             AS float
	WSDATA   nPesoLiquido2             AS float
	WSDATA   nPesoLiquido3             AS float
	WSDATA   nPesoLiquido4             AS float
	WSDATA   nPesoLiquido5             AS float
	WSDATA   nFatCorrecao1             AS float
	WSDATA   nFatCorrecao2             AS float
	WSDATA   nFatCorrecao3             AS float
	WSDATA   nFatCorrecao4             AS float
	WSDATA   nFatCorrecao5             AS float
	WSDATA   nFatCorrecao6             AS float
	WSDATA   cDtHrPreEntrada           AS dateTime
	WSDATA   cOpPreEntrada             AS string OPTIONAL
	WSDATA   cMemoObs                  AS string OPTIONAL
	WSDATA   nPesoCavInic              AS float
	WSDATA   cPlacaCavInic             AS string OPTIONAL
	WSDATA   nPesoCavFinal             AS float
	WSDATA   cPlacaCavFinal            AS string OPTIONAL
	WSDATA   nQtdeTara1                AS int
	WSDATA   nPesoTara1                AS float
	WSDATA   cTipoTara1                AS string OPTIONAL
	WSDATA   nTotTara1                 AS float
	WSDATA   nQtdeTara2                AS int
	WSDATA   nPesoTara2                AS float
	WSDATA   cTipoTara2                AS string OPTIONAL
	WSDATA   nTotTara2                 AS float
	WSDATA   nQtdeTara3                AS int
	WSDATA   nPesoTara3                AS float
	WSDATA   cTipoTara3                AS string OPTIONAL
	WSDATA   nTotTara3                 AS float
	WSDATA   nQtdeTara4                AS int
	WSDATA   nPesoTara4                AS float
	WSDATA   cTipoTara4                AS string OPTIONAL
	WSDATA   nTotTara4                 AS float
	WSDATA   nQtdeTara5                AS int
	WSDATA   nPesoTara5                AS float
	WSDATA   cTipoTara5                AS string OPTIONAL
	WSDATA   nTotTara5                 AS float
	WSDATA   nQtdeTara6                AS int
	WSDATA   nPesoTara6                AS float
	WSDATA   cTipoTara6                AS string OPTIONAL
	WSDATA   nTotTara6                 AS float
	WSDATA   nTotTaras                 AS float
	WSDATA   cDtHrPosPesa              AS dateTime
	WSDATA   cTmpVeicEmpr              AS string OPTIONAL
	WSDATA   cCampoUsu1                AS string OPTIONAL
	WSDATA   cCampoUsu2                AS string OPTIONAL
	WSDATA   cCampoUsu3                AS string OPTIONAL
	WSDATA   cCampoUsu4                AS string OPTIONAL
	WSDATA   cCampoUsu5                AS string OPTIONAL
	WSDATA   cCampoUsu6                AS string OPTIONAL
	WSDATA   cCampoUsu7                AS string OPTIONAL
	WSDATA   cCampoUsu8                AS string OPTIONAL
	WSDATA   cCampoUsu9                AS string OPTIONAL
	WSDATA   cCampoUsu10               AS string OPTIONAL
	WSDATA   nPesoLiqCorrUsu           AS float
	WSDATA   cVfyIni                   AS string OPTIONAL
	WSDATA   cVfyFim                   AS string OPTIONAL
	WSDATA   nCodRota                  AS int
	WSDATA   cPrintUltUsu              AS string OPTIONAL
	WSDATA   nPrintCnt                 AS int
	WSDATA   cPrintObsReimp            AS string OPTIONAL
	WSDATA   cPrintDataHora            AS dateTime
	WSDATA   nPtRetRota                AS int
	WSDATA   cSeqLoteItem              AS string OPTIONAL
	WSDATA   cVeicTipo                 AS string OPTIONAL
	WSDATA   nPesoTaraDoc              AS float
	WSDATA   nNumCompart               AS int
	WSDATA   cDpyCompart               AS string OPTIONAL
	WSDATA   cTmpVeicExt               AS string OPTIONAL
	WSDATA   cPtoDesc                  AS string OPTIONAL
	WSDATA   nDosaAlvo                 AS float
	WSDATA   nDosaLenta                AS float
	WSDATA   nDosaCorte                AS float
	WSDATA   nVfyMws                   AS int
	WSDATA   cBackReg                  AS string OPTIONAL
	WSDATA   cDescDocTot               AS string OPTIONAL
	WSDATA   cCaminhoTicketPDF         AS string OPTIONAL
	WSDATA   oWSDocumentosDoTicket     AS WS_GUARDIAN_ArrayOfExportaDocumentoDoTicketG4 OPTIONAL
	WSDATA   oWSItensDoTicket          AS WS_GUARDIAN_ArrayOfExportaItemDoTicketG4 OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WS_GUARDIAN_ExportaTicketG4
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WS_GUARDIAN_ExportaTicketG4
Return

WSMETHOD CLONE WSCLIENT WS_GUARDIAN_ExportaTicketG4
	Local oClone := WS_GUARDIAN_ExportaTicketG4():NEW()
	oClone:nChave               := ::nChave
	oClone:cSequencial          := ::cSequencial
	oClone:cPlacaCarreta        := ::cPlacaCarreta
	oClone:cPlacaVeiculo        := ::cPlacaVeiculo
	oClone:cSttFim              := ::cSttFim
	oClone:cStatus              := ::cStatus
	oClone:cStatusIntegracao    := ::cStatusIntegracao
	oClone:cNumTransp           := ::cNumTransp
	oClone:cCodTransportadora   := ::cCodTransportadora
	oClone:cCodEmissor          := ::cCodEmissor
	oClone:cCodItem             := ::cCodItem
	oClone:cRecExp              := ::cRecExp
	oClone:nSeqRecExp           := ::nSeqRecExp
	oClone:cDescrStt            := ::cDescrStt
	oClone:cDescRecExp          := ::cDescRecExp
	oClone:cRazSocTrans         := ::cRazSocTrans
	oClone:cRazSocEmissor       := ::cRazSocEmissor
	oClone:cDescricaoItem       := ::cDescricaoItem
	oClone:nPesoInicial         := ::nPesoInicial
	oClone:cOpPesoInicial       := ::cOpPesoInicial
	oClone:cDtHrPesoInicial     := ::cDtHrPesoInicial
	oClone:cBalPesoInicial      := ::cBalPesoInicial
	oClone:nPesoFinal           := ::nPesoFinal
	oClone:cOpPesoFinal         := ::cOpPesoFinal
	oClone:cDtHrPesoFinal       := ::cDtHrPesoFinal
	oClone:cBalPesoFinal        := ::cBalPesoFinal
	oClone:nPesoLiquido         := ::nPesoLiquido
	oClone:nFatCorrecao         := ::nFatCorrecao
	oClone:nFatConversao        := ::nFatConversao
	oClone:nLiquidoCorrigido    := ::nLiquidoCorrigido
	oClone:cUnidadeAposConversao := ::cUnidadeAposConversao
	oClone:nPesoTotDoc          := ::nPesoTotDoc
	oClone:nPesoBrutoDoc        := ::nPesoBrutoDoc
	oClone:nDifOrigemRealPc     := ::nDifOrigemRealPc
	oClone:nDifOrigemRealKg     := ::nDifOrigemRealKg
	oClone:nDifBrutoPc          := ::nDifBrutoPc
	oClone:nDifBrutoKg          := ::nDifBrutoKg
	oClone:nPesoLiquido1        := ::nPesoLiquido1
	oClone:nPesoLiquido2        := ::nPesoLiquido2
	oClone:nPesoLiquido3        := ::nPesoLiquido3
	oClone:nPesoLiquido4        := ::nPesoLiquido4
	oClone:nPesoLiquido5        := ::nPesoLiquido5
	oClone:nFatCorrecao1        := ::nFatCorrecao1
	oClone:nFatCorrecao2        := ::nFatCorrecao2
	oClone:nFatCorrecao3        := ::nFatCorrecao3
	oClone:nFatCorrecao4        := ::nFatCorrecao4
	oClone:nFatCorrecao5        := ::nFatCorrecao5
	oClone:nFatCorrecao6        := ::nFatCorrecao6
	oClone:cDtHrPreEntrada      := ::cDtHrPreEntrada
	oClone:cOpPreEntrada        := ::cOpPreEntrada
	oClone:cMemoObs             := ::cMemoObs
	oClone:nPesoCavInic         := ::nPesoCavInic
	oClone:cPlacaCavInic        := ::cPlacaCavInic
	oClone:nPesoCavFinal        := ::nPesoCavFinal
	oClone:cPlacaCavFinal       := ::cPlacaCavFinal
	oClone:nQtdeTara1           := ::nQtdeTara1
	oClone:nPesoTara1           := ::nPesoTara1
	oClone:cTipoTara1           := ::cTipoTara1
	oClone:nTotTara1            := ::nTotTara1
	oClone:nQtdeTara2           := ::nQtdeTara2
	oClone:nPesoTara2           := ::nPesoTara2
	oClone:cTipoTara2           := ::cTipoTara2
	oClone:nTotTara2            := ::nTotTara2
	oClone:nQtdeTara3           := ::nQtdeTara3
	oClone:nPesoTara3           := ::nPesoTara3
	oClone:cTipoTara3           := ::cTipoTara3
	oClone:nTotTara3            := ::nTotTara3
	oClone:nQtdeTara4           := ::nQtdeTara4
	oClone:nPesoTara4           := ::nPesoTara4
	oClone:cTipoTara4           := ::cTipoTara4
	oClone:nTotTara4            := ::nTotTara4
	oClone:nQtdeTara5           := ::nQtdeTara5
	oClone:nPesoTara5           := ::nPesoTara5
	oClone:cTipoTara5           := ::cTipoTara5
	oClone:nTotTara5            := ::nTotTara5
	oClone:nQtdeTara6           := ::nQtdeTara6
	oClone:nPesoTara6           := ::nPesoTara6
	oClone:cTipoTara6           := ::cTipoTara6
	oClone:nTotTara6            := ::nTotTara6
	oClone:nTotTaras            := ::nTotTaras
	oClone:cDtHrPosPesa         := ::cDtHrPosPesa
	oClone:cTmpVeicEmpr         := ::cTmpVeicEmpr
	oClone:cCampoUsu1           := ::cCampoUsu1
	oClone:cCampoUsu2           := ::cCampoUsu2
	oClone:cCampoUsu3           := ::cCampoUsu3
	oClone:cCampoUsu4           := ::cCampoUsu4
	oClone:cCampoUsu5           := ::cCampoUsu5
	oClone:cCampoUsu6           := ::cCampoUsu6
	oClone:cCampoUsu7           := ::cCampoUsu7
	oClone:cCampoUsu8           := ::cCampoUsu8
	oClone:cCampoUsu9           := ::cCampoUsu9
	oClone:cCampoUsu10          := ::cCampoUsu10
	oClone:nPesoLiqCorrUsu      := ::nPesoLiqCorrUsu
	oClone:cVfyIni              := ::cVfyIni
	oClone:cVfyFim              := ::cVfyFim
	oClone:nCodRota             := ::nCodRota
	oClone:cPrintUltUsu         := ::cPrintUltUsu
	oClone:nPrintCnt            := ::nPrintCnt
	oClone:cPrintObsReimp       := ::cPrintObsReimp
	oClone:cPrintDataHora       := ::cPrintDataHora
	oClone:nPtRetRota           := ::nPtRetRota
	oClone:cSeqLoteItem         := ::cSeqLoteItem
	oClone:cVeicTipo            := ::cVeicTipo
	oClone:nPesoTaraDoc         := ::nPesoTaraDoc
	oClone:nNumCompart          := ::nNumCompart
	oClone:cDpyCompart          := ::cDpyCompart
	oClone:cTmpVeicExt          := ::cTmpVeicExt
	oClone:cPtoDesc             := ::cPtoDesc
	oClone:nDosaAlvo            := ::nDosaAlvo
	oClone:nDosaLenta           := ::nDosaLenta
	oClone:nDosaCorte           := ::nDosaCorte
	oClone:nVfyMws              := ::nVfyMws
	oClone:cBackReg             := ::cBackReg
	oClone:cDescDocTot          := ::cDescDocTot
	oClone:cCaminhoTicketPDF    := ::cCaminhoTicketPDF
	oClone:oWSDocumentosDoTicket := IIF(::oWSDocumentosDoTicket = NIL , NIL , ::oWSDocumentosDoTicket:Clone() )
	oClone:oWSItensDoTicket     := IIF(::oWSItensDoTicket = NIL , NIL , ::oWSItensDoTicket:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WS_GUARDIAN_ExportaTicketG4
	Local oNode116
	Local oNode117
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::nChave             :=  WSAdvValue( oResponse,"_CHAVE","int",NIL,"Property nChave as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cSequencial        :=  WSAdvValue( oResponse,"_SEQUENCIAL","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cPlacaCarreta      :=  WSAdvValue( oResponse,"_PLACACARRETA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cPlacaVeiculo      :=  WSAdvValue( oResponse,"_PLACAVEICULO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cSttFim            :=  WSAdvValue( oResponse,"_STTFIM","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cStatus            :=  WSAdvValue( oResponse,"_STATUS","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cStatusIntegracao  :=  WSAdvValue( oResponse,"_STATUSINTEGRACAO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cNumTransp         :=  WSAdvValue( oResponse,"_NUMTRANSP","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cCodTransportadora :=  WSAdvValue( oResponse,"_CODTRANSPORTADORA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cCodEmissor        :=  WSAdvValue( oResponse,"_CODEMISSOR","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cCodItem           :=  WSAdvValue( oResponse,"_CODITEM","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cRecExp            :=  WSAdvValue( oResponse,"_RECEXP","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nSeqRecExp         :=  WSAdvValue( oResponse,"_SEQRECEXP","int",NIL,"Property nSeqRecExp as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cDescrStt          :=  WSAdvValue( oResponse,"_DESCRSTT","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cDescRecExp        :=  WSAdvValue( oResponse,"_DESCRECEXP","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cRazSocTrans       :=  WSAdvValue( oResponse,"_RAZSOCTRANS","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cRazSocEmissor     :=  WSAdvValue( oResponse,"_RAZSOCEMISSOR","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cDescricaoItem     :=  WSAdvValue( oResponse,"_DESCRICAOITEM","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nPesoInicial       :=  WSAdvValue( oResponse,"_PESOINICIAL","float",NIL,"Property nPesoInicial as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cOpPesoInicial     :=  WSAdvValue( oResponse,"_OPPESOINICIAL","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cDtHrPesoInicial   :=  WSAdvValue( oResponse,"_DTHRPESOINICIAL","dateTime",NIL,"Property cDtHrPesoInicial as s:dateTime on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cBalPesoInicial    :=  WSAdvValue( oResponse,"_BALPESOINICIAL","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nPesoFinal         :=  WSAdvValue( oResponse,"_PESOFINAL","float",NIL,"Property nPesoFinal as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cOpPesoFinal       :=  WSAdvValue( oResponse,"_OPPESOFINAL","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cDtHrPesoFinal     :=  WSAdvValue( oResponse,"_DTHRPESOFINAL","dateTime",NIL,"Property cDtHrPesoFinal as s:dateTime on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cBalPesoFinal      :=  WSAdvValue( oResponse,"_BALPESOFINAL","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nPesoLiquido       :=  WSAdvValue( oResponse,"_PESOLIQUIDO","float",NIL,"Property nPesoLiquido as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nFatCorrecao       :=  WSAdvValue( oResponse,"_FATCORRECAO","float",NIL,"Property nFatCorrecao as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nFatConversao      :=  WSAdvValue( oResponse,"_FATCONVERSAO","float",NIL,"Property nFatConversao as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nLiquidoCorrigido  :=  WSAdvValue( oResponse,"_LIQUIDOCORRIGIDO","float",NIL,"Property nLiquidoCorrigido as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cUnidadeAposConversao :=  WSAdvValue( oResponse,"_UNIDADEAPOSCONVERSAO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nPesoTotDoc        :=  WSAdvValue( oResponse,"_PESOTOTDOC","float",NIL,"Property nPesoTotDoc as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nPesoBrutoDoc      :=  WSAdvValue( oResponse,"_PESOBRUTODOC","float",NIL,"Property nPesoBrutoDoc as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nDifOrigemRealPc   :=  WSAdvValue( oResponse,"_DIFORIGEMREALPC","float",NIL,"Property nDifOrigemRealPc as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nDifOrigemRealKg   :=  WSAdvValue( oResponse,"_DIFORIGEMREALKG","float",NIL,"Property nDifOrigemRealKg as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nDifBrutoPc        :=  WSAdvValue( oResponse,"_DIFBRUTOPC","float",NIL,"Property nDifBrutoPc as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nDifBrutoKg        :=  WSAdvValue( oResponse,"_DIFBRUTOKG","float",NIL,"Property nDifBrutoKg as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nPesoLiquido1      :=  WSAdvValue( oResponse,"_PESOLIQUIDO1","float",NIL,"Property nPesoLiquido1 as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nPesoLiquido2      :=  WSAdvValue( oResponse,"_PESOLIQUIDO2","float",NIL,"Property nPesoLiquido2 as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nPesoLiquido3      :=  WSAdvValue( oResponse,"_PESOLIQUIDO3","float",NIL,"Property nPesoLiquido3 as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nPesoLiquido4      :=  WSAdvValue( oResponse,"_PESOLIQUIDO4","float",NIL,"Property nPesoLiquido4 as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nPesoLiquido5      :=  WSAdvValue( oResponse,"_PESOLIQUIDO5","float",NIL,"Property nPesoLiquido5 as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nFatCorrecao1      :=  WSAdvValue( oResponse,"_FATCORRECAO1","float",NIL,"Property nFatCorrecao1 as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nFatCorrecao2      :=  WSAdvValue( oResponse,"_FATCORRECAO2","float",NIL,"Property nFatCorrecao2 as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nFatCorrecao3      :=  WSAdvValue( oResponse,"_FATCORRECAO3","float",NIL,"Property nFatCorrecao3 as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nFatCorrecao4      :=  WSAdvValue( oResponse,"_FATCORRECAO4","float",NIL,"Property nFatCorrecao4 as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nFatCorrecao5      :=  WSAdvValue( oResponse,"_FATCORRECAO5","float",NIL,"Property nFatCorrecao5 as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nFatCorrecao6      :=  WSAdvValue( oResponse,"_FATCORRECAO6","float",NIL,"Property nFatCorrecao6 as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cDtHrPreEntrada    :=  WSAdvValue( oResponse,"_DTHRPREENTRADA","dateTime",NIL,"Property cDtHrPreEntrada as s:dateTime on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cOpPreEntrada      :=  WSAdvValue( oResponse,"_OPPREENTRADA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cMemoObs           :=  WSAdvValue( oResponse,"_MEMOOBS","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nPesoCavInic       :=  WSAdvValue( oResponse,"_PESOCAVINIC","float",NIL,"Property nPesoCavInic as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cPlacaCavInic      :=  WSAdvValue( oResponse,"_PLACACAVINIC","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nPesoCavFinal      :=  WSAdvValue( oResponse,"_PESOCAVFINAL","float",NIL,"Property nPesoCavFinal as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cPlacaCavFinal     :=  WSAdvValue( oResponse,"_PLACACAVFINAL","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nQtdeTara1         :=  WSAdvValue( oResponse,"_QTDETARA1","int",NIL,"Property nQtdeTara1 as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nPesoTara1         :=  WSAdvValue( oResponse,"_PESOTARA1","float",NIL,"Property nPesoTara1 as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cTipoTara1         :=  WSAdvValue( oResponse,"_TIPOTARA1","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nTotTara1          :=  WSAdvValue( oResponse,"_TOTTARA1","float",NIL,"Property nTotTara1 as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nQtdeTara2         :=  WSAdvValue( oResponse,"_QTDETARA2","int",NIL,"Property nQtdeTara2 as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nPesoTara2         :=  WSAdvValue( oResponse,"_PESOTARA2","float",NIL,"Property nPesoTara2 as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cTipoTara2         :=  WSAdvValue( oResponse,"_TIPOTARA2","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nTotTara2          :=  WSAdvValue( oResponse,"_TOTTARA2","float",NIL,"Property nTotTara2 as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nQtdeTara3         :=  WSAdvValue( oResponse,"_QTDETARA3","int",NIL,"Property nQtdeTara3 as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nPesoTara3         :=  WSAdvValue( oResponse,"_PESOTARA3","float",NIL,"Property nPesoTara3 as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cTipoTara3         :=  WSAdvValue( oResponse,"_TIPOTARA3","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nTotTara3          :=  WSAdvValue( oResponse,"_TOTTARA3","float",NIL,"Property nTotTara3 as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nQtdeTara4         :=  WSAdvValue( oResponse,"_QTDETARA4","int",NIL,"Property nQtdeTara4 as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nPesoTara4         :=  WSAdvValue( oResponse,"_PESOTARA4","float",NIL,"Property nPesoTara4 as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cTipoTara4         :=  WSAdvValue( oResponse,"_TIPOTARA4","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nTotTara4          :=  WSAdvValue( oResponse,"_TOTTARA4","float",NIL,"Property nTotTara4 as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nQtdeTara5         :=  WSAdvValue( oResponse,"_QTDETARA5","int",NIL,"Property nQtdeTara5 as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nPesoTara5         :=  WSAdvValue( oResponse,"_PESOTARA5","float",NIL,"Property nPesoTara5 as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cTipoTara5         :=  WSAdvValue( oResponse,"_TIPOTARA5","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nTotTara5          :=  WSAdvValue( oResponse,"_TOTTARA5","float",NIL,"Property nTotTara5 as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nQtdeTara6         :=  WSAdvValue( oResponse,"_QTDETARA6","int",NIL,"Property nQtdeTara6 as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nPesoTara6         :=  WSAdvValue( oResponse,"_PESOTARA6","float",NIL,"Property nPesoTara6 as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cTipoTara6         :=  WSAdvValue( oResponse,"_TIPOTARA6","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nTotTara6          :=  WSAdvValue( oResponse,"_TOTTARA6","float",NIL,"Property nTotTara6 as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nTotTaras          :=  WSAdvValue( oResponse,"_TOTTARAS","float",NIL,"Property nTotTaras as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cDtHrPosPesa       :=  WSAdvValue( oResponse,"_DTHRPOSPESA","dateTime",NIL,"Property cDtHrPosPesa as s:dateTime on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cTmpVeicEmpr       :=  WSAdvValue( oResponse,"_TMPVEICEMPR","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cCampoUsu1         :=  WSAdvValue( oResponse,"_CAMPOUSU1","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cCampoUsu2         :=  WSAdvValue( oResponse,"_CAMPOUSU2","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cCampoUsu3         :=  WSAdvValue( oResponse,"_CAMPOUSU3","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cCampoUsu4         :=  WSAdvValue( oResponse,"_CAMPOUSU4","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cCampoUsu5         :=  WSAdvValue( oResponse,"_CAMPOUSU5","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cCampoUsu6         :=  WSAdvValue( oResponse,"_CAMPOUSU6","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cCampoUsu7         :=  WSAdvValue( oResponse,"_CAMPOUSU7","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cCampoUsu8         :=  WSAdvValue( oResponse,"_CAMPOUSU8","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cCampoUsu9         :=  WSAdvValue( oResponse,"_CAMPOUSU9","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cCampoUsu10        :=  WSAdvValue( oResponse,"_CAMPOUSU10","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nPesoLiqCorrUsu    :=  WSAdvValue( oResponse,"_PESOLIQCORRUSU","float",NIL,"Property nPesoLiqCorrUsu as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cVfyIni            :=  WSAdvValue( oResponse,"_VFYINI","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cVfyFim            :=  WSAdvValue( oResponse,"_VFYFIM","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nCodRota           :=  WSAdvValue( oResponse,"_CODROTA","int",NIL,"Property nCodRota as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cPrintUltUsu       :=  WSAdvValue( oResponse,"_PRINTULTUSU","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nPrintCnt          :=  WSAdvValue( oResponse,"_PRINTCNT","int",NIL,"Property nPrintCnt as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cPrintObsReimp     :=  WSAdvValue( oResponse,"_PRINTOBSREIMP","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cPrintDataHora     :=  WSAdvValue( oResponse,"_PRINTDATAHORA","dateTime",NIL,"Property cPrintDataHora as s:dateTime on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::nPtRetRota         :=  WSAdvValue( oResponse,"_PTRETROTA","int",NIL,"Property nPtRetRota as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cSeqLoteItem       :=  WSAdvValue( oResponse,"_SEQLOTEITEM","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cVeicTipo          :=  WSAdvValue( oResponse,"_VEICTIPO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nPesoTaraDoc       :=  WSAdvValue( oResponse,"_PESOTARADOC","float",NIL,"Property nPesoTaraDoc as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nNumCompart        :=  WSAdvValue( oResponse,"_NUMCOMPART","int",NIL,"Property nNumCompart as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cDpyCompart        :=  WSAdvValue( oResponse,"_DPYCOMPART","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cTmpVeicExt        :=  WSAdvValue( oResponse,"_TMPVEICEXT","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cPtoDesc           :=  WSAdvValue( oResponse,"_PTODESC","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nDosaAlvo          :=  WSAdvValue( oResponse,"_DOSAALVO","float",NIL,"Property nDosaAlvo as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nDosaLenta         :=  WSAdvValue( oResponse,"_DOSALENTA","float",NIL,"Property nDosaLenta as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nDosaCorte         :=  WSAdvValue( oResponse,"_DOSACORTE","float",NIL,"Property nDosaCorte as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nVfyMws            :=  WSAdvValue( oResponse,"_VFYMWS","int",NIL,"Property nVfyMws as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cBackReg           :=  WSAdvValue( oResponse,"_BACKREG","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cDescDocTot        :=  WSAdvValue( oResponse,"_DESCDOCTOT","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cCaminhoTicketPDF  :=  WSAdvValue( oResponse,"_CAMINHOTICKETPDF","string",NIL,NIL,NIL,"S",NIL,NIL) 
	oNode116 :=  WSAdvValue( oResponse,"_DOCUMENTOSDOTICKET","ArrayOfExportaDocumentoDoTicketG4",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode116 != NIL
		::oWSDocumentosDoTicket := WS_GUARDIAN_ArrayOfExportaDocumentoDoTicketG4():New()
		::oWSDocumentosDoTicket:SoapRecv(oNode116)
	EndIf
	oNode117 :=  WSAdvValue( oResponse,"_ITENSDOTICKET","ArrayOfExportaItemDoTicketG4",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode117 != NIL
		::oWSItensDoTicket := WS_GUARDIAN_ArrayOfExportaItemDoTicketG4():New()
		::oWSItensDoTicket:SoapRecv(oNode117)
	EndIf
Return

// WSDL Data Structure ArrayOfLogAplicacao

WSSTRUCT WS_GUARDIAN_ArrayOfLogAplicacao
	WSDATA   oWSLogAplicacao           AS WS_GUARDIAN_LogAplicacao OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WS_GUARDIAN_ArrayOfLogAplicacao
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WS_GUARDIAN_ArrayOfLogAplicacao
	::oWSLogAplicacao      := {} // Array Of  WS_GUARDIAN_LOGAPLICACAO():New()
Return

WSMETHOD CLONE WSCLIENT WS_GUARDIAN_ArrayOfLogAplicacao
	Local oClone := WS_GUARDIAN_ArrayOfLogAplicacao():NEW()
	oClone:oWSLogAplicacao := NIL
	If ::oWSLogAplicacao <> NIL 
		oClone:oWSLogAplicacao := {}
		aEval( ::oWSLogAplicacao , { |x| aadd( oClone:oWSLogAplicacao , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WS_GUARDIAN_ArrayOfLogAplicacao
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_LOGAPLICACAO","LogAplicacao",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSLogAplicacao , WS_GUARDIAN_LogAplicacao():New() )
			::oWSLogAplicacao[len(::oWSLogAplicacao)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ArrayOfLogPeriferico

WSSTRUCT WS_GUARDIAN_ArrayOfLogPeriferico
	WSDATA   oWSLogPeriferico          AS WS_GUARDIAN_LogPeriferico OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WS_GUARDIAN_ArrayOfLogPeriferico
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WS_GUARDIAN_ArrayOfLogPeriferico
	::oWSLogPeriferico     := {} // Array Of  WS_GUARDIAN_LOGPERIFERICO():New()
Return

WSMETHOD CLONE WSCLIENT WS_GUARDIAN_ArrayOfLogPeriferico
	Local oClone := WS_GUARDIAN_ArrayOfLogPeriferico():NEW()
	oClone:oWSLogPeriferico := NIL
	If ::oWSLogPeriferico <> NIL 
		oClone:oWSLogPeriferico := {}
		aEval( ::oWSLogPeriferico , { |x| aadd( oClone:oWSLogPeriferico , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WS_GUARDIAN_ArrayOfLogPeriferico
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_LOGPERIFERICO","LogPeriferico",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSLogPeriferico , WS_GUARDIAN_LogPeriferico():New() )
			::oWSLogPeriferico[len(::oWSLogPeriferico)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ConsultaLogAuditoriaIN

WSSTRUCT WS_GUARDIAN_ConsultaLogAuditoriaIN
	WSDATA   cDataInicio               AS dateTime
	WSDATA   cDataFinal                AS dateTime
	WSDATA   cCodigoEstacaoControle    AS string OPTIONAL
	WSDATA   cLoginUsuarioLogado       AS string OPTIONAL
	WSDATA   cLoginUsuarioAssinado     AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WS_GUARDIAN_ConsultaLogAuditoriaIN
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WS_GUARDIAN_ConsultaLogAuditoriaIN
Return

WSMETHOD CLONE WSCLIENT WS_GUARDIAN_ConsultaLogAuditoriaIN
	Local oClone := WS_GUARDIAN_ConsultaLogAuditoriaIN():NEW()
	oClone:cDataInicio          := ::cDataInicio
	oClone:cDataFinal           := ::cDataFinal
	oClone:cCodigoEstacaoControle := ::cCodigoEstacaoControle
	oClone:cLoginUsuarioLogado  := ::cLoginUsuarioLogado
	oClone:cLoginUsuarioAssinado := ::cLoginUsuarioAssinado
Return oClone

WSMETHOD SOAPSEND WSCLIENT WS_GUARDIAN_ConsultaLogAuditoriaIN
	Local cSoap := ""
	cSoap += WSSoapValue("DataInicio", ::cDataInicio, ::cDataInicio , "dateTime", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("DataFinal", ::cDataFinal, ::cDataFinal , "dateTime", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CodigoEstacaoControle", ::cCodigoEstacaoControle, ::cCodigoEstacaoControle , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("LoginUsuarioLogado", ::cLoginUsuarioLogado, ::cLoginUsuarioLogado , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("LoginUsuarioAssinado", ::cLoginUsuarioAssinado, ::cLoginUsuarioAssinado , "string", .F. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

// WSDL Data Structure ArrayOfConsultaLogAuditoriaOUT

WSSTRUCT WS_GUARDIAN_ArrayOfConsultaLogAuditoriaOUT
	WSDATA   oWSConsultaLogAuditoriaOUT AS WS_GUARDIAN_ConsultaLogAuditoriaOUT OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WS_GUARDIAN_ArrayOfConsultaLogAuditoriaOUT
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WS_GUARDIAN_ArrayOfConsultaLogAuditoriaOUT
	::oWSConsultaLogAuditoriaOUT := {} // Array Of  WS_GUARDIAN_CONSULTALOGAUDITORIAOUT():New()
Return

WSMETHOD CLONE WSCLIENT WS_GUARDIAN_ArrayOfConsultaLogAuditoriaOUT
	Local oClone := WS_GUARDIAN_ArrayOfConsultaLogAuditoriaOUT():NEW()
	oClone:oWSConsultaLogAuditoriaOUT := NIL
	If ::oWSConsultaLogAuditoriaOUT <> NIL 
		oClone:oWSConsultaLogAuditoriaOUT := {}
		aEval( ::oWSConsultaLogAuditoriaOUT , { |x| aadd( oClone:oWSConsultaLogAuditoriaOUT , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WS_GUARDIAN_ArrayOfConsultaLogAuditoriaOUT
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_CONSULTALOGAUDITORIAOUT","ConsultaLogAuditoriaOUT",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSConsultaLogAuditoriaOUT , WS_GUARDIAN_ConsultaLogAuditoriaOUT():New() )
			::oWSConsultaLogAuditoriaOUT[len(::oWSConsultaLogAuditoriaOUT)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ArrayOfHistoricoPassagem

WSSTRUCT WS_GUARDIAN_ArrayOfHistoricoPassagem
	WSDATA   oWSHistoricoPassagem      AS WS_GUARDIAN_HistoricoPassagem OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WS_GUARDIAN_ArrayOfHistoricoPassagem
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WS_GUARDIAN_ArrayOfHistoricoPassagem
	::oWSHistoricoPassagem := {} // Array Of  WS_GUARDIAN_HISTORICOPASSAGEM():New()
Return

WSMETHOD CLONE WSCLIENT WS_GUARDIAN_ArrayOfHistoricoPassagem
	Local oClone := WS_GUARDIAN_ArrayOfHistoricoPassagem():NEW()
	oClone:oWSHistoricoPassagem := NIL
	If ::oWSHistoricoPassagem <> NIL 
		oClone:oWSHistoricoPassagem := {}
		aEval( ::oWSHistoricoPassagem , { |x| aadd( oClone:oWSHistoricoPassagem , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WS_GUARDIAN_ArrayOfHistoricoPassagem
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_HISTORICOPASSAGEM","HistoricoPassagem",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSHistoricoPassagem , WS_GUARDIAN_HistoricoPassagem():New() )
			::oWSHistoricoPassagem[len(::oWSHistoricoPassagem)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure InformaCarregamento

WSSTRUCT WS_GUARDIAN_InformaCarregamento
	WSDATA   cBalanca                  AS string OPTIONAL
	WSDATA   cCodigoVagao              AS string OPTIONAL
	WSDATA   nPesoBrutoMaximo          AS double
	WSDATA   nPesoCarregamento         AS double
	WSDATA   nDribble                  AS double
	WSDATA   nPreact                   AS double
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WS_GUARDIAN_InformaCarregamento
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WS_GUARDIAN_InformaCarregamento
Return

WSMETHOD CLONE WSCLIENT WS_GUARDIAN_InformaCarregamento
	Local oClone := WS_GUARDIAN_InformaCarregamento():NEW()
	oClone:cBalanca             := ::cBalanca
	oClone:cCodigoVagao         := ::cCodigoVagao
	oClone:nPesoBrutoMaximo     := ::nPesoBrutoMaximo
	oClone:nPesoCarregamento    := ::nPesoCarregamento
	oClone:nDribble             := ::nDribble
	oClone:nPreact              := ::nPreact
Return oClone

WSMETHOD SOAPSEND WSCLIENT WS_GUARDIAN_InformaCarregamento
	Local cSoap := ""
	cSoap += WSSoapValue("Balanca", ::cBalanca, ::cBalanca , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CodigoVagao", ::cCodigoVagao, ::cCodigoVagao , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("PesoBrutoMaximo", ::nPesoBrutoMaximo, ::nPesoBrutoMaximo , "double", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("PesoCarregamento", ::nPesoCarregamento, ::nPesoCarregamento , "double", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Dribble", ::nDribble, ::nDribble , "double", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Preact", ::nPreact, ::nPreact , "double", .T. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

// WSDL Data Structure RetornoFotoAvulsa

WSSTRUCT WS_GUARDIAN_RetornoFotoAvulsa
	WSDATA   oWSStatus                 AS WS_GUARDIAN_StatusRetorno
	WSDATA   cMotivoErro               AS string OPTIONAL
	WSDATA   cCaminhoFoto              AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WS_GUARDIAN_RetornoFotoAvulsa
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WS_GUARDIAN_RetornoFotoAvulsa
Return

WSMETHOD CLONE WSCLIENT WS_GUARDIAN_RetornoFotoAvulsa
	Local oClone := WS_GUARDIAN_RetornoFotoAvulsa():NEW()
	oClone:oWSStatus            := IIF(::oWSStatus = NIL , NIL , ::oWSStatus:Clone() )
	oClone:cMotivoErro          := ::cMotivoErro
	oClone:cCaminhoFoto         := ::cCaminhoFoto
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WS_GUARDIAN_RetornoFotoAvulsa
	Local oNode1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNode1 :=  WSAdvValue( oResponse,"_STATUS","StatusRetorno",NIL,"Property oWSStatus as tns:StatusRetorno on SOAP Response not found.",NIL,"O",NIL,NIL) 
	If oNode1 != NIL
		::oWSStatus := WS_GUARDIAN_StatusRetorno():New()
		::oWSStatus:SoapRecv(oNode1)
	EndIf
	::cMotivoErro        :=  WSAdvValue( oResponse,"_MOTIVOERRO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cCaminhoFoto       :=  WSAdvValue( oResponse,"_CAMINHOFOTO","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure TransportadoraIntegracao

WSSTRUCT WS_GUARDIAN_TransportadoraIntegracao
	WSDATA   cRazaoSocial              AS string OPTIONAL
	WSDATA   cCnpj                     AS string OPTIONAL
	WSDATA   cInscricaoEstadual        AS string OPTIONAL
	WSDATA   cEndereco                 AS string OPTIONAL
	WSDATA   cComplemento              AS string OPTIONAL
	WSDATA   cMunicipio                AS string OPTIONAL
	WSDATA   cUF                       AS string OPTIONAL
	WSDATA   cCep                      AS string OPTIONAL
	WSDATA   cTelefone                 AS string OPTIONAL
	WSDATA   cObservacao               AS string OPTIONAL
	WSDATA   cEmail                    AS string OPTIONAL
	WSDATA   nEstado                   AS int
	WSDATA   nTipoDocumento            AS int
	WSDATA   lIncluiAtualiza           AS boolean
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WS_GUARDIAN_TransportadoraIntegracao
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WS_GUARDIAN_TransportadoraIntegracao
Return

WSMETHOD CLONE WSCLIENT WS_GUARDIAN_TransportadoraIntegracao
	Local oClone := WS_GUARDIAN_TransportadoraIntegracao():NEW()
	oClone:cRazaoSocial         := ::cRazaoSocial
	oClone:cCnpj                := ::cCnpj
	oClone:cInscricaoEstadual   := ::cInscricaoEstadual
	oClone:cEndereco            := ::cEndereco
	oClone:cComplemento         := ::cComplemento
	oClone:cMunicipio           := ::cMunicipio
	oClone:cUF                  := ::cUF
	oClone:cCep                 := ::cCep
	oClone:cTelefone            := ::cTelefone
	oClone:cObservacao          := ::cObservacao
	oClone:cEmail               := ::cEmail
	oClone:nEstado              := ::nEstado
	oClone:nTipoDocumento       := ::nTipoDocumento
	oClone:lIncluiAtualiza      := ::lIncluiAtualiza
Return oClone

WSMETHOD SOAPSEND WSCLIENT WS_GUARDIAN_TransportadoraIntegracao
	Local cSoap := ""
	cSoap += WSSoapValue("RazaoSocial", ::cRazaoSocial, ::cRazaoSocial , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Cnpj", ::cCnpj, ::cCnpj , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("InscricaoEstadual", ::cInscricaoEstadual, ::cInscricaoEstadual , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Endereco", ::cEndereco, ::cEndereco , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Complemento", ::cComplemento, ::cComplemento , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Municipio", ::cMunicipio, ::cMunicipio , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("UF", ::cUF, ::cUF , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Cep", ::cCep, ::cCep , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Telefone", ::cTelefone, ::cTelefone , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Observacao", ::cObservacao, ::cObservacao , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Email", ::cEmail, ::cEmail , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Estado", ::nEstado, ::nEstado , "int", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("TipoDocumento", ::nTipoDocumento, ::nTipoDocumento , "int", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("IncluiAtualiza", ::lIncluiAtualiza, ::lIncluiAtualiza , "boolean", .T. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

// WSDL Data Structure EmissorIntegracao

WSSTRUCT WS_GUARDIAN_EmissorIntegracao
	WSDATA   nTipoEmissor              AS int
	WSDATA   cRazaoSocial              AS string OPTIONAL
	WSDATA   cCnpj                     AS string OPTIONAL
	WSDATA   cInscricaoEstadual        AS string OPTIONAL
	WSDATA   cEndereco                 AS string OPTIONAL
	WSDATA   cComplemento              AS string OPTIONAL
	WSDATA   cMunicipio                AS string OPTIONAL
	WSDATA   cUF                       AS string OPTIONAL
	WSDATA   cCep                      AS string OPTIONAL
	WSDATA   cTelefone                 AS string OPTIONAL
	WSDATA   cEmail                    AS string OPTIONAL
	WSDATA   cObservacao               AS string OPTIONAL
	WSDATA   nEstado                   AS int
	WSDATA   nTipoDocumento            AS int
	WSDATA   lIncluiAtualiza           AS boolean
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WS_GUARDIAN_EmissorIntegracao
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WS_GUARDIAN_EmissorIntegracao
Return

WSMETHOD CLONE WSCLIENT WS_GUARDIAN_EmissorIntegracao
	Local oClone := WS_GUARDIAN_EmissorIntegracao():NEW()
	oClone:nTipoEmissor         := ::nTipoEmissor
	oClone:cRazaoSocial         := ::cRazaoSocial
	oClone:cCnpj                := ::cCnpj
	oClone:cInscricaoEstadual   := ::cInscricaoEstadual
	oClone:cEndereco            := ::cEndereco
	oClone:cComplemento         := ::cComplemento
	oClone:cMunicipio           := ::cMunicipio
	oClone:cUF                  := ::cUF
	oClone:cCep                 := ::cCep
	oClone:cTelefone            := ::cTelefone
	oClone:cEmail               := ::cEmail
	oClone:cObservacao          := ::cObservacao
	oClone:nEstado              := ::nEstado
	oClone:nTipoDocumento       := ::nTipoDocumento
	oClone:lIncluiAtualiza      := ::lIncluiAtualiza
Return oClone

WSMETHOD SOAPSEND WSCLIENT WS_GUARDIAN_EmissorIntegracao
	Local cSoap := ""
	cSoap += WSSoapValue("TipoEmissor", ::nTipoEmissor, ::nTipoEmissor , "int", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("RazaoSocial", ::cRazaoSocial, ::cRazaoSocial , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Cnpj", ::cCnpj, ::cCnpj , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("InscricaoEstadual", ::cInscricaoEstadual, ::cInscricaoEstadual , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Endereco", ::cEndereco, ::cEndereco , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Complemento", ::cComplemento, ::cComplemento , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Municipio", ::cMunicipio, ::cMunicipio , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("UF", ::cUF, ::cUF , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Cep", ::cCep, ::cCep , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Telefone", ::cTelefone, ::cTelefone , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Email", ::cEmail, ::cEmail , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Observacao", ::cObservacao, ::cObservacao , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Estado", ::nEstado, ::nEstado , "int", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("TipoDocumento", ::nTipoDocumento, ::nTipoDocumento , "int", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("IncluiAtualiza", ::lIncluiAtualiza, ::lIncluiAtualiza , "boolean", .T. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

// WSDL Data Structure MotoristaIntegracao

WSSTRUCT WS_GUARDIAN_MotoristaIntegracao
	WSDATA   cCpf                      AS string OPTIONAL
	WSDATA   cRg                       AS string OPTIONAL
	WSDATA   cNome                     AS string OPTIONAL
	WSDATA   cCnh                      AS string OPTIONAL
	WSDATA   nEstado                   AS int
	WSDATA   cObservacao               AS string OPTIONAL
	WSDATA   cInfoAcompanhantes        AS string OPTIONAL
	WSDATA   cNacionalidade            AS string OPTIONAL
	WSDATA   cDataNascimento           AS dateTime
	WSDATA   cDocEstrangeiro           AS string OPTIONAL
	WSDATA   lIncluiAtualiza           AS boolean
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WS_GUARDIAN_MotoristaIntegracao
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WS_GUARDIAN_MotoristaIntegracao
Return

WSMETHOD CLONE WSCLIENT WS_GUARDIAN_MotoristaIntegracao
	Local oClone := WS_GUARDIAN_MotoristaIntegracao():NEW()
	oClone:cCpf                 := ::cCpf
	oClone:cRg                  := ::cRg
	oClone:cNome                := ::cNome
	oClone:cCnh                 := ::cCnh
	oClone:nEstado              := ::nEstado
	oClone:cObservacao          := ::cObservacao
	oClone:cInfoAcompanhantes   := ::cInfoAcompanhantes
	oClone:cNacionalidade       := ::cNacionalidade
	oClone:cDataNascimento      := ::cDataNascimento
	oClone:cDocEstrangeiro      := ::cDocEstrangeiro
	oClone:lIncluiAtualiza      := ::lIncluiAtualiza
Return oClone

WSMETHOD SOAPSEND WSCLIENT WS_GUARDIAN_MotoristaIntegracao
	Local cSoap := ""
	cSoap += WSSoapValue("Cpf", ::cCpf, ::cCpf , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Rg", ::cRg, ::cRg , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Nome", ::cNome, ::cNome , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Cnh", ::cCnh, ::cCnh , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Estado", ::nEstado, ::nEstado , "int", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Observacao", ::cObservacao, ::cObservacao , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("InfoAcompanhantes", ::cInfoAcompanhantes, ::cInfoAcompanhantes , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Nacionalidade", ::cNacionalidade, ::cNacionalidade , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("DataNascimento", ::cDataNascimento, ::cDataNascimento , "dateTime", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("DocEstrangeiro", ::cDocEstrangeiro, ::cDocEstrangeiro , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("IncluiAtualiza", ::lIncluiAtualiza, ::lIncluiAtualiza , "boolean", .T. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

// WSDL Data Structure ArrayOfItemIntegracao

WSSTRUCT WS_GUARDIAN_ArrayOfItemIntegracao
	WSDATA   oWSItemIntegracao         AS WS_GUARDIAN_ItemIntegracao OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WS_GUARDIAN_ArrayOfItemIntegracao
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WS_GUARDIAN_ArrayOfItemIntegracao
	::oWSItemIntegracao    := {} // Array Of  WS_GUARDIAN_ITEMINTEGRACAO():New()
Return

WSMETHOD CLONE WSCLIENT WS_GUARDIAN_ArrayOfItemIntegracao
	Local oClone := WS_GUARDIAN_ArrayOfItemIntegracao():NEW()
	oClone:oWSItemIntegracao := NIL
	If ::oWSItemIntegracao <> NIL 
		oClone:oWSItemIntegracao := {}
		aEval( ::oWSItemIntegracao , { |x| aadd( oClone:oWSItemIntegracao , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT WS_GUARDIAN_ArrayOfItemIntegracao
	Local cSoap := ""
	aEval( ::oWSItemIntegracao , {|x| cSoap := cSoap  +  WSSoapValue("ItemIntegracao", x , x , "ItemIntegracao", .F. , .F., 0 , NIL, .F.,.F.)  } ) 
Return cSoap

// WSDL Data Structure ArrayOfDocumento

WSSTRUCT WS_GUARDIAN_ArrayOfDocumento
	WSDATA   oWSDocumento              AS WS_GUARDIAN_Documento OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WS_GUARDIAN_ArrayOfDocumento
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WS_GUARDIAN_ArrayOfDocumento
	::oWSDocumento         := {} // Array Of  WS_GUARDIAN_DOCUMENTO():New()
Return

WSMETHOD CLONE WSCLIENT WS_GUARDIAN_ArrayOfDocumento
	Local oClone := WS_GUARDIAN_ArrayOfDocumento():NEW()
	oClone:oWSDocumento := NIL
	If ::oWSDocumento <> NIL 
		oClone:oWSDocumento := {}
		aEval( ::oWSDocumento , { |x| aadd( oClone:oWSDocumento , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT WS_GUARDIAN_ArrayOfDocumento
	Local cSoap := ""
	aEval( ::oWSDocumento , {|x| cSoap := cSoap  +  WSSoapValue("Documento", x , x , "Documento", .F. , .F., 0 , NIL, .F.,.F.)  } ) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WS_GUARDIAN_ArrayOfDocumento
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_DOCUMENTO","Documento",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSDocumento , WS_GUARDIAN_Documento():New() )
			::oWSDocumento[len(::oWSDocumento)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ArrayOfListaFatoresCorrecaoTicket

WSSTRUCT WS_GUARDIAN_ArrayOfListaFatoresCorrecaoTicket
	WSDATA   oWSListaFatoresCorrecaoTicket AS WS_GUARDIAN_ListaFatoresCorrecaoTicket OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WS_GUARDIAN_ArrayOfListaFatoresCorrecaoTicket
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WS_GUARDIAN_ArrayOfListaFatoresCorrecaoTicket
	::oWSListaFatoresCorrecaoTicket := {} // Array Of  WS_GUARDIAN_LISTAFATORESCORRECAOTICKET():New()
Return

WSMETHOD CLONE WSCLIENT WS_GUARDIAN_ArrayOfListaFatoresCorrecaoTicket
	Local oClone := WS_GUARDIAN_ArrayOfListaFatoresCorrecaoTicket():NEW()
	oClone:oWSListaFatoresCorrecaoTicket := NIL
	If ::oWSListaFatoresCorrecaoTicket <> NIL 
		oClone:oWSListaFatoresCorrecaoTicket := {}
		aEval( ::oWSListaFatoresCorrecaoTicket , { |x| aadd( oClone:oWSListaFatoresCorrecaoTicket , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT WS_GUARDIAN_ArrayOfListaFatoresCorrecaoTicket
	Local cSoap := ""
	aEval( ::oWSListaFatoresCorrecaoTicket , {|x| cSoap := cSoap  +  WSSoapValue("ListaFatoresCorrecaoTicket", x , x , "ListaFatoresCorrecaoTicket", .F. , .F., 0 , NIL, .F.,.F.)  } ) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WS_GUARDIAN_ArrayOfListaFatoresCorrecaoTicket
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_LISTAFATORESCORRECAOTICKET","ListaFatoresCorrecaoTicket",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSListaFatoresCorrecaoTicket , WS_GUARDIAN_ListaFatoresCorrecaoTicket():New() )
			::oWSListaFatoresCorrecaoTicket[len(::oWSListaFatoresCorrecaoTicket)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ArrayOfCampoAdicionalTicket

WSSTRUCT WS_GUARDIAN_ArrayOfCampoAdicionalTicket
	WSDATA   oWSCampoAdicionalTicket   AS WS_GUARDIAN_CampoAdicionalTicket OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WS_GUARDIAN_ArrayOfCampoAdicionalTicket
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WS_GUARDIAN_ArrayOfCampoAdicionalTicket
	::oWSCampoAdicionalTicket := {} // Array Of  WS_GUARDIAN_CAMPOADICIONALTICKET():New()
Return

WSMETHOD CLONE WSCLIENT WS_GUARDIAN_ArrayOfCampoAdicionalTicket
	Local oClone := WS_GUARDIAN_ArrayOfCampoAdicionalTicket():NEW()
	oClone:oWSCampoAdicionalTicket := NIL
	If ::oWSCampoAdicionalTicket <> NIL 
		oClone:oWSCampoAdicionalTicket := {}
		aEval( ::oWSCampoAdicionalTicket , { |x| aadd( oClone:oWSCampoAdicionalTicket , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT WS_GUARDIAN_ArrayOfCampoAdicionalTicket
	Local cSoap := ""
	aEval( ::oWSCampoAdicionalTicket , {|x| cSoap := cSoap  +  WSSoapValue("CampoAdicionalTicket", x , x , "CampoAdicionalTicket", .F. , .F., 0 , NIL, .F.,.F.)  } ) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WS_GUARDIAN_ArrayOfCampoAdicionalTicket
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_CAMPOADICIONALTICKET","CampoAdicionalTicket",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSCampoAdicionalTicket , WS_GUARDIAN_CampoAdicionalTicket():New() )
			::oWSCampoAdicionalTicket[len(::oWSCampoAdicionalTicket)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ArrayOfEmbalagensTicket

WSSTRUCT WS_GUARDIAN_ArrayOfEmbalagensTicket
	WSDATA   oWSEmbalagensTicket       AS WS_GUARDIAN_EmbalagensTicket OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WS_GUARDIAN_ArrayOfEmbalagensTicket
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WS_GUARDIAN_ArrayOfEmbalagensTicket
	::oWSEmbalagensTicket  := {} // Array Of  WS_GUARDIAN_EMBALAGENSTICKET():New()
Return

WSMETHOD CLONE WSCLIENT WS_GUARDIAN_ArrayOfEmbalagensTicket
	Local oClone := WS_GUARDIAN_ArrayOfEmbalagensTicket():NEW()
	oClone:oWSEmbalagensTicket := NIL
	If ::oWSEmbalagensTicket <> NIL 
		oClone:oWSEmbalagensTicket := {}
		aEval( ::oWSEmbalagensTicket , { |x| aadd( oClone:oWSEmbalagensTicket , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT WS_GUARDIAN_ArrayOfEmbalagensTicket
	Local cSoap := ""
	aEval( ::oWSEmbalagensTicket , {|x| cSoap := cSoap  +  WSSoapValue("EmbalagensTicket", x , x , "EmbalagensTicket", .F. , .F., 0 , NIL, .F.,.F.)  } ) 
Return cSoap

// WSDL Data Structure ArrayOfConteinerVO

WSSTRUCT WS_GUARDIAN_ArrayOfConteinerVO
	WSDATA   oWSConteinerVO            AS WS_GUARDIAN_ConteinerVO OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WS_GUARDIAN_ArrayOfConteinerVO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WS_GUARDIAN_ArrayOfConteinerVO
	::oWSConteinerVO       := {} // Array Of  WS_GUARDIAN_CONTEINERVO():New()
Return

WSMETHOD CLONE WSCLIENT WS_GUARDIAN_ArrayOfConteinerVO
	Local oClone := WS_GUARDIAN_ArrayOfConteinerVO():NEW()
	oClone:oWSConteinerVO := NIL
	If ::oWSConteinerVO <> NIL 
		oClone:oWSConteinerVO := {}
		aEval( ::oWSConteinerVO , { |x| aadd( oClone:oWSConteinerVO , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT WS_GUARDIAN_ArrayOfConteinerVO
	Local cSoap := ""
	aEval( ::oWSConteinerVO , {|x| cSoap := cSoap  +  WSSoapValue("ConteinerVO", x , x , "ConteinerVO", .F. , .F., 0 , NIL, .F.,.F.)  } ) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WS_GUARDIAN_ArrayOfConteinerVO
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_CONTEINERVO","ConteinerVO",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSConteinerVO , WS_GUARDIAN_ConteinerVO():New() )
			::oWSConteinerVO[len(::oWSConteinerVO)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ArrayOfPontoDoFluxo

WSSTRUCT WS_GUARDIAN_ArrayOfPontoDoFluxo
	WSDATA   oWSPontoDoFluxo           AS WS_GUARDIAN_PontoDoFluxo OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WS_GUARDIAN_ArrayOfPontoDoFluxo
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WS_GUARDIAN_ArrayOfPontoDoFluxo
	::oWSPontoDoFluxo      := {} // Array Of  WS_GUARDIAN_PONTODOFLUXO():New()
Return

WSMETHOD CLONE WSCLIENT WS_GUARDIAN_ArrayOfPontoDoFluxo
	Local oClone := WS_GUARDIAN_ArrayOfPontoDoFluxo():NEW()
	oClone:oWSPontoDoFluxo := NIL
	If ::oWSPontoDoFluxo <> NIL 
		oClone:oWSPontoDoFluxo := {}
		aEval( ::oWSPontoDoFluxo , { |x| aadd( oClone:oWSPontoDoFluxo , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT WS_GUARDIAN_ArrayOfPontoDoFluxo
	Local cSoap := ""
	aEval( ::oWSPontoDoFluxo , {|x| cSoap := cSoap  +  WSSoapValue("PontoDoFluxo", x , x , "PontoDoFluxo", .F. , .F., 0 , NIL, .F.,.F.)  } ) 
Return cSoap

// WSDL Data Structure ETransportadora

WSSTRUCT WS_GUARDIAN_ETransportadora
	WSDATA   cRazaoSocial              AS string OPTIONAL
	WSDATA   cCnpj                     AS string OPTIONAL
	WSDATA   cInscricaoEstadual        AS string OPTIONAL
	WSDATA   cEndereco                 AS string OPTIONAL
	WSDATA   cComplemento              AS string OPTIONAL
	WSDATA   cMunicipio                AS string OPTIONAL
	WSDATA   nUF                       AS int
	WSDATA   cCep                      AS string OPTIONAL
	WSDATA   cTelefone                 AS string OPTIONAL
	WSDATA   cObservacao               AS string OPTIONAL
	WSDATA   cData                     AS dateTime
	WSDATA   cEmail                    AS string OPTIONAL
	WSDATA   nEstado                   AS int
	WSDATA   nTipoDocumento            AS int
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WS_GUARDIAN_ETransportadora
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WS_GUARDIAN_ETransportadora
Return

WSMETHOD CLONE WSCLIENT WS_GUARDIAN_ETransportadora
	Local oClone := WS_GUARDIAN_ETransportadora():NEW()
	oClone:cRazaoSocial         := ::cRazaoSocial
	oClone:cCnpj                := ::cCnpj
	oClone:cInscricaoEstadual   := ::cInscricaoEstadual
	oClone:cEndereco            := ::cEndereco
	oClone:cComplemento         := ::cComplemento
	oClone:cMunicipio           := ::cMunicipio
	oClone:nUF                  := ::nUF
	oClone:cCep                 := ::cCep
	oClone:cTelefone            := ::cTelefone
	oClone:cObservacao          := ::cObservacao
	oClone:cData                := ::cData
	oClone:cEmail               := ::cEmail
	oClone:nEstado              := ::nEstado
	oClone:nTipoDocumento       := ::nTipoDocumento
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WS_GUARDIAN_ETransportadora
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cRazaoSocial       :=  WSAdvValue( oResponse,"_RAZAOSOCIAL","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cCnpj              :=  WSAdvValue( oResponse,"_CNPJ","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cInscricaoEstadual :=  WSAdvValue( oResponse,"_INSCRICAOESTADUAL","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cEndereco          :=  WSAdvValue( oResponse,"_ENDERECO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cComplemento       :=  WSAdvValue( oResponse,"_COMPLEMENTO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cMunicipio         :=  WSAdvValue( oResponse,"_MUNICIPIO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nUF                :=  WSAdvValue( oResponse,"_UF","int",NIL,"Property nUF as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cCep               :=  WSAdvValue( oResponse,"_CEP","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cTelefone          :=  WSAdvValue( oResponse,"_TELEFONE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cObservacao        :=  WSAdvValue( oResponse,"_OBSERVACAO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cData              :=  WSAdvValue( oResponse,"_DATA","dateTime",NIL,"Property cData as s:dateTime on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cEmail             :=  WSAdvValue( oResponse,"_EMAIL","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nEstado            :=  WSAdvValue( oResponse,"_ESTADO","int",NIL,"Property nEstado as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nTipoDocumento     :=  WSAdvValue( oResponse,"_TIPODOCUMENTO","int",NIL,"Property nTipoDocumento as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
Return

// WSDL Data Structure EEmissor

WSSTRUCT WS_GUARDIAN_EEmissor
	WSDATA   nTipoEmissor              AS int
	WSDATA   cRazaoSocial              AS string OPTIONAL
	WSDATA   cCnpj                     AS string OPTIONAL
	WSDATA   cInscricaoEstadual        AS string OPTIONAL
	WSDATA   cEndereco                 AS string OPTIONAL
	WSDATA   cComplemento              AS string OPTIONAL
	WSDATA   cMunicipio                AS string OPTIONAL
	WSDATA   nUF                       AS int
	WSDATA   cCep                      AS string OPTIONAL
	WSDATA   cTelefone                 AS string OPTIONAL
	WSDATA   cEmail                    AS string OPTIONAL
	WSDATA   cObservacao               AS string OPTIONAL
	WSDATA   cData                     AS dateTime
	WSDATA   nEstado                   AS int
	WSDATA   nTipoDocumento            AS int
	WSDATA   nsequencialFatorCorrecao  AS int
	WSDATA   oWSTransportadoras        AS WS_GUARDIAN_ArrayOfETransportadora OPTIONAL
	WSDATA   lNaoVerificaToleranciaPesoOrigem AS boolean
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WS_GUARDIAN_EEmissor
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WS_GUARDIAN_EEmissor
Return

WSMETHOD CLONE WSCLIENT WS_GUARDIAN_EEmissor
	Local oClone := WS_GUARDIAN_EEmissor():NEW()
	oClone:nTipoEmissor         := ::nTipoEmissor
	oClone:cRazaoSocial         := ::cRazaoSocial
	oClone:cCnpj                := ::cCnpj
	oClone:cInscricaoEstadual   := ::cInscricaoEstadual
	oClone:cEndereco            := ::cEndereco
	oClone:cComplemento         := ::cComplemento
	oClone:cMunicipio           := ::cMunicipio
	oClone:nUF                  := ::nUF
	oClone:cCep                 := ::cCep
	oClone:cTelefone            := ::cTelefone
	oClone:cEmail               := ::cEmail
	oClone:cObservacao          := ::cObservacao
	oClone:cData                := ::cData
	oClone:nEstado              := ::nEstado
	oClone:nTipoDocumento       := ::nTipoDocumento
	oClone:nsequencialFatorCorrecao := ::nsequencialFatorCorrecao
	oClone:oWSTransportadoras   := IIF(::oWSTransportadoras = NIL , NIL , ::oWSTransportadoras:Clone() )
	oClone:lNaoVerificaToleranciaPesoOrigem := ::lNaoVerificaToleranciaPesoOrigem
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WS_GUARDIAN_EEmissor
	Local oNode17
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::nTipoEmissor       :=  WSAdvValue( oResponse,"_TIPOEMISSOR","int",NIL,"Property nTipoEmissor as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cRazaoSocial       :=  WSAdvValue( oResponse,"_RAZAOSOCIAL","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cCnpj              :=  WSAdvValue( oResponse,"_CNPJ","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cInscricaoEstadual :=  WSAdvValue( oResponse,"_INSCRICAOESTADUAL","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cEndereco          :=  WSAdvValue( oResponse,"_ENDERECO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cComplemento       :=  WSAdvValue( oResponse,"_COMPLEMENTO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cMunicipio         :=  WSAdvValue( oResponse,"_MUNICIPIO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nUF                :=  WSAdvValue( oResponse,"_UF","int",NIL,"Property nUF as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cCep               :=  WSAdvValue( oResponse,"_CEP","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cTelefone          :=  WSAdvValue( oResponse,"_TELEFONE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cEmail             :=  WSAdvValue( oResponse,"_EMAIL","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cObservacao        :=  WSAdvValue( oResponse,"_OBSERVACAO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cData              :=  WSAdvValue( oResponse,"_DATA","dateTime",NIL,"Property cData as s:dateTime on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::nEstado            :=  WSAdvValue( oResponse,"_ESTADO","int",NIL,"Property nEstado as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nTipoDocumento     :=  WSAdvValue( oResponse,"_TIPODOCUMENTO","int",NIL,"Property nTipoDocumento as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nsequencialFatorCorrecao :=  WSAdvValue( oResponse,"_SEQUENCIALFATORCORRECAO","int",NIL,"Property nsequencialFatorCorrecao as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	oNode17 :=  WSAdvValue( oResponse,"_TRANSPORTADORAS","ArrayOfETransportadora",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode17 != NIL
		::oWSTransportadoras := WS_GUARDIAN_ArrayOfETransportadora():New()
		::oWSTransportadoras:SoapRecv(oNode17)
	EndIf
	::lNaoVerificaToleranciaPesoOrigem :=  WSAdvValue( oResponse,"_NAOVERIFICATOLERANCIAPESOORIGEM","boolean",NIL,"Property lNaoVerificaToleranciaPesoOrigem as s:boolean on SOAP Response not found.",NIL,"L",NIL,NIL) 
Return

// WSDL Data Structure ArrayOfEItem

WSSTRUCT WS_GUARDIAN_ArrayOfEItem
	WSDATA   oWSEItem                  AS WS_GUARDIAN_EItem OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WS_GUARDIAN_ArrayOfEItem
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WS_GUARDIAN_ArrayOfEItem
	::oWSEItem             := {} // Array Of  WS_GUARDIAN_EITEM():New()
Return

WSMETHOD CLONE WSCLIENT WS_GUARDIAN_ArrayOfEItem
	Local oClone := WS_GUARDIAN_ArrayOfEItem():NEW()
	oClone:oWSEItem := NIL
	If ::oWSEItem <> NIL 
		oClone:oWSEItem := {}
		aEval( ::oWSEItem , { |x| aadd( oClone:oWSEItem , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WS_GUARDIAN_ArrayOfEItem
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_EITEM","EItem",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSEItem , WS_GUARDIAN_EItem():New() )
			::oWSEItem[len(::oWSEItem)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ArrayOfItemTicket

WSSTRUCT WS_GUARDIAN_ArrayOfItemTicket
	WSDATA   oWSItemTicket             AS WS_GUARDIAN_ItemTicket OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WS_GUARDIAN_ArrayOfItemTicket
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WS_GUARDIAN_ArrayOfItemTicket
	::oWSItemTicket        := {} // Array Of  WS_GUARDIAN_ITEMTICKET():New()
Return

WSMETHOD CLONE WSCLIENT WS_GUARDIAN_ArrayOfItemTicket
	Local oClone := WS_GUARDIAN_ArrayOfItemTicket():NEW()
	oClone:oWSItemTicket := NIL
	If ::oWSItemTicket <> NIL 
		oClone:oWSItemTicket := {}
		aEval( ::oWSItemTicket , { |x| aadd( oClone:oWSItemTicket , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WS_GUARDIAN_ArrayOfItemTicket
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_ITEMTICKET","ItemTicket",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSItemTicket , WS_GUARDIAN_ItemTicket():New() )
			::oWSItemTicket[len(::oWSItemTicket)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ArrayOfOperacaoTicket

WSSTRUCT WS_GUARDIAN_ArrayOfOperacaoTicket
	WSDATA   oWSOperacaoTicket         AS WS_GUARDIAN_OperacaoTicket OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WS_GUARDIAN_ArrayOfOperacaoTicket
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WS_GUARDIAN_ArrayOfOperacaoTicket
	::oWSOperacaoTicket    := {} // Array Of  WS_GUARDIAN_OPERACAOTICKET():New()
Return

WSMETHOD CLONE WSCLIENT WS_GUARDIAN_ArrayOfOperacaoTicket
	Local oClone := WS_GUARDIAN_ArrayOfOperacaoTicket():NEW()
	oClone:oWSOperacaoTicket := NIL
	If ::oWSOperacaoTicket <> NIL 
		oClone:oWSOperacaoTicket := {}
		aEval( ::oWSOperacaoTicket , { |x| aadd( oClone:oWSOperacaoTicket , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WS_GUARDIAN_ArrayOfOperacaoTicket
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_OPERACAOTICKET","OperacaoTicket",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSOperacaoTicket , WS_GUARDIAN_OperacaoTicket():New() )
			::oWSOperacaoTicket[len(::oWSOperacaoTicket)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ArrayOfReimpressoesTicket

WSSTRUCT WS_GUARDIAN_ArrayOfReimpressoesTicket
	WSDATA   oWSReimpressoesTicket     AS WS_GUARDIAN_ReimpressoesTicket OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WS_GUARDIAN_ArrayOfReimpressoesTicket
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WS_GUARDIAN_ArrayOfReimpressoesTicket
	::oWSReimpressoesTicket := {} // Array Of  WS_GUARDIAN_REIMPRESSOESTICKET():New()
Return

WSMETHOD CLONE WSCLIENT WS_GUARDIAN_ArrayOfReimpressoesTicket
	Local oClone := WS_GUARDIAN_ArrayOfReimpressoesTicket():NEW()
	oClone:oWSReimpressoesTicket := NIL
	If ::oWSReimpressoesTicket <> NIL 
		oClone:oWSReimpressoesTicket := {}
		aEval( ::oWSReimpressoesTicket , { |x| aadd( oClone:oWSReimpressoesTicket , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WS_GUARDIAN_ArrayOfReimpressoesTicket
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_REIMPRESSOESTICKET","ReimpressoesTicket",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSReimpressoesTicket , WS_GUARDIAN_ReimpressoesTicket():New() )
			::oWSReimpressoesTicket[len(::oWSReimpressoesTicket)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ArrayOfEEmbalagensTicket

WSSTRUCT WS_GUARDIAN_ArrayOfEEmbalagensTicket
	WSDATA   oWSEEmbalagensTicket      AS WS_GUARDIAN_EEmbalagensTicket OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WS_GUARDIAN_ArrayOfEEmbalagensTicket
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WS_GUARDIAN_ArrayOfEEmbalagensTicket
	::oWSEEmbalagensTicket := {} // Array Of  WS_GUARDIAN_EEMBALAGENSTICKET():New()
Return

WSMETHOD CLONE WSCLIENT WS_GUARDIAN_ArrayOfEEmbalagensTicket
	Local oClone := WS_GUARDIAN_ArrayOfEEmbalagensTicket():NEW()
	oClone:oWSEEmbalagensTicket := NIL
	If ::oWSEEmbalagensTicket <> NIL 
		oClone:oWSEEmbalagensTicket := {}
		aEval( ::oWSEEmbalagensTicket , { |x| aadd( oClone:oWSEEmbalagensTicket , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WS_GUARDIAN_ArrayOfEEmbalagensTicket
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_EEMBALAGENSTICKET","EEmbalagensTicket",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSEEmbalagensTicket , WS_GUARDIAN_EEmbalagensTicket():New() )
			::oWSEEmbalagensTicket[len(::oWSEEmbalagensTicket)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ArrayOfFluxoTicketSequencia

WSSTRUCT WS_GUARDIAN_ArrayOfFluxoTicketSequencia
	WSDATA   oWSFluxoTicketSequencia   AS WS_GUARDIAN_FluxoTicketSequencia OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WS_GUARDIAN_ArrayOfFluxoTicketSequencia
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WS_GUARDIAN_ArrayOfFluxoTicketSequencia
	::oWSFluxoTicketSequencia := {} // Array Of  WS_GUARDIAN_FLUXOTICKETSEQUENCIA():New()
Return

WSMETHOD CLONE WSCLIENT WS_GUARDIAN_ArrayOfFluxoTicketSequencia
	Local oClone := WS_GUARDIAN_ArrayOfFluxoTicketSequencia():NEW()
	oClone:oWSFluxoTicketSequencia := NIL
	If ::oWSFluxoTicketSequencia <> NIL 
		oClone:oWSFluxoTicketSequencia := {}
		aEval( ::oWSFluxoTicketSequencia , { |x| aadd( oClone:oWSFluxoTicketSequencia , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WS_GUARDIAN_ArrayOfFluxoTicketSequencia
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_FLUXOTICKETSEQUENCIA","FluxoTicketSequencia",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSFluxoTicketSequencia , WS_GUARDIAN_FluxoTicketSequencia():New() )
			::oWSFluxoTicketSequencia[len(::oWSFluxoTicketSequencia)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ArrayOfIntegracaoOCR

WSSTRUCT WS_GUARDIAN_ArrayOfIntegracaoOCR
	WSDATA   oWSIntegracaoOCR          AS WS_GUARDIAN_IntegracaoOCR OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WS_GUARDIAN_ArrayOfIntegracaoOCR
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WS_GUARDIAN_ArrayOfIntegracaoOCR
	::oWSIntegracaoOCR     := {} // Array Of  WS_GUARDIAN_INTEGRACAOOCR():New()
Return

WSMETHOD CLONE WSCLIENT WS_GUARDIAN_ArrayOfIntegracaoOCR
	Local oClone := WS_GUARDIAN_ArrayOfIntegracaoOCR():NEW()
	oClone:oWSIntegracaoOCR := NIL
	If ::oWSIntegracaoOCR <> NIL 
		oClone:oWSIntegracaoOCR := {}
		aEval( ::oWSIntegracaoOCR , { |x| aadd( oClone:oWSIntegracaoOCR , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WS_GUARDIAN_ArrayOfIntegracaoOCR
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_INTEGRACAOOCR","IntegracaoOCR",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSIntegracaoOCR , WS_GUARDIAN_IntegracaoOCR():New() )
			::oWSIntegracaoOCR[len(::oWSIntegracaoOCR)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ArrayOfImportaDocumentoDoTicketG4

WSSTRUCT WS_GUARDIAN_ArrayOfImportaDocumentoDoTicketG4
	WSDATA   oWSImportaDocumentoDoTicketG4 AS WS_GUARDIAN_ImportaDocumentoDoTicketG4 OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WS_GUARDIAN_ArrayOfImportaDocumentoDoTicketG4
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WS_GUARDIAN_ArrayOfImportaDocumentoDoTicketG4
	::oWSImportaDocumentoDoTicketG4 := {} // Array Of  WS_GUARDIAN_IMPORTADOCUMENTODOTICKETG4():New()
Return

WSMETHOD CLONE WSCLIENT WS_GUARDIAN_ArrayOfImportaDocumentoDoTicketG4
	Local oClone := WS_GUARDIAN_ArrayOfImportaDocumentoDoTicketG4():NEW()
	oClone:oWSImportaDocumentoDoTicketG4 := NIL
	If ::oWSImportaDocumentoDoTicketG4 <> NIL 
		oClone:oWSImportaDocumentoDoTicketG4 := {}
		aEval( ::oWSImportaDocumentoDoTicketG4 , { |x| aadd( oClone:oWSImportaDocumentoDoTicketG4 , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT WS_GUARDIAN_ArrayOfImportaDocumentoDoTicketG4
	Local cSoap := ""
	aEval( ::oWSImportaDocumentoDoTicketG4 , {|x| cSoap := cSoap  +  WSSoapValue("ImportaDocumentoDoTicketG4", x , x , "ImportaDocumentoDoTicketG4", .F. , .F., 0 , NIL, .F.,.F.)  } ) 
Return cSoap

// WSDL Data Structure ArrayOfImportaItemDoTicketG4

WSSTRUCT WS_GUARDIAN_ArrayOfImportaItemDoTicketG4
	WSDATA   oWSImportaItemDoTicketG4  AS WS_GUARDIAN_ImportaItemDoTicketG4 OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WS_GUARDIAN_ArrayOfImportaItemDoTicketG4
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WS_GUARDIAN_ArrayOfImportaItemDoTicketG4
	::oWSImportaItemDoTicketG4 := {} // Array Of  WS_GUARDIAN_IMPORTAITEMDOTICKETG4():New()
Return

WSMETHOD CLONE WSCLIENT WS_GUARDIAN_ArrayOfImportaItemDoTicketG4
	Local oClone := WS_GUARDIAN_ArrayOfImportaItemDoTicketG4():NEW()
	oClone:oWSImportaItemDoTicketG4 := NIL
	If ::oWSImportaItemDoTicketG4 <> NIL 
		oClone:oWSImportaItemDoTicketG4 := {}
		aEval( ::oWSImportaItemDoTicketG4 , { |x| aadd( oClone:oWSImportaItemDoTicketG4 , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT WS_GUARDIAN_ArrayOfImportaItemDoTicketG4
	Local cSoap := ""
	aEval( ::oWSImportaItemDoTicketG4 , {|x| cSoap := cSoap  +  WSSoapValue("ImportaItemDoTicketG4", x , x , "ImportaItemDoTicketG4", .F. , .F., 0 , NIL, .F.,.F.)  } ) 
Return cSoap

// WSDL Data Structure ArrayOfExportaDocumentoDoTicketG4

WSSTRUCT WS_GUARDIAN_ArrayOfExportaDocumentoDoTicketG4
	WSDATA   oWSExportaDocumentoDoTicketG4 AS WS_GUARDIAN_ExportaDocumentoDoTicketG4 OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WS_GUARDIAN_ArrayOfExportaDocumentoDoTicketG4
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WS_GUARDIAN_ArrayOfExportaDocumentoDoTicketG4
	::oWSExportaDocumentoDoTicketG4 := {} // Array Of  WS_GUARDIAN_EXPORTADOCUMENTODOTICKETG4():New()
Return

WSMETHOD CLONE WSCLIENT WS_GUARDIAN_ArrayOfExportaDocumentoDoTicketG4
	Local oClone := WS_GUARDIAN_ArrayOfExportaDocumentoDoTicketG4():NEW()
	oClone:oWSExportaDocumentoDoTicketG4 := NIL
	If ::oWSExportaDocumentoDoTicketG4 <> NIL 
		oClone:oWSExportaDocumentoDoTicketG4 := {}
		aEval( ::oWSExportaDocumentoDoTicketG4 , { |x| aadd( oClone:oWSExportaDocumentoDoTicketG4 , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WS_GUARDIAN_ArrayOfExportaDocumentoDoTicketG4
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_EXPORTADOCUMENTODOTICKETG4","ExportaDocumentoDoTicketG4",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSExportaDocumentoDoTicketG4 , WS_GUARDIAN_ExportaDocumentoDoTicketG4():New() )
			::oWSExportaDocumentoDoTicketG4[len(::oWSExportaDocumentoDoTicketG4)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ArrayOfExportaItemDoTicketG4

WSSTRUCT WS_GUARDIAN_ArrayOfExportaItemDoTicketG4
	WSDATA   oWSExportaItemDoTicketG4  AS WS_GUARDIAN_ExportaItemDoTicketG4 OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WS_GUARDIAN_ArrayOfExportaItemDoTicketG4
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WS_GUARDIAN_ArrayOfExportaItemDoTicketG4
	::oWSExportaItemDoTicketG4 := {} // Array Of  WS_GUARDIAN_EXPORTAITEMDOTICKETG4():New()
Return

WSMETHOD CLONE WSCLIENT WS_GUARDIAN_ArrayOfExportaItemDoTicketG4
	Local oClone := WS_GUARDIAN_ArrayOfExportaItemDoTicketG4():NEW()
	oClone:oWSExportaItemDoTicketG4 := NIL
	If ::oWSExportaItemDoTicketG4 <> NIL 
		oClone:oWSExportaItemDoTicketG4 := {}
		aEval( ::oWSExportaItemDoTicketG4 , { |x| aadd( oClone:oWSExportaItemDoTicketG4 , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WS_GUARDIAN_ArrayOfExportaItemDoTicketG4
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_EXPORTAITEMDOTICKETG4","ExportaItemDoTicketG4",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSExportaItemDoTicketG4 , WS_GUARDIAN_ExportaItemDoTicketG4():New() )
			::oWSExportaItemDoTicketG4[len(::oWSExportaItemDoTicketG4)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure LogAplicacao

WSSTRUCT WS_GUARDIAN_LogAplicacao
	WSDATA   cCodigo                   AS string OPTIONAL
	WSDATA   nSequencial               AS long
	WSDATA   cInformacao               AS string OPTIONAL
	WSDATA   cData                     AS dateTime
	WSDATA   nCategoria                AS int
	WSDATA   cFuncao                   AS string OPTIONAL
	WSDATA   nTipo                     AS int
	WSDATA   cSistemaDeIntegracao      AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WS_GUARDIAN_LogAplicacao
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WS_GUARDIAN_LogAplicacao
Return

WSMETHOD CLONE WSCLIENT WS_GUARDIAN_LogAplicacao
	Local oClone := WS_GUARDIAN_LogAplicacao():NEW()
	oClone:cCodigo              := ::cCodigo
	oClone:nSequencial          := ::nSequencial
	oClone:cInformacao          := ::cInformacao
	oClone:cData                := ::cData
	oClone:nCategoria           := ::nCategoria
	oClone:cFuncao              := ::cFuncao
	oClone:nTipo                := ::nTipo
	oClone:cSistemaDeIntegracao := ::cSistemaDeIntegracao
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WS_GUARDIAN_LogAplicacao
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cCodigo            :=  WSAdvValue( oResponse,"_CODIGO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nSequencial        :=  WSAdvValue( oResponse,"_SEQUENCIAL","long",NIL,"Property nSequencial as s:long on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cInformacao        :=  WSAdvValue( oResponse,"_INFORMACAO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cData              :=  WSAdvValue( oResponse,"_DATA","dateTime",NIL,"Property cData as s:dateTime on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::nCategoria         :=  WSAdvValue( oResponse,"_CATEGORIA","int",NIL,"Property nCategoria as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cFuncao            :=  WSAdvValue( oResponse,"_FUNCAO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nTipo              :=  WSAdvValue( oResponse,"_TIPO","int",NIL,"Property nTipo as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cSistemaDeIntegracao :=  WSAdvValue( oResponse,"_SISTEMADEINTEGRACAO","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure LogPeriferico

WSSTRUCT WS_GUARDIAN_LogPeriferico
	WSDATA   cCodigo                   AS string OPTIONAL
	WSDATA   nSequencial               AS long
	WSDATA   cInformacao               AS string OPTIONAL
	WSDATA   cData                     AS dateTime
	WSDATA   nCategoria                AS int
	WSDATA   cJustificativa            AS string OPTIONAL
	WSDATA   nSequencialPeriferico     AS int
	WSDATA   cCodigoPeriferico         AS string OPTIONAL
	WSDATA   cDescricaoPeriferico      AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WS_GUARDIAN_LogPeriferico
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WS_GUARDIAN_LogPeriferico
Return

WSMETHOD CLONE WSCLIENT WS_GUARDIAN_LogPeriferico
	Local oClone := WS_GUARDIAN_LogPeriferico():NEW()
	oClone:cCodigo              := ::cCodigo
	oClone:nSequencial          := ::nSequencial
	oClone:cInformacao          := ::cInformacao
	oClone:cData                := ::cData
	oClone:nCategoria           := ::nCategoria
	oClone:cJustificativa       := ::cJustificativa
	oClone:nSequencialPeriferico := ::nSequencialPeriferico
	oClone:cCodigoPeriferico    := ::cCodigoPeriferico
	oClone:cDescricaoPeriferico := ::cDescricaoPeriferico
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WS_GUARDIAN_LogPeriferico
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cCodigo            :=  WSAdvValue( oResponse,"_CODIGO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nSequencial        :=  WSAdvValue( oResponse,"_SEQUENCIAL","long",NIL,"Property nSequencial as s:long on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cInformacao        :=  WSAdvValue( oResponse,"_INFORMACAO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cData              :=  WSAdvValue( oResponse,"_DATA","dateTime",NIL,"Property cData as s:dateTime on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::nCategoria         :=  WSAdvValue( oResponse,"_CATEGORIA","int",NIL,"Property nCategoria as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cJustificativa     :=  WSAdvValue( oResponse,"_JUSTIFICATIVA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nSequencialPeriferico :=  WSAdvValue( oResponse,"_SEQUENCIALPERIFERICO","int",NIL,"Property nSequencialPeriferico as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cCodigoPeriferico  :=  WSAdvValue( oResponse,"_CODIGOPERIFERICO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cDescricaoPeriferico :=  WSAdvValue( oResponse,"_DESCRICAOPERIFERICO","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure ConsultaLogAuditoriaOUT

WSSTRUCT WS_GUARDIAN_ConsultaLogAuditoriaOUT
	WSDATA   cData                     AS dateTime
	WSDATA   cCodigoEstacaoControle    AS string OPTIONAL
	WSDATA   cLoginUsuarioLogado       AS string OPTIONAL
	WSDATA   cLoginUsuarioAssinado     AS string OPTIONAL
	WSDATA   cNomeModulo               AS string OPTIONAL
	WSDATA   cDescricaoAcao            AS string OPTIONAL
	WSDATA   cCamposAlterados          AS string OPTIONAL
	WSDATA   cValoresOriginais         AS string OPTIONAL
	WSDATA   cValoresAlterados         AS string OPTIONAL
	WSDATA   cJustificativa            AS string OPTIONAL
	WSDATA   cDetalhes                 AS string OPTIONAL
	WSDATA   cMensagemRetornoWebService AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WS_GUARDIAN_ConsultaLogAuditoriaOUT
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WS_GUARDIAN_ConsultaLogAuditoriaOUT
Return

WSMETHOD CLONE WSCLIENT WS_GUARDIAN_ConsultaLogAuditoriaOUT
	Local oClone := WS_GUARDIAN_ConsultaLogAuditoriaOUT():NEW()
	oClone:cData                := ::cData
	oClone:cCodigoEstacaoControle := ::cCodigoEstacaoControle
	oClone:cLoginUsuarioLogado  := ::cLoginUsuarioLogado
	oClone:cLoginUsuarioAssinado := ::cLoginUsuarioAssinado
	oClone:cNomeModulo          := ::cNomeModulo
	oClone:cDescricaoAcao       := ::cDescricaoAcao
	oClone:cCamposAlterados     := ::cCamposAlterados
	oClone:cValoresOriginais    := ::cValoresOriginais
	oClone:cValoresAlterados    := ::cValoresAlterados
	oClone:cJustificativa       := ::cJustificativa
	oClone:cDetalhes            := ::cDetalhes
	oClone:cMensagemRetornoWebService := ::cMensagemRetornoWebService
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WS_GUARDIAN_ConsultaLogAuditoriaOUT
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cData              :=  WSAdvValue( oResponse,"_DATA","dateTime",NIL,"Property cData as s:dateTime on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cCodigoEstacaoControle :=  WSAdvValue( oResponse,"_CODIGOESTACAOCONTROLE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cLoginUsuarioLogado :=  WSAdvValue( oResponse,"_LOGINUSUARIOLOGADO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cLoginUsuarioAssinado :=  WSAdvValue( oResponse,"_LOGINUSUARIOASSINADO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cNomeModulo        :=  WSAdvValue( oResponse,"_NOMEMODULO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cDescricaoAcao     :=  WSAdvValue( oResponse,"_DESCRICAOACAO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cCamposAlterados   :=  WSAdvValue( oResponse,"_CAMPOSALTERADOS","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cValoresOriginais  :=  WSAdvValue( oResponse,"_VALORESORIGINAIS","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cValoresAlterados  :=  WSAdvValue( oResponse,"_VALORESALTERADOS","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cJustificativa     :=  WSAdvValue( oResponse,"_JUSTIFICATIVA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cDetalhes          :=  WSAdvValue( oResponse,"_DETALHES","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cMensagemRetornoWebService :=  WSAdvValue( oResponse,"_MENSAGEMRETORNOWEBSERVICE","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure HistoricoPassagem

WSSTRUCT WS_GUARDIAN_HistoricoPassagem
	WSDATA   cCodigo                   AS string OPTIONAL
	WSDATA   nMedia                    AS decimal
	WSDATA   nMinimo                   AS decimal
	WSDATA   nMaximo                   AS decimal
	WSDATA   cData                     AS dateTime
	WSDATA   nPeriferico               AS int
	WSDATA   nEstacaoControle          AS int
	WSDATA   nOperacaoTicket           AS int
	WSDATA   cTAG                      AS string OPTIONAL
	WSDATA   nEstado                   AS int
	WSDATA   cEstacaoControleCodigo    AS string OPTIONAL
	WSDATA   cPerifericoCodigo         AS string OPTIONAL
	WSDATA   cPontoDeControleCodigo    AS string OPTIONAL
	WSDATA   lFlagPossivelIdentificacao AS boolean
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WS_GUARDIAN_HistoricoPassagem
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WS_GUARDIAN_HistoricoPassagem
Return

WSMETHOD CLONE WSCLIENT WS_GUARDIAN_HistoricoPassagem
	Local oClone := WS_GUARDIAN_HistoricoPassagem():NEW()
	oClone:cCodigo              := ::cCodigo
	oClone:nMedia               := ::nMedia
	oClone:nMinimo              := ::nMinimo
	oClone:nMaximo              := ::nMaximo
	oClone:cData                := ::cData
	oClone:nPeriferico          := ::nPeriferico
	oClone:nEstacaoControle     := ::nEstacaoControle
	oClone:nOperacaoTicket      := ::nOperacaoTicket
	oClone:cTAG                 := ::cTAG
	oClone:nEstado              := ::nEstado
	oClone:cEstacaoControleCodigo := ::cEstacaoControleCodigo
	oClone:cPerifericoCodigo    := ::cPerifericoCodigo
	oClone:cPontoDeControleCodigo := ::cPontoDeControleCodigo
	oClone:lFlagPossivelIdentificacao := ::lFlagPossivelIdentificacao
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WS_GUARDIAN_HistoricoPassagem
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cCodigo            :=  WSAdvValue( oResponse,"_CODIGO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nMedia             :=  WSAdvValue( oResponse,"_MEDIA","decimal",NIL,"Property nMedia as s:decimal on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nMinimo            :=  WSAdvValue( oResponse,"_MINIMO","decimal",NIL,"Property nMinimo as s:decimal on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nMaximo            :=  WSAdvValue( oResponse,"_MAXIMO","decimal",NIL,"Property nMaximo as s:decimal on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cData              :=  WSAdvValue( oResponse,"_DATA","dateTime",NIL,"Property cData as s:dateTime on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::nPeriferico        :=  WSAdvValue( oResponse,"_PERIFERICO","int",NIL,"Property nPeriferico as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nEstacaoControle   :=  WSAdvValue( oResponse,"_ESTACAOCONTROLE","int",NIL,"Property nEstacaoControle as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nOperacaoTicket    :=  WSAdvValue( oResponse,"_OPERACAOTICKET","int",NIL,"Property nOperacaoTicket as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cTAG               :=  WSAdvValue( oResponse,"_TAG","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nEstado            :=  WSAdvValue( oResponse,"_ESTADO","int",NIL,"Property nEstado as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cEstacaoControleCodigo :=  WSAdvValue( oResponse,"_ESTACAOCONTROLECODIGO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cPerifericoCodigo  :=  WSAdvValue( oResponse,"_PERIFERICOCODIGO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cPontoDeControleCodigo :=  WSAdvValue( oResponse,"_PONTODECONTROLECODIGO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::lFlagPossivelIdentificacao :=  WSAdvValue( oResponse,"_FLAGPOSSIVELIDENTIFICACAO","boolean",NIL,"Property lFlagPossivelIdentificacao as s:boolean on SOAP Response not found.",NIL,"L",NIL,NIL) 
Return

// WSDL Data Enumeration StatusRetorno

WSSTRUCT WS_GUARDIAN_StatusRetorno
	WSDATA   Value                     AS string
	WSDATA   cValueType                AS string
	WSDATA   aValueList                AS Array Of string
	WSMETHOD NEW
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WS_GUARDIAN_StatusRetorno
	::Value := NIL
	::cValueType := "string"
	::aValueList := {}
	aadd(::aValueList , "AguardandoNaFila" )
	aadd(::aValueList , "Processado" )
	aadd(::aValueList , "Erro" )
Return Self

WSMETHOD SOAPSEND WSCLIENT WS_GUARDIAN_StatusRetorno
	Local cSoap := "" 
	cSoap += WSSoapValue("Value", ::Value, NIL , "string", .F. , .F., 3 , NIL, .F.,.F.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WS_GUARDIAN_StatusRetorno
	::Value := NIL
	If oResponse = NIL ; Return ; Endif 
	::Value :=  oResponse:TEXT
Return 

WSMETHOD CLONE WSCLIENT WS_GUARDIAN_StatusRetorno
Local oClone := WS_GUARDIAN_StatusRetorno():New()
	oClone:Value := ::Value
Return oClone

// WSDL Data Structure ItemIntegracao

WSSTRUCT WS_GUARDIAN_ItemIntegracao
	WSDATA   nTipo                     AS int
	WSDATA   cNome                     AS string OPTIONAL
	WSDATA   cInformacao               AS string OPTIONAL
	WSDATA   nPesoUnitario             AS decimal
	WSDATA   cUnidadeMedida            AS string OPTIONAL
	WSDATA   lPodeConverter            AS boolean
	WSDATA   nFatorConversao           AS decimal
	WSDATA   cUnidadeMedidaConversao   AS string OPTIONAL
	WSDATA   lUtilizaContador          AS boolean
	WSDATA   nInicioContador           AS int
	WSDATA   nFinalContador            AS int
	WSDATA   nPrefixoContador          AS int
	WSDATA   nEstado                   AS int
	WSDATA   cCodigoFatorCorrecao      AS string OPTIONAL
	WSDATA   cCodigoFluxo              AS string OPTIONAL
	WSDATA   lInicialObrigatoria       AS boolean
	WSDATA   nQuantidadeViasRelatorioImpressas AS int
	WSDATA   lIncluiAtualiza           AS boolean
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WS_GUARDIAN_ItemIntegracao
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WS_GUARDIAN_ItemIntegracao
Return

WSMETHOD CLONE WSCLIENT WS_GUARDIAN_ItemIntegracao
	Local oClone := WS_GUARDIAN_ItemIntegracao():NEW()
	oClone:nTipo                := ::nTipo
	oClone:cNome                := ::cNome
	oClone:cInformacao          := ::cInformacao
	oClone:nPesoUnitario        := ::nPesoUnitario
	oClone:cUnidadeMedida       := ::cUnidadeMedida
	oClone:lPodeConverter       := ::lPodeConverter
	oClone:nFatorConversao      := ::nFatorConversao
	oClone:cUnidadeMedidaConversao := ::cUnidadeMedidaConversao
	oClone:lUtilizaContador     := ::lUtilizaContador
	oClone:nInicioContador      := ::nInicioContador
	oClone:nFinalContador       := ::nFinalContador
	oClone:nPrefixoContador     := ::nPrefixoContador
	oClone:nEstado              := ::nEstado
	oClone:cCodigoFatorCorrecao := ::cCodigoFatorCorrecao
	oClone:cCodigoFluxo         := ::cCodigoFluxo
	oClone:lInicialObrigatoria  := ::lInicialObrigatoria
	oClone:nQuantidadeViasRelatorioImpressas := ::nQuantidadeViasRelatorioImpressas
	oClone:lIncluiAtualiza      := ::lIncluiAtualiza
Return oClone

WSMETHOD SOAPSEND WSCLIENT WS_GUARDIAN_ItemIntegracao
	Local cSoap := ""
	cSoap += WSSoapValue("Tipo", ::nTipo, ::nTipo , "int", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Nome", ::cNome, ::cNome , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Informacao", ::cInformacao, ::cInformacao , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("PesoUnitario", ::nPesoUnitario, ::nPesoUnitario , "decimal", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("UnidadeMedida", ::cUnidadeMedida, ::cUnidadeMedida , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("PodeConverter", ::lPodeConverter, ::lPodeConverter , "boolean", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("FatorConversao", ::nFatorConversao, ::nFatorConversao , "decimal", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("UnidadeMedidaConversao", ::cUnidadeMedidaConversao, ::cUnidadeMedidaConversao , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("UtilizaContador", ::lUtilizaContador, ::lUtilizaContador , "boolean", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("InicioContador", ::nInicioContador, ::nInicioContador , "int", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("FinalContador", ::nFinalContador, ::nFinalContador , "int", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("PrefixoContador", ::nPrefixoContador, ::nPrefixoContador , "int", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Estado", ::nEstado, ::nEstado , "int", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CodigoFatorCorrecao", ::cCodigoFatorCorrecao, ::cCodigoFatorCorrecao , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CodigoFluxo", ::cCodigoFluxo, ::cCodigoFluxo , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("InicialObrigatoria", ::lInicialObrigatoria, ::lInicialObrigatoria , "boolean", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("QuantidadeViasRelatorioImpressas", ::nQuantidadeViasRelatorioImpressas, ::nQuantidadeViasRelatorioImpressas , "int", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("IncluiAtualiza", ::lIncluiAtualiza, ::lIncluiAtualiza , "boolean", .T. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

// WSDL Data Structure Documento

WSSTRUCT WS_GUARDIAN_Documento
	WSDATA   cDescricao                AS string OPTIONAL
	WSDATA   nPesoOrigem               AS decimal
	WSDATA   nEstado                   AS int
	WSDATA   cCodigo                   AS string OPTIONAL
	WSDATA   cData                     AS dateTime
	WSDATA   lPesagemRealizada         AS boolean
	WSDATA   nTolerancia               AS double
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WS_GUARDIAN_Documento
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WS_GUARDIAN_Documento
Return

WSMETHOD CLONE WSCLIENT WS_GUARDIAN_Documento
	Local oClone := WS_GUARDIAN_Documento():NEW()
	oClone:cDescricao           := ::cDescricao
	oClone:nPesoOrigem          := ::nPesoOrigem
	oClone:nEstado              := ::nEstado
	oClone:cCodigo              := ::cCodigo
	oClone:cData                := ::cData
	oClone:lPesagemRealizada    := ::lPesagemRealizada
	oClone:nTolerancia          := ::nTolerancia
Return oClone

WSMETHOD SOAPSEND WSCLIENT WS_GUARDIAN_Documento
	Local cSoap := ""
	cSoap += WSSoapValue("Descricao", ::cDescricao, ::cDescricao , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("PesoOrigem", ::nPesoOrigem, ::nPesoOrigem , "decimal", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Estado", ::nEstado, ::nEstado , "int", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Codigo", ::cCodigo, ::cCodigo , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Data", ::cData, ::cData , "dateTime", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("PesagemRealizada", ::lPesagemRealizada, ::lPesagemRealizada , "boolean", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Tolerancia", ::nTolerancia, ::nTolerancia , "double", .T. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WS_GUARDIAN_Documento
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cDescricao         :=  WSAdvValue( oResponse,"_DESCRICAO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nPesoOrigem        :=  WSAdvValue( oResponse,"_PESOORIGEM","decimal",NIL,"Property nPesoOrigem as s:decimal on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nEstado            :=  WSAdvValue( oResponse,"_ESTADO","int",NIL,"Property nEstado as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cCodigo            :=  WSAdvValue( oResponse,"_CODIGO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cData              :=  WSAdvValue( oResponse,"_DATA","dateTime",NIL,"Property cData as s:dateTime on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::lPesagemRealizada  :=  WSAdvValue( oResponse,"_PESAGEMREALIZADA","boolean",NIL,"Property lPesagemRealizada as s:boolean on SOAP Response not found.",NIL,"L",NIL,NIL) 
	::nTolerancia        :=  WSAdvValue( oResponse,"_TOLERANCIA","double",NIL,"Property nTolerancia as s:double on SOAP Response not found.",NIL,"N",NIL,NIL) 
Return

// WSDL Data Structure ListaFatoresCorrecaoTicket

WSSTRUCT WS_GUARDIAN_ListaFatoresCorrecaoTicket
	WSDATA   nNumero                   AS int
	WSDATA   cDescricao                AS string OPTIONAL
	WSDATA   cData                     AS dateTime
	WSDATA   nEstado                   AS int
	WSDATA   cCodigoItem               AS string OPTIONAL
	WSDATA   cCodigo                   AS string OPTIONAL
	WSDATA   nFator                    AS decimal
	WSDATA   nValorMinimo              AS decimal
	WSDATA   nValorMaximo              AS decimal
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WS_GUARDIAN_ListaFatoresCorrecaoTicket
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WS_GUARDIAN_ListaFatoresCorrecaoTicket
Return

WSMETHOD CLONE WSCLIENT WS_GUARDIAN_ListaFatoresCorrecaoTicket
	Local oClone := WS_GUARDIAN_ListaFatoresCorrecaoTicket():NEW()
	oClone:nNumero              := ::nNumero
	oClone:cDescricao           := ::cDescricao
	oClone:cData                := ::cData
	oClone:nEstado              := ::nEstado
	oClone:cCodigoItem          := ::cCodigoItem
	oClone:cCodigo              := ::cCodigo
	oClone:nFator               := ::nFator
	oClone:nValorMinimo         := ::nValorMinimo
	oClone:nValorMaximo         := ::nValorMaximo
Return oClone

WSMETHOD SOAPSEND WSCLIENT WS_GUARDIAN_ListaFatoresCorrecaoTicket
	Local cSoap := ""
	cSoap += WSSoapValue("Numero", ::nNumero, ::nNumero , "int", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Descricao", ::cDescricao, ::cDescricao , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Data", ::cData, ::cData , "dateTime", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Estado", ::nEstado, ::nEstado , "int", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CodigoItem", ::cCodigoItem, ::cCodigoItem , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Codigo", ::cCodigo, ::cCodigo , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Fator", ::nFator, ::nFator , "decimal", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ValorMinimo", ::nValorMinimo, ::nValorMinimo , "decimal", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ValorMaximo", ::nValorMaximo, ::nValorMaximo , "decimal", .T. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WS_GUARDIAN_ListaFatoresCorrecaoTicket
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::nNumero            :=  WSAdvValue( oResponse,"_NUMERO","int",NIL,"Property nNumero as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cDescricao         :=  WSAdvValue( oResponse,"_DESCRICAO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cData              :=  WSAdvValue( oResponse,"_DATA","dateTime",NIL,"Property cData as s:dateTime on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::nEstado            :=  WSAdvValue( oResponse,"_ESTADO","int",NIL,"Property nEstado as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cCodigoItem        :=  WSAdvValue( oResponse,"_CODIGOITEM","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cCodigo            :=  WSAdvValue( oResponse,"_CODIGO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nFator             :=  WSAdvValue( oResponse,"_FATOR","decimal",NIL,"Property nFator as s:decimal on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nValorMinimo       :=  WSAdvValue( oResponse,"_VALORMINIMO","decimal",NIL,"Property nValorMinimo as s:decimal on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nValorMaximo       :=  WSAdvValue( oResponse,"_VALORMAXIMO","decimal",NIL,"Property nValorMaximo as s:decimal on SOAP Response not found.",NIL,"N",NIL,NIL) 
Return

// WSDL Data Structure CampoAdicionalTicket

WSSTRUCT WS_GUARDIAN_CampoAdicionalTicket
	WSDATA   nNumero                   AS int
	WSDATA   cValor                    AS string OPTIONAL
	WSDATA   cCodigo                   AS string OPTIONAL
	WSDATA   cData                     AS dateTime
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WS_GUARDIAN_CampoAdicionalTicket
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WS_GUARDIAN_CampoAdicionalTicket
Return

WSMETHOD CLONE WSCLIENT WS_GUARDIAN_CampoAdicionalTicket
	Local oClone := WS_GUARDIAN_CampoAdicionalTicket():NEW()
	oClone:nNumero              := ::nNumero
	oClone:cValor               := ::cValor
	oClone:cCodigo              := ::cCodigo
	oClone:cData                := ::cData
Return oClone

WSMETHOD SOAPSEND WSCLIENT WS_GUARDIAN_CampoAdicionalTicket
	Local cSoap := ""
	cSoap += WSSoapValue("Numero", ::nNumero, ::nNumero , "int", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Valor", ::cValor, ::cValor , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Codigo", ::cCodigo, ::cCodigo , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Data", ::cData, ::cData , "dateTime", .T. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WS_GUARDIAN_CampoAdicionalTicket
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::nNumero            :=  WSAdvValue( oResponse,"_NUMERO","int",NIL,"Property nNumero as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cValor             :=  WSAdvValue( oResponse,"_VALOR","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cCodigo            :=  WSAdvValue( oResponse,"_CODIGO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cData              :=  WSAdvValue( oResponse,"_DATA","dateTime",NIL,"Property cData as s:dateTime on SOAP Response not found.",NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure EmbalagensTicket

WSSTRUCT WS_GUARDIAN_EmbalagensTicket
	WSDATA   cCodigo                   AS string OPTIONAL
	WSDATA   cData                     AS dateTime
	WSDATA   nPeso                     AS decimal
	WSDATA   nQuantidade               AS decimal
	WSDATA   nSequencial               AS int
	WSDATA   nSequencialItem           AS int
	WSDATA   nSequencialTck            AS int
	WSDATA   nCodigoTck                AS int
	WSDATA   cCodigoItem               AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WS_GUARDIAN_EmbalagensTicket
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WS_GUARDIAN_EmbalagensTicket
Return

WSMETHOD CLONE WSCLIENT WS_GUARDIAN_EmbalagensTicket
	Local oClone := WS_GUARDIAN_EmbalagensTicket():NEW()
	oClone:cCodigo              := ::cCodigo
	oClone:cData                := ::cData
	oClone:nPeso                := ::nPeso
	oClone:nQuantidade          := ::nQuantidade
	oClone:nSequencial          := ::nSequencial
	oClone:nSequencialItem      := ::nSequencialItem
	oClone:nSequencialTck       := ::nSequencialTck
	oClone:nCodigoTck           := ::nCodigoTck
	oClone:cCodigoItem          := ::cCodigoItem
Return oClone

WSMETHOD SOAPSEND WSCLIENT WS_GUARDIAN_EmbalagensTicket
	Local cSoap := ""
	cSoap += WSSoapValue("Codigo", ::cCodigo, ::cCodigo , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Data", ::cData, ::cData , "dateTime", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Peso", ::nPeso, ::nPeso , "decimal", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Quantidade", ::nQuantidade, ::nQuantidade , "decimal", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Sequencial", ::nSequencial, ::nSequencial , "int", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("SequencialItem", ::nSequencialItem, ::nSequencialItem , "int", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("SequencialTck", ::nSequencialTck, ::nSequencialTck , "int", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CodigoTck", ::nCodigoTck, ::nCodigoTck , "int", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CodigoItem", ::cCodigoItem, ::cCodigoItem , "string", .F. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

// WSDL Data Structure ConteinerVO

WSSTRUCT WS_GUARDIAN_ConteinerVO
	WSDATA   nSequencial               AS int
	WSDATA   cDescricao                AS string OPTIONAL
	WSDATA   cConteiner                AS string OPTIONAL
	WSDATA   cData                     AS dateTime
	WSDATA   nTicketSequencial         AS int
	WSDATA   cCodigo                   AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WS_GUARDIAN_ConteinerVO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WS_GUARDIAN_ConteinerVO
Return

WSMETHOD CLONE WSCLIENT WS_GUARDIAN_ConteinerVO
	Local oClone := WS_GUARDIAN_ConteinerVO():NEW()
	oClone:nSequencial          := ::nSequencial
	oClone:cDescricao           := ::cDescricao
	oClone:cConteiner           := ::cConteiner
	oClone:cData                := ::cData
	oClone:nTicketSequencial    := ::nTicketSequencial
	oClone:cCodigo              := ::cCodigo
Return oClone

WSMETHOD SOAPSEND WSCLIENT WS_GUARDIAN_ConteinerVO
	Local cSoap := ""
	cSoap += WSSoapValue("Sequencial", ::nSequencial, ::nSequencial , "int", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Descricao", ::cDescricao, ::cDescricao , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Conteiner", ::cConteiner, ::cConteiner , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Data", ::cData, ::cData , "dateTime", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("TicketSequencial", ::nTicketSequencial, ::nTicketSequencial , "int", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Codigo", ::cCodigo, ::cCodigo , "string", .F. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WS_GUARDIAN_ConteinerVO
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::nSequencial        :=  WSAdvValue( oResponse,"_SEQUENCIAL","int",NIL,"Property nSequencial as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cDescricao         :=  WSAdvValue( oResponse,"_DESCRICAO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cConteiner         :=  WSAdvValue( oResponse,"_CONTEINER","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cData              :=  WSAdvValue( oResponse,"_DATA","dateTime",NIL,"Property cData as s:dateTime on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::nTicketSequencial  :=  WSAdvValue( oResponse,"_TICKETSEQUENCIAL","int",NIL,"Property nTicketSequencial as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cCodigo            :=  WSAdvValue( oResponse,"_CODIGO","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure PontoDoFluxo

WSSTRUCT WS_GUARDIAN_PontoDoFluxo
	WSDATA   nSequencia                AS int
	WSDATA   cCodigoOperacao           AS string OPTIONAL
	WSDATA   cEstacaoControle          AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WS_GUARDIAN_PontoDoFluxo
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WS_GUARDIAN_PontoDoFluxo
Return

WSMETHOD CLONE WSCLIENT WS_GUARDIAN_PontoDoFluxo
	Local oClone := WS_GUARDIAN_PontoDoFluxo():NEW()
	oClone:nSequencia           := ::nSequencia
	oClone:cCodigoOperacao      := ::cCodigoOperacao
	oClone:cEstacaoControle     := ::cEstacaoControle
Return oClone

WSMETHOD SOAPSEND WSCLIENT WS_GUARDIAN_PontoDoFluxo
	Local cSoap := ""
	cSoap += WSSoapValue("Sequencia", ::nSequencia, ::nSequencia , "int", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CodigoOperacao", ::cCodigoOperacao, ::cCodigoOperacao , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("EstacaoControle", ::cEstacaoControle, ::cEstacaoControle , "string", .F. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

// WSDL Data Structure ArrayOfETransportadora

WSSTRUCT WS_GUARDIAN_ArrayOfETransportadora
	WSDATA   oWSETransportadora        AS WS_GUARDIAN_ETransportadora OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WS_GUARDIAN_ArrayOfETransportadora
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WS_GUARDIAN_ArrayOfETransportadora
	::oWSETransportadora   := {} // Array Of  WS_GUARDIAN_ETRANSPORTADORA():New()
Return

WSMETHOD CLONE WSCLIENT WS_GUARDIAN_ArrayOfETransportadora
	Local oClone := WS_GUARDIAN_ArrayOfETransportadora():NEW()
	oClone:oWSETransportadora := NIL
	If ::oWSETransportadora <> NIL 
		oClone:oWSETransportadora := {}
		aEval( ::oWSETransportadora , { |x| aadd( oClone:oWSETransportadora , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WS_GUARDIAN_ArrayOfETransportadora
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_ETRANSPORTADORA","ETransportadora",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSETransportadora , WS_GUARDIAN_ETransportadora():New() )
			::oWSETransportadora[len(::oWSETransportadora)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure EItem

WSSTRUCT WS_GUARDIAN_EItem
	WSDATA   nTipo                     AS int
	WSDATA   cNome                     AS string OPTIONAL
	WSDATA   cInformacao               AS string OPTIONAL
	WSDATA   nPesoUnitario             AS decimal
	WSDATA   cUnidadeMedida            AS string OPTIONAL
	WSDATA   lPodeConverter            AS boolean
	WSDATA   nFatorConversao           AS decimal
	WSDATA   cUnidadeMedidaConversao   AS string OPTIONAL
	WSDATA   lUtilizaContador          AS boolean
	WSDATA   nInicioContador           AS int
	WSDATA   nFinalContador            AS int
	WSDATA   nPrefixoContador          AS int
	WSDATA   nValorAtualContador       AS int
	WSDATA   cData                     AS dateTime
	WSDATA   nEstado                   AS int
	WSDATA   nFatorCorrecao            AS int
	WSDATA   cCodigoFatorCorrecao      AS string OPTIONAL
	WSDATA   nFluxo                    AS int
	WSDATA   cCodigoFluxo              AS string OPTIONAL
	WSDATA   lInicialObrigatoria       AS boolean
	WSDATA   nQuantidadeViasRelatorioImpressas AS int
	WSDATA   nRecebimentoToleranciaNegativa AS decimal
	WSDATA   nRecebimentoToleranciaPositiva AS decimal
	WSDATA   nExpedicaoToleranciaNegativa AS decimal
	WSDATA   nExpedicaoToleranciaPositiva AS decimal
	WSDATA   nTipoVerificacaoPesoOrigem AS int
	WSDATA   oWSEmissoresFatoresItem   AS WS_GUARDIAN_ArrayOfEItemEmissorFator OPTIONAL
	WSDATA   oWSEmissores              AS WS_GUARDIAN_ArrayOfEEmissor OPTIONAL
	WSDATA   oWSGestores               AS WS_GUARDIAN_ArrayOfEUsuario OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WS_GUARDIAN_EItem
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WS_GUARDIAN_EItem
Return

WSMETHOD CLONE WSCLIENT WS_GUARDIAN_EItem
	Local oClone := WS_GUARDIAN_EItem():NEW()
	oClone:nTipo                := ::nTipo
	oClone:cNome                := ::cNome
	oClone:cInformacao          := ::cInformacao
	oClone:nPesoUnitario        := ::nPesoUnitario
	oClone:cUnidadeMedida       := ::cUnidadeMedida
	oClone:lPodeConverter       := ::lPodeConverter
	oClone:nFatorConversao      := ::nFatorConversao
	oClone:cUnidadeMedidaConversao := ::cUnidadeMedidaConversao
	oClone:lUtilizaContador     := ::lUtilizaContador
	oClone:nInicioContador      := ::nInicioContador
	oClone:nFinalContador       := ::nFinalContador
	oClone:nPrefixoContador     := ::nPrefixoContador
	oClone:nValorAtualContador  := ::nValorAtualContador
	oClone:cData                := ::cData
	oClone:nEstado              := ::nEstado
	oClone:nFatorCorrecao       := ::nFatorCorrecao
	oClone:cCodigoFatorCorrecao := ::cCodigoFatorCorrecao
	oClone:nFluxo               := ::nFluxo
	oClone:cCodigoFluxo         := ::cCodigoFluxo
	oClone:lInicialObrigatoria  := ::lInicialObrigatoria
	oClone:nQuantidadeViasRelatorioImpressas := ::nQuantidadeViasRelatorioImpressas
	oClone:nRecebimentoToleranciaNegativa := ::nRecebimentoToleranciaNegativa
	oClone:nRecebimentoToleranciaPositiva := ::nRecebimentoToleranciaPositiva
	oClone:nExpedicaoToleranciaNegativa := ::nExpedicaoToleranciaNegativa
	oClone:nExpedicaoToleranciaPositiva := ::nExpedicaoToleranciaPositiva
	oClone:nTipoVerificacaoPesoOrigem := ::nTipoVerificacaoPesoOrigem
	oClone:oWSEmissoresFatoresItem := IIF(::oWSEmissoresFatoresItem = NIL , NIL , ::oWSEmissoresFatoresItem:Clone() )
	oClone:oWSEmissores         := IIF(::oWSEmissores = NIL , NIL , ::oWSEmissores:Clone() )
	oClone:oWSGestores          := IIF(::oWSGestores = NIL , NIL , ::oWSGestores:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WS_GUARDIAN_EItem
	Local oNode27
	Local oNode28
	Local oNode29
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::nTipo              :=  WSAdvValue( oResponse,"_TIPO","int",NIL,"Property nTipo as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cNome              :=  WSAdvValue( oResponse,"_NOME","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cInformacao        :=  WSAdvValue( oResponse,"_INFORMACAO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nPesoUnitario      :=  WSAdvValue( oResponse,"_PESOUNITARIO","decimal",NIL,"Property nPesoUnitario as s:decimal on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cUnidadeMedida     :=  WSAdvValue( oResponse,"_UNIDADEMEDIDA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::lPodeConverter     :=  WSAdvValue( oResponse,"_PODECONVERTER","boolean",NIL,"Property lPodeConverter as s:boolean on SOAP Response not found.",NIL,"L",NIL,NIL) 
	::nFatorConversao    :=  WSAdvValue( oResponse,"_FATORCONVERSAO","decimal",NIL,"Property nFatorConversao as s:decimal on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cUnidadeMedidaConversao :=  WSAdvValue( oResponse,"_UNIDADEMEDIDACONVERSAO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::lUtilizaContador   :=  WSAdvValue( oResponse,"_UTILIZACONTADOR","boolean",NIL,"Property lUtilizaContador as s:boolean on SOAP Response not found.",NIL,"L",NIL,NIL) 
	::nInicioContador    :=  WSAdvValue( oResponse,"_INICIOCONTADOR","int",NIL,"Property nInicioContador as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nFinalContador     :=  WSAdvValue( oResponse,"_FINALCONTADOR","int",NIL,"Property nFinalContador as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nPrefixoContador   :=  WSAdvValue( oResponse,"_PREFIXOCONTADOR","int",NIL,"Property nPrefixoContador as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nValorAtualContador :=  WSAdvValue( oResponse,"_VALORATUALCONTADOR","int",NIL,"Property nValorAtualContador as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cData              :=  WSAdvValue( oResponse,"_DATA","dateTime",NIL,"Property cData as s:dateTime on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::nEstado            :=  WSAdvValue( oResponse,"_ESTADO","int",NIL,"Property nEstado as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nFatorCorrecao     :=  WSAdvValue( oResponse,"_FATORCORRECAO","int",NIL,"Property nFatorCorrecao as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cCodigoFatorCorrecao :=  WSAdvValue( oResponse,"_CODIGOFATORCORRECAO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nFluxo             :=  WSAdvValue( oResponse,"_FLUXO","int",NIL,"Property nFluxo as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cCodigoFluxo       :=  WSAdvValue( oResponse,"_CODIGOFLUXO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::lInicialObrigatoria :=  WSAdvValue( oResponse,"_INICIALOBRIGATORIA","boolean",NIL,"Property lInicialObrigatoria as s:boolean on SOAP Response not found.",NIL,"L",NIL,NIL) 
	::nQuantidadeViasRelatorioImpressas :=  WSAdvValue( oResponse,"_QUANTIDADEVIASRELATORIOIMPRESSAS","int",NIL,"Property nQuantidadeViasRelatorioImpressas as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nRecebimentoToleranciaNegativa :=  WSAdvValue( oResponse,"_RECEBIMENTOTOLERANCIANEGATIVA","decimal",NIL,"Property nRecebimentoToleranciaNegativa as s:decimal on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nRecebimentoToleranciaPositiva :=  WSAdvValue( oResponse,"_RECEBIMENTOTOLERANCIAPOSITIVA","decimal",NIL,"Property nRecebimentoToleranciaPositiva as s:decimal on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nExpedicaoToleranciaNegativa :=  WSAdvValue( oResponse,"_EXPEDICAOTOLERANCIANEGATIVA","decimal",NIL,"Property nExpedicaoToleranciaNegativa as s:decimal on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nExpedicaoToleranciaPositiva :=  WSAdvValue( oResponse,"_EXPEDICAOTOLERANCIAPOSITIVA","decimal",NIL,"Property nExpedicaoToleranciaPositiva as s:decimal on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nTipoVerificacaoPesoOrigem :=  WSAdvValue( oResponse,"_TIPOVERIFICACAOPESOORIGEM","int",NIL,"Property nTipoVerificacaoPesoOrigem as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	oNode27 :=  WSAdvValue( oResponse,"_EMISSORESFATORESITEM","ArrayOfEItemEmissorFator",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode27 != NIL
		::oWSEmissoresFatoresItem := WS_GUARDIAN_ArrayOfEItemEmissorFator():New()
		::oWSEmissoresFatoresItem:SoapRecv(oNode27)
	EndIf
	oNode28 :=  WSAdvValue( oResponse,"_EMISSORES","ArrayOfEEmissor",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode28 != NIL
		::oWSEmissores := WS_GUARDIAN_ArrayOfEEmissor():New()
		::oWSEmissores:SoapRecv(oNode28)
	EndIf
	oNode29 :=  WSAdvValue( oResponse,"_GESTORES","ArrayOfEUsuario",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode29 != NIL
		::oWSGestores := WS_GUARDIAN_ArrayOfEUsuario():New()
		::oWSGestores:SoapRecv(oNode29)
	EndIf
Return

// WSDL Data Structure ItemTicket

WSSTRUCT WS_GUARDIAN_ItemTicket
	WSDATA   cCodigo                   AS string OPTIONAL
	WSDATA   nSequencial               AS int
	WSDATA   nSequencialTck            AS int
	WSDATA   cCodigoTck                AS string OPTIONAL
	WSDATA   nSequencialItm            AS int
	WSDATA   cCodigoItm                AS string OPTIONAL
	WSDATA   nEstado                   AS int
	WSDATA   cData                     AS dateTime
	WSDATA   cSequencialLot            AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WS_GUARDIAN_ItemTicket
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WS_GUARDIAN_ItemTicket
Return

WSMETHOD CLONE WSCLIENT WS_GUARDIAN_ItemTicket
	Local oClone := WS_GUARDIAN_ItemTicket():NEW()
	oClone:cCodigo              := ::cCodigo
	oClone:nSequencial          := ::nSequencial
	oClone:nSequencialTck       := ::nSequencialTck
	oClone:cCodigoTck           := ::cCodigoTck
	oClone:nSequencialItm       := ::nSequencialItm
	oClone:cCodigoItm           := ::cCodigoItm
	oClone:nEstado              := ::nEstado
	oClone:cData                := ::cData
	oClone:cSequencialLot       := ::cSequencialLot
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WS_GUARDIAN_ItemTicket
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cCodigo            :=  WSAdvValue( oResponse,"_CODIGO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nSequencial        :=  WSAdvValue( oResponse,"_SEQUENCIAL","int",NIL,"Property nSequencial as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nSequencialTck     :=  WSAdvValue( oResponse,"_SEQUENCIALTCK","int",NIL,"Property nSequencialTck as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cCodigoTck         :=  WSAdvValue( oResponse,"_CODIGOTCK","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nSequencialItm     :=  WSAdvValue( oResponse,"_SEQUENCIALITM","int",NIL,"Property nSequencialItm as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cCodigoItm         :=  WSAdvValue( oResponse,"_CODIGOITM","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nEstado            :=  WSAdvValue( oResponse,"_ESTADO","int",NIL,"Property nEstado as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cData              :=  WSAdvValue( oResponse,"_DATA","dateTime",NIL,"Property cData as s:dateTime on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cSequencialLot     :=  WSAdvValue( oResponse,"_SEQUENCIALLOT","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure OperacaoTicket

WSSTRUCT WS_GUARDIAN_OperacaoTicket
	WSDATA   cCodigo                   AS string OPTIONAL
	WSDATA   cTicketSequencial         AS string OPTIONAL
	WSDATA   cPlacaVeiculo             AS string OPTIONAL
	WSDATA   oWSMotorista              AS WS_GUARDIAN_EMotorista OPTIONAL
	WSDATA   cUnidadeAposConversao     AS string OPTIONAL
	WSDATA   cTipoVeiculo              AS string OPTIONAL
	WSDATA   nEixo                     AS int
	WSDATA   nCompartimento            AS int
	WSDATA   nFatorCorrecaoLista       AS decimal
	WSDATA   nFatorCorrecaoCalculo     AS decimal
	WSDATA   nPeso                     AS decimal
	WSDATA   nTaraTotal                AS decimal
	WSDATA   nFatorConversao           AS decimal
	WSDATA   nPesoLiqObtido            AS decimal
	WSDATA   nPesoLiqCorrigido         AS decimal
	WSDATA   nPesoLiqCorrigidoCalculo  AS decimal
	WSDATA   nPesoLiqConvertido        AS decimal
	WSDATA   nPesoBrutoVeiculo         AS decimal
	WSDATA   cUsuarioLogin             AS string OPTIONAL
	WSDATA   cDataPesagem              AS dateTime
	WSDATA   nPeriferico               AS int
	WSDATA   cPerifericoCodigo         AS string OPTIONAL
	WSDATA   cEstacaoControle          AS string OPTIONAL
	WSDATA   cPontoDeControle          AS string OPTIONAL
	WSDATA   nTipoOperacaoCodigo       AS int
	WSDATA   cTipoOperacaoDescricao    AS string OPTIONAL
	WSDATA   cOperacaoCodigo           AS string OPTIONAL
	WSDATA   nEstado                   AS int
	WSDATA   cDataIdentificacao        AS dateTime
	WSDATA   oWSIdentificadoresAdicionais AS WS_GUARDIAN_ArrayOfIdentificadorAdicional OPTIONAL
	WSDATA   oWSEixos                  AS WS_GUARDIAN_ArrayOfEixoOperacao OPTIONAL
	WSDATA   oWSErrosOperacoesTicket   AS WS_GUARDIAN_ArrayOfErrosOperacoesTicket OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WS_GUARDIAN_OperacaoTicket
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WS_GUARDIAN_OperacaoTicket
Return

WSMETHOD CLONE WSCLIENT WS_GUARDIAN_OperacaoTicket
	Local oClone := WS_GUARDIAN_OperacaoTicket():NEW()
	oClone:cCodigo              := ::cCodigo
	oClone:cTicketSequencial    := ::cTicketSequencial
	oClone:cPlacaVeiculo        := ::cPlacaVeiculo
	oClone:oWSMotorista         := IIF(::oWSMotorista = NIL , NIL , ::oWSMotorista:Clone() )
	oClone:cUnidadeAposConversao := ::cUnidadeAposConversao
	oClone:cTipoVeiculo         := ::cTipoVeiculo
	oClone:nEixo                := ::nEixo
	oClone:nCompartimento       := ::nCompartimento
	oClone:nFatorCorrecaoLista  := ::nFatorCorrecaoLista
	oClone:nFatorCorrecaoCalculo := ::nFatorCorrecaoCalculo
	oClone:nPeso                := ::nPeso
	oClone:nTaraTotal           := ::nTaraTotal
	oClone:nFatorConversao      := ::nFatorConversao
	oClone:nPesoLiqObtido       := ::nPesoLiqObtido
	oClone:nPesoLiqCorrigido    := ::nPesoLiqCorrigido
	oClone:nPesoLiqCorrigidoCalculo := ::nPesoLiqCorrigidoCalculo
	oClone:nPesoLiqConvertido   := ::nPesoLiqConvertido
	oClone:nPesoBrutoVeiculo    := ::nPesoBrutoVeiculo
	oClone:cUsuarioLogin        := ::cUsuarioLogin
	oClone:cDataPesagem         := ::cDataPesagem
	oClone:nPeriferico          := ::nPeriferico
	oClone:cPerifericoCodigo    := ::cPerifericoCodigo
	oClone:cEstacaoControle     := ::cEstacaoControle
	oClone:cPontoDeControle     := ::cPontoDeControle
	oClone:nTipoOperacaoCodigo  := ::nTipoOperacaoCodigo
	oClone:cTipoOperacaoDescricao := ::cTipoOperacaoDescricao
	oClone:cOperacaoCodigo      := ::cOperacaoCodigo
	oClone:nEstado              := ::nEstado
	oClone:cDataIdentificacao   := ::cDataIdentificacao
	oClone:oWSIdentificadoresAdicionais := IIF(::oWSIdentificadoresAdicionais = NIL , NIL , ::oWSIdentificadoresAdicionais:Clone() )
	oClone:oWSEixos             := IIF(::oWSEixos = NIL , NIL , ::oWSEixos:Clone() )
	oClone:oWSErrosOperacoesTicket := IIF(::oWSErrosOperacoesTicket = NIL , NIL , ::oWSErrosOperacoesTicket:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WS_GUARDIAN_OperacaoTicket
	Local oNode4
	Local oNode30
	Local oNode31
	Local oNode32
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cCodigo            :=  WSAdvValue( oResponse,"_CODIGO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cTicketSequencial  :=  WSAdvValue( oResponse,"_TICKETSEQUENCIAL","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cPlacaVeiculo      :=  WSAdvValue( oResponse,"_PLACAVEICULO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	oNode4 :=  WSAdvValue( oResponse,"_MOTORISTA","EMotorista",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode4 != NIL
		::oWSMotorista := WS_GUARDIAN_EMotorista():New()
		::oWSMotorista:SoapRecv(oNode4)
	EndIf
	::cUnidadeAposConversao :=  WSAdvValue( oResponse,"_UNIDADEAPOSCONVERSAO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cTipoVeiculo       :=  WSAdvValue( oResponse,"_TIPOVEICULO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nEixo              :=  WSAdvValue( oResponse,"_EIXO","int",NIL,"Property nEixo as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nCompartimento     :=  WSAdvValue( oResponse,"_COMPARTIMENTO","int",NIL,"Property nCompartimento as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nFatorCorrecaoLista :=  WSAdvValue( oResponse,"_FATORCORRECAOLISTA","decimal",NIL,"Property nFatorCorrecaoLista as s:decimal on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nFatorCorrecaoCalculo :=  WSAdvValue( oResponse,"_FATORCORRECAOCALCULO","decimal",NIL,"Property nFatorCorrecaoCalculo as s:decimal on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nPeso              :=  WSAdvValue( oResponse,"_PESO","decimal",NIL,"Property nPeso as s:decimal on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nTaraTotal         :=  WSAdvValue( oResponse,"_TARATOTAL","decimal",NIL,"Property nTaraTotal as s:decimal on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nFatorConversao    :=  WSAdvValue( oResponse,"_FATORCONVERSAO","decimal",NIL,"Property nFatorConversao as s:decimal on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nPesoLiqObtido     :=  WSAdvValue( oResponse,"_PESOLIQOBTIDO","decimal",NIL,"Property nPesoLiqObtido as s:decimal on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nPesoLiqCorrigido  :=  WSAdvValue( oResponse,"_PESOLIQCORRIGIDO","decimal",NIL,"Property nPesoLiqCorrigido as s:decimal on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nPesoLiqCorrigidoCalculo :=  WSAdvValue( oResponse,"_PESOLIQCORRIGIDOCALCULO","decimal",NIL,"Property nPesoLiqCorrigidoCalculo as s:decimal on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nPesoLiqConvertido :=  WSAdvValue( oResponse,"_PESOLIQCONVERTIDO","decimal",NIL,"Property nPesoLiqConvertido as s:decimal on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nPesoBrutoVeiculo  :=  WSAdvValue( oResponse,"_PESOBRUTOVEICULO","decimal",NIL,"Property nPesoBrutoVeiculo as s:decimal on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cUsuarioLogin      :=  WSAdvValue( oResponse,"_USUARIOLOGIN","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cDataPesagem       :=  WSAdvValue( oResponse,"_DATAPESAGEM","dateTime",NIL,"Property cDataPesagem as s:dateTime on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::nPeriferico        :=  WSAdvValue( oResponse,"_PERIFERICO","int",NIL,"Property nPeriferico as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cPerifericoCodigo  :=  WSAdvValue( oResponse,"_PERIFERICOCODIGO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cEstacaoControle   :=  WSAdvValue( oResponse,"_ESTACAOCONTROLE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cPontoDeControle   :=  WSAdvValue( oResponse,"_PONTODECONTROLE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nTipoOperacaoCodigo :=  WSAdvValue( oResponse,"_TIPOOPERACAOCODIGO","int",NIL,"Property nTipoOperacaoCodigo as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cTipoOperacaoDescricao :=  WSAdvValue( oResponse,"_TIPOOPERACAODESCRICAO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cOperacaoCodigo    :=  WSAdvValue( oResponse,"_OPERACAOCODIGO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nEstado            :=  WSAdvValue( oResponse,"_ESTADO","int",NIL,"Property nEstado as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cDataIdentificacao :=  WSAdvValue( oResponse,"_DATAIDENTIFICACAO","dateTime",NIL,"Property cDataIdentificacao as s:dateTime on SOAP Response not found.",NIL,"S",NIL,NIL) 
	oNode30 :=  WSAdvValue( oResponse,"_IDENTIFICADORESADICIONAIS","ArrayOfIdentificadorAdicional",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode30 != NIL
		::oWSIdentificadoresAdicionais := WS_GUARDIAN_ArrayOfIdentificadorAdicional():New()
		::oWSIdentificadoresAdicionais:SoapRecv(oNode30)
	EndIf
	oNode31 :=  WSAdvValue( oResponse,"_EIXOS","ArrayOfEixoOperacao",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode31 != NIL
		::oWSEixos := WS_GUARDIAN_ArrayOfEixoOperacao():New()
		::oWSEixos:SoapRecv(oNode31)
	EndIf
	oNode32 :=  WSAdvValue( oResponse,"_ERROSOPERACOESTICKET","ArrayOfErrosOperacoesTicket",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode32 != NIL
		::oWSErrosOperacoesTicket := WS_GUARDIAN_ArrayOfErrosOperacoesTicket():New()
		::oWSErrosOperacoesTicket:SoapRecv(oNode32)
	EndIf
Return

// WSDL Data Structure ReimpressoesTicket

WSSTRUCT WS_GUARDIAN_ReimpressoesTicket
	WSDATA   cCodigo                   AS string OPTIONAL
	WSDATA   nSequencial               AS int
	WSDATA   nSequencialTck            AS int
	WSDATA   cData                     AS dateTime
	WSDATA   cObservacao               AS string OPTIONAL
	WSDATA   nSequencialUsuario        AS int
	WSDATA   cCodigoUsuario            AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WS_GUARDIAN_ReimpressoesTicket
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WS_GUARDIAN_ReimpressoesTicket
Return

WSMETHOD CLONE WSCLIENT WS_GUARDIAN_ReimpressoesTicket
	Local oClone := WS_GUARDIAN_ReimpressoesTicket():NEW()
	oClone:cCodigo              := ::cCodigo
	oClone:nSequencial          := ::nSequencial
	oClone:nSequencialTck       := ::nSequencialTck
	oClone:cData                := ::cData
	oClone:cObservacao          := ::cObservacao
	oClone:nSequencialUsuario   := ::nSequencialUsuario
	oClone:cCodigoUsuario       := ::cCodigoUsuario
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WS_GUARDIAN_ReimpressoesTicket
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cCodigo            :=  WSAdvValue( oResponse,"_CODIGO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nSequencial        :=  WSAdvValue( oResponse,"_SEQUENCIAL","int",NIL,"Property nSequencial as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nSequencialTck     :=  WSAdvValue( oResponse,"_SEQUENCIALTCK","int",NIL,"Property nSequencialTck as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cData              :=  WSAdvValue( oResponse,"_DATA","dateTime",NIL,"Property cData as s:dateTime on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cObservacao        :=  WSAdvValue( oResponse,"_OBSERVACAO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nSequencialUsuario :=  WSAdvValue( oResponse,"_SEQUENCIALUSUARIO","int",NIL,"Property nSequencialUsuario as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cCodigoUsuario     :=  WSAdvValue( oResponse,"_CODIGOUSUARIO","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure EEmbalagensTicket

WSSTRUCT WS_GUARDIAN_EEmbalagensTicket
	WSDATA   nTicket                   AS int
	WSDATA   nItem                     AS int
	WSDATA   nQuantidade               AS decimal
	WSDATA   nPeso                     AS decimal
	WSDATA   cData                     AS dateTime
	WSDATA   nemtCodigo                AS int
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WS_GUARDIAN_EEmbalagensTicket
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WS_GUARDIAN_EEmbalagensTicket
Return

WSMETHOD CLONE WSCLIENT WS_GUARDIAN_EEmbalagensTicket
	Local oClone := WS_GUARDIAN_EEmbalagensTicket():NEW()
	oClone:nTicket              := ::nTicket
	oClone:nItem                := ::nItem
	oClone:nQuantidade          := ::nQuantidade
	oClone:nPeso                := ::nPeso
	oClone:cData                := ::cData
	oClone:nemtCodigo           := ::nemtCodigo
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WS_GUARDIAN_EEmbalagensTicket
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::nTicket            :=  WSAdvValue( oResponse,"_TICKET","int",NIL,"Property nTicket as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nItem              :=  WSAdvValue( oResponse,"_ITEM","int",NIL,"Property nItem as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nQuantidade        :=  WSAdvValue( oResponse,"_QUANTIDADE","decimal",NIL,"Property nQuantidade as s:decimal on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nPeso              :=  WSAdvValue( oResponse,"_PESO","decimal",NIL,"Property nPeso as s:decimal on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cData              :=  WSAdvValue( oResponse,"_DATA","dateTime",NIL,"Property cData as s:dateTime on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::nemtCodigo         :=  WSAdvValue( oResponse,"_EMTCODIGO","int",NIL,"Property nemtCodigo as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
Return

// WSDL Data Structure FluxoTicketSequencia

WSSTRUCT WS_GUARDIAN_FluxoTicketSequencia
	WSDATA   cCodigo                   AS string OPTIONAL
	WSDATA   lNovoRegistro             AS boolean
	WSDATA   nSequencial               AS int
	WSDATA   nSequenciaFluxo           AS int
	WSDATA   nSeqTicket                AS int
	WSDATA   oWSListaFluxoTicketOperacaoEstacaoControle AS WS_GUARDIAN_ArrayOfFluxoTicketOperacaoEstacaoControle OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WS_GUARDIAN_FluxoTicketSequencia
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WS_GUARDIAN_FluxoTicketSequencia
Return

WSMETHOD CLONE WSCLIENT WS_GUARDIAN_FluxoTicketSequencia
	Local oClone := WS_GUARDIAN_FluxoTicketSequencia():NEW()
	oClone:cCodigo              := ::cCodigo
	oClone:lNovoRegistro        := ::lNovoRegistro
	oClone:nSequencial          := ::nSequencial
	oClone:nSequenciaFluxo      := ::nSequenciaFluxo
	oClone:nSeqTicket           := ::nSeqTicket
	oClone:oWSListaFluxoTicketOperacaoEstacaoControle := IIF(::oWSListaFluxoTicketOperacaoEstacaoControle = NIL , NIL , ::oWSListaFluxoTicketOperacaoEstacaoControle:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WS_GUARDIAN_FluxoTicketSequencia
	Local oNode6
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cCodigo            :=  WSAdvValue( oResponse,"_CODIGO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::lNovoRegistro      :=  WSAdvValue( oResponse,"_NOVOREGISTRO","boolean",NIL,"Property lNovoRegistro as s:boolean on SOAP Response not found.",NIL,"L",NIL,NIL) 
	::nSequencial        :=  WSAdvValue( oResponse,"_SEQUENCIAL","int",NIL,"Property nSequencial as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nSequenciaFluxo    :=  WSAdvValue( oResponse,"_SEQUENCIAFLUXO","int",NIL,"Property nSequenciaFluxo as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nSeqTicket         :=  WSAdvValue( oResponse,"_SEQTICKET","int",NIL,"Property nSeqTicket as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	oNode6 :=  WSAdvValue( oResponse,"_LISTAFLUXOTICKETOPERACAOESTACAOCONTROLE","ArrayOfFluxoTicketOperacaoEstacaoControle",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode6 != NIL
		::oWSListaFluxoTicketOperacaoEstacaoControle := WS_GUARDIAN_ArrayOfFluxoTicketOperacaoEstacaoControle():New()
		::oWSListaFluxoTicketOperacaoEstacaoControle:SoapRecv(oNode6)
	EndIf
Return

// WSDL Data Structure IntegracaoOCR

WSSTRUCT WS_GUARDIAN_IntegracaoOCR
	WSDATA   cCodigo                   AS string OPTIONAL
	WSDATA   nSequencial               AS long
	WSDATA   cPontoDeControle          AS string OPTIONAL
	WSDATA   cData                     AS dateTime
	WSDATA   cRegraDoOCR               AS string OPTIONAL
	WSDATA   cPlacaOCR                 AS string OPTIONAL
	WSDATA   nPlacaConvergente         AS int
	WSDATA   cCodigoOperacao           AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WS_GUARDIAN_IntegracaoOCR
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WS_GUARDIAN_IntegracaoOCR
Return

WSMETHOD CLONE WSCLIENT WS_GUARDIAN_IntegracaoOCR
	Local oClone := WS_GUARDIAN_IntegracaoOCR():NEW()
	oClone:cCodigo              := ::cCodigo
	oClone:nSequencial          := ::nSequencial
	oClone:cPontoDeControle     := ::cPontoDeControle
	oClone:cData                := ::cData
	oClone:cRegraDoOCR          := ::cRegraDoOCR
	oClone:cPlacaOCR            := ::cPlacaOCR
	oClone:nPlacaConvergente    := ::nPlacaConvergente
	oClone:cCodigoOperacao      := ::cCodigoOperacao
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WS_GUARDIAN_IntegracaoOCR
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cCodigo            :=  WSAdvValue( oResponse,"_CODIGO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nSequencial        :=  WSAdvValue( oResponse,"_SEQUENCIAL","long",NIL,"Property nSequencial as s:long on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cPontoDeControle   :=  WSAdvValue( oResponse,"_PONTODECONTROLE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cData              :=  WSAdvValue( oResponse,"_DATA","dateTime",NIL,"Property cData as s:dateTime on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cRegraDoOCR        :=  WSAdvValue( oResponse,"_REGRADOOCR","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cPlacaOCR          :=  WSAdvValue( oResponse,"_PLACAOCR","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nPlacaConvergente  :=  WSAdvValue( oResponse,"_PLACACONVERGENTE","int",NIL,"Property nPlacaConvergente as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cCodigoOperacao    :=  WSAdvValue( oResponse,"_CODIGOOPERACAO","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure ImportaDocumentoDoTicketG4

WSSTRUCT WS_GUARDIAN_ImportaDocumentoDoTicketG4
	WSDATA   nCompartimento            AS int
	WSDATA   cDescricao                AS string OPTIONAL
	WSDATA   cFlag                     AS string OPTIONAL
	WSDATA   nPeso                     AS float
	WSDATA   nTolerancia               AS float
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WS_GUARDIAN_ImportaDocumentoDoTicketG4
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WS_GUARDIAN_ImportaDocumentoDoTicketG4
Return

WSMETHOD CLONE WSCLIENT WS_GUARDIAN_ImportaDocumentoDoTicketG4
	Local oClone := WS_GUARDIAN_ImportaDocumentoDoTicketG4():NEW()
	oClone:nCompartimento       := ::nCompartimento
	oClone:cDescricao           := ::cDescricao
	oClone:cFlag                := ::cFlag
	oClone:nPeso                := ::nPeso
	oClone:nTolerancia          := ::nTolerancia
Return oClone

WSMETHOD SOAPSEND WSCLIENT WS_GUARDIAN_ImportaDocumentoDoTicketG4
	Local cSoap := ""
	cSoap += WSSoapValue("Compartimento", ::nCompartimento, ::nCompartimento , "int", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Descricao", ::cDescricao, ::cDescricao , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Flag", ::cFlag, ::cFlag , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Peso", ::nPeso, ::nPeso , "float", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Tolerancia", ::nTolerancia, ::nTolerancia , "float", .T. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

// WSDL Data Structure ImportaItemDoTicketG4

WSSTRUCT WS_GUARDIAN_ImportaItemDoTicketG4
	WSDATA   cCodItem                  AS string OPTIONAL
	WSDATA   cDescrItem                AS string OPTIONAL
	WSDATA   nCompartimento            AS int
	WSDATA   cFlag                     AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WS_GUARDIAN_ImportaItemDoTicketG4
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WS_GUARDIAN_ImportaItemDoTicketG4
Return

WSMETHOD CLONE WSCLIENT WS_GUARDIAN_ImportaItemDoTicketG4
	Local oClone := WS_GUARDIAN_ImportaItemDoTicketG4():NEW()
	oClone:cCodItem             := ::cCodItem
	oClone:cDescrItem           := ::cDescrItem
	oClone:nCompartimento       := ::nCompartimento
	oClone:cFlag                := ::cFlag
Return oClone

WSMETHOD SOAPSEND WSCLIENT WS_GUARDIAN_ImportaItemDoTicketG4
	Local cSoap := ""
	cSoap += WSSoapValue("CodItem", ::cCodItem, ::cCodItem , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("DescrItem", ::cDescrItem, ::cDescrItem , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Compartimento", ::nCompartimento, ::nCompartimento , "int", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("Flag", ::cFlag, ::cFlag , "string", .F. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

// WSDL Data Structure ExportaDocumentoDoTicketG4

WSSTRUCT WS_GUARDIAN_ExportaDocumentoDoTicketG4
	WSDATA   nCompartimento            AS int
	WSDATA   cDescricao                AS string OPTIONAL
	WSDATA   nPeso                     AS float
	WSDATA   nTolerancia               AS float
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WS_GUARDIAN_ExportaDocumentoDoTicketG4
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WS_GUARDIAN_ExportaDocumentoDoTicketG4
Return

WSMETHOD CLONE WSCLIENT WS_GUARDIAN_ExportaDocumentoDoTicketG4
	Local oClone := WS_GUARDIAN_ExportaDocumentoDoTicketG4():NEW()
	oClone:nCompartimento       := ::nCompartimento
	oClone:cDescricao           := ::cDescricao
	oClone:nPeso                := ::nPeso
	oClone:nTolerancia          := ::nTolerancia
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WS_GUARDIAN_ExportaDocumentoDoTicketG4
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::nCompartimento     :=  WSAdvValue( oResponse,"_COMPARTIMENTO","int",NIL,"Property nCompartimento as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cDescricao         :=  WSAdvValue( oResponse,"_DESCRICAO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nPeso              :=  WSAdvValue( oResponse,"_PESO","float",NIL,"Property nPeso as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nTolerancia        :=  WSAdvValue( oResponse,"_TOLERANCIA","float",NIL,"Property nTolerancia as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
Return

// WSDL Data Structure ExportaItemDoTicketG4

WSSTRUCT WS_GUARDIAN_ExportaItemDoTicketG4
	WSDATA   cCodItem                  AS string OPTIONAL
	WSDATA   cDescrItem                AS string OPTIONAL
	WSDATA   nCompartimento            AS int
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WS_GUARDIAN_ExportaItemDoTicketG4
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WS_GUARDIAN_ExportaItemDoTicketG4
Return

WSMETHOD CLONE WSCLIENT WS_GUARDIAN_ExportaItemDoTicketG4
	Local oClone := WS_GUARDIAN_ExportaItemDoTicketG4():NEW()
	oClone:cCodItem             := ::cCodItem
	oClone:cDescrItem           := ::cDescrItem
	oClone:nCompartimento       := ::nCompartimento
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WS_GUARDIAN_ExportaItemDoTicketG4
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cCodItem           :=  WSAdvValue( oResponse,"_CODITEM","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cDescrItem         :=  WSAdvValue( oResponse,"_DESCRITEM","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nCompartimento     :=  WSAdvValue( oResponse,"_COMPARTIMENTO","int",NIL,"Property nCompartimento as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
Return

// WSDL Data Structure ArrayOfEItemEmissorFator

WSSTRUCT WS_GUARDIAN_ArrayOfEItemEmissorFator
	WSDATA   oWSEItemEmissorFator      AS WS_GUARDIAN_EItemEmissorFator OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WS_GUARDIAN_ArrayOfEItemEmissorFator
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WS_GUARDIAN_ArrayOfEItemEmissorFator
	::oWSEItemEmissorFator := {} // Array Of  WS_GUARDIAN_EITEMEMISSORFATOR():New()
Return

WSMETHOD CLONE WSCLIENT WS_GUARDIAN_ArrayOfEItemEmissorFator
	Local oClone := WS_GUARDIAN_ArrayOfEItemEmissorFator():NEW()
	oClone:oWSEItemEmissorFator := NIL
	If ::oWSEItemEmissorFator <> NIL 
		oClone:oWSEItemEmissorFator := {}
		aEval( ::oWSEItemEmissorFator , { |x| aadd( oClone:oWSEItemEmissorFator , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WS_GUARDIAN_ArrayOfEItemEmissorFator
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_EITEMEMISSORFATOR","EItemEmissorFator",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSEItemEmissorFator , WS_GUARDIAN_EItemEmissorFator():New() )
			::oWSEItemEmissorFator[len(::oWSEItemEmissorFator)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ArrayOfEEmissor

WSSTRUCT WS_GUARDIAN_ArrayOfEEmissor
	WSDATA   oWSEEmissor               AS WS_GUARDIAN_EEmissor OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WS_GUARDIAN_ArrayOfEEmissor
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WS_GUARDIAN_ArrayOfEEmissor
	::oWSEEmissor          := {} // Array Of  WS_GUARDIAN_EEMISSOR():New()
Return

WSMETHOD CLONE WSCLIENT WS_GUARDIAN_ArrayOfEEmissor
	Local oClone := WS_GUARDIAN_ArrayOfEEmissor():NEW()
	oClone:oWSEEmissor := NIL
	If ::oWSEEmissor <> NIL 
		oClone:oWSEEmissor := {}
		aEval( ::oWSEEmissor , { |x| aadd( oClone:oWSEEmissor , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WS_GUARDIAN_ArrayOfEEmissor
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_EEMISSOR","EEmissor",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSEEmissor , WS_GUARDIAN_EEmissor():New() )
			::oWSEEmissor[len(::oWSEEmissor)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ArrayOfEUsuario

WSSTRUCT WS_GUARDIAN_ArrayOfEUsuario
	WSDATA   oWSEUsuario               AS WS_GUARDIAN_EUsuario OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WS_GUARDIAN_ArrayOfEUsuario
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WS_GUARDIAN_ArrayOfEUsuario
	::oWSEUsuario          := {} // Array Of  WS_GUARDIAN_EUSUARIO():New()
Return

WSMETHOD CLONE WSCLIENT WS_GUARDIAN_ArrayOfEUsuario
	Local oClone := WS_GUARDIAN_ArrayOfEUsuario():NEW()
	oClone:oWSEUsuario := NIL
	If ::oWSEUsuario <> NIL 
		oClone:oWSEUsuario := {}
		aEval( ::oWSEUsuario , { |x| aadd( oClone:oWSEUsuario , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WS_GUARDIAN_ArrayOfEUsuario
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_EUSUARIO","EUsuario",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSEUsuario , WS_GUARDIAN_EUsuario():New() )
			::oWSEUsuario[len(::oWSEUsuario)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure EMotorista

WSSTRUCT WS_GUARDIAN_EMotorista
	WSDATA   cCpf                      AS string OPTIONAL
	WSDATA   cDocEstrangeiro           AS string OPTIONAL
	WSDATA   cRg                       AS string OPTIONAL
	WSDATA   cNome                     AS string OPTIONAL
	WSDATA   cCnh                      AS string OPTIONAL
	WSDATA   nEstado                   AS int
	WSDATA   cObservacao               AS string OPTIONAL
	WSDATA   cData                     AS dateTime
	WSDATA   cInfoAcompanhantes        AS string OPTIONAL
	WSDATA   cFoto                     AS base64Binary OPTIONAL
	WSDATA   cNacionalidade            AS string OPTIONAL
	WSDATA   cDataNascimento           AS dateTime
	WSDATA   oWSArquivos               AS WS_GUARDIAN_ArrayOfEArquivos OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WS_GUARDIAN_EMotorista
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WS_GUARDIAN_EMotorista
Return

WSMETHOD CLONE WSCLIENT WS_GUARDIAN_EMotorista
	Local oClone := WS_GUARDIAN_EMotorista():NEW()
	oClone:cCpf                 := ::cCpf
	oClone:cDocEstrangeiro      := ::cDocEstrangeiro
	oClone:cRg                  := ::cRg
	oClone:cNome                := ::cNome
	oClone:cCnh                 := ::cCnh
	oClone:nEstado              := ::nEstado
	oClone:cObservacao          := ::cObservacao
	oClone:cData                := ::cData
	oClone:cInfoAcompanhantes   := ::cInfoAcompanhantes
	oClone:cFoto                := ::cFoto
	oClone:cNacionalidade       := ::cNacionalidade
	oClone:cDataNascimento      := ::cDataNascimento
	oClone:oWSArquivos          := IIF(::oWSArquivos = NIL , NIL , ::oWSArquivos:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WS_GUARDIAN_EMotorista
	Local oNode13
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cCpf               :=  WSAdvValue( oResponse,"_CPF","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cDocEstrangeiro    :=  WSAdvValue( oResponse,"_DOCESTRANGEIRO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cRg                :=  WSAdvValue( oResponse,"_RG","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cNome              :=  WSAdvValue( oResponse,"_NOME","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cCnh               :=  WSAdvValue( oResponse,"_CNH","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nEstado            :=  WSAdvValue( oResponse,"_ESTADO","int",NIL,"Property nEstado as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cObservacao        :=  WSAdvValue( oResponse,"_OBSERVACAO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cData              :=  WSAdvValue( oResponse,"_DATA","dateTime",NIL,"Property cData as s:dateTime on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cInfoAcompanhantes :=  WSAdvValue( oResponse,"_INFOACOMPANHANTES","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cFoto              :=  WSAdvValue( oResponse,"_FOTO","base64Binary",NIL,NIL,NIL,"SB",NIL,NIL) 
	::cNacionalidade     :=  WSAdvValue( oResponse,"_NACIONALIDADE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cDataNascimento    :=  WSAdvValue( oResponse,"_DATANASCIMENTO","dateTime",NIL,"Property cDataNascimento as s:dateTime on SOAP Response not found.",NIL,"S",NIL,NIL) 
	oNode13 :=  WSAdvValue( oResponse,"_ARQUIVOS","ArrayOfEArquivos",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode13 != NIL
		::oWSArquivos := WS_GUARDIAN_ArrayOfEArquivos():New()
		::oWSArquivos:SoapRecv(oNode13)
	EndIf
Return

// WSDL Data Structure ArrayOfIdentificadorAdicional

WSSTRUCT WS_GUARDIAN_ArrayOfIdentificadorAdicional
	WSDATA   oWSIdentificadorAdicional AS WS_GUARDIAN_IdentificadorAdicional OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WS_GUARDIAN_ArrayOfIdentificadorAdicional
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WS_GUARDIAN_ArrayOfIdentificadorAdicional
	::oWSIdentificadorAdicional := {} // Array Of  WS_GUARDIAN_IDENTIFICADORADICIONAL():New()
Return

WSMETHOD CLONE WSCLIENT WS_GUARDIAN_ArrayOfIdentificadorAdicional
	Local oClone := WS_GUARDIAN_ArrayOfIdentificadorAdicional():NEW()
	oClone:oWSIdentificadorAdicional := NIL
	If ::oWSIdentificadorAdicional <> NIL 
		oClone:oWSIdentificadorAdicional := {}
		aEval( ::oWSIdentificadorAdicional , { |x| aadd( oClone:oWSIdentificadorAdicional , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WS_GUARDIAN_ArrayOfIdentificadorAdicional
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_IDENTIFICADORADICIONAL","IdentificadorAdicional",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSIdentificadorAdicional , WS_GUARDIAN_IdentificadorAdicional():New() )
			::oWSIdentificadorAdicional[len(::oWSIdentificadorAdicional)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ArrayOfEixoOperacao

WSSTRUCT WS_GUARDIAN_ArrayOfEixoOperacao
	WSDATA   oWSEixoOperacao           AS WS_GUARDIAN_EixoOperacao OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WS_GUARDIAN_ArrayOfEixoOperacao
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WS_GUARDIAN_ArrayOfEixoOperacao
	::oWSEixoOperacao      := {} // Array Of  WS_GUARDIAN_EIXOOPERACAO():New()
Return

WSMETHOD CLONE WSCLIENT WS_GUARDIAN_ArrayOfEixoOperacao
	Local oClone := WS_GUARDIAN_ArrayOfEixoOperacao():NEW()
	oClone:oWSEixoOperacao := NIL
	If ::oWSEixoOperacao <> NIL 
		oClone:oWSEixoOperacao := {}
		aEval( ::oWSEixoOperacao , { |x| aadd( oClone:oWSEixoOperacao , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WS_GUARDIAN_ArrayOfEixoOperacao
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_EIXOOPERACAO","EixoOperacao",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSEixoOperacao , WS_GUARDIAN_EixoOperacao():New() )
			::oWSEixoOperacao[len(::oWSEixoOperacao)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ArrayOfErrosOperacoesTicket

WSSTRUCT WS_GUARDIAN_ArrayOfErrosOperacoesTicket
	WSDATA   oWSErrosOperacoesTicket   AS WS_GUARDIAN_ErrosOperacoesTicket OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WS_GUARDIAN_ArrayOfErrosOperacoesTicket
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WS_GUARDIAN_ArrayOfErrosOperacoesTicket
	::oWSErrosOperacoesTicket := {} // Array Of  WS_GUARDIAN_ERROSOPERACOESTICKET():New()
Return

WSMETHOD CLONE WSCLIENT WS_GUARDIAN_ArrayOfErrosOperacoesTicket
	Local oClone := WS_GUARDIAN_ArrayOfErrosOperacoesTicket():NEW()
	oClone:oWSErrosOperacoesTicket := NIL
	If ::oWSErrosOperacoesTicket <> NIL 
		oClone:oWSErrosOperacoesTicket := {}
		aEval( ::oWSErrosOperacoesTicket , { |x| aadd( oClone:oWSErrosOperacoesTicket , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WS_GUARDIAN_ArrayOfErrosOperacoesTicket
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_ERROSOPERACOESTICKET","ErrosOperacoesTicket",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSErrosOperacoesTicket , WS_GUARDIAN_ErrosOperacoesTicket():New() )
			::oWSErrosOperacoesTicket[len(::oWSErrosOperacoesTicket)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ArrayOfFluxoTicketOperacaoEstacaoControle

WSSTRUCT WS_GUARDIAN_ArrayOfFluxoTicketOperacaoEstacaoControle
	WSDATA   oWSFluxoTicketOperacaoEstacaoControle AS WS_GUARDIAN_FluxoTicketOperacaoEstacaoControle OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WS_GUARDIAN_ArrayOfFluxoTicketOperacaoEstacaoControle
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WS_GUARDIAN_ArrayOfFluxoTicketOperacaoEstacaoControle
	::oWSFluxoTicketOperacaoEstacaoControle := {} // Array Of  WS_GUARDIAN_FLUXOTICKETOPERACAOESTACAOCONTROLE():New()
Return

WSMETHOD CLONE WSCLIENT WS_GUARDIAN_ArrayOfFluxoTicketOperacaoEstacaoControle
	Local oClone := WS_GUARDIAN_ArrayOfFluxoTicketOperacaoEstacaoControle():NEW()
	oClone:oWSFluxoTicketOperacaoEstacaoControle := NIL
	If ::oWSFluxoTicketOperacaoEstacaoControle <> NIL 
		oClone:oWSFluxoTicketOperacaoEstacaoControle := {}
		aEval( ::oWSFluxoTicketOperacaoEstacaoControle , { |x| aadd( oClone:oWSFluxoTicketOperacaoEstacaoControle , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WS_GUARDIAN_ArrayOfFluxoTicketOperacaoEstacaoControle
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_FLUXOTICKETOPERACAOESTACAOCONTROLE","FluxoTicketOperacaoEstacaoControle",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSFluxoTicketOperacaoEstacaoControle , WS_GUARDIAN_FluxoTicketOperacaoEstacaoControle():New() )
			::oWSFluxoTicketOperacaoEstacaoControle[len(::oWSFluxoTicketOperacaoEstacaoControle)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure EItemEmissorFator

WSSTRUCT WS_GUARDIAN_EItemEmissorFator
	WSDATA   nSequencialItem           AS int
	WSDATA   nSequencialEmissor        AS int
	WSDATA   nSequencialoFator         AS int
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WS_GUARDIAN_EItemEmissorFator
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WS_GUARDIAN_EItemEmissorFator
Return

WSMETHOD CLONE WSCLIENT WS_GUARDIAN_EItemEmissorFator
	Local oClone := WS_GUARDIAN_EItemEmissorFator():NEW()
	oClone:nSequencialItem      := ::nSequencialItem
	oClone:nSequencialEmissor   := ::nSequencialEmissor
	oClone:nSequencialoFator    := ::nSequencialoFator
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WS_GUARDIAN_EItemEmissorFator
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::nSequencialItem    :=  WSAdvValue( oResponse,"_SEQUENCIALITEM","int",NIL,"Property nSequencialItem as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nSequencialEmissor :=  WSAdvValue( oResponse,"_SEQUENCIALEMISSOR","int",NIL,"Property nSequencialEmissor as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nSequencialoFator  :=  WSAdvValue( oResponse,"_SEQUENCIALOFATOR","int",NIL,"Property nSequencialoFator as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
Return

// WSDL Data Structure EUsuario

WSSTRUCT WS_GUARDIAN_EUsuario
	WSDATA   cLogin                    AS string OPTIONAL
	WSDATA   cNome                     AS string OPTIONAL
	WSDATA   cSenha                    AS string OPTIONAL
	WSDATA   cInformacao               AS string OPTIONAL
	WSDATA   nEstado                   AS int
	WSDATA   cData                     AS dateTime
	WSDATA   cEmail                    AS string OPTIONAL
	WSDATA   nTipo                     AS int
	WSDATA   lExpirar_Senha            AS boolean
	WSDATA   lAdLdap                   AS boolean
	WSDATA   oWSPerfisDoUsuario        AS WS_GUARDIAN_ArrayOfEPerfisDoUsuario OPTIONAL
	WSDATA   oWSHistoricosUsuario      AS WS_GUARDIAN_ArrayOfEHistoricoSenhasUsuario OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WS_GUARDIAN_EUsuario
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WS_GUARDIAN_EUsuario
Return

WSMETHOD CLONE WSCLIENT WS_GUARDIAN_EUsuario
	Local oClone := WS_GUARDIAN_EUsuario():NEW()
	oClone:cLogin               := ::cLogin
	oClone:cNome                := ::cNome
	oClone:cSenha               := ::cSenha
	oClone:cInformacao          := ::cInformacao
	oClone:nEstado              := ::nEstado
	oClone:cData                := ::cData
	oClone:cEmail               := ::cEmail
	oClone:nTipo                := ::nTipo
	oClone:lExpirar_Senha       := ::lExpirar_Senha
	oClone:lAdLdap              := ::lAdLdap
	oClone:oWSPerfisDoUsuario   := IIF(::oWSPerfisDoUsuario = NIL , NIL , ::oWSPerfisDoUsuario:Clone() )
	oClone:oWSHistoricosUsuario := IIF(::oWSHistoricosUsuario = NIL , NIL , ::oWSHistoricosUsuario:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WS_GUARDIAN_EUsuario
	Local oNode11
	Local oNode12
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cLogin             :=  WSAdvValue( oResponse,"_LOGIN","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cNome              :=  WSAdvValue( oResponse,"_NOME","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cSenha             :=  WSAdvValue( oResponse,"_SENHA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cInformacao        :=  WSAdvValue( oResponse,"_INFORMACAO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nEstado            :=  WSAdvValue( oResponse,"_ESTADO","int",NIL,"Property nEstado as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cData              :=  WSAdvValue( oResponse,"_DATA","dateTime",NIL,"Property cData as s:dateTime on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cEmail             :=  WSAdvValue( oResponse,"_EMAIL","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nTipo              :=  WSAdvValue( oResponse,"_TIPO","int",NIL,"Property nTipo as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::lExpirar_Senha     :=  WSAdvValue( oResponse,"_EXPIRAR_SENHA","boolean",NIL,"Property lExpirar_Senha as s:boolean on SOAP Response not found.",NIL,"L",NIL,NIL) 
	::lAdLdap            :=  WSAdvValue( oResponse,"_ADLDAP","boolean",NIL,"Property lAdLdap as s:boolean on SOAP Response not found.",NIL,"L",NIL,NIL) 
	oNode11 :=  WSAdvValue( oResponse,"_PERFISDOUSUARIO","ArrayOfEPerfisDoUsuario",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode11 != NIL
		::oWSPerfisDoUsuario := WS_GUARDIAN_ArrayOfEPerfisDoUsuario():New()
		::oWSPerfisDoUsuario:SoapRecv(oNode11)
	EndIf
	oNode12 :=  WSAdvValue( oResponse,"_HISTORICOSUSUARIO","ArrayOfEHistoricoSenhasUsuario",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode12 != NIL
		::oWSHistoricosUsuario := WS_GUARDIAN_ArrayOfEHistoricoSenhasUsuario():New()
		::oWSHistoricosUsuario:SoapRecv(oNode12)
	EndIf
Return

// WSDL Data Structure ArrayOfEArquivos

WSSTRUCT WS_GUARDIAN_ArrayOfEArquivos
	WSDATA   oWSEArquivos              AS WS_GUARDIAN_EArquivos OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WS_GUARDIAN_ArrayOfEArquivos
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WS_GUARDIAN_ArrayOfEArquivos
	::oWSEArquivos         := {} // Array Of  WS_GUARDIAN_EARQUIVOS():New()
Return

WSMETHOD CLONE WSCLIENT WS_GUARDIAN_ArrayOfEArquivos
	Local oClone := WS_GUARDIAN_ArrayOfEArquivos():NEW()
	oClone:oWSEArquivos := NIL
	If ::oWSEArquivos <> NIL 
		oClone:oWSEArquivos := {}
		aEval( ::oWSEArquivos , { |x| aadd( oClone:oWSEArquivos , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WS_GUARDIAN_ArrayOfEArquivos
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_EARQUIVOS","EArquivos",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSEArquivos , WS_GUARDIAN_EArquivos():New() )
			::oWSEArquivos[len(::oWSEArquivos)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure IdentificadorAdicional

WSSTRUCT WS_GUARDIAN_IdentificadorAdicional
	WSDATA   cTAG                      AS string OPTIONAL
	WSDATA   cData                     AS dateTime
	WSDATA   nLado                     AS int
	WSDATA   cCodigo                   AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WS_GUARDIAN_IdentificadorAdicional
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WS_GUARDIAN_IdentificadorAdicional
Return

WSMETHOD CLONE WSCLIENT WS_GUARDIAN_IdentificadorAdicional
	Local oClone := WS_GUARDIAN_IdentificadorAdicional():NEW()
	oClone:cTAG                 := ::cTAG
	oClone:cData                := ::cData
	oClone:nLado                := ::nLado
	oClone:cCodigo              := ::cCodigo
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WS_GUARDIAN_IdentificadorAdicional
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cTAG               :=  WSAdvValue( oResponse,"_TAG","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cData              :=  WSAdvValue( oResponse,"_DATA","dateTime",NIL,"Property cData as s:dateTime on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::nLado              :=  WSAdvValue( oResponse,"_LADO","int",NIL,"Property nLado as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cCodigo            :=  WSAdvValue( oResponse,"_CODIGO","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure EixoOperacao

WSSTRUCT WS_GUARDIAN_EixoOperacao
	WSDATA   nNumero                   AS int
	WSDATA   nPeso                     AS decimal
	WSDATA   nPesoOrigem               AS decimal
	WSDATA   cData                     AS dateTime
	WSDATA   nDiferenca                AS decimal
	WSDATA   nDiferencaMaximaPermitida AS decimal
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WS_GUARDIAN_EixoOperacao
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WS_GUARDIAN_EixoOperacao
Return

WSMETHOD CLONE WSCLIENT WS_GUARDIAN_EixoOperacao
	Local oClone := WS_GUARDIAN_EixoOperacao():NEW()
	oClone:nNumero              := ::nNumero
	oClone:nPeso                := ::nPeso
	oClone:nPesoOrigem          := ::nPesoOrigem
	oClone:cData                := ::cData
	oClone:nDiferenca           := ::nDiferenca
	oClone:nDiferencaMaximaPermitida := ::nDiferencaMaximaPermitida
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WS_GUARDIAN_EixoOperacao
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::nNumero            :=  WSAdvValue( oResponse,"_NUMERO","int",NIL,"Property nNumero as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nPeso              :=  WSAdvValue( oResponse,"_PESO","decimal",NIL,"Property nPeso as s:decimal on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nPesoOrigem        :=  WSAdvValue( oResponse,"_PESOORIGEM","decimal",NIL,"Property nPesoOrigem as s:decimal on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cData              :=  WSAdvValue( oResponse,"_DATA","dateTime",NIL,"Property cData as s:dateTime on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::nDiferenca         :=  WSAdvValue( oResponse,"_DIFERENCA","decimal",NIL,"Property nDiferenca as s:decimal on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nDiferencaMaximaPermitida :=  WSAdvValue( oResponse,"_DIFERENCAMAXIMAPERMITIDA","decimal",NIL,"Property nDiferencaMaximaPermitida as s:decimal on SOAP Response not found.",NIL,"N",NIL,NIL) 
Return

// WSDL Data Structure ErrosOperacoesTicket

WSSTRUCT WS_GUARDIAN_ErrosOperacoesTicket
	WSDATA   cCodigo                   AS string OPTIONAL
	WSDATA   nTipoErro                 AS int
	WSDATA   cData                     AS dateTime
	WSDATA   cObservacao               AS string OPTIONAL
	WSDATA   cEstado                   AS string OPTIONAL
	WSDATA   nOperacoesTicketSequencial AS long
	WSDATA   nUsuarioSequencial        AS int
	WSDATA   oWSUsuario                AS WS_GUARDIAN_Usuario OPTIONAL
	WSDATA   cDescricaoTipoErro        AS string OPTIONAL
	WSDATA   cDescricaoEstado          AS string OPTIONAL
	WSDATA   oWSErrosOperacoesTicketDetalhe AS WS_GUARDIAN_ArrayOfErrosOperacoesTicketDetalhe OPTIONAL
	WSDATA   nMotivoErroOperacao       AS int
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WS_GUARDIAN_ErrosOperacoesTicket
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WS_GUARDIAN_ErrosOperacoesTicket
Return

WSMETHOD CLONE WSCLIENT WS_GUARDIAN_ErrosOperacoesTicket
	Local oClone := WS_GUARDIAN_ErrosOperacoesTicket():NEW()
	oClone:cCodigo              := ::cCodigo
	oClone:nTipoErro            := ::nTipoErro
	oClone:cData                := ::cData
	oClone:cObservacao          := ::cObservacao
	oClone:cEstado              := ::cEstado
	oClone:nOperacoesTicketSequencial := ::nOperacoesTicketSequencial
	oClone:nUsuarioSequencial   := ::nUsuarioSequencial
	oClone:oWSUsuario           := IIF(::oWSUsuario = NIL , NIL , ::oWSUsuario:Clone() )
	oClone:cDescricaoTipoErro   := ::cDescricaoTipoErro
	oClone:cDescricaoEstado     := ::cDescricaoEstado
	oClone:oWSErrosOperacoesTicketDetalhe := IIF(::oWSErrosOperacoesTicketDetalhe = NIL , NIL , ::oWSErrosOperacoesTicketDetalhe:Clone() )
	oClone:nMotivoErroOperacao  := ::nMotivoErroOperacao
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WS_GUARDIAN_ErrosOperacoesTicket
	Local oNode8
	Local oNode11
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cCodigo            :=  WSAdvValue( oResponse,"_CODIGO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nTipoErro          :=  WSAdvValue( oResponse,"_TIPOERRO","int",NIL,"Property nTipoErro as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cData              :=  WSAdvValue( oResponse,"_DATA","dateTime",NIL,"Property cData as s:dateTime on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cObservacao        :=  WSAdvValue( oResponse,"_OBSERVACAO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cEstado            :=  WSAdvValue( oResponse,"_ESTADO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nOperacoesTicketSequencial :=  WSAdvValue( oResponse,"_OPERACOESTICKETSEQUENCIAL","long",NIL,"Property nOperacoesTicketSequencial as s:long on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nUsuarioSequencial :=  WSAdvValue( oResponse,"_USUARIOSEQUENCIAL","int",NIL,"Property nUsuarioSequencial as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	oNode8 :=  WSAdvValue( oResponse,"_USUARIO","Usuario",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode8 != NIL
		::oWSUsuario := WS_GUARDIAN_Usuario():New()
		::oWSUsuario:SoapRecv(oNode8)
	EndIf
	::cDescricaoTipoErro :=  WSAdvValue( oResponse,"_DESCRICAOTIPOERRO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cDescricaoEstado   :=  WSAdvValue( oResponse,"_DESCRICAOESTADO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	oNode11 :=  WSAdvValue( oResponse,"_ERROSOPERACOESTICKETDETALHE","ArrayOfErrosOperacoesTicketDetalhe",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode11 != NIL
		::oWSErrosOperacoesTicketDetalhe := WS_GUARDIAN_ArrayOfErrosOperacoesTicketDetalhe():New()
		::oWSErrosOperacoesTicketDetalhe:SoapRecv(oNode11)
	EndIf
	::nMotivoErroOperacao :=  WSAdvValue( oResponse,"_MOTIVOERROOPERACAO","int",NIL,"Property nMotivoErroOperacao as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
Return

// WSDL Data Structure FluxoTicketOperacaoEstacaoControle

WSSTRUCT WS_GUARDIAN_FluxoTicketOperacaoEstacaoControle
	WSDATA   cCodigo                   AS string OPTIONAL
	WSDATA   nSequencial               AS int
	WSDATA   nSequencialFluxoTicketSequencia AS int
	WSDATA   nTipo                     AS int
	WSDATA   nSequencialOperacaoEstacaoControle AS int
	WSDATA   cCodigoOperacaoEstacaoControle AS string OPTIONAL
	WSDATA   cCodigoFluxoTicketSequencia AS string OPTIONAL
	WSDATA   cOperacaoCodigo           AS string OPTIONAL
	WSDATA   cEstacaoControleCodigo    AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WS_GUARDIAN_FluxoTicketOperacaoEstacaoControle
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WS_GUARDIAN_FluxoTicketOperacaoEstacaoControle
Return

WSMETHOD CLONE WSCLIENT WS_GUARDIAN_FluxoTicketOperacaoEstacaoControle
	Local oClone := WS_GUARDIAN_FluxoTicketOperacaoEstacaoControle():NEW()
	oClone:cCodigo              := ::cCodigo
	oClone:nSequencial          := ::nSequencial
	oClone:nSequencialFluxoTicketSequencia := ::nSequencialFluxoTicketSequencia
	oClone:nTipo                := ::nTipo
	oClone:nSequencialOperacaoEstacaoControle := ::nSequencialOperacaoEstacaoControle
	oClone:cCodigoOperacaoEstacaoControle := ::cCodigoOperacaoEstacaoControle
	oClone:cCodigoFluxoTicketSequencia := ::cCodigoFluxoTicketSequencia
	oClone:cOperacaoCodigo      := ::cOperacaoCodigo
	oClone:cEstacaoControleCodigo := ::cEstacaoControleCodigo
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WS_GUARDIAN_FluxoTicketOperacaoEstacaoControle
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cCodigo            :=  WSAdvValue( oResponse,"_CODIGO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nSequencial        :=  WSAdvValue( oResponse,"_SEQUENCIAL","int",NIL,"Property nSequencial as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nSequencialFluxoTicketSequencia :=  WSAdvValue( oResponse,"_SEQUENCIALFLUXOTICKETSEQUENCIA","int",NIL,"Property nSequencialFluxoTicketSequencia as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nTipo              :=  WSAdvValue( oResponse,"_TIPO","int",NIL,"Property nTipo as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nSequencialOperacaoEstacaoControle :=  WSAdvValue( oResponse,"_SEQUENCIALOPERACAOESTACAOCONTROLE","int",NIL,"Property nSequencialOperacaoEstacaoControle as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cCodigoOperacaoEstacaoControle :=  WSAdvValue( oResponse,"_CODIGOOPERACAOESTACAOCONTROLE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cCodigoFluxoTicketSequencia :=  WSAdvValue( oResponse,"_CODIGOFLUXOTICKETSEQUENCIA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cOperacaoCodigo    :=  WSAdvValue( oResponse,"_OPERACAOCODIGO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cEstacaoControleCodigo :=  WSAdvValue( oResponse,"_ESTACAOCONTROLECODIGO","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure ArrayOfEPerfisDoUsuario

WSSTRUCT WS_GUARDIAN_ArrayOfEPerfisDoUsuario
	WSDATA   oWSEPerfisDoUsuario       AS WS_GUARDIAN_EPerfisDoUsuario OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WS_GUARDIAN_ArrayOfEPerfisDoUsuario
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WS_GUARDIAN_ArrayOfEPerfisDoUsuario
	::oWSEPerfisDoUsuario  := {} // Array Of  WS_GUARDIAN_EPERFISDOUSUARIO():New()
Return

WSMETHOD CLONE WSCLIENT WS_GUARDIAN_ArrayOfEPerfisDoUsuario
	Local oClone := WS_GUARDIAN_ArrayOfEPerfisDoUsuario():NEW()
	oClone:oWSEPerfisDoUsuario := NIL
	If ::oWSEPerfisDoUsuario <> NIL 
		oClone:oWSEPerfisDoUsuario := {}
		aEval( ::oWSEPerfisDoUsuario , { |x| aadd( oClone:oWSEPerfisDoUsuario , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WS_GUARDIAN_ArrayOfEPerfisDoUsuario
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_EPERFISDOUSUARIO","EPerfisDoUsuario",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSEPerfisDoUsuario , WS_GUARDIAN_EPerfisDoUsuario():New() )
			::oWSEPerfisDoUsuario[len(::oWSEPerfisDoUsuario)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ArrayOfEHistoricoSenhasUsuario

WSSTRUCT WS_GUARDIAN_ArrayOfEHistoricoSenhasUsuario
	WSDATA   oWSEHistoricoSenhasUsuario AS WS_GUARDIAN_EHistoricoSenhasUsuario OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WS_GUARDIAN_ArrayOfEHistoricoSenhasUsuario
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WS_GUARDIAN_ArrayOfEHistoricoSenhasUsuario
	::oWSEHistoricoSenhasUsuario := {} // Array Of  WS_GUARDIAN_EHISTORICOSENHASUSUARIO():New()
Return

WSMETHOD CLONE WSCLIENT WS_GUARDIAN_ArrayOfEHistoricoSenhasUsuario
	Local oClone := WS_GUARDIAN_ArrayOfEHistoricoSenhasUsuario():NEW()
	oClone:oWSEHistoricoSenhasUsuario := NIL
	If ::oWSEHistoricoSenhasUsuario <> NIL 
		oClone:oWSEHistoricoSenhasUsuario := {}
		aEval( ::oWSEHistoricoSenhasUsuario , { |x| aadd( oClone:oWSEHistoricoSenhasUsuario , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WS_GUARDIAN_ArrayOfEHistoricoSenhasUsuario
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_EHISTORICOSENHASUSUARIO","EHistoricoSenhasUsuario",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSEHistoricoSenhasUsuario , WS_GUARDIAN_EHistoricoSenhasUsuario():New() )
			::oWSEHistoricoSenhasUsuario[len(::oWSEHistoricoSenhasUsuario)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure EArquivos

WSSTRUCT WS_GUARDIAN_EArquivos
	WSDATA   cCaminho                  AS string OPTIONAL
	WSDATA   cArquivo                  AS base64Binary OPTIONAL
	WSDATA   cNome                     AS string OPTIONAL
	WSDATA   cData                     AS dateTime
	WSDATA   nMotoristaSequencial      AS int
	WSDATA   nFormatoEmailSequencial   AS int
	WSDATA   nPessoaSequencial         AS int
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WS_GUARDIAN_EArquivos
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WS_GUARDIAN_EArquivos
Return

WSMETHOD CLONE WSCLIENT WS_GUARDIAN_EArquivos
	Local oClone := WS_GUARDIAN_EArquivos():NEW()
	oClone:cCaminho             := ::cCaminho
	oClone:cArquivo             := ::cArquivo
	oClone:cNome                := ::cNome
	oClone:cData                := ::cData
	oClone:nMotoristaSequencial := ::nMotoristaSequencial
	oClone:nFormatoEmailSequencial := ::nFormatoEmailSequencial
	oClone:nPessoaSequencial    := ::nPessoaSequencial
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WS_GUARDIAN_EArquivos
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cCaminho           :=  WSAdvValue( oResponse,"_CAMINHO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cArquivo           :=  WSAdvValue( oResponse,"_ARQUIVO","base64Binary",NIL,NIL,NIL,"SB",NIL,NIL) 
	::cNome              :=  WSAdvValue( oResponse,"_NOME","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cData              :=  WSAdvValue( oResponse,"_DATA","dateTime",NIL,"Property cData as s:dateTime on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::nMotoristaSequencial :=  WSAdvValue( oResponse,"_MOTORISTASEQUENCIAL","int",NIL,"Property nMotoristaSequencial as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nFormatoEmailSequencial :=  WSAdvValue( oResponse,"_FORMATOEMAILSEQUENCIAL","int",NIL,"Property nFormatoEmailSequencial as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nPessoaSequencial  :=  WSAdvValue( oResponse,"_PESSOASEQUENCIAL","int",NIL,"Property nPessoaSequencial as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
Return

// WSDL Data Structure Usuario

WSSTRUCT WS_GUARDIAN_Usuario
	WSDATA   cCodigo                   AS string OPTIONAL
	WSDATA   lNovoRegistro             AS boolean
	WSDATA   nSequencial               AS int
	WSDATA   cLogin                    AS string OPTIONAL
	WSDATA   cNome                     AS string OPTIONAL
	WSDATA   cSenha                    AS string OPTIONAL
	WSDATA   cEmail                    AS string OPTIONAL
	WSDATA   nTipo                     AS int
	WSDATA   nConfiguracaoEnvio        AS int
	WSDATA   cInformacao               AS string OPTIONAL
	WSDATA   cData                     AS dateTime
	WSDATA   nEstado                   AS int
	WSDATA   oWSListaHistoricoSenhasUsuario AS WS_GUARDIAN_ArrayOfHistoricoSenhasUsuario OPTIONAL
	WSDATA   oWSListaSequenciaisPerfil AS WS_GUARDIAN_ArrayOfInt OPTIONAL
	WSDATA   lExpirarSenha             AS boolean
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WS_GUARDIAN_Usuario
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WS_GUARDIAN_Usuario
Return

WSMETHOD CLONE WSCLIENT WS_GUARDIAN_Usuario
	Local oClone := WS_GUARDIAN_Usuario():NEW()
	oClone:cCodigo              := ::cCodigo
	oClone:lNovoRegistro        := ::lNovoRegistro
	oClone:nSequencial          := ::nSequencial
	oClone:cLogin               := ::cLogin
	oClone:cNome                := ::cNome
	oClone:cSenha               := ::cSenha
	oClone:cEmail               := ::cEmail
	oClone:nTipo                := ::nTipo
	oClone:nConfiguracaoEnvio   := ::nConfiguracaoEnvio
	oClone:cInformacao          := ::cInformacao
	oClone:cData                := ::cData
	oClone:nEstado              := ::nEstado
	oClone:oWSListaHistoricoSenhasUsuario := IIF(::oWSListaHistoricoSenhasUsuario = NIL , NIL , ::oWSListaHistoricoSenhasUsuario:Clone() )
	oClone:oWSListaSequenciaisPerfil := IIF(::oWSListaSequenciaisPerfil = NIL , NIL , ::oWSListaSequenciaisPerfil:Clone() )
	oClone:lExpirarSenha        := ::lExpirarSenha
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WS_GUARDIAN_Usuario
	Local oNode13
	Local oNode14
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cCodigo            :=  WSAdvValue( oResponse,"_CODIGO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::lNovoRegistro      :=  WSAdvValue( oResponse,"_NOVOREGISTRO","boolean",NIL,"Property lNovoRegistro as s:boolean on SOAP Response not found.",NIL,"L",NIL,NIL) 
	::nSequencial        :=  WSAdvValue( oResponse,"_SEQUENCIAL","int",NIL,"Property nSequencial as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cLogin             :=  WSAdvValue( oResponse,"_LOGIN","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cNome              :=  WSAdvValue( oResponse,"_NOME","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cSenha             :=  WSAdvValue( oResponse,"_SENHA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cEmail             :=  WSAdvValue( oResponse,"_EMAIL","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nTipo              :=  WSAdvValue( oResponse,"_TIPO","int",NIL,"Property nTipo as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nConfiguracaoEnvio :=  WSAdvValue( oResponse,"_CONFIGURACAOENVIO","int",NIL,"Property nConfiguracaoEnvio as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cInformacao        :=  WSAdvValue( oResponse,"_INFORMACAO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cData              :=  WSAdvValue( oResponse,"_DATA","dateTime",NIL,"Property cData as s:dateTime on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::nEstado            :=  WSAdvValue( oResponse,"_ESTADO","int",NIL,"Property nEstado as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	oNode13 :=  WSAdvValue( oResponse,"_LISTAHISTORICOSENHASUSUARIO","ArrayOfHistoricoSenhasUsuario",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode13 != NIL
		::oWSListaHistoricoSenhasUsuario := WS_GUARDIAN_ArrayOfHistoricoSenhasUsuario():New()
		::oWSListaHistoricoSenhasUsuario:SoapRecv(oNode13)
	EndIf
	oNode14 :=  WSAdvValue( oResponse,"_LISTASEQUENCIAISPERFIL","ArrayOfInt",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode14 != NIL
		::oWSListaSequenciaisPerfil := WS_GUARDIAN_ArrayOfInt():New()
		::oWSListaSequenciaisPerfil:SoapRecv(oNode14)
	EndIf
	::lExpirarSenha      :=  WSAdvValue( oResponse,"_EXPIRARSENHA","boolean",NIL,"Property lExpirarSenha as s:boolean on SOAP Response not found.",NIL,"L",NIL,NIL) 
Return

// WSDL Data Structure ArrayOfErrosOperacoesTicketDetalhe

WSSTRUCT WS_GUARDIAN_ArrayOfErrosOperacoesTicketDetalhe
	WSDATA   oWSErrosOperacoesTicketDetalhe AS WS_GUARDIAN_ErrosOperacoesTicketDetalhe OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WS_GUARDIAN_ArrayOfErrosOperacoesTicketDetalhe
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WS_GUARDIAN_ArrayOfErrosOperacoesTicketDetalhe
	::oWSErrosOperacoesTicketDetalhe := {} // Array Of  WS_GUARDIAN_ERROSOPERACOESTICKETDETALHE():New()
Return

WSMETHOD CLONE WSCLIENT WS_GUARDIAN_ArrayOfErrosOperacoesTicketDetalhe
	Local oClone := WS_GUARDIAN_ArrayOfErrosOperacoesTicketDetalhe():NEW()
	oClone:oWSErrosOperacoesTicketDetalhe := NIL
	If ::oWSErrosOperacoesTicketDetalhe <> NIL 
		oClone:oWSErrosOperacoesTicketDetalhe := {}
		aEval( ::oWSErrosOperacoesTicketDetalhe , { |x| aadd( oClone:oWSErrosOperacoesTicketDetalhe , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WS_GUARDIAN_ArrayOfErrosOperacoesTicketDetalhe
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_ERROSOPERACOESTICKETDETALHE","ErrosOperacoesTicketDetalhe",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSErrosOperacoesTicketDetalhe , WS_GUARDIAN_ErrosOperacoesTicketDetalhe():New() )
			::oWSErrosOperacoesTicketDetalhe[len(::oWSErrosOperacoesTicketDetalhe)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure EPerfisDoUsuario

WSSTRUCT WS_GUARDIAN_EPerfisDoUsuario
	WSDATA   nUsuario                  AS int
	WSDATA   nPerfilUsuario            AS int
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WS_GUARDIAN_EPerfisDoUsuario
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WS_GUARDIAN_EPerfisDoUsuario
Return

WSMETHOD CLONE WSCLIENT WS_GUARDIAN_EPerfisDoUsuario
	Local oClone := WS_GUARDIAN_EPerfisDoUsuario():NEW()
	oClone:nUsuario             := ::nUsuario
	oClone:nPerfilUsuario       := ::nPerfilUsuario
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WS_GUARDIAN_EPerfisDoUsuario
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::nUsuario           :=  WSAdvValue( oResponse,"_USUARIO","int",NIL,"Property nUsuario as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nPerfilUsuario     :=  WSAdvValue( oResponse,"_PERFILUSUARIO","int",NIL,"Property nPerfilUsuario as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
Return

// WSDL Data Structure EHistoricoSenhasUsuario

WSSTRUCT WS_GUARDIAN_EHistoricoSenhasUsuario
	WSDATA   cSenhaAnterior            AS string OPTIONAL
	WSDATA   cData                     AS dateTime
	WSDATA   nCodigoDoUsuario          AS int
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WS_GUARDIAN_EHistoricoSenhasUsuario
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WS_GUARDIAN_EHistoricoSenhasUsuario
Return

WSMETHOD CLONE WSCLIENT WS_GUARDIAN_EHistoricoSenhasUsuario
	Local oClone := WS_GUARDIAN_EHistoricoSenhasUsuario():NEW()
	oClone:cSenhaAnterior       := ::cSenhaAnterior
	oClone:cData                := ::cData
	oClone:nCodigoDoUsuario     := ::nCodigoDoUsuario
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WS_GUARDIAN_EHistoricoSenhasUsuario
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cSenhaAnterior     :=  WSAdvValue( oResponse,"_SENHAANTERIOR","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cData              :=  WSAdvValue( oResponse,"_DATA","dateTime",NIL,"Property cData as s:dateTime on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::nCodigoDoUsuario   :=  WSAdvValue( oResponse,"_CODIGODOUSUARIO","int",NIL,"Property nCodigoDoUsuario as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
Return

// WSDL Data Structure ArrayOfHistoricoSenhasUsuario

WSSTRUCT WS_GUARDIAN_ArrayOfHistoricoSenhasUsuario
	WSDATA   oWSHistoricoSenhasUsuario AS WS_GUARDIAN_HistoricoSenhasUsuario OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WS_GUARDIAN_ArrayOfHistoricoSenhasUsuario
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WS_GUARDIAN_ArrayOfHistoricoSenhasUsuario
	::oWSHistoricoSenhasUsuario := {} // Array Of  WS_GUARDIAN_HISTORICOSENHASUSUARIO():New()
Return

WSMETHOD CLONE WSCLIENT WS_GUARDIAN_ArrayOfHistoricoSenhasUsuario
	Local oClone := WS_GUARDIAN_ArrayOfHistoricoSenhasUsuario():NEW()
	oClone:oWSHistoricoSenhasUsuario := NIL
	If ::oWSHistoricoSenhasUsuario <> NIL 
		oClone:oWSHistoricoSenhasUsuario := {}
		aEval( ::oWSHistoricoSenhasUsuario , { |x| aadd( oClone:oWSHistoricoSenhasUsuario , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WS_GUARDIAN_ArrayOfHistoricoSenhasUsuario
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_HISTORICOSENHASUSUARIO","HistoricoSenhasUsuario",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSHistoricoSenhasUsuario , WS_GUARDIAN_HistoricoSenhasUsuario():New() )
			::oWSHistoricoSenhasUsuario[len(::oWSHistoricoSenhasUsuario)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ArrayOfInt

WSSTRUCT WS_GUARDIAN_ArrayOfInt
	WSDATA   nint                      AS int OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WS_GUARDIAN_ArrayOfInt
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WS_GUARDIAN_ArrayOfInt
	::nint                 := {} // Array Of  0
Return

WSMETHOD CLONE WSCLIENT WS_GUARDIAN_ArrayOfInt
	Local oClone := WS_GUARDIAN_ArrayOfInt():NEW()
	oClone:nint                 := IIf(::nint <> NIL , aClone(::nint) , NIL )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WS_GUARDIAN_ArrayOfInt
	Local oNodes1 :=  WSAdvValue( oResponse,"_INT","int",{},NIL,.T.,"N",NIL,"a") 
	::Init()
	If oResponse = NIL ; Return ; Endif 
	aEval(oNodes1 , { |x| aadd(::nint ,  val(x:TEXT)  ) } )
Return

// WSDL Data Structure ErrosOperacoesTicketDetalhe

WSSTRUCT WS_GUARDIAN_ErrosOperacoesTicketDetalhe
	WSDATA   cCodigo                   AS string OPTIONAL
	WSDATA   nTipoDetalhe              AS int
	WSDATA   cConteudoDetalhe          AS string OPTIONAL
	WSDATA   nSequencialErrosOperacaoTicket AS long
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WS_GUARDIAN_ErrosOperacoesTicketDetalhe
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WS_GUARDIAN_ErrosOperacoesTicketDetalhe
Return

WSMETHOD CLONE WSCLIENT WS_GUARDIAN_ErrosOperacoesTicketDetalhe
	Local oClone := WS_GUARDIAN_ErrosOperacoesTicketDetalhe():NEW()
	oClone:cCodigo              := ::cCodigo
	oClone:nTipoDetalhe         := ::nTipoDetalhe
	oClone:cConteudoDetalhe     := ::cConteudoDetalhe
	oClone:nSequencialErrosOperacaoTicket := ::nSequencialErrosOperacaoTicket
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WS_GUARDIAN_ErrosOperacoesTicketDetalhe
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cCodigo            :=  WSAdvValue( oResponse,"_CODIGO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nTipoDetalhe       :=  WSAdvValue( oResponse,"_TIPODETALHE","int",NIL,"Property nTipoDetalhe as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cConteudoDetalhe   :=  WSAdvValue( oResponse,"_CONTEUDODETALHE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nSequencialErrosOperacaoTicket :=  WSAdvValue( oResponse,"_SEQUENCIALERROSOPERACAOTICKET","long",NIL,"Property nSequencialErrosOperacaoTicket as s:long on SOAP Response not found.",NIL,"N",NIL,NIL) 
Return

// WSDL Data Structure HistoricoSenhasUsuario

WSSTRUCT WS_GUARDIAN_HistoricoSenhasUsuario
	WSDATA   cCodigo                   AS string OPTIONAL
	WSDATA   nSequencial               AS int
	WSDATA   cData                     AS dateTime
	WSDATA   nSequencialUsuario        AS int
	WSDATA   cSenhaUsuario             AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WS_GUARDIAN_HistoricoSenhasUsuario
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WS_GUARDIAN_HistoricoSenhasUsuario
Return

WSMETHOD CLONE WSCLIENT WS_GUARDIAN_HistoricoSenhasUsuario
	Local oClone := WS_GUARDIAN_HistoricoSenhasUsuario():NEW()
	oClone:cCodigo              := ::cCodigo
	oClone:nSequencial          := ::nSequencial
	oClone:cData                := ::cData
	oClone:nSequencialUsuario   := ::nSequencialUsuario
	oClone:cSenhaUsuario        := ::cSenhaUsuario
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WS_GUARDIAN_HistoricoSenhasUsuario
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cCodigo            :=  WSAdvValue( oResponse,"_CODIGO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nSequencial        :=  WSAdvValue( oResponse,"_SEQUENCIAL","int",NIL,"Property nSequencial as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cData              :=  WSAdvValue( oResponse,"_DATA","dateTime",NIL,"Property cData as s:dateTime on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::nSequencialUsuario :=  WSAdvValue( oResponse,"_SEQUENCIALUSUARIO","int",NIL,"Property nSequencialUsuario as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cSenhaUsuario      :=  WSAdvValue( oResponse,"_SENHAUSUARIO","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return


