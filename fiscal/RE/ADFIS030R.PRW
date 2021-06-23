#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.ch"
#INCLUDE "FWMBROWSE.CH"

/*/{Protheus.doc} User Function ADFIS030R
	Tela do Painel Fiscal - PIS e COFINS
	@type  Function
	@author Abel Babini Filho
	@since 21/01/19
	@version 03
	@history Chamado 048575 - Relatorio Credito Presumido - Abel Babini - 23/04/2019
	@history Chamado 040918 - Relatorio INSS para calculo da desoneração - 27/05/2019
	@history Chamado 045022 - Relatorio Cred Pis/Cof Parcelado sobre Ativo - 10/06/2019
	@history Chamado 049766 - Ajuste Campo Valor Contábil - Abel Babini - 10/06/2019
	@history Chamado 051633 - OS 052957 || FISCAL || DEJAIME || 8921 || REL. PIS/COFINS - ABEL - 09/09/2019 
	@history Chamado TI - ABEL - 20/09/2019 || Ajustes no Painel Fiscal para não permitir gerar mais do que 30 dias
	@history Chamado 052243 - ABEL - 01/10/2019 - RETIRADO RELACIONAMENTO COM A SN3
	@history Chamado 051633 - ABEL - 22/11/2019 - Ajustado o relatório de Benfeitoria para acrescentar planilhas de resumo
	@history Ticket  13124 - Abel Babini - 14/05/2021 - Criar rotina de fechamento do período, gravando valores e parâmetros utilizados no calculo

	/*/
User Function ADFIS030R()

	Local aArea		:= GetArea()
	Local aPergs	:= {}
	Local i := 0
	
	Private cCadastr  := OemToAnsi("PAINEL FISCAL PIS COFINS")
	Private cPathRel
		
	//Definição de Fontes
	Private oFont001	:= TFont():New( "Arial",,14,,.f.,,,,,.f. )
	Private oFont002	:= TFont():New( "Arial",,16,,.T.,,,,,.f. )
	Private oFont003	:= TFont():New( "Arial",,18,,.T.,,,,,.f. )
	
	Private _mvpr01
	Private _mvpr02

	//Parâmetros aba 24
	Private cCPPCAGR	:= cValToChar( GETMV("MV_CPPCAGR") )
	Private cCAJCPPC	:= GETMV("MV_CAJCPPC")
	Private cXNCMCPR	:= GETMV("MV_#NCMCPR")
	Private cACPPCAG	:= GETMV("MV_ACPPCAG")
	Private cCSTPRES	:= GETMV("MV_CSTPRES")
	Private cDAPCCPA	:= GETMV("MV_DAPCCPA")
	Private cNCMCPPC	:= GETMV("MV_NCMCPPC")
	Private cXCPRCEP	:= GETMV("MV_#CPRCEP")
	Private cNCMCREP	:= GETMV("MV_NCMCREP")
	Private cXCFCPEX	:= GETMV("MV_#CFCPEX")
	Private cXACPPCI	:= GETMV("MV_#ACPPCI")
	Private cXCSTCPI	:= GETMV("MV_#CSTCPI")
	Private cXINCPMI	:= GETMV("MV_#INCPMI")
	Private cXNCMEMB	:= GETMV("MV_#NCMEMB")
	Private cXCFCPMI	:= GETMV("MV_#CFCPMI")
	
	Private nPerMI		:= 0 //Percentual Mercado Interno
	Private nPerME		:= 0 //Percentual Mercado Externo
	Private nTotInMI 	:= 0 //Total de Insumos Animal + Vegetal Mercado Interno
	Private nTotInME	:= 0 //Total de Insumos Animal + Vegetal Mercado Externo
	Private nTotExCA	:= 0 //Total Exportação Carne de Aves
	Private nTotExNC	:= 0 //Total Exportação Não Comestíveis
	Private nTotAlZr	:= 0 //Total Venda Carna de Aves Aliquota Zero
	Private nTotInd		:= 0 //Total Industrializado
	
	Private nTVlMI		:= 0	// Total Vl. Contabil Merc Interno
	Private nTBCPMI		:= 0	// Total BC Pis Merc Interno
	Private nTBCCMI		:= 0	// Total BC Cofins Merc Interno
	Private nTVlPMI		:= 0	// Total Vl Pis Merc Interno
	Private nTVlCMI		:= 0	// Total Vl Cofins Merc Interno

	Private nTVlME		:= 0	// Total Vl. Contabil Merc Externo
	Private nTBCPME		:= 0	// Total BC Pis Merc  Externo
	Private nTBCCME		:= 0	// Total BC Cofins Merc Externo
	Private nTVlPME		:= 0	// Total Vl Pis Merc Externo
	Private nTVlCME		:= 0	// Total Vl Cofins Merc Externo
	
	Private nTVlMIF		:= 0	// Total Vl. Contabil Merc Interno
	Private nTBCPMIF	:= 0	// Total BC Pis Merc Interno
	Private nTBCCMIF	:= 0	// Total BC Cofins Merc Interno
	Private nTVlPMIF	:= 0	// Total Vl Pis Merc Interno
	Private nTVlCMIF	:= 0	// Total Vl Cofins Merc Interno

	Private nTVlMEF		:= 0	// Total Vl. Contabil Merc Externo
	Private nTBCPMEF	:= 0	// Total BC Pis Merc  Externo
	Private nTBCCMEF	:= 0	// Total BC Cofins Merc Externo
	Private nTVlPMEF	:= 0	// Total Vl Pis Merc Externo
	Private nTVlCMEF	:= 0	// Total Vl Cofins Merc Externo

	Private _cMesI		:= ""
	Private _cAnoI		:= ""
	Private _cMesAnt	:= ""
	Private _cAnoAnt	:= ""
	Private _cMesF		:= ""
	Private _cAnoF		:= ""
	Private aRet		:= {}
	
	Private aFilSlCP	:= {} //AdmGetFil()
	Private cFilIn		:= ""

	//-----------------------------------
	//Variáveis BROWSER 24 - CREDITO PRESUMIDO
	//-----------------------------------
	Private aBrw24MI, aBrw24ME, ATBR24FI, ATBR24FE	 := {}
	Private nVlTotMI24, nVlTotME24	:= 0
	
	//INICIO Chamado n.040918 - Abel.Babini - Relatorio INSS para calculo da desoneração - 27/05/2019
	//-----------------------------------
	//Variáveis BROWSER 25 - INSS DESONERAÇÃO
	//-----------------------------------
	Private aBrw25Dt,aBrw25Rs,aCFAux,aFlAux	, aBrw25P1, aBrw25Pr  := {}
	Private cAlsB25Dt 
	Private nQFIL, nQPrC, nQCFOP := 0
	Private aTt25v01		:= {} //ICMS ST
	Private aTt25v02		:= {} //Exportação
	Private aTt25v03		:= {} //Devoluções
	Private aTt25v04		:= {} //Imobilizado

	Private cP25A01			:= GETMV("MV_#CFINSS",,"1201,1202,2201,2202,1410,2410,3201,5105,6105,5101,5118,5122,5125,5401,6401,5922,6101,6102,6107,6118,6122,5551,6551,5252,6252,7101,7105,5124,6124,5102,6102") //CFOP PARA CONSIDERAR COMO RECEITA NO CALCULO DA DESONERAÇÃO DO INSS
	Private cP25A02			:= GETMV("MV_#CFICST",,"5401|6401") //CFOP PARA SOMAR ICMS ST NO CALCULO INSS DESONERACAO
	Private cP25A03			:= GETMV("MV_#CFINEX",,"7101") //CFOP PARA SOMAR EXPORTACAO NO CALCULO INSS DESONERACAO
	Private cP25A04			:= GETMV("MV_#CFINDV",,"1201,1410,2201,2202") //CFOP PARA DEDUZIR DEVOLUÇÃO NO CALCULO INSS DESONERACAO
	Private cP25A05			:= GETMV("MV_#CFIDV2",,"1410") //CFOP PARA SOMAR ICMS ST NAS DEVOLUÇÕES NO CALCULO INSS DESONERACAO
	Private cP25A06			:= GETMV("MV_#CFINIM",,"5551,6551") //CFOP PARA SOMAR IMOBILIZADO NO CALCULO INSS DESONERACAO
	Private cP25A07			:= GETMV("MV_#ALINSS",,0.01) //CFOP PARA SOMAR IMOBILIZADO NO CALCULO INSS DESONERACAO
	
	Private cP25A01b		:= "%"+FormatIn(cP25A01,",")+"%"
	
	//FIM Chamado n.040918 - Abel.Babini - Relatorio INSS para calculo da desoneração - 27/05/2019

	// INICIO Chamado n.045022  - Abel.Babini - Relatorio Cred Pis/Cof Parcelado sobre Ativo - 10/06/2019
	//-----------------------------------
	//Variáveis BROWSER 26 - CREDITO PIS/COFINS
	//-----------------------------------
	Private cAlsB26Dt 
	Private nQMes, nTPMes,nTCMes,nQItens, nVlTOrig, nVlCPT, nVlCCT, nVlCPCBC, nVlCPCBP, nVlCPCBT, nVlCCCBP, nVlCCCBT	:= 0
	Private aBrw26Cr := aBrw26Pr := aBrw26Dt := aBrw26Sv := aBrw26Bn := aNomeMes := {}
	Private nNomeAno
	Private cNomeMes
	
	// FIM Chamado n.045022  - Abel.Babini - Relatorio Cred Pis/Cof Parcelado sobre Ativo - 10/06/2019

	// INICIO n.051633  ³ OS 052957 || FISCAL || DEJAIME || 8921 || REL. PIS/COFINS - ABEL - 09/09/2019
	//-----------------------------------
	//Variáveis BROWSER 27 - CONFERENCIA PIS/COFINS
	//-----------------------------------
	Private cAlsB27Dt 
	Private aBrw27Be, aBrw27Se, aBrw27SN, aBrw27Im, aBrw27Dt	:= {}

	Private nA27T01,nA27T02,nA27T03,nA27T04		:= 0
	Private nA27T11,nA27T12,nA27T13,nA27T14	,nA27T15,nA27T16,nA27T17,nA27T18	:= 0
	Private nA27T21,nA27T22,nA27T23,nA27T24,nA27T25,nA27T26,nA27T27,nA27T28		:= 0
	Private nA27T31,nA27T32,nA27T33,nA27T34		:= 0

	// FIM n.051633  ³ OS 052957 || FISCAL || DEJAIME || 8921 || REL. PIS/COFINS - ABEL - 09/09/2019

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Tela do Painel Fiscal - PIS e COFINS')
	
	//-----------------------------------
	//INÍCIO DO PROGRAMA
	//-----------------------------------

	//Adiciona Perguntas / Parâmetros ao relatório
	aAdd( aPergs ,{1,"Data De "     ,Ctod(space(8)),"" ,'.T.',,'.T.',80,.T.})
    aAdd( aPergs ,{1,"Data Até"     ,Ctod(space(8)),"" ,'.T.',,'.T.',80,.T.})    
	      
    //Executa as perguntas ao usuário e só executa o relatório caso o usuário confirme a tela de parâmetros;
    If ParamBox(aPergs ,"Parâmetros ",aRet,,,,,,,,.T.,.T.) 
    	_lPerg	:= .T.

    	_mvpr01	:= aRet[1]
    	_mvpr02	:= aRet[2]

		//Valida Informações das datas informadas:
		_cMesI	:= StrZero(Month(aRet[1]),2)
		_cAnoI	:= Alltrim(Str(Year(aRet[1])))
		_cMesF	:= StrZero(Month(aRet[2]),2)
		_cAnoF	:= Alltrim(Str(Year(aRet[2])))
		If !(_cMesI == _cMesF) .Or. !(_cAnoI == _cAnoF)
			Alert('É necessário que Mês e Ano inicial sejam iguais ao Mês e Ano final. Impossível continuar!')
			_lPerg = .F.
		Endif
    Else
    	Alert("Não foram informados os parâmetros. Operação cancelada!")
    	Return
    Endif

    if _lPerg    
	    aFilSlCP	:= AdmGetFil()   
	    IF Len(aFilSlCP)==0
	    	Alert("Nenhuma Filial Selecionada. Operação cancelada!")
	    	_lPerg = .F.
	    Else
		    For i:= 1 to Len(aFilSlCP)
		    	If i=1
		    		cFilIn := aFilSlCP[i]
		    	Else
		    		cFilIn += ','+ aFilSlCP[i]
		    	Endif
		    Next i
		    
		    cFilIn	:= '%'+FormatIn(cFilIn,',')+'%'
	
	    Endif
	endif
	
	//Interno TI³ ABEL - 20/09/2019 || Ajustes no Painel Fiscal para não permitir gerar mais do que 30 dias
	if _lPerg
	    cPathRel	:= cGetFile("Arquivo XML", "Selecione o diretório para salvar o relatório",,'C:\TEMP\',.T.,GETF_RETDIRECTORY + GETF_LOCALHARD + GETF_NETWORKDRIVE)
	    IF Alltrim(cPathRel) == ""
	    	cPathRel := "C:\TEMP\"
	    ENDIF
        
		//Apresenta tela do Painel
		PNCON001() 
	endif
	
	RestArea(aArea)
Return

/*/{Protheus.doc} Static Function PNCON001
	Tela do Painel Fiscal - PIS e COFINS
	@type  Function
	@author Abel Babini Filho
	@since 21/01/19
	@version 03
	/*/
Static Function PNCON001() 
	Local oDlg		:= Nil
	Local aSize   	:= MsAdvSize(.f.)
	Local aInfo   	:= {aSize[1],aSize[2],aSize[3],aSize[4],3,3}
	Local aObjects	:= {},aPosObj :={}	
	Local cHrIni, cHrFim
	Local nColBr25 := 0

	//--------------------------------------------**
	//Variáveirs do Browser24 - CREDITO PRESUMIDO
	//---------------------------------------------
	Local oFLr24p1, oFLr24p2, oFLr24p3, oFLr24p4
	Local oBrw24MI, oBrw24ME

	//INICIO Chamado n.040918 - Abel.Babini - Relatorio INSS para calculo da desoneração - 27/05/2019
	//--------------------------------------------**
	//Variáveirs do Browser25 - INSS DESONERACAO
	//---------------------------------------------
	Local oFLr25p1, oFLr25p2, oFLr25p3
	//FIM Chamado n.040918 - Abel.Babini - Relatorio INSS para calculo da desoneração - 27/05/2019

	// INICIO Chamado n.045022  - Abel.Babini - Relatorio Cred Pis/Cof Parcelado sobre Ativo - 10/06/2019
	//-----------------------------------
	//Variáveis BROWSER 26 - CREDITO PIS/COFINS
	//-----------------------------------
	Local oFLr26p1,oFLr26p2, oFLr26p3
	// FIM Chamado n.045022  - Abel.Babini - Relatorio Cred Pis/Cof Parcelado sobre Ativo - 10/06/2019
	
	//---------------------------------------------
	//Variáveirs Privadas
	//---------------------------------------------
	//Private oDlg		:= Nil
	Private cFld01 := 'Informações Gerais'

	//FOLDER 24 - CREDITO PRESUMIDO
	Private cFld24 := 'Cred Presumido'
	Private cFld242 := 'Merc_Interno'
	Private cFld243 := 'Merc_Externo'
	Private cFld244 := 'Parametros'
	Private cFld245 := 'Filiais'
	
	Private cFld24t1 := cFld24 + ' - Resumo'
	Private cFld24t2 := cFld24 + ' - MI'
	Private cFld24t3 := cFld24 + ' - ME' 
	Private cFld24t4 := cFld24 + ' - Param'
	Private cFld24t5 := cFld24 + ' - Filiais'
	
	Private cFld24p01 := 'Resumo'
	Private cFld24p02 := 'Mercado Interno'
	Private cFld24p03 := 'Mercado Externo'
	Private cFld24p04 := 'Parâmetros'

	//INICIO Chamado n.040918 - Abel.Babini - Relatorio INSS para calculo da desoneração - 27/05/2019
	//FOLDER 25 - INSS DESONERAÇÃO
	Private cFld25 := 'INSS Desoneração'
	Private cFld252 := 'Consolidação Bloco P100'
	Private cFld253 := 'Detalhe'
	Private cFld254 := 'Parametros'
	Private cFld25t1 := cFld25 + ' - Resumo'
	Private cFld25t2 := cFld25 + ' - Detalhe'
	Private cFld25t3 := cFld25 + ' - Bloco P100'
	Private cFld25t4 := cFld25 + ' - Param'

	Private cFld25p01 := 'Resumo'
	Private cFld25p02 := 'Consolidação Bloco P100'
	Private cFld25p03 := 'Detalhe'
	Private cFld25p04 := 'Conf. Produtos'
	Private cFld25p05 := 'Parâmetros'
	Private oBrw25Rs, oBrw25P1, oBrw25Pr

	Private oTBitmap1
	Private oTAlert1
	//FIM Chamado n.040918 - Abel.Babini - Relatorio INSS para calculo da desoneração - 27/05/2019

	//INICIO Chamado n.045022  - Abel.Babini - Relatorio Cred Pis/Cof Parcelado sobre Ativo - 10/06/2019
	//FOLDER 26 - CREDITO PIS/COFINS
	Private cFld26 := 'Credito Imobilizado Benfeitorias'
	Private cFld262 := 'Projeção PIS'
	Private cFld263 := 'Projeção COFINS'
	Private cFld264 := 'Detalhes'
	Private cFld265 := 'Resumo Serviços'
	Private cFld266 := 'Resumo Bens'
	Private cFld26t1 := cFld26 + ' - Resumo'
	Private cFld26t2 := cFld26 + ' - Projeção'
	Private cFld26t3 := cFld26 + ' - Detalhe'
	Private cFld26t4 := cFld26 + ' - Param'
	Private cFld26t5 := cFld26 + ' - Resumo Serviços'
	Private cFld26t6 := cFld26 + ' - Resumo Bens'

	Private cFld26p01 := 'Resumo'
	Private cFld26p02 := 'Projeção'
	Private cFld26p03 := 'Detalhe'
	Private cFld26p04 := 'Parâmetros'
	Private oBrw26Rs, oBrw26Pr, oBrw26Dt

	//FIM Chamado n.045022  - Abel.Babini - Relatorio Cred Pis/Cof Parcelado sobre Ativo - 10/06/2019
	
	// INICIO n.051633  ³ OS 052957 || FISCAL || DEJAIME || 8921 || REL. PIS/COFINS - ABEL - 09/09/2019
	Private cFld27 := 'Conferência de Pis e Cofins'
	Private cFld272 := 'Detalhe'
	Private cFld273 := 'Imobilizado'
	Private cFld274 := 'Benf. Bens'
	Private cFld275 := 'Benf. Serv.'
	Private cFld276 := 'Serv. sem Cred.'

	Private cFld27t1 := cFld26 + ' - Resumo'
	Private cFld27t2 := cFld26 + ' - Detalhe'
	Private cFld27t3 := cFld26 + ' - Imobilizado'
	Private cFld27t4 := cFld26 + ' - Benf Bens'
	Private cFld27t5 := cFld26 + ' - Benf Serv'
	Private cFld27t6 := cFld26 + ' - Serv s Cred'
	
	Private cFld27p01 := 'Resumo'
	Private cFld27p02 := 'Detalhe'
	Private cFld27p03 := 'Imobilizado'
	Private cFld27p04 := 'Benf Bens'	
	Private cFld27p05 := 'Benf Serv'	
	Private cFld27p06 := 'Serv s Cred'	
	// FIM n.051633  ³ OS 052957 || FISCAL || DEJAIME || 8921 || REL. PIS/COFINS - ABEL - 09/09/2019

	//Ticket  13124 - Abel Babini - 14/05/2021 - Criar rotina de fechamento do período, gravando valores e parâmetros utilizados no calculo
	Private _cMVMstr	:= GETMV("MV_#PNUSMR",,"") //Usuário com permissão de fechamento do Período no 
	Private _lMsUser	:= IIF(__cUserID $ _cMVMstr, .T., .F.)
	Private cLstVrs		:= xRecVer('ZZ')
	Private _lPerFch	:= xVerFcht(cLstVrs)
	Private _cNomUse	:= Alltrim(substr(cUsuario,7,15))

	cLstVrs := IIF(ALLTRIM(cLstVrs)=='','001',cLstVrs)
	//Verifica se houve fechamento, e em caso afirmativa, utiliza os parâmetros utilizados na época.
	xLoadPar()

	//Atualiza variáveis de Mes e Ano do período anterior.
	If _cMesI == "1"
		_cMesAnt := "12"
		_cAnoAnt := Alltrim(Str(Val(_cAnoI)-1))
	Else
		_cMesAnt := Alltrim(Strzero(Val(_cMesI)-1,2	))
		_cAnoAnt := _cAnoI
	Endif	

	cHrIni	:= TIME()
	MsgRun( "Carregando dados fiscais - Crédito Presumido, aguarde...",,{ || xABrw24() } ) //CREDITO PRESUMIDO
	MsgRun( "Carregando dados fiscais - INSS Desoneração, aguarde...",,{ || xABrw25() } ) //INSS DESONERAÇÃO //Chamado n.040918 - Abel.Babini - Relatorio INSS para calculo da desoneração - 27/05/2019
	MsgRun( "Carregando dados fiscais - Crédito Benfeitoria em Imobilizados, aguarde...",,{ || xABrw26() } ) //INSS DESONERAÇÃO //Chamado n.040918 - Abel.Babini - Relatorio INSS para calculo da desoneração - 27/05/2019
	MsgRun( "Carregando dados fiscais - Conferência Pis/Cofins, aguarde...",,{ || xABrw27() } ) //CONFERÊNCIA PIS/COFINS // INICIO n.051633  ³ OS 052957 || FISCAL || DEJAIME || 8921 || REL. PIS/COFINS - ABEL - 09/09/2019
	
	cHrFim	:= ElapTime( cHrIni, TIME() )
	
	AADD(aObjects,{100,040,.T.,.F.,.F.})
	AADD(aObjects,{100,100,.T.,.T.,.F.})
	aPosObj:=MsObjSize(aInfo,aObjects)
	
	DEFINE MSDIALOG oDlg TITLE cCadastr OF oMainWnd PIXEL FROM aSize[7],0 TO aSize[6],aSize[5]
	oDlg:lMaximized := .T.

	@ 001,aPosObj[1,2] TO aPosObj[1,3],aPosObj[1,4] OF oDlg PIXEL
	
	@ 004,008 SAY OemToAnsi("Ano")		FONT oFont002 SIZE 022,7 OF oDlg PIXEL			 //"Ano"
	@ 004,036 SAY OemtoAnsi("Mês")		FONT oFont002 SIZE 030,7 OF oDlg PIXEL			 //"Mês"
	@ 004,060 SAY OemToAnsi("Filial")	FONT oFont002 SIZE 021,7 OF oDlg PIXEL			 //"Filial"

	@ 012,008 SAY OemToAnsi(_cAnoI)	FONT oFont001 SIZE 022,7 OF oDlg PIXEL			 //"Ano"
	@ 012,036 SAY OemtoAnsi(_cMesI)	FONT oFont001 SIZE 030,7 OF oDlg PIXEL			 //"Mês"
	@ 012,060 SAY OemToAnsi(SM0->M0_FILIAL)	FONT oFont001 SIZE 060,7 OF oDlg PIXEL			 //"Filial"
	
	@ 004,200 BUTTON OemToAnsi('Exp. Pis/Cof')		SIZE 42,13 FONT oDlg:oFont ACTION xExpPISR() OF oDlg PIXEL //"Exportar Excel"
	@ 018,200 BUTTON OemToAnsi('Exp. Pis/Cof Det')	SIZE 42,13 FONT oDlg:oFont ACTION xExpPISD() OF oDlg PIXEL //"Exportar Excel"
	@ 004,250 BUTTON OemToAnsi('Sair')     	 		SIZE 42,13 FONT oDlg:oFont ACTION oDlg:End() OF oDlg PIXEL //"Sair"

	
	aFolder  := {;
				cFld01,;
				cFld24,;
				cFld25,;
				cFld26,;
				cFld27;
				}

	oFolder030:=TFolder():New(aPosObj[2,1],aPosObj[2,2],aFolder,{},oDlg,,,, .T., .F.,aPosObj[2,4]-2,aPosObj[2,3]-10,)
	oFolder030:aDialogs[1]:oFont :=oDlg:oFont //Informações Gerais
		
	oFolder030:aDialogs[2/*24*/]:oFont :=oDlg:oFont //Credito Presumido
	oFolder030:aDialogs[3/*25*/]:oFont :=oDlg:oFont //INSS Desoneração
	oFolder030:aDialogs[4]:oFont :=oDlg:oFont //Conferência Pis/Cofins // INICIO n.051633  ³ OS 052957 || FISCAL || DEJAIME || 8921 || REL. PIS/COFINS - ABEL - 09/09/2019	
	
	//--------------------------------------------------------------------------
	//ABA 01 - INFORMAÇÕES GERAIS (INICIO)
	//--------------------------------------------------------------------------
	
	oFLr01	:= FWLayer():New()
	oFLr01:Init( oFolder030:aDialogs[1], .F., .T.)
	
	//Define os Paineis 
	//TITULO
	oFLr01:AddLine ('TITULO', 10, .F.)
	oFLr01:AddCollumn('TITULO',100,.F.,'TITULO')
	//DETALHE
	oFLr01:AddLine ('DETALHE', 90, .F.)
	oFLr01:AddCollumn('DET_ESQ',100,.F.,'DETALHE')

	oPn01TE	:= oFLr01:GetColPanel('TITULO','TITULO')
	oPn01DE	:= oFLr01:GetColPanel('DET_ESQ','DETALHE')

	oPn01TE:FreeChildren()
	oPn01DE:FreeChildren()
	
	//PARÂMETROS
	@ 001,008 SAY OemToAnsi("INFORMAÇÕES GERAIS - PAINEL FISCAL")		FONT oFont003 SIZE 200,15 OF oPn01TE PIXEL
		
	@ 011,015 SAY OemToAnsi("Esta rotina tem o objetivo de centralizar a emissão dos relatórios relacionados ao Fechamento Fiscal."+;
							" A geração dos relatórios poderá ser realizada de forma consolidade, clicando no botão 'Gera Relatório' localizado no painel superior, ou de forma individualizada, clicando no botão 'Gera Relatório' localizado em cada aba."+;
							" Novas funcionalidades pdoerão ser adicionadas ao longo do tempo afim de atender à demanda do Departamento Fiscal.";
							)				FONT oFont002 SIZE 400,200 OF oPn01DE PIXEL
	
	If _lMsUser
		@ 050,470 BUTTON OemToAnsi('Fecha Período')	SIZE 42,26 When !_lPerFch	FONT oDlg:oFont ACTION xGrvFcht() OF oPn01DE PIXEL
		@ 050,520 BUTTON OemToAnsi('Reabre Período')	SIZE 42,26 When _lPerFch	FONT oDlg:oFont ACTION xAbrFcht() OF oPn01DE PIXEL
	Endif

	@ 101,008 SAY OemToAnsi("Tempo de Processamento: "+cHrFim)		FONT oFont003 SIZE 200,15 OF oPn01DE PIXEL


	//--------------------------------------------------------------------------
	//ABA 24 - Relatório de Crédito Presumido
	//--------------------------------------------------------------------------

	aFld24  := {cFld24p01,cFld24p02,cFld24p03,cFld24p04}
	oFld024:=TFolder():New(1,1,aFld24,{},oFolder030:aDialogs[2/*24*/],,,, .T., .F.,aPosObj[2,4]-5,aPosObj[2,3]-55,)
	oFld024:aDialogs[1]:oFont :=oDlg:oFont
	oFld024:aDialogs[2]:oFont :=oDlg:oFont
	oFld024:aDialogs[3]:oFont :=oDlg:oFont
	oFld024:aDialogs[4]:oFont :=oDlg:oFont

	////////////////////////////////////////////////////////////
	oFLr24p1:= FWLayer():New()
	oFLr24p1:Init( oFld024:aDialogs[1], .F., .T.) //RESUMO
	//TITULO
	oFLr24p1:AddLine ('TIT_DLG1', 6, .F.)
	oFLr24p1:AddCollumn('TIT_DLG1',100,.F.,'TIT_DLG1')
	//DETALHE
	oFLr24p1:AddLine ('DET_DLG1', 88, .F.)
	oFLr24p1:AddCollumn('DET_DLG1E',50,.F.,'DET_DLG1')
	oFLr24p1:AddCollumn('DET_DLG1D',50,.F.,'DET_DLG1')
	//RODAPE
	oFLr24p1:AddLine ('ROD_DLG1', 6, .F.)
	oFLr24p1:AddCollumn('ROD_DLG1',100,.F.,'ROD_DLG1')
	
	oPn24T1		:= oFLr24p1:GetColPanel('TIT_DLG1','TIT_DLG1')
	oPn24D1E	:= oFLr24p1:GetColPanel('DET_DLG1E','DET_DLG1')
	oPn24D1D	:= oFLr24p1:GetColPanel('DET_DLG1D','DET_DLG1')
	oPn24R1		:= oFLr24p1:GetColPanel('ROD_DLG1','ROD_DLG1')

	oPn24T1:FreeChildren()
	oPn24D1E:FreeChildren()
	oPn24D1D:FreeChildren()
	oPn24R1:FreeChildren()
	
	//Cabecalho
	@ 001,008 SAY OemToAnsi("Crédito Presumido Pis/Cofins - Resumo")	FONT oFont003 SIZE 200,15 OF oPn24T1 PIXEL	
	
	@ 001,008 SAY OemToAnsi("Mercado Interno")	FONT oFont002 SIZE 200,15 OF oPn24D1E PIXEL	
	@ 001,008 SAY OemToAnsi("Mercado Externo")	FONT oFont002 SIZE 200,15 OF oPn24D1D PIXEL	
	
	@ 011,015 SAY OemToAnsi("% Receita Industrializados")		FONT oFont001 SIZE 200,15 OF oPn24D1E PIXEL
	@ 010,120 MSGET nPerMI	SIZE 60,08 OF oPn24D1E PIXEL When .F. PICTURE '@E 9,999,999,999.99%'

	@ 026,015 SAY OemToAnsi("Total Receita Industrializados")		FONT oFont001 SIZE 200,15 OF oPn24D1E PIXEL
	@ 025,120 MSGET nTotInd	SIZE 60,08 OF oPn24D1E PIXEL When .F. PICTURE '@E 9,999,999,999.99'

	@ 041,015 SAY OemToAnsi("Total Receita Carne Aves Aliq. Zero")		FONT oFont001 SIZE 200,15 OF oPn24D1E PIXEL
	@ 040,120 MSGET nTotAlZr	SIZE 60,08 OF oPn24D1E PIXEL When .F. PICTURE '@E 9,999,999,999.99'

	@ 056,015 SAY OemToAnsi("Total Vl. Contábil")				FONT oFont001 SIZE 200,15 OF oPn24D1E PIXEL
	@ 055,120 MSGET nTVlMI	SIZE 60,08 OF oPn24D1E PIXEL When .F. PICTURE '@E 9,999,999,999.99' // Total Vl. Contabil

	@ 071,015 SAY OemToAnsi("Base Calculo Pis")					FONT oFont001 SIZE 200,15 OF oPn24D1E PIXEL
	@ 070,120 MSGET nTBCPMI	SIZE 60,08 OF oPn24D1E PIXEL When .F. PICTURE '@E 9,999,999,999.99' // Total Vl. Contabil

	@ 086,015 SAY OemToAnsi("Base Calculo Cofins")				FONT oFont001 SIZE 200,15 OF oPn24D1E PIXEL
	@ 085,120 MSGET nTBCCMI	SIZE 60,08 OF oPn24D1E PIXEL When .F. PICTURE '@E 9,999,999,999.99' // Total Vl. Contabil

	@ 101,015 SAY OemToAnsi("Total Vl. Pis")				FONT oFont002 SIZE 200,15 OF oPn24D1E PIXEL
	@ 100,120 MSGET nTVlPMI	SIZE 60,08 OF oPn24D1E PIXEL When .F. PICTURE '@E 9,999,999,999.99' // Total Vl Pis Merc Interno
	
	@ 097,011 TO 130,185 OF oPn24D1E PIXEL
	
	@ 116,015 SAY OemToAnsi("Total Vl. Cofins")			FONT oFont002 SIZE 200,15 OF oPn24D1E PIXEL
	@ 115,120 MSGET nTVlCMI	SIZE 60,08 OF oPn24D1E PIXEL When .F. PICTURE '@E 9,999,999,999.99' // Total Vl Cofins Merc Interno

	@ 011,015 SAY OemToAnsi("% Receita Exportação")		FONT oFont001 SIZE 200,15 OF oPn24D1D PIXEL
	@ 010,120 MSGET nPerME	SIZE 60,08 OF oPn24D1D PIXEL When .F. PICTURE '@E 9,999,999,999.99%'

	@ 026,015 SAY OemToAnsi("Total Receita Exportação")		FONT oFont001 SIZE 200,15 OF oPn24D1D PIXEL
	@ 025,120 MSGET nTotInME	SIZE 60,08 OF oPn24D1D PIXEL When .F. PICTURE '@E 9,999,999,999.99'

	@ 041,015 SAY OemToAnsi("Total Receita ")		FONT oFont001 SIZE 200,15 OF oPn24D1D PIXEL
	@ 040,120 MSGET nTotExCA	SIZE 60,08 OF oPn24D1D PIXEL When .F. PICTURE '@E 9,999,999,999.99'

	@ 056,015 SAY OemToAnsi("Total Vl. Contábil")				FONT oFont001 SIZE 200,15 OF oPn24D1D PIXEL
	@ 055,120 MSGET nTVlME	SIZE 60,08 OF oPn24D1D PIXEL When .F. PICTURE '@E 9,999,999,999.99' // Total Vl. Contabil

	@ 071,015 SAY OemToAnsi("Base Calculo Pis")				FONT oFont001 SIZE 200,15 OF oPn24D1D PIXEL
	@ 070,120 MSGET nTBCPME	SIZE 60,08 OF oPn24D1D PIXEL When .F. PICTURE '@E 9,999,999,999.99' // Total Vl. Contabil

	@ 086,015 SAY OemToAnsi("Base Calculo Cofins")				FONT oFont001 SIZE 200,15 OF oPn24D1D PIXEL
	@ 085,120 MSGET nTBCCME	SIZE 60,08 OF oPn24D1D PIXEL When .F. PICTURE '@E 9,999,999,999.99' // Total Vl. Contabil

	@ 101,015 SAY OemToAnsi("Total Vl. Pis")				FONT oFont002 SIZE 200,15 OF oPn24D1D PIXEL
	@ 100,120 MSGET nTVlPME	SIZE 60,08 OF oPn24D1D PIXEL When .F. PICTURE '@E 9,999,999,999.99' // Total Vl Pis Merc Interno

	@ 097,011 TO 130,185 OF oPn24D1D PIXEL
	
	@ 116,015 SAY OemToAnsi("Total Vl. Cofins")			FONT oFont002 SIZE 200,15 OF oPn24D1D PIXEL
	@ 115,120 MSGET nTVlCME	SIZE 60,08 OF oPn24D1D PIXEL When .F. PICTURE '@E 9,999,999,999.99' // Total Vl Cofins Merc Interno
	
	//QUADRO DE RELATÓRIO
	@ 140,008 SAY OemToAnsi("OUTRAS OPÇÕES")	FONT oFont003 SIZE 200,15 OF oPn24D1D PIXEL
	@ 155,008 BUTTON OemToAnsi('Gera Relatório')	SIZE 42,13 FONT oDlg:oFont ACTION xRelBr24() OF oPn24D1D PIXEL //"Exportar Excel"
	
	////////////////////////////////////////////////////////////
	oFLr24p2:= FWLayer():New()
	oFLr24p2:Init( oFld024:aDialogs[2], .F., .T.) //MERCADO INTERNO
	
	//TITULO
	oFLr24p2:AddLine ('TIT_DLG2', 6, .F.)
	oFLr24p2:AddCollumn('TIT_DLG2',100,.F.,'TIT_DLG2')
	//DETALHE
	oFLr24p2:AddLine ('DET_DLG2', 84, .F.)
	oFLr24p2:AddCollumn('DET_DLG2E',100,.F.,'DET_DLG2')
	//RODAPE
	oFLr24p2:AddLine ('ROD_DLG2', 10, .F.)
	oFLr24p2:AddCollumn('ROD_DLG2',100,.F.,'ROD_DLG2')
	
	oPn24T2		:= oFLr24p2:GetColPanel('TIT_DLG2','TIT_DLG2')
	oPn24D2E	:= oFLr24p2:GetColPanel('DET_DLG2E','DET_DLG2')
	oPn24R2		:= oFLr24p2:GetColPanel('ROD_DLG2','ROD_DLG2')

	oPn24T2:FreeChildren()
	oPn24D2E:FreeChildren()
	oPn24R2:FreeChildren()

	@ 001,008 SAY OemToAnsi("Crédito Presumido Pis/Cofins - Mercado Interno")	FONT oFont003 SIZE 200,15 OF oPn24T2 PIXEL	

	@ 011,008 SAY OemToAnsi("TOTAIS")	FONT oFont002 SIZE 200,15 OF oPn24R2 PIXEL	

	@ 001,210 SAY OemToAnsi("Vl. Contábil")	FONT oFont002 SIZE 200,15 OF oPn24R2 PIXEL	
	@ 010,210 MSGET nTVlMI	SIZE 60,08 OF oPn24R2 PIXEL When .F. PICTURE '@E 9,999,999,999.99' // Total Vl. Contabil

	@ 001,280 SAY OemToAnsi("BC Pis")	FONT oFont002 SIZE 200,15 OF oPn24R2 PIXEL	
	@ 010,280 MSGET nTBCPMI	SIZE 60,08 OF oPn24R2 PIXEL When .F. PICTURE '@E 9,999,999,999.99' // Total BC Pis Merc Interno

	@ 001,345 SAY OemToAnsi("Vl. Pis")	FONT oFont002 SIZE 200,15 OF oPn24R2 PIXEL	
	@ 010,345 MSGET nTVlPMI	SIZE 60,08 OF oPn24R2 PIXEL When .F. PICTURE '@E 9,999,999,999.99' // Total Vl Pis Merc Interno

	@ 001,410 SAY OemToAnsi("BC Cofins")	FONT oFont002 SIZE 200,15 OF oPn24R2 PIXEL	
	@ 010,410 MSGET nTBCCMI	SIZE 60,08 OF oPn24R2 PIXEL When .F. PICTURE '@E 9,999,999,999.99' // Total BC Cofins Merc Interno

	@ 001,480 SAY OemToAnsi("Vl. Cofins")	FONT oFont002 SIZE 200,15 OF oPn24R2 PIXEL	
	@ 010,480 MSGET nTVlCMI	SIZE 60,08 OF oPn24R2 PIXEL When .F. PICTURE '@E 9,999,999,999.99' // Total Vl Cofins Merc Interno

	//Browser Mercado Interno
	oBrw24MI:= TcBrowse():New(010,050,150,150,,,,oPn24D2E,,,,,,,,,,,,.f.,,.t.,,.f.,,,,)

	oBrw24MI:AddColumn( TcColumn():New( "Filial"		, {|| aBrw24MI[oBrw24MI:nAt,23]}	, "@!"						,,,"LEFT"	,030,.f.,.f.,,,,.f.,) )     					
	oBrw24MI:AddColumn( TcColumn():New( "Cod. Forn."	, {|| aBrw24MI[oBrw24MI:nAt,01]}	, "@!"						,,,"LEFT"	,030,.f.,.f.,,,,.f.,) )     					
	oBrw24MI:AddColumn( TcColumn():New( "Loja Forn."	, {|| aBrw24MI[oBrw24MI:nAt,02]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )     					
	oBrw24MI:AddColumn( TcColumn():New( "Fornecedor"	, {|| aBrw24MI[oBrw24MI:nAt,03]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )     					
	oBrw24MI:AddColumn( TcColumn():New( "Cod. Produto"	, {|| aBrw24MI[oBrw24MI:nAt,04]}	, "@!"						,,,"LEFT"	,040,.f.,.f.,,,,.f.,) )     					
	oBrw24MI:AddColumn( TcColumn():New( "Produto"		, {|| aBrw24MI[oBrw24MI:nAt,05]}	, "@!"						,,,"LEFT"	,040,.f.,.f.,,,,.f.,) )     					
	oBrw24MI:AddColumn( TcColumn():New( "Dt. Entrada"	, {|| aBrw24MI[oBrw24MI:nAt,06]}	, ""						,,,"CENTER"	,030,.f.,.f.,,,,.f.,) )     					
	oBrw24MI:AddColumn( TcColumn():New( "Vl. Contabil"	, {|| aBrw24MI[oBrw24MI:nAt,07]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) )     					
	oBrw24MI:AddColumn( TcColumn():New( "CST Pis"		, {|| aBrw24MI[oBrw24MI:nAt,08]}	, "@!"						,,,"LEFT"	,025,.f.,.f.,,,,.f.,) )     					
	oBrw24MI:AddColumn( TcColumn():New( "Vl. BC. Pis"	, {|| aBrw24MI[oBrw24MI:nAt,09]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) )     					
	oBrw24MI:AddColumn( TcColumn():New( "Aliq. Pis"		, {|| aBrw24MI[oBrw24MI:nAt,10]}	, "@E 999,999,999.99"		,,,"RIGHT"	,030,.f.,.f.,,,,.f.,) )     					
	oBrw24MI:AddColumn( TcColumn():New( "Vl. Pis"		, {|| aBrw24MI[oBrw24MI:nAt,11]}	, "@E 999,999,999.99"		,,,"RIGHT"	,030,.f.,.f.,,,,.f.,) )     					
	oBrw24MI:AddColumn( TcColumn():New( "CST Cofins"	, {|| aBrw24MI[oBrw24MI:nAt,12]}	, "@!"						,,,"LEFT"	,025,.f.,.f.,,,,.f.,) )     					
	oBrw24MI:AddColumn( TcColumn():New( "VL_BC. Cofins"	, {|| aBrw24MI[oBrw24MI:nAt,13]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) )     					
	oBrw24MI:AddColumn( TcColumn():New( "Aliq. Cofins"	, {|| aBrw24MI[oBrw24MI:nAt,14]}	, "@E 999,999,999.99"		,,,"RIGHT"	,030,.f.,.f.,,,,.f.,) )     					
	oBrw24MI:AddColumn( TcColumn():New( "Vl. Cofins"	, {|| aBrw24MI[oBrw24MI:nAt,15]}	, "@E 999,999,999.99"		,,,"RIGHT"	,030,.f.,.f.,,,,.f.,) )     					
	oBrw24MI:AddColumn( TcColumn():New( "Nat. BC. Cred.", {|| aBrw24MI[oBrw24MI:nAt,16]}	, "@!"						,,,"LEFT"	,025,.f.,.f.,,,,.f.,) )     					
	oBrw24MI:AddColumn( TcColumn():New( "Ind.Orig.Cred.", {|| aBrw24MI[oBrw24MI:nAt,17]}	, "@!"						,,,"LEFT"	,025,.f.,.f.,,,,.f.,) )     					
	oBrw24MI:AddColumn( TcColumn():New( "CFOP"			, {|| aBrw24MI[oBrw24MI:nAt,18]}	, "@!"						,,,"LEFT"	,030,.f.,.f.,,,,.f.,) )     					
	oBrw24MI:AddColumn( TcColumn():New( "NCM"			, {|| aBrw24MI[oBrw24MI:nAt,19]}	, "@!"						,,,"LEFT"	,030,.f.,.f.,,,,.f.,) )     					
	oBrw24MI:AddColumn( TcColumn():New( "Nota Fiscal"	, {|| aBrw24MI[oBrw24MI:nAt,20]}	, "@!"						,,,"LEFT"	,040,.f.,.f.,,,,.f.,) )     					
	oBrw24MI:AddColumn( TcColumn():New( "Serie"			, {|| aBrw24MI[oBrw24MI:nAt,21]}	, "@!"						,,,"LEFT"	,030,.f.,.f.,,,,.f.,) )     					
	oBrw24MI:AddColumn( TcColumn():New( "Instr. Normat.", {|| aBrw24MI[oBrw24MI:nAt,22]}	, "@!"						,,,"LEFT"	,150,.f.,.f.,,,,.f.,) )     					

	oBrw24MI:SetArray(aBrw24MI)
	oBrw24MI:Align		:=	CONTROL_ALIGN_ALLCLIENT	
	oBrw24MI:bLine := {||{ 	aBrw24MI[oBrw24MI:nAt,23],;//Filial
							aBrw24MI[oBrw24MI:nAt,01],;//Cod. Forn.
							aBrw24MI[oBrw24MI:nAt,02],;//Loja Forn.
							aBrw24MI[oBrw24MI:nAt,03],;//Fornecedor
							aBrw24MI[oBrw24MI:nAt,04],;//Cod. Produto
							aBrw24MI[oBrw24MI:nAt,05],;//Produto
							aBrw24MI[oBrw24MI:nAt,06],;//Dt. Entrada
							Transform(aBrw24MI[oBrw24MI:nAT,07],'@E 999,999,999.99'),;//Vl. Contabil
							aBrw24MI[oBrw24MI:nAt,08],;//CST Pis
							Transform(aBrw24MI[oBrw24MI:nAT,09],'@E 9,999,999,999.99'),;//VL_BC_PIS
							Transform(aBrw24MI[oBrw24MI:nAT,10],'@E 9,999,999,999.99'),;//ALIQ_PIS
							Transform(aBrw24MI[oBrw24MI:nAT,11],'@E 9,999,999,999.99'),;//VL_PIS
							aBrw24MI[oBrw24MI:nAt,12],;//CST_COFINS
							Transform(aBrw24MI[oBrw24MI:nAT,13],'@E 9,999,999,999.99'),;//VL_BC_COFINS
							Transform(aBrw24MI[oBrw24MI:nAT,14],'@E 9,999,999,999.99'),;//ALIQ_COFINS
							Transform(aBrw24MI[oBrw24MI:nAT,15],'@E 9,999,999,999.99'),;//VL_COFINS
							aBrw24MI[oBrw24MI:nAt,16],;//NAT_BC_CRED
							aBrw24MI[oBrw24MI:nAt,17],;//IND_ORIG_CRED
							aBrw24MI[oBrw24MI:nAt,18],;//CFOP
							aBrw24MI[oBrw24MI:nAt,19],;//NCM
							aBrw24MI[oBrw24MI:nAt,20],;//NOTA FISCAL
							aBrw24MI[oBrw24MI:nAt,21],;//SERIE
							aBrw24MI[oBrw24MI:nAt,22],;//INSR.NORM.
							 } }
	
	////////////////////////////////////////////////////////////
	oFLr24p3:= FWLayer():New()
	oFLr24p3:Init( oFld024:aDialogs[3], .F., .T.) //MERCADO EXTERNO
	
	//TITULO
	oFLr24p3:AddLine ('TIT_DLG3', 6, .F.)
	oFLr24p3:AddCollumn('TIT_DLG3',100,.F.,'TIT_DLG3')
	//DETALHE
	oFLr24p3:AddLine ('DET_DLG3', 84, .F.)
	oFLr24p3:AddCollumn('DET_DLG3E',100,.F.,'DET_DLG3')
	//RODAPE
	oFLr24p3:AddLine ('ROD_DLG3', 10, .F.)
	oFLr24p3:AddCollumn('ROD_DLG3',100,.F.,'ROD_DLG3')
	
	oPn24T3		:= oFLr24p3:GetColPanel('TIT_DLG3','TIT_DLG3')
	oPn24D3E	:= oFLr24p3:GetColPanel('DET_DLG3E','DET_DLG3')
	oPn24R3		:= oFLr24p3:GetColPanel('ROD_DLG3','ROD_DLG3')

	oPn24T3:FreeChildren()
	oPn24D3E:FreeChildren()
	oPn24R3:FreeChildren()

	@ 001,008 SAY OemToAnsi("Crédito Presumido Pis/Cofins - Mercado Externo")	FONT oFont003 SIZE 200,15 OF oPn24T3 PIXEL	

	@ 011,008 SAY OemToAnsi("TOTAIS")	FONT oFont002 SIZE 200,15 OF oPn24R3 PIXEL	

	@ 001,210 SAY OemToAnsi("Vl. Contábil")	FONT oFont002 SIZE 200,15 OF oPn24R3 PIXEL	
	@ 010,210 MSGET nTVlME	SIZE 60,08 OF oPn24R3 PIXEL When .F. PICTURE '@E 9,999,999,999.99' // Total Vl. Contabil

	@ 001,280 SAY OemToAnsi("BC Pis")	FONT oFont002 SIZE 200,15 OF oPn24R3 PIXEL	
	@ 010,280 MSGET nTBCPME	SIZE 60,08 OF oPn24R3 PIXEL When .F. PICTURE '@E 9,999,999,999.99' // Total BC Pis Merc Interno

	@ 001,345 SAY OemToAnsi("Vl. Pis")	FONT oFont002 SIZE 200,15 OF oPn24R3 PIXEL	
	@ 010,345 MSGET nTVlPME	SIZE 60,08 OF oPn24R3 PIXEL When .F. PICTURE '@E 9,999,999,999.99' // Total Vl Pis Merc Interno

	@ 001,410 SAY OemToAnsi("BC Cofins")	FONT oFont002 SIZE 200,15 OF oPn24R3 PIXEL	
	@ 010,410 MSGET nTBCCME	SIZE 60,08 OF oPn24R3 PIXEL When .F. PICTURE '@E 9,999,999,999.99' // Total BC Cofins Merc Interno

	@ 001,480 SAY OemToAnsi("Vl. Cofins")	FONT oFont002 SIZE 200,15 OF oPn24R3 PIXEL	
	@ 010,480 MSGET nTVlCME	SIZE 60,08 OF oPn24R3 PIXEL When .F. PICTURE '@E 9,999,999,999.99' // Total Vl Cofins Merc Interno
	
	
	//Browser Projeção
	oBrw24ME:= TcBrowse():New(010,050,150,150,,,,oPn24D3E,,,,,,,,,,,,.f.,,.t.,,.f.,,,,)	
	oBrw24ME:AddColumn( TcColumn():New( "Filial"		, {|| aBrw24ME[oBrw24ME:nAt,23]}	, "@!"						,,,"LEFT"	,030,.f.,.f.,,,,.f.,) )     					
	oBrw24ME:AddColumn( TcColumn():New( "Cod. Forn."	, {|| aBrw24ME[oBrw24ME:nAt,01]}	, "@!"						,,,"LEFT"	,030,.f.,.f.,,,,.f.,) )     					
	oBrw24ME:AddColumn( TcColumn():New( "Loja Forn."	, {|| aBrw24ME[oBrw24ME:nAt,02]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )     					
	oBrw24ME:AddColumn( TcColumn():New( "Fornecedor"	, {|| aBrw24ME[oBrw24ME:nAt,03]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )     					
	oBrw24ME:AddColumn( TcColumn():New( "Cod. Produto"	, {|| aBrw24ME[oBrw24ME:nAt,04]}	, "@!"						,,,"LEFT"	,040,.f.,.f.,,,,.f.,) )     					
	oBrw24ME:AddColumn( TcColumn():New( "Produto"		, {|| aBrw24ME[oBrw24ME:nAt,05]}	, "@!"						,,,"LEFT"	,040,.f.,.f.,,,,.f.,) )     					
	oBrw24ME:AddColumn( TcColumn():New( "Dt. Entrada"	, {|| aBrw24ME[oBrw24ME:nAt,06]}	, ""						,,,"CENTER"	,030,.f.,.f.,,,,.f.,) )     					
	oBrw24ME:AddColumn( TcColumn():New( "Vl. Contabil"	, {|| aBrw24ME[oBrw24ME:nAt,07]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) )     					
	oBrw24ME:AddColumn( TcColumn():New( "CST Pis"		, {|| aBrw24ME[oBrw24ME:nAt,08]}	, "@!"						,,,"LEFT"	,025,.f.,.f.,,,,.f.,) )     					
	oBrw24ME:AddColumn( TcColumn():New( "Vl. BC. Pis"	, {|| aBrw24ME[oBrw24ME:nAt,09]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) )     					
	oBrw24ME:AddColumn( TcColumn():New( "Aliq. Pis"		, {|| aBrw24ME[oBrw24ME:nAt,10]}	, "@E 999,999,999.99"		,,,"RIGHT"	,030,.f.,.f.,,,,.f.,) )     					
	oBrw24ME:AddColumn( TcColumn():New( "Vl. Pis"		, {|| aBrw24ME[oBrw24ME:nAt,11]}	, "@E 999,999,999.99"		,,,"RIGHT"	,030,.f.,.f.,,,,.f.,) )     					
	oBrw24ME:AddColumn( TcColumn():New( "CST Cofins"	, {|| aBrw24ME[oBrw24ME:nAt,12]}	, "@!"						,,,"LEFT"	,025,.f.,.f.,,,,.f.,) )     					
	oBrw24ME:AddColumn( TcColumn():New( "VL_BC. Cofins"	, {|| aBrw24ME[oBrw24ME:nAt,13]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) )     					
	oBrw24ME:AddColumn( TcColumn():New( "Aliq. Cofins"	, {|| aBrw24ME[oBrw24ME:nAt,14]}	, "@E 999,999,999.99"		,,,"RIGHT"	,030,.f.,.f.,,,,.f.,) )     					
	oBrw24ME:AddColumn( TcColumn():New( "Vl. Cofins"	, {|| aBrw24ME[oBrw24ME:nAt,15]}	, "@E 999,999,999.99"		,,,"RIGHT"	,030,.f.,.f.,,,,.f.,) )     					
	oBrw24ME:AddColumn( TcColumn():New( "Nat. BC. Cred.", {|| aBrw24ME[oBrw24ME:nAt,16]}	, "@!"						,,,"LEFT"	,025,.f.,.f.,,,,.f.,) )     					
	oBrw24ME:AddColumn( TcColumn():New( "Ind.Orig.Cred.", {|| aBrw24ME[oBrw24ME:nAt,17]}	, "@!"						,,,"LEFT"	,025,.f.,.f.,,,,.f.,) )     					
	oBrw24ME:AddColumn( TcColumn():New( "CFOP"			, {|| aBrw24ME[oBrw24ME:nAt,18]}	, "@!"						,,,"LEFT"	,030,.f.,.f.,,,,.f.,) )     					
	oBrw24ME:AddColumn( TcColumn():New( "NCM"			, {|| aBrw24ME[oBrw24ME:nAt,19]}	, "@!"						,,,"LEFT"	,030,.f.,.f.,,,,.f.,) )     					
	oBrw24ME:AddColumn( TcColumn():New( "Nota Fiscal"	, {|| aBrw24ME[oBrw24ME:nAt,20]}	, "@!"						,,,"LEFT"	,040,.f.,.f.,,,,.f.,) )     					
	oBrw24ME:AddColumn( TcColumn():New( "Serie"			, {|| aBrw24ME[oBrw24ME:nAt,21]}	, "@!"						,,,"LEFT"	,030,.f.,.f.,,,,.f.,) )     					
	oBrw24ME:AddColumn( TcColumn():New( "Instr. Normat.", {|| aBrw24ME[oBrw24ME:nAt,22]}	, "@!"						,,,"LEFT"	,150,.f.,.f.,,,,.f.,) )     					

	oBrw24ME:SetArray(aBrw24ME)
	oBrw24ME:Align		:=	CONTROL_ALIGN_ALLCLIENT	
	oBrw24ME:bLine := {||{ 	aBrw24ME[oBrw24ME:nAt,23],;//Filial
							aBrw24ME[oBrw24ME:nAt,01],;//Cod. Forn.
							aBrw24ME[oBrw24ME:nAt,02],;//Loja Forn.
							aBrw24ME[oBrw24ME:nAt,03],;//Fornecedor
							aBrw24ME[oBrw24ME:nAt,04],;//Cod. Produto
							aBrw24ME[oBrw24ME:nAt,05],;//Produto
							aBrw24ME[oBrw24ME:nAt,06],;//Dt. Entrada
							Transform(aBrw24ME[oBrw24ME:nAT,07],'@E 999,999,999.99'),;//Vl. Contabil
							aBrw24ME[oBrw24ME:nAt,08],;//CST Pis
							Transform(aBrw24ME[oBrw24ME:nAT,09],'@E 9,999,999,999.99'),;//VL_BC_PIS
							Transform(aBrw24ME[oBrw24ME:nAT,10],'@E 9,999,999,999.99'),;//ALIQ_PIS
							Transform(aBrw24ME[oBrw24ME:nAT,11],'@E 9,999,999,999.99'),;//VL_PIS
							aBrw24ME[oBrw24ME:nAt,12],;//CST_COFINS
							Transform(aBrw24ME[oBrw24ME:nAT,13],'@E 9,999,999,999.99'),;//VL_BC_COFINS
							Transform(aBrw24ME[oBrw24ME:nAT,14],'@E 9,999,999,999.99'),;//ALIQ_COFINS
							Transform(aBrw24ME[oBrw24ME:nAT,15],'@E 9,999,999,999.99'),;//VL_COFINS
							aBrw24ME[oBrw24ME:nAt,16],;//NAT_BC_CRED
							aBrw24ME[oBrw24ME:nAt,17],;//IND_ORIG_CRED
							aBrw24ME[oBrw24ME:nAt,18],;//CFOP
							aBrw24ME[oBrw24ME:nAt,19],;//NCM
							aBrw24ME[oBrw24ME:nAt,20],;//NOTA FISCAL
							aBrw24ME[oBrw24ME:nAt,21],;//SERIE
							aBrw24ME[oBrw24ME:nAt,22],;//INSR.NORM.
							 } }
	////////////////////////////////////////////////////////////
	oFLr24p4:= FWLayer():New()
	oFLr24p4:Init( oFld024:aDialogs[4], .F., .T.) //PARAMETROS
	
	//TITULO
	oFLr24p4:AddLine ('TIT_DLG4', 6, .F.)
	oFLr24p4:AddCollumn('TIT_DLG4',100,.F.,'TIT_DLG4')
	//DETALHE
	oFLr24p4:AddLine ('DET_DLG4', 94, .F.)
	oFLr24p4:AddCollumn('DET_DLG4E',050,.F.,'DET_DLG4')
	oFLr24p4:AddCollumn('DET_DLG4D',050,.F.,'DET_DLG4')
	
	oPn24T4		:= oFLr24p4:GetColPanel('TIT_DLG4','TIT_DLG4')
	oPn24D4E	:= oFLr24p4:GetColPanel('DET_DLG4E','DET_DLG4')
	oPn24D4D	:= oFLr24p4:GetColPanel('DET_DLG4D','DET_DLG4')

	oPn24T4:FreeChildren()
	oPn24D4E:FreeChildren()
	oPn24D4D:FreeChildren()

	@ 001,008 SAY OemToAnsi("Crédito Presumido Pis/Cofins - Parâmetros")	FONT oFont003 SIZE 200,15 OF oPn24T4 PIXEL	

	@ 001,015 SAY OemToAnsi("Parâmetros Comuns (Mercado Interno e Externo)")		FONT oFont002 SIZE 200,15 OF oPn24D4E PIXEL
	
	@ 015,020 SAY OemToAnsi("MV_CPPCAGR")				FONT oFont002 SIZE 200,15 OF oPn24D4E PIXEL
	@ 014,080 MSGET cCPPCAGR	SIZE 60,08 OF oPn24D4E PIXEL When .F. PICTURE '' //'@!'
	@ 024,020 SAY OemToAnsi("Indica se ira processar credito presumido de PIS e Cofins conforme lei 12.058/2009 e Instrução")		FONT oFont001 SIZE 400,15 OF oPn24D4E PIXEL

	@ 036,020 SAY OemToAnsi("MV_CAJCPP")				FONT oFont002 SIZE 200,15 OF oPn24D4E PIXEL
	@ 035,080 MSGET cCAJCPPC	SIZE 60,08 OF oPn24D4E PIXEL When .F. PICTURE '@!'
	@ 045,020 SAY OemToAnsi("Informar o código que será utilizado no ajuste de credito presumido da lei 12.058/2009 que conforme tabela 4.3.8 da RFB")		FONT oFont001 SIZE 400,15 OF oPn24D4E PIXEL

	@ 057,020 SAY OemToAnsi("MV_#NCMCPR")				FONT oFont002 SIZE 200,15 OF oPn24D4E PIXEL
	@ 056,080 MSGET cXNCMCPR	SIZE 200,08 OF oPn24D4E PIXEL When .F. PICTURE '@!'
	@ 066,020 SAY OemToAnsi("Informar o NCM para cálculo da Receita Total, utilizado tanto no Mercado Interno quanto Externo")		FONT oFont001 SIZE 400,15 OF oPn24D4E PIXEL
	
	@ 080,020 SAY OemToAnsi("Parâmetros Específicos Mercado Interno")		FONT oFont002 SIZE 200,15 OF oPn24D4E PIXEL
	@ 094,020 SAY OemToAnsi("MV_#ACPPCI")			FONT oFont002 SIZE 200,15 OF oPn24D4E PIXEL
	@ 093,080 MSGET cXACPPCI	SIZE 60,08 OF oPn24D4E PIXEL When .F. PICTURE '@!'
	@ 103,020 SAY OemToAnsi("Informar a alíquota de Credito Presumido de PIS e Cofins, com base na lei 10925/2004")			FONT oFont001 SIZE 400,15 OF oPn24D4E PIXEL

	@ 115,020 SAY OemToAnsi("MV_#CSTCPI")			FONT oFont002 SIZE 200,15 OF oPn24D4E PIXEL
	@ 114,080 MSGET cXCSTCPI	SIZE 60,08 OF oPn24D4E PIXEL When .F. PICTURE '@!'
	@ 124,020 SAY OemToAnsi("CST que será escriturado no registro F100 para o cálculo de credito presumido referente ao Mercado Interno Art.8 da Lei 10.925/2004")			FONT oFont001 SIZE 400,15 OF oPn24D4E PIXEL

	@ 136,020 SAY OemToAnsi("MV_#INCPMI")			FONT oFont002 SIZE 200,15 OF oPn24D4E PIXEL
	@ 135,080 MSGET cXINCPMI	SIZE 200,08 OF oPn24D4E PIXEL When .F. PICTURE '@!'
	@ 145,020 SAY OemToAnsi("Informar a descrição que será utilizada no ajuste de Crédito Presumido Mercado Interno.")			FONT oFont001 SIZE 400,15 OF oPn24D4E PIXEL

	@ 157,020 SAY OemToAnsi("MV_#NCMEMB")			FONT oFont002 SIZE 200,15 OF oPn24D4E PIXEL
	@ 156,080 MSGET cXNCMEMB	SIZE 200,08 OF oPn24D4E PIXEL When .F. PICTURE '@!'
	@ 166,020 SAY OemToAnsi("NCM dos prod. Embutidos para cálculo das Receitas com Embutidos")			FONT oFont001 SIZE 400,15 OF oPn24D4E PIXEL

	@ 178,020 SAY OemToAnsi("MV_#CFCPMI")			FONT oFont002 SIZE 200,15 OF oPn24D4E PIXEL
	@ 177,080 MSGET cXCFCPMI	SIZE 200,08 OF oPn24D4E PIXEL When .F. PICTURE '@!'
	@ 187,020 SAY OemToAnsi("CFOP a serem considerados para filtrar as NF´s de Entrada com direito a crédito")			FONT oFont001 SIZE 400,15 OF oPn24D4E PIXEL


	@ 001,015 SAY OemToAnsi("Parâmetros Específicos Mercado Externo")		FONT oFont002 SIZE 200,15 OF oPn24D4D PIXEL
	@ 015,020 SAY OemToAnsi("MV_ACPPCAG")			FONT oFont002 SIZE 200,15 OF oPn24D4D PIXEL
	@ 014,080 MSGET cACPPCAG	SIZE 60,08 OF oPn24D4D PIXEL When .F. PICTURE '@!'
	@ 024,020 SAY OemToAnsi("Informar a alíquota de Credito Presumido de PIS e Cofins, com base na lei 12.058/2009 N RFB nº 977, de 14 novembro de 2009")			FONT oFont001 SIZE 400,15 OF oPn24D4D PIXEL

	@ 036,020 SAY OemToAnsi("MV_CSTPRES")			FONT oFont002 SIZE 200,15 OF oPn24D4D PIXEL
	@ 035,080 MSGET cCSTPRES	SIZE 60,08 OF oPn24D4D PIXEL When .F. PICTURE '@!'
	@ 045,020 SAY OemToAnsi("CST que sera escriturado no registro F100 para o cálculo de credito presumido conforme lei 12.058/2")			FONT oFont001 SIZE 400,15 OF oPn24D4D PIXEL

	@ 057,020 SAY OemToAnsi("MV_DAPCCPA")			FONT oFont002 SIZE 200,15 OF oPn24D4D PIXEL
	@ 056,080 MSGET cDAPCCPA	SIZE 200,08 OF oPn24D4D PIXEL When .F. PICTURE '@!'
	@ 066,020 SAY OemToAnsi("Informar a descrição que será utilizada no ajuste de credito presumido da lei 12.058/2009")			FONT oFont001 SIZE 400,15 OF oPn24D4D PIXEL

	@ 078,020 SAY OemToAnsi("MV_NCMCPPC")			FONT oFont002 SIZE 200,15 OF oPn24D4D PIXEL
	@ 077,080 MSGET cNCMCPPC	SIZE 200,08 OF oPn24D4D PIXEL When .F. PICTURE '@!'
	@ 087,020 SAY OemToAnsi("NCM de exportação que serão utilizados para a geração do credito presumido de PIS e COFINS conforme lei 12.058/2009")			FONT oFont001 SIZE 400,15 OF oPn24D4D PIXEL

	@ 099,020 SAY OemToAnsi("MV_#CPRCEP")			FONT oFont002 SIZE 200,15 OF oPn24D4D PIXEL
	@ 098,080 MSGET cXCPRCEP	SIZE 200,08 OF oPn24D4D PIXEL When .F. PICTURE '@!'
	@ 108,020 SAY OemToAnsi("CFOP a serem utilizados como Receita de Exportação.")										FONT oFont001 SIZE 400,15 OF oPn24D4D PIXEL

	@ 120,020 SAY OemToAnsi("MV_NCMCREP")			FONT oFont002 SIZE 200,15 OF oPn24D4D PIXEL
	@ 119,080 MSGET cNCMCREP	SIZE 200,08 OF oPn24D4D PIXEL When .F. PICTURE '@!'
	@ 129,020 SAY OemToAnsi("NCM dos prod. agropec. utilizados c/ insumos na fabricação de prod. destinado a alimentação humana  ou animal lei 12.058/2009")			FONT oFont001 SIZE 400,15 OF oPn24D4D PIXEL

	@ 141,020 SAY OemToAnsi("MV_#CFCPEX")			FONT oFont002 SIZE 200,15 OF oPn24D4D PIXEL
	@ 140,080 MSGET cXCFCPEX	SIZE 200,08 OF oPn24D4D PIXEL When .F. PICTURE '@!'
	@ 150,020 SAY OemToAnsi("CFOP a serem considerados para filtrar as NF´s de Entrada com direito a crédito")			FONT oFont001 SIZE 400,15 OF oPn24D4D PIXEL


	//INICIO Chamado n.040918 - Abel.Babini - Relatorio INSS para calculo da desoneração - 27/05/2019
	//--------------------------------------------------------------------------
	//ABA 25 - Relatório INSS Desoneração
	//--------------------------------------------------------------------------

	aFld25  := {cFld25p01,cFld25p02,cFld25p03,cFld25p04,cFld25p05}
	oFld025:=TFolder():New(1,1,aFld25,{},oFolder030:aDialogs[3/*25*/],,,, .T., .F.,aPosObj[2,4]-5,aPosObj[2,3]-55,)
	oFld025:aDialogs[1]:oFont :=oDlg:oFont //Resumo
	oFld025:aDialogs[2]:oFont :=oDlg:oFont //Consolidaçãp BLoco P100
	oFld025:aDialogs[3]:oFont :=oDlg:oFont //Detalhe
	oFld025:aDialogs[4]:oFont :=oDlg:oFont //Conferência Produtos
	oFld025:aDialogs[5]:oFont :=oDlg:oFont //Parametros

	////////////////////////////////////////////////////////////
	oFLr25p1:= FWLayer():New()
	oFLr25p1:Init( oFld025:aDialogs[1], .F., .T.) //RESUMO
	//TITULO
	oFLr25p1:AddLine ('TIT_DLG1', 6, .F.)
	oFLr25p1:AddCollumn('TIT_DLG1',100,.F.,'TIT_DLG1')
	//DETALHE
	oFLr25p1:AddLine ('DET_DLG1', 80, .F.)
	oFLr25p1:AddCollumn('DET_DLG1E',100,.F.,'DET_DLG1')
	//RODAPE
	oFLr25p1:AddLine ('ROD_DLG1', 14, .F.)
	oFLr25p1:AddCollumn('ROD_DLG1',50,.F.,'ROD_DLG1')
	oFLr25p1:AddCollumn('ROD_DLG2',50,.F.,'ROD_DLG1')
	
	oPn25T1		:= oFLr25p1:GetColPanel('TIT_DLG1','TIT_DLG1')
	oPn25D1E	:= oFLr25p1:GetColPanel('DET_DLG1E','DET_DLG1')
	oPn25R1		:= oFLr25p1:GetColPanel('ROD_DLG1','ROD_DLG1')
	oPn25R2		:= oFLr25p1:GetColPanel('ROD_DLG2','ROD_DLG1')

	oPn25T1:FreeChildren()
	oPn25D1E:FreeChildren()
	oPn25R1:FreeChildren()
	oPn25R2:FreeChildren()
	
	@ 001,008 SAY OemToAnsi("INSS Desoneração - Resumo")	FONT oFont003 SIZE 200,15 OF oPn25T1 PIXEL	
	
	//QUADRO DE RELATÓRIO
	@ 005,008 SAY OemToAnsi("OUTRAS OPÇÕES")	FONT oFont003 SIZE 200,15 OF oPn25R2 PIXEL
	@ 018,008 BUTTON OemToAnsi('Gera Relatório')	SIZE 42,13 FONT oDlg:oFont ACTION xRelBr25() OF oPn25R2 PIXEL //"Exportar Excel"

	IF Len(aBrw25Pr)>0
	    oTBitmap1 := TBitmap():New(05,01,30,30,,"FWSKIN_ALERT_ICO.PNG",.T.,oPn25R1,{||Alert("Complemento de Produtos com erro. Faça os ajustes necessários!")},,.F.,.F.,,,.F.,,.T.,,.F.)
        oTBitmap1:lAutoSize := .T.
	    @010,035 SAY OemToAnsi("ATENÇÃO: Existem produtos com erro no complemento (Cod. Ativ e INSS Patron.). Consulte aba Conf. Produtos!")	FONT oFont003 SIZE 200,15 OF oPn25R1 PIXEL
	ENDIF

	oBrw25Rs:= TcBrowse():New(010,050,150,150,,,,oPn25D1E,,,,,,,,,,,,.f.,,.t.,,.f.,,,,)	
	oBrw25Rs:AddColumn( TcColumn():New( "CFOP"			, {|| aBrw25Rs[oBrw25Rs:nAt,01]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )
	For nColBr25 = 1 To nQFIL
		fAddC25( nColBr25 )
	Next nColBr25
		
	oBrw25Rs:SetArray(aBrw25Rs)
	oBrw25Rs:Align		:=	CONTROL_ALIGN_ALLCLIENT	
	oBrw25Rs:bLine := {||{aBrw25Rs[oBrw25Rs:nAt]} } 	

	////////////////////////////////////////////////////////////
	oFLr25p2:= FWLayer():New()
	oFLr25p2:Init( oFld025:aDialogs[2], .F., .T.) //Consolidação Bloco P100
	
	//TITULO
	oFLr25p2:AddLine ('TIT_DLG2', 6, .F.)
	oFLr25p2:AddCollumn('TIT_DLG2',100,.F.,'TIT_DLG2')
	//DETALHE
	oFLr25p2:AddLine ('DET_DLG2', 94, .F.)
	oFLr25p2:AddCollumn('DET_DLG2E',100,.F.,'DET_DLG2')
	//RODAPE
	//oFLr25p2:AddLine ('ROD_DLG2', 10, .F.)
	//oFLr25p2:AddCollumn('ROD_DLG2',100,.F.,'ROD_DLG2')
	
	oPn25T2		:= oFLr25p2:GetColPanel('TIT_DLG2','TIT_DLG2')
	oPn25D2E	:= oFLr25p2:GetColPanel('DET_DLG2E','DET_DLG2')
	//oPn25R2		:= oFLr25p2:GetColPanel('ROD_DLG2','ROD_DLG2')

	oPn25T2:FreeChildren()
	oPn25D2E:FreeChildren()
	//oPn25R2:FreeChildren()

	@ 001,008 SAY OemToAnsi("INSS Desoneração - Consolidação Bloco P100")	FONT oFont003 SIZE 500,15 OF oPn25T2 PIXEL	
	oBrw25P1:= TcBrowse():New(010,050,150,150,,,,oPn25D2E,,,,,,,,,,,,.f.,,.t.,,.f.,,,,)
	
	oBrw25P1:AddColumn( TcColumn():New( ""			, {|| aBrw25P1[oBrw25P1:nAt,01]}	, "@!"						,,,"LEFT"	,200,.f.,.f.,,,,.f.,) )
	For nColBr25 = 1 To nQFIL+1
		fAddC25b( nColBr25 )
	Next nColBr25

	oBrw25P1:SetArray(aBrw25P1)
	oBrw25P1:Align		:=	CONTROL_ALIGN_ALLCLIENT	
	oBrw25P1:bLine := {||{aBrw25P1[oBrw25P1:nAt]} } 	
	
	////////////////////////////////////////////////////////////
	oFLr25p3:= FWLayer():New()
	oFLr25p3:Init( oFld025:aDialogs[3], .F., .T.) //Detalhe
	
	//TITULO
	oFLr25p3:AddLine ('T25_DLG2', 6, .F.)
	oFLr25p3:AddCollumn('T25_DLG2',100,.F.,'T25_DLG2')
	//DETALHE
	oFLr25p3:AddLine ('D25_DLG2', 94, .F.)
	oFLr25p3:AddCollumn('D25_DLG2E',100,.F.,'D25_DLG2')
	
	oPn25T3		:= oFLr25p3:GetColPanel('T25_DLG2','T25_DLG2')
	oPn25D3E	:= oFLr25p3:GetColPanel('D25_DLG2E','D25_DLG2')

	oPn25T3:FreeChildren()
	oPn25D3E:FreeChildren()

	@ 001,008 SAY OemToAnsi("INSS Desoneração - Detalhe")	FONT oFont003 SIZE 500,15 OF oPn25T3 PIXEL	
	
	//Browser Mercado Externo
	oBrw25Dt:= TcBrowse():New(010,050,150,150,,,,oPn25D3E,,,,,,,,,,,,.f.,,.t.,,.f.,,,,)	
	oBrw25Dt:AddColumn( TcColumn():New( "Filial"		, {|| aBrw25Dt[oBrw25Dt:nAt,01]}	, "@!"						,,,"LEFT"	,030,.f.,.f.,,,,.f.,) )     					
	oBrw25Dt:AddColumn( TcColumn():New( "Dt. Entrada"	, {|| aBrw25Dt[oBrw25Dt:nAt,02]}	, ""						,,,"CENTER"	,030,.f.,.f.,,,,.f.,) )     					
	oBrw25Dt:AddColumn( TcColumn():New( "Dt. Emissão"	, {|| aBrw25Dt[oBrw25Dt:nAt,03]}	, ""						,,,"CENTER"	,030,.f.,.f.,,,,.f.,) )     					
	oBrw25Dt:AddColumn( TcColumn():New( "Série"			, {|| aBrw25Dt[oBrw25Dt:nAt,04]}	, "@!"						,,,"LEFT"	,030,.f.,.f.,,,,.f.,) )     					
	oBrw25Dt:AddColumn( TcColumn():New( "Documento"		, {|| aBrw25Dt[oBrw25Dt:nAt,05]}	, "@!"						,,,"LEFT"	,030,.f.,.f.,,,,.f.,) )     					
	oBrw25Dt:AddColumn( TcColumn():New( "Cod. Clie."	, {|| aBrw25Dt[oBrw25Dt:nAt,06]}	, "@!"						,,,"LEFT"	,030,.f.,.f.,,,,.f.,) )     					
	oBrw25Dt:AddColumn( TcColumn():New( "Loja Clie."	, {|| aBrw25Dt[oBrw25Dt:nAt,07]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )     					
	oBrw25Dt:AddColumn( TcColumn():New( "Cliente"		, {|| aBrw25Dt[oBrw25Dt:nAt,08]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )     					
	oBrw25Dt:AddColumn( TcColumn():New( "Tipo Doc"		, {|| aBrw25Dt[oBrw25Dt:nAt,09]}	, "@!"						,,,"LEFT"	,040,.f.,.f.,,,,.f.,) )     					
	oBrw25Dt:AddColumn( TcColumn():New( "CFOP"			, {|| aBrw25Dt[oBrw25Dt:nAt,10]}	, "@!"						,,,"LEFT"	,040,.f.,.f.,,,,.f.,) )     					
	oBrw25Dt:AddColumn( TcColumn():New( "Vl. Contabil"	, {|| aBrw25Dt[oBrw25Dt:nAt,11]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) )     					
	oBrw25Dt:AddColumn( TcColumn():New( "Vl. ICMS Ret"	, {|| aBrw25Dt[oBrw25Dt:nAt,12]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) )     					
	oBrw25Dt:AddColumn( TcColumn():New( "Especie"		, {|| aBrw25Dt[oBrw25Dt:nAt,13]}	, "@!"						,,,"LEFT"	,040,.f.,.f.,,,,.f.,) )     					
	oBrw25Dt:AddColumn( TcColumn():New( "Observação"	, {|| aBrw25Dt[oBrw25Dt:nAt,14]}	, "@!"						,,,"LEFT"	,040,.f.,.f.,,,,.f.,) )     					
	oBrw25Dt:AddColumn( TcColumn():New( "Cod. Produto"	, {|| aBrw25Dt[oBrw25Dt:nAt,15]}	, "@!"						,,,"LEFT"	,040,.f.,.f.,,,,.f.,) )     					
	oBrw25Dt:AddColumn( TcColumn():New( "Produto"		, {|| aBrw25Dt[oBrw25Dt:nAt,16]}	, "@!"						,,,"LEFT"	,040,.f.,.f.,,,,.f.,) )     					
	oBrw25Dt:AddColumn( TcColumn():New( "TES"			, {|| aBrw25Dt[oBrw25Dt:nAt,17]}	, "@!"						,,,"LEFT"	,040,.f.,.f.,,,,.f.,) )     					

	oBrw25Dt:SetArray(aBrw25Dt)
	oBrw25Dt:Align		:=	CONTROL_ALIGN_ALLCLIENT	

	////////////////////////////////////////////////////////////
	oFLr25p4:= FWLayer():New()
	oFLr25p4:Init( oFld025:aDialogs[4], .F., .T.) //CONFERÊNCIA PRODUTOS
	
	//TITULO
	oFLr25p4:AddLine ('TIT_DLG4', 15, .F.)
	oFLr25p4:AddCollumn('TIT_DLG4',100,.F.,'TIT_DLG4')
	//DETALHE
	oFLr25p4:AddLine ('DET_DLG4', 70, .F.)
	oFLr25p4:AddCollumn('DET_DLG4E',100,.F.,'DET_DLG4')
	//RODAPE
	oFLr25p4:AddLine ('R25_DLG4', 15, .F.)
	oFLr25p4:AddCollumn('R25_DLG4',100,.F.,'R25_DLG4')
	
	oPn25T4		:= oFLr25p4:GetColPanel('TIT_DLG4','TIT_DLG4')
	oPn25D4E	:= oFLr25p4:GetColPanel('DET_DLG4E','DET_DLG4')
	oPn25R4		:= oFLr25p4:GetColPanel('R25_DLG4','R25_DLG4')

	oPn25T4:FreeChildren()
	oPn25D4E:FreeChildren()
	oPn25R4:FreeChildren()

	@ 001,008 SAY OemToAnsi("INSS Desoneração - Conferência Cadastro / Complemento Produtos")	FONT oFont003 SIZE 500,15 OF oPn25T4 PIXEL	
	//If Len(aBrw25Pr) > 0
	oBrw25Pr:= TcBrowse():New(010,050,150,150,,,,oPn25D4E,,,,,,,,,,,,.f.,,.t.,,.f.,,,,)	
	oBrw25Pr:AddColumn( TcColumn():New( "Filial"			, {|| aBrw25Pr[oBrw25Pr:nAt,02]}	, "@!"						,,,"LEFT"	,025,.f.,.f.,,,,.f.,) )
	oBrw25Pr:AddColumn( TcColumn():New( "Código"			, {|| aBrw25Pr[oBrw25Pr:nAt,03]}	, "@!"						,,,"LEFT"	,040,.f.,.f.,,,,.f.,) )
	oBrw25Pr:AddColumn( TcColumn():New( "Nome"				, {|| aBrw25Pr[oBrw25Pr:nAt,04]}	, "@!"						,,,"LEFT"	,080,.f.,.f.,,,,.f.,) )
	oBrw25Pr:AddColumn( TcColumn():New( "Cod.Atividade"		, {|| aBrw25Pr[oBrw25Pr:nAt,05]}	, "@!"						,,,"LEFT"	,040,.f.,.f.,,,,.f.,) )
	oBrw25Pr:AddColumn( TcColumn():New( "INSS Patron."		, {|| aBrw25Pr[oBrw25Pr:nAt,06]}	, "@!"						,,,"LEFT"	,040,.f.,.f.,,,,.f.,) )
	oBrw25Pr:SetArray(aBrw25Pr)
	oBrw25Pr:Align		:=	CONTROL_ALIGN_ALLCLIENT	
	//oBrw25Pr:bLine := {||{aBrw25Pr[oBrw25Pr:nAt]} } 	

	If Len(aBrw25Pr) > 0
		@ 005,408 SAY OemToAnsi("Ajusta Complemento dos Produtos? ")	FONT oFont003 SIZE 200,15 OF oPn25R4 PIXEL
		@ 018,408 BUTTON OemToAnsi('Ajuste')				SIZE 42,13 	FONT oDlg:oFont ACTION xAjBr25() OF oPn25R4 PIXEL //"Exportar Excel"

	Endif
	////////////////////////////////////////////////////////////
	oFLr25p5:= FWLayer():New()
	oFLr25p5:Init( oFld025:aDialogs[5], .F., .T.) //PARAMETROS
	
	//TITULO
	oFLr25p5:AddLine ('TIT_DLG4', 6, .F.)
	oFLr25p5:AddCollumn('TIT_DLG4',100,.F.,'TIT_DLG4')
	//DETALHE
	oFLr25p5:AddLine ('DET_DLG4', 94, .F.)
	oFLr25p5:AddCollumn('DET_DLG4E',050,.F.,'DET_DLG4')
	oFLr25p5:AddCollumn('DET_DLG4D',050,.F.,'DET_DLG4')
	
	oPn25T5		:= oFLr25p5:GetColPanel('TIT_DLG4','TIT_DLG4')
	oPn25D5E	:= oFLr25p5:GetColPanel('DET_DLG4E','DET_DLG4')
	oPn25D5D	:= oFLr25p5:GetColPanel('DET_DLG4D','DET_DLG4')

	oPn25T5:FreeChildren()
	oPn25D5E:FreeChildren()
	oPn25D5D:FreeChildren()

	@ 001,008 SAY OemToAnsi("INSS Desoneração - Parâmetros")	FONT oFont003 SIZE 200,15 OF oPn25T5 PIXEL	

	@ 001,015 SAY OemToAnsi("Parâmetros Comuns")		FONT oFont002 SIZE 200,15 OF oPn25D5E PIXEL
	
	@ 015,020 SAY OemToAnsi("MV_#CFINSS")				FONT oFont002 SIZE 200,15 OF oPn25D5E PIXEL
	@ 014,080 MSGET cP25A01	SIZE 200,08 OF oPn25D5E PIXEL When .F. PICTURE '@!'
	@ 024,020 SAY OemToAnsi("Indica os CFOPs que serão considerados para calculo das Receitas")		FONT oFont001 SIZE 400,15 OF oPn25D5E PIXEL

	@ 036,020 SAY OemToAnsi("MV_#CFICST")				FONT oFont002 SIZE 200,15 OF oPn25D5E PIXEL
	@ 035,080 MSGET cP25A02	SIZE 200,08 OF oPn25D5E PIXEL When .F. PICTURE '@!'
	@ 045,020 SAY OemToAnsi("Indica os CFOPs que serão considerados para calculo do ICMS ST")		FONT oFont001 SIZE 400,15 OF oPn25D5E PIXEL

	@ 057,020 SAY OemToAnsi("MV_#CFINEX")				FONT oFont002 SIZE 200,15 OF oPn25D5E PIXEL
	@ 056,080 MSGET cP25A03	SIZE 200,08 OF oPn25D5E PIXEL When .F. PICTURE '@!'
	@ 066,020 SAY OemToAnsi("Indica os CFOPs que serão considerados para calculo da Exportação")		FONT oFont001 SIZE 400,15 OF oPn25D5E PIXEL
	
	@ 078,020 SAY OemToAnsi("MV_#CFINDV")				FONT oFont002 SIZE 200,15 OF oPn25D5E PIXEL
	@ 077,080 MSGET cP25A04	SIZE 200,08 OF oPn25D5E PIXEL When .F. PICTURE '@!'
	@ 087,020 SAY OemToAnsi("Indica os CFOPs que serão considerados para deduzir as devoluções do calculo")		FONT oFont001 SIZE 400,15 OF oPn25D5E PIXEL

	@ 099,020 SAY OemToAnsi("MV_#CFIDV2")				FONT oFont002 SIZE 200,15 OF oPn25D5E PIXEL
	@ 098,080 MSGET cP25A05	SIZE 200,08 OF oPn25D5E PIXEL When .F. PICTURE '@!'
	@ 108,020 SAY OemToAnsi("Indica os CFOPs que serão considerados para anular as devoluções do calculo")		FONT oFont001 SIZE 400,15 OF oPn25D5E PIXEL

	@ 120,020 SAY OemToAnsi("MV_#CFINIM")				FONT oFont002 SIZE 200,15 OF oPn25D5E PIXEL
	@ 119,080 MSGET cP25A06	SIZE 200,08 OF oPn25D5E PIXEL When .F. PICTURE '@!'
	@ 129,020 SAY OemToAnsi("Indica os CFOPs que serão considerados para calculo dos Imobilizados")		FONT oFont001 SIZE 400,15 OF oPn25D5E PIXEL

	@ 141,020 SAY OemToAnsi("MV_#ALINSS")				FONT oFont002 SIZE 200,15 OF oPn25D5E PIXEL
	@ 140,080 MSGET cP25A07	SIZE 60,08 OF oPn25D5E PIXEL When .F. //PICTURE '@!'
	@ 150,020 SAY OemToAnsi("Indica a alíquota para cálculo do INSS")		FONT oFont001 SIZE 400,15 OF oPn25D5E PIXEL
	//FIM Chamado n.040918 - Abel.Babini - Relatorio INSS para calculo da desoneração - 27/05/2019
	
	// INICIO Chamado n.045022  - Abel.Babini - Relatorio Cred Pis/Cof Parcelado sobre Ativo - 10/06/2019
	//-----------------------------------
	//ABA 26 - CREDITO PIS/COFINS
	//-----------------------------------

	aFld26  := {cFld26p01,cFld26p02,cFld26p03}
	oFld026:=TFolder():New(1,1,aFld26,{},oFolder030:aDialogs[4/*25*/],,,, .T., .F.,aPosObj[2,4]-5,aPosObj[2,3]-55,)
	oFld026:aDialogs[1]:oFont :=oDlg:oFont //Resumo
	oFld026:aDialogs[2]:oFont :=oDlg:oFont //Projecao
	oFld026:aDialogs[3]:oFont :=oDlg:oFont //Detalhe
	//oFld026:aDialogs[4]:oFont :=oDlg:oFont //Parametros

	////////////////////////////////////////////////////////////
	oFLr26p1:= FWLayer():New()
	oFLr26p1:Init( oFld026:aDialogs[1], .F., .T.) //RESUMO

	//TITULO
	oFLr26p1:AddLine ('TIT_DLG1', 6, .F.)
	oFLr26p1:AddCollumn('TIT_DLG1',100,.F.,'TIT_DLG1')
	//DETALHE
	oFLr26p1:AddLine ('DET_DLG1', 79, .F.)
	oFLr26p1:AddCollumn('DET_DLG1E',50,.F.,'DET_DLG1')
	oFLr26p1:AddCollumn('DET_DLG1D',50,.F.,'DET_DLG1')
	//RODAPE
	oFLr26p1:AddLine ('ROD_DLG1', 15, .F.)
	oFLr26p1:AddCollumn('ROD_DLG1',100,.F.,'ROD_DLG1')
	
	oPn26T1		:= oFLr26p1:GetColPanel('TIT_DLG1','TIT_DLG1')
	oPn26D1E	:= oFLr26p1:GetColPanel('DET_DLG1E','DET_DLG1')
	oPn26D1D	:= oFLr26p1:GetColPanel('DET_DLG1D','DET_DLG1')
	oPn26R1		:= oFLr26p1:GetColPanel('ROD_DLG1','ROD_DLG1')

	oPn26T1:FreeChildren()
	oPn26D1E:FreeChildren()
	oPn26D1D:FreeChildren()
	oPn26R1:FreeChildren()

	//Cabecalho
	@ 001,008 SAY OemToAnsi("Crédito Pis/Cofins - Benfeitorias em Imobilizados - Resumo")	FONT oFont003 SIZE 400,15 OF oPn26T1 PIXEL	
	
	@ 001,008 SAY OemToAnsi("Pis")		FONT oFont002 SIZE 200,15 OF oPn26D1E PIXEL	
	@ 001,008 SAY OemToAnsi("Cofins")	FONT oFont002 SIZE 200,15 OF oPn26D1D PIXEL	

	@ 011,015 SAY OemToAnsi("Quantidade de Itens")		FONT oFont001 SIZE 200,15 OF oPn26D1E PIXEL
	@ 010,120 MSGET nQItens	SIZE 60,08 OF oPn26D1E PIXEL When .F. PICTURE '@E 9,999,999,999'

	@ 026,015 SAY OemToAnsi("Total Valor Original M1")		FONT oFont001 SIZE 200,15 OF oPn26D1E PIXEL
	@ 025,120 MSGET nVlTOrig	SIZE 60,08 OF oPn26D1E PIXEL When .F. PICTURE '@E 9,999,999,999.99'

	@ 041,015 SAY OemToAnsi("Total de Crédito Disponível")		FONT oFont001 SIZE 200,15 OF oPn26D1E PIXEL
	@ 040,120 MSGET nVlCPT	SIZE 60,08 OF oPn26D1E PIXEL When .F. PICTURE '@E 9,999,999,999.99'

	//@ 056,015 SAY OemToAnsi("Total Vl. Original")				FONT oFont001 SIZE 200,15 OF oPn26D1E PIXEL
	//@ 055,120 MSGET nTVlMI	SIZE 60,08 OF oPn26D1E PIXEL When .F. PICTURE '@E 9,999,999,999.99' // Total Vl. Contabil

	@ 071,015 SAY OemToAnsi("Total Crédito no Mês - Pis")				FONT oFont002 SIZE 200,15 OF oPn26D1E PIXEL
	@ 070,120 MSGET nTPMes	SIZE 60,08 OF oPn26D1E PIXEL When .F. PICTURE '@E 9,999,999,999.99' // Total Vl Pis Merc Interno
	
	@ 067,011 TO 082,185 OF oPn26D1E PIXEL
	

	@ 011,015 SAY OemToAnsi("Quantidade de Itens")		FONT oFont001 SIZE 200,15 OF oPn26D1D PIXEL
	@ 010,120 MSGET nQItens	SIZE 60,08 OF oPn26D1D PIXEL When .F. PICTURE '@E 9,999,999,999'

	@ 026,015 SAY OemToAnsi("Total Valor Original M1")		FONT oFont001 SIZE 200,15 OF oPn26D1D PIXEL
	@ 025,120 MSGET nVlTOrig	SIZE 60,08 OF oPn26D1D PIXEL When .F. PICTURE '@E 9,999,999,999.99'

	@ 041,015 SAY OemToAnsi("Total de Crédito Disponível")		FONT oFont001 SIZE 200,15 OF oPn26D1D PIXEL
	@ 040,120 MSGET nVlCCT	SIZE 60,08 OF oPn26D1D PIXEL When .F. PICTURE '@E 9,999,999,999.99'

	//@ 056,015 SAY OemToAnsi("Total Vl. Original")				FONT oFont001 SIZE 200,15 OF oPn26D1D PIXEL
	//@ 055,120 MSGET nTVlMI	SIZE 60,08 OF oPn26D1D PIXEL When .F. PICTURE '@E 9,999,999,999.99' // Total Vl. Contabil

	@ 071,015 SAY OemToAnsi("Total Crédito no Mês - Cofins")				FONT oFont002 SIZE 200,15 OF oPn26D1D PIXEL
	@ 070,120 MSGET nTCMes	SIZE 60,08 OF oPn26D1D PIXEL When .F. PICTURE '@E 9,999,999,999.99' // Total Vl Pis Merc Interno
	
	@ 067,011 TO 082,185 OF oPn26D1D PIXEL
	

	//QUADRO DE RELATÓRIO
	@ 001,508 SAY OemToAnsi("OUTRAS OPÇÕES")		SIZE 200,15	FONT oFont003 						OF oPn26R1 PIXEL
	@ 013,508 BUTTON OemToAnsi('Gera Relatório')	SIZE 42,13	FONT oDlg:oFont ACTION xRelBr26()	OF oPn26R1 PIXEL //"Exportar Excel"

	////////////////////////////////////////////////////////////
	oFLr26p2:= FWLayer():New()
	oFLr26p2:Init( oFld026:aDialogs[2], .F., .T.) //Projeção
	
	//TITULO PIS
	oFLr26p2:AddLine ('TIT_DLG2', 6, .F.)
	oFLr26p2:AddCollumn('TIT_DLG2',100,.F.,'TIT_DLG2')
	//DETALHE PIS
	oFLr26p2:AddLine ('DET_DLG2', 44, .F.)
	oFLr26p2:AddCollumn('DET_DLG2E',100,.F.,'DET_DLG2')
	//TITULO PIS
	oFLr26p2:AddLine ('TIT2_DLG2', 6, .F.)
	oFLr26p2:AddCollumn('TIT2_DLG2',100,.F.,'TIT2_DLG2')
	//DETALHE COFINS
	oFLr26p2:AddLine ('DET2_DLG2', 44, .F.)
	oFLr26p2:AddCollumn('DET2_DLG2E',100,.F.,'DET2_DLG2')

	//RODAPE
	//oFLr25p2:AddLine ('ROD_DLG2', 10, .F.)
	//oFLr25p2:AddCollumn('ROD_DLG2',100,.F.,'ROD_DLG2')
	
	oPn26T2		:= oFLr26p2:GetColPanel('TIT_DLG2','TIT_DLG2')
	oPn26D2E	:= oFLr26p2:GetColPanel('DET_DLG2E','DET_DLG2')
	oPn26T2B	:= oFLr26p2:GetColPanel('TIT2_DLG2','TIT2_DLG2')
	oPn26D2B	:= oFLr26p2:GetColPanel('DET2_DLG2E','DET2_DLG2')
	//oPn25R2		:= oFLr25p2:GetColPanel('ROD_DLG2','ROD_DLG2')

	oPn26T2:FreeChildren()
	oPn26D2E:FreeChildren()
	oPn26T2B:FreeChildren()
	oPn26D2B:FreeChildren()
	//oPn25R2:FreeChildren()

	//PIS
	@ 001,008 SAY OemToAnsi("Projeção do Crédito Pis - Benfeitorias em Imobilizados")	FONT oFont003 SIZE 500,15 OF oPn26T2 PIXEL	
	oBrw26Pr:= TcBrowse():New(010,050,150,150,,,,oPn26D2E,,,,,,,,,,,,.f.,,.t.,,.f.,,,,)

	oBrw26Pr:AddColumn( TcColumn():New( "Filial"			, {|| aBrw26Pr[oBrw26Pr:nAt,01]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )
	oBrw26Pr:AddColumn( TcColumn():New( "C.Base"			, {|| aBrw26Pr[oBrw26Pr:nAt,02]}	, "@!"						,,,"LEFT"	,030,.f.,.f.,,,,.f.,) )
	oBrw26Pr:AddColumn( TcColumn():New( "Item"				, {|| aBrw26Pr[oBrw26Pr:nAt,03]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )
	oBrw26Pr:AddColumn( TcColumn():New( "Serie NF"		, {|| aBrw26Pr[oBrw26Pr:nAt,04]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )
	oBrw26Pr:AddColumn( TcColumn():New( "Nota Fiscal"	, {|| aBrw26Pr[oBrw26Pr:nAt,05]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )
	oBrw26Pr:AddColumn( TcColumn():New( "Item NF"			, {|| aBrw26Pr[oBrw26Pr:nAt,06]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )
	oBrw26Pr:AddColumn( TcColumn():New( "Descrição"		, {|| aBrw26Pr[oBrw26Pr:nAt,07]}	, "@!"						,,,"LEFT"	,060,.f.,.f.,,,,.f.,) )
	oBrw26Pr:AddColumn( TcColumn():New( "Fornecedor"	, {|| aBrw26Pr[oBrw26Pr:nAt,08]}	, "@!"						,,,"LEFT"	,060,.f.,.f.,,,,.f.,) )
	oBrw26Pr:AddColumn( TcColumn():New( "Dt. Aquisição", {|| aBrw26Pr[oBrw26Pr:nAt,09]}	, "@!"						,,,"LEFT"	,030,.f.,.f.,,,,.f.,) )
	oBrw26Pr:AddColumn( TcColumn():New( "Tipo"				, {|| aBrw26Pr[oBrw26Pr:nAt,10]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )
	oBrw26Pr:AddColumn( TcColumn():New( "Base Calc. Mes", {|| aBrw26Pr[oBrw26Pr:nAt,11]}, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 
	oBrw26Pr:AddColumn( TcColumn():New( "Vl.Cred.Total", {|| aBrw26Pr[oBrw26Pr:nAt,12]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 
	oBrw26Pr:AddColumn( TcColumn():New(aNomeMes[1]		, {|| aBrw26Pr[oBrw26Pr:nAt,13]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 		
	oBrw26Pr:AddColumn( TcColumn():New(aNomeMes[2]		, {|| aBrw26Pr[oBrw26Pr:nAt,14]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 		
	oBrw26Pr:AddColumn( TcColumn():New(aNomeMes[3]		, {|| aBrw26Pr[oBrw26Pr:nAt,15]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 		
	oBrw26Pr:AddColumn( TcColumn():New(aNomeMes[4]		, {|| aBrw26Pr[oBrw26Pr:nAt,16]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 		
	oBrw26Pr:AddColumn( TcColumn():New(aNomeMes[5]		, {|| aBrw26Pr[oBrw26Pr:nAt,17]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 		
	oBrw26Pr:AddColumn( TcColumn():New(aNomeMes[6]		, {|| aBrw26Pr[oBrw26Pr:nAt,18]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 		
	oBrw26Pr:AddColumn( TcColumn():New(aNomeMes[7]		, {|| aBrw26Pr[oBrw26Pr:nAt,19]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 		
	oBrw26Pr:AddColumn( TcColumn():New(aNomeMes[8]		, {|| aBrw26Pr[oBrw26Pr:nAt,20]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 		
	oBrw26Pr:AddColumn( TcColumn():New(aNomeMes[9]		, {|| aBrw26Pr[oBrw26Pr:nAt,21]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 		
	oBrw26Pr:AddColumn( TcColumn():New(aNomeMes[10]		, {|| aBrw26Pr[oBrw26Pr:nAt,22]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 		
	oBrw26Pr:AddColumn( TcColumn():New(aNomeMes[11]		, {|| aBrw26Pr[oBrw26Pr:nAt,23]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 		
	oBrw26Pr:AddColumn( TcColumn():New(aNomeMes[12]		, {|| aBrw26Pr[oBrw26Pr:nAt,24]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 		
	oBrw26Pr:AddColumn( TcColumn():New(aNomeMes[13]		, {|| aBrw26Pr[oBrw26Pr:nAt,25]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 		
	oBrw26Pr:AddColumn( TcColumn():New(aNomeMes[14]		, {|| aBrw26Pr[oBrw26Pr:nAt,26]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 		
	oBrw26Pr:AddColumn( TcColumn():New(aNomeMes[15]		, {|| aBrw26Pr[oBrw26Pr:nAt,27]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 		
	oBrw26Pr:AddColumn( TcColumn():New(aNomeMes[16]		, {|| aBrw26Pr[oBrw26Pr:nAt,28]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 		
	oBrw26Pr:AddColumn( TcColumn():New(aNomeMes[17]		, {|| aBrw26Pr[oBrw26Pr:nAt,29]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 		
	oBrw26Pr:AddColumn( TcColumn():New(aNomeMes[18]		, {|| aBrw26Pr[oBrw26Pr:nAt,30]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 		
	oBrw26Pr:AddColumn( TcColumn():New(aNomeMes[19]		, {|| aBrw26Pr[oBrw26Pr:nAt,31]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 		
	oBrw26Pr:AddColumn( TcColumn():New(aNomeMes[20]		, {|| aBrw26Pr[oBrw26Pr:nAt,32]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 		
	oBrw26Pr:AddColumn( TcColumn():New(aNomeMes[21]		, {|| aBrw26Pr[oBrw26Pr:nAt,33]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 		
	oBrw26Pr:AddColumn( TcColumn():New(aNomeMes[22]		, {|| aBrw26Pr[oBrw26Pr:nAt,34]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) )
	oBrw26Pr:AddColumn( TcColumn():New(aNomeMes[23]		, {|| aBrw26Pr[oBrw26Pr:nAt,35]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) )
	oBrw26Pr:AddColumn( TcColumn():New(aNomeMes[24]		, {|| aBrw26Pr[oBrw26Pr:nAt,36]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) )	
	//
	oBrw26Pr:AddColumn( TcColumn():New( "Total Disponível"	, {|| aBrw26Pr[oBrw26Pr:nAt,37]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 

	oBrw26Pr:SetArray(aBrw26Pr)
	oBrw26Pr:Align		:=	CONTROL_ALIGN_ALLCLIENT	
	oBrw26Pr:bLine := {||{aBrw26Pr[oBrw26Pr:nAt]} } 	

	//COFINS
	@ 001,008 SAY OemToAnsi("Projeção do Crédito Cofins - Benfeitorias em Imobilizados")	FONT oFont003 SIZE 500,15 OF oPn26T2B PIXEL	
	oBrw26Cr:= TcBrowse():New(010,050,150,150,,,,oPn26D2B,,,,,,,,,,,,.f.,,.t.,,.f.,,,,)

	oBrw26Cr:AddColumn( TcColumn():New( "Filial"			, {|| aBrw26Cr[oBrw26Cr:nAt,01]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )
	oBrw26Cr:AddColumn( TcColumn():New( "C.Base"			, {|| aBrw26Cr[oBrw26Cr:nAt,02]}	, "@!"						,,,"LEFT"	,030,.f.,.f.,,,,.f.,) )
	oBrw26Cr:AddColumn( TcColumn():New( "Item"				, {|| aBrw26Cr[oBrw26Cr:nAt,03]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )
	oBrw26Cr:AddColumn( TcColumn():New( "Serie NF"		, {|| aBrw26Cr[oBrw26Cr:nAt,04]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )
	oBrw26Cr:AddColumn( TcColumn():New( "Nota Fiscal"	, {|| aBrw26Cr[oBrw26Cr:nAt,05]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )
	oBrw26Cr:AddColumn( TcColumn():New( "Item NF"			, {|| aBrw26Cr[oBrw26Cr:nAt,06]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )
	oBrw26Cr:AddColumn( TcColumn():New( "Descrição"			, {|| aBrw26Cr[oBrw26Cr:nAt,07]}	, "@!"						,,,"LEFT"	,060,.f.,.f.,,,,.f.,) )
	oBrw26Cr:AddColumn( TcColumn():New( "Fornecedor"		, {|| aBrw26Cr[oBrw26Cr:nAt,08]}	, "@!"						,,,"LEFT"	,060,.f.,.f.,,,,.f.,) )
	oBrw26Cr:AddColumn( TcColumn():New( "Dt. Aquisição"		, {|| aBrw26Cr[oBrw26Cr:nAt,09]}	, "@!"						,,,"LEFT"	,030,.f.,.f.,,,,.f.,) )
	oBrw26Cr:AddColumn( TcColumn():New( "Tipo"				, {|| aBrw26Cr[oBrw26Cr:nAt,10]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )
	oBrw26Cr:AddColumn( TcColumn():New( "Base Calc. Mes"	, {|| aBrw26Cr[oBrw26Cr:nAt,11]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 
	oBrw26Cr:AddColumn( TcColumn():New( "Vl.Cred.Total"		, {|| aBrw26Cr[oBrw26Cr:nAt,12]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 
	oBrw26Cr:AddColumn( TcColumn():New(aNomeMes[1]		, {|| aBrw26Cr[oBrw26Cr:nAt,13]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 		
	oBrw26Cr:AddColumn( TcColumn():New(aNomeMes[2]		, {|| aBrw26Cr[oBrw26Cr:nAt,14]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 		
	oBrw26Cr:AddColumn( TcColumn():New(aNomeMes[3]		, {|| aBrw26Cr[oBrw26Cr:nAt,15]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 		
	oBrw26Cr:AddColumn( TcColumn():New(aNomeMes[4]		, {|| aBrw26Cr[oBrw26Cr:nAt,16]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 		
	oBrw26Cr:AddColumn( TcColumn():New(aNomeMes[5]		, {|| aBrw26Cr[oBrw26Cr:nAt,17]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 		
	oBrw26Cr:AddColumn( TcColumn():New(aNomeMes[6]		, {|| aBrw26Cr[oBrw26Cr:nAt,18]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 		
	oBrw26Cr:AddColumn( TcColumn():New(aNomeMes[7]		, {|| aBrw26Cr[oBrw26Cr:nAt,19]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 		
	oBrw26Cr:AddColumn( TcColumn():New(aNomeMes[8]		, {|| aBrw26Cr[oBrw26Cr:nAt,20]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 		
	oBrw26Cr:AddColumn( TcColumn():New(aNomeMes[9]		, {|| aBrw26Cr[oBrw26Cr:nAt,21]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 		
	oBrw26Cr:AddColumn( TcColumn():New(aNomeMes[10]		, {|| aBrw26Cr[oBrw26Cr:nAt,22]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 		
	oBrw26Cr:AddColumn( TcColumn():New(aNomeMes[11]		, {|| aBrw26Cr[oBrw26Cr:nAt,23]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 		
	oBrw26Cr:AddColumn( TcColumn():New(aNomeMes[12]		, {|| aBrw26Cr[oBrw26Cr:nAt,24]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 		
	oBrw26Cr:AddColumn( TcColumn():New(aNomeMes[13]		, {|| aBrw26Cr[oBrw26Cr:nAt,25]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 		
	oBrw26Cr:AddColumn( TcColumn():New(aNomeMes[14]		, {|| aBrw26Cr[oBrw26Cr:nAt,26]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 		
	oBrw26Cr:AddColumn( TcColumn():New(aNomeMes[15]		, {|| aBrw26Cr[oBrw26Cr:nAt,27]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 		
	oBrw26Cr:AddColumn( TcColumn():New(aNomeMes[16]		, {|| aBrw26Cr[oBrw26Cr:nAt,28]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 		
	oBrw26Cr:AddColumn( TcColumn():New(aNomeMes[17]		, {|| aBrw26Cr[oBrw26Cr:nAt,29]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 		
	oBrw26Cr:AddColumn( TcColumn():New(aNomeMes[18]		, {|| aBrw26Cr[oBrw26Cr:nAt,30]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 		
	oBrw26Cr:AddColumn( TcColumn():New(aNomeMes[19]		, {|| aBrw26Cr[oBrw26Cr:nAt,31]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 		
	oBrw26Cr:AddColumn( TcColumn():New(aNomeMes[20]		, {|| aBrw26Cr[oBrw26Cr:nAt,32]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 		
	oBrw26Cr:AddColumn( TcColumn():New(aNomeMes[21]		, {|| aBrw26Cr[oBrw26Cr:nAt,33]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 		
	oBrw26Cr:AddColumn( TcColumn():New(aNomeMes[22]		, {|| aBrw26Cr[oBrw26Cr:nAt,34]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) )
	oBrw26Cr:AddColumn( TcColumn():New(aNomeMes[23]		, {|| aBrw26Cr[oBrw26Cr:nAt,35]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) )
	oBrw26Cr:AddColumn( TcColumn():New(aNomeMes[24]		, {|| aBrw26Cr[oBrw26Cr:nAt,36]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) )	
	//
	oBrw26cr:AddColumn( TcColumn():New( "Total Disponível"	, {|| aBrw26Cr[oBrw26Cr:nAt,37]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 

	oBrw26Cr:SetArray(aBrw26Cr)
	oBrw26Cr:Align		:=	CONTROL_ALIGN_ALLCLIENT	
	oBrw26Cr:bLine := {||{aBrw26Cr[oBrw26Cr:nAt]} } 	

	////////////////////////////////////////////////////////////
	oFLr26p3:= FWLayer():New()
	oFLr26p3:Init( oFld026:aDialogs[3], .F., .T.) //Detalhe
	
	//TITULO
	oFLr26p3:AddLine ('TIT_DLG2', 6, .F.)
	oFLr26p3:AddCollumn('TIT_DLG2',100,.F.,'TIT_DLG2')
	//DETALHE
	oFLr26p3:AddLine ('DET_DLG2', 94, .F.)
	oFLr26p3:AddCollumn('DET_DLG2E',100,.F.,'DET_DLG2')
	//RODAPE
	//oFLr25p2:AddLine ('ROD_DLG2', 10, .F.)
	//oFLr25p2:AddCollumn('ROD_DLG2',100,.F.,'ROD_DLG2')
	
	oPn26T3		:= oFLr26p3:GetColPanel('TIT_DLG2','TIT_DLG2')
	oPn26D3E	:= oFLr26p3:GetColPanel('DET_DLG2E','DET_DLG2')
	//oPn25R2		:= oFLr25p2:GetColPanel('ROD_DLG2','ROD_DLG2')

	oPn26T3:FreeChildren()
	oPn26D3E:FreeChildren()
	//oPn25R2:FreeChildren()

	@ 001,008 SAY OemToAnsi("Detalhes do Crédito Pis/Cofins - Benfeitorias em Imobilizados")	FONT oFont003 SIZE 500,15 OF oPn26T3 PIXEL	
	oBrw26Dt:= TcBrowse():New(010,050,150,150,,,,oPn26D3E,,,,,,,,,,,,.f.,,.t.,,.f.,,,,)

	oBrw26Dt:AddColumn( TcColumn():New( "Filial"			, {|| aBrw26Dt[oBrw26Dt:nAt,01]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )
	oBrw26Dt:AddColumn( TcColumn():New( "C.Base"			, {|| aBrw26Dt[oBrw26Dt:nAt,02]}	, "@!"						,,,"LEFT"	,030,.f.,.f.,,,,.f.,) )
	oBrw26Dt:AddColumn( TcColumn():New( "Item"				, {|| aBrw26Dt[oBrw26Dt:nAt,03]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )
	oBrw26Dt:AddColumn( TcColumn():New( "Descrição"			, {|| aBrw26Dt[oBrw26Dt:nAt,04]}	, "@!"						,,,"LEFT"	,060,.f.,.f.,,,,.f.,) )
	oBrw26Dt:AddColumn( TcColumn():New( "Cod.Forn."			, {|| aBrw26Dt[oBrw26Dt:nAt,12]}	, "@!"						,,,"LEFT"	,030,.f.,.f.,,,,.f.,) )
	oBrw26Dt:AddColumn( TcColumn():New( "Loja"				, {|| aBrw26Dt[oBrw26Dt:nAt,13]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )
	oBrw26Dt:AddColumn( TcColumn():New( "Fornecedor"		, {|| aBrw26Dt[oBrw26Dt:nAt,32]}	, "@!"						,,,"LEFT"	,060,.f.,.f.,,,,.f.,) )
	oBrw26Dt:AddColumn( TcColumn():New( "Dt. Aquisição"		, {|| aBrw26Dt[oBrw26Dt:nAt,05]}	, "@!"						,,,"LEFT"	,030,.f.,.f.,,,,.f.,) )
	oBrw26Dt:AddColumn( TcColumn():New( "Vl.Orig.M1"		, {|| aBrw26Dt[oBrw26Dt:nAt,31]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 
	oBrw26Dt:AddColumn( TcColumn():New( "Cod.BC Cred"		, {|| aBrw26Dt[oBrw26Dt:nAt,28]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )
	oBrw26Dt:AddColumn( TcColumn():New( "CST Pis"			, {|| aBrw26Dt[oBrw26Dt:nAt,24]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )
	oBrw26Dt:AddColumn( TcColumn():New( "Aliq. Pis"			, {|| aBrw26Dt[oBrw26Dt:nAt,25]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )
	oBrw26Dt:AddColumn( TcColumn():New( "CST Cofins"		, {|| aBrw26Dt[oBrw26Dt:nAt,26]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )
	oBrw26Dt:AddColumn( TcColumn():New( "Aliq. Cofins"		, {|| aBrw26Dt[oBrw26Dt:nAt,27]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )
	oBrw26Dt:AddColumn( TcColumn():New( "Base Pis/Cofins"	, {|| aBrw26Dt[oBrw26Dt:nAt,29]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )
	oBrw26Dt:AddColumn( TcColumn():New( "Parcelas"			, {|| aBrw26Dt[oBrw26Dt:nAt,06]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )
	oBrw26Dt:AddColumn( TcColumn():New( "Meses Ja Utilizados", {|| aBrw26Dt[oBrw26Dt:nAt,07]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )
	oBrw26Dt:AddColumn( TcColumn():New( "Serie NF"			, {|| aBrw26Dt[oBrw26Dt:nAt,14]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )
	oBrw26Dt:AddColumn( TcColumn():New( "Nota Fiscal"		, {|| aBrw26Dt[oBrw26Dt:nAt,15]}	, "@!"						,,,"LEFT"	,030,.f.,.f.,,,,.f.,) )
	oBrw26Dt:AddColumn( TcColumn():New( "Iten NF"			, {|| aBrw26Dt[oBrw26Dt:nAt,16]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )
	oBrw26Dt:AddColumn( TcColumn():New( "Espécie NF"		, {|| aBrw26Dt[oBrw26Dt:nAt,17]}	, "@!"						,,,"LEFT"	,030,.f.,.f.,,,,.f.,) )
	oBrw26Dt:AddColumn( TcColumn():New( "Projeto"			, {|| aBrw26Dt[oBrw26Dt:nAt,18]}	, "@!"						,,,"LEFT"	,030,.f.,.f.,,,,.f.,) )
	oBrw26Dt:AddColumn( TcColumn():New( "Qtd.Itens"			, {|| aBrw26Dt[oBrw26Dt:nAt,08]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 
	oBrw26Dt:AddColumn( TcColumn():New( "Baixa"				, {|| aBrw26Dt[oBrw26Dt:nAt,09]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )
	oBrw26Dt:AddColumn( TcColumn():New( "Chapa"				, {|| aBrw26Dt[oBrw26Dt:nAt,10]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )
	oBrw26Dt:AddColumn( TcColumn():New( "Grupo"				, {|| aBrw26Dt[oBrw26Dt:nAt,11]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )
	oBrw26Dt:AddColumn( TcColumn():New( "Status"			, {|| aBrw26Dt[oBrw26Dt:nAt,19]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )
	oBrw26Dt:AddColumn( TcColumn():New( "Calculo Pis"		, {|| aBrw26Dt[oBrw26Dt:nAt,20]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )
	oBrw26Dt:AddColumn( TcColumn():New( "Data Classif."		, {|| aBrw26Dt[oBrw26Dt:nAt,21]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )
	oBrw26Dt:AddColumn( TcColumn():New( "Identif. Bem"		, {|| aBrw26Dt[oBrw26Dt:nAt,22]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )
	oBrw26Dt:AddColumn( TcColumn():New( "Utiliz. Bem"		, {|| aBrw26Dt[oBrw26Dt:nAt,23]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )
	oBrw26Dt:AddColumn( TcColumn():New( "Tipo"				, {|| aBrw26Dt[oBrw26Dt:nAt,30]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )

	oBrw26Dt:SetArray(aBrw26Dt)
	oBrw26Dt:Align		:=	CONTROL_ALIGN_ALLCLIENT	
	oBrw26Dt:bLine := {||{aBrw26Dt[oBrw26Dt:nAt]} } 	

	// FIM Chamado n.045022  - Abel.Babini - Relatorio Cred Pis/Cof Parcelado sobre Ativo - 10/06/2019

	// INICIO n.051633  ³ OS 052957 || FISCAL || DEJAIME || 8921 || REL. PIS/COFINS - ABEL - 09/09/2019
	//-----------------------------------
	//ABA 27 - CONFERENCIA PIS/COFINS
	//-----------------------------------

	aFld27  := {cFld27p01,cFld27p02,cFld27p03,cFld27p04,cFld27p05,cFld27p06}
	//aFld27  := {cFld27p02}
	oFld027:=TFolder():New(1,1,aFld27,{},oFolder030:aDialogs[5/*25*/],,,, .T., .F.,aPosObj[2,4]-5,aPosObj[2,3]-55,)
	oFld027:aDialogs[1]:oFont :=oDlg:oFont //Resumo
	oFld027:aDialogs[2]:oFont :=oDlg:oFont //Detalhe
	oFld027:aDialogs[3]:oFont :=oDlg:oFont //Imobilizado
	oFld027:aDialogs[4]:oFont :=oDlg:oFont //Benf. Bens
	oFld027:aDialogs[5]:oFont :=oDlg:oFont //Benf. Serv.
	oFld027:aDialogs[6]:oFont :=oDlg:oFont //Serv. Sem Cred

	////////////////////////////////////////////////////////////
	oFLr27p1:= FWLayer():New()
	oFLr27p1:Init( oFld027:aDialogs[1], .F., .T.) //RESUMO


	//TITULO
	oFLr27p1:AddLine ('TIT_DLG1', 6, .F.)
	oFLr27p1:AddCollumn('TIT_DLG1',100,.F.,'TIT_DLG1')
	//DETALHE
	oFLr27p1:AddLine ('DET_DLG1', 79, .F.)
	oFLr27p1:AddCollumn('DET_DLG1E',100,.F.,'DET_DLG1')
	//oFLr27p1:AddCollumn('DET_DLG1E',50,.F.,'DET_DLG1')
	//oFLr27p1:AddCollumn('DET_DLG1D',50,.F.,'DET_DLG1')
	//RODAPE
	oFLr27p1:AddLine ('ROD_DLG1', 15, .F.)
	oFLr27p1:AddCollumn('ROD_DLG1',100,.F.,'ROD_DLG1')
	
	oPn27T1		:= oFLr27p1:GetColPanel('TIT_DLG1','TIT_DLG1')
	oPn27D1E	:= oFLr27p1:GetColPanel('DET_DLG1E','DET_DLG1')
	//oPn27D1D	:= oFLr27p1:GetColPanel('DET_DLG1D','DET_DLG1')
	oPn27R1		:= oFLr27p1:GetColPanel('ROD_DLG1','ROD_DLG1')

	oPn27T1:FreeChildren()
	oPn27D1E:FreeChildren()
	//oPn27D1D:FreeChildren()
	oPn27R1:FreeChildren()

	//Cabecalho
	@ 001,008 SAY OemToAnsi("Conferência de Pis/Cofins - Resumo")	FONT oFont003 SIZE 400,15 OF oPn27T1 PIXEL	
	
	//@ 001,008 SAY OemToAnsi("Pis")		FONT oFont002 SIZE 200,15 OF oPn27D1E PIXEL	
	@ 001,060 SAY OemToAnsi("Imobilizado")		FONT oFont002 SIZE 060,15 OF oPn27D1E PIXEL
	@ 001,170 SAY OemToAnsi("Benf. Bens")		FONT oFont002 SIZE 060,15 OF oPn27D1E PIXEL
	@ 001,280 SAY OemToAnsi("Benf. Serv.")		FONT oFont002 SIZE 060,15 OF oPn27D1E PIXEL
	@ 001,390 SAY OemToAnsi("Serv. s/ Créd")	FONT oFont002 SIZE 060,15 OF oPn27D1E PIXEL
	//@ 001,008 SAY OemToAnsi("Cofins")	FONT oFont002 SIZE 200,15 OF oPn27D1D PIXEL	

	@ 011,015 SAY OemToAnsi("Quant. Itens")		FONT oFont001 SIZE 200,15 OF oPn27D1E PIXEL
	@ 010,060 MSGET nA27T01	SIZE 100,08 OF oPn27D1E PIXEL When .F. PICTURE '@E 9,999,999,999'
	@ 010,170 MSGET nA27T11	SIZE 100,08 OF oPn27D1E PIXEL When .F. PICTURE '@E 9,999,999,999'
	@ 010,280 MSGET nA27T21	SIZE 100,08 OF oPn27D1E PIXEL When .F. PICTURE '@E 9,999,999,999'
	@ 010,390 MSGET nA27T31	SIZE 100,08 OF oPn27D1E PIXEL When .F. PICTURE '@E 9,999,999,999'

	@ 026,015 SAY OemToAnsi("Base Cálc. Mês")		FONT oFont001 SIZE 200,15 OF oPn27D1E PIXEL
	@ 025,060 MSGET nA27T02	SIZE 100,08 OF oPn27D1E PIXEL When .F. PICTURE '@E 9,999,999,999.99'
	@ 025,170 MSGET nA27T12	SIZE 100,08 OF oPn27D1E PIXEL When .F. PICTURE '@E 9,999,999,999.99'
	@ 025,280 MSGET nA27T22	SIZE 100,08 OF oPn27D1E PIXEL When .F. PICTURE '@E 9,999,999,999.99'
	@ 025,390 MSGET nA27T32	SIZE 100,08 OF oPn27D1E PIXEL When .F. PICTURE '@E 9,999,999,999.99'

	@ 051,015 SAY OemToAnsi("Vl. Pis")		FONT oFont002 SIZE 200,15 OF oPn27D1E PIXEL
	@ 050,060 MSGET nA27T03	SIZE 100,08 OF oPn27D1E PIXEL When .F. PICTURE '@E 9,999,999,999.99'
	@ 050,170 MSGET nA27T13	SIZE 100,08 OF oPn27D1E PIXEL When .F. PICTURE '@E 9,999,999,999.99'
	@ 050,280 MSGET nA27T23	SIZE 100,08 OF oPn27D1E PIXEL When .F. PICTURE '@E 9,999,999,999.99'
	@ 050,390 MSGET nA27T33	SIZE 100,08 OF oPn27D1E PIXEL When .F. PICTURE '@E 9,999,999,999.99'

	@ 060,170 SAY OemToAnsi("Mes Ant.")		FONT oFont001 SIZE 060,15 OF oPn27D1E PIXEL
	@ 060,220 SAY OemToAnsi("Mes Atual")	FONT oFont001 SIZE 060,15 OF oPn27D1E PIXEL
	@ 060,280 SAY OemToAnsi("Mes Ant.")		FONT oFont001 SIZE 060,15 OF oPn27D1E PIXEL
	@ 060,330 SAY OemToAnsi("Mes Atual")	FONT oFont001 SIZE 060,15 OF oPn27D1E PIXEL
	@ 067,170 MSGET nA27T15	SIZE 50,08 OF oPn27D1E PIXEL When .F. PICTURE '@E 9,999,999,999.99'
	@ 067,220 MSGET nA27T16	SIZE 50,08 OF oPn27D1E PIXEL When .F. PICTURE '@E 9,999,999,999.99'
	@ 067,280 MSGET nA27T25	SIZE 50,08 OF oPn27D1E PIXEL When .F. PICTURE '@E 9,999,999,999.99'
	@ 067,330 MSGET nA27T26	SIZE 50,08 OF oPn27D1E PIXEL When .F. PICTURE '@E 9,999,999,999.99'

	@ 093,015 SAY OemToAnsi("Vl. Cofins")		FONT oFont002 SIZE 200,15 OF oPn27D1E PIXEL
	@ 092,060 MSGET nA27T04	SIZE 100,08 OF oPn27D1E PIXEL When .F. PICTURE '@E 9,999,999,999.99'
	@ 092,170 MSGET nA27T14	SIZE 100,08 OF oPn27D1E PIXEL When .F. PICTURE '@E 9,999,999,999.99'
	@ 092,280 MSGET nA27T24	SIZE 100,08 OF oPn27D1E PIXEL When .F. PICTURE '@E 9,999,999,999.99'
	@ 092,390 MSGET nA27T34	SIZE 100,08 OF oPn27D1E PIXEL When .F. PICTURE '@E 9,999,999,999.99'
	@ 102,170 SAY OemToAnsi("Mes Ant.")		FONT oFont001 SIZE 060,15 OF oPn27D1E PIXEL
	@ 102,220 SAY OemToAnsi("Mes Atual")	FONT oFont001 SIZE 060,15 OF oPn27D1E PIXEL
	@ 102,280 SAY OemToAnsi("Mes Ant.")		FONT oFont001 SIZE 060,15 OF oPn27D1E PIXEL
	@ 102,330 SAY OemToAnsi("Mes Atual")	FONT oFont001 SIZE 060,15 OF oPn27D1E PIXEL
	@ 109,170 MSGET nA27T17	SIZE 50,08 OF oPn27D1E PIXEL When .F. PICTURE '@E 9,999,999,999.99'
	@ 109,220 MSGET nA27T18	SIZE 50,08 OF oPn27D1E PIXEL When .F. PICTURE '@E 9,999,999,999.99'
	@ 109,280 MSGET nA27T27	SIZE 50,08 OF oPn27D1E PIXEL When .F. PICTURE '@E 9,999,999,999.99'
	@ 109,330 MSGET nA27T28	SIZE 50,08 OF oPn27D1E PIXEL When .F. PICTURE '@E 9,999,999,999.99'

	@ 047,011 TO 079,494 OF oPn27D1E PIXEL
	@ 089,011 TO 121,494 OF oPn27D1E PIXEL

	//QUADRO DE RELATÓRIO
	@ 001,508 SAY OemToAnsi("OUTRAS OPÇÕES")		SIZE 200,15	FONT oFont003 						OF oPn27R1 PIXEL
	@ 013,508 BUTTON OemToAnsi('Gera Relatório')	SIZE 42,13	FONT oDlg:oFont ACTION xRelBr27()	OF oPn27R1 PIXEL //"Exportar Excel"

	////////////////////////////////////////////////////////////
	oFLr27p2:= FWLayer():New()
	oFLr27p2:Init( oFld027:aDialogs[2], .F., .T.) //Detalhe

	//TITULO
	oFLr27p2:AddLine ('TIT_DLG2', 6, .F.)
	oFLr27p2:AddCollumn('TIT_DLG2',100,.F.,'TIT_DLG2')
	//DETALHE
	oFLr27p2:AddLine ('DET_DLG2', 82, .F.)
	oFLr27p2:AddCollumn('DET_DLG2E',100,.F.,'DET_DLG2')
	//RODAPE
	oFLr27p2:AddLine ('ROD_DLG2', 12, .F.)
	oFLr27p2:AddCollumn('ROD_DLG2',100,.F.,'ROD_DLG2')
	
	oPn27T2		:= oFLr27p2:GetColPanel('TIT_DLG2','TIT_DLG2')
	oPn27D2E	:= oFLr27p2:GetColPanel('DET_DLG2E','DET_DLG2')
	oPn27R2		:= oFLr27p2:GetColPanel('ROD_DLG2','ROD_DLG2')

	oPn27T2:FreeChildren()
	oPn27D2E:FreeChildren()
	oPn27R2:FreeChildren()
	
	@ 001,008 SAY OemToAnsi("Conferência do Pis/Cofins ")	FONT oFont003 SIZE 500,15 OF oPn27T2 PIXEL
	
	oBrw27Dt:= TcBrowse():New(010,050,150,150,,,,oPn27D2E,,,,,,,,,,,,.f.,,.t.,,.f.,,,,)

	oBrw27Dt:AddColumn( TcColumn():New( "Filial"			, {|| aBrw27Dt[oBrw27Dt:nAt,01]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )
	oBrw27Dt:AddColumn( TcColumn():New( "Dt.Entrada"		, {|| aBrw27Dt[oBrw27Dt:nAt,02]}	, "@!"						,,,"LEFT"	,030,.f.,.f.,,,,.f.,) )
	oBrw27Dt:AddColumn( TcColumn():New( "Serie"				, {|| aBrw27Dt[oBrw27Dt:nAt,03]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )
	oBrw27Dt:AddColumn( TcColumn():New( "NF"				, {|| aBrw27Dt[oBrw27Dt:nAt,04]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )
	oBrw27Dt:AddColumn( TcColumn():New( "Cod.Forn."			, {|| aBrw27Dt[oBrw27Dt:nAt,05]}	, "@!"						,,,"LEFT"	,030,.f.,.f.,,,,.f.,) )
	oBrw27Dt:AddColumn( TcColumn():New( "Loja"				, {|| aBrw27Dt[oBrw27Dt:nAt,06]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )
	oBrw27Dt:AddColumn( TcColumn():New( "Fornecedor"		, {|| aBrw27Dt[oBrw27Dt:nAt,07]}	, "@!"						,,,"LEFT"	,080,.f.,.f.,,,,.f.,) )
	oBrw27Dt:AddColumn( TcColumn():New( "CFOP"				, {|| aBrw27Dt[oBrw27Dt:nAt,08]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )
	oBrw27Dt:AddColumn( TcColumn():New( "Cod.Prod."			, {|| aBrw27Dt[oBrw27Dt:nAt,09]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )
	oBrw27Dt:AddColumn( TcColumn():New( "Produto"			, {|| aBrw27Dt[oBrw27Dt:nAt,10]}	, "@!"						,,,"LEFT"	,060,.f.,.f.,,,,.f.,) )
	oBrw27Dt:AddColumn( TcColumn():New( "TES"				, {|| aBrw27Dt[oBrw27Dt:nAt,11]}	, "@!"						,,,"LEFT"	,015,.f.,.f.,,,,.f.,) )
	oBrw27Dt:AddColumn( TcColumn():New( "Espécie NF"		, {|| aBrw27Dt[oBrw27Dt:nAt,12]}	, "@!"						,,,"LEFT"	,030,.f.,.f.,,,,.f.,) )
	oBrw27Dt:AddColumn( TcColumn():New( "Vl.Contabil"		, {|| aBrw27Dt[oBrw27Dt:nAt,13]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 
	oBrw27Dt:AddColumn( TcColumn():New( "Vl.Total"			, {|| aBrw27Dt[oBrw27Dt:nAt,14]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 
	oBrw27Dt:AddColumn( TcColumn():New( "ICMS Ret."			, {|| aBrw27Dt[oBrw27Dt:nAt,15]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 
	oBrw27Dt:AddColumn( TcColumn():New( "IPI Obs."			, {|| aBrw27Dt[oBrw27Dt:nAt,16]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 
	oBrw27Dt:AddColumn( TcColumn():New( "Vl.Frete"			, {|| aBrw27Dt[oBrw27Dt:nAt,17]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 
	oBrw27Dt:AddColumn( TcColumn():New( "Vl.Seguro"			, {|| aBrw27Dt[oBrw27Dt:nAt,18]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 
	oBrw27Dt:AddColumn( TcColumn():New( "Vl.Despesa"		, {|| aBrw27Dt[oBrw27Dt:nAt,19]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 
	oBrw27Dt:AddColumn( TcColumn():New( "NCM"				, {|| aBrw27Dt[oBrw27Dt:nAt,20]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )
	oBrw27Dt:AddColumn( TcColumn():New( "Vl.Desconto"		, {|| aBrw27Dt[oBrw27Dt:nAt,21]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 
	oBrw27Dt:AddColumn( TcColumn():New( "Base Pis"			, {|| aBrw27Dt[oBrw27Dt:nAt,22]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 
	oBrw27Dt:AddColumn( TcColumn():New( "Aliq.Pis"			, {|| aBrw27Dt[oBrw27Dt:nAt,23]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 
	oBrw27Dt:AddColumn( TcColumn():New( "Val.Pis"			, {|| aBrw27Dt[oBrw27Dt:nAt,24]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 
	oBrw27Dt:AddColumn( TcColumn():New( "Base Cofins"		, {|| aBrw27Dt[oBrw27Dt:nAt,25]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 
	oBrw27Dt:AddColumn( TcColumn():New( "Aliq.Cofins"		, {|| aBrw27Dt[oBrw27Dt:nAt,26]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 
	oBrw27Dt:AddColumn( TcColumn():New( "Val.Cofins"		, {|| aBrw27Dt[oBrw27Dt:nAt,27]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 
	oBrw27Dt:AddColumn( TcColumn():New( "CST Pis"			, {|| aBrw27Dt[oBrw27Dt:nAt,28]}	, "@!"						,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 
	oBrw27Dt:AddColumn( TcColumn():New( "CST Cofins"		, {|| aBrw27Dt[oBrw27Dt:nAt,29]}	, "@!"						,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 
	oBrw27Dt:AddColumn( TcColumn():New( "Cod.BC Cred"		, {|| aBrw27Dt[oBrw27Dt:nAt,30]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )
	oBrw27Dt:AddColumn( TcColumn():New( "Ind.Nat.Frete"		, {|| aBrw27Dt[oBrw27Dt:nAt,31]}	, "@!"						,,,"LEFT"	,030,.f.,.f.,,,,.f.,) )
	oBrw27Dt:AddColumn( TcColumn():New( "Observ."			, {|| aBrw27Dt[oBrw27Dt:nAt,32]}	, "@!"						,,,"LEFT"	,080,.f.,.f.,,,,.f.,) )
	oBrw27Dt:AddColumn( TcColumn():New( "Form.Prop."		, {|| aBrw27Dt[oBrw27Dt:nAt,33]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )
	oBrw27Dt:AddColumn( TcColumn():New( "Chave NF-e"		, {|| aBrw27Dt[oBrw27Dt:nAt,34]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )
	oBrw27Dt:AddColumn( TcColumn():New( "Cod.Base ATF"		, {|| aBrw27Dt[oBrw27Dt:nAt,35]}	, "@!"						,,,"LEFT"	,030,.f.,.f.,,,,.f.,) )
	oBrw27Dt:AddColumn( TcColumn():New( "Dt.Aquisição"		, {|| aBrw27Dt[oBrw27Dt:nAt,36]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )
	oBrw27Dt:AddColumn( TcColumn():New( "Parcelas"			, {|| aBrw27Dt[oBrw27Dt:nAt,37]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )
	oBrw27Dt:AddColumn( TcColumn():New( "Meses Ja Utilizados",{|| aBrw27Dt[oBrw27Dt:nAt,38]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )
	oBrw27Dt:AddColumn( TcColumn():New( "Base Calc. Total"	, {|| aBrw27Dt[oBrw27Dt:nAt,39]}	, "@E 999,999,999.99"		,,,"LEFT"	,030,.f.,.f.,,,,.f.,) )
	oBrw27Dt:AddColumn( TcColumn():New( "Base Calc. Mes"	, {|| aBrw27Dt[oBrw27Dt:nAt,40]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 
	oBrw27Dt:AddColumn( TcColumn():New( "Valor Pis Mes"		, {|| aBrw27Dt[oBrw27Dt:nAt,41]}	, "@E 999,999,999.99"		,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )
	oBrw27Dt:AddColumn( TcColumn():New( "Valor Cofins Mes"	, {|| aBrw27Dt[oBrw27Dt:nAt,42]}	, "@E 999,999,999.99"		,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )
	oBrw27Dt:AddColumn( TcColumn():New( "Utiliz. Bem"		, {|| aBrw27Dt[oBrw27Dt:nAt,43]}	, "@!"						,,,"LEFT"	,060,.f.,.f.,,,,.f.,) )

	oBrw27Dt:SetArray(aBrw27Dt)
	oBrw27Dt:Align		:=	CONTROL_ALIGN_ALLCLIENT	
	oBrw27Dt:bLine := {||{aBrw27Dt[oBrw27Dt:nAt]} } 	
	
	////////////////////////////////////////////////////////////
	oFLr27p3:= FWLayer():New()
	oFLr27p3:Init( oFld027:aDialogs[3], .F., .T.) //No Mês

	//TITULO
	oFLr27p3:AddLine ('TIT_DLG3', 6, .F.)
	oFLr27p3:AddCollumn('TIT_DLG3',100,.F.,'TIT_DLG3')
	//DETALHE
	oFLr27p3:AddLine ('DET_DLG3', 82, .F.)
	oFLr27p3:AddCollumn('DET_DLG3E',100,.F.,'DET_DLG3')
	//RODAPE
	oFLr27p3:AddLine ('ROD_DLG3', 12, .F.)
	oFLr27p3:AddCollumn('ROD_DLG3',100,.F.,'ROD_DLG3')
	
	oPn27T3		:= oFLr27p3:GetColPanel('TIT_DLG3','TIT_DLG3')
	oPn27D3E	:= oFLr27p3:GetColPanel('DET_DLG3E','DET_DLG3')
	oPn27R3		:= oFLr27p3:GetColPanel('ROD_DLG3','ROD_DLG3')

	oPn27T3:FreeChildren()
	oPn27D3E:FreeChildren()
	oPn27R3:FreeChildren()

	@ 001,008 SAY OemToAnsi("Imobilizado")	FONT oFont003 SIZE 500,15 OF oPn27T3 PIXEL
	
	oBrw27Im:= TcBrowse():New(010,050,150,150,,,,oPn27D3E,,,,,,,,,,,,.f.,,.t.,,.f.,,,,)

	oBrw27Im:AddColumn( TcColumn():New( "Filial"			, {|| aBrw27Im[oBrw27Im:nAt,01]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )
	oBrw27Im:AddColumn( TcColumn():New( "Dt.Entrada"		, {|| aBrw27Im[oBrw27Im:nAt,02]}	, "@!"						,,,"LEFT"	,030,.f.,.f.,,,,.f.,) )
	oBrw27Im:AddColumn( TcColumn():New( "Serie"				, {|| aBrw27Im[oBrw27Im:nAt,03]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )
	oBrw27Im:AddColumn( TcColumn():New( "NF"				, {|| aBrw27Im[oBrw27Im:nAt,04]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )
	oBrw27Im:AddColumn( TcColumn():New( "Cod.Forn."			, {|| aBrw27Im[oBrw27Im:nAt,05]}	, "@!"						,,,"LEFT"	,030,.f.,.f.,,,,.f.,) )
	oBrw27Im:AddColumn( TcColumn():New( "Loja"				, {|| aBrw27Im[oBrw27Im:nAt,06]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )
	oBrw27Im:AddColumn( TcColumn():New( "Fornecedor"		, {|| aBrw27Im[oBrw27Im:nAt,07]}	, "@!"						,,,"LEFT"	,080,.f.,.f.,,,,.f.,) )
	oBrw27Im:AddColumn( TcColumn():New( "CFOP"				, {|| aBrw27Im[oBrw27Im:nAt,08]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )
	oBrw27Im:AddColumn( TcColumn():New( "Cod.Prod."			, {|| aBrw27Im[oBrw27Im:nAt,09]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )
	oBrw27Im:AddColumn( TcColumn():New( "Produto"			, {|| aBrw27Im[oBrw27Im:nAt,10]}	, "@!"						,,,"LEFT"	,060,.f.,.f.,,,,.f.,) )
	oBrw27Im:AddColumn( TcColumn():New( "TES"				, {|| aBrw27Im[oBrw27Im:nAt,11]}	, "@!"						,,,"LEFT"	,015,.f.,.f.,,,,.f.,) )
	oBrw27Im:AddColumn( TcColumn():New( "Espécie NF"		, {|| aBrw27Im[oBrw27Im:nAt,12]}	, "@!"						,,,"LEFT"	,030,.f.,.f.,,,,.f.,) )
	oBrw27Im:AddColumn( TcColumn():New( "Vl.Contabil"		, {|| aBrw27Im[oBrw27Im:nAt,13]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 
	oBrw27Im:AddColumn( TcColumn():New( "Vl.Total"			, {|| aBrw27Im[oBrw27Im:nAt,14]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 
	oBrw27Im:AddColumn( TcColumn():New( "ICMS Ret."			, {|| aBrw27Im[oBrw27Im:nAt,15]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 
	oBrw27Im:AddColumn( TcColumn():New( "IPI Obs."			, {|| aBrw27Im[oBrw27Im:nAt,16]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 
	oBrw27Im:AddColumn( TcColumn():New( "Vl.Frete"			, {|| aBrw27Im[oBrw27Im:nAt,17]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 
	oBrw27Im:AddColumn( TcColumn():New( "Vl.Seguro"			, {|| aBrw27Im[oBrw27Im:nAt,18]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 
	oBrw27Im:AddColumn( TcColumn():New( "Vl.Despesa"		, {|| aBrw27Im[oBrw27Im:nAt,19]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 
	oBrw27Im:AddColumn( TcColumn():New( "NCM"				, {|| aBrw27Im[oBrw27Im:nAt,20]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )
	oBrw27Im:AddColumn( TcColumn():New( "Vl.Desconto"		, {|| aBrw27Im[oBrw27Im:nAt,21]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 
	oBrw27Im:AddColumn( TcColumn():New( "Base Pis"			, {|| aBrw27Im[oBrw27Im:nAt,22]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 
	oBrw27Im:AddColumn( TcColumn():New( "Aliq.Pis"			, {|| aBrw27Im[oBrw27Im:nAt,23]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 
	oBrw27Im:AddColumn( TcColumn():New( "Val.Pis"			, {|| aBrw27Im[oBrw27Im:nAt,24]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 
	oBrw27Im:AddColumn( TcColumn():New( "Base Cofins"		, {|| aBrw27Im[oBrw27Im:nAt,25]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 
	oBrw27Im:AddColumn( TcColumn():New( "Aliq.Cofins"		, {|| aBrw27Im[oBrw27Im:nAt,26]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 
	oBrw27Im:AddColumn( TcColumn():New( "Val.Cofins"		, {|| aBrw27Im[oBrw27Im:nAt,27]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 
	oBrw27Im:AddColumn( TcColumn():New( "CST Pis"			, {|| aBrw27Im[oBrw27Im:nAt,28]}	, "@!"						,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 
	oBrw27Im:AddColumn( TcColumn():New( "CST Cofins"		, {|| aBrw27Im[oBrw27Im:nAt,29]}	, "@!"						,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 
	oBrw27Im:AddColumn( TcColumn():New( "Cod.BC Cred"		, {|| aBrw27Im[oBrw27Im:nAt,30]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )
	oBrw27Im:AddColumn( TcColumn():New( "Ind.Nat.Frete"		, {|| aBrw27Im[oBrw27Im:nAt,31]}	, "@!"						,,,"LEFT"	,030,.f.,.f.,,,,.f.,) )
	oBrw27Im:AddColumn( TcColumn():New( "Observ."			, {|| aBrw27Im[oBrw27Im:nAt,32]}	, "@!"						,,,"LEFT"	,080,.f.,.f.,,,,.f.,) )
	oBrw27Im:AddColumn( TcColumn():New( "Form.Prop."		, {|| aBrw27Im[oBrw27Im:nAt,33]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )
	oBrw27Im:AddColumn( TcColumn():New( "Chave NF-e"		, {|| aBrw27Im[oBrw27Im:nAt,34]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )
	oBrw27Im:AddColumn( TcColumn():New( "Cod.Base ATF"		, {|| aBrw27Im[oBrw27Im:nAt,35]}	, "@!"						,,,"LEFT"	,030,.f.,.f.,,,,.f.,) )
	oBrw27Im:AddColumn( TcColumn():New( "Dt.Aquisição"		, {|| aBrw27Im[oBrw27Im:nAt,36]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )
	oBrw27Im:AddColumn( TcColumn():New( "Parcelas"			, {|| aBrw27Im[oBrw27Im:nAt,37]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )
	oBrw27Im:AddColumn( TcColumn():New( "Meses Ja Utilizados",{|| aBrw27Im[oBrw27Im:nAt,38]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )
	oBrw27Im:AddColumn( TcColumn():New( "Base Calc. Total"	, {|| aBrw27Im[oBrw27Im:nAt,39]}	, "@E 999,999,999.99"		,,,"LEFT"	,030,.f.,.f.,,,,.f.,) )
	oBrw27Im:AddColumn( TcColumn():New( "Base Calc. Mes"	, {|| aBrw27Im[oBrw27Im:nAt,40]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 
	oBrw27Im:AddColumn( TcColumn():New( "Valor Pis Mes"		, {|| aBrw27Im[oBrw27Im:nAt,41]}	, "@E 999,999,999.99"		,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )
	oBrw27Im:AddColumn( TcColumn():New( "Valor Cofins Mes"	, {|| aBrw27Im[oBrw27Im:nAt,42]}	, "@E 999,999,999.99"		,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )
	oBrw27Im:AddColumn( TcColumn():New( "Utiliz. Bem"		, {|| aBrw27Im[oBrw27Im:nAt,43]}	, "@!"						,,,"LEFT"	,060,.f.,.f.,,,,.f.,) )

	oBrw27Im:SetArray(aBrw27Im)
	oBrw27Im:Align		:=	CONTROL_ALIGN_ALLCLIENT	
	oBrw27Im:bLine := {||{aBrw27Im[oBrw27Im:nAt]} } 	

	////////////////////////////////////////////////////////////
	oFLr27p4:= FWLayer():New()
	oFLr27p4:Init( oFld027:aDialogs[4], .F., .T.) //Meses Anteriores

	//TITULO
	oFLr27p4:AddLine ('TIT_DLG4', 6, .F.)
	oFLr27p4:AddCollumn('TIT_DLG4',100,.F.,'TIT_DLG4')
	//DETALHE
	oFLr27p4:AddLine ('DET_DLG4', 82, .F.)
	oFLr27p4:AddCollumn('DET_DLG4E',100,.F.,'DET_DLG4')
	//RODAPE
	oFLr27p4:AddLine ('ROD_DLG4', 12, .F.)
	oFLr27p4:AddCollumn('ROD_DLG4',100,.F.,'ROD_DLG4')
	
	oPn27T4		:= oFLr27p4:GetColPanel('TIT_DLG4','TIT_DLG4')
	oPn27D4E	:= oFLr27p4:GetColPanel('DET_DLG4E','DET_DLG4')
	oPn27R4		:= oFLr27p4:GetColPanel('ROD_DLG4','ROD_DLG4')

	oPn27T4:FreeChildren()
	oPn27D4E:FreeChildren()
	oPn27R4:FreeChildren()
	
	@ 001,008 SAY OemToAnsi("Benfeitoria com Bens")	FONT oFont003 SIZE 500,15 OF oPn27T4 PIXEL
	
	oBrw27Be:= TcBrowse():New(010,050,150,150,,,,oPn27D4E,,,,,,,,,,,,.f.,,.t.,,.f.,,,,)

	oBrw27Be:AddColumn( TcColumn():New( "Filial"			, {|| aBrw27Be[oBrw27Be:nAt,01]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )
	oBrw27Be:AddColumn( TcColumn():New( "Dt.Entrada"		, {|| aBrw27Be[oBrw27Be:nAt,02]}	, "@!"						,,,"LEFT"	,030,.f.,.f.,,,,.f.,) )
	oBrw27Be:AddColumn( TcColumn():New( "Serie"				, {|| aBrw27Be[oBrw27Be:nAt,03]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )
	oBrw27Be:AddColumn( TcColumn():New( "NF"				, {|| aBrw27Be[oBrw27Be:nAt,04]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )
	oBrw27Be:AddColumn( TcColumn():New( "Cod.Forn."			, {|| aBrw27Be[oBrw27Be:nAt,05]}	, "@!"						,,,"LEFT"	,030,.f.,.f.,,,,.f.,) )
	oBrw27Be:AddColumn( TcColumn():New( "Loja"				, {|| aBrw27Be[oBrw27Be:nAt,06]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )
	oBrw27Be:AddColumn( TcColumn():New( "Fornecedor"		, {|| aBrw27Be[oBrw27Be:nAt,07]}	, "@!"						,,,"LEFT"	,080,.f.,.f.,,,,.f.,) )
	oBrw27Be:AddColumn( TcColumn():New( "CFOP"				, {|| aBrw27Be[oBrw27Be:nAt,08]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )
	oBrw27Be:AddColumn( TcColumn():New( "Cod.Prod."			, {|| aBrw27Be[oBrw27Be:nAt,09]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )
	oBrw27Be:AddColumn( TcColumn():New( "Produto"			, {|| aBrw27Be[oBrw27Be:nAt,10]}	, "@!"						,,,"LEFT"	,060,.f.,.f.,,,,.f.,) )
	oBrw27Be:AddColumn( TcColumn():New( "TES"				, {|| aBrw27Be[oBrw27Be:nAt,11]}	, "@!"						,,,"LEFT"	,015,.f.,.f.,,,,.f.,) )
	oBrw27Be:AddColumn( TcColumn():New( "Espécie NF"		, {|| aBrw27Be[oBrw27Be:nAt,12]}	, "@!"						,,,"LEFT"	,030,.f.,.f.,,,,.f.,) )
	oBrw27Be:AddColumn( TcColumn():New( "Vl.Contabil"		, {|| aBrw27Be[oBrw27Be:nAt,13]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 
	oBrw27Be:AddColumn( TcColumn():New( "Vl.Total"			, {|| aBrw27Be[oBrw27Be:nAt,14]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 
	oBrw27Be:AddColumn( TcColumn():New( "ICMS Ret."			, {|| aBrw27Be[oBrw27Be:nAt,15]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 
	oBrw27Be:AddColumn( TcColumn():New( "IPI Obs."			, {|| aBrw27Be[oBrw27Be:nAt,16]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 
	oBrw27Be:AddColumn( TcColumn():New( "Vl.Frete"			, {|| aBrw27Be[oBrw27Be:nAt,17]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 
	oBrw27Be:AddColumn( TcColumn():New( "Vl.Seguro"			, {|| aBrw27Be[oBrw27Be:nAt,18]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 
	oBrw27Be:AddColumn( TcColumn():New( "Vl.Despesa"		, {|| aBrw27Be[oBrw27Be:nAt,19]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 
	oBrw27Be:AddColumn( TcColumn():New( "NCM"				, {|| aBrw27Be[oBrw27Be:nAt,20]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )
	oBrw27Be:AddColumn( TcColumn():New( "Vl.Desconto"		, {|| aBrw27Be[oBrw27Be:nAt,21]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 
	oBrw27Be:AddColumn( TcColumn():New( "Base Pis"			, {|| aBrw27Be[oBrw27Be:nAt,22]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 
	oBrw27Be:AddColumn( TcColumn():New( "Aliq.Pis"			, {|| aBrw27Be[oBrw27Be:nAt,23]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 
	oBrw27Be:AddColumn( TcColumn():New( "Val.Pis"			, {|| aBrw27Be[oBrw27Be:nAt,24]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 
	oBrw27Be:AddColumn( TcColumn():New( "Base Cofins"		, {|| aBrw27Be[oBrw27Be:nAt,25]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 
	oBrw27Be:AddColumn( TcColumn():New( "Aliq.Cofins"		, {|| aBrw27Be[oBrw27Be:nAt,26]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 
	oBrw27Be:AddColumn( TcColumn():New( "Val.Cofins"		, {|| aBrw27Be[oBrw27Be:nAt,27]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 
	oBrw27Be:AddColumn( TcColumn():New( "CST Pis"			, {|| aBrw27Be[oBrw27Be:nAt,28]}	, "@!"						,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 
	oBrw27Be:AddColumn( TcColumn():New( "CST Cofins"		, {|| aBrw27Be[oBrw27Be:nAt,29]}	, "@!"						,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 
	oBrw27Be:AddColumn( TcColumn():New( "Cod.BC Cred"		, {|| aBrw27Be[oBrw27Be:nAt,30]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )
	oBrw27Be:AddColumn( TcColumn():New( "Ind.Nat.Frete"		, {|| aBrw27Be[oBrw27Be:nAt,31]}	, "@!"						,,,"LEFT"	,030,.f.,.f.,,,,.f.,) )
	oBrw27Be:AddColumn( TcColumn():New( "Observ."			, {|| aBrw27Be[oBrw27Be:nAt,32]}	, "@!"						,,,"LEFT"	,080,.f.,.f.,,,,.f.,) )
	oBrw27Be:AddColumn( TcColumn():New( "Form.Prop."		, {|| aBrw27Be[oBrw27Be:nAt,33]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )
	oBrw27Be:AddColumn( TcColumn():New( "Chave NF-e"		, {|| aBrw27Be[oBrw27Be:nAt,34]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )
	oBrw27Be:AddColumn( TcColumn():New( "Cod.Base ATF"		, {|| aBrw27Be[oBrw27Be:nAt,35]}	, "@!"						,,,"LEFT"	,030,.f.,.f.,,,,.f.,) )
	oBrw27Be:AddColumn( TcColumn():New( "Dt.Aquisição"		, {|| aBrw27Be[oBrw27Be:nAt,36]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )
	oBrw27Be:AddColumn( TcColumn():New( "Parcelas"			, {|| aBrw27Be[oBrw27Be:nAt,37]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )
	oBrw27Be:AddColumn( TcColumn():New( "Meses Ja Utilizados",{|| aBrw27Be[oBrw27Be:nAt,38]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )
	oBrw27Be:AddColumn( TcColumn():New( "Base Calc. Total"	, {|| aBrw27Be[oBrw27Be:nAt,39]}	, "@E 999,999,999.99"		,,,"LEFT"	,030,.f.,.f.,,,,.f.,) )
	oBrw27Be:AddColumn( TcColumn():New( "Base Calc. Mes"	, {|| aBrw27Be[oBrw27Be:nAt,40]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 
	oBrw27Be:AddColumn( TcColumn():New( "Valor Pis Mes"		, {|| aBrw27Be[oBrw27Be:nAt,41]}	, "@E 999,999,999.99"		,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )
	oBrw27Be:AddColumn( TcColumn():New( "Valor Cofins Mes"	, {|| aBrw27Be[oBrw27Be:nAt,42]}	, "@E 999,999,999.99"		,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )
	oBrw27Be:AddColumn( TcColumn():New( "Utiliz. Bem"		, {|| aBrw27Be[oBrw27Be:nAt,43]}	, "@!"						,,,"LEFT"	,060,.f.,.f.,,,,.f.,) )

	oBrw27Be:SetArray(aBrw27Be)
	oBrw27Be:Align		:=	CONTROL_ALIGN_ALLCLIENT	
	oBrw27Be:bLine := {||{aBrw27Be[oBrw27Be:nAt]} } 	
	
	////////////////////////////////////////////////////////////
	oFLr27p5:= FWLayer():New()
	oFLr27p5:Init( oFld027:aDialogs[5], .F., .T.) //Benf Serviços

	//TITULO
	oFLr27p5:AddLine ('TIT_DLG5', 6, .F.)
	oFLr27p5:AddCollumn('TIT_DLG5',100,.F.,'TIT_DLG5')
	//DETALHE
	oFLr27p5:AddLine ('DET_DLG5', 82, .F.)
	oFLr27p5:AddCollumn('DET_DLG5E',100,.F.,'DET_DLG5')
	//RODAPE
	oFLr27p5:AddLine ('ROD_DLG5', 12, .F.)
	oFLr27p5:AddCollumn('ROD_DLG5',100,.F.,'ROD_DLG5')
	
	oPn27T5		:= oFLr27p5:GetColPanel('TIT_DLG5','TIT_DLG5')
	oPn27D5E	:= oFLr27p5:GetColPanel('DET_DLG5E','DET_DLG5')
	oPn27R5		:= oFLr27p5:GetColPanel('ROD_DLG5','ROD_DLG5')

	oPn27T5:FreeChildren()
	oPn27D5E:FreeChildren()
	oPn27R5:FreeChildren()
	
	@ 001,008 SAY OemToAnsi("Benfeitoria com Serviços")	FONT oFont003 SIZE 500,15 OF oPn27T5 PIXEL
	
	oBrw27Se:= TcBrowse():New(010,050,150,150,,,,oPn27D5E,,,,,,,,,,,,.f.,,.t.,,.f.,,,,)

	oBrw27Se:AddColumn( TcColumn():New( "Filial"			, {|| aBrw27Se[oBrw27Se:nAt,01]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )
	oBrw27Se:AddColumn( TcColumn():New( "Dt.Entrada"		, {|| aBrw27Se[oBrw27Se:nAt,02]}	, "@!"						,,,"LEFT"	,030,.f.,.f.,,,,.f.,) )
	oBrw27Se:AddColumn( TcColumn():New( "Serie"				, {|| aBrw27Se[oBrw27Se:nAt,03]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )
	oBrw27Se:AddColumn( TcColumn():New( "NF"				, {|| aBrw27Se[oBrw27Se:nAt,04]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )
	oBrw27Se:AddColumn( TcColumn():New( "Cod.Forn."			, {|| aBrw27Se[oBrw27Se:nAt,05]}	, "@!"						,,,"LEFT"	,030,.f.,.f.,,,,.f.,) )
	oBrw27Se:AddColumn( TcColumn():New( "Loja"				, {|| aBrw27Se[oBrw27Se:nAt,06]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )
	oBrw27Se:AddColumn( TcColumn():New( "Fornecedor"		, {|| aBrw27Se[oBrw27Se:nAt,07]}	, "@!"						,,,"LEFT"	,080,.f.,.f.,,,,.f.,) )
	oBrw27Se:AddColumn( TcColumn():New( "CFOP"				, {|| aBrw27Se[oBrw27Se:nAt,08]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )
	oBrw27Se:AddColumn( TcColumn():New( "Cod.Prod."			, {|| aBrw27Se[oBrw27Se:nAt,09]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )
	oBrw27Se:AddColumn( TcColumn():New( "Produto"			, {|| aBrw27Se[oBrw27Se:nAt,10]}	, "@!"						,,,"LEFT"	,060,.f.,.f.,,,,.f.,) )
	oBrw27Se:AddColumn( TcColumn():New( "TES"				, {|| aBrw27Se[oBrw27Se:nAt,11]}	, "@!"						,,,"LEFT"	,015,.f.,.f.,,,,.f.,) )
	oBrw27Se:AddColumn( TcColumn():New( "Espécie NF"		, {|| aBrw27Se[oBrw27Se:nAt,12]}	, "@!"						,,,"LEFT"	,030,.f.,.f.,,,,.f.,) )
	oBrw27Se:AddColumn( TcColumn():New( "Vl.Contabil"		, {|| aBrw27Se[oBrw27Se:nAt,13]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 
	oBrw27Se:AddColumn( TcColumn():New( "Vl.Total"			, {|| aBrw27Se[oBrw27Se:nAt,14]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 
	oBrw27Se:AddColumn( TcColumn():New( "ICMS Ret."			, {|| aBrw27Se[oBrw27Se:nAt,15]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 
	oBrw27Se:AddColumn( TcColumn():New( "IPI Obs."			, {|| aBrw27Se[oBrw27Se:nAt,16]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 
	oBrw27Se:AddColumn( TcColumn():New( "Vl.Frete"			, {|| aBrw27Se[oBrw27Se:nAt,17]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 
	oBrw27Se:AddColumn( TcColumn():New( "Vl.Seguro"			, {|| aBrw27Se[oBrw27Se:nAt,18]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 
	oBrw27Se:AddColumn( TcColumn():New( "Vl.Despesa"		, {|| aBrw27Se[oBrw27Se:nAt,19]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 
	oBrw27Se:AddColumn( TcColumn():New( "NCM"				, {|| aBrw27Se[oBrw27Se:nAt,20]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )
	oBrw27Se:AddColumn( TcColumn():New( "Vl.Desconto"		, {|| aBrw27Se[oBrw27Se:nAt,21]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 
	oBrw27Se:AddColumn( TcColumn():New( "Base Pis"			, {|| aBrw27Se[oBrw27Se:nAt,22]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 
	oBrw27Se:AddColumn( TcColumn():New( "Aliq.Pis"			, {|| aBrw27Se[oBrw27Se:nAt,23]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 
	oBrw27Se:AddColumn( TcColumn():New( "Val.Pis"			, {|| aBrw27Se[oBrw27Se:nAt,24]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 
	oBrw27Se:AddColumn( TcColumn():New( "Base Cofins"		, {|| aBrw27Se[oBrw27Se:nAt,25]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 
	oBrw27Se:AddColumn( TcColumn():New( "Aliq.Cofins"		, {|| aBrw27Se[oBrw27Se:nAt,26]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 
	oBrw27Se:AddColumn( TcColumn():New( "Val.Cofins"		, {|| aBrw27Se[oBrw27Se:nAt,27]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 
	oBrw27Se:AddColumn( TcColumn():New( "CST Pis"			, {|| aBrw27Se[oBrw27Se:nAt,28]}	, "@!"						,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 
	oBrw27Se:AddColumn( TcColumn():New( "CST Cofins"		, {|| aBrw27Se[oBrw27Se:nAt,29]}	, "@!"						,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 
	oBrw27Se:AddColumn( TcColumn():New( "Cod.BC Cred"		, {|| aBrw27Se[oBrw27Se:nAt,30]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )
	oBrw27Se:AddColumn( TcColumn():New( "Ind.Nat.Frete"		, {|| aBrw27Se[oBrw27Se:nAt,31]}	, "@!"						,,,"LEFT"	,030,.f.,.f.,,,,.f.,) )
	oBrw27Se:AddColumn( TcColumn():New( "Observ."			, {|| aBrw27Se[oBrw27Se:nAt,32]}	, "@!"						,,,"LEFT"	,080,.f.,.f.,,,,.f.,) )
	oBrw27Se:AddColumn( TcColumn():New( "Form.Prop."		, {|| aBrw27Se[oBrw27Se:nAt,33]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )
	oBrw27Se:AddColumn( TcColumn():New( "Chave NF-e"		, {|| aBrw27Se[oBrw27Se:nAt,34]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )
	oBrw27Se:AddColumn( TcColumn():New( "Cod.Base ATF"		, {|| aBrw27Se[oBrw27Se:nAt,35]}	, "@!"						,,,"LEFT"	,030,.f.,.f.,,,,.f.,) )
	oBrw27Se:AddColumn( TcColumn():New( "Dt.Aquisição"		, {|| aBrw27Se[oBrw27Se:nAt,36]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )
	oBrw27Se:AddColumn( TcColumn():New( "Parcelas"			, {|| aBrw27Se[oBrw27Se:nAt,37]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )
	oBrw27Se:AddColumn( TcColumn():New( "Meses Ja Utilizados",{|| aBrw27Se[oBrw27Se:nAt,38]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )
	oBrw27Se:AddColumn( TcColumn():New( "Base Calc. Total"	, {|| aBrw27Se[oBrw27Se:nAt,39]}	, "@E 999,999,999.99"		,,,"LEFT"	,030,.f.,.f.,,,,.f.,) )
	oBrw27Se:AddColumn( TcColumn():New( "Base Calc. Mes"	, {|| aBrw27Se[oBrw27Se:nAt,40]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 
	oBrw27Se:AddColumn( TcColumn():New( "Valor Pis Mes"		, {|| aBrw27Se[oBrw27Se:nAt,41]}	, "@E 999,999,999.99"		,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )
	oBrw27Se:AddColumn( TcColumn():New( "Valor Cofins Mes"	, {|| aBrw27Se[oBrw27Se:nAt,42]}	, "@E 999,999,999.99"		,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )
	oBrw27Se:AddColumn( TcColumn():New( "Utiliz. Bem"		, {|| aBrw27Se[oBrw27Se:nAt,43]}	, "@!"						,,,"LEFT"	,060,.f.,.f.,,,,.f.,) )

	oBrw27Se:SetArray(aBrw27Se)
	oBrw27Se:Align		:=	CONTROL_ALIGN_ALLCLIENT	
	oBrw27Se:bLine := {||{aBrw27Se[oBrw27Se:nAt]} } 	
	
	////////////////////////////////////////////////////////////
	oFLr27p6:= FWLayer():New()
	oFLr27p6:Init( oFld027:aDialogs[6], .F., .T.) //Serviços sem crédito

	//TITULO
	oFLr27p6:AddLine ('TIT_DLG6', 6, .F.)
	oFLr27p6:AddCollumn('TIT_DLG6',100,.F.,'TIT_DLG6')
	//DETALHE
	oFLr27p6:AddLine ('DET_DLG6', 82, .F.)
	oFLr27p6:AddCollumn('DET_DLG6E',100,.F.,'DET_DLG6')
	//RODAPE
	oFLr27p6:AddLine ('ROD_DLG6', 12, .F.)
	oFLr27p6:AddCollumn('ROD_DLG6',100,.F.,'ROD_DLG6')
	
	oPn27T6		:= oFLr27p6:GetColPanel('TIT_DLG6','TIT_DLG6')
	oPn27D6E	:= oFLr27p6:GetColPanel('DET_DLG6E','DET_DLG6')
	oPn27R6		:= oFLr27p6:GetColPanel('ROD_DLG6','ROD_DLG6')

	oPn27T6:FreeChildren()
	oPn27D6E:FreeChildren()
	oPn27R6:FreeChildren()
	
	@ 001,008 SAY OemToAnsi("Serviços sem Crédito")	FONT oFont003 SIZE 500,15 OF oPn27T6 PIXEL
	
	oBrw27SN:= TcBrowse():New(010,050,150,150,,,,oPn27D6E,,,,,,,,,,,,.f.,,.t.,,.f.,,,,)

	oBrw27SN:AddColumn( TcColumn():New( "Filial"			, {|| aBrw27SN[oBrw27SN:nAt,01]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )
	oBrw27SN:AddColumn( TcColumn():New( "Dt.Entrada"		, {|| aBrw27SN[oBrw27SN:nAt,02]}	, "@!"						,,,"LEFT"	,030,.f.,.f.,,,,.f.,) )
	oBrw27SN:AddColumn( TcColumn():New( "Serie"				, {|| aBrw27SN[oBrw27SN:nAt,03]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )
	oBrw27SN:AddColumn( TcColumn():New( "NF"				, {|| aBrw27SN[oBrw27SN:nAt,04]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )
	oBrw27SN:AddColumn( TcColumn():New( "Cod.Forn."			, {|| aBrw27SN[oBrw27SN:nAt,05]}	, "@!"						,,,"LEFT"	,030,.f.,.f.,,,,.f.,) )
	oBrw27SN:AddColumn( TcColumn():New( "Loja"				, {|| aBrw27SN[oBrw27SN:nAt,06]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )
	oBrw27SN:AddColumn( TcColumn():New( "Fornecedor"		, {|| aBrw27SN[oBrw27SN:nAt,07]}	, "@!"						,,,"LEFT"	,080,.f.,.f.,,,,.f.,) )
	oBrw27SN:AddColumn( TcColumn():New( "CFOP"				, {|| aBrw27SN[oBrw27SN:nAt,08]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )
	oBrw27SN:AddColumn( TcColumn():New( "Cod.Prod."			, {|| aBrw27SN[oBrw27SN:nAt,09]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )
	oBrw27SN:AddColumn( TcColumn():New( "Produto"			, {|| aBrw27SN[oBrw27SN:nAt,10]}	, "@!"						,,,"LEFT"	,060,.f.,.f.,,,,.f.,) )
	oBrw27SN:AddColumn( TcColumn():New( "TES"				, {|| aBrw27SN[oBrw27SN:nAt,11]}	, "@!"						,,,"LEFT"	,015,.f.,.f.,,,,.f.,) )
	oBrw27SN:AddColumn( TcColumn():New( "Espécie NF"		, {|| aBrw27SN[oBrw27SN:nAt,12]}	, "@!"						,,,"LEFT"	,030,.f.,.f.,,,,.f.,) )
	oBrw27SN:AddColumn( TcColumn():New( "Vl.Contabil"		, {|| aBrw27SN[oBrw27SN:nAt,13]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 
	oBrw27SN:AddColumn( TcColumn():New( "Vl.Total"			, {|| aBrw27SN[oBrw27SN:nAt,14]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 
	oBrw27SN:AddColumn( TcColumn():New( "ICMS Ret."			, {|| aBrw27SN[oBrw27SN:nAt,15]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 
	oBrw27SN:AddColumn( TcColumn():New( "IPI Obs."			, {|| aBrw27SN[oBrw27SN:nAt,16]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 
	oBrw27SN:AddColumn( TcColumn():New( "Vl.Frete"			, {|| aBrw27SN[oBrw27SN:nAt,17]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 
	oBrw27SN:AddColumn( TcColumn():New( "Vl.Seguro"			, {|| aBrw27SN[oBrw27SN:nAt,18]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 
	oBrw27SN:AddColumn( TcColumn():New( "Vl.Despesa"		, {|| aBrw27SN[oBrw27SN:nAt,19]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 
	oBrw27SN:AddColumn( TcColumn():New( "NCM"				, {|| aBrw27SN[oBrw27SN:nAt,20]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )
	oBrw27SN:AddColumn( TcColumn():New( "Vl.Desconto"		, {|| aBrw27SN[oBrw27SN:nAt,21]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 
	oBrw27SN:AddColumn( TcColumn():New( "Base Pis"			, {|| aBrw27SN[oBrw27SN:nAt,22]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 
	oBrw27SN:AddColumn( TcColumn():New( "Aliq.Pis"			, {|| aBrw27SN[oBrw27SN:nAt,23]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 
	oBrw27SN:AddColumn( TcColumn():New( "Val.Pis"			, {|| aBrw27SN[oBrw27SN:nAt,24]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 
	oBrw27SN:AddColumn( TcColumn():New( "Base Cofins"		, {|| aBrw27SN[oBrw27SN:nAt,25]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 
	oBrw27SN:AddColumn( TcColumn():New( "Aliq.Cofins"		, {|| aBrw27SN[oBrw27SN:nAt,26]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 
	oBrw27SN:AddColumn( TcColumn():New( "Val.Cofins"		, {|| aBrw27SN[oBrw27SN:nAt,27]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 
	oBrw27SN:AddColumn( TcColumn():New( "CST Pis"			, {|| aBrw27SN[oBrw27SN:nAt,28]}	, "@!"						,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 
	oBrw27SN:AddColumn( TcColumn():New( "CST Cofins"		, {|| aBrw27SN[oBrw27SN:nAt,29]}	, "@!"						,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 
	oBrw27SN:AddColumn( TcColumn():New( "Cod.BC Cred"		, {|| aBrw27SN[oBrw27SN:nAt,30]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )
	oBrw27SN:AddColumn( TcColumn():New( "Ind.Nat.Frete"		, {|| aBrw27SN[oBrw27SN:nAt,31]}	, "@!"						,,,"LEFT"	,030,.f.,.f.,,,,.f.,) )
	oBrw27SN:AddColumn( TcColumn():New( "Observ."			, {|| aBrw27SN[oBrw27SN:nAt,32]}	, "@!"						,,,"LEFT"	,080,.f.,.f.,,,,.f.,) )
	oBrw27SN:AddColumn( TcColumn():New( "Form.Prop."		, {|| aBrw27SN[oBrw27SN:nAt,33]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )
	oBrw27SN:AddColumn( TcColumn():New( "Chave NF-e"		, {|| aBrw27SN[oBrw27SN:nAt,34]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )
	oBrw27SN:AddColumn( TcColumn():New( "Cod.Base ATF"		, {|| aBrw27SN[oBrw27SN:nAt,35]}	, "@!"						,,,"LEFT"	,030,.f.,.f.,,,,.f.,) )
	oBrw27SN:AddColumn( TcColumn():New( "Dt.Aquisição"		, {|| aBrw27SN[oBrw27SN:nAt,36]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )
	oBrw27SN:AddColumn( TcColumn():New( "Parcelas"			, {|| aBrw27SN[oBrw27SN:nAt,37]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )
	oBrw27SN:AddColumn( TcColumn():New( "Meses Ja Utilizados",{|| aBrw27SN[oBrw27SN:nAt,38]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )
	oBrw27SN:AddColumn( TcColumn():New( "Base Calc. Total"	, {|| aBrw27SN[oBrw27SN:nAt,39]}	, "@E 999,999,999.99"		,,,"LEFT"	,030,.f.,.f.,,,,.f.,) )
	oBrw27SN:AddColumn( TcColumn():New( "Base Calc. Mes"	, {|| aBrw27SN[oBrw27SN:nAt,40]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 
	oBrw27SN:AddColumn( TcColumn():New( "Valor Pis Mes"		, {|| aBrw27SN[oBrw27SN:nAt,41]}	, "@E 999,999,999.99"		,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )
	oBrw27SN:AddColumn( TcColumn():New( "Valor Cofins Mes"	, {|| aBrw27SN[oBrw27SN:nAt,42]}	, "@E 999,999,999.99"		,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )
	oBrw27SN:AddColumn( TcColumn():New( "Utiliz. Bem"		, {|| aBrw27SN[oBrw27SN:nAt,43]}	, "@!"						,,,"LEFT"	,060,.f.,.f.,,,,.f.,) )

	oBrw27SN:SetArray(aBrw27SN)
	oBrw27SN:Align		:=	CONTROL_ALIGN_ALLCLIENT	
	oBrw27SN:bLine := {||{aBrw27SN[oBrw27SN:nAt]} } 	
	
	// FIM n.051633  ³ OS 052957 || FISCAL || DEJAIME || 8921 || REL. PIS/COFINS - ABEL - 09/09/2019
	
	//--------------------------------------------------------------------------
	//FIM DA CONSTRUÇÃO DAS ABAS
	//--------------------------------------------------------------------------
	ACTIVATE MSDIALOG oDlg
Return

//INICIO Chamado n.040918 - Abel.Babini - Relatorio INSS para calculo da desoneração - 27/05/2019

/*/{Protheus.doc} Static Function xAjBr25
	Tela do Painel Fiscal - PIS e COFINS
	@type  Function
	@author Abel Babini Filho
	@since 27/05/2019
	@version 03
	/*/
Static Function xAjBr25()
	Local _i	:= 1
	Local lB5Lp	:= .T.
	
	IF cEmpAnt == '01'
	
		While Len(aBrw25Pr) >0 .AND. lB5Lp 
			dbSelectArea('SB5')
			SB5->(dbSetOrder(1))
			If SB5->(dbSeek(aBrw25Pr[_i,1]))
				Reclock("SB5",.F.)
				IF Alltrim(aBrw25Pr[_i,2])$"01|02"
					SB5->B5_INSPAT	:="1"
					SB5->B5_CODATIV	:="02070000"
				ELSE
					SB5->B5_INSPAT	:="1"
					SB5->B5_CODATIV	:="99990010"
				ENDIF
				SB5->(MsUnlock())
			Else
				//_i += 1
				aCab	:= {}
				IF Alltrim(aBrw25Pr[_i,2])$"01|02"
					aCab:= {	{"B5_FILIAL"	,aBrw25Pr[_i,2]	,Nil},;		// Código identificador do produto            
								{"B5_COD"		,aBrw25Pr[_i,3]	,Nil},;		// Código identificador do produto
								{"B5_CEME"		,aBrw25Pr[_i,4]	,Nil},;		// Nome científico do produto
								{"B5_INSPAT"	,"1"			,Nil},;		// Nome científico do produto
								{"B5_CODATIV"	,"02070000"		,Nil}}		// Nome científico do produto
				ELSE
					aCab:= {	{"B5_FILIAL"	,aBrw25Pr[_i,2]	,Nil},;		// Código identificador do produto            
								{"B5_COD"		,aBrw25Pr[_i,3]	,Nil},;		// Código identificador do produto
								{"B5_CEME"		,aBrw25Pr[_i,4]	,Nil},;		// Nome científico do produto
								{"B5_INSPAT"	,"1"			,Nil},;		// Nome científico do produto
								{"B5_CODATIV"	,"99990010"		,Nil}}		// Nome científico do produto
				ENDIF
            	MSExecAuto({|x,y| Mata180(x,y)},aCab,3) //Inclusão				
				
			Endif
			ADEL(aBrw25Pr,_i)
			ASIZE(aBrw25Pr,Len(aBrw25Pr)-1)		
		EndDo

	Endif
	SysRefresh()	
	
	oPn25R1:FreeChildren()

Return

/*/{Protheus.doc} Static Function fAddC25
	Cria colunas no Browser INSS Desoneracao Resumo 
	@type  Function
	@author Abel Babini Filho
	@since 27/05/2019
	@version 03
	/*/
Static Function fAddC25( pLin ) 
     oBrw25Rs:AddColumn( TcColumn():New( aFlAux[pLin]+" - Vl.Cont"	, {|| aBrw25Rs[oBrw25Rs:nAt,pLin*2]}	, "@E 999,999,999.99"		,,,"RIGHT"	,050,.f.,.f.,,,,.f.,) ) 
     oBrw25Rs:AddColumn( TcColumn():New( aFlAux[pLin]+" - ICMS Ret"	, {|| aBrw25Rs[oBrw25Rs:nAt,pLin*2+1]}	, "@E 999,999,999.99"		,,,"RIGHT"	,050,.f.,.f.,,,,.f.,) ) 
     IF pLin == nQFIL
     	oBrw25Rs:AddColumn( TcColumn():New( "TOTAL - Vl.Cont"		, {|| aBrw25Rs[oBrw25Rs:nAt,pLin*2+2]}	, "@E 999,999,999.99"		,,,"RIGHT"	,050,.f.,.f.,,,,.f.,) ) 
     	oBrw25Rs:AddColumn( TcColumn():New( "TOTAL - ICMS Ret"		, {|| aBrw25Rs[oBrw25Rs:nAt,pLin*2+3]}	, "@E 999,999,999.99"		,,,"RIGHT"	,050,.f.,.f.,,,,.f.,) )      
     ENDIF
Return( NIL ) 

/*/{Protheus.doc} Static Function fAddC25b
	Cria colunas no Browser INSS Desoneracao Bloco P100
	@type  Function
	@author Abel Babini Filho
	@since 27/05/2019
	@version 03
	/*/
Static Function fAddC25b( pLin ) 
	If pLin == nQFIL +1
		oBrw25P1:AddColumn( TcColumn():New( "Total"			, {|| aBrw25P1[oBrw25P1:nAt,pLin+1]}	, "@E 999,999,999.99"					,,,"RIGHT"	,050,.f.,.f.,,,,.f.,) )
	Else
		oBrw25P1:AddColumn( TcColumn():New( aFlAux[pLin]	, {|| aBrw25P1[oBrw25P1:nAt,pLin+1]}	, "@E 999,999,999.99"		,,,"RIGHT"	,050,.f.,.f.,,,,.f.,) )
	Endif
	
Return( NIL ) 
//FIM Chamado n.040918 - Abel.Babini - Relatorio INSS para calculo da desoneração - 27/05/2019

/*/{Protheus.doc} Static Function SalvaXml
	Salva arquivo Excel
	@type  Function
	@author Abel Babini Filho
	@since 27/05/2019
	@version 03
	/*/
Static Function SalvaXml()

	oExcel:Activate()
	oExcel:GetXMLFile(cArquivo)

Return()

/*/{Protheus.doc} Static Function CriaExcel
³Cria objeto Excel do Relatório
@type  Function
@author Abel Babini Filho
@since 27/05/2019
@version 03
/*/
Static Function CriaExcel()
  oMsExcel := MsExcel():New()
	oMsExcel:WorkBooks:Open(cArquivo)
	oMsExcel:SetVisible( .T. )
	oMsExcel:Destroy()
Return() 

/*/{Protheus.doc} Static Function xRelBr24
Gera Relatório Ref. Crédito Presumido
@type  Function
@author Abel Babini Filho
@since 27/05/2019
@version 03
/*/
Static Function xRelBr24()
	Local aSays			:= {}
	Local aButtons		:= {}
	Local nOpca			:= 0
	Private oExcel     := FWMSEXCELEX():New()
	//Private cArquivo	:= cGetFile("Arquivo XML", "Selecione o diretório para salvar o relatório",,'C:\',.T.,GETF_RETDIRECTORY + GETF_LOCALHARD + GETF_NETWORKDRIVE)	
	Private oMsExcel   := NIL
	
	cArquivo := cPathRel +  'RCREDPRES_' + DTOS(DATE()) + STRTRAN(TIME(),':','') + '.XML'
	//+-----------------------------------------------+
	//|Monta Form Batch - Interface com o Usuario     |
	//+-----------------------------------------------+
	AADD(aSays,"Este programa tem a finalidade de Gerar um arquivo Excel " )
	AADD(aSays,"Relatorio de Crédito Presumido" )
    
	AADD(aButtons, { 1,.T.,{|o| nOpca:=1, o:oWnd:End(), Processa({||xRelBr24b()},"Gerando arquivo","Aguarde...")    }})
	AADD(aButtons, { 2,.T.,{|o| nOpca:=2, o:oWnd:End() }})	
	FormBatch( cCadastr, aSays, aButtons )
	
Return

/*/{Protheus.doc} Static Function xRelBr24b
Gera o arquivo Excel do Relatório de Crédito Presumido
@type  Function
@author Abel Babini Filho
@since 27/05/2019
@version 03
/*/
Static Function xRelBr24b()
	BEGIN SEQUENCE
		
		IF .NOT.( ApOleClient("MsExcel") )   // se nao existir o excel sai fora..
		    Alert("Nao Existe Excel Instalado")
            BREAK
        EndIF
        	
    	//Planilha1 - Resumo
    	Cab24P1()             
        GEx24P1()
        
    	//Planilha1 - Resumo
    	Cab24P5()             
        GEx24P5()

        //Planilha2 - Mercado Interno
    	Cab24P2()
        GEx24P2()
        
        //Planilha2 - Mercado Externo
    	Cab24P3()
        GEx24P3()

        //Planilha4 - Parametros
    	Cab24P4()
        GEx24P4()

        SalvaXml()
		CriaExcel()
	
	    MsgInfo("Arquivo Excel gerado!")    
	    
	END SEQUENCE

Return

/*/{Protheus.doc} Static Function Cab24P1
Gera o arquivo Excel do Relatório de Crédito Presumido
@type  Function
@author Abel Babini Filho
@since 27/05/2019
@version 03
/*/
Static Function Cab24P1() 
	//PLANILHA 1 - RESUMO
    oExcel:AddworkSheet(cFld24)
	oExcel:AddTable (cFld24,cFld24t1)
	oExcel:AddColumn(cFld24,cFld24t1,"Descrição"	,1,1)
	oExcel:AddColumn(cFld24,cFld24t1,"Valor"		,2,2)

RETURN(NIL)  

/*/{Protheus.doc} Static Function Cab24P2
Gera o arquivo Excel do Relatório de Crédito Presumido
@type  Function
@author Abel Babini Filho
@since 27/05/2019
@version 03
/*/
Static Function Cab24P2() 
	//PLANILHA 2 - MERCADO INTERNO
    oExcel:AddworkSheet(cFld242)
	oExcel:AddTable (cFld242,cFld24t2)
	oExcel:AddColumn(cFld242,cFld24t2,"Filial"  	,1,1)
	oExcel:AddColumn(cFld242,cFld24t2,"Cod.Forn."  	,1,1)
	oExcel:AddColumn(cFld242,cFld24t2,"Loja"		,1,1)
	oExcel:AddColumn(cFld242,cFld24t2,"Fornecedor"	,1,1)
	oExcel:AddColumn(cFld242,cFld24t2,"Cod.Produto"	,1,1)
	oExcel:AddColumn(cFld242,cFld24t2,"Produto"		,1,1)
	oExcel:AddColumn(cFld242,cFld24t2,"Dt.Entrada"	,1,1)
	oExcel:AddColumn(cFld242,cFld24t2,"Vl.Contabil"	,2,3)
	oExcel:AddColumn(cFld242,cFld24t2,"CST Pis"		,1,1)
	oExcel:AddColumn(cFld242,cFld24t2,"BC Pis"		,2,3)
	oExcel:AddColumn(cFld242,cFld24t2,"Aliq. Pis"	,2,3)
	oExcel:AddColumn(cFld242,cFld24t2,"Vl. Pis"		,2,3)
	oExcel:AddColumn(cFld242,cFld24t2,"CST Cofins"	,1,1)
	oExcel:AddColumn(cFld242,cFld24t2,"BC Cofins"	,2,3)
	oExcel:AddColumn(cFld242,cFld24t2,"Aliq. Cofins",2,3)
	oExcel:AddColumn(cFld242,cFld24t2,"Vl. Cofins"	,2,3)
	oExcel:AddColumn(cFld242,cFld24t2,"Nat BC Cred",1,1)
	oExcel:AddColumn(cFld242,cFld24t2,"Ind.Orig.Cred",1,1)
	oExcel:AddColumn(cFld242,cFld24t2,"CFOP"		,1,1)
	oExcel:AddColumn(cFld242,cFld24t2,"NCM"			,1,1)
	oExcel:AddColumn(cFld242,cFld24t2,"Nota"		,1,1)
	oExcel:AddColumn(cFld242,cFld24t2,"Serie"		,1,1)
	oExcel:AddColumn(cFld242,cFld24t2,"Intr.Normat.",1,1)
	
Return(NIL)

/*/{Protheus.doc} Static Function Cab24P3
Gera o arquivo Excel do Relatório de Crédito Presumido
@type  Function
@author Abel Babini Filho
@since 27/05/2019
@version 03
/*/
Static Function Cab24P3()
 
	//PLANILHA 3 - MERCADO EXTERNO
    oExcel:AddworkSheet(cFld243)
	oExcel:AddTable (cFld243,cFld24t3)
	oExcel:AddColumn(cFld243,cFld24t3,"Filial"		,1,1)
	oExcel:AddColumn(cFld243,cFld24t3,"Cod.Forn."	,1,1)
	oExcel:AddColumn(cFld243,cFld24t3,"Loja"		,1,1)
	oExcel:AddColumn(cFld243,cFld24t3,"Fornecedor"	,1,1)
	oExcel:AddColumn(cFld243,cFld24t3,"Cod.Produto"	,1,1)
	oExcel:AddColumn(cFld243,cFld24t3,"Produto"		,1,1)
	oExcel:AddColumn(cFld243,cFld24t3,"Dt.Entrada"	,1,1)
	oExcel:AddColumn(cFld243,cFld24t3,"Vl.Contábil"	,2,3)
	oExcel:AddColumn(cFld243,cFld24t3,"CST Pis"		,1,1)
	oExcel:AddColumn(cFld243,cFld24t3,"BC Pis"		,2,3)
	oExcel:AddColumn(cFld243,cFld24t3,"Aliq. Pis"	,2,3)
	oExcel:AddColumn(cFld243,cFld24t3,"Vl. Pis"		,2,3)
	oExcel:AddColumn(cFld243,cFld24t3,"CST Cofins"	,1,1)
	oExcel:AddColumn(cFld243,cFld24t3,"BC Cofins"	,2,3)
	oExcel:AddColumn(cFld243,cFld24t3,"Aliq. Cofins",2,3)
	oExcel:AddColumn(cFld243,cFld24t3,"Vl. Cofins"	,2,3)
	oExcel:AddColumn(cFld243,cFld24t3,"Nat BC Cred",1,1)
	oExcel:AddColumn(cFld243,cFld24t3,"Ind.Orig.Cred",1,1)
	oExcel:AddColumn(cFld243,cFld24t3,"CFOP"		,1,1)
	oExcel:AddColumn(cFld243,cFld24t3,"NCM"			,1,1)
	oExcel:AddColumn(cFld243,cFld24t3,"Nota"		,1,1)
	oExcel:AddColumn(cFld243,cFld24t3,"Serie"		,1,1)
	oExcel:AddColumn(cFld243,cFld24t3,"Intr.Normat.",1,1)
		
Return(NIL)

/*/{Protheus.doc} Static Function Cab24P4
Gera o arquivo Excel do Relatório de Crédito Presumido
@type  Function
@author Abel Babini Filho
@since 27/05/2019
@version 03
/*/
Static Function Cab24P4()
	//PLANILHA 4 - PARAMETROS
    oExcel:AddworkSheet(cFld244)
	oExcel:AddTable (cFld244,cFld24t4)
	oExcel:AddColumn(cFld244,cFld24t4,"Parametro"	,1,1)
	oExcel:AddColumn(cFld244,cFld24t4,"Conteudo"	,1,1)
	oExcel:AddColumn(cFld244,cFld24t4,"Descricao"	,1,1)
Return(NIL) 

/*/{Protheus.doc} Static Function Cab24P5
Gera o arquivo Excel do Relatório de Crédito Presumido
@type  Function
@author Abel Babini Filho
@since 27/05/2019
@version 03
/*/
Static Function Cab24P5()
 
	//PLANILHA 2 - RESUMO FILIAL
    oExcel:AddworkSheet(cFld245)
	oExcel:AddTable (cFld245,cFld24t5)
	oExcel:AddColumn(cFld245,cFld24t5,"Filial"								,1,1)
	oExcel:AddColumn(cFld245,cFld24t5,"Total Receita Industrializados"		,2,3)
	oExcel:AddColumn(cFld245,cFld24t5,"Total Receita Carne Aves Aliq. Zero"	,2,3)
	oExcel:AddColumn(cFld245,cFld24t5,"% Receita Industrializados"			,2,2)
	oExcel:AddColumn(cFld245,cFld24t5,"Total Vl. Contábil"					,2,3)
	oExcel:AddColumn(cFld245,cFld24t5,"Total BC Pis"						,2,3)
	oExcel:AddColumn(cFld245,cFld24t5,"Total Vl. Pis"						,2,3)
	oExcel:AddColumn(cFld245,cFld24t5,"Total BC Cofins"						,2,3)
	oExcel:AddColumn(cFld245,cFld24t5,"Total Vl. Cofins"					,2,3)
	oExcel:AddColumn(cFld245,cFld24t5,"||"									,1,1)
	oExcel:AddColumn(cFld245,cFld24t5,"Total Receita Exportação"			,2,3)
	oExcel:AddColumn(cFld245,cFld24t5,"Total Receita"						,2,3)
	oExcel:AddColumn(cFld245,cFld24t5,"% Receita Exportação"				,2,2)
	oExcel:AddColumn(cFld245,cFld24t5,"Total Vl. Contábil"					,2,3)
	oExcel:AddColumn(cFld245,cFld24t5,"Total BC Pis"						,2,3)
	oExcel:AddColumn(cFld245,cFld24t5,"Total Vl. Pis"						,2,3)
	oExcel:AddColumn(cFld245,cFld24t5,"Total BC Cofins"						,2,3)
	oExcel:AddColumn(cFld245,cFld24t5,"Total Vl. Cofins"					,2,3)
					
Return(NIL)

/*/{Protheus.doc} Static Function GEx24P1
Gera o arquivo Excel do Relatório de Crédito Presumido
@type  Function
@author Abel Babini Filho
@since 27/05/2019
@version 03
/*/
Static Function GEx24P1()

	//PLANILHA 1 - RESUMO
	oExcel:AddRow(cFld24,cFld24t1,{'MERCADO INTERNO'						,'' })
	oExcel:AddRow(cFld24,cFld24t1,{'Total Receita Industrializados'			, nTotInd }) 
	oExcel:AddRow(cFld24,cFld24t1,{'Total Receita Carne Aves Aliq. Zero'	, nTotAlZr }) 
	oExcel:AddRow(cFld24,cFld24t1,{'% Receita Industrializados'				, nPerMI }) 
	oExcel:AddRow(cFld24,cFld24t1,{'Total Vl. Contábil'						, nTVlMI })
	oExcel:AddRow(cFld24,cFld24t1,{'Total Vl. Pis'							, nTVlPMI })
	oExcel:AddRow(cFld24,cFld24t1,{'Total Vl. Cofins'						, nTVlCMI })
	oExcel:AddRow(cFld24,cFld24t1,{''										,''})
	oExcel:AddRow(cFld24,cFld24t1,{'MERCADO EXTERNO'						,''})
	oExcel:AddRow(cFld24,cFld24t1,{'Total Receita Exportação'				, nTotInME })
	oExcel:AddRow(cFld24,cFld24t1,{'Total Receita'							, nTotExCA }) 
	oExcel:AddRow(cFld24,cFld24t1,{'% Receita Exportação'					, nPerME }) 
	oExcel:AddRow(cFld24,cFld24t1,{'Total Vl. Contábil'						, nTVlME })
	oExcel:AddRow(cFld24,cFld24t1,{'Total Vl. Pis'							, nTVlPME })
	oExcel:AddRow(cFld24,cFld24t1,{'Total Vl. Cofins'						, nTVlCME }) 

Return

/*/{Protheus.doc} Static Function GEx24P5
Gera o arquivo Excel do Relatório de Crédito Presumido
@type  Function
@author Abel Babini Filho
@since 27/05/2019
@version 03
/*/
Static Function GEx24P5()
	Local nExcel1 := 0
	//PLANILHA 2 - RESUMO POR FILIAL		
	FOR nExcel1 := 1 TO Len(aTBr24FI)
		oExcel:AddRow(cFld245,cFld24t5,{;
						aTBr24FI[nExcel1][01],; 
						nTotInd,;
						nTotAlZr,;
						nPerMI,;
						aTBr24FI[nExcel1][02],; 
						aTBr24FI[nExcel1][03],; 
						aTBr24FI[nExcel1][04],; 
						aTBr24FI[nExcel1][05],;
						aTBr24FI[nExcel1][06],;
						"",;
						nTotInME,;
						nTotExCA,;
						nPerME,;
						aTBr24FE[nExcel1][02],; 
						aTBr24FE[nExcel1][03],; 
						aTBr24FE[nExcel1][04],; 
						aTBr24FE[nExcel1][05],;
						aTBr24FE[nExcel1][06];
						})	
	NEXT nExcel1
	//ADICIONA LINHA EM BRANCA
	oExcel:AddRow(cFld245,cFld24t5,;
					{'',; 
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					''})	

	//Acrescenta Total Geral
	oExcel:AddRow(cFld245,cFld24t5,{;
					"TOTAL",; 
					nTotInd,;
					nTotAlZr,;
					nPerMI,;
					nTVlMI,; 
					"",; 
					nTVlPMI,; 
					"",;
					nTVlCMI,;
					"",;
					nTotInME,;
					nTotExCA,;
					nPerME,;
					nTVlME,; 
					"",; 
					nTVlPME,; 
					"",;
					nTVlCME;
					})		
Return

/*/{Protheus.doc} Static Function GEx24P2
Gera o arquivo Excel do Relatório de Crédito Presumido
@type  Function
@author Abel Babini Filho
@since 27/05/2019
@version 03
/*/
Static Function GEx24P2()
	Local nExcel1 := 0
	//PLANILHA 2 - MERCADO INTERNO			
	FOR nExcel1 := 1 TO Len(aBrw24MI)
		oExcel:AddRow(cFld242,cFld24t2,;
						{aBrw24MI[nExcel1][23],;
						aBrw24MI[nExcel1][01],; 
						aBrw24MI[nExcel1][02],; 
						aBrw24MI[nExcel1][03],; 
						aBrw24MI[nExcel1][04],; 
						aBrw24MI[nExcel1][05],;
						aBrw24MI[nExcel1][06],;
						aBrw24MI[nExcel1][07],;
						aBrw24MI[nExcel1][08],;
						aBrw24MI[nExcel1][09],;
						aBrw24MI[nExcel1][10],;
						aBrw24MI[nExcel1][11],;
						aBrw24MI[nExcel1][12],;
						aBrw24MI[nExcel1][13],;
						aBrw24MI[nExcel1][14],;
						aBrw24MI[nExcel1][15],;
						aBrw24MI[nExcel1][16],;
						aBrw24MI[nExcel1][17],;
						aBrw24MI[nExcel1][18],;
						aBrw24MI[nExcel1][19],;
						aBrw24MI[nExcel1][20],;
						aBrw24MI[nExcel1][21],;
						aBrw24MI[nExcel1][22];
						})	
	NEXT nExcel1
	//ADICIONA LINHA EM BRANCA
	oExcel:AddRow(cFld242,cFld24t2,;
					{'',; 
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'';
					})	
	
Return

/*/{Protheus.doc} Static Function GEx24P3
Gera o arquivo Excel do Relatório de Crédito Presumido
@type  Function
@author Abel Babini Filho
@since 27/05/2019
@version 03
/*/
Static Function GEx24P3()
	Local nExcel1 := 0
	//PLANILHA 3 - MERCADO EXTERNO			
	FOR nExcel1 := 1 TO Len(aBrw24ME)
		oExcel:AddRow(cFld243,cFld24t3,;
						{aBrw24ME[nExcel1][23],;
						aBrw24ME[nExcel1][01],; 
						aBrw24ME[nExcel1][02],; 
						aBrw24ME[nExcel1][03],; 
						aBrw24ME[nExcel1][04],; 
						aBrw24ME[nExcel1][05],;
						aBrw24ME[nExcel1][06],;
						aBrw24ME[nExcel1][07],;
						aBrw24ME[nExcel1][08],;
						aBrw24ME[nExcel1][09],;
						aBrw24ME[nExcel1][10],;
						aBrw24ME[nExcel1][11],;
						aBrw24ME[nExcel1][12],;
						aBrw24ME[nExcel1][13],;
						aBrw24ME[nExcel1][14],;
						aBrw24ME[nExcel1][15],;
						aBrw24ME[nExcel1][16],;
						aBrw24ME[nExcel1][17],;
						aBrw24ME[nExcel1][18],;
						aBrw24ME[nExcel1][19],;
						aBrw24ME[nExcel1][20],;
						aBrw24ME[nExcel1][21],;
						aBrw24ME[nExcel1][22];
						})	
	NEXT nExcel1
	//ADICIONA LINHA EM BRANCA
	oExcel:AddRow(cFld243,cFld24t3,;
					{'',; 
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'';
					})	

Return

/*/{Protheus.doc} Static Function GEx24P4
Gera o arquivo Excel do Relatório de Crédito Presumido
@type  Function
@author Abel Babini Filho
@since 27/05/2019
@version 03
/*/
Static Function GEx24P4()
	//PLANILHA4 - PARAMETROS
	oExcel:AddRow(cFld244,cFld24t4,{'Parâmetros Comuns (Mercado Interno e Externo)',;
									'',;
									'';
									 }) 

	oExcel:AddRow(cFld244,cFld24t4,{'MV_CPPCAGR',;
									cCPPCAGR,;
									'Indica se ira processar credito presumido de PIS e Cofins conforme lei 12.058/2009 e Instrução';
									 }) 

	oExcel:AddRow(cFld244,cFld24t4,{'MV_CAJCPP',;
									cCAJCPPC,;
									'Informar o código que será utilizado no ajuste de credito presumido da lei 12.058/2009 que conforme tabela 4.3.8 da RFB';
									 }) 

	oExcel:AddRow(cFld244,cFld24t4,{'MV_#NCMCPR',;
									cXNCMCPR,;
									'Informar o NCM para cálculo da Receita Total, utilizado tanto no Mercado Interno quanto Externo';
									 }) 

	oExcel:AddRow(cFld244,cFld24t4,{'Parâmetros Específicos Mercado Interno',;
									'',;
									'';
									 }) 

	oExcel:AddRow(cFld244,cFld24t4,{'MV_#ACPPCI',;
									cXACPPCI,;
									'Informar a alíquota de Credito Presumido de PIS e Cofins, com base na lei 10925/2004';
									 }) 

	oExcel:AddRow(cFld244,cFld24t4,{'MV_#CSTCPI',;
									cXCSTCPI,;
									'CST que será escriturado no registro F100 para o cálculo de credito presumido referente ao Mercado Interno Art.8 da Lei 10.925/2004';
									 }) 

	oExcel:AddRow(cFld244,cFld24t4,{'MV_#INCPMI',;
									cXINCPMI,;
									'Informar a descrição que será utilizada no ajuste de Crédito Presumido Mercado Interno.';
									 }) 
									 
	oExcel:AddRow(cFld244,cFld24t4,{'MV_#NCMEMB',;
									cXNCMEMB,;
									'NCM dos prod. Embutidos para cálculo das Receitas com Embutidos';
									 }) 
									 
	oExcel:AddRow(cFld244,cFld24t4,{'MV_#CFCPMI',;
									cXCFCPMI,;
									'CFOP a serem considerados para filtrar as NF´s de Entrada com direito a crédito';
									 }) 

	oExcel:AddRow(cFld244,cFld24t4,{'Parâmetros Específicos Mercado Externo',;
									'',;
									'';
									 }) 
									 
	oExcel:AddRow(cFld244,cFld24t4,{'MV_ACPPCAG',;
									cACPPCAG,;
									'Informar a alíquota de Credito Presumido de PIS e Cofins, com base na lei 12.058/2009 N RFB nº 977, de 14 novembro de 2009';
									 }) 
									 
	oExcel:AddRow(cFld244,cFld24t4,{'MV_CSTPRES',;
									cCSTPRES,;
									'CST que sera escriturado no registro F100 para o cálculo de credito presumido conforme lei 12.058/2';
									 }) 
									 
	oExcel:AddRow(cFld244,cFld24t4,{'MV_DAPCCPA',;
									cDAPCCPA,;
									'Informar a descrição que será utilizada no ajuste de credito presumido da lei 12.058/2009';
									 }) 
									 
	oExcel:AddRow(cFld244,cFld24t4,{'MV_NCMCPPC',;
									cNCMCPPC,;
									'NCM de exportação que serão utilizados para a geração do credito presumido de PIS e COFINS conforme lei 12.058/2009';
									 }) 
									 
	oExcel:AddRow(cFld244,cFld24t4,{'MV_#CPRCEP',;
									cXCPRCEP,;
									'CFOP a serem utilizados como Receita de Exportação.';
									 }) 

	oExcel:AddRow(cFld244,cFld24t4,{'MV_NCMCREP',;
									cNCMCREP,;
									'NCM dos prod. agropec. utilizados c/ insumos na fabricação de prod. destinado a alimentação humana  ou animal lei 12.058/2009';
									 }) 
									 
	oExcel:AddRow(cFld244,cFld24t4,{'MV_#CFCPEX',;
									cXCFCPEX,;
									'CFOP a serem considerados para filtrar as NF´s de Entrada com direito a crédito';
									 }) 

Return

/*/{Protheus.doc} Static Function xABrw24
Relatório de Crédito Presumido
@type  Function
@author Abel Babini Filho
@since 27/05/2019
@version 03
/*/
Static Function xABrw24()
	Local aTotSai		:= {}
	Local aTotEnt		:= {}
	Local aTotSEmb		:= {}
	Local aTotEntI		:= {}
	Local aCrePresu		:= {}
	// Local cCstPE		:= GetNewPar("MV_CSTPRES","62")
	Local cCstPI		:= GetNewPar("MV_#CSTCPI","61")
	
	Local cFilBk		:= cFilAnt
	Local _nFil := 0
	Local nX := 0
	
	//Verifica a Receita de Exportação
	aTotSai   := U_F1SPresu(aRet[1],aRet[2],'*')
	
	//Verifica a Receita de Embutidos
	aTotSEmb   := U_F1SCPrEm(aRet[1],aRet[2],'*')
	
	//
	aBrw24ME	:= {}
	nTVlME		:= 0	// Total Vl. Contabil
	nTBCPME		:= 0	// Total BC Pis Merc  Externo
	nTBCCME		:= 0	// Total BC Cofins Merc Externo
	nTVlPME		:= 0	// Total Vl Pis Merc Externo
	nTVlCME		:= 0	// Total Vl Cofins Merc Externo

	aBrw24MI	:= {}
	nTVlMI		:= 0	// Total Vl. Contabil
	nTBCPMI		:= 0	// Total BC Pis Merc Interno
	nTBCCMI		:= 0	// Total BC Cofins Merc Interno
	nTVlPMI		:= 0	// Total Vl Pis Merc Interno
	nTVlCMI		:= 0	// Total Vl Cofins Merc Interno

	aTBr24FE	:= {}
	aTBr24FI	:= {}
	
	For _nFil := 1 to Len(aFilSlCP)
		cFilAnt	:= aFilSlCP[_nFil]
		
		nTVlMEF		:= 0	// Total Vl. Contabil na Filial
		nTBCPMEF	:= 0	// Total BC Pis Merc  Externo na Filial
		nTBCCMEF	:= 0	// Total BC Cofins Merc Externo na Filial
		nTVlPMEF	:= 0	// Total Vl Pis Merc Externo na Filial
		nTVlCMEF	:= 0	// Total Vl Cofins Merc Externo na Filial
	
		nTVlMIF		:= 0	// Total Vl. Contabil na Filial
		nTBCPMIF	:= 0	// Total BC Pis Merc Interno na Filial
		nTBCCMIF	:= 0	// Total BC Cofins Merc Interno na Filial
		nTVlPMIF	:= 0	// Total Vl Pis Merc Interno na Filial
		nTVlCMIF	:= 0	// Total Vl Cofins Merc Interno na Filial

		AaDD(aTotEnt	,U_F1EPresu(aRet[1],aRet[2],'*')) //Verifica as Compras para Calculo do  Mercado Externo
		AaDD(aTotEntI	,U_F1ECPrIn(aRet[1],aRet[2],'*')) //Verifica as Compras para Calculo do Mercado Mercado Interno
	
		nTotInME	:= aTotSai[1]		//Total de Insumos Animal + Vegetal Mercado Externo
		nTotInMI	:= 0				//Total de Insumos Animal + Vegetal Mercado Interno
		nTotExCA	:= aTotSai[2]		//Total Exportação Carne de Aves
		nTotExNC	:= 0				//Total Exportação Não Comestíveis
		nTotAlZr	:= aTotSEmb[2]		//Total Venda Carna de Aves Aliquota Zero
		nTotInd		:= aTotSEmb[1]		//Total Industrializado
	
	
		If aTotSai[1] > 0
			nPerME :=  Round((aTotSai[1] * 100) / aTotSai[2],2)
			For nX := 1 to Len(aTotEnt[_nFil])
				If !Empty(aTotEnt[_nFil,nX,3])
				
					aCrePresu := U_F100CrPr(aTotSai,aTotEnt[_nFil],aRet[2], nX)  
					
					//INICIO Abel Babini-10/06/2019-Ch.049766|Ajuste Campo Valor Contábil
					//nTVlME	+= aCrePresu[8]	// Total Vl. Contabil
					nTVlME	+= aCrePresu[24]	// Total Vl. Contabil
					//FIM Abel Babini-10/06/2019-Ch.049766|Ajuste Campo Valor Contábil
					nTBCPME	+= aCrePresu[8]	// Total BC Pis Merc  Externo
					nTBCCME	+= aCrePresu[8]	// Total BC Cofins Merc Externo
					nTVlPME	+= aCrePresu[1]	// Total Vl Pis Merc Externo
					nTVlCME	+= aCrePresu[2]	// Total Vl Cofins Merc Externo

					//INICIO Abel Babini-10/06/2019-Ch.049766|Ajuste Campo Valor Contábil
					//nTVlMEF		+= aCrePresu[8]	// Total Vl. Contabil na Filial
					nTVlMEF		+= aCrePresu[24]	// Total Vl. Contabil na Filial
					//FIM Abel Babini-10/06/2019-Ch.049766|Ajuste Campo Valor Contábil
					nTBCPMEF	+= aCrePresu[8]	// Total BC Pis Merc  Externo na Filial
					nTBCCMEF	+= aCrePresu[8]	// Total BC Cofins Merc Externo na Filial
					nTVlPMEF	+= aCrePresu[1]	// Total Vl Pis Merc Externo na Filial
					nTVlCMEF	+= aCrePresu[2]	// Total Vl Cofins Merc Externo na Filial

					Aadd( aBrw24ME, {;
									Substr(aCrePresu[11],1,6) ,;// F100 - 03 - COD_PART (Entrada= SA2->A2_COD, Saida= SA1->A1_COD)
									aCrePresu[17] ,;// F100 - 20 - LOJA (Entarada = SA2->A2_LOJA, Saida = SA1->A1_LOJA)
									aCrePresu[20] ,;// NOME FORNECEDOR								
									aCrePresu[12] ,;// F100 - 04 - COD_ITEM
									aCrePresu[21] ,;// DESCRIÇÃO PRODUTO
									aCrePresu[19] ,;// DT_ENTRADA
									aCrePresu[24]  ,;// F100 - 06 - VL_OPER
									cCstPI ,; 	// F100 - 07 - CST_PIS
									aCrePresu[8] ,; // F100 - 08 - VL_BC_PIS
									aCrePresu[9] ,; // F100 - 09 - ALIQ_PIS
									aCrePresu[1] ,; // F100 - 10 - VL_PIS
									cCstPI ,; 	// F100 - 11 - CST_COFINS
									aCrePresu[8] ,; // F100 - 12 - VL_BC_COFINS
									aCrePresu[10] ,;// F100 - 13 - ALIQ_COFINS
									aCrePresu[2] ,; // F100 - 14 - VL_COFINS
									'13' ,; 		// F100 - 15 - NAT_BC_CRED
									aCrePresu[13] ,;// F100 - 16 - IND_ORIG_CRED
									aCrePresu[22] ,;// CFOP
									aCrePresu[23] ,;// NCM
									aCrePresu[14] ,;// NOTA FISCAL
									aCrePresu[15] ,;// SERIE NOTA
									aCrePresu[5] ,; // F100 - 19 - DESC_DOC_OPER
									cFilAnt })
				EndIf
			Next nX
		EndIf

		If aTotSEmb[1]>0
			nPerMI :=  Round((aTotSEmb[1] * 100) / aTotSEmb[2],2)
			For nX := 1 to Len(aTotEntI[_nFil])
				
				If !Empty(aTotEntI[_nFil,nX,3])
				
					aCrePresu := U_F100CPrI(aTotSEmb,aTotEntI[_nFil],aRet[2], nX)  
					
					//INICIO Abel Babini-10/06/2019-Ch.049766|Ajuste Campo Valor Contábil
					//nTVlMI	+= aCrePresu[8]	// Total Vl. Contabil
					nTVlMI	+= aCrePresu[24]	// Total Vl. Contabil
					//FIM Abel Babini-10/06/2019-Ch.049766|Ajuste Campo Valor Contábil
					nTBCPMI	+= aCrePresu[8]	// Total BC Pis Merc Interno
					nTBCCMI	+= aCrePresu[8]	// Total BC Cofins Merc Interno
					nTVlPMI	+= aCrePresu[1]	// Total Vl Pis Merc Interno
					nTVlCMI	+= aCrePresu[2]	// Total Vl Cofins Merc Interno

					//INICIO Abel Babini-10/06/2019-Ch.049766|Ajuste Campo Valor Contábil
					//nTVlMIF		+= aCrePresu[8]	// Total Vl. Contabil na Filial
					nTVlMIF		+= aCrePresu[24]	// Total Vl. Contabil na Filial
					//FIM Abel Babini-10/06/2019-Ch.049766|Ajuste Campo Valor Contábil
					nTBCPMIF	+= aCrePresu[8]	// Total BC Pis Merc Interno na Filial
					nTBCCMIF	+= aCrePresu[8]	// Total BC Cofins Merc Interno na Filial
					nTVlPMIF	+= aCrePresu[1]	// Total Vl Pis Merc Interno na Filial
					nTVlCMIF	+= aCrePresu[2]	// Total Vl Cofins Merc Interno na Filial
		     		
					Aadd( aBrw24MI, {;
									Substr(aCrePresu[11],1,6) ,;// F100 - 03 - COD_PART (Entrada= SA2->A2_COD, Saida= SA1->A1_COD)
									aCrePresu[17] ,;// F100 - 20 - LOJA (Entarada = SA2->A2_LOJA, Saida = SA1->A1_LOJA)
									aCrePresu[20] ,;// NOME FORNECEDOR								
									aCrePresu[12] ,;// F100 - 04 - COD_ITEM
									aCrePresu[21] ,;// DESCRIÇÃO PRODUTO
									aCrePresu[19] ,;// DT_ENTRADA
									aCrePresu[24]  ,;// F100 - 06 - VL_OPER
									cCstPI ,; 	// F100 - 07 - CST_PIS
									aCrePresu[8] ,; // F100 - 08 - VL_BC_PIS
									aCrePresu[9] ,; // F100 - 09 - ALIQ_PIS
									aCrePresu[1] ,; // F100 - 10 - VL_PIS
									cCstPI ,; 	// F100 - 11 - CST_COFINS
									aCrePresu[8] ,; // F100 - 12 - VL_BC_COFINS
									aCrePresu[10] ,;// F100 - 13 - ALIQ_COFINS
									aCrePresu[2] ,; // F100 - 14 - VL_COFINS
									'13' ,; 		// F100 - 15 - NAT_BC_CRED
									aCrePresu[13] ,;// F100 - 16 - IND_ORIG_CRED
									aCrePresu[22] ,;// CFOP
									aCrePresu[23] ,;// NCM
									aCrePresu[14] ,;// NOTA FISCAL
									aCrePresu[15] ,;// SERIE NOTA
									aCrePresu[5] ,; // F100 - 19 - DESC_DOC_OPER
									cFilAnt })
				EndIf
			Next nX
		Endif
		//Totais Mercado Externo
		aAdd(aTBr24FE, {;
			cFilAnt,;
			nTVlMEF,;	// Total Vl. Contabil
			nTBCPMEF,;	// Total BC Pis Merc  Externo
			nTBCCMEF,;	// Total BC Cofins Merc Externo
			nTVlPMEF,;	// Total Vl Pis Merc Externo
			nTVlCMEF;	// Total Vl Cofins Merc Externo
			})

		//Totais Mercado Interno
		aAdd(aTBr24FI, {;
			cFilAnt,;
			nTVlMIF,;	// Total Vl. Contabil
			nTBCPMIF,;	// Total BC Pis Merc  Externo
			nTBCCMIF,;	// Total BC Cofins Merc Externo
			nTVlPMIF,;	// Total Vl Pis Merc Externo
			nTVlCMIF;	// Total Vl Cofins Merc Externo
			})

	Next _nFil
	cFilAnt		:= cFilBk
	//
	SysRefresh()
Return

//INICIO Chamado n.040918 - Abel.Babini - Relatorio INSS para calculo da desoneração - 27/05/2019
/*/{Protheus.doc} Static Function xABrw25
Carrega da dados Ref. INSS DESONERAÇÃO 
@type  Function
@author Abel Babini Filho
@since 27/05/2019
@version 03
/*/
Static Function xABrw25()
	Local _i := 0
	Local _j := 0
	Local i := 0
	Local j := 0
	Local nPFilx := 0
	Local nPCFOP := 0

	If Select(cAlsB25Dt) > 0
		(cAlsB25Dt)->(dbCloseArea())
	Endif
	cAlsB25Dt:=GetNextAlias()

	BeginSQL  Alias cAlsB25Dt
		//SELECIONA AS NFS DE COMPRAS DE UNIFORME QUE CALCULARAM ICMS DENTRO DO MÊS, PERMITINDO CRÉDITO
		column FT_ENTRADA as Date
		column FT_EMISSAO as Date
		SELECT 
			SFT.FT_FILIAL, 
			SFT.FT_ENTRADA, 
			SFT.FT_EMISSAO,
			SFT.FT_SERIE, 
			SFT.FT_NFISCAL, 
			SFT.FT_CLIEFOR, 
			SFT.FT_LOJA,
			SA1.A1_NOME, 
			SFT.FT_TIPO, 
			SFT.FT_CFOP, 
			SFT.FT_VALCONT,
			//IIF(FT_CFOP < '5000',-SFT.FT_VALCONT,SFT.FT_VALCONT) AS FT_VALCONT, 
			SFT.FT_ICMSRET, 
			SFT.FT_ESPECIE,  
			SFT.FT_OBSERV, 
			SFT.FT_PRODUTO,
			SB1.B1_DESC, 
			SFT.FT_TES,
			SB5.B5_INSPAT,
			SB5.B5_CODATIV
		FROM 
			%TABLE:SFT% SFT
		LEFT JOIN %TABLE:SA1% SA1 ON
			SA1.%notDel%
		AND SA1.A1_COD = SFT.FT_CLIEFOR
		AND SA1.A1_LOJA = SFT.FT_LOJA
		AND ((SFT.FT_CFOP > '5000' AND SFT.FT_TIPO NOT IN ('D','B')) OR (SFT.FT_CFOP < '5000' AND SFT.FT_TIPO IN ('D','B')))
		LEFT JOIN %TABLE:SB1% SB1 ON
			SB1.%notDel%
		AND SB1.B1_COD = SFT.FT_PRODUTO
		LEFT JOIN %TABLE:SB5% SB5 ON
			SB5.%notDel%
		AND SB5.B5_COD = SFT.FT_PRODUTO
		AND SB5.B5_FILIAL = SFT.FT_FILIAL		
		WHERE 
			SFT.%notdel%
		AND SFT.FT_FILIAL IN %Exp:cFilIn%
		AND SFT.FT_ENTRADA>=%Exp:DToS(_mvpr01)% AND SFT.FT_ENTRADA<=%Exp:DToS(_mvpr02)% 
		AND SFT.FT_DTCANC=''
		AND SFT.FT_CFOP IN %Exp:cP25A01b%		
		ORDER BY SFT.FT_FILIAL, SFT.FT_ENTRADA,SFT.FT_CLIEFOR,SFT.FT_LOJA,SFT.FT_SERIE,SFT.FT_NFISCAL
	EndSQL
	aBrw25Dt	:= {}
	aCFAux		:= {}
	aFlAux		:= {}
	nQCFOP		:= 0
	nQFIL		:= 0
	nQPrC		:= 0
	(cAlsB25Dt)->(dbGoTop())
	While !(cAlsB25Dt)->(Eof())
		//PREENCHE ARRAY AUXILIAR CFOP
		IF ASCAN(aCFAux,Alltrim((cAlsB25Dt)->FT_CFOP)) = 0
			AADD(aCFAux,Alltrim((cAlsB25Dt)->FT_CFOP))
			nQCFOP += 1
		Endif
		//PREENCHE ARRAY AUXILIAR FILIAL
		IF ASCAN(aFlAux,Alltrim((cAlsB25Dt)->FT_FILIAL)) = 0
			AADD(aFlAux,Alltrim((cAlsB25Dt)->FT_FILIAL))
			nQFIL += 1
		Endif
		
		//PREENCHE ARRAY DE PRODUTOS COM ERRO NO COMPLEMENTO
		
		IF Alltrim((cAlsB25Dt)->FT_FILIAL) $ "01|02" .AND. (Alltrim((cAlsB25Dt)->B5_INSPAT)!="1" .OR. Alltrim((cAlsB25Dt)->B5_CODATIV)!="02070000")
			IF ASCAN(aBrw25Pr,{|X| Alltrim(X[1]) == AllTrim((cAlsB25Dt)->FT_FILIAL)+AllTrim((cAlsB25Dt)->FT_PRODUTO) }) = 0
				AADD(aBrw25Pr,{Alltrim((cAlsB25Dt)->FT_FILIAL)+Alltrim((cAlsB25Dt)->FT_PRODUTO),(cAlsB25Dt)->FT_FILIAL,(cAlsB25Dt)->FT_PRODUTO,(cAlsB25Dt)->B1_DESC,(cAlsB25Dt)->B5_INSPAT,(cAlsB25Dt)->B5_CODATIV})
			ENDIF
		ELSEIF !(Alltrim((cAlsB25Dt)->FT_FILIAL) $ "01|02") .AND. (Alltrim((cAlsB25Dt)->B5_INSPAT)!="1" .OR. Alltrim((cAlsB25Dt)->B5_CODATIV)!="99990010")
			IF ASCAN(aBrw25Pr,{|X| Alltrim(X[1]) == AllTrim((cAlsB25Dt)->FT_FILIAL)+AllTrim((cAlsB25Dt)->FT_PRODUTO) }) = 0
				AADD(aBrw25Pr,{Alltrim((cAlsB25Dt)->FT_FILIAL)+Alltrim((cAlsB25Dt)->FT_PRODUTO),(cAlsB25Dt)->FT_FILIAL,(cAlsB25Dt)->FT_PRODUTO,(cAlsB25Dt)->B1_DESC,(cAlsB25Dt)->B5_INSPAT,(cAlsB25Dt)->B5_CODATIV})
			ENDIF		
		ENDIF
		
		//IF ASCAN(aBrw25Pr,Alltrim((cAlsB25Dt)->FT_FILIAL)+Alltrim((cAlsB25Dt)->FT_PRODUTO)) = 0
		//	AADD(aFlAux,Alltrim((cAlsB25Dt)->FT_FILIAL))
		//	nQPrC	+= 1
		//Endif
		
		
		AADD(aBrw25Dt,{;
						(cAlsB25Dt)->FT_FILIAL,; 
						(cAlsB25Dt)->FT_ENTRADA,; 
						(cAlsB25Dt)->FT_EMISSAO,;
						(cAlsB25Dt)->FT_SERIE,; 
						(cAlsB25Dt)->FT_NFISCAL,; 
						(cAlsB25Dt)->FT_CLIEFOR,; 
						(cAlsB25Dt)->FT_LOJA,;
						(cAlsB25Dt)->A1_NOME,; 
						(cAlsB25Dt)->FT_TIPO,; 
						(cAlsB25Dt)->FT_CFOP,; 
						(cAlsB25Dt)->FT_VALCONT,; 
						(cAlsB25Dt)->FT_ICMSRET,;
						(cAlsB25Dt)->FT_ESPECIE,;
						(cAlsB25Dt)->FT_OBSERV,; 
						(cAlsB25Dt)->FT_PRODUTO,;
						(cAlsB25Dt)->B1_DESC,; 
						(cAlsB25Dt)->FT_TES;
						})
		(cAlsB25Dt)->(dbSkip())
	EndDo
	
	ASORT(aCFAux)
	ASORT(aFlAux)
	
	//Inicializa Array
	nPCFOP		:= Len(aCFAux)
	nPFil		:= Len(aFlAux)
	aBrw25Rs 	:= Array(nPCFOP,((nPFil+1)*2)+1)//Qtd de Filiais+coluna total * 2 (vl contabil e vl icms ret) + coluna do cfop
	aTt25v01	:= Array(nPFil)
	aTt25v02	:= Array(nPFil)
	aTt25v03	:= Array(nPFil)
	aTt25v04	:= Array(nPFil)
	aBrw25P1	:= Array(5,nPFil+2)
	
	For i:=1 to nPFil
		aTt25v01[i]	:= 0 
		aTt25v02[i]	:= 0
		aTt25v03[i]	:= 0
		aTt25v04[i]	:= 0
	Next
	
	For nPCFOP:= 1 to Len(aCFAux)
		For nPFilx:=1 to ((Len(aFlAux)+1)*2)+1
			If nPFilx == 1
				aBrw25Rs[nPCFOP,nPFilx]:= ""
			Else
				aBrw25Rs[nPCFOP,nPFilx]:= 0
			Endif
		Next nPFilx
	Next nPCFOP

	(cAlsB25Dt)->(dbGoTop())
	While !(cAlsB25Dt)->(Eof())
		nPCFOP	:= ASCAN(aCFAux,Alltrim((cAlsB25Dt)->FT_CFOP))
		nPFil 	:= ASCAN(aFlAux,Alltrim((cAlsB25Dt)->FT_FILIAL))
		If nPCFOP == 0 .OR. nPFil == 0
			Alert('Erro!')
		Else
			IF nPFil == 1
				aBrw25Rs[nPCFOP,1]			:= Alltrim((cAlsB25Dt)->FT_CFOP)
				aBrw25Rs[nPCFOP,nPFil+1]	+= IIF( (cAlsB25Dt)->FT_CFOP > "5000", (cAlsB25Dt)->FT_VALCONT ,-(cAlsB25Dt)->FT_VALCONT)
				aBrw25Rs[nPCFOP,nPFil+2]	+= IIF( (cAlsB25Dt)->FT_CFOP > "5000", (cAlsB25Dt)->FT_ICMSRET ,-(cAlsB25Dt)->FT_ICMSRET)
			ELSE
				aBrw25Rs[nPCFOP,1]			:= Alltrim((cAlsB25Dt)->FT_CFOP)
				aBrw25Rs[nPCFOP,nPFil*2]	+= IIF( (cAlsB25Dt)->FT_CFOP > "5000", (cAlsB25Dt)->FT_VALCONT ,-(cAlsB25Dt)->FT_VALCONT)
				aBrw25Rs[nPCFOP,nPFil*2+1]	+= IIF( (cAlsB25Dt)->FT_CFOP > "5000", (cAlsB25Dt)->FT_ICMSRET ,-(cAlsB25Dt)->FT_ICMSRET)
			
			ENDIF
		Endif
		
		//Monta array de ICMS ST		
		If Alltrim((cAlsB25Dt)->FT_CFOP)$cP25A02	//'5401|6401'
			aTt25v01[nPFil]	+= (cAlsB25Dt)->FT_ICMSRET
		Endif
		
		//Monta array de Exportação		
		If Alltrim((cAlsB25Dt)->FT_CFOP)$cP25A03	//'7101'
			aTt25v02[nPFil]	+= (cAlsB25Dt)->FT_VALCONT
		Endif

		//Monta array de Devolucoes		
		If Alltrim((cAlsB25Dt)->FT_CFOP)$cP25A04	//'1201|1410|2201'
			aTt25v03[nPFil]	+= (cAlsB25Dt)->FT_VALCONT
		Endif
		If Alltrim((cAlsB25Dt)->FT_CFOP)$cP25A05	//'1410'
			aTt25v03[nPFil]	-= (cAlsB25Dt)->FT_ICMSRET
		Endif

		//Monta array de Imobilizado		
		If Alltrim((cAlsB25Dt)->FT_CFOP)$cP25A06 //''
			aTt25v04[nPFil]	+= (cAlsB25Dt)->FT_VALCONT
		Endif
		(cAlsB25Dt)->(dbSkip())
	EndDo
	
	//Inicializa coluna 1 do array Consolidado do Bloco P100
	aBrw25P1[1,1]	:= "Valor Total da Receita Bruta do Estabelecimento no Periodo"
	aBrw25P1[2,1]	:= "Valor da Receita Bruta Total do Estabelecimento Vinculada ao Codigo Atividade"
	aBrw25P1[3,1]	:= "Valor da Exclusão da Receita Bruta"
	aBrw25P1[4,1]	:= "Valor da Base de Calculo Contribuição sobre o valor da Receita Bruta"
	aBrw25P1[5,1]	:= "Valor da Contribuição Previdenciária"
	For i:= 1 to 5
		For j := 1 to nQFIL+1
			aBrw25P1[i,j+1]	:= 0
		Next j
	Next i
	
	For i:= 1 to Len(aBrw25Rs)
		//Totaliza array aBrw25Rs
		For nPFilx := 1 to nQFIL
			aBrw25Rs[i,((nQFIL+1)*2)]	+= aBrw25Rs[i,nPFilx*2]
			aBrw25Rs[i,((nQFIL+1)*2)+1]	+= aBrw25Rs[i,nPFilx*2+1]
		Next nPFilx
		
		If Alltrim(aBrw25Rs[i,1]) > '5000'
			For nPFilx := 1 to nQFIL
				aBrw25P1[1,nPFilx+1]+=aBrw25Rs[i,nPFilx*2]
				aBrw25P1[2,nPFilx+1]+=aBrw25Rs[i,nPFilx*2]
			Next nPFil
		Endif
	Next i
	
	For nPFilx := 1 to nQFIL
		aBrw25P1[1,nPFilx+1]-=aTt25v04[nPFilx]
		aBrw25P1[2,nPFilx+1]-=aTt25v04[nPFilx]
		aBrw25P1[3,nPFilx+1]+=aTt25v01[nPFilx]+aTt25v02[nPFilx]+aTt25v03[nPFilx]
		aBrw25P1[4,nPFilx+1]+=aBrw25P1[1,nPFilx+1]-aBrw25P1[3,nPFilx+1]
		aBrw25P1[5,nPFilx+1]+=Round(aBrw25P1[4,nPFilx+1]*cP25A07,2)
	Next nPFil
	
	//Cria coluna totalizado do bloco P100
	For _i := 1 to 5
		For _j := 2 to nQFIL+1
			aBrw25P1[_i,nQFIL+2] += aBrw25P1[_i,_j] 
		Next _j
	Next _i
	
	(cAlsB25Dt)->(dbCloseArea())
	
	//Verifica se os produtos estão com o complemento cadastrado
	SysRefresh()
Return

/*/{Protheus.doc} Static Function xRelBr25
Gera Relatório Ref. INSS DESONERAÇÃO 
@type  Function
@author Abel Babini Filho
@since 27/05/2019
@version 03
/*/
Static Function xRelBr25()
	Local aSays			:= {}
	Local aButtons		:= {}
	Local nOpca			:= 0
	Private oExcel     := FWMSEXCELEX():New()
	//Private cArquivo	:= cGetFile("Arquivo XML", "Selecione o diretório para salvar o relatório",,'C:\',.T.,GETF_RETDIRECTORY + GETF_LOCALHARD + GETF_NETWORKDRIVE)	
	Private oMsExcel   := NIL
	
	cArquivo := cPathRel +  'RINSSDES_' + DTOS(DATE()) + STRTRAN(TIME(),':','') + '.XML'
	//+-----------------------------------------------+
	//|Monta Form Batch - Interface com o Usuario     |
	//+-----------------------------------------------+
	AADD(aSays,"Este programa tem a finalidade de Gerar um arquivo Excel " )
	AADD(aSays,"Relatorio de INSS Desoneração" )
    
	AADD(aButtons, { 1,.T.,{|o| nOpca:=1, o:oWnd:End(), Processa({||xRelBr25b()},"Gerando arquivo","Aguarde...")    }})
	AADD(aButtons, { 2,.T.,{|o| nOpca:=2, o:oWnd:End() }})	
	FormBatch( cCadastr, aSays, aButtons )
	
Return

/*/{Protheus.doc} Static Function xRelBr25b
Gera Relatório Ref. INSS DESONERAÇÃO 
@type  Function
@author Abel Babini Filho
@since 27/05/2019
@version 03
/*/
Static Function xRelBr25b()
	BEGIN SEQUENCE
		
		IF .NOT.( ApOleClient("MsExcel") )   // se nao existir o excel sai fora..
		    Alert("Nao Existe Excel Instalado")
            BREAK
        EndIF
        	
    	//Planilha1 - Resumo
    	Cab25P1()             
        GEx25P1()

    	//Planilha3 - Detalhe
    	Cab25P3()             
        GEx25P3()

        //Planilha4 - Parametros
    	Cab25P4()
        GEx25P4()

        SalvaXml()
		CriaExcel()
	
	    MsgInfo("Arquivo Excel gerado!")    
	    
	END SEQUENCE

Return

/*/{Protheus.doc} Static Function Cab25P1
Gera Relatório Ref. INSS DESONERAÇÃO 
@type  Function
@author Abel Babini Filho
@since 27/05/2019
@version 03
/*/
Static Function Cab25P1() 	
	Local nColBr25	:= 0
	//PLANILHA 1 - RESUMO
    oExcel:AddworkSheet(cFld25)
	oExcel:AddTable (cFld25,cFld25t1)
	oExcel:AddColumn(cFld25,cFld25t1,"                          CFOP                          "		,1,1)
	
	For nColBr25 := 1 To nQFIL
		oExcel:AddColumn(cFld25,cFld25t1,aFlAux[nColBr25] + " - Vl.Cont.",2,2)
		oExcel:AddColumn(cFld25,cFld25t1,aFlAux[nColBr25] + " - ICMS Ret",2,2)
	Next nColBr25
	
	oExcel:AddColumn(cFld25,cFld25t1,"TOTAL - Vl.Cont."	,2,2)
	oExcel:AddColumn(cFld25,cFld25t1,"TOTAL - ICMS Ret"	,2,2)

RETURN(NIL)  

/*/{Protheus.doc} Static Function Cab25P3
Gera Relatório Ref. INSS DESONERAÇÃO 
@type  Function
@author Abel Babini Filho
@since 27/05/2019
@version 03
/*/
Static Function Cab25P3()
 	//DETALHE
    oExcel:AddworkSheet(cFld253)
	oExcel:AddTable (cFld253,cFld25t3)
	oExcel:AddColumn(cFld253,cFld25t3,"Filial"		,1,1)
	oExcel:AddColumn(cFld253,cFld25t3,"Dt.Entrada"	,1,1)
	oExcel:AddColumn(cFld253,cFld25t3,"Dt.Emissão"	,1,1)
	oExcel:AddColumn(cFld253,cFld25t3,"Serie"		,1,1)
	oExcel:AddColumn(cFld253,cFld25t3,"Documento"	,1,1)
	oExcel:AddColumn(cFld253,cFld25t3,"Cod.Cliente"	,1,1)
	oExcel:AddColumn(cFld253,cFld25t3,"Loja"			,1,1)
	oExcel:AddColumn(cFld253,cFld25t3,"Cliente"		,1,1)
	oExcel:AddColumn(cFld253,cFld25t3,"Tipo Doc"		,1,1)
	oExcel:AddColumn(cFld253,cFld25t3,"CFOP"			,1,1)
	oExcel:AddColumn(cFld253,cFld25t3,"Vl.Contábil"	,2,3)
	oExcel:AddColumn(cFld253,cFld25t3,"Vl.ICMS Ret"	,2,3)
	oExcel:AddColumn(cFld253,cFld25t3,"Espécie"		,1,1)
	oExcel:AddColumn(cFld253,cFld25t3,"Observação"	,1,1)
	oExcel:AddColumn(cFld253,cFld25t3,"Cod.Produto"	,1,1)
	oExcel:AddColumn(cFld253,cFld25t3,"Produto"		,1,1)
	oExcel:AddColumn(cFld253,cFld25t3,"TES"			,1,1)
Return(NIL)

/*/{Protheus.doc} Static Function Cab25P4
Gera Relatório Ref. INSS DESONERAÇÃO 
@type  Function
@author Abel Babini Filho
@since 27/05/2019
@version 03
/*/
Static Function Cab25P4()
	//PLANILHA 4 - PARAMETROS
    oExcel:AddworkSheet(cFld254)
	oExcel:AddTable (cFld254,cFld25t4)
	oExcel:AddColumn(cFld254,cFld25t4,"Parametro"	,1,1)
	oExcel:AddColumn(cFld254,cFld25t4,"Conteudo"	,1,1)
	oExcel:AddColumn(cFld254,cFld25t4,"Descricao"	,1,1)
Return(NIL) 

/*/{Protheus.doc} Static Function GEx25P1
Gera Relatório Ref. INSS DESONERAÇÃO 
@type  Function
@author Abel Babini Filho
@since 27/05/2019
@version 03
/*/
Static Function GEx25P1()
	Local nLin, nCol := 0
	Local aZero	:= {{}}
	Local aMemCalc
	Local aP100:={}
	
	//Cria array da linha em branco
	If Len(aBrw25Rs) > 0
		ASIZE(aZero[1],Len(aBrw25Rs[1]))
	Endif
	
	//RESUMO
	FOR nLin := 1 TO Len(aBrw25Rs)
		//For nCol:=1 to Len(aBrw25Rs[nlin])
			oExcel:AddRow(cFld25,cFld25t1,aBrw25Rs[nLin])
		//Next nCol
	Next nLin
	
	//Linha em branco
	oExcel:AddRow(cFld25,cFld25t1,aZero[1])
	
	//Imprime mémoria de cálculo
	aMemCalc := Array(4,Len(aZero[1]))
	aMemCalc[1,1] := "Imobilizado - Não integra a Base Bruta do PIS E COFINS"
	aMemCalc[2,1] := "ICMS ST"
	aMemCalc[3,1] := "Exportação"
	aMemCalc[4,1] := "Devoluções"
	 
	FOR nCol:=1 TO Len(aTt25v04)
		aMemCalc[1,nCol*2] := aTt25v04[nCol]
		aMemCalc[2,nCol*2] := aTt25v01[nCol]
		aMemCalc[3,nCol*2] := aTt25v02[nCol]
		aMemCalc[4,nCol*2] := aTt25v03[nCol]
	NEXT nCol		
	oExcel:AddRow(cFld25,cFld25t1,aMemCalc[1])
	oExcel:AddRow(cFld25,cFld25t1,aMemCalc[2])
	oExcel:AddRow(cFld25,cFld25t1,aMemCalc[3])
	oExcel:AddRow(cFld25,cFld25t1,aMemCalc[4])
	
	//Linha em branco
	oExcel:AddRow(cFld25,cFld25t1,aZero[1])

	//BLOCO P100
	aP100 := Array(Len(aBrw25P1),Len(aZero[1]))
	FOR nLin := 1 TO Len(aP100)
		FOR nCol:=1 TO Len(aBrw25P1[nLin])
			IF nCol <= 2
				aP100[nLin,nCol] := aBrw25P1[nLin,nCol]
			ELSE
				aP100[nLin,(nCol-1)*2] := aBrw25P1[nLin,nCol]
			ENDIF
		NEXT nCol
		oExcel:AddRow(cFld25,cFld25t1,aP100[nLin])
	Next nLin

Return

/*/{Protheus.doc} Static Function GEx25P3
Gera Relatório Ref. INSS DESONERAÇÃO 
@type  Function
@author Abel Babini Filho
@since 27/05/2019
@version 03
/*/
Static Function GEx25P3()
	Local nExcel1 := 0
	//PLANILHA 3 - MERCADO EXTERNO			
	procregua(Len(aBrw25Dt))
	FOR nExcel1 := 1 TO Len(aBrw25Dt)
		IncProc()
		oExcel:AddRow(cFld253,cFld25t3,;
						{aBrw25Dt[nExcel1][01],; 
						aBrw25Dt[nExcel1][02],; 
						aBrw25Dt[nExcel1][03],; 
						aBrw25Dt[nExcel1][04],; 
						aBrw25Dt[nExcel1][05],;
						aBrw25Dt[nExcel1][06],;
						aBrw25Dt[nExcel1][07],;
						aBrw25Dt[nExcel1][08],;
						aBrw25Dt[nExcel1][09],;
						aBrw25Dt[nExcel1][10],;
						aBrw25Dt[nExcel1][11],;
						aBrw25Dt[nExcel1][12],;
						aBrw25Dt[nExcel1][13],;
						aBrw25Dt[nExcel1][14],;
						aBrw25Dt[nExcel1][15],;
						aBrw25Dt[nExcel1][16],;
						aBrw25Dt[nExcel1][17];
						})	
	NEXT nExcel1
	//ADICIONA LINHA EM BRANCA
	oExcel:AddRow(cFld253,cFld25t3,;
					{'',; 
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'';
					})	

Return

/*/{Protheus.doc} Static Function GEx25P4
Gera Relatório Ref. INSS DESONERAÇÃO 
@type  Function
@author Abel Babini Filho
@since 27/05/2019
@version 03
/*/
Static Function GEx25P4()
	//PLANILHA4 - PARAMETROS
	oExcel:AddRow(cFld254,cFld25t4,{'Parâmetros Comuns (INSS Desoneração)',;
									'',;
									'';
									 }) 

	oExcel:AddRow(cFld254,cFld25t4,{'MV_#CFINSS',;
									cP25A01,;
									'Indica os CFOPs que serão considerados para calculo das Receitas';
									 }) 

	oExcel:AddRow(cFld254,cFld25t4,{'MV_#CFICST',;
									cP25A02,;
									'Indica os CFOPs que serão considerados para calculo do ICMS ST';
									 }) 

	oExcel:AddRow(cFld254,cFld25t4,{'MV_#CFINEX',;
									cP25A03,;
									'Indica os CFOPs que serão considerados para calculo da Exportação';
									 }) 

	oExcel:AddRow(cFld254,cFld25t4,{'MV_#CFINDV',;
									cP25A04,;
									'Indica os CFOPs que serão considerados para deduzir as devoluções do calculo';
									 }) 

	oExcel:AddRow(cFld254,cFld25t4,{'MV_#CFIDV2',;
									cP25A05,;
									'Indica os CFOPs que serão considerados para anular as devoluções do calculo';
									 }) 

	oExcel:AddRow(cFld254,cFld25t4,{'MV_#CFINIM',;
									cP25A06,;
									'Indica os CFOPs que serão considerados para calculo dos Imobilizados';
									 }) 
									 
	oExcel:AddRow(cFld254,cFld25t4,{'MV_#ALINSS',;
									cP25A07,;
									'Indica a alíquota para cálculo do INSS';
									 }) 

Return
//FIM Chamado n.040918 - Abel.Babini - Relatorio INSS para calculo da desoneração - 27/05/2019


// INICIO Chamado n.045022  - Abel.Babini - Relatorio Cred Pis/Cof Parcelado sobre Ativo - 10/06/2019
/*/{Protheus.doc} Static Function xABrw26
Carrega da dados Ref. Credito Benfeitoria Imobilizados 
@type  Function
@author Abel Babini Filho
@since 27/05/2019
@version 03
/*/
Static Function xABrw26()
	// Local nVlCPCBf	:= 0
	Local nBPrj	:= 0
	Local nPProd := 0
	Local _i := 0
	
	If Select(cAlsB26Dt) > 0
		(cAlsB26Dt)->(dbCloseArea())
	Endif
	cAlsB26Dt:=GetNextAlias()

	BeginSQL  Alias cAlsB26Dt
		column N1_AQUISIC as Date
		SELECT
			N1_AQUISIC,
			N1_MESCPIS,
			DATEDIFF( month, N1_AQUISIC,%Exp:DToS(_mvpr02)%) AS QTMES2,
			N1_FILIAL,
			N1_CBASE,
			N1_ITEM,
			N1_DESCRIC,
			N1_QUANTD,
			N1_BAIXA,
			N1_CHAPA,
			N1_GRUPO,
			N1_FORNEC,
			N1_LOJA,
			N1_NSERIE,
			N1_NFISCAL,
			N1_NFITEM,
			N1_NFESPEC,
			N1_PROJETO,
			N1_STATUS,
			N1_CALCPIS,
			N1_DTCLASS,
			N1_DETPATR,
			N1_UTIPATR,
  		CASE WHEN N1_XATFBEN = '1' THEN 'Benfeitoria Bens' ELSE CASE WHEN N1_XATFBEN = '2' THEN 'Benfeitoria Servicos' ELSE CASE WHEN N1_XATFBEN = '3' THEN 'Ativo Imobilizado' ELSE '' END END END AS XATFBEN,
			N1_CSTPIS,
			N1_ALIQPIS,
			N1_CSTCOFI,
			N1_ALIQCOF,
			N1_CODBCC,
			N1_CBCPIS,
			'01' as N3_TIPO,
			FT_BASEPIS AS N3_VORIG1,
			A2_NOME
		FROM %TABLE:SN1% SN1
		LEFT JOIN %TABLE:SA2% SA2 ON
				SA2.%notDel%
			AND SA2.A2_COD = SN1.N1_FORNEC
			AND SA2.A2_LOJA = SN1.N1_LOJA
		LEFT JOIN %TABLE:SFT% SFT ON
				SFT.%notDel%
			AND SFT.FT_FILIAL = SN1.N1_FILIAL
			AND SFT.FT_NFISCAL = SN1.N1_NFISCAL
			AND SFT.FT_SERIE = SN1.N1_NSERIE
			AND SFT.FT_CLIEFOR = SN1.N1_FORNEC
			AND SFT.FT_LOJA = SN1.N1_LOJA
			AND SFT.FT_ITEM = SN1.N1_NFITEM
		WHERE SN1.%notDel%
			AND SN1.N1_FILIAL IN %Exp:cFilIn%
			AND SN1.N1_CALCPIS IN ('3')
			AND SN1.N1_AQUISIC <= %Exp:DToS(_mvpr02)%
			AND DATEDIFF( month, N1_AQUISIC,%Exp:DToS(_mvpr02)%)+1 <= N1_MESCPIS				
		ORDER BY N1_FILIAL, N1_DESCRIC, N1_CBASE
	EndSQL
/*
		//RETIRADO O RELACIONAMENTO ABAIXO PARA NÃO DUPLICAR AS LINHAS NO RELATÓRIO PARA BENS QUE POSSUEM 2 LINHAS NA SN3.
		//CHAMADO 052243 || OS 053581 || FISCAL || SIMONE || 8463 || ALTERAR NOTA || ABEL BABINI FILHO 01/10/2019
		LEFT JOIN %TABLE:SN3% SN3 ON
				SN3.%notDel%
			AND SN3.N3_FILIAL = SN1.N1_FILIAL
			AND SN3.N3_CBASE = SN1.N1_CBASE
			AND SN3.N3_ITEM = SN1.N1_ITEM

*/
	// INICIO n.051633  ³ OS 052957 || FISCAL || DEJAIME || 8921 || REL. PIS/COFINS - ABEL - 09/09/2019
	// Retirado condição de item classificado para permitir listar os itens mesmo sem classificação 
	//		AND SN3.N3_TIPO = '01'
	//		AND SN1.N1_STATUS = '1'
	// FIM n.051633  ³ OS 052957 || FISCAL || DEJAIME || 8921 || REL. PIS/COFINS - ABEL - 09/09/2019
	
	//Inicializa Array Projeção
	aBrw26Pr	:= {}
	aBrw26Cr	:= {}
	aBrw26Dt	:= {}
	aBrw26Sv	:= {}
	aBrw26Bn	:= {}
	nQItens		:= 0
	nVlTOrig	:= 0
	nVlCPT		:= 0
	nVlCCT		:= 0
	
	(cAlsB26Dt)->(dbGoTop())
	While !(cAlsB26Dt)->(Eof())
		//Quantidade de Itens
		nQItens += 1
		//Total do Valor Original das Mercadorias
		nVlTOrig	+= (cAlsB26Dt)->N3_VORIG1
			
		//Adiciona linhas ao Array de Detalhes
		AADD(aBrw26Dt,{;
			(cAlsB26Dt)->N1_FILIAL,;
			(cAlsB26Dt)->N1_CBASE,;
			(cAlsB26Dt)->N1_ITEM,;
			(cAlsB26Dt)->N1_DESCRIC,;
			(cAlsB26Dt)->N1_AQUISIC,;
			(cAlsB26Dt)->N1_MESCPIS,;
			(cAlsB26Dt)->QTMES2,;
			(cAlsB26Dt)->N1_QUANTD,;
			(cAlsB26Dt)->N1_BAIXA,;
			(cAlsB26Dt)->N1_CHAPA,;//10
			(cAlsB26Dt)->N1_GRUPO,;
			(cAlsB26Dt)->N1_FORNEC,;
			(cAlsB26Dt)->N1_LOJA,;
			(cAlsB26Dt)->N1_NSERIE,;
			(cAlsB26Dt)->N1_NFISCAL,;
			(cAlsB26Dt)->N1_NFITEM,;
			(cAlsB26Dt)->N1_NFESPEC,;
			(cAlsB26Dt)->N1_PROJETO,;
			(cAlsB26Dt)->N1_STATUS,;
			(cAlsB26Dt)->N1_CALCPIS,;//20
			(cAlsB26Dt)->N1_DTCLASS,;
			(cAlsB26Dt)->N1_DETPATR,;
			(cAlsB26Dt)->N1_UTIPATR,;
			(cAlsB26Dt)->N1_CSTPIS,;
			(cAlsB26Dt)->N1_ALIQPIS,;
			(cAlsB26Dt)->N1_CSTCOFI,;
			(cAlsB26Dt)->N1_ALIQCOF,;
			(cAlsB26Dt)->N1_CODBCC,;
			(cAlsB26Dt)->N1_CBCPIS,;
			(cAlsB26Dt)->N3_TIPO,;//30
			(cAlsB26Dt)->N3_VORIG1,;
			(cAlsB26Dt)->A2_NOME,;
			(cAlsB26Dt)->XATFBEN})//33


		//Calcula valor da parcela do crédito
		nVlCPCBC	:= Round((cAlsB26Dt)->N3_VORIG1 / (cAlsB26Dt)->N1_MESCPIS,2)
		
		nVlCPCBP	:= Round((cAlsB26Dt)->N3_VORIG1 * (cAlsB26Dt)->N1_ALIQPIS /100 / (cAlsB26Dt)->N1_MESCPIS,2)
		nVlCPCBT	:= Round((cAlsB26Dt)->N3_VORIG1 * (cAlsB26Dt)->N1_ALIQPIS /100 ,2)

		nVlCCCBP	:= Round((cAlsB26Dt)->N3_VORIG1 * (cAlsB26Dt)->N1_ALIQCOF /100 / (cAlsB26Dt)->N1_MESCPIS,2)
		nVlCCCBT	:= Round((cAlsB26Dt)->N3_VORIG1 * (cAlsB26Dt)->N1_ALIQCOF /100 ,2)

		nQMes		:= ((cAlsB26Dt)->N1_MESCPIS-(cAlsB26Dt)->QTMES2)

		xAddB26P() //Adiciona Linha em Branco no Array Projeção
		nBPrj 	:= Len(aBrw26Pr)
		
		//ARRAY PIS PROJETADO		
		aBrw26Pr[nBPrj,01] := (cAlsB26Dt)->N1_FILIAL// - Filial
		aBrw26Pr[nBPrj,02] := (cAlsB26Dt)->N1_CBASE// - Codigo
		aBrw26Pr[nBPrj,03] := (cAlsB26Dt)->N1_ITEM// - Item
		aBrw26Pr[nBPrj,04] := (cAlsB26Dt)->N1_NSERIE// - Serie NF
		aBrw26Pr[nBPrj,05] := (cAlsB26Dt)->N1_NFISCAL// - Nota Fiscal
		aBrw26Pr[nBPrj,06] := (cAlsB26Dt)->N1_NFITEM// - Item NF
		aBrw26Pr[nBPrj,07] := (cAlsB26Dt)->N1_DESCRIC// - Descrição
		aBrw26Pr[nBPrj,08] := (cAlsB26Dt)->A2_NOME// - Nome Fornecedor
		aBrw26Pr[nBPrj,09] := (cAlsB26Dt)->N1_AQUISIC// - Dt.Aquisição
		aBrw26Pr[nBPrj,10] := (cAlsB26Dt)->XATFBEN// - Tipo (Produto ou Serviço)
		aBrw26Pr[nBPrj,11] := nVlCPCBC // - Base Calculo mensal
		aBrw26Pr[nBPrj,12] := nVlCPCBT// - Vl.Cred.Total
		
		For _i := 1 to nQMes
			aBrw26Pr[nBPrj,_i+12] := nVlCPCBP
		Next _i
		aBrw26Pr[nBPrj,37] := nVlCPCBP * nQMes// - Total 
		//Total do Credito de Pis Disponível
		nVlCPT		+= nVlCPCBP * nQMes
		
		//ARRAY COFINS PROJETADO		
		aBrw26Cr[nBPrj,01] := (cAlsB26Dt)->N1_FILIAL// - Filial
		aBrw26Cr[nBPrj,02] := (cAlsB26Dt)->N1_CBASE// - Codigo
		aBrw26Cr[nBPrj,03] := (cAlsB26Dt)->N1_ITEM// - Item
		aBrw26Cr[nBPrj,04] := (cAlsB26Dt)->N1_NSERIE// - Serie NF
		aBrw26Cr[nBPrj,05] := (cAlsB26Dt)->N1_NFISCAL// - Nota Fiscal
		aBrw26Cr[nBPrj,06] := (cAlsB26Dt)->N1_NFITEM// - Item NF
		aBrw26Cr[nBPrj,07] := (cAlsB26Dt)->N1_DESCRIC// - Descrição
		aBrw26Cr[nBPrj,08] := (cAlsB26Dt)->A2_NOME// - Nome Fornecedor
		aBrw26Cr[nBPrj,09] := (cAlsB26Dt)->N1_AQUISIC// - Dt.Aquisição
		aBrw26Cr[nBPrj,10] := (cAlsB26Dt)->XATFBEN// - Tipo (Produto ou Serviço)
		aBrw26Cr[nBPrj,11] := nVlCPCBC // - Base Calculo mensal
		aBrw26Cr[nBPrj,12] := nVlCCCBT// - Vl.Cred.Total
		For _i := 1 to nQMes
			aBrw26Cr[nBPrj,_i+12] := nVlCCCBP
		Next _i
		aBrw26Cr[nBPrj,37] := nVlCCCBP * nQMes// - Total 
		//Total do Credito de Cofins Disponível
		nVlCCT		+= nVlCCCBP * nQMes
		nPProd := 0
		//INICIO Chamado 051633 - ABEL - 08/11/2019 - Ajustado o relatório de Benfeitoria para acrescentar planilhas de resumo
		IF Alltrim((cAlsB26Dt)->XATFBEN) == 'Benfeitoria Servicos'
			nPProd	:= ASCAN(aBrw26Sv,{|X| Alltrim(X[7]) == Alltrim((cAlsB26Dt)->N1_FILIAL)+Alltrim((cAlsB26Dt)->N1_DESCRIC)})
			If nPProd == 0
				AADD(aBrw26Sv,{	(cAlsB26Dt)->N1_FILIAL,;
											Alltrim((cAlsB26Dt)->N1_DESCRIC),;
											nVlCPCBC,;
											nVlCPCBP,;
											nVlCPCBC,;
											nVlCCCBP,;
											(cAlsB26Dt)->N1_FILIAL+Alltrim((cAlsB26Dt)->N1_DESCRIC)})
			ELSE
				aBrw26Sv[nPProd,03] +=nVlCPCBC
				aBrw26Sv[nPProd,04] +=nVlCPCBP
				aBrw26Sv[nPProd,05] +=nVlCPCBC
				aBrw26Sv[nPProd,06] +=nVlCCCBP
			ENDIF
		ELSEIF Alltrim((cAlsB26Dt)->XATFBEN) == 'Benfeitoria Bens'
			nPProd	:= ASCAN(aBrw26Bn,{|X| Alltrim(X[7]) == Alltrim((cAlsB26Dt)->N1_FILIAL)+Alltrim((cAlsB26Dt)->N1_DESCRIC)})
			If nPProd == 0
				AADD(aBrw26Bn,{	(cAlsB26Dt)->N1_FILIAL,;
											Alltrim((cAlsB26Dt)->N1_DESCRIC),;
											nVlCPCBC,;
											nVlCPCBP,;
											nVlCPCBC,;
											nVlCCCBP,;
											(cAlsB26Dt)->N1_FILIAL+Alltrim((cAlsB26Dt)->N1_DESCRIC)})
			ELSE
				aBrw26Bn[nPProd,03] +=nVlCPCBC
				aBrw26Bn[nPProd,04] +=nVlCPCBP
				aBrw26Bn[nPProd,05] +=nVlCPCBC
				aBrw26Bn[nPProd,06] +=nVlCCCBP
			ENDIF
		ENDIF
	//FIM Chamado 051633 - ABEL - 08/11/2019 - Ajustado o relatório de Benfeitoria para acrescentar planilhas de resumo
		(cAlsB26Dt)->(dbSkip())
	EndDo

	nTPMes	:= 0
	nTCMes	:= 0
	For _i := 1 to Len(aBrw26Pr)
		nTPMes	+= aBrw26Pr[_i,13]
		nTCMes	+= aBrw26Cr[_i,13]
	Next _i


	//Prepara Array dos 24 meses
	aNomeMes	:= Array(24)
	cNomeMes	:= ""
	nNomeAno	:= Val(_cAnoF)
	nAuxMes	:= Val(_cMesF) 
	For _i := 1 to 24
		If nAuxMes = 1 
			cNomeMes	:= "Janeiro / "+Alltrim(Str(nNomeAno))
		Elseif nAuxMes = 2
			cNomeMes	:= "Fevereiro / "+Alltrim(Str(nNomeAno))
		Elseif nAuxMes = 3
			cNomeMes	:= "Março / "+Alltrim(Str(nNomeAno))
		Elseif nAuxMes = 4
			cNomeMes	:= "Abril / "+Alltrim(Str(nNomeAno))
		Elseif nAuxMes = 5
			cNomeMes	:= "Maio / "+Alltrim(Str(nNomeAno))
		Elseif nAuxMes = 6
			cNomeMes	:= "Junho / "+Alltrim(Str(nNomeAno))
		Elseif nAuxMes = 7
			cNomeMes	:= "Julho / "+Alltrim(Str(nNomeAno))
		Elseif nAuxMes = 8
			cNomeMes	:= "Agosto / "+Alltrim(Str(nNomeAno))
		Elseif nAuxMes = 9
			cNomeMes	:= "Setembro / "+Alltrim(Str(nNomeAno))
		Elseif nAuxMes = 10
			cNomeMes	:= "Outubro / "+Alltrim(Str(nNomeAno))
		Elseif nAuxMes = 11
			cNomeMes	:= "Novembro / "+Alltrim(Str(nNomeAno))
		Elseif nAuxMes = 12
			cNomeMes	:= "Dezembro / "+Alltrim(Str(nNomeAno))
			nNomeAno 	+= 1
		Endif
		
		aNomeMes[_i]	:= cNomeMes 
		
		nAuxMes	+=	1
		If nAuxMes > 12
			nAuxMes := 1
		Endif
	Next _i

Return

Static Function xAddB26P()
	AADD(aBrw26Pr,{;
					"",;// - Filial
					"",;// - Codigo
					"",;// - Item
					"",;// - Serie NF
					"",;// - Nota Fiscal
					"",;// - Item NF
					"",;// - Descrição
					"",;// - Nome Fornecedor
					"",;// - Dt.Aquisição
					"",;// - Tipo (Produto ou Serviço)
					0,;// - Base Calculo Mes
					0,;// - Vl.Cred.Total
					0,;// - Mes 01
					0,;// - Mes 02
					0,;// - Mes 03
					0,;// - Mes 04
					0,;// - Mes 05
					0,;// - Mes 06
					0,;// - Mes 07
					0,;// - Mes 08
					0,;// - Mes 09
					0,;// - Mes 10
					0,;// - Mes 11
					0,;// - Mes 12
					0,;// - Mes 13
					0,;// - Mes 14
					0,;// - Mes 15
					0,;// - Mes 16
					0,;// - Mes 17
					0,;// - Mes 18
					0,;// - Mes 19
					0,;// - Mes 20
					0,;// - Mes 21
					0,;// - Mes 22
					0,;// - Mes 23
					0,;// - Mes 24
					0})// - Total 

	AADD(aBrw26Cr,{;
					"",;// - Filial
					"",;// - Codigo
					"",;// - Item
					"",;// - Serie NF
					"",;// - Nota Fiscal
					"",;// - Item NF
					"",;// - Descrição
					"",;// - Nome Fornecedor
					"",;// - Dt.Aquisição
					"",;// - Tipo (Produto ou Serviço)
					0,;// - Base Calculo Mes
					0,;// - Vl.Cred.Total
					0,;// - Mes 01
					0,;// - Mes 02
					0,;// - Mes 03
					0,;// - Mes 04
					0,;// - Mes 05
					0,;// - Mes 06
					0,;// - Mes 07
					0,;// - Mes 08
					0,;// - Mes 09
					0,;// - Mes 10
					0,;// - Mes 11
					0,;// - Mes 12
					0,;// - Mes 13
					0,;// - Mes 14
					0,;// - Mes 15
					0,;// - Mes 16
					0,;// - Mes 17
					0,;// - Mes 18
					0,;// - Mes 19
					0,;// - Mes 20
					0,;// - Mes 21
					0,;// - Mes 22
					0,;// - Mes 23
					0,;// - Mes 24
					0})// - Total 
Return

/*/{Protheus.doc} Static Function xRelBr26
Gera Relatório Ref. Credito Benfeitoria Imobilizados 
@type  Function
@author Abel Babini Filho
@since 27/05/2019
@version 03
/*/
Static Function xRelBr26()
	Local aSays			:= {}
	Local aButtons		:= {}
	Local nOpca			:= 0
	Private oExcel     := FWMSEXCELEX():New()
	//Private cArquivo	:= cGetFile("Arquivo XML", "Selecione o diretório para salvar o relatório",,'C:\',.T.,GETF_RETDIRECTORY + GETF_LOCALHARD + GETF_NETWORKDRIVE)	
	Private oMsExcel   := NIL
	
	cArquivo := cPathRel +  'RPCBENFIMOB_' + DTOS(DATE()) + STRTRAN(TIME(),':','') + '.XML'
	//+-----------------------------------------------+
	//|Monta Form Batch - Interface com o Usuario     |
	//+-----------------------------------------------+
	AADD(aSays,"Este programa tem a finalidade de Gerar um arquivo Excel " )
	AADD(aSays,"Relatorio de Credito de Pis/Cofins sobre Benfeitorias em Imobilizados" )
    
	AADD(aButtons, { 1,.T.,{|o| nOpca:=1, o:oWnd:End(), Processa({||xRelBr26b()},"Gerando arquivo","Aguarde...")    }})
	AADD(aButtons, { 2,.T.,{|o| nOpca:=2, o:oWnd:End() }})	
	FormBatch( cCadastr, aSays, aButtons )
	
Return

/*/{Protheus.doc} Static Function xRelBr26b
Gera Relatório Ref. Credito Benfeitoria Imobilizados 
@type  Function
@author Abel Babini Filho
@since 27/05/2019
@version 03
/*/
Static Function xRelBr26b()
	BEGIN SEQUENCE
		
		IF .NOT.( ApOleClient("MsExcel") )   // se nao existir o excel sai fora..
		    Alert("Nao Existe Excel Instalado")
            BREAK
        EndIF
        	
    	//Planilha1 - Resumo
    	Cab26P1()             
        GEx26P1()

    	//Planilha3 - Projetado Pis
    	Cab26P2()             
        GEx26P2()

    	//Planilha3 - Projetado Cofins
    	Cab26P3()             
        GEx26P3()

        //Planilha4 - Detalhes
    	Cab26P4()
        GEx26P4()

        //Planilha4 - Resumo Serviços
    	Cab26P5()
        GEx26P5()

        //Planilha4 - Resumo Bens
    	Cab26P6()
        GEx26P6()

        SalvaXml()
		CriaExcel()
	
	    MsgInfo("Arquivo Excel gerado!")    
	    
	END SEQUENCE

Return

/*/{Protheus.doc} Static Function Cab26P1
Gera Relatório Ref. Credito Benfeitoria Imobilizados 
@type  Function
@author Abel Babini Filho
@since 27/05/2019
@version 03
/*/
Static Function Cab26P1() 	
	//PLANILHA 1 - RESUMO
	oExcel:AddworkSheet(cFld26)
	oExcel:AddTable (cFld26,cFld26t1)
	oExcel:AddColumn(cFld26,cFld26t1,"Descrição"	,1,1)
	oExcel:AddColumn(cFld26,cFld26t1,"Valor PIS"		,2,2)
	oExcel:AddColumn(cFld26,cFld26t1,"Valor COFINS"		,2,2)

RETURN(NIL)  

/*/{Protheus.doc} Static Function Cab26P2
Gera Relatório Ref. Credito Benfeitoria Imobilizados 
@type  Function
@author Abel Babini Filho
@since 27/05/2019
@version 03
/*/
Static Function Cab26P2()
 	//DETALHE
  oExcel:AddworkSheet(cFld262)
	oExcel:AddTable (cFld262,cFld26t2)
	oExcel:AddColumn(cFld262,cFld26t2, "Filial"			,1,1)//, {|| aBrw26Pr[oBrw26Pr:nAt,01]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )
	oExcel:AddColumn(cFld262,cFld26t2, "C.Base"			,1,1)//, {|| aBrw26Pr[oBrw26Pr:nAt,02]}	, "@!"						,,,"LEFT"	,030,.f.,.f.,,,,.f.,) )
	oExcel:AddColumn(cFld262,cFld26t2, "Item"				,1,1)//, {|| aBrw26Pr[oBrw26Pr:nAt,03]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )
	//INICIO Chamado 051633 - ABEL - 22/11/2019 - Ajustado o relatório de Benfeitoria para acrescentar Informações da NF
	oExcel:AddColumn(cFld262,cFld26t2, "Série NF"		,1,1)//, {|| aBrw26Pr[oBrw26Pr:nAt,03]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )
	oExcel:AddColumn(cFld262,cFld26t2, "Nota Fiscal",1,1)//, {|| aBrw26Pr[oBrw26Pr:nAt,03]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )
	oExcel:AddColumn(cFld262,cFld26t2, "Item NF"		,1,1)//, {|| aBrw26Pr[oBrw26Pr:nAt,03]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )
	//FIM Chamado 051633 - ABEL - 22/11/2019 - Ajustado o relatório de Benfeitoria para acrescentar Informações da NF
	oExcel:AddColumn(cFld262,cFld26t2, "Descrição"	,1,1)//, {|| aBrw26Pr[oBrw26Pr:nAt,04]}	, "@!"						,,,"LEFT"	,060,.f.,.f.,,,,.f.,) )
	oExcel:AddColumn(cFld262,cFld26t2, "Fornecedor"	,1,1)//, {|| aBrw26Pr[oBrw26Pr:nAt,05]}	, "@!"						,,,"LEFT"	,060,.f.,.f.,,,,.f.,) )
	oExcel:AddColumn(cFld262,cFld26t2, "Dt. Aquisição",1,1)//, {|| aBrw26Pr[oBrw26Pr:nAt,06]}	, "@!"						,,,"LEFT"	,030,.f.,.f.,,,,.f.,) )
	oExcel:AddColumn(cFld262,cFld26t2, "Tipo"				,1,1)//, {|| aBrw26Pr[oBrw26Pr:nAt,07]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )
	oExcel:AddColumn(cFld262,cFld26t2, "Bs.Calc.Mes",2,3)//, {|| aBrw26Pr[oBrw26Pr:nAt,08]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 
	oExcel:AddColumn(cFld262,cFld26t2, "Vl.Cred.Total",2,3)//, {|| aBrw26Pr[oBrw26Pr:nAt,08]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 
	oExcel:AddColumn(cFld262,cFld26t2, aNomeMes[1]	,2,3)//, {|| aBrw26Pr[oBrw26Pr:nAt,09]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 		
	oExcel:AddColumn(cFld262,cFld26t2, aNomeMes[2]	,2,3)//, {|| aBrw26Pr[oBrw26Pr:nAt,10]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 		
	oExcel:AddColumn(cFld262,cFld26t2, aNomeMes[3]	,2,3)//, {|| aBrw26Pr[oBrw26Pr:nAt,11]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 		
	oExcel:AddColumn(cFld262,cFld26t2, aNomeMes[4]	,2,3)//, {|| aBrw26Pr[oBrw26Pr:nAt,12]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 		
	oExcel:AddColumn(cFld262,cFld26t2, aNomeMes[5]	,2,3)//, {|| aBrw26Pr[oBrw26Pr:nAt,13]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 		
	oExcel:AddColumn(cFld262,cFld26t2, aNomeMes[6]	,2,3)//, {|| aBrw26Pr[oBrw26Pr:nAt,14]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 		
	oExcel:AddColumn(cFld262,cFld26t2, aNomeMes[7]	,2,3)//, {|| aBrw26Pr[oBrw26Pr:nAt,15]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 		
	oExcel:AddColumn(cFld262,cFld26t2, aNomeMes[8]	,2,3)//, {|| aBrw26Pr[oBrw26Pr:nAt,16]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 		
	oExcel:AddColumn(cFld262,cFld26t2, aNomeMes[9]	,2,3)//, {|| aBrw26Pr[oBrw26Pr:nAt,17]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 		
	oExcel:AddColumn(cFld262,cFld26t2, aNomeMes[10]	,2,3)//, {|| aBrw26Pr[oBrw26Pr:nAt,18]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 		
	oExcel:AddColumn(cFld262,cFld26t2, aNomeMes[11]	,2,3)//, {|| aBrw26Pr[oBrw26Pr:nAt,19]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 		
	oExcel:AddColumn(cFld262,cFld26t2, aNomeMes[12]	,2,3)//, {|| aBrw26Pr[oBrw26Pr:nAt,20]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 		
	oExcel:AddColumn(cFld262,cFld26t2, aNomeMes[13]	,2,3)//, {|| aBrw26Pr[oBrw26Pr:nAt,21]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 		
	oExcel:AddColumn(cFld262,cFld26t2, aNomeMes[14]	,2,3)//, {|| aBrw26Pr[oBrw26Pr:nAt,22]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 		
	oExcel:AddColumn(cFld262,cFld26t2, aNomeMes[15]	,2,3)//, {|| aBrw26Pr[oBrw26Pr:nAt,23]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 		
	oExcel:AddColumn(cFld262,cFld26t2, aNomeMes[16]	,2,3)//, {|| aBrw26Pr[oBrw26Pr:nAt,24]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 		
	oExcel:AddColumn(cFld262,cFld26t2, aNomeMes[17]	,2,3)//, {|| aBrw26Pr[oBrw26Pr:nAt,25]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 		
	oExcel:AddColumn(cFld262,cFld26t2, aNomeMes[18]	,2,3)//, {|| aBrw26Pr[oBrw26Pr:nAt,26]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 		
	oExcel:AddColumn(cFld262,cFld26t2, aNomeMes[19]	,2,3)//, {|| aBrw26Pr[oBrw26Pr:nAt,27]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 		
	oExcel:AddColumn(cFld262,cFld26t2, aNomeMes[20]	,2,3)//, {|| aBrw26Pr[oBrw26Pr:nAt,28]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 		
	oExcel:AddColumn(cFld262,cFld26t2, aNomeMes[21]	,2,3)//, {|| aBrw26Pr[oBrw26Pr:nAt,29]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 		
	oExcel:AddColumn(cFld262,cFld26t2, aNomeMes[22]	,2,3)//, {|| aBrw26Pr[oBrw26Pr:nAt,30]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) )
	oExcel:AddColumn(cFld262,cFld26t2, aNomeMes[23]	,2,3)//, {|| aBrw26Pr[oBrw26Pr:nAt,31]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) )
	oExcel:AddColumn(cFld262,cFld26t2, aNomeMes[24]	,2,3)//, {|| aBrw26Pr[oBrw26Pr:nAt,32]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) )	
	oExcel:AddColumn(cFld262,cFld26t2, "Total Disponível"	,2,3)//, {|| aBrw26Pr[oBrw26Pr:nAt,33]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 

Return(NIL)

/*/{Protheus.doc} Static Function Cab26P3
Gera Relatório Ref. Credito Benfeitoria Imobilizados 
@type  Function
@author Abel Babini Filho
@since 27/05/2019
@version 03
/*/
Static Function Cab26P3()
 	//DETALHE
  oExcel:AddworkSheet(cFld263)
	oExcel:AddTable(cFld263,cFld26t3)
	oExcel:AddColumn(cFld263,cFld26t3, "Filial"			,1,1)//, {|| aBrw26Pr[oBrw26Pr:nAt,01]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )
	oExcel:AddColumn(cFld263,cFld26t3, "C.Base"			,1,1)//, {|| aBrw26Pr[oBrw26Pr:nAt,02]}	, "@!"						,,,"LEFT"	,030,.f.,.f.,,,,.f.,) )
	oExcel:AddColumn(cFld263,cFld26t3, "Item"				,1,1)//, {|| aBrw26Pr[oBrw26Pr:nAt,03]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )
	//INICIO Chamado 051633 - ABEL - 22/11/2019 - Ajustado o relatório de Benfeitoria para acrescentar Informações da NF
	oExcel:AddColumn(cFld263,cFld26t3, "Série NF"		,1,1)//, {|| aBrw26Pr[oBrw26Pr:nAt,03]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )
	oExcel:AddColumn(cFld263,cFld26t3, "Nota Fiscal",1,1)//, {|| aBrw26Pr[oBrw26Pr:nAt,03]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )
	oExcel:AddColumn(cFld263,cFld26t3, "Item NF"		,1,1)//, {|| aBrw26Pr[oBrw26Pr:nAt,03]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )
	//FIM Chamado 051633 - ABEL - 22/11/2019 - Ajustado o relatório de Benfeitoria para acrescentar Informações da NF
	oExcel:AddColumn(cFld263,cFld26t3, "Descrição"	,1,1)//, {|| aBrw26Pr[oBrw26Pr:nAt,04]}	, "@!"						,,,"LEFT"	,060,.f.,.f.,,,,.f.,) )
	oExcel:AddColumn(cFld263,cFld26t3, "Fornecedor"	,1,1)//, {|| aBrw26Pr[oBrw26Pr:nAt,05]}	, "@!"						,,,"LEFT"	,060,.f.,.f.,,,,.f.,) )
	oExcel:AddColumn(cFld263,cFld26t3, "Dt. Aquisição",1,1)//, {|| aBrw26Pr[oBrw26Pr:nAt,06]}	, "@!"						,,,"LEFT"	,030,.f.,.f.,,,,.f.,) )
	oExcel:AddColumn(cFld263,cFld26t3, "Tipo"				,1,1)//, {|| aBrw26Pr[oBrw26Pr:nAt,07]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )
	oExcel:AddColumn(cFld263,cFld26t3, "Bs.Calc.Mes",2,3)//, {|| aBrw26Pr[oBrw26Pr:nAt,08]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 
	oExcel:AddColumn(cFld263,cFld26t3, "Vl.Cred.Total",2,3)//, {|| aBrw26Pr[oBrw26Pr:nAt,08]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 
	oExcel:AddColumn(cFld263,cFld26t3, aNomeMes[1]	,2,3)//, {|| aBrw26Pr[oBrw26Pr:nAt,09]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 		
	oExcel:AddColumn(cFld263,cFld26t3, aNomeMes[2]	,2,3)//, {|| aBrw26Pr[oBrw26Pr:nAt,10]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 		
	oExcel:AddColumn(cFld263,cFld26t3, aNomeMes[3]	,2,3)//, {|| aBrw26Pr[oBrw26Pr:nAt,11]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 		
	oExcel:AddColumn(cFld263,cFld26t3, aNomeMes[4]	,2,3)//, {|| aBrw26Pr[oBrw26Pr:nAt,12]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 		
	oExcel:AddColumn(cFld263,cFld26t3, aNomeMes[5]	,2,3)//, {|| aBrw26Pr[oBrw26Pr:nAt,13]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 		
	oExcel:AddColumn(cFld263,cFld26t3, aNomeMes[6]	,2,3)//, {|| aBrw26Pr[oBrw26Pr:nAt,14]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 		
	oExcel:AddColumn(cFld263,cFld26t3, aNomeMes[7]	,2,3)//, {|| aBrw26Pr[oBrw26Pr:nAt,15]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 		
	oExcel:AddColumn(cFld263,cFld26t3, aNomeMes[8]	,2,3)//, {|| aBrw26Pr[oBrw26Pr:nAt,16]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 		
	oExcel:AddColumn(cFld263,cFld26t3, aNomeMes[9]	,2,3)//, {|| aBrw26Pr[oBrw26Pr:nAt,17]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 		
	oExcel:AddColumn(cFld263,cFld26t3, aNomeMes[10]	,2,3)//, {|| aBrw26Pr[oBrw26Pr:nAt,18]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 		
	oExcel:AddColumn(cFld263,cFld26t3, aNomeMes[11]	,2,3)//, {|| aBrw26Pr[oBrw26Pr:nAt,19]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 		
	oExcel:AddColumn(cFld263,cFld26t3, aNomeMes[12]	,2,3)//, {|| aBrw26Pr[oBrw26Pr:nAt,20]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 		
	oExcel:AddColumn(cFld263,cFld26t3, aNomeMes[13]	,2,3)//, {|| aBrw26Pr[oBrw26Pr:nAt,21]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 		
	oExcel:AddColumn(cFld263,cFld26t3, aNomeMes[14]	,2,3)//, {|| aBrw26Pr[oBrw26Pr:nAt,22]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 		
	oExcel:AddColumn(cFld263,cFld26t3, aNomeMes[15]	,2,3)//, {|| aBrw26Pr[oBrw26Pr:nAt,23]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 		
	oExcel:AddColumn(cFld263,cFld26t3, aNomeMes[16]	,2,3)//, {|| aBrw26Pr[oBrw26Pr:nAt,24]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 		
	oExcel:AddColumn(cFld263,cFld26t3, aNomeMes[17]	,2,3)//, {|| aBrw26Pr[oBrw26Pr:nAt,25]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 		
	oExcel:AddColumn(cFld263,cFld26t3, aNomeMes[18]	,2,3)//, {|| aBrw26Pr[oBrw26Pr:nAt,26]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 		
	oExcel:AddColumn(cFld263,cFld26t3, aNomeMes[19]	,2,3)//, {|| aBrw26Pr[oBrw26Pr:nAt,27]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 		
	oExcel:AddColumn(cFld263,cFld26t3, aNomeMes[20]	,2,3)//, {|| aBrw26Pr[oBrw26Pr:nAt,28]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 		
	oExcel:AddColumn(cFld263,cFld26t3, aNomeMes[21]	,2,3)//, {|| aBrw26Pr[oBrw26Pr:nAt,29]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 		
	oExcel:AddColumn(cFld263,cFld26t3, aNomeMes[22]	,2,3)//, {|| aBrw26Pr[oBrw26Pr:nAt,30]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) )
	oExcel:AddColumn(cFld263,cFld26t3, aNomeMes[23]	,2,3)//, {|| aBrw26Pr[oBrw26Pr:nAt,31]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) )
	oExcel:AddColumn(cFld263,cFld26t3, aNomeMes[24]	,2,3)//, {|| aBrw26Pr[oBrw26Pr:nAt,32]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) )	
	oExcel:AddColumn(cFld263,cFld26t3, "Total Disponível"	,2,3)//, {|| aBrw26Pr[oBrw26Pr:nAt,33]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 

Return(NIL)

/*/{Protheus.doc} Static Function Cab26P4
Gera Relatório Ref. Credito Benfeitoria Imobilizados 
@type  Function
@author Abel Babini Filho
@since 27/05/2019
@version 03
/*/
Static Function Cab26P4()
	//PLANILHA 4 - PARAMETROS
    oExcel:AddworkSheet(cFld264)
	oExcel:AddTable(cFld264,cFld26t4)
	oExcel:AddColumn(cFld264,cFld26t4, "Filial"				,1,1)//, {|| aBrw26Dt[oBrw26Dt:nAt,01]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )
	oExcel:AddColumn(cFld264,cFld26t4, "C.Base"				,1,1)//, {|| aBrw26Dt[oBrw26Dt:nAt,02]}	, "@!"						,,,"LEFT"	,030,.f.,.f.,,,,.f.,) )
	oExcel:AddColumn(cFld264,cFld26t4, "Item"					,1,1)//, {|| aBrw26Dt[oBrw26Dt:nAt,03]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )
	oExcel:AddColumn(cFld264,cFld26t4, "Descrição"		,1,1)//, {|| aBrw26Dt[oBrw26Dt:nAt,04]}	, "@!"						,,,"LEFT"	,060,.f.,.f.,,,,.f.,) )
	oExcel:AddColumn(cFld264,cFld26t4, "Cod.Forn."		,1,1)//, {|| aBrw26Dt[oBrw26Dt:nAt,12]}	, "@!"						,,,"LEFT"	,030,.f.,.f.,,,,.f.,) )
	oExcel:AddColumn(cFld264,cFld26t4, "Loja"					,1,1)//, {|| aBrw26Dt[oBrw26Dt:nAt,13]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )
	oExcel:AddColumn(cFld264,cFld26t4, "Fornecedor"		,1,1)//, {|| aBrw26Dt[oBrw26Dt:nAt,32]}	, "@!"						,,,"LEFT"	,060,.f.,.f.,,,,.f.,) )
	oExcel:AddColumn(cFld264,cFld26t4, "Dt. Aquisição",1,1)//, {|| aBrw26Dt[oBrw26Dt:nAt,05]}	, "@!"						,,,"LEFT"	,030,.f.,.f.,,,,.f.,) )
	oExcel:AddColumn(cFld264,cFld26t4 , "Vl.Orig.M1"	,2,3)//, {|| aBrw26Dt[oBrw26Dt:nAt,31]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 
	oExcel:AddColumn(cFld264,cFld26t4 , "Cod.BC Cred"	,1,1)//, {|| aBrw26Dt[oBrw26Dt:nAt,28]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )
	oExcel:AddColumn(cFld264,cFld26t4 , "CST Pis"			,1,1)//, {|| aBrw26Dt[oBrw26Dt:nAt,24]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )
	oExcel:AddColumn(cFld264,cFld26t4 , "Aliq. Pis"		,2,2)//, {|| aBrw26Dt[oBrw26Dt:nAt,25]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )
	oExcel:AddColumn(cFld264,cFld26t4 , "CST Cofins"	,1,1)//, {|| aBrw26Dt[oBrw26Dt:nAt,26]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )
	oExcel:AddColumn(cFld264,cFld26t4 , "Aliq. Cofins",2,2)//, {|| aBrw26Dt[oBrw26Dt:nAt,27]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )
	oExcel:AddColumn(cFld264,cFld26t4 , "Base Pis/Cofins"	,1,1)//, {|| aBrw26Dt[oBrw26Dt:nAt,29]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )
	oExcel:AddColumn(cFld264,cFld26t4 , "Parcelas"		,1,1)//, {|| aBrw26Dt[oBrw26Dt:nAt,06]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )
	oExcel:AddColumn(cFld264,cFld26t4 , "Meses Ja Utilizados",1,1)//, {|| aBrw26Dt[oBrw26Dt:nAt,07]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )
	oExcel:AddColumn(cFld264,cFld26t4 , "Serie NF"		,1,1)//, {|| aBrw26Dt[oBrw26Dt:nAt,14]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )
	oExcel:AddColumn(cFld264,cFld26t4 , "Nota Fiscal"	,1,1)//, {|| aBrw26Dt[oBrw26Dt:nAt,15]}	, "@!"						,,,"LEFT"	,030,.f.,.f.,,,,.f.,) )
	oExcel:AddColumn(cFld264,cFld26t4 , "Item NF"			,1,1)//, {|| aBrw26Dt[oBrw26Dt:nAt,16]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )
	oExcel:AddColumn(cFld264,cFld26t4 , "Espécie NF"	,1,1)//, {|| aBrw26Dt[oBrw26Dt:nAt,17]}	, "@!"						,,,"LEFT"	,030,.f.,.f.,,,,.f.,) )
	oExcel:AddColumn(cFld264,cFld26t4 , "Projeto"			,1,1)//, {|| aBrw26Dt[oBrw26Dt:nAt,18]}	, "@!"						,,,"LEFT"	,030,.f.,.f.,,,,.f.,) )
	oExcel:AddColumn(cFld264,cFld26t4 , "Qtd.Itens"		,2,2)//, {|| aBrw26Dt[oBrw26Dt:nAt,08]}	, "@E 999,999,999.99"		,,,"RIGHT"	,040,.f.,.f.,,,,.f.,) ) 
	oExcel:AddColumn(cFld264,cFld26t4 , "Baixa"				,1,1)//, {|| aBrw26Dt[oBrw26Dt:nAt,09]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )
	oExcel:AddColumn(cFld264,cFld26t4 , "Chapa"				,1,1)//, {|| aBrw26Dt[oBrw26Dt:nAt,10]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )
	oExcel:AddColumn(cFld264,cFld26t4 , "Grupo"				,1,1)//, {|| aBrw26Dt[oBrw26Dt:nAt,11]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )
	oExcel:AddColumn(cFld264,cFld26t4 , "Status"			,1,1)//, {|| aBrw26Dt[oBrw26Dt:nAt,19]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )
	oExcel:AddColumn(cFld264,cFld26t4 , "Calculo Pis"	,1,1)//, {|| aBrw26Dt[oBrw26Dt:nAt,20]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )
	oExcel:AddColumn(cFld264,cFld26t4 , "Data Classif."		,1,1)//, {|| aBrw26Dt[oBrw26Dt:nAt,21]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )
	oExcel:AddColumn(cFld264,cFld26t4 , "Identif. Bem",1,1)//, {|| aBrw26Dt[oBrw26Dt:nAt,22]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )
	oExcel:AddColumn(cFld264,cFld26t4 , "Utiliz. Bem"	,1,1)//, {|| aBrw26Dt[oBrw26Dt:nAt,23]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )
	oExcel:AddColumn(cFld264,cFld26t4 , "Tipo"				,1,1)//, {|| aBrw26Dt[oBrw26Dt:nAt,30]}	, "@!"						,,,"LEFT"	,020,.f.,.f.,,,,.f.,) )

Return(NIL) 

//INICIO Chamado 051633 - ABEL - 08/11/2019 - Ajustado o relatório de Benfeitoria para acrescentar planilhas de resumo
/*/{Protheus.doc} Static Function Cab26P5
Gera Relatório Ref. Credito Benfeitoria Imobilizados 
@type  Function
@author Abel Babini Filho
@since 27/05/2019
@version 03
/*/
Static Function Cab26P5()
	//PLANILHA 4 - PARAMETROS
   oExcel:AddworkSheet(cFld265)
	oExcel:AddTable(cFld265,cFld26t5)
	oExcel:AddColumn(cFld265,cFld26t5, "Filial"					,1,1)
	oExcel:AddColumn(cFld265,cFld26t5, "Descrição"			,1,1)
	oExcel:AddColumn(cFld265,cFld26t5 , "Base Cálc. Mês",2,3)
	oExcel:AddColumn(cFld265,cFld26t5 , "Vl. PIS Mês"		,2,3)
	oExcel:AddColumn(cFld265,cFld26t5 , ""							,1,1)
	oExcel:AddColumn(cFld265,cFld26t5, "Filial"					,1,1)
	oExcel:AddColumn(cFld265,cFld26t5, "Descrição"			,1,1)
	oExcel:AddColumn(cFld265,cFld26t5 , "Base Cálc. Mês",2,3)
	oExcel:AddColumn(cFld265,cFld26t5 , "Vl. COFINS Mês",2,3)
Return(NIL) 

/*/{Protheus.doc} Static Function Cab26P6
Gera Relatório Ref. Credito Benfeitoria Imobilizados 
@type  Function
@author Abel Babini Filho
@since 27/05/2019
@version 03
/*/
Static Function Cab26P6()
	//PLANILHA 4 - PARAMETROS
   oExcel:AddworkSheet(cFld266)
	oExcel:AddTable(cFld266,cFld26t6)
	oExcel:AddColumn(cFld266,cFld26t6, "Filial"					,1,1)
	oExcel:AddColumn(cFld266,cFld26t6, "Descrição"			,1,1)
	oExcel:AddColumn(cFld266,cFld26t6 , "Base Cálc. Mês",2,3)
	oExcel:AddColumn(cFld266,cFld26t6 , "Vl. PIS Mês"		,2,3)
	oExcel:AddColumn(cFld266,cFld26t6 , ""							,1,1)
	oExcel:AddColumn(cFld266,cFld26t6, "Filial"					,1,1)
	oExcel:AddColumn(cFld266,cFld26t6, "Descrição"			,1,1)
	oExcel:AddColumn(cFld266,cFld26t6 , "Base Cálc. Mês",2,3)
	oExcel:AddColumn(cFld266,cFld26t6 , "Vl. COFINS Mês",2,3)
Return(NIL) 
//FIM Chamado 051633 - ABEL - 08/11/2019 - Ajustado o relatório de Benfeitoria para acrescentar planilhas de resumo

/*/{Protheus.doc} Static Function GEx26P1
Gera Relatório Ref. Credito Benfeitoria Imobilizados 
@type  Function
@author Abel Babini Filho
@since 27/05/2019
@version 03
/*/
Static Function GEx26P1()
	oExcel:AddRow(cFld26,cFld26t1,{'Quantidade de Itens'		,nQItens	,'' })
	oExcel:AddRow(cFld26,cFld26t1,{'Total Valor Original M1'	,nVlTOrig	,'' }) 
	oExcel:AddRow(cFld26,cFld26t1,{'Total de Crédito Disponível',nVlCPT		,nVlCCT }) 
	oExcel:AddRow(cFld26,cFld26t1,{'Total Crédito no Mês'		,nTPMes		,nTCMes }) 
	oExcel:AddRow(cFld26,cFld26t1,{''							,''			,''})

Return

/*/{Protheus.doc} Static Function GEx26P2
Gera Relatório Ref. Credito Benfeitoria Imobilizados 
@type  Function
@author Abel Babini Filho
@since 27/05/2019
@version 03
/*/
Static Function GEx26P2()
	Local nExcel1 := 0
	//PIS			
	procregua(Len(aBrw26Pr))
	FOR nExcel1 := 1 TO Len(aBrw26Pr)
		IncProc()
		//Chamado 051633 - ABEL - 22/11/2019 - Ajustado o relatório de Benfeitoria para acrescentar Informações da NF
		oExcel:AddRow(cFld262,cFld26t2,;
						{aBrw26Pr[nExcel1][01],;
						aBrw26Pr[nExcel1][02],;
						aBrw26Pr[nExcel1][03],;
						aBrw26Pr[nExcel1][04],;
						aBrw26Pr[nExcel1][05],;
						aBrw26Pr[nExcel1][06],;
						aBrw26Pr[nExcel1][07],;
						aBrw26Pr[nExcel1][08],; 
						aBrw26Pr[nExcel1][09],; 		
						aBrw26Pr[nExcel1][10],; 		
						aBrw26Pr[nExcel1][11],; 		
						aBrw26Pr[nExcel1][12],; 		
						aBrw26Pr[nExcel1][13],; 		
						aBrw26Pr[nExcel1][14],; 		
						aBrw26Pr[nExcel1][15],; 		
						aBrw26Pr[nExcel1][16],; 		
						aBrw26Pr[nExcel1][17],; 		
						aBrw26Pr[nExcel1][18],; 		
						aBrw26Pr[nExcel1][19],; 		
						aBrw26Pr[nExcel1][20],; 		
						aBrw26Pr[nExcel1][21],; 		
						aBrw26Pr[nExcel1][22],; 		
						aBrw26Pr[nExcel1][23],; 		
						aBrw26Pr[nExcel1][24],; 		
						aBrw26Pr[nExcel1][25],; 		
						aBrw26Pr[nExcel1][26],; 		
						aBrw26Pr[nExcel1][27],; 		
						aBrw26Pr[nExcel1][28],; 		
						aBrw26Pr[nExcel1][29],; 		
						aBrw26Pr[nExcel1][30],;
						aBrw26Pr[nExcel1][31],;
						aBrw26Pr[nExcel1][32],;	
						aBrw26Pr[nExcel1][33],;	
						aBrw26Pr[nExcel1][34],;	
						aBrw26Pr[nExcel1][35],;	
						aBrw26Pr[nExcel1][36],;	
						aBrw26Pr[nExcel1][37]}) 


	NEXT nExcel1
	//ADICIONA LINHA EM BRANCA
	oExcel:AddRow(cFld262,cFld26t2,;
					{'',; 
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'';
					})	

Return

/*/{Protheus.doc} Static Function GEx26P3
Gera Relatório Ref. Credito Benfeitoria Imobilizados 
@type  Function
@author Abel Babini Filho
@since 27/05/2019
@version 03
/*/
Static Function GEx26P3()
	Local nExcel1 := 0
	//PIS			
	procregua(Len(aBrw26Cr))
	FOR nExcel1 := 1 TO Len(aBrw26Cr)
		IncProc()
		//Chamado 051633 - ABEL - 22/11/2019 - Ajustado o relatório de Benfeitoria para acrescentar Informações da NF
		oExcel:AddRow(cFld263,cFld26t3,;
						{aBrw26Cr[nExcel1][01],;
						aBrw26Cr[nExcel1][02],;
						aBrw26Cr[nExcel1][03],;
						aBrw26Cr[nExcel1][04],;
						aBrw26Cr[nExcel1][05],;
						aBrw26Cr[nExcel1][06],;
						aBrw26Cr[nExcel1][07],;
						aBrw26Cr[nExcel1][08],; 
						aBrw26Cr[nExcel1][09],; 		
						aBrw26Cr[nExcel1][10],; 		
						aBrw26Cr[nExcel1][11],; 		
						aBrw26Cr[nExcel1][12],; 		
						aBrw26Cr[nExcel1][13],; 		
						aBrw26Cr[nExcel1][14],; 		
						aBrw26Cr[nExcel1][15],; 		
						aBrw26Cr[nExcel1][16],; 		
						aBrw26Cr[nExcel1][17],; 		
						aBrw26Cr[nExcel1][18],; 		
						aBrw26Cr[nExcel1][19],; 		
						aBrw26Cr[nExcel1][20],; 		
						aBrw26Cr[nExcel1][21],; 		
						aBrw26Cr[nExcel1][22],; 		
						aBrw26Cr[nExcel1][23],; 		
						aBrw26Cr[nExcel1][24],; 		
						aBrw26Cr[nExcel1][25],; 		
						aBrw26Cr[nExcel1][26],; 		
						aBrw26Cr[nExcel1][27],; 		
						aBrw26Cr[nExcel1][28],; 		
						aBrw26Cr[nExcel1][29],; 		
						aBrw26Cr[nExcel1][30],;
						aBrw26Cr[nExcel1][31],;
						aBrw26Cr[nExcel1][32],;	
						aBrw26Cr[nExcel1][33],;	
						aBrw26Cr[nExcel1][34],;
						aBrw26Cr[nExcel1][35],;
						aBrw26Cr[nExcel1][36],;
						aBrw26Cr[nExcel1][37]})

	NEXT nExcel1
	//ADICIONA LINHA EM BRANCA
	oExcel:AddRow(cFld263,cFld26t3,;
					{'',; 
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'';
					})	
Return

/*/{Protheus.doc} Static Function GEx26P4
Gera Relatório Ref. Credito Benfeitoria Imobilizados 
@type  Function
@author Abel Babini Filho
@since 27/05/2019
@version 03
/*/
Static Function GEx26P4()
	Local nExcel1 := 0
	//DETALHAMENTO			
	procregua(Len(aBrw26Dt))
	FOR nExcel1 := 1 TO Len(aBrw26Dt)
		IncProc()
		oExcel:AddRow(cFld264,cFld26t4,;
						{aBrw26Dt[nExcel1][01],;
						aBrw26Dt[nExcel1][02],;
						aBrw26Dt[nExcel1][03],;
						aBrw26Dt[nExcel1][04],;
						aBrw26Dt[nExcel1][12],;
						aBrw26Dt[nExcel1][13],;
						aBrw26Dt[nExcel1][32],;
						aBrw26Dt[nExcel1][05],;
						aBrw26Dt[nExcel1][31],;
						aBrw26Dt[nExcel1][28],;
						aBrw26Dt[nExcel1][24],;
						aBrw26Dt[nExcel1][25],;
						aBrw26Dt[nExcel1][26],;
						aBrw26Dt[nExcel1][27],;
						aBrw26Dt[nExcel1][29],;
						aBrw26Dt[nExcel1][06],;
						aBrw26Dt[nExcel1][07],;
						aBrw26Dt[nExcel1][14],;
						aBrw26Dt[nExcel1][15],;
						aBrw26Dt[nExcel1][16],;
						aBrw26Dt[nExcel1][17],;
						aBrw26Dt[nExcel1][18],;
						aBrw26Dt[nExcel1][08],;
						aBrw26Dt[nExcel1][09],;
						aBrw26Dt[nExcel1][10],;
						aBrw26Dt[nExcel1][11],;
						aBrw26Dt[nExcel1][19],;
						aBrw26Dt[nExcel1][20],;
						aBrw26Dt[nExcel1][21],;
						aBrw26Dt[nExcel1][22],;
						aBrw26Dt[nExcel1][23],;
						aBrw26Dt[nExcel1][30]})
	NEXT nExcel1 

	//ADICIONA LINHA EM BRANCA
	oExcel:AddRow(cFld264,cFld26t4,;
					{'',; 
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'';
					})	

Return(NIL) 

//INICIO Chamado 051633 - ABEL - 08/11/2019 - Ajustado o relatório de Benfeitoria para acrescentar planilhas de resumo
/*/{Protheus.doc} Static Function GEx26P5
Gera Relatório Ref. Credito Benfeitoria Imobilizados 
@type  Function
@author Abel Babini Filho
@since 27/05/2019
@version 03
/*/
Static Function GEx26P5()
	Local cFAux	:= ''
	Local nTF01	:= 0
	Local nTF02	:= 0
	Local nTF03	:= 0
	Local nTF04	:= 0
	Local nTF11	:= 0
	Local nTF12	:= 0
	Local nTF13	:= 0
	Local nTF14	:= 0
	Local nExcel1 := 0
	//DETALHAMENTO			
	procregua(Len(aBrw26Sv))
	FOR nExcel1 := 1 TO Len(aBrw26Sv)
		IncProc()
		If nExcel1 > 1 .AND. cFAux <> aBrw26Sv[nExcel1][01]
			oExcel:AddRow(cFld265,cFld26t5,{cFAux,"",nTF01,nTF02,"",cFAux,"",nTF03,nTF04})
			oExcel:AddRow(cFld265,cFld26t5,{'','','','','','','','',''})
			nTF01	:= 0
			nTF02	:= 0
			nTF03	:= 0
			nTF04	:= 0			
		Endif
		oExcel:AddRow(cFld265,cFld26t5,;
						{aBrw26Sv[nExcel1][01],;
						aBrw26Sv[nExcel1][02],;
						aBrw26Sv[nExcel1][03],;
						aBrw26Sv[nExcel1][04],;
						'',;
						aBrw26Sv[nExcel1][01],;
						aBrw26Sv[nExcel1][02],;
						aBrw26Sv[nExcel1][05],;
						aBrw26Sv[nExcel1][06]})
		cFAux := aBrw26Sv[nExcel1][01]
		nTF01 += aBrw26Sv[nExcel1][03]
		nTF02 += aBrw26Sv[nExcel1][04]
		nTF03 += aBrw26Sv[nExcel1][05]
		nTF04 += aBrw26Sv[nExcel1][06]				
		nTF11 += aBrw26Sv[nExcel1][03]
		nTF12 += aBrw26Sv[nExcel1][04]
		nTF13 += aBrw26Sv[nExcel1][05]
		nTF14 += aBrw26Sv[nExcel1][06]					
		IF nExcel1 == Len(aBrw26Sv)
			oExcel:AddRow(cFld265,cFld26t5,{cFAux,"",nTF01,nTF02,"",cFAux,"",nTF03,nTF04})
			oExcel:AddRow(cFld265,cFld26t5,{'','','','','','','','',''})	
		ENDIF
	NEXT nExcel1 

	IF nExcel1 > 0
		oExcel:AddRow(cFld265,cFld26t5,{'','','','','','','','',''})	
		oExcel:AddRow(cFld265,cFld26t5,{"","TOTAL GERAL",nTF11,nTF12,"","","",nTF13,nTF14})
	ENDIF
	//ADICIONA LINHA EM BRANCA
	oExcel:AddRow(cFld265,cFld26t5,{'','','','','','','','',''})	

Return(NIL) 

/*/{Protheus.doc} Static Function GEx26P6
Gera Relatório Ref. Credito Benfeitoria Imobilizados 
@type  Function
@author Abel Babini Filho
@since 27/05/2019
@version 03
/*/
Static Function GEx26P6()
	Local cFAux	:= ''
	Local nTF01	:= 0
	Local nTF02	:= 0
	Local nTF03	:= 0
	Local nTF04	:= 0
	Local nTF11	:= 0
	Local nTF12	:= 0
	Local nTF13	:= 0
	Local nTF14	:= 0
	Local nExcel1 := 0
	//DETALHAMENTO			
	procregua(Len(aBrw26Bn))
	FOR nExcel1 := 1 TO Len(aBrw26Bn)
		IncProc()
		If nExcel1 > 1 .AND. cFAux <> aBrw26Bn[nExcel1][01]
			oExcel:AddRow(cFld266,cFld26t6,{cFAux,"",nTF01,nTF02,"",cFAux,"",nTF03,nTF04})
			oExcel:AddRow(cFld266,cFld26t6,{'','','','','','','','',''})	
			nTF01	:= 0
			nTF02	:= 0
			nTF03	:= 0
			nTF04	:= 0			
		Endif
		oExcel:AddRow(cFld266,cFld26t6,;
						{aBrw26Bn[nExcel1][01],;
						aBrw26Bn[nExcel1][02],;
						aBrw26Bn[nExcel1][03],;
						aBrw26Bn[nExcel1][04],;
						'',;
						aBrw26Bn[nExcel1][01],;
						aBrw26Bn[nExcel1][02],;
						aBrw26Bn[nExcel1][05],;
						aBrw26Bn[nExcel1][06]})
		cFAux := aBrw26Bn[nExcel1][01]
		nTF01 += aBrw26Bn[nExcel1][03]
		nTF02 += aBrw26Bn[nExcel1][04]
		nTF03 += aBrw26Bn[nExcel1][05]
		nTF04 += aBrw26Bn[nExcel1][06]							
		nTF11 += aBrw26Bn[nExcel1][03]
		nTF12 += aBrw26Bn[nExcel1][04]
		nTF13 += aBrw26Bn[nExcel1][05]
		nTF14 += aBrw26Bn[nExcel1][06]	
		IF nExcel1 == Len(aBrw26Bn)
			oExcel:AddRow(cFld266,cFld26t6,{cFAux,"",nTF01,nTF02,"",cFAux,"",nTF03,nTF04})
			oExcel:AddRow(cFld266,cFld26t6,{'','','','','','','','',''})	
		ENDIF
	NEXT nExcel1 
	IF nExcel1 > 0
		oExcel:AddRow(cFld265,cFld26t5,{'','','','','','','','',''})	
		oExcel:AddRow(cFld265,cFld26t5,{"","TOTAL GERAL",nTF11,nTF12,"","","",nTF13,nTF14})
	ENDIF

	//ADICIONA LINHA EM BRANCA
	oExcel:AddRow(cFld266,cFld26t6,{'','','','','','','','',''})	

Return(NIL) 
// FIM Chamado 051633 - ABEL - 08/11/2019 - Ajustado o relatório de Benfeitoria para acrescentar planilhas de resumo
// FIM Chamado n.045022  - Abel.Babini - Relatorio Cred Pis/Cof Parcelado sobre Ativo - 10/06/2019

/*/{Protheus.doc} Static Function xExpPISD
Gera planilha Excel com todos os relatórios de todas as Abas
@type  Function
@author Abel Babini Filho
@since 27/05/2019
@version 03
/*/
Static Function xExpPISD()
	Local aSays			:= {}
	Local aButtons		:= {}
	Local nOpca			:= 0
	Private oExcel     := FWMSEXCELEX():New()
	//Private cArquivo	:= cGetFile("Arquivo XML", "Selecione o diretório para salvar o relatório",,'C:\',.T.,GETF_RETDIRECTORY + GETF_LOCALHARD + GETF_NETWORKDRIVE)	
	Private oMsExcel   := NIL
	
	cArquivo := cPathRel +  'PNFISPISD_' + DTOS(DATE()) + STRTRAN(TIME(),':','') + '.XML'
	//+-----------------------------------------------+
	//|Monta Form Batch - Interface com o Usuario     |
	//+-----------------------------------------------+
	AADD(aSays,"Este programa tem a finalidade de Gerar um arquivo Excel do Painel Fiscal" )
	AADD(aSays,"Relatorio Detalhado Apuração Pis/Cofins" )
    
	AADD(aButtons, { 1,.T.,{|o| nOpca:=1, o:oWnd:End(), Processa({||xExPISD()},"Gerando arquivo","Aguarde...")    }})
	AADD(aButtons, { 2,.T.,{|o| nOpca:=2, o:oWnd:End() }})	
	FormBatch( cCadastr, aSays, aButtons )
Return

/*/{Protheus.doc} Static Function xExpPISR
Gera planilha Excel com todos os relatórios de todas as Abas
@type  Function
@author Abel Babini Filho
@since 27/05/2019
@version 03
/*/
Static Function xExpPISR()
	Local aSays			:= {}
	Local aButtons		:= {}
	Local nOpca			:= 0
	Private oExcel     := FWMSEXCELEX():New()
	//Private cArquivo	:= cGetFile("Arquivo XML", "Selecione o diretório para salvar o relatório",,'C:\',.T.,GETF_RETDIRECTORY + GETF_LOCALHARD + GETF_NETWORKDRIVE)	
	Private oMsExcel   := NIL
	
	cArquivo := cPathRel +  'PNFISPISR_' + DTOS(DATE()) + STRTRAN(TIME(),':','') + '.XML'
	//+-----------------------------------------------+
	//|Monta Form Batch - Interface com o Usuario     |
	//+-----------------------------------------------+
	AADD(aSays,"Este programa tem a finalidade de Gerar um arquivo Excel do Painel Fiscal" )
	AADD(aSays,"Relatorio Resumido Apuração Pis/Cofins" )
    
	AADD(aButtons, { 1,.T.,{|o| nOpca:=1, o:oWnd:End(), Processa({||xExPISR()},"Gerando arquivo","Aguarde...")    }})
	AADD(aButtons, { 2,.T.,{|o| nOpca:=2, o:oWnd:End() }})	
	FormBatch( cCadastr, aSays, aButtons )
Return

/*/{Protheus.doc} Static Function xExPISD
Gera planilha Excel com todos os relatórios de todas as Abas
@type  Function
@author Abel Babini Filho
@since 27/05/2019
@version 03
/*/
Static Function xExPISD
	BEGIN SEQUENCE
		
		IF .NOT.( ApOleClient("MsExcel") )   // se nao existir o excel sai fora..
		    Alert("Nao Existe Excel Instalado")
            BREAK
        EndIF

		//Relatório de Crédito Presumido
    	//Planilha1 - Resumo
    	Cab24P1()             
        GEx24P1()
        
        //Planilha2 - Resumo por Filial
    	Cab24P5()
        GEx24P5()
        
        //Planilha3 - Mercado Interno
    	Cab24P2()
        GEx24P2()
        
        //Planilha4 - Mercado Externo
    	Cab24P3()
        GEx24P3()

        //Planilha5 - Parametros
    	Cab24P4()
        GEx24P4()

        SalvaXml()
		CriaExcel()
	
	    MsgInfo("Arquivo Excel gerado!")    
	    
	END SEQUENCE
Return

/*/{Protheus.doc} Static Function xExPISR
Gera planilha Excel com todos os relatórios de todas as Abas
@type  Function
@author Abel Babini Filho
@since 27/05/2019
@version 03
/*/
Static Function xExPISR
	BEGIN SEQUENCE
		
		IF .NOT.( ApOleClient("MsExcel") )   // se nao existir o excel sai fora..
		    Alert("Nao Existe Excel Instalado")
            BREAK
        EndIF

		//Relatório de Crédito Presumido
    	//Planilha1 - Resumo
    	Cab24P1()             
        GEx24P1()

        //Planilha2 - Resumo por Filial
    	Cab24P5()
        GEx24P5()

        SalvaXml()
		CriaExcel()
	
	    MsgInfo("Arquivo Excel gerado!")    
	    
	END SEQUENCE
Return

// INICIO n.051633  ³ OS 052957 || FISCAL || DEJAIME || 8921 || REL. PIS/COFINS - ABEL - 09/09/2019
/*/{Protheus.doc} Static Function xABrw27
Carrega da dados Ref. Conferencia Pis/Cofins  
@type  Function
@author Abel Babini Filho
@since 27/05/2019
@version 03
/*/
Static Function xABrw27()
	
	If Select(cAlsB27Dt) > 0
		(cAlsB27Dt)->(dbCloseArea())
	Endif
	cAlsB27Dt:=GetNextAlias()

	BeginSQL  Alias cAlsB27Dt
		column N1_AQUISIC as Date
		column FT_ENTRADA as Date	
		SELECT
		  SFT.FT_FILIAL,
		  SFT.FT_ENTRADA,
		  SFT.FT_SERIE,
		  SFT.FT_NFISCAL,
		  SFT.FT_CLIEFOR,
		  SFT.FT_LOJA,
		  CASE WHEN (SFT.FT_TIPO IN ('D','B') AND SFT.FT_CFOP > '5000' ) OR (SFT.FT_TIPO NOT IN ('D','B') AND SFT.FT_CFOP < '5000' ) THEN SA2.A2_NOME	ELSE SA1.A1_NOME  	END AS NOME,
		  SFT.FT_CFOP,
		  SFT.FT_PRODUTO,
		  SB1.B1_DESC		AS PRODUTO,
		  SFT.FT_TES,
		  SFT.FT_ESPECIE,
		  SFT.FT_VALCONT,
		  SFT.FT_TOTAL,
		  SFT.FT_ICMSRET,
		  SFT.FT_IPIOBS,
		  SFT.FT_FRETE,
		  SFT.FT_SEGURO,
		  SFT.FT_DESPESA,
		  SFT.FT_POSIPI,
		  SFT.FT_DESCONT,
		  SFT.FT_BASEPIS,
		  SFT.FT_ALIQPIS,
		  SFT.FT_VALPIS,
		  SFT.FT_BASECOF,
		  SFT.FT_ALIQCOF,
		  SFT.FT_VALCOF,
		  SFT.FT_CSTPIS,
		  SFT.FT_CSTCOF,
		  SFT.FT_CODBCC,
		  SFT.FT_INDNTFR,
		  SFT.FT_OBSERV,
		  SFT.FT_FORMUL,
		  SFT.FT_CHVNFE,
		  SFT.FT_TES,
		  SN1.N1_CBASE,
		  SN1.N1_AQUISIC,
		  SN1.N1_MESCPIS,
		  DATEDIFF( month, SN1.N1_AQUISIC,%Exp:DToS(_mvpr02)%) AS QTMES2,
		  SFT.FT_BASEPIS AS N3_VORIG1,
		  CASE WHEN SN1.N1_MESCPIS > 0 THEN ROUND(SFT.FT_BASEPIS / SN1.N1_MESCPIS, 2) ELSE 0 END AS BASE_NO_MES,
		  CASE WHEN SN1.N1_MESCPIS > 0 THEN ROUND(SFT.FT_BASEPIS / SN1.N1_MESCPIS * 0.0165, 2) ELSE 0 END AS VALOR_PIS_MES,
		  CASE WHEN SN1.N1_MESCPIS > 0 THEN ROUND(SFT.FT_BASEPIS / SN1.N1_MESCPIS * 0.076, 2) ELSE 0 END AS VALOR_COFINS_MES,
		  CASE WHEN SN1.N1_XATFBEN = '1' THEN 'Benfeitoria Bens' ELSE CASE WHEN SN1.N1_XATFBEN = '2' THEN 'Benfeitoria Servicos' ELSE CASE WHEN SN1.N1_XATFBEN = '3' THEN 'Ativo Imobilizado' ELSE '' END END END AS XATFBEN
		FROM %TABLE:SFT% SFT
		LEFT JOIN %TABLE:SB1% SB1 ON
			SB1.%notDel%
		AND SB1.B1_COD = SFT.FT_PRODUTO
		LEFT JOIN %TABLE:SA2% SA2 ON
			SA2.%notDel%
		AND SA2.A2_COD = SFT.FT_CLIEFOR
		AND SA2.A2_LOJA = SFT.FT_LOJA
		AND ((SFT.FT_TIPO IN ('D','B') AND SFT.FT_CFOP > '5000') OR (SFT.FT_TIPO NOT IN ('D','B') AND SFT.FT_CFOP < '5000'))
		LEFT JOIN %TABLE:SA1% SA1 ON
			SA1.%notDel%
		AND SA1.A1_COD = SFT.FT_CLIEFOR
		AND SA1.A1_LOJA = SFT.FT_LOJA
		AND ((SFT.FT_TIPO IN ('D','B') AND SFT.FT_CFOP < '5000') OR (SFT.FT_TIPO NOT IN ('D','B') AND SFT.FT_CFOP > '5000'))
		LEFT JOIN %TABLE:SN1% SN1
		   ON SN1.N1_FILIAL = SFT.FT_FILIAL
		  AND SN1.N1_NFISCAL = SFT.FT_NFISCAL
		  AND SN1.N1_NSERIE = SFT.FT_SERIE
		  AND SN1.N1_NFITEM = SFT.FT_ITEM
		  AND SN1.N1_FORNEC = SFT.FT_CLIEFOR
		  AND SN1.N1_LOJA = SFT.FT_LOJA
		  AND SN1.N1_NFESPEC = SFT.FT_ESPECIE
		  AND SN1.%notDel%
		LEFT JOIN %TABLE:SN3% SN3
		  ON SN3.N3_FILIAL = SN1.N1_FILIAL
		  AND SN3.N3_CBASE = SN1.N1_CBASE
		  AND SN3.%notDel%
		WHERE SFT.%notDel%
		AND SFT.FT_FILIAL IN %Exp:cFilIn%
		AND (SFT.FT_ENTRADA >= %Exp:DToS(_mvpr01)%
		AND SFT.FT_ENTRADA <= %Exp:DToS(_mvpr02)%)
		AND (SFT.FT_DTCANC = '')
			
		UNION
		
		SELECT
		  SFT.FT_FILIAL,
		  SFT.FT_ENTRADA,
		  SFT.FT_SERIE,
		  SFT.FT_NFISCAL,
		  SFT.FT_CLIEFOR,
		  SFT.FT_LOJA,
		  CASE WHEN (SFT.FT_TIPO IN ('D','B') AND SFT.FT_CFOP > '5000' ) OR (SFT.FT_TIPO NOT IN ('D','B') AND SFT.FT_CFOP < '5000' ) THEN SA2.A2_NOME	ELSE SA1.A1_NOME  	END AS NOME,
		  SFT.FT_CFOP,
		  SFT.FT_PRODUTO,
		  SB1.B1_DESC		AS PRODUTO,
		  SFT.FT_TES,
		  SFT.FT_ESPECIE,
		  SFT.FT_VALCONT,
		  SFT.FT_TOTAL,
		  SFT.FT_ICMSRET,
		  SFT.FT_IPIOBS,
		  SFT.FT_FRETE,
		  SFT.FT_SEGURO,
		  SFT.FT_DESPESA,
		  SFT.FT_POSIPI,
		  SFT.FT_DESCONT,
		  SFT.FT_BASEPIS,
		  SFT.FT_ALIQPIS,
		  SFT.FT_VALPIS,
		  SFT.FT_BASECOF,
		  SFT.FT_ALIQCOF,
		  SFT.FT_VALCOF,
		  SFT.FT_CSTPIS,
		  SFT.FT_CSTCOF,
		  SFT.FT_CODBCC,
		  SFT.FT_INDNTFR,
		  SFT.FT_OBSERV,
		  SFT.FT_FORMUL,
		  SFT.FT_CHVNFE,
		  SFT.FT_TES,
		  SN1.N1_CBASE,
		  SN1.N1_AQUISIC,
		  SN1.N1_MESCPIS,
		  DATEDIFF( month, SN1.N1_AQUISIC,%Exp:DToS(_mvpr02)%) AS QTMES2,
		  SFT.FT_BASEPIS AS N3_VORIG1,
		  CASE WHEN SN1.N1_MESCPIS > 0 THEN ROUND(SFT.FT_BASEPIS / SN1.N1_MESCPIS, 2) ELSE 0 END AS BASE_NO_MES,
		  CASE WHEN SN1.N1_MESCPIS > 0 THEN ROUND(SFT.FT_BASEPIS / SN1.N1_MESCPIS * 0.0165, 2) ELSE 0 END AS VALOR_PIS_MES,
		  CASE WHEN SN1.N1_MESCPIS > 0 THEN ROUND(SFT.FT_BASEPIS / SN1.N1_MESCPIS * 0.076, 2) ELSE 0 END AS VALOR_COFINS_MES,
		  CASE WHEN SN1.N1_XATFBEN = '1' THEN 'Benfeitoria Bens' ELSE CASE WHEN SN1.N1_XATFBEN = '2' THEN 'Benfeitoria Servicos' ELSE CASE WHEN SN1.N1_XATFBEN = '3' THEN 'Ativo Imobilizado' ELSE '' END END END AS XATFBEN
		FROM %TABLE:SFT% SFT	
		LEFT JOIN %TABLE:SB1% SB1 ON
			SB1.%notDel%
		AND SB1.B1_COD = SFT.FT_PRODUTO
		LEFT JOIN %TABLE:SA2% SA2 ON
			SA2.%notDel%
		AND SA2.A2_COD = SFT.FT_CLIEFOR
		AND SA2.A2_LOJA = SFT.FT_LOJA
		AND ((SFT.FT_TIPO IN ('D','B') AND SFT.FT_CFOP > '5000') OR (SFT.FT_TIPO NOT IN ('D','B') AND SFT.FT_CFOP < '5000'))
		LEFT JOIN %TABLE:SA1% SA1 ON
			SA1.%notDel%
		AND SA1.A1_COD = SFT.FT_CLIEFOR
		AND SA1.A1_LOJA = SFT.FT_LOJA
		AND ((SFT.FT_TIPO IN ('D','B') AND SFT.FT_CFOP < '5000') OR (SFT.FT_TIPO NOT IN ('D','B') AND SFT.FT_CFOP > '5000'))
		LEFT JOIN %TABLE:SN1% SN1
		   ON SN1.N1_FILIAL = SFT.FT_FILIAL
		  AND SN1.N1_NFISCAL = SFT.FT_NFISCAL
		  AND SN1.N1_NSERIE = SFT.FT_SERIE
		  AND SN1.N1_NFITEM = SFT.FT_ITEM
		  AND SN1.N1_FORNEC = SFT.FT_CLIEFOR
		  AND SN1.N1_LOJA = SFT.FT_LOJA
		  AND SN1.N1_NFESPEC = SFT.FT_ESPECIE
		  AND SN1.%notDel%
		LEFT JOIN %TABLE:SN3% SN3
		  ON SN3.N3_FILIAL = SN1.N1_FILIAL
		  AND SN3.N3_CBASE = SN1.N1_CBASE
		  AND SN3.N3_ITEM	= SN1.N1_ITEM
		  AND SN3.%notDel%
		WHERE SFT.%notDel%
		AND SFT.FT_FILIAL IN %Exp:cFilIn%
		AND SFT.FT_ENTRADA < %Exp:DToS(_mvpr01)%
		AND (SFT.FT_DTCANC = '')
		AND SN3.N3_TIPO = '01'
		AND SN1.N1_CALCPIS IN ('3')
		AND SN1.N1_AQUISIC < %Exp:DToS(_mvpr01)%
		AND DATEDIFF( month, N1_AQUISIC,%Exp:DToS(_mvpr02)%)+1 <= N1_MESCPIS	
	EndSQL
	
		
	//Inicializa Arrays
	aBrw27Be	:= {}
	aBrw27Se	:= {}
	aBrw27SN	:= {}
	aBrw27Im	:= {}
	aBrw27Dt	:= {}
	
	nA27T01		:= 0
	nA27T02		:= 0
	nA27T03		:= 0
	nA27T04		:= 0
	
	nA27T11		:= 0
	nA27T12		:= 0
	nA27T13		:= 0
	nA27T14		:= 0
	nA27T15		:= 0
	nA27T16		:= 0
	nA27T17		:= 0
	nA27T18		:= 0
	
	nA27T21		:= 0
	nA27T22		:= 0
	nA27T23		:= 0
	nA27T24		:= 0
	nA27T25		:= 0
	nA27T26		:= 0
	nA27T27		:= 0
	nA27T28		:= 0
	
	nA27T31		:= 0
	nA27T32		:= 0
	nA27T33		:= 0
	nA27T34		:= 0
	
		
	(cAlsB27Dt)->(dbGoTop())
	While !(cAlsB27Dt)->(Eof())
				
		//Adiciona linhas ao Array de Detalhes
		AADD(aBrw27Dt,{;
			(cAlsB27Dt)->FT_FILIAL,;
			(cAlsB27Dt)->FT_ENTRADA,;
			(cAlsB27Dt)->FT_SERIE,;
			(cAlsB27Dt)->FT_NFISCAL,;
			(cAlsB27Dt)->FT_CLIEFOR,;
			(cAlsB27Dt)->FT_LOJA,;
			(cAlsB27Dt)->NOME,;
			(cAlsB27Dt)->FT_CFOP,;
			(cAlsB27Dt)->FT_PRODUTO,;
			(cAlsB27Dt)->PRODUTO,;
			(cAlsB27Dt)->FT_TES,;
			(cAlsB27Dt)->FT_ESPECIE,;
			(cAlsB27Dt)->FT_VALCONT,;
			(cAlsB27Dt)->FT_TOTAL,;
			(cAlsB27Dt)->FT_ICMSRET,;
			(cAlsB27Dt)->FT_IPIOBS,;
			(cAlsB27Dt)->FT_FRETE,;
			(cAlsB27Dt)->FT_SEGURO,;
			(cAlsB27Dt)->FT_DESPESA,;
			(cAlsB27Dt)->FT_POSIPI,;
			(cAlsB27Dt)->FT_DESCONT,;
			(cAlsB27Dt)->FT_BASEPIS,;
			(cAlsB27Dt)->FT_ALIQPIS,;
			(cAlsB27Dt)->FT_VALPIS,;
			(cAlsB27Dt)->FT_BASECOF,;
			(cAlsB27Dt)->FT_ALIQCOF,;
			(cAlsB27Dt)->FT_VALCOF,;
			(cAlsB27Dt)->FT_CSTPIS,;
			(cAlsB27Dt)->FT_CSTCOF,;
			(cAlsB27Dt)->FT_CODBCC,;
			(cAlsB27Dt)->FT_INDNTFR,;
			(cAlsB27Dt)->FT_OBSERV,;
			(cAlsB27Dt)->FT_FORMUL,;
			(cAlsB27Dt)->FT_CHVNFE,;
			(cAlsB27Dt)->N1_CBASE,;
			(cAlsB27Dt)->N1_AQUISIC,;
			(cAlsB27Dt)->N1_MESCPIS,;
			(cAlsB27Dt)->QTMES2,;
			(cAlsB27Dt)->N3_VORIG1,;
			(cAlsB27Dt)->BASE_NO_MES,;
			(cAlsB27Dt)->VALOR_PIS_MES,;
			(cAlsB27Dt)->VALOR_COFINS_MES,;
			(cAlsB27Dt)->XATFBEN})
		
		IF Alltrim((cAlsB27Dt)->FT_CFOP) $ '1551,2551,3551'
		
			if Alltrim((cAlsB27Dt)->XATFBEN) == 'Ativo Imobilizado'
				//Adiciona linhas ao Array de Bens
				AADD(aBrw27Im,{;
					(cAlsB27Dt)->FT_FILIAL,;
					(cAlsB27Dt)->FT_ENTRADA,;
					(cAlsB27Dt)->FT_SERIE,;
					(cAlsB27Dt)->FT_NFISCAL,;
					(cAlsB27Dt)->FT_CLIEFOR,;
					(cAlsB27Dt)->FT_LOJA,;
					(cAlsB27Dt)->NOME,;
					(cAlsB27Dt)->FT_CFOP,;
					(cAlsB27Dt)->FT_PRODUTO,;
					(cAlsB27Dt)->PRODUTO,;
					(cAlsB27Dt)->FT_TES,;
					(cAlsB27Dt)->FT_ESPECIE,;
					(cAlsB27Dt)->FT_VALCONT,;
					(cAlsB27Dt)->FT_TOTAL,;
					(cAlsB27Dt)->FT_ICMSRET,;
					(cAlsB27Dt)->FT_IPIOBS,;
					(cAlsB27Dt)->FT_FRETE,;
					(cAlsB27Dt)->FT_SEGURO,;
					(cAlsB27Dt)->FT_DESPESA,;
					(cAlsB27Dt)->FT_POSIPI,;
					(cAlsB27Dt)->FT_DESCONT,;
					(cAlsB27Dt)->FT_BASEPIS,;
					(cAlsB27Dt)->FT_ALIQPIS,;
					(cAlsB27Dt)->FT_VALPIS,;
					(cAlsB27Dt)->FT_BASECOF,;
					(cAlsB27Dt)->FT_ALIQCOF,;
					(cAlsB27Dt)->FT_VALCOF,;
					(cAlsB27Dt)->FT_CSTPIS,;
					(cAlsB27Dt)->FT_CSTCOF,;
					(cAlsB27Dt)->FT_CODBCC,;
					(cAlsB27Dt)->FT_INDNTFR,;
					(cAlsB27Dt)->FT_OBSERV,;
					(cAlsB27Dt)->FT_FORMUL,;
					(cAlsB27Dt)->FT_CHVNFE,;
					(cAlsB27Dt)->N1_CBASE,;
					(cAlsB27Dt)->N1_AQUISIC,;
					(cAlsB27Dt)->N1_MESCPIS,;
					(cAlsB27Dt)->QTMES2,;
					(cAlsB27Dt)->N3_VORIG1,;
					(cAlsB27Dt)->BASE_NO_MES,;
					(cAlsB27Dt)->VALOR_PIS_MES,;
					(cAlsB27Dt)->VALOR_COFINS_MES,;
					(cAlsB27Dt)->XATFBEN})

				nA27T01	+= 1
				nA27T02	+= (cAlsB27Dt)->FT_BASEPIS	
				nA27T03	+= (cAlsB27Dt)->FT_VALPIS
				nA27T04	+= (cAlsB27Dt)->FT_VALCOF
			else
				//Adiciona linhas ao Array de Bens
				AADD(aBrw27Be,{;
					(cAlsB27Dt)->FT_FILIAL,;
					(cAlsB27Dt)->FT_ENTRADA,;
					(cAlsB27Dt)->FT_SERIE,;
					(cAlsB27Dt)->FT_NFISCAL,;
					(cAlsB27Dt)->FT_CLIEFOR,;
					(cAlsB27Dt)->FT_LOJA,;
					(cAlsB27Dt)->NOME,;
					(cAlsB27Dt)->FT_CFOP,;
					(cAlsB27Dt)->FT_PRODUTO,;
					(cAlsB27Dt)->PRODUTO,;
					(cAlsB27Dt)->FT_TES,;
					(cAlsB27Dt)->FT_ESPECIE,;
					(cAlsB27Dt)->FT_VALCONT,;
					(cAlsB27Dt)->FT_TOTAL,;
					(cAlsB27Dt)->FT_ICMSRET,;
					(cAlsB27Dt)->FT_IPIOBS,;
					(cAlsB27Dt)->FT_FRETE,;
					(cAlsB27Dt)->FT_SEGURO,;
					(cAlsB27Dt)->FT_DESPESA,;
					(cAlsB27Dt)->FT_POSIPI,;
					(cAlsB27Dt)->FT_DESCONT,;
					(cAlsB27Dt)->FT_BASEPIS,;
					(cAlsB27Dt)->FT_ALIQPIS,;
					(cAlsB27Dt)->FT_VALPIS,;
					(cAlsB27Dt)->FT_BASECOF,;
					(cAlsB27Dt)->FT_ALIQCOF,;
					(cAlsB27Dt)->FT_VALCOF,;
					(cAlsB27Dt)->FT_CSTPIS,;
					(cAlsB27Dt)->FT_CSTCOF,;
					(cAlsB27Dt)->FT_CODBCC,;
					(cAlsB27Dt)->FT_INDNTFR,;
					(cAlsB27Dt)->FT_OBSERV,;
					(cAlsB27Dt)->FT_FORMUL,;
					(cAlsB27Dt)->FT_CHVNFE,;
					(cAlsB27Dt)->N1_CBASE,;
					(cAlsB27Dt)->N1_AQUISIC,;
					(cAlsB27Dt)->N1_MESCPIS,;
					(cAlsB27Dt)->QTMES2,;
					(cAlsB27Dt)->N3_VORIG1,;
					(cAlsB27Dt)->BASE_NO_MES,;
					(cAlsB27Dt)->VALOR_PIS_MES,;
					(cAlsB27Dt)->VALOR_COFINS_MES,;
					(cAlsB27Dt)->XATFBEN})					

				nA27T11	+= 1
				nA27T12	+= (cAlsB27Dt)->BASE_NO_MES	
				nA27T13	+= (cAlsB27Dt)->VALOR_PIS_MES
				nA27T14	+= (cAlsB27Dt)->VALOR_COFINS_MES
				
				if (cAlsB27Dt)->QTMES2 > 0
					nA27T15	+= (cAlsB27Dt)->VALOR_PIS_MES
					nA27T17	+= (cAlsB27Dt)->VALOR_COFINS_MES				
				else
					nA27T16	+= (cAlsB27Dt)->VALOR_PIS_MES
					nA27T18	+= (cAlsB27Dt)->VALOR_COFINS_MES				
				endif
			endif

		ELSEIF Alltrim((cAlsB27Dt)->FT_CFOP) $ '1126,2126,3126'
			if Alltrim((cAlsB27Dt)->FT_TES) $ '04J'
				//Adiciona linhas ao Array de Serviços
				AADD(aBrw27SN,{;
					(cAlsB27Dt)->FT_FILIAL,;
					(cAlsB27Dt)->FT_ENTRADA,;
					(cAlsB27Dt)->FT_SERIE,;
					(cAlsB27Dt)->FT_NFISCAL,;
					(cAlsB27Dt)->FT_CLIEFOR,;
					(cAlsB27Dt)->FT_LOJA,;
					(cAlsB27Dt)->NOME,;
					(cAlsB27Dt)->FT_CFOP,;
					(cAlsB27Dt)->FT_PRODUTO,;
					(cAlsB27Dt)->PRODUTO,;
					(cAlsB27Dt)->FT_TES,;
					(cAlsB27Dt)->FT_ESPECIE,;
					(cAlsB27Dt)->FT_VALCONT,;
					(cAlsB27Dt)->FT_TOTAL,;
					(cAlsB27Dt)->FT_ICMSRET,;
					(cAlsB27Dt)->FT_IPIOBS,;
					(cAlsB27Dt)->FT_FRETE,;
					(cAlsB27Dt)->FT_SEGURO,;
					(cAlsB27Dt)->FT_DESPESA,;
					(cAlsB27Dt)->FT_POSIPI,;
					(cAlsB27Dt)->FT_DESCONT,;
					(cAlsB27Dt)->FT_BASEPIS,;
					(cAlsB27Dt)->FT_ALIQPIS,;
					(cAlsB27Dt)->FT_VALPIS,;
					(cAlsB27Dt)->FT_BASECOF,;
					(cAlsB27Dt)->FT_ALIQCOF,;
					(cAlsB27Dt)->FT_VALCOF,;
					(cAlsB27Dt)->FT_CSTPIS,;
					(cAlsB27Dt)->FT_CSTCOF,;
					(cAlsB27Dt)->FT_CODBCC,;
					(cAlsB27Dt)->FT_INDNTFR,;
					(cAlsB27Dt)->FT_OBSERV,;
					(cAlsB27Dt)->FT_FORMUL,;
					(cAlsB27Dt)->FT_CHVNFE,;
					(cAlsB27Dt)->N1_CBASE,;
					(cAlsB27Dt)->N1_AQUISIC,;
					(cAlsB27Dt)->N1_MESCPIS,;
					(cAlsB27Dt)->QTMES2,;
					(cAlsB27Dt)->N3_VORIG1,;
					(cAlsB27Dt)->BASE_NO_MES,;
					(cAlsB27Dt)->VALOR_PIS_MES,;
					(cAlsB27Dt)->VALOR_COFINS_MES,;
					(cAlsB27Dt)->XATFBEN})		

				nA27T31	+= 1
				nA27T32	+= (cAlsB27Dt)->FT_BASEPIS	
				nA27T33	+= (cAlsB27Dt)->FT_VALPIS
				nA27T34	+= (cAlsB27Dt)->FT_VALCOF
			else
				//Adiciona linhas ao Array de Serviços
				AADD(aBrw27Se,{;
					(cAlsB27Dt)->FT_FILIAL,;
					(cAlsB27Dt)->FT_ENTRADA,;
					(cAlsB27Dt)->FT_SERIE,;
					(cAlsB27Dt)->FT_NFISCAL,;
					(cAlsB27Dt)->FT_CLIEFOR,;
					(cAlsB27Dt)->FT_LOJA,;
					(cAlsB27Dt)->NOME,;
					(cAlsB27Dt)->FT_CFOP,;
					(cAlsB27Dt)->FT_PRODUTO,;
					(cAlsB27Dt)->PRODUTO,;
					(cAlsB27Dt)->FT_TES,;
					(cAlsB27Dt)->FT_ESPECIE,;
					(cAlsB27Dt)->FT_VALCONT,;
					(cAlsB27Dt)->FT_TOTAL,;
					(cAlsB27Dt)->FT_ICMSRET,;
					(cAlsB27Dt)->FT_IPIOBS,;
					(cAlsB27Dt)->FT_FRETE,;
					(cAlsB27Dt)->FT_SEGURO,;
					(cAlsB27Dt)->FT_DESPESA,;
					(cAlsB27Dt)->FT_POSIPI,;
					(cAlsB27Dt)->FT_DESCONT,;
					(cAlsB27Dt)->FT_BASEPIS,;
					(cAlsB27Dt)->FT_ALIQPIS,;
					(cAlsB27Dt)->FT_VALPIS,;
					(cAlsB27Dt)->FT_BASECOF,;
					(cAlsB27Dt)->FT_ALIQCOF,;
					(cAlsB27Dt)->FT_VALCOF,;
					(cAlsB27Dt)->FT_CSTPIS,;
					(cAlsB27Dt)->FT_CSTCOF,;
					(cAlsB27Dt)->FT_CODBCC,;
					(cAlsB27Dt)->FT_INDNTFR,;
					(cAlsB27Dt)->FT_OBSERV,;
					(cAlsB27Dt)->FT_FORMUL,;
					(cAlsB27Dt)->FT_CHVNFE,;
					(cAlsB27Dt)->N1_CBASE,;
					(cAlsB27Dt)->N1_AQUISIC,;
					(cAlsB27Dt)->N1_MESCPIS,;
					(cAlsB27Dt)->QTMES2,;
					(cAlsB27Dt)->N3_VORIG1,;
					(cAlsB27Dt)->BASE_NO_MES,;
					(cAlsB27Dt)->VALOR_PIS_MES,;
					(cAlsB27Dt)->VALOR_COFINS_MES,;
					(cAlsB27Dt)->XATFBEN})					

				nA27T21	+= 1
				nA27T22	+= (cAlsB27Dt)->BASE_NO_MES	
				nA27T23	+= (cAlsB27Dt)->VALOR_PIS_MES
				nA27T24	+= (cAlsB27Dt)->VALOR_COFINS_MES
				
				if (cAlsB27Dt)->QTMES2 > 0
					nA27T25	+= (cAlsB27Dt)->VALOR_PIS_MES
					nA27T27	+= (cAlsB27Dt)->VALOR_COFINS_MES				
				else
					nA27T26	+= (cAlsB27Dt)->VALOR_PIS_MES
					nA27T28	+= (cAlsB27Dt)->VALOR_COFINS_MES				
				endif
			endif

		ENDIF
		
		(cAlsB27Dt)->(dbSkip())
	EndDo

Return

/*/{Protheus.doc} Static Function xRelBr27
Carrega da dados Ref. Conferencia Pis/Cofins  
@type  Function
@author Abel Babini Filho
@since 27/05/2019
@version 03
/*/
Static Function xRelBr27()
	Local aSays			:= {}
	Local aButtons		:= {}
	Local nOpca			:= 0
	Private oExcel     := FWMSEXCELEX():New()
	//Private cArquivo	:= cGetFile("Arquivo XML", "Selecione o diretório para salvar o relatório",,'C:\',.T.,GETF_RETDIRECTORY + GETF_LOCALHARD + GETF_NETWORKDRIVE)	
	Private oMsExcel   := NIL
	
	cArquivo := cPathRel +  'RCONFPISCOF_' + DTOS(DATE()) + STRTRAN(TIME(),':','') + '.XML'
	//+-----------------------------------------------+
	//|Monta Form Batch - Interface com o Usuario     |
	//+-----------------------------------------------+
	AADD(aSays,"Este programa tem a finalidade de Gerar um arquivo Excel " )
	AADD(aSays,"Relatorio de Credito de Pis/Cofins sobre Benfeitorias em Imobilizados" )
    
	AADD(aButtons, { 1,.T.,{|o| nOpca:=1, o:oWnd:End(), Processa({||xRelBr27b()},"Gerando arquivo","Aguarde...")    }})
	AADD(aButtons, { 2,.T.,{|o| nOpca:=2, o:oWnd:End() }})	
	FormBatch( cCadastr, aSays, aButtons )
	
Return

/*/{Protheus.doc} Static Function xRelBr27b
Carrega da dados Ref. Conferencia Pis/Cofins  
@type  Function
@author Abel Babini Filho
@since 27/05/2019
@version 03
/*/
Static Function xRelBr27b()
	BEGIN SEQUENCE
		
		IF .NOT.( ApOleClient("MsExcel") )   // se nao existir o excel sai fora..
		    Alert("Nao Existe Excel Instalado")
            BREAK
        EndIF
        	
    	//Planilha1 - Resumo
    	Cab27P1()             
        GEx27P1()

    	//Planilha3 - Detalhe
    	Cab27P2()             
        GEx27P2()

    	//Planilha3 - IMOBILIZADO
    	Cab27P3()             
        GEx27P3()

        //Planilha4 - BENFEITORIA COM BENS
    	Cab27P4()
        GEx27P4()

        //Planilha4 - BENFEITORIA COM SERVIÇOS
    	Cab27P5()
        GEx27P5()

        //Planilha4 - SERVIÇOS SEM CREDITO
    	Cab27P6()
        GEx27P6()

        SalvaXml()
		CriaExcel()
	
	    MsgInfo("Arquivo Excel gerado!")    
	    
	END SEQUENCE

Return

/*/{Protheus.doc} Static Function Cab27P1
Carrega da dados Ref. Conferencia Pis/Cofins  
@type  Function
@author Abel Babini Filho
@since 27/05/2019
@version 03
/*/
Static Function Cab27P1() 	
	// Local nColBr27	:= 0
	//PLANILHA 1 - RESUMO
	oExcel:AddworkSheet(cFld27)
	oExcel:AddTable (cFld27,cFld27t1)
	oExcel:AddColumn(cFld27,cFld27t1,"Descrição"		,1,1)
	oExcel:AddColumn(cFld27,cFld27t1,"IMOBILIZADO"		,2,2)
	oExcel:AddColumn(cFld27,cFld27t1,"BENF. BENS"		,2,2)
	oExcel:AddColumn(cFld27,cFld27t1,"BENF. SERV"		,2,2)
	oExcel:AddColumn(cFld27,cFld27t1,"SERV. S/ CRÉDITO"	,2,2)

RETURN(NIL)  

/*/{Protheus.doc} Static Function Cab27P2
Carrega da dados Ref. Conferencia Pis/Cofins  
@type  Function
@author Abel Babini Filho
@since 27/05/2019
@version 03
/*/
Static Function Cab27P2()
 	//DETALHE
    oExcel:AddworkSheet(cFld272)
	oExcel:AddTable (cFld272,cFld27t2)
	oExcel:AddColumn(cFld272,cFld27t2, "Filial"			,1,1)
	oExcel:AddColumn(cFld272,cFld27t2, "Dt.Entrada"		,1,1)
	oExcel:AddColumn(cFld272,cFld27t2, "Serie"			,1,1)
	oExcel:AddColumn(cFld272,cFld27t2, "NF"				,1,1)
	oExcel:AddColumn(cFld272,cFld27t2, "Cod.Forn."		,1,1)
	oExcel:AddColumn(cFld272,cFld27t2, "Loja"			,1,1)
	oExcel:AddColumn(cFld272,cFld27t2, "Fornecedor"		,1,1)
	oExcel:AddColumn(cFld272,cFld27t2, "CFOP"			,1,1)
	oExcel:AddColumn(cFld272,cFld27t2, "Cod.Prod."		,1,1)
	oExcel:AddColumn(cFld272,cFld27t2, "Produto"		,1,1)
	oExcel:AddColumn(cFld272,cFld27t2, "TES"			,1,1)
	oExcel:AddColumn(cFld272,cFld27t2, "Espécie NF"		,1,1)
	oExcel:AddColumn(cFld272,cFld27t2, "Vl.Contabil"	,2,3,.T.)
	oExcel:AddColumn(cFld272,cFld27t2, "Vl.Total"		,2,3,.T.)
	oExcel:AddColumn(cFld272,cFld27t2, "ICMS Ret."		,2,3)
	oExcel:AddColumn(cFld272,cFld27t2, "IPI Obs."		,2,3)
	oExcel:AddColumn(cFld272,cFld27t2, "Vl.Frete"		,2,3)
	oExcel:AddColumn(cFld272,cFld27t2, "Vl.Seguro"		,2,3)
	oExcel:AddColumn(cFld272,cFld27t2, "Vl.Despesa"		,2,3)
	oExcel:AddColumn(cFld272,cFld27t2, "NCM"			,1,1)
	oExcel:AddColumn(cFld272,cFld27t2, "Vl.Desconto"	,2,3)
	oExcel:AddColumn(cFld272,cFld27t2, "Base Pis"		,2,3,.T.)
	oExcel:AddColumn(cFld272,cFld27t2, "Aliq.Pis"		,2,3)
	oExcel:AddColumn(cFld272,cFld27t2, "Val.Pis"		,2,3,.T.)
	oExcel:AddColumn(cFld272,cFld27t2, "Base Cofins"	,2,3,.T.)
	oExcel:AddColumn(cFld272,cFld27t2, "Aliq.Cofins"	,2,3)
	oExcel:AddColumn(cFld272,cFld27t2, "Val.Cofins"		,2,3,.T.)
	oExcel:AddColumn(cFld272,cFld27t2, "CST Pis"		,1,1)
	oExcel:AddColumn(cFld272,cFld27t2, "CST Cofins"		,1,1)
	oExcel:AddColumn(cFld272,cFld27t2, "Cod.BC Cred"	,1,1)
	oExcel:AddColumn(cFld272,cFld27t2, "Ind.Nat.Frete"	,1,1)
	oExcel:AddColumn(cFld272,cFld27t2, "Observ."		,1,1)
	oExcel:AddColumn(cFld272,cFld27t2, "Form.Prop."		,1,1)
	oExcel:AddColumn(cFld272,cFld27t2, "Chave NF-e"		,1,1)
	oExcel:AddColumn(cFld272,cFld27t2, "Cod.Base ATF"	,1,1)
	oExcel:AddColumn(cFld272,cFld27t2, "Dt.Aquisição"	,1,1)
	oExcel:AddColumn(cFld272,cFld27t2, "Parcelas"		,1,1)
	oExcel:AddColumn(cFld272,cFld27t2, "Meses Ja Utilizados",1,1)
	oExcel:AddColumn(cFld272,cFld27t2, "Base Calc. Total"	,2,3,.T.)
	oExcel:AddColumn(cFld272,cFld27t2, "Base Calc. Mes"		,2,3,.T.)
	oExcel:AddColumn(cFld272,cFld27t2, "Valor Pis Mes"		,2,3,.T.)
	oExcel:AddColumn(cFld272,cFld27t2, "Valor Cofins Mes"	,2,3,.T.)
	oExcel:AddColumn(cFld272,cFld27t2, "Utiliz. Bem"		,1,1) 

Return(NIL)

/*/{Protheus.doc} Static Function Cab27P3
Carrega da dados Ref. Conferencia Pis/Cofins  
@type  Function
@author Abel Babini Filho
@since 27/05/2019
@version 03
/*/
Static Function Cab27P3()
 	//DETALHE
    oExcel:AddworkSheet(cFld273)
	oExcel:AddTable (cFld273,cFld27t3)
	oExcel:AddColumn(cFld273,cFld27t3, "Filial"			,1,1)
	oExcel:AddColumn(cFld273,cFld27t3, "Dt.Entrada"		,1,1)
	oExcel:AddColumn(cFld273,cFld27t3, "Serie"			,1,1)
	oExcel:AddColumn(cFld273,cFld27t3, "NF"				,1,1)
	oExcel:AddColumn(cFld273,cFld27t3, "Cod.Forn."		,1,1)
	oExcel:AddColumn(cFld273,cFld27t3, "Loja"			,1,1)
	oExcel:AddColumn(cFld273,cFld27t3, "Fornecedor"		,1,1)
	oExcel:AddColumn(cFld273,cFld27t3, "CFOP"			,1,1)
	oExcel:AddColumn(cFld273,cFld27t3, "Cod.Prod."		,1,1)
	oExcel:AddColumn(cFld273,cFld27t3, "Produto"		,1,1)
	oExcel:AddColumn(cFld273,cFld27t3, "TES"			,1,1)
	oExcel:AddColumn(cFld273,cFld27t3, "Espécie NF"		,1,1)
	oExcel:AddColumn(cFld273,cFld27t3, "Vl.Contabil"	,2,3,.T.)
	oExcel:AddColumn(cFld273,cFld27t3, "Vl.Total"		,2,3,.T.)
	oExcel:AddColumn(cFld273,cFld27t3, "ICMS Ret."		,2,3)
	oExcel:AddColumn(cFld273,cFld27t3, "IPI Obs."		,2,3)
	oExcel:AddColumn(cFld273,cFld27t3, "Vl.Frete"		,2,3)
	oExcel:AddColumn(cFld273,cFld27t3, "Vl.Seguro"		,2,3)
	oExcel:AddColumn(cFld273,cFld27t3, "Vl.Despesa"		,2,3)
	oExcel:AddColumn(cFld273,cFld27t3, "NCM"			,1,1)
	oExcel:AddColumn(cFld273,cFld27t3, "Vl.Desconto"	,2,3)
	oExcel:AddColumn(cFld273,cFld27t3, "Base Pis"		,2,3,.T.)
	oExcel:AddColumn(cFld273,cFld27t3, "Aliq.Pis"		,2,3)
	oExcel:AddColumn(cFld273,cFld27t3, "Val.Pis"		,2,3,.T.)
	oExcel:AddColumn(cFld273,cFld27t3, "Base Cofins"	,2,3,.T.)
	oExcel:AddColumn(cFld273,cFld27t3, "Aliq.Cofins"	,2,3)
	oExcel:AddColumn(cFld273,cFld27t3, "Val.Cofins"		,2,3,.T.)
	oExcel:AddColumn(cFld273,cFld27t3, "CST Pis"		,1,1)
	oExcel:AddColumn(cFld273,cFld27t3, "CST Cofins"		,1,1)
	oExcel:AddColumn(cFld273,cFld27t3, "Cod.BC Cred"	,1,1)
	oExcel:AddColumn(cFld273,cFld27t3, "Ind.Nat.Frete"	,1,1)
	oExcel:AddColumn(cFld273,cFld27t3, "Observ."		,1,1)
	oExcel:AddColumn(cFld273,cFld27t3, "Form.Prop."		,1,1)
	oExcel:AddColumn(cFld273,cFld27t3, "Chave NF-e"		,1,1)
	oExcel:AddColumn(cFld273,cFld27t3, "Cod.Base ATF"	,1,1)
	oExcel:AddColumn(cFld273,cFld27t3, "Dt.Aquisição"	,1,1)
	oExcel:AddColumn(cFld273,cFld27t3, "Parcelas"		,1,1)
	oExcel:AddColumn(cFld273,cFld27t3, "Meses Ja Utilizados",1,1)
	oExcel:AddColumn(cFld273,cFld27t3, "Base Calc. Total"	,2,3,.T.)
	oExcel:AddColumn(cFld273,cFld27t3, "Base Calc. Mes"		,2,3,.T.)
	oExcel:AddColumn(cFld273,cFld27t3, "Valor Pis Mes"		,2,3,.T.)
	oExcel:AddColumn(cFld273,cFld27t3, "Valor Cofins Mes"	,2,3,.T.)
	oExcel:AddColumn(cFld273,cFld27t3, "Utiliz. Bem"		,1,1) 

Return(NIL)

/*/{Protheus.doc} Static Function Cab27P4
Carrega da dados Ref. Conferencia Pis/Cofins  
@type  Function
@author Abel Babini Filho
@since 27/05/2019
@version 03
/*/
Static Function Cab27P4()
 	//DETALHE
    oExcel:AddworkSheet(cFld274)
	oExcel:AddTable (cFld274,cFld27t4)
	oExcel:AddColumn(cFld274,cFld27t4, "Filial"			,1,1)
	oExcel:AddColumn(cFld274,cFld27t4, "Dt.Entrada"		,1,1)
	oExcel:AddColumn(cFld274,cFld27t4, "Serie"			,1,1)
	oExcel:AddColumn(cFld274,cFld27t4, "NF"				,1,1)
	oExcel:AddColumn(cFld274,cFld27t4, "Cod.Forn."		,1,1)
	oExcel:AddColumn(cFld274,cFld27t4, "Loja"			,1,1)
	oExcel:AddColumn(cFld274,cFld27t4, "Fornecedor"		,1,1)
	oExcel:AddColumn(cFld274,cFld27t4, "CFOP"			,1,1)
	oExcel:AddColumn(cFld274,cFld27t4, "Cod.Prod."		,1,1)
	oExcel:AddColumn(cFld274,cFld27t4, "Produto"		,1,1)
	oExcel:AddColumn(cFld274,cFld27t4, "TES"			,1,1)
	oExcel:AddColumn(cFld274,cFld27t4, "Espécie NF"		,1,1)
	oExcel:AddColumn(cFld274,cFld27t4, "Vl.Contabil"	,2,3,.T.)
	oExcel:AddColumn(cFld274,cFld27t4, "Vl.Total"		,2,3,.T.)
	oExcel:AddColumn(cFld274,cFld27t4, "ICMS Ret."		,2,3)
	oExcel:AddColumn(cFld274,cFld27t4, "IPI Obs."		,2,3)
	oExcel:AddColumn(cFld274,cFld27t4, "Vl.Frete"		,2,3)
	oExcel:AddColumn(cFld274,cFld27t4, "Vl.Seguro"		,2,3)
	oExcel:AddColumn(cFld274,cFld27t4, "Vl.Despesa"		,2,3)
	oExcel:AddColumn(cFld274,cFld27t4, "NCM"			,1,1)
	oExcel:AddColumn(cFld274,cFld27t4, "Vl.Desconto"	,2,3)
	oExcel:AddColumn(cFld274,cFld27t4, "Base Pis"		,2,3,.T.)
	oExcel:AddColumn(cFld274,cFld27t4, "Aliq.Pis"		,2,3)
	oExcel:AddColumn(cFld274,cFld27t4, "Val.Pis"		,2,3,.T.)
	oExcel:AddColumn(cFld274,cFld27t4, "Base Cofins"	,2,3,.T.)
	oExcel:AddColumn(cFld274,cFld27t4, "Aliq.Cofins"	,2,3)
	oExcel:AddColumn(cFld274,cFld27t4, "Val.Cofins"		,2,3,.T.)
	oExcel:AddColumn(cFld274,cFld27t4, "CST Pis"		,1,1)
	oExcel:AddColumn(cFld274,cFld27t4, "CST Cofins"		,1,1)
	oExcel:AddColumn(cFld274,cFld27t4, "Cod.BC Cred"	,1,1)
	oExcel:AddColumn(cFld274,cFld27t4, "Ind.Nat.Frete"	,1,1)
	oExcel:AddColumn(cFld274,cFld27t4, "Observ."		,1,1)
	oExcel:AddColumn(cFld274,cFld27t4, "Form.Prop."		,1,1)
	oExcel:AddColumn(cFld274,cFld27t4, "Chave NF-e"		,1,1)
	oExcel:AddColumn(cFld274,cFld27t4, "Cod.Base ATF"	,1,1)
	oExcel:AddColumn(cFld274,cFld27t4, "Dt.Aquisição"	,1,1)
	oExcel:AddColumn(cFld274,cFld27t4, "Parcelas"		,1,1)
	oExcel:AddColumn(cFld274,cFld27t4, "Meses Ja Utilizados",1,1)
	oExcel:AddColumn(cFld274,cFld27t4, "Base Calc. Total"	,2,3,.T.)
	oExcel:AddColumn(cFld274,cFld27t4, "Base Calc. Mes"		,2,3,.T.)
	oExcel:AddColumn(cFld274,cFld27t4, "Valor Pis Mes"		,2,3,.T.)
	oExcel:AddColumn(cFld274,cFld27t4, "Valor Cofins Mes"	,2,3,.T.)
	oExcel:AddColumn(cFld274,cFld27t4, "Utiliz. Bem"		,1,1) 

Return(NIL) 

/*/{Protheus.doc} Static Function Cab27P5
Carrega da dados Ref. Conferencia Pis/Cofins  
@type  Function
@author Abel Babini Filho
@since 27/05/2019
@version 03
/*/
Static Function Cab27P5()
 	//DETALHE
    oExcel:AddworkSheet(cFld275)
	oExcel:AddTable (cFld275,cFld27t5)
	oExcel:AddColumn(cFld275,cFld27t5, "Filial"			,1,1)
	oExcel:AddColumn(cFld275,cFld27t5, "Dt.Entrada"		,1,1)
	oExcel:AddColumn(cFld275,cFld27t5, "Serie"			,1,1)
	oExcel:AddColumn(cFld275,cFld27t5, "NF"				,1,1)
	oExcel:AddColumn(cFld275,cFld27t5, "Cod.Forn."		,1,1)
	oExcel:AddColumn(cFld275,cFld27t5, "Loja"			,1,1)
	oExcel:AddColumn(cFld275,cFld27t5, "Fornecedor"		,1,1)
	oExcel:AddColumn(cFld275,cFld27t5, "CFOP"			,1,1)
	oExcel:AddColumn(cFld275,cFld27t5, "Cod.Prod."		,1,1)
	oExcel:AddColumn(cFld275,cFld27t5, "Produto"		,1,1)
	oExcel:AddColumn(cFld275,cFld27t5, "TES"			,1,1)
	oExcel:AddColumn(cFld275,cFld27t5, "Espécie NF"		,1,1)
	oExcel:AddColumn(cFld275,cFld27t5, "Vl.Contabil"	,2,3,.T.)
	oExcel:AddColumn(cFld275,cFld27t5, "Vl.Total"		,2,3,.T.)
	oExcel:AddColumn(cFld275,cFld27t5, "ICMS Ret."		,2,3)
	oExcel:AddColumn(cFld275,cFld27t5, "IPI Obs."		,2,3)
	oExcel:AddColumn(cFld275,cFld27t5, "Vl.Frete"		,2,3)
	oExcel:AddColumn(cFld275,cFld27t5, "Vl.Seguro"		,2,3)
	oExcel:AddColumn(cFld275,cFld27t5, "Vl.Despesa"		,2,3)
	oExcel:AddColumn(cFld275,cFld27t5, "NCM"			,1,1)
	oExcel:AddColumn(cFld275,cFld27t5, "Vl.Desconto"	,2,3)
	oExcel:AddColumn(cFld275,cFld27t5, "Base Pis"		,2,3,.T.)
	oExcel:AddColumn(cFld275,cFld27t5, "Aliq.Pis"		,2,3)
	oExcel:AddColumn(cFld275,cFld27t5, "Val.Pis"		,2,3,.T.)
	oExcel:AddColumn(cFld275,cFld27t5, "Base Cofins"	,2,3,.T.)
	oExcel:AddColumn(cFld275,cFld27t5, "Aliq.Cofins"	,2,3)
	oExcel:AddColumn(cFld275,cFld27t5, "Val.Cofins"		,2,3,.T.)
	oExcel:AddColumn(cFld275,cFld27t5, "CST Pis"		,1,1)
	oExcel:AddColumn(cFld275,cFld27t5, "CST Cofins"		,1,1)
	oExcel:AddColumn(cFld275,cFld27t5, "Cod.BC Cred"	,1,1)
	oExcel:AddColumn(cFld275,cFld27t5, "Ind.Nat.Frete"	,1,1)
	oExcel:AddColumn(cFld275,cFld27t5, "Observ."		,1,1)
	oExcel:AddColumn(cFld275,cFld27t5, "Form.Prop."		,1,1)
	oExcel:AddColumn(cFld275,cFld27t5, "Chave NF-e"		,1,1)
	oExcel:AddColumn(cFld275,cFld27t5, "Cod.Base ATF"	,1,1)
	oExcel:AddColumn(cFld275,cFld27t5, "Dt.Aquisição"	,1,1)
	oExcel:AddColumn(cFld275,cFld27t5, "Parcelas"		,1,1)
	oExcel:AddColumn(cFld275,cFld27t5, "Meses Ja Utilizados",1,1)
	oExcel:AddColumn(cFld275,cFld27t5, "Base Calc. Total"	,2,3,.T.)
	oExcel:AddColumn(cFld275,cFld27t5, "Base Calc. Mes"		,2,3,.T.)
	oExcel:AddColumn(cFld275,cFld27t5, "Valor Pis Mes"		,2,3,.T.)
	oExcel:AddColumn(cFld275,cFld27t5, "Valor Cofins Mes"	,2,3,.T.)
	oExcel:AddColumn(cFld275,cFld27t5, "Utiliz. Bem"		,1,1) 

Return(NIL) 

/*/{Protheus.doc} Static Function Cab27P6
Carrega da dados Ref. Conferencia Pis/Cofins  
@type  Function
@author Abel Babini Filho
@since 27/05/2019
@version 03
/*/
Static Function Cab27P6()
 	//DETALHE
    oExcel:AddworkSheet(cFld276)
	oExcel:AddTable (cFld276,cFld27t6)
	oExcel:AddColumn(cFld276,cFld27t6, "Filial"			,1,1)
	oExcel:AddColumn(cFld276,cFld27t6, "Dt.Entrada"		,1,1)
	oExcel:AddColumn(cFld276,cFld27t6, "Serie"			,1,1)
	oExcel:AddColumn(cFld276,cFld27t6, "NF"				,1,1)
	oExcel:AddColumn(cFld276,cFld27t6, "Cod.Forn."		,1,1)
	oExcel:AddColumn(cFld276,cFld27t6, "Loja"			,1,1)
	oExcel:AddColumn(cFld276,cFld27t6, "Fornecedor"		,1,1)
	oExcel:AddColumn(cFld276,cFld27t6, "CFOP"			,1,1)
	oExcel:AddColumn(cFld276,cFld27t6, "Cod.Prod."		,1,1)
	oExcel:AddColumn(cFld276,cFld27t6, "Produto"		,1,1)
	oExcel:AddColumn(cFld276,cFld27t6, "TES"			,1,1)
	oExcel:AddColumn(cFld276,cFld27t6, "Espécie NF"		,1,1)
	oExcel:AddColumn(cFld276,cFld27t6, "Vl.Contabil"	,2,3,.T.)
	oExcel:AddColumn(cFld276,cFld27t6, "Vl.Total"		,2,3,.T.)
	oExcel:AddColumn(cFld276,cFld27t6, "ICMS Ret."		,2,3)
	oExcel:AddColumn(cFld276,cFld27t6, "IPI Obs."		,2,3)
	oExcel:AddColumn(cFld276,cFld27t6, "Vl.Frete"		,2,3)
	oExcel:AddColumn(cFld276,cFld27t6, "Vl.Seguro"		,2,3)
	oExcel:AddColumn(cFld276,cFld27t6, "Vl.Despesa"		,2,3)
	oExcel:AddColumn(cFld276,cFld27t6, "NCM"			,1,1)
	oExcel:AddColumn(cFld276,cFld27t6, "Vl.Desconto"	,2,3)
	oExcel:AddColumn(cFld276,cFld27t6, "Base Pis"		,2,3,.T.)
	oExcel:AddColumn(cFld276,cFld27t6, "Aliq.Pis"		,2,3)
	oExcel:AddColumn(cFld276,cFld27t6, "Val.Pis"		,2,3,.T.)
	oExcel:AddColumn(cFld276,cFld27t6, "Base Cofins"	,2,3,.T.)
	oExcel:AddColumn(cFld276,cFld27t6, "Aliq.Cofins"	,2,3)
	oExcel:AddColumn(cFld276,cFld27t6, "Val.Cofins"		,2,3,.T.)
	oExcel:AddColumn(cFld276,cFld27t6, "CST Pis"		,1,1)
	oExcel:AddColumn(cFld276,cFld27t6, "CST Cofins"		,1,1)
	oExcel:AddColumn(cFld276,cFld27t6, "Cod.BC Cred"	,1,1)
	oExcel:AddColumn(cFld276,cFld27t6, "Ind.Nat.Frete"	,1,1)
	oExcel:AddColumn(cFld276,cFld27t6, "Observ."		,1,1)
	oExcel:AddColumn(cFld276,cFld27t6, "Form.Prop."		,1,1)
	oExcel:AddColumn(cFld276,cFld27t6, "Chave NF-e"		,1,1)
	oExcel:AddColumn(cFld276,cFld27t6, "Cod.Base ATF"	,1,1)
	oExcel:AddColumn(cFld276,cFld27t6, "Dt.Aquisição"	,1,1)
	oExcel:AddColumn(cFld276,cFld27t6, "Parcelas"		,1,1)
	oExcel:AddColumn(cFld276,cFld27t6, "Meses Ja Utilizados",1,1)
	oExcel:AddColumn(cFld276,cFld27t6, "Base Calc. Total"	,2,3,.T.)
	oExcel:AddColumn(cFld276,cFld27t6, "Base Calc. Mes"		,2,3,.T.)
	oExcel:AddColumn(cFld276,cFld27t6, "Valor Pis Mes"		,2,3,.T.)
	oExcel:AddColumn(cFld276,cFld27t6, "Valor Cofins Mes"	,2,3,.T.)
	oExcel:AddColumn(cFld276,cFld27t6, "Utiliz. Bem"		,1,1) 

Return(NIL) 

/*/{Protheus.doc} Static Function GEx27P1
Carrega da dados Ref. Conferencia Pis/Cofins  
@type  Function
@author Abel Babini Filho
@since 27/05/2019
@version 03
/*/
Static Function GEx27P1()
	oExcel:AddRow(cFld27,cFld27t1,{'Quant. Itens'		,nA27T01,nA27T11,nA27T21,nA27T31 })
	oExcel:AddRow(cFld27,cFld27t1,{'Base Cálculo'		,nA27T02,nA27T12,nA27T22,nA27T32 })

	oExcel:AddRow(cFld27,cFld27t1,{''					,''	,''		,''		,''})
	oExcel:AddRow(cFld27,cFld27t1,{'Vl Pis'				,nA27T03,nA27T13,nA27T23,nA27T33 }) 
	oExcel:AddRow(cFld27,cFld27t1,{'Vl Pis Mês Ant'		,'',nA27T15,nA27T25,'' })
	oExcel:AddRow(cFld27,cFld27t1,{'Vl Pis Mês Atual'	,'',nA27T16,nA27T26,'' })

	oExcel:AddRow(cFld27,cFld27t1,{''					,''	,''		,''		,''})
	oExcel:AddRow(cFld27,cFld27t1,{'Vl Cofins'			,nA27T04,nA27T14,nA27T24,nA27T34 }) 
	oExcel:AddRow(cFld27,cFld27t1,{'Vl Cofins Mês Ant'	,'',nA27T17	,nA27T27,'' })
	oExcel:AddRow(cFld27,cFld27t1,{'Vl Cofins Mês Atual','',nA27T18	,nA27T28,'' })
	oExcel:AddRow(cFld27,cFld27t1,{''					,''	,''		,''		,''})

Return

/*/{Protheus.doc} Static Function GEx27P2
Carrega da dados Ref. Conferencia Pis/Cofins  
@type  Function
@author Abel Babini Filho
@since 27/05/2019
@version 03
/*/
Static Function GEx27P2()	
	Local nExcel1 := 0
	procregua(Len(aBrw27Dt))
	FOR nExcel1 := 1 TO Len(aBrw27Dt)
		IncProc()
		oExcel:AddRow(cFld272,cFld27t2,;
						{aBrw27Dt[nExcel1][01],;
						aBrw27Dt[nExcel1][02],;
						aBrw27Dt[nExcel1][03],;
						aBrw27Dt[nExcel1][04],;
						aBrw27Dt[nExcel1][05],;
						aBrw27Dt[nExcel1][06],;
						aBrw27Dt[nExcel1][07],;
						aBrw27Dt[nExcel1][08],; 
						aBrw27Dt[nExcel1][09],; 		
						aBrw27Dt[nExcel1][10],; 		
						aBrw27Dt[nExcel1][11],; 		
						aBrw27Dt[nExcel1][12],; 		
						aBrw27Dt[nExcel1][13],; 		
						aBrw27Dt[nExcel1][14],; 		
						aBrw27Dt[nExcel1][15],; 		
						aBrw27Dt[nExcel1][16],; 		
						aBrw27Dt[nExcel1][17],; 		
						aBrw27Dt[nExcel1][18],; 		
						aBrw27Dt[nExcel1][19],; 		
						aBrw27Dt[nExcel1][20],; 		
						aBrw27Dt[nExcel1][21],; 		
						aBrw27Dt[nExcel1][22],; 		
						aBrw27Dt[nExcel1][23],; 		
						aBrw27Dt[nExcel1][24],; 		
						aBrw27Dt[nExcel1][25],; 		
						aBrw27Dt[nExcel1][26],; 		
						aBrw27Dt[nExcel1][27],; 		
						aBrw27Dt[nExcel1][28],; 		
						aBrw27Dt[nExcel1][29],; 		
						aBrw27Dt[nExcel1][30],;
						aBrw27Dt[nExcel1][31],;
						aBrw27Dt[nExcel1][32],;	
						aBrw27Dt[nExcel1][33],;	
						aBrw27Dt[nExcel1][34],;	
						aBrw27Dt[nExcel1][35],;	
						IIF(Alltrim(DTOS(aBrw27Dt[nExcel1][36]))=='',DTOC(aBrw27Dt[nExcel1][36]),aBrw27Dt[nExcel1][36]),;
						aBrw27Dt[nExcel1][37],;	
						aBrw27Dt[nExcel1][38],;	
						aBrw27Dt[nExcel1][39],;	
						aBrw27Dt[nExcel1][40],;	
						aBrw27Dt[nExcel1][41],;	
						aBrw27Dt[nExcel1][42],;	
						aBrw27Dt[nExcel1][43]}) 


	NEXT nExcel1
	//ADICIONA LINHA EM BRANCA
	oExcel:AddRow(cFld272,cFld27t2,;
					{'',; 
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'';
					})	

Return

/*/{Protheus.doc} Static Function GEx27P3
Carrega da dados Ref. Conferencia Pis/Cofins  
@type  Function
@author Abel Babini Filho
@since 27/05/2019
@version 03
/*/
Static Function GEx27P3()
	Local nExcel1 := 0
	procregua(Len(aBrw27Im))
	FOR nExcel1 := 1 TO Len(aBrw27Im)
		IncProc()
		oExcel:AddRow(cFld273,cFld27t3,;
						{aBrw27Im[nExcel1][01],;
						aBrw27Im[nExcel1][02],;
						aBrw27Im[nExcel1][03],;
						aBrw27Im[nExcel1][04],;
						aBrw27Im[nExcel1][05],;
						aBrw27Im[nExcel1][06],;
						aBrw27Im[nExcel1][07],;
						aBrw27Im[nExcel1][08],; 
						aBrw27Im[nExcel1][09],; 		
						aBrw27Im[nExcel1][10],; 		
						aBrw27Im[nExcel1][11],; 		
						aBrw27Im[nExcel1][12],; 		
						aBrw27Im[nExcel1][13],; 		
						aBrw27Im[nExcel1][14],; 		
						aBrw27Im[nExcel1][15],; 		
						aBrw27Im[nExcel1][16],; 		
						aBrw27Im[nExcel1][17],; 		
						aBrw27Im[nExcel1][18],; 		
						aBrw27Im[nExcel1][19],; 		
						aBrw27Im[nExcel1][20],; 		
						aBrw27Im[nExcel1][21],; 		
						aBrw27Im[nExcel1][22],; 		
						aBrw27Im[nExcel1][23],; 		
						aBrw27Im[nExcel1][24],; 		
						aBrw27Im[nExcel1][25],; 		
						aBrw27Im[nExcel1][26],; 		
						aBrw27Im[nExcel1][27],; 		
						aBrw27Im[nExcel1][28],; 		
						aBrw27Im[nExcel1][29],; 		
						aBrw27Im[nExcel1][30],;
						aBrw27Im[nExcel1][31],;
						aBrw27Im[nExcel1][32],;	
						aBrw27Im[nExcel1][33],;	
						aBrw27Im[nExcel1][34],;	
						aBrw27Im[nExcel1][35],;	
						IIF(Alltrim(DTOS(aBrw27Im[nExcel1][36]))=='',DTOC(aBrw27Im[nExcel1][36]),aBrw27Im[nExcel1][36]),;
						aBrw27Im[nExcel1][37],;	
						aBrw27Im[nExcel1][38],;	
						aBrw27Im[nExcel1][39],;	
						aBrw27Im[nExcel1][40],;	
						aBrw27Im[nExcel1][41],;	
						aBrw27Im[nExcel1][42],;	
						aBrw27Im[nExcel1][43]}) 


	NEXT nExcel1
	//ADICIONA LINHA EM BRANCA
	oExcel:AddRow(cFld273,cFld27t3,;
					{'',; 
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'';
					})	

Return

/*/{Protheus.doc} Static Function GEx27P4
Carrega da dados Ref. Conferencia Pis/Cofins  
@type  Function
@author Abel Babini Filho
@since 27/05/2019
@version 03
/*/
Static Function GEx27P4()
	Local nExcel1 := 0
	procregua(Len(aBrw27Be))
	FOR nExcel1 := 1 TO Len(aBrw27Be)
		IncProc()
		oExcel:AddRow(cFld274,cFld27t4,;
						{aBrw27Be[nExcel1][01],;
						aBrw27Be[nExcel1][02],;
						aBrw27Be[nExcel1][03],;
						aBrw27Be[nExcel1][04],;
						aBrw27Be[nExcel1][05],;
						aBrw27Be[nExcel1][06],;
						aBrw27Be[nExcel1][07],;
						aBrw27Be[nExcel1][08],; 
						aBrw27Be[nExcel1][09],; 		
						aBrw27Be[nExcel1][10],; 		
						aBrw27Be[nExcel1][11],; 		
						aBrw27Be[nExcel1][12],; 		
						aBrw27Be[nExcel1][13],; 		
						aBrw27Be[nExcel1][14],; 		
						aBrw27Be[nExcel1][15],; 		
						aBrw27Be[nExcel1][16],; 		
						aBrw27Be[nExcel1][17],; 		
						aBrw27Be[nExcel1][18],; 		
						aBrw27Be[nExcel1][19],; 		
						aBrw27Be[nExcel1][20],; 		
						aBrw27Be[nExcel1][21],; 		
						aBrw27Be[nExcel1][22],; 		
						aBrw27Be[nExcel1][23],; 		
						aBrw27Be[nExcel1][24],; 		
						aBrw27Be[nExcel1][25],; 		
						aBrw27Be[nExcel1][26],; 		
						aBrw27Be[nExcel1][27],; 		
						aBrw27Be[nExcel1][28],; 		
						aBrw27Be[nExcel1][29],; 		
						aBrw27Be[nExcel1][30],;
						aBrw27Be[nExcel1][31],;
						aBrw27Be[nExcel1][32],;	
						aBrw27Be[nExcel1][33],;	
						aBrw27Be[nExcel1][34],;	
						aBrw27Be[nExcel1][35],;	
						IIF(Alltrim(DTOS(aBrw27Be[nExcel1][36]))=='',DTOC(aBrw27Be[nExcel1][36]),aBrw27Be[nExcel1][36]),;
						aBrw27Be[nExcel1][37],;	
						aBrw27Be[nExcel1][38],;	
						aBrw27Be[nExcel1][39],;	
						aBrw27Be[nExcel1][40],;	
						aBrw27Be[nExcel1][41],;	
						aBrw27Be[nExcel1][42],;	
						aBrw27Be[nExcel1][43]}) 


	NEXT nExcel1
	//ADICIONA LINHA EM BRANCA
	oExcel:AddRow(cFld274,cFld27t4,;
					{'',; 
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'';
					})	

Return(NIL) 

/*/{Protheus.doc} Static Function GEx27P5
Carrega da dados Ref. Conferencia Pis/Cofins  
@type  Function
@author Abel Babini Filho
@since 27/05/2019
@version 03
/*/
Static Function GEx27P5()
	Local nExcel1 := 0
	procregua(Len(aBrw27Se))
	FOR nExcel1 := 1 TO Len(aBrw27Se)
		IncProc()
		oExcel:AddRow(cFld275,cFld27t5,;
						{aBrw27Se[nExcel1][01],;
						aBrw27Se[nExcel1][02],;
						aBrw27Se[nExcel1][03],;
						aBrw27Se[nExcel1][04],;
						aBrw27Se[nExcel1][05],;
						aBrw27Se[nExcel1][06],;
						aBrw27Se[nExcel1][07],;
						aBrw27Se[nExcel1][08],; 
						aBrw27Se[nExcel1][09],; 		
						aBrw27Se[nExcel1][10],; 		
						aBrw27Se[nExcel1][11],; 		
						aBrw27Se[nExcel1][12],; 		
						aBrw27Se[nExcel1][13],; 		
						aBrw27Se[nExcel1][14],; 		
						aBrw27Se[nExcel1][15],; 		
						aBrw27Se[nExcel1][16],; 		
						aBrw27Se[nExcel1][17],; 		
						aBrw27Se[nExcel1][18],; 		
						aBrw27Se[nExcel1][19],; 		
						aBrw27Se[nExcel1][20],; 		
						aBrw27Se[nExcel1][21],; 		
						aBrw27Se[nExcel1][22],; 		
						aBrw27Se[nExcel1][23],; 		
						aBrw27Se[nExcel1][24],; 		
						aBrw27Se[nExcel1][25],; 		
						aBrw27Se[nExcel1][26],; 		
						aBrw27Se[nExcel1][27],; 		
						aBrw27Se[nExcel1][28],; 		
						aBrw27Se[nExcel1][29],; 		
						aBrw27Se[nExcel1][30],;
						aBrw27Se[nExcel1][31],;
						aBrw27Se[nExcel1][32],;	
						aBrw27Se[nExcel1][33],;	
						aBrw27Se[nExcel1][34],;	
						aBrw27Se[nExcel1][35],;	
						IIF(Alltrim(DTOS(aBrw27Se[nExcel1][36]))=='',DTOC(aBrw27Se[nExcel1][36]),aBrw27Se[nExcel1][36]),;
						aBrw27Se[nExcel1][37],;	
						aBrw27Se[nExcel1][38],;	
						aBrw27Se[nExcel1][39],;	
						aBrw27Se[nExcel1][40],;	
						aBrw27Se[nExcel1][41],;	
						aBrw27Se[nExcel1][42],;	
						aBrw27Se[nExcel1][43]}) 


	NEXT nExcel1
	//ADICIONA LINHA EM BRANCA
	oExcel:AddRow(cFld275,cFld27t5,;
					{'',; 
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'';
					})	

Return(NIL) 

/*/{Protheus.doc} Static Function GEx27P6
Carrega da dados Ref. Conferencia Pis/Cofins  
@type  Function
@author Abel Babini Filho
@since 27/05/2019
@version 03
/*/
Static Function GEx27P6()
	Local nExcel1 := 0
	procregua(Len(aBrw27SN))
	FOR nExcel1 := 1 TO Len(aBrw27SN)
		IncProc()
		oExcel:AddRow(cFld276,cFld27t6,;
						{aBrw27SN[nExcel1][01],;
						aBrw27SN[nExcel1][02],;
						aBrw27SN[nExcel1][03],;
						aBrw27SN[nExcel1][04],;
						aBrw27SN[nExcel1][05],;
						aBrw27SN[nExcel1][06],;
						aBrw27SN[nExcel1][07],;
						aBrw27SN[nExcel1][08],; 
						aBrw27SN[nExcel1][09],; 		
						aBrw27SN[nExcel1][10],; 		
						aBrw27SN[nExcel1][11],; 		
						aBrw27SN[nExcel1][12],; 		
						aBrw27SN[nExcel1][13],; 		
						aBrw27SN[nExcel1][14],; 		
						aBrw27SN[nExcel1][15],; 		
						aBrw27SN[nExcel1][16],; 		
						aBrw27SN[nExcel1][17],; 		
						aBrw27SN[nExcel1][18],; 		
						aBrw27SN[nExcel1][19],; 		
						aBrw27SN[nExcel1][20],; 		
						aBrw27SN[nExcel1][21],; 		
						aBrw27SN[nExcel1][22],; 		
						aBrw27SN[nExcel1][23],; 		
						aBrw27SN[nExcel1][24],; 		
						aBrw27SN[nExcel1][25],; 		
						aBrw27SN[nExcel1][26],; 		
						aBrw27SN[nExcel1][27],; 		
						aBrw27SN[nExcel1][28],; 		
						aBrw27SN[nExcel1][29],; 		
						aBrw27SN[nExcel1][30],;
						aBrw27SN[nExcel1][31],;
						aBrw27SN[nExcel1][32],;	
						aBrw27SN[nExcel1][33],;	
						aBrw27SN[nExcel1][34],;	
						aBrw27SN[nExcel1][35],;	
						IIF(Alltrim(DTOS(aBrw27SN[nExcel1][36]))=='',DTOC(aBrw27SN[nExcel1][36]),aBrw27SN[nExcel1][36]),;
						aBrw27SN[nExcel1][37],;	
						aBrw27SN[nExcel1][38],;	
						aBrw27SN[nExcel1][39],;	
						aBrw27SN[nExcel1][40],;	
						aBrw27SN[nExcel1][41],;	
						aBrw27SN[nExcel1][42],;	
						aBrw27SN[nExcel1][43]}) 


	NEXT nExcel1
	//ADICIONA LINHA EM BRANCA
	oExcel:AddRow(cFld276,cFld27t6,;
					{'',; 
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'',;
					'';
					})	

Return(NIL) 

// FIM n.051633  ³ OS 052957 || FISCAL || DEJAIME || 8921 || REL. PIS/COFINS - ABEL - 09/09/2019

//Ticket  13124 - Abel Babini - 14/05/2021 - Criar rotina de fechamento do período, gravando valores e parâmetros utilizados no calculo
/*/{Protheus.doc} Statix Function xRecVer
	Retorna a última versão salva na tabela ZFU
	@type  Function
	@author Abel Babini Filho
	@since 10/12/2019
	@version 1
	/*/
Static Function xRecVer(cTabZFU)
	Local cVerAnt := ''
	Local cQuery1
	If Select(cQuery1) > 0
		(cQuery1)->(dbCloseArea())
	Endif
	cQuery1:=GetNextAlias()
	
	BeginSQL Alias cQuery1
		SELECT DISTINCT
			MAX(ZFU.ZFU_VERSAO)	AS VERSAO
		FROM %TABLE:ZFU% ZFU (NOLOCK)
		WHERE ZFU.ZFU_FILIAL = %xFilial:ZFU%
			AND ZFU.ZFU_PERIOD = %Exp:_cAnoI+_cMesI%
			AND ZFU.ZFU_TABELA = %Exp:cTabZFU%
			AND ZFU.ZFU_STATUS <> '3'
			AND ZFU.%notDel%			
	EndSQL

	DbSelectArea(cQuery1)
	(cQuery1)->(dbGoTop())
	IF !(cQuery1)->(eof())
		cVerAnt := Alltrim((cQuery1)->VERSAO)
	ENDIF
	(cQuery1)->(dbCloseArea())
Return cVerAnt
	
/*/{Protheus.doc} Static Function GravaZFU
	Grava Registros na Tabela ZFU
	@author Abel Babini Filho
	@since 27/12/2019
	@version 01
	/*/
Static Function GravaZFU(cFilZFU, zPeriZFU, cVerZFU, dDtZFU, cTabZFU, cChavZFU, cUserZFU, cStatZFU, nValZFU,cKeyDZFU, cSDOCZFU)
	dbSelectArea('ZFU')
	RECLOCK('ZFU',.T.)
		ZFU->ZFU_FILIAL	:= cFilZFU
		ZFU->ZFU_PERIOD	:= zPeriZFU
		ZFU->ZFU_VERSAO	:= cVerZFU
		ZFU->ZFU_DTGRV	:= dDtZFU
		ZFU->ZFU_TABELA	:= cTabZFU
		ZFU->ZFU_CHAVE	:= cChavZFU
		ZFU->ZFU_USUARI	:= cUserZFU
		ZFU->ZFU_STATUS	:= cStatZFU
		ZFU->ZFU_VALOR	:= nValZFU
		ZFU->ZFU_KEYDOC	:= cKeyDZFU
		ZFU->ZFU_STSDOC	:= cSDOCZFU
	MSUNLOCK()
Return

/*/{Protheus.doc} Static Function xLoadPar  
	Carrega Parâmetros utilizados no fechamento do painel
	@author Abel Babini Filho
	@since 23/04/2021
	@version 01
	/*/
Static Function xLoadPar()
	Local cVerAnt		:= ''
	Local cAlLdPar	:= ''

	//Verifica a última versão do período atual
	cVerAnt := xRecVer('ZZ')

	IF cVerAnt != ''
		If Select(cAlLdPar) > 0
			(cAlLdPar)->(dbCloseArea())
		Endif
		cAlLdPar:=GetNextAlias()
		
		BeginSQL Alias cAlLdPar
			SELECT
				ZFU.ZFU_FILIAL	AS FILIAL,
				ZFU.ZFU_TABELA	AS TABELA,
				ZFU.ZFU_CHAVE		AS CHAVE,
				ZFU.ZFU_PERIOD	AS PERIODO,
				ZFU.ZFU_VERSAO	AS VERSAO,
				ZFU.ZFU_USUARI	AS USUARIO,
				ZFU.ZFU_DTGRV	AS DATAGRV,
				ZFU.ZFU_STATUS	AS STATUS,
				ZFU.ZFU_KEYDOC	AS KEYDOC,
				ZFU.ZFU_VALOR		AS VALOR
			FROM %TABLE:ZFU% ZFU (NOLOCK)
			WHERE ZFU.ZFU_FILIAL = %xFilial:ZFU%
				AND ZFU.ZFU_PERIOD = %Exp:_cAnoI+_cMesI%
				AND ZFU.ZFU_TABELA = 'ZZ'
				AND ZFU.ZFU_VERSAO = %Exp:cVerAnt%
				AND ZFU.ZFU_STATUS = '2'
				AND ZFU.%notDel%			
		EndSQL
	
		DbSelectArea(cAlLdPar)
		(cAlLdPar)->(dbGoTop())
		while !(cAlLdPar)->(eof())

			aParZFU := strtokarr ((cAlLdPar)->KEYDOC, "||") 
			IF aParZFU[1] == "MV_#PNUSMR"
				_cMVMstr := aParZFU[2]
				_lMsUser	:= IIF(__cUserID $ _cMVMstr, .T., .F.)

			ELSEIF aParZFU[1] == "MV_CPPCAGR"
				cCPPCAGR := aParZFU[2]

			ELSEIF aParZFU[1] == "MV_CAJCPP"
				cCAJCPPC := aParZFU[2]

			ELSEIF aParZFU[1] == "MV_#NCMCPR"
				cXNCMCPR := aParZFU[2]

			ELSEIF aParZFU[1] == "MV_#ACPPCI"
				cXACPPCI := aParZFU[2]

			ELSEIF aParZFU[1] == "MV_#CSTCPI"
				cXCSTCPI := aParZFU[2]

			ELSEIF aParZFU[1] == "MV_#INCPMI"
				cXINCPMI := aParZFU[2]

			ELSEIF aParZFU[1] == "MV_#NCMEMB"
				cXNCMEMB := aParZFU[2]

			ELSEIF aParZFU[1] == "MV_#CFCPMI"
				cXCFCPMI := aParZFU[2]

			ELSEIF aParZFU[1] == "MV_ACPPCAG"
				cACPPCAG := aParZFU[2]

			ELSEIF aParZFU[1] == "MV_CSTPRES"
				cCSTPRES := aParZFU[2]

			ELSEIF aParZFU[1] == "MV_DAPCCPA"
				cDAPCCPA := aParZFU[2]

			ELSEIF aParZFU[1] == "MV_NCMCPPC"
				cNCMCPPC := aParZFU[2]

			ELSEIF aParZFU[1] == "MV_#CPRCEP"
				cXCPRCEP := aParZFU[2]

			ELSEIF aParZFU[1] == "MV_NCMCREP"
				cNCMCREP := aParZFU[2]

			ELSEIF aParZFU[1] == "MV_#CFCPEX"
				cXCFCPEX := aParZFU[2]

			ELSEIF aParZFU[1] == "MV_#CFINSS"
				cP25A01 := aParZFU[2]

			ELSEIF aParZFU[1] == "MV_#CFICST"
				cP25A02 := aParZFU[2]

			ELSEIF aParZFU[1] == "MV_#CFINEX"
				cP25A03 := aParZFU[2]

			ELSEIF aParZFU[1] == "MV_#CFINDV"
				cP25A04 := aParZFU[2]

			ELSEIF aParZFU[1] == "MV_#CFIDV2"
				cP25A05 := aParZFU[2]

			ELSEIF aParZFU[1] == "MV_#CFINIM"
				cP25A06 := aParZFU[2]

			ELSEIF aParZFU[1] == "MV_#ALINSS"
				cP25A07 := Val(aParZFU[2])

			ENDIF

			(cAlLdPar)->(dbSkip())
		EndDo
	
		(cAlLdPar)->(dbCloseArea())
	ENDIF

Return

/*/{Protheus.doc} Static Function xGrvFcht()
	Função que Grava as informações e fecha o período
	@type Static Function
	@author Abel Babini
	@since 21/01/2020
	/*/
Static Function xGrvFcht()
	//GravaZFU(cFilZFU, zPeriZFU, cVerZFU, dDtZFU, cTabZFU, cChavZFU, cUserZFU, cStatZFU, nValZFU,cKeyDZFU, cSDOCZFU)
	Local lRet := MessageBox('Deseja realmente fechar o período '+' (' + _cMesI +'/'+_cAnoI +')'+'?','Fechamento do Período',4)

	IF lRet == 6
		ZFU->(dbGoTop())
		If ZFU->(dbSeek(xFilial('ZFU')+_cAnoI+_cMesI+cLstVrs+'ZZ'))
			While !ZFU->(eof()) .AND. ;
						ZFU->ZFU_FILIAL == xFilial('ZFU') .AND. ;
						ZFU->ZFU_PERIOD == _cAnoI+_cMesI .AND. ;
						ZFU->ZFU_VERSAO == cLstVrs 
				
				IF ZFU->ZFU_TABELA == 'ZZ'
				
					IF ZFU->ZFU_STATUS == '1'
						RECLOCK('ZFU',.F.)
							ZFU->ZFU_STATUS := '2'
						MSUNLOCK()
					ENDIF
				ENDIF
				ZFU->(dbSkip())
			EndDo
		Endif

		GravaZFU(xFilial('ZFU'), _cAnoI+_cMesI, cLstVrs, dDATABASE, 'Z1', 'Z00000100', _cNomUse, '2', 0,DToS(_mvpr01), '') //DATA INICIAL
		GravaZFU(xFilial('ZFU'), _cAnoI+_cMesI, cLstVrs, dDATABASE, 'Z1', 'Z00000110', _cNomUse, '2', 0,DToS(_mvpr02), '') //DATA FINAL
		GravaZFU(xFilial('ZFU'), _cAnoI+_cMesI, cLstVrs, dDATABASE, 'Z1', 'Z00000140', _cNomUse, '2', 0,DtoS(Date()), '') //DATA FECHAMENTO
		GravaZFU(xFilial('ZFU'), _cAnoI+_cMesI, cLstVrs, dDATABASE, 'Z1', 'Z00000150', _cNomUse, '2', 0,Time(), '') //HORA FECHAMENTO

		//GRAVA PARÂMETROS
		GravaZFU(xFilial('ZFU'), _cAnoI+_cMesI, cLstVrs, dDATABASE, 'ZZ', 'ZZZZZZZZZ', _cNomUse, '2', 0,'MV_CPPCAGR'+'||'+IIF(cCPPCAGR=='.T.',"T","F"), '') //LOGICO - "Indica se ira processar credito presumido de PIS e Cofins conforme lei 12.058/2009 e Instrução"
		GravaZFU(xFilial('ZFU'), _cAnoI+_cMesI, cLstVrs, dDATABASE, 'ZZ', 'ZZZZZZZZZ', _cNomUse, '2', 0,'MV_CAJCPP'+'||'+cCAJCPPC, '') //TEXTO - "Informar o código que será utilizado no ajuste de credito presumido da lei 12.058/2009 que conforme tabela 4.3.8 da RFB"
		GravaZFU(xFilial('ZFU'), _cAnoI+_cMesI, cLstVrs, dDATABASE, 'ZZ', 'ZZZZZZZZZ', _cNomUse, '2', 0,'MV_#NCMCPR'+'||'+cXNCMCPR, '') //TEXTO - "Informar o NCM para cálculo da Receita Total, utilizado tanto no Mercado Interno quanto Externo"
		GravaZFU(xFilial('ZFU'), _cAnoI+_cMesI, cLstVrs, dDATABASE, 'ZZ', 'ZZZZZZZZZ', _cNomUse, '2', 0,'MV_#ACPPCI'+'||'+cXACPPCI, '') //TEXTO - "Informar a alíquota de Credito Presumido de PIS e Cofins, com base na lei 10925/2004"
		GravaZFU(xFilial('ZFU'), _cAnoI+_cMesI, cLstVrs, dDATABASE, 'ZZ', 'ZZZZZZZZZ', _cNomUse, '2', 0,'MV_#CSTCPI'+'||'+cXCSTCPI, '') //TEXTO - "CST que será escriturado no registro F100 para o cálculo de credito presumido referente ao Mercado Interno Art.8 da Lei 10.925/2004"
		GravaZFU(xFilial('ZFU'), _cAnoI+_cMesI, cLstVrs, dDATABASE, 'ZZ', 'ZZZZZZZZZ', _cNomUse, '2', 0,'MV_#INCPMI'+'||'+cXINCPMI, '') //TEXTO - "Informar a descrição que será utilizada no ajuste de Crédito Presumido Mercado Interno."
		GravaZFU(xFilial('ZFU'), _cAnoI+_cMesI, cLstVrs, dDATABASE, 'ZZ', 'ZZZZZZZZZ', _cNomUse, '2', 0,'MV_#NCMEMB'+'||'+cXNCMEMB, '') //TEXTO - "NCM dos prod. Embutidos para cálculo das Receitas com Embutidos"
		GravaZFU(xFilial('ZFU'), _cAnoI+_cMesI, cLstVrs, dDATABASE, 'ZZ', 'ZZZZZZZZZ', _cNomUse, '2', 0,'MV_#CFCPMI'+'||'+cXCFCPMI, '') //TEXTO - "CFOP a serem considerados para filtrar as NF´s de Entrada com direito a crédito"
		GravaZFU(xFilial('ZFU'), _cAnoI+_cMesI, cLstVrs, dDATABASE, 'ZZ', 'ZZZZZZZZZ', _cNomUse, '2', 0,'MV_ACPPCAG'+'||'+cACPPCAG, '') //TEXTO - "Informar a alíquota de Credito Presumido de PIS e Cofins, com base na lei 12.058/2009 N RFB nº 977, de 14 novembro de 2009"
		GravaZFU(xFilial('ZFU'), _cAnoI+_cMesI, cLstVrs, dDATABASE, 'ZZ', 'ZZZZZZZZZ', _cNomUse, '2', 0,'MV_CSTPRES'+'||'+cCSTPRES, '') //TEXTO - "CST que sera escriturado no registro F100 para o cálculo de credito presumido conforme lei 12.058/2"
		GravaZFU(xFilial('ZFU'), _cAnoI+_cMesI, cLstVrs, dDATABASE, 'ZZ', 'ZZZZZZZZZ', _cNomUse, '2', 0,'MV_DAPCCPA'+'||'+cDAPCCPA, '') //TEXTO - "Informar a descrição que será utilizada no ajuste de credito presumido da lei 12.058/2009"
		GravaZFU(xFilial('ZFU'), _cAnoI+_cMesI, cLstVrs, dDATABASE, 'ZZ', 'ZZZZZZZZZ', _cNomUse, '2', 0,'MV_NCMCPPC'+'||'+cNCMCPPC, '') //TEXTO - "NCM de exportação que serão utilizados para a geração do credito presumido de PIS e COFINS conforme lei 12.058/2009"
		GravaZFU(xFilial('ZFU'), _cAnoI+_cMesI, cLstVrs, dDATABASE, 'ZZ', 'ZZZZZZZZZ', _cNomUse, '2', 0,'MV_#CPRCEP'+'||'+cXCPRCEP, '') //TEXTO - "CFOP a serem utilizados como Receita de Exportação."
		GravaZFU(xFilial('ZFU'), _cAnoI+_cMesI, cLstVrs, dDATABASE, 'ZZ', 'ZZZZZZZZZ', _cNomUse, '2', 0,'MV_NCMCREP'+'||'+cNCMCREP, '') //TEXTO - "NCM dos prod. agropec. utilizados c/ insumos na fabricação de prod. destinado a alimentação humana  ou animal lei 12.058/2009"
		GravaZFU(xFilial('ZFU'), _cAnoI+_cMesI, cLstVrs, dDATABASE, 'ZZ', 'ZZZZZZZZZ', _cNomUse, '2', 0,'MV_#CFCPEX'+'||'+cXCFCPEX, '') //TEXTO - "CFOP a serem considerados para filtrar as NF´s de Entrada com direito a crédito"
		GravaZFU(xFilial('ZFU'), _cAnoI+_cMesI, cLstVrs, dDATABASE, 'ZZ', 'ZZZZZZZZZ', _cNomUse, '2', 0,'MV_#CFINSS'+'||'+cP25A01, '') //TEXTO - "Indica os CFOPs que serão considerados para calculo das Receitas"
		GravaZFU(xFilial('ZFU'), _cAnoI+_cMesI, cLstVrs, dDATABASE, 'ZZ', 'ZZZZZZZZZ', _cNomUse, '2', 0,'MV_#CFICST'+'||'+cP25A02, '') //TEXTO - "Indica os CFOPs que serão considerados para calculo do ICMS ST"
		GravaZFU(xFilial('ZFU'), _cAnoI+_cMesI, cLstVrs, dDATABASE, 'ZZ', 'ZZZZZZZZZ', _cNomUse, '2', 0,'MV_#CFINEX'+'||'+cP25A03, '') //TEXTO - "Indica os CFOPs que serão considerados para calculo da Exportação"
		GravaZFU(xFilial('ZFU'), _cAnoI+_cMesI, cLstVrs, dDATABASE, 'ZZ', 'ZZZZZZZZZ', _cNomUse, '2', 0,'MV_#CFINDV'+'||'+cP25A04, '') //TEXTO - "Indica os CFOPs que serão considerados para deduzir as devoluções do calculo"
		GravaZFU(xFilial('ZFU'), _cAnoI+_cMesI, cLstVrs, dDATABASE, 'ZZ', 'ZZZZZZZZZ', _cNomUse, '2', 0,'MV_#CFIDV2'+'||'+cP25A05, '') //TEXTO - "Indica os CFOPs que serão considerados para anular as devoluções do calculo"
		GravaZFU(xFilial('ZFU'), _cAnoI+_cMesI, cLstVrs, dDATABASE, 'ZZ', 'ZZZZZZZZZ', _cNomUse, '2', 0,'MV_#CFINIM'+'||'+cP25A06, '') //TEXTO - "Indica os CFOPs que serão considerados para calculo dos Imobilizados"
		GravaZFU(xFilial('ZFU'), _cAnoI+_cMesI, cLstVrs, dDATABASE, 'ZZ', 'ZZZZZZZZZ', _cNomUse, '2', 0,'MV_#ALINSS'+'||'+Alltrim(Str(cP25A07)), '') //TEXTO - "Indica a alíquota para cálculo do INSS"

		_lPerFch	:= .T.
	Endif
	
	// aSldFcht	:= xSldFcht()
	

	oFLr01:Refresh(.T.)
	SYSREFRESH(.T.)
Return 

/*/{Protheus.doc} Static Function xAbrFcht()
	Função que reabre o período
	@type Static Function
	@author Abel Babini
	@since 27/01/2020
	/*/
Static Function xAbrFcht()
	Local lRet := MessageBox('Deseja realmente reabrir o período '+' (' + _cMesI +'/'+_cAnoI +')'+'?','Reabertura do Período',4)
	IF lRet == 6
		ZFU->(dbGoTop())
		If ZFU->(dbSeek(xFilial('ZFU')+_cAnoI+_cMesI+cLstVrs+'ZZ'))
			While !ZFU->(eof()) .AND. ;
						ZFU->ZFU_FILIAL == xFilial('ZFU') .AND. ;
						ZFU->ZFU_PERIOD == _cAnoI+_cMesI .AND. ;
						ZFU->ZFU_VERSAO == cLstVrs .AND. ;
						ZFU->ZFU_TABELA == 'ZZ'
				IF ZFU->ZFU_STATUS == '2'
					RECLOCK('ZFU',.F.)
						ZFU->ZFU_STATUS := '3'
					MSUNLOCK()
				ENDIF
				ZFU->(dbSkip())
			EndDo
		Endif
		//Registra usuário que reabriu o período
		GravaZFU(xFilial('ZFU'), _cAnoI+_cMesI, cLstVrs, dDATABASE, 'Z1', 'Z00000160', _cNomUse, '3', 0,DtoS(Date()), '') //DATA REABERTURA
		GravaZFU(xFilial('ZFU'), _cAnoI+_cMesI, cLstVrs, dDATABASE, 'Z1', 'Z00000170', _cNomUse, '3', 0,Time(), '') //HORA REABERTURA

		_lPerFch	:= .F. 
	Endif
	
	// aSldFcht	:= xSldFcht()
	

	oFLr01:Refresh(.T.)
	SYSREFRESH(.T.)
Return

/*/{Protheus.doc} Static Function xVerFcht()
	Função que Retorna se o período já foi fechado com as informações do Fechamento
	@type Static Function
	@author Abel Babini
	@since 17/05/2021
	/*/
Static Function xVerFcht(cVerAnt)
	Local lFechado	:= .F.

	IF cVerAnt != ''
		ZFU->(dbGoTop())
		If ZFU->(dbSeek(xFilial('ZFU')+_cAnoI+_cMesI+cVerAnt+'ZZ'))
			While !ZFU->(eof()) .AND. ;
						ZFU->ZFU_FILIAL == xFilial('ZFU') .AND. ;
						ZFU->ZFU_PERIOD == _cAnoI+_cMesI .AND. ;
						ZFU->ZFU_VERSAO == cVerAnt .AND. ;
						ZFU->ZFU_TABELA == 'ZZ'

				IF ZFU->ZFU_STATUS == '2'
					lFechado := .T.
				ENDIF
				ZFU->(dbSkip())
			EndDo
		ENDIF
	ENDIF

Return lFechado
