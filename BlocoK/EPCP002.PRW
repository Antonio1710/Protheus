#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"

/*/{Protheus.doc} User Function EPCP002
	Gera requisicoes e devolucoes para acertar estoque de acordo com a digitacao do inventario
	@type  Function
	@author Erike Yuri da Silva
	@since 31/01/2006
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@history ticket SN     - Ricardo Lima - 19/09/2018 - ajuste nas casas decimanis e acerto da diferenca para op de maior valor
	@history ticket 048140 - FWNM         - 27/03/2019 - Mudanca de mensagem p/ usuario identificar a ocorrencia de maior valor
	@history ticket 051064 - FWNM         - 13/08/2019 -  051064 || OS 052377 || CONTROLADORIA || REINALDO_FRANCISCHINELLI || 8947 || RATEIO
	@history ticket 051089 - FWNM         - 13/08/2019 -  051089 || OS 052389 || CONTROLADORIA || REINALDO_FRANCISCHINELLI || 8947 || MV_DBLQMOV
	@history ticket 15796  - FWNM         - 10/08/2021 -  ERRO ROTINA GERA AJUSTE - Objeto: EPCP002
/*/
User Function EPCP002(lBatch,cCodInv)

	LOCAL oDlg
	LOCAL nOpca		:=0
	LOCAL lOk		:= .T.
	
	PRIVATE lLocCQ	:= .T.		// Flag usado para indicar se criou IndRegua no SD7
	PRIVATE cLoteEst 			// Numero do lote para lancamentos do estoque      
	PRIVATE cNomArq				//	Nome do arquivo temporario criado pela IndRegua 
	PRIVATE nHdlPrv   			// Endereco do arquivo de contra prova dos lanctos cont.
	PRIVATE nNewOrd
	
	#IFDEF TOP
		TCInternal(5,"*OFF")   // Desliga Refresh no Lock do Top
	#ENDIF
	
	Private aRotina := Menudef()
	/*
	If !(  Substring(Alltrim(SM0->M0_CGC),1,8) $ "10216923|62355789|61161139")
		Alert ("Empresa nใo autorizada a utilizar o template de rateio de inventแrio")
		Return nil
	EndIf
	*/
	
	AjustaSx1()

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Gera requisicoes e devolucoes para acertar estoque de acordo com a digitacao do inventario')
	
	IF lBatch
		nOpca := 1
	Endif
	
	If __cInternet != Nil
		lBatch := .T.
	EndIf
	IF !lBatch
		If Substr(cAcesso,19,1) == " "
			Help ( " ", 1, "SEMPERM" )
			Return .F.
		EndIf
		DEFINE MSDIALOG oDlg FROM  96,4 TO 355,625 TITLE OemToAnsi("Acerto do Inventario") PIXEL
		@ 18, 9 TO 99, 300 LABEL "" OF oDlg  PIXEL
		@ 29, 15 Say OemToAnsi("Este programa ira gerar movimentacoes de ajuste para corrigir o saldo do estoque.") SIZE 275, 10 OF oDlg PIXEL	
		@ 38, 15 Say OemToAnsi("Estas movimentacoes serao baseadas nas contagens realizadas e cadastradas na Rotina Inventario CMP.") SIZE 275, 10 OF oDlg PIXEL	
		@ 48, 15 Say OemToAnsi("O programa devera gerar uma Requisicao ou uma Devolucao para as ordens de producao selecionadas.") SIZE 275, 10 OF oDlg PIXEL	
		@ 58, 15 Say OemToAnsi("Nota: Sera considerado apenas o estoque inventariado na data da selecao (parametros).") SIZE 255, 10 OF oDlg PIXEL	
		@ 68, 15 Say OemToAnsi("Sera gerado historico de todos os processamentos, mesmos dos que tiveram inconsistencias.") SIZE 255, 10 OF oDlg PIXEL	
	
		DEFINE SBUTTON FROM 108,209 TYPE 05 ACTION Pergunte("PCP002",.T.) ENABLE OF oDlg
		DEFINE SBUTTON FROM 108,238 TYPE 1 ACTION (nOpca:=1,oDlg:End()) ENABLE OF oDlg
		DEFINE SBUTTON FROM 108,267 TYPE 2 ACTION oDlg:End() ENABLE OF oDlg
		ACTIVATE MSDIALOG oDlg CENTER
	Endif
	If nOpca == 1
		IF lOk
			If lBatch
				EPCP002Proc(lBatch,cCodInv)
			Else		
				Processa({|lend| EPCP002Proc(lBatch,NIL)},"Pre-Processamento do Inventario","Efetuando Calculo dos Ajustes...",.F.)
			Endif
		Endif	
	EndIf
	
	If !lLocCQ
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Devolve as ordens originais do arquivo                       ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		RetIndex("SD7")
		dbClearFilter()
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Apaga indice de trabalho                                     ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		cNomArq += OrdBagExt()
		Delete File &(cNomArq)
	EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณEPCP002Proc ณ Autor ณ Erike Yuri da Silva   ณ Data ณ04/02/06ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Processa o Acerto do Inventario do Dia CMP              ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ EPCP002                                                    ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/         
