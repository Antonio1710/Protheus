#INCLUDE "rwmake.ch"
#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFAT002    บAutor  ณMicrosiga           บ Data ณ  02/05/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Efetua transfer๊ncias em lote                              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function FAT002()

	LOCAL oSay,oSay2,oSay3
	LOCAL oBtn1,oBtn2,oBtn3
	LOCAL oDlg            
	Local cPerg:="FAT002" 
		
	Private cCadastro:="Processamento Transfer๊ncias Integrado/Incubatorio"
	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Efetua transfer๊ncias em lote')

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณAcerta dicionแrio de perguntas       ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

	AjustaSX1(cPerg)         
	
	Pergunte(cPerg,.T.)
		
	ProcLogIni( {},"FAT002")
	
	DEFINE MSDIALOG oDlg FROM  96,9 TO 320,612 TITLE OemToAnsi(cCadastro) PIXEL
	@ 11,6 TO 90,287 LABEL "" OF oDlg  PIXEL
	@ 16, 15 SAY OemToAnsi("Este programa efetua as trasnfer๊ncias relativas aos processos de remessa para integrado/incubatorio") SIZE 268, 8 OF oDlg PIXEL			   									
			
	DEFINE SBUTTON FROM 93, 163 TYPE 15 ACTION ProcLogView() ENABLE OF oDlg
	DEFINE SBUTTON FROM 93, 193 TYPE 5  ACTION Pergunte(cPerg,.T.) ENABLE OF oDlg
	DEFINE SBUTTON FROM 93, 223 TYPE 1  ACTION If(.T.,(Processa({|lEnd| E001Proces()},OemToAnsi("Processamento Trasnferencias"),OemToAnsi("Efetuando trasnferสncias..."),.F.),oDlg:End()),) ENABLE OF oDlg
	DEFINE SBUTTON FROM 93, 253 TYPE 2  ACTION oDlg:End() ENABLE OF oDlg
	ACTIVATE MSDIALOG oDlg CENTERED    
	
