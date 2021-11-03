#Include "Rwmake.ch"
#Include "Protheus.ch"
#Include "Topconn.ch"

/*/{Protheus.doc} User Function ADVEN041R
	Relat๓rio de rentabilidade por supervisor. Chamado 032203
	@type  Function
	@author Everson
	@since 14/02/2017
	@version 1
	@history Chamado 045773 - Everson     - 12/12/2018 - Alterado o order by da consulta de totalizador geral.
	@history Ticket   15553 - Abel Babini - 14/06/2021 - Corre็ใo de error log no retorno das filiais selecionadas.
	@history Ticket   15718 - Everson     - 16/06/2021 - Tratamento para errorlog.
	@history Ticket      ti - F. Macieira - 06/09/2021 - Performance Cloud OPTION(QUERYTRACEON 9481)
/*/
User Function ADVEN041R() // U_ADVEN041R()
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declaracao de Variaveis                                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Private cPerg		:= PADR("ADV41R",10," ")
	Private aOrd        := {}
	Private tamanho     := "G"
	Private limite      := 220
	Private nomeprog    := "ADVEN041R"
	Private mv_tabpr    := ""
	Private nTipo       := 18
	Private aReturn     := { "Zebrado", 1,"Administracao", 2, 2, 1,"",1}
	Private nLastKey    := 0
	Private m_pag	   	:= 01
	
	Private cString 	:= "SC6"
	Private titulo  	:= "METAS DE VENDAS DIARIA SUPERVISOR"
	Private cDesc1  	:= "Apresenta valor de custo ponderado + cobertura"
	Private cDesc2  	:= "+ Meta media."
	Private cDesc3  	:= " By Desenvolvimento ADORO"
	Private nomerel 	:= "ADVEN041R"
	Private Cabec1 		:= ""
	Private Cabec2 		:= ""
	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Relat๓rio de rentabilidade por supervisor.')
	//__cUserID := "000835"
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Verifica as perguntas                ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	ValidPerg(cPerg)
	Pergunte(cPerg,.F.)
	
	nomerel := SetPrint(cString,nomerel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho)
	
	If nLastKey == 27
		Return Nil
	EndIf
	
	//Ticket   15553 - Abel Babini - 14/06/2021 - Corre็ใo de error log no retorno das filiais selecionadas.
	MV_PAR05 := formatIn(Alltrim(MV_PAR05),',') //15718 - Everson     - 16/06/2021.

	SetDefault(aReturn,cString)

	If nLastKey == 27
		Return Nil
	EndIf
	
	Processa({|| imprimeRel()},"Imprimindo Relat๓rio")
	
Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณimprimeRelบ Autor ณ Everson            บ Data ณ  14/02/2017 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Gera relat๓rio.                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณChamado 032203.                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function imprimeRel()

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declaracao de Variaveis                                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู		
	Local cQuery		:= ""
	Local nTotReg		:= 0
	Local cNvlUsr		:= ""
	
	Private _cGrpos		:= ""
	Private oHashSuper  := tHashMap():New()
	Private oHashAtivo  := tHashMap():New()
	Private oHashCobTGrp:= tHashMap():New()
	Private oHashCobSNB	:= tHashMap():New()
	Private oHashCart	:= tHashMap():New()
	Private oHashCobCons:= tHashMap():New()
	Private oHashCobTCons:= tHashMap():New()
	Private _nDiasUtil	:= MV_PAR06 
	Private _nDiasCorr  := MV_PAR07
	
	Private cArq
	Private oExcelApp
	Private _Eof 		:= Chr(13) + Chr(10)
	Private cLin 		:= ""
	Private cLin6 		:= ""
	Private cLin7 		:= ""
	Private cLin8 		:= ""
	Private _nQTCartT 	:= 0
	Private nLin        := 0
	Private cabec6 		:= ""
	Private Cabec7 		:= ""
	Private Cabec8 		:= ""
	Private cLin6  		:= ""
	Private cLin7		:= ""
	Private _aSup		:= {}
    Private _aTotaliz  	:= {}       
	Private _nCobQbr	:= 0 
	Private _nTotD		:= 0
	Private _nQbrTotVnd	:= 0          
	Private _nQbrMtVnd	:=	0
	Private _nQbrReVnd	:=	0
	Private _nQbrRfVnd	:=	0
	Private _nQbrMtVol	:=	0
	Private _nAcVdT     :=	0
	Private _nAcMtPrcT	:=	0
	Private _nAcRePrcT	:=	0
	Private _nAcRfPrcT	:=	0
	Private _nAcMtVolT	:=	0
	Private _nCobT		:=  0
	Private _nAcVdTT    :=	0
	Private _nAcMPrcTT  :=	0
	Private _nAcCobTT	:=  0
	Private _nAcRPrcTT  :=	0
	Private _nAcFPrcTT  :=	0
	Private _nAcMVolTT  :=	0 
	Private _cAgrupadores := ""
	Private _cAgrupGrupos 	:= ""
	Private aAcD		:= {}
	Private _lDiret		:= .F.
	
	Private _Supervis	:= ""
	Private _NomSup		:= ""
	Private _cQuebraAnt	:= ""
	Private _cQuebraTot	:= ""
	Private _nContaSup	:= ""
	
	cNvlUsr := Posicione("SA3",7,xFilial("SA3") + Alltrim(cValToChar(__cUserID)),"A3_NIVETAB")

	If cNvlUsr == "4"
		_lDiret := .T.
      
	EndIf
	_lDiret := .T.
	//Monta cabe็alho do relat๓rio.
	If _lDiret
	   cabec6 := "|                               |   PRECO FOB (R$/KG)   |     FATURAMENTO(R$)                DIFERENCA FAT.(R$)        |       INDICE      |                  VOLUME(KG)                    |      ATINGIMENTO(%)         |"
	   Cabec7 := "|GRUPO DE PRODUTOS:             |  META   REAL.   CT    |   META       REALIZADO       CT     REAL - META  REAL - CT   |      IPM   IPCT   |    META        REALIZ.  PROJETADO  NECESSARIA  |  REALIZADO    PROJETADO COB |"
	   Cabec8 := "|_______________________________|_______________________|______________________________________________________________|___________________|________________________________________________|_____________________________|"
	   cLin6  := ";;PRC FOB;PRC.FOB;PRC. FOB.;FAT.;FAT.;FAT.;DIF.FAT;DIF.FAT.;INDICE;INDICE;VOL.;VOl.;VOL.;VOL.;ATING.;ATING."+_eof
	   cLin7  := "GRUPO;PRODUTOS;META;REAL;CT;META;REALIZADO;CT;REAL - META;REAL _ CT;IPM;IPCT;META;REALIZADO;PROJETADO;NECESSARIA;REALIZADO;PROJETADO"+_eof
	   //          1    6   10         20         30         40         50          60          70          80          90          00          10          20          30          40          50          60          70          80          9
	
	Else
	   cabec6 := "|                               |   PRECO FOB (R$/KG)   |     FATURAMENTO(R$)                DIFERENCA FAT.(R$)        |       INDICE      |                  VOLUME(KG)                    |      ATINGIMENTO(%)         |"
	   Cabec7 := "|GRUPO DE PRODUTOS:             |  META   REAL.         |   META       REALIZADO              REAL - META              |      IPM          |    META        REALIZ.  PROJETADO  NECESSARIA  |  REALIZADO    PROJETADO COB |"
	   Cabec8 := "|_______________________________|_______________________|______________________________________________________________|___________________|________________________________________________|_____________________________|"
	   cLin6  := ";;PRC FOB;PRC.FOB;FAT.;FAT.;DIF.FAT;INDICE;VOL.;VOl.;VOL.;VOL.;ATING.;ATING."+_eof
	   cLin7  := "GRUPO;PRODUTOS;META;REAL;META;REALIZADO;REAL - META;IPM;META;REALIZADO;PROJETADO;NECESSARIA;REALIZADO;PROJETADO"+_eof
	   //          1    6   10         20         30         40         50          60          70          80          90          00          10          20          30          40          50          60          70          80          9
	
	EndIf 
	
	//Obt้m dados de vendas.
	MsAguarde({||cQuery := scriptConsolidado()},"Aguarde","Obtendo dados.")

	//Everson - 12/12/2018. Chamado 045773.
	//cQuery += " CONSOLIDADO.A3_CODSUP,  CONSOLIDADO.BM_QBRNVL, CONSOLIDADO.X5_DESCRI, CONSOLIDADO.BM_GRUPO "
	cQuery += " ORDER BY " 
	cQuery += " CONSOLIDADO.A3_CODSUP, CONSOLIDADO.X5_DESCRI, CONSOLIDADO.BM_QBRNVL, CONSOLIDADO.BM_GRUPO " 

	If Select("CONSOLIDADO") > 0
		CONSOLIDADO->(DbCloseArea())
	EndIf
	
	MsAguarde({||execConsult(cQuery,"CONSOLIDADO")},"Aguarde","Consulta dados de vendas.")
	
	DbSelectArea("CONSOLIDADO")
	CONSOLIDADO->(DbGotop())
	MsAguarde({||nTotReg := contar("CONSOLIDADO","!Eof()")},"Aguarde","Conferindo n๚mero de registros.")
	ProcRegua(nTotReg)
	
