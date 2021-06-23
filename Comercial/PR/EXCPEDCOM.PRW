#include "rwmake.ch"
#INCLUDE "PROTHEUS.CH"
#include "font.ch"

/*/{Protheus.doc} User Function EXCPEDCOM
	Rotina/tela para exclusao de Pedidos de venda (somente) que se utilizarao da rotina de tabela de preco customizada.
	@type  Function
	@author Mauricio-MDS TEC 
	@since 14/06/2011
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
    @history chamado 050729 - FWNM - 13/07/2020 - || OS 052035 || TECNOLOGIA || LUIZ || 8451 || REDUCAO DE BASE - Bloqueado pois Não está sendo utilizado, pois ao executar deu error ao tentar consultar parâmetro que não existe MV_EXCPED
/*/
User Function EXCPEDCOM() 

	Local _cUsers := GETMV("MV_EXCPED",,"")

	//  Bloqueado pois Não está sendo utilizado, pois ao executar deu error ao tentar consultar parâmetro que não existe MV_EXCPED
	msgAlert("Rotina desativada e obsoleta! Utilizar EXPPROJ ou ADEST031R...") // chamado 050729 - FWNM - 13/07/2020 - || OS 052035 || TECNOLOGIA || LUIZ || 8451 || REDUCAO DE BASE - Bloqueado pois Não está sendo utilizado, pois ao executar deu error ao tentar consultar parâmetro que não existe MV_EXCPED

