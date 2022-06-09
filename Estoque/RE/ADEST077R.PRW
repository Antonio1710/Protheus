#Include "Protheus.ch"
#include "TopConn.CH"

/*/{Protheus.doc} User Function ADEST077R
	Relatorio de pesagem de ração.
	@type  Function
	@author Everson
	@since 31/05/2022
	@version version
	@history, Everson, 09/06/20222, ticket 18465 - Adicionado filtro por placa.
/*/
User Function ADEST077R() 

    //Variáveis.
    Local aArea := GetArea()
	Local oReport := Nil
	Local cPerg := "ADEST077R" 
	
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
    @since 31/05/2022
    @version 01
/*/
Static Function RPTStruc(cPerg)

    //Variáveis.
    Local cNome     := "ADEST077R"
    Local cTitulo   := "Lista de Pesagem"
	Local oReport   := Nil
	Local oSection1 := Nil
	
	oReport := TReport():New(cNome,cTitulo, cPerg,{|oReport| RPTPRINT(oReport)},cTitulo)
	oReport:SetLandscape(.T.)
	
	oSection1 := TRSection():New(oReport, "Pedidos",{"SC5"}, ,.F.,.T.)

	TRCell():New(oSection1,"ROTEIRO" ,"D_LISTA","Roteiro"    ,"@!",10)
	TRCell():New(oSection1,"ORDERAC" ,"D_LISTA","Ord Ração"  ,"@!",10)
	TRCell():New(oSection1,"ORDEPES" ,"D_LISTA","Ord Pesagem","@!",15)
	TRCell():New(oSection1,"TICKET"  ,"D_LISTA","Ticket"     ,"@!",10)
	TRCell():New(oSection1,"DATAINI" ,"D_LISTA","Dt Pesagem inicial" ,"@!",10)
	TRCell():New(oSection1,"HORAINI" ,"D_LISTA","Hr Pesagem inicial" ,"@!",08)
	TRCell():New(oSection1,"DATAFIM" ,"D_LISTA","Dt Pesagem final"	 ,"@!",10)
	TRCell():New(oSection1,"HORAFIM" ,"D_LISTA","Hr Pesagem final"	 ,"@!",08)
	TRCell():New(oSection1,"PLACA"   ,"D_LISTA","Placa"	 ,"@!",15)
	TRCell():New(oSection1,"GRANJA"  ,"D_LISTA","Granja" ,"@!",15)
	TRCell():New(oSection1,"PRODUTO" ,"D_LISTA","Produto","@!",15)
	TRCell():New(oSection1,"LOTE"    ,"D_LISTA","Lote"   ,"@!",15)
	TRCell():New(oSection1,"PESO"    ,"D_LISTA","Peso"   ,"@!",15)
	TRCell():New(oSection1,"SILO"    ,"D_LISTA","Silo"   ,"@!",04)

Return (oReport)
/*/{Protheus.doc} RPTPrint
    Gera relatório.
    @type  Static Function
    @author Everson
    @since 31/05/2022
    @version 01
