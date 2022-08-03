#Include "Protheus.ch"
#include "TopConn.CH"

/*/{Protheus.doc} User Function ADEST080R
	Relatorio Solicitação relatório de roteiro.
	@type  Function
	@author Antonio Fomingos
	@since 25/07/2022
	@version version
	@history, Antonio Domingos, 29/07/2022, ticket 77061 - Solicitação relatório de roteiro.
/*/
User Function ADEST080R() 

    //Variáveis.
    Local aArea := GetArea()
	Local oReport := Nil
	Local cPerg := "ADEST080R" 
	
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
    @author Antonio Domingos
    @since 29/07/2022
    @version 01
/*/
Static Function RPTStruc(cPerg)

    //Variáveis.
    Local cNome     := "ADEST080R"
    Local cTitulo   := "Relatório de roteiro"
	Local oReport   := Nil
	Local oSection1 := Nil
	
	oReport := TReport():New(cNome,cTitulo, cPerg,{|oReport| RPTPRINT(oReport)},cTitulo)
	oReport:SetLandscape(.T.)
	
	oSection1 := TRSection():New(oReport, "Pedidos",{"SC5"}, ,.F.,.T.)

//cidade da granja, transportador e motorista se possível.

TRCell():New(oSection1,"ZFC_NUMERO","TRB_ZFC"," Numero Ordem","@!",6)
TRCell():New(oSection1,"ZFC_STATUS","TRB_ZFC"," Status"    ,"@!",1)
TRCell():New(oSection1,"ZFC_TIPVIA ","TRB_ZFC","Tp de Viagem","@!",1)
TRCell():New(oSection1,"ZFC_AMARRA ","TRB_ZFC","Amarracao"    ,"@!",6)
TRCell():New(oSection1,"ZFC_GUIAPE ","TRB_ZFC","Guia Pesagem"    ,"@!",6)
TRCell():New(oSection1,"ZFC_APANHA ","TRB_ZFC","Apanha"    ,"@!",1)
TRCell():New(oSection1,"ZFC_LACRES","TRB_ZFC","Lacres"    ,"@!",75)
TRCell():New(oSection1,"ZFC_HRCHEG ","TRB_ZFC","Hora Chegada"    ,"@!",5)
TRCell():New(oSection1,"ZFC_OBSERV ","TRB_ZFC","Observacoes"    ,"@!",200)
TRCell():New(oSection1,"ZFC_GALPAO ","TRB_ZFC","Galpao" ,"@!",2)
TRCell():New(oSection1,"ZFC_NRLOTE ","TRB_ZFC","Num. Lote" ,"@!",5)
TRCell():New(oSection1,"ZFC_DTACAR ","TRB_ZFC","DataCarrega","@!",8)
TRCell():New(oSection1,"ZFC_FRTVLR ","TRB_ZFC","Vlr.Frete","@!",12)
TRCell():New(oSection1,"ZFC_FRTPED ","TRB_ZFC","Vlr. Pedagio","@!",12)
TRCell():New(oSection1,"ZFC_FRTTOT ","TRB_ZFC","VlrFrt_Pedag","@!",12)
TRCell():New(oSection1,"ZFC_PEDVEN ","TRB_ZFC","Pedido Venda","@!",6)
TRCell():New(oSection1,"A4_COD","TRB_ZFC","cod Transportador","@!",6)
TRCell():New(oSection1,"A4_NOME","TRB_ZFC","Nome Transportador","@!",6)
TRCell():New(oSection1,"CC2_MUN","TRB_ZFC","Municipio Granja","@!",6) //?
TRCell():New(oSection1,"DHB_NOMMOT","TRB_ZFC","Nome Motorista","@!",6)		//ZV4
TRCell():New(oSection1,"ZFC_NUMEDA ","TRB_ZFC","Seq.Edata","@!",9)
TRCell():New(oSection1,"ZFC_STAEDA ","TRB_ZFC","Status Edata","@!",1)
TRCell():New(oSection1,"ZFC_NUMSAG ","TRB_ZFC","Seq.Edata","@!",9)
TRCell():New(oSection1,"ZFC_STASAG ","TRB_ZFC","Status Sag","@!",1)
TRCell():New(oSection1,"ZFC_FILORI ","TRB_ZFC","Filial Orige","@!",2)
TRCell():New(oSection1,"ZFC_NF 	   ","TRB_ZFC","NF Vinculada","@!",9)
TRCell():New(oSection1,"ZFC_SERIE  ","TRB_ZFC","Serie NF","@!",3)
	
	//TRFunction():New(oSection1:Cell("PESO"),"Total Geral" ,"SUM",,,"@E 999,999,999,999,999.999",,.F.,.T.)

Return (oReport)
/*/{Protheus.doc} RPTPrint
    Gera relatório.
    @type  Static Function
    @author Antonio Domingos
    @since 31/05/2022
    @version 01
