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
/*/

User Function M410INIC()

Local _cAlias := Alias()
Local _cOrder := IndexOrd()
Local _cRecno := Recno()

Private _nTcConn1	:= advConnection()

//Conout( DToC(Date()) + " " + Time() + " M410INIC >>> INICIO PE" )

/* 
INICIO Retirada trecho de fonte para o chamado 041995 || TECNOLOGIA || FERNANDO_SIGOLI || 8451 || FONTES DO TECLAN WILLIAM COSTA 07/06/2018 
// parametros para conexao DBINTECLAN
cBanco         := "MSSQL/DBINTECLAN"    // Nome do Banco(MSSQL7)/Nome do Ambiente(Fonte ODBC) no TOPCONNECT
cServidor      := "10.5.1.2"  			  // Nome do Servidor onde fica o Ambiente(Fonte ODBC)
FINAL Retirada trecho de fonte para o chamado 041995 || TECNOLOGIA || FERNANDO_SIGOLI || 8451 || FONTES DO TECLAN WILLIAM COSTA 07/06/2018 
*/
// Ricardo Lima - 09/05/18
If CEMPANT = '01' .and. !IsInCallStack('RESTEXECUTE') .And. ! IsInCallStack('U_RESTEXECUTE')  // Somente para a Empresa AD'oro
	dbSelectArea("SA3")
	dbSetOrder(7)
	If dbSeek(xFilial("SA3")+__cUserID)
			If SUBSTR(SA3->A3_XVLDPER,1,1) = '1'
			ApMsgInfo('Vendedor sem PERMISSÃO para Incluir Pedido, verifique com a Supervisão!','Permissões de Vendedores')
			Return(.F.)
		Endif
	Endif
Endif