Static Function EPCP002Proc(lBatch,cCodInv)

	Local cCod,cLocal,dData,nQuant,nQtSegUm,dDtInvDe,dDtInvAte,cDocDe,cDocAte
	Local cLote:="",cLoteCtl:="",dDtValid:="",cNumSerie:="",cLocaliza:="",cChave :="",cNumInv := ""
	Local cApropri,cNumSeq,cLog:=""
	Local cLocalCQ:=GetMv("MV_CQ")
	Local dData2:=GETMV("MV_ULMES")
	Local dData1:=GETNEWPAR("MV_DBLQMOV",dData2)
	Local dDataFec:=IIF(dData1>dData2,dData1,dData2)
	Local cCusMed :=GETMV("MV_CUSMED") 
	Local cAliasSql:="ZAM", cQuery:=""
	Local cAliasCC := If(CtbInUse(), "CTT", "SI3")
	Local lOpca,lPassou,lOkLote:=.F.,lGeraCQ0:=.F., lContinua := .T.
	Local lOK, lDigita,lAglutina,lEstNeg :=If(GetMV('MV_ESTNEG')=='N',.F.,.T.)  
	Local nAchou,i,z,nDiferenca:=0
	Local nTotEnd 	:= 0, nQtdInv := 0,nX:=0,nCampo:=0 ,nEmpenho:=0  
	Local nRecSF5 	:= SF5->(Recno())   
	Local aSaldo	:=Array(7)
	Local nSaldo    := 0
	Local aSaldoSBF	:=Array(7)
	Local aMata		:={},aStruZAM := {},aStru := {},aInvCount:={}
	Local aCM		:={},aCusto:={},aCM1:={},aLogs:={{}},aLocks := {}
	
	Private cDrvINV	:= ""                                  
	Private cArqInv	:= ""       	
	Private cArqApu	:= ""
	Private aOP		:= {}    
	Private lMSErroAuto := .F.
	
	Private aCampos1  := {}
	Private aCampos2  := {}
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Cria estrutura da tabela de pre-processamento.               ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	#IFDEF WNTX
		cDrvINV := "DBFNTX"
	#ENDIF
	#IFDEF WCDX
		cDrvINV := "DBFCDX"
	#ENDIF
	#IFDEF WAXS
		cDrvINV := "DBFCDXAX"
	#ENDIF
	#IFDEF WCODEBASE
		cDrvINV := "DBFCDXTTS"
	#ENDIF                                                           
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Definicao do nome do arquivo: "INV"+Empresa+Id do Usuario    ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	cArqInv := CriaTrab(Nil,.F.) //REtArq(cDrvINV,"INV"+Substr(cNumEmp,1,2)/*+__cUserID*/,.t.)
	
	If MSFile(cArqInv,,cDrvINV) 
		If Select("INV")==0
	   		dbUseArea( .T.,cDrvINV, cArqInv, "INV", If(.F. .OR. .T., !.T., NIL), .F. )   
	 	EndIf
		DbCloseArea()
		FErase(cArqInv)
		FErase(FileNoExt(cArqInv)+"1"+OrdBagExt())
	EndIf
	
	If Select("INV")> 0
		INV->(DbCloseArea())
	EndIf
	
	AADD(aStru ,{"LOG"	   		,"C", 4,0})
	AADD(aStru ,{"FILIAL"		,"C", 2,0})
	AADD(aStru ,{"COD"			,"C", TamSx3("D3_COD")[1]		,0})			
	AADD(aStru ,{"CC"	 		,"C", TamSx3("D3_CC")[1]		,0})
	AADD(aStru ,{"GRUPO"	 	,"C", TamSx3("D3_GRUPO")[1]		,0})
	AADD(aStru ,{"ARMAZEM"	 	,"C", TamSx3("D3_LOCAL")[1]		,0})
	AADD(aStru ,{"UM"	 		,"C", TamSx3("D3_UM")[1]		,0})
	AADD(aStru ,{"SEGUM"	 	,"C", TamSx3("D3_SEGUM")[1]		,0})
	AADD(aStru ,{"CONTA"	 	,"C", TamSx3("D3_CONTA")[1]		,0})
	AADD(aStru ,{"QUANT"	 	,"N", TamSx3("D3_QUANT")[1]	,TamSx3("D3_QUANT")[2]})
	AADD(aStru ,{"QTSEGUM"	 	,"N", TamSx3("D3_QTSEGUM")[1],TamSx3("D3_QTSEGUM")[2]})
	AADD(aStru ,{"SLDMP8"	 	,"N", TamSx3("D3_QUANT")[1]	,TamSx3("D3_QUANT")[2]})
	AADD(aStru ,{"SLDMP8SG"	 	,"N", TamSx3("D3_QTSEGUM")[1],TamSx3("D3_QTSEGUM")[2]})
	AADD(aStru ,{"DIF"	   		,"N", TamSx3("D3_QUANT")[1],TamSx3("D3_QUANT")[2]})
	AADD(aStru ,{"TIPO"	 		,"C", TamSx3("D3_TIPO")[1]		,0})
	AADD(aStru ,{"LOCALIZ"	 	,"C", TamSx3("D3_LOCALIZ")[1]	,0})
	AADD(aStru ,{"NUMSERI"	 	,"C", TamSx3("D3_NUMSERI")[1]	,0})
	AADD(aStru ,{"LOTECTL"	 	,"C", TamSx3("D3_LOTECTL")[1]	,0})
	AADD(aStru ,{"NUMLOTE"	 	,"C", TamSx3("D3_NUMLOTE")[1]	,0})
	AADD(aStru ,{"USUARIO"	 	,"C", TamSx3("D3_USUARIO")[1]	,0})
	AADD(aStru ,{"DTVALID"	 	,"D", TamSx3("D3_DTVALID")[1]	,0})
	AADD(aStru ,{"TM"	 		,"C", TamSx3("D3_TM")[1]		,0})
	AADD(aStru ,{"CF"	 		,"C", TamSx3("D3_CF")[1]		,0})
	AADD(aStru ,{"CHAVE"	 	,"C", TamSx3("D3_CHAVE")[1]		,0})  
	AADD(aStru ,{"NUMINV" 	    ,"C", TamSx3("D3_NUMINV")[1]	,0})  
	DbCreate(cArqInv,aStru,__LocalDriver)
	dbUseArea( .T.,cDrvINV, cArqInv, "INV", If(.F. .OR. .T., !.T., NIL), .F. )
	IndRegua("INV",FileNoExt(cArqInv)+"1","FILIAL+COD+ARMAZEM+LOCALIZ+NUMSERI+LOTECTL+NUMLOTE",,,"Selecionando Registros...")
	dbClearIndex()
	dbSetIndex( FileNoExt(cArqInv)+"1"+OrdBagExt())
	Do While .T.
		IF lBatch
			pergunte("PCP002",.F.)
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ Carrega as perguntas selecionadas                            ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			If cCodInv#NIL
				MV_PAR01 := ZAM->ZAM_DATA
				MV_PAR02 := ZAM->ZAM_DTATE
				MV_PAR03 := ZAM->ZAM_COD
				MV_PAR04 := ZAM->ZAM_COD
				MV_PAR05 := cCodInv
				MV_PAR06 := cCodInv
			EndIf
		Else
			pergunte("PCP002",.F.)
			lOpca:=.T.
		Endif
		
		// Chamado n. 051089 || OS 052389 || CONTROLADORIA || REINALDO_FRANCISCHINELLI || 8947 || MV_DBLQMOV - FWNM - 13/08/2019
		lUsrAut := .f.
		cUsrAut  := GetMV("MV_#USRKFS",,"001908#001428") // Usuarios autorizados
		If RetCodUsr() $ cUsrAut
			lUsrAut := .t.
		EndIf
		//
		
		If mv_par01 <= dDataFec
			If lUsrAut
				If !MsgYesNo("Voc๊ ้ um usuแrio autorizado pelo parโmetro MV_#USRKFS! Os parโmetros MV_DBLQMOV/MV_ULMES estใo fechados para o perํodo " +DtoC(dDataFec)+ " ... Deseja continuar mesmo assim?")
					Return
				EndIf
			Else
				Aviso("Aviso","Nao existem registros com data posterior ao parametro MV_DBLQMOV/MV_ULMES: "+DTOC(dDataFec),{"OK"})
				//Help (' ', 1, 'FECHTO')
				Return
			EndIf
		EndIf
	
		If !Empty(mv_par09)
			(cAliasCC)->(dbSetOrder(1))
			If !(cAliasCC)->((dbSeek(xFilial(cAliasCC)+mv_par09)))
				mv_par09:=""
			Endif
		Endif
		
		If !Empty(mv_par10)
			(cAliasCC)->(dbSetOrder(1))
			If !(cAliasCC)->((dbSeek(xFilial(cAliasCC)+mv_par10)))
				mv_par10:="ZZZZZZZZZ"
			Endif
		Endif
		
		If lBatch
			lOpca := .T.
		Endif
	
		If !lOpcA
			Exit
		Else
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ Posiciona numero do Lote para Lancamentos do Faturamento     ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			dbSelectArea("SX5")
			dbSeek(xFilial()+"09EST")
			cLoteEst:=IIF(Found(),Trim(X5Descri()),"EST ")
	
			PRIVATE nTotal := 0 	// Total dos lancamentos contabeis
			dbSelectArea("ZAM")
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ Totaliza registros de digitacao de inventario                          ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			cAliasSQL	:= "ZAMSQL"
			aStruZAM	:= ZAM->(dbStruct())
			cQuery		:= " SELECT DISTINCT ZAM_FILIAL,ZAM_COD,ZAM_LOCAL,ZAM_QUANT,ZAM_QTSEGU,ZAM_LOCALI,ZAM_NUMSER, "
			cQuery 		+= " ZAM_LOTECT,ZAM_NUMLOT,ZAM_DTVALI,ZAM_DATA,ZAM_NUM  "
			cQuery 		+= " FROM "
			cQuery 		+= RetSqlName("ZAM")+" ZAM "
			cQuery 		+= " WHERE ZAM.ZAM_FILIAL='"+xFilial("ZAM")+"' AND"
			cQuery 		+= " ZAM.ZAM_DATA>='"+DTOS(mv_par01)+"' AND ZAM.ZAM_DTATE='"+DTOS(mv_par02)+"' AND"
			cQuery 		+= " ZAM.ZAM_COD>='"+mv_par03+"' AND ZAM.ZAM_COD<='"+mv_par04+"' AND"
			cQuery 		+= " ZAM.ZAM_DOC>='"+mv_par05+"' AND ZAM.ZAM_DOC<='"+mv_par06+"' AND"
			cQuery 		+= " ZAM.ZAM_STATUS<>'2' AND"
			cQuery 		+= " ZAM.D_E_L_E_T_<>'*'"
			cQuery 		+= " ORDER BY ZAM_FILIAL,ZAM_COD,ZAM_LOCAL,ZAM_LOCALI,ZAM_NUMSER,ZAM_LOTECT,ZAM_NUMLOT"
			cQuery 		:= ChangeQuery(cQuery)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSQL,.F.,.T.)
			For nX := 1 To Len(aStruZAM)
				If aStruZAM[nX][2]<>"C" .And. FieldPos(aStruZAM[nX][1])<>0
					TcSetField(cAliasSQL,aStruZAM[nX][1],aStruZAM[nX][2],aStruZAM[nX][3],aStruZAM[nX][4])
				EndIf
			Next nX
			If !lBatch
				ProcRegua(LastRec(),21,6)
			EndIf
			nQuant 		:= 0
			nQtSegum	:= 0
			DbGotop()
			While !EOF()
				If !lBatch
					IncProc()
				EndIf
	
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณ Filtra itens com digitacao incorreta rastreabilidade         ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				If Rastro(ZAM_COD) .And. Empty(ZAM_LOTECT) .Or. (Rastro(ZAM_COD,"S") .And. Empty(ZAM_NUMLOT))
					dbSkip()
					Loop
				EndIf
	
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณ Filtra itens com digitacao incorreta localizacao fisica      ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				If Localiza(ZAM_COD) .And. Empty(ZAM_LOCALI+ZAM_NUMSER)
					dbSkip()
					Loop
				EndIf
	            
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณTrava arquivo para somente este usuario utilizar rotinaณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				nTentativas := 0                           
				While !LockByName("ZAM"+ZAM_COD+ZAM_LOCAL,.T.,!Empty(xFilial("ZAM")),.T.) .And. nTentativas <= 50
					nTentativas++
					Sleep(5000)
				End            
				
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณ Se apos 50 tentativas nao conseguir travar chave aborta sistema  ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				If nTentativas >= 50                 
					For nX :=1 To Len(aLocks)
						UnLockByName(aLocks[nX],.T.,!Empty(xFilial("ZAM")),.T.)
					Next  
					MsgAlert('Nao conseguiu acesso exclusivo para o produto "'+ZAM_COD+'", do '+;
							'armazem "'+ZAM_LOCAL+'" !!!' ,"ATENCAO")   
					lContinua := .F.  
					aLocks := {}
					Exit  
				Else
					//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
					//ณ Salva produto locado para posteriormente deslocalo           ณ
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
					Aadd(aLocks,"ZAM"+ZAM_COD+ZAM_LOCAL)
				EndIf		 
	
				cNumInv  := ZAM_NUM
				cCod     := ZAM_COD
				cLocal   := ZAM_LOCAL
				dData    := RetMaxDateZAM(cAliasSQL,ZAM_COD,ZAM_LOCAL,ZAM_LOCALI,ZAM_NUMSER,ZAM_LOTECT,ZAM_NUMLOT,ZAM_DATA)
				cLote	 := ZAM_NUMLOT
				cLoteCtl := ZAM_LOTECT
				dDtValid := ZAM_DTVALI
				nEmpenho := 0
				cLocaliza:= ZAM_LOCALI
				cNumSerie:= ZAM_NUMSER
				cLog     := ""
				nQuant   := ZAM_QUANT
				nQtSegum := ZAM_QTSEGU
				//aInvCount:= QtdInvZAM(cCod,cLocal,cLocaliza,cNumSerie,cLoteCtl,cLote) 	
				//nQuant   := aInvCount[1]
				//nQtSegum := aInvCount[2]
				
				SB1->(dbSeek(xFilial("SB1")+cCod))
				(cAliasSQL)->(dbSkip())
	
				cApropri := "0"
				dbSelectArea("SB2")
				dbSetOrder(1)
				If !dbSeek(xFilial()+cCod+cLocal)
					CriaSB2(cCod,cLocal)
				EndIf
				If Localiza(cCod)
					nTotEnd := SaldoSBF(cLocal,"",cCod)
					If QtdComp(SB2->B2_QATU)-QtdComp(SB2->B2_QACLASS)-QtdComp(SB2->B2_QEMP) # QtdComp(nTotEnd)-QtdComp(SB2->B2_QEMP)
						cLog     := 'B2BF'												
					EndIf   						
				EndIf
	
				If Rastro(cCod) .Or. Localiza(cCod)
					aSaldoSBF	:= CalcEstL(cCod,cLocal,mv_par02+1,cLoteCtl,cLote,cLocaliza,cNumSerie)
					If IntDl(cCod)
						nEmpenho := SB2->B2_RESERVA
						cLog     := If(Empty(cLog),'SB2E',cLog)
					Else
						If Localiza(cCod)
							nEmpenho	:= EmpLocLz(cCod,cLocal,cLoteCTL,cLote,cLocaliza,cNumSerie)
							cLog		:= If(Empty(cLog),"SBF",cLog)
							aSaldoSBF[7]:= ConvUm(SB1->B1_COD, aSaldoSBF[1], aSaldoSBF[7], 2)
						ElseIf Rastro(cCod)
							nEmpenho	:= EmpLote(cCod,cLocal,cLoteCTL,cLote)
							cLog		:= If(Empty(cLog),"SB8",cLog)
						EndIf
					EndIf
				Else
					aSaldo := CalcEst(cCod,cLocal,mv_par02+1)
					If !lEstNeg
						nEmpenho	:= SB2->B2_RESERVA
						cLog		:= If(Empty(cLog),"SB2E",cLog)
					EndIf
				EndIf
	
				//--> Verifica se o saldo do produto no armazem esta disponivel
				If SB2->B2_STATUS $ "2"
					cLog := If(Empty(cLog),"SB2I",cLog)
				Else
					If Localiza(cCod)
						If aSaldoSBF[1] = 0
							cLog := "SBF0"
						Endif	
					ElseIF aSaldo[1] < 0
						cLog := "SB2-"
					Endif				
				EndIf
	
				If SB2->B2_DINVENT <= mv_par01
					If SB2->B2_STATUS # "2"					
						RecLock("INV",.T.)
						FILIAL	:= xFilial()
						COD		:= cCod
						GRUPO	:= SB1->B1_GRUPO
						ARMAZEM	:= cLocal
						UM		:= SB1->B1_UM
						SEGUM   := SB1->B1_SEGUM
						CONTA	:= SB1->B1_CONTA
						QUANT	:= nQuant
						QTSEGUM	:= nQtSegUm
						nSaldo  := IIF(Localiza(cCod),aSaldoSBF[1],aSaldo[1])
						SLDMP8	:= nSaldo
						SLDMP8SG:= IIF(Localiza(cCod),aSaldoSBF[7],aSaldo[7])
						DIF		:= ABS(nQuant - nSaldo)
						TIPO	:= SB1->B1_TIPO
						LOCALIZ	:= cLocaliza
						NUMSERI	:= cNumSerie
						LOTECTL	:= cLoteCtl
						NUMLOTE	:= cLote
						USUARIO	:= SubStr(cUsuario,7,15)
						DTVALID	:= dDtValid
	                    NUMINV  := cNumInv
	
						If nSaldo > nQuant
							TM	:= "999"
							CF	:= "RE"+cApropri
						Else
							TM	:= "499"
							CF	:= "DE"+cApropri
						EndIf
						CHAVE	:= SubStr(CF,2,1)+IIF(CF=="DE4","9","0")
						LOG      := IIF(cLog $ "SB2-/SBF0" .and. TM="499","",cLog)
						INV->(MsUnLock())  					
	
					Else
						For i:=1 to Len(aLogs)
							nAchou:=ASCAN(aLogs[i],{|x| x[1] == cLog .And. x[2]+x[3]+x[4]+x[5]+x[6]+x[7] == cCod+cLocal+cLoteCtl+cLote+cLocaliza+cNumSerie})
							If nAchou > 0
								Exit
							EndIf
						Next i
						If nAchou == 0
							//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
							//ณ Adiciona registro em array p/ baixar empenho.  ณ
							//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
							If Len(aLogs[Len(aLogs)]) > 4095
								AADD(aLogs,{})
							EndIf
							AADD(aLogs[Len(aLogs)],{cLog,cCod,cLocal,cLoteCtl,cLote,cLocaliza,cNumSerie})
						EndIf
					EndIf
				EndIf
				dbSelectArea(cAliasSql)
			EndDo
			Exit
		EndIf
	EndDo
	
	If lContinua
		If INV->(RecCount()> 0)
			If ViewPreProc() == 1
				If MsgYesNo ("Confirma processamento?","Ajuste de Inventแrio") 
					//Salva integridade de perguntas
					dDtInvDe 	:= mv_par01
					dDtInvAte	:= mv_par02
					cDocDe		:= mv_par05
					cDocAte		:= mv_par06                       
					Processa({|| EPCP002PAcerto(dDtInvDe,dDtInvAte,cDocDe,cDocAte) },"Acerto do inventario Fracionado...")		
					DbSelectArea("SF5")
					DbGoTo(nRecSF5)
				EndIf
		    EndIf
		Else
			Aviso("Aviso","Nao existem registros a serem analisados",{"OK"})
		EndIf
	EndIf		     
	
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณFaz UnLock dos produtos locados para o inventarioณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	For nX :=1 To Len(aLocks)
		UnLockByName(aLocks[nX],.T.,!Empty(xFilial("ZAM")),.T.)
	Next
	
	If Select("INV")> 0
		INV->(DbCloseArea())
	EndIf   
	
	If Select("APU")> 0
		APU->(DbCloseArea())
	EndIf
	
	If MSFile(cArqInv,,cDrvINV)  		
		FErase(cArqInv)
		FErase(FileNoExt(cArqInv)+"1"+OrdBagExt())
	EndIf                                           
	If MSFile(cArqApu,,cDrvINV)  		
		FErase(cArqApu)
		FErase(FileNoExt(cArqApu)+"1"+OrdBagExt())	
	EndIf                                           	
	
	dbSelectArea(cAliasSQL)
	dbCloseArea()
	dbSelectArea("ZAM")
	
	If Len(aLogs[1]) > 0
		For i:=1 to Len(aLogs)
			For z:=1 to Len(aLogs[i])
				// Verifica saldo em estoque
				If aLogs[i,z,1] == "SB2"
					dbSelectArea("SB2")
					dbSetOrder(1)
					If dbSeek(xFilial()+aLogs[i,z,2]+aLogs[i,z,3])
						If B2_QATU > 0 .And. B2_STATUS # "2"
							aLogs[i,z,1] := "OK"
						EndIf
					EndIf
				EndIf
			Next z
		Next i
		E002LstNeg(aLogs)
	EndIf

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณE002LstNegณ Autor ณErike Yuri da Silva    ณ Data ณ04/02/2006ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Relatorio de Produtos que ficaram com o saldo negativo     ณฑฑ
ฑฑณ          ณ ou tiveram itens que nao podem ser inventariados           ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ EPCP002                                                    ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function E002LstNeg(aLogs)

	LOCAL titulo   := "Itens nao Inventariados"	//
	LOCAL cDesc1   := "O relatorio lista os produtos que nao puderam ser inventariados por "	
	LOCAL cDesc2   := "alguma situacao que impede a correta contagem de seus saldos e lista "	
	LOCAL cDesc3   := "tb produtos que continuam com saldo divergente apos o processamento."	
	LOCAL cString  := "SB2"
	LOCAL wnrel    := "EPCP002"
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Variaveis tipo Private padrao de todos os relatorios         ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	PRIVATE aReturn	:= {"Zebrado",1,"Administracao", 2, 2, 1, "",1 }	
	PRIVATE nLastKey:= 0,cPerg:="      "
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Envia controle para a funcao SETPRINT                        ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	
	wnrel:=	SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,,,,,.F.)
	If nLastKey = 27
		dbClearFilter()
		Return
	Endif
	
	SetDefault(aReturn,cString)
	
	If nLastKey = 27
		dbClearFilter()
		Return
	Endif
	
	RptStatus({|lEnd| E002CImp(@lEnd,wnRel,titulo,aLogs)},titulo)

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ E002CImp ณ Autor ณ Erike Yuri da Silva   ณ Data ณ04/02/2006ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Chamada do Relatorio                                       ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ EPCP002  			                                      ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function E002CImp(lEnd,WnRel,titulo,aLogs)

	LOCAL Tamanho  := "P"
	LOCAL nTipo    := 0
	LOCAL cRodaTxt := "REGISTRO(S)"	
	LOCAL nCntImpr := 0
	LOCAL i,z
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Inicializa variaveis para controlar cursor de progressao     ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	SetRegua(Len(aLogs))
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Inicializa os codigos de caracter Comprimido/Normal da impressora ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	nTipo  := IIF(aReturn[4]==1,15,18)
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Contadores de linha e pagina                                 ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	PRIVATE li := 80 ,m_pag := 1
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Cria o cabecalho.                                        ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	cabec1 := "OCOR PRODUTO         DESCRICAO       ARMAZ   QUANTIDADE     LOTE      SUB-LOTE"	
	cabec2 := "                                            ENDERECO        NUMERO DE SERIE   "
	//         1234 123456789012345 12345678901234545 12   12345678901234  1234567890 123456
	//                                                     123456789012345 12345678901234567890
	//         0         1         2         3         4         5         6         7         8
	//         012345678901234567890123456789012345678901234567890123456789012345678901234567890
	
	SB1->(dbSetOrder(1))
	SB2->(dbSetOrder(1))
	
	For i:=1 to Len(aLogs)
		IncRegua()
		For z:=1 to Len(aLogs[i])
			If aLogs[i,z,1] != "OK"
				If li > 58
					cabec(titulo,cabec1,cabec2,wnrel,Tamanho,nTipo)
				EndIf
				SB1->(dbSeek(xFilial("SB1")+aLogs[i,z,2]))
				SB2->(dbSeek(xFilial("SB2")+aLogs[i,z,2]+aLogs[i,z,3]))
				@ li,000 PSay aLogs[i,z,1]
				@ li,005 PSay aLogs[i,z,2] Picture PesqPict("SD3","D3_COD",15)
				@ li,021 PSay Left(SB1->B1_DESC,15) Picture PesqPict("SB1","B1_DESC",15)
				@ li,039 PSay aLogs[i,z,3] Picture PesqPict("SD3","D3_LOCAL",2)
				@ li,044 PSay SB2->B2_QATU	Picture PesqPictQt("B2_QATU",14)
				@ li,060 PSay aLogs[i,z,4]	Picture PesqPict("ZAM","ZAM_LOTECT",10)
				@ li,071 PSay aLogs[i,z,5]	Picture PesqPict("ZAM","ZAM_NUMLOT",8)
				If !Empty(aLogs[i,z,6]+aLogs[i,z,7])
					li++
					@ li,044 PSay aLogs[i,z,6]	Picture PesqPict("ZAM","ZAM_LOCALI",15)
					@ li,060 PSay aLogs[i,z,7]	Picture PesqPict("ZAM","ZAM_NUMSER",20)
				EndIf
				li++
			EndIf
		Next z
	Next i
	
	
	IF li != 80
		If li >= 50
			cabec(titulo,cabec1,cabec2,wnrel,Tamanho,nTipo)
		Else
			li++
		EndIf
		@ li,10 PSay "Legenda das Ocorrencias"
		li++
		@ li,10 PSay "SB2 - > Itens com saldo negativo nos Saldos em estoque."
		li++
		@ li,10 PSay "SLD  - > O inventario comprometeria o saldo atual do produto"
		li++
		@ li,10 PSay "SB2E/SB8/SBF - > Itens empenhados / reservados no arquivo SB2/SB8/SBF"
		li++
		@ li,10 PSay "SB2I - > Itens com saldo Indisponivel nos Saldos em Estoque"
		li++
		@ li,10 PSay "B2BF - > Itens com saldo desbalanceado entre o SB2 e o SBF, favor"
		li++
		@ li,10 PSay "B2D3 - > Quantidade nas OPS insuficiente para o ajuste no produto "
		li++											
		@ li,10 PSay "         verificar todos os processos pendentes para a tabela SBF "
		li++											
		@ li,10 PSay "         como por exemplo: enderecamentos pendentes e empenhos para"
		li++											
		@ li,10 PSay "         producao com enderecos pendentes."
		li++											
		@ li,10 PSay "INV  - > Itens com movimentacoes de C.Q."
		li++											
		Roda(nCntImpr,cRodaTxt,Tamanho)
	EndIF
	
	Set Device to Screen
	
	If aReturn[5] = 1
		Set Printer To
		dbCommitAll()
		OurSpool(wnrel)
	Endif
	
	MS_FLUSH()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณAjustaSX1 ณ Autor ณErike Yuri da Silva    ณ Data ณ04/02/2006ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณCria dianamicamente perguntas para a rotina de acerto.      ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณEPCP002                                                     ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AjustaSX1()
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Inclui pergunta no SX1                                        ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	//       1        2         3                             4                                5                               6      7     8  9 0  1   2    3   4   5   6               7       8       9       0                   1      2        3       4  5  6  7  8  9  0   1  2
	PutSX1("PCP002","01","Data de Selecao De ?          ","?Fecha de Seleccion De ?      ","Selection Date ?	       ","mv_ch1","D",	8 ,0,0,"G","","   ","","","mv_par01"	,""		,""		,""		,"01/01/2006"		,""		,""		,""		,"","","","","","","","","",{},{},{})				
	PutSX1("PCP002","02","Data de Selecao Ate?          ","?Fecha de Seleccion Ate?      ","Selection Date ?	       ","mv_ch2","D",	8 ,0,0,"G","","   ","","","mv_par02"	,""		,""		,""		,"31/12/2049"		,""		,""		,""		,"","","","","","","","","",{},{},{})				
	PutSX1("PCP002","03","Do  Produto ?	                ","?De Producto ?	             ","From Product ?	           ","mv_ch3","C",	15,0,0,"G","","SB1","","","mv_par03"	,""		,""		,""		,Space(15)			,""		,""		,""		,"","","","","","","","","",{},{},{})				
	PutSX1("PCP002","04","Ate o Produto ?               ","?A Producto ?	             ","To Product ? 	           ","mv_ch4","C",	15,0,0,"G","","SB1","","","mv_par04"	,""		,""		,""		,"ZZZZZZZZZZZZZZZ"	,""		,""		,""		,"","","","","","","","","",{},{},{})			
	PutSX1("PCP002","05","Do  Documento ?	            ","?De Documento ?  	         ","From Document ?     	   ","mv_ch5","C",	6 ,0,0,"G","","   ","","","mv_par05"	,""		,""		,""		,Space(6)			,""		,""		,""		,"","","","","","","","","",{},{},{})				
	PutSX1("PCP002","06","Ate o Documento ?  	        ","?A Documento ?   	         ","To Document ?   	       ","mv_ch6","C",	6 ,0,0,"G","","   ","","","mv_par06"	,""		,""		,""		,"ZZZZZZ"			,""		,""		,""		,"","","","","","","","","",{},{},{})
	PutSX1("PCP002","07","Da Op ?	                    ","?De O. P. ?	                 ","From Product.Order ?	   ","mv_ch7","C",	13,0,0,"G","","SC2","","","mv_par07"	,""		,""		,""		,Space(13)			,""		,""		,""		,"","","","","","","","","",{},{},{})	
	PutSX1("PCP002","08","Ate Op?	                    ","?A O. P. ?	                 ","To Production Order ?	   ","mv_ch8","C",	13,0,0,"G","","SC2","","","mv_par08"	,""		,""		,""		,"ZZZZZZZZZZZZZ"	,""		,""		,""		,"","","","","","","","","",{},{},{}) 		
	PutSX1("PCP002","09","Do Centro de Custo ?          ","?Do Centro de Costo ?         ","To Cost Center ?	       ","mv_ch9","C",	9 ,0,0,"G","","CTT","","","mv_par09"	,""		,""		,""		,Space(9)			,""		,""		,""		,"","","","","","","","","",{},{},{})
	PutSX1("PCP002","10","Ate Centro de Custo ?         ","?Ate Centro de Costo ?        ","From Cost Center ?	       ","mv_cha","C",	9 ,0,0,"G","","CTT","","","mv_par10"	,""		,""		,""		,"ZZZZZZZZZ"		,""		,""		,""		,"","","","","","","","","",{},{},{})								

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณSldSD3OPDiณ Autor ณErike Yuri da Silva    ณ Data ณ04/02/2006ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณCalcula o saldo do produto relacionado as OPs movimentadas  ณฑฑ
ฑฑณ          ณno periodo informado.                                       ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณEPCP002                                                     ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function SldSD3OPDia(cProduto,cLocal,dData,cLoteCtl,cLote,cEnd,cNumSeri,cOp,cCC)

	Local cAliasTmp	:= "SQLSD3"
	Local lRastro	:= .F.
	Local lRastroS	:= .F.
	Local lCLocal	:= .F.
	Local _cEnd, _cNumSeri, _cLoteCtl, _cNumLote
	Local nSaldo	:= 0
	Local nX
	Local aStruSD3	:= {}
	Default dData	:= mv_par01
	Default cLoteCtl:= Space(TamSx3('D3_LOTECTL')[1])
	Default cLote	:= Space(TamSx3('D3_NUMLOTE')[1])
	Default cEnd	:= Space(TamSx3('D3_LOCALIZ')[1])
	Default cNumSeri:= Space(TamSx3('D3_NUMSERI')[1])
	
	aStruSD3 := SD3->(DbStruct())
	dbSelectArea("SD3")
	cQuery := "SELECT D3_COD,D3_LOCAL,D3_NUMSEQ,D3_LOCALIZ,D3_NUMSERI,D3_LOTECTL,D3_NUMLOTE,D3_QUANT"
	cQuery += " FROM "
	cQuery += RetSqlName("SD3")+" SD3 "
	cQuery += " WHERE SD3.D3_FILIAL='"+xFilial("SD3")+"' AND"
	cQuery += " SD3.D3_COD ='"+cProduto+"' AND "
	cQuery += " SD3.D3_LOCAL ='"+cLocal+"' AND "
	cQuery += " SD3.D3_OP = '"+cOp+"' AND " 
	cQuery += " SD3.D3_CC = '"+cCC+"' AND " 
	cQuery += " SD3.D3_TM > '499' AND "
	cQuery += " SD3.D3_ESTORNO='' AND "
	cQuery += " SD3.D3_FLAGINV ='' AND "
	cQuery += " NOT(SD3.D3_CF LIKE 'PR%') AND"
	cQuery += " SD3.D_E_L_E_T_<>'*' "
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.F.,.T.)
	For nX := 1 To Len(aStruSD3)
		If aStruSD3[nX][2]<>"C" .And. FieldPos(aStruSD3[nX][1])<>0
			TcSetField(cAliasTmp,aStruSD3[nX][1],aStruSD3[nX][2],aStruSD3[nX][3],aStruSD3[nX][4])
		EndIf
	Next nX
	
	dbSelectArea(cAliasTmp)
	While (cAliasTmp)->( !Eof())
		lRastro		:= Rastro((cAliasTmp)->D3_COD)
		lRastroS	:= Rastro((cAliasTmp)->D3_COD, 'S')
		lCLocal		:= Localiza((cAliasTmp)->D3_COD)
		_cEnd		:= (cAliasTmp)->D3_LOCALIZ
		_cNumSeri	:= (cAliasTmp)->D3_NUMSERI
		_cLoteCtl	:= (cAliasTmp)->D3_LOTECTL
		_cNumLote	:= (cAliasTmp)->D3_NUMLOTE
	
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Se o SD3 nao possuir as informacoes de endereco busco no SDB ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู   	
		If lCLocal .And. Empty(_cEnd) .And. SDB->(DbSeek(xFilial("SDB")+(cAliasTmp)->(D3_COD+D3_LOCAL+D3_NUMSEQ)))
			_cEnd 		:= SDB->DB_LOCALIZ
			_cNumSeri	:= SDB->DB_NUMSERI
			_cLoteCtl	:= SDB->DB_LOTECTL
			_cNumLote	:= SDB->DB_NUMLOTE	
		ElseIf !lCLocal .And. lRastro .And. Empty(_cLoteCtl+_cNumLote) .And. SD5->(DbSeek(xFilial("SD5")+(cAliasTmp)->(D3_NUMSEQ+D3_COD+D3_LOCAL)))	
			_cLoteCtl	:= SD5->D5_LOTECTL
			_cNumLote	:= SD5->D5_NUMLOTE
		EndIf
		
		If lCLocal .And. Empty(_cEnd)
			(cAliasTmp)->(DbSkip())
			Loop
		EndIf   
		
		If lRastro .And. Empty(_cLoteCtl+_cNumLote)
			(cAliasTmp)->(DbSkip())
			Loop	
		EndIf   
		
	    If (cLoteCtl+cLote+cEnd+cNumSeri)#(_cLoteCtl+_cNumLote+_cEnd+_cNumSeri)
			(cAliasTmp)->(DbSkip())
			Loop	    
	    EndIf
		nSaldo += (cAliasTmp)->D3_QUANT
		(cAliasTmp)->(DbSkip())
	EndDo
	(cAliasTmp)->(DbCloseArea())

