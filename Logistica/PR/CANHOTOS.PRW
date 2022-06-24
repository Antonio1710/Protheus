#INCLUDE "PROTHEUS.CH"
#INCLUDE "rwmake.ch"
#INCLUDE "FWBROWSE.CH"

/*/{Protheus.doc} User Function CANHOTOS
	(Relatorio de Devolução de Canhotos)
	@type  Function
	@author 
	@since 05/12/2019
	@version 01
	@history CHAMADO: 053687 - RETIRADO O BOTÃO 'DESMARCAR DIA' E DEIXADO NA POSIÇÃO O 'MARCAR TODOS' POR ADRIANO SAVOINE 05/12/2019.
	@history CHAMADO: 7805   - RETIRADO O BOTÃO 'DESMARCAR DIA' E DEIXADO NA POSIÇÃO O 'MARCAR TODOS' POR ADRIANO SAVOINE 05/12/2019.
	@history Ticket   7805   - Leonardo P. Monteiro - 12/01/2021 - Correção do error.log ao selecionar a opção de parâmetros para recarregar o componente de tela Mbrowser. Erro: 'TOTVS Manufatura ERROR.LOG - U_CANHOTOS(CANHOTOS.PRW)'.
	@history Ticket   75031  - Everson, 23/06/2022 - Tratamento para marcar registros com data de entrega futura.
	/*/

User Function CANHOTOS()   

	Private  oBrowse, oColumn, oDlg, cCondicao
	Private  aInd		 := {}            						//INDICE DO FILTRO
	Private  bFiltraBrw := {|| Nil}                           	//MONTAGEM DO FILTRO  
	Private oPanel
	Private oTFont
	Private oSBtn02
	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Relatorio de Devolução de Canhotos')
	
	cCondicao := EpaPerg(cCondicao)	//CHAMA OS PARAMETROS na entrada do programa
	// cria teclas de atalho F9, F10, F11 e F12
	SetKey(VK_F9 ,{||MarquUne(), oBrowse :Refresh(.F.) })
	SetKey(VK_F10,{||MARCA("X"), oBrowse :Refresh(.T.) })
	SetKey(VK_F11,{||DESMARCA(Space(1)), oBrowse :Refresh(.T.) })
	SetKey(VK_F12,{||cCondicao:=EpaPerg(cCondicao), ;
					EndFilBrw( "SC5", aInd ), ;
					bFiltraBrw := {|| FilBrowse( "SC5", aInd,@cCondicao ) }, ;
					Eval( bFiltraBrw ), ;
					oBrowse :Refresh(.T.) })
	
	//-------------------------------------------------------------------
	// Abertura da tabela  #include "fwmvcdef.ch" 
	//-------------------------------------------------------------------
	//DbUseArea(.T.,,"SC5010","SC5",.T.,.F.) abrir arquivo *.dbf
	dbSelectArea("SC5")
	DbSetOrder(1)
	// Filtra
	EndFilBrw( "SC5", aInd )
	bFiltraBrw := {|| FilBrowse( "SC5", aInd,@cCondicao ) }
	Eval( bFiltraBrw )
	
	//-------------------------------------------------------------------
	// Define a janela do Browse
	//-------------------------------------------------------------------
	DEFINE MSDIALOG oDlg FROM 0,0 TO 650,1250 PIXEL	TITLE "DEVOLUÇÃO DE CANHOTOS"
	 
	
	CriaObj()
	
	//-------------------------------------------------------------------
	// Ativação do janela
	//-------------------------------------------------------------------
	
	aButton := {}
	//INICIO CHAMADO: 053687 - RETIRADO O BOTÃO 'DESMARCAR DIA' E DEIXADO NA POSIÇÃO O 'MARCAR TODOS' POR ADRIANO SAVOINE 05/12/2019.
	//@ 230,290 Button "Marca Todos" Size 40,09 Action (MARCA("X"), oBrowse :Refresh(.T.)) of ODlg Pixel
	@ 230,335 Button "Marca Todos" Size 40,09 Action (MARCA("X"), oBrowse :Refresh(.T.)) of ODlg Pixel
	//@ 230,335 Button "Desmarca Dia" Size 50,09 Action (DESMARCA(Space(1)), oBrowse :Refresh(.T.)) of ODlg Pixel 
	//FIM CHAMADO: 053687 - RETIRADO O BOTÃO 'DESMARCAR DIA' E DEIXADO NA POSIÇÃO O 'MARCAR TODOS' POR ADRIANO SAVOINE 05/12/2019.  
	oSBtn02 := TButton():New(230,390,"Desmarca Fiscal",ODlg,{||DesmarcaFiscal(Space(1)),oBrowse :Refresh(.T.)},50,09,,,.F.,.T.,.F.,,.F.,,,.F. )
	
	IF !(ALLTRIM(__CUSERID) $ GETMV("MV_#USUCAN")) //chamado 039784
	
		oSBtn02:Disable()
		
	ENDIF
	
	@ 230,445 Button "Parâmetros" Size 40,09 Action (PARME(), oBrowse :Refresh(.T.)) of ODlg Pixel 
	
	@ 230,490 Button "Motivo" Size 35,09 Action (Motivo(), oBrowse :Refresh(.T.)) of ODlg Pixel
	@ 230,535 Button "Quantidade" Size 40,09 Action (Totalite()) of ODlg Pixel
	@ 230,580 Button "Sair" Size 35,09 Action ( SetKey(VK_F9 ,{||}), SetKey(VK_F10,{||}), ;
												SetKey(VK_F11,{||}), SetKey(VK_F12,{||}), oDlg:End()) of oDlg Pixel
												
	@ 250,535 Button "Relatorio" Size 40,09 Action (U_ADFAT006R(), oBrowse :Refresh(.T.)) of ODlg Pixel 
	
	ACTIVATE MSDIALOG oDlg CENTERED //ON INIT EnchoiceBar(oDlg,{|| nOpca := 1,oDlg:End()},{|| nOpca := 2,oDlg:End()},,aButton)
	
	// Limpa as teclas de atalho F9, F10, F11, e F12
	SetKey(VK_F9 ,{||})
	SetKey(VK_F10,{||})
	SetKey(VK_F11,{||})
	SetKey(VK_F12,{||})

