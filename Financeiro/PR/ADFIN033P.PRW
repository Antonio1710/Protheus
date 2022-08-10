#Include "Rwmake.ch"
#Include "Protheus.ch"
#Include "Topconn.ch"
#Include 'AP5mail.ch'
#INCLUDE "Report.ch"
#INCLUDE "ParmType.ch"
#INCLUDE "FWCommand.ch"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "MntTRCell.ch"
#include "font.ch"

/*/{Protheus.doc} User Function ADFIN033P
	Painel Contas Pagar
	@type  Function
	@author Everson
	@since 05/06/2017
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@chamado 035557
	@history chamado n. 051182 - FWNM          - 13/09/2019 - OS 052502 || FINANCAS || FLAVIA || 8461 || REL.PAGAMENTO
	@history chamado n. 054604 - FWNM          - 03/01/2020 - OS 055999 || FINANCAS || FLAVIA || 8461 || REL. PAGAMENTOS
	@history Chamado n. 058206 - WILLIAM COSTA - 19/05/2020 - Adicionado campo Nr do Cheque
	@history Ticket 70142   - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
	@history Ticket 78007   - Antonio Domingos - 10/08/2022 - ADFIN030P - Apagar Geração de arquivos Temporarios
/*/
User Function ADFIN033P()

	Local aArea			:= GetArea()
	Local oTelMenu
	Local oConfDiPag
	
	Local oFechar
	Private   cArqCPD
	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Painel Contas Pagar')
	
	oTelMenu			:= MsDialog():Create()
	oTelMenu:cName     := "oTelMenu"
	oTelMenu:cCaption  := "Contas a Pagar"
	oTelMenu:nLeft     := 34
	oTelMenu:nTop      := 222
	oTelMenu:nWidth    := 250
	oTelMenu:nHeight   := 300
	oTelMenu:lShowHint := .F.
	oTelMenu:lCentered := .T.
	
	oConfDiPag := TButton():New(016,005,"Conferência Pagamentos Diários",oTelMenu,{|| cofCobDia() },111,018,,,.F.,.T.,.F.,,.F.,,,.F. )
	
	oGroup1  := TGroup():Create(oTelMenu,115,005,135,120,"",,,.T.)
	
	oFechar := TButton():New(120,075,"Fechar",oTelMenu,{|| oTelMenu:End() },040,010,,,.F.,.T.,.F.,,.F.,,,.F. )
	
	oTelMenu:Activate(,,,.T.,{||.T.},,{||  })
	
	//Ticket 78007   - Antonio Domingos - 10/08/2022 - ADFIN030P - Apagar Geração de arquivos Temporarios
	Iif(File(cArqCPD + GetDBExtension()),FErase(cArqCPD  + GetDBExtension()) ,Nil)
	
	RestArea(aArea)
	
Return Nil