Return nSaldo

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณViewPreProณ Autor ณErike Yuri da Silva    ณ Data ณ04/02/2006ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณGeracao/Visualizaco do pr้-processamento da apuracao do inveณฑฑ
ฑฑณ          ณntario CMP.                                              ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณEPCP002                                                     ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ViewPreProc()

	Local nI        := 0
	Local nJ        := 0
	Local nOpcA		:= 0
	Local aPages	:= { "Plan01","Plan02"}
	Local aTitulo	:= { "Apuracao", "Pre-Visualizacao de Ajustes" }
	Local aButtons	:= {{"VERNOTA",{|| EPCP002Leg() },"Legenda" }}
	Local aLegenda	:= {	LoadBitmap( GetResources(), 'BR_AMARELO' ), ; //REQUISICAO
							LoadBitmap( GetResources(), 'BR_LARANJA' ), ; //DEVOLUCAO
							LoadBitmap( GetResources(), 'BR_PRETO'	),;	   //Itens com saldo Insuficiente
							LoadBitmap( GetResources(), 'BR_VERMELHO' ),; //Divergencia entre Estoque e Endereco
							LoadBitmap( GetResources(), 'BR_CINZA' ),;     //Item sam saldo nas Ops         
							LoadBitmap( GetResources(), 'BR_VERDE' ),;     //Diferenca Inventario Nula  																			
							LoadBitmap( GetResources(), 'BR_AZUL' ),}    //Ajuste Irrelevante
	
	Local aSizeAut	:= MsAdvSize(.T.,.F.) 
	Local aCoord	:= FWGetDialogSize(oMainWnd) /* Utilizado para pegar as coordenadas da tela do Protheus para montar a tela de interface */
	Local _oButExit :=	Nil 	
	Local _oButCalc	:=	Nil	    
	Local _oButMarc	:=	Nil	 //Objeto Botao Marca
	Local _oButDmrc	:=	Nil	 //Objeto Botao Desmarca
	Local _oButInve	:=	Nil	 //Objeto Botao Inverte selecao  
	Local cLegend   := ""
	Local nQtdInv   := 0
	Local nQtdSB2   := 0
	Local cSB1Descri:= ""
	
	Private lMark     := .T.
	Private lFirst    := .T.
	Private nDif      := 0
	Private nTot      := 0
	Private nTotRat   := 0
	Private nTotPerc  := 0   
	Private oTotRat   := Nil
	Private oTotPerc  := Nil  
	
	Private oDlg      := Nil
	Private oLbx1     := Nil
	Private oLbx2     := Nil
	Private oOk       := LoadBitmap( GetResources(), "LBOK" ) //Imagem "Marcado"
	Private oNo       := LoadBitmap( GetResources(), "LBNO" ) //Imagem "Desmarcado"
	
	//Cria arquivo para apuracao
	If !CriaApur()
		Return nOpcA	
	EndIf
	
	// adiciona os campos do ListBox 1
	dbSelectArea("INV")
	dbSetOrder(1)
	dbGotop()
	
	aCampos1  := {}
	
	nI:=1
	While !INV->(EOF())
		
		cSB1Descri := ""
		SB1->(DbSetOrder(1))
		If SB1->( DbSeek( xFilial("SB1") + ALLTRIM(INV->COD) ) )
			cSB1Descri := SB1->B1_DESC
		EndIf
		
		Aadd(aCampos1, {"", INV->COD, cSB1Descri, INV->GRUPO, INV->ARMAZEM, INV->UM, INV->QUANT, INV->SLDMP8, ;
						INV->DIF, INV->LOCALIZ, INV->NUMSERI, INV->LOTECTL, INV->NUMLOTE, INV->SEGUM, ;
						INV->QTSEGUM, INV->SLDMP8SG, INV->TIPO, INV->CONTA, INV->USUARIO, INV->DTVALID, ;
	   	                INV->TM, INV->CF,{},INV->NUMINV,INV->LOG})
	   	
	   	// adiciona os campos do ListBox 2 
		dbSelectArea("APU") 
		dbSetOrder(1)
		dbSeek(INV->FILIAL+INV->COD+INV->ARMAZEM+INV->LOCALIZ)
	
		While !APU->(EOF()) .And. APU->(FILIAL+COD+ARMAZEM+LOCALIZ) == INV->(FILIAL+COD+ARMAZEM+LOCALIZ) 
			
			cSB1Descri := ""
			SB1->(DbSetOrder(1))
			If SB1->( DbSeek( xFilial("SB1") + ALLTRIM(APU->COD) ) )
				cSB1Descri := SB1->B1_DESC
			EndIf
		
			aCampos2 := {}
			aCampos2:= {lMark, APU->OP, APU->COD, cSB1Descri, APU->ARMAZEM,APU->LOCALIZ, APU->CC, ;
	 				     APU->QTDSD3, APU->QTDRAT, APU->PERC, APU->EMISSAO}
			
			If (INV->LOG == "SBF " .OR. INV->LOG == "SB8 " .Or. INV->LOG == "SB2E" .Or. INV->LOG == "B2D3")	    
		    	//If APU->QTDRAT > 0.001 
					Aadd(aCampos1[nI][23],aCampos2) 		  		 
	   				nTotRat  := nTotRat + APU->QTDRAT
	   				nTotPerc := nTotPerc + APU->PERC 
	   				nTot     := nTot + APU->QTDSD3
	   				nDif     := APU->DIF
				//Endif				
			Else
				Aadd(aCampos1[nI][23],aCampos2) 		  		 	
			Endif		
			APU->(dbSkip())   	               
		End
		nI++
	   	INV->(dbSkip())                
	End
	
	// Define Legenda
	For nI:=1 to Len(aCampos1)
		cTm     := aCampos1[nI][21]
		cLog    := aCampos1[nI][25]
		nQtdInv := aCampos1[nI][7]
		nQtdSB2 := aCampos1[nI][8]
		cLegend := ""
			
		If cLog $ "SB2 |SB2-|SBF0"
			cLegend := "3"
		ElseIf cLog == "B2BF" //.And. (nQtdInv > nQtdEst .Or. nQtdInv < nQtdEst)
			cLegend := "4"
		ElseIF cLog	$ "B2D3|S/OP" //.And. (nQtdInv > nQtdEst .Or. nQtdInv < nQtdEst)	 
			cLegend := "5"
		ElseIf nQtdInv == nQtdSB2
			cLegend := "6"
		ElseIF cLog == "IRRV"
			cLegend := "7"
		ElseIF nQtdInv > nQtdSB2 
			cLegend := "2"
		ElseIf nQtdInv < nQtdSB2
			cLegend := "1"				
		Endif	
	    
	    // Define a Legenda
	    aCampos1[nI][1] := cLegend
		
		// Grava linha padrao para inicializar o ListBox 2 quando o vetor for vazio.
		If Len(aCampos1[nI][23]) == 0  
			Aadd(aCampos1[nI][23],{.F.,"NAO HA OP",aCampos1[nI][2], "","","","",0,0,0})	
		Else
			If cLog == "B2D3" .And. cTm == "999" .And. TemOp(aCampos1[nI][23])	
				aCampos1[nI][25] := "SBF "
			Endif	
		Endif
	Next     
	
	DEFINE MSDIALOG oDlg TITLE "Rateio" FROM aCoord[1],aCoord[2] TO aCoord[3],aCoord[4] OF oMainWnd COLOR "W+/W" PIXEL
	
	oFolder:= TFolder():New(02,00,aTitulo,aPages,oDlg,,,, .F., .F.,700,230) //650,230
	//oFolder:align	:= CONTROL_ALIGN_ALLCLIENT
	oFolder:Refresh()
	
	@ 00,00 LISTBOX oLbx1 FIELDS HEADER ;
	   " ", "Produto", "Descri็ใo", "Grupo", "Armazem", "Unid.", "Qtd Invent.", "Qtd Estoque", "Diferenca", "Endereco", ;
	   "Num de Serie", "Lote", "Sub-Lote", "Segunda UM", "Inv.Seg.UM","Qtd.Est 2aUM", "Tipo", "C.Contabil",;
	   "Usuario", "Valid. Lote", "Tp Movimento", "Tipo RE/DE" ;    
	   SIZE 650,190 OF oFolder:aDialogs[1] PIXEL ON CHANGE MudaLin(oLbx1:nAt)
	   
	//Metodos da ListBox
	oLbx1:SetArray( aCampos1 )
	oLbx1:bLine := {|| {IF(aCampos1[oLbx1:nAt,1]== "3",aLegenda[3],;// Saldo SB2  
						 IF(aCampos1[oLbx1:nAt,1]== "4",aLegenda[4],;// Saldo B2BF 				 					 
						 IF(aCampos1[oLbx1:nAt,1]== "5",aLegenda[5],; //Saldo B2D3  					 					 
						 IF(aCampos1[oLbx1:nAt,1]== "6",aLegenda[6],;// Diferenca = 0	  					 		 
	 					 IF(aCampos1[oLbx1:nAt,1]== "7",aLegenda[7],;// Ajuste Irrelevante	 
						 IF(aCampos1[oLbx1:nAt,1]== "2",aLegenda[2],aLegenda[1])))))),; // Devolucao ou Requisicao
		                 	aCampos1[oLbx1:nAt,2 ],;
		                 	aCampos1[oLbx1:nAt,3 ],;
		                 	aCampos1[oLbx1:nAt,4 ],;
		                 	aCampos1[oLbx1:nAt,5 ],;
		                 	aCampos1[oLbx1:nAt,6 ],;
		                 	aCampos1[oLbx1:nAt,7 ],;
	          	         	aCampos1[oLbx1:nAt,8 ],;
		                 	aCampos1[oLbx1:nAt,9 ],;
		                 	aCampos1[oLbx1:nAt,10],;
						 	aCampos1[oLbx1:nAt,11],;	     	          
		     	         	aCampos1[oLbx1:nAt,12],;
		                 	aCampos1[oLbx1:nAt,13],;
		                 	aCampos1[oLbx1:nAt,14],;
		                 	aCampos1[oLbx1:nAt,15],;
		                 	aCampos1[oLbx1:nAt,16],;
		                 	aCampos1[oLbx1:nAt,17],;
	          	         	aCampos1[oLbx1:nAt,18],;
		                 	aCampos1[oLbx1:nAt,19],;
		                 	aCampos1[oLbx1:nAt,20],;                   
		                 	aCampos1[oLbx1:nAt,21],;
		                 	aCampos1[oLbx1:nAt,22]}}
	
	@ 00,00 LISTBOX oLbx2 FIELDS HEADER ;
	   " ", "OP", "Produto", "Descri็ใo", "Armazem", "Endereco", "Centro Custo", ;
	   "Base Calculo", "Qtd Ratear", "% Rateio" ;     				   
	     SIZE 650,190 OF oFolder:aDialogs[2] PIXEL ON dblClick(MarkLin(),oLbx2:Refresh())
	
	//Metodos da ListBox
	oLbx2:SetArray( aCampos1[1][23] )
	oLbx2:bLine := {|| {IF(aCampos1[1][23][oLbx2:nAt,1],oOk,oNo),;
		                   aCampos1[1][23][oLbx2:nAt,2 ],;
		                   aCampos1[1][23][oLbx2:nAt,3 ],;
		                   aCampos1[1][23][oLbx2:nAt,4 ],;
		                   aCampos1[1][23][oLbx2:nAt,5 ],;
		                   aCampos1[1][23][oLbx2:nAt,6 ],;
		                   aCampos1[1][23][oLbx2:nAt,7 ],;
	          	           aCampos1[1][23][oLbx2:nAt,8 ],;
		                   aCampos1[1][23][oLbx2:nAt,9 ],;
		                   aCampos1[1][23][oLbx2:nAt,10]}}
	
	//Botoes Folder 2
	@ 200,005 Button _oButMarc Prompt "&Marcar Todos"     Size 50,08 Pixel Action _Marca(1,oLbx1:nAt) Message "Marcar todos" Of oFolder:aDialogs[2]
	@ 200,055 Button _oButDmrc Prompt "&Desmarcar Todos"  Size 50,08 Pixel Action _Marca(2,oLbx1:nAt) Message "Desmarcar todos" Of oFolder:aDialogs[2]
	@ 200,105 Button _oButInve Prompt "Inverter sele็ใo"  Size 50,08 Pixel Action _Marca(3,oLbx1:nAt) Message "Inverte a sele็ใo atual" Of oFolder:aDialogs[2]
	
	//Gets com os totais
	@ 201,295 SAY "Total Vlr. Rateio: " SIZE 65,8 OF oFolder:aDialogs[2] PIXEL 
	@ 200,340 MSGET oTotRat Var nTotRat  PICTURE "@E 999999999999.9999" SIZE 50,03 PIXEL OF oFolder:aDialogs[2] When .F. // @history ticket 15796  - FWNM         - 10/08/2021 -  ERRO ROTINA GERA AJUSTE - Objeto: EPCP002
	//@ 200,340 MSGET oTotRat Var nTotRat  PICTURE "@E 999999999999.999" SIZE 50,03 PIXEL OF oFolder:aDialogs[2] When .F.
	@ 201,435 SAY "Total %: " SIZE 65,8 OF oFolder:aDialogs[2] PIXEL 
	@ 200,460 MSGET oTotPerc Var nTotPerc PICTURE "@E 999.99" SIZE 25,03 PIXEL OF oFolder:aDialogs[2] When .F.
	
	oLbx1:Refresh()
	oLbx2:Refresh()
	
	//Botoes Tela
	//@ 250,505 Button _oButCalc Prompt "&Calcular" Size 50,10 Pixel Action MudaLin(oLbx1:nAt) Message "Calcular" Of oDlg
	//@ 250,565 Button _oButExit Prompt "&Sair"  Size 50,10 Pixel Action oDlg:End() Message "Sair" Of oDlg
	
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||If(VldApur(),(nOpcA := 1,oDlg:End()),)},{||oDlg:End()},,aButtons)

