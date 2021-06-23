#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include "RwMake.ch"
#Include "Totvs.ch"
#Include "Topconn.ch"

/*/{Protheus.doc} User Function ADFAT007P
	APP Aprovação de Refaturamento
	@type  Function
	@author user
	@since 18/11/2019
	@version 1
	@history 26/09/18 | Ricardo Lima      | APP Aprovação de Refaturamento             | 044082
	@history 18/10/2019 | Abel Babini | Ch 052777 | Possibilitar Alterar a quantidade de venda de produtos de faturamento real (MV_PRDREAL) quanto Solicitado Refaturamento.
	/*/
User Function ADFAT007P

Local aAreaAtu   := GetArea()
Local oSay1
Local oSay2
Local oTGet1
Local oFont1 := TFont():New("MS Sans Serif",0,-12,,.T.,0,,700,.T.,.F.,.F.,,,,,)
Local aSize  := {}

Private oCombo
Private aItems := {'Sim','Nao'}
Private cCombo := aItems[1]
Private sObs   := Space(254)

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'APP Aprovação de Refaturamento')

aSize := MsAdvSize(.T.)

Define MsDialog oPrjWindow TITLE "Solicita Aprovação para Refaturamento" STYLE DS_MODALFRAME From aSize[7],0 To aSize[6]-(aSize[6]/2),aSize[5]-(aSize[5]/1.6) OF oPrjWindow /*oMainWnd*/ PIXEL

oSay1 := TSay():New( 35, 008, { || "Deseja Solicitar Aprovação para Refaturamento?"}  , oPrjWindow, ,oFont1 , .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 160, 008 )
oCombo := TComboBox():New(35,150,{|u|if(PCount()>0,cCombo:=u,cCombo)}, aItems,70,20,oPrjWindow,,,,,,.T.,,,,,,,,,'cCombo')

oSay2 := TSay():New( 60, 008, { || "Observação"}  , oPrjWindow, ,oFont1 , .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 090, 008 )
oTGet1  := tMultiget():new( 60, 50, {| u | if( pCount() > 0, sObs := u, sObs ) }, oPrjWindow, 190, 50, , , , , , .T. )

ACTIVATE MSDIALOG oPrjWindow ON INIT EnchoiceBar(oPrjWindow,{|| Processa({|| ADFATA7()},,"Processando...") ,oPrjWindow:End()},{|| oPrjWindow:End()}) CENTERED

RestArea( aAreaAtu )

Return .T.

/*/{Protheus.doc} Static Function AjuQtRft
	Permite Alterar quantidades para produtos de de faturamento de peso real.
	@type  Function
	@author Abel Babini Filho
	@since 18/10/2019
	@version 1
	/*/
