#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TBICODE.CH"   
#INCLUDE "XMLXFUN.CH"
#Include "Rwmake.ch"
#Include 'Topconn.ch'  

/*{Protheus.doc} User Function ADLOG056P
	Programa consumir de webservice ravex para Retornar Roteiros 
	@type  Function
	@author WILLIAM COSTA
	@since 09/10/2019
	@version 01
	@history Chamado 058410 - WILLIAM COSTA - 27/05/2020 - Alterado o cálculo do Km quando vier do ravex
	@history Chamado 058641 - WILLIAM COSTA - 04/06/2020 - Identificado que quando a loja do cliente tem letra o ravex não manda o cliente e loja correto então foi alterado o campo de cliente e loja para pegar da tabela do Protheus não mais do WebService
	@history Chamado 18824  - Leonardo P. Monteiro - 26/08/2020 - Declaração da variável M_PAG para prevenção do erro variable does not exist M_PAG on SENDCABEC(APLIB080.PRW) 18/05/2020 17:21:57 line : 3218.
*/
 
User Function ADLOG056P()

	Local oChk1         := NIL
	Local oBtnConfig    := NIL   //Éverson - 13/09/2016, chamado 029242.
	Private oWs         := NIL
	Private oResp       := ''
	Private cPerg       := 'ADLOG056P' 
	Private nId         := 0
	Private oTxtTela    := NIL
	//Private m_pag      	:= 01	
		
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Programa consumir de webservice ravex para Retornar Roteiros')
	
	//+------------------------------------------------+
	//|Cria grupo de perguntas.                        |
	//+------------------------------------------------+
	MontaPerg()
	
	Define MsDialog oTxtTela Title OemToAnsi("ADLOG056P - Importação de Arquivos RAVEX") From 20, 1 To 271, 345 COLORS 0, 16777215 Pixel Style 128
	@ 010,005 Say " Esse programa tem o objetivo de importar arquivos magnéticos "
	@ 024,005 Say " de acordo com o Layout RAVEX e conforme os parâmetros "
	@ 038,005 Say " abaixo "
	
	
	@ 105,005 Button oBtnConfig Prompt "Config. Emplac." Size 050, 010 Of oTxtTela Action (configParam()) Pixel //Éverson - 13/09/2016, chamado 029242.
	
	@ 105,070 BMPBUTTON TYPE 05 ACTION {Pergunte(cPerg,.T.)}
	@ 105,110 BMPBUTTON TYPE 01 ACTION (Processa({||CRIAWEBSERVICE()},"Processando","Aguarde, importando WebService..."), Close(oTxtTela))
	@ 105,140 BMPBUTTON TYPE 02 ACTION Close(oTxtTela)
	
	Activate Dialog oTxtTela Centered
		
RETURN(NIL)	

STATIC FUNCTION CRIAWEBSERVICE()

	oWs := WSSiviraFullWebService():New()

	oWs:cLogin := 'adoro_user_ws'
	oWs:cSenha := 'SdUdWSdA'
	 
   	If oWs:Autenticar()
	    // autenticação ok
	    oResp   := oWs:oWSAutenticarResult 
	    cMetodo := 'Autenticar' 
	    
	    IF oResp:NID == 2
	    
	    	RETORNARROTEIROS()
	    
	    ENDIF
	    
	Endif

RETURN(NIL)     	  

STATIC FUNCTION RETORNARROTEIROS()

	Local cDtHrIni := ''
	Local cDtHrFin := ''
	
	cDtHrIni := Substr(DTOS(MV_PAR01),1,4)+ '-' + Substr(DTOS(MV_PAR01),5,2)+ '-' + Substr(DTOS(MV_PAR01),7,2) +  "T" + '00:00:00'
	cDtHrFin := Substr(DTOS(MV_PAR02),1,4)+ '-' + Substr(DTOS(MV_PAR02),5,2)+ '-' + Substr(DTOS(MV_PAR02),7,2) +  "T" + '23:59:59'
	
	oWs:CCNPJEMISSOR                 := '60037058000301'
	oWs:OWSFILTRO:CFINAL             := cDtHrFin
	oWs:OWSFILTRO:CINICIAL           := cDtHrIni
	oWs:OWSFILTRO:LPERIODOESTIMATIVA := .T.
	oWs:OWSFILTRO:NIDROTEIRO         := 0

	If oWs:RetornarRoteiros()
	    // autenticação ok
	    oResp   := oWs:oWSRetornarRoteirosResult  
	    
	    IMPORTAXML()
	    
	Endif

RETURN(NIL)     	
                      