Return nOpcA

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณCriaApur  ณ Autor ณErike Yuri da Silva    ณ Data ณ04/02/2006ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณCria arquivo de apuracao do inventario com os dados relacio-ณฑฑ
ฑฑณ          ณnados ao periodo informado.                                 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณEPCP002                                                     ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CriaApur()

	Local cAliasTmp	:= "SQLSD3"
	Local cQuery	:= ""
	Local nCount	:= 0
	Local nTotal	:= 0 
	Local aOpAux	:= {}
	Local aStru		:= {}                         
	Local lRastro	:= .F.
	Local lRastroS 	:= .F.
	Local lCLocal	:= .F.   
	Local cLog      := ""
	
	Local cEnd,cNumSeri,cLoteCtl,cNumLote
	Local aAreaZAM	:= ZAM->(GetArea("ZAM"))
	Local aAreaSDB	:= SDB->(GetArea("SDB"))
	Local aAreaSD5	:= SD5->(GetArea("SD5"))
	
	dbSelectArea("ZAM")
	cIndZAM := CriaTrab(NIL,.F.)                                  
	IndRegua("ZAM",cIndZAM,"ZAM->ZAM_FILIAL+ZAM->ZAM_COD+ZAM->ZAM_LOCAL+ZAM->ZAM_NUM+ZAM->ZAM_LOCALI+ZAM->ZAM_NUMSER+ZAM->ZAM_LOTECT+ZAM->ZAM_NUMLOT",,,"Selec.Registros")
	dbSelectArea("ZAM")
	DbSetOrder(RetIndex()+1) 
	
	If Select("APU") > 0
		APU->(DbCloseArea())
	EndIf                                                       
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Definicao do nome do arquivo: "APU"+Empresa+Id do Usuario    ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	cArqApu	:= CriaTrab(Nil,.F.) //REtArq(cDrvINV,"APU"+Substr(cNumEmp,1,2)+__cUserID,.t.)
	If MSFile(cArqApu,,cDrvINV)
		dbUseArea( .T.,cDrvINV, cArqApu, "APU", If(.F. .OR. .T., !.T., NIL), .F. )
		DbCloseArea()
		FErase(cArqApu)
		FErase(FileNoExt(cArqApu)+"1"+OrdBagExt())	
	EndIf
	
	aOp		:= {}
	
	DbSelectArea("SC2")
	DbSetOrder(1)
	
	//DbSelectArea("ZAM")
	//DbSetOrder(3)
	
	DbSelectArea("SDB")
	DbSetOrder(1)
	
	DbSelectArea("SD5")
	DbSetOrder(3)
	
	cQuery	:= "SELECT ZAM.ZAM_DOC,ZAM.ZAM_NUM,SD3.D3_FILIAL,SD3.D3_COD,SD3.D3_TIPO,SD3.D3_LOCAL,SD3.D3_LOCALIZ,SD3.D3_CC,SD3.D3_NUMSERI,SD3.D3_LOTECTL,SD3.D3_NUMLOTE,SD3.D3_NUMSEQ,SD3.D3_OP,SD3.D3_EMISSAO,ZAM.ZAM_DATA,ZAM.ZAM_DTATE"
	cQuery	+= " FROM "
	cQuery	+= RetSqlName("SD3")+" SD3,"
	cQuery	+= RetSqlName("ZAM")+" ZAM, "                       
	cQuery	+= RetSqlName("SC2")+" SC2 "
	cQuery	+= " WHERE SD3.D3_FILIAL='"+xFilial("SD3")+"' AND" 
	cQuery 	+= " SD3.D3_OP>='"+mv_par07+"' AND SD3.D3_OP<='"+mv_par08+"' AND"
	cQuery 	+= " SD3.D3_OP<>'' AND" 
	cQuery 	+= " SD3.D3_CC>='"+mv_par09+"' AND SD3.D3_CC<='"+mv_par10+"' AND"
	cQuery 	+= " SD3.D3_CC<>'' AND"
	cQuery 	+= " SD3.D3_CF<>'PR0' AND"
	cQuery 	+= " SD3.D3_FLAGINV='' AND "
	cQuery 	+= " SD3.D3_ESTORNO='' AND "
	cQuery 	+= " SD3.D3_TM > '499' AND "
	cQuery 	+= " SD3.D_E_L_E_T_<>'*' AND"  
	cQuery 	+= " ZAM.ZAM_FILIAL='"+xFilial("ZAM")+"' AND"
	cQuery  += " ZAM.ZAM_DATA >='"+DTOS(mv_par01)+"' AND ZAM.ZAM_DATA <='"+DTOS(mv_par02)+"' AND "
	cQuery	+= " ZAM.ZAM_DTATE ='"+DTOS(mv_par02)+"' AND"
	cQuery 	+= " ZAM.ZAM_COD>='"+mv_par03+"' AND ZAM.ZAM_COD<='"+mv_par04+"' AND"
	cQuery 	+= " ZAM.ZAM_DOC>='"+mv_par05+"' AND ZAM.ZAM_DOC<='"+mv_par06+"' AND"
	cQuery 	+= " ZAM.ZAM_STATUS<>'2' AND"
	cQuery 	+= " ZAM.ZAM_COD=SD3.D3_COD AND"
	cQuery 	+= " ZAM.ZAM_LOCAL=SD3.D3_LOCAL AND"
	cQuery	+= " SD3.D3_EMISSAO>=ZAM.ZAM_DATA  AND SD3.D3_EMISSAO<=ZAM.ZAM_DTATE AND" 
	cQuery 	+= " ZAM.D_E_L_E_T_<>'*' AND"
	cQuery 	+= " SC2.C2_FILIAL='"+xFilial("SC2")+"' AND"
	cQuery 	+= " SC2.C2_NUM + SC2.C2_ITEM + SC2.C2_SEQUEN + SC2.C2_GRUPO = SD3.D3_OP AND "
	//cQuery 	+= " SC2.C2_DATRF<>''  AND"
	
	cQuery 	+= " SC2.C2_PRODUTO<>ZAM.ZAM_COD AND"
	
	cQuery 	+= " SC2.D_E_L_E_T_<>'*' "
	
	cQuery 	+= " ORDER BY SD3.D3_EMISSAO "
	
	cQuery	:= ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.F.,.T.)
	dbGotop()
	While (cAliasTmp)->(!Eof())
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Faz distinct manual                                          ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู   
		If !Empty( AsCan(aOp,{|x|x[2] == (cAliasTmp)->D3_OP}))
			(cAliasTmp)->(dbSkip())
			Loop	
		EndIf
		
		lRastro  := Rastro((cAliasTmp)->D3_COD)
		lRastroS := Rastro((cAliasTmp)->D3_COD, 'S')
		lCLocal  := Localiza((cAliasTmp)->D3_COD)
		cEnd	 := (cAliasTmp)->D3_LOCALIZ
		cNumSeri := (cAliasTmp)->D3_NUMSERI
		cLoteCtl := (cAliasTmp)->D3_LOTECTL
		cNumLote := (cAliasTmp)->D3_NUMLOTE 
	
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Se o SD3 nao possuir as informacoes de endereco busco no SDB ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู   	
		If lCLocal .And. Empty(cEnd) .And. SDB->(DbSeek(xFilial("SDB")+(cAliasTmp)->(D3_COD+D3_LOCAL+D3_NUMSEQ)))
			cEnd 		:= SDB->DB_LOCALIZ
			cNumSeri	:= SDB->DB_NUMSERI
			cLoteCtl	:= SDB->DB_LOTECTL
			cNumLote	:= SDB->DB_NUMLOTE	 
		ElseIf !lCLocal .And. lRastro .And. Empty(cLoteCtl+cNumLote) .And. SD5->(DbSeek(xFilial("SD5")+(cAliasTmp)->(D3_NUMSEQ+D3_COD+D3_LOCAL)))	
			cLoteCtl	:= SD5->D5_LOTECTL
			cNumLote	:= SD5->D5_NUMLOTE
		EndIf  
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Verifica se foi digitado inventario com o rastro ou endereco ณ
		//ณ lidos na movimentacao.                                       ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู   
		
		If !(ZAM->(DbSeek(xFilial("ZAM")+(cAliasTmp)->(D3_COD+D3_LOCAL+ZAM_NUM)+cEnd+cNumSeri+cLoteCtl+cNumLote)) .And. ; //inclusใo do ZAM_DOC
			DTOS(ZAM->ZAM_DATA)>=(cAliasTmp)->ZAM_DATA .And. DTOS(ZAM->ZAM_DTATE) <= (cAliasTmp)->ZAM_DTATE)		
			(cAliasTmp)->(DbSkip())
			Loop
		EndIf   
		                                                   
		If SC2->(DbSeek(xFilial("SC2")+(cAliasTmp)->D3_OP))     
			AADD(aOp,{"OP"+StrZero(++nCount,4),(cAliasTmp)->D3_OP,(cAliasTmp)->D3_EMISSAO,NIL,(cAliasTmp)->D3_CC,(cAliasTmp)->D3_EMISSAO})
		EndIf
		(cAliasTmp)->(DbSkip())
	EndDo                        
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Restaura ambiente                                            ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู   
	(cAliasTmp)->(dbCloseArea())	
	ZAM->(RestArea(aAreaZAM))
	SDB->(RestArea(aAreaSDB))
	SD5->(RestArea(aAreaSD5))
	
	AADD(aStru ,{"FILIAL"	,"C", 2,0})  
	AADD(aStru ,{"OP"		,"C", TamSx3("D3_OP")[1]		,0})
	AADD(aStru ,{"COD"		,"C", TamSx3("D3_COD")[1]		,0})	
	AADD(aStru ,{"ARMAZEM"	,"C", TamSx3("D3_LOCAL")[1]		,0})
	AADD(aStru ,{"LOCALIZ"	,"C", TamSx3("D3_LOCALIZ")[1]	,0})
	AADD(aStru ,{"CC"	 	,"C", TamSx3("D3_CC")[1]    	,0})
	AADD(aStru ,{"QTDRAT"	,"N", TamSx3("D3_QUANT")[1],TamSx3("D3_QUANT")[2]})
	AADD(aStru ,{"TOTAL"	,"N", TamSx3("D3_QUANT")[1] ,TamSx3("D3_QUANT")[2]})
	AADD(aStru ,{"DIF"	  	,"N", TamSx3("D3_QUANT")[1]	,TamSx3("D3_QUANT")[2]}) 
	AADD(aStru ,{"QTDSD3"	,"N", TamSx3("D3_QUANT")[1] ,TamSx3("D3_QUANT")[2]})
	AADD(aStru ,{"PERC" 	,"N", 6 ,2})
	AADD(aStru ,{"EMISSAO" 	,"D", 8 ,0})
	
	DbCreate(cArqApu,aStru,__LocalDriver)
	dbUseArea( .T.,cDrvINV, cArqApu, "APU", If(.F. .OR. .T., !.T., NIL), .F. )
	IndRegua("APU",FileNoExt(cArqApu)+"1","FILIAL+COD+ARMAZEM+LOCALIZ",,,"Selecionando Registros...")
	dbClearIndex()
	dbSetIndex( FileNoExt(cArqApu)+"1"+OrdBagExt())
	
	DbSelectArea("INV")
	DbSetOrder(1)
	DbGotop()
	While INV->(!Eof())
	    
	    cLog := ""
	    //Verifica se existe divergencia entre SB2 e SBF
		If INV->LOG=="B2BF"
			// Chamado n. 051064 || OS 052377 || CONTROLADORIA || REINALDO_FRANCISCHINELLI || 8947 || RATEIO - FWNM - 13/08/2019
			msgAlert("As ordens de produ็ใo nใo serใo listadas pois existe diverg๊ncia entre SB2 e SBF! Verifique... " + INV->LOG + ", " + INV->COD  + ", " + INV->ARMAZEM + ", " + INV->LOCALIZ)
			//
			INV->(DbSkip())
			Loop
		EndIf
		
		//Verifica se o saldo inventariado eh maior que o saldo em estoque
		If Empty(INV->DIF)
			// Chamado n. 051064 || OS 052377 || CONTROLADORIA || REINALDO_FRANCISCHINELLI || 8947 || RATEIO - FWNM - 13/08/2019
			msgAlert("As ordens de produ็ใo nใo serใo listadas pois o saldo inventariado ้ maior que o saldo em estoque! Verifique... " + INV->LOG + ", " + INV->COD  + ", " + INV->ARMAZEM + ", " + INV->LOCALIZ)
			//
			INV->(DbSkip())
			Loop		
		EndIf
		
	    nTotal		:= 0        
		aOpAux		:= {}
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณFaz ajuste das quantidades fracionadas nao permitindo ณ 
		//ณa existencia de percentuais zerados                   ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		For nCount:=1 To Len(aOp)	
			Aadd(aOpAux,SldSD3OPDia(INV->COD,INV->ARMAZEM,MV_PAR01,INV->LOTECTL,INV->NUMLOTE,INV->LOCALIZ,INV->NUMSERI,aOp[nCount,2],aOp[nCount,5]))
			nTotal += aOpAux[nCount]	
		Next
		
		//Valdir 29-06 acrescentei INV->TM == '499' porque o nTotal ้ absoluto e quando o saldo do estoque ้ maior que a OP dava erro dizendo que nใo tinha saldo na OP.
		If INV->DIF >nTotal .And. INV->TM == '499' .And. (INV->LOG <> "B2BF" .And. INV->LOG <> "SB2 " .And. INV->LOG <> "SBF0" .And. INV->LOG <> "SB2-")
			RecLock("INV",.F.)
				INV->LOG := "B2D3"	
			MsUnlocK()
		EndIf
		
		For nCount:=1 To Len(aOp)
			
			// Nao carrega valores saldo SD3 = 0
			If aOpAux[nCount] <> 0 
				RecLock("APU",.T.)
					APU->FILIAL  := INV->FILIAL 
					APU->COD	 := INV->COD
					APU->ARMAZEM := INV->ARMAZEM
					APU->LOCALIZ := INV->LOCALIZ
					APU->OP		 := aOp[nCount,2]
					APU->CC		 := aOp[nCount,5]			      			
					APU->DIF	 := INV->DIF
					APU->TOTAL   := nTotal 
					APU->EMISSAO := STOD(aOp[nCount,6])			      			
	
			   		// Calcula o percentual a ser distribuidos nas Ops				                                   
					APU->QTDSD3		:= aOpAux[nCount]
				   	APU->PERC		:= NoRound((APU->QTDSD3*100)/nTotal,4)  // Ricardo Lima - 19/09/18 
			   		APU->QTDRAT	    := NoRound((APU->DIF*APU->PERC)/100,4)  
			   		
			   		//Faz o Arredondamento conforme regra do campo B1_TIPODEC
					APU->QTDRAT   := A250AvalQt(APU->QTDRAT,APU->COD)
				MsUnlock()
	
				// Caso existe alguma OP com D3_QUANT < 0.001, o ajuste e irrelevante
				If NoRound(((aOpAux[nCount]*100)/nTotal),2) < 0.00001
					cLog := "IRRV"
				Endif
					
				If cLog == "IRRV" .And. (INV->LOG <> "B2BF" .And. INV->LOG <> "SB2 " .And. INV->LOG <> "SBF0" .And. INV->LOG <> "SB2-")
					RecLock("INV",.F.)
						INV->LOG := cLog
					MsUnlock("INV")
				Endif 	
					
			Endif
		Next 
		INV->(DbSkip())
	EndDo	

Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณQtdInvZAM ณ Autor ณErike Yuri da Silva    ณ Data ณ04/02/2006ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณCalcula o saldo do produto inventariodo na tabela de digita-ณฑฑ
ฑฑณ          ณcao do inventario CMP.                                   ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณEPCP002                                                     ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑdaฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function QtdInvZAM(cCod,cLocal,cLocaliz,cNumSeri,cLoteCtl,cNumLote)

	Local cAliasSldZAM	:= "ZAMSLD"
	Local cQuery		:= ""
	Local aRetSld		:= {0,0}

	cQuery := "SELECT SUM(ZAM_QUANT) As TotQTD, SUM(ZAM_QTSEGU) As TotQTDSEG"
	cQuery += " FROM "
	cQuery += RetSqlName("ZAM")+" ZAM "
	cQuery += " WHERE ZAM.ZAM_FILIAL='"+xFilial("ZAM")+"' AND"
	cQuery += " ZAM.ZAM_DATA>='"+DTOS(mv_par01)+"' AND ZAM.ZAM_DTATE='"+DTOS(mv_par02)+"' AND"
	cQuery += " ZAM.ZAM_COD='"+cCod+"' AND ZAM.ZAM_LOCAL='"+cLocal+"' AND"
	cQuery += " ZAM.ZAM_LOCALI='"+cLocaliz+"' AND ZAM.ZAM_NUMSER='"+cNumSeri+"' AND"
	cQuery += " ZAM.ZAM_LOTECT='"+cLoteCtl+"' AND ZAM.ZAM_NUMLOT='"+cNumLote+"' AND"
	cQuery += " ZAM.ZAM_DOC>='"+mv_par05+"' AND ZAM.ZAM_DOC<='"+mv_par06+"' AND"
	cQuery += " ZAM.ZAM_STATUS<>'2' AND"
	cQuery += " ZAM.D_E_L_E_T_<>'*'"
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSldZAM,.F.,.T.)
	If (cAliasSldZAM)->(!Eof())
		aRetSld[1] := (cAliasSldZAM)->TotQTD
		aRetSld[2] := (cAliasSldZAM)->TotQTDSEG
	EndIf
	DbCloseArea()