Return

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Rotina desenvolvida para classificacao e definição de periodos e valores para relatorio 50 maiores por Rentabilidade')

	if !(__cUserID $ _cUsers)
		MsgInfo("Usuario sem permissao para utilizar a rotina.","Atenção")
		Return()
	Endif
	
	aCores := {{"Empty(C5_LIBEROK).And.Empty(C5_NOTA) .And. Empty(C5_BLQ)",'ENABLE' },;		//Pedido em Aberto
				{ "!Empty(C5_NOTA).Or.C5_LIBEROK=='E' .And. Empty(C5_BLQ)" ,'DISABLE'},;		   	//Pedido Encerrado
				{ "!Empty(C5_LIBEROK).And.Empty(C5_NOTA).And. Empty(C5_BLQ)",'BR_AMARELO'},;
				{ "C5_BLQ == '1'",'BR_AZUL'},;	//Pedido Bloquedo por regra
				{ "C5_BLQ == '2'",'BR_LARANJA'}}	//Pedido Bloquedo por verba
				
	aRotina := { { OemToAnsi("Pesquisa")  ,"AXPESQUI"    ,0,1},;  // bUscar
				{ OemToAnsi("Visualiza") ,"A410Visual"	 ,0,2,0 ,NIL},;		//"Visual"
				{ OemToAnsi("legenda")   ,"A410Legend"	 ,0,3,0 ,.F.},;		//"Legenda"
				{ OemToAnsi("Excluir")   ,"U_EXCPDCM()",0,4} }  // alteracao customizada

	cCadastro := "Exclusão de pedidos de Venda - Tabela de Preço"

	DbSelectArea("SC5")
	dbSetOrder(1)
	dbGotop()

	mBrowse( 6, 1,22,75,"SC5",,,,,,aCores) 

	Return()

	User function EXCPDCM()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aArray  	 := {}
	Local aOrdProd   := {}
	Local aChave     := {}

	Local cIndex1, cChave, cFiltro, nIndex
	Local nLinGetD, cTitulo, aC, aR, aCGD, cLinhaOK, cTudoOk, nOpcx, aAlter, lRetMod2
	Local nPosPed, nPosIt, nPosEnt, nPosPri, nPosCor, nPosPig, nX

	Private aHeader, aCols
	Private Altera := .f.
	Private _cCampo := ""
	Private _nTot := 0 

	U_ADINF009P('EXCPEDCOM' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Rotina desenvolvida para classificacao e definição de periodos e valores para relatorio 50 maiores por Rentabilidade')

	If !MsgYesNo(OemToAnsi("Confirma a exclusao do pedido "+SC5->C5_NUM),"Atenção")
		Return()
	EndIf


	If !Empty(SC5->C5_PLACA) .AND. Empty(SC5->C5_NOTA)
			ApMsgInfo(OemToAnsi("Este pedido nao pode ser alterado pois já foi roterizado." + Chr(13) + ;
								"Roteiro: " + AllTrim(SC5->C5_ROTEIRO) + " - Placa: " + AllTrim(SC5->C5_PLACA),;
								"Bloqueado por Roteiro" ))
			Return()
	EndIf

	If !Empty(SC5->C5_NOTA)
			ApMsgInfo(OemToAnsi("Este pedido nao pode ser alterado pois já foi faturado." + Chr(13) + ;
								"NF: " + AllTrim(SC5->C5_ROTEIRO) + " - Placa: " + AllTrim(SC5->C5_PLACA)+""))		                    
			Return()
	EndIf

	mandaemail()

	dbSelectArea("SC6")   
	dbSetOrder(1)	
	If dbSeek(xFilial("SC6")+SC5->C5_NUM)
		While !Eof() .And. SC6->C6_NUM == SC5->C5_NUM
			Reclock("SC6",.F.)
			dbDelete()
			MsUnlock()
			SC6->(dbSkip())
		EndDo
	EndIf  
	
	dbSelectArea("SC9")   
	dbSetOrder(1)	
	If dbSeek(xFilial("SC9")+SC5->C5_NUM)
		While !Eof() .And. SC9->C9_PEDIDO == SC5->C5_NUM
			Reclock("SC9",.F.)
			dbDelete()
			MsUnlock()
			SC9->(dbSkip())
		EndDo
	EndIf

	DbSelectArea("SC5")
	RecLock("SC5",.F.)
	SC5->C5_MENNOT5 := "EXCLUIDO PELA ROTINA EXCPEDCOM (TABELA DE PRECO)"
	DbDelete()
	MsUnlock()
			
	return()

	Static Function MandaEmail()

	Local cMotivo 	:= Space(115)
	Local nOpt 		:= 0
	Local lRet		:= .f.
	Local _lMail	:= .f.
	Local _nTotSC6	:= 0
	Local _cMens	:= " "
	Local _cMens1	:= " "
	Local _cMens2	:= " "
	Local _cMens3	:= " "   

	DEFINE MSDIALOG oDlg FROM	18,1 TO 80,550 TITLE "ADORO S/A  -  Motivo da Exclusão" PIXEL  
	@  1, 3 	TO 28, 242 OF oDlg  PIXEL
	If File("adoro.bmp")
	@ 3,5 BITMAP oBmp FILE "adoro.bmp" OF oDlg NOBORDER SIZE 25,25 PIXEL 
	oBmp:lStretch:=.T.
	EndIf
	@ 05, 37	SAY "Motivo:" SIZE 24, 7 OF oDlg PIXEL 
	@ 12, 37  	MSGET cMotivo  SIZE	200, 9 OF oDlg PIXEL Valid !Empty(cMotivo)    
	DEFINE SBUTTON FROM 02,246 TYPE 1 ACTION (nOpt := 1,oDlg:End()) ENABLE OF oDlg
	DEFINE SBUTTON FROM 16,246 TYPE 2 ACTION oDlg:End() ENABLE OF oDlg

	ACTIVATE MSDIALOG oDlg CENTERED

	If nOpt == 1
		_lMail	:= .T.
		lRet 		:= .T.
	Else
		return(lRet)
	Endif

	If _lMail			
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
				_cMens1 += '<p align="center"><b><font color="#FF0000" face="Verdana" size="3">'+cMotivo+'</font></b></p>
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
					SC6->(DBSKIP())
				ENDDo
				
				/*
				If Len(aCols) > 0
					
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
				*/
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
		
				lRet := U_ENVIAEMAIL(GetMv("MV_RELFROM"),cEmail,_cMens,"PEDIDO No."+SC5->C5_NUM+" ,PEDIDO EXCLUÍDO - "+_cData+" - "+_cHora,"")	//Por Adriana em 24/05/2019 substituido MV_RELACNT por MV_RELFROM	

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

Return()