Return                   

Static Function MarquUne()

	LOCAL dDtEntrega := CTOD("")
	
	dDtEntrega := SC5->C5_DTENTR

	IF ALLTRIM(SC5->C5_CANHOTO) == '' .OR. ALLTRIM(SC5->C5_XTIPO) = '2' //Everson - 23/06/2022. Chamado 75031.
	
		IF SC5->(RecLock("SC5",.F.))
		
			SC5->C5_CANHOTO := IIF(EMPTY(C5_CANHOTO),"X"," ")
			SC5->C5_CANHUSU := IIF(EMPTY(C5_CANHOTO) .And. EMPTY(C5_CANHMOT),"",CUSERNAME)
			SC5->C5_CANHDAT := IIF(EMPTY(C5_CANHOTO) .And. EMPTY(C5_CANHMOT),CTOD(""),DATE())
			SC5->C5_CANHHOR := IIF(EMPTY(C5_CANHOTO) .And. EMPTY(C5_CANHMOT),"",SUBSTR(Time(),1,5))
			
			SC5->(MsUnLock())
		ENDIF
		
	ELSE	
	
		IF ALLTRIM(SC5->C5_CANHOTO) == 'X'   
	
			dDtEntrega := SC5->C5_DTENTR
		
			IF (dDtEntrega > Date()) .Or. (dDtEntrega == DATE()      .OR. ; //Everson - 23/06/2022. Chamado 75031.
			   dDtEntrega  == (DATE()  - GETMV("MV_#DIACAN"))) .OR. ALLTRIM(SC5->C5_XTIPO) = '2'
			   
				   IF SC5->(RecLock("SC5",.F.))
					
						SC5->C5_CANHOTO := IIF(EMPTY(C5_CANHOTO),"X"," ")
						SC5->C5_CANHUSU := IIF(EMPTY(C5_CANHOTO) .And. EMPTY(C5_CANHMOT),"",CUSERNAME)
						SC5->C5_CANHDAT := IIF(EMPTY(C5_CANHOTO) .And. EMPTY(C5_CANHMOT),CTOD(""),DATE())
						SC5->C5_CANHHOR := IIF(EMPTY(C5_CANHOTO) .And. EMPTY(C5_CANHMOT),"",SUBSTR(Time(),1,5))
						
						SC5->(MsUnLock())
						
					ENDIF
					
			ELSE
			
				ALERT("Olá " + cUserName                   + ;
				      ' Nota Fiscal: ' + SC5->C5_NOTA       + ;
				      ' Não pode ser desmarcar o canhoto, ' + ;
					  ' para desmarcar entre em contato com a Gerente Fiscal, devido estar fora da data de liberação ' + ;
					  DTOC(DATE()- GETMV("MV_#DIACAN")) + ' até ' + DTOC(DATE()))
				
				
			ENDIF	
		ENDIF
		
	ENDIF	
