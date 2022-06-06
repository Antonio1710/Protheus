#include "rwmake.ch"
#include "font.ch"
#include "topconn.ch"

/*/{Protheus.doc} User Function ALTDTENT
	Tela customizada do pedido de venda para alterar somente a Data de entrega(solicitada 
	por Vagner durante validação tabela de preço
	@type  Function
	@author Mauricio da Silva
	@since 14/06/11
	@history Ticket 8     	- Abel Babini - 05/02/2020 - Log de execução da rotina na tabela ZBE e manter o status de pré aprovação do pedido.
	@history ticket  8    	- Abel Babini - 19/02/2021 - Não limpar flag de pré liberação quando altera data de entrega
	@history Ticket  8    	- Abel B.     - 01/03/2021 - Nova rotina de Pré-liberação de crédito levando-se em consideração a ordem DATA DE ENTREGA + NUMERO DO PEDIDO
	@history Ticket  8    	- Abel B.     - 03/03/2021 - Nova versão - Nova rotina de Pré-liberação de crédito levando-se em consideração a ordem DATA DE ENTREGA + NUMERO DO PEDIDO
	@history Ticket 018465  - Everson     - 24/03/2022 - Tratamento para pedidos com pesagem já iniciada.
	@history Ticket 70142 - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
	@history Ticket 018465  - Everson     - 30/05/2022 - Correção da chamada da função.

	/*/
User Function ALTDTENT() 

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'tela customizada do pedido de venda para alterar somente a Data de entrega(solicitada por Vagner durante validação tabela de preço')

	aCores := {{"Empty(C5_LIBEROK).And.Empty(C5_NOTA) .And. Empty(C5_BLQ)",'ENABLE' },;		//Pedido em Aberto
	{ "!Empty(C5_NOTA).Or.C5_LIBEROK=='E' .And. Empty(C5_BLQ)" ,'DISABLE'},;		   	//Pedido Encerrado
	{ "!Empty(C5_LIBEROK).And.Empty(C5_NOTA).And. Empty(C5_BLQ)",'BR_AMARELO'},;
	{ "C5_BLQ == '1'",'BR_AZUL'},;	//Pedido Bloquedo por regra
	{ "C5_BLQ == '2'",'BR_LARANJA'}}	//Pedido Bloquedo por verba

	aRotina := { { OemToAnsi("Pesquisa")  ,"AXPESQUI"    ,0,1},;  // bUscar
	{ OemToAnsi("Visualiza") ,"A410Visual"	 ,0,2,0 ,NIL},;		//"Visual"
	{ OemToAnsi("legenda")   ,"A410Legend"	 ,0,3,0 ,.F.},;		//"Legenda"
	{ OemToAnsi("Alterar")   ,"U_ALTPVFAT()",0,4} }  // alteracao customizada

	cCadastro := "Alteracao Data de entrega de Pedidos pelo Comercial"

	DbSelectArea("SC5")
	dbSetOrder(1)
	dbGotop()

	mBrowse( 6, 1,22,75,"SC5",,,,,,aCores) 

Return()