Static Function AjuQtRft()
	Local aAreaSC6	:= GetArea('SC6')	
	Local C5Filial	:= SC5->C5_FILIAL
	Local C5Pedido	:= SC5->C5_NUM
	Local cMVPrRea	:= GETMV("MV_PRDREAL",,"")
	Local lCont		:= .F.
	
	Local oDlgAtB	:= Nil
	Local oBtnCan	:= Nil
	Local oBtnOK	:= Nil
	Local nPAju		:= 0

	Local cAlPBrut
	Local _nTotalBr		:= 0
	Local _nTotalkg		:= 0
	Local _nTotalCx		:= 0     
				
	Private nQtdAju	:= 0
	
	//POSICIONA ITEM P.V. (SC6)
	SC6->(DbSeek(xFilial("SC6")+SC5->C5_NUM))

	//POSICIONA CLIENTE (SA1/SA2)
	If ALLTRIM(SC5->C5_TIPO)$"NCIP"
		SA1->(DbSeek(xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI))
	Else
		SA2->(DbSeek(xFilial("SA2")+SC5->C5_CLIENTE+SC5->C5_LOJACLI))
	Endif

	
	While !SC6->(Eof()) .AND. SC6->C6_FILIAL == C5Filial .AND. SC6->C6_NUM == C5Pedido
		nQtdAju	:= SC6->C6_QTDVEN
		lCont		:= .F.
		
		IF Alltrim(SC6->C6_PRODUTO) $ cMVPrRea //18/10/2019 | Abel Babini | Ch 052777 | Possibilitar Alterar a quantidade de venda de produtos de faturamento real (MV_PRDREAL) quanto Solicitado Refaturamento.
		
			DEFINE MSDIALOG oDlgAtB TITLE "Refaturamento - Altera Quantidade para Peso Real" FROM 000, 000  TO 240, 640 COLORS 0, 16777215 PIXEL style 128
			oDlgAtB:lEscClose     := .F. //Permite sair ao se pressionar a tecla ESC.
			
			DEFINE SBUTTON oBtnCan 	FROM 089, 190 TYPE 02 OF oDlgAtB ENABLE Action( oDlgAtB:End() )
			DEFINE SBUTTON oBtnOK 	FROM 089, 240 TYPE 01 OF oDlgAtB ENABLE Action( IIF( ValidQt(), ( lCont := .T., oDlgAtB:End() ), .F. ) )

			@ 005,010 SAY OemToAnsi('Cod. Cliente')					SIZE 030,025 	OF oDlgAtB COLORS 0 PIXEL
			@ 014,010 MSGET OemToAnsi(ALLTRIM(SC6->C6_CLI))			SIZE 030,008	OF oDlgAtB PIXEL When .F. PICTURE '@!'
			
			@ 005,040 SAY OemToAnsi('Loja ')						SIZE 150,025 	OF oDlgAtB COLORS 0, 16777215 PIXEL
			@ 014,040 MSGET OemToAnsi(ALLTRIM(SC6->C6_LOJA))		SIZE 015,008	OF oDlgAtB PIXEL When .F. PICTURE '@!'
			
			@ 005,070 SAY OemToAnsi('Cliente')						SIZE 150,025 	OF oDlgAtB COLORS 0, 16777215 PIXEL
			@ 014,070 MSGET OemToAnsi(IIF(ALLTRIM(SC5->C5_TIPO)$"NCIP",SA1->A1_NOME,SA2->A2_NOME))	SIZE 100,008	OF oDlgAtB PIXEL When .F. PICTURE '@!'
			
			@ 005,180 SAY OemToAnsi('Dt. Emissão')					SIZE 150,025 	OF oDlgAtB COLORS 0, 16777215 PIXEL
			@ 014,180 MSGET OemToAnsi(DTOC(SC5->C5_EMISSAO))		SIZE 035,008	OF oDlgAtB PIXEL When .F. PICTURE '@!'
			
			//@ 005,220 SAY OemToAnsi('Dt. Entrada')				SIZE 150,025 	OF oDlgAtB COLORS 0, 16777215 PIXEL
			//@ 014,220 MSGET OemToAnsi(DTOC(SD1->D1_DTDIGIT))		SIZE 035,008	OF oDlgAtB PIXEL When .F. PICTURE '@!'
			
		
			@ 030,010 SAY OemToAnsi('Pedido')						SIZE 050,025 	OF oDlgAtB COLORS 0, 16777215 PIXEL
			@ 039,010 MSGET OemToAnsi(ALLTRIM(SC6->C6_NUM))			SIZE 040,008 	OF oDlgAtB PIXEL When .F. PICTURE '@!'
						
			@ 030,053 SAY OemToAnsi('Item Ped.')					SIZE 050,025 	OF oDlgAtB COLORS 0, 16777215 PIXEL
			@ 039,053 MSGET OemToAnsi(ALLTRIM(SC6->C6_ITEM))		SIZE 022,008 	OF oDlgAtB PIXEL When .F. PICTURE '@!'
			
			@ 030,077 SAY OemToAnsi('Cod. Prod')					SIZE 050,025 	OF oDlgAtB COLORS 0, 16777215 PIXEL
			@ 039,077 MSGET OemToAnsi(ALLTRIM(SC6->C6_PRODUTO))		SIZE 050,008 	OF oDlgAtB PIXEL When .F. PICTURE '@!'
			
			@ 030,133 SAY OemToAnsi('Produto')						SIZE 050,025 	OF oDlgAtB COLORS 0, 16777215 PIXEL
			@ 039,133 MSGET OemToAnsi(ALLTRIM(SC6->C6_DESCRI))		SIZE 160,008 	OF oDlgAtB PIXEL When .F. PICTURE '@!'
		
			@ 055,010 SAY OemToAnsi('Seg.UM')						SIZE 050,025 	OF oDlgAtB COLORS 0, 16777215 PIXEL
			@ 064,010 MSGET OemToAnsi(ALLTRIM(SC6->C6_SEGUM))		SIZE 020,008 	OF oDlgAtB PIXEL When .F. PICTURE '@!'

			@ 055,033 SAY OemToAnsi('Qtd. Seg. UM')					SIZE 050,025 	OF oDlgAtB COLORS 0, 16777215 PIXEL
			@ 064,033 MSGET SC6->C6_UNSVEN							SIZE 050,008 	OF oDlgAtB PIXEL When .F. PICTURE '@E 999,999,999.99'

			@ 055,086 SAY OemToAnsi('Unid.Med')						SIZE 050,025 	OF oDlgAtB COLORS 0, 16777215 PIXEL
			@ 064,086 MSGET OemToAnsi(ALLTRIM(SC6->C6_UM))			SIZE 020,008 	OF oDlgAtB PIXEL When .F. PICTURE '@!'

			@ 055,109 SAY OemToAnsi('Qtd. Atual')					SIZE 050,025 	OF oDlgAtB COLORS 0, 16777215 PIXEL
			@ 064,109 MSGET SC6->C6_QTDVEN							SIZE 050,008 	OF oDlgAtB PIXEL When .F. PICTURE '@E 999,999,999.99'
		
			@ 055,162 SAY OemToAnsi('Qtd. Ajustada')				SIZE 050,025 	OF oDlgAtB COLORS 0, 16777215 PIXEL
			@ 064,162 MSGET nQtdAju									SIZE 050,008 	OF oDlgAtB PIXEL When .T. PICTURE '@E 999,999,999.99'
			
			ACTIVATE MSDIALOG oDlgAtB CENTERED
			
			IF lCont .AND. !(nQtdAju == SC6->C6_QTDVEN)
				
				nPAju	:= nQtdAju-SC6->C6_QTDVEN
			
				RecLock("SC6",.F.)
					SC6->C6_QTDVEN	:= nQtdAju
					SC6->C6_QTDEMP	:= nQtdAju
					SC6->C6_VALOR 	:= ROUND((nQtdAju*C6_PRCVEN),2)
				MsUnlock()

				SC9->(DbSetOrder(2))
				IF SC9->(dbSeek(xFilial("SC9")+SC6->C6_CLI+SC6->C6_LOJA+SC6->C6_NUM+SC6->C6_ITEM))
					RecLock("SC9",.F.)
						SC9->C9_QTDLIB	:= nQtdAju
					MsUnlock()
				ENDIF
				
				//Ajusta Peso Liquido e Peso Bruto
				If Select(cAlPBrut) > 0
					(cAlPBrut)->(dbCloseArea())
				Endif
				cAlPBrut:=GetNextAlias()
				BeginSQL  Alias cAlPBrut
					SELECT SUM(C6_UNSVEN*ZC_TARA) PBRUTO, SUM(C6_QTDVEN) PLIQUI, SUM(C6_UNSVEN) CX
					FROM %TABLE:SC6% SC6
					INNER JOIN %TABLE:SZC% SZC ON 
						ZC_UNIDADE = C6_SEGUM AND
						SZC.%notDel% 
					WHERE C6_FILIAL =%xFilial:SC6%
					AND C6_NUM = %Exp:SC6->C6_NUM%
					AND SC6.%notDel% 
					GROUP BY C6_FILIAL, C6_NUM
				EndSQL 
				DbSelectArea(cAlPBrut)
				(cAlPBrut)->(DbGoTop())
				_nTotalBr   := (cAlPBrut)->PBRUTO
				_nTotalkg   := (cAlPBrut)->PLIQUI
				_nTotalCx   := (cAlPBrut)->CX     
				
				(cAlPBrut)->(dbCloseArea())

				RecLock("SC5",.F.)
					If cEmpAnt == "02"
						SC5->C5_PBRUTO  := _nTotalBr
					Else
						SC5->C5_PBRUTO  := _nTotalBr + _nTotalkg
					Endif
					SC5->C5_PESOL   := _nTotalKg
					SC5->C5_VOLUME1 := _nTotalCx
				MsUnlock()
				
			ENDIF
		ENDIF
	
		SC6->(DBSkip())
	Enddo
	
	RestArea(aAreaSC6)