/*/
Static Function RPTPrint(oReport)

    //Variáveis.
	Local oSection1 := oReport:Section(1)
	Local cQuery    := ""

    cQuery += " SELECT *.ZFC,SA4.A4_COD, SA4.A4_NOME " 
    cQuery += " FROM " 
    cQuery += " " + RetSqlName("ZFC") + " (NOLOCK) AS ZFC " 

    cQuery += " INNER JOIN " 
    cQuery += " " + RetSqlName("SC5") + " (NOLOCK) AS SC5 ON " 
    cQuery += " C5_FILIAL = ZFC_FILIAL " 
    cQuery += " AND C5_NUM = ZFC_PEDVEN " 
    cQuery += " AND SC5.D_E_L_E_T_ = '' " 

    cQuery += " LEFT OUTER JOIN " 
    cQuery += " " + RetSqlName("SA4") + " (NOLOCK) AS SA4 ON " 
    cQuery += " A4_FILIAL = '" + FWxFilial("SA4") + "' " 
    cQuery += " AND A4_COD = C5_TRANSP" 
    cQuery += " AND SC5.D_E_L_E_T_ = '' " 
	//ExistCpo("CC2",M->C5_UFDEST+M->C5_CMUNDE)

    cQuery += " LEFT OUTER JOIN " 
    cQuery += " " + RetSqlName("CC2") + " (NOLOCK) AS CC2 ON " 
    cQuery += " CC2_FILIAL = '" + FWxFilial("CC2") + "' " 
    cQuery += " AND CC2_EST = C5_UFDEST" 
    cQuery += " AND CC2_CODMUN = C5_CMUNDE" 
    cQuery += " AND SC5.D_E_L_E_T_ = '' "

  	cQuery += " LEFT OUTER JOIN " 
    cQuery += " " + RetSqlName("DHB") + " (NOLOCK) AS DHB ON " 
    cQuery += " DHB_FILIAL = '" + FWxFilial("DHB") + "' " 
    cQuery += " AND DHB_CPFMOT = C5_CODMOT" 
    cQuery += " AND DHB.D_E_L_E_T_ = '' "

	cQuery += " WHERE " 
    cQuery += " ZFC_FILIAL = '" + FWxFilial("ZFC") + "' " 
    cQuery += " AND ZFC_NUMERO >= '" + MV_PAR01 + "' "
    cQuery += " AND ZFC_NUMERO <= '" + MV_PAR02 + "'"
    cQuery += " AND ZFC.D_E_L_E_T_ = '' " 
      
    cQuery += " ORDER BY ZFC_FILIAL, ZFC_NUMERO " 
	
	If Select("TRB_ZFC") > 0
		TRB_ZFC->(DbCloseArea())
	EndIf
			
	TcQuery cQuery New Alias "TRB_ZFC"
    TCSetField("TRB_ZFC", "ZFC_DTACAR", "D")
    TCSetField("TRB_ZFC", "ZFC_FRTVLR", "N")
    TCSetField("TRB_ZFC", "ZFC_FRTPED", "N")
    TCSetField("TRB_ZFC", "ZFC_FRTTOT", "N")

	DbSelectArea("TRB_ZFC")
	TRB_ZFC->(DbGoTop())

	oReport:SetMeter(Contar("TRB_ZFC","!Eof()"))

    TRB_ZFC->(DbGoTop())

    oSection1:Init()
			
	While ! TRB_ZFC->(Eof())
        
		If oReport:Cancel()
			Exit

		EndIf

		oReport:IncMeter()
			
		oSection1:Cell("ROTEIRO"):SetValue(ZFC_NUMERO)
		oSection1:Cell("ROTEIRO"):SetValue(ZFC_STATUS)
		oSection1:Cell("ROTEIRO"):SetValue(ZFC_TIPVIA)
		oSection1:Cell("ROTEIRO"):SetValue(ZFC_AMARRA)
		oSection1:Cell("ROTEIRO"):SetValue(ZFC_GUIAPE)
		oSection1:Cell("ROTEIRO"):SetValue(ZFC_APANHA)
		oSection1:Cell("ROTEIRO"):SetValue(ZFC_USERGI)
		oSection1:Cell("ROTEIRO"):SetValue(ZFC_USERGA)
		oSection1:Cell("ROTEIRO"):SetValue(ZFC_LACRES)
		oSection1:Cell("ROTEIRO"):SetValue(ZFC_HRCHEG)
		oSection1:Cell("ROTEIRO"):SetValue(ZFC_OBSERV)
		oSection1:Cell("ROTEIRO"):SetValue(ZFC_GALPAO)
		oSection1:Cell("ROTEIRO"):SetValue(ZFC_NRLOTE)
		oSection1:Cell("ROTEIRO"):SetValue(ZFC_DTACAR)
		oSection1:Cell("ROTEIRO"):SetValue(ZFC_FRTVLR)
		oSection1:Cell("ROTEIRO"):SetValue(ZFC_FRTPED)
		oSection1:Cell("ROTEIRO"):SetValue(ZFC_FRTTOT)
		oSection1:Cell("ROTEIRO"):SetValue(ZFC_PEDVEN)
		oSection1:Cell("ROTEIRO"):SetValue(A4_COD)
		oSection1:Cell("ROTEIRO"):SetValue(A4_NOME)
		oSection1:Cell("ROTEIRO"):SetValue(CC2_MUN)
		oSection1:Cell("ROTEIRO"):SetValue(DHB_NOMMOT)		
		oSection1:Cell("ROTEIRO"):SetValue(ZFC_NUMEDA)
		oSection1:Cell("ROTEIRO"):SetValue(ZFC_STAEDA)
		oSection1:Cell("ROTEIRO"):SetValue(ZFC_NUMSAG)
		oSection1:Cell("ROTEIRO"):SetValue(ZFC_STASAG)
		oSection1:Cell("ROTEIRO"):SetValue(ZFC_FILORI)
		oSection1:Cell("ROTEIRO"):SetValue(ZFC_NF) 	  
		oSection1:Cell("ROTEIRO"):SetValue(ZFC_SERIE) 
		
		oSection1:Cell("PEDV"):SetValue(TRB_ZFC->PEDVEN)	
		oSection1:Cell("NF"):SetValue(TRB_ZFC->ZFC_NF)	

		oSection1:Printline()	

        TRB_ZFC->(DbSkip())	
			
	End

    oSection1:Finish()	
			
Return Nil

