#include "rwmake.ch"
#include "TbiConn.ch"
#include "TbiCode.ch"
#include "Topconn.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ Rcomw01  บAutor  ณ Sergio Oliveira    บ Data ณ  Out/2006   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Processo de aprovacao dos Pedidos de Compras via Workflow. บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ CSU                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function RCOMW01(_nOpc, oProcess)

Local _cIndex, _cFiltro, _cOrdem, _lProcesso := .F.
Local _cFilial, _cOpcao, _cObs,_i
Local nSaldo 		:= 0 , 	nSalDif 	:= 0  ,	cTipoLim  	:= ""
Local aRetSaldo 	:={} ,	cAprov    	:= "" , cObs 		:= ""
Local nTotal    	:= 0 , 	cGrupo	 	:= "" , lLiberou	:= .F.

Local cChaveSCR	:= ""
Local cWFID		:= ""
Local cOpc		:= ""
Local cQuery 	:= Nil
Local aFiles		:= Directory( '\WorkFlow\Html\Anexo\*.Htm' )

Private cFile		:= ''
Private cPasta  := '\WorkFlow\Html\Anexo\'

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Processo de aprovacao dos Pedidos de Compras via Workflow')

For nInd := 1 To Len( aFiles )
	If aFiles[1][3] < ( MsDate() - 3 )
		FErase( cPasta + aFiles[ nInd ][ 1 ] )
	EndIf
Next nInd

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ1 - Prepara as Solicitacoes para aprovacao            ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