STATIC FUNCTION IMPORTAXML()

	Local _cCodCli      := ''
	Local _cLoja        := ''
	Local _cPedNum      := ''
	Local _cProduto     := ''
	Local _cRoteiro     := ''
	Local _cSeqNum      := ''
	Local _cPlaca       := ''
	Local cDesc1       	:= "Este programa tem como objetivo imprimir relatorio "
	Local cDesc2       	:= "de acordo com os parametros informados pelo usuario."
	Local cDesc3       	:= "Relatório de Erros de Importação"
	Local titulo       	:= "Relatório de Erros de Importação"
	Local nLin         	:= 80
	Local Cabec1       	:= " ATENDIMENTO TELEVENDAS "
	Local Cabec2       	:= ""
	Local aOrd 			:= {} 
	Local aDadosRoteiro	:= {} 
	Local nPos          := 0
	Local lRel          := .T.
	Local cTabela       := ""
	Local aLinhaErro    := {}
	Local nTipoErro     := 0
	Local aCargaFt      := {}
	Local lPedInc       := .T.
	Local p             := 0
	Local _KmTotal      := ""
	Local lGeraCrg      := SuperGetMv( "MV_#ROAD02" , .F. , .F. , )
	Private lAbortPrint := .F.
	Private Tamanho     := "M"
	Private NomeProg    := "ADLOG056P" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo       := 18
	Private aReturn     := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey    := 0
	Private wnrel       := "IMPRDNET" // Coloque aqui o nome do arquivo usado para impressao em disco
	Private cString     := ""
	Private aRot        := {}      
	Private aRots       := {}      
	Private nContRot    := 0
	Private nContPed    := 0
	Private cPedido     := '' 
	Private nRotIni     := 0
	Private nRotFin     := 0
	//Tkt 18824 - Declaração da varíavel faltante.
	Private m_pag      	:= 01

	IF ISALPHA(MV_PAR03) .OR. ALLTRIM(MV_PAR03) == ''
		
		MsgAlert("Não pode utilizar Letras no Roteiro ou branco! Verifique os parâmetros...","ADLOG056P-01 - Roteiro Ini Inválido")
		RETURN(NIL)
		
	ENDIF

	IF ISALPHA(MV_PAR04)  .OR. ALLTRIM(MV_PAR04) == ''
		
		MsgAlert("Não pode utilizar Letras no Roteiro ou branco! Verifique os parâmetros...","ADLOG056P-02 - Roteiro Fin Inválido")
		RETURN(NIL)
		
	ENDIF
	
	/////// ************INICIO CRIA VETOR E VARIAVEIS DE RETORNA ROTEIRO****************************************** //
	IF LEN(oResp:OWSROTEIRO) > 0
	 
		IF oResp:OWSROTEIRO[1]:NID <> -1 // VERIFICA SE EXISTE ERRO
			
			nRotIni := IIF(MV_PAR03 == ''   ,0  ,VAL(MV_PAR03))
			nRotFin := IIF(MV_PAR04 == 'ZZZ',999,VAL(MV_PAR04))

			IF nRotIni == nRotFin

				ProcRegua(1)

			ELSE

				ProcRegua(nRotFin - nRotIni)

			ENDIF	

			FOR nContRot := 1 TO LEN(oResp:OWSROTEIRO)
			
				FOR nContPed := 1 TO LEN(oResp:OWSROTEIRO[nContRot]:OWSPEDIDOS:OWSITEMROTEIRO)
				
				    IF VAL(ALLTRIM(oResp:OWSROTEIRO[nContRot]:CIDENTIFICADORROTA)) >= nRotIni .AND. ;
			   		   VAL(ALLTRIM(oResp:OWSROTEIRO[nContRot]:CIDENTIFICADORROTA)) <= nRotFin
						
						// *** INICIO RETORNO ROTEIROS *** //
						cPedido := oResp:OWSROTEIRO[nContRot]:OWSPEDIDOS:OWSITEMROTEIRO[nContPed]:CNUMEROPEDIDO
						
						//log de inicio de importação de pedidos roteirizados
						u_GrLogZBE (Date(),TIME(),cUserName," INICIO IMPORTACAO PED.VENDAS","LOGISTICA","ADLOG056P","RAVEX - IMPORTAR-PEDIDOS",ComputerName(),LogUserName()) 
						
						_cCodCli  := Posicione("SC5",1,FWxFilial("SC5")+cPedido,"C5_CLIENTE") //SUBSTR(STRZERO(VAL(oResp:OWSROTEIRO[nContRot]:OWSPEDIDOS:OWSITEMROTEIRO[nContPed]:CCODIGOCLIENTE),8),1,6)
						_cLoja    := Posicione("SC5",1,FWxFilial("SC5")+cPedido,"C5_LOJACLI") //SUBSTR(STRZERO(VAL(oResp:OWSROTEIRO[nContRot]:OWSPEDIDOS:OWSITEMROTEIRO[nContPed]:CCODIGOCLIENTE),8),7,2)
						_cPedNum  := oResp:OWSROTEIRO[nContRot]:OWSPEDIDOS:OWSITEMROTEIRO[nContPed]:CNUMEROPEDIDO
						_cProduto := '128270' //nao descobri para que usa o campo de produto William Costa 29/04/2019 por isso coloquei um valor fixo
						_cRoteiro := oResp:OWSROTEIRO[nContRot]:CIDENTIFICADORROTA
						_cSeqNum  := STRZERO(oResp:OWSROTEIRO[nContRot]:OWSPEDIDOS:OWSITEMROTEIRO[nContPed]:NSEQUENCIA,2)
						_cPlaca   := STRTRAN(oResp:OWSROTEIRO[nContRot]:CPLACA,'-','')
						_KmTotal  := CVALTOCHAR(INT(oResp:OWSROTEIRO[nContRot]:NKMESTIMADO))  //Ricardo Lima-10/01/2019-Ch:044314|Gera carga de entrega para geração de frete no faturamento
						_bOkC5    := .F.
						_bOkC6    := .F.
						_bOkC9	  := .F.
						
						IncProc("PV " + Alltrim(cValToChar(_cPedNum)) + "|" + _cCodCli + _cLoja + "|" + _cRoteiro + "|") //Éverson - 13/09/2016, chamado 029242.
						
						_RotEnt   := .F.
						
						//Verifica se o pedido já foi enviado ao Edata.
						DbSelectArea("SC5")
						SC5->(DbSetOrder(3))
						SC5->(DbGoTop())
						If SC5->(DbSeek(xFilial("SC5") + _cCodCli + _cLoja + _cPedNum))
						
							If Alltrim(SC5->C5_XINT) == "3"
								MsgStop("O pedido " + Alltrim(cValToChar(SC5->C5_NUM)) +;
									" já enviado para o Edata, para altera-lo é necessário o Estorno.","importarPV(IMPRDNET)")
								_RotEnt := .T.
								
							ElseIf !Empty(SC5->C5_NOTA) //incluido por Adriana para nao roteirizar pedido faturado
								MsgStop("Processo interrompido, pedido já faturado, não pode ser roteirizado "+_cPedNum,"importarPV(IMPRDNET)")
								_RotEnt := .T.
							
							Else
							
								// *** INICIO CHAMADO 040504 WILLIAM COSTA 21/03/2018 *** //	
								IF Empty(_cRoteiro) .OR. Empty(SC5->C5_ROTEIRO)
							
									u_GrLogZBE (Date(),TIME(),cUserName,"IMPORTACAO RAVEX","LOGISTICA","ADLOG056P",;
											"PEDIDO: "+SC5->C5_NUM +'||' + _cPedNum +" ROTEIRO BRANCO: "+SC5->C5_ROTEIRO+"||"+_cRoteiro,;
											ComputerName(),LogUserName())
								ENDIF
								// *** FINAL CHAMADO 040504 WILLIAM COSTA 21/03/2018 *** //
								
							
								_dtEntr := SC5->C5_DTENTR
								
								//Verifica se há pedido no roteiro que já tenha sido enviado ao Edata.
								DbSelectArea("SC5")
								//SC5->(dbSetOrder(9))
								SC5->(DBORDERNICKNAME("SC5_9")) //atualização protheus 12 WILLIAM COSTA 28/12/2017 CHAMADO 036032
								SC5->(DbGoTop())
								SC5->(dbSeek(xFilial("SC5") + DTOS(_dtEntr) + Alltrim(_cRoteiro)))						
								Do While ! SC5->(Eof()) .And. _dtEntr == SC5->C5_DTENTR .And. Alltrim(_cRoteiro) == Alltrim(SC5->C5_ROTEIRO)
								
									If Alltrim(SC5->C5_XINT) == "3"
										If !_RotEnt
											MsgAlert("Processo interrompido, o roteiro " + Alltrim(SC5->C5_ROTEIRO) + " (" + DToC(CToD(cValToChar(_dtEntr))) +;
													"-" + Alltrim(SC5->C5_NUM) + ")" +;
													" já foi enviado ao Edata! Verifique!","importarPV(IMPRDNET)")
											
										Endif	
										
										_RotEnt := .T.
										
									Endif
									
									DbSelectArea("SC5")
									SC5->(DbSkip())
										
								EndDo
								
							Endif	
							
						Endif				
						
						//Salva as informações de retorno do RAVEX no cabeçalho (SC5), nos itens (SC6) e itens liberados (SC9) do pedido de venda.
						If !_RotEnt
						
							//Salva as informações de retorno do RAVEX no cabeçalho do pedido de venda.
							DbSelectArea("SC5")
							SC5->(dbSetOrder(3))
							SC5->(DbGotop())
							If SC5->(dbSeek(xFilial("SC5") + _cCodCli + _cLoja + _cPedNum))
							
								_c_RotA := SC5->C5_ROTEIRO   //Mauricio - 11/08/17 - Chamado 036566
								_c_SeqA := SC5->C5_SEQUENC   //Mauricio - 11/08/17 - Chamado 036566
								_c_PlcA := SC5->C5_PLACA     //Mauricio - 11/08/17 - Chamado 036566

								SC5->(recLock("SC5",.F.))
								SC5->C5_ROTEIRO := _cRoteiro
								SC5->C5_SEQUENC := _cSeqNum
								SC5->C5_PLACA   := _cPlaca 
								SC5->C5_XRAVEX  := .T.          
								SC5->C5_XNIDROT := oResp:OWSROTEIRO[nContRot]:NID
								SC5->C5_UFPLACA := "  " //Incluido para obrigar a roteirização pelo Protheus  em 18/11/14 por adriana  - chamado 020095
								_bOkC5 := .T.
								SC5->(msUnlock())

								aRot := {}
								AAdd(aRot,DTOC(SC5->C5_DTENTR))
								AAdd(aRot,SC5->C5_ROTEIRO)
								AAdd(aRot,SC5->C5_NUM)
								AAdd(aRots,aRot)
								
								//Ricardo Lima-10/01/2019-Ch:044314|Gera carga de entrega para geração de frete no faturamento
								
								For p:=1 to Len(aCargaFt)
									if _cPedNum = aCargaFt[p][3]
										lPedInc := .F.
									Endif
								Next
								If lPedInc = .T.
									Aadd( aCargaFt , { _cCodCli , _cLoja , _cPedNum , _cProduto , _cRoteiro , _cSeqNum , _cPlaca, _KmTotal, DToS(SC5->C5_DTENTR)} ) //Everson-28/05/2019-Ch:044314.
								Endif
								lPedInc := .T.
								
								
								_dtEntr := SC5->C5_DTENTR
								
								//Mauricio - 11/08/17 - Chamado 036566 - Inclusão de log para troca de roteiro, placa, sequencia quando retornado pelo
								//RAVEX. Efetuado apenas para a SC5 para nao poluir o log, mas estende-se as tabelas abaixo.
								u_GrLogZBE (Date(),TIME(),cUserName,"IMPORTACAO RAVEX","LOGISTICA","ADLOG056P",;
										"PEDIDO: "+SC5->C5_NUM+" ROTEIRO/SEQ/PLACA DE: "+_c_RotA+" "+_c_SeqA+" "+_c_PlcA+" " + cValToChar(_KmTotal) + " PARA: "+_cRoteiro+" "+_cSeqNum+" "+_cPlaca,; //Everson - 28/02/2019. Chamado 044314. Adicionado o Km percorrido.
										ComputerName(),LogUserName())
							
							EndIf
										
							DbSelectArea("SC6")
							SC6->(DbSetOrder(1))
							SC6->(DbGoTop())
 							If SC6->(DbSeek(xFilial("SC6") + _cPedNum)) .And. _bOkC5 .And. ! Empty(Alltrim(cValToChar(_cRoteiro))) .And. ! Empty(Alltrim(cValToChar(_cSeqNum)))
								
								While Alltrim(SC6->C6_NUM) == Alltrim(_cPedNum) .And. ! SC6->(Eof())
									
									If (SC6->C6_QTDVEN - SC6->C6_QTDENT) > 0 //Valida se a quantidade entregue é menor que a quantidade do pedido.
										
										SC6->(recLock("SC6",.F.))
										SC6->C6_ROTEIRO 	:= _cRoteiro
										SC6->C6_SEQUENC 	:= _cSeqNum
										_bOkC6 			:= .T.
										
										SC6->(msUnlock())
										
									Endif
									
									SC6->(dbSkip())
									
								Enddo
								
							Endif	
												
							//Incluido para gravar SC9 em 18/11/14 por adriana - chamado 020095
							DbSelectArea("SC9")
							SC9->(DbSetOrder(1))
							SC9->(DbGoTop())
							If SC9->(DbSeek( xFilial("SC9") + _cPedNum )) .And. _bOkC6	
							
								While ! SC9->(Eof()) .and. SC9->C9_PEDIDO == _cPedNum .And. xFilial("SC9") == SC9->C9_FILIAL			
									
									If Reclock("SC9",.F.) //Valida se foi possível "travar" o registro.
										SC9->C9_PLACA 		:= _cPlaca  
										SC9->C9_ROTEIRO 		:= _cRoteiro
										SC9->C9_SEQUENC      := _cSeqNum
										SC9->C9_DTENTR 		:= _dtEntr 
										_bOkC9					:= .T.
										
										SC9->(MsUnlock())
				
									Endif
							
									SC9->(dbSkip())
									
								EndDo
								
							Endif
							
							//Mauricio - 11/08/17 - Chamado 036566 - Fernando informou que no retorno do RAVEX ha pedidos com roteiros trocados
							//sendo assim necessario atualizar tambem o roteiro na tabela de controle de frete SZK se existir registro com os dados anteriores da SC5.
							
							IF _bOkC5  //Atualizou o SC5
							dbSelectArea("SZK")
							dbSetOrder(4)     // ZK_FILIAL + ZK_DTENTR  + ZK_PLACA + ZK_ROTEIRO )
							If dbSeek(xFilial("SZK")+ DTOS(_dtEntr) + _c_PlcA + _c_RotA)  
							
								//grava log chamado 041202 - WILLIAM COSTA 23/04/2018
								u_GrLogZBE (Date(),TIME(),cUserName," RecLock(SZK,.F.)","LOGISTICA","ADLOG056",;
								"Filial: "+xFilial("SZK")+" Data: "+DTOS(_dtEntr)+" Placa: "+_c_PlcA+" Roteiro: "+_c_RotA,ComputerName(),LogUserName())	
											
								RecLock("SZK",.F.)
								Replace ZK_FILIAL   With xFilial("SZK")	              
								Replace ZK_PLACA    With _cPlaca
								Replace ZK_PLACAPG  With _cPlaca             
								Replace ZK_ROTEIRO  With _cRoteiro
								Replace ZK_PLCCAV   With "" //Everson - 10/07/2019.   	    	
								SZK->(MsUnlock())
								
							ELSE
							
								//grava log chamado 041202 - WILLIAM COSTA 23/04/2018
								u_GrLogZBE (Date(),TIME(),cUserName," ELSE RecLock(SZK,.F.)","LOGISTICA","ADLOG056",;
								"Filial: "+xFilial("SZK")+" Data: "+DTOS(_dtEntr)+" Placa: "+_c_PlcA+" Roteiro: "+_c_RotA,ComputerName(),LogUserName())
								
							Endif												
							Endif
							
						Endif
						
						//Éverson - 12/09/2016, chamado 029242.
						If !_RotEnt .And. _bOkC5 .And.  _bOkC6 .And. _bOkC9
							
							//Verifica se o o roteiro está no array.
							nPos := 0
							nPos := Ascan(aDadosRoteiro,{|x| Alltrim(cValtoChar(x[3])) == Alltrim(cValToChar(_cRoteiro))})
							
							//O dados são adicionados ao array para emplacamento automático.
							If nPos == 0
							
								Aadd(aDadosRoteiro,{_cPlaca,_dtEntr,_cRoteiro})
							
							EndIf
						
						EndIf
						
						If _RotEnt .Or. ! _bOkC5 .Or.  ! _bOkC6 .Or. ! _bOkC9 //Éverson - 13/09/2016, chamado 029242.
							
							//Éverson - 13/09/2016, chamado 029242.
							If _RotEnt
								cTabela	:= "Erro pedido já faturado e/ou enviado para o Edata"
								nTipoErro	:= 1
								
							ElseIf ! _bOkC5 .Or.  ! _bOkC6 .Or. ! _bOkC9
								cTabela	:= "Tabela SC5"
								nTipoErro	:= 2
								
							ElseIf _bOkC5 .Or.  ! _bOkC6 .Or. ! _bOkC9
								cTabela	:= "Tabela SC6"
								nTipoErro	:= 3
								
							ElseIf _bOkC5 .Or. _bOkC6 .Or. ! _bOkC9
								cTabela	:= "Tabela SC9"
								nTipoErro	:= 4
								
							EndIf
							
							Aadd(aLinhaErro,{_cPedNum + " - Roteiro: " + cValToChar(_cRoteiro) + Space(12) + cTabela,nTipoErro})//Éverson - 13/09/2016, chamado 029242.
							
						EndIf
						
						// *** FINAL RETORNO ROTEIROS 
						
					ENDIF
				NEXT nContPed
			NEXT nCont
			
			//Ricardo Lima-10/01/2019-Ch:044314|Gera carga de entrega para geração de frete no faturamento
			If lGeraCrg
				If Len(aCargaFt) > 0
					ConOut('Inicio StartJob para Geração de Carga')
						MsAguarde( {|| U_ADLOG049P(cEmpAnt , cFilAnt , aCargaFt ) }, "Aguarde", "Gerando cargas..." ) //Everson-23/05/2019-Ch:044314.
						
					ConOut('Fim StartJob para Geração de Carga')
				Endif
			Endif
		
			
			//log de fim de importação de pedidos roteirizados
			u_GrLogZBE (Date(),TIME(),cUserName," FINAL IMPORTACAO PED.VENDAS","LOGISTICA","ADLOG056","RAVEX - IMPORTAR-PEDIDOS",ComputerName(),LogUserName()) 
			
			If Len(aLinhaErro) > 0	// Deseja imprimir o relatório de erros gerados na importação?
				If Msgbox("Deseja imprimir o relatório de erros gerados na importação?", "IMPRDNET-001", "YESNO")
					wnrel := SetPrint(cString,NomeProg,"",@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)
					
					If nLastKey == 27
						lRel := .F.
						
					Endif
					
					If lRel
						SetDefault(aReturn,cString)
					
					EndIf
					
					If nLastKey == 27
						lRel := .F.
						
					Endif
					
					If lRel
						nTipo := If(aReturn[4]==1,15,18)
						RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin,aLinhaErro) },Titulo)
						
					EndIf
					
				Endif
				
			Endif
			
			//Éverson - 12/09/2016, chamado 029242.
			If Len(aDadosRoteiro) > 0 .AND. ;
			   MsgYesNo("Há " + cValToChar(Len(aDadosRoteiro)) + " roteiro(s) para ser(em) emplacado(s). Deseja efetuar o emplacamento automático?","importarPV(IMPRDNET)")
				
				telaEmplacamento(aDadosRoteiro)
				
			EndIf
			
		ELSE
		
			cMetodo := 'Roteiro'
		    nId     := -1
		    EmailViagem(cMetodo,nId,'000000000 - 1-) Erro WEBSERVICE VAZIO - SEM RETORNO DE ROTEIROS')
		
			
		ENDIF
	ELSE 
	
		cMetodo := 'Roteiro'
	    nId     := -1
	    EmailViagem(cMetodo,nId,'000000000 - 2-) Erro WEBSERVICE VAZIO - SEM RETORNO DE ROTEIROS')
	    
    ENDIF
    
    IF LEN(aRots) > 0
    
		cMetodo := 'Roteiro'
	    nId     := 1
    	EmailViagem('Roteiro',nId,'IMPORTA_ROTEIRO')
    
    ENDIF 
    
	/////// ************FINAL CRIA VETOR E VARIAVEIS DE RETORNA ROTEIRO ****************************************** //  
	
