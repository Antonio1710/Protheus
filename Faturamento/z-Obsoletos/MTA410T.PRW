#Include "RwMake.ch"
#Include "Protheus.ch"
#Include "Topconn.ch"
#Include "TbiConn.ch"
#Include "TbiCode.ch"

User Function MTA410T()      // DELMTA450T()  RENOMEADA PARA DEL PARA TESTAR

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ MTA450I  ³ Autor ³ hcconsys  - heverson  ³ Data ³ 04/11/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Ponto de Entrada no MATA456 (Liberacao de Credito e estoque³±±
±±³          ³ gravar SC9, para gravar o campo C9_ROTEIRO,C9_DTENTR       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico Ad'oro Alimenticia                              ³±±
±±³          ³ Usuarios FAT - MATA456 - Liberacao de Credito              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ´±±
±±³ versionamento:  ³                                                     ³±±
±±³Chamado 045119. Everson 12/11/2018. Comentado o trecho de código que   ³±±
±±³não bloqueava pedido exportação por crédito.                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Guarda ambiente inicial                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local _aArea	:= GetArea()
Local _cAlias 	:= Alias()
Local _cOrder 	:= IndexOrd()
Local _cRecno 	:= Recno()

/*
INICIO Retirada trecho de fonte para o chamado 041995 || TECNOLOGIA || FERNANDO_SIGOLI || 8451 || FONTES DO TECLAN WILLIAM COSTA 07/06/2018
//Mauricio - 27/07/16 - integraçao TECLAN
Private _nTcConn1	:= advConnection()
// parametros para conexao DBINTECLAN
cBanco         := "MSSQL/DBINTECLAN"    // Nome do Banco(MSSQL7)/Nome do Ambiente(Fonte ODBC) no TOPCONNECT
cServidor      := "10.5.1.2"  			// Servidor onde fica o Ambiente(Fonte ODBC)
FINAL Retirada trecho de fonte para o chamado 041995 || TECNOLOGIA || FERNANDO_SIGOLI || 8451 || FONTES DO TECLAN WILLIAM COSTA 07/06/2018
*/ 

//Mauricio 16/11/11 - Tratamento para forçar bloqueio por limite de credito(Padrao Protheus estava falhando)
_nLimCred := 0  
_nVlrItem := 0
_nLimCred := Posicione("SA1",1,xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,"A1_LC")
_lBloq    := .F. 
_nSldAb   := fBscSld(SC5->C5_CLIENTE,SC5->C5_LOJACLI)   //busca saldo em aberto para o cliente 
_Tipo     := SC5->C5_TIPO
_estado   := SC5->C5_EST

if cEmpAnt == "01" //Alterado por Adriana devido ao error.log quando empresa <> 01 - chamado 032804

	/*
	INICIO Retirada trecho de fonte para o chamado 041995 || TECNOLOGIA || FERNANDO_SIGOLI || 8451 || FONTES DO TECLAN WILLIAM COSTA 07/06/2018
	//Mauricio - 27/07/2016 - tratamento por conta do TECLAN.
	IF !Empty(SC5->C5_TECPROT)
  	 	_cPed := SC5->C5_NUM 
   		//_nTcConn2 := TCLINK(cBanco,cServidor)   // Chamado 032003
   		TcConType("TCPIP")
    	
	   	If (_nTcConn2 := TCLINK(cBanco,cServidor)) <0
		    IF IsInCallStack('U_ADVEN002P')  == .T.
        	    Aadd(aPedidos,{cchave, ;
                           ''    , ;
                           ''    , ;
                           ''    , ;
                           'Atencao !! Não foi possível  conectar ao banco DBINTECLAN, verifique com administrador' ,;
                           cVendedor})  
                                                                                                                       
            ELSEIF IsInCallStack('RESTEXECUTE') //Everson - 25/09/2017. Chamado 037261.
            	Aadd(aPedidos,{'Atencao !! Não foi possível  conectar ao banco DBINTECLAN, verifique com administrador'})
			        	
        	ELSE
	        	//cMsgError := "Não foi possível  conectar ao banco DBINTECLAN"
	        	MsgInfo("Não foi possível  conectar ao banco DBINTECLAN, verifique com administrador","ERROR")
	    	ENDIF    
   		Else
   				   
	   		TcSetConn(_nTcConn2)
		
   			cQuery:= " UPDATE [DBINTECLAN].[dbo].[ATENDE] "
  			cQuery+= " SET PEDIDO = '"+_cPed+"' "
   			cQuery+= " WHERE LTRIM(RTRIM(PROTOCOL)) = '"+Alltrim(SC5->C5_TECPROT)+"' "     
   			TCSQLExec(cQuery)
    
   			TcUnLink(_nTcConn2)
    
//   		TcSetConn(_nTcConn1)
   		Endif
		TcSetConn(_nTcConn1)
    
	ENDIF
	FINAL Retirada trecho de fonte para o chamado 041995 || TECNOLOGIA || FERNANDO_SIGOLI || 8451 || FONTES DO TECLAN WILLIAM COSTA 07/06/2018
    */
Endif

dbSelectArea("SC6")
dbSetOrder(1)
if dbseek(xfilial("SC6") + SC5->C5_NUM)
	
	//DO WHILE .NOT. EOF() .AND. SC6->C6_FILIAL == SC5->C5_FILIAL .AND. SC6->C6_NUM == SC5->C5_NUM  // RICARDO LIMA - 25/01/18
	DO WHILE SC6->( !EOF()) .AND. SC6->C6_FILIAL == SC5->C5_FILIAL .AND. SC6->C6_NUM == SC5->C5_NUM
		if SC6->C6_QTDENT < SC6->C6_QTDVEN  //qtd total pendente
			_nVlrItem := ((SC6->C6_QTDVEN - SC6->C6_QTDENT) * SC6->C6_PRCVEN)   //valor pendente no pedido (inclusive parcial)
		endif
		// Alex Borges - 19/07/12 - If para tratar a TES
         DbSelectArea("SF4")
	     DbSetOrder(1)
	     if dbseek(xFilial("SF4")+SC6->C6_TES)
		    // If (ALLTRIM(SF4->F4_DUPLIC) = 'S')  Alex Borges 01/12/11
		 If ((ALLTRIM(SF4->F4_DUPLIC) = 'S') .and. (ALLTRIM(_Tipo) $ 'N/C')) //.and. (ALLTRIM(_estado)<> "EïX")) //Everson - 12/11/2018. Chamado 045119. Pedido exportação deve ficar bloqueado por crédito.
			if (_nVlrItem + _nSldAb) > _nLimCred   //limite excedido deve bloquear
				DbSelectArea("SC9")
				DbSetOrder(1)
				if dbseek(xFilial("SC9")+SC6->C6_NUM+SC6->C6_ITEM)  //somente se achou item liberado no SC9
					If empty(SC9->C9_BLCRED)   //somente se ja não houver bloqueio
						Reclock("SC9",.F.)
						SC9->C9_BLCRED := "01"  //bloqueio por limite de valor
					   /*	Replace C9_ROTEIRO With SC6->C6_ROTEIRO
						Replace C9_DTENTR  with SC6->C6_ENTREG     // ALTERADO EM 29/10/08 POR HCCONSYS P/ TRATAR NUMERO DO LACRE NA ROTINA MENUBALA()
						Replace C9_VEND1   with SC5->C5_VEND1 */
						
						// Alex Borges - 28/11/11 - Adaptacao de codigo
						SC9->C9_ROTEIRO := SC6->C6_ROTEIRO
						SC9->C9_DTENTR  := SC6->C6_ENTREG     // ALTERADO EM 29/10/08 POR HCCONSYS P/ TRATAR NUMERO DO LACRE NA ROTINA MENUBALA()
						SC9->C9_VEND1   := SC5->C5_VEND1
						MsUnlock()
					Else
						// Alex Borges - 28/11/11 - Adaptacao de codigo
						/*Replace C9_ROTEIRO With SC6->C6_ROTEIRO
						Replace C9_DTENTR  with SC6->C6_ENTREG     // ALTERADO EM 29/10/08 POR HCCONSYS P/ TRATAR NUMERO DO LACRE NA ROTINA MENUBALA()
						Replace C9_VEND1   with SC5->C5_VEND1*/
						Reclock("SC9",.F.)
						SC9->C9_ROTEIRO := SC6->C6_ROTEIRO
						SC9->C9_DTENTR  := SC6->C6_ENTREG     // ALTERADO EM 29/10/08 POR HCCONSYS P/ TRATAR NUMERO DO LACRE NA ROTINA MENUBALA()
						SC9->C9_VEND1   := SC5->C5_VEND1
						MsUnlock()
					Endif
				Endif
			Else
				dbSelectArea("SC9")
				dbSetOrder(1)
				if dbseek(xfilial("SC9") + SC6->C6_NUM + SC6->C6_ITEM )
					
					RecLock("SC9",.F.)
					// Alex Borges - 28/11/11 - Adaptacao de codigo
					/*Replace C9_ROTEIRO With SC6->C6_ROTEIRO
					Replace C9_DTENTR  with SC6->C6_ENTREG     // ALTERADO EM 29/10/08 POR HCCONSYS P/ TRATAR NUMERO DO LACRE NA ROTINA MENUBALA()
					Replace C9_VEND1   with SC5->C5_VEND1*/
					
				    SC9->C9_ROTEIRO := SC6->C6_ROTEIRO
					SC9->C9_DTENTR  := SC6->C6_ENTREG     // ALTERADO EM 29/10/08 POR HCCONSYS P/ TRATAR NUMERO DO LACRE NA ROTINA MENUBALA()
					SC9->C9_VEND1   := SC5->C5_VEND1
					
					MsUnlock()
					
				endif
			Endif
		End If
		End If 	
			_nLimCred -= _nVlrItem  //deduzo o valor do item ja validado do limite utilizado.
			dbSelectArea("SC6")
			dbSetOrder(1)
			dbskip()
			
	enddo
	
endif

RestArea( _aArea )
dbSelectArea(_cAlias)
dbSetOrder(_cOrder)
dbGoto(_cRecno)

Return

	
static function fBscSld(_cCl,_cL)  ////Mauricio 16/11/11 - retorna saldo em aberto para o Cliente.
//Local _cCl
//Local _cL
Local _nSld := 0
Local _cQuery := ""

If Select("TSE1") > 0
   DbSelectArea("TSE1")
   DbCloseArea("TSE1")
Endif

//_cQuery := " SELECT E1_SALDO FROM "+RetSqlNam("SE1")+" SE1 "
//_cQuery += " WHERE SE1.E1_CLIENTE = '"+_cCL+"' AND SE1.E1_LOJA = '"+_cL+"' AND SE1.D_E_L_E_T_ = '' AND SE1.E1_SALDO > 0"

_cQuery := " SELECT SUM(E1_SALDO)  E1_SALDO "
_cQuery += " FROM "+RetSqlName("SE1")+" SE1 " 
_cQuery += " WHERE SE1.E1_CLIENTE = '"+_cCL+"' AND SE1.E1_LOJA = '"+_cL+"' " 
_cQuery += " AND SE1.E1_SALDO > 0 AND SE1.D_E_L_E_T_ = ' ' " 
				
_cQuery := ChangeQuery(_cQuery) // RICARDO LIMA - 25/01/18

TCQUERY _cQuery NEW ALIAS "TSE1"

dbSelectArea("TSE1")

IF TSE1->(!Eof())
	_nSld := TSE1->E1_SALDO
EndIF 

dbcloseArea("TSE1")  
return(_nSld)