/*
INICIO Retirada trecho de fonte para o chamado 041995 || TECNOLOGIA || FERNANDO_SIGOLI || 8451 || FONTES DO TECLAN WILLIAM COSTA 07/06/2018
&&Verifico codigo de vendedor no SA3 pelo usuario do sistema.
dbSelectArea("SA3")
dbSetOrder(7)
If dbSeek(xFilial("SA3")+__cUserID)
	_cCodVen := SA3->A3_COD      &&com este codigo é que vou buscar registros em aberto(Atendimento) na tabela do TECLAN.
	
	//_nTcConn2 := TCLINK(cBanco,cServidor)  && Chamado 032003
	TcConType("TCPIP")
	
	If (_nTcConn2 := TCLINK(cBanco,cServidor)) <0
		_lRet     := .F.
		IF IsInCallStack('U_ADVEN002P')  == .T.
			Aadd(aPedidos,{cchave, ;
			''    , ;
			''    , ;
			''    , ;
			'Atencao !! Não foi possível  conectar ao banco DBINTECLAN, verifique com administrador' ,;
			cVendedor})
			
		ELSEIF IsInCallStack('RESTEXECUTE') .Or. IsInCallStack('U_RESTEXECUTE')//Everson - 25/09/2017. Chamado 037261.
			Aadd(aPedidos,{'Atencao !! Não foi possível  conectar ao banco DBINTECLAN, verifique com administrador'})
							
		ELSE
			//cMsgError := "Não foi possível  conectar ao banco DBINTECLAN"
			MsgInfo("Não foi possível  conectar ao banco DBINTECLAN, verifique com administrador","ERROR")
		ENDIF
		
	else
		
		TcSetConn(_nTcConn2)
		
		&&Busco atendimento em aberto na tabela ATENDE do banco DBINTECLAN
		If Select("TATD") > 0
			DbSelectArea("TATD")
			DbCloseArea("TATD")
		Endif
		
		&&Busco o atendimento em aberto que no caso só pode ser obrigatoriamente UNICO.....
		
		cQuery := "SELECT * "
		cQuery += "FROM  [DBINTECLAN].[dbo].[ATENDE] ATD "
		cQuery += "WHERE ATD.DT_FIM = ' '  AND ATD.DT_ATENDE <> '' AND "
		cQuery += "ATD.VEND = '"+_cCodVen+"' "
		cQuery += "AND R_E_C_N_O_ = (SELECT MAX(R_E_C_N_O_) FROM  [DBINTECLAN].[dbo].[ATENDE] ATD WHERE ATD.DT_FIM = ' ' AND ATD.DT_ATENDE = '"+dToc(dDataBase)+"' AND ATD.VEND = '"+_cCodVen+"') "
		
		TCQUERY cQuery NEW ALIAS "TATD"
		
		DbSelectArea("TATD")
		DbGoTop()
		
		If TATD->(!Eof())
			
			_cTADCLIE  := TATD->CODCLI
			_cTADLOJA  := TATD->LOJA
			_cTADPROT  := TATD->PROTOCOL
			
			TcSetConn(_nTcConn1)
			
			&&atualizacao dos dados do pedido com dados do atendimento.
			dbSelectArea("SA1")
			dbSetOrder(1)
			IF dbSeek(xFilial("SA1")+_cTADCLIE+_cTADLOJA)
				
				M->C5_TIPO    := "N"
				M->C5_CLIENTE := TATD->CODCLI
				M->C5_LOJACLI := TATD->LOJA
				
				ALTERA := .F.
				a410Cli("C5_CLIENTE",M->C5_CLIENTE,.F.)
				a410Loja("C5_LOJACLI",M->C5_LOJACLI,.F.)
				M->C5_CLIENT := _cTADCLIE
				a410Cli("C5_CLIENT",M->C5_CLIENT,.F.)
				
				M->C5_LOJAENT := _cTADLOJA
				a410Loja("C5_LOJAENT",M->C5_LOJAENT,.F.)       
				
				M->C5_TIPOCLI := SA1->A1_TIPO
				M->C5_NOMECLI := SA1->A1_NREDUZ
				M->C5_EST     := SA1->A1_EST
				M->C5_ENDERE  := SA1->A1_END
				M->C5_VEND1   := _cCodVen
				M->C5_BAIRRO  := SA1->A1_BAIRRO
				M->C5_CIDADE  := SA1->A1_MUN
				M->C5_ROTEIRO := IIF(EMPTY(SA1->A1_ROTEIRO),"200",SA1->A1_ROTEIRO)
				M->C5_DTENTR  := ddatabase+1
				M->C5_NATUREZ := SA1->A1_NATUREZ
				M->C5_DATA1   := DataValida(M->C5_DTENTR + VAL(SA1->A1_COND))
				M->C5_TABELA  := SA1->A1_TABELA
				M->C5_TECPROT := _cTADPROT
				//M->C5_MOEDA   := 1

				If ExistTrigger('C5_CLIENTE')            //incluido por Adriana para forçar a execução dos gatilhos em 20160823
					RunTrigger(1,nil,nil,,'C5_CLIENTE')
				Endif

				If ExistTrigger('C5_LOJACLI')      
					RunTrigger(1,nil,nil,,'C5_LOJACLI') //incluido por Adriana para forçar a execução dos gatilhos em 20160823
				Endif

			ENDIF
			
		ENDIF
		TcSetConn(_nTcConn2)
		DbCloseArea("TATD")
		//TcUnLink(_nTcConn1)
		TcUnLink(_nTcConn2)
	endif
	TcSetConn(_nTcConn1)

	// REFAZ FILTRO SA1 - pois ao executar o PE perdia o filtro VAR_IXB variavel publica definida no ponto de entrada M410FSQL
	dbSelectArea("SA1")                                     

	If !Alltrim(cUsername) $ GetMV("MV_GERENTE")  	// Se for Gerente 		nao tem Filtro
   		If SA3->A3_NIVETAB == "2"  					// Se for Supervisor	filtra equipe
			Set Filter to A1_VEND  $ VAR_IXB[3]  
   		Elseif SA3->A3_NIVETAB == "1"  				// Se for Vendedor 		filtra somente codigo do vendedor
   			Set Filter to A1_VEND  == VAR_IXB[3]
   		Endif                  
	Endif

else
	TcSetConn(_nTcConn1)
	
Endif

FINAL Retirada trecho de fonte para o chamado 041995 || TECNOLOGIA || FERNANDO_SIGOLI || 8451 || FONTES DO TECLAN WILLIAM COSTA 07/06/2018 
*/


dbSelectArea(_cAlias)
dbSetOrder(_cOrder)
dbGoto(_cRecno)

//Conout( DToC(Date()) + " " + Time() + " M410INIC >>> FINAL PE" )

Return()