If _nOpc == 1
	U_xCONSOLE("1 - Prepara os Pedidos a serem enviadas para aprovacao", .F.)
	// RICARDO LIMA - 13/11/17
	cQuery := " SELECT DISTINCT SCR.*, SC7.C7_NUMSC "
	cQuery += " FROM "+ RetSQLName( 'SCR' ) +" SCR "
	cQuery += " INNER JOIN "+ RetSQLName( 'SC7' ) +" SC7 ON "
	cQuery += " SC7.C7_FILIAL = '"+ xFilial( 'SC7' ) +"' "
	cQuery += " AND SCR.CR_FILIAL = '"+ xFilial( 'SCR' ) +"' "
	cQuery += " AND SCR.CR_NUM = SC7.C7_NUM "
	cQuery += " WHERE SC7.C7_XWFID = '"+ CriaVar( 'C7_XWFID' , .F. ) +"' "
	cQuery += " AND SC7.C7_CONAPRO = 'B' "
	cQuery += " AND SCR.CR_TIPO = 'PC' "
	cQuery += " AND SCR.CR_STATUS = '02' "
	cQuery += " AND SCR.CR_XTPLIB = 'V' "
	cQuery += " AND SCR.CR_WF IN ( '"+ CriaVar( 'CR_WF' , .F. ) +"','3' ) "
	cQuery += " AND SC7.D_E_L_E_T_ = '"+ Space( 1 ) +"' "
	cQuery += " AND SCR.D_E_L_E_T_ = '"+ Space( 1 ) +"' "
	cQuery += " ORDER BY SCR.CR_FILIAL,SCR.CR_NUM,SCR.CR_NIVEL,SCR.CR_USER "
	cQuery := ChangeQuery( cQuery )                    
	
	
	dbUseArea( .T. , __cRdd , TcGenQry( ,,cQuery ), 'TMP' , .T. , .F. )
	
	dbSelectArea("TMP")
	TMP->( dbGotop() )
	While !TMP->( Eof() )
		
		_cWFId 	   := EnviaPC( TMP->CR_FILIAL, TMP->CR_NUM, TMP->CR_USER , TMP->CR_APROV, TMP->( CR_FILIAL + CR_TIPO + CR_NUM + CR_USER ) , TMP->CR_TOTAL, TMP->CR_WF,, TMP->C7_NUMSC )
		_lProcesso := .T.
		
		// Fazer o tratamento quando houver o mesmo usuario na
		// alcada de aprovacao:
		
		DbSelectarea("SCR")
		DbSetOrder(2)
		IF DbSeek(TMP->(CR_FILIAL+CR_TIPO+CR_NUM+CR_USER))
			
			While !Eof() .And. SCR->(CR_FILIAL+CR_TIPO+CR_NUM+CR_USER) == TMP->(CR_FILIAL+CR_TIPO+CR_NUM+CR_USER) .And.;
				SCR->CR_STATUS == '03'
				DbSkip()
			EndDo
			
			If SCR->(CR_FILIAL+CR_TIPO+CR_NUM+CR_USER) == TMP->(CR_FILIAL+CR_TIPO+CR_NUM+CR_USER)
				Reclock("SCR",.F.)
				SCR->CR_WF		:= "1"					// Status 1 - envio para aprovadores
				If SCR->( FieldPos( "CR_WFID" ) ) > 0
					SCR->CR_WFID	:= _cWFId			// Rastreabilidade
				EndIf
				MSUnlock()
			EndIf
		ENDIF
		
		TMP->(DbSkip())
	EndDo
	
	TMP->( dbCloseArea() )
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ2 - Processa O RETORNO DO EMAIL                       ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
ElseIf _nOPC == 2
	
	U_xCONSOLE("2 - Processa O RETORNO DO EMAIL", .F.)
	U_xCONSOLE("2 - Semaforo Vermelho", .F. )
	
	IIF( Select( 'TMP' ) > 0 , TMP->( dbCloseArea() ) , Nil )
	ChkFile("SC7")
	ChkFile("SCR")
	ChkFile("SAL")
	ChkFile("SC1")
	ChkFile("SCS")
	ChkFile("SAK")
	ChkFile("SM2")
	
	If !( oProcess == Nil )
		cFilAnt		:= oProcess:aParams[1]
		cChaveSCR	:= AllTrim(oProcess:aParams[2])
		cOpc     	:= alltrim(oProcess:oHtml:RetByName("OPC"))
		cObs     	:= alltrim(oProcess:oHtml:RetByName("OBS"))
		cWFID     	:= alltrim(oProcess:oHtml:RetByName("WFID"))
		cWF       	:= alltrim(oProcess:oHtml:RetByName("WF")) //cWF -> ' '-Nao Enviado / 3-rejeitado por saldo insuficiente no retorno
		
		U_xCONSOLE( 'APARAMS'+ oProcess:aParams[2] )
		U_xCONSOLE("2 - Chave :" + cChaveSCR, .F.)
		U_xCONSOLE("2 - Opc   :" + cOpc, .F.)
		U_xCONSOLE("2 - Obs: "+ cObs)
		
		If cOpc	$ "S|N"  // Aprovacao S-Sim N-Nao
			
			// Posiciona na tabela de Alcadas
			dbSelectArea( "SCR" )
			SCR->( dbOrderNickName( 'SCRWFID001' ) )
			If SCR->( MsSeek( xFilial( 'SCR' ) + Padr( cWFID , TamSx3( 'CR_WFID' )[1] ) ) )
				If !( SCR->CR_RESPOST == CriaVar( 'CR_RESPOST' , .F. ) )
					ConOut( 'PROCESSO ABORTADO E-MAIL JA RESPONDIDO ==>> PROCESSO [ '+ cWFID +' ]' )
					Return .F.
				EndIf
			EndIf
			
			dbSelectArea( "SCR" )
			SCR->( dbSetOrder( 2 ) )
			If SCR->( dbSeek( cChaveSCR ) )
				xTipo := AllTrim( SCR->CR_XTPLIB )
				
				While SCR->( !Eof() ) .And. SCR->(CR_FILIAL+CR_TIPO+CR_NUM+CR_USER) == cChaveSCR .And. SCR->CR_STATUS == '03'
					SCR->( dbSkip() )
				EndDo
				
				If SCR->( FieldPos( "CR_WFID" ) ) > 0 .And. TRIM(SCR->CR_WFID) <> TRIM(cWFID)
					//"Este processo nao foi encontrado e portanto deve ser descartado
					// abre uma notificacao a pessoa que respondeu
					
					U_xCONSOLE("2 - Primeira Critica: "+IIF(!FOUND(),"Sim","Nao"), .F. )
					U_xCONSOLE("2 - Segunda Critica: "+IIF(TRIM(SCR->CR_WFID) <> TRIM(cWFID),"Sim","Nao"), .F. )
					
					U_xCONSOLE("2 - SCR->CR_WFID: "+SCR->CR_WFID)
					U_xCONSOLE("2 - cWFID		 : "+cWFID)
					
					
					Return .T.
				EndIf
				
				If SCR->(CR_FILIAL+CR_TIPO+CR_NUM+CR_USER) <> cChaveSCR
					ConOut('2- Fim de Processo(Mesmo Aprovador)')
					Return // Fim de Processo
				EndIf
				
				Reclock("SCR",.F.)
				SCR->CR_WF		:= "2"			// Status 2 - respondido
				MSUnlock()
				
				If !Empty( SCR->CR_DATALIB ) .And. SCR->CR_STATUS $ "03#04#05"
					U_xCONSOLE("2 - Semaforo Verde", .F. )
					Return .T.
				EndIf
				
				DbSelectArea('SC7')
				DbSetOrder(1)
				DbSeek(xFilial('SC7')+Trim(SCR->CR_NUM))
				nRecSC7 := 0
				nRecSC7 := SC7->( Recno() )
				
				
				// REPosiciona na tabela de Alcadas
				DbSelectArea("SCR")
				DbSetOrder(2)
				DbSeek(cChaveSCR)
				
				While SCR->( !Eof() ) .And. SCR->(CR_FILIAL+CR_TIPO+CR_NUM+CR_USER) == cChaveSCR .And. SCR->CR_STATUS == '03'
					SCR->( dbSkip() )
				EndDo
				
				lRejeita := .F.
				nRecSCR := 0
				nRecSCR := SCR->( Recno() )
				lLiberou := U_AlcAprv({ SCR->CR_NUM,"PC",nTotal, SCR->CR_APROV,,SC7->C7_APROV,,,,,cObs},dDataBase,If(cOpc=="S",4,6), cWF,.F., cChaveSCR, @lRejeita , cOpc )
				
				If lLiberou .And. !lRejeita
					If xTipo == 'V'
						ConOut(' USUARIO TIPO [ '+ xTipo +' ] ==>> PEDIDO NAO LIBERADO - FILIAL + PEDIDO: '+Left(cChaveSCR,2)+'/'+SubStr(cChaveSCR,5,6))
					Else
						ConOut(' USUARIO TIPO [ '+ xTipo +' ] ==>> PEDIDO LIBERADO - FILIAL + PEDIDO: '+Left(cChaveSCR,2)+'/'+SubStr(cChaveSCR,5,6))
						ConOut( 'PEDIDO "'+ IIF( lRejeita == .T. , 'R' , 'L' ) +'" ')
						ConOut(' ATUALIZANDO SC7 ---- USUARIO TIPO [ '+ xTipo +' ] ==>> PEDIDO LIBERADO - FILIAL + PEDIDO: '+Left(cChaveSCR,2)+'/'+SubStr(cChaveSCR,5,6))
						
						//INICIO CHAMADO 033773 - WILLIAM COSTA
						dbSelectArea("ZBE")
						RecLock("ZBE",.T.)
							Replace ZBE_FILIAL 	   	WITH xFilial("ZBE")
							Replace ZBE_DATA 	   	WITH dDataBase
							Replace ZBE_HORA 	   	WITH TIME()
							Replace ZBE_USUARI	    WITH UPPER(Alltrim(cUserName))
							Replace ZBE_LOG	        WITH ("RCOMW01-1 " + " WHERE C7_FILIAL =  Left(cChaveSCR,2) : " + Left(cChaveSCR,2)  + " AND   C7_NUM = SubStr(cChaveSCR,5,6) : " + SubStr(cChaveSCR,5,6) + " Variavel: " + IIF( lRejeita == .T. , 'R' , 'L' ) + " nRecSC7: " + cValToChar(nRecSC7) + " nRecSCR: " + cValToChar(nRecSCR))  
							Replace ZBE_MODULO	    WITH "COMPRAS"
							Replace ZBE_ROTINA	    WITH "RCOMW01" 
						MsUnlock()
						ZBE->(dbCloseArea())
						
						DbSelectArea("SCR")
						//FINAL CHAMADO 033773 - WILLIAM COSTA  
						// RICARDO LIMA - 13/11/17
						_cExec := " UPDATE "+ RetSQLName('SC7')+" SET C7_CONAPRO = '"+ IIF( lRejeita == .T. , 'R' , 'L' ) +"' , C7_XWFID = '"+ cWFID +"' "
						_cExec += " WHERE C7_FILIAL = '"+Left(cChaveSCR,2)+"' "
						_cExec += " AND   C7_NUM = '"+SubStr(cChaveSCR,5,6)+"' "
						_cExec += " AND   D_E_L_E_T_ = '"+ Space( 1 ) +"' "
						
						If TcSQLExec( _cExec ) < 0
							ConOut( 'Data :'+ Dtoc( MsDate() ) +' - Hora: '+ Time() +' ' )
							ConOut( 'ERRO NA LIBERACAO DO PEDIDO DE COMPRA [ '+SubStr(cChaveSCR,5,6)+' ]')
							ConOut( ''+TcSQLError()+'')
							Return .T.
						EndIf
						
						SC7->( dbGoto( nRecSC7 ) )
						SCR->( dbGoto( nRecSCR ) )
						
						_cWFId 	:= EnviaPC( SC7->C7_FILIAL, SC7->C7_NUM, SC7->C7_USER,, SCR->(CR_FILIAL+CR_TIPO+CR_NUM+CR_USER), SCR->CR_TOTAL, "5",, SC7->C7_NUMSC )
						// RICARDO LIMA - 13/11/17
						_cExec := " UPDATE "+ RetSQLName( 'SC7' ) +" SET C7_XWF	= '9', C7_XWFID	= '"+ _cWFId	+"' "
						_cExec += " WHERE C7_FILIAL = '"+ Left( cChaveSCR, 2 ) +"' "
						_cExec += " AND   C7_NUM = '" + SubStr( cChaveSCR, 5, 6 )+"' "
						_cExec += " AND   D_E_L_E_T_ = '"+ Space( 1 ) +"' "
						
						If TcSQLExec( _cExec ) < 0
							ConOut( 'Data :'+ Dtoc( MsDate() ) +' - Hora: '+ Time() +' ' )
							ConOut( 'ERRO NA ATUALIZACAO DO PEDIDO DE COMPRA [ '+SubStr(cChaveSCR,5,6)+' ]')
							ConOut( ''+TcSQLError()+'')
							Return .T.
						EndIf
						
					EndIf
					
					If lRejeita
						
						ConOut( 'PEDIDO : "'+ IIF( lRejeita == .T. , 'R' , 'L' ) +'" ')
						ConOut(' Pedido REJEITADO - FILIAL + PEDIDO: '+Left(cChaveSCR,2)+'/'+SubStr(cChaveSCR,5,6))
						
						//INICIO CHAMADO 033773 - WILLIAM COSTA
						dbSelectArea("ZBE")
						RecLock("ZBE",.T.)
							Replace ZBE_FILIAL 	   	WITH xFilial("ZBE")
							Replace ZBE_DATA 	   	WITH dDataBase
							Replace ZBE_HORA 	   	WITH TIME()
							Replace ZBE_USUARI	    WITH UPPER(Alltrim(cUserName))
							Replace ZBE_LOG	        WITH ("RCOMW01-2 " + " WHERE C7_FILIAL =  Left(cChaveSCR,2) : " + Left(cChaveSCR,2)  + " AND   C7_NUM = SubStr(cChaveSCR,5,6) : " + SubStr(cChaveSCR,5,6) + " Variavel: " + 'R' + " nRecSC7: " + cValToChar(nRecSC7) + " nRecSCR: " + cValToChar(nRecSCR))  
							Replace ZBE_MODULO	    WITH "COMPRAS"
							Replace ZBE_ROTINA	    WITH "RCOMW01" 
						MsUnlock()
						ZBE->(dbCloseArea())
						
						DbSelectArea("SCR")
						//FINAL CHAMADO 033773 - WILLIAM COSTA  
						
						_cExec := " UPDATE "+ RetSQLName('SC7')+" SET C7_CONAPRO = 'R' "
						_cExec += " WHERE C7_FILIAL = '"+Left(cChaveSCR,2)+"' "
						_cExec += " AND   C7_NUM = '"+SubStr(cChaveSCR,5,6)+"' "
						_cExec += " AND   D_E_L_E_T_ = '"+ Space( 1 ) +"' "
						
						If TcSQLExec( _cExec ) < 0
							ConOut( 'Data :'+ Dtoc( MsDate() ) +' - Hora: '+ Time() +' ' )
							ConOut( 'ERRO NA LIBERACAO DO PEDIDO DE COMPRA [ '+SubStr(cChaveSCR,5,6)+' ]')
							ConOut( ''+TcSQLError()+'')
							Return .T.
						EndIf
						
						SC7->( dbGoto( nRecSC7 ) )
						SCR->( dbGoto( nRecSCR ) )
						
						_cWFId 	:= EnviaPC( SCR->CR_FILIAL, SCR->CR_NUM, SCR->CR_USER, SCR->CR_APROV, SCR->(CR_FILIAL+CR_TIPO+CR_NUM+CR_USER), SCR->CR_TOTAL, "4",, Posicione( 'SC7',1, xFilial('SC7') + SCR->CR_NUM , 'C7_NUMSC' )  )
						
						Reclock("SCR",.F.)
						SCR->CR_WF		:= "9"			// Status 1 - envio email
						SCR->CR_WFID	:= _cWFId		// Rastreabilidade
						SCR->( MsUnLock() )
						
					EndIf
					
				Else
					
					ConOut(' USUARIO TIPO [ '+ xTipo +' ] ==>> PEDIDO NAO LIBERADO - FILIAL + PEDIDO: '+Left(cChaveSCR,2)+'/'+SubStr(cChaveSCR,5,6))
					ConOut( 'PEDIDO "'+ IIF( lRejeita == .T. , 'R' , 'L' ) +'" ')
					
					If xTipo == 'A'
						ConOut(' ATUALIZANDO SC7 ---- USUARIO TIPO [ '+ xTipo +' ] ==>> PEDIDO LIBERADO - FILIAL + PEDIDO: '+Left(cChaveSCR,2)+'/'+SubStr(cChaveSCR,5,6))
						
						//INICIO CHAMADO 033773 - WILLIAM COSTA
						dbSelectArea("ZBE")
						RecLock("ZBE",.T.)
							Replace ZBE_FILIAL 	   	WITH xFilial("ZBE")
							Replace ZBE_DATA 	   	WITH dDataBase
							Replace ZBE_HORA 	   	WITH TIME()
							Replace ZBE_USUARI	    WITH UPPER(Alltrim(cUserName))
							Replace ZBE_LOG	        WITH ("RCOMW01-3 " + " WHERE C7_FILIAL =  Left(cChaveSCR,2) : " + Left(cChaveSCR,2)  + " AND   C7_NUM = SubStr(cChaveSCR,5,6) : " + SubStr(cChaveSCR,5,6) + " Variavel: " + IIF( lRejeita == .T. , 'R' , 'L' ) + " nRecSC7: " + cValToChar(nRecSC7) + " nRecSCR: " + cValToChar(nRecSCR))  
							Replace ZBE_MODULO	    WITH "COMPRAS"
							Replace ZBE_ROTINA	    WITH "RCOMW01" 
						MsUnlock()
						ZBE->(dbCloseArea())
						
						DbSelectArea("SCR")
						//FINAL CHAMADO 033773 - WILLIAM COSTA  
						// RICARDO LIMA - 13/11/17
						_cExec := " UPDATE "+ RetSQLName('SC7')+" SET C7_CONAPRO = '"+ IIF( lRejeita == .T. , 'R' , 'L' ) +"' , C7_XWFID = '"+ cWFID +"' "
						_cExec += " WHERE C7_FILIAL = '"+Left(cChaveSCR,2)+"' "
						_cExec += " AND   C7_NUM = '"+SubStr(cChaveSCR,5,6)+"' "
						_cExec += " AND   D_E_L_E_T_ = '"+ Space( 1 ) +"' "
						
						If TcSQLExec( _cExec ) < 0
							ConOut( 'Data :'+ Dtoc( MsDate() ) +' - Hora: '+ Time() +' ' )
							ConOut( 'ERRO NA LIBERACAO DO PEDIDO DE COMPRA [ '+SubStr(cChaveSCR,5,6)+' ]')
							ConOut( ''+TcSQLError()+'')
							Return .T.
						EndIf
					Else
						ConOut( 'USUARIO VISTADOR ==>> PEDIDO DE VENDA NAO ATUALIZADO')
						While SCR->( !Eof() ) .And. SCR->CR_FILIAL == SubStr( cChaveSCR , 1 , 2 ) .And. SCR->CR_NUM == SubStr( cChaveSCR , 3,6 )
							
							If SCR->CR_STATUS == '02' .And. !( SCR->CR_RESPOST == CriaVar( 'CR_RESPOST' , .F. ) ) .And. SCR->CR_XTPLIB == 'V'
								ConOut( 'CR Respondido pelo Vistador [ '+ SCR->CR_USER +' ] ' )
								SCR->( dbSkip() )
								Loop
							EndIf
							
							If SCR->CR_STATUS == '01' .And. SCR->CR_RESPOST == CriaVar( 'CR_RESPOST' , .F. ) .And. SCR->CR_XTPLIB == 'V'
								ConOut( 'Troco o STATUS DO APROVADOR [ '+ SCR->CR_STATUS +' ] VISTADOR ')
								RecLock( 'SCR', .F. )
								SCR->CR_STATUS := '02'
								SCR->( MsUnLock() )
								Exit
							EndIf
							
							If SCR->CR_STATUS == '01' .And. SCR->CR_RESPOST == CriaVar( 'CR_RESPOST' , .F. ) .And. SCR->CR_XTPLIB == 'A'
								ConOut( 'Troco o STATUS DO APROVADOR [ '+ SCR->CR_STATUS +' ] APROVADOR')
								RecLock( 'SCR', .F. )
								SCR->CR_STATUS := '02'
								SCR->( MsUnLock() )
								Exit
							EndIf
							
							SCR->( dbSkip() )
						EndDO
						
					EndIf
					
					If lRejeita
						
						ConOut( 'PEDIDO : "'+ IIF( lRejeita == .T. , 'R' , 'L' ) +'" ')
						ConOut(' Pedido REJEITADO - FILIAL + PEDIDO: '+Left(cChaveSCR,2)+'/'+SubStr(cChaveSCR,5,6))
						
						//INICIO CHAMADO 033773 - WILLIAM COSTA
						dbSelectArea("ZBE")
						RecLock("ZBE",.T.)
							Replace ZBE_FILIAL 	   	WITH xFilial("ZBE")
							Replace ZBE_DATA 	   	WITH dDataBase
							Replace ZBE_HORA 	   	WITH TIME()
							Replace ZBE_USUARI	    WITH UPPER(Alltrim(cUserName))
							Replace ZBE_LOG	        WITH ("RCOMW01-4 " + " WHERE C7_FILIAL =  Left(cChaveSCR,2) : " + Left(cChaveSCR,2)  + " AND   C7_NUM = SubStr(cChaveSCR,5,6) : " + SubStr(cChaveSCR,5,6) + " Variavel: " + 'R' + " nRecSC7: " + cValToChar(nRecSC7) + " nRecSCR: " + cValToChar(nRecSCR))  
							Replace ZBE_MODULO	    WITH "COMPRAS"
							Replace ZBE_ROTINA	    WITH "RCOMW01" 
						MsUnlock()
						ZBE->(dbCloseArea())
						
						DbSelectArea("SCR")
						//FINAL CHAMADO 033773 - WILLIAM COSTA 
						
						_cExec := " UPDATE "+ RetSQLName('SC7')+" SET C7_CONAPRO = 'R' "
						_cExec += " WHERE C7_FILIAL = '"+Left(cChaveSCR,2)+"' "
						_cExec += " AND   C7_NUM = '"+SubStr(cChaveSCR,5,6)+"' "
						_cExec += " AND   D_E_L_E_T_ = '"+ Space( 1 ) +"' "
						
						If TcSQLExec( _cExec ) < 0
							ConOut( 'Data :'+ Dtoc( MsDate() ) +' - Hora: '+ Time() +' ' )
							ConOut( 'ERRO NA LIBERACAO DO PEDIDO DE COMPRA [ '+SubStr(cChaveSCR,5,6)+' ]')
							ConOut( ''+TcSQLError()+'')
							Return .T.
						EndIf
						
						SC7->( dbGoto( nRecSC7 ) )
						SCR->( dbGoto( nRecSCR ) )
						
						_cWFId 	:= EnviaPC( SCR->CR_FILIAL, SCR->CR_NUM, SCR->CR_USER, SCR->CR_APROV, SCR->(CR_FILIAL+CR_TIPO+CR_NUM+CR_USER), SCR->CR_TOTAL, "4",, Posicione( 'SC7',1, xFilial('SC7') + SCR->CR_NUM , 'C7_NUMSC' )  )
						
						Reclock("SCR",.F.)
						SCR->CR_WF		:= "9"			// Status 1 - envio email
						SCR->CR_WFID	:= _cWFId		// Rastreabilidade
						SCR->( MsUnLock() )
						
					EndIf
					
				EndIf
			Else
				U_xCONSOLE( '99 - NAO FOI POSSIVEL LOCALIZAR A CHAVE [ '+ cChaveSCR +' ]')
				oProcess:Finish() // FINALIZA O PROCE
			EndIf
		Else
			cFilAnt		:= '01'
			cChaveSCR	:= '01PC000023                                            000001'
			cOpc     	:= 'N'
			cObs     	:= ''
			cWFID     	:= '               '
			cWF       	:= ' '
		EndIf
		
		U_xCONSOLE("2 - Semaforo Verde", .F. )
	EndIf
	