RETURN(NIL) 

STATIC FUNCTION EmailViagem(cMetodo,nId,cmensagem)

    Local cServer      := Alltrim(GetMv("MV_INTSERV"))  
    Local cAccount     := AllTrim(GetMv("MV_INTACNT"))
    Local cPassword    := AllTrim(GetMv("MV_INTPSW"))
    Local cFrom        := AllTrim(GetMv("MV_INTACNT"))
    Local cTo          := AllTrim(GetMv("MV_#USUENT"))
    Local lOk          := .T.  
    Local lAutOk       := .F. 
    Local lSmtpAuth    := GetMv("MV_RELAUTH",,.F.) 
    Local cSubject     := ""  
    Local cBody        := ""
    Local cAtach       := ""               
    Local _cStatEml    := ""
    Local _cPedido     := ""
    Local _cStatEml    := ""
    
	//***************************** INICIO ENVIO DE EMAIL CONFIRMANDO A GERACAO DO PEDIDO DE VENDA **************
                            
    _cStatEml    := cMetodo 
    cBody        := RetHTML(_cStatEml,nId,cmensagem)
    lOk          := .T.  
    lAutOk       := .F. 
    Connect Smtp Server cServer Account cAccount Password cPassword Result lOk
	                        
	IF lAutOk == .F.
		IF ( lSmtpAuth )
			lAutOk := MailAuth(cAccount,cPassword)
	    ELSE
	        lAutOk := .T.
	    ENDIF
	ENDIF

	IF lOk .And. lAutOk     
	   cSubject := "WEBSERVICE RETORNO ROTEIROS"          
	   Send Mail From cFrom To cTo Subject cSubject Body cBody ATTACHMENT cAtach Result lOk                                           
	ENDIF            
	
	IF lOk
	   Disconnect Smtp Server
	ENDIF
				                        
    //****************************** FINAL ENVIO DE EMAIL CONFIRMANDO A GERACAO DO PEDIDO DE VENDA **************