/*	If nTotReg <= 0
		MsgInfo("Nใo hแ dados a serem impressos.","Fun็ใo imprimeRel")
		Return Nil
		
	EndIf*/
	
	//Obt้m dados de cobertura de vendas.
	MsAguarde({||cobSuperv()},"Aguarde","Obtendo cobertura total de clientes.")
	
	//Obt้m dados de clientes ativos.
	MsAguarde({||ativosSuper()},"Aguarde","Obtendo clientes ativos.")
	
	//Obt้m dados de cobertura por supervisor nํvel e totalizador.
	MsAguarde({||cobNvTot()},"Aguarde","Obtendo cobertura por sup, nvl e tot.")
	
	//Obt้m dados de cobertura por grupo nํvel e totalizador.
	MsAguarde({||cobConsolidado()},"Aguarde","Obtendo cobertura por grp, nvl e tot.")
	
	//Obt้m dados de cobertura por nํvel e totalizador.
	MsAguarde({||cobTConsolidado()},"Aguarde","Obtendo cobertura por nvl e tot.")
	
	//Obt้m carteira de clientes por supervisor.
	MsAguarde({||carteira()},"Aguarde","Obtendo carteira de clientes por supervisor.")
	
	CONSOLIDADO->(DbGotop())
	
	//Variแveis para gera็ใo de arquivo CSV.
	cPath    := AllTrim(GetTempPath())
	cArq     := "ADVEN041R_"+__cUserID+"_" + DToS(Date()) + "_" + StrTran(cValToChar(Time()),":","") + ".CSV"
	
	If File("D:\TEMP\"+cArq)
		FErase("D:\TEMP\"+cArq)
			
	EndIf
	
	If File(cPath+"\"+cArq)
		FErase(cPath+"\"+cArq)	
			
	EndIf
	
	If File("\SYSTEM\"+cArq)
		FErase("\SYSTEM\"+cArq)
		
	EndIf
	
	nHdl := fCreate(cArq,0)
	
	_Vazia := ";;;;;;;;;;;;;;;;;;"+_eof
	
	nLin:=5
	Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	
	_Supervis 	:= CONSOLIDADO->A3_CODSUP
	_NomSup		:= CONSOLIDADO->ZR_DESCRIC
	
	//Imprime cabe็alho.
	ImpCabec(_Supervis,_NomSup)
	
	_cQuebraAnt:= CONSOLIDADO->BM_QBRNVL
	_cQuebraTot:= CONSOLIDADO->X5_DESCRI
	_nContaSup := 1
	_cGrpos    += "'" + CONSOLIDADO->BM_GRUPO + "',"
	
	While ! CONSOLIDADO->(Eof())
	        	
		IncProc(" Supervisor: " + CONSOLIDADO->A3_CODSUP)
		
		//Quebra por supervisor.
		If CONSOLIDADO->A3_CODSUP != _Supervis
		    _nContaSup += 1
			totQbrNv(_cQuebraAnt+_cQuebraTot,1)
			totQbrtot()
			TotGer(_Supervis)
	        totNvSup()
			@nLin,000 Psay "|"+Replic("-",217)+"|"
			nLin := nLin + 1
			
			@nLin,002 Psay "|" + _supervis
			@nLin,218 Psay "|"
			nLin := nLin + 1
			
			@nLin,000 Psay "|"+Replic("-",217)+"|"
			nLin := nLin + 1
			
			_nQbrTotVnd :=	0
			_nQbrMtVnd	:=	0
			_nQbrReVnd	:=	0
			_nQbrRfVnd	:=	0
			_nQbrMtVol	:=	0
			_nCobQbr	:=  0
			
			_nAcVdT     :=	0
			_nAcMtPrcT	:=	0
			_nAcRePrcT	:=	0
			_nAcRfPrcT	:=	0
			_nAcMtVolT	:=	0
			
			_cQuebraAnt:=	CONSOLIDADO->BM_QBRNVL
			_cQuebraTot:=   CONSOLIDADO->X5_DESCRI
			nLin := 56
			
		EndIf
		
		//Quebra por quantidade de linhas.
		If nLin > 55 
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 6
			_Supervis := CONSOLIDADO->A3_CODSUP
			ImpCabec(_Supervis,_NomSup)
			
		EndIf                                   
		
		//Quebra por nํvel.
		If 	CONSOLIDADO->BM_QBRNVL != _cQuebraAnt
			totQbrNv(_cQuebraAnt+_cQuebraTot,1)
			_cQuebraAnt :=	CONSOLIDADO->BM_QBRNVL
			_nQbrTotVnd :=	0
			_nQbrMtVnd	:=	0
			_nQbrReVnd	:=	0
			_nQbrRfVnd	:=	0
			_nQbrMtVol	:=	0
			_nCobQbr	:=  0
			
		EndIf
		
		//Quebra por totalizador.
		If 	CONSOLIDADO->X5_DESCRI != _cQuebraTot
			totQbrtot()
			_cQuebraTot :=	CONSOLIDADO->X5_DESCRI
			_nAcVdT     :=	0
			_nAcMtPrcT	:=	0
			_nAcRePrcT	:=	0
			_nAcRfPrcT	:=	0
			_nAcMtVolT	:=	0
			
		EndIf
		
	  	If !(Alltrim(CONSOLIDADO->BM_QBRNVL) $ _cAgrupadores)
	   		If Empty(_cAgrupadores)
	   			_cAgrupadores := _cAgrupadores + CONSOLIDADO->BM_QBRNVL
	   				
	   		Else
	   			_cAgrupadores := _cAgrupadores + "+" + CONSOLIDADO->BM_QBRNVL
	   			
	   		EndIf
	   				  
	   	EndIf 
	   	
	   	If !(Alltrim(CONSOLIDADO->BM_GRUPO) $ _cAgrupGrupos)
	   		If Empty(_cAgrupGrupos)
	   			_cAgrupGrupos += "'" + CONSOLIDADO->BM_GRUPO + "',"
	   				
	   		Else
	   			_cAgrupGrupos := _cAgrupGrupos + "'" + CONSOLIDADO->BM_GRUPO + "',"
	   			
	   		EndIf
	   				  
	   	EndIf 

		cLin := "" 
		
		@nLin,000 Psay "|" + CONSOLIDADO->BM_QBRNVL + CONSOLIDADO->X5_DESCRI
		@nLin,005 Psay CONSOLIDADO->BM_GRUPO
		@nLin,010 Psay Substr(CONSOLIDADO->BM_DESC,1,20)
		cLin += CONSOLIDADO->BM_QBRNVL + CONSOLIDADO->X5_DESCRI + ";" + CONSOLIDADO->BM_GRUPO + " " + Substr(CONSOLIDADO->BM_DESC,1,20) + ";"
		
		@nLin,033 Psay "|" 
		@nLin,035 Psay CONSOLIDADO->PRC_META Picture "@E 99.99"   //Pre็o unitแrio meta.
		cLin += Transform(CONSOLIDADO->PRC_META,"@E 99.99")+";"
		
		@nLin,042 Psay CONSOLIDADO->PRC_REAL Picture "@E 99.99"   //Pre็o unitแrio real.
		cLin += Transform(CONSOLIDADO->PRC_REAL,"@E 99.99")+";"
		
		If _lDiret
		   @nLin,049 Psay CONSOLIDADO->PRC_REF Picture "@E 99.99" // Pre็o unitแrio refer๊ncia.
		   cLin += Transform(CONSOLIDADO->PRC_REF,"@E 99.99")+";"
		   
		EndIf   
		
		@nLin,057 Psay "|"
	
		@nLin,058 Psay CONSOLIDADO->FAT_META Picture "@E 999,999,999" //Faturamento Meta.
		cLin += Transform(CONSOLIDADO->FAT_META,"@E 999,999,999")+";"
		
		_nTotD := 0
		_nTotD += CONSOLIDADO->FAT_META
		_I :=  aScan(aAcD,{|x| x[2] == CONSOLIDADO->BM_GRUPO})
		
		If _I == 0
			Aadd(aAcD,{CONSOLIDADO->BM_QBRNVL,CONSOLIDADO->BM_GRUPO,_nTotD})
			
		Else
			aAcD[_I][3] += _nTotD
			
		EndIf
		
		@nLin,070 Psay CONSOLIDADO->FAT_REAL Picture "@E 999,999,999" // Faturamento real.
		cLin += Transform(CONSOLIDADO->FAT_REAL,"@E 999,999,999")+";"
		
		If _lDiret
		   @nLin,083 Psay CONSOLIDADO->FAT_REF Picture "@E 999,999,999"// Faturamento refer๊ncia.
		   cLin += Transform(CONSOLIDADO->FAT_REF,"@E 999,999,999")+";"
		   
		EndIf
		   
		@nLin,096 Psay CONSOLIDADO->FAT_DR_M Picture "@E 99,999,999" // Diferen็a faturamento real - faturamento meta.
		cLin += Transform(CONSOLIDADO->FAT_DR_M,"@E 99,999,999")+";"
		
		If _lDiret
		   @nLin,107 Psay CONSOLIDADO->FAT_DR_RF Picture "@E 99,999,999"  // "Diferen็a faturamento real - faturamento refer๊ncia.
		   cLin += Transform(CONSOLIDADO->FAT_DR_RF,"@E 99,999,999") +";"
		   
	    EndIf
	    
		@nLin,120 Psay "|"
		
		@nLin,125 Psay CONSOLIDADO->FAT_INDIPM Picture "@E 9.999"  //อndice IPM.
		cLin += Transform(CONSOLIDADO->FAT_INDIPM,"@E 9.999")+";"
		
		If _lDiret
		   @nLin,132 Psay CONSOLIDADO->FAT_INDIPR Picture "@E 99.999" //อndice IPR.
		   cLin += Transform(CONSOLIDADO->FAT_INDIPR,"@E 99.999")+";"

	    EndIf
	    
		@nLin,140 Psay "|"

		@nLin,140 Psay CONSOLIDADO->META_PESO Picture "@E 99,999,999"  //Volume meta.
		cLin += Transform(CONSOLIDADO->META_PESO,"@E 99,999,999")+";"
		
	    @nLin,152 Psay CONSOLIDADO->PESO_REAL Picture "@E 99,999,999"   //Volume real.
	    cLin += Transform(CONSOLIDADO->PESO_REAL,"@E 99,999,999")+";"
	
		@nLin,162 Psay CONSOLIDADO->PESO_PROJETADO Picture "@E 99,999,999,999" //Volume projetado.
		cLin += Transform(CONSOLIDADO->PESO_PROJETADO,"@E 99,999,999")+";"

		@nLin,177 Psay CONSOLIDADO->NECESSARIA Picture "@E 99999,999" //Volume necessแrio.
		cLin += Transform(CONSOLIDADO->NECESSARIA,"@E 99999,999" )+";"
		
		@nLin,188 Psay "|"

		@nLin,193 Psay CONSOLIDADO->ATING_R Picture "@E 99999.9"  //Atingimento realizado.
		cLin += Transform(CONSOLIDADO->ATING_R,"@E 99999.9" )+";"

		@nLin,204 Psay CONSOLIDADO->ATING_P Picture "@E 99999.9"  //Atingimento projetado.
		cLin += Transform(CONSOLIDADO->ATING_P,"@E 99999.9" )+";"
		
		@nLin,213 Psay CONSOLIDADO->COB PICTURE "@E 9999"  //Cobertura.
		cLin += Transform(CONSOLIDADO->COB,"@E 9999" ) + _eof
		
		fWrite(nHdl,cLin,Len(cLin))
		
		@nLin,218 Psay "|"
		
		nLin++
		
		//Totalizadores de quebra por nํvel.
		_nQbrTotVnd	+=  CONSOLIDADO->PESO_REAL
		_nQbrMtVnd	+=	CONSOLIDADO->FAT_META
		_nQbrReVnd	+=	CONSOLIDADO->FAT_REAL
		_nQbrMtVol	+=	CONSOLIDADO->META_PESO
		_nQbrRfVnd 	+=	CONSOLIDADO->FAT_REF
		_nCobQbr	+=	CONSOLIDADO->COB
		
		//Totalizadores de quebra por total.
		_nAcVdT     +=	CONSOLIDADO->PESO_REAL
		_nAcMtPrcT	+=	CONSOLIDADO->FAT_META  
		_nAcRePrcT	+=	CONSOLIDADO->FAT_REAL
		_nAcMtVolT	+=	CONSOLIDADO->META_PESO
	    _nAcRfPrcT	+=	CONSOLIDADO->FAT_REF
	    			
		_Supervis  	:= 	CONSOLIDADO->A3_CODSUP
		_cQuebraAnt	:=	CONSOLIDADO->BM_QBRNVL
		_cQuebraTot	:=  CONSOLIDADO->X5_DESCRI
		
		_cGrpos 	+= "'" + CONSOLIDADO->BM_GRUPO + "',"
		
		CONSOLIDADO->(DbSkip())
		
	Enddo
	
	totQbrNv(_cQuebraAnt+_cQuebraTot,1)
	totQbrtot()                               
	TotGer(_Supervis)
	totNvSup()
	
	@nLin,00 Psay "|" + Replic("-",217) + "|"
	
	nLin := nLin + 1
	
	@nLin,02 Psay _supervis
	
	nLin := nLin + 1
	
	@nLin,00 Psay "|" + Replic("-",217) + "|"
	
	nLin := nLin + 1
	
	Processa({||dadosCsld()},"Imprimindo dados consolidados")
	
	nLin := 56
             
	Set Device to Screen
	
	Ms_Flush()
	
	If aReturn[5]==1
		Set Printer to
		OurSpool(nomerel)
		
	endif 
	      
	fClose(nHdl)
	
	If __cUserID $ GETMV("MV_#USUTPR")
	   bBloco:={||_fOpenExcel()}
	   MsAguarde(bBloco,"Aguarde","Exportando dados para Microsoft Excel...",.F.)
	   
	EndIf    
	  
	If File("\SYSTEM\"+cArq)
		FErase("\SYSTEM\"+cArq)
		
	EndIf

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณscriptTotaบ Autor ณ Everson            บ Data ณ  15/02/2017 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Script sql para impressใo o resultado total por grupo.     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณChamado 032203.                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function scriptTotal()

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declaracao de Variaveis                                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู		
	Local cQuery	:= ""
	
	cQuery += " SELECT " 
	cQuery += " TOTAL.BM_QBRNVL, " 
	cQuery += " TOTAL.X5_DESCRI, " 
	cQuery += " TOTAL.BM_GRUPO, " 
	cQuery += " TOTAL.BM_DESC, " 
	cQuery += " AVG(TOTAL.PRC_META) AS PRC_META, " 
	cQuery += " CASE WHEN SUM(TOTAL.PESO_REAL) = 0 THEN 0 ELSE SUM(TOTAL.FAT_REAL)/SUM(TOTAL.PESO_REAL) END AS PRC_REAL, " 
	cQuery += " AVG(TOTAL.PRC_REF) AS PRC_REF, " 
	cQuery += " SUM(TOTAL.FAT_META) AS FAT_META, " 
	cQuery += " SUM(TOTAL.FAT_REAL) AS FAT_REAL, " 
	cQuery += " SUM(TOTAL.FAT_REF) AS FAT_REF, " 
	cQuery += " SUM(TOTAL.FAT_DR_M) AS FAT_DR_M, " 
	cQuery += " SUM(TOTAL.FAT_DR_RF) AS FAT_DR_RF, "
	 
	cQuery += " CASE WHEN SUM(TOTAL.FAT_META) = 0 THEN 0 ELSE SUM(TOTAL.FAT_REAL)/SUM(TOTAL.FAT_META) END AS FAT_INDIPM, "
	 
	cQuery += " CASE WHEN SUM(TOTAL.PESO_REAL) = 0 THEN 0  " 
	cQuery += " ELSE  " 
	cQuery += " (SUM(TOTAL.FAT_REAL)/SUM(TOTAL.PESO_REAL)) - (SUM(TOTAL.FAT_REF)/SUM(TOTAL.PESO_REAL)) " 
	cQuery += " END AS FAT_INDIPR, " 
	
	cQuery += " SUM(TOTAL.META_PESO) AS META_PESO, " 
	
	cQuery += " SUM(TOTAL.PESO_REAL) AS PESO_REAL, " 
	
	cQuery += " CASE WHEN " + cValToChar(_nDiasCorr) + " <> 0 THEN " 
	cQuery += " (SUM(TOTAL.PESO_REAL)/" + cValToChar(_nDiasCorr) + ") * " + cValToChar(_nDiasUtil) + " " 
	cQuery += " ELSE " 
	cQuery += " 0 " 
	cQuery += " END AS PESO_PROJETADO, " 
	
	cQuery += " CASE WHEN " + cValToChar(_nDiasUtil - _nDiasCorr) + " <> 0 THEN " 
	cQuery += " (COALESCE(SUM(TOTAL.META_PESO),0)-SUM(TOTAL.PESO_REAL)) / " + cValToChar(_nDiasUtil - _nDiasCorr) + " " 
	cQuery += " ELSE " 
	cQuery += " 0 " 
	cQuery += " END AS NECESSARIA, "
	 
	cQuery += " CASE WHEN SUM(TOTAL.META_PESO) <> 0 THEN  " 
	cQuery += " (SUM(TOTAL.PESO_REAL)/SUM(TOTAL.META_PESO))*100 " 
	cQuery += " ELSE " 
	cQuery += " 0 " 
	cQuery += " END AS ATING_R, " 
	
	cQuery += " CASE WHEN SUM(TOTAL.META_PESO) <> 0 AND " + cValToChar(_nDiasCorr) + " <> 0 THEN " 
	cQuery += " (((SUM(TOTAL.PESO_REAL)/" + cValToChar(_nDiasCorr) + ")*" + cValToChar(_nDiasUtil) + ")/SUM(TOTAL.META_PESO))*100 " 
	cQuery += " ELSE " 
	cQuery += " 0 " 
	cQuery += " END AS ATING_P,  " 
	
	cQuery += " SUM(TOTAL.COB) AS COB " 
	cQuery += " FROM " 
	cQuery += " ( " 
	
	cQuery += scriptConsolidado()
	
	cQuery += " ) AS TOTAL " 
	cQuery += " GROUP BY " 
	cQuery += " TOTAL.BM_QBRNVL, " 
	cQuery += " TOTAL.X5_DESCRI, " 
	cQuery += " TOTAL.BM_GRUPO, " 
	cQuery += " TOTAL.BM_DESC " 
	
	//Everson - 12/12/2018. Chamado 045773.
	//cQuery += " ORDER BY TOTAL.BM_QBRNVL, TOTAL.X5_DESCRI, TOTAL.BM_GRUPO "
	cQuery += " ORDER BY TOTAL.X5_DESCRI, TOTAL.BM_QBRNVL, TOTAL.BM_GRUPO " 

	//cQuery += " OPTION(QUERYTRACEON 9481) " // @history Ticket      ti - F. Macieira - 06/09/2021 - Performance Cloud OPTION(QUERYTRACEON 9481)

Return cQuery
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณscriptConsolidado บ Autor ณ Everson   บ Data ณ  14/02/2017  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Script sql com o consolidado por supervisor.               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณChamado 032203.                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function scriptConsolidado()

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declaracao de Variaveis                                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู	
	Local cQuery	:= ""
	
	cQuery := ""
	cQuery += " SELECT * " 
	cQuery += " FROM " 
	cQuery += " ( " 
	cQuery += " SELECT " 
	cQuery += " COALESCE(PRE_CONS.BM_QBRNVL,PRE_CONS.SUB_BM_QBRNVL)   AS BM_QBRNVL,  " 
	cQuery += " COALESCE(PRE_CONS.X5_DESCRI,PRE_CONS.SUB_X5_DESCRI)   AS X5_DESCRI, " 
	cQuery += " COALESCE(PRE_CONS.A3_CODSUP,PRE_CONS.SUB_A3_CODSUP)   AS A3_CODSUP, " 
	cQuery += " COALESCE(PRE_CONS.ZR_DESCRIC,PRE_CONS.SUB_ZR_DESCRIC) AS ZR_DESCRIC, " 
	cQuery += " COALESCE(PRE_CONS.BM_GRUPO,PRE_CONS.SUB_BM_GRUPO)     AS BM_GRUPO, " 
	cQuery += " COALESCE(PRE_CONS.BM_DESC,PRE_CONS.SUB_BM_DESC)       AS BM_DESC, " 
	cQuery += " COALESCE(PRE_CONS.PRC_META,PRE_CONS.SUB_PRC_META)     AS PRC_META, " 
	cQuery += " COALESCE(PRE_CONS.PRC_REAL,PRE_CONS.SUB_PRC_REAL)     AS PRC_REAL, " 
	cQuery += " COALESCE(PRE_CONS.PRC_REF,PRE_CONS.SUB_PRC_REF)       AS PRC_REF, " 
	cQuery += " COALESCE(PRE_CONS.FAT_META,PRE_CONS.SUB_FAT_META)     AS FAT_META, " 
	cQuery += " COALESCE(PRE_CONS.FAT_REAL,PRE_CONS.SUB_FAT_REAL)     AS FAT_REAL, " 
	cQuery += " COALESCE(PRE_CONS.FAT_REF,PRE_CONS.SUB_FAT_REF)       AS FAT_REF, " 
	cQuery += " COALESCE(PRE_CONS.FAT_DR_M,PRE_CONS.SUB_FAT_DR_M)     AS FAT_DR_M, " 
	cQuery += " COALESCE(PRE_CONS.FAT_DR_RF,PRE_CONS.SUB_FAT_DR_RF)   AS FAT_DR_RF, " 
	cQuery += " COALESCE(PRE_CONS.INDIPM,PRE_CONS.SUB_INDIPM)         AS FAT_INDIPM, " 
	cQuery += " COALESCE(PRE_CONS.INDIPR,PRE_CONS.SUB_INDIPR)         AS FAT_INDIPR, " 
	cQuery += " CASE WHEN PRE_CONS.META_PESO IS NULL OR PRE_CONS.META_PESO = 0 THEN PRE_CONS.SUB_META_PESO ELSE PRE_CONS.META_PESO END AS META_PESO, " 
	cQuery += " COALESCE(PRE_CONS.PESO_REAL,PRE_CONS.SUB_PESO_REAL)   AS PESO_REAL, " 
	cQuery += " COALESCE(PRE_CONS.PESO_PROJETADO,PRE_CONS.SUB_PESO_PROJETADO)   AS PESO_PROJETADO, " 
	
	cQuery += " CASE WHEN  " + cValToChar(_nDiasUtil - _nDiasCorr) + "  <> 0 THEN "
	cQuery += " (COALESCE(CASE WHEN PRE_CONS.META_PESO IS NULL OR PRE_CONS.META_PESO = 0 THEN PRE_CONS.SUB_META_PESO ELSE PRE_CONS.META_PESO END,0) "
	cQuery += " -COALESCE(PRE_CONS.PESO_REAL,PRE_CONS.SUB_PESO_REAL))/( " + cValToChar(_nDiasUtil - _nDiasCorr) + " ) "
	cQuery += " ELSE "
	cQuery += " 0 "
	cQuery += " END "
	cQuery += " AS NECESSARIA, "
	
	 
	cQuery += " COALESCE(PRE_CONS.ATING_R,PRE_CONS.SUB_ATING_R)       AS ATING_R, " 
	cQuery += " COALESCE(PRE_CONS.ATING_P,PRE_CONS.SUB_ATING_P)       AS ATING_P, " 
	cQuery += " COALESCE(PRE_CONS.COB,PRE_CONS.SUB_COB)               AS COB " 
	cQuery += " FROM " 
	cQuery += " ( " 
	cQuery += " SELECT " 
	cQuery += " METAATENDIDA.BM_QBRNVL, " 
	cQuery += " METAATENDIDA.X5_DESCRI, " 
	cQuery += " METAATENDIDA.A3_CODSUP, " 
	cQuery += " METAATENDIDA.ZR_DESCRIC, " 
	cQuery += " METAATENDIDA.BM_GRUPO, " 
	cQuery += " METAATENDIDA.BM_DESC, " 
	cQuery += " CASE WHEN METAATENDIDA.PRC_META = 0 THEN METAATENDIDA.PRC_META2 ELSE  METAATENDIDA.PRC_META  END AS PRC_META, " 
	cQuery += " METAATENDIDA.PRC_REAL, " 
	cQuery += " CASE WHEN METAATENDIDA.PESO_REAL = 0 THEN 0 ELSE " 
	cQuery += " METAATENDIDA.FAT_REF / METAATENDIDA.PESO_REAL  " 
	cQuery += " END AS PRC_REF, " 
	cQuery += " METAATENDIDA.PESO_REAL*(CASE WHEN METAATENDIDA.PRC_META = 0 THEN METAATENDIDA.PRC_META2 ELSE  METAATENDIDA.PRC_META  END) AS FAT_META, " 
	cQuery += " METAATENDIDA.FAT_REAL, " 
	cQuery += " METAATENDIDA.FAT_REF, " 
	cQuery += " METAATENDIDA.FAT_REAL-(METAATENDIDA.PESO_REAL*(CASE WHEN METAATENDIDA.PRC_META = 0 THEN METAATENDIDA.PRC_META2 ELSE  METAATENDIDA.PRC_META  END)) AS FAT_DR_M, " 
	cQuery += " METAATENDIDA.FAT_REAL-METAATENDIDA.FAT_REF AS FAT_DR_RF, " 
	
	cQuery += " CASE WHEN METAATENDIDA.PESO_REAL*(CASE WHEN METAATENDIDA.PRC_META = 0 THEN METAATENDIDA.PRC_META2 ELSE  METAATENDIDA.PRC_META  END) = 0 THEN 0 " 
	cQuery += " ELSE " 
	cQuery += " ((METAATENDIDA.PESO_REAL*(CASE WHEN METAATENDIDA.PRC_META = 0 THEN METAATENDIDA.PRC_META2 ELSE  METAATENDIDA.PRC_META  END)) + " 
	cQuery += " (METAATENDIDA.FAT_REAL-METAATENDIDA.PESO_REAL*(CASE WHEN METAATENDIDA.PRC_META = 0 THEN METAATENDIDA.PRC_META2 ELSE  METAATENDIDA.PRC_META  END)))/ " 
	cQuery += " (METAATENDIDA.PESO_REAL*(CASE WHEN METAATENDIDA.PRC_META = 0 THEN METAATENDIDA.PRC_META2 ELSE  METAATENDIDA.PRC_META  END)) " 
	cQuery += " END " 
	cQuery += " AS INDIPM, " 
	
	cQuery += " (METAATENDIDA.PRC_REAL -  " 
	cQuery += " (CASE WHEN METAATENDIDA.PESO_REAL = 0 THEN 0 ELSE " 
	cQuery += " METAATENDIDA.FAT_REF/ METAATENDIDA.PESO_REAL  " 
	cQuery += " END)) " 
	cQuery += " AS INDIPR, " 
	
	cQuery += " COALESCE(CASE WHEN METAATENDIDA.META_PESO = 0 THEN METAATENDIDA.META_PESO2 ELSE METAATENDIDA.META_PESO END,0) AS META_PESO, " 
	
	cQuery += " METAATENDIDA.PESO_REAL, " 
	
	cQuery += " CASE WHEN  " + cValToChar(_nDiasCorr) + " = 0 THEN 0 ELSE (METAATENDIDA.PESO_REAL/ " + cValToChar(_nDiasCorr) + ") * " + cValToChar(_nDiasUtil) + " END AS PESO_PROJETADO, " 
	
	cQuery += " COALESCE(CASE WHEN CASE WHEN METAATENDIDA.META_PESO = 0 THEN METAATENDIDA.META_PESO2 ELSE METAATENDIDA.META_PESO END = 0 THEN 0 " 
	cQuery += " ELSE " 
	cQuery += " (METAATENDIDA.PESO_REAL/ " 
	cQuery += " CASE WHEN METAATENDIDA.META_PESO = 0 THEN METAATENDIDA.META_PESO2 ELSE METAATENDIDA.META_PESO END)*100 " 
	cQuery += " END,0) AS ATING_R, "
	
	cQuery += " COALESCE(CASE WHEN  " + cValToChar(_nDiasCorr) + " = 0 OR (CASE WHEN METAATENDIDA.META_PESO = 0 THEN METAATENDIDA.META_PESO2 ELSE METAATENDIDA.META_PESO END) = 0 THEN 0 ELSE " 
	cQuery += " (((METAATENDIDA.PESO_REAL / " + cValToChar(_nDiasCorr) + ") * " + cValToChar(_nDiasUtil) + ") / (CASE WHEN METAATENDIDA.META_PESO = 0 THEN METAATENDIDA.META_PESO2 ELSE METAATENDIDA.META_PESO END))*100  " 
	cQuery += "  END,0) AS ATING_P, "
	
	cQuery += " COALESCE(METAATENDIDA.COB,0) AS COB, " 
	
	cQuery += " METAGERAL.* " 
	
	cQuery += " FROM " 
	cQuery += " ( " 
	cQuery += " SELECT " 
	
	cQuery += " VENDAS.BM_QBRNVL, " 
	cQuery += " VENDAS.X5_DESCRI, " 
	cQuery += " VENDAS.A3_CODSUP, " 
	cQuery += " VENDAS.ZR_DESCRIC, " 
	cQuery += " VENDAS.BM_GRUPO, " 
	cQuery += " VENDAS.BM_DESC, " 
	cQuery += " ROUND(AJ_METAVLR.PRC_META2,4) AS PRC_META2, " 
	cQuery += " ROUND(AVG(COALESCE(METAS.VALOR,0)),4) AS PRC_META, " 
	cQuery += " CASE WHEN SUM(VENDAS.QUANTLIQ) > 0  THEN  " 
	cQuery += " SUM(VENDAS.VALLIQ) / SUM(VENDAS.QUANTLIQ) " 
	cQuery += " ELSE " 
	cQuery += " 0 END AS PRC_REAL, " 
	cQuery += " SUM(VENDAS.VALLIQ) AS FAT_REAL, " 
	cQuery += " SUM(VENDAS.PRC_RF*VENDAS.QUANTLIQ) AS FAT_REF, " 
	cQuery += " AVG(COALESCE(METAS.PESO,0))  AS META_PESO, " 
	cQuery += " AJ_METAPESO.META_PESO2, " 
	cQuery += " SUM(VENDAS.QUANTLIQ) AS PESO_REAL, " 
	cQuery += " COUNT(DISTINCT VENDAS.D2_CLIENTE+VENDAS.D2_LOJA) AS COB " 
	
	cQuery += " FROM " 
	cQuery += " ( " 
	
	cQuery += scriptBase()
	
	cQuery += " ) AS VENDAS " 
	cQuery += " LEFT OUTER JOIN " 
	cQuery += " ( " 
	cQuery += " SELECT " 
	cQuery += " ZZT_SUPERV, " 
	cQuery += " BM_GRUPO, " 
	cQuery += " BM_NIVEL, " 
	cQuery += " BM_QBRNVL, " 
	cQuery += " COALESCE(X5_DESCRI,'9') AS X5_DESCRI, " 
	cQuery += " PESO, " 
	cQuery += " VALOR " 
	cQuery += " FROM " 
	cQuery += " ( " 
	cQuery += " SELECT  " 
	cQuery += " ZZT_SUPERV,  " 
	cQuery += " ZZT_GRUPO,  " 
	cQuery += " BM_GRUPO, " 
	cQuery += " BM_DESC, " 
	cQuery += " BM_NIVEL, " 
	cQuery += " BM_QBRNVL, " 
	cQuery += " SUM(ZZT_PESMET) AS 'PESO'  " 
	cQuery += " FROM  " 
	cQuery += "   " + RetSqlName("ZZT") + " (NOLOCK)  AS ZZT " 
	cQuery += " INNER JOIN " 
	cQuery += "  " + RetSqlName("SBM") + "  (NOLOCK)  AS SBM " 
	cQuery += " ON ZZT_GRUPO = BM_GRUPO " 
	cQuery += " WHERE " 
	cQuery += " ZZT.D_E_L_E_T_= '' " 
	cQuery += " AND SBM.D_E_L_E_T_= '' " 
	cQuery += " AND (ZZT_DATA BETWEEN '" + DToS(MV_PAR10) + "' AND '" + DToS(MV_PAR11) + "') "
	cQuery += " AND ZZT_PESMET > 0  " 
	cQuery += " GROUP BY  " 
	cQuery += " ZZT_SUPERV,  " 
	cQuery += " ZZT_GRUPO, " 
	cQuery += " BM_GRUPO, " 
	cQuery += " BM_DESC, " 
	cQuery += " BM_NIVEL, " 
	cQuery += " BM_QBRNVL " 
	cQuery += " ) AS VOLMETA " 
	cQuery += " LEFT OUTER JOIN " 
	cQuery += " ( " 
	cQuery += " SELECT " 
	cQuery += " X5_CHAVE, X5_DESCRI " 
	cQuery += " FROM " 
	cQuery += "  " + RetSqlName("SX5") + "  (NOLOCK) AS SX5 " 
	cQuery += " WHERE " 
	cQuery += " SX5.D_E_L_E_T_ = '' " 
	cQuery += " AND X5_FILIAL+X5_TABELA = '02W1' " 
	cQuery += " ) AS SX52 " 
	cQuery += " ON VOLMETA.BM_QBRNVL = SX52.X5_CHAVE " 
	cQuery += " LEFT OUTER JOIN " 
	cQuery += " ( " 
	cQuery += " SELECT  " 
	cQuery += " ZZS_GRUPO,  " 
	cQuery += " SUM(ZZS_PRMETA)/COUNT(*) AS 'VALOR'  " 
	cQuery += " FROM  " 
	cQuery += "  " + RetSqlName("ZZS") + "  (NOLOCK) AS ZZS " 
	cQuery += " WHERE " 
	cQuery += " ZZS.D_E_L_E_T_ = ''  " 
	cQuery += " AND (ZZS_DATA BETWEEN '" + DToS(MV_PAR10) + "' AND '" + DToS(MV_PAR11) + "') "
	cQuery += " AND ZZS_PRMETA > 0    " 
	cQuery += " GROUP BY  " 
	cQuery += " ZZS_GRUPO " 
	cQuery += " ) AS VLRMETA " 
	cQuery += " ON ZZT_GRUPO = VLRMETA.ZZS_GRUPO " 
	cQuery += " ) AS METAS " 
	cQuery += " ON VENDAS.A3_CODSUP  = METAS.ZZT_SUPERV " 
	cQuery += " AND VENDAS.X5_DESCRI = METAS.X5_DESCRI " 
	cQuery += " AND VENDAS.BM_NIVEL  = METAS.BM_NIVEL " 
	cQuery += " AND VENDAS.BM_QBRNVL = METAS.BM_QBRNVL " 
	cQuery += " AND VENDAS.BM_GRUPO  = METAS.BM_GRUPO " 
	cQuery += " LEFT OUTER JOIN " 
	cQuery += " ( " 
	cQuery += " SELECT  " 
	cQuery += " ZZS_GRUPO,  " 
	cQuery += " SUM(ZZS_PRMETA)/COUNT(*) AS 'PRC_META2'  " 
	cQuery += " FROM  " 
	cQuery += "  " + RetSqlName("ZZS") + "  (NOLOCK) AS ZZS " 
	cQuery += " WHERE " 
	cQuery += " ZZS.D_E_L_E_T_ = ''  " 
	cQuery += " AND (ZZS_DATA BETWEEN '" + DToS(MV_PAR10) + "' AND '" + DToS(MV_PAR11) + "') " 
	cQuery += " AND ZZS_PRMETA > 0    " 
	cQuery += " GROUP BY  " 
	cQuery += " ZZS_GRUPO " 
	cQuery += " ) AS AJ_METAVLR " 
	cQuery += " ON VENDAS.BM_GRUPO = AJ_METAVLR.ZZS_GRUPO " 
	cQuery += " LEFT OUTER JOIN " 
	cQuery += " ( " 
	cQuery += " SELECT " 
	cQuery += " ZZT_SUPERV,ZZT_GRUPO, " 
	cQuery += " SUM(ZZT_PESMET)/COUNT(*) AS 'META_PESO2' " 
	cQuery += " FROM " 
	cQuery += "   " + RetSqlName("ZZT") + "   (NOLOCK) AS ZZT " 
	cQuery += " WHERE " 
	cQuery += " ZZT.D_E_L_E_T_ = '' " 
	cQuery += " AND (ZZT_DATA BETWEEN '" + DToS(MV_PAR10) + "' AND '" + DToS(MV_PAR11) + "') "
	cQuery += " GROUP BY " 
	cQuery += " ZZT_SUPERV,ZZT_GRUPO " 
	cQuery += " ) AS AJ_METAPESO " 
	cQuery += " ON VENDAS.A3_CODSUP = AJ_METAPESO.ZZT_SUPERV " 
	cQuery += " AND VENDAS.BM_GRUPO = AJ_METAPESO.ZZT_GRUPO " 
	cQuery += " GROUP BY " 
	cQuery += " VENDAS.BM_QBRNVL, " 
	cQuery += " VENDAS.X5_DESCRI, " 
	cQuery += " VENDAS.A3_CODSUP, " 
	cQuery += " VENDAS.ZR_DESCRIC, " 
	cQuery += " VENDAS.BM_GRUPO, " 
	cQuery += " VENDAS.BM_DESC, " 
	cQuery += " AJ_METAVLR.PRC_META2, " 
	cQuery += " AJ_METAPESO.META_PESO2 " 
	cQuery += " ) AS METAATENDIDA " 
	cQuery += "  " 
	cQuery += " FULL OUTER JOIN " 
	cQuery += " ( " 
	cQuery += " SELECT  " 
	cQuery += " PRE_META.SUB_BM_QBRNVL, " 
	cQuery += " PRE_META.SUB_X5_DESCRI, " 
	cQuery += " PRE_META.SUB_A3_CODSUP, " 
	cQuery += " PRE_META.SUB_ZR_DESCRIC, " 
	cQuery += " PRE_META.SUB_BM_GRUPO, " 
	cQuery += " PRE_META.SUB_BM_DESC, " 
	cQuery += " ROUND(COALESCE(CASE WHEN PRE_META.SUB_PRC_META = 0 THEN AJ_METAVLR.PRC_META2 ELSE PRE_META.SUB_PRC_META END,0),4) AS SUB_PRC_META, " 
	cQuery += " PRE_META.SUB_PRC_REAL, " 
	cQuery += " PRE_META.SUB_PRC_REF, " 
	cQuery += " PRE_META.SUB_FAT_META, " 
	cQuery += " PRE_META.SUB_FAT_REAL, " 
	cQuery += " PRE_META.SUB_FAT_REF, " 
	cQuery += " PRE_META.SUB_FAT_DR_M, " 
	cQuery += " PRE_META.SUB_FAT_DR_RF, " 
	cQuery += " PRE_META.SUB_INDIPM, " 
	cQuery += " PRE_META.SUB_INDIPR, " 
	cQuery += " COALESCE(CASE WHEN PRE_META.SUB_META_PESO = 0 THEN AJ_METAPESO.META_PESO2 ELSE PRE_META.SUB_META_PESO END,0) AS SUB_META_PESO, " 
	cQuery += " PRE_META.SUB_PESO_REAL, " 
	cQuery += " PRE_META.SUB_PESO_PROJETADO, " 
	cQuery += " PRE_META.SUB_NECESSARIA, " 
	cQuery += " PRE_META.SUB_ATING_R, " 
	cQuery += " PRE_META.SUB_ATING_P, " 
	cQuery += " PRE_META.SUB_COB " 
	cQuery += " FROM " 
	cQuery += " ( " 
	cQuery += " SELECT " 
	cQuery += " METAF.BM_QBRNVL AS SUB_BM_QBRNVL, " 
	cQuery += " METAF.X5_DESCRI AS SUB_X5_DESCRI, " 
	cQuery += " METAF.ZZT_SUPERV AS SUB_A3_CODSUP, " 
	cQuery += " ZR_DESCRIC AS SUB_ZR_DESCRIC, " 
	cQuery += " METAF.ZZT_GRUPO AS SUB_BM_GRUPO,  " 
	cQuery += " BM_DESC AS SUB_BM_DESC, " 
	cQuery += " AVG(METAF.VLRMETASUB) AS SUB_PRC_META, " 
	cQuery += " 0 AS SUB_PRC_REAL, " 
	cQuery += " 0 AS SUB_PRC_REF, " 
	cQuery += " 0 AS SUB_FAT_META, " 
	cQuery += " 0 AS SUB_FAT_REAL, " 
	cQuery += " 0 AS SUB_FAT_REF, " 
	cQuery += " 0 AS SUB_FAT_DR_M, " 
	cQuery += " 0 AS SUB_FAT_DR_RF, " 
	cQuery += " 0 AS SUB_INDIPM, " 
	cQuery += " 0 AS SUB_INDIPR, " 
	cQuery += " SUM(METAF.PESO) AS SUB_META_PESO, " 
	cQuery += " 0 AS SUB_PESO_REAL, " 
	cQuery += " 0 AS SUB_PESO_PROJETADO, " 
	cQuery += " 0 AS SUB_NECESSARIA, " 
	cQuery += " 0 AS SUB_ATING_R, " 
	cQuery += " 0 AS SUB_ATING_P, " 
	cQuery += " 0 AS SUB_COB " 
	cQuery += " FROM " 
	cQuery += " ( " 
	cQuery += " SELECT   " 
	cQuery += " META.ZZT_SUPERV,   " 
	cQuery += " META.ZZT_GRUPO,   " 
	cQuery += " META.BM_QBRNVL,   " 
	cQuery += " COALESCE(META.X5_DESCRI,'9') AS X5_DESCRI,   " 
	cQuery += " META.PESO,   " 
	cQuery += " VLR_META.VLRMETASUB   " 
	cQuery += " FROM   " 
	cQuery += " (   " 
	cQuery += " SELECT    " 
	cQuery += " ZZT_SUPERV,    " 
	cQuery += " ZZT_GRUPO,   " 
	cQuery += " BM_QBRNVL,   " 
	cQuery += " X5_DESCRI,    " 
	cQuery += " COUNT(*) QUANT,    " 
	cQuery += " SUM(ZZT_VALOR)/COUNT(*) AS 'VALOR', 0 AS 'PESO'    " 
	cQuery += " FROM     " 
	cQuery += "   " + RetSqlName("ZZT") + "   (NOLOCK) AS ZZT   " 
	cQuery += " INNER JOIN   " 
	cQuery += "  " + RetSqlName("SBM") + "    (NOLOCK) AS SBM   " 
	cQuery += " ON ZZT_GRUPO = BM_GRUPO   " 
	cQuery += " LEFT OUTER JOIN   " 
	cQuery += " (   " 
	cQuery += " SELECT   " 
	cQuery += " X5_CHAVE, X5_DESCRI   " 
	cQuery += " FROM   " 
	cQuery += "  " + RetSqlName("SX5") + "  (NOLOCK) AS SX5   " 
	cQuery += " WHERE   " 
	cQuery += " SX5.D_E_L_E_T_ = ''   " 
	cQuery += " AND X5_FILIAL+X5_TABELA = '02W1'   " 
	cQuery += " ) AS SX51   " 
	cQuery += " ON BM_QBRNVL = SX51.X5_CHAVE   " 
	cQuery += " WHERE    " 
	cQuery += " ZZT.D_E_L_E_T_ = ''   " 
	
	cQuery += " AND SBM.D_E_L_E_T_ = ''  "
	
	cQuery += " AND (ZZT_DATA BETWEEN '" + DToS(MV_PAR10)  +"' AND '" + DToS(MV_PAR11) + "') "
	cQuery += " GROUP BY ZZT_SUPERV, ZZT_GRUPO, BM_QBRNVL, X5_DESCRI    " 
	cQuery += "  " 
	cQuery += " UNION    " 
	cQuery += "  " 
	cQuery += " SELECT    " 
	cQuery += " ZZT_SUPERV,    " 
	cQuery += " ZZT_GRUPO,   " 
	cQuery += " BM_QBRNVL,   " 
	cQuery += " X5_DESCRI,    " 
	cQuery += " COUNT(*) QUANT,    " 
	cQuery += " 0 AS 'VALOR', SUM(ZZT_PESMET) AS 'PESO'    " 
	cQuery += " FROM     " 
	cQuery += "   " + RetSqlName("ZZT") + " (NOLOCK) AS ZZT   " 
	cQuery += " INNER JOIN   " 
	cQuery += "  " + RetSqlName("SBM") + "  (NOLOCK) AS SBM   " 
	cQuery += " ON ZZT_GRUPO = BM_GRUPO   " 
	cQuery += " LEFT OUTER JOIN   " 
	cQuery += " (   " 
	cQuery += " SELECT   " 
	cQuery += " X5_CHAVE, X5_DESCRI   " 
	cQuery += " FROM   " 
	cQuery += "  " + RetSqlName("SX5") + "  (NOLOCK) AS SX5   " 
	cQuery += " WHERE   " 
	cQuery += " SX5.D_E_L_E_T_ = ''   " 
	cQuery += " AND X5_FILIAL+X5_TABELA = '02W1'   " 
	cQuery += " ) AS SX51   " 
	cQuery += " ON BM_QBRNVL = SX51.X5_CHAVE   " 
	cQuery += " WHERE    " 
	cQuery += " ZZT.D_E_L_E_T_ = ''   " 
				
	cQuery += " AND SBM.D_E_L_E_T_ = ''  "
	
	cQuery += " AND ZZT_PESMET > 0    " 
	cQuery += " AND (ZZT_DATA BETWEEN '" + DToS(MV_PAR10) + "' AND '" + DToS(MV_PAR11) + "') "
	cQuery += " GROUP BY ZZT_SUPERV, ZZT_GRUPO, BM_QBRNVL, X5_DESCRI   " 
	cQuery += " ) AS META   " 
	cQuery += " LEFT OUTER JOIN   " 
	cQuery += " (   " 
	cQuery += " SELECT    " 
	cQuery += " ZZS_GRUPO,     " 
	cQuery += " SUM(ZZS_PRMETA)/COUNT(*) AS 'VLRMETASUB'    " 
	cQuery += " FROM  " + RetSqlName("ZZS") + "  (NOLOCK)   " 
	cQuery += " WHERE   " 
	cQuery += " (ZZS_DATA BETWEEN '" + DToS(MV_PAR10) + "' AND '" + DToS(MV_PAR11) + "') "
	cQuery += " AND D_E_L_E_T_ = '' AND ZZS_PRMETA > 0      " 
	cQuery += " GROUP BY ZZS_GRUPO   " 
	cQuery += " ) AS VLR_META   " 
	cQuery += " ON META.ZZT_GRUPO = VLR_META.ZZS_GRUPO " 
	cQuery += " ) AS METAF " 
	cQuery += " INNER JOIN " 
	cQuery += "  " + RetSqlName("SBM") + " (NOLOCK) AS SBM " 
	cQuery += " ON METAF.ZZT_GRUPO = BM_GRUPO " 
	cQuery += " INNER JOIN " 
	cQuery += "  " + RetSqlName("SZR") + " (NOLOCK) AS SZR " 
	cQuery += " ON METAF.ZZT_SUPERV = ZR_CODIGO " 
	cQuery += " WHERE " 
	cQuery += " SBM.D_E_L_E_T_ = '' " 
	cQuery += " AND SZR.D_E_L_E_T_ = '' " 
	cQuery += " GROUP BY " 
	cQuery += " METAF.ZZT_SUPERV, ZR_DESCRIC,METAF.ZZT_GRUPO,BM_DESC, " 
	cQuery += " METAF.BM_QBRNVL, METAF.X5_DESCRI " 
	cQuery += " ) AS PRE_META " 
	cQuery += " LEFT OUTER JOIN " 
	cQuery += " ( " 
	cQuery += " SELECT  " 
	cQuery += " ZZS_GRUPO,  " 
	cQuery += " SUM(ZZS_PRMETA)/COUNT(*) AS 'PRC_META2'  " 
	cQuery += " FROM  " 
	cQuery += "  " + RetSqlName("ZZS") + " (NOLOCK) AS ZZS " 
	cQuery += " WHERE " 
	cQuery += " ZZS.D_E_L_E_T_ = ''  " 
	cQuery += " AND (ZZS_DATA BETWEEN '" + DToS(MV_PAR10) + "' AND '" + DToS(MV_PAR11) + "') "
	cQuery += " AND ZZS_PRMETA > 0    " 
	cQuery += " GROUP BY  " 
	cQuery += " ZZS_GRUPO " 
	cQuery += " ) AS AJ_METAVLR " 
	cQuery += " ON PRE_META.SUB_BM_GRUPO = AJ_METAVLR.ZZS_GRUPO " 
	cQuery += " LEFT OUTER JOIN " 
	cQuery += " ( " 
	cQuery += " SELECT " 
	cQuery += " ZZT_SUPERV,ZZT_GRUPO, " 
	cQuery += " SUM(ZZT_PESMET)/COUNT(*) AS 'META_PESO2' " 
	cQuery += " FROM " 
	cQuery += "   " + RetSqlName("ZZT") + " (NOLOCK)  AS ZZT " 
	cQuery += " WHERE " 
	cQuery += " ZZT.D_E_L_E_T_ = '' " 
	cQuery += " AND (ZZT_DATA BETWEEN '" + DToS (MV_PAR10) + "' AND '" + DToS(MV_PAR11) + "') "
	cQuery += " GROUP BY " 
	cQuery += " ZZT_SUPERV,ZZT_GRUPO " 
	cQuery += " ) AS AJ_METAPESO " 
	cQuery += " ON PRE_META.SUB_BM_GRUPO = AJ_METAPESO.ZZT_GRUPO " 
	cQuery += " AND PRE_META.SUB_A3_CODSUP = AJ_METAPESO.ZZT_SUPERV " 
	cQuery += " ) AS METAGERAL " 
	cQuery += " ON METAATENDIDA.A3_CODSUP = METAGERAL.SUB_A3_CODSUP " 
	cQuery += " AND METAATENDIDA.BM_QBRNVL = METAGERAL.SUB_BM_QBRNVL " 
	cQuery += " AND METAATENDIDA.X5_DESCRI =  METAGERAL.SUB_X5_DESCRI " 
	cQuery += " AND METAATENDIDA.BM_GRUPO = METAGERAL.SUB_BM_GRUPO " 
	cQuery += " ) AS PRE_CONS " 
	cQuery += " ) AS CONSOLIDADO "
	cQuery += " WHERE "
	cQuery += " CONSOLIDADO.A3_CODSUP >= '" + Alltrim(cValToChar(MV_PAR03)) + "' " 
	cQuery += " AND CONSOLIDADO.A3_CODSUP <= '" + Alltrim(cValToChar(MV_PAR04)) + "' " 

Return cQuery
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณcobSuperv บ Autor ณ Everson            บ Data ณ  14/02/2017 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Script sql com o consolidado por supervisor.               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณChamado 032203.                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function cobSuperv()

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declaracao de Variaveis                                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู	
	Local cQuery	:= ""
	Local nCobTot	:= 0
	
	cQuery := ""
	cQuery += " SELECT "
	
	cQuery += " VENDAS.A3_CODSUP, COUNT(DISTINCT VENDAS.D2_CLIENTE+VENDAS.D2_LOJA) AS COB "
	cQuery += " FROM "
	cQuery += " ( "
	
	cQuery += scriptBase()
	
	cQuery += " ) AS VENDAS "
	cQuery += " GROUP BY VENDAS.A3_CODSUP ORDER BY VENDAS.A3_CODSUP "

	//cQuery += " OPTION(QUERYTRACEON 9481) " // @history Ticket      ti - F. Macieira - 06/09/2021 - Performance Cloud OPTION(QUERYTRACEON 9481)
	
	If Select("COBSUP") > 0
		COBSUP->(DbCloseArea())
	EndIf
	
	TcQuery cQuery New Alias "COBSUP"

	DbSelectArea("COBSUP")
	While ! COBSUP->(Eof())
		
		oHashSuper:Set(COBSUP->A3_CODSUP,COBSUP->COB)
		
		nCobTot += Val(cValToChar(COBSUP->COB))
		
		COBSUP->(DbSkip())
	EndDo
	DbCloseArea("COBSUP")
	
	oHashSuper:Set("TOTAL",nCobTot)

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณcobNvTot  บ Autor ณ Everson            บ Data ณ  20/02/2017 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Script sql com o consolidado por supervisor, nํvel e       บฑฑ
ฑฑ           ณ totalizador.                                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณChamado 032203.                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function cobNvTot()

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declaracao de Variaveis                                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู	
	Local cQuery	:= ""
	Local cChave	:= ""
	
	cQuery := ""
	cQuery += " SELECT "
	
	cQuery += " VENDAS.A3_CODSUP, BM_QBRNVL, X5_DESCRI, "
	cQuery += " COUNT(DISTINCT VENDAS.D2_CLIENTE+VENDAS.D2_LOJA) AS COB  "
	cQuery += " FROM "
	cQuery += " ( "
	
	cQuery += scriptBase()
	
	cQuery += " ) AS VENDAS "
	cQuery += " GROUP BY VENDAS.A3_CODSUP, X5_DESCRI, BM_QBRNVL ORDER BY VENDAS.A3_CODSUP, X5_DESCRI, BM_QBRNVL "

	//cQuery += " OPTION(QUERYTRACEON 9481) " // @history Ticket      ti - F. Macieira - 06/09/2021 - Performance Cloud OPTION(QUERYTRACEON 9481)
	
	If Select("COBNVBQL") > 0
		COBNVBQL->(DbCloseArea())
	EndIf
	
	TcQuery cQuery New Alias "COBNVBQL"

	DbSelectArea("COBNVBQL")
	While ! COBNVBQL->(Eof())
	
		cChave := Alltrim(cValToChar(COBNVBQL->A3_CODSUP))+Alltrim(cValToChar(COBNVBQL->BM_QBRNVL))+Alltrim(cValToChar(COBNVBQL->X5_DESCRI))
		
		oHashCobSNB:Set(cChave,COBNVBQL->COB)
		
		COBNVBQL->(DbSkip())
	EndDo
	DbCloseArea("COBNVBQL")

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณcobConsoliบ Autor ณ Everson            บ Data ณ  06/03/2017 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Script sql com o consolidado por grupo, nํvel e            บฑฑ
ฑฑ           ณ totalizador.                                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณChamado 033828.                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function cobConsolidado()

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declaracao de Variaveis                                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู	
	Local cQuery	:= ""
	Local cChave	:= ""
	
	cQuery := ""
	cQuery += " SELECT "
	
	cQuery += " BM_QBRNVL, X5_DESCRI, BM_GRUPO,
	cQuery += " COUNT(DISTINCT VENDAS.D2_CLIENTE+VENDAS.D2_LOJA) AS COB   "
	cQuery += " FROM "
	cQuery += " ( "
	
	cQuery += scriptBase()
	
	cQuery += " ) AS VENDAS "
	cQuery += " GROUP BY X5_DESCRI, BM_QBRNVL, BM_GRUPO ORDER BY X5_DESCRI, BM_QBRNVL, BM_GRUPO "

	//cQuery += " OPTION(QUERYTRACEON 9481) " // @history Ticket      ti - F. Macieira - 06/09/2021 - Performance Cloud OPTION(QUERYTRACEON 9481)
	
	If Select("COBCONS") > 0
		COBCONS->(DbCloseArea())
	EndIf
	
	TcQuery cQuery New Alias "COBCONS"

	DbSelectArea("COBCONS")
	While ! COBCONS->(Eof())
	
		cChave := Alltrim(cValToChar(COBCONS->BM_QBRNVL))+Alltrim(cValToChar(COBCONS->X5_DESCRI))+Alltrim(cValToChar(COBCONS->BM_GRUPO))
		
		oHashCobCons:Set(cChave,COBCONS->COB)
		
		COBCONS->(DbSkip())
	EndDo
	DbCloseArea("COBCONS")

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณcobTConsolบ Autor ณ Everson            บ Data ณ  06/03/2017 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Script sql com o consolidado por nํvel e  totalizador      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณChamado 033828.                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function cobTConsolidado()

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declaracao de Variaveis                                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู	
	Local cQuery	:= ""
	Local cChave	:= ""
	
	cQuery := ""
	cQuery += " SELECT "
	
	cQuery += " BM_QBRNVL, X5_DESCRI,
	cQuery += " COUNT(DISTINCT VENDAS.D2_CLIENTE+VENDAS.D2_LOJA) AS COB   "
	cQuery += " FROM "
	cQuery += " ( "
	
	cQuery += scriptBase()
	
	cQuery += " ) AS VENDAS "
	cQuery += " GROUP BY X5_DESCRI, BM_QBRNVL ORDER BY X5_DESCRI, BM_QBRNVL "

	//cQuery += " OPTION(QUERYTRACEON 9481) " // @history Ticket      ti - F. Macieira - 06/09/2021 - Performance Cloud OPTION(QUERYTRACEON 9481)
	
	If Select("COBTCONS") > 0
		COBTCONS->(DbCloseArea())
	EndIf
	
	TcQuery cQuery New Alias "COBTCONS"

	DbSelectArea("COBTCONS")
	While ! COBTCONS->(Eof())
	
		cChave := Alltrim(cValToChar(COBTCONS->BM_QBRNVL))+Alltrim(cValToChar(COBTCONS->X5_DESCRI))

		oHashCobTCons:Set(cChave,COBTCONS->COB)
		
		COBTCONS->(DbSkip())
	EndDo
	DbCloseArea("COBTCONS")

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณcarteira  บ Autor ณ Everson            บ Data ณ  20/02/2017 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณConsulta carteira por supervisor.                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณChamado 032203.                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function carteira()

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declaracao de Variaveis                                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local cQuery	:= ""
	
	cQuery := ""
	cQuery += " SELECT A3.A3_CODSUP, COUNT(*) AS 'QTD_CLI'" 
	cQuery += " FROM " + RetSqlName("SA1") +  " (NOLOCK) A1,"
	cQuery += "       " + RetSqlName("SA3") + " (NOLOCK) A3"
	cQuery += " WHERE A1.D_E_L_E_T_ = ''"
	cQuery += " AND A3.D_E_L_E_T_ = '' "
	
	If mv_par12 == 1
	   cQuery += "   AND A1.A1_VEND = A3.A3_COD"
	   
	Else
	   cQuery += "   AND A1.A1_XVEND2 = A3.A3_COD"
	   
	EndIf
	   
	cQuery += " GROUP BY A3.A3_CODSUP ORDER BY A3.A3_CODSUP "

	//cQuery += " OPTION(QUERYTRACEON 9481) " // @history Ticket      ti - F. Macieira - 06/09/2021 - Performance Cloud OPTION(QUERYTRACEON 9481)
	
	If Select("CARTEIRA") > 0
		CARTEIRA->(DbCloseArea())
	EndIf
	
	TcQuery cQuery New Alias "CARTEIRA"

	CARTEIRA->(DbGoTop())
	
	While ! CARTEIRA->(EOF())
	
		oHashCart:Set(Alltrim(cValToChar(CARTEIRA->A3_CODSUP)),CARTEIRA->QTD_CLI)
		
		CARTEIRA->(dbskip())
		
	EndDo
	   
	CARTEIRA->(DbCloseArea()) 
	
Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณativosSupeบ Autor ณ Everson            บ Data ณ  14/02/2017 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Script sql com dados dos clientes ativos 1 e 2.            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณChamado 032203.                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ativosSuper()

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declaracao de Variaveis                                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู	
	Local cQuery	:= ""
	Local nAtvTT1	:= 0
	Local nAtvTT2	:= 0
	
	cQuery := ""
	cQuery += " SELECT "
	cQuery += " ATIVOS.A3_CODSUP, "
	cQuery += " SUM(CASE WHEN ATIVOS.TOTAL >= " + cValToChar(MV_PAR08) + " THEN 1 ELSE 0 END) AS ATIV1, "
	cQuery += " SUM(CASE WHEN ATIVOS.TOTAL >= " + cValToChar(MV_PAR09) + " THEN 1 ELSE 0 END) AS ATIV2 "
	cQuery += " FROM "
	cQuery += " ( "
	cQuery += " SELECT "
	cQuery += " VENDAS.A3_CODSUP, "
	cQuery += " VENDAS.D2_CLIENTE, "
	cQuery += " VENDAS.D2_LOJA, "
	cQuery += " SUM(VENDAS.D2_TOTAL) AS TOTAL "
	cQuery += " FROM " 
	cQuery += " ( "
	
	cQuery += scriptBase()
	
	cQuery += " ) AS VENDAS "
	cQuery += " GROUP BY "
	cQuery += " VENDAS.A3_CODSUP, "
	cQuery += " VENDAS.D2_CLIENTE, "
	cQuery += " VENDAS.D2_LOJA "
	cQuery += " ) AS ATIVOS "
	cQuery += " GROUP BY "
	cQuery += " ATIVOS.A3_CODSUP "
	cQuery += " ORDER BY ATIVOS.A3_CODSUP "

	//cQuery += " OPTION(QUERYTRACEON 9481) " // @history Ticket      ti - F. Macieira - 06/09/2021 - Performance Cloud OPTION(QUERYTRACEON 9481)
	
	If Select("ATIVOS") > 0
		ATIVOS->(DbCloseArea())
	EndIf
	
	TcQuery cQuery New Alias "ATIVOS"
	
	DbSelectArea("ATIVOS")
	While ! ATIVOS->(Eof())
		
		oHashAtivo:Set(ATIVOS->A3_CODSUP,cValToChar(ATIVOS->ATIV1) + "/" + cValToChar(ATIVOS->ATIV2))
		
		nAtvTT1	+= Val(cValToChar(ATIVOS->ATIV1))
		nAtvTT2	+= Val(cValToChar(ATIVOS->ATIV2))
		
		ATIVOS->(DbSkip())
	EndDo
	DbCloseArea("ATIVOS")
	
	oHashAtivo:Set("TOTAL",cValToChar(nAtvTT1) + "/" + cValToChar(nAtvTT2))

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณcobGrp    บ Autor ณ Everson            บ Data ณ  14/02/2017 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Script sql com a cobertura por supervisor.                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณChamado 032203.                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function cobGrp(cSuper,cGrupos)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declaracao de Variaveis                                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู	
	Local cQuery	:= ""
	Local nCob		:= 0
	
	If Empty(Alltrim(cValToChar(cSuper))) .And. Empty(Alltrim(cValToChar(cGrupos)))
		Return nCob
		
	EndIf	

	cQuery := ""
	cQuery += " SELECT "
	cQuery += " COUNT(DISTINCT VENDAS.D2_CLIENTE+VENDAS.D2_LOJA) AS COB "
	cQuery += " FROM "
	cQuery += " ( "
	
	cQuery += scriptBase()
	cGrupos:= StrTran(cGrupos,"'","")
	cGrupos:= StrTran(cGrupos,",","|")
	cQuery += " ) AS VENDAS "
	//Substituido por CHARINDEX por Adriana para otimizar consulta - chamado 039792	
	//cQuery += " WHERE VENDAS.BM_GRUPO IN ('" + cGrupos + "') "
	cQuery += " WHERE (CHARINDEX(CONVERT(CHAR(4),( VENDAS.BM_GRUPO )),( '" + cGrupos + "' ))>0 ) "
	
	If ! Empty(Alltrim(cValToChar(cSuper)))
		cQuery += " AND VENDAS.A3_CODSUP = '" + Alltrim(cValToChar(cSuper)) + "' "
		
	EndIf

	If Select("COBGRP") > 0
		COBGRP->(DbCloseArea())
		
	EndIf
	
	TcQuery cQuery New Alias "COBGRP"
	
	DbSelectArea("COBGRP")
		nCob := Val(cValToChar(COBGRP->COB))
	DbCloseArea("COBGRP")

Return nCob
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณscriptBaseบ Autor ณ Everson            บ Data ณ  14/02/2017 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Script sql base com as vendas do perํodo.                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณChamado 032203.                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function scriptBase()

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declaracao de Variaveis                                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู	
	Local cQuery	:= ""
	
	cQuery := ""
	cQuery += " SELECT " 
	
	cQuery += " D2_FILIAL,  " 
	cQuery += " D2_EMISSAO,  " 
	cQuery += " D2_DOC,  " 
	cQuery += " D2_SERIE, " 
	cQuery += " SA31.A3_CODSUP, " 
	cQuery += " SA31.ZR_DESCRIC, " 
	cQuery += " F2_VEND1,  " 
	cQuery += " F2_XVEND2,  " 
	cQuery += " D2_PEDIDO,  " 
	cQuery += " D2_CLIENTE,  " 
	cQuery += " D2_LOJA,  " 
	cQuery += " D2_COD,  " 
	cQuery += " ROUND(D2_QUANT-D2_QTDEDEV,0) AS QUANTLIQ, " 
	cQuery += " D2_PRCVEN, " 
	cQuery += " D2_TOTAL, "
	cQuery += " PRC_RF.PRC_RF,  " 
	cQuery += " ROUND((CASE WHEN A1_DESC > 0 " 
	cQuery += " THEN  " 
	cQuery += " (D2_TOTAL-D2_VALDEV)-(((D2_TOTAL-D2_VALDEV)*A1_DESC)/100) " 
	cQuery += " ELSE D2_TOTAL-D2_VALDEV END) - " 
	cQuery += " (( " 
	cQuery += " D2_QUANT-D2_QTDEDEV " 
	cQuery += " ) * (CASE WHEN C5_TPFRETE = 'C' THEN C5_FRETAPV ELSE 0 END)),4) AS VALLIQ, " 
	cQuery += " BM_GRUPO, " 
	cQuery += " BM_DESC, " 
	cQuery += " BM_NIVEL, " 
	cQuery += " BM_QBRNVL, " 
	cQuery += " SUBSTRING(COALESCE(X5_DESCRI,'9'),1,1) AS X5_DESCRI, " 
	cQuery += " META_NCONST.ZZT_PESMET " 
	 
	cQuery += " FROM    " 
	cQuery += "  " + RetSqlName("SF2") + " (NOLOCK) AS SF2 " 
	cQuery += " INNER JOIN    " 
	cQuery += "   " + RetSqlName("SD2") + " (NOLOCK) AS SD2 " 
	cQuery += " ON F2_FILIAL = D2_FILIAL " 
	cQuery += " AND F2_DOC = D2_DOC " 
	cQuery += " AND F2_SERIE = D2_SERIE " 
	cQuery += " INNER JOIN " 
	cQuery += "   " + RetSqlName("SC5") + " (NOLOCK) AS SC5 " 
	cQuery += " ON D2_FILIAL = C5_FILIAL " 
	cQuery += " AND D2_FILIAL = C5_FILIAL " 
	cQuery += " AND D2_PEDIDO = C5_NUM " 
	cQuery += " AND D2_CLIENTE = C5_CLIENTE " 
	cQuery += " AND D2_LOJA = C5_LOJACLI " 
	cQuery += " INNER JOIN   " 
	cQuery += "   " + RetSqlName("SA1") + " (NOLOCK) AS SA1 " 
	cQuery += " ON F2_CLIENTE = A1_COD   " 
	cQuery += " AND F2_LOJA = A1_LOJA " 
	cQuery += " INNER JOIN " 
	cQuery += "   " + RetSqlName("SB1") + " (NOLOCK) AS SB1 " 
	cQuery += " ON D2_COD = B1_COD " 
	cQuery += " LEFT OUTER JOIN " 
	cQuery += "   " + RetSqlName("SBM") + " (NOLOCK) AS SBM " 
	cQuery += " ON B1_GRUPO = BM_GRUPO " 
	cQuery += " LEFT OUTER JOIN " 
	cQuery += " ( " 
	cQuery += " SELECT " 
	cQuery += " X5_CHAVE, X5_DESCRI " 
	cQuery += " FROM " 
	cQuery += "  " + RetSqlName("SX5") + " (NOLOCK) AS SX5 " 
	cQuery += " WHERE " 
	cQuery += " SX5.D_E_L_E_T_ = '' " 
	cQuery += " AND X5_FILIAL+X5_TABELA = '02W1' " 
	cQuery += " ) AS SX51 " 
	cQuery += " ON BM_QBRNVL = SX51.X5_CHAVE " 
	cQuery += " INNER JOIN " 
	cQuery += " ( " 
	cQuery += " SELECT A3_COD, A3_CODSUP, ZR_DESCRIC " 
	cQuery += " FROM " + RetSqlName("SA3") + " (NOLOCK) AS SA3 " 
	cQuery += " INNER JOIN      " 
	cQuery += "  " + RetSqlName("SZR") + " (NOLOCK) AS SZR " 
	cQuery += " ON A3_CODSUP = ZR_CODIGO " 
	cQuery += " WHERE " 
	cQuery += " SA3.D_E_L_E_T_ = '' " 
	cQuery += " AND SZR.D_E_L_E_T_ = '' " 
	cQuery += " ) AS SA31 " 
	
	If MV_PAR12 == 1
		cQuery += " ON F2_VEND1 = SA31.A3_COD " 
	
	Else
		cQuery += " ON F2_XVEND2 = SA31.A3_COD " 
		
	EndIf
	
	cQuery += " LEFT OUTER JOIN " 
	cQuery += " ( " 
	cQuery += " SELECT " 
	cQuery += " ZZS_DATA, " 
	cQuery += " ZZS_GRUPO, " 
	cQuery += " MAX(ZZS_VALOR) AS PRC_RF " 
	cQuery += " FROM  " 
	cQuery += "  " + RetSqlName("ZZS") + " (NOLOCK) AS ZZS " 
	cQuery += " WHERE " 
	cQuery += " ZZS.D_E_L_E_T_ = ''  " 
	cQuery += " GROUP BY " 
	cQuery += " ZZS_DATA, " 
	cQuery += " ZZS_GRUPO " 
	cQuery += " ) AS PRC_RF " 
	cQuery += " ON " 
	cQuery += " D2_EMISSAO = PRC_RF.ZZS_DATA " 
	cQuery += " AND BM_GRUPO = PRC_RF.ZZS_GRUPO " 
	cQuery += " FULL OUTER JOIN " 
	cQuery += " ( " 
	cQuery += " SELECT " 
	cQuery += " ZZT_DATA, " 
	cQuery += " ZZT_GRUPO, " 
	cQuery += " ZZT_SUPERV, " 
	cQuery += " SUM(ZZT_PESMET) AS ZZT_PESMET " 
	cQuery += " FROM " 
	cQuery += "   " + RetSqlName("ZZT") + " (NOLOCK) AS ZZT " 
	cQuery += " INNER JOIN " 
	cQuery += "  " + RetSqlName("SZR") + "  (NOLOCK) AS SZR " 
	cQuery += " ON ZZT_SUPERV = ZR_CODIGO " 
	cQuery += " WHERE " 
	cQuery += " ZZT.D_E_L_E_T_ = '' " 
	cQuery += " AND SZR.D_E_L_E_T_ = '' " 
	cQuery += " AND ZZT_PESMET > 0 " 
	cQuery += " GROUP BY " 
	cQuery += " ZZT_DATA, " 
	cQuery += " ZZT_GRUPO, " 
	cQuery += " ZZT_SUPERV " 
	cQuery += " ) AS META_NCONST " 
	cQuery += " ON D2_EMISSAO = META_NCONST.ZZT_DATA " 
	cQuery += " AND SA31.A3_CODSUP = META_NCONST.ZZT_SUPERV " 
	cQuery += " AND BM_GRUPO = META_NCONST.ZZT_GRUPO " 
	cQuery += " WHERE    "             
	//  Substituido por CHARINDEX por Adriana para otimizar consulta - chamado 039792	                                                                   
	//	cQuery += " F2_FILIAL IN (" + Alltrim(cValToChar(MV_PAR05)) + ") " 									
	//Ticket   15553 - Abel Babini - 14/06/2021 - Corre็ใo de error log no retorno das filiais selecionadas.
	//cQuery += " (CHARINDEX(CONVERT(CHAR(2),(F2_FILIAL)),('" + Alltrim(_cFilIn) + "'))>0) " //15718 - Everson     - 16/06/2021.

	cQuery += " F2_FILIAL IN " + MV_PAR05 + " " //15718 - Everson     - 16/06/2021.
	
	cQuery += " AND F2_TIPO ='N' " 
	cQuery += " AND D2_TP   ='PA' " 
	cQuery += " AND F2_EMISSAO BETWEEN '" + DToS(MV_PAR01) + "' and '" + DToS(MV_PAR02) + "' " 
	cQuery += " AND SF2.D_E_L_E_T_= '' " 
	cQuery += " AND SD2.D_E_L_E_T_= '' " 
	cQuery += " AND SC5.D_E_L_E_T_= '' " 
	cQuery += " AND SA1.D_E_L_E_T_= '' " 
	cQuery += " AND SB1.D_E_L_E_T_ = '' " 
	cQuery += " AND SBM.D_E_L_E_T_ = '' "   
//  Substituido por CHARINDEX por Adriana para otimizar consulta - chamado 039792	
//	cQuery += " AND (LEFT(D2_CF,4) IN ('5922','6922') OR   "  
//	cQuery += " (LEFT(D2_CF,2) <> '59' AND LEFT(D2_CF,2) <> '69' AND LEFT(D2_CF,4) <> '5116' AND LEFT(D2_CF,4) <> '6116' AND LEFT(D2_CF,4) <> '5151' AND LEFT(D2_CF,4) <> '6151')) " 
 	cQuery += " AND ("
  	cQuery += " (CHARINDEX(CONVERT(CHAR(4),( LEFT(D2_CF,4))), ('5922,6922'))>0) OR"
  	cQuery += " ("	
  	cQuery += " (CHARINDEX(CONVERT(CHAR(2),( LEFT(D2_CF,2))), ('59,69'))=0) AND" 
  	cQuery += " (CHARINDEX(CONVERT(CHAR(4),( LEFT(D2_CF,4))), ('5116,6116,5151,6151'))=0)" 
  	cQuery += " )"
  	cQuery += " )"  
 	cQuery += " AND BM_NIVEL = '3' " 
	cQuery += " AND SA31.A3_CODSUP >= '" + Alltrim(cValToChar(MV_PAR03)) + "' " 
	cQuery += " AND SA31.A3_CODSUP <= '" + Alltrim(cValToChar(MV_PAR04)) + "' " 

Return cQuery 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณImpCabec  บ Autor ณ Everson            บ Data ณ  17/02/2017 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณCabe็alho do relat๓rio.                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณChamado 032203.                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ImpCabec(_Supervis)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declaracao de Variaveis                                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local cAtivos	:= ""
	Local cAtivo1	:= ""
	Local cAtivo2	:= ""
	Local cCobertura:= ""
	Local Cabec3	:= ""
	Local Cabec4	:= ""
	Local Cabec5	:= ""
	Local cabec5B	:= ""
	
	Private _nQtdcart := 0

	oHashCart:Get(Alltrim(cValToChar(_Supervis)),@_nQtdcart)
	_nQtdcart := Val(cValToChar(_nQtdcart))
	
	@nLin,001 Psay Replic("_",217)
	nLin := nLin + 1 
	            
	If Ascan(_aSup,_Supervis) == 0
	   Aadd(_aSup,_Supervis)
	   _nQtcartT += _nQtdcart

	EndIf

	oHashAtivo:Get(_Supervis,@cAtivos)
	
	aAtivos := StrToKarr(cAtivos,"/")
	If Len(aAtivos) <> 2
		cAtivo1 := "0"
		cAtivo2 := "0"
	Else
		cAtivo1 := aAtivos[1]
		cAtivo2 := aAtivos[2]
	
	EndIf
	
	oHashSuper:Get(_Supervis,@cCobertura)
	
	_NomSup 	:= Posicione("SZR",1,xFilial("SZR")+_Supervis,"ZR_DESCRIC")
	_TamNomSUp 	:= Len(_NomSup)
	
	Cabec3 := "| SUPERVISOR: "+ _Supervis +" - "+ _NomSup + Space(108-_TamNomSUp)+"DE : "+substr(dtos(mv_par01),7,2)+"/"+substr(dtos(mv_par01),5,2)+"/"+substr(dtos(mv_par01),1,4) +Space(54)+"  DIAS UTEIS: " +right(str(_nDiasUtil),2)+"  |"
	   cLin := "SUPERVISOR:;"+_Supervis+";"+_NomSup+";;;;;DE:"+substr(dtos(mv_par01),7,2)+"/"+substr(dtos(mv_par01),5,2)+"/"+substr(dtos(mv_par01),1,4)+";;;;;DIAS UTEIS:;"+right(str(_nDiasUtil),2)+";;;"+_eof
	   fWrite(nHdl,cLin,Len(cLin))
	
	Cabec4 := "|"+Space(130)+"ATE: "+substr(dtos(mv_par02),7,2)+"/"+substr(dtos(mv_par02),5,2)+"/"+substr(dtos(mv_par02),1,4) +Space(2)+Space(51)+ "DIAS CORRIDOS: " +right(str(_nDiasCorr),2)+"  |"
	   cLin := ";;;;;;;ATE:"+substr(dtos(mv_par02),7,2)+"/"+substr(dtos(mv_par02),5,2)+"/"+substr(dtos(mv_par02),1,4)+";;;;;DIAS CORRIDOS:;"+right(str(_nDiasCorr),2)+";;;"+_eof
	   fWrite(nHdl,cLin,Len(cLin))
	
	Cabec5 := "| CLIENTES CARTEIRA : "+right(str(_nQtdcart),5)+"        COBERTURA MES: " + cValToChar(cCobertura) + "     ATIVO1: " + cAtivo1 + "     ATIVO2: " + cAtivo2
	   cLin := "CLIENTES;CARTEIRA:;"+right(str(_nQtdcart),5)+";;;;COBERTURA;MES:" + cValToChar(cCobertura) + ";;ATIVO1:;" + cAtivo1 + ";;ATIVO2:;" + cAtivo2 + ";;;"+_eof
	   fWrite(nHdl,cLin,Len(cLin))
	   fWrite(nHdl,_Vazia,Len(_vazia))    &&inclui 1 linha em branco

	cabec5B:="   "+ Space(149)+"|"
	
	@nLin,000 Psay Cabec3
	nLin++
	
	@nLin,00 Psay Cabec4
	nLin++
	
	@nLin,00 Psay Cabec5
	
	@nLin,067 Psay Cabec5B
	nLin++
	
	@nLin,000 Psay "|" + Replic("_",217)+"|"
	nLin++
	
	@nLin,00 Psay Cabec6
	
	   fWrite(nHdl,cLin6,Len(cLin6))
	
	nLin++
	
	@nLin,00 Psay Cabec7
	
	   fWrite(nHdl,cLin7,Len(cLin7))
	 
	nLin++
	
	@nLin,00 Psay Cabec8
	nLin++

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณImpCabec2 บ Autor ณ Everson            บ Data ณ  17/02/2017 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณCabe็alho do relat๓rio (dados totalizados).                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณChamado 032203.                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ImpCabec2()

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declaracao de Variaveis                                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู	
	Local cQuery	 := ""
	Local nCobertura := ""
	Local cAtivos	 := ""
	Local aAtivos	 := {}
	Local cAtivo1	 := ""
	Local cAtivo2	 := ""
	
	oHashSuper:Get("TOTAL",@nCobertura)
	
	oHashAtivo:Get("TOTAL",cAtivos)
	
	aAtivos := StrToKarr(cAtivos,"/")
	
	If Len(aAtivos) <> 2
		cAtivo1 := "0"
		cAtivo2 := "0"
		
	Else
		cAtivo1 := aAtivos[1]
		cAtivo2 := aAtivos[2]
		
	EndIf
	
	@nLin,001 Psay Replic("_",217)
	nLin := nLin + 1

	Cabec3 := "| SUPERVISOR: "+mv_par03+ " Ate "+mv_par04+ Space(100)+"DE : "+substr(dtos(mv_par01),7,2)+"/"+substr(dtos(mv_par01),5,2)+"/"+substr(dtos(mv_par01),1,4)+ Space(54)+"  DIAS UTEIS: " +right(str(_nDiasUtil),2)+"  |"
	cLin := "SUPERVISOR:;"+mv_par03+"; Ate "+mv_par04+";;;;;DE:"+substr(dtos(mv_par01),7,2)+"/"+substr(dtos(mv_par01),5,2)+"/"+substr(dtos(mv_par01),1,4)+";;;;;DIAS UTEIS:;"+right(str(_nDiasUtil),2)+";;;"+_eof
	fWrite(nHdl,cLin,Len(cLin)) 

	Cabec4 := "|"+Space(130)+"ATE: "+substr(dtos(mv_par02),7,2)+"/"+substr(dtos(mv_par02),5,2)+"/"+substr(dtos(mv_par02),1,4) +Space(2)+Space(51)+ "DIAS CORRIDOS: " +right(str(_nDiasCorr),2)+"  |"
	cLin := ";;;;;;;ATE:"+substr(dtos(mv_par02),7,2)+"/"+substr(dtos(mv_par02),5,2)+"/"+substr(dtos(mv_par02),1,4)+";;;;;DIAS CORRIDOS:;"+right(str(_nDiasCorr),2)+";;;"+_eof
	fWrite(nHdl,cLin,Len(cLin)) 

	Cabec5 := "| CLIENTES CARTEIRA : "+right(str(_nQtcartT),5)+"        COBERTURA MES: " + cValToChar(nCobertura) + "     ATIVO1: " + cAtivo1 +"     ATIVO2: " + cAtivo2
	cLin := "CLIENTES;CARTEIRA:;"+right(str(_nQtcartT),5)+";;;;COBERTURA;MES:" + cValToChar(nCobertura) + ";;ATIVO1:;" + cAtivo1 + ";;ATIVO2:;" + cAtivo2 +";;;"+_eof
	
	fWrite(nHdl,cLin,Len(cLin))
	
	fWrite(nHdl,_Vazia,Len(_vazia))
	
	cabec5B:="  "+ Space(150)+"|"
	@nLin,000 Psay Cabec3
	nLin++
	
	@nLin,00 Psay Cabec4
	nLin++                    
	
	@nLin,000 Psay Cabec5
	
	@nLin,067 Psay Cabec5b
	nLin++
	
	@nLin,000 Psay "|" + Replic("_",217)+"|"
	nLin++
	
	@nLin,00 Psay Cabec6
	fWrite(nHdl,cLin6,Len(cLin6)) 
	nLin++
	
	@nLin,00 Psay Cabec7
	fWrite(nHdl,cLin7,Len(cLin7)) 
	nLin++
	
	@nLin,00 Psay Cabec8
	nLin++

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณtotQbrNv  บ Autor ณ Everson            บ Data ณ  17/02/2017 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณQuebra por nํvel.                                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณChamado 032203.                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function totQbrNv(cNvQbr,nOpc)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declaracao de Variaveis                                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local nValorCob	:= 0

	@nLin,000 Psay "|"
	@nLin,032 Psay "|"     
	@nLin,056 Psay "|"      
	@nLin,119 Psay "|"        
	@nLin,139 Psay "|"       
	@nLin,188 Psay "|"       
	@nLin,218 Psay "|"
	
	cLin := ""
	@nLin,000 Psay "|"
	@nLin,002 Psay "SubTotal - Grupo"
	cLin += "SubTotal; - Grupo"+";"
	
	@nLin,032 Psay "|" 
	
	@nLin,034 Psay _nQbrMtVnd / _nQbrTotVnd 		PICTURE "@E 99.99"  // Total "Preco FOB(R$/KG)" Meta   36
	cLin += Transform(_nQbrMtVnd / _nQbrTotVnd,"@E 99.99")+";"
	
	@nLin,041 Psay _nQbrReVnd / _nQbrTotVnd 		PICTURE "@E 99.99"  // Total "Preco FOB(R$/KG)" Realizado   43
	cLin += Transform(_nQbrReVnd / _nQbrTotVnd,"@E 99.99")+";"
	
	If _lDiret
	   @nLin,048 Psay _nQbrRfVnd / _nQbrTotVnd 		PICTURE "@E 99.99"  // Total "Preco FOB(R$/KG)" Referencia  50
	   cLin += Transform(_nQbrRfVnd / _nQbrTotVnd,"@E 99.99")+";"
	EndIf 
	  
	@nLin,056 Psay "|"
	@nLin,057 Psay _nQbrMtVnd 						PICTURE "@E 999,999,999" // Total "Faturamento(R$)" Meta   59
	cLin += Transform(_nQbrMtVnd,"@E 999,999,999")+";"
	
	@nLin,069 Psay _nQbrReVnd 						PICTURE "@E 999,999,999"  // Total "Faturamento(R$)" Realizado 71
	cLin += Transform(_nQbrReVnd,"@E 999,999,999")+";"
	
	If _lDiret 
	   @nLin,082 Psay _nQbrRfVnd 						PICTURE "@E 999,999,999"  //Total "Faturamento(R$)" Referencia 84
	   cLin += Transform(_nQbrRfVnd,"@E 999,999,999")+";"
	   
	EndIf  
	 
	@nLin,096 Psay _nQbrReVnd  -  	_nQbrMtVnd		PICTURE "@E 9,999,999" //Total "Diferenca Fat(R$) Real - Meta 98
	cLin += Transform(_nQbrReVnd  -  	_nQbrMtVnd,"@E 9,999,999")+";"  
	
	If _lDiret
	   @nLin,107 Psay _nQbrReVnd  -  	_nQbrRfVnd		PICTURE "@E 9,999,999"//Total "Diferenca Fat(R$) Real - Referencia 109
	   cLin += Transform(_nQbrReVnd  -  	_nQbrRfVnd,"@E 9,999,999")+";"  
	   
	EndIf 
	  
	@nLin,119 Psay "|"     //121
	@nLin,124 Psay _nQbrReVnd /   	_nQbrMtVnd 	PICTURE "@E 9.999"  //Total "Indice" IPM 126
	cLin += Transform(_nQbrReVnd /   	_nQbrMtVnd,"@E 9.999")+";"
	
	If _lDiret
	   @nLin,131 Psay (_nQbrReVnd / _nQbrTotVnd) - (_nQbrRfVnd / _nQbrTotVnd) 	PICTURE "@E 99.999"//Total "Indice" IPR 133
	   cLin += transform((_nQbrReVnd / _nQbrTotVnd) - (_nQbrRfVnd / _nQbrTotVnd),"@E 99.999")+";"  
	
	EndIf
	   
	@nLin,139 Psay "|"   //141
	
	@nLin,141 Psay _nQbrMtVol PICTURE "@E 99999,999"  //Total "Volume(Kg)" Meta 143
	cLin += Transform(_nQbrMtVol,"@E 99999,999")+";"
	
	@nLin,153 Psay _nQbrTotVnd PICTURE "@E 99999,999"   // Total Volume(kgs) Realizado  155
	cLin += Transform(_nQbrTotVnd,"@E 99999,999")+";"
	
	@nLin,162 Psay (_nQbrTotVnd / _nDiasCorr) * _nDiasUtil PICTURE "@E 99,999,999,999"  //Total "Volume" Projetado 167
	cLin += Transform((_nQbrTotVnd / _nDiasCorr) * _nDiasUtil,"@E 99999,999")+";"
	
	@nLin,177 Psay (_nQbrMtVol - _nQbrTotVnd) / (_nDiasUtil - _nDiasCorr) PICTURE "@E 99999,999"  // Total "Volume" Necessaria 182
	cLin += Transform((_nQbrMtVol - _nQbrTotVnd) / (_nDiasUtil - _nDiasCorr),"@E 99999,999")+";"
	
	@nLin,193 Psay (_nQbrTotVnd / _nQbrMtVol)*100 PICTURE "@E 99999.9" //Total "Atingimento(%)" Realizado 197
	cLin += Transform((_nQbrTotVnd / _nQbrMtVol)*100,"@E 99999.9")+";"  
	
	@nLin,204 Psay (((_nQbrTotVnd / _nDiasCorr) * _nDiasUtil) / _nQbrMtVol)*100 PICTURE "@E 99999.9"  //Total "Atingimento(%)" Projetado 210
	cLin += Transform((((_nQbrTotVnd / _nDiasCorr) * _nDiasUtil) / _nQbrMtVol)*100,"@E 99999.9")+";"
	
	_cGrpos := Substr(_cGrpos,1,Len(_cGrpos) - 1)
	
	_nCobQbr := 0

	//Cobertura.
	If nOpc == 1 //Por supervisor e grupo de produtos.
		oHashCobSNB:Get(Alltrim(cValToChar(_Supervis))+Alltrim(cValToChar(cNvQbr)),@_nCobQbr)
		_nCobQbr := Val(cValToChar(_nCobQbr))
	
	Else //Consolidado.
		oHashCobTCons:Get(cNvQbr,@_nCobQbr)
		_nCobQbr := Val(cValToChar(_nCobQbr))
		
	EndIf
	
	@nLin,213 Psay _nCobQbr PICTURE "@E 9999"
	cLin += Transform(_nCobQbr,"@E 9999" )+_eof

	fWrite(nHdl,cLin,Len(cLin)) 
	
	nLin++
	@nLin,000 Psay "|"
	@nLin,032 Psay "|"
	@nLin,056 Psay "|"
	@nLin,119 Psay "|" 
	@nLin,139 Psay "|"
	@nLin,188 Psay "|"
	@nLin,218 Psay "|"
	
	_nCobT  += _nCobQbr
	
	_nCobQbr:= 0
	_cGrpos := ""
	
	nLin++

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณtotQbrtot บ Autor ณ Everson            บ Data ณ  17/02/2017 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณQuebra por totalizador.                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณChamado 032203.                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function totQbrtot()

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declaracao de Variaveis                                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	
	_nMeta :=  _nAcMtPrcT / _nAcVdT
	_nRealiz := _nAcRePrcT / _nAcVdT
	_nReferen := _nAcRfPrcT / _nAcVdT
	
	_nAcMeta := _nAcMtPrcT
	_nAcReal := _nAcRePrcT
	_nAcRefer := _nAcRfPrcT
	_nDifMet := _nAcRePrcT  -  _nAcMtPrcT
	_nDifRef := _nAcRePrcT  -  _nAcRfPrcT
	
	_nIPM := _nAcRePrcT /   _nAcMtPrcT
	_nIPR := _nAcRePrcT /   _nAcRfPrcT
	
	_nVolMet := _nAcMtVolT
	_nVolRea := _nAcVdT
	  
	_nVolProj := (_nAcVdT / _nDiasCorr) * _nDiasUtil // "Volume(kg)" Projetado
	
	_nVolNec := (_nAcMtVolT - _nAcVdT) / (_nDiasUtil - _nDiasCorr) //"Volume(kg)" Necessaria
	
	_nAtgRea := (_nAcVdT / _nAcMtVolT) * 100 //"Atingimento(%)" REalizado  
	
	_nAtgPrj := (((_nAcVdT / _nDiasCorr) * _nDiasUtil) / _nAcMtVolT) * 100 //"Atingimento(%)" Projetado
	
	Aadd(_aTotaliz,{_cAgrupadores,_nMeta,_nRealiz,_nReferen,_nAcMeta,_nAcReal,_nAcRefer,_nDifMet,_nDifRef,_nIPM,_nIPR,_nVolMet,_nVolRea,_nVolProj,_nVolNec,;
	    _nAtgRea,_nAtgPrj,_cAgrupGrupos})
	                
	_nAcVdTT    +=  _nAcVdt
	_nAcMPrcTT  +=  _nAcMtPrcT
	_nAcRPrcTT  +=  _nAcRePrcT
	_nAcMVolTT  +=  _nAcMtVolT
	_nDiasUtTT  := _nDiasUtil
	_nAcFPrcTT  +=  _nAcRfPrcT
	
	_nCobT		  :=    0  
	                       
	_nAcVdT       :=	0
	_nAcMtPrcT	  :=	0
	_nAcRePrcT	  :=	0
	_nAcMtVolT	  :=	0 
	_nAcRfPrcT	  :=	0
	_cAgrupadores := ""
	
	_cAgrupGrupos := ""
	
Return Nil 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTotGer    บ Autor ณ Everson            บ Data ณ  17/02/2017 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณTotalizador geral.                                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณChamado 032203.                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function TotGer(cSuper)                            

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declaracao de Variaveis                                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	
	cLin := ""
	
	@nLin,000 Psay "|"
	
	@nLin,002 Psay "Totaliz.Geral"
	cLin += ";Totaliz.Geral;"  
	               
	@nLin,032 Psay "|"
	
	@nLin,034 Psay _nAcMPrcTT / _nAcVdTT		PICTURE "@E 99.99"  //"Preco Fob(R$/KG)" Meta
	cLin += Transform(_nAcMPrcTT / _nAcVdTT,"@E 99.99")+";" 
	
	@nLin,041 Psay _nAcRPrcTT  / _nAcVdTT 		PICTURE "@E 99.99"  //"Preco Fob(R$/KG)" Realizado
	cLin += Transform(_nAcRPrcTT  / _nAcVdTT,"@E 99.99")+";" 
	
	If _lDiret
	   @nLin,048 Psay  _nAcFPrcTT  / _nAcVdTT 		PICTURE "@E 99.99" //""Preco Fob(R$/KG)" Referencial
	   cLin += Transform(_nAcFPrcTT  / _nAcVdTT,"@E 99.99")+";" 
	   
	EndIf 
	  
	@nLin,056 Psay "|"
	
	@nLin,057 Psay _nAcMPrcTT 						PICTURE "@E 999,999,999" //"Faturamento(R$)" Meta
	cLin += Transform(_nAcMPrcTT,"@E 999,999,999")+";" 
	
	@nLin,069 Psay _nAcRPrcTT 						PICTURE "@E 999,999,999"  //"Faturamento(R$)" Realizado
	cLin += Transform(_nAcRPrcTT,"@E 999,999,999")+";" 
	 
	If _lDiret
	   @nLin,082 Psay  _nAcFPrcTT 						PICTURE "@E 999,999,999" //"Faturamento(R$)" Referencial
	   cLin += Transform(_nAcFPrcTT,"@E 999,999,999")+";"
	   
	EndIf   
	
	@nLin,096 Psay _nAcRPrcTT  -  _nAcMPrcTT		PICTURE "@E 9,999,999" //"Diferenca Fat(R$)" Real - Meta
	cLin += Transform(_nAcRPrcTT  -  _nAcMPrcTT,"@E 9,999,999")+";"
	
	If _lDiret
	   @nLin,107 Psay _nAcRPrcTT - _nAcFPrcTT  		PICTURE "@E 9,999,999" //"Diferenca Fat(R$)" Real - Referencial
	   cLin += Transform(_nAcRPrcTT - _nAcFPrcTT,"@E 9,999,999")+";" 
	   
	EndIf   
	
	@nLin,119 Psay "|"
	
	@nLin,124 Psay _nAcRPrcTT /   _nAcMPrcTT 	PICTURE "@E 9.999"  //"Indice" IPM
	cLin += Transform(_nAcRPrcTT /   _nAcMPrcTT,"@E 9.999")+";" 
	
	If _lDiret
	   @nLin,131 Psay (_nAcRPrcTT  / _nAcVdTT) - (_nAcFPrcTT  / _nAcVdTT) 	PICTURE "@E 99.999"//"Indice" IPR
	   cLin += Transform((_nAcRPrcTT  / _nAcVdTT) - (_nAcFPrcTT  / _nAcVdTT), "@E 99.999")+";" 
	
	EndIf
	   
	@nLin,139 Psay "|"
	
	@nLin,141 Psay _nAcMVolTT PICTURE "@E 99999,999"  //"Volume(KG)" Meta
	cLin += Transform(_nAcMVolTT, "@E 99999,999")+";" 
	 
	@nLin,153 Psay _nAcVdTT PICTURE "@E 99999,999"   //"Volume(kg)" Realizado
	cLin += Transform(_nAcVdTT, "@E 99999,999")+";" 
	
	@nLin,162 Psay (_nAcVdTT / _nDiasCorr) * _nDiasUtil PICTURE "@E 99,999,999,999"  //"Volume(kg)" Projetado
	cLin += Transform((_nAcVdTT / _nDiasCorr) * _nDiasUtil, "@E 99999,999")+";" 
	
	@nLin,177 Psay (_nAcMVolTT - _nAcVdTT) / (_nDiasUtil - _nDiasCorr) PICTURE "@E 99999,999"   //"Volume(kg)" Necessaria 
	cLin += Transform((_nAcMVolTT - _nAcVdTT) / (_nDiasUtil - _nDiasCorr), "@E 99999,999")+";" 
	
	@nLin,188 Psay "|"
	
	@nLin,193 Psay (_nAcVdTT / _nAcMVolTT)*100 PICTURE "@E 99999.9" //"Atingimento(%)" Realizado
	cLin += Transform((_nAcVdTT / _nAcMVolTT)*100, "@E 99999.9")+";" 
	
	@nLin,204 Psay (((_nAcVdTT / _nDiasCorr) * _nDiasUtil)/ _nAcMVolTT)*100 PICTURE "@E 99999.9"  //"Atingimento(%)" Projetad
	cLin += Transform((((_nAcVdTT / _nDiasCorr) * _nDiasUtil)/ _nAcMVolTT)*100, "@E 99999.9")+";"
	
	oHashSuper:Get(cSuper,@_nAcCobTT)
	
	@nLin,212 Psay _nAcCobTT PICTURE "@E 99999"
	cLin += Transform(_nAcCobTT,"@E 9999" )+_eof
	
	fWrite(nHdl,cLin,Len(cLin))
	@nLin,218 Psay "|" 
	                         
	nLin++
	
	@nLin,000 Psay "|"
	@nLin,032 Psay "|"
	@nLin,056 Psay "|"
	@nLin,119 Psay "|"
	@nLin,139 Psay "|"
	@nLin,188 Psay "|"
	@nLin,218 Psay "|"
	
	nLin++

	_nAcVdTT    :=	0
	_nAcMPrcTT  :=	0
	_nAcRPrcTT  :=	0
	_nAcMVolTT  :=	0
	_nAcFPrcTT  :=	0
	_nAcCobTT	:=  0
	
	_nAcCobTT	:=  0
	                          
	_nAcVdT     :=	0
	_nAcMtPrcT	:=	0
	_nAcRePrcT	:=	0
	_nAcMtVolT	:=	0
	_nAcRfPrcT	:=	0
  
Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณdadosCsld บ Autor ณ Everson            บ Data ณ  17/02/2017 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณDados consolidados.                                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณChamado 032203.                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function dadosCsld()

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declaracao de Variaveis                                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู	
	Local cQuery	:= ""
	Local nTotReg	:= 0
	Local nCobertura:= 0
	
	_cQuebra		:= ""
	_cCod			:= ""
	_aCodGrup		:= {}
	_aQbr			:= {}
	_bE				:= 0
	
	_cAgrupGrupos	:= ""
	
	cQuery := scriptTotal()
	
	If Select("TOTALGRP") > 0
		TOTALGRP->(DbCloseArea())
		
	EndIf
	
	MsAguarde({||execConsult(cQuery,"TOTALGRP")},"Aguarde","Consulta dados gerais.")
	
	DbSelectArea("TOTALGRP")
	MsAguarde({||nTotReg := contar("TOTALGRP","!Eof()")},"Aguarde","Gerando meta geral...")
	ProcRegua(nTotReg)
	TOTALGRP->(DbGoTop())

	_Supervis := ""
	
	Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	nLin := 5
	ImpCabec2()
	
	_acVendas	:=	0
	_acMT_PRC	:=	0
	_acRE_prc	:=	0
	_acMT_VOL	:=	0
	_acMT_FaR	:=	0
	_acRF_prc	:=	0
	_acRF_FaR	:=	0
	
	//
	_nAcVdTT    := 0
	_nAcMPrcTT  := 0
	_nAcRPrcTT  := 0
	_nAcMVolTT  := 0
	_nAcFPrcTT  := 0
	_nAcCobTT	:= 0
	_nAcCobTT	:= 0
	
	//Totalizadores de quebra de nํvel.
	_nQbrMtVnd	:=	0
	_nQbrReVnd	:=	0
	_nQbrRfVnd	:=	0
	_nQbrTotVnd	:=	0
	_nQbrMtVol	:=	0
	
	
	//Totalizadores de total X5_DESCRI.
	_acVendasT	:=	0
	_acMT_PRCT	:=	0
	_acRE_prcT	:=	0
	_acMT_VOLT	:=	0
	_acMT_FaRT	:=	0 
	_acRF_prcT	:=	0
	_acRF_FaRT	:=	0 
	
	While ! TOTALGRP->(Eof())
	
		IncProc(" Grupo: " + TOTALGRP->BM_GRUPO)
	
		_cQuebraAnt :=	TOTALGRP->BM_QBRNVL
		_cQuebraGrp	:=	TOTALGRP->BM_GRUPO
		_cQuebraTot	:=	TOTALGRP->X5_DESCRI
		_anNOMGRUP	:=	TOTALGRP->BM_DESC
		
		_nQbrMtVnd	+=	TOTALGRP->FAT_META 
		_nQbrReVnd	+=	TOTALGRP->FAT_REAL
		_nQbrRfVnd	+=	TOTALGRP->FAT_REF
		_nQbrMtVol	+=	TOTALGRP->META_PESO
		_nQbrTotVnd	+=	TOTALGRP->PESO_REAL	
		
	    _nAcMtPrcT  += 	TOTALGRP->FAT_META
		_nAcRePrcT  += 	TOTALGRP->FAT_REAL	
		_nAcRfPrcT  += 	TOTALGRP->FAT_REF
		_nAcMtVolT	+=	TOTALGRP->META_PESO	
		_nAcVdT     +=	TOTALGRP->PESO_REAL	
		
		_acVendasT	+=	TOTALGRP->PESO_REAL	
		_acMT_FaRT	+= 	TOTALGRP->FAT_META
		_acRE_prcT	+=	TOTALGRP->FAT_REAL	
		_acMT_VOLT	+=	TOTALGRP->META_PESO		
		_acRF_FaRT	+= 	TOTALGRP->FAT_REF
		_acRF_prcT	+=	TOTALGRP->FAT_REF 		   		
		
		_acMT_PRCT	:=	_acMT_FaRT / _acVendasT
		
		_acVendas	+=	TOTALGRP->PESO_REAL	
		_acMT_FaR	+= 	TOTALGRP->FAT_META
		_acRE_prc	+=	TOTALGRP->FAT_REAL
		_acMT_VOL	+=	TOTALGRP->META_PESO	
		_acMT_PRC	:=  iif(_acVendas=0,_acMT_FaR/_nContaSup,_acMT_FaR / _acVendas) 
		_acRF_FaR	+= 	TOTALGRP->FAT_REF
		_acRF_prc	+=	TOTALGRP->FAT_REF
		
		If nLin > 55
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 5
			ImpCabec2()
			
		EndIf
		
	    cLin := ""
		@nLin,000 Psay "|" + _cQuebraAnt+_cQuebraTot
		
		@nLin,005 Psay _cQuebraGrp
		@nLin,010 Psay SUBSTR(_anNOMGRUP,1,20)
		cLin += _cQuebraAnt+_cQuebraTot+";"+_cQuebraGrp+" "+SUBSTR(_anNOMGRUP,1,20)+";"
		
		@nLin,033 Psay "|"
		
		@nLin,035 Psay TOTALGRP->PRC_META PICTURE "@E 99.99"  //"Preco FOB(R$/kg)" Meta
		cLin += Transform(TOTALGRP->PRC_META,"@E 99.99")+";"
		
		@nLin,042 Psay TOTALGRP->PRC_REAL PICTURE "@E 99.99"  //"Preco FOB(R$/kg)" Realizado
		cLin += Transform(TOTALGRP->PRC_REAL,"@E 99.99")+";"
		
		If _lDiret
		   @nLin,049 Psay Iif(TOTALGRP->PESO_REAL > 0,TOTALGRP->FAT_REF/TOTALGRP->PESO_REAL,0) PICTURE "@E 99.99"
		   cLin += Transform(Iif(TOTALGRP->PESO_REAL > 0,TOTALGRP->FAT_REF/TOTALGRP->PESO_REAL,0),"@E 99.99")+";"
		   
		EndIf   
		
		@nLin,057 Psay "|"

		@nLin,057 Psay TOTALGRP->FAT_META PICTURE "@E 999,999,999" //"Faturamento(R$)" Meta
		cLin += Transform(TOTALGRP->FAT_META,"@E 999,999,999")+";"
		
		@nLin,069 Psay TOTALGRP->FAT_REAL PICTURE "@E 999,999,999"  //"Faturamento(R$)" Realizado
		cLin += Transform(TOTALGRP->FAT_REAL,"@E 999,999,999")+";"
		
		If _lDiret
		   @nLin,082 Psay TOTALGRP->FAT_REF PICTURE "@E 999,999,999"// "Faturamento(R$)" Referencial_acRF_PRC
		   cLin += Transform(TOTALGRP->FAT_REF,"@E 999,999,999")+";"
		   
		EndIf 
		  
		@nLin,095 Psay TOTALGRP->FAT_DR_M PICTURE "@E 99,999,999" //"Diferenca Fat(R$)" Real - Meta
		cLin += Transform(TOTALGRP->FAT_DR_M,"@E 99,999,999" )+";"
		
		If _lDiret
		   @nLin,106 Psay TOTALGRP->FAT_DR_RF PICTURE "@E 99,999,999"//"Diferenca Fat(R$)" Real - Referencial _acRF_PRC
		   cLin += Transform(TOTALGRP->FAT_DR_RF,"@E 99,999,999" )+";"
		   
		EndIf  
		 
		@nLin,119 Psay "|"
		
		@nLin,124 Psay TOTALGRP->FAT_INDIPM PICTURE "@E 9.999"  //"indice" IPM
		cLin += Transform(TOTALGRP->FAT_INDIPM,"@E 9.999" )+";"
		
		If _lDiret
		   @nLin,131 Psay TOTALGRP->FAT_INDIPR PICTURE "@E 99.999"  // "indice" IPR
		   cLin += Transform(TOTALGRP->FAT_INDIPR,"@E 99.999" )+";"

		EndIf 
		  
		@nLin,139 Psay "|"

		@nLin,139 Psay TOTALGRP->META_PESO PICTURE "@E 99,999,999"  //"Volume(kg)" Meta
		cLin += Transform(TOTALGRP->META_PESO,"@E 99,999,999" )+";"

        @nLin,151 Psay TOTALGRP->PESO_REAL PICTURE "@E 99,999,999"   //"Volume(kg)" Realizado
        cLin += Transform(TOTALGRP->PESO_REAL,"@E 99,999,999" )+";"
        
        @nLin,161 Psay TOTALGRP->PESO_PROJETADO PICTURE "@E 99,999,999,999"  //"Volume(kg" Projetado
        cLin += Transform(TOTALGRP->PESO_PROJETADO ,"@E 99,999,999,999")+";"
        
		@nLin,176 Psay TOTALGRP->NECESSARIA PICTURE "@E 99999,999" //"Volume(KG)" Necessaria
		cLin += Transform(TOTALGRP->NECESSARIA,"@E 99999,999")+";"
		
	   	@nLin,187 Psay "|"
	   	
	   	@nLin,192 Psay TOTALGRP->ATING_R PICTURE "@E 99999.9"// "Atingimento(%)" Realizado
	   	cLin += Transform(TOTALGRP->ATING_R,"@E 99999.9")+";"
	   		
		@nLin,203 Psay TOTALGRP->ATING_P PICTURE "@E 99999.9"  // "Atingimento(%)" Projetado		
		cLin += Transform(TOTALGRP->ATING_P,"@E 99999.9")+";"
		
		nCobertura := 0
		oHashCobCons:Get(Alltrim(cValTochar(_cQuebraAnt))+Alltrim(cValTochar(_cQuebraTot))+Alltrim(cValTochar(_cQuebraGrp)),@nCobertura)
		
        @nLin,212 Psay nCobertura PICTURE "@E 9999"
        cLin += Transform(nCobertura,"@E 9999" ) + _eof
		
		fWrite(nHdl,cLin,Len(cLin))
		
		@nLin,217 Psay "|"
		
		nLin++
		
		if !(ALLTRIM(TOTALGRP->BM_QBRNVL) $ _cAgrupadores)
	   		If empty(_cAgrupadores)
	   			_cAgrupadores := _cAgrupadores + TOTALGRP->BM_QBRNVL
 	
	   		Else
	   			_cAgrupadores := _cAgrupadores +"+"+ TOTALGRP->BM_QBRNVL 
	   			
	   		EndIF	
	   			  
	   	EndIF
	   	
	   	If !(Alltrim(CONSOLIDADO->BM_GRUPO) $ _cAgrupGrupos)
	   		If Empty(_cAgrupGrupos)
	   			_cAgrupGrupos += "'" + TOTALGRP->BM_GRUPO + "',"
	   				
	   		Else
	   			_cAgrupGrupos := _cAgrupGrupos + "'" + TOTALGRP->BM_GRUPO + "',"
	   			
	   		EndIf
	   				  
	   	EndIf
		
		TOTALGRP->(DbSkip())
		
		If _cQuebraAnt	!=	TOTALGRP->BM_QBRNVL
			totQbrNv(Alltrim(cValToChar(_cQuebraAnt)) + Alltrim(cValToChar(_cQuebraTot)),2)
			_nQbrMtVnd	:=	0
			_nQbrReVnd	:=	0
			_nQbrRfVnd	:=	0
			_nQbrTotVnd	:=	0
			_nQbrMtVol	:=	0

		EndIf
		
		If _cQuebraTot	!=	TOTALGRP->X5_DESCRI
			totQbrtot()
			_cQuebraTot	:=	""
			_acVendasT	:=	0
			_acMT_FaRT	:=	0
			_acRE_prcT	:=	0
			_acMT_VOLT	:=	0
			_acRF_FaRT	:=	0
			_acRF_prcT	:=	0
			_nAcVdT     :=	0	   		
			_nAcMtVolT	:=	0
			_acMT_PRCT	:=	0
			
		EndIf
		
	EndDo

	TotGer("TOTAL") 
	totNvGer()
	
	nLin := nLin + 1
	nLin := 56

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณtotNvGer  บ Autor ณ Everson            บ Data ณ  17/02/2017 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณTotalizador por agrupamento de nํveis por supervisor.       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณChamado 032203.                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function totNvGer()

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declaracao de Variaveis                                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local nTotCobert	:= 0

	For _yy := 1 to len(_aTotaliz)    
	    If nLin > 55   //60 
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 8
			
		EndIf
		
	    cLin := ""
	    @nLin,000 Psay "|"
	    @nLin,002 Psay "Totalizador ("+ALLTRIM(_aTotaliz[_yy,1])+")"
	    cLin += "Totalizador;("+ALLTRIM(_aTotaliz[_yy,1])+");"
	    
	    @nLin,032 Psay "|"
	    @nLin,034 Psay _aTotaliz[_yy,2]		PICTURE "@E 99.99"  //"Preco FOB(R$/KG)" Meta
	    cLin += Transform(_aTotaliz[_yy,2],"@E 99.99")+";" 
	    
	    @nLin,041 Psay _aTotaliz[_yy,3]		PICTURE "@E 99.99"  //"Preco FOB(R$/KG)" Realizado
	    cLin += Transform(_aTotaliz[_yy,3],"@E 99.99")+";"
	    
	    if _lDiret
	       @nLin,048 Psay _aTotaliz[_yy,4]  	PICTURE "@E 99.99"  //"Preco FOB(R$/KG)" Referencial
	       cLin += Transform(_aTotaliz[_yy,4],"@E 99.99")+";"  
	       
	    EndIf 
	      
	    @nLin,056 Psay "|"
	    @nLin,057 Psay _aTotaliz[_yy,5] 	PICTURE "@E 999,999,999" // "Faturamento(R$)" Meta
	    cLin += Transform(_aTotaliz[_yy,5],"@E 999,999,999")+";" 
	     
	    @nLin,069 Psay _aTotaliz[_yy,6] 	PICTURE "@E 999,999,999"  //"Faturamento(R$)" Realizado
	    cLin += Transform(_aTotaliz[_yy,6],"@E 999,999,999")+";"
	    
	    if _lDiret    
	       @nLin,082 Psay _aTotaliz[_yy,7] 	PICTURE "@E 999,999,999"  // "Faturamento(R$)" Referencial
	       cLin += Transform(_aTotaliz[_yy,7],"@E 999,999,999")+";"
	       
	    EndIf
	        
	    @nLin,096 Psay _aTotaliz[_yy,8]		PICTURE "@E 9,999,999" // "Diferenca Fat(R$)" Real - Meta
	    cLin += Transform(_aTotaliz[_yy,8],"@E 9,999,999")+";"
	    
	    if _lDiret     
	       @nLin,107 Psay _aTotaliz[_yy,9]  	PICTURE "@E 9,999,999" // Diferenca Fat(R$)" Real - Referencial
	       cLin += Transform(_aTotaliz[_yy,9],"@E 9,999,999")+";"
	       
	    EndIf  
	     
	    @nLin,119 Psay "|"
	    @nLin,124 Psay _aTotaliz[_yy,10] 	PICTURE "@E 9.999"  // "indice" IPM
	    cLin += Transform(_aTotaliz[_yy,10],"@E 9.999")+";"  
	    
	    if _lDiret
	       &&Mauricio - 09/04/14 - altera็ใo na formula de calculo conforme solicita็ใo dos Srs. Marcus e Vagner.
	       @nLin,131 Psay _aTotaliz[_yy,3] - _aTotaliz[_yy,4] PICTURE "@E 99.999"  // "indice" IPR  // Alex Borges 24/11/11
	       cLin += Transform(_aTotaliz[_yy,3] - _aTotaliz[_yy,4],"@E 99.999")+";"
	
	    EndIf
	       
	    @nLin,139 Psay "|"
	
	    @nLin,141 Psay _aTotaliz[_yy,12]    PICTURE "@E 99999,999"  // "Volume(kg)" Meta
	    cLin += Transform(_aTotaliz[_yy,12],"@E 99999,999" )+";"
	    
	    @nLin,153 Psay _aTotaliz[_yy,13]    PICTURE "@E 99999,999"   // "Volume(kg)" Realizado
	    cLin += Transform(_aTotaliz[_yy,13],"@E 99999,999" )+";" 
	      
	    @nLin,162 Psay _aTotaliz[_yy,14]    PICTURE "@E 99,999,999,999"  // "Volume(kg)" Projetado
	    cLin += Transform(_aTotaliz[_yy,14],"@E 99999,999" )+";" 
	       
	    @nLin,177 Psay _aTotaliz[_yy,15]    PICTURE "@E 99999,999" //"Volume(kg)" Necessaria
	    cLin += Transform(_aTotaliz[_yy,15],"@E 99999,999" )+";"
	    
	    @nLin,188 Psay "|" 
	    
	    @nLin,193 Psay _aTotaliz[_yy,16]    PICTURE "@E 99999.9" //"Atingimento(%)" REalizado
	    cLin += Transform(_aTotaliz[_yy,16],"@E 99999.9")+";"
	    
	    @nLin,204 Psay _aTotaliz[_yy,17]    PICTURE "@E 99999.9"  //"Atingimento(%)" Projetado
	    cLin += Transform(_aTotaliz[_yy,17],"@E 99999.9")+";"
		
		nTotCobert := cobGrp("",Substr(_aTotaliz[_yy,18],1,Len(_aTotaliz[_yy,18]) - 1)) //<<<<<<<<<<<<<
		
	    @nLin,213 Psay nTotCobert PICTURE "@E 9999"  //"Atingimento" Projetado
	    cLin += Transform(nTotCobert,"@E 9999" ) + _eof
	    
	    fWrite(nHdl,cLin,Len(cLin))
	    
	    @nLin,218 Psay "|"
	    nLin++
	
	Next
	
	_aTotaliz := {}
    
Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณtotNvSup  บ Autor ณ Everson            บ Data ณ  17/02/2017 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณTotalizador por agrupamento de nํveis geral.                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณChamado 032203.                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function totNvSup()

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declaracao de Variaveis                                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local nTotCobert	:= 0

	For _yy := 1 to len(_aTotaliz)
	    
	    If nLin > 55   //60 
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 8
			
		EndIf
		
	    cLin := ""
	    @nLin,000 Psay "|"
	    @nLin,002 Psay "Totalizador ("+ALLTRIM(_aTotaliz[_yy,1])+")"
	    cLin += "Totalizador;("+ALLTRIM(_aTotaliz[_yy,1])+");"
	    
	    @nLin,032 Psay "|"
	    @nLin,034 Psay _aTotaliz[_yy,2]		PICTURE "@E 99.99"  //"Preco FOB(R$/KG)" Meta
	    cLin += Transform(_aTotaliz[_yy,2],"@E 99.99")+";" 
	    
	    @nLin,041 Psay _aTotaliz[_yy,3]		PICTURE "@E 99.99"  //"Preco FOB(R$/KG)" Realizado
	    cLin += Transform(_aTotaliz[_yy,3],"@E 99.99")+";"
	    
	    if _lDiret
	       @nLin,048 Psay _aTotaliz[_yy,4]  	PICTURE "@E 99.99"  //"Preco FOB(R$/KG)" Referencial
	       cLin += Transform(_aTotaliz[_yy,4],"@E 99.99")+";"  
	       
	    EndIf   
	    
	    @nLin,056 Psay "|"
	    
	    @nLin,057 Psay _aTotaliz[_yy,5] 	PICTURE "@E 999,999,999" // "Faturamento(R$)" Meta 
	    cLin += Transform(_aTotaliz[_yy,5],"@E 999,999,999")+";"  
	    
	    @nLin,069 Psay _aTotaliz[_yy,6] 	PICTURE "@E 999,999,999"  //"Faturamento(R$)" Realizado
	    cLin += Transform(_aTotaliz[_yy,6],"@E 999,999,999")+";"
	    
	    if _lDiret    
	       @nLin,082 Psay _aTotaliz[_yy,7] 	PICTURE "@E 999,999,999"  // "Faturamento(R$)" Referencial
	       cLin += Transform(_aTotaliz[_yy,7],"@E 999,999,999")+";"
	       
	    EndIf    
	    
	    @nLin,096 Psay _aTotaliz[_yy,8]		PICTURE "@E 9,999,999" // "Diferenca Fat(R$)" Real - Meta
	    cLin += Transform(_aTotaliz[_yy,8],"@E 9,999,999")+";"
	    
	    if _lDiret     
	       @nLin,107 Psay _aTotaliz[_yy,9]  	PICTURE "@E 9,999,999" // Diferenca Fat(R$)" Real - Referencial
	       cLin += Transform(_aTotaliz[_yy,9],"@E 9,999,999")+";"
	       
	    EndIf   
	    
	    @nLin,119 Psay "|"
	    
	    @nLin,124 Psay _aTotaliz[_yy,10] 	PICTURE "@E 9.999"  // "indice" IPM
	    cLin += Transform(_aTotaliz[_yy,10],"@E 9.999")+";"
	    
	    if _lDiret
	       @nLin,131 Psay _aTotaliz[_yy,3] - _aTotaliz[_yy,4]   PICTURE "@E 99.999"  // "indice" IPR  // Alex Borges 24/11/11
	       cLin += Transform(_aTotaliz[_yy,3] - _aTotaliz[_yy,4],"@E 99.999")+";"
	
	    EndIf 
	      
	    @nLin,139 Psay "|"
	
	    @nLin,141 Psay _aTotaliz[_yy,12]    PICTURE "@E 99999,999"  // "Volume(kg)" Meta
	    cLin += Transform(_aTotaliz[_yy,12],"@E 99999,999")+";"
	    
	    @nLin,153 Psay _aTotaliz[_yy,13]    PICTURE "@E 99999,999"   // "Volume(kg)" Realizado
	    cLin += Transform(_aTotaliz[_yy,13],"@E 99999,999")+";" 
	     
	    @nLin,162 Psay _aTotaliz[_yy,14]    PICTURE "@E 99,999,999,999"  // "Volume(kg)" Projetado
	    cLin += Transform(_aTotaliz[_yy,14],"@E 99999,999")+";"
	         
	    @nLin,177 Psay _aTotaliz[_yy,15]    PICTURE "@E 99999,999" //"Volume(kg)" Necessaria
	    cLin += Transform(_aTotaliz[_yy,15],"@E 99999,999")+";"
	    
	    @nLin,188 Psay "|" 
	    
	    @nLin,193 Psay _aTotaliz[_yy,16]    PICTURE "@E 99999.9" //"Atingimento(%)" REalizado
	    cLin += Transform(_aTotaliz[_yy,16],"@E 99999.9")+";"
	    
	    @nLin,204 Psay _aTotaliz[_yy,17]    PICTURE "@E 99999.9"  //"Atingimento(%)" Projetado
	    cLin += Transform(_aTotaliz[_yy,17],"@E 99999.9")+";"

		_nCobT := cobGrp(_Supervis,Substr(_aTotaliz[_yy,18],1,Len(_aTotaliz[_yy,18]) - 1)) //<<<<<<<<<<<<<
		
	    @nLin,213 Psay _nCobT PICTURE "@E 9999"  //"Atingimento" Projetado
	    cLin += Transform(_nCobT,"@E 9999" )+_eof
	    
	    fWrite(nHdl,cLin,Len(cLin))
	    
	    @nLin,218 Psay "|"
	    nLin++
	
	Next
	
	_aTotaliz := {}
    
Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ_fOpenExceบ Autor ณ Everson            บ Data ณ  17/02/2017 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณFun็ใo para gerar objeto excel.                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณChamado 032203.                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function _fOpenExcel()
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declaracao de Variaveis                                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
	
	cArqSai := "D:\TEMP\"     // Arquivo de Saida local
	
	CpyS2T("\SYSTEM\"+cArq,cPath,.T.)
	
	CpyS2T("\SYSTEM\"+cArq,cArqSai,.T.)
	
	FerasE("\SYSTEM\"+cArq)
	
	//------------------------------
	// Abre MS-EXCEL
	//------------------------------
	If ! ApOleClient( 'MsExcel' )
		MsgStop( "Ocorreram problemas que impossibilitaram abrir o MS-Excel ou mesmo nใo estแ instalado. Por favor, tente novamente." )  //'MsExcel nao instalado'
		Return Nil
		
	EndIf
	
	oExcelApp:= MsExcel():New()  && Objeto para abrir Excel.
	oExcelApp:WorkBooks:Open( cPath + cArq ) // Abre uma planilha
	oExcelApp:SetVisible(.T.)

Return Nil

Static Function execConsult(cQuery,cArq)
	
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cArq, .F., .T.) 

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณValidPerg บ Autor ณ Everson            บ Data ณ  14/02/2017 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณCria pergunta na SX1.                                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณChamado 032203.                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ValidPerg(cPerg)

	PutSX1(cPerg,"01","Faturamento de "   ,"Data de Entrega de ","Data de Entrega de "     ,"mv_ch1","D", 8,0,0  ,"G","","   ","","","mv_par01" ,"    "          ,"","","",""               ,"","",     "","","","","","","",""," ")
	PutSX1(cPerg,"02","Faturamento ate"   ,"Data de Entrega ate","Data de Entrega ate"     ,"mv_ch2","D", 8,0,0  ,"G","","   ","","","mv_par02" ,"    "          ,"","","",""               ,"","",     "","","","","","","",""," ")
	PutSX1(cPerg,"03","Do Supervisor      "   ,"Do Supervisor      ","Do Supervisor      "     ,"mv_ch3","C", 6,0,0  ,"G","","A06","","","mv_par03" ,"    "          ,"","","",""               ,"","",     "","","","","","","",""," ")
	PutSX1(cPerg,"04","Ate Supervisor     "   ,"Ate Supervisor     ","Ate Supervisor     "     ,"mv_ch4","C", 6,0,0  ,"G","","A06","","","mv_par04" ,"    "          ,"","","",""               ,"","",     "","","","","","","",""," ")
	PutSx1(cPerg,"05","Seleciona filiais"     ,"Seleciona filiais"  ,"Seleciona filiais"       ,"mv_ch5","C",50,0,0  ,"G","U_FXFIL()","","","","mv_par05","","","","","","","","","","","","","","","","","","","")
	PutSx1(cPerg,"06","Nr.dias Uteis meta"    ,"Nr.dias Uteis meta" ,"Nr.dias Uteis meta"      ,"mv_ch6","N", 2,0,0  ,"G","","","","","mv_par06","","","","","","","","","","","","","","","","","","","")
	PutSx1(cPerg,"07","Nr.dias corridos"      ,"Nr.dias corridos"   ,"Nr.dias corridos"        ,"mv_ch7","N", 2,0,0  ,"G","","","","","mv_par07","","","","","","","","","","","","","","","","","","","")
	PutSx1(cPerg,"08","Valor limite 1"        ,"Valor limite 1"     ,"Valor limite 1"          ,"mv_ch8","N",12,0,0  ,"G","","","","","mv_par08","","","","","","","","","","","","","","","","","","","")
	PutSx1(cPerg,"09","Valor limite 2"        ,"Valor limite 2"     ,"Valor limite 2"          ,"mv_ch9","N",12,0,0  ,"G","","","","","mv_par09","","","","","","","","","","","","","","","","","","","")
	PutSx1(cPerg,"10","Data Meta Inicio"      ,"Data Meta Inicio"   ,"Data Meta Inicio"        ,"mv_ch10","D",8,0,0  ,"G","","","","","mv_par10","","","","","","","","","","","","","","","","","","","")
	PutSx1(cPerg,"11","Data Meta Inicio"      ,"Data Meta Inicio"   ,"Data Meta Inicio"        ,"mv_ch11","D",8,0,0  ,"G","","","","","mv_par11","","","","","","","","","","","","","","","","","","","")
	PutSX1(cPerg,"12","Vendedor?"             ,"Vendedor?"          ,"Vendedor?"               ,"mv_ch12","N",01,0,01,"C","","","","","mv_par12" ,"Vendedor 1","Vendedor 1","Vendedor 1","","Vendedor 2","Vendedor 2","Vendedor 2","","","","","","","",""," ")

Return Nil