/*/{Protheus.doc} Static Function cofCobDia
	Interface Conferência Pagamentos Diários.
	@type  Static Function
	@author Everson
	@since 05/06/2017
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@chamado n. 035557
/*/
Static Function cofCobDia()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
	Local aArea		:= GetArea()
	
	Local oIntPrinc
	
	Local aTFLCPD	:= {}
	Local oTFLCPD
	
	Local oBase
	Local oCSVB
	Local aAltBase	:= {}
	Local aHBase	:= {}
	Local aColsBase	:= {}
	
	Local oGroup1
	Local oBorBx
	Local oCPLvr
	Local oDataDe
	Local oDataAte
	
	Local oAnalise
	
	Local oCSVA
	
	Local oFechar
	
	Private dDataDe	:= Date()
	Private dDataAte:= Date()
	
	Private lCPagLvr  := .F.
	
	Private aOrderBase:= {}
	
	Private oTxtBusca
	Private aSelBusca := {}
	Private cSelBusca := ""
	Private oSelBusca
	
	Private oBusca
	Private oBtnBusca
	Private oBtnBusca
	Private cBusca	  := Space(60)
	Private nBusca	  := 0
	
	//Log de acesso.
	logAcesso("COFCOBDIA")
	
	oIntPrinc			:= MsDialog():Create()
	oIntPrinc:cName     := "oIntPrinc"
	oIntPrinc:cCaption  := "Conferência Pagamentos Diários"
	oIntPrinc:nLeft     := 34
	oIntPrinc:nTop      := 222
	oIntPrinc:nWidth    := 1200
	oIntPrinc:nHeight   := 550
	oIntPrinc:lShowHint := .F.
	oIntPrinc:lCentered := .T.
	
		aTFLCPD := {"Base","Resumo Por Banco"}
		oTFLCPD := TFolder():New(001,005,aTFLCPD,,oIntPrinc,,,,.T.,,535,235)
		oTFLCPD:SetOption(2)
		
		/*oTxtBusca := TSay():New(002,010,{||"Localiza registro:"},oTFLCPD:aDialogs[1],,,,,,.T.,CLR_RED,CLR_WHITE,250,20)
		aSelBusca := {"1=Nome Rede"}
		cSelBusca := aSelBusca[1]
        oSelBusca := TComboBox():New(010,010,{|u|if(PCount()>0,cSelBusca:=u,cSelBusca)},;
        aSelBusca,050,22,oTFLCPD:aDialogs[1],,,,,,.T.,,,,,,,,,'cSelBusca')

		oBusca   := TGet():New(010,062,{|u|If(PCount() == 0,cBusca,cBusca := u)},oTFLCPD:aDialogs[1],100,010,"@C",,0,16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cBusca",,,,.T.,,,"",2) 
		oBtnBusca:= TButton():New(010,165,"Ok",oTFLCPD:aDialogs[1],,20,12,,,.F.,.T.,.F.,,.F.,,,.F. )
		oBtnBusca:bAction := {|| nBusca := Ascan(oTitulos:aCols,{|x| AllTrim(Upper(cBusca))$Upper(x[Val(cValToChar(cSelBusca))])}),;
								Iif(nBusca > 0,Eval({||oTitulos:ForceRefresh(),oTitulos:GoTo(nBusca),oTitulos:Refresh()}),;
								MsgAlert("Não foi possível localizar o registro","Função cobDia"))}*/
		
		Aadd(aHBase,{"Filial"   ,"FILIAL"   ,"",TamSX3("E2_FILIAL")[1] , 0,"","" ,"C","",""})
		Aadd(aHBase,{"Tipo"     ,"TIPO"     ,"",TamSX3("E2_TIPO")[1]   , 0,"","" ,"C","",""})
		Aadd(aHBase,{"Título"   ,"TITULO"   ,"",TamSX3("E2_NUM")[1]    , 0,"","" ,"C","",""})
		Aadd(aHBase,{"Parcela"  ,"PARC"     ,"",TamSX3("E2_PARCELA")[1], 0,"","" ,"C","",""})
		Aadd(aHBase,{"Natureza" ,"NAT"      ,"",TamSX3("E2_NATUREZ")[1], 0,"","" ,"C","",""})
		Aadd(aHBase,{"Cod. Forn","CODFOR"   ,"",TamSX3("E2_FORNECE")[1], 0,"","" ,"C","",""})
		Aadd(aHBase,{"Nome Forn","NMFOR"    ,"",TamSX3("E2_NOMFOR")[1],  0,"","" ,"C","",""})
		Aadd(aHBase,{"Emissão"  ,"EMISSAO"  ,"",TamSX3("E2_EMISSAO")[1], 0,"","" ,"D","",""})
		Aadd(aHBase,{"Vencto"   ,"VENCTO"   ,"",TamSX3("E2_VENCREA")[1], 0,"","" ,"D","",""})
		Aadd(aHBase,{"Pagto"    ,"PAGTO"    ,"",TamSX3("E2_BAIXA")[1]  , 0,"","" ,"D","",""})
		
		Aadd(aHBase,{"Valor"    ,"VLR"  ,"@E 999,999,999.99" ,15, 2,"","" ,"N","",""})
		
		Aadd(aHBase,{"Situação" ,"SITUAC"     ,"",40, 0,"","" ,"C","",""})
		Aadd(aHBase,{"Bordero"  ,"BORDERO"    ,"",TamSX3("E2_NUMBOR")[1], 0,"","" ,"C","",""})
		Aadd(aHBase,{"Banco"    ,"BANCO"      ,"",10, 0,"","" ,"C","",""})
		Aadd(aHBase,{"Log.Dt-Hr","LOG"        ,"",TamSX3("E2_LOGDTHR")[1], 0,"","" ,"C","",""})
		Aadd(aHBase,{"Desc. Natureza","DESNAT","",40, 0,"","" ,"C","",""})
		Aadd(aHBase,{"Razão Social","RSOCIAL" ,"",40, 0,"","" ,"C","",""})
		
		oBase 	 := MsNewGetDados():New(002,002,205,530,,"Allwaystrue()","Allwaystrue()","",aAltBase,Nil,999,Nil,Nil,Nil,oTFLCPD:aDialogs[1],aHBase,@aColsBase)
		oBase:oBrowse:bHeaderClick := {|| ordenaGrid(oBase,oBase:aCols,oBase:oBrowse:ColPos,aHBase) } 
		
		oCSVB	 := TButton():New(209,485,"CSV",oTFLCPD:aDialogs[1],{|| MsAguarde({|| grCPDCSV(oBase,aHBase,"CPD_BASE_" + cUserName + "_" + DToS(Date()) + "_" + StrTran(cValToChar(Time()),":","") + ".CSV")},"Aguarde","Gerando CSV...") },40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
		
		oGroup1  := TGroup():Create(oIntPrinc,001,545,236,595,"",,,.T.)
			
			dDataDe   := Date()
			oDataDe   := TGet():New(010,550,{|u|If(PCount() == 0,dDataDe,dDataDe   := u)},oIntPrinc,040,010,"@D",{||NaoVazio()},0,16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"dDataDe",,,,.T.,,,"Data de:",1) 
			
			dDataAte  := Date()
			oDataAte  := TGet():New(040,550,{|u|If(PCount() == 0,dDataAte,dDataAte := u)},oIntPrinc,040,010,"@D",{||NaoVazio()},0,16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"dDataAte",,,,.T.,,,"Data ate:",1) 
			
			cFiltr	  := Iif(lCPagLvr,"C Pagar (Livre)","Borderô/Baixas")
			oFiltr    := TGet():New(100,550,{|u|If(PCount() == 0,cFiltr,cFiltr   := u)},oIntPrinc,040,010,,,0,16777215,,.F.,,.T.,,.F.,{|| .F. },.F.,.F.,,.F.,.F. ,,"cFiltr",,,,.T.,,,"Filtro:",1) 
			
			oBorBx 	  := TButton():New(070,550,"Borderô/Baixas"  ,oIntPrinc,  {|| cFiltr := "Borderô/Baixas" , oFiltr:Refresh(), lCPagLvr := .F., MsAguarde({|| carrCPD(oBase,aHBase,oAnalise,dDataDe,dDataAte,oTFLCPD,oCSVA) },"Aguarde","Atualizando dados...")},40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
			
			oCPLvr 	  := TButton():New(085,550,"C Pagar (Livre)" ,oIntPrinc,  {|| cFiltr := "C Pagar (Livre)", oFiltr:Refresh(), lCPagLvr := .T., MsAguarde({|| carrCPD(oBase,aHBase,oAnalise,dDataDe,dDataAte,oTFLCPD,oCSVA) },"Aguarde","Atualizando dados...")},40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
			
		oFechar	 := TButton():New(245,550,"Fechar",oIntPrinc,{||oIntPrinc:End()},40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
		oFechar:SetCss("QPushButton{background-color: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1, stop: 0 #FF0000, stop: 1 #8C1717);color: white}")	
		
	oIntPrinc:Activate(,,,.T.,{||.T.},,{|| carrCPD(oBase,aHBase,oAnalise,dDataDe,dDataAte,oTFLCPD,oCSVA) })
	
	RestArea(aArea)
	
Return Nil

/*/{Protheus.doc} Static Function carrCPD
	Carrega dados carrCPD
	@type  Static Function
	@author Everson
	@since 06/06/2017
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@chamado n. 035557
/*/
Static Function carrCPD(oBase,aHBase,oAnalise,dDataDe,dDataAte,oTFLCPD,oCSVA)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
	Local aArea		:= GetArea()
	Local cQuery	:= ""
	Local cQuery2	:= ""
	Local aDatas	:= {}
	Local aDatas2	:= {}
	Local i			:= 1
	Local w			:= 1
	
	Local aHAnalise		:= {}
	Local aAltAnalise	:= {}
	Local aColsAnalise	:= {}
	
	Local aStru		:= {}
	//Local cArqCPD	:= ""
	Local cIndex	:= ""
	
	Local nTotFilG	:= 0
	
	Local cTpDt		:= ""
	Local nTotDt	:= 0
	Local aTotais 	:= {}
	Local nSubTot	:= 0
	
	//
	cQuery := scriptCPD(dDataDe,dDataAte)
	
	//
	If Select("D_CPD") > 0
		D_CPD->(DbCloseArea())
		
	EndIf
	
	//
	TcQuery cQuery New Alias "D_CPD"
	DbSelectArea("D_CPD")
	D_CPD->(DbGoTop())
	
	//
	oBase:aCols := {}
	
	While ! D_CPD->(Eof())
	
		Aadd(oBase:aCols , Array(Len(aHBase) + 1) )
		oBase:aCols[Len(oBase:aCols), Len(oBase:aCols[1]) ] := .F.
		
		oBase:aCols[Len(oBase:aCols),Ascan(aHBase,{|x| AllTrim(x[2]) == "FILIAL" })] := D_CPD->E2_FILIAL
		oBase:aCols[Len(oBase:aCols),Ascan(aHBase,{|x| AllTrim(x[2]) == "TIPO"   })] := D_CPD->E2_TIPO
		oBase:aCols[Len(oBase:aCols),Ascan(aHBase,{|x| AllTrim(x[2]) == "TITULO" })] := D_CPD->E2_NUM
		oBase:aCols[Len(oBase:aCols),Ascan(aHBase,{|x| AllTrim(x[2]) == "PARC"   })] := D_CPD->E2_PARCELA
		oBase:aCols[Len(oBase:aCols),Ascan(aHBase,{|x| AllTrim(x[2]) == "NAT"    })] := D_CPD->E2_NATUREZ
		oBase:aCols[Len(oBase:aCols),Ascan(aHBase,{|x| AllTrim(x[2]) == "CODFOR" })] := D_CPD->E2_FORNECE
		oBase:aCols[Len(oBase:aCols),Ascan(aHBase,{|x| AllTrim(x[2]) == "NMFOR"  })] := D_CPD->E2_NOMFOR
		oBase:aCols[Len(oBase:aCols),Ascan(aHBase,{|x| AllTrim(x[2]) == "EMISSAO"})] := Iif(! Empty(Alltrim(cValToChar(D_CPD->E2_EMISSAO))), SToD(D_CPD->E2_EMISSAO) ,Nil)
		oBase:aCols[Len(oBase:aCols),Ascan(aHBase,{|x| AllTrim(x[2]) == "VENCTO" })] := Iif(! Empty(Alltrim(cValToChar(D_CPD->E2_VENCREA))), SToD(D_CPD->E2_VENCREA) ,Nil)
		oBase:aCols[Len(oBase:aCols),Ascan(aHBase,{|x| AllTrim(x[2]) == "PAGTO"  })] := Iif(! Empty(Alltrim(cValToChar(D_CPD->PAGTO)))     , SToD(D_CPD->PAGTO) ,Nil)
		oBase:aCols[Len(oBase:aCols),Ascan(aHBase,{|x| AllTrim(x[2]) == "VLR"    })] := D_CPD->VALOR
		oBase:aCols[Len(oBase:aCols),Ascan(aHBase,{|x| AllTrim(x[2]) == "SITUAC" })] := D_CPD->SITUAC
		oBase:aCols[Len(oBase:aCols),Ascan(aHBase,{|x| AllTrim(x[2]) == "BORDERO"})] := D_CPD->E2_NUMBOR
		oBase:aCols[Len(oBase:aCols),Ascan(aHBase,{|x| AllTrim(x[2]) == "BANCO"  })] := D_CPD->E2_PORTADO
		oBase:aCols[Len(oBase:aCols),Ascan(aHBase,{|x| AllTrim(x[2]) == "LOG"    })] := D_CPD->E2_LOGDTHR
		oBase:aCols[Len(oBase:aCols),Ascan(aHBase,{|x| AllTrim(x[2]) == "DESNAT" })] := D_CPD->ED_DESCRIC
		oBase:aCols[Len(oBase:aCols),Ascan(aHBase,{|x| AllTrim(x[2]) == "RSOCIAL"})] := D_CPD->A2_NOME
		
		//
		If aScan(aDatas,{|x| x[1] == D_CPD->PAGTO }) == 0
			Aadd(aDatas,{D_CPD->PAGTO})
		
		EndIf
		
		D_CPD->(DbSkip())
		
	EndDo
	
	//
	For i := 1 To Len(aDatas)
		Aadd(aDatas2,aDatas[i][1])
		
	Next i
	
	//
	aSort(aDatas2)
	
	//
	D_CPD->(DbCloseArea())
	
	//
	If Len(oBase:aCols) == 0
		
		Aadd(oBase:aCols , Array(Len(aHBase) + 1) )
		oBase:aCols[Len(oBase:aCols), Len(oBase:aCols[1]) ] := .F.
		
		oBase:aCols[Len(oBase:aCols),Ascan(aHBase,{|x| AllTrim(x[2]) == "FILIAL" })] := ""
		oBase:aCols[Len(oBase:aCols),Ascan(aHBase,{|x| AllTrim(x[2]) == "TIPO"   })] := ""
		oBase:aCols[Len(oBase:aCols),Ascan(aHBase,{|x| AllTrim(x[2]) == "TITULO" })] := ""
		oBase:aCols[Len(oBase:aCols),Ascan(aHBase,{|x| AllTrim(x[2]) == "PARC"   })] := ""
		oBase:aCols[Len(oBase:aCols),Ascan(aHBase,{|x| AllTrim(x[2]) == "NAT"    })] := ""
		oBase:aCols[Len(oBase:aCols),Ascan(aHBase,{|x| AllTrim(x[2]) == "CODFOR" })] := ""
		oBase:aCols[Len(oBase:aCols),Ascan(aHBase,{|x| AllTrim(x[2]) == "NMFOR"  })] := ""
		oBase:aCols[Len(oBase:aCols),Ascan(aHBase,{|x| AllTrim(x[2]) == "EMISSAO"})] := ""
		oBase:aCols[Len(oBase:aCols),Ascan(aHBase,{|x| AllTrim(x[2]) == "VENCTO" })] := ""
		oBase:aCols[Len(oBase:aCols),Ascan(aHBase,{|x| AllTrim(x[2]) == "PAGTO"  })] := ""
		oBase:aCols[Len(oBase:aCols),Ascan(aHBase,{|x| AllTrim(x[2]) == "VLR"    })] := 0
		oBase:aCols[Len(oBase:aCols),Ascan(aHBase,{|x| AllTrim(x[2]) == "SITUAC" })] := ""
		oBase:aCols[Len(oBase:aCols),Ascan(aHBase,{|x| AllTrim(x[2]) == "BORDERO"})] := ""
		oBase:aCols[Len(oBase:aCols),Ascan(aHBase,{|x| AllTrim(x[2]) == "BANCO"  })] := ""
		oBase:aCols[Len(oBase:aCols),Ascan(aHBase,{|x| AllTrim(x[2]) == "LOG"    })] := ""
		oBase:aCols[Len(oBase:aCols),Ascan(aHBase,{|x| AllTrim(x[2]) == "DESNAT" })] := ""
		oBase:aCols[Len(oBase:aCols),Ascan(aHBase,{|x| AllTrim(x[2]) == "RSOCIAL"})] := ""
	
	EndIf
	
	//
	oBase:Refresh()
	
	//
	If Valtype(oAnalise) == "O"
		FreeObj(oAnalise:oBrowse)
		FreeObj(oAnalise)
		
	EndIf
	
	//
	If Valtype(oCSVA) == "0"
		FreeObj(oCSVA)	
	
	EndIf
	
	//
	cQuery2 := scriptCPD(dDataDe,dDataAte)
	cQuery2 += " ORDER BY E2_FILIAL, E2_PORTADO " 
	
	If Select("D_ACPD") > 0
		D_ACPD->(DbCloseArea())
		
	EndIf
	
	//
	TcQuery cQuery2 New Alias "D_ACPD"
	DbSelectArea("D_ACPD")
	D_ACPD->(DbGoTop())
	
	//Cria estrutura do arquivo temporário.
		aStru := {}
		Aadd(aStru,{"TMP_FIL" ,"C",02,0})
		Aadd(aStru,{"TMP_POR" ,"C",10,0})
		
		//
		For i := 1 To Len(aDatas2)
		
			Aadd(aStru,{"T_" + Alltrim(cValToChar(aDatas2[i])) ,"N",15,2})
		
		Next i
		
		Aadd(aStru,{"TMP_TOTAL","N",15,2})
	//
	
	//Cria arquivo temporário.
	cArqCPD := "T_" + Criatrab(,.F.)
	MsCreate(cArqCPD,aStru,"DBFCDX")
	
	If Select("TACPD") > 0
		TACPD->(DbCloseArea())
		
	EndIf
	
	//Atribui a tabela temporária ao alias TRB.
	DbUseArea(.T.,"DBFCDX",cArqCPD,"TACPD",.T.,.F.)	
	
	//Define o índice do arquivo temporário.
	cIndex   := "TMP_FIL+TMP_POR"
	
	//Cria índice no arquivo temporário.
	IndRegua("TACPD", cArqCPD, cIndex,,,"Criando índice..." )
	
	DbSelectArea("D_ACPD")
	D_ACPD->(DbGoTop())
	While ! D_ACPD->(Eof())
		
		DbSelectArea("TACPD")
		TACPD->(DbGoTop())
		
		If TACPD->(DbSeek(D_ACPD->E2_FILIAL + D_ACPD->E2_PORTADO))
			
			RecLock("TACPD",.F.)
				
				TACPD->&("T_" + Alltrim(cValToChar(D_ACPD->PAGTO))) := TACPD->&("T_" + Alltrim(cValToChar(D_ACPD->PAGTO))) +  D_ACPD->VALOR
				TACPD->TMP_TOTAL += D_ACPD->VALOR
				
			MsUnlock()
		
		Else
		
			RecLock("TACPD",.T.)
				
				//
				For i := 1 To Len(aDatas2)
					TACPD->&("T_" + Alltrim(cValToChar(aDatas2[i]))) := 0
				
				Next i
				
				TACPD->TMP_FIL   := D_ACPD->E2_FILIAL
				TACPD->TMP_POR   := D_ACPD->E2_PORTADO
				TACPD->&("T_" + Alltrim(cValToChar(D_ACPD->PAGTO))) := D_ACPD->VALOR
				TACPD->TMP_TOTAL := D_ACPD->VALOR
							
			MsUnlock()
		
		EndIf
		
		D_ACPD->(DbSkip())
		
	EndDo
	
	//
	Aadd(aHAnalise,{"Filial"   ,"FILIAL" ,"",TamSX3("E2_FILIAL")[1] , 0,"","" ,"C","",""})
	Aadd(aHAnalise,{"Portador" ,"PORTAD" ,"",10, 0,"","" ,"C","",""})
	
	//
	For i := 1 To Len(aDatas2)
	
		Aadd(aHAnalise,{DToC(SToD(cValToChar(aDatas2[i]))), Alltrim(cValToChar(aDatas2[i])),"@E 999,999,999.99",15,2,"","" ,"N","",""})

	Next i
	
	//
	Aadd(aHAnalise,{"Total Geral" ,"TOTALG"   ,"@E 999,999,999.99",15, 2,"","" ,"N","",""})
	
	//
	oAnalise := MsNewGetDados():New(002,002,205,530,,"Allwaystrue()","Allwaystrue()","",aAltAnalise,1,999,Nil,Nil,Nil,oTFLCPD:aDialogs[2],aHAnalise,@aColsAnalise)
	oAnalise:oBrowse:bLDblClick := {|| MsAguarde({|| obterDetalhe(oAnalise,aHAnalise,dDataDe,dDataAte)},"Aguarde","Obtendo dados...") }
	
	//
	oAnalise:aCols := {}
	
	//
	nTotFilG := 0
	DbSelectArea("TACPD")
	TACPD->(DbGoTop())
	While ! TACPD->(Eof())
	
		cFil := TACPD->TMP_FIL 
		
		Aadd(oAnalise:aCols , Array(Len(aHAnalise) + 1) )
		oAnalise:aCols[Len(oAnalise:aCols), Len(oAnalise:aCols[1]) ] := .F.
		
		oAnalise:aCols[Len(oAnalise:aCols),Ascan(aHAnalise,{|x| AllTrim(x[2]) == "FILIAL" })] := TACPD->TMP_FIL 
		oAnalise:aCols[Len(oAnalise:aCols),Ascan(aHAnalise,{|x| AllTrim(x[2]) == "PORTAD" })] := TACPD->TMP_POR
		
		//
		For i := 1 To Len(aDatas2)
			
			oAnalise:aCols[Len(oAnalise:aCols),Ascan(aHAnalise,{|x| AllTrim(x[2]) == Alltrim(cValToChar(aDatas2[i])) })] := TACPD->&("T_" + Alltrim(cValToChar(aDatas2[i])))
			
		Next i
		
		oAnalise:aCols[Len(oAnalise:aCols),Ascan(aHAnalise,{|x| AllTrim(x[2]) == "TOTALG" })] := TACPD->TMP_TOTAL
		oAnalise:oBrowse:lUseDefaultColors := .F.
		oAnalise:oBrowse:SetBlkBackColor({|| getColor(oAnalise:aCols,oAnalise:nAt,aHAnalise)})
		
		nTotFilG += TACPD->TMP_TOTAL
		
		//
		TACPD->(DbSkip())
		
		//Totalizador por filial.
		If cFil <> TACPD->TMP_FIL 
			
			Aadd(oAnalise:aCols , Array(Len(aHAnalise) + 1) )
			oAnalise:aCols[Len(oAnalise:aCols), Len(oAnalise:aCols[1]) ] := .F.
			
			oAnalise:aCols[Len(oAnalise:aCols),Ascan(aHAnalise,{|x| AllTrim(x[2]) == "FILIAL" })] := ""
			oAnalise:aCols[Len(oAnalise:aCols),Ascan(aHAnalise,{|x| AllTrim(x[2]) == "PORTAD" })] := "Total " + cFil
			
			//
			nSubTot := 0
			For i := 1 To Len(aHAnalise)
				
				If Alltrim(cValToChar(aHAnalise[i][8])) == "N"
					
					//
					For w := 1 To Len(oAnalise:aCols)
				
						If ! Empty(Alltrim(cValToChar(oAnalise:aCols[w][1]))) .And. Alltrim(cValToChar(oAnalise:aCols[w][1])) == cFil
						
							nSubTot += Val(cValToChar(oAnalise:aCols[w][i]))
						
						EndIf
					
					Next w
					
					oAnalise:aCols[Len(oAnalise:aCols),Ascan(aHAnalise,{|x| AllTrim(x[2]) == Alltrim(cValToChar(aHAnalise[i][2])) })] := nSubTot
					nSubTot := 0
					
				EndIf
			
			Next i
			
			oAnalise:aCols[Len(oAnalise:aCols),Ascan(aHAnalise,{|x| AllTrim(x[2]) == "TOTALG" })] := nTotFilG
			nTotFilG := 0
		
		EndIf
		//
		
	EndDo
	
	//
	If Len(oAnalise:aCols) == 0
	
		Aadd(oAnalise:aCols , Array(Len(aHAnalise) + 1) )
		oAnalise:aCols[Len(oAnalise:aCols), Len(oAnalise:aCols[1]) ] := .F.
		
		oAnalise:aCols[Len(oAnalise:aCols),Ascan(aHAnalise,{|x| AllTrim(x[2]) == "FILIAL" })] := ""
		oAnalise:aCols[Len(oAnalise:aCols),Ascan(aHAnalise,{|x| AllTrim(x[2]) == "PORTAD" })] := ""
		oAnalise:aCols[Len(oAnalise:aCols),Ascan(aHAnalise,{|x| AllTrim(x[2]) == "TOTALG" })] := 0	
		
	Else
	
		//Totalizador geral.
		aTotais := {}
		For i := 1 To Len(aHAnalise)
			
			cTpDt := Alltrim(cValToChar(aHAnalise[i][8]))
			
			If cTpDt == "N"
				
			
				nTotDt := 0
				For w := 1 To Len(oAnalise:aCols)
				
					If ! Empty(Alltrim(cValToChar(oAnalise:aCols[w][1])))
					
						nTotDt += Val(cValToChar(oAnalise:aCols[w][i]))
					
					EndIf
					
				Next w
				
				Aadd(aTotais,{Alltrim(cValToChar(aHAnalise[i][2])),nTotDt})
				
				
			Else
			
				Aadd(aTotais,{Alltrim(cValToChar(aHAnalise[i][2])),Iif(i == 2,"Totais -->","")})
				
			EndIf
			
		
		Next i
	
	EndIf
	
	//Cria os totais na grid.
	If Len(aTotais) > 0
	
		Aadd(oAnalise:aCols , Array(Len(aHAnalise) + 1) )
		oAnalise:aCols[Len(oAnalise:aCols), Len(oAnalise:aCols[1]) ] := .F.
		
		For i := 1 To Len(aHAnalise)
		
			oAnalise:aCols[Len(oAnalise:aCols),Ascan(aHAnalise,{|x| AllTrim(x[2]) == Alltrim(cValToChar(aTotais[i][1])) })] := aTotais[i][2]
		
		Next i
				
		//
		oAnalise:Refresh()
	
	EndIf
	
	//
	TACPD->(DbCloseArea())
	
	//
	oAnalise:Refresh()
	
	//
	oCSVA	 := TButton():New(209,485,"CSV",oTFLCPD:aDialogs[2],{|| MsAguarde({|| grCPDCSV(oAnalise,aHAnalise,"CPD_ANALISE_" + cUserName + "_" + DToS(Date()) + "_" + StrTran(cValToChar(Time()),":","") + ".CSV")},"Aguarde","Gerando CSV...") },40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
	
	//
	//Iif(! Empty(Alltrim(cValToChar(cArqCPD)))   .And. File(cArqCPD   + GetDBExtension())  ,FErase(cArqCPD  + GetDBExtension()) ,Nil)
	
	//
	If Select("TACPD") > 0
		TACPD->(DbCloseArea())
		
	EndIf
	
	If ! Empty(Alltrim(cValToChar(cArqCPD)))
		FErase( Alltrim(cValToChar(cArqCPD)) + GetDBExtension() )
		FErase( Alltrim(cValToChar(cArqCPD)) + OrdBagExt() )
	
	EndIf
	
	//
	aOrderBase := {}
	
	//
	RestArea(aArea)
	
Return Nil

/*/{Protheus.doc} Static Function obterDetalhe 
	Atribui cor a msnewgetdados
	@type  Static Function
	@author Everson
	@since 07/06/2017
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@chamado n. 035557
/*/
Static Function obterDetalhe(oAnalise,aHAnalise,dDataDe,dDataAte)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
	Local aArea		:= GetArea()
	Local nLinha	:= oAnalise:nAt
	Local nColuna	:= oAnalise:oBrowse:ColPos
	Local cTitColum	:= Alltrim(cValToChar(aHAnalise[nColuna][1]))
	Local cCmpHeader:= Alltrim(cValToChar(aHAnalise[nColuna][2]))
	Local cFil		:= Alltrim(cValToChar(oAnalise:aCols[nLinha][aScan(aHAnalise,{|x| Alltrim(cValToChar(x[2])) == "FILIAL"})]))
	Local cBanco	:= Alltrim(cValToChar(oAnalise:aCols[nLinha][aScan(aHAnalise,{|x| Alltrim(cValToChar(x[2])) == "PORTAD"})]))
	Local nVlr		:= oAnalise:aCols[nLinha][nColuna]
	
	Local oDet		
	Local aHDet		:= {}
	Local aColsDet	:= {}
	Local aAltDet	:= {}
	
	Local oIntDet
	Local oFechar
	
	Local oCSVD
	Local oFont 	:= TFont():New(,,-14,,.T.)
	Local oTxtDetalhes

	//
	If cTitColum == "Portador" .Or. nVlr == 0
		RestArea(aArea)
		Return Nil
		
	EndIf
	
	//
	oIntDet			:= MsDialog():Create()
	oIntDet:cName     := "oIntDet"
	oIntDet:cCaption  := "Detalhes"
	oIntDet:nLeft     := 34
	oIntDet:nTop      := 222
	oIntDet:nWidth    := 1200
	oIntDet:nHeight   := 550
	oIntDet:lShowHint := .F.
	oIntDet:lCentered := .T.
		
		oCSVD := TButton():New(005,005,"CSV",oIntDet,{|| MsAguarde({|| grCPDCSV(oDet,aHDet,"CPD_DETALHE_" + cUserName + "_" + DToS(Date()) + "_" + StrTran(cValToChar(Time()),":","") + ".CSV")},"Aguarde","Gerando CSV...") },40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
		
		oTxtDetalhes := TSay():New(005,050,{||"Filial: " + cFil + " | Portador: " + cBanco  + " | Data: " + cTitColum + " | " + Iif(lCPagLvr,"C Pagar (Livre)","Borderô/Baixas")},oIntDet,,oFont,,,,.T.,CLR_RED,CLR_WHITE,260,25)
		
		nTotDet := 0
		oTotDet := TGet():New(005,525,{|u|If(PCount() == 0,nTotDet,nTotDet   := u)},oIntDet,070,010,"@E 999,999,999.99",,0,16777215,,.F.,,.T.,,.F.,{|| .F. },.F.,.F.,,.F.,.F. ,,"nTotDet",,,,.T.,,,"Total:",1) 
		
		Aadd(aHDet,{"Filial"   ,"FILIAL"   ,"",TamSX3("E2_FILIAL")[1] , 0,"","" ,"C","",""})
		Aadd(aHDet,{"Tipo"     ,"TIPO"     ,"",TamSX3("E2_TIPO")[1]   , 0,"","" ,"C","",""})
		Aadd(aHDet,{"Título"   ,"TITULO"   ,"",TamSX3("E2_NUM")[1]    , 0,"","" ,"C","",""})
		Aadd(aHDet,{"Parcela"  ,"PARC"     ,"",TamSX3("E2_PARCELA")[1], 0,"","" ,"C","",""})
		Aadd(aHDet,{"Natureza" ,"NAT"      ,"",TamSX3("E2_NATUREZ")[1], 0,"","" ,"C","",""})
		Aadd(aHDet,{"Cod. Forn","CODFOR"   ,"",TamSX3("E2_FORNECE")[1], 0,"","" ,"C","",""})
		Aadd(aHDet,{"Nome Forn","NMFOR"    ,"",TamSX3("E2_NOMFOR")[1], 0,"","" ,"C","",""})
		Aadd(aHDet,{"Emissão"  ,"EMISSAO"  ,"",10, 0,"","" ,"C","",""})
		Aadd(aHDet,{"Vencto"   ,"VENCTO"   ,"",10, 0,"","" ,"C","",""})
		Aadd(aHDet,{"Pagto"    ,"PAGTO"    ,"",TamSX3("E2_BAIXA")[1], 0,"","" ,"C","",""})
		
		Aadd(aHDet,{"Valor"    ,"VLR"  ,"@E 999,999,999.99" ,15, 2,"","" ,"N","",""})
		
		Aadd(aHDet,{"Situação" ,"SITUAC"     ,"",40, 0,"","" ,"C","",""})
		Aadd(aHDet,{"Bordero"  ,"BORDERO"    ,"",TamSX3("E2_NUMBOR")[1], 0,"","" ,"C","",""})
		Aadd(aHDet,{"Banco"    ,"BANCO"      ,"",15, 0,"","" ,"C","",""})
		Aadd(aHDet,{"Log.Dt-Hr","LOG"        ,"",TamSX3("E2_LOGDTHR")[1], 0,"","" ,"C","",""})
		Aadd(aHDet,{"Desc. Natureza","DESNAT","",40, 0,"","" ,"C","",""})
		Aadd(aHDet,{"Razão Social","RSOCIAL" ,"",40, 0,"","" ,"C","",""})
	
		
		oDet 	:= MsNewGetDados():New(030,005,240,595,,"Allwaystrue()","Allwaystrue()","",aAltDet,Nil,999,Nil,Nil,Nil,oIntDet,aHDet,@aColsDet)
	
		oFechar	 := TButton():New(245,550,"Fechar",oIntDet,{||oIntDet:End()},40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
		oFechar:SetCss("QPushButton{background-color: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1, stop: 0 #FF0000, stop: 1 #8C1717);color: white}")	
	
	oIntDet:Activate(,,,.T.,{||.T.},,{|| MsAguarde({|| carCPDDet(oDet,aHDet,dDataDe,dDataAte,cFil,cBanco,cCmpHeader,@nTotDet,oTotDet,cTitColum) },"Aguarde","Obtendo dados...") })

	//
	RestArea(aArea)
	
Return Nil

/*/{Protheus.doc} Static Function carCPDDet 
	Carrega dados do detalhe
	@type  Static Function
	@author Everson
	@since 07/06/2017
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@chamado n. 035557
/*/
Static Function carCPDDet(oDet,aHDet,dDataDe,dDataAte,cFil,cBanco,cData,nTotDet,oTotDet,cTitColum)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
	Local aArea		:= GetArea()
	Local cQuery	:= ""
	
	//
	cFil   		:= Alltrim(cValToChar(cFil))
	cBanco 		:= Alltrim(cValToChar(cBanco))
	cData  		:= Alltrim(cValToChar(cData))
	nTotDet		:= 0
	cTitColum	:= Alltrim(cValToChar(cTitColum))
	
	//
	cQuery := ""
	cQuery += " SELECT * FROM ( "
	
	cQuery += scriptCPD(dDataDe,dDataAte)
	
	cQuery += " ) AS FONTE "
	
	If ! Empty(cFil)
		
		cQuery += " WHERE FONTE.E2_FILIAL = '" + cFil + "' AND FONTE.E2_PORTADO = '" + cBanco + "' "
		
		If cTitColum <> "Total Geral"
			cQuery += " AND FONTE.PAGTO = '" + cData + "' "

		EndIf
		
	Else
		
		If "Total" $(cBanco)
			
			cFil := Alltrim(cValToChar(Substr(cBanco,At("Total",cBanco) + 5,Len(cBanco))))
			cQuery += " WHERE FONTE.E2_FILIAL = '" + cFil + "' "
		
			If cTitColum <> "Total Geral"
				cQuery += " AND FONTE.PAGTO = '" + cData + "' "
	
			EndIf
			
		
		ElseIf "Totais" $(cBanco)
			
			If cTitColum <> "Total Geral"
				cQuery += " WHERE FONTE.PAGTO = '" + cData + "' "
	
			EndIf
			
		
		EndIf 
	
	EndIf
	
	//
	If Select("D_DETALHE") > 0
		D_DETALHE->(DbCloseArea())
		
	EndIf
	
	//
	TcQuery cQuery New Alias "D_DETALHE"
	DbSelectArea("D_DETALHE")
	D_DETALHE->(DbGoTop())
	
	oDet:aCols := {}
	While ! D_DETALHE->(Eof())
	
		Aadd(oDet:aCols , Array(Len(aHDet) + 1) )
		oDet:aCols[Len(oDet:aCols), Len(oDet:aCols[1]) ] := .F.
		
		oDet:aCols[Len(oDet:aCols),Ascan(aHDet,{|x| AllTrim(x[2]) == "FILIAL" })] := D_DETALHE->E2_FILIAL
		oDet:aCols[Len(oDet:aCols),Ascan(aHDet,{|x| AllTrim(x[2]) == "TIPO"   })] := D_DETALHE->E2_TIPO
		oDet:aCols[Len(oDet:aCols),Ascan(aHDet,{|x| AllTrim(x[2]) == "TITULO" })] := D_DETALHE->E2_NUM
		oDet:aCols[Len(oDet:aCols),Ascan(aHDet,{|x| AllTrim(x[2]) == "PARC"   })] := D_DETALHE->E2_PARCELA
		oDet:aCols[Len(oDet:aCols),Ascan(aHDet,{|x| AllTrim(x[2]) == "NAT"    })] := D_DETALHE->E2_NATUREZ
		oDet:aCols[Len(oDet:aCols),Ascan(aHDet,{|x| AllTrim(x[2]) == "CODFOR" })] := D_DETALHE->E2_FORNECE
		oDet:aCols[Len(oDet:aCols),Ascan(aHDet,{|x| AllTrim(x[2]) == "NMFOR"  })] := D_DETALHE->E2_NOMFOR
		oDet:aCols[Len(oDet:aCols),Ascan(aHDet,{|x| AllTrim(x[2]) == "EMISSAO"})] := Iif(! Empty(Alltrim(cValToChar(D_DETALHE->E2_EMISSAO))), DToC(SToD(D_DETALHE->E2_EMISSAO)) ,Nil)
		oDet:aCols[Len(oDet:aCols),Ascan(aHDet,{|x| AllTrim(x[2]) == "VENCTO" })] := Iif(! Empty(Alltrim(cValToChar(D_DETALHE->E2_VENCREA))), DToC(SToD(D_DETALHE->E2_VENCREA)) ,Nil)
		oDet:aCols[Len(oDet:aCols),Ascan(aHDet,{|x| AllTrim(x[2]) == "PAGTO"  })] := Iif(! Empty(Alltrim(cValToChar(D_DETALHE->PAGTO))), DToC(SToD(D_DETALHE->PAGTO)) ,Nil)
		oDet:aCols[Len(oDet:aCols),Ascan(aHDet,{|x| AllTrim(x[2]) == "VLR"    })] := D_DETALHE->VALOR
		oDet:aCols[Len(oDet:aCols),Ascan(aHDet,{|x| AllTrim(x[2]) == "SITUAC" })] := D_DETALHE->SITUAC
		oDet:aCols[Len(oDet:aCols),Ascan(aHDet,{|x| AllTrim(x[2]) == "BORDERO"})] := D_DETALHE->E2_NUMBOR
		oDet:aCols[Len(oDet:aCols),Ascan(aHDet,{|x| AllTrim(x[2]) == "BANCO"  })] := D_DETALHE->E2_PORTADO
		oDet:aCols[Len(oDet:aCols),Ascan(aHDet,{|x| AllTrim(x[2]) == "LOG"    })] := D_DETALHE->E2_LOGDTHR
		oDet:aCols[Len(oDet:aCols),Ascan(aHDet,{|x| AllTrim(x[2]) == "DESNAT" })] := D_DETALHE->ED_DESCRIC
		oDet:aCols[Len(oDet:aCols),Ascan(aHDet,{|x| AllTrim(x[2]) == "RSOCIAL"})] := D_DETALHE->A2_NOME
		
		nTotDet += D_DETALHE->VALOR
		
		D_DETALHE->(DbSkip())
		
	EndDo
	
	DbCloseArea("D_DETALHE")
	
	//
	If Len(oDet:aCols) == 0
	
		Aadd(oDet:aCols , Array(Len(aHDet) + 1) )
		oDet:aCols[Len(oDet:aCols), Len(oDet:aCols[1]) ] := .F.
		
		oDet:aCols[Len(oDet:aCols),Ascan(aHDet,{|x| AllTrim(x[2]) == "FILIAL" })] := ""
		oDet:aCols[Len(oDet:aCols),Ascan(aHDet,{|x| AllTrim(x[2]) == "TIPO"   })] := ""
		oDet:aCols[Len(oDet:aCols),Ascan(aHDet,{|x| AllTrim(x[2]) == "TITULO" })] := ""
		oDet:aCols[Len(oDet:aCols),Ascan(aHDet,{|x| AllTrim(x[2]) == "PARC"   })] := ""
		oDet:aCols[Len(oDet:aCols),Ascan(aHDet,{|x| AllTrim(x[2]) == "NAT"    })] := ""
		oDet:aCols[Len(oDet:aCols),Ascan(aHDet,{|x| AllTrim(x[2]) == "CODFOR" })] := ""
		oDet:aCols[Len(oDet:aCols),Ascan(aHDet,{|x| AllTrim(x[2]) == "NMFOR"  })] := ""
		oDet:aCols[Len(oDet:aCols),Ascan(aHDet,{|x| AllTrim(x[2]) == "EMISSAO"})] := ""
		oDet:aCols[Len(oDet:aCols),Ascan(aHDet,{|x| AllTrim(x[2]) == "VENCTO" })] := ""
		oDet:aCols[Len(oDet:aCols),Ascan(aHDet,{|x| AllTrim(x[2]) == "PAGTO"  })] := ""
		oDet:aCols[Len(oDet:aCols),Ascan(aHDet,{|x| AllTrim(x[2]) == "VLR"    })] := 0
		oDet:aCols[Len(oDet:aCols),Ascan(aHDet,{|x| AllTrim(x[2]) == "SITUAC" })] := ""
		oDet:aCols[Len(oDet:aCols),Ascan(aHDet,{|x| AllTrim(x[2]) == "BORDERO"})] := ""
		oDet:aCols[Len(oDet:aCols),Ascan(aHDet,{|x| AllTrim(x[2]) == "BANCO"  })] := ""
		oDet:aCols[Len(oDet:aCols),Ascan(aHDet,{|x| AllTrim(x[2]) == "LOG"    })] := ""
		oDet:aCols[Len(oDet:aCols),Ascan(aHDet,{|x| AllTrim(x[2]) == "DESNAT" })] := ""
		oDet:aCols[Len(oDet:aCols),Ascan(aHDet,{|x| AllTrim(x[2]) == "RSOCIAL"})] := ""
	
	EndIf
	
	//
	oDet:Refresh()
	oTotDet:Refresh()
	
	//
	RestArea(aArea)
	
Return Nil

/*/{Protheus.doc} Static Function getColor 
	Atribui cor a msnewgetdados
	@type  Static Function
	@author Everson
	@since 07/06/2017
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@chamado n. 035557
/*/
Static Function getColor(aLinha,nLinha,aHeader)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
	Local aArea		:= GetArea()
	
	Local nCor2 	:= 16776960
	Local nCor3 	:= 16777215
	Local nPosProd 	:= aScan(aHeader,{|x| Alltrim(x[2]) == "FILIAL"})
	Local nUsado 	:= Len(aHeader)+1
	Local nRet		:= nCor3
	
	//
	If Empty(aLinha[nLinha][nPosProd])
	     nRet := nCor2
	     
	Endif

	//
	RestArea(aArea)
	
Return nRet

/*/{Protheus.doc} Static Function ordenaGrid
	Ordena grid msnewgetdados
	@type  Static Function
	@author Everson
	@since 07/06/2017
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@chamado n. 035557
/*/
Static Function ordenaGrid(oGrid,aColsGrid,nCol,aHGrid) 

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
	Local aArea	:= GetArea()
	Local lOrd	:= .T.
	Local nPos	:= 0
	
	//
	nPos := 0
	nPos :=  aScan(aOrderBase,{|x| x[1] == nCol })
	If nPos > 0
		lOrd := aOrderBase[nPos][2]
		lOrd := Iif(lOrd,.F.,.T.)
		aOrderBase[nPos][2] := lOrd
		
	Else
		Aadd(aOrderBase,{nCol,.T.})
		lOrd := .T.
	
	EndIf

	//
	If aHGrid[nCol][8] == "N"

		If lOrd
			aColsGrid := aSort(aColsGrid,,,{|x,y| x[nCol] <  y[nCol] })
		
		Else
			aColsGrid := aSort(aColsGrid,,,{|x,y| x[nCol] >  y[nCol] })
		
		EndIf
	
	Else
		
		If lOrd
			aColsGrid := aSort(aColsGrid,,,{|x,y| cValToChar(x[nCol]) <  cValToChar(y[nCol]) })
		
		Else
			aColsGrid := aSort(aColsGrid,,,{|x,y| cValToChar(x[nCol]) >  cValToChar(y[nCol]) })
		
		EndIf
	
	EndIf
	
    oGrid:setArray(aColsGrid,.T.) 
    oGrid:oBrowse:Refresh() 

	//
	RestArea(aArea)
	
Return Nil

/*/{Protheus.doc} Static Function scriptCPD  
	Script Sql CPD
	@type  Static Function
	@author Everson
	@since 07/06/2017
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@chamado n. 035557
/*/
Static Function scriptCPD(dDataDe,dDataAte)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
	Local aArea		:= GetArea()
	Local cQuery	:= ""
	
	// Chamado n. ³ 051182 || OS 052502 || FINANCAS || FLAVIA || 8461 || REL.PAGAMENTO - fwnm - 16/09/2019
	If AllTrim(FunName())=="ADFIN079R"
		lCPagLvr := .f.
	EndIf
	//
	
	//Base Pagar 1.
	cQuery := ""
	cQuery += " SELECT  " 
	cQuery += " CASE WHEN E2_FILIAL IN ('01','02','06') THEN 'VP' ELSE CASE WHEN E2_FILIAL IN ('03','04','05','09') THEN 'SC' ELSE E2_FILIAL END END AS E2_FILIAL  " 
	cQuery += " ,E2_TIPO " 
	cQuery += " ,E2_NUM " 
	cQuery += " ,E2_NUMBCO " 
	cQuery += " ,E2_PARCELA " 
	cQuery += " ,E2_NATUREZ " 
	cQuery += " ,E2_FORNECE " 
	cQuery += " ,E2_NOMFOR " 
	cQuery += " ,E2_EMISSAO " 
	cQuery += " ,E2_VENCREA " 
	cQuery += " ,E2_VENCREA AS PAGTO " 
	cQuery += " ,(E2_SALDO + E2_ACRESC - E2_DECRESC) AS VALOR "           //Mauricio - 25/08/17 - Chamado 036867 - Incluido Descrescimo
	cQuery += " ,'BORD' AS SITUAC " 
	cQuery += " ,E2_PORTADO " 
	cQuery += " ,E2_LOGDTHR " 
	cQuery += " ,ED_DESCRIC " 
	cQuery += " ,A2_NOME, E2_NUMBOR "
	
	// Chamado n. 051182 || OS 052502 || FINANCAS || FLAVIA || 8461 || REL.PAGAMENTO - fwnm - 13/09/2019
	cQuery += " ,E2_FILIAL E2_FIL, E2_PREFIXO, E2_LOJA " 
	//
	 
	cQuery += " FROM  " 
	cQuery += " " + RetSqlName("SE2") + " (NOLOCK) AS SE2 " 
	cQuery += " LEFT JOIN " + RetSqlName("SED") + " (NOLOCK) AS NAT  " 
	cQuery += " ON NAT.ED_CODIGO = E2_NATUREZ " 
	cQuery += " LEFT JOIN " + RetSqlName("SA2") + " (NOLOCK) AS CAD  " 
	cQuery += " ON CAD.A2_COD = E2_FORNECE  " 
	cQuery += " AND CAD.A2_LOJA = E2_LOJA " 
	cQuery += " WHERE  " 
	cQuery += " SE2.D_E_L_E_T_ = '' " 
	cQuery += " AND NAT.D_E_L_E_T_= '' " 
	cQuery += " AND CAD.D_E_L_E_T_= '' " 
	cQuery += " AND E2_SALDO > 0 " 
	cQuery += " AND E2_RJ = '' " 
	cQuery += " AND E2_VENCREA >= '" + DToS(dDataDe) + "' " 
	cQuery += " AND E2_VENCREA <= '" + DToS(dDataAte) + "' " 
	cQuery += " AND E2_PORTADO <> '' " 
	cQuery += " AND E2_TIPO NOT IN ('PA','NDF') " 

	cQuery += " UNION ALL " 
	
	//Base Pagar 2 (Somente PA).
	cQuery += " SELECT  " 
	cQuery += " CASE WHEN E2_FILIAL IN ('01','02','06') THEN 'VP' ELSE CASE WHEN E2_FILIAL IN ('03','04','05','09') THEN 'SC' ELSE E2_FILIAL END END AS E2_FILIAL  " 
	cQuery += " ,E2_TIPO " 
	cQuery += " ,E2_NUM " 
	cQuery += " ,E2_NUMBCO " 
	cQuery += " ,E2_PARCELA " 
	cQuery += " ,E2_NATUREZ " 
	cQuery += " ,E2_FORNECE " 
	cQuery += " ,E2_NOMFOR " 
	cQuery += " ,E2_EMISSAO " 
	cQuery += " ,E2_VENCREA " 
	cQuery += " ,E2_VENCREA " 
	cQuery += " ,(E2_SALDO + E2_ACRESC - E2_DECRESC) AS VALOR "           //Mauricio - 25/08/17 - Chamado 036867 - Incluido Descrescimo
	cQuery += " ,'BORD' AS BORD " 
	cQuery += " ,E2_PORTADO " 
	cQuery += " ,E2_LOGDTHR " 
	cQuery += " ,ED_DESCRIC " 
	cQuery += " ,A2_NOME, E2_NUMBOR " 

	// Chamado n. 051182 || OS 052502 || FINANCAS || FLAVIA || 8461 || REL.PAGAMENTO - fwnm - 13/09/2019
	cQuery += " ,E2_FILIAL E2_FIL, E2_PREFIXO, E2_LOJA " 
	//

	cQuery += " FROM  " 
	cQuery += " " + RetSqlName("SE2") + " (NOLOCK) AS SE2 " 
	cQuery += " LEFT JOIN " + RetSqlName("SED") + " (NOLOCK) AS NAT  " 
	cQuery += " ON NAT.ED_CODIGO = E2_NATUREZ " 
	cQuery += " LEFT JOIN " + RetSqlName("SA2") + " (NOLOCK) AS CAD  " 
	cQuery += " ON CAD.A2_COD = E2_FORNECE  " 
	cQuery += " AND CAD.A2_LOJA = E2_LOJA " 
	cQuery += " WHERE  " 
	cQuery += " SE2.D_E_L_E_T_ = '' " 
	cQuery += " AND NAT.D_E_L_E_T_= '' " 
	cQuery += " AND CAD.D_E_L_E_T_= '' " 
	cQuery += " AND E2_SALDO > 0 " 
	cQuery += " AND E2_RJ = '' " 
	cQuery += " AND E2_VENCREA >= '" + DToS(dDataDe) + "' " 
	cQuery += " AND E2_VENCREA <= '" + DToS(dDataAte) + "' " 
	cQuery += " AND E2_PORTADO <> '' " 
	cQuery += " AND E2_NUMBOR <> '' " 
	cQuery += " AND E2_TIPO IN ('PA') " 

	// Chamado n. 051182 || OS 052502 || FINANCAS || FLAVIA || 8461 || REL.PAGAMENTO - fwnm - 13/09/2019
	//    cQuery += " AND E2_NUM  NOT IN (SELECT E5_NUMERO FROM SE5010 AS SE5_PA WHERE E5_FILIAL = SE2.E2_FILIAL AND E5_PREFIXO = SE2.E2_PREFIXO AND E5_NUMERO = SE2.E2_NUM AND E5_PARCELA = SE2.E2_PARCELA AND E5_TIPO = SE2.E2_TIPO AND E5_CLIFOR = SE2.E2_FORNECE AND E5_LOJA = SE2.E2_LOJA AND (E5_TIPO+E5_TIPODOC+E5_RECPAG) = 'PA PAP' AND E5_VALOR = SE2.E2_VALOR AND SE5_PA.D_E_L_E_T_ <> '*') "
	 cQuery += " AND E2_NUM  NOT IN (SELECT E5_NUMERO FROM " + RetSqlName("SE5") + " AS SE5_PA WHERE E5_FILIAL = SE2.E2_FILIAL AND E5_PREFIXO = SE2.E2_PREFIXO AND E5_NUMERO = SE2.E2_NUM AND E5_PARCELA = SE2.E2_PARCELA AND E5_TIPO = SE2.E2_TIPO AND E5_CLIFOR = SE2.E2_FORNECE AND E5_LOJA = SE2.E2_LOJA AND (E5_TIPO+E5_TIPODOC+E5_RECPAG) = 'PA PAP' AND E5_VALOR = SE2.E2_VALOR AND SE5_PA.D_E_L_E_T_ <> '*') "
    //
	cQuery += " UNION ALL " 
	
	//Base Pagamentos.
	cQuery += " SELECT " 
	cQuery += " CASE WHEN E5_FILIAL IN ('01','02','06') THEN 'VP' ELSE CASE WHEN E5_FILIAL IN ('03','04','05','09') THEN 'SC' ELSE E5_FILIAL END END AS E5_FILIAL " 
	cQuery += " ,E5_TIPO " 
	cQuery += " ,E5_NUMERO " 
	cQuery += " ,E5_NUMCHEQ " 
	cQuery += " ,E5_PARCELA " 
	cQuery += " ,E5_NATUREZ " 
	cQuery += " ,E5_CLIFOR " 
	cQuery += " ,E5_BENEF " 
	cQuery += " ,'' " 
	cQuery += " ,'' " 
	cQuery += " ,E5_DATA " 
	cQuery += " ,E5_VALOR " 
	cQuery += " ,'BX_MAN' AS BX_MAN " 
	cQuery += " ,E5_BANCO " 
	cQuery += " ,'' " 
	cQuery += " ,ED_DESCRIC " 
	cQuery += " ,A2_NOME, '' AS E2_NUMBOR " 

	// Chamado n. 051182 || OS 052502 || FINANCAS || FLAVIA || 8461 || REL.PAGAMENTO - fwnm - 13/09/2019
	cQuery += " ,E5_FILIAL E2_FILIAL, E5_PREFIXO E2_PREFIXO, E5_LOJA E2_LOJA " 
	//

	cQuery += " FROM " 
	cQuery += " " + RetSqlName("SE5") + " AS SE5 " 
	cQuery += " LEFT JOIN  " 
	cQuery += " " + RetSqlName("SED") + " NAT  " 
	cQuery += " ON " 
	cQuery += " NAT.ED_CODIGO = E5_NATUREZ " 
	cQuery += " AND NAT.D_E_L_E_T_='' " 
	cQuery += " LEFT JOIN  " 
	cQuery += " " + RetSqlName("SA2") + " CAD  " 
	cQuery += " ON CAD.A2_COD = E5_CLIFOR  " 
	cQuery += " AND CAD.A2_LOJA = E5_LOJA  " 
	cQuery += " AND CAD.D_E_L_E_T_='' " 
	cQuery += " WHERE  " 
	cQuery += " SE5.D_E_L_E_T_= '' " 
	cQuery += " AND E5_DATA>= GETDATE()-30 " 
	cQuery += " AND E5_RECPAG='P'  " 
	cQuery += " AND E5_TIPODOC NOT IN ('ES','DC','C2','MT','M2','E2','JR','J2') " // Chamado n. 054604 || OS 055999 || FINANCAS || FLAVIA || 8461 || REL. PAGAMENTOS - FWNM - 03/01/2020
	cQuery += " AND E5_SITUACA='' " 
	cQuery += " AND E5_MOTBX IN ('NOR','DEB') " 
	cQuery += " AND E5_DATA >= '" + DToS(dDataDe) + "' " 
	cQuery += " AND E5_DATA <= '" + DToS(dDataAte) + "' " 

	cQuery += " UNION ALL " 
	
	//Base Estorno.
	cQuery += " SELECT  " 
	cQuery += " CASE WHEN E5_FILIAL IN ('01','02','06') THEN 'VP' ELSE CASE WHEN E5_FILIAL IN ('03','04','05','09') THEN 'SC' ELSE E5_FILIAL END END AS E5_FILIAL " 
	cQuery += " ,E5_TIPO " 
	cQuery += " ,E5_NUMERO " 
	cQuery += " ,E5_NUMCHEQ " 
	cQuery += " ,E5_PARCELA " 
	cQuery += " ,E5_NATUREZ " 
	cQuery += " ,E5_CLIFOR " 
	cQuery += " ,E5_BENEF " 
	cQuery += " ,'' " 
	cQuery += " ,'' " 
	cQuery += " ,E5_DATA " 
	cQuery += " ,E5_VALOR * -1 AS E5_VALOR " 
	cQuery += " ,'EST BX' AS EST_BX " 
	cQuery += " ,E5_BANCO " 
	cQuery += " ,'' " 
	cQuery += " ,ED_DESCRIC " 
	cQuery += " ,A2_NOME, '' AS E2_NUMBOR " 

	// Chamado n. 051182 || OS 052502 || FINANCAS || FLAVIA || 8461 || REL.PAGAMENTO - fwnm - 13/09/2019
	cQuery += " ,E5_FILIAL E2_FIL, E5_PREFIXO E2_PREFIXO, E5_LOJA E2_LOJA " 
	//

	cQuery += " FROM  " 
	cQuery += " " + RetSqlName("SE5") + " (NOLOCK) AS SE5 " 
	cQuery += " LEFT JOIN  " 
	cQuery += " " + RetSqlName("SED") + " (NOLOCK) NAT  " 
	cQuery += " ON (NAT.ED_CODIGO = E5_NATUREZ) AND (NAT.D_E_L_E_T_='') " 
	cQuery += " LEFT JOIN  " 
	cQuery += " " + RetSqlName("SA2") + " (NOLOCK) CAD  " 
	cQuery += " ON (CAD.A2_COD = E5_CLIFOR) AND (CAD.A2_LOJA = E5_LOJA) AND (CAD.D_E_L_E_T_='') " 
	cQuery += " WHERE  " 
	cQuery += " E5_DATA >= GETDATE()-30 " 
	cQuery += " AND E5_TIPODOC='ES' " 
	cQuery += " AND E5_RECPAG='R' " 
	cQuery += " AND SE5.D_E_L_E_T_='' " 
	cQuery += " AND E5_DATA >= '" + DToS(dDataDe) + "' " 
	cQuery += " AND E5_DATA <= '" + DToS(dDataAte) + "' " 
	cQuery += " AND E5_BANCO <> '' " 
	
	//
	If lCPagLvr
	
		cQuery += " UNION ALL " 
		cQuery += " SELECT  " 
		cQuery += " CASE WHEN E2_FILIAL IN ('01','02','06') THEN 'VP' ELSE CASE WHEN E2_FILIAL IN ('03','04','05','09') THEN 'SC' ELSE E2_FILIAL END END AS E2_FILIAL  " 
		cQuery += " ,E2_TIPO " 
		cQuery += " ,E2_NUM " 
		cQuery += " ,E2_NUMBCO " 
		cQuery += " ,E2_PARCELA " 
		cQuery += " ,E2_NATUREZ " 
		cQuery += " ,E2_FORNECE " 
		cQuery += " ,E2_NOMFOR " 
		cQuery += " ,E2_EMISSAO " 
		cQuery += " ,E2_VENCREA " 
		cQuery += " ,E2_VENCREA AS PAGTO " 
		cQuery += " ,(E2_SALDO + E2_ACRESC - E2_DECRESC) AS VALOR "      //Mauricio - 25/08/17 - Chamado 036867 - Incluido Descrescimo
		cQuery += " ,'Ñ AGEND' AS BORD " 
		cQuery += " ,'SEM BCO' " 
		cQuery += " ,E2_LOGDTHR " 
		cQuery += " ,'' " 
		cQuery += " ,'', E2_NUMBOR " 

		// Chamado n. 051182 || OS 052502 || FINANCAS || FLAVIA || 8461 || REL.PAGAMENTO - fwnm - 13/09/2019
		cQuery += " ,E2_FILIAL E2_FIL, E2_PREFIXO, E2_LOJA " 
		//

		cQuery += " FROM  " 
		cQuery += " " + RetSqlName("SE2") + " (NOLOCK) AS SE2 " 
		cQuery += " LEFT JOIN  " + RetSqlName("SED") + "  (NOLOCK) AS NAT  " 
		cQuery += " ON NAT.ED_CODIGO = E2_NATUREZ " 
		cQuery += " LEFT JOIN  " + RetSqlName("SA2") + "  (NOLOCK) AS CAD  " 
		cQuery += " ON CAD.A2_COD = E2_FORNECE  " 
		cQuery += " AND CAD.A2_LOJA = E2_LOJA " 
		cQuery += " WHERE  " 
		cQuery += " SE2.D_E_L_E_T_ = '' " 
		cQuery += " AND NAT.D_E_L_E_T_= '' " 
		cQuery += " AND CAD.D_E_L_E_T_= '' " 
		cQuery += " AND E2_SALDO > 0 " 
		cQuery += " AND E2_RJ = '' " 
		cQuery += " AND E2_VENCREA >= '" + DToS(dDataDe) + "' " 
		cQuery += " AND E2_VENCREA <= '" + DToS(dDataAte) + "' "
		cQuery += " AND E2_PORTADO = '' " 
		cQuery += " AND E2_TIPO NOT IN ('PA','NDF') " 
	
	EndIf
	
	//
	RestArea(aArea)
	
Return cQuery

/*/{Protheus.doc} Static Function grCPDCSV  
	Gera arquivo CSV a partir do objeto msnewgetdados
	@type  Static Function
	@author Everson
	@since 07/06/2017
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@chamado n. 035557
/*/
Static Function grCPDCSV(oRegistros,aHReg,cArq)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
	Local aArea		:= GetArea()
	Local i			:= 1
	Local w			:= 1
	Local cDir		:= ""
	Local nHdl
	Local cEof		:= Chr(13) + Chr(10)
	Local cLin		:= ""
	
	cDir := cGetFile("Arquivo CSV.", "Selecione o diretório para salvar o CSV",,'C:\',.T.,GETF_RETDIRECTORY + GETF_LOCALHARD + GETF_NETWORKDRIVE)
	
	//
	If Empty(Alltrim(cValToChar(cDir)))
		Return Nil
		
	EndIf
	
	//Cria o arquivo no disco.
	nHdl := FCreate(cDir + cArq,0)
	
	//Verifica se foi possível criar o arquivo.
	If nHdl == -1
    	MsgAlert("O Arquivo não " + cArq + " pode ser criado:" + cEof + STR(FERROR()),"Função grCPDCSV")
		Return Nil
		
	EndIf
	
	//
	cLin := ""
	For i := 1 To Len(aHReg)
		cLin += cValToChar(aHReg[i][1]) + ";"
	
	Next i
	
	cLin += cEof
	
	For i := 1 To Len(oRegistros:aCols)
	
		For w := 1 To Len(aHReg)
			
			If Alltrim(cValToChar(aHReg[w][8])) == "N"
			
				cLin += Transform(Val(cValToChar(oRegistros:aCols[i][w])),"@E 999,999,999.99") + ";"
				
			Else
				cLin += cValToChar(oRegistros:aCols[i][w]) + ";"
			
			EndIf
		
		Next w
		
		cLin += cEof
		
		FWrite(nHdl,cLin,Len(cLin))
		
		cLin := ""
	
	Next i
	
	//Fecha o arquivo.
	FClose(nHdl)
	
	//
	WinExec("Explorer.exe" + Space(1) + cDir )
	
	//
	MsgInfo("Arquivo gerado.","Função grCPDCSV")
	
	//
	RestArea(aArea)

Return Nil

/*/{Protheus.doc} Static Function logAcesso
	Log de acesso de rotina
	@type  Static Function
	@author Everson
	@since 07/06/2017
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@chamado n. 035557
/*/
Static Function logAcesso(cRotina)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
	Local aArea		:= GetArea()
	
	cRotina := Alltrim(cValToChar(cRotina))

	//Log.
	RecLock("ZBE",.T.)
		ZBE->ZBE_FILIAL := xFilial("SE1")
		ZBE->ZBE_DATA	:= Date()
		ZBE->ZBE_HORA	:= cValToChar(Time())
		ZBE->ZBE_USUARI	:= cUserName
		ZBE->ZBE_LOG	:= "ACESSO A ROTINA " + cRotina
		ZBE->ZBE_MODULO	:= "FINANCEIRO"
		ZBE->ZBE_ROTINA	:= "ADFIN033P"
	MsUnlock()
	
	RestArea(aArea)
	
Return Nil

/*/{Protheus.doc} u_FIN033A0
Ticket 70142 - Substituicao de funcao Static Call por User Function MP 12.1.33
@type function
@version 1.0
@author Edvar   / Flek Solution
@since 16/03/2022
@history Ticket 70142  - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
/*/
Function u_FIN033A0( uPar1, uPar2 )
Return( scriptCPD( uPar1, uPar2 ) )
