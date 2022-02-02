#include "protheus.ch"
#include "FWMVCDef.ch"
#include "topconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PM200ROT  ºAutor  ³Fernando Macieira   º Data ³  12/21/17   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Adiciona botões no Gerenciamento de Projetos (PMS)         º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Adoro                                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºChamado   ³ 047440 || OS 048708 || FINANCEIRO || REGINALDO || 8451     º±±
±±º          ³ || APROVACAO PROJETOS - FWNM - 29/04/2019                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function PM200ROT()

	Private aUsRotina := MenuDef()
	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'P.E Adiciona botões no (PMS) ')

	
	aAdd(aUsRotina, {'Cronograma Financeiro', "u_ADPMS001P()", 0, 7, 0, Nil})
	aAdd(aUsRotina, {'Projetos x CC Autorizados', "u_ADPRJ002P()", 0, 8, 0, Nil})
	aAdd(aUsRotina, {'Aprovações', "u_UpZC7()", 0, 9, 0, Nil})

Return aUsRotina

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³UPZC7     ºAutor  ³Fernando Macieira   º Data ³  07/11/18   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Demonstra aos usuarios o status na central de aprovações º±±
±±º          ³ do projeto selecionado                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Adoro                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function UpZC7()

	Local aArea 	  := GetArea()
	Local oInterface
	Local oGroup1
	Local oGroup2
	Local oFechar
	
	Private oProjetos
	Private cArq	 := ""
	Private stru	 := {}
	Private aCpoBro	 := {}
	Private lInverte := .F.
	Private oTotPrj
	Private nTotPrj	 := 0
	
	oInterface			 := MsDialog():Create()
	oInterface:cName     := "oInterface"
	oInterface:cCaption  := "Projetos - Status das Aprovações"
	oInterface:nLeft     := 34
	oInterface:nTop      := 222
	oInterface:nWidth    := 1000
	oInterface:nHeight   := 550
	oInterface:lShowHint := .F.                                  	
	oInterface:lCentered := .T.
	
	//Grid
	oGroup1 := TGroup():Create(oInterface,010,005,234,495,"",,,.T.)
	
	//Cria arquivo strutura.
	stru := {}
	//Aadd(stru,{"OK"        ,"C",02	,0})
	Aadd(stru,{"ZC7_PROJET"    ,"C"	,TamSX3("ZC7_PROJET")[1]  ,0})
	Aadd(stru,{"ZC7_REVPRJ"    ,"C"	,TamSX3("ZC7_REVPRJ")[1]  ,0})
	Aadd(stru,{"ZC7_VLRBLQ"    ,"N"	,TamSX3("ZC7_VLRBLQ")[1]  ,4})
	Aadd(stru,{"ZC7_NOMAPR"    ,"C"	,TamSX3("ZC7_NOMAPR")[1]  ,0})
	Aadd(stru,{"ZC7_REPROV"    ,"C"	,TamSX3("ZC7_REPROV")[1]  ,0}) // Chamado n. 047440 || OS 048708 || FINANCEIRO || REGINALDO || 8451 || APROVACAO PROJETOS - FWNM - 29/04/2019
	Aadd(stru,{"ZC7_DTAPR"     ,"D"	,TamSX3("ZC7_DTAPR")[1]  ,0})
	Aadd(stru,{"ZC7_HRAPR"     ,"C"	,TamSX3("ZC7_HRAPR")[1]  ,0})
	Aadd(stru,{"ZC7_OBS"       ,"C"	,TamSX3("ZC7_OBS")[1]  ,0})
	
	//Cria tabela temporária.
	cArq := Criatrab(,.F.)
	MsCreate(cArq,stru,"DBFCDX")
	
	//Atribui a tabela temporária ao alias TRB.
	DbUseArea(.T.,"DBFCDX",cArq,"TTRAG",.T.,.F.)
	
	aCpoBro := {}
	//Aadd(aCpoBro,{"OK"       ,, "Mark"})
	Aadd(aCpoBro,{"ZC7_PROJET",,"Projeto"})
	Aadd(aCpoBro,{"ZC7_REVPRJ",,"Revisão"})
	Aadd(aCpoBro,{"ZC7_VLRBLQ",,"Valor Suplementado"})
	Aadd(aCpoBro,{"ZC7_NOMAPR",,"Nome Aprovador/Reprovador"})
	Aadd(aCpoBro,{"ZC7_REPROV",,"Reprovado?"}) // Chamado n. 047440 || OS 048708 || FINANCEIRO || REGINALDO || 8451 || APROVACAO PROJETOS - FWNM - 29/04/2019
	Aadd(aCpoBro,{"ZC7_DTAPR" ,,"Dt Aprovação/Reprovação"})
	Aadd(aCpoBro,{"ZC7_HRAPR" ,,"Hr Aprovação/Reprovação"})
	Aadd(aCpoBro,{"ZC7_OBS"   ,,"Observações"})
	
	RecLock("TTRAG",.T.)
	
		TTRAG->ZC7_PROJET := ""
		TTRAG->ZC7_REVPRJ := ""
		TTRAG->ZC7_VLRBLQ := 0
		TTRAG->ZC7_NOMAPR := ""
		TTRAG->ZC7_REPROV := ""
		TTRAG->ZC7_DTAPR := CtoD("  /  /  ")
		TTRAG->ZC7_HRAPR  := ""
		TTRAG->ZC7_OBS    := ""
	
	TTRAG->(MsUnlock())
	
	oProjetos := MsSelect():New("TTRAG","","",aCpoBro ,@lInverte,"",{010,005,234,495},,,oInterface,,)
	oGroup2	 := TGroup():Create(oInterface,239,005,260,495,"",,,.T.)
	oTotPrj  := TGet():New(245,010,{|u|If(PCount() == 0,nTotPrj,nTotPrj := u)},oInterface,050,010,"@E 999,999,999",,0,16777215,,.F.,,.T.,,.F.,{|| .F. },.F.,.F.,,.F.,.F. ,,"nTotPrj",,,,.T.,,,"Total registros:",2)
	oFechar	 := TButton():New(245,450,"Fechar",oInterface,{||oInterface:End()},40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
	oFechar:SetCss("QPushButton{background-color: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1, stop: 0 #FF0000, stop: 1 #8C1717);color: white}")
	oInterface:Activate(,,,.T.,{||.T.},,{|| MsAguarde({|| carrArq() },"Aguarde","Carregando dados da central de aprovação...") })

	If Select("TTRAG") > 0
		TTRAG->(DbCloseArea())
	EndIf
	
	FErase( cArq + GetDBExtension() )
	
	RestArea(aArea)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³carrArq        ºAutor  ³             º Data ³  05/12/2017   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Carrega os registros na MsSelect.                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function carrArq()

	Local aArea 	:= GetArea()
	Local aProjetos	:= {}
	Local i			:= 1
	Local cQuery	:= ""

	If Select("TTRAG") > 0
		TTRAG->(DbCloseArea())
		FErase( cArq + GetDBExtension() )
	EndIf

	nTotPrj:= 0
	oTotPrj:Refresh()

	cQuery := scriptSql()

	If Select("D_PROJETOS") > 0
		D_PROJETOS->(DbCloseArea())
	EndIf

	TcQuery cQuery New Alias "D_PROJETOS"

	aTamSX3	:= TAMSX3("ZC7_VLRBLQ")
	TCSETFIELD("D_PROJETOS", "ZC7_VLRBLQ",		aTamSX3[3], aTamSX3[1], aTamSX3[2])

	aTamSX3	:= TAMSX3("ZC7_DTAPR")
	TCSETFIELD("D_PROJETOS", "ZC7_DTAPR",		aTamSX3[3], aTamSX3[1], aTamSX3[2])

	DbSelectArea("D_PROJETOS")
	D_PROJETOS->(DbGoTop())
	Do While ! D_PROJETOS->(Eof())
	
		Aadd(aProjetos,{D_PROJETOS->ZC7_PROJET,D_PROJETOS->ZC7_REVPRJ,D_PROJETOS->ZC7_VLRBLQ,D_PROJETOS->ZC7_NOMAPR,D_PROJETOS->ZC7_DTAPR,D_PROJETOS->ZC7_HRAPR,D_PROJETOS->ZC7_OBS,D_PROJETOS->ZC7_REPROV})
		
		nTotPrj++
		
		D_PROJETOS->( dbSkip() )
	
	EndDo

	D_PROJETOS->(DbCloseArea())

	//Cria arquivo strutura.
	stru := {}
	//Aadd(stru,{"OK"        ,"C",02	,0})
	Aadd(stru,{"ZC7_PROJET"    ,"C"	,TamSX3("ZC7_PROJET")[1]  ,0})
	Aadd(stru,{"ZC7_REVPRJ"    ,"C"	,TamSX3("ZC7_REVPRJ")[1]  ,0})
	Aadd(stru,{"ZC7_VLRBLQ"    ,"N"	,TamSX3("ZC7_VLRBLQ")[1]  ,4})
	Aadd(stru,{"ZC7_NOMAPR"    ,"C"	,TamSX3("ZC7_NOMAPR")[1]  ,0})
	Aadd(stru,{"ZC7_REPROV"    ,"C"	,TamSX3("ZC7_REPROV")[1]  ,0}) // Chamado n. 047440 || OS 048708 || FINANCEIRO || REGINALDO || 8451 || APROVACAO PROJETOS - FWNM - 29/04/2019
	Aadd(stru,{"ZC7_DTAPR"     ,"D"	,TamSX3("ZC7_DTAPR")[1]  ,0})
	Aadd(stru,{"ZC7_HRAPR"     ,"C"	,TamSX3("ZC7_HRAPR")[1]  ,0})
	Aadd(stru,{"ZC7_OBS"       ,"C"	,TamSX3("ZC7_OBS")[1]  ,0})

	//Cria tabela temporária.
	cArq := Criatrab(,.F.)
	MsCreate(cArq,stru,"DBFCDX")

	//Atribui a tabela temporária ao alias TRB.
	DbUseArea(.T.,"DBFCDX",cArq,"TTRAG",.T.,.F.)

	//
	aCpoBro := {}
	//Aadd(aCpoBro,{"OK"      ,, "Mark"})
	Aadd(aCpoBro,{"ZC7_PROJET",,"Projeto"})
	Aadd(aCpoBro,{"ZC7_REVPRJ",,"Revisão"})
	Aadd(aCpoBro,{"ZC7_VLRBLQ",,"Valor Suplementado"})
	Aadd(aCpoBro,{"ZC7_NOMAPR",,"Nome Aprovador"})
	Aadd(aCpoBro,{"ZC7_REPROV",,"Reprovado?"}) // Chamado n. 047440 || OS 048708 || FINANCEIRO || REGINALDO || 8451 || APROVACAO PROJETOS - FWNM - 29/04/2019
	Aadd(aCpoBro,{"ZC7_DTAPR" ,,"Data Aprovação"})
	Aadd(aCpoBro,{"ZC7_HRAPR" ,,"Hora Aprovação"})
	Aadd(aCpoBro,{"ZC7_OBS"   ,,"Observações"})

	For i := 1 To Len(aProjetos)
	
		//IncProc("Carregando cadastro de clientes " + cvaltochar(i) +" De: "+cvlatochar(Len(aProjetos)))
	
		RecLock("TTRAG",.T.)
	
			//Aadd(aProjetos,{D_PROJETOS->ZC7_PROJET,D_PROJETOS->ZC7_REVPRJ,D_PROJETOS->ZC7_VLRBLQ,D_PROJETOS->ZC7_NOMAPR,D_PROJETOS->ZC7_DTAPR,D_PROJETOS->ZC7_HRAPR,D_PROJETOS->ZC7_OBS,D_PROJETOS->ZC7_REPROV})
		//	TTRAG->Ok      := cMark
			TTRAG->ZC7_PROJET := Alltrim(cValToChar(aProjetos[i][1]))
			TTRAG->ZC7_REVPRJ := Alltrim(cValToChar(aProjetos[i][2]))
			TTRAG->ZC7_VLRBLQ := aProjetos[i][3]
			TTRAG->ZC7_NOMAPR := Alltrim(cValToChar(aProjetos[i][4]))
			TTRAG->ZC7_REPROV := Iif(!Empty(aProjetos[i][8]),"Sim","")
			TTRAG->ZC7_DTAPR  := aProjetos[i][5]
			TTRAG->ZC7_HRAPR  := Alltrim(cValToChar(aProjetos[i][6]))
			TTRAG->ZC7_OBS    := Alltrim(cValToChar(aProjetos[i][7]))
	
		TTRAG->(MsUnlock())
	
	Next i

	If nTotPrj <= 0
		
		RecLock("TTRAG",.T.)
		
		TTRAG->ZC7_PROJET := ""
		TTRAG->ZC7_REVPRJ := ""
		TTRAG->ZC7_VLRBLQ := 0
		TTRAG->ZC7_NOMAPR := ""
		TTRAG->ZC7_REPROV := ""
		TTRAG->ZC7_DTAPR := CtoD("  /  /  ")
		TTRAG->ZC7_HRAPR  := ""
		TTRAG->ZC7_OBS    := ""
		
		TTRAG->(MsUnlock())
		
	EndIf
	
	TTRAG->(DbGoTop())

	//
	Eval(oProjetos:oBrowse:bGoTop)
	oProjetos:oBrowse:Refresh()
	Eval(oProjetos:oBrowse:bGoTop)

	For i := 1 To nTotPrj
		oProjetos:oBrowse:GoUp()
	Next i

	oTotPrj:Refresh()

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³scriptSql      ºAutor  ³             º Data ³  05/12/2017   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Script sql.                                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function scriptSql()

	Local aArea 	:= GetArea()

	cQuery := ""
	cQuery += " SELECT ZC7_PROJET, ZC7_REVPRJ, ZC7_VLRBLQ, ZC7_NOMAPR, ZC7_REPROV, ZC7_DTAPR, ZC7_HRAPR, ZC7_OBS "
	cQuery += " FROM " + RetSqlName("ZC7") + " ZC7 WITH (NOLOCK) WHERE ZC7_FILIAL BETWEEN ' ' AND 'z' " 
	cQuery += " AND ZC7_PROJET = '"+AF8->AF8_PROJET+"' "
	//cQuery += " AND ZC7_REVPRJ = '"+AF8->AF8_REVISA+"' "
	cQuery += " AND ZC7.D_E_L_E_T_ = ''  "
	cQuery += " ORDER BY 1,2 "

	RestArea(aArea)

Return cQuery