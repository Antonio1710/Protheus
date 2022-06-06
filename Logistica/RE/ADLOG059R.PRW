#Include "RwMake.ch"
#Include "Protheus.ch"
#Include "Totvs.ch"
#Include "Topconn.ch"   
/*/{Protheus.doc} User Function ADLOG059R
	Relatório para conferência de documentos fiscais de transporte emitidos.
	Alteração Everson-21/08/2019-Ch:044314. Adiconado o valor do ICMS. Ch:044314  
	@type  Function
	@author Everson
	@since 31/07/2019
	@version 01
	@history Everson, 15/06/2020, Chamado 058936. Correção do error log por falta de declaração da variável.
	@history Ticket 70142   - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
	/*/
User Function ADLOG059R() // U_ADLOG059R()

	//Variáveis.
	Local aArea	 	:= GetArea()
	Local cQuery	:= ""
	Local cEof		:= Chr(13) + Chr(10) //Everson - 15/06/2020. Chamado 058936.
	
	//
	Private cDir	:= ""
	Private nHdl	:= 0
	Private cArq  	:= "Doc_Emit"+__cUserID+"_" + DToS(Date()) + "_" + StrTran(cValToChar(Time()),":","") + ".CSV"

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Relatório para conferência de documentos fiscais de transporte emitidos')
	
	//
	cDir := cGetFile("Arquivo CSV.", "Selecione o diretório para salvar o CSV",,'C:\',.T.,GETF_RETDIRECTORY + GETF_LOCALHARD + GETF_NETWORKDRIVE)
	
	//
	If Empty(Alltrim(cValToChar(cDir)))
		RestArea(aArea)
		Return Nil

	EndIf
	
	//Cria o arquivo no disco.
	nHdl := FCreate(cDir + cArq,0)

	//Verifica se foi possível criar o arquivo.
	If nHdl == -1
		MsgAlert("O Arquivo não " + cArq + " pode ser criado:" + cEof + STR(FERROR()),"Função ADLOG059R")
		RestArea(aArea)
		Return Nil

	EndIf
	
	//
	If ! Pergunte("ADLOG057R",.T.)
		RestArea(aArea)
		RestArea(aArea)
		Return Nil

	EndIf
	
	//
	If Select("D_DOCEM") > 0
		D_DOCEM->(DbCloseArea())
		
	EndIf
	
	//
	cQuery	:= scpSql()
	
	//
	TcQuery cQuery New Alias "D_DOCEM"
	D_DOCEM->(DbGoTop())
		
		Processa( {|| processa() }, "Aguarde", "Gerando relatório",.F.)
	
	D_DOCEM->(DbCloseArea())
	
	//
	RestArea(aArea)
	
Return Nil
/*/{Protheus.doc} processa
	Gera relatório.
	@type  Static Function
	@author Everson
	@since 31/07/2019
	@version 01
	/*/
Static Function processa()

	//Variáveis.
	Local aArea	 		:= GetArea()
	Local nTotReg		:= Contar("D_DOCEM","!Eof()")
	Local cEof			:= Chr(13) + Chr(10)
	Local cLin			:= ""
	Local cMsgStatus	:= ""
	
	//
	ProcRegua(nTotReg)
	
	//
	D_DOCEM->(DbGoTop())
	
	//
	//Everson-21/08/2019-Ch:044314.
	cLin +=  "Filial;Dt Entrega;Roteiro;Transportadora;Loja;Nome;Placa;DT Emissão;Tipo Doc;Num Doc;Ser Doc;Valor;Status;Tem ICMS;Valor ICMS;Pedido Compra;Entrada;" + cEof
	FWrite(nHdl,cLin,Len(cLin))
	cLin := ""
	
	While ! D_DOCEM->(Eof())
	
		//
		IncProc() 
		
		//cMsgStatus := Static Call(ADLOG057P,tlbStatus,Alltrim(D_DOCEM->ZFK_STATUS),1)
		//@history Ticket 70142  - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
		cMsgStatus := u_LOG057A4( Alltrim(D_DOCEM->ZFK_STATUS),1 )
		
		//
		cLin += Alltrim(D_DOCEM->ZFK_FILIAL) + ";"	
		cLin += DToC(SToD(D_DOCEM->ZFK_DTENTR)) + ";"	
		cLin += Alltrim(D_DOCEM->ZFK_ROTEIR) + ";"	
		cLin += Alltrim(D_DOCEM->ZFK_TRANSP) + ";"
		cLin += Alltrim(D_DOCEM->ZFK_LOJA)   + ";"	
		cLin += Alltrim(D_DOCEM->ZFK_NMTRAN) + ";"	
		cLin += Alltrim(D_DOCEM->ZFK_PLACA)  + ";"	
		cLin += DToC(SToD(D_DOCEM->ZFK_DTEMIS)) + ";"	
		cLin += Alltrim(D_DOCEM->ZFK_TPDOC)  + ";"	
		cLin += Alltrim(D_DOCEM->ZFK_NUMDOC) + ";"	
		cLin += Alltrim(D_DOCEM->ZFK_SERDOC) + ";"	
		cLin += Transform(Val(cValToChar(D_DOCEM->ZFK_VALOR)),"@E 999,999,999.99") + ";"	
		cLin += Alltrim(cMsgStatus)          + ";"	
		cLin += Alltrim(D_DOCEM->ZFK_ICMS)   + ";"	
		cLin += Transform(Val(cValToChar(D_DOCEM->ZFK_VLRICM)),"@E 999,999,999.99") + ";"	//Everson-21/08/2019-Ch:044314.
		cLin += Alltrim(D_DOCEM->ZFK_PEDCOM) + ";"	
		cLin += Alltrim(D_DOCEM->ZFK_ENTRAD) + ";"

		cLin += cEof

		FWrite(nHdl,cLin,Len(cLin))

		cLin := ""

		D_DOCEM->(DbSkip())
		
	End

	//Fecha o arquivo.
	FClose(nHdl)

	WinExec("Explorer.exe" + Space(1) + cDir )

	MsgInfo("Arquivo gerado.","Função processa(ADLOG059R)")
	
	//
	RestArea(aArea)
	
Return Nil
/*/{Protheus.doc} scpSql
	Script Sql com dos documentos emitidos. 
	@type  Static Function
	@author Everson
	@since 31/07/2019
	@version 01
	/*/
Static Function scpSql()

	//Variáveis.	
	Local aArea	 := GetArea()
	Local cQuery:= ""	

	cQuery += " SELECT " 
	cQuery += " DISTINCT  " 
	cQuery += " ZFK_FILIAL,  " 
	cQuery += " ZFK_DTENTR, ZFK_ROTEIR, ZFK_TRANSP, ZFK_LOJA, ZFK_NMTRAN, ZFK_PLACA,  " 
	cQuery += " ZFK_DTEMIS,  " 
	cQuery += " CASE WHEN ZFK_TPDOC = '1' THEN 'CT-E' ELSE 'MDF-E' END AS ZFK_TPDOC,  " 
	cQuery += " ZFK_NUMDOC, ZFK_SERDOC, SUM(ZFK_VALOR) AS ZFK_VALOR, ZFK_STATUS, " 
	cQuery += " CASE WHEN ZFK_ICMS = '2' THEN 'Sim' ELSE 'Não' END AS ZFK_ICMS,  " 
	cQuery += " ZFK_PEDCOM,  " 
	cQuery += " CASE WHEN ZFK_ENTRAD = '1' THEN 'Pendente' ELSE 'Lançado' END AS ZFK_ENTRAD, ZFK_TPDOC AS TPDOC, ZFK_VLRICM "  //Everson-21/08/2019-Ch:044314.
	cQuery += " FROM " 
	cQuery += " " + RetSqlName("ZFK") + " (NOLOCK) AS ZFK " 
	cQuery += " WHERE " 
	cQuery += " ZFK_FILIAL      = '" + FWxFilial("ZFK") + "' " 
	cQuery += " AND ZFK_DTENTR >= '" + DToS(MV_PAR01)		+ "' " 
	cQuery += " AND ZFK_DTENTR <= '" + DToS(MV_PAR02)   	+ "' " 
	cQuery += " AND ZFK_TRANSP >= '" + Alltrim(MV_PAR03)	+ "' " 
	cQuery += " AND ZFK_TRANSP <= '" + Alltrim(MV_PAR05)	+ "' " 
	cQuery += " AND ZFK_LOJA   >= '" + Alltrim(MV_PAR04)	+ "' " 
	cQuery += " AND ZFK_LOJA   <= '" + Alltrim(MV_PAR06)	+ "' " 
	cQuery += " AND ZFK_PLACA  >= '" + Alltrim(MV_PAR07)	+ "' " 
	cQuery += " AND ZFK_PLACA  <= '" + Alltrim(MV_PAR08)	+ "' " 
	cQuery += " AND ZFK_ROTEIR >= '" + Alltrim(MV_PAR09)	+ "' " 
	cQuery += " AND ZFK_ROTEIR <= '" + Alltrim(MV_PAR10)	+ "' " 
	cQuery += " AND ZFK.D_E_L_E_T_ = '' " 
	
	cQuery += " GROUP BY "
	cQuery += " ZFK_FILIAL, ZFK_DTENTR, ZFK_ROTEIR, ZFK_TRANSP, ZFK_LOJA, ZFK_NMTRAN, ZFK_PLACA,  "
	cQuery += " ZFK_DTEMIS, ZFK_TPDOC, ZFK_NUMDOC, ZFK_SERDOC, ZFK_STATUS, ZFK_ICMS, ZFK_PEDCOM, ZFK_ENTRAD, ZFK_VLRICM " //Everson-21/08/2019-Ch:044314.
	
	cQuery += " ORDER BY " 
	cQuery += " ZFK_FILIAL, ZFK_TRANSP, ZFK_PLACA, ZFK_DTENTR, ZFK_ROTEIR, ZFK_TPDOC " 

	//
	RestArea(aArea)
	
Return cQuery 
