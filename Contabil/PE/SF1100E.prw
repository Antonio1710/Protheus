#INCLUDE "PROTHEUS.CH"
#INCLUDE "rwmake.ch"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} User Function SF1100E
	PE na Exclusao de NFE - MATA103 - Documento de Entrada
	Tratamento da atualização do campo STATUS_PRC e STATUS_INT da tabela intermediário SGNFE010 devido ao projeto SAG II	
	@type  Function
	@author HCCONSYS
	@since 03/2009
	@version version
	@history Revisão leiaute fonte - Adriana Oliveira - 13/12/2019
	@history Alteração - Adriana Oliveira - 13/12/2019 - 053647, para excluir a NF nas tabelas ZZA e ZZB de Dados da NF de Importação
/*/

User Function SF1100E()

Local aArea		:= GetArea()
Local cFiltro	:= ""
Local cSeriNF	:= "" 
Local cNumNF	:= "" 
Local cItemNF	:= "" 

If cEmpAnt == '01'

	//TRATAMENTO INTEGRAÇÃO SAG - INICIO
	
	If SF1->F1_CODIGEN > 0 .and. SF1->F1_FORMUL=='S' .AND. "PRODUTOR RURAL" $ SF1->F1_MENNOTA
		lRet	:= IntegraSAG()	
	EndIf
	RestArea(aArea)

	//TRATAMENTO INTEGRAÇÃO SAG - FIM
	
	//Inicio alterações Adriana Oliveira - 13/12/2019 - 053647
	If SF1->F1_EST = "EX" 
		cNumNF	:= CriaVar("ZZB_NUMNF",.F.)
		cItemNF	:= CriaVar("ZZB_ITEMNF",.F.)
		
		//dbSelectArea("SD1")
		cFiltro := "ZZB_NUMNF 	= '" + SF1->F1_DOC  	+ "' .AND. ZZB_SERINF = '" + SF1->F1_SERIE  + "' .AND. " 
		cFiltro += "ZZB_FORNEC 	= '" + SF1->F1_FORNECE  + "' .AND. ZZB_LOJA   = '" + SF1->F1_LOJA	+ "'  "
			
		cIndex:= CriaTrab(NIL,.F.)
		IndRegua("ZZB",cIndex,"ZZB_NUMNF",,cFiltro,"Verificando NF Importação ...")
		
		ZZB->(dbGoTop())
		
		Do While ZZB->(!Eof())
					
			RecLock("ZZB",.F.)
		
				ZZB->ZZB_NUMNF 	:= cNumNF
				ZZB->ZZB_ITEMNF	:= cItemNF
		
			MsunLock("ZZB")
							
			ZZB->(DbSkip())
							
		Enddo

		DbClosearea("ZZB")

		DbSelectArea("ZZA")
		DbSetOrder(2)
		If DBSEEK( xFilial("ZZA")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE)
			RecLock("ZZA",.F.)
		
				ZZA->ZZA_NUMNF 	:= cNumNF
				ZZA->ZZA_SERINF	:= cSeriNF
		
			MsunLock("ZZA")
		Endif

		DbClosearea("ZZA")

	Endif
	//Fim alterações Adriana Oliveira - 13/12/2019 - 053647

Endif

RestArea(aArea)

RETURN()


/*/{Protheus.doc} Static Function IntegraSAG
	Processa Integração SAG na Exclusao de NFE - MATA103 - Documento de Entrada
	@type  Function
	@author KF
	@since 26/08/2016
	@version version
/*/

Static Function IntegraSAG()

Local aArea	    := GetArea()
Local aAreaSF1  := SF1->(GetArea())
Local cAliasNFE := CriaTrab(NIL,.F.)	
Local cKeyNFE	:= SF1->(F1_FILIAL+F1_DOC+F1_FORNECE+F1_LOJA)
// Local _nTcConn1 := advConnection()
// Local _cNomBco2 := GetPvProfString("INTSAGBD","BCO2","ERROR",GetADV97())
// Local _cSrvBco2 := GetPvProfString("INTSAGBD","SRV2","ERROR",GetADV97())
// Local _cPortBco2:= Val(GetPvProfString("INTSAGBD","PRT2","ERROR",GetADV97()))
// Local _nTcConn2 := 0

// If (_nTcConn2 := TcLink(_cNomBco2,_cSrvBco2,_cPortBco2)) < 0
// 	_lRet     := .F.
// 	cMsgError := "Não foi possível  conectar ao banco integração"
// 	MsgInfo("Não foi possível  conectar ao banco integração, verifique com administrador","ERROR")		
// 	Return lRet
// EndIf

//TcSetConn(_nTcConn2)

TcSqlExec("UPDATE SGNFE010 SET STATUS_INT = '' , STATUS_PRC = '', D1_MSEXP='' WHERE F1_FILIAL+F1_XDOC+F1_FORNECE+F1_LOJA = '" +cKeyNFE + "' " )

//TcUnLink(_nTcConn2) 
                    
//TcSetConn(_nTcConn1)

RestArea(aArea)
RestArea(aAreaSF1)

Return