/*/
Static Function RPTPrint(oReport)

    //Variáveis.
	Local oSection1 := oReport:Section(1)
	Local cQuery    := ""

    cQuery += " SELECT " 
        cQuery += " ZIF_ROTEIR, " 
        cQuery += " ZIR_NUMERO, " 
        cQuery += " ZIF_NUMERO, " 
        cQuery += " ZIG_NUMERO, ZIG_DTPES1, ZIG_HRPES1, " 
        cQuery += " ZIG_DTPES2, ZIG_HRPES2, " 
        cQuery += " ZIG_PLACA, " 
        cQuery += " ZIR_DESGRJ, " 
        cQuery += " ZIR_DESC, " 
        cQuery += " ZIR_DESLOT, " 
        cQuery += " ZIG_PESOLI " 
    cQuery += " FROM " 
        cQuery += " " + RetSqlName("ZIF") + " (NOLOCK) AS ZIF " 
        cQuery += " INNER JOIN " 
        cQuery += " " + RetSqlName("ZIG") + " (NOLOCK) AS ZIG ON " 
        cQuery += " ZIF_FILIAL = ZIG_FILIAL " 
        cQuery += " AND ZIF_NUMERO = ZIG_ORDEM " 
        cQuery += " INNER JOIN " 
        cQuery += " " + RetSqlName("ZIR") + " (NOLOCK) AS ZIR ON  " 
        cQuery += " ZIF_FILIAL = ZIR_FILIAL " 
        cQuery += " AND ZIF_NUMERO = ZIR_ORDEM " 
    cQuery += " WHERE " 
        cQuery += " ZIF_FILIAL = '" + FWxFilial("ZIF") + "' " 
        cQuery += " AND ZIG_DTPES1 >= '" + DToS(MV_PAR01) + "' " 
        cQuery += " AND ZIG_DTPES2 <= '" + DToS(MV_PAR02) + "' "  
        cQuery += " AND ZIG_PLACA >= '" + cValToChar(MV_PAR03) + "' "  //Everson, 09/06/20222, ticket 18465 - Adicionado filtro por placa.
        cQuery += " AND ZIG_PLACA <= '" + cValToChar(MV_PAR04) + "' "  //Everson, 09/06/20222, ticket 18465 - Adicionado filtro por placa.
        cQuery += " AND ZIG_DTPES2 <> ''  "  
        cQuery += " AND ZIF.D_E_L_E_T_ = '' " 
        cQuery += " AND ZIG.D_E_L_E_T_ = '' " 
    cQuery += " ORDER BY ZIF_ROTEIR, ZIR_NUMERO, ZIF_NUMERO, ZIG_NUMERO " 
	
	If Select("D_LISTA") > 0
		D_LISTA->(DbCloseArea())

	EndIf
			
	TcQuery cQuery New Alias "D_LISTA"
    TCSetField("D_LISTA", "ZIG_DTPES1", "D")
    TCSetField("D_LISTA", "ZIG_DTPES2", "D")
			
	DbSelectArea("D_LISTA")
	D_LISTA->(DbGoTop())

	oReport:SetMeter(Contar("D_LISTA","!Eof()"))

    D_LISTA->(DbGoTop())

    oSection1:Init()
			
	While ! D_LISTA->(Eof())
        
		If oReport:Cancel()
			Exit

		EndIf

		oReport:IncMeter()
			
		oSection1:Cell("ROTEIRO"):SetValue(D_LISTA->ZIF_ROTEIR)
		oSection1:Cell("ORDERAC"):SetValue(D_LISTA->ZIR_NUMERO)	
		oSection1:Cell("ORDEPES"):SetValue(D_LISTA->ZIF_NUMERO)	
		oSection1:Cell("TICKET"):SetValue(D_LISTA->ZIG_NUMERO)	
		oSection1:Cell("DATAINI"):SetValue(DToC(D_LISTA->ZIG_DTPES1))	
		oSection1:Cell("HORAINI"):SetValue(D_LISTA->ZIG_HRPES1)	
		oSection1:Cell("DATAFIM"):SetValue(DToC(D_LISTA->ZIG_DTPES2))	
		oSection1:Cell("HORAFIM"):SetValue(D_LISTA->ZIG_HRPES2)	
		oSection1:Cell("PLACA"):SetValue(D_LISTA->ZIG_PLACA)	
		oSection1:Cell("GRANJA"):SetValue(D_LISTA->ZIR_DESGRJ)	
		oSection1:Cell("PRODUTO"):SetValue(D_LISTA->ZIR_DESC)
		oSection1:Cell("LOTE"):SetValue(D_LISTA->ZIR_DESLOT)	
		oSection1:Cell("PESO"):SetValue(Transform(D_LISTA->ZIG_PESOLI, "@E 999,999,999.999"))	
		oSection1:Cell("SILO"):SetValue("")	

		oSection1:Printline()	

        D_LISTA->(DbSkip())	
			
	End

    oSection1:Finish()	
			
Return Nil