Return



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณE001ProcesบAutor  ณMicrosiga           บ Data ณ  02/05/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function E001Proces()


	Local cQuery 		:= ""
	Local cWhere		:= ""
	Local cAliasSD2	    := CriaTrab(NIL,.F.)	
	Local cAlDes		:= ""
	Local _dData		:= dDataBase	
	Local dDtDigit 		:= _dData   
	Local cTes			:= SuperGetMV("FS_TESREMI" ,,"702|705|735")  // KF 30/11/15
	Local cMens			:=  "Log de Processsamento Transfer๊nias Int/Inc" + CRLF + CRLF
	Private aItens      := {}      
	Private lMsErroAuto := .F.
	
	cQuery := "SELECT D2_FILIAL,D2_EMISSAO, D2_COD,D2_LOCAL,D2_QUANT as QTDE, SD2.R_E_C_N_O_ AS REC "
	cQuery += "FROM "+RetSqlName("SD2")+" SD2 "
	cQuery += "WHERE D2_FILIAL = '" + xFilial("SD2") + "' AND SD2.D2_TES IN ('702','705','735') AND "	
	cQuery += "SD2.D2_EMISSAO BETWEEN '" + DTOS(MV_PAR01) + "' AND '" +  DTOS(MV_PAR02) + "' AND SD2.D2_COD BETWEEN '" + MV_PAR03 + "' AND '" +	MV_PAR04 + "' AND "
	cQuery += "SD2.D2_DOC BETWEEN '" + MV_PAR05 + "' AND '" +  MV_PAR06 + "' AND "
	cQuery += "NOT EXISTS (SELECT 1 FROM " + RetSqlName("SD3") + " SD3 WHERE SD2.D2_EMISSAO=SD3.D3_EMISSAO AND SD3.D3_FILIAL=SD2.D2_FILIAL AND SD2.R_E_C_N_O_ = SD3.D3_XRECSD2 AND SD3.D3_XRECSD2<>'' AND SD3.D_E_L_E_T_=' ' ) "
	cQuery += "AND SD2.D2_EMISSAO>='20151201' "           

	cQuery := ChangeQuery(cQuery)		
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSD2,.T.,.F.)

	ProcLogIni( {},"FAT001")
	ProcLogAtu("INICIO")

	DbSelectArea(cAliasSD2)
	Dbgotop()
	
	While (cAliasSD2)->(!EOF())
		
		aItens:={}
		
		DDATABASE:=STOD((cAliasSD2)->D2_EMISSAO)
		
		//posiciona no SD2
		DbSelectArea("SD2")
		Dbgoto((cAliasSD2)->REC) 

		//posiciona no SF2
		SF2->(DbSetOrder(1))
		SF2->(DbSeek(xFilial("SF2")+ SD2->(D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA)))
		
        //posiciona no produto
		SB1->(DbSetOrder(1))
		SB1->(DbSeek( xFilial("SB1") + (cAliasSD2)->D2_COD ))

		//define o almoxarifado
		If SF2->F2_TIPO == "N"
			SA1->(dbSetOrder(1))
			SA1->(dbSeek(xFilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA))
			If SA1->(!EOF())
				If !Empty(SA1->A1_LOCAL)
					cAlDes := SA1->A1_LOCAL
					lContinua:=.T.
				EndIf
			EndIf
		ElseIf SF2->F2_TIPO == "B"
			SA2->(dbSetOrder(1))
			SA2->(dbSeek(xFilial("SA2")+SF2->F2_CLIENTE+SF2->F2_LOJA))
			If SA2->(!EOF())
				If !Empty(SA2->A2_LOCAL)
					cAlDes := SA2->A2_LOCAL
					lContinua:=.T.
				EndIf
			EndIf
		EndIf      
		
				//tratamento para criar armazem no SB2 - destino
		SB2->(DbSetOrder(1))
		If ! SB2->(DbSeek( xFilial("SB2") + (cAliasSD2)->D2_COD + cAlDes ))
			CriaSB2((cAliasSD2)->D2_COD,cAlDes)
		EndIf 
	
		//define n๚mero sequencial e de documento
		cNumseq := ProxNum()
		aadd (aItens,{	GetSXENum("SD3","D3_DOC") ,;   // 01.Numero do Documento
			(cAliasSD2)->D2_EMISSAO})// 02.Data da Transferencia
		aadd (aItens,{})
			
		aItens[2] :=  {{"D3_COD" 		, SB1->B1_COD			,NIL}}// 01.Produto Origem
		aAdd(aItens[2],{"D3_DESCRI" 	, SB1->B1_DESC			,NIL})// 02.Descricao
		aAdd(aItens[2],{"D3_UM"     	, SB1->B1_UM			,NIL})// 03.Unidade de Medida
		aAdd(aItens[2],{"D3_LOCAL"  	, (cAliasSD2)->D2_LOCAL	,NIL})// 04.Local Origem
		aAdd(aItens[2],{"D3_LOCALIZ"	, CriaVar("D3_LOCALIZ")	,NIL})// 05.Endereco Origem
		aAdd(aItens[2],{"D3_COD"    	, SB1->B1_COD			,NIL})// 06.Produto Destino
		aAdd(aItens[2],{"D3_DESCRI" 	, SB1->B1_DESC			,NIL})// 07.Descricao
		aAdd(aItens[2],{"D3_UM"     	, SB1->B1_UM			,NIL})// 08.Unidade de Medida
		aAdd(aItens[2],{"D3_LOCAL"  	, cAlDes				,NIL})// 09.Armazem Destino
		aAdd(aItens[2],{"D3_LOCALIZ"	, CriaVar("D3_LOCALIZ")	,NIL})// 10.Endereco Destino
		aAdd(aItens[2],{"D3_NUMSERI"	, CriaVar("D3_NUMSERI")	,NIL})// 11.Numero de Serie
		aAdd(aItens[2],{"D3_LOTECTL"	, CriaVar("D3_LOTECTL")	,NIL})// 12.Lote Origem
		aAdd(aItens[2],{"D3_NUMLOTE"	, CriaVar("D3_NUMLOTE")	,NIL})// 13.Sub-Lote
		aAdd(aItens[2],{"D3_DTVALID"	, CriaVar("D3_DTVALID")	,NIL})// 14.Data de Validade
		aAdd(aItens[2],{"D3_POTENCI"	, CriaVar("D3_POTENCI")	,NIL})// 15.Potencia do Lote
		aAdd(aItens[2],{"D3_QUANT"  	, (cAliasSD2)->QTDE		,NIL})// 16.Quantidade
		aAdd(aItens[2],{"D3_QTSEGUM"	, CriaVar("D3_QTSEGUM")	,NIL})// 17.Quantidade na 2 UM
		aAdd(aItens[2],{"D3_ESTORNO"	, CriaVar("D3_ESTORNO")	,NIL})// 18.Estorno
		aAdd(aItens[2],{"D3_NUMSEQ" 	, cNumseq				,NIL})// 19.NumSeq
		aAdd(aItens[2],{"D3_LOTECTL"	, CriaVar("D3_LOTECTL")	,NIL})// 20.Lote Destino
		aAdd(aItens[2],{"D3_DTVALID"	, CriaVar("D3_DTVALID")	,NIL})// 21.Data de Validade Destino
		
		Begin Transaction
		
			lMsErroAuto := .F.
	
			MsExecAuto({|x| MATA261(x)},aItens) 
			
			If lMsErroAuto
				MostraErro()
				DisarmTransaction()
				cMens+= "Nf : " + SF2->F2_DOC + " - Serie : " + SF2->F2_SERIE + " - Produto: " + SD2->D2_COD + " - Erro!" + CRLF
			Else
				cMens+= "Nf : " + SF2->F2_DOC + " - Serie : " + SF2->F2_SERIE + " - Produto: " + SD2->D2_COD + " - OK!" + CRLF
			EndIf
			
		End Transaction
				
		DbSelectArea(cAliasSD2)		
		(cAliasSD2)->(DbSkip())
	EndDo
	
	DbSelectArea(cAliasSD2)
	dbCloseArea()
	
	U_ExTelaMen("FAT002",cMens,"Arial",12,,.F.,.T.)	
	
	Aviso("FAT002","Transfer๊ncias efetuadas com sucesso!",{"Ok"})    		
	ProcLogAtu("FIM")

	
	DDATABASE:= _dData

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAjustaSX1 บAutor  ณClaudio D. de Souza บ Data ณ08.07.2004   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณInsere novas perguntas ao sx1                               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINR150                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AjustaSX1(cPerg)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Variaveis utilizadas para parametros ณ
//ณ mv_par01	  // Calendแrio 		 ณ
//ณ mv_par02	  // Periodo   		     ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

