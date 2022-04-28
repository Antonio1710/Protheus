#Include "Protheus.ch"
#include "TopConn.CH"

/*/{Protheus.doc} User Function ADLOG079R
	Relatorio de pedidos reprogramados.
	@type  Function
	@author Everson
	@since 26/04/2022
	@version version
/*/
User Function ADLOG079R() 

    //Variáveis.
    Local aArea := GetArea()
	Local oReport := Nil
	Local cPerg := "ADLOG079R" 
	
	If ! Pergunte(cPerg,.T.)
        RestArea(aArea)
        Return Nil

    EndIf
	
	oReport := RptStruc(cPerg)
	oReport:PrintDialog()

    RestArea(aArea)

Return Nil
/*/{Protheus.doc} RPTStruc
    Gera estrutura do relatório.
    @type  Static Function
    @author Everson
    @since 26/04/2022
    @version 01
/*/
Static Function RPTStruc(cPerg)

    //Variáveis.
    Local cNome     := "ADLOG079R"
    Local cTitulo   := "Relatório de Pedidos Reprogramados"
	Local oReport   := Nil
	Local oSection1 := Nil
	
	oReport := TReport():New(cNome,cTitulo, cPerg,{|oReport| RPTPRINT(oReport)},cTitulo)
	oReport:SetLandscape(.T.)
	
	oSection1 := TRSection():New(oReport, "Pedidos",{"SC5"}, ,.F.,.T.)

	TRCell():New(oSection1,"PEDIORG"    ,"D_PED","Nº Pedido Original"    ,"@!",06)
	TRCell():New(oSection1,"DTENORG"    ,"D_PED","Dt Entrega Original"	 ,"@!",10)
	TRCell():New(oSection1,"PLCORG"     ,"D_PED","Placa Original" ,"@!",07)
	TRCell():New(oSection1,"ROTEORG"    ,"D_PED","Roteiro Original" ,"@!",04)
	TRCell():New(oSection1,"PEDREP"     ,"D_PED","Nº Pedido Repr.","@!",06)
	TRCell():New(oSection1,"DTEMIREP"   ,"D_PED","Dt Emissão","@!",10)
	TRCell():New(oSection1,"HREMISS"    ,"D_PED","Hr Emissão","@!",08)
	TRCell():New(oSection1,"PESTOTAL"   ,"D_PED","Peso Total","@E 999,999,999.999",15)
	TRCell():New(oSection1,"QTDCAIXA"   ,"D_PED","Qtd Caixas","@E 99,999",06)
	TRCell():New(oSection1,"CLILOJA"    ,"D_PED","Cli/Loja","@!",08)
	TRCell():New(oSection1,"NMCLI"      ,"D_PED","Nome","@!",60)
	TRCell():New(oSection1,"DEENTREP"   ,"D_PED","Dt Entrega","@!",10)
	TRCell():New(oSection1,"PLCREP"     ,"D_PED","Placa","@!",07)
	TRCell():New(oSection1,"ROTEREP"    ,"D_PED","Roteiro" ,"@!",04)

Return (oReport)
/*/{Protheus.doc} RPTPrint
    Gera relatório.
    @type  Static Function
    @author Everson
    @since 26/04/2022
    @version 01
/*/
Static Function RPTPrint(oReport)

    //Variáveis.
	Local oSection1 := oReport:Section(1)
	Local cQuery    := ""
	
	cQuery += " SELECT  " 

	cQuery += " PEDRPR.C5_NUM, PEDRPR.C5_EMISSAO, PEDRPR.C5_HRINCLU, PEDRPR.C5_PBRUTO, PEDRPR.C5_VOLUME1, PEDRPR.C5_CLIENTE, PEDRPR.C5_LOJACLI, PEDRPR.C5_NOMECLI, PEDRPR.C5_DTENTR, PEDRPR.C5_PLACA, PEDRPR.C5_ROTEIRO, " 
	
	cQuery += " PEDORG.C5_NUM AS PEDORG, PEDORG.C5_DTENTR AS DTENTORG, PEDORG.C5_PLACA AS PLACAORG, PEDORG.C5_ROTEIRO AS ROTORG " 
	
	cQuery += " FROM  " 

	cQuery += " " + RetSqlName("SC5") + " (NOLOCK) AS PEDRPR  " 
	cQuery += " LEFT OUTER JOIN " 
	cQuery += " ( SELECT * FROM " + RetSqlName("SC5") + " (NOLOCK) AS SC5 WHERE C5_FILIAL = '" + FWxFilial("SC5") + "' AND SC5.D_E_L_E_T_ = '' ) AS PEDORG ON " 
	
	cQuery += " PEDRPR.C5_FILIAL = PEDORG.C5_FILIAL " 
	cQuery += " AND PEDRPR.C5_XPDEVOR = PEDORG.C5_NUM " 
	cQuery += " WHERE  " 
	cQuery += " PEDRPR.C5_FILIAL = '" + FWxFilial("SC5") + "'  " 
	cQuery += " AND PEDRPR.C5_PRIOR = 'R'  " 
	cQuery += " AND PEDRPR.C5_DTENTR BETWEEN '" + DToS(MV_PAR01) + "' AND '" + DToS(MV_PAR02) + "' " 
	cQuery += " AND PEDRPR.D_E_L_E_T_ = '' " 

	cQuery += " ORDER BY PEDRPR.C5_NUM  " 
	
	If Select("D_PED") > 0
		D_PED->(DbCloseArea())

	EndIf
			
	TcQuery cQuery New Alias "D_PED"
    TCSetField("D_PED", "DTENTORG", "D")
    TCSetField("D_PED", "C5_EMISSAO", "D")
    TCSetField("D_PED", "C5_DTENTR", "D")
			
	DbSelectArea("D_PED")
	D_PED->(DbGoTop())

	oReport:SetMeter(Contar("D_PED","!Eof()"))

    D_PED->(DbGoTop())

    oSection1:Init()
			
	While ! D_PED->(Eof())
        

		If oReport:Cancel()
			Exit

		EndIf

		oReport:IncMeter()
			
		oSection1:Cell("PEDIORG"):SetValue(D_PED->PEDORG)
		oSection1:Cell("DTENORG"):SetValue(DToC(D_PED->DTENTORG))	
		oSection1:Cell("PLCORG"):SetValue(D_PED->PLACAORG)	
		
		oSection1:Cell("PEDREP"):SetValue(D_PED->C5_NUM)	
		oSection1:Cell("DTEMIREP"):SetValue(DToC(D_PED->C5_EMISSAO))	
		oSection1:Cell("HREMISS"):SetValue(D_PED->C5_HRINCLU)	
		oSection1:Cell("PESTOTAL"):SetValue(D_PED->C5_PBRUTO)	
		oSection1:Cell("QTDCAIXA"):SetValue(D_PED->C5_VOLUME1)	
		oSection1:Cell("CLILOJA"):SetValue(D_PED->C5_CLIENTE + D_PED->C5_LOJACLI)	
		oSection1:Cell("NMCLI"):SetValue(D_PED->C5_NOMECLI)	
		oSection1:Cell("DEENTREP"):SetValue(DToC(D_PED->C5_DTENTR))	
		oSection1:Cell("PLCREP"):SetValue(D_PED->C5_PLACA)	

		oSection1:Cell("ROTEORG"):SetValue(D_PED->ROTORG)	
		oSection1:Cell("ROTEREP"):SetValue(D_PED->C5_ROTEIRO)	

		oSection1:Printline()	


        D_PED->(DbSkip())	
			
	End

    oSection1:Finish()	
			
Return Nil