Return


Static Function ValidQt()
	Local lRet := .T.
	Local nBut	:= 1
	
	IF ! nQtdAju == SC6->C6_QTDVEN
		nBut:=AVISO("Alterar Qtd. Venda","Você está alterando a quantidade de venda do item "+Alltrim(SC6->C6_PRODUTO)+" - "+chr(13)+;
				Alltrim(SC6->C6_DESCRI)+", de "+Alltrim(Str(SC6->C6_QTDVEN))+" para "+Alltrim(Str(nQtdAju))+chr(13)+"."+;
				"Deseja realmente alterar?",{"Não", "Sim"},1)
		IF nBut == 2
			lRet	:= .T.
		Else
			lRet	:= .F.
			nQtdAju := SC6->C6_QTDVEN
		Endif
	ENDIF
Return lRet

/*/{Protheus.doc} Static Function ADFATA7
	APP Aprovação de Refaturamento
	@type  Function
	@author Ricardo Lima
	@since 26/09/18
	@history Chamado 044082
	/*/
Static Function ADFATA7

	if oCombo:aItems[oCombo:NAT]='Sim'
		Reclock('SC5',.F.)
			SC5->C5_XAPREFA := 'S'
			SC5->C5_XOBSRFA := Alltrim(SC5->C5_XOBSRFA) + Alltrim(sObs) + ', '
			SC5->C5_REFATUR := ''
			SC5->C5_XUSREFA := __cUserId
		Msunlock('SC5')
		
		//Chamadi Interno TI - Abel Babini Filho - 18/10/2019 - Permite Alterar quantidades para produtos de de faturamento de peso real.
		AjuQtRft()

		
		ADFATW7() // envia Workflow
		ApMsgInfo('Pedido enviado para Aprovação de Refaturamento','Aprovação de Refaturamento')

	Else
		ApMsgInfo('Marque como Sim para que o Pedido seja enviado para Aprovação de Refaturamento','Aprovação de Refaturamento')
	endif