Return aRetSld

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณEPCP002Legบ Autor ณ Erike Yuri da Silvaบ Data ณ  06/03/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Legenda.                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function EPCP002Leg()

	BrwLegenda("Legenda", "Tipos",{			{'BR_AMARELO'   ,"Requisi็ใo"}			                 ,; 
											{'BR_LARANJA'   ,"Devolu็ใo"}                            ,;
											{'BR_PRETO'    	,"Item com saldo Insuficiente"}          ,;
											{'BR_VERMELHO' 	,"Divergencia entre Estoque e Endereco"} ,;										
											{'BR_CINZA'     ,"Item sem saldo nas Ops"}               ,; 
											{'BR_VERDE'     ,"Diferenca Inventario Nula"}               ,; 
											{'BR_AZUL' 	    ,"Ajuste Irrelevante"} } )  																			
Return(.T.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณVldApur   บ Autor ณErike Yuri da Silva บ Data ณ  08/03/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Validacao da apuracao                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function VldApur()
	
	Local lRet := .T.

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณRetMaxDateZAMณ Autor ณ Erike Yuri da Silva   ณ Data ณ04/02/06ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Retorna a maior data de inventario para o produto conforme ณฑฑ
ฑฑณ          ณ chave                                                      ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ EPCP002                                                    ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function RetMaxDateZAM(cAliasAtu,cCod,cLocal,cLocaliz,cNumSeri,cLotectl,cNumLote,dData)

	Local cAliasTmp	:= "ZAMSQL1"
	Local dDataRet	:= dDataBase
	
	dbSelectArea("ZAM")
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Totaliza registros de digitacao de inventario                          ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	
	cQuery		:= "SELECT  MAX(ZAM_DTATE) DATAATE "
	cQuery 		+= " FROM "
	cQuery 		+= RetSqlName("ZAM")+" ZAM "
	cQuery 		+= " WHERE ZAM.ZAM_FILIAL='"+xFilial("ZAM")+"' AND"
	cQuery 		+= " ZAM.ZAM_DATA='"+DTOS(dData)+"' AND"
	cQuery 		+= " ZAM.ZAM_COD='"+cCod+"' AND"
	cQuery 		+= " ZAM.ZAM_LOCAL='"+cLocal+"' AND"
	cQuery 		+= " ZAM.ZAM_LOCALI='"+cLocaliz+"' AND"
	cQuery 		+= " ZAM.ZAM_NUMSER='"+cNumSeri+"' AND"
	cQuery 		+= " ZAM.ZAM_LOTECT='"+cLoteCtl+"' AND"
	cQuery 		+= " ZAM.ZAM_NUMLOT='"+cNumLote+"' AND"
	cQuery 		+= " ZAM.ZAM_STATUS<>'2' AND"
	cQuery 		+= " ZAM.D_E_L_E_T_<>'*'"
	cQuery 		:= ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.F.,.T.)
	If !Eof() .And. !Empty((cAliasTmp)->DATAATE)
		dDataRet := STOD((cAliasTmp)->DATAATE )
	EndIf
	(cAliasTmp)->(DbCloseArea())
	DbSelectArea(cAliasAtu)

