#include "protheus.ch"
#include "topconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LPP02001  ºAutor  ³Fernando Macieira   º Data ³  17/10/2018 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina baixa provisao por transferencia.                   º±±
±±º          ³ Devera executar apenas quando transf entre empresa.        º±±
±±º          ³ Chamado n. 043889 (Monik e Tamires - Controladoria)        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Adoro                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

Parâmetro: MV_TRFAMES (http://tdn.totvs.com/pages/releaseview.action?pageId=364914692)

Verbas necessárias:
Férias - Baixa Transferências – (Opcionais)
0239 - Valor Provisão (783)
0260 – Adicional (784)
0261 - Um Terço (785)
0240 – INSS (786)
0241 – FGTS (787)

13 - Baixa Transferências – (Opcionais)
0270 - Valor Provisão (811)
0271 – Adicional (812)
0272 – INSS (813)
0273 – FGTS (814)

*/

User Function LPP02001()

Local nVlr     := 0
Local cQuery   := ""
Local cSitFolh := ""
Local aAreaSRA := SRA->( GetArea() )

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')


If AllTrim(SRZ->RZ_MAT) == "zzzzzz" // Contabilização por CC
	
	If Select("Work") > 0
		Work->( dbCloseArea() )
	EndIf
	
	cQuery := " SELECT RZ_FILIAL, RZ_MAT "
	cQuery += " FROM " + RetSqlName("SRZ")
	cQuery += " WHERE RZ_FILIAL='"+SRZ->RZ_FILIAL+"' "
	cQuery += " AND RZ_CC='"+SRZ->RZ_CC+"' "
	cQuery += " AND RZ_PD='"+SRZ->RZ_PD+"' "
	cQuery += " AND RZ_TIPO='"+SRZ->RZ_TIPO+"' "
	cQuery += " AND RZ_TPC='"+SRZ->RZ_TPC+"' "
	cQuery += " AND RZ_MAT<>'zzzzzz' "
	cQuery += " AND D_E_L_E_T_='' "
	
	tcQuery cQuery New Alias "Work"
	
	Work->( dbGoTop() )
	
	If Work->( !EOF() )
		cSitFolh := Posicione("SRA", 1, Work->RZ_FILIAL+Work->RZ_MAT, "RA_SITFOLH")
		
		If cSitFolh == "D" .and. ExistSRE(Work->RZ_FILIAL, Work->RZ_MAT)
			nVlr := Abs(SRZ->RZ_VAL)
		EndIf
		
	EndIf
	
Else // Contabilizacao por matricula
	cSitFolh := Posicione("SRA", 1, SRZ->RZ_FILIAL+SRZ->RZ_MAT, "RA_SITFOLH")
	
	If cSitFolh == "D" .and. ExistSRE(SRZ->RZ_FILIAL, SRZ->RZ_MAT)
		nVlr := Abs(SRZ->RZ_VAL)
	EndIf
	
EndIf

If Select("Work") > 0
	Work->( dbCloseArea() )
EndIf

RestArea( aAreaSRA )

Return nVlr



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LPP02001  ºAutor  ³Microsiga           º Data ³  10/17/18   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao para verificar se o funcionario foi transferido     º±±
±±º          ³ entre empresas.                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Adoro                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function ExistSRE(cRZ_FILIAL, cRZ_MAT)

Local lRet   := .f.
Local cQuery := ""

If Select("WorkSRE")
	WorkSRE->( dbCloseArea() )
EndIf

cQuery := " SELECT RE_EMPD, RE_EMPP "
cQuery += " FROM " + RetSqlName("SRE")
cQuery += " WHERE RE_FILIAL='"+FWxFilial("SRE")+"' "
cQuery += " AND RE_EMPD='"+cEmpAnt+"' "
cQuery += " AND RE_FILIALD='"+cRZ_FILIAL+"' "
cQuery += " AND RE_MATD='"+cRZ_MAT+"' "
cQuery += " AND D_E_L_E_T_='' "

tcQuery cQuery New Alias "WorkSRE"

WorkSRE->( dbGoTop() )

If WorkSRE->( !EOF() )
	If WorkSRE->RE_EMPD <> WorkSRE->RE_EMPP
		lRet := .t.
	EndIf
EndIf

If Select("WorkSRE")
	WorkSRE->( dbCloseArea() )
EndIf

Return lRet