RETURN(NIL)   

Static Function RetHTML(_cStatEml,nId,cmensagem)

	Local cRet       := "" 
	Local nContEmail := 0

	cRet := "<p <span style='"
	cRet += 'font-family:"Calibri"'
	cRet += "'><b>WEBSERVICE RETORNO ROTEIROS............: </b>" 
	cRet += "<br>"                                                                                        
	cRet += "<b>STATUS.............: </b>"
	
	IF _cStatEml == 'Roteiro' .AND. nId == 1 // viagem ok
 	
	   cRet += " WEBSERVICE RETORNO ROTEIROS COM SUCESSO"
	   cRet += "<br>"
	   cRet += "<br>"
	   
	   FOR nContEmail:=1 TO LEN(aRots)
	   
	   		cRet += 'Data de Entrega: ' + aRots[nContEmail][1] + ' Roteiro: ' + aRots[nContEmail][2] + ' Pedido: ' + aRots[nContEmail][3] + ' Roteiro Importado.' + "<br>"
	
	   NEXT
	   
	ENDIF	
	
	IF (_cStatEml == 'Roteiro' .AND. nId == -1) .OR. ;
	   (_cStatEml == 'Roteiro' .AND. nId == 0 )      // Viagem com erro
 	
	   cRet += " WEBSERVICE ROTEIRO COM ERRO, favor verificar"
	   cRet += "<br>"
	   cRet += "<br>"
	   
	   cRet += 'Data de Entrega Ini: ' + DTOC(MV_PAR01) + ' Data de Entrega Fin: ' + DTOC(MV_PAR02) + ' e Roteiro Ini: ' + MV_PAR03 + ' Roteiro Fin: ' + MV_PAR04 + ' ' + cmensagem  + ' não encontrada no protheus'

	ENDIF  
	
	cRet += "<br>"
	cRet += "<br><br>ATT, <br> TI <br><br> E-mail gerado por processo automatizado."
	cRet += "<br>"
	cRet += '</span>'
	cRet += '</body>'
	cRet += '</html>'
      
Return(cRet)     

Static Function MontaPerg()  
                                
	Private bValid := Nil 
	Private cF3	    := Nil
	Private cSXG   := Nil
	Private cPyme  := Nil
	
	U_xPutSx1(cPerg,'01','Data Entrega Inicial ?','','','mv_ch01','D',08,0,0,'G',bValid,cF3  ,cSXG,cPyme,'MV_PAR01')
	U_xPutSx1(cPerg,'02','Data Entrega Final   ?','','','mv_ch02','D',08,0,0,'G',bValid,cF3  ,cSXG,cPyme,'MV_PAR02')
	U_xPutSx1(cPerg,'03','Roteiro Inicial      ?','','','mv_ch03','C',03,0,0,'G',bValid,cF3  ,cSXG,cPyme,'MV_PAR03')
	U_xPutSx1(cPerg,'04','Roteiro Final        ?','','','mv_ch04','C',03,0,0,'G',bValid,cF3  ,cSXG,cPyme,'MV_PAR04')
	
    Pergunte(cPerg,.T.)
	
Return Nil

/*{Protheus.doc} Static Function configParam
	Função configurar a tabela de frete e tipo de frete por faixa de roteiros
	@type  Function
	@author Everson
	@since 13/09/2016
	@version 01
*/