PutSx1(cPerg,"01","Emissao de          "    ,"Emissao de          " ,"Emissao de          ","mv_cha","D", 8,0,1,"G","",""    ,"","","mv_par01",""                ,""               ,""            ,"",""        		,""            	,""          		,"","","","","","","","","")
PutSx1(cPerg,"02","Emissao ate	       "    ,"Emissao ate         " ,"Emissao ate         ","mv_chb","D", 8,0,1,"G","","","","","mv_par02",""                ,""               ,""            ,"",""        		,""            	,""          		,"","","","","","","","","")
PutSx1(cPerg,"03","Produto ate	       "    ,"Produto ate         " ,"Produto ate         ","mv_chc","C", TamSX3("B1_COD")[1],0,1,"G","","","","","mv_par03",""                ,""               ,""            ,"",""        		,""            	,""          		,"","","","","","","","","")
PutSx1(cPerg,"04","Produto ate	       "    ,"Produto ate         " ,"Produto ate         ","mv_chd","C", TamSX3("B1_COD")[1],0,1,"G","","","","","mv_par04",""                ,""               ,""            ,"",""        		,""            	,""          		,"","","","","","","","","")
PutSx1(cPerg,"05","Nota    de          "    ,"Nota	de           " ,"Nota  de             ","mv_che","C", TamSX3("D2_DOC")[1],0,1,"G","","","","","mv_par05",""                ,""               ,""            ,"",""        		,""            	,""          		,"","","","","","","","","")
PutSx1(cPerg,"06","Nota    ate          "   ,"Nota ate            " ,"Nota  ate           ","mv_chf","C", TamSX3("D2_DOC")[1],0,1,"G","","","","","mv_par06",""                ,""               ,""            ,"",""        		,""            	,""          		,"","","","","","","","","")

Return