User function ALTPVFAT()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	// Local aArray  	 := {}
	// Local aOrdProd   := {}
	Local aChave     := {}
	Local cRegLog    := ""  
	// Local cIndex1, cChave, cFiltro, nIndex
	Local nLinGetD, cTitulo, aC, aR, aCGD, cLinhaOK, cTudoOk, nOpcx, aAlter, lRetMod2, _ni
	// Local nPosPed, nPosIt, nPosEnt, nPosPri, nPosCor, nPosPig, nX

	Private aHeader, aCols
	Private Altera := .f.
	Private _cCampo := ""
	Private _nTot := 0 
	Private _ni := 1

	U_ADINF009P('ALTDTENT' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'tela customizada do pedido de venda para alterar somente a Data de entrega(solicitada por Vagner durante validação tabela de preço')

	//INICIO Ticket 8     - Abel Babini - 05/02/2020 - Log de execução da rotina na tabela ZBE e manter o status de pré aprovação do pedido.
	//Gera log na tabela ZBE.
	DbSelectArea("ZBE")
	RecLock("ZBE",.T.)
	Replace ZBE_FILIAL 	   	WITH xFilial("ZBE")
	Replace ZBE_DATA 	   		WITH dDataBase
	Replace ZBE_HORA 	   		WITH Time()
	Replace ZBE_USUARI	    WITH __cUserID
	Replace ZBE_LOG	        WITH "Altera Dt Entrega SC5 pedido " + cValToChar(SC5->C5_NUM) 
	Replace ZBE_MODULO	    WITH "COMERCIAL"
	Replace ZBE_ROTINA	    WITH "ALTDTENT" 
	Replace ZBE_PARAME      WITH "Pedido " + cValToChar(SC5->C5_NUM) + " Recno " + cValToChar(SC5->( Recno() ))+ " Status " + cValToChar(SC5->C5_XPREAPR) 
	ZBE->( MsUnLock())
	//FIM Ticket 8     - Abel Babini - 05/02/2020 - Log de execução da rotina na tabela ZBE e manter o status de pré aprovação do pedido.

	dbSelectArea("SA1")           //Valido apenas para que o supervisor/gerente/diretor possa alterar a data de entrega
	dbSetOrder(1)		
	If SA1->(dbSeek(xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI))

		_cRepresent := SA1->A1_VEND
		_cSuperv    := Posicione("SA3",1,xFilial("SA3")+_cRepresent,"A3_SUPER")        // supervisor para aprovação
		_cSupervi   := Posicione("SA3",1,xFilial("SA3")+_cSuperv,"A3_CODUSR")
		_cGerent    := Posicione("SA3",1,xFilial("SA3")+_cRepresent,"A3_GEREN")        // gerente para aprovação
		_cGerente   := Posicione("SA3",1,xFilial("SA3")+_cGerent,"A3_CODUSR")
		_cDireto    := Posicione("SA3",1,xFilial("SA3")+_cRepresent,"A3_XDIRET")       // diretor para aprovação
		_cDiretor   := Posicione("SA3",1,xFilial("SA3")+_cDireto,"A3_CODUSR")

		_cPodeAlt := _cSupervi+"/"+_cGerente+"/"+_cDiretor

		if !(__cUserID $ _cPodeAlt)
			MsgInfo("Usuario sem permissao para utilizar a rotina. Não é supervisor/gerente/diretor do vendedor no pedido.","Atenção")
			Return()
		Endif

	endif   

	//Everson - 05/04/2018. Chamado 037261. SalesForce.
	If Alltrim(cValToChar(SC5->C5_XGERSF)) == "2"
		MsgStop("Pedido gerado pela integração Protheus x SalesForce, não poderá ser alterado.","Função ALTDTENT")
		Return Nil

	EndIf  

	//Everson - 24/03/2022. Chamado 018465. Pesagem.
	If ! U_ADFAT41A(SC5->C5_NUM) //Everson - 30/05/2022. Chamado TI.  
		Return Nil
	EndIf  

	if !(Empty(SC5->C5_LIBEROK)).And.!(Empty(SC5->C5_NOTA)) .And. Empty(SC5->C5_BLQ) //somente pedidos em aberto   
		msginfo("Pedido nao se encontra em aberto para alteração","Atenção")
		return()
	ElseIf  SC5->C5_XREDE == 'S' .And. !Empty(SC5->C5_CODRED)     //se rede
		If      SC5->C5_LIBEROK == "E" .AND. !Empty(SC5->C5_XLIBERA) .AND. SC5->C5_BLQ = " "
			ApMsgInfo(OemToAnsi("Pedido já sofreu avaliação e foi rejeitado.Nao podendo ser mais utilizado"),OemToAnsi(" A T E N Ç Ã O "))
			Return()								
		EndIf	
	ElseIf SC5->C5_XREDE == 'N' .AND. SC5->C5_BLQ == " "       //se loja
		If      SC5->C5_LIBEROK == "E"
			ApMsgInfo(OemToAnsi("Pedido já sofreu avaliação e foi rejeitado.Nao podendo ser mais utilizado"),OemToAnsi(" A T E N Ç Ã O "))
			Return()
		Endif
	Endif       
	if !Empty(SC5->C5_PLACA) .AND. Empty(SC5->C5_NOTA)   //Mauricio 08/02/2012 - valida se ja houve roteirizacao.

		ApMsgInfo(OemToAnsi("Este pedido nao pode ser alterado pois já foi roterizado." + Chr(13) + ;
		"Roteiro: " + AllTrim(SC5->C5_ROTEIRO) + " - Placa: " + AllTrim(SC5->C5_PLACA),;
		"Pedido roteirizado" ))
		Return()      		  
	EndIf

	if SC5->C5_DTENTR < ctod("01/04/2017") .and. SC5->C5_EST = "SP"   // alterado por Adriana em 31/03/17

		ApMsgInfo(OemToAnsi("Pedido com entrega anterior a 01/04/2017, somente por alteração do pedido"),OemToAnsi(" A T E N Ç Ã O "))

		Return()      		  
	EndIf
	
	//ticket  8    - Abel Babini - 19/02/2021 - Não limpar flag de pré liberação quando altera data de entrega
	//Comentado a rotina para manter o status de pre aprovação do pedido.
	//fPreAprv(xFilial("SC5"),SC5->C5_NUM,SC5->C5_CLIENTE,SC5->C5_LOJACLI)  //funcao pra limpeza de flag de pre aprovacao de pedidos de venda.    //27/10/16 Novo tratamento para pre aprovacao do credito
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Seleciona os registro dos itens do pedido conforme parametros³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SC6")
	dbSetOrder(1)
	if dbseek(xfilial("SC6")+SC5->C5_NUM)

		aHeader:={}
		aCols  :={}

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Montando aHeader                                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("Sx3")
		dbSetOrder(1)
		dbSeek("SC6")
		nUsado:=0
		aHeader:={}
		While !Eof() .And. (SX3->x3_arquivo == "SC6")
			IF !(Alltrim(SX3->X3_CAMPO) $ "C6_NUM,C6_QTDEMP,C6_QTDENT,C6_QTDEMP2,C6_QTDENT2")
				IF X3USO(SX3->x3_usado) .AND. cNivel >= SX3->x3_nivel
					nUsado:=nUsado+1
					AADD(aHeader,{ TRIM(SX3->x3_titulo), SX3->x3_campo, SX3->x3_picture,;
					SX3->x3_tamanho, SX3->x3_decimal,"AllwaysTrue()",;
					"û", SX3->x3_tipo, SX3->x3_arquivo, SX3->x3_context } )
				Endif
			EndIf    
			dbSkip()
		End

		dbSelectAREa("SC6")   
		While !Eof() .and. SC6->C6_NUM == SC5->C5_NUM	     	
			Aadd(aChave, Recno())
			AADD(aCols,Array(nUsado+1))
			For _ni:=1 to nUsado
				aCols[Len(aCols),_ni]:=FieldGet(FieldPos(aHeader[_ni,2]))
			Next
			aCols[Len(aCols),nUsado+1]:=.F.
			dbSkip()

		End

		If Len(aCols) == 0
			aCols:={Array(nUsado+1)}
			aCols[1,nUsado+1]:=.F.
			For _ni:=1 to nUsado
				aCols[1,_ni]:=CriaVar(aHeader[_ni,2])
			Next
		Endif

		nLinGetD := 0
		cTitulo  := "Alteracao da Data de Entrega pelo Comercial"

		aC:={}   

		_cNum       := SC5->C5_NUM
		_cCliente   := SC5->C5_CLIENTE
		_cLojCli    := SC5->C5_LOJACLI
		_cTipo      := SC5->C5_TIPO
		_cLojEnt    := SC5->C5_LOJAENT
		_cComplST   := " "
		_cCNome     := Posicione("SA1",1,xfilial("SA1")+_cCLiente+_cLojCli,"A1_NOME")
		_dDTENTR    := SC5->C5_DTENTR
		_dDTEOLD    := SC5->C5_DTENTR //apenas para efeito de log


		Aadd(aC,{"_cNum"     ,{15,010}  ,"Numero     " ,"@!"     ,"" ,"",.F.})
		Aadd(aC,{"_cCliente" ,{15,200}  ,"Cliente    " ,"@!"     ,"" ,"",.F.})
		Aadd(aC,{"_cCNome"   ,{15,280}  ,"Nome       " ,"@!"     ,"","",.F.})
		Aadd(aC,{"_dDTENTR"  ,{45,010}  ,"Data Entrega" ,"@!"     ,"U_vlddata()","",.T.})  //unico campo que pode ser alterado.

		aR:={}  
		aCGD   :={170,5,128,315}  
		cLinhaOk:="ExecBlock('md2linok',.f.,.f.)"
		cTudoOk :="ExecBlock('md2tudok',.f.,.f.)"   
		nOpcx   :=6
		aAlter  :={}    //{"C6_ENTREG"}
		lRetMod2:=Modelo2(cTitulo,aC,aR,aCGD,nOpcx,,,aAlter)

		If lRetMod2 
			RecLock("SC5",.F.)
			SC5->C5_DTENTR := _dDTENTR
			MsUnlock()

			nPosPed   :=	Ascan(aHeader,{|x| Trim(x[2]) == "C6_NUM"})
			nPosIt    :=	Ascan(aHeader,{|x| Trim(x[2]) == "C6_ITEM"})	  
			nPosEntr  :=	Ascan(aHeader,{|x| Trim(x[2]) == "C6_ENTREG"})

			For nX:=1 to Len(aCols)	      
				dbSelectArea("SC6")
				dbSetOrder(1)
				dbgotop()		  
				dbSeek(xFilial("SC6")+SC5->C5_NUM+aCols[nX][nPosIt])
				If Found()
					Reclock("SC6",.F.)
					SC6->C6_ENTREG  := _dDTENTR
					MsUnlock()			
				Endif	
				// ALEX BORGES - 09/01/12 - ALTERAR TAMBEM A DATA DE ENTREGA NA TABELA SC9
				dbSelectArea("SC9")
				dbSetOrder(1)
				dbgotop()		  
				If dbSeek(xFilial("SC9")+SC5->C5_NUM+aCols[nX][nPosIt])
					Reclock("SC9",.F.)
					SC9->C9_DTENTR  := _dDTENTR
					MsUnlock()			
				Endif			
			Next

			//chamada da rotina pra gravar log
			cRegLog:= "ALTERACAO DATA ENTREGA DE: "+DTOC(_dDTEOLD)+" PARA: "+DTOC(_dDTENTR)
			u_GrLogZBE (Date(),TIME(),cUserName,cRegLog,"COMERCIAL","ALTDTENT","PEDIDO: "+SC5->C5_NUM,ComputerName(),LogUserName())

			//Ticket  8      - Abel B.  - 01/03/2021 - Nova rotina de Pré-liberação de crédito levando-se em consideração a ordem DATA DE ENTREGA + NUMERO DO PEDIDO
			//Static Call(M410STTS,fLibCred, SC5->C5_CLIENTE, SC5->C5_LOJACLI, SC5->C5_DTENTR)
			//@history Ticket 70142  - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
  			u_10STTSA1( SC5->C5_CLIENTE, SC5->C5_LOJACLI, SC5->C5_DTENTR )

			//Everson - 04/03/2018. Chamada 037261.
			If !(Empty(Alltrim(cValToChar(SC5->C5_XPEDSAL)))) .And. FindFunction("U_ADVEN050P")
				U_ADVEN050P("",.F.,.F.," AND C5_NUM = '" + Alltrim(cValToChar(SC5->C5_NUM)) + "' AND C5_XPEDSAL <> '' ",.F.,.F.,.T.)

			EndIf

		Endif
		dbSelectArea("SC6")
	Endif