Static Function configParam()

	Local oDlgConfig
	Local aAltParam	:= {'ROTDE','ROTAT','TAFRT','TIFRT'}
	Local aHParam		:= {}
	Local aColsParam	:= {}
	Local oSBtn01
	Local oSBtn02
	Local oParametros
	Local cTab			:= "EA"
	
	//Cria objeto MsDialog.
	oDlgConfig:= MsDialog():Create()
	oDlgConfig:cName     := "oDlgConfig"
	oDlgConfig:cCaption  := "Parâmetros da Rotina de Emplacamento"
	oDlgConfig:nLeft     := 34
	oDlgConfig:nTop      := 222
	oDlgConfig:nWidth    := 900
	oDlgConfig:nHeight   := 450
	oDlgConfig:lShowHint := .F.
	oDlgConfig:lCentered := .T.
	
	//Cria botão de confirmação.
	oSBtn01:= SBUTTON():Create(oDlgConfig)
	oSBtn01:cName := "oSBtn01"
	oSBtn01:cCaption := "OK"
	oSBtn01:nLeft := 765
	oSBtn01:nTop := 390
	oSBtn01:nWidth := 50
	oSBtn01:nHeight := 20
	oSBtn01:lShowHint := .F.
	oSBtn01:lReadOnly := .F.
	oSBtn01:Align := 0
	oSBtn01:lVisibleControl := .T.
	oSBtn01:bAction := {|| grvParametros(oParametros,aHParam,oDlgConfig,cTab)}
	
	//Cria botão de cancelamento.
	oSBtn02:= SBUTTON():Create(oDlgConfig)
	oSBtn02:cName := "oSBtn02"
	oSBtn02:cCaption := "Cancelar"
	oSBtn02:nLeft := 833
	oSBtn02:nTop := 390
	oSBtn02:nWidth := 50
	oSBtn02:nHeight := 20
	oSBtn02:lShowHint := .F.
	oSBtn02:lReadOnly := .F.
	oSBtn02:Align := 0
	oSBtn02:lVisibleControl := .T.
	oSBtn02:bAction := {||oDlgConfig:End()}
	
	//Cria Header.
	Aadd(aHParam,{"Rota de" 		,"ROTDE"	,""	, 10,0,"","" ,"C","",""})
	Aadd(aHParam,{"Rota ate" 		,"ROTAT"	,""	, 10,0,"","" ,"C","",""})
	Aadd(aHParam,{"Tabela de Frete"	,"TAFRT"	,""	, 04,0,"","" ,"C","ZV8",""})
	Aadd(aHParam,{"Desc. Tab Frt"	,"DESCTA"	,""	, 30,0,"","" ,"C","",""})
	Aadd(aHParam,{"Tipo de Frete"	,"TIFRT"	,""	, 04,0,"","" ,"C","SZH",""})
	Aadd(aHParam,{"Desc. de Frete"	,"DESCTI"	,""	, 30,0,"","" ,"C","",""})
	
	oParametros := MsNewGetDados():New(005,004,180,445,GD_UPDATE + GD_INSERT + GD_DELETE,"Allwaystrue()","Allwaystrue()","",aAltParam,Nil,999,Nil,Nil,Nil,oDlgConfig,aHParam,@aColsParam)
	
	oDlgConfig:Activate(,,,.T.,{||.T.},,{|| cargaConfPara(oParametros,aHParam,cTab)})
	
Return Nil

/*{Protheus.doc} Static Function grvParametros
	Função para gravar as configurações de emplacamento 
	@type  Function
	@author Everson
	@since 13/09/2016
	@version 01
*/

Static Function grvParametros(oParametros,aHParam,oDlgConfig,cTab)

	Local aArea	:= GetArea()
	Local cUpdate	:= "UPDATE " + RetSqlName("SX5") + " SET D_E_L_E_T_ = '*' WHERE X5_TABELA = '" + cTab + "' AND X5_FILIAL = '" + xFilial("SX5") + "'"
	Local i		:= 1
	Local cChave	:= ""
	Local cDados	:= ""
	
	//Valida dados no aCols.
	If Len(oParametros:aCols) <= 0
		MsgStop("Não há dados a serem salvos.","Função grvParametros(IMPRDNET)")
		Return Nil
		
	EndIf
	
	//Solicita confirmação do usuário.
	If ! MsgYesNo("Deseja salvar o(s) registro(s)?","Função grvParametros(IMPRDNET)")
		RestArea(aArea)
		Return Nil
		
	EndIf
	
	//Apaga registros existentes.
	If TcSqlExec(cUpdate) < 0
		MsgStop("Não foi possível atualizar os registros.","Função grvParametros(IMPRDNET)")
		Return Nil
		
	EndIf
	
	//Grava os novos registros.
	For i := 1 To Len(oParametros:aCols)
		
		If ! oParametros:aCols[i][Len(oParametros:aCols[1])]
		
			cChave	:= Alltrim(cValToChar(oParametros:aCols[i][Ascan(aHParam,{|x| AllTrim(x[2]) == "ROTDE"})]))
			
			cDados	:= Alltrim(cValToChar(oParametros:aCols[i][Ascan(aHParam,{|x| AllTrim(x[2]) == "ROTDE"})])) + "/" +;
					   Alltrim(cValToChar(oParametros:aCols[i][Ascan(aHParam,{|x| AllTrim(x[2]) == "ROTAT"})])) + "/" +;
					   Alltrim(cValToChar(oParametros:aCols[i][Ascan(aHParam,{|x| AllTrim(x[2]) == "TAFRT"})])) + "/" +;
					   Alltrim(cValToChar(oParametros:aCols[i][Ascan(aHParam,{|x| AllTrim(x[2]) == "TIFRT"})]))
		
			DbSelectArea("SX5")
			Reclock("SX5",.T.)
				SX5->X5_FILIAL	:= xFilial("SX5")
				SX5->X5_TABELA	:= cTab
				SX5->X5_CHAVE		:= cChave
				SX5->X5_DESCRI	:= cDados
				SX5->X5_DESCSPA	:= cDados
				SX5->X5_DESCENG	:= cDados
			MsUnlock()
		
		EndIf
	
	Next i
	
	MsgInfo("Processo relizado.","Função grvParametros(IMPRDNET)")
	
	//Fecha janela.
	oDlgConfig:End()
	
	RestArea(aArea)
	
Return Nil

/*{Protheus.doc} Static Function cargaConfPara
	Função para carregar as configurações de emplacamento
	@type  Function
	@author Everson
	@since 13/09/2016
	@version 01
*/

Static Function cargaConfPara(oParametros,aHParam,cTab)

	Local aArea	:= GetArea()
	Local aDados	:= {}
	Local i		:= 1
	Local cRotaDe := ""
	Local cRotaAte:= ""
	Local cTaFrt	:= ""
	Local cDescTa	:= ""
	Local cTiFrt	:= ""
	Local cDescTi	:= ""
	
	//Zera aCols.
	oParametros:aCols := {}
	
	//Obtém dados de parâmetros.
	aDados := dadosParametros(cTab)
	
	If Len(aDados) > 0
		
		For i := 1 To Len(aDados)
			
			cRotaDe 	:= aDados[i][1]
			cRotaAte	:= aDados[i][2]
			cTaFrt		:= aDados[i][3]
			cDescTa	:= aDados[i][4]
			cTiFrt		:= aDados[i][5]
			cDescTi	:= aDados[i][6]
			
			Aadd(oParametros:aCols , Array(Len(aHParam)+1) )
			oParametros:aCols[Len(oParametros:aCols), Len(oParametros:aCols[1]) ] := .F.
			oParametros:aCols[Len(oParametros:aCols),Ascan(aHParam,{|x| AllTrim(x[2]) == "ROTDE"  })] := Alltrim(cValToChar(cRotaDe)) + Space(10)
			oParametros:aCols[Len(oParametros:aCols),Ascan(aHParam,{|x| AllTrim(x[2]) == "ROTAT"  })] := Alltrim(cValToChar(cRotaAte)) + Space(10)
			oParametros:aCols[Len(oParametros:aCols),Ascan(aHParam,{|x| AllTrim(x[2]) == "TAFRT"  })] := Alltrim(cValToChar(cTaFrt)) + Space(04)
			oParametros:aCols[Len(oParametros:aCols),Ascan(aHParam,{|x| AllTrim(x[2]) == "DESCTA" })] := Alltrim(cValToChar(cDescTa)) + Space(30)
			oParametros:aCols[Len(oParametros:aCols),Ascan(aHParam,{|x| AllTrim(x[2]) == "TIFRT"  })] := Alltrim(cValToChar(cTiFrt)) + Space(04)
			oParametros:aCols[Len(oParametros:aCols),Ascan(aHParam,{|x| AllTrim(x[2]) == "DESCTI" })] := Alltrim(cValToChar(cDescTi)) + Space(30)
		
		Next i
	
	Else
		Aadd(oParametros:aCols , Array(Len(aHParam)+1) )
		oParametros:aCols[Len(oParametros:aCols), Len(oParametros:aCols[1]) ] := .F.
		oParametros:aCols[Len(oParametros:aCols),Ascan(aHParam,{|x| AllTrim(x[2]) == "ROTDE"  })] := Space(10)
		oParametros:aCols[Len(oParametros:aCols),Ascan(aHParam,{|x| AllTrim(x[2]) == "ROTAT"  })] := Space(10)
		oParametros:aCols[Len(oParametros:aCols),Ascan(aHParam,{|x| AllTrim(x[2]) == "TAFRT"  })] := Space(04)
		oParametros:aCols[Len(oParametros:aCols),Ascan(aHParam,{|x| AllTrim(x[2]) == "DESCTA" })] := Space(30)
		oParametros:aCols[Len(oParametros:aCols),Ascan(aHParam,{|x| AllTrim(x[2]) == "TIFRT"  })] := Space(04)
		oParametros:aCols[Len(oParametros:aCols),Ascan(aHParam,{|x| AllTrim(x[2]) == "DESCTI" })] := Space(30)
	
	EndIf
	
	oParametros:Refresh()
	
	RestArea(aArea)
			