ElseIf _nOpc == 3
	
	U_xCONSOLE("3 - Envia resposta de Pedido bloqueado para o Comprador", .F.)
	
	IIF( Select( 'TMP' ) > 0 , TMP->( dbCloseArea() ) , Nil )
	CHKfile("SC7")	// P. de Compras
	CHKFile("SCR")  // Documentos com al็adas
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Seleciona os registros do SCR - DbF / INDREGUA                         ณ
	//ณ Abre um novo Alias para evitar problemas com filtros ja existentes.    ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	
	cQuery := " SELECT SCR.* "
	cQuery += " FROM "+ RetSQLName( 'SCR' ) +" SCR "
	cQuery += " WHERE SCR.CR_FILIAL = '"+ xFilial( 'SCR' ) +"' "
	cQuery += " AND SCR.CR_TIPO = 'PC' "
	cQuery += " AND SCR.CR_STATUS = '04' "
	cQuery += " AND SCR.CR_WF IN ( '"+ CriaVar( 'CR_WF' , .F. ) +"', '2' ) "
	cQuery += " AND SCR.D_E_L_E_T_ = '"+ Space( 1 ) +"' "
	cQuery += " ORDER BY SCR.CR_FILIAL, SCR.CR_NUM "
	cQuery := ChangeQuery( cQuery )
	
	IIF( Select( 'TMP' ) > 0 , TMP->( dbCloseArea() ) , Nil )
	dbUseArea( .T. , __cRdd , TcGenQry( ,, cQuery ) , 'TMP' , .T. , .F. )
	dbSelectArea( 'TMP' )
	TMP->( dbGotop() )
	
	While TMP->( !Eof() )
		_cWFId 	:= EnviaPC(TMP->CR_FILIAL, TMP->CR_NUM, TMP->CR_USER, TMP->CR_APROV, TMP->(CR_FILIAL+CR_TIPO+CR_NUM+CR_USER), TMP->CR_TOTAL, "4",, Posicione( 'SC7',1, xFilial('SC7') + TMP->CR_NUM , 'C7_NUMSC' )  )
		
		DbSelectarea("SCR")
		DbSetOrder(2)
		IF DbSeek(TMP->(CR_FILIAL+CR_TIPO+CR_NUM+CR_USER))
			
			While !Eof() .And. SCR->(CR_FILIAL+CR_TIPO+CR_NUM+CR_USER) == TMP->(CR_FILIAL+CR_TIPO+CR_NUM+CR_USER) .And.;
				SCR->CR_STATUS # '04'
				DbSkip()
			EndDo
			
			Reclock("SCR",.F.)
			SCR->CR_WF		:= "9"			// Status 1 - envio email
			SCR->CR_WFID	:= _cWFId		// Rastreabilidade
			MSUnlock()
		ENDIF
		
		_lProcesso := .T.
		
		TMP->( dbSkip() )
	EndDo
	
	TMP->( dbCloseArea() )
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ4 - Processa O RETORNO DO EMAIL DE SC REPROVADA       ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	
ElseIf _nOPC == 4
	
	U_xCONSOLE("4 - Processa O RETORNO DO EMAIL DE PEDIDO DE COMPRA REPROVADO", .F.)
	U_xCONSOLE("4 - Semaforo Vermelho", .F. )
	
	ChkFile("SCR")
	ChkFile("SC1")
	ChkFile("SC7")
	ChkFile("SM2")
	
	DbSelectArea('SX3')
	DbSetOrder(2)
	
	If oprocess <> nil
		cFilAnt		:= alltrim(oProcess:oHtml:RetByName("CFILANT"))
		cChaveSCR	:= xFilial('SC1')+alltrim(oProcess:oHtml:RetByName("CHAVE"))
		cOpc     	:= alltrim(oProcess:oHtml:RetByName("OPC"))
		cWFID     	:= alltrim(oProcess:oHtml:RetByName("WFID"))
		cObs     	:= alltrim(oProcess:oHtml:RetByName("OBS"))
		
		U_xCONSOLE("4 - Chave :" + cChaveSCR, .F.)
		U_xCONSOLE("4 - Opc   :" + cOpc, .F.)
		oProcess:Finish() // FINALIZA O PROCESSO
	ENDIF
	
	// Posiciona na tabela de Alcadas
	DbSelectArea("SCR")
	DbSetOrder(2)
	DbSeek(cChaveSCR)
	
	If !Found()
		Return .t.
	EndIf
	
	While !Eof() .And. SCR->(CR_FILIAL+CR_TIPO+CR_NUM+CR_USER) == cChaveSCR .And.	SCR->CR_STATUS # '04'
		DbSkip()
	EndDo
	
	IF TRIM(SCR->CR_WFID) <> TRIM(cWFID)
		U_xCONSOLE("4 - Semaforo Verde(ID Diferentes)", .F. )
		Return .T.
	ENDIF
	
	Reclock("SCR",.F.)
	SCR->CR_WF	:= "3"	// Status 2 - respondido
	MSUnlock()
	
	DbSelectArea("SC7")
	DbSetOrder(1)
	DbSeek(xFilial('SC7')+Alltrim(SCR->CR_NUM))
	
	IF !FOUND()
		U_xCONSOLE("4 - Semaforo Verde", .F. )
		Return .T.
	ENDIF
	
	DbSelectArea("SAL")
	DbSetOrder(3)
	DbSeek(xFilial()+SC7->C7_APROV+SCR->CR_APROV)
	
	IF cOpc	== "S"  // Submete a SC de compra a nova aprova็ใo ?
		//lEstorna := U_AlcAprv({SCR->CR_NUM,"PC",SCR->CR_TOTAL,SCR->CR_LIBAPRO,,SC7->C7_APROV,,,,,cObs},SC7->C7_EMISSAO,5)
		lEstorna	:= .T.
		
		_lProcesso := .T.
		
		DbSelectArea("SC7")
		DbSetOrder(1)
		DbSeek(xFilial('SC7')+Alltrim(SCR->CR_NUM))
		
	Else  // Estornar o PC para eliminar o empenho Desnecessario:
		_lProcesso := .T.
		
		If SuperGetMv( 'MV_X_EXCPC',,.F.) == .t.
			
			DbSelectArea("SC7")
			DbSetOrder(1)
			If DbSeek(xFilial('SC7')+Alltrim(SCR->CR_NUM))
				
				_cSoli   := SC7->C7_USER
				_nRegSC7 := Recno()
				
				// Estornar a SC para eliminar o empenho desnecessario:
				
				aCabc7:={  {"C7_NUM" ,SC7->C7_NUM, Nil},; // Numero
				{"C7_EMISSAO" ,SC7->C7_EMISSAO, Nil},; // Data de Emissao
				{"C7_FORNECE" ,SC7->C7_FORNECE		,Nil},; // Fornecedor
				{"C7_LOJA"    ,SC7->C7_LOJA		,Nil},; // Loja do Fornecedor
				{"C7_COND"    ,SC7->C7_COND        ,Nil},; // Condicao de pagamento
				{"C7_CONTATO" ,SC7->C7_CONTATO	,Nil},; // Contato
				{"C7_FILENT"  ,xFilial("SC7")	,Nil}} // Filial Entrega
				
				aItemC7 := {}
				
				_aStru := SC7->(DbStruct())
				
				While !Eof() .And. SC7->(C7_FILIAL+C7_NUM) == _cChave
					
					For _i := 1 To Len(_aStru)
						
						DbSelectArea('SX3')
						DbSeek(_aStru[_i][1])
						If X3USO(x3_usado) // Pegar apenas os campos usados
							aAdd(aItemC7, {{ _aStru[_i][1] ,SC7->&(_aStru[_i][1]) ,Nil} } )
						EndIf
						
					Next
					
					DbSelectArea('SC7')
					DbSkip()
					
				EndDo
				
				SC7->(DbGoTo(_nRegSC7))
				
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณExecuta a rotina automatica para o Estorno da Solicitacao de Compra.ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				
				lMsErroAuto := .f.
				
				// Adequacao - Apenas para que o Workflow consiga excluir o PC:
				
				_cRestCom := GetMV('MV_RESTCOM')
				PutMv("MV_RESTCOM", "N")
				
				MATA120(1,aCabC7,aItemC7,5)
				
				// Voltar ao que era antes:
				
				PutMv("MV_RESTCOM", _cRestCom)
				
				SC7->(DbGoTo(_nRegSC7))
				
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณEnvia  erro na geracao da rotina  automatica. ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				If lMsErroAuto
					
					cAssunto := "Problema no Pedido de Compra: " + SC7->C7_NUM + ' / '+SC7->C7_FILIAL
					cTitulo  := 'Problema com Relacao ap PC Nro. '+ SC7->C7_NUM + ' / '+SC7->C7_FILIAL
					cDetalhe := 'Houve um erro no momento da Exclusao do PC. '
					cDetalhe += 'Analise o Log em anexo e proceda com a correcao. '
					_cUsuario := SuperGetMV("MV_WFADMIN",,"000000") // Mandar para o Administrador
					U_Rcomw06( cAssunto, cTitulo, cDetalhe, _cUsuario, GetSrvProfString('\Startpath\','')+NomeAutoLog() )
					
					// Avisr ao usuario quando o Workflow exclui o Documento:
				Else
					
					cAssunto := "Pedido de Compras Excluido: " + Right(_cChave,6)
					cTitulo  := 'Foi solicitado a exclusao do PC Nro. '+ Right(_cChave,6) + ' / '+xFilial('SC7')
					cDetalhe := 'Este Pedido de compra foi rejeitado pelo(s) aprovador(es). '
					cDetalhe += Trim(UsrFullName(_cSoli))+', Voce solicitou a exclusao deste documento. '
					_cUsuario := Upper(UsrRetMail(_cSoli))
					U_Rcomw06( cAssunto, cTitulo, cDetalhe, _cUsuario, Nil )
					
				EndIf
				
				// Estornar as alcadas:
				
				_cExec := " DELETE FROM "+RetSqlName('SCR')
				_cExec += " WHERE CR_FILIAL = '"+xFilial('SCR')+"' "
				_cExec += " AND   CR_TIPO   = 'PC' "
				_cExec += " AND   CR_NUM    = '"+Right(_cChave,6)+"' "
				_cExec += " AND   D_E_L_E_T_ = ' ' "
				
				TcSqlExec(_cExec)
				
			EndIf
			
		EndIf
		
	EndIf
	
	U_xCONSOLE("4 - Semaforo Verde", .F. )
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ5 - Envia resposta de pedido aprovado para o compradorณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	
ElseIf _nOpc == 5
	
	U_xCONSOLE("5 - Envia resposta de Pedido APROVADO para o Comprador", .F.)
	
	CHKFile("SCR")              // Documentos com al็adas
	CHKFile("SC7")
	// RICARDO LIMA - 13/11/17
	cQuery := " SELECT SC7.* "
	cQuery += " FROM "+ RetSQLName( 'SC7' ) +" SC7 "
	cQuery += " WHERE SC7.C7_FILIAL = '"+ xFilial( 'SC7' ) +"' "
	cQuery += " AND SC7.C7_TIPO = '1' "
	cQuery += " AND SC7.C7_CONAPRO = 'L' "
	cQuery += " AND SC7.C7_XWF <> '9' "
	cQuery += " AND SC7.C7_XWFID <> '"+ CriaVar( 'C7_XWFID' , .F. ) +"' "
	cQuery += " AND SC7.D_E_L_E_T_ = '"+ Space( 1 ) +"' "
	cQuery += " ORDER BY SC7.C7_FILIAL , SC7.C7_NUM , SC7.C7_ITEM "
	cQuery := ChangeQuery( cQuery )
	
	IIF( Select( 'TMP' ) > 0 , TMP->( dbCloseArea() ) , Nil )
	dbUseArea( .T. , __cRdd , TcGenQry( ,, cQuery ) , 'TMP' , .T. , .F. )
	dbSelectArea( 'TMP' )
	TMP->( dbGotop() )
	While TMP->( !Eof() )
		
		_cNum	:= TMP->C7_NUM
		_cWFID   := ""
		
		DbSelectarea("SCR")
		DbSetOrder(1)
		If !DbSeek(TMP->(C7_FILIAL+"PC"+C7_NUM),.T.)
			DbSelectArea('TMP')
			DbSkip()
			Loop
		EndIf
		
		IF TMP->C7_FILIAL 	== SCR->CR_FILIAL 	.AND. ;
			SCR->CR_TIPO 	== "PC" 			.AND. ;
			TRIM(TMP->C7_NUM) 	== TRIM(SCR->CR_NUM)
			
			_cWFId 	:= EnviaPC(TMP->C7_FILIAL, TMP->C7_NUM, TMP->C7_USER,, SCR->(CR_FILIAL+CR_TIPO+CR_NUM+CR_USER), SCR->CR_TOTAL, "5",, TMP->C7_NUMSC )
			_lProcesso := .T.
		ENDIF
		
		While !TMP->(EOF()) .AND. _cNum == TMP->C7_NUM .AND. !EMPTY(_cWFID)
			_cNum	:= TMP->C7_NUM
			
			dbSelectarea( 'SC7' )
			SC7->( dbSetOrder( 1 ) )
			If SC7->( dbSeek( TMP->( C7_FILIAL + C7_NUM + C7_ITEM ) ) )
				Reclock("SC7",.F.)
				SC7->C7_XWF		:= "9"			// Status 1 - envio email // RICARDO LIMA - 13/11/17
				SC7->C7_XWFID	:= _cWFId		// Rastreabilidade        // RICARDO LIMA - 13/11/17
				SC7->( MsUnLock() )
			EndIf
			TMP->( dbSkip() )
		EndDo
	EndDo
	
	TMP->( dbCloseArea() )
	
ElseIf _nOpc == 6
	
	U_xCONSOLE("6 - Processamento de TimeOut", .F.)
	
	CHKfile("SC7")	// Solicitacao de Compras
	CHKFile("SCR")  // Documentos com al็adas
	CHKFile("SCR",.F.,"TMP")
	
	_cSelect := " SELECT R_E_C_N_O_ REG "
	_cSelect += " FROM "+RetSqlName('SCR')
	_cSelect += " WHERE CR_FILIAL = '"+xFilial('SCR')+"' "
	_cSelect += " AND   CR_TIPO = 'PC' "
	_cSelect += " AND   CR_NUM  = '"+oProcess+"' "
	_cSelect += " AND   CR_STATUS = '02' "
	_cSelect += " AND   CR_WF = '1' "
	_cSelect += " AND   D_E_L_E_T_ = ' ' "
	
	U_MontaView( _cSelect, 'TTTMMMPPP' )
	
	TTTMMMPPP->(DbGoTop())
	
	If TTTMMMPPP->(Eof())
		ConOut('Time-Out sem prosseguimento')
		TMP->( dbCloseArea() )
		Return .T.
	EndIf
	
	dbSelectArea('TMP')
	dbGoTo( TTTMMMPPP->REG )
	
	_cWFId 	:= EnviaPC(TMP->CR_FILIAL, TMP->CR_NUM, TMP->CR_USER , TMP->CR_APROV, TMP->(CR_FILIAL+CR_TIPO+CR_NUM+CR_USER), TMP->CR_TOTAL, "", _nOpc)
	_lProcesso := .T.
	
	dbSelectArea('TMP')
	dbGoTo( TTTMMMPPP->REG )
	
	RecLock("TMP",.F.)
	TMP->CR_WFID := _cWFId		// Rastreabilidade
	TMP->( MsUnLock() )
	
	TMP->( dbCloseArea() )
	
ElseIf _nOpc == 7
	U_xCONSOLE("7 - Prepara os Pedidos a serem enviadas para aprovacao NIVEL 2", .F.)
	dbSelectArea( 'SCR' )
	SCR->( dbSetOrder( 1 ) )
	// RICARDO LIMA - 13/11/17
	cQuery := " SELECT DISTINCT SCR.* , SC7.C7_NUMSC "
	cQuery += " FROM "+ RetSQLName( 'SCR' ) +" SCR "
	cQuery += " INNER JOIN "+ RetSQLName( 'SC7' ) +" SC7 ON "
	cQuery += " SC7.C7_FILIAL = '"+ xFilial( 'SC7' ) +"' "
	cQuery += " AND SCR.CR_FILIAL = '"+ xFilial( 'SCR' ) +"' "
	cQuery += " AND SCR.CR_NUM = SC7.C7_NUM "
	cQuery += " WHERE SC7.C7_XWFID = '"+ CriaVar( 'C7_XWFID' , .F. ) +"' "
	cQuery += " AND SC7.C7_CONAPRO = 'B' "
	cQuery += " AND SCR.CR_TIPO = 'PC' "
	cQuery += " AND SCR.CR_RESPOST = '"+ CriaVar( 'CR_RESPOST' , .F. ) +"' "
	cQuery += " AND SCR.CR_WF = '"+ CriaVar( 'CR_WF' , .F. ) +"' "
	cQuery += " AND SCR.CR_STATUS = '02' "
	cQuery += " AND SCR.CR_XTPLIB = 'A' "
	cQuery += " AND SC7.D_E_L_E_T_ = '"+ Space( 1 ) +"' "
	cQuery += " AND SCR.D_E_L_E_T_ = '"+ Space( 1 ) +"' "
	cQuery += " ORDER BY SCR.CR_FILIAL,SCR.CR_NUM,SCR.CR_NIVEL,SCR.CR_USER "
	cQuery := ChangeQuery( cQuery )
	
	IIF( Select( 'TMP' ) > 0 , TMP->( dbCloseArea() ) , Nil )
	dbUseArea( .T. , __cRdd , TcGenQry( ,,cQuery ), 'TMP', .T. , .F. )
	dbSelectArea( 'TMP' )
	While !TMP->( Eof() )
		nCount 		:= 0
		cNumero 	:= TMP->CR_NUM
		nRecno 		:= TMP->( Recno() )
		nTotal 		:= CalcRet( cNumero )
		lContinua 	:= .F.
		
		If SCR->( MsSeek( xFilial( 'SCR' ) + TMP->CR_TIPO + TMP->CR_NUM + TMP->CR_NIVEL ) )//CR_FILIAL, CR_TIPO, CR_NUM, CR_NIVEL
			While  SCR->( !Eof() ) .And. SCR->CR_FILIAL == xFilial( 'SCR' ) .And. SCR->CR_NUM == cNumero
				
				If SCR->CR_XTPLIB == 'V' .And. SCR->CR_RESPOST == 'S'
					lContinua := .T.
					nCount += 1
				EndIf
				
				SCR->( dbSkip() )
			EndDo
		EndIf
		If !( nCount == ( nTotal - 1 ) ) .And. !lContinua
			ConOut( 'PEDIDO [ '+ cNumero +' ] NAO PODE SER ENVIADO PARA O NIVEL 2 ')
			ConOut( 'POIS NAO FOI VISTADO POR TODOS OS RELACIONADOS' )
			TMP->( dbSkip() ) ; Loop
		EndIf
		
		TMP->( dbGoto( nRecno ) )
		_cWFId 	   := EnviaPC( TMP->CR_FILIAL, TMP->CR_NUM, TMP->CR_USER , TMP->CR_APROV, TMP->( CR_FILIAL + CR_TIPO + CR_NUM + CR_USER ) , TMP->CR_TOTAL, '7',, TMP->C7_NUMSC )
		_lProcesso := .T.
		
		// Fazer o tratamento quando houver o mesmo usuario na
		// alcada de aprovacao:
		
		dbSelectarea("SCR")
		SCR->( dbSetOrder( 2 ) )
		IF SCR->( dbSeek( TMP->( CR_FILIAL+CR_TIPO+CR_NUM+CR_USER ) ) )
			
			While SCR->( !Eof() ) .And. SCR->( CR_FILIAL + CR_TIPO + CR_NUM + CR_USER ) == TMP->( CR_FILIAL + CR_TIPO + CR_NUM + CR_USER ) .And.;
				SCR->CR_STATUS == '03'
				SCR->( dbSkip() )
			EndDo
			
			If SCR->( CR_FILIAL + CR_TIPO + CR_NUM + CR_USER ) == TMP->( CR_FILIAL + CR_TIPO + CR_NUM + CR_USER )
				Reclock("SCR",.F.)
				SCR->CR_WF		:= "1"					// Status 1 - envio para aprovadores
				If SCR->( FieldPos( "CR_WFID" ) ) > 0
					SCR->CR_WFID	:= _cWFId			// Rastreabilidade
				EndIf
				SCR->( MsUnLock() )
			EndIf
		ENDIF
		
		TMP->(DbSkip())
	EndDo
	
ElseIf _nOpc == 8
	
	U_xCONSOLE("8 - ENVIA RESPOSTA DE PEDIDO APROVADO MANUALMENTE NO SISTEMS PARA O COMPRADOR", .F.)
	
	CHKFile("SCR")              // Documentos com al็adas
	CHKFile("SC7")
	// RICARDO LIMA - 13/11/17
	cQuery := " SELECT SC7.* "
	cQuery += " FROM "+ RetSQLName( 'SC7' ) +" SC7 "
	cQuery += " WHERE SC7.C7_FILIAL = '"+ xFilial( 'SC7' ) +"' "
	cQuery += " AND SC7.C7_TIPO = '1' "
	cQuery += " AND SC7.C7_CONAPRO = 'L' "
	cQuery += " AND SC7.C7_XWF = 'M' "
	cQuery += " AND SC7.D_E_L_E_T_ = '"+ Space( 1 ) +"' "
	cQuery += " ORDER BY SC7.C7_FILIAL , SC7.C7_NUM , SC7.C7_ITEM "
	cQuery := ChangeQuery( cQuery )
	
	IIF( Select( 'TMP' ) > 0 , TMP->( dbCloseArea() ) , Nil )
	dbUseArea( .T. , __cRdd , TcGenQry( ,, cQuery ) , 'TMP' , .T. , .F. )
	
	dbSelectArea( 'TMP' )
	TMP->( dbGotop() )
	While TMP->( !Eof() )
		
		_cNum	:= TMP->C7_NUM
		_cWFID   := ""
		
		DbSelectarea("SCR")
		DbSetOrder(1)
		If !DbSeek(TMP->(C7_FILIAL+"PC"+C7_NUM),.T.)
			DbSelectArea('TMP')
			DbSkip()
			Loop
		EndIf
		
		IF TMP->C7_FILIAL 	== SCR->CR_FILIAL .AND. SCR->CR_TIPO 	== "PC" .AND. TRIM(TMP->C7_NUM) == TRIM(SCR->CR_NUM)
			_cWFId 	:= EnviaPC(TMP->C7_FILIAL, TMP->C7_NUM, TMP->C7_USER,, SCR->(CR_FILIAL+CR_TIPO+CR_NUM+CR_USER), SCR->CR_TOTAL, "5",, TMP->C7_NUMSC )
			_lProcesso := .T.
		ENDIF
		
		While !TMP->(EOF()) .AND. _cNum == TMP->C7_NUM .AND. !EMPTY(_cWFID)
			_cNum	:= TMP->C7_NUM
			
			dbSelectarea( 'SC7' )
			SC7->( dbSetOrder( 1 ) )
			
			If SC7->( dbSeek( TMP->( C7_FILIAL + C7_NUM + C7_ITEM ) ) )
				Reclock("SC7",.F.)
				SC7->C7_XWF		:= "9"			// Status 1 - envio email  // RICARDO LIMA - 13/11/17
				SC7->C7_XWFID	:= _cWFId		// Rastreabilidade         // RICARDO LIMA - 13/11/17
				SC7->( MsUnLock() )
			EndIf
			
			TMP->( dbSkip() )
		EndDo
		
		TMP->( dbSkip() )
	EndDo
	
	TMP->( dbCloseArea() )
	
EndIf

If 	_lProcesso
	U_xCONSOLE(" Mensagem processada ", .F. )
Else
	U_xCONSOLE(" Nao houve processamento", .F.)
EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณEnviaPC   บAutor  ณ Sergio Oliveira    บ Data ณ  Ago/2006   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ _cWF ' ' - Envia email para aprovador                      บฑฑ
ฑฑบ          ณ _cWF '3' - Reenvia email para aprovador, foi rejeitado     บฑฑ
ฑฑบ          ณ            por insuficiencia de saldo				      บฑฑ
ฑฑบ          ณ _cWF '4' - Envia email para o comprador informando que o PCบฑฑ
ฑฑบ          ณ            estแ reprovado								  บฑฑ
ฑฑบ          ณ _cWF '5' - Envia email para o comprador informando que o PCบฑฑ
ฑฑบ          ณ            estแ aprovado					     			  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Rcomw01.prw                                                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function EnviaPC(_cFilial,_cNum, _cUser, _cAprov, _cChave , _nTotal, _cWF, _nOpc, ___NumSc )
//EnviaPC(TMP->CR_FILIAL, TMP->CR_NUM, TMP->CR_USER , TMP->CR_APROV, TMP->(CR_FILIAL+CR_TIPO+CR_NUM+CR_USER), TMP->CR_TOTAL, TMP->CR_WF)
Local _cDesCon := '', _cEscolha := '', _cHora := '01', _cTemCt
Local _nPedAtu := 0, _y := 0, _nAchou := 0, _nDesconto := 0, _nTotPed := 0
Local _lEntrei := .f. , _lAlcada := .f., _lCotacao := .f.
Local _nHora   := SuperGetMV('MV_X_HINT',,18)  // Tempo de Time-Out
Local _nDia    := SuperGetMV('MV_X_DIAS',,2)  // Tempo de Time-Out
Local __nCount	:= 0
Local cSC8Alias	:= GetNextAlias()
Local nTotReg	:= 0
Local	cPictQtd:=AvSx3("C8_QUANT",6)
Local	cPictPre:=AvSx3("C8_PRECO",6)



Private _aCtbCcDt := {}, _aSaldoAno := {}, _aOrc := {}, _aAlcada := {}
Private _aDespesa := {}, _aProdFor := {}, _aAplic := {}, _aUrgent := {}
_nVlIpiUn := 0
lDetalhe := .F.
lObs	 := .F.

_cNum := PadR(_cNum,6,' ')

ChkFile("SE4")
ChkFile("SC8")
ChkFile("SA2")
ChkFile("SB1")
ChkFile("SBM")
ChkFile("SAL")
ChkFile("SC1")

DbSelectArea("SAL")
DbSetOrder(3)

DbSelectArea("SC7")
DbSetOrder(1)
DbSeek(_cFilial+_cNum)

DbSelectArea("SC1")
DbSetOrder(1)
DbSeek(xFilial('SC1')+SC7->C7_NUMSC)

DbSelectArea("SA2")
DbSetOrder(1)
DbSeek(xFilial("SA2")+SC7->(C7_FORNECE+C7_LOJA))

_cDesCon := GetAdvFVal( "SE4", "E4_DESCRI", xFilial( "SE4" ) + SC7->C7_COND, 1, "" )

//--------------------------- 1 ENVIO DE EMAIL PARA APROVAวรO
IF EMPTY(TRIM(_cWF))
	oProcess          	:= TWFProcess():New( "000001", "Envio Aprovacao Pedido de Compra :" + _cFilial + "/" +  TRIM(_cNum) )
	oProcess          	:NewTask( "Envio Pedido de Compra : "+_cFilial + _cNum, "\workflow\html\PCAprovacao.htm")
	If _nOpc == 6 // TimeOut
		oProcess:cSubject 	:= _cFilial + "/" +  TRIM(_cNum)+" Time-Out de Aprovacao de Pedido de Compra'
	Else
		oProcess:cSubject 	:= _cFilial + "/" +  TRIM(_cNum)+' Aprovacao de Pedido de Compra'
	EndIf
	oProcess:bReturn  	:= "U_RCOMW01(2)"
	//oProcess:btimeout	:= { { "U_Rcomw01(6,'" + SC7->C7_NUM + "')", _nDia, _nHora, 0, } } // Tempo de TimeOutS
	oProcess:cTo      	:= UPPER( UsrRetMail( _cUser ) )
	
	
	oProcess:UserSiga	:= SC7->C7_USER
	oProcess:NewVersion(.T.)
	lObs				:= .T.
	oHtml				:= oProcess:oHTML
	
	// Hidden Fields
	oHtml:ValByName( "CHAVE"	    , _cChave)
	//aadd((oHtml:ValByName("CHAVE"))	,_cChave)
	oHtml:ValByName( "CFILANT"	    , cFilAnt)
	oHtml:ValByName( "WF"   		, Trim(_cWF))
	oHtml:ValByName( "WFID"			, oProcess:fProcessId)
	
	//Cabe็alho
	If _nOpc == 6 // TimeOut
		oHtml:ValByName( "TAIMAUT"	, "TIME-OUT DO PROCESSO" )
	Else
		oHtml:ValByName( "TAIMAUT"	, "" )
	EndIf
	oHtml:ValByName( "C7_FILIAL"	, SC7->C7_FILIAL )
	oHtml:ValByName( "C7_NUM"		, SC7->C7_NUM )
	oHtml:ValByName( "C7_EMISSAO"	, DTOC(SC7->C7_EMISSAO) )
	oHtml:ValByName( "C7_USER"		, UsrFullName(SC7->C7_USER) )
	oHtml:ValByName( "CR_USER"   	, UsrFullName(_cUser) )
	oHtml:ValByName( "A2_NOME"   	, Trim(SA2->A2_NOME)+ ' - '+SA2->A2_COD + ' / ' + SA2->A2_LOJA  )
	oHtml:ValByName( "E4_DESCRI"    , _cDesCon)
	oHtml:ValByName( "OBS"		    , "" )
	
ENDIF

//--------------------------- 3 RE-APROVACAO - RESPOSTA REJEITADA
IF TRIM(_cWF) == "3"
	oProcess          	:= TWFProcess():New( "000002", "Reenvio Aprovacao Pedido de Compra :" + _cFilial + "/" +  TRIM(_cNum) )
	oProcess          	:NewTask( "Reenvio PC : "+_cFilial + _cNum, "\workflow\html\PCAprovacao.HTM" )
	oProcess:cSubject 	:= _cFilial + "/" +  TRIM(_cNum)+" Reaprovacao Pedido de Compra "
	oProcess:bReturn  	:= "U_Rcomw01(2)"
	oProcess:cTo      	:= UPPER(UsrRetMail(_cUser))
	oProcess:UserSiga	:= SC7->C7_USER
	oProcess:NewVersion(.T.)
	lDetalhe := .T.
	lObs		 := .T.
	
	oHtml     			:= oProcess:oHTML
	
	// Hidden Fields
	oHtml:ValByName( "CHAVE"	    , _cChave)
	oHtml:ValByName( "CFILANT"	    , cFilAnt)
	oHtml:ValByName( "WF"   		, Trim(_cWF))
	oHtml:ValByName( "WFID"			, oProcess:fProcessId)
	
	//Cabe็alho
	
	oHtml:ValByName( "C7_FILIAL"	, SC7->C7_FILIAL )
	oHtml:ValByName( "C7_NUM"		, SC7->C7_NUM )
	oHtml:ValByName( "C7_EMISSAO"	, DTOC(SC7->C7_EMISSAO) )
	oHtml:ValByName( "C7_USER"		, UsrFullName(SC7->C7_USER) )
	oHtml:ValByName( "CR_USER"   	, UsrFullName(_cUser) )
	oHtml:ValByName( "A2_NOME"   	, Trim(SA2->A2_NOME)+ ' - '+SA2->A2_COD + ' / ' + SA2->A2_LOJA  )
	oHtml:ValByName( "E4_DESCRI"    , _cDesCon)
	
	oHtml:ValByName( "OBS"		    , "" )
	
ENDIF

//--------------------------- 4 ENVIO DE EMAIL PARA COMPRADOR - INFORMANDO SOBRE O PEDIDO REPROVADO
IF TRIM(_cWF) == "4"
	oProcess          	:= TWFProcess():New( "000003", "Envio p/comprador PC Reprovado : " + _cFilial + "/" +  TRIM(_cNum) )
	oProcess          	:NewTask( "Envio PC reprovado : "+_cFilial + _cNum, "\workflow\html\PCReprovadoII.HTM" )//pcreprovadoII.htm
	oProcess:cSubject 	:= _cFilial + "/" +  TRIM(_cNum)+" / Reprovacao do Pedido de Compra "
	oProcess:bReturn  	:= "U_Rcomw01(4)"
	oProcess:cTo      	:= UPPER( UsrRetMail( SC7->C7_USER ) )
	oProcess:cCC      	:= PegaSol()
	oProcess:UserSiga		:= SC7->C7_USER
	oProcess:NewVersion(.T.)
	
	oHtml     			:= oProcess:oHTML
	
	
	//Cabe็alho
	oHtml:ValByName( "C7_FILIAL"	, SC7->C7_FILIAL )
	oHtml:ValByName( "C7_NUM"		, SC7->C7_NUM )
	oHtml:ValByName( "C7_EMISSAO"	, DTOC(SC7->C7_EMISSAO) )
	oHtml:ValByName( "C7_USER"		, UsrFullName(SC7->C7_USER) )
	oHtml:ValByName( "CR_USER"   	, UsrFullName(_cUser) )
	oHtml:ValByName( "A2_NOME"   	, Trim(SA2->A2_NOME)+ ' - '+SA2->A2_COD + ' / ' + SA2->A2_LOJA  )
	oHtml:ValByName( "E4_DESCRI"    , _cDesCon)
	
	//oHtml:ValByName( "OBS"		    , "" )
	
ENDIF

//--------------------------- 5 ENVIO DE EMAIL PARA COMPRADOR - INFORMANDO SOBRE O PEDIDO APROVADO
IF TRIM(_cWF) == "5"
	oProcess          	:= TWFProcess():New( "000004", "Envio p/comprador Pedido de Compra aprovado : " + _cFilial + "/" +  TRIM(_cNum) )
	oProcess          	:NewTask( "Envio Pedido de Compra aprovado : "+_cFilial + _cNum, "\workflow\html\PCAprovadoII.HTM" )
	oProcess:cSubject 	:= _cFilial + "/" +  TRIM(_cNum)+" / Pedido de Compra Aprovado"
	oProcess:cTo      	:= UPPER( UsrRetMail( SC7->C7_USER ) )
	oProcess:UserSiga	:= SC7->C7_USER
	//oProcess:cCC      	:= PegaSol()
	oProcess:NewVersion(.T.)
	
	oHtml     			:= oProcess:oHTML
	
	//Cabe็alho
	oHtml:ValByName( "C7_FILIAL"	, SC7->C7_FILIAL )
	oHtml:ValByName( "C7_NUM"		, SC7->C7_NUM )
	oHtml:ValByName( "C7_EMISSAO"	, DTOC(SC7->C7_EMISSAO) )
	oHtml:ValByName( "C7_USER"		, UsrFullName(SC7->C7_USER) )
	oHtml:ValByName( "A2_NOME"   	, Trim(SA2->A2_NOME)+ ' - '+SA2->A2_COD + ' / ' + SA2->A2_LOJA  )
	oHtml:ValByName( "E4_DESCRI"    , _cDesCon)
	
	// Hidden Fields
	
ENDIF

IF TRIM(_cWF) == "7"
	oProcess          	:= TWFProcess():New( "000007", "Envio Aprovador II: " + _cFilial + "/" +  TRIM(_cNum) )
	oProcess          	:NewTask( "PC Vistado : "+_cFilial + _cNum, "\workflow\html\PCAprovacao.HTM" )
	oProcess:cSubject 	:= _cFilial + "/" +  TRIM(_cNum)+" / Pedido de Compra"
	oProcess:cTo      	:= UPPER( UsrRetMail( _cUser ) )
	oProcess:bReturn  	:= "U_Rcomw01(2)"
	oProcess:UserSiga	:= SC7->C7_USER
	//oProcess:cCC      	:= PegaSol()
	oProcess:NewVersion(.T.)
	
	oHtml     			:= oProcess:oHTML
	
	//Cabe็alho
	oHtml:ValByName( "C7_FILIAL"	, SC7->C7_FILIAL )
	oHtml:ValByName( "C7_NUM"		, SC7->C7_NUM )
	oHtml:ValByName( "C7_EMISSAO"	, DTOC(SC7->C7_EMISSAO) )
	oHtml:ValByName( "C7_USER"		, UsrFullName(SC7->C7_USER) )
	oHtml:ValByName( "A2_NOME"   	, Trim(SA2->A2_NOME)+ ' - '+SA2->A2_COD + ' / ' + SA2->A2_LOJA  )
	oHtml:ValByName( "E4_DESCRI"    , _cDesCon)
	
	oHtml:ValByName( "CHAVE"	    , _cChave)
	oHtml:ValByName( "CFILANT"	    , cFilAnt)
	oHtml:ValByName( "WF"   		, TRIM(_cWF))
	oHtml:ValByName( "WFID"			, oProcess:fProcessId)
	
	
ENDIF


//-------------------------------------------------------------
// ALIMENTA A TELA DE ITENS DO SOLICITACAO DE COMPRAS
//-------------------------------------------------------------

While !SC7->(EOF()) .AND. SC7->C7_FILIAL == _cFilial .AND. SC7->C7_NUM == _cNum
	
	DbSELECTAREA("SB1")
	DbSetOrder(1)
	DbSeek(xFilial()+SC7->C7_PRODUTO)
	
	DbSELECTAREA("SBM")
	DbSetOrder(1)
	DbSeek(xFilial()+SB1->B1_GRUPO)
	
	_nVlIpiUn := 0
	AAdd( (	oHtml:ValByName( "t1.1"  )), SC7->C7_ITEM)
	AAdd( (	oHtml:ValByName( "t1.2"  )), SB1->B1_COD)
	AAdd( (	oHtml:ValByName( "t1.3"  )), SC7->C7_DESCRI)
	AAdd( (	oHtml:ValByName( "t1.4"  )), SB1->B1_UM)
	AAdd( (	oHtml:ValByName( "t1.5"  )), TRANSFORM(SC7->C7_QUANT,'@E 999,999.999'))
	AAdd( (	oHtml:ValByName( "t1.6"  )), TRANSFORM(SC7->C7_PRECO,'@E 999,999.999'))
	AAdd( (	oHtml:ValByName( "t1.7"  )), TRANSFORM(SC7->C7_IPI,'@E 9,999.99'))
	AAdd( (	oHtml:ValByName( "t1.8"  )), TRANSFORM((SC7->C7_QUANT * SC7->C7_PRECO)+SC7->C7_VALIPI,'@E 999,999.99'))   // Total
	AAdd( (	oHtml:ValByName( "t1.9"  )), SC7->C7_DATPRF )
	AAdd( ( oHtml:ValByName( "t1.10"  ) ) , IIF( !Empty( SC7->C7_PROJETO ), SC7->C7_PROJETO , CriaVar( 'C7_PROJETO' , .F. ) ) )
	AAdd( (	oHtml:ValByName( "t1.11"  )), SC7->C7_CC)
	AAdd( (	oHtml:ValByName( "t1.12"  )), TRANSFORM(SB1->B1_UPRC,'@E 999,999.999'))
	AAdd( (	oHtml:ValByName( "t1.13"  )), SB1->B1_UCOM)
	
	_nDesconto += SC7->C7_VLDESC
	_nTotPed   += SC7->C7_TOTAL + SC7->C7_VALIPI
	
	If Ascan( _aProdFor, SC7->C7_PRODUTO ) == 0
		Aadd( _aProdFor, SC7->C7_PRODUTO )
	EndIf
	
	// Sergio em Nov/2006: Exibir a justificativa
	/*	//If Empty(_cWF)
	//If SC1->( FieldPos( "C1_XJUSTIF" ) ) > 0 .And. !Empty(SC7->C7_NUMSC)
	//AAdd( (oHtml:ValByName( "t3.1"  )), SC7->C7_ITEM )
	//AAdd( (oHtml:ValByName( "t3.2"  )), Posicione( "SC1", 1, xFilial("SC1")+SC7->(C7_NUMSC+C7_ITEMSC), "C1_XJUSTIF" ) )
	//Else
	//AAdd( (oHtml:ValByName( "t3.1"  )), "" )
	//AAdd( (oHtml:ValByName( "t3.2"  )), "" )
	//EndIf
	//EndIf */
	
	SC7->(DbSkip())
Enddo

oHtml:ValByName( "CR_TOTAL"		, Transform(_nTotPed,'@E 999,999,999.99') )
If !( AllTrim( _cWF ) == '4' ) .And. !( AllTrim( _cWF ) == '5' )
	oHtml:ValByName( "CR_DESCONTO"	, Transform(_nDesconto,'@E 999,999,999.99') )
	oHtml:ValByName( "CR_LIQUIDO"	, Transform(_nTotPed - _nDesconto,'@E 999,999,999.99') )
EndIf
//-------------------------------------------------------------
// ALIMENTA A TELA DE PROCESSO DE APROVACAOO DE PEDIDO DE COMPRA
//-------------------------------------------------------------

_cCHAVESCR := SUBS(_cCHAVE, 1, 24)

dbSelectArea('SC7')
SC7->( dbSetOrder( 1 ) )
SC7->( dbSeek( xFilial('SC7') + _cNum ) )
If  _cWF == '5'
	RecLock( 'SC7' , .F. )
	SC7->C7_XWF := '9'  // RICARDO LIMA - 13/11/17
	SC7->( MsUnLock() )
EndIf


dbSelectarea( 'SCR' )
SCR->( dbSetOrder( 1 ) )
SCR->( dbSeek( _cCHAVESCR , .T. ) )
nSCRRecno := SCR->( Recno() )
If ( _cWF == '4' )
	RecLock( 'SCR' , .F. )
	SCR->CR_WF := '9'
	SCR->( MsUnLock() )
EndIf

WHILE !SCR->(EOF()) .AND. AllTrim(SCR->(CR_FILIAL+CR_TIPO+CR_NUM)) == AllTrim(_cCHAVESCR)
	cSituaca := ""
	
	DbSelectArea('SCR')
	Do Case
		Case SCR->CR_STATUS == "01"
			IIF(SCR->CR_XTPLIB == 'A', cSituaca := 'Aguardando Aprovacao', cSituaca := 'Aguardando Visto' )
		Case SCR->CR_STATUS == "02"
			IIF(SCR->CR_XTPLIB == 'A', cSituaca := 'Em Processo de Aprovacao', cSituaca := 'Em Processo de Visto' )
		Case SCR->CR_STATUS == "03"
			IIF(SCR->CR_XTPLIB == 'A', cSituaca := 'Aprovado', cSituaca := 'Vistado' )
		Case SCR->CR_STATUS == "04"
			cSituaca := 'Bloqueado'
		Case SCR->CR_STATUS == "05"
			cSituaca := 'Nivel Liberado'
	EndCase
	
	_cT4 := UsrFullName(SCR->CR_USERLIB)
	If SCR->(FieldPos("CR_X_OBS")) > 0
		_cT6 := AllTrim(SCR->CR_X_OBS)
	Else
		_cT6 := AllTrim(SCR->CR_OBS)
	EndIf
	_lAlcada := .t.
	
	AAdd( (oHtml:ValByName( "t.1" )), SCR->CR_NIVEL)
	AAdd( (oHtml:ValByName( "t.2" )), UsrFullName(SCR->CR_USER))
	AAdd( (oHtml:ValByName( "t.3" )), cSituaca    )
	AAdd( (oHtml:ValByName( "t.4" )), IIF(EMPTY(_cT4),"", _cT4))
	AAdd( (oHtml:ValByName( "t.5" )), DTOC(SCR->CR_DATALIB))
	AAdd( (oHtml:ValByName( "t.6" )), IIF(EMPTY(_cT6),"", _cT6))
	
	SCR->(DbSkip())
	
ENDDO


// Se nao houver alcada, e porque o PC foi liberado automaticamente:
If !_lAlcada
	AAdd( (oHtml:ValByName( "t.1" )), "" )
	AAdd( (oHtml:ValByName( "t.2" )), "" )
	AAdd( (oHtml:ValByName( "t.3" )), "" )
	AAdd( (oHtml:ValByName( "t.4" )), "" )
	AAdd( (oHtml:ValByName( "t.5" )), "" )
	AAdd( (oHtml:ValByName( "t.6" )), "" )
EndIf

// Preencher as cotacoes para este pedido:

If Empty(Trim(_cWF) ) .Or. Trim(_cWF) == '3'
	
	_aSC8 := {}
	
	_cSelCot := "SELECT * FROM "+RetSqlName('SC7')+" SC7, "+RetSqlName('SC8')+" SC8"
	_cSelCot += " WHERE SC7.C7_FILIAL = '"+xFilial("SC7")+"' "
	_cSelCot += " AND SC8.C8_FILIAL   = '"+xFilial("SC8")+"' "
	_cSelCot += " AND SC7.C7_NUM = '"+_cNum+"' "
	_cSelCot += " AND SC7.C7_NUMCOT = SC8.C8_NUM"
	_cSelCot += " AND SC7.C7_PRODUTO = SC8.C8_PRODUTO"
	_cSelCot += " AND SC7.C7_NUMSC   = SC8.C8_NUMSC"
	_cSelCot += " AND SC7.C7_ITEMSC  = SC8.C8_ITEMSC"
	_cSelCot += " AND SC7.D_E_L_E_T_ = ' '"
	_cSelCot += " AND SC8.D_E_L_E_T_ = ' '"
	_cSelCot += " ORDER BY SC7.C7_ITEM, SC7.C7_PRODUTO"
	_cSelCot := ChangeQuery(_cSelCot)
	TCQUERY _cSelCot NEW ALIAS "C7C8"
	TCSETFIELD("C7C8","C8_PRECO"  ,"N",14,2)
	TCSETFIELD("C7C8","C8_VALIPI"  ,"N",14,2)
	DBSELECTAREA("C7C8")
	dbGoTop()
	
	While !Eof()
		
		If Ascan( _aProdFor, C7C8->C8_PRODUTO ) > 0
			
			DbSelectArea('SA2')
			DbSeek( xFilial('SA2')+C7C8->(C8_FORNECE+C8_LOJA) )
			
			DbSelectArea('SB1')
			DbSeek( xFilial('SB1')+C7C8->C8_PRODUTO )
			Aadd( _aSC8, { C7C8->C8_NUM, C7C8->C8_FORNECE, C7C8->C8_LOJA, SA2->A2_NOME, C7C8->C7_DESCRI, TRANSFORM(C7C8->C8_PRECO*C7C8->C8_QUANT,'@E 999,999.99'), C7C8->C8_NUMPED, TRANSFORM(C7C8->C8_ALIIPI ,'@E 999,999.99'), TRANSFORM(C7C8->C8_PICM ,'@E 999,999.99'), TRANSFORM(C7C8->C8_VALFRE ,'@E 999,999.99'),C7C8->C8_ITEM, C7C8->C8_PRODUTO } )
			
			_lCotacao := .t.
			
		EndIf
		
		DbSelectArea('C7C8')
		DbSkip()
	EndDo
	dbSelectArea("C7C8")
	dbCloseArea("C7C8")
	dbSelectArea("SC8")
	// Deve-se tambem testar se houve cotacao para o pedido:
	_lCotacao := .T.
	
	/*	//If !_lCotacao
	// #FF0000
	_//cExibe  := "<p><font color='#FF0000'>*** Nใo foi gerada concorr๊ncia para este pedido por se tratar de item fornecido atrav้s de contrato previamente negociado por Estrat้gia de Suprimentos ***</font></p>"
	//AAdd( (oHtml:ValByName( "t2.1" )), "" )
	//AAdd( (oHtml:ValByName( "t2.2" )), "" )
	//AAdd( (oHtml:ValByName( "t2.3" )), "" )
	//AAdd( (oHtml:ValByName( "t2.4" )), _cExibe )
	//Else
	//Asort(_aSC8,,, { |x,y| x[6] < y[6] } )
	//For _i := 1 To Len(_aSC8)
	
	//If SC7->C7_NUM # _aSC8[_i][7] .And. _aSC8[_i][7] # "XXXXXX"
	//Loop
	//EndIf
	
	//DbSelectArea('SCE')
	//DbSetOrder(1) // CE_FILIAL+CE_NUMCOT+CE_ITEMCOT+CE_PRODUTO+CE_FORNECE+CE_LOJA
	//DbSeek( xFilial('SCE')+_aSC8[_i][1]+_aSC8[_i][11]+_aSC8[_i][12]+_aSC8[_i][2]+_aSC8[_i][3] )
	//If _aSC8[_i][7] # "XXXXXX" // Cotacao XXXXXX = Perdedora
	//_cExibe  := "<p><font color='#0000FF'>"+_aSC8[_i][4]+"</font></p>"
	//_cExibe2 := "<p><font color='#0000FF'>"+_aSC8[_i][6]+"</font></p>"
	//_cExibe3 := "<p><font color='#0000FF'>"+_aSC8[_i][5]+"</font></p>"
	//_cExibe4 := "<p><font color='#0000FF'>"+SCE->CE_MOTIVO+"</font></p>"
	//AAdd( (oHtml:ValByName( "t2.1" )), _cExibe )
	//AAdd( (oHtml:ValByName( "t2.2" )), _cExibe2 )
	//AAdd( (oHtml:ValByName( "t2.3" )), _cExibe3 )
	//AAdd( (oHtml:ValByName( "t2.4" )), _cExibe4 )
	//Else
	//AAdd( (oHtml:ValByName( "t2.1" )), _aSC8[_i][4] )
	//AAdd( (oHtml:ValByName( "t2.2" )), _aSC8[_i][6] )
	//AAdd( (oHtml:ValByName( "t2.3" )), _aSC8[_i][5] )
	//AAdd( (oHtml:ValByName( "t2.4" )), SCE->CE_MOTIVO )
	//EndIf
	///Next
	//EndIf */
	
EndIf

If !( AllTrim( _cWF ) == '5' ) .And. !( AllTrim( _cWF ) == '4' )
	
	cQuery := " SELECT 	SC8.C8_FORNECE, SC8.C8_LOJA, "
	cQuery += " 		SC8.C8_PRODUTO, SC8.C8_TOTAL,SC8.C8_QUANT,SC8.C8_PRECO,"
	cQuery += " 		SC8.C8_MOTIVO "
	cQuery += " FROM "+ RetSQLName( 'SC8' ) +" SC8 "
	cQuery += " WHERE SC8.C8_FILIAL = '"+ xFilial( 'SC7' ) +"' "
	cQuery += "		AND SC8.C8_NUMSC IN ( SELECT SC7.C7_NUMSC "
	cQuery += "								FROM "+ RetSQLName( 'SC7' ) +" SC7 "
	cQuery += "								WHERE SC7.C7_FILIAL = '"+ xFilial( 'SC8' ) +"' "
	cQuery += "								AND SC7.C7_NUMSC = '"+ ___NumSc +"' "
	cQuery += "								AND SC7.D_E_L_E_T_ = '"+ Space( 1 ) +"' ) "
	cQuery += "		AND SC8.D_E_L_E_T_ = '"+ Space( 1 ) +"' "
	cQuery += "	ORDER BY SC8.C8_FORNECE, SC8.C8_LOJA "
	cQuery := ChangeQuery( cQuery )
	
	dbUseArea( .T., __cRdd, TcGenQry(,, cQuery ), cSC8Alias , .T. , .F. )
	dbSelectArea( cSC8Alias )
	( cSC8Alias )->( dbEval( { || nTotReg ++ },{ || .T. },{ || ( cSC8Alias )->( !Eof() ) } ) )
	
	If nTotReg == 0
		Aadd( ( oHtml:ValByName( "t2.1" ) ), CriaVar( 'A2_NOME'		, .F. ) 	)
		Aadd( ( oHtml:ValByName( "t2.2" ) ), CriaVar( 'C8_TOTAL'	, .F. ) 	)
		Aadd( ( oHtml:ValByName( "t2.3" ) ), CriaVar( 'B1_DESC'		, .F. ) 	)
		Aadd( ( oHtml:ValByName( "t2.4" ) ), CriaVar( 'C8_MOTIVO'	, .F. ) 	)
		Aadd( ( oHtml:ValByName( "t2.5" ) ), CriaVar( 'C8_QUANT'	, .F. ) 	)
		Aadd( ( oHtml:ValByName( "t2.6" ) ), CriaVar( 'C8_PRECO'	, .F. ) 	)
	Else
		AEval( SC8->( dbStruct() ),{ |x| IIF( x[2] # "C" , TcSetField( ( cSC8Alias ) , AllTrim( x[ 1 ] ), x[ 2 ], x[ 3 ], x[ 4 ] ) , Nil ) } )
		
		( cSC8Alias )->( dbGoTop() )
		While ( cSC8Alias )->( !Eof() )
			
			Aadd( ( oHtml:ValByName( "t2.1" ) ), AllTrim( Posicione( 'SA2', 1, xFilial( 'SA2' ) + Padr( ( cSC8Alias )->C8_FORNECE, TamSx3( 'A2_COD' )[1] ) + Padr( ( cSC8Alias )->C8_LOJA, TamSx3( 'A2_LOJA' )[1] ) , 'A2_NOME' ) ) 	)
			Aadd( ( oHtml:ValByName( "t2.2" ) ), TransForm( ( cSC8Alias )->C8_TOTAL , PesqPict( 'SC8', 'C8_TOTAL' ) ) 		)
			Aadd( ( oHtml:ValByName( "t2.3" ) ), AllTrim( Posicione( 'SB1', 1, xFilial( 'SB1' ) + Padr( ( cSC8Alias )->C8_PRODUTO, TamSx3( 'B1_COD' )[1] ) , 'B1_DESC' ) )	)
			Aadd( ( oHtml:ValByName( "t2.4" ) ), AllTrim(  ( cSC8Alias )->C8_MOTIVO )		)
			
			Aadd( ( oHtml:ValByName( "t2.5" ) ), TransForm(  (cSC8Alias )->C8_QUANT  ,cPictQtd)		)
			Aadd( ( oHtml:ValByName( "t2.6" ) ), TransForm(  (cSC8Alias )->C8_PRECO ,cPictPre)		)
			
			
			( cSC8Alias )->( dbSkip() )
		EndDo
	EndIf
	
	oHtmAtt := Nil
	oHtmAtt := GeraAnexo( _cNum )
	
	If ValType( oHtmAtt ) == 'O'
		cFile		:= 'Detalhes_Pedido_'+ AllTrim( _cNum ) +'.Htm '
		
		If !lIsDir( cPasta )
			MakeDir( cPasta )
		EndIf
		
		___Arquivo := cPasta + cFile
		oHtmAtt:SaveFile( ___Arquivo )
		oProcess:AttachFile( Upper( ___Arquivo ) )
		
	EndIf
	
EndIf

Aadd(	oProcess:aParams, xFilial( 'SCR' ) )
Aadd(	oProcess:aParams, _cChave	)
_cWFID := oProcess:fProcessId

If TRIM(_cWF) # "5" .And. GetNewPar('MV_X_LNKEM','H') == 'L'
	
	_cProcesso := "Queira por gentileza clicar no link abaixo para proceder com a aprovacao"
	_cProcesso  += " deste documento."
	
	cOldTo  := oProcess:cTo
	cOldCC  := oProcess:cCC
	cOldBCC := oProcess:cBCC
	
	//Uso um endereco invalido, apenas para criar o processo de workflow, mas sem envia-lo
	oProcess:cTo  := NIL
	oProcess:cCC  := NIL
	oProcess:cBCC := NIL
	
	cMailId    := oProcess:Start()  // Crio o processo e gravo o ID do processo de Workflow
	chtmlfile  := cmailid + ".htm"
	cmailto    := "mailto:" + AllTrim( SuperGetMV('MV_WFMAIL',,GetMv("MV_WFMAILT")) )
	chtmltexto := wfloadfile("\workflow\emp"+cEmpAnt+"\temp\" + chtmlfile )
	chtmltexto := strtran( chtmltexto, cmailto, "WFHTTPRET.APL" )
	wfsavefile("\workflow\" + chtmlfile+'l ', chtmltexto)
	
	//A fc abaixo faz a criacao e envio do link para resposta
	
	U_EnviaLink(chtmlfile+'l ',cOldTo,cOldCC,cOldBCC,oProcess:cSubject, cFilAnt, 'PC', _cNum, _cProcesso, UsrFullName(_cUser) )
	
Else
	
	oProcess:Start()  // Crio o processo e gravo o ID do processo de Workflow
	
EndIf

Return _cWFId

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณPegaSol   บAutor  ณ Sergio Oliveira    บ Data ณ  Nov/2006   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Obter os e-mails dos n Solicitantes das n Solicita็๕es de  บฑฑ
ฑฑบ          ณ Compras relacionados ao pedido de compras posicionado.     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Rcomw01.prw                                                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function PegaSol()

Local cVerifica
Local cSolicts := " "

cVerifica := " SELECT DISTINCT C7_NUMSC "
cVerifica += " FROM "+RetSqlName('SC7')+" SC7, "+RetSqlName('SC1')+" SC1 "
cVerifica += " WHERE C7_FILIAL  = '"+xFilial('SC7')+"' "
cVerifica += " AND   C7_NUM     = '"+SC7->C7_NUM+"' "
cVerifica += " AND   SC7.D_E_L_E_T_ = ' ' "
cVerifica += " AND   C1_FILIAL  = C7_FILIAL "
cVerifica += " AND   C1_NUM     = C7_NUM "
cVerifica += " AND   SC1.D_E_L_E_T_ = ' ' "

U_MontaView( cVerifica, 'VerSCs' )

DbSelectArea('VerSCs')
DbGoTop()
While !Eof()
	cSolicts += UsrRetMail(VerSCs->C1_USER)
	DbSkip()
	If !Eof()
		cSolicts += ";"
	EndIf
EndDo

Return

User Function XCONSOLE( _ctxt, lAuto )

local _ctxt

U_ADINF009P('RCOMW01' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Processo de aprovacao dos Pedidos de Compras via Workflow')

if _ctxt == NIL
	_ctxt := 'nulo'
endif
If lAuto == Nil
	lAuto	:= .T.
EndIf

If lAuto
	Aviso(	"Mensagem de Log",;
	_cTxt,;
	{ "&Retorna" },2,;
	"Diverg๊ncia no Processamento" )
Else
	CONOUT(_cTXT)
	
	nHdl2:= FOPEN("conout.log",2)
	IIF(nHdl2 > 0,,nHdl2:=MSFCREATE("conout.log",0))
	fseek(nHdl2,0,2)
	
	_cLogBody := ''
	_cLogBody += DTOC(DATE()) +" @ "+ TIME() +" "+ _cTxt + chr(13) + chr(10)
	Fwrite(nHdl2,_cLogBody,len(_cLogBody))
	
	_cLogBody := replicate('-',80) + chr(13) + chr(10)
	Fwrite(nHdl2,_cLogBody,len(_cLogBody))
	
	FCLOSE(nHdl2)
EndIf

Return

Static Function CalcRet( cNumero )
Local lRet 		:= .F.
Local nTotReg	:= 0
Local cQuery 	:= Nil
Local cAlias 	:= GetNextAlias()

cQuery := " SELECT COUNT( * ) TOTAL "
cQuery += " FROM "+ RetSQLName( 'SCR' ) +" SCR "
cQuery += " WHERE CR_FILIAL = '"+ xFilial( 'SCR' ) +"' "
cQuery += " AND CR_NUM = '"+ cNumero +"' "
cQuery += " AND CR_RESPOST = 'S' "
cQuery += " AND CR_WFID <> '"+ CriaVar( 'CR_WFID', .F. ) +"' "
cQuery += " AND SCR.D_E_L_E_T_ = '"+ Space( 1 ) +"' "
cQuery := ChangeQuery( cQuery )

dbUseArea( .T. , __cRdd , TcGenQry( ,,cQuery ) , cAlias , .T. , .F. )
dbSelectArea( cAlias )
( cAlias )->( dbEval( { || nTotReg ++ },{ || .T. },{ || ( cAlias )->( !Eof() ) } ) )
( cAlias )->( dbCloseArea() )

Return( nTotReg )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRCOMW01   บAutor  ณMicrosiga           บ Data ณ  05/07/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GeraAnexo( cNumero )
Local aArea				:= GetArea()
Local aSC7Area		:= SC7->( GetArea() )
Local aSC7Produto := {}
Local nTotReg 		:= 0
Local nInd			:= 0
Local nXnd			:= 0
Local cSD1Alias	:= GetNextAlias()
Local oHtml			:= TWFHtml():New( '\WorkFlow\Html\Detalhe_Pedido.Htm' )
Local nMaxUltCom 	:= GetNewPar("MV_#ULTCOM",8)


dbSelectArea( 'SC7' )
SC7->( dbSetOrder( 1 ) )

oHtml:ValByName( "C7_FILIAL"	, SC7->C7_FILIAL )
oHtml:ValByName( "C7_NUM"			, SC7->C7_NUM )


SC7->( dbGoTop() )
If SC7->( MsSeek( xFilial( 'SC7' ) + Padr( cNumero , TamSx3( 'C7_NUM' )[ 1 ] ) ) )
	SC7->( dbEval( { || Aadd( aSC7Produto, SC7->C7_PRODUTO ) },{ || .T. },{ || SC7->( !Eof() ) .And. SC7->C7_FILIAL == xFilial( 'SC7' ) .And. SC7->C7_NUM == Padr( cNumero, TamSx3( 'C7_NUM' )[ 1 ] ) } ) )
	
	For nInd := 1 To Len( aSC7Produto )
		aSD1Dados := {}
		
		cQry := " SELECT DISTINCT TOP "+Str(nMaxUltCom,1)+" SD1.D1_FILIAL, 	"
		cQry += "				SD1.D1_EMISSAO, SD1.D1_DOC, SD1.D1_SERIE, "
		cQry += "				SD1.D1_FORNECE, SD1.D1_LOJA, SD1.D1_ITEM, "
		cQry += "				SD1.D1_QUANT,		SD1.D1_VUNIT "
		cQry += " FROM "+ RetSQLName( 'SD1' ) +" SD1 "
		cQry += "	WHERE  SD1.D1_FILIAL = '"+ xFilial( 'SD1' ) +"' "
		cQry += " 				AND SD1.D1_COD = '"+ aSC7Produto[ nInd ]  +"' "
		cQry += " 				AND SD1.D1_PEDIDO <> '"+ cNumero +"' "
		cQry += " 				AND SD1.D_E_L_E_T_ = '"+ Space( 1 ) +"'
		cQry += "	GROUP BY SD1.D1_FILIAL, SD1.D1_EMISSAO, SD1.D1_DOC, SD1.D1_SERIE, "
		cQry += "						SD1.D1_FORNECE, SD1.D1_LOJA, SD1.D1_ITEM, SD1.D1_QUANT, SD1.D1_VUNIT "
		cQry += "	ORDER BY SD1.D1_EMISSAO DESC "
		cQry := ChangeQuery( cQry )
		
		dbUseArea( .T., __cRdd, TcGenQry( ,, cQry ), cSD1Alias, .T., .F. )
		
		dbSelectArea( cSD1Alias )
		( cSD1Alias )->( dbEval( { || nTotReg ++ },,{ || ( cSD1Alias )->( !Eof() ) } ) )
		
		If nTotReg == 0
			
			Aadd( ( oHtml:ValByName( "t3.1" ) ), '001' 	)
			Aadd( ( oHtml:ValByName( "t3.2" ) ), CriaVar( 'D1_COD'		, .F. ) 	)
			Aadd( ( oHtml:ValByName( "t3.3" ) ), CriaVar( 'D1_QUANT'	, .F. ) 	)
			Aadd( ( oHtml:ValByName( "t3.4" ) ), CriaVar( 'D1_VUNIT'	, .F. ) 	)
			Aadd( ( oHtml:ValByName( "t3.5" ) ), CriaVar( 'F1_COND'		, .F. )		)
			Aadd( ( oHtml:ValByName( "t3.6" ) ), CriaVar( 'D1_EMISSAO', .F. ) 	)
			Aadd( ( oHtml:ValByName( "t3.7" ) ), CriaVar( 'A2_NOME'		, .F. ) 	)
			
		Else
			
			( cSD1Alias )->( dbGoTop() )
			AEval( SD1->( dbStruct() ),{ |x| IIF( x[2] # "C" , TcSetField( ( cSD1Alias ) , AllTrim( x[ 1 ] ), x[ 2 ], x[ 3 ], x[ 4 ] ) , Nil ) } )
			
			( cSD1Alias )->( dbEval( { || Aadd( aSD1Dados, { ( cSD1Alias )->D1_ITEM ,;
			AllTrim( aSC7Produto[ nInd ] ),;
			( cSD1Alias )->D1_QUANT,;
			AllTrim( TransForm( ( cSD1Alias )->D1_VUNIT, PesqPict( 'SD1' ,'D1_VUNIT' ) ) ),;
			( cSD1Alias )->D1_EMISSAO,;
			( cSD1Alias )->D1_DOC,;
			( cSD1Alias )->D1_SERIE,;
			( cSD1Alias )->D1_FORNECE,;
			( cSD1Alias )->D1_LOJA,;
			AllTrim( Posicione( 'SA2',1, xFilial( 'SA2' ) + ( cSD1Alias )->D1_FORNECE + ( cSD1Alias )->D1_LOJA , 'A2_NOME' ) ) } )   },;
			{ || .T. },;
			{ || ( cSD1Alias )->( !Eof() )  }  ) )
			
			For nXnd := 1 To Len( aSD1Dados )
				Aadd( ( oHtml:ValByName( "t3.1" ) ), aSD1Dados[ nXnd,01 ] 	)
				Aadd( ( oHtml:ValByName( "t3.2" ) ), aSD1Dados[ nXnd,02 ] 	)
				Aadd( ( oHtml:ValByName( "t3.3" ) ), aSD1Dados[ nXnd,03 ] 	)
				Aadd( ( oHtml:ValByName( "t3.4" ) ), aSD1Dados[ nXnd,04 ] 	)
				Aadd( ( oHtml:ValByName( "t3.5" ) ), AllTrim( Posicione( 'SF1',3, xFilial( 'SF1' )+Dtos( aSD1Dados[ nXnd,5 ] )+aSD1Dados[ nXnd,6 ]+aSD1Dados[ nXnd,7 ]+aSD1Dados[ nXnd,8 ]+aSD1Dados[ nXnd,9 ] , 'F1_COND' ) ) )
				Aadd( ( oHtml:ValByName( "t3.6" ) ), aSD1Dados[ nXnd,05 ] 	)
				Aadd( ( oHtml:ValByName( "t3.7" ) ), aSD1Dados[ nXnd,10 ] 	)
			Next nXnd
			
		EndIf
		
		IIF( Select( cSD1Alias ) > 0 , ( cSD1Alias )->( dbCloseArea() ) , Nil )
		
	Next nInd
	
Else
	
	Aadd( ( oHtml:ValByName( "t3.1" ) ), '001' 	)
	Aadd( ( oHtml:ValByName( "t3.2" ) ), CriaVar( 'D1_COD'		, .F. ) 	)
	Aadd( ( oHtml:ValByName( "t3.3" ) ), CriaVar( 'D1_QUANT'	, .F. ) 	)
	Aadd( ( oHtml:ValByName( "t3.4" ) ), CriaVar( 'D1_VUNIT'	, .F. ) 	)
	Aadd( ( oHtml:ValByName( "t3.5" ) ), CriaVar( 'F1_COND'		, .F. )		)
	Aadd( ( oHtml:ValByName( "t3.6" ) ), CriaVar( 'D1_EMISSAO', .F. ) 	)
	Aadd( ( oHtml:ValByName( "t3.7" ) ), CriaVar( 'A2_NOME'		, .F. ) 	)
	
EndIf

RestArea( aSC7Area )
RestArea( aArea )
Return( oHtml )