Return dDataRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณEPCP002PAcertoณ Autor ณ Eduardo Fernandes     ณ Data ณ12/08/06ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Acerto do inventario a partir de inclusao de movimentacoes   ณฑฑ
ฑฑณ          ณ internas de producao                                         ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ EPCP002                                                      ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function EPCP002PAcerto(dDtInvDe,dDtInvAte,cDocDe,cDocAte)

	Local i,j,K          
	Local nQtdRat	:= 0
	Local nQtdSD3	:= 0 
	Local cLog      := ""
	Local cDoc      := ""
	Local cProd     := ""
	Local cOp       := ""
	Local cLoc      := ""
	Local cEnd      := ""
	Local cNumSer   := ""
	Local cLotCtl   := ""
	Local cNumLot   := ""
	Local cNumInv   := ""
	Local dData     := Space(08)
	Local aMata		:= {}
	Local aErro     := {}
	Local nDif      := 0 
	Local aErroLog  := {}
	Local aErroTot  := {}
	Local cErro     := "" 
	Local cTm		:= "" 
	Local nSaldRat  := 0
	Local nSaldFim  := 0
	Local lRet      := .T.
	Local cTpSaldo  := SuperGetMv("MV_TPSALDO") // S - CalcEst ; Q - B2_QATU-B2_QACLASS-B2_RESERVA      //--Valdir 29-08-2007
	Local dDataSC2           
	
	Private	lMSHelpAuto	   := .T.
	Private lAutoErrNoFile := .T.
	
	SC2->(dbSetOrder(1))
	
	// -- Quantidade de passos do processo -- //
	ProcRegua(Len(aCampos1))				
	
	For i:= 1 To Len(aCampos1)
		
		IncProc("Incluindo movimentacao do produto:"+cProd+'...')
		cLog    := aCampos1[i][25]
		cProd   := aCampos1[i][2]
		cLoc    := aCampos1[i][5]
		cEnd    := aCampos1[i][10]
		cMunSer := aCampos1[i][11]
		cNumLot := aCampos1[i][12]
		cLotCtl := aCampos1[i][13] 
		nQtdSB2 := aCampos1[i][8] 
		nQtdInv := aCampos1[i][7]
		nDif    := aCampos1[i][9]
		cNumInv := aCampos1[i][24]
		cTm     := If(nQtdInv-nQtdSB2<0,"999","499")
		
		If cLog == "B2D3" .And. cTm == "999" .And. TemOp(aCampos1[i][23])
			cLog := "SBF "
		Endif
		
		If cTm == "999" .And. nQtdSB2 < nDif
			cLog := "SB2 "		
		Endif
		
		If nDif == 0 .And. (cLog <> "SB2-" .And. cLog <> "SBF0" .And. cLog <> "SB2 ")
			cLog := "NULO"
		Endif	
		
		If (cLog <> "B2BF" .And. cLog <> "B2D3" .And. cLog <> "S/OP" .And. cLog <> "SB2-" .And. cLog <> "SBF0" .And. cLog <> "NULO" .And. cLog <> "SB2 ")
	
			If cTm == "999" .And. cTpSaldo=="S"	//--Valdir 29-08-2007
				lRet := RefazVetOp(i)			//--Valdir 29-08-2007
		    Else                      			//--Valdir 29-08-2007
		    	lRet := .T.                   	//--Valdir 29-08-2007
			Endif                               //--Valdir 29-08-2007
	
			If lRet
				For j:= 1 To Len(aCampos1[i][23]) // array contendo o rateio do produto principal contido na primeira aba
				
					If aCampos1[i][23][j][1] // se estiver marcado o markbrowse do rateio entใo fa็a
						cOp     := aCampos1[i][23][j][2]
						dData   := aCampos1[i][23][j][11]
						nQtdRat := aCampos1[i][23][j][9] 
						nPerc   :=aCampos1[i][23][j][10] 
						cDoc    := "RATEIO" //Upper(NextNumero("SD3",2,"D3_DOC",.T.))
			                                 
						//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
						//ณ Alteracao realizada conforme orientacao da Inteligencia Protheus - 		ณ
						//ณ Chamado AAXISZ - Limpar o campo C2_DATRF e depois restaura-lo (19/10/06)ณ
						//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู			
						SC2->(DbSetOrder(1))
						If SC2->(DbSeek(xFilial("SC2")+cOp))
					   		dDataSC2 := SC2->C2_DATRF
					   		Reclock("SC2",.F.)
					   			SC2->C2_DATRF := Ctod("  /  /  ")
					   		SC2->( MsUnlock() )
						Endif  
	
		    
	
		    			aMata	:= {} 
		    			Aadd(aMata,{"D3_TM"     ,cTm					 ,".T."})
						Aadd(aMata,{"D3_COD"    ,cProd				     ,nil})
						Aadd(aMata,{"D3_QUANT"  ,nQtdRat                 ,nil})
						Aadd(aMata,{"D3_LOCAL"  ,cLoc			         ,nil})
						Aadd(aMata,{"D3_DOC"    ,cDoc				     ,".T."})
						Aadd(aMata,{"D3_LOCALIZ",cEnd				     ,".T."})				
						Aadd(aMata,{"D3_OP"		,cOp					 ,".T."})
						Aadd(aMata,{"D3_EMISSAO",dData 					 ,nil})
						Aadd(aMata,{"D3_FLAGINV","2"			         ,nil}) //flag do movimento de inventแrio
						Aadd(aMata,{"D3_CC"     ,SC2->C2_CC			     ,nil})
						Aadd(aMata,{"D3_NUMINV" ,cNumInv			     ,nil})				   
						If !Empty(AllTrim(aCampos1[i][12])+AllTrim(aCampos1[i][13]))
							Aadd(aMata,{"D3_LOTECTL",cLotCtl             ,nil})
							Aadd(aMata,{"D3_NUMLOTE",cNumLot             ,nil})
							Aadd(aMata,{"D3_DTVALID",aCampos1[i][20]	  ,".T."})
						EndIf
						If !Empty(AllTrim(aCampos1[i][11]))
							Aadd(aMata,{"D3_NUMSERI",cNumSer			  ,nil})
						Endif
											
						//Inicio da Transacao
						//Begin Transaction
	   	   				lMSErroAuto := .F.
	       				MsExecAuto({|x|Mata240(x)},aMata) // Movimentos Internos Simples
	   
	       				If lMSErroAuto  // Se der erro
		  						
								cLog := "ERRO"
		  						If IsBlind()
									Conout("Erro na gravacao da movimentacao")
								Else	
									aErroLog := GetAutoGRLog() 
		  							For k:=1 to Len(aErroLog)
		  								cErro := AllTrim(aErroLog[1])
		  								If "INVALIDO" $ UPPER(aErroLog[k])
		  									cErro += AllTrim(aErroLog[k])
		  									Aadd(aErro,{cNumInv,7,.T.,cOp,cErro,cProd,nQtdRat,nPerc})
		  								Endif	
									Next
									
									logZBE("ERRO MATA240 INV: " + AllTrim(cNumInv) + ", OP: " + cOP + ", PROD: " + cProd + ", ERRO: " + AllTrim(cErro))
									//DisarmTransaction()
								Endif	
		   				Else // naum deu erro 
		    					EvalTrigger()
								Commit
			  			        
					      	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
								//ณ Atualiza Totais do Inventario processado                  ณ
								//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
								nSaldRat += nQtdRat
								
								If cTm == "999"
									nSaldFim := nQtdSB2 - nSaldRat
								Else
									nSaldFim := nQtdSB2 + nSaldRat
								Endif
								
								U_TotalZAM(cNumInv,,nDif,nQtdSB2,nSaldFim)	 

								logZBE( "OK MATA240 INV: " + AllTrim(cNumInv) + ", OP: " + cOP + ", PROD: " + cProd + ", DIF: " + TRANSFORM(nDif, "@E 999,999.99") + "INI: " + TRANSFORM(nQtdSB2, "@E 999,999,999.99") + "FIM: " + TRANSFORM(nSaldFim, "@E 999,999,999.99") )
			  			        
	      						//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
								//ณ Alteracao realizada conforme orientacao da Inteligencia Protheus - 		ณ
								//ณ Chamado AAXISZ - Restaurar o campo C2_DATRF (19/10/06)					ณ
								//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู			
								SC2->(DbSetOrder(1))
								If SC2->(DbSeek(xFilial("SC2")+cOp))
						   			Reclock("SC2",.F.)
						   				SC2->C2_DATRF := dDataSC2
						   			MsUnlock()			
								Endif 			
	
					      	// Ajusta Flag da Op Original 
								DbSelectArea("SD3")
								DbSetOrder(1)
								DbSeek(xFilial("SD3")+cOp+cProd+cLoc)
								While !Eof() .And. D3_FILIAL+D3_OP+D3_COD+D3_LOCAL==xFilial("SD3")+cOp+cProd+cLoc
									RecLock("SD3",.F.)
									If Empty(D3_FLAGINV)
										D3_FLAGINV := "1" // flag a op origem do ajuste com 1
									EndIf
									MsUnLock()
									DbSkip()
								EndDo  	
							Endif
	   				//End Transaction           
					Endif
				Next j
		   Else
		   		// Grava log de saldo insuficiente ao redistribuir saldo dia a dia
		   		cLog := 'SB2-'
		   Endif
		Endif                     
			
		//Carrega Vetor com Historicos
		Do Case
			Case cLog == "SBF " .Or. cLog == "SB8 " .Or. cLog == "SB2E" .Or. cLog == "IRRV"
				Aadd(aErro,{cNumInv,0}) // Processamento OK
				logZBE( "LOG MATA240 INV: " + AllTrim(cNumInv) + ", OP: " + cOP + ", PROD: " + cProd + ", CLOG: Processamento OK" )
			Case cLog == "B2D3"
				Aadd(aErro,{cNumInv,1}) // Sem OP no periodo
				logZBE( "LOG MATA240 INV: " + AllTrim(cNumInv) + ", OP: " + cOP + ", PROD: " + cProd + ", CLOG: Sem OP no periodo" )
			Case cLog == "SLD"
				Aadd(aErro,{cNumInv,2}) // Saldo SB2 Bloqueado
				logZBE( "LOG MATA240 INV: " + AllTrim(cNumInv) + ", OP: " + cOP + ", PROD: " + cProd + ", CLOG: Saldo SB2 Bloqueado" )
			Case cLog == "SB2 "
				Aadd(aErro,{cNumInv,3}) // Saldo Insuficiente	
				logZBE( "LOG MATA240 INV: " + AllTrim(cNumInv) + ", OP: " + cOP + ", PROD: " + cProd + ", CLOG: Saldo Insuficiente" )
			Case cLog == "B2BF"
				Aadd(aErro,{cNumInv,4}) // Divergencia SB2 X SBF 
				logZBE( "LOG MATA240 INV: " + AllTrim(cNumInv) + ", OP: " + cOP + ", PROD: " + cProd + ", CLOG: Divergencia SB2 X SBF" )
			Case cLog == "S/OP"
				Aadd(aErro,{cNumInv,6}) // Qtd OPs Insuficiente	
				logZBE( "LOG MATA240 INV: " + AllTrim(cNumInv) + ", OP: " + cOP + ", PROD: " + cProd + ", CLOG: Qtd OPs Insuficiente" )
			Case cLog == "NULO"
				Aadd(aErro,{cNumInv,8}) // Inventario Nulo	
				logZBE( "LOG MATA240 INV: " + AllTrim(cNumInv) + ", OP: " + cOP + ", PROD: " + cProd + ", CLOG: Inventario Nulo" )
			Case cLog == "SBF0"
				Aadd(aErro,{cNumInv,9}) // Sem Saldo no Endereco
				logZBE( "LOG MATA240 INV: " + AllTrim(cNumInv) + ", OP: " + cOP + ", PROD: " + cProd + ", CLOG: Sem Saldo no Endereco" )
			Case cLog == "SB2-"
				Aadd(aErro,{cNumInv,10})// Saldo Atual Negativo			
				logZBE( "LOG MATA240 INV: " + AllTrim(cNumInv) + ", OP: " + cOP + ", PROD: " + cProd + ", CLOG: Saldo Atual Negativo" )
			OTHERWISE
				logZBE( "LOG MATA240 INV: " + AllTrim(cNumInv) + ", OP: " + cOP + ", PROD: " + cProd + ", CLOG: STATUS DESCONHECIDO" )
		End Case

		// Grava o historico do processamento
		For K:= 1 to Len(aErro)
			If aErro[k][2] <> 7
				U_EPCP004(aErro[K][1],aErro[K][2])	
				Aadd(aErroTot,{aErro[K][1],aErro[K][2],.T.,"","",cProd})
			Else
				U_EPCP004(aErro[K][1],aErro[K][2],.T.,aErro[K][4],aErro[K][5],aErro[K][7],aErro[K][8])//Historico do ExecAuto
				Aadd(aErroTot,{aErro[K][1],aErro[K][2],.T.,aErro[K][4],aErro[K][5],aErro[K][6]})				
			Endif
		Next
		
		aErro :={}
	
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Atualiza status de processamento                          ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		U_StatusZAM(cLog,cNumInv) 
		nSaldRat := 0	 		
	Next i
	
	If Len(aErroTot)> 0	
		MostraLog(aErroTot)	
	Endif	