Return Nil

/*{Protheus.doc} Static Function dadosParametros
	Função obtém dados de parâmetros	
	@type  Function
	@author Everson
	@since 13/09/2016
	@version 01
*/

Static Function dadosParametros(cTab)

	Local aDados	:= {}
	Local cQuery	:= ""
	Local cRotaDe := ""
	Local cRotaAte:= ""
	Local cTaFrt	:= ""
	Local cDescTa	:= ""
	Local cTiFrt	:= ""
	Local cDescTi	:= ""
	Local aRetorno:= {}

	cQuery := ""
	cQuery += " SELECT *  "
	cQuery += " FROM  " + RetSqlName("SX5") + "  AS SX5 "
	cQuery += " WHERE  "
	cQuery += " X5_TABELA = '" + cTab + "'  "
	cQuery += " AND SX5.D_E_L_E_T_ = '' "
	cQuery += " ORDER BY X5_CHAVE "
	
	If Select("PARAMETROS") > 0
		PARAMETROS->(DbCloseArea())
		
	EndIf
	
	TcQuery cQuery new Alias "PARAMETROS"
	DbSelectArea("PARAMETROS")
	PARAMETROS->(DbGoTop())
	
	While ! PARAMETROS->(Eof())
		
		aDados := StrToKarr(Alltrim(cValToChar(PARAMETROS->X5_DESCRI)),"/")
		
		If Len(aDados) == 4
		
			cRotaDe 	:= Alltrim(cValToChar(aDados[1]))
			cRotaAte	:= Alltrim(cValToChar(aDados[2]))
			cTaFrt		:= Alltrim(cValToChar(aDados[3]))
			cTiFrt		:= Alltrim(cValToChar(aDados[4]))
			
			cDescTa	:= Posicione("ZV8",1,xFilial("ZV8") + cTaFrt,"ZV8_CIDADE")
			cDescTi	:= Posicione("SZH",1,xFilial("SZH") + cTiFrt,"ZH_DESCRIC")
			
			Aadd(aRetorno,{cRotaDe,cRotaAte,cTaFrt,cDescTa,cTiFrt,cDescTi})
			
		EndIf
		
		PARAMETROS->(DbSkip())
		
	EndDo

Return(aRetorno)

/*{Protheus.doc} Static Function telaEmplacamento
	Função para seleção dos roteiros que serão emplacados
	@type  Function
	@author Everson
	@since 13/09/2016
	@version 01
*/

Static Function telaEmplacamento(aDadosRoteiro)

	Local oTelaRotas
	Local oMark
	Local i			:= 1
	Local w			:= 1
	Local aDados		:= {}
	
	Local cRotaDe 	:= ""
	Local cRotaAte	:= ""
	Local cTaFrt		:= ""
	Local cDescTa		:= ""
	Local cTiFrt		:= ""
	Local cDescTi		:= ""
	Local nReg			:= 0
	
	Private cMark   	:= GetMark()   
	Private lInverte 	:= .F.
	Private _stru		:= {}
	Private aCpoBro	:= {}
	Private _carq
	
	If Len(aDadosRoteiro) <= 0
		Return Nil
		
	EndIf
	
	Aadd(_stru,{"OK" 		,"C",02,0})
	Aadd(_stru,{"TMP_DATA"  ,"C",10,0})
	Aadd(_stru,{"TMP_ROT"   ,"C",10,0})
	Aadd(_stru,{"TMP_PLACA" ,"C",08,0})
	Aadd(_stru,{"TMP_TBFRT" ,"C",04,0})
	Aadd(_stru,{"TMP_DSTA"  ,"C",30,0})
	Aadd(_stru,{"TMP_TIFRT" ,"C",04,0})
	Aadd(_stru,{"TMP_DSTI"  ,"C",30,0})
	
	//Cria arquivo temporário.
	_carq := "T_" + Criatrab(,.F.)
	MsCreate(_carq,_stru,"DBFCDX")
	Sleep(1000)
	
	//Atribui a tabela temporária ao alias TRB.
	DbUseArea(.T.,"DBFCDX",_carq,"TTEMP",.T.,.F.)
	
	//Define quais colunas (campos da TTEMP) serao exibidas na MsSelect.
	Aadd(aCpoBro,{"OK"			,, ""})		
	Aadd(aCpoBro,{"TMP_DATA"		,,"Data Entrega"})		
	Aadd(aCpoBro,{"TMP_ROT"		,,"Roteiro"})
	Aadd(aCpoBro,{"TMP_PLACA"	,,"Veículo"})	
	Aadd(aCpoBro,{"TMP_TBFRT" 	,,"Tabela Frete"})
	Aadd(aCpoBro,{"TMP_DSTA"  	,,"Desc. Tabela"})
	Aadd(aCpoBro,{"TMP_TIFRT" 	,,"Tipo Frete"})
	Aadd(aCpoBro,{"TMP_DSTI"  	,,"Desc. Tipo"})
	
	//Obtém dados de parâmetros.
	aDados := dadosParametros("EA")
	
	//Preenche o arquivo temporário.
	DbSelectArea("TTEMP")
	
	For i := 1 To Len(aDadosRoteiro)
	
		If Empty(Alltrim(cValToChar(aDadosRoteiro[i][1])))
			MsgAlert("Por favor, verifique o roteiro " + Alltrim(cValToChar(aDadosRoteiro[i][3])) +;
			 		  ", pois não há veículo definido para o mesmo.","Função telaEmplacamento(IMPRDNET)")
			
		EndIf
		
		nReg := 0
		
		For w := 1 To Len(aDados)
			
			//Roteiro
			If Alltrim(cValToChar(aDadosRoteiro[i][3])) >= Alltrim(cValToChar(aDados[w][1])) .And.;
			   Alltrim(cValToChar(aDadosRoteiro[i][3])) <= Alltrim(cValToChar(aDados[w][2]))
				
				cRotaDe 	:= aDados[w][1]
				cRotaAte	:= aDados[w][2]
				cTaFrt		:= aDados[w][3]
				cDescTa	:= aDados[w][4]
				cTiFrt		:= aDados[w][5]
				cDescTi	:= aDados[w][6]
				
				nReg++
				
			EndIf
			
		Next w
		
		//Valida se há tabela de frete e tipo de frete para a rota.
		If nReg == 0
			MsgAlert("Por favor, verifique o roteiro " + Alltrim(cValToChar(aDadosRoteiro[i][3])) + ",pois não há tabela de frete e/ou tipo de frete para o mesmo.",;
					 "Função telaEmplacamento(IMPRDNET)")
		
		EndIf
		
		RecLock("TTEMP",.T.)		
			TTEMP->OK				:= cMark
			TTEMP->TMP_DATA		:= DToC(CToD(cValToChar(aDadosRoteiro[i][2])))
			TTEMP->TMP_ROT 		:= Alltrim(cValToChar(aDadosRoteiro[i][3]))
			TTEMP->TMP_PLACA		:= Alltrim(cValToChar(aDadosRoteiro[i][1]))
			TTEMP->TMP_TBFRT		:= cTaFrt
			TTEMP->TMP_DSTA		:= cDescTa
			TTEMP->TMP_TIFRT		:= cTiFrt
			TTEMP->TMP_DSTI		:= cDescTi
		MsunLock()
		
	
	Next i
		
	Define MsDialog oTelaRotas Title "Processamento da Rotina de Emplacamento" From 000, 000  To 400, 950 COLORS 0, 16777215 Pixel Style 128
		
	@ 006, 130 Say oSay1 PROMPT "Serão gerados os emplacamentos para as rotas selecionadas abaixo. Deseja prosseguir?" Size 300, 014 Of oTelaRotas COLORS 0, 16777215 Pixel
			
	oMark := MsSelect():New("TTEMP","OK","",aCpoBro ,@lInverte,@cMark ,{017,003,170,475},,,oTelaRotas,,)
	Eval(oMark:oBrowse:bGoTop)
	oMark:oBrowse:Refresh()
	
	@ 180, 006 Button oButton2 PROMPT "Editar Roteiro"  Size 060, 013 Of oTelaRotas Action (editarRota(oMark)) Pixel
	@ 180, 360 Button oButton2 PROMPT "Ok"       		   Size 048, 013 Of oTelaRotas Action (oTelaRotas:End(),Processa({||OK_Emplacamento()} ,"Processando","Aguarde...")) Pixel
	@ 180, 420 Button oButton3 PROMPT "Cancelar" 		   Size 048, 013 Of oTelaRotas Action (oTelaRotas:End()) Pixel
    
  	Activate MsDialog oTelaRotas Centered
  	
	//Fecha alias.
  	If Select("TTEMP") > 0
  		TTEMP->(DbCloseArea())
  	
  	EndIf
	
	//Apaga arquivo temporário.
	Iif(File(_carq + GetDBExtension()),FErase(_carq  + GetDBExtension()) ,Nil)
	
	MsgInfo("Processamento finalizado.","Função telaEmplacamento(IMPRDNET)")

