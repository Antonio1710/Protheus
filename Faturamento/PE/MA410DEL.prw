#INCLUDE "fiveWin.ch"   
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH" 

/*/{Protheus.doc} User Function MA410DEL
	Ponto de Entrada que envia email para os responsaveis pelo Pedido de Venda 
	informando o motivo do bloqueio PE refedinido em subst. ao PE A410EXC por
	HCCONSYS 16/01/09
	@type  Function
	@author HCCONSYS
	@since 16/01/09
	@history chamato TI    -              - 24/05/2019 - Devido a substituicao email para shared relay, substituido MV_RELACNT p/ MV_RELFROM
	@history ticket 8      - Abel Babini  - 01/03/2021 - Não limpar flag dos registros e chamar a rotina de liberação de crédtio.
	@history ticket 8      - Abel Babini  - 03/03/2021 - Nova versao - Não limpar flag dos registros e chamar a rotina de liberação de crédtio.
	/*/
User Function MA410DEL()
	
	Local aArea		:= GetArea()
	Local cMotivo 	:= Space(115)
	Local nOpt 		:= 0
	Local lRet		:= .f.
	Local _lMail	:= .f.
	Local _nTotSC6	:= 0
	Local _cMens	:= " "
	Local _cMens1	:= " "
	Local _cMens2	:= " "
	Local _cMens3	:= " "   
	Local cAliasSD1	:= GetNextAlias()
	Local cQuery    := ""
	Local _cFilial  := SC5->C5_FILIAL
	Local cPedido	:= SC5->C5_NUM
	Local _cCliente := SC5->C5_CLIENTE
	Local _cLoja    := SC5->C5_LOJACLI
	Local _cPedAnt  := SC5->C5_XREFATD

	if cEmpAnt <> "01" //Alterado por Adriana devido ao error.log quando empresa <> 01 - chamado 032804
		Return(.t.)
	endif     

	//ticket 8      - Abel Babini  - 01/03/2021 - Não limpar flag dos registros e chamar a rotina de liberação de crédtio.
	//fPreAprv(_cFilial,cPedido,_cCliente,_cLoja)  //&&funcao pra limpeza de flag de pre aprovacao de pedidos de venda.
	StaticCall(M410STTS,fLibCred, SC5->C5_CLIENTE, SC5->C5_LOJACLI, SC5->C5_DTENTR, .T., SC5->C5_FILIAL+SC5->C5_NUM)

	//&&Mauricio - Chamado 037330 - 07/10/17 - limpo nr pedido na exclusão de um pedido
	IF !Empty(_cPedAnt)
		AltPedOr(_cPedAnt,cPedido)
	Endif   

	If !IsInCallStack('U_RESTEXECUTE') .And. ! IsInCallStack('RESTEXECUTE') .And. SC5->C5_UFPLACA <> "99" //&&12/10/16 - Flag para pedido excluido por rotina ADFIN006P/ADFIN018P

		DEFINE MSDIALOG oDlg FROM	18,1 TO 80,550 TITLE "ADORO S/A Crédito -  Motivo do Bloqueio" PIXEL
		@  1, 3 	TO 28, 242 OF oDlg  PIXEL
		If File("adoro.bmp")
			@ 3,5 BITMAP oBmp FILE "adoro.bmp" OF oDlg NOBORDER SIZE 25,25 PIXEL
			oBmp:lStretch:=.T.
		EndIf
		@ 05, 37	SAY "Motivo:" SIZE 24, 7 OF oDlg PIXEL
		@ 12, 37  	MSGET cMotivo  SIZE	200, 9 OF oDlg PIXEL Valid !Empty(cMotivo)
		DEFINE SBUTTON FROM 02,246 TYPE 1 ACTION (nOpt := 1,oDlg:End()) ENABLE OF oDlg
		//DEFINE SBUTTON FROM 16,246 TYPE 2 ACTION oDlg:End() ENABLE OF oDlg //fernando sigoli 28/04/2017

		ACTIVATE MSDIALOG oDlg CENTERED

		If nOpt == 1                                                                            
			_lMail	:= .T.
			lRet 		:= .T.
		Else
			return(lRet)
		Endif

	Else
		lRet := .T.	
	Endif

	If _lMail .Or. IsInCallStack('RESTEXECUTE') .Or. IsInCallStack('U_RESTEXECUTE')

		_cMens1 := '<html>'
		_cMens1 += '<head>'
		_cMens1 += '<meta http-equiv="content-type" content="text/html;charset=iso-8859-1">'
		_cMens1 += '<meta name="generator" content="Microsoft FrontPage 4.0">'
		_cMens1 += '<title>Pedido Bloqueado</title>'
		_cMens1 += '<meta name="ProgId" content="FrontPage.Editor.Document">'
		_cMens1 += '</head>'
		_cMens1 += '<body bgcolor="#C0C0C0">'
		_cMens1 += '<center>'
		_cMens1 += '<table border="0" width="982" cellspacing="0" cellpadding="0">'
		_cMens1 += '<tr height="80">'
		_cMens1 += '<td width="100%" height="80" background="http://www.adoro.com.br/microsiga/pedido_bloq.jpg">&nbsp;</td>'
		_cMens1 += '</tr>'
		_cMens1 += '</center>'
		_cMens1 += '<tr>'
		_cMens1 += '<td width="100%" bgcolor="#386079">'
		_cMens1 += '<div align="left">'
		_cMens1 += '<table border="1" width="100%">'
		_cMens1 += '<tr>'
		_cMens1 += '<td width="982" bordercolorlight="#FAA21B" bordercolordark="#FAA21B">'
		_cMens1 += '<b><font face="Arial" color="#FFFFFF" size="4">Pedido: '+SC5->C5_NUM+'</font></b>'
		_cMens1 += '</td></tr>'
		_cMens1 += '</table>'
		_cMens1 += '</div>'
		_cMens1 += '</td>'
		_cMens1 += '</tr>' 
		_cMens1 += '<center>'
		_cMens1 += '<tr>'
		_cMens1 += '<td width="100%">'
		_cMens1 += '<table border="1" width="982">'
		_cMens1 += '<tr>'
		_cMens1 += '<td width="87" bgcolor="#FAA21B"><font face="Arial" size="1">Cod.Cliente:</font></td>'
		_cMens1 += '<td width="38" bgcolor="#FFFFFF"><font face="Arial" size="1">'+SC5->C5_CLIENTE+'</font></td>'
		_cMens1 += '</center>'
		_cMens1 += '<td width="25" bgcolor="#FAA21B">'
		_cMens1 += '<p align="right"><font face="Arial" size="1">Loja:</font></td>'
		_cMens1 += '<center>'
		_cMens1 += '<td width="17" bgcolor="#FFFFFF">'
		_cMens1 += '<p align="center"><font face="Arial" size="1">'+SC5->C5_LOJACLI+'</font></td>'
		_cMens1 += '</center>'
		_cMens1 += '<td width="36" bgcolor="#FAA21B">'
		_cMens1 += '<p align="right"><font face="Arial" size="1">Nome:</font></td>'
		_cMens1 += '<center>'
		_cMens1 += '<td width="751" bgcolor="#FFFFFF"><font face="Arial" size="1">'+SC5->C5_NOMECLI+'</font></td>'
		_cMens1 += '</tr>'
		_cMens1 += '</table>'
		_cMens1 += '<table border="1" width="982">'
		_cMens1 += '<tr>'
		_cMens1 += '<td width="8%" bgcolor="#FAA21B"><font face="Arial" size="1">Endereço:</font></td>'
		_cMens1 += '<td width="41%" bgcolor="#FFFFFF"><font face="Arial" size="1">'+SC5->C5_ENDERE+'</font></td>'
		_cMens1 += '<td width="4%" bgcolor="#FAA21B"><font face="Arial" size="1">Bairro:</font></td>'
		_cMens1 += '<td width="17%" bgcolor="#FFFFFF"><font face="Arial" size="1">'+SC5->C5_BAIRRO+'</font></td>'
		_cMens1 += '<td width="5%" bgcolor="#FAA21B"><font face="Arial" size="1">Cidade:</font></td>'
		_cMens1 += '<td width="40%" bgcolor="#FFFFFF"><font face="Arial" size="1">'+SC5->C5_CIDADE+'</font></td>'
		_cMens1 += '</tr>'
		_cMens1 += '</table>'
		_cMens1 += '</tr>'
		_cMens1 += '</table>'
		_cMens1 += '<center><table border="1" width="982">'
		_cMens1 += '<tr>'
		_cMens1 += '<td width="6%" bgcolor="#FAA21B" align="center"><font face="Arial" size="1">Roteiro:</font></td>'
		_cMens1 += '<td width="44%" bgcolor="#FFFFFF"><font face="Arial" size="1">'+SC5->C5_ROTEIRO+'</font></td>'
		_cMens1 += '<td width="7%" bgcolor="#FAA21B" align="center"><font face="Arial" size="1">Sequência:</font></td>'
		_cMens1 += '<td width="43%" bgcolor="#FFFFFF"><font face="Arial" size="1">'+SC5->C5_SEQUENC+'</font></td>'
		_cMens1 += '</tr>'
		_cMens1 += '</table>'
		_cMens1 += '<table border="1" width="982">'
		_cMens1 += '<tr>'
		_cMens1 += '<td width="170" bgcolor="#FAA21B"><font face="Arial" size="1">Condição de Pagamento:</font></td>'
		_cMens1 += '<td width="81" bgcolor="#FFFFFF"><font face="Arial" size="1">'+SC5->C5_CONDPAG+'</font></td>'
		_cMens1 += '<td width="84" bgcolor="#FAA21B"><font face="Arial" size="1">Vencimento:</font></td>'
		_cMens1 += '<td width="168" bgcolor="#FFFFFF"><font face="Arial" size="1">'+DTOC(SC5->C5_DATA1)+'</font></td>'
		_cMens1 += '<td width="46" bgcolor="#FAA21B" align="center"><font face="Arial" size="1">Emissão:</font></td>'
		_cMens1 += '<td width="393" bgcolor="#FFFFFF"><font face="Arial" size="1">'+DTOC(SC5->C5_DTENTR)+'</font></td>'
		_cMens1 += '</tr>'
		_cMens1 += '</table>'
		_cMens1 += '<table border="1" width="982">'
		_cMens1 += '<tr>'
		_cMens1 += '<td width="7%" bgcolor="#FAA21B">'
		_cMens1 += '<p align="center"><font size="1" face="Arial">Vendedor:</font></p>'
		_cMens1 += '</td>'
		_cMens1 += '<td width="12%" bgcolor="#FFFFFF">'
		_cMens1 += '<p align="center"><font face="Arial" size="1">'+SC5->C5_VEND1+'</font></p>'
		_cMens1 += '</td>'
		_cMens1 += '<td width="15%" bgcolor="#FAA21B" align="center"><font face="Arial" size="1">Carteira:</font></td>'
		_cMens1 += '</center>'
		_cMens1 += '<td width="66%" bgcolor="#FFFFFF">'
		DBSelectArea("SA3")
		DBSetOrder(1)
		DBSeek(XFilial("SA3")+SC5->C5_VEND1)
		_cMens1 += '<p align="left"><font face="Arial" size="1">'+UPPER(ALLTRIM(SA3->A3_NOME))+'</font></p>'
		_cMens1 += '</td></tr></table><center>'
		_cMens1 += '<table border="1" width="982">'
		_cMens1 += '<tr>'
		_cMens1 += '<td width="982%" bgcolor="#FAA21B">'
		_cMens1 += '<p align="center"><font face="Arial" size="1">Motivo</font></td>'
		_cMens1 += '</tr><tr>'
		_cMens1 += '<td width="982" bgcolor="#FFFFFF">'
		_cMens1 += '<p align="center"><b><font color="#FF0000" face="Verdana" size="3">'+cMotivo+'</font></b></p>'
		_cMens1 += '</tr>'
		_cMens1 += '</table></center>'
		_cMens1 += '<table border="1" cellpadding="0" cellspacing="2" width="982">'
		_cMens1 += '<tr>'
		_cMens1 += '<td align="center" bgcolor="#FAA21B" width="1468" colspan="9">'
		_cMens1 += '<p align="center"><font face="Arial" size="1">Itens do Pedido</font></td>'
		_cMens1 += '</tr></center>'
		_cMens1 += '<tr>'
		_cMens1 += '<td width="14" bgcolor="#386079" align="center"><p align="center"><font face="Arial" size="1"  color="#FFFFFF"><b>Item</b></font></td>'
		_cMens1 += '<td width="50" bgcolor="#386079" align="center"><p align="center"><font face="Arial" size="1"  color="#FFFFFF"><b>Produto</b></font></td>'
		_cMens1 += '<td width="544" bgcolor="#386079" align="center"><p align="center"><font face="Arial" size="1" color="#FFFFFF"><b>Descrição</b></font></td>'
		_cMens1 += '<td width="57" bgcolor="#386079" align="center"><p align="center"><font size="1" face="Arial"  color="#FFFFFF"><b>TES</b></font></p></td>'
		_cMens1 += '<td width="283" bgcolor="#386079" align="center"><p align="center"><font size="1" face="Arial" color="#FFFFFF"><b>Operação</b></font></p></td>'
		_cMens1 += '<td width="42" bgcolor="#386079" align="center"><p align="center"><font face="Arial" size="1"  color="#FFFFFF"><b>UM</b></font></td>'
		_cMens1 += '<td width="91" bgcolor="#386079" align="center"><p align="center"><font face="Arial" size="1"  color="#FFFFFF"><b>Quantidade</b></font></td>'
		_cMens1 += '<td width="244" bgcolor="#386079" align="center"><p align="center"><font size="1" face="Arial" color="#FFFFFF"><b>Valor Unitário</b></font></td>'
		_cMens1 += '<td width="263" bgcolor="#386079" align="center"><p align="center"><font size="1" face="Arial" color="#FFFFFF"><b>Valor</b></font></td>'
		_cMens1 += '</tr>'

		/*
		DBSelectArea("SC6")
		DBSetOrder(1)
		DbSeek(XFilial("SC6")+SC5->C5_NUM)
		WHILE SC6->C6_NUM == SC5->C5_NUM
		_cMens2 += '<tr>'
		_cMens2 += '<td width="14" bgcolor="#FFFFFF"><font face="Arial" size="1">'+SC6->C6_ITEM+'</font></td>'
		_cMens2 += '<td width="50" bgcolor="#FFFFFF"><p align="center"><font face="Arial" size="1">'+SC6->C6_PRODUTO+'</font></td>'
		_cMens2 += '<td width="544" bgcolor="#FFFFFF"><p align="center"><font face="Arial" size="1">'+SC6->C6_DESCRI+'</font></td>'
		_cMens2 += '<td width="57" bgcolor="#FFFFFF"><p align="center"><font face="Arial" size="1">'+SC6->C6_TES+'</font></p></td>'
		_cMens2 += '<td width="283" bgcolor="#FFFFFF"><font face="Arial" size="1">'+Posicione("SF4",1,XFilial("SF4")+SC6->C6_TES,"F4_TEXTO")+'</font></td>'
		_cMens2 += '<td width="42" bgcolor="#FFFFFF"><p align="center"><font face="Arial" size="1">'+SC6->C6_UM+'</font></p></td>'
		_cMens2 += '<td width="91" bgcolor="#FFFFFF"><p align="center"><font face="Arial" size="1">'+TRANSFORM(SC6->C6_QTDVEN,"@!")+'</font></p></td>'
		_cMens2 += '<td width="244" bgcolor="#FFFFFF"><p align="right"><font face="Arial" size="1">'+TRANSFORM(SC6->C6_PRCVEN,"@E 999,999,999.99")+'</font></p></td>'
		_cMens2 += '<td width="263" bgcolor="#FFFFFF"><p align="right"><font face="Arial" size="1">'+TRANSFORM(SC6->C6_VALOR,"@E 999,999,999.99")+'</font></p></td>'
		_cMens2 += '</tr>'
		_nTotSC6 += SC6->C6_VALOR
		DBSKIP()
		END
		*/
		If Len(aCols) > 0 .And. ! IsInCallStack('RESTEXECUTE') .And. ! IsInCallStack('U_RESTEXECUTE')

			nItem 	:= ASCAN( AHEADER, { |X| ALLTRIM(X[2]) == "C6_ITEM" } )
			nProduto := ASCAN( AHEADER, { |X| ALLTRIM(X[2]) == "C6_PRODUTO" } )
			nDescri 	:= ASCAN( AHEADER, { |X| ALLTRIM(X[2]) == "C6_DESCRI" } )
			nTes 		:= ASCAN( AHEADER, { |X| ALLTRIM(X[2]) == "C6_TES" } )
			nUM 		:= ASCAN( AHEADER, { |X| ALLTRIM(X[2]) == "C6_UM" } )
			nQTDVEN 	:= ASCAN( AHEADER, { |X| ALLTRIM(X[2]) == "C6_QTDVEN" } )
			nPRCVEN 	:= ASCAN( AHEADER, { |X| ALLTRIM(X[2]) == "C6_PRCVEN" } )
			nVALOR 	:= ASCAN( AHEADER, { |X| ALLTRIM(X[2]) == "C6_VALOR" } )

			For n1 := 1 to Len(aCols)
				_cMens2 += '<tr>'
				_cMens2 += '<td width="14" bgcolor="#FFFFFF"><font face="Arial" size="1">'+aCols[n1,nITEM]+'</font></td>'
				_cMens2 += '<td width="50" bgcolor="#FFFFFF"><p align="center"><font face="Arial" size="1">'+aCols[n1,nPRODUTO]+'</font></td>'
				_cMens2 += '<td width="544" bgcolor="#FFFFFF"><p align="center"><font face="Arial" size="1">'+aCols[n1,nDESCRI]+'</font></td>'
				_cMens2 += '<td width="57" bgcolor="#FFFFFF"><p align="center"><font face="Arial" size="1">'+aCols[n1,nTES]+'</font></p></td>'
				_cMens2 += '<td width="283" bgcolor="#FFFFFF"><font face="Arial" size="1">'+Posicione("SF4",1,XFilial("SF4")+aCols[n1,nTES],"F4_TEXTO")+'</font></td>'
				_cMens2 += '<td width="42" bgcolor="#FFFFFF"><p align="center"><font face="Arial" size="1">'+aCols[n1,nUM]+'</font></p></td>'
				_cMens2 += '<td width="91" bgcolor="#FFFFFF"><p align="center"><font face="Arial" size="1">'+TRANSFORM(aCols[n1,nQTDVEN],"@!")+'</font></p></td>'
				_cMens2 += '<td width="244" bgcolor="#FFFFFF"><p align="right"><font face="Arial" size="1">'+TRANSFORM(aCols[n1,nPRCVEN],"@E 999,999,999.99")+'</font></p></td>'
				_cMens2 += '<td width="263" bgcolor="#FFFFFF"><p align="right"><font face="Arial" size="1">'+TRANSFORM(aCols[n1,nVALOR],"@E 999,999,999.99")+'</font></p></td>'
				_cMens2 += '</tr>'
				_nTotSC6 += aCols[n1,nVALOR]
			Next n1 
		Endif

		_cMens3 := '<tr>'
		_cMens3 += '<td width="1325" bgcolor="#386079" colspan="8">'
		_cMens3	+= '<p align="right"><font face="Arial" size="1" color="#FFFFFF"><b>TOTAL DO PEDIDO</b></font></td>'
		_cMens3	+= '<td width="263" bgcolor="#FFFFFF"><font face="Arial" size="1">'+TRANSFORM(_nTotSC6,"@E 999,999,999.99")+'</font></td>'
		_cMens3	+= '</tr>'
		_cMens3	+= '</table>'
		_cMens3	+= '</td>'
		_cMens3	+= '</tr>'
		_cMens3	+= '<center>'
		_cMens3	+= '<tr>'
		_cMens3	+= '<td width="100%" bgcolor="#386079" bordercolorlight="#FAA21B" bordercolordark="#FAA21B">'
		_cMens3	+= '<p align="center">'
		_cMens3	+= '<font face="Arial" size="1" color="#FFFFFF"><b>Email Enviado Automaticamente pelo Sistema Protheus by Adoro Informática</b></font>'
		_cMens3	+= '</p>'
		_cMens3	+= '</td>'
		_cMens3	+= '</tr>'
		_cMens3	+= '</table>'
		_cMens3	+= '</center>'
		_cMens3	+= '</body>'
		_cMens3	+= '</html>'
		DBSelectAreA("SZD")
		RecLock("SZD",.t.)
		ZD_FILIAL := SC5->C5_FILIAL
		ZD_CODCLI := SC5->C5_CLIENTE
		ZD_NOMECLI := SC5->C5_NOMECLI
		ZD_AUTNOME := UPPER(SUBSTR(CUSUARIO,7,15))
		ZD_RESPONS := "33"
		ZD_RESPNOM := "CREDITO"
		ZD_PEDIDO  := SC5->C5_NUM
		ZD_ROTEIRO := SC5->C5_ROTEIRO
		ZD_SEQUENC := SC5->C5_SEQUENC
		ZD_OBS1    := UPPER(cMotivo)
		ZD_VEND    := SC5->C5_VEND1
		ZD_LOJA    := SC5->C5_LOJACLI
		ZD_DEVTOT  := 'O'
		ZD_DTDEV   := ddatabase
		MsUnlock()
		DbSelectArea("SA3")
		DbSetOrder(1)
		DbSeek(Xfilial("SA3")+SC5->C5_VEND1)
		_eMailVend := SA3->A3_EMAIL

		DbSelectArea("SZR")
		DbSetOrder(1)
		DbSeek(Xfilial("SZR")+SA3->A3_CODSUP)
		_eMailSup := alltrim(UsrRetMail(SZR->ZR_USER))

		IF !Empty(Getmv("mv_mailtst"))
			cEmail := Alltrim(Getmv("mv_mailtst"))
		ELSE
			cEmail :=_eMailVend+';'+_eMailSup+';'+Alltrim(GetMv("mv_emails1"))+';'+Alltrim(GetMv("mv_emails2"))	// Em 23/02/2016 incluido o parâmetro MV_EMAILS2 - CHAMADO 026668 - WILLIAM COSTA
		ENDIF


		_cMens := _cMens1+_cMens2+_cMens3
		_cData := transform(MsDate(),"@!")
		_cHora := transform(Time(),"@!")  
		
		If !IsInCallStack('U_RESTEXECUTE') .And. ! IsInCallStack('RESTEXECUTE')
			lRet := U_ENVIAEMAIL(GetMv("MV_RELFROM"),cEmail,_cMens,"PEDIDO No."+SC5->C5_NUM+" ,PEDIDO EXCLUÍDO - "+_cData+" - "+_cHora,"")	//Por Adriana em 24/05/2019 substituido MV_RELACNT por MV_RELFROM		
		
			If Alltrim(cValToChar(SC5->C5_XGERSF)) == "2" .And. Alltrim(cValToChar(SC5->C5_XPEDSAL)) <> ""
				U_ADVEN050P("",.F.,.T., " AND C5_NUM IN ('" + Alltrim(cValToChar(SC5->C5_NUM)) + "') AND C5_XPEDSAL <> '' " , .F. )
		
			EndIf
			
		Else
			
			lRet := .T.
		
		EndIf
		
	Endif


	//+-----------------------------------------+
	//|Nao consegui enviar o e-mail vou exibir  |
	//|o resultado em tela                      |
	//+-----------------------------------------+                                                                                                          
	If !lRet 
		ApMsgInfo("Nao foi possível o Envio do E-mail.O E-mail será impresso em "+;
		"Tela e o registro será processado. "+;
		"Possíveis causas podem ser:  Problemas com E-mail do destinatário "+;
		"ou  no serviço interno de E-mail da empresa.","Erro de Envio")
		//+---------------------------------+
		//|Montando arquivo de Trabalho     |
		//+---------------------------------+	
		_aFile:={}
		AADD(_aFile,{"LINHA","C",1000,0})    
		_cNom := CriaTrab(_aFile)
		dbUseArea(.T.,,_cNom,"TRB",.F.,.F.)		
		DbSelectArea("TRB")

		//+----------------------------------+
		//|Montando o Texto em TRB           |
		//+----------------------------------+	

		TxtNew:=ALLTRIM(STRTRAN(_cMens,CHR(13),"ª"))+"ª"  
		TEXTO :=''
		For I:=0 to LEN(TxtNew)
			// Pego o proximo bloco
			TEXTO+=SUBSTR(TxtNew,1,1)	
			// Exclui o caracter posicionado
			TxtNew:=STUFF(TxtNew,1,1,"")	
			If 	LEN(TEXTO)>=200 	//txt=="ª" .or. _nTamLin > limite			
				TEXTO:=SUBSTR(TEXTO,1,LEN(TEXTO)-1)
				RecLock("TRB",.t.)
				Replace TRB->LINHA With TEXTO 
				MsUnlock()
				TEXTO:=""							
			Endif
		Next

		//+-------------------------+
		//|Copiando para Arquivo    |
		//+-------------------------+

		DbSelectArea("TRB")    	
		//COPY to &"c:\"+_cNom+".html" SDF  
		cPath := GetSrvProfString("StartPath","")+"PED_EXC\"
		COPY to &cPath+_cNom+".html" SDF	

		DbCloseArea("TRB")

		//ShellExecute('open',"c:\"+_cNom+".html",'','',1)
		ShellExecute('open',cPath+_cNom+".html",'','',1)

	Endif


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄA¿
	//³INICIO TRATAMENTO PEDIDO TRANSPORTADOR CCSKF³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄAÙ

	//cQuery := " SELECT SD1.R_E_C_N_O_ AS REC "
	//cQuery += " FROM "+ RetSqlName("SD1") +" SD1, "+ RetSqlName("SC6") +" SC6 " 
	//cQuery += " WHERE SC6.C6_FILIAL = '" + xFilial( "SC6" ) + "' AND SC6.C6_NUM = '" + cPedido + "' AND SC6.D_E_L_E_T_ = '*' "
	//cQuery += " AND SD1.R_E_C_N_O_ = SC6.C6_XRECSD1 AND SC6.C6_XRECSD1<> 0 AND SD1.D_E_L_E_T_ = ' ' "
	// RICARDO LIMA - 16/01/18
	cQuery := " SELECT SD1.R_E_C_N_O_ AS REC " 
	cQuery += " FROM "+ RetSqlName("SD1") +" SD1 WITH (NOLOCK) "
	cQuery += " INNER JOIN "+ RetSqlName("SC6") +" SC6 WITH (NOLOCK) ON SD1.R_E_C_N_O_ = SC6.C6_XRECSD1 AND SC6.C6_XRECSD1<> 0 AND SC6.D_E_L_E_T_ = '*' "
	cQuery += " WHERE SC6.C6_FILIAL = '" + xFilial( "SC6" ) + "' "
	cQuery += " AND SC6.C6_NUM = '" + cPedido + "' "
	cQuery += " AND SD1.D_E_L_E_T_ = ' ' "

	If Select(cAliasSD1) > 0
		(cAliasSD1)->(dbCloseArea())
	EndIf

	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasSD1,.F.,.T.)
	dbSelectArea(cAliasSD1)

	(cAliasSD1)->(dbGoTop())

	While (cAliasSD1)->(!Eof())

		SD1->(DbSetOrder(1))
		SD1->(DbGoTo((cAliasSD1)->(REC)))
		RecLock("SD1",.F.)		        
		Replace SD1->D1_XPVDEV With ' '
		MsUnLock("SD1")
		(cAliasSD1)->(dbSkip())
	Enddo

	(cAliasSD1)->(dbCloseArea())     

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄA¿
	//³FIM TRATAMENTO PEDIDO TRANSPORTADOR - CCSKF³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄAÙ


