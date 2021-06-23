#include "PROTHEUS.CH"
#include "TOPCONN.CH"


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³NOVO2     ºAutor  ³Fernando Macieira   º Data ³  05/29/18   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ P.E. utilizado para executar rotinas apos o recalculo.     º±±
±±º          ³ Chamado 036729 (Estoque em Trânsito)                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Adoro                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function MA330FIM()


Local nCusto    := 0
Local cQuery    := ""
Local aAreaSD3  := SD3->( GetArea() )

Private cLocTran  := GetMV("MV_LOCTRAN",,"95")
Private cFilOrig  := GetMV("MV_#TRAFIL",,"08")
Private cFilEntr  := GetMV("MV_#TRAFIE",,"03")
Private cProdTra  := GetMV("MV_#TRAPRD",,"383369")
Private cTMEntrad := GetMV("MV_#TRATME",,"201")
Private cTMSaida  := GetMV("MV_#TRATMS",,"701")
Private cCliTran  := GetMV("MV_#TRACLI",,"014999")
Private cLojCTran := GetMV("MV_#TRALO1",,"00")
Private cForTran  := GetMV("MV_#TRAFOR",,"022503")
Private cLojFTran := GetMV("MV_#TRALOJ",,"21")
Private	cTESEntra := GetMV("MV_#TRATES",,"02T")
Private	cTESSaida := GetMV("MV_#TRATSS",,"866")


If Select("Work") > 0
	Work->( dbCloseArea() )
EndIf

cQuery := " SELECT D3_FILIAL, D3_DOC, D3_COD, D3_CF, D3_LOCAL, D3_EMISSAO, D3_TM "
cQuery += " FROM " + RetSqlName("SD3")
cQuery += " WHERE D3_FILIAL='"+cFilOrig+"' "
cQuery += " AND D3_COD='"+cProdTra+"' "
cQuery += " AND D3_LOCAL='"+cLocTran+"' "
cQuery += " AND D3_EMISSAO LIKE '"+Left(DtoS(MV_PAR01),6)+"%' "
cQuery += " AND D3_TM IN ('"+cTMEntrad+"','"+cTMSaida+"') "
cQuery += " AND D3_ESTORNO <> 'S' "
cQuery += " AND D_E_L_E_T_='' "

tcQuery cQuery new alias "Work"

aTamSX3 := TamSX3("D3_EMISSAO")
tcSetField("Work", "D3_EMISSAO", aTamSX3[3], aTamSX3[1], aTamSX3[2])


Work->( dbGoTop() )
Do While Work->( !EOF() )
	
	// Posiciono nas movimentações de estoque criadas pelas movimetaçoes de estoque em transito
	SD3->( dbSetOrder(2) ) // D3_FILIAL+D3_DOC+D3_COD
	If SD3->( dbSeek(Work->D3_FILIAL+Work->D3_DOC+Work->D3_COD) )
		
		Do While SD3->( !EOF() ) .and. SD3->D3_FILIAL == Work->D3_FILIAL .and. SD3->D3_DOC == Work->D3_DOC .and. SD3->D3_COD == Work->D3_COD
		
			// Busca custo da nota de entrada
			If AllTrim(Work->D3_TM) == AllTrim(cTMEntrad)
				nCusto := BuscaCusto("SD1")
			EndIf
			
			// Busca custo da nota de saida
			If AllTrim(Work->D3_TM) == AllTrim(cTMSaida)
				nCusto := BuscaCusto("SD2")
			EndIf
			
			// Gravo custo oriundo das origens
			If nCusto > 0
				RecLock("SD3", .f.)
				SD3->D3_CUSTO1 := nCusto
				SD3->( msUnLock() )
			EndIf
		
			SD3->( dbSkip() )
			
		EndDo
		
	EndIf
	
	Work->( dbSkip() )
	
EndDo

If Select("Work") > 0
	Work->( dbCloseArea() )
EndIf

RestArea( aAreaSD3 )

Return



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MA330FIM  ºAutor  ³Microsiga           º Data ³  05/30/18   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function BuscaCusto(cOrigem)

Local nValor := 0
Local cQuery2 := ""


If Select("Work2") > 0
	Work2->( dbCloseArea() )
EndIf


If cOrigem == "SD1"
	
	cQuery2 := " SELECT D1_CUSTO "
	cQuery2 += " FROM " + RetSqlName("SD1")
	cQuery2 += " WHERE D1_FILIAL='"+cFilEntr+"' "
	cQuery2 += " AND D1_COD='"+Work->D3_COD+"' "
	cQuery2 += " AND D1_DOC='"+Work->D3_DOC+"' "
	cQuery2 += " AND D1_FORNECE='"+cForTran+"' "
	cQuery2 += " AND D1_LOJA='"+cLojFTran+"' "
	cQuery2 += " AND D1_TES='"+cTESEntra+"' "
	cQuery2 += " AND D1_DTDIGIT='"+DtoS(Work->D3_EMISSAO)+"' "
	cQuery2 += " AND D_E_L_E_T_='' "
	
	tcQuery cQuery2 new alias "Work2"
	
	aTamSX3 := TamSX3("D1_CUSTO")
	tcSetField("Work2", "D1_CUSTO", aTamSX3[3], aTamSX3[1], aTamSX3[2])
	
	Work2->( dbGoTop() )
	
	If Work2->( !EOF() )
		nValor := Work2->D1_CUSTO
	EndIf
	
	
	
ElseIf cOrigem == "SD2"
	
	cQuery2 := " SELECT D2_CUSTO1 "
	cQuery2 += " FROM " + RetSqlName("SD2")
	cQuery2 += " WHERE D2_FILIAL='"+cFilOrig+"' "
	cQuery2 += " AND D2_DOC='"+Work->D3_DOC+"' "
	cQuery2 += " AND D2_CLIENTE='"+cCliTran+"' "
	cQuery2 += " AND D2_LOJA='"+cLojCTran+"' "
	cQuery2 += " AND D2_COD='"+Work->D3_COD+"' "
	cQuery2 += " AND D2_TES='"+cTESSaida+"' "
	cQuery2 += " AND D2_EMISSAO='"+DtoS(Work->D3_EMISSAO)+"' "
	cQuery2 += " AND D_E_L_E_T_='' "
	
	tcQuery cQuery2 new alias "Work2"
	
	aTamSX3 := TamSX3("D2_CUSTO1")
	tcSetField("Work2", "D2_CUSTO1", aTamSX3[3], aTamSX3[1], aTamSX3[2])
	
	Work2->( dbGoTop() )
	
	If Work2->( !EOF() )
		nValor := Work2->D2_CUSTO1
	EndIf
	
	
	
EndIf


If Select("Work2") > 0
	Work2->( dbCloseArea() )
EndIf


Return nValor