Return(Nil)

/*{Protheus.doc} Static Function editarRota
	Função para edição de rota na MSSelect
	@type  Function
	@author Everson
	@since 15/09/2016
	@version 01
*/

Static Function editarRota(oMark)

	Local oEdicao
	Local oPlaca
	Local cPlaca	:= Alltrim(cValToChar(TTEMP->TMP_PLACA)) + Space(8)
	Local oCodTab	
	Local cCodTab	:= Alltrim(cValToChar(TTEMP->TMP_TBFRT))
	Local oDestino
	Local cDestino:= Alltrim(cValToChar(TTEMP->TMP_DSTA)) + Space(30)
	Local oTipoFrt
	Local cTipoFrt := Alltrim(cValToChar(TTEMP->TMP_TIFRT))
	Local oDescFrt
	Local cDescFrt := Alltrim(cValToChar(TTEMP->TMP_DSTI)) + Space(30)
	
	DbSelectArea("TTEMP")
	
	Define MsDialog oEdicao Title "Edição de Roteiro" From (235),(480) To (470),(919) Pixel Style 128
	
		@ (002),(001) To (090),(218) Label "Dados do roteiro" Pixel Of oEdicao
		
		@ (010),(004) Say "Roteiro               Entrega                                         " Size (193),(008) COLOR CLR_BLACK Pixel Of oEdicao
		@ (020),(005) Say Alltrim(cValToChar9(TTEMP->TMP_ROT))											Size (018),(008) COLOR CLR_RED   Pixel Of oEdicao
		@ (020),(045) Say CToD(cValToChar(TTEMP->TMP_DATA))												Size (032),(008) COLOR CLR_RED   Pixel Of oEdicao
		
		@ (040),(005) Say "Placa:" 																			Size (017),(008) COLOR CLR_BLACK Pixel Of oEdicao
		@ (040),(037) MsGet oPlaca 	 Var cPlaca   Valid U_UfPlaca(cPlaca) F3 "A05"					Size (030),(009) COLOR CLR_BLACK Pixel Of oEdicao
		@ (040),(082) MsGet oCodTab  Var cCodTab  Valid ExistCpo("ZV8",cCodTab) F3 "ZV8"				Size (040),(009) COLOR CLR_BLACK Pixel Of oEdicao
		@ (040),(127) MsGet oDestino Var cDestino Valid ! Empty(cDestino)							    Size (090),(009) COLOR CLR_BLACK Pixel Of oEdicao When .F.
		
		@ (060),(005) Say "Tipo de Frt:" 																   Size (035),(008) COLOR CLR_BLACK Pixel Of oEdicao
		@ (060),(037) MsGet oTipoFrt Var cTipoFrt Valid ExistCpo("SZH" ,cTipoFrt) F3 "SZH"  		Size (030),(009) COLOR CLR_BLACK Pixel Of oEdicao
		@ (060),(082) MsGet oDescFrt Var cDescFrt Valid ! Empty(cDescFrt)								Size (135),(009) COLOR CLR_BLACK Pixel Of oEdicao When .F.
		
		Define SButton From (100),(150) Type 1 Enable Of oEdicao Action (Ok_Edicao(oEdicao,oMark,cPlaca,cCodTab,cDestino,cTipoFrt,cDescFrt))
		Define SButton From (100),(185) Type 2 Enable Of oEdicao Action (oEdicao:End())
	
	Activate MsDialog oEdicao Centered
	
Return Nil

/*{Protheus.doc} Static Function Ok_Edicao
	Função de confirmação de edição de roteiro
	@type  Function
	@author Everson
	@since 15/09/2016
	@version 01
*/

Static Function Ok_Edicao(oEdicao,oMark,cPlaca,cCodTab,cDestino,cTipoFrt,cDescFrt)

	Local aArea	:= GetArea("TTEMP")
	
	//Remove espaços em branco.
	cPlaca 	:= Alltrim(cValToChar(cPlaca))
	cCodTab	:= Alltrim(cValToChar(cCodTab))
	cDestino	:= Alltrim(cValToChar(cDestino))
	cTipoFrt	:= Alltrim(cValToChar(cTipoFrt))
	cDescFrt	:= Alltrim(cValToChar(cDescFrt))
	
	//Verifica os argumentos da função.
	If Empty(cPlaca) .Or. Empty(cCodTab) .Or. Empty(cDestino) .Or. Empty(cTipoFrt) .Or. Empty(cDescFrt)
		MsgStop("Por favor, reveja se todos os campos estão preenchidos.","Função Ok_Edicao(IMPRDNET)")
		RestArea(aArea)
		Return Nil
		
	EndIf
	
	//Grava novos dados informados.
	DbSelectArea("TTEMP")
	RecLock("TTEMP",.F.)
		TTEMP->TMP_PLACA		:= cPlaca
		TTEMP->TMP_TBFRT		:= cCodTab
		TTEMP->TMP_DSTA		:= cDestino
		TTEMP->TMP_TIFRT		:= cTipoFrt
		TTEMP->TMP_DSTI		:= cDescFrt
	MsUnlock()
	
	//Refresh MSSelect.
	oMark:oBrowse:Refresh()
	
	//Fecha janela de edição.
	oEdicao:End()
	
	RestArea(aArea)

Return Nil

/*{Protheus.doc} Static Function OK_Emplacamento
	Função de confirmação do emplacamento
	@type  Function
	@author Everson
	@since 13/09/2016
	@version 01
*/

