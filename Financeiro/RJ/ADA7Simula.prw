#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณADA7SIMULAบAutor  ณMicrosiga           บ Data ณ  06/10/19   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบChamado   ณ 049746 || OS 051039 || FINANCAS || ANA || 8384 ||          บฑฑ
ฑฑบ          ณ || REL. PARCELAS RJAP - FWNM - 10/06/2019                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function ADA7SIMULA()

	Local cDesc1         := "Este programa tem como objetivo imprimir relatorio "
	Local cDesc2         := "de acordo com os parametros informados pelo usuario."
	Local cDesc3         := "Simulacao - Atualizacao de Parcelas"
	Local titulo         := "Simulacao - Atualizacao de Parcelas"
	Local nLin           := 80
	Local Cabec1         := ""
	Local Cabec2         := ""
	Local aOrd           := {}
	
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private limite       := 132
	Private tamanho      := "M"
	Private nomeprog     := "ADA7SIMULA"
	Private nTipo        := 18
	Private aReturn      := { "Zebrado", 1, "Administracao", 1, 2, 1, "", 1}
	Private nLastKey     := 0
	Private cPerg        := "ADA7SIMULQ"
	Private CbTxt        := Space(10)
	Private cbcont       := 00
	Private CONTFL       := 01
	Private m_pag        := 01
	Private wnrel        := "ADA7SIMULA"
	Private aCoord		 := {}
	Private cString 	 := "ZAG"        
	Private nTot1		 := 0
	Private nTot2		 := 0           
	Private nFator		 := 0
	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')
	                            
	&&lSimulaAtu	:= .T.
	
	         //          1         2         3         4         5         6         7         8         9         0         1         2         3
	         //0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012
	Cabec1 := "Titulo      Prefixo   Parcela   Beneficiario               Vencto Real            Valor        Fator  Val.Correc.  Valor Corrig. "
	
	MV_PAR01 := SPACE(03)
	MV_PAR02 := 0
	
	If !Pergunte(cPerg,.T.)
		ValidPerg()
		If !Pergunte (cPerg, .T.)
			Return
		EndIf
	EndIf
	
	nFator := ZAG->ZAG_CORREC 
	
	If !Empty(ZAG->ZAG_LEGEND)
		MsgInfo("Nao e permitido utilizar esta rotina para indices ja processados!!")
		Return()
	EndIf
	
	wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.F.,Tamanho,,.F.)
	
	If nLastKey == 27
		Return
	Endif
	
	SetDefault(aReturn,cString)
	
	If nLastKey == 27
		Return
	Endif
	
	nTipo := If(aReturn[4]==1,15,18)
	
	RptStatus({|| Pmr210Imp(Cabec1,Cabec2,Titulo,nLin) },Titulo)
	Return
	
	Static Function Pmr210Imp(Cabec1,Cabec2,Titulo,nLin)
	
	Local cQuery 	:= "" 
	Local _nCusto	:= 0                                   
	
	&& Atualiza Status informando que a simulacao foi efetivada.
	RecLock("ZAG",.F.)
		ZAG->ZAG_STATUS := "1" 
	MsUnlock("ZAG")
	
	&& Pesquisa de regs. para processamento.
	cQuery := " SELECT ZAH.ZAH_NUMERO,ZAF.*  "
	cQuery += " FROM " + RetSqlName("ZAH") + " ZAH, " + RetSqlName("ZAF") + " ZAF "
	cQuery += " WHERE ZAH.ZAH_NUMERO = ZAF.ZAF_NUMERO " 
	cQuery += " AND ZAH.D_E_L_E_T_ = '' AND ZAF.D_E_L_E_T_ = '' "
	cQuery += " AND ZAF.ZAF_LEGEND = '' "
	cQuery += " AND ZAF.ZAF_SALDO     > 0  "  // Chamado n. 049746 || OS 051039 || FINANCAS || ANA || 8384 ||REL. PARCELAS RJAP - FWNM - 10/06/2019
	
	Tcquery cQuery Alias "TARQ" New
	
	TARQ->(dbGoTop())
	SetRegua(RecCount())
	
	While TARQ->(!Eof())
		
		If lAbortPrint
			@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif
		
		If nLin > 58
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 8
		Endif           
		
		nValor := 1 + (nFator/100) &&(MV_PAR02/100)
	
		dbSelectArea("SA2")
		SA2->(dbSeek(xFilial("SA2")+TARQ->ZAF_FORNEC))
	
		@ nLin, 000 PSAY TARQ->ZAH_NUMERO
		@ nLin, 013 PSAY TARQ->ZAF_PREFIX
		@ nLin, 022 PSAY TARQ->ZAF_PARCEL
		@ nLin, 033 PSAY TARQ->ZAF_FORNEC + '-' + Substr(SA2->A2_NOME,1,19)
		@ nLin, 061 PSAY Stod(TARQ->ZAF_VENCTO)          	
		@ nLin, 074 PSAY TARQ->ZAF_SALDO				 					PICTURE '@R 999,999,999.99'
		&&@ nLin, 090 PSAY MV_PAR02						 					PICTURE '@R 999.99999999'
		@ nLin, 090 PSAY nFator							 					PICTURE '@R 999.99999999'
		@ nLin, 100 PSAY (TARQ->ZAF_SALDO * nFator)-TARQ->ZAF_SALDO			PICTURE '@R 999,999,999.99'
		@ nLin, 115 PSAY TARQ->ZAF_SALDO * nFator							PICTURE '@R 999,999,999.99'
	
		nTot1 += ( (TARQ->ZAF_SALDO * nFator)-TARQ->ZAF_SALDO )
		nTot2 += ( TARQ->ZAF_SALDO * nFator )
		nLin ++ 
	
		TARQ->(dbSkip())
		IncRegua()
	EndDo                                      
	
	nLin += 2 
	@ nLin, 000 PSAY 'TOTAL'
	@ nLin, 100 PSAY nTot1												PICTURE '@R 999,999,999.99'
	@ nLin, 115 PSAY nTot2												PICTURE '@R 999,999,999.99'
	
	TARQ->(dbCloseArea())
	
	SET DEVICE TO SCREEN
	
	If aReturn[5]==1
		dbCommitAll()
		SET PRINTER TO
		OurSpool(wnrel)
	Endif
	
	MS_FLUSH()

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณADA7SIMULAบAutor  ณMicrosiga           บ Data ณ  06/10/19   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function ValidPerg()

	Local _sAlias := Alias()
	Local aRegs := {}
	Local i,j
	
	dbSelectArea("SX1")
	dbSetOrder(1)
	cPerg := PADR(cPerg,10)
	
	aAdd(aRegs,{cPerg,"01","Periodo Correcao " ,"" ,"","mv_ch1","C",03,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","ZAG" })
	aAdd(aRegs,{cPerg,"02","Fator Correcao  "  ,"" ,"","mv_ch2","N",12,8,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","" })
	aAdd(aRegs,{cPerg,"03","Data Contab.    "  ,"" ,"","mv_ch3","D",08,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","" })
	aAdd(aRegs,{cPerg,"04","Conta Debito    "  ,"" ,"","mv_ch4","C",20,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","CT1" })
	aAdd(aRegs,{cPerg,"05","Conta Credito   "  ,"" ,"","mv_ch5","C",20,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","CT1" })
	aAdd(aRegs,{cPerg,"06","Hist๓rico       "  ,"" ,"","mv_ch6","C",50,0,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","" })
	
	For i:=1 to Len(aRegs)
		If !dbSeek(cPerg+aRegs[i,2])
			RecLock("SX1",.T.)
			For j:=1 to FCount()
				If j <= Len(aRegs[i])
					FieldPut(j,aRegs[i,j])
				Endif
			Next
			MsUnlock()
		Endif
	Next
	
	dbSelectArea(_sAlias)

Return()