Return

User function vlddata()

	Local _nDiasDtE     := diasEntrega() //GetMV("MV_XDIASEN") // Everson - 03/01/2018. Chamado 037426.

	U_ADINF009P('ALTDTENT' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'tela customizada do pedido de venda para alterar somente a Data de entrega(solicitada por Vagner durante validação tabela de preço')
	
	_lret := .T.

	if _dDTENTR > (_nDiasDte+ddatabase)
		MSgInfo("Data de entrega é maior que o periodo permitido!","Atenção")
		_lRet := .F.
	Endif   

return(_lret) 

//21/10/16 - funcao para pre aprovacao.
Static function fPreAprv(_cFilial,cPedido,_cCliente,_cLoja) 
	DbSelectArea("SC5")
	_cASC5 := Alias()
	_cOSC5 := IndexOrd()
	_cRSC5 := Recno()

	//Verifico se eh rede ou varejo...
	dbSelectArea("SA1")
	dbSetOrder(1)
	dbGoTop()
	If dbSeek(xFilial("SA1")+_cCliente+_cLoja)
		dbSelectArea("SZF")
		dbSetOrder(1)
		dbGoTop()
		If dbSeek(xFilial("SZF")+SUBSTR(SA1->A1_CGC,1,8))  //REDE
			//Limpo flag de pedidos relativos a Rede....aonde no caso não ha como filtrar data de entrega, cliente e pedidos utilizados...limpo todos.

			If Select("LSC5") > 0
				DbSelectArea("LSC5")
				DbCloseArea("LSC5")
			Endif

			_cQuery := "SELECT C5.C5_FILIAL, C5.C5_NUM FROM "+RetSqlName("SC5")+" C5, "+RetSqlName("SZF")+" ZF, "+RetSqlName("SA1")+" A1 "
			_cQuery += " WHERE  C5_NOTA = ''  AND C5_CLIENTE NOT IN ('031017','030545') "
			_cQuery += " AND C5.C5_CLIENTE = A1.A1_COD AND C5.C5_LOJACLI = A1.A1_LOJA"
			_cQuery += " AND ZF_CGCMAT = '"+SZF->ZF_CGCMAT+"' AND LEFT(A1_CGC,8) = ZF_CGCMAT "      
			_cQuery += " AND C5.D_E_L_E_T_='' AND ZF.D_E_L_E_T_='' AND A1.D_E_L_E_T_='' "

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

		Else  //eh varejo
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
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³diasEntrega    ºAutor  ³Everson      º Data ³  19/12/2017   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Função para retornar o dias de entrega.                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Chamado 037426.                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function diasEntrega() // U_diasEntrega()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	Local aArea	:= GetArea()
	Local nDias := 0
	Local nDSem := DoW(dDataBase)
	Local nDiasP:= GetMV("MV_XDIASEN")
	Local cDias := Alltrim(cValToChar(GetMv("MV_#DIASEN",,"")))
	Local aDias := {}

	//
	If Empty(cDias)
		RestArea(aArea)
		nDias := nDiasP
		Return nDias

	EndIf

	//
	aDias := StrToKarr(cDias,"/")
	nDias := Val(cValToChar(aDias[nDSem]))

	//
	RestArea(aArea)

Return nDias