Return

Static Function MARCA(cMarca)

	LOCAL dDtEntrega := CTOD("")
	Local cMensagem  := ''
	Local cRot       := ''
	Local cRotOld    := ''
	Local cDtEntr    := ''
	Local cDtEntrOld := ''
	
	cDtEntrOld := SC5->C5_DTENTR
	cRotOld    := SC5->C5_ROTEIRO

	WHILE ! SC5->(EOF())
	
		IF ALLTRIM(SC5->C5_CANHOTO) == ''   
	
			dDtEntrega := SC5->C5_DTENTR
			cDtEntr    := SC5->C5_DTENTR
			cRot       := SC5->C5_ROTEIRO
	
			IF (dDtEntrega > Date()) .Or. dDtEntrega <= DATE() .OR. ALLTRIM(SC5->C5_XTIPO) = '2'     
			   
			   IF cDtEntr == cDtEntrOld .AND. ;
			      cRot    == cRotOld          // e a mesma data de entrega e o mesmo roteiro altera 
			   
				   IF SC5->(RecLock("SC5",.F.))
					
						SC5->C5_CANHOTO := cMarca
						SC5->C5_CANHUSU := IIF(cMarca=="X",CUSERNAME,"")
						SC5->C5_CANHDAT := IIF(cMarca=="X",DATE(),CTOD(""))
						SC5->C5_CANHHOR := IIF(cMarca=="X",SUBSTR(Time(),1,5),"")
						
						SC5->(MsUnLock())
						
					ENDIF
					
				ELSE
				
					cMensagem+= "Olá " + cUserName                   + ;
					            ' Nota Fiscal: ' + SC5->C5_NOTA       + ;
					            ' Não pode ser marcado o canhoto, ' + ;
							    ' Só poderá marcar canhoto do Roteiro: ' + cRot + CHR(10) + CHR(13) + CHR(10) + CHR(13)
					
				ENDIF
			ENDIF	
		ENDIF
		SC5->(DBSkip())
		
	ENDDO

	IF !EMPTY(cMensagem)
	 
		U_ExTelaMen("CANHOTOS - Tela de Canhotos!!!", cMensagem, "Arial", 10, , .F., .T.)
		
	ENDIF	

Return

Static Function DESMARCA(cMarca)

	LOCAL dDtEntrega := CTOD("")
	Local cMensagem  := ''
	
	WHILE ! SC5->(EOF())
	
		IF ALLTRIM(SC5->C5_CANHOTO) == 'X'   
	
			dDtEntrega := SC5->C5_DTENTR
		
			IF (dDtEntrega > Date()) .Or. (dDtEntrega == DATE()      .OR. ; //Everson - 23/06/2022. Chamado 75031.
			   dDtEntrega  == (DATE() - GETMV("MV_#DIACAN"))) .OR. ALLTRIM(SC5->C5_XTIPO) = '2'
			   
				   IF SC5->(RecLock("SC5",.F.))
					
						SC5->C5_CANHOTO := cMarca
						SC5->C5_CANHUSU := IIF(cMarca=="X",CUSERNAME,"")
						SC5->C5_CANHDAT := IIF(cMarca=="X",DATE(),CTOD(""))
						SC5->C5_CANHHOR := IIF(cMarca=="X",SUBSTR(Time(),1,5),"")
						
						SC5->(MsUnLock())
						
					ENDIF
					
			ELSE
			
				cMensagem+= "Olá " + cUserName                   + ;
				            ' Nota Fiscal: ' + SC5->C5_NOTA       + ;
				            ' Não pode ser desmarcar o canhoto, ' + ;
						    ' para desmarcar entre em contato com a Gerente Fiscal, devido estar fora da data de liberação ' + ;
						    DTOC(DATE()- GETMV("MV_#DIACAN")) + ' até ' + DTOC(DATE()) + CHR(10) + CHR(13) + CHR(10) + CHR(13)
				
				
			ENDIF	
		ENDIF
		SC5->(DBSkip())
		
	ENDDO

	IF !EMPTY(cMensagem)
	 
		U_ExTelaMen("CANHOTOS - Tela de Canhotos!!!", cMensagem, "Arial", 10, , .F., .T.)
		
	ENDIF	