Return(.t.)

//&&21/10/16 - funcao para pre aprovacao.
Static function fPreAprv(_cFilial,cPedido,_cCliente,_cLoja) 
	DbSelectArea("SC5")
	_cASC5 := Alias()
	_cOSC5 := IndexOrd()
	_cRSC5 := Recno()

	//&&Verifico se eh rede ou varejo...
	dbSelectArea("SA1")
	dbSetOrder(1)
	dbGoTop()
	If dbSeek(xFilial("SA1")+_cCliente+_cLoja)
		dbSelectArea("SZF")
		dbSetOrder(1)
		dbGoTop()
		If dbSeek(xFilial("SZF")+SUBSTR(SA1->A1_CGC,1,8))  //&&REDE
			//Limpo flag de pedidos relativos a Rede....aonde no caso não ha como filtrar data de entrega, cliente e pedidos utilizados...limpo todos.

			If Select("LSC5") > 0
				DbSelectArea("LSC5")
				DbCloseArea("LSC5")
			Endif

			/*_cQuery := "SELECT C5.C5_FILIAL, C5.C5_NUM FROM "+RetSqlName("SC5")+" C5, "+RetSqlName("SZF")+" ZF, "+RetSqlName("SA1")+" A1 "
			_cQuery += " WHERE  C5_NOTA = ''  AND C5_CLIENTE NOT IN ('031017','030545') "
			_cQuery += " AND C5.C5_CLIENTE = A1.A1_COD AND C5.C5_LOJACLI = A1.A1_LOJA"
			_cQuery += " AND ZF_CGCMAT = '"+SZF->ZF_CGCMAT+"' AND LEFT(A1_CGC,8) = ZF_CGCMAT "      
			_cQuery += " AND C5.D_E_L_E_T_='' AND ZF.D_E_L_E_T_='' AND A1.D_E_L_E_T_='' " */

			_cQuery := "SELECT C5.C5_FILIAL, C5.C5_NUM " 
			_cQuery += "FROM "+RetSqlName("SC5")+" C5 "
			_cQuery += "INNER JOIN "+RetSqlName("SA1")+" A1 ON A1.A1_COD=C5.C5_CLIENTE AND A1.A1_LOJA=C5.C5_LOJACLI AND A1.D_E_L_E_T_= ' ' "
			_cQuery += "INNER JOIN "+RetSqlName("SZF")+" ZF ON LEFT(A1_CGC,8) = ZF_CGCMAT AND ZF.D_E_L_E_T_ = ' ' "
			_cQuery += "WHERE C5_CLIENTE NOT IN ('031017','030545') AND C5_NOTA = ' ' AND C5.D_E_L_E_T_ = ' ' "  
			_cQuery += "AND ZF_CGCMAT = '"+SZF->ZF_CGCMAT+"' "

			TCQUERY _cQuery new alias "LSC5"	

			DbSelectArea ("LSC5")
			LSC5->(dbgotop())
			Do While LSC5->(!EOF())
				DbSelectArea("SC5")
				DbSetOrder(1)
				If dbseek(LSC5->C5_FILIAL+LSC5->C5_NUM)
					if Reclock("SC5",.F.)
						SC5->C5_XPREAPR := " "
						SC5->(Msunlock())
					endif
				Endif	         
				LSC5->(DbSkip())
			Enddo

			DbcloseArea("LSC5")

		Else  //&&eh varejo
			if Reclock("SC5",.F.)
				SC5->C5_XPREAPR := " "
				SC5->(Msunlock())
			endif   
		Endif
	Endif

	dbSelectArea(_cASC5)
	dbSetOrder(_cOSC5)
	dbGoto(_cRSC5)
Return()

Static function AltPedOr(_cPedAnt,_cNumPed)
	DbSelectArea("SC5")
	_SC5cAlias := Alias()
	_SC5cOrder := IndexOrd()
	_SC5cRecno := Recno()
	_cPeds := ""

	if dbseek(xFilial("SC5")+_cPedAnt)
		_cPedold := SC5->C5_XPEDGER
		If _cNumPed $ _cPedold
			_nPSUBS   := AT(_cNumPed,_cPedold)
			IF _nPSUBS == 1
				_cPedNew  := Substr(_cPedold,_nPSUBS + 7,Len(_cPedold))
			else   
				_cPedNew  := Substr(_cPedold,1,_nPSUBS - 2)+Substr(_cPedold,_nPSUBS + 6,Len(_cPedold))
			endif
			RecLock("SC5",.F.)
			SC5->C5_XPEDGER := _cPedNew  //&&somente limpo, nao gravo atual. Gravacao eh por outro ponto de entrada
			SC5->(MsUnlock())
		Endif
	endif

	dbSelectArea(_SC5cAlias)
	dbSetOrder(_SC5cOrder)
	dbGoto(_SC5cRecno)

Return()