Static Function OK_Emplacamento()

	Local nTotRot	:= 0
	Local nAux		:= 1

	DbSelectArea("TTEMP")
	TTEMP->(DbGoTop())
	
	//Obtém o total de registros.
	nTotRot := Contar("TTEMP","!Eof() .And. ! Empty(TTEMP->OK)")
	
	//Atribui a quantidade de registros à régua de processamento.
	ProcRegua(nTotRot)
	
	TTEMP->(DbGoTop())
	While ! TTEMP->(Eof())
		
		If ! Empty(TTEMP->OK)
		
			//Incrementa a régua de processamento.
			IncProc("Processando Roteiro " + Alltrim(cValToChar(TTEMP->TMP_ROT)) + " (" + cValtoChar(nAux) + "/" + cValToChar(nTotRot) + ").") 
		
			If Empty(Alltrim(cValToChar(TTEMP->TMP_PLACA))) .Or. Empty(Alltrim(cValToChar(TTEMP->TMP_DATA))) .Or.;
			Empty(Alltrim(cValToChar(TTEMP->TMP_ROT))) .Or. Empty(Alltrim(cValToChar(TTEMP->TMP_TBFRT))) .Or. Empty(Alltrim(cValToChar(TTEMP->TMP_TIFRT)))
				
				MsgStop("Há dados não definidos para o roteiro abaixo. O emplacamento não poderá ser efetuado." + Chr(13) + Chr(10) +;
				"Roteiro: "         + Alltrim(cValToChar(TTEMP->TMP_ROT))   + "" + Chr(13) + Chr(10) +;
				"Placa: "           + Alltrim(cValToChar(TTEMP->TMP_PLACA)) + "" + Chr(13) + Chr(10) +;
				"Dt. Entrega: "     + DToC(SToD(cValToChar(TTEMP->TMP_DATA)))     + "" + Chr(13) + Chr(10) +;
				"Tabela de frete: " + Alltrim(cValToChar(TTEMP->TMP_TBFRT)) + "" + Chr(13) + Chr(10) +;
				"Tipo de frete: "   + Alltrim(cValToChar(TTEMP->TMP_TIFRT)) + "" + Chr(13) + Chr(10) ,"Função OK_Emplacamento(IMPRDNET)")
				
			Else
			
				//Gera o emplacamento.
				gerarGravaDados(TTEMP->TMP_PLACA, CToD(cValToChar(TTEMP->TMP_DATA)), TTEMP->TMP_ROT, TTEMP->TMP_TBFRT, TTEMP->TMP_TIFRT)
				
				nAux++
				
			EndIf
			
		EndIf
		
		TTEMP->(DbSkip())
		
	EndDo

Return(Nil)

/*{Protheus.doc} Static Function gerarGravaDados
	Função para emplacamento no momento da importação do arquivo de retorno no RAVEX.
	@type  Function
	@author Everson
	@since 12/09/2016
	@version 01
*/

Static Function gerarGravaDados(cPlaca, dDataEntrega, cRoteiro, cTabFrt, cTipoFrt)
	
	Local aArea	 	:= GetArea()
	Local cContMsg	:= " Será necessário efetuar o emplacamento manual."
	Local cGuia	 	:= Space(6)
	Local cCodigo		:= ""
	Local cDestino 	:= ""
	Local cDescFrt	:= ""

	//Remove espaços em branco.
	cPlaca		:= Alltrim(cValToChar(cPlaca))
	cRoteiro 	:= Alltrim(cValToChar(cRoteiro))
	
	//Valida placa informada.
	If ! U_UfPlaca(cPlaca) //Função disponível no fonte AD0055.
		RestArea(aArea)
		Return Nil
		
	EndIf
	
	//Valida argumentos da função.
	If Empty(cPlaca)
		MsgStop("Função não recebeu a placa do veículo." + cContMsg,"Função gerarGravaDados (AD0055)")
		RestArea(aArea)
		Return Nil
		
	ElseIf Empty(Alltrim(cValToChar(dDataEntrega)))
		MsgStop("Função não recebeu a data de entrega dos pedidos." + cContMsg,"Função gerarGravaDados (AD0055)")
		RestArea(aArea)
		Return Nil
		
	ElseIf Empty(cRoteiro)
		MsgStop("Função não recebeu o número do roteiro." + cContMsg,"Função gerarGravaDados (AD0055)")
		RestArea(aArea)
		Return Nil
		
	EndIf
	
	//Obtém o código da tabela de frete.
	cCodigo := cTabFrt

	//Obtém a descrição da tabela de frete.
	cDestino := Posicione("ZV8",1,xFilial("ZV8") + cCodigo, "ZV8_CIDADE")
	cDestino := Alltrim(cValToChar(cDestino))
	
	//Valida o retorno da função Posicione.
	If Empty(cDestino)
		MsgStop("Não foi possível obter a descriação da tabela de frete referente ao código " + cCodigo + "." + cContMsg,;
		"Função gerarGravaDados (AD0055)")
		RestArea(aArea)
		Return Nil
				
	EndIf
	
	//Obtém a descrição do tipo de frete.
	cDescFrt := Posicione("SZH",1,xFilial("SZH") + cTipoFrt, "ZH_DESCRIC")
	cDescFrt := Alltrim(cValToChar(cDescFrt))
	
	// Valida o retorno da função Posicione.
	If Empty(cDescFrt)
		MsgStop("Não foi possível obter a descriação do tipo de frete referente ao código " + cTipoFrt + "." + cContMsg,;
		"Função gerarGravaDados (AD0055)")
		RestArea(aArea)
		Return Nil
				
	EndIf	

	// Utilizada a função estática GravaPLACA disponível no fonte AD0055.PRW.
	If Empty(Alltrim(cValToChar(cPlaca))) .Or. Empty(Alltrim(cValToChar(cCodigo))) .Or.;
	   Empty(Alltrim(cValToChar(cDestino))) .Or. Empty(Alltrim(cValToChar(cTipoFrt))) .Or.;
	   Empty(Alltrim(cValToChar(cRoteiro))) .Or. Empty(Alltrim(cValToChar(dDataEntrega))) .Or. Empty(Alltrim(cValToChar(cDescFrt)))
		MsgStop("Função gerarGravaDados não recebeu todos os argumentos.","Função gerarGravaDados(IMPRDNET)")
		
	Else
		StaticCall(AD0055,GravaPLACA,cPlaca,cCodigo,cDestino,cTipoFrt,cRoteiro,cGuia,dDataEntrega,cDescFrt,.F.,.T.)
	
	EndIf
	
	RestArea(aArea)
	
Return(Nil)

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin,aLinhaErro)

	Local Cabec1 := "Codigo             Descrição do Campo                                Erro Encontrado na Exportação"
	Local Cabec2 := ""
	Local _nCaminha := 1
	
	Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	nLin := 8
	@ nLin,001 PSAY "A importação e o emplacamento automático não serão realizados para os registros que possuem as ocorrências listadas abaixo: "
	nLin := nLin + 1 // Avanca a linha de impressao
	
	For _nCaminha := 1 To Len(aLinhaErro) //Éverson - 12/09/2016, chamado 029242.
	
		If lAbortPrint
			@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
			
		Endif
		
		If nLin > 64 // Salto de Página. Neste caso o formulario tem 55 linhas...		
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 8
			
		Endif
					   
		@ nLin,001 PSAY Alltrim(cValToChar(aLinhaErro[_nCaminha][1])) +;
		                Space(30) + Iif(aLinhaErro[_nCaminha][2] == 2,"Imp. Pedidos - Pedido não encontrado!","") //Éverson - 12/09/2016, chamado 029242.
			
		nLin := nLin + 1 // Avanca a linha de impressao
		
	Next _nCaminha
	
	SET DEVICE TO SCREEN
	
	If aReturn[5]==1
		dbCommitAll()
		SET PRINTER TO
		OurSpool(wnrel)
	Endif
	
	MS_FLUSH()
	
Return Nil