Return


Static Function PARME()

	If  ValType(oBrowse) == "O"
		//Ticket   7805 - Leonardo P. Monteiro - 12/01/2021 - Correção do error.log 'TOTVS Manufatura ERROR.LOG - U_CANHOTOS(CANHOTOS.PRW)'.
		oBrowse:DeActivate(.t.)
		//oBrowse:oBrowse:END  
		//oBrowse:END
		//oBrowse:= NIl
		
	EndIf                   
	                        
	EndFilBrw( "SC5", aInd )
	cCondicao := EpaPerg(cCondicao)       
	
	dbSelectArea("SC5")
	DbSetOrder(1)
	
	aInd := {}
	// Filtra 
	bFiltraBrw := {|| FilBrowse( "SC5", aInd,@cCondicao ) }
	Eval( bFiltraBrw )
	
	                  
	CriaObj()

      
Return Nil


Static Function EpaPerg(cCondicao)

	Pergunte("CANHOTO",.T.)
	
	cCondicao:="C5_FILIAL == " + CHR(34) + xFilial("SC5") + CHR(34) + ;
               " .AND. dToS(C5_DTENTR) >= " + CHR(34) + dToS(MV_PAR01) + CHR(34) + ;
               " .AND. dToS(C5_DTENTR) <= " + CHR(34) + dToS(MV_PAR02) + CHR(34) + ;
               Iif(MV_PAR03<>"       ", " .AND. C5_PLACA == " + CHR(34) + MV_PAR03 + CHR(34), "") + ;
               " .AND. C5_ROTEIRO >= " + CHR(34) + MV_PAR04 + CHR(34) + ;
               " .AND. C5_ROTEIRO <= " + CHR(34) + MV_PAR05 + CHR(34) + ;  
               " .AND. C5_NOTA >= " + CHR(34) + MV_PAR07 + CHR(34) + ;
               " .AND. C5_NOTA <= " + CHR(34) + MV_PAR08 + CHR(34) + ;
               Iif(MV_PAR06==2, " .AND. C5_CANHOTO != " + CHR(34) + "X" + CHR(34), "") + ;
               " .AND. C5_NOTA != " + CHR(34) + " " + CHR(34)
               
Return cCondicao

Static Function Motivo()  

	Local cMotivo := SC5->C5_CANHMOT
	Local oPainerzin := Nil
	
	DEFINE MSDIALOG oPainerzin FROM 0,0 TO 60,400 PIXEL	TITLE "Motivo de Não Devolução do Canhoto"
	
		@ 10,08 MSGET oPed Var cMotivo SIZE 160,13 PIXEL OF oPainerzin
		@ 10,170 BUTTON "&OK" SIZE 23,14 PIXEL ACTION oPainerzin:End()
	
	ACTIVATE DIALOG oPainerzin CENTER
	
	If SC5->(RecLock("SC5",.F.))
	
		SC5->C5_CANHMOT := cMotivo
		SC5->C5_CANHUSU := Iif(Empty(C5_CANHOTO) .And. Empty(C5_CANHMOT),"",CUSERNAME)
		SC5->C5_CANHDAT := Iif(Empty(C5_CANHOTO) .And. Empty(C5_CANHMOT),CtoD(""),DATE())
		SC5->C5_CANHHOR := Iif(Empty(C5_CANHOTO) .And. Empty(C5_CANHMOT),"",SUBSTR(Time(),1,5))
		SC5->(MsUnLock())
		
	Endif
	
Return

Static Function Totalite()

	Local _nVerde:=0
	Local _nVermelho:=0
	
	Count to _nVerde	for C5_CANHOTO == "X"
	Count to _nVermelho	for C5_CANHOTO != "X"
	
	_nTotal   := _nVerde + _nVermelho
	_aLegenda := {	{ "BR_VERDE"		, " Devolvidos      " + Space(4) + Transform(_nVerde, "@E ##9,999") },;
					{ "BR_VERMELHO"		, " Não Devolvidos  " + Space(1) + Transform(_nVermelho, "@E ##9,999") },;
					{ ""				, "___________________________________________________" },;
					{ ""				, Space(18) + "Total " + Space(3) + Transform(_nTotal, "@E ##9,999") } }
						
	BrwLegenda( "Total", "Devolução de Canhotos", _aLegenda )
	
