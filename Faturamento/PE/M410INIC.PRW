#Include "RwMake.ch"
#Include "Protheus.ch"
#Include "Topconn.ch"
#Include "TbiConn.ch"
#Include "TbiCode.ch"


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Programa ³ M410INIC º Autor ³ Mauricio - MDS TEC º Data ³ 29/06/2016  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Desc.    ³ PE para atualizar dados do cabecalho do pedido de venda comº±±
±±º          ³ dados de tabela do atendimento de call center(TECLAN)      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Uso      ³ ADORO                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
// ---------+-------------------+-----------------------------------------------------------------+---------------
// Data     | Autor             | Descricao                                                       | Chamado
// ---------+-------------------+-----------------------------------------------------------------+---------------
// 09/05/18 | Ricardo Lima      | Valida permissão do vendedor na tela de pedido de vendas        |
// ---------+-------------------+-----------------------------------------------------------------+---------------
@history Ticket  TI     - Leonardo P. Monteiro - 26/02/2022 - Inclusão de conouts no fonte. 
/*/

User Function M410INIC()

	Local _cAlias 		:= Alias()
	Local _cOrder 		:= IndexOrd()
	Local _cRecno 		:= Recno()

	Private _nTcConn1	:= advConnection()
	Private lSfInt		:= (IsInCallStack('U_RESTEXECUTE') .OR. IsInCallStack('RESTEXECUTE'))

	Conout( DToC(Date()) + " " + Time() + " M410INIC >>> INICIO PE" )

	/* 
	INICIO Retirada trecho de fonte para o chamado 041995 || TECNOLOGIA || FERNANDO_SIGOLI || 8451 || FONTES DO TECLAN WILLIAM COSTA 07/06/2018 
	// parametros para conexao DBINTECLAN
	cBanco         := "MSSQL/DBINTECLAN"    // Nome do Banco(MSSQL7)/Nome do Ambiente(Fonte ODBC) no TOPCONNECT
	cServidor      := "10.5.1.2"  			  // Nome do Servidor onde fica o Ambiente(Fonte ODBC)
	FINAL Retirada trecho de fonte para o chamado 041995 || TECNOLOGIA || FERNANDO_SIGOLI || 8451 || FONTES DO TECLAN WILLIAM COSTA 07/06/2018 
	*/
	// Ricardo Lima - 09/05/18
	If CEMPANT = '01' .and. !lSfInt  // Somente para a Empresa AD'oro
		dbSelectArea("SA3")
		dbSetOrder(7)
		If dbSeek(xFilial("SA3")+__cUserID)
				If SUBSTR(SA3->A3_XVLDPER,1,1) = '1'
				ApMsgInfo('Vendedor sem PERMISSÃO para Incluir Pedido, verifique com a Supervisão!','Permissões de Vendedores')
				Return(.F.)
			Endif
		Endif
	Endif

	dbSelectArea(_cAlias)
	dbSetOrder(_cOrder)
	dbGoto(_cRecno)

	Conout( DToC(Date()) + " " + Time() + " M410INIC >>> FINAL PE" )

Return()