Return

/*/{Protheus.doc} Static Function ADFATW7
	APP Aprovação de Refaturamento
	@type  Function
	@author Ricardo Lima 
	@since 26/09/18
	@version version
	@history Chamado 044082
	/*/
Static Function ADFATW7

	Local sMsg := ""
	Local cAssunto := "Aprovação de Refaturamento"
	Local cQuery   := ""
	Local sDestWF  := CTBSplit( Alltrim(GETMV("MV_IDREFAT")) , "/")

	cQuery := " SELECT * "
	cQuery += " FROM "+RetSqlName("SC6")+" C6 "
	cQuery += " WHERE C6_FILIAL = '"+SC5->C5_FILIAL+"' AND C6_NUM = '"+SC5->C5_NUM+"' "
	cQuery += " AND C6.D_E_L_E_T_ = ' ' "
	If Select("TC6") > 0
		TC6->(DbCloseArea())
	EndIf
	TcQuery cQuery New Alias "TC6"

	sMsg := "<!DOCTYPE html PUBLIC '-//W3C//DTD XHTML 1.0 Transitional//EN' 'http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd'>"
	sMsg += "<head>"
	sMsg += "<meta http-equiv='Content-Language' content='pt-br' />"
	sMsg += "<meta http-equiv='Content-Type' content='text/html; charset=utf-8' />"
	sMsg += "<title>Aprovação de Pedido de Venda para Refaturamento</title>"
	sMsg += "<style type='text/css'>"
	sMsg += ".style1 {"
	sMsg += "font-family: 'Century Gothic';"
	sMsg += "text-align: center;"
	sMsg += "text-decoration: underline;"
	sMsg += "font-size: x-large;"
	sMsg += "}"
	sMsg += ".style2 {"
	sMsg += "text-align: left;"
	sMsg += "font-family: 'Century Gothic';"
	sMsg += "}"
	sMsg += "td"
	sMsg += "{border-style: none;"
	sMsg += "border-color: inherit;"
	sMsg += "border-width: medium;"
	sMsg += "padding-top:1px;"
	sMsg += "padding-right:1px;"
	sMsg += "padding-left:1px;"
	sMsg += "color:gray;"
	sMsg += "font-size:9.0pt;"
	sMsg += "font-weight:400;"
	sMsg += "font-style:normal;"
	sMsg += "text-decoration:none;"
	sMsg += "font-family:'Century Gothic', sans-serif;"
	sMsg += "text-align:general;"
	sMsg += "vertical-align:middle;"
	sMsg += "white-space:nowrap;"
	sMsg += "}"
	sMsg += ".style4 {"
	sMsg += "font-family: 'Century Gothic';"
	sMsg += "}"
	sMsg += "</style>"
	sMsg += "</head>"
	sMsg += "<body>"
	sMsg += "<p><img alt='ADORO' src='http://www.adoro.com.br/images/logo-adoro.png' style='float: left' /></p>"
	sMsg += "<p class='style1'><strong>Aprovação de Pedido de Venda para Refaturamento</strong></p>"
	sMsg += "<p class='style2'>&nbsp;<span style='font-size: 12.0pt; mso-fareast-font-family: Calibri; mso-fareast-theme-font: minor-latin; color: black; mso-ansi-language: PT-BR; mso-fareast-language: PT-BR; mso-bidi-language: AR-SA'>Foi solicitado a aprovação para Refaturamento de Pedido de vendas,"
	sMsg += " Pedido: <strong>"+SC5->C5_NUM+"</strong></span>.</p>"
	sMsg += "<table style='width: 679pt'>"
	sMsg += "<tr>"
	sMsg += "<td>Cliente</td>"
	sMsg += "<td>Loja</td>"
	sMsg += "<td>Nome Cliente</td>"
	sMsg += "<td>Endereço</td>"
	sMsg += "<td>Cidade</td>"
	sMsg += "<td>Data Emissão</td>"
	sMsg += "<td>Data Entrega</td>"
	sMsg += "<td>&nbsp;</td>"
	sMsg += "<td>&nbsp;</td>"
	sMsg += "</tr>"
	sMsg += "<tr>"
	sMsg += "<td>"+SC5->C5_CLIENTE+"</td>"
	sMsg += "<td>"+SC5->C5_LOJACLI+"</td>"
	sMsg += "<td>"+SC5->C5_NOMECLI+"</td>"
	sMsg += "<td>"+SC5->C5_ENDERE+"</td>"
	sMsg += "<td>"+SC5->C5_CIDADE+"</td>"
	sMsg += "<td>"+DTOC(SC5->C5_EMISSAO)+"</td>"
	sMsg += "<td>"+DTOC(SC5->C5_DTENTR)+"</td>"
	sMsg += "<td>&nbsp;</td>"
	sMsg += "<td>&nbsp;</td>"
	sMsg += "</tr>"
	sMsg += "<tr>"
	sMsg += "<td></td>"
	sMsg += "</tr>"
	sMsg += "<tr>"
	sMsg += "<td>Item</td>"
	sMsg += "<td>Produto</td>"
	sMsg += "<td>Descrição</td>"
	sMsg += "<td>Seg UM Medida</td>"
	sMsg += "<td>Qtd Seg UM</td>"
	sMsg += "<td>Valor Unitario</td>"
	sMsg += "<td>Valor Total</td>"
	sMsg += "<td>Pri UM</td>"
	sMsg += "<td>Qtd Pri UM</td>"
	sMsg += "</tr>"
	While TC6->(!Eof())
			sMsg += "<tr>"
			sMsg += "<td>"+TC6->C6_ITEM+"</td>"
			sMsg += "<td>"+TC6->C6_PRODUTO+"</td>"
			sMsg += "<td>"+TC6->C6_DESCRI+"</td>"
			sMsg += "<td>"+TC6->C6_SEGUM+"</td>"
			sMsg += "<td>"+Transform( TC6->C6_UNSVEN , X3Picture( "C6_UNSVEN" ))+"</td>"
			sMsg += "<td>"+Transform( TC6->C6_PRCVEN , X3Picture( "C6_PRCVEN" ))+"</td>"
			sMsg += "<td>"+Transform( TC6->C6_VALOR , X3Picture( "C6_VALOR" ))+"</td>"
			sMsg += "<td>"+TC6->C6_UM+"</td>"
			sMsg += "<td>"+Transform( TC6->C6_QTDVEN , X3Picture( "C6_QTDVEN" ))+"</td>"
			sMsg += "</tr>"
		TC6->(dbSkip())
	End
	sMsg += "<tr>"
	sMsg += "<td>&nbsp;</td>"
	sMsg += "<td>&nbsp;</td>"
	sMsg += "<td>&nbsp;</td>"
	sMsg += "<td>&nbsp;</td>"
	sMsg += "<td>&nbsp;</td>"
	sMsg += "<td>Total do Pedido</td>"
	sMsg += "<td>"+Transform( SC5->C5_XTOTPED , X3Picture( "C5_XTOTPED" ))+"</td>"
	sMsg += "<td>&nbsp;</td>"
	sMsg += "<td>&nbsp;</td>"
	sMsg += "<td>&nbsp;</td>"
	sMsg += "</tr>"
	sMsg += "<tr>"
	sMsg += "<td>Obs</td>"
	sMsg += "<td>"+SC5->C5_XOBSRFA+"</td>"
	sMsg += "</tr>"
	sMsg += "</table>"
	sMsg += "<p>&nbsp;</p>"
	sMsg += "<p class='style4'>"
	sMsg += "<p class='style4'>Envio Automático - AD&#39;ORO</p>"
	sMsg += "</body>"
	sMsg += "</html>"

	For w:=1 to Len(sDestWF)
		U_F50En2WF( UsrRetMail(sDestWF[w]) , '' , cAssunto , sMsg , '' )
	Next

Return