Return(Nil)


Static Function CriaObj()

	oPanel:= tPanel():New(00,00,,oDlg,oTFont,.T.,,CLR_WHITE,CLR_WHITE,626,200)
	
	DEFINE FWBROWSE oBrowse DATA TABLE ALIAS "SC5" OF oPanel
	
	oBrowse :DisableConfig()
	oBrowse :DisableReport()
	oBrowse :DisableSeek()
	oBrowse :DisableLocate()
	oBrowse:SetLineHeight(2)
		
	//--------------------------------------------------------		
	// Cria uma coluna de marca/desmarca		
	//--------------------------------------------------------		
	ADD MARKCOLUMN oColumn DATA { || If(C5_CANHOTO=="X",'LBOK','LBNO') } DOUBLECLICK { |oBrowse| MarquUne() } ;
				HEADERCLICK { |oBrowse| oBrowse :Refresh(.T.), oBrowse :Refresh(.T.) } OF oBrowse
	//--------------------------------------------------------		
	// Adiciona legenda no Browse		
	//--------------------------------------------------------		
	// //ADD LEGEND DATA 'C5_CANHOTO == " "' COLOR "GREEN" TITLE "Chave teste 1" OF oBrowse		
	// //ADD LEGEND DATA 'C5_CANHOTO != " "' COLOR "RED"   TITLE "Chave teste 2" OF oBrowse		
	//-------------------------------------------------------------------		
	// Adiciona as colunas do Browse		
	//-------------------------------------------------------------------		
	ADD COLUMN oColumn DATA { || C5_FILIAL  } TITLE "Fil"          SIZE 02 OF oBrowse		
	ADD COLUMN oColumn DATA { || C5_DTENTR  } TITLE "Entrega"      SIZE 10 OF oBrowse		
	ADD COLUMN oColumn DATA { || C5_NOTA    } TITLE "Nº NF"        SIZE 09 OF oBrowse		
	ADD COLUMN oColumn DATA { || C5_NUM     } TITLE "Pedido"       SIZE 06 OF oBrowse
	ADD COLUMN oColumn DATA { || C5_PLACA   } TITLE "Placa"        SIZE 07 OF oBrowse		
	ADD COLUMN oColumn DATA { || C5_NOMECLI } TITLE "Cliente"      SIZE 06 OF oBrowse		
	ADD COLUMN oColumn DATA { || C5_CIDADE  } TITLE "Cidade"       SIZE 15 OF oBrowse		
	ADD COLUMN oColumn DATA { || C5_EST     } TITLE "UF"           SIZE 02 OF oBrowse
	ADD COLUMN oColumn DATA { || C5_ROTEIRO } TITLE "Roteiro"      SIZE 03 OF oBrowse		
	ADD COLUMN oColumn DATA { || C5_CANHUSU } TITLE "Canh.Usuario" SIZE 10 OF oBrowse
	ADD COLUMN oColumn DATA { || C5_CANHDAT } TITLE "Data Canhoto" SIZE 10 OF oBrowse
	ADD COLUMN oColumn DATA { || C5_CANHHOR } TITLE "Hora Canhoto" SIZE 08 OF oBrowse
	ADD COLUMN oColumn DATA { || C5_CANHMOT } TITLE "Motivo"       SIZE 50 OF oBrowse
	//-------------------------------------------------------------------	
	// Ativação do Browse	
	//-------------------------------------------------------------------	
	
	
	ACTIVATE FWBROWSE oBrowse

Return Nil

Static Function DesmarcaFiscal(cMarca)

	While ! SC5->(EOF())
		If SC5->(RecLock("SC5",.F.))
			SC5->C5_CANHOTO := cMarca
			SC5->C5_CANHUSU := Iif(cMarca=="X",CUSERNAME,"")
			SC5->C5_CANHDAT := Iif(cMarca=="X",DDATABASE,CtoD(""))
			SC5->C5_CANHHOR := Iif(cMarca=="X",SUBSTR(Time(),1,5),"")
			SC5->(MsUnLock())
		Endif
		SC5->(DBSkip())
	End
    
Return()