Return 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ_Marca    บAutor  ณEduardo Fernandes      บ Data ณ  07/08/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณRotina de marcacao ou nao do primeiro elemento do array recebi-บฑฑ
ฑฑบ          ณdo                                                             บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณnOp  - Numero da opcao(1-Marca,2-Desmarca,3-Inverte)           บฑฑ
ฑฑบ          ณnPos     - Posicao da Linha ListBox 1                          บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณNao se aplica                                                  บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAplicacao ณRotina chamada pelos botoes da tela de selecao das OPS         บฑฑ
ฑฑฬออออออออออฯอออัออออออออัออออออัอออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista      ณ Data   ณBops  ณManutencao Efetuada                        บฑฑ
ฑฑฬออออออออออออออุออออออออุออออออุอออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ              ณ        ณ      ณ                                           บฑฑ
ฑฑฬออออออออออัอออฯออออออออฯออออออฯอออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ14612 - CMP		                                         บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function _Marca(nOp,nPos)

	Local lMarca,i
	
	If nOp == 1 		//Marca todos
		lMarca	:=	.T.
	ElseIf nOp == 2		//Desmarca Todos
		lMarca	:=	.F.
	Endif
	
	If aCampos1[oLbx1:nAt][23][oLbx2:nAt][2] == "NAO HA OP"
		lMarca	:=	.F.
	Else
		If lMarca != NIL
			For i := 1 To Len(aCampos1[nPos][23])				
				aCampos1[nPos][23][i][1] := lMarca
			Next i
		Else	//Inverte Selecao
			For i := 1 To Len(aCampos1[nPos][23])
				aCampos1[nPos][23][i][1] := !aCampos1[nPos][23][i][1]
			Next i
		EndIf
	Endif	
	
	MudaLin(nPos)
	oLbx2:Refresh()	//Atualiza Listbox

Return Nil


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMudaLin   บAutor  ณEduardo Fernandes      บ Data ณ  10/08/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณAtualizacao do segundo listbox relacionado ao primeiro         บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณnPos     - Posicao da Linha ListBox 1                          บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณNao se aplica                                                  บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista      ณ Data   ณBops  ณManutencao Efetuada                        บฑฑ
ฑฑฬออออออออออออออุออออออออุออออออุอออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ              ณ        ณ      ณ                                           บฑฑ
ฑฑฬออออออออออัอออฯออออออออฯออออออฯอออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ14612 - CMP		                                         บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/                                                                                              

Static Function MudaLin(nPos)

	Local nX,cTm
	Local lOk      := .F.
	Local cProd    := aCampos1[nPos][2]
	Local cDescr   := Posicione("SB1",1,xFilial("SB1")+cProd,"B1_DESC")
	Local cNum     := aCampos1[nPos][24]
	Local nVlrMMp  := 0 // Ricardo Lima - 19/09/18
	
	nDif      := 0
	nTot      := 0
	nTotRat   := 0
	nTotPerc  := 0 
	
	nDif   := aCampos1[nPos][9]
	cTm    := aCampos1[nPos][21]
	
	// Remonta Base Calculo conforme OPs selecionadas
	For nX := 1 to Len(aCampos1[nPos][23])
		If aCampos1[nPos][23][nX][1]
			nTot := nTot + aCampos1[nPos][23][nX][8]
		EndIf
	Next nX
	
	// Se for requisicao verifica apenas de tem alguma op selecionada
	If cTm == "999"
		For nX := 1 to Len(aCampos1[nPos][23])
			If aCampos1[nPos][23][nX][1]
		    	lOk := .T.
		    	Exit
		    Endif
		Next nX
	Endif                                         
	
	If nTot < nDif .And. (aCampos1[nPos][25] <> "B2BF" .And. aCampos1[nPos][25] <> "SB2 " .And.;
	   aCampos1[nPos][25] <> "SB2-" .And. aCampos1[nPos][25] <> "SBF0") .And. !lOk 
		// Mensagem quando nao tem nenhuma OP selecionada
		If !IsInCallStack("RefazVetOP")
			If !lFirst
				MsgAlert("Sem Ops/Qtd Insuficiente Selecionadas para o Produto: "+ AllTrim(cProd) + " - " + cDescr)
			Endif
			lFirst := .F.
		Endif
			
		If aCampos1[nPos][25]<> "B2D3"		
			aCampos1[nPos][25]:= "S/OP"		
		Endif	
	Else
		//Mensagem de Ajuste Irrelevante
		If !IsInCallStack("RefazVetOP")
			If aCampos1[nPos][24]== "IRRV" .And. !lFirst
				MsgAlert("O Ajuste: " + cNum + " ้ Irrelevante. Produto: " + AllTrim(cProd) + " - " + cDescr)
			Endif
			lFirst := .F.
		Endif
		
		//Ajusta o log para gravacao dos movimentos
		If aCampos1[nPos][25]== "S/OP"		
			aCampos1[nPos][25]:= "SBF "		
		Endif	
		
		For nX := 1 To Len(aCampos1[nPos][23])
			If aCampos1[nPos][23][nX][1]
				// Calcula o percentual a ser distribuidos nas Ops
				aCampos1[nPos][23][nX][10]	:= NoRound((aCampos1[nPos][23][nX][8]*100)/nTot,4)   // Ricardo Lima - 19/09/18
				aCampos1[nPos][23][nX][9]	:= NoRound((nDif*aCampos1[nPos][23][nX][10])/100,4)   
				
				//Faz o Arredondamento conforme regra do campo B1_TIPODEC
				aCampos1[nPos][23][nX][9]  := A250AvalQt(aCampos1[nPos][23][nX][9],cProd)
				
				If aCampos1[nPos][23][nX][9] < 0.0001  // Ricardo Lima - 19/09/18
					aCampos1[nPos][23][nX][1]  := .F.
					aCampos1[nPos][23][nX][9]	:= 0
					aCampos1[nPos][23][nX][10]	:= 0 				
				Endif
			Else
				aCampos1[nPos][23][nX][9]	:= 0
				aCampos1[nPos][23][nX][10]	:= 0
			Endif
			nTotRat  := nTotRat + aCampos1[nPos][23][nX][9]
			nTotPerc := nTotPerc + aCampos1[nPos][23][nX][10]		
		Next nX
		
		//Se a somatoria do percentual distribuidos nas Ops for menor que 100,
		//adiciona a diferenca na primeira OP encontrada com % maior que 0.001.
		If (100.00 - nTotPerc) > 0  
			// Ricardo Lima - 19/09/18
			For nX:=1 to Len(aCampos1[nPos][23])
				if aCampos1[nPos][23][nX][8] > nVlrMMp 
					nVlrMMp := aCampos1[nPos][23][nX][8]
				Endif
			Next
			// Ricardo Lima - 19/09/18
			For nX:=1 to Len(aCampos1[nPos][23])
				If aCampos1[nPos][23][nX][1]
					If aCampos1[nPos][23][nX][8] = nVlrMMp // > 0.000001  // Ricardo Lima - 19/09/18
						aCampos1[nPos][23][nX][10] += 100.0000 - nTotPerc  // Ricardo Lima - 19/09/18
						aCampos1[nPos][23][nX][9] += nDif - nTotRat
						nTotPerc := nTotPerc + (100.0000 - nTotPerc) // Ricardo Lima - 19/09/18
						nTotRat  := nTotRat + (nDif - nTotRat)
						nX:= Len(aCampos1[nPos][23])
					EndIf
				Endif	
			Next
		EndIf
	Endif
	
	If !IsInCallStack("RefazVetOP")
		oLbx2:SetArray( aCampos1[nPos][23] )
		oLbx2:bLine := {|| {IF(aCampos1[nPos][23][oLbx2:nAt,1],oOk,oNo),;
	                        aCampos1[nPos][23][oLbx2:nAt,2 ],;
		                    aCampos1[nPos][23][oLbx2:nAt,3 ],;
		                    aCampos1[nPos][23][oLbx2:nAt,4 ],;
		                    aCampos1[nPos][23][oLbx2:nAt,5 ],;
		                    aCampos1[nPos][23][oLbx2:nAt,6 ],;
		                    aCampos1[nPos][23][oLbx2:nAt,7 ],;
		                    aCampos1[nPos][23][oLbx2:nAt,8 ],;
	          	            aCampos1[nPos][23][oLbx2:nAt,9 ],;
		                    aCampos1[nPos][23][oLbx2:nAt,10 ]}}
	
		oLbx2:Refresh()
		oTotRat:Refresh()
		oTotPerc:Refresh()  
	Endif	
	                    
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMarkLin   บAutor  ณEduardo Fernandes      บ Data ณ  16/08/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณAtualizacao do segundo listbox						         บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ											                     บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณNao se aplica                                                  บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista      ณ Data   ณBops  ณManutencao Efetuada                        บฑฑ
ฑฑฬออออออออออออออุออออออออุออออออุอออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ              ณ        ณ      ณ                                           บฑฑ
ฑฑฬออออออออออัอออฯออออออออฯออออออฯอออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ14612 - CMP		                                         บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/                                                                                              

Static Function MarkLin()

	Local lMarca
	
	If aCampos1[oLbx1:nAt][23][oLbx2:nAt][2] <> "NAO HA OP"
		aCampos1[oLbx1:nAt][23][oLbx2:nAt][1] := !aCampos1[oLbx1:nAt][23][oLbx2:nAt][1]	
	Else
		lMarca	:=	.F.
	Endif
	
	MudaLin(oLbx1:nAt)
	oLbx2:Refresh()
	                    
Return lMarca        

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMostraLOG บAutor  ณEduardo Fernandes      บ Data ณ  24/08/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณGeracao da Tela de Log apos processamento 			         บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ											                     บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณNao se aplica                                                  บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista      ณ Data   ณBops  ณManutencao Efetuada                        บฑฑ
ฑฑฬออออออออออออออุออออออออุออออออุอออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ              ณ        ณ      ณ                                           บฑฑ
ฑฑฬออออออออออัอออฯออออออออฯออออออฯอออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณEPCP002PAcerto		                                         บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/                                                                                              

Static Function MostraLog(aErro)

	Local oDlg
	Local oFont 
	Local cCabec    := "INVENTARIO    |ERRO"
	Local nI 		:= 0
	Local cMemo     := ""
	Local cErro     := ""
	Local cOp       := ""
	Local cCod      := ""
	Local lTela     := .F.
	
	DEFINE FONT oFont NAME "Courier New" SIZE 5,0   //6,15
	
	For nI:=1 To Len(aErro)
		If aErro[nI][2] <> 0
			lTela := .T.
			cCod := aErro[nI][6]
			Do Case
				Case aErro[nI][2] == 1
					// Chamado n. 048140 - FWNM - 27/03/2019
					cErro:= "Valor rateio superior consumo OP "
					// cErro:= "Sem OP no periodo "
				Case aErro[nI][2] == 2
					cErro:= "Saldo Bloqueado "
				Case aErro[nI][2] == 3
					cErro:= "Saldo Insuficiente "
				Case aErro[nI][2] == 4
					cErro:= "Divergencia SB2 X SBF "					
				Case aErro[nI][2] == 6		
					cErro:= "Qtd OPs Insuficiente "   
				Case aErro[nI][2] == 7		
					cErro:= aErro[nI][5]
					cOp  := aErro[nI][4] 
				Case aErro[nI][2] == 8		
					cErro:= "Inventario Nulo "
				Case aErro[nI][2] == 9		
					cErro:= "Sem Saldo no Endereco "
				Case aErro[nI][2] == 10		
					cErro:= "Saldo Atual Negativo "				  						
			EndCase
	
			cMemo += cCabec + CRLF
			cMemo += aErro[nI][1]+SPACE(12)+cErro + CRLF
			cMemo += cCod+SPACE(02)+cOp + CRLF + CRLF								
		Endif
		
		cCod := ""
		cOp  := ""
	Next
	
	If lTela
		DEFINE MSDIALOG oDlg TITLE "Erros Processamento" From 3,0 to 340,417 PIXEL
		
		@ 5,5 GET oMemo  VAR cMemo MEMO SIZE 200,145 OF oDlg PIXEL 
		oMemo:bRClicked := {||AllwaysTrue()}
		oMemo:oFont:=oFont
		
		DEFINE SBUTTON  FROM 153,175 TYPE 1 ACTION oDlg:End() ENABLE OF oDlg PIXEL //Apaga
		
		ACTIVATE MSDIALOG oDlg CENTER
	Endif
	
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTemOp     บAutor  ณEduardo Fernandes      บ Data ณ  24/08/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณPesquisa se existe o OP para o vetor aCampos1     	         บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณaVet    - Vetor onde sera efetuado a busca                     บฑฑ
ฑฑบ			 ณ													             บฑฑ
ฑฑบ			 ณ														         บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณNao se aplica                                                  บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista      ณ Data   ณBops  ณManutencao Efetuada                        บฑฑ
ฑฑฬออออออออออออออุออออออออุออออออุอออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ              ณ        ณ      ณ                                           บฑฑ
ฑฑฬออออออออออัอออฯออออออออฯออออออฯอออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ14612 - CMP		                                         บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/                                                                                              

Static Function TemOP(aVet)

	Local lRet   := .F. 
	Local nAchou := 0
	
	nAchou:=Ascan(aVet,{|x| x[2] <> "NAO HA OP"})
	
	If nAchou > 0
		lRet := .T.
	EndIf

Return lRet         

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณRefazVetOP    ณ Autor ณ Eduardo Fernandes     ณ Data ณ27/04/07ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณCalcula saldo do estoque dia a dia e remonta saldo do vetor deณฑฑ
ฑฑณ          ณops, recalculando qtd a ratear p/ os dias que o saldo atenda aณฑฑ
ฑฑณ          ณdemanda das ordens de producao.							  		    ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ EPCP002                                                      ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function RefazVetOP(nPos)

	Local nA,nB
	Local aSaldo     := {}
	Local aSaldoSBF  := {} 
	Local aSaldoDia  := {}
	Local nSaldo     := 0
	Local nSalAux    := 0
	Local nSalOld    := 0
	Local nSldTrans  := 0  
	Local dDataOp    := Ctod("")
	Local nQtdOp     := 0 
	Local nAchou     := 0
	Local lRet       := .T.
	
	Local cProd      := aCampos1[nPos][2]
	Local cLoc       := aCampos1[nPos][5]
	Local cEnd       := aCampos1[nPos][10]
	Local cNumSer    := aCampos1[nPos][11]
	Local cNumLot    := aCampos1[nPos][12]
	Local cLotCtl    := aCampos1[nPos][13] 
	Local nVez       := MV_PAR02 - MV_PAR01
	
	// Calcula saldo em estoque dia a dia
	For nA := 1 To nVez	
		dDataOp := IIF(nA == 1, MV_PAR01, dDataOp + 1)
		
		If Rastro(cProd) .Or. Localiza(cProd)
			aSaldoSBF	:= CalcEstL(cProd,cLoc,dDataOp+1,cLotCtl,cNumLot,cEnd,cNumSer)
		Else
			aSaldo := CalcEst(cProd,cLoc,dDataOp+1)
		Endif
		
		nSaldo    := IIF(Localiza(cProd),aSaldoSBF[1],aSaldo[1])
		nSalAux   := nSaldo - nSalOld
		
	   // Avalia a Qtd das Ops selecionadas para o dia
	   nQtdOp := 0
	   For nB := 1 To Len(aCampos1[nPos][23])
	   	If aCampos1[nPos][23][nB][1]
	   		IF aCampos1[nPos][23][nB][10] == dDataOp
	    			nQtdOp += aCampos1[nPos][23][nB][8]
	    		Endif 
	    	Endif
	   Next nB
	    
	   // Grava o saldo em OPs do dia anterior
		nSalOld   += nQtdOp
		
	   If nQtdOp > nSalAux .And. nQtdOp > 0
	   	nSldTrans := nQtdOp   
	   Else
	    	Loop
	   Endif
	    
	   //Adiciona do vetor de saldo dia a dia
	   AAdd(aSaldoDia, {dDataOp, nSalAux, nQtdOp, nSldTrans}) 
	   
	   If nSalAux < 0
	   	nA := nVez + 1
	   Endif
	   
	Next nA
	
	// Verifica se existe saldo a Redistribuir
	For nA:=1 To Len(aSaldoDia)
		dDataOp := aSaldoDia[nA][1]
		For nB:=1 To Len(aCampos1[nPos][23])   		
	   	If aCampos1[nPos][22][nB][1]
	         // Desmarca as Ops com data em que o saldo nao atende
	   		If aCampos1[nPos][23][nB][10] == dDataOp                
	         	aCampos1[nPos][23][nB][1] := .F.	
	         Endif
	      Endif
	   Next nB	
	Next nA
	
	If Len(aSaldoDia) > 0
		// Chama a rotina para redistribuir a diferenca inventario nas ops dos dias validos
		MudaLin(nPos)
	   
		// Faz recursividade ate o vetor aSaldoDia ficar vazio
		RefazVetOP(nPos)
	Endif	
	
	nAchou := 0
	nAchou:=Ascan(aCampos1[nPos][23],{|x| x[1] == .T.})
	
	If nAchou = 0
		lRet := .F.
	EndIf
	
	Return lRet 

// MenuDef()    
Static Function MenuDef()

   Local aRotina := { {"Processar","EPCP002" ,0 ,1 ,19}} 

Return(aRotina)

/*/{Protheus.doc} Static Function LOGZBE
	Gera log ZBE
	@type  Static Function
	@author Everson
	@since 24/05/2019
	@version 01
/*/
Static Function logZBE(cMensagem)

	RecLock("ZBE", .T.)
		Replace ZBE_FILIAL 	   	With FWxFilial("ZBE")
		Replace ZBE_DATA 	   	With msDate()
		Replace ZBE_HORA 	   	With Time()
		Replace ZBE_USUARI	    With Upper(Alltrim(cUserName))
		Replace ZBE_LOG	        With cMensagem
		Replace ZBE_MODULO	    With "SIGAEST"
		Replace ZBE_ROTINA	    With "EPCP002" 
	ZBE->( msUnlock() )

Return
