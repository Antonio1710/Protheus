#INCLUDE "PROTHEUS.CH"  
#INCLUDE "TOPCONN.CH" 
#INCLUDE "FILEIO.CH"      
  
//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
//±±ºPrograma  ³ADFIN027P ºAutor  ³WILLIAM COSTA       º Data ³  17/01/2017 º±±
//±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
//±±ºDesc.     ³ IMPORTACAO DE TXT DE RISK RATING PLUS DA CISP PARA VERIFI  º±±
//±±º          ³ CAR CLIENTES INADIMPLENTES                                 º±±
//±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
//±±ºUso       ³ FINANCEIRO - AD'oro - Solicitado Sr. ALBERTO SILVA         º±±
//±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß


User Function ADFIN027P()
    
	Private cFile
	Private aFile
	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'IMPORTACAO DE TXT DE RISK RATING PLUS DA CISP PARA VERIFICAR CLIENTES INADIMPLENTES')
	                                
	cFile := cGetFile( "Lista Arquivos TXT|*.TXT|Lista Arquivos TXT|*.txt",OemToAnsi("Abrir arquivo..."),,,.T.,GETF_LOCALFLOPPY + GETF_LOCALHARD + 32)
	
	If ! Empty( cFile )
	
	   If ( MsgNoYes( "Confirma importacao do arquivo " + cFile ) )
	
	      aFile := Directory( cFile )
	     
	      Processa( { || ProcFile("Analisando arquivo!!!") } )
	     
	   End
	
	End

Return( NIL )

Static Function ProcFile()   

	Local cLF                   := Chr( 10 )
	Local cTxt                  := ''
	Local cChr                  := ''
	Local nTam                  := 0  
	PRIVATE nCodAssociado       := ''
	PRIVATE cTipoPessoa         := ''
	PRIVATE cCNPJ               := ''
	PRIVATE cNome               := ''
	PRIVATE cRiscoAtual         := ''
	PRIVATE nRiscoPontualidade  := ''
	PRIVATE nRiscoRelacMercado  := ''
	PRIVATE nRiscoOcorrencias   := ''
	PRIVATE nRiscoCredPraca     := ''
	PRIVATE nRiscoDensComercial := ''
	PRIVATE cSitRecFederal      := ''
	PRIVATE dSitRFederal        := ''
	PRIVATE cSitSINTEGRA        := ''
	PRIVATE cInscrSINTEGRA      := ''
	PRIVATE dSitSINTEGRA        := ''
	PRIVATE nDebAtualTotal      := ''
	PRIVATE nQtdAssDebito       := ''
	PRIVATE nQtdAssGrupo        := ''
	PRIVATE nTotDeb05           := ''
	PRIVATE nQtdAss05           := ''
	PRIVATE cTipoPessoa         := ''
	PRIVATE nTotDeb15           := ''
	PRIVATE nQtdVenc15          := ''
	PRIVATE nTotDeb30           := ''
	PRIVATE nQtdVenc30          := ''
	PRIVATE nQtdVen02           := ''
	PRIVATE nQtdChequeSemFundo  := ''
	PRIVATE dAtuCheque          := ''
	PRIVATE dGerArq             := ''
	PRIVATE cHoraGerArq         := ''
	PRIVATE cCNPJRAIZ           := ''
	PRIVATE nLinha              := 1
	PRIVATE cArq                := CriaTrab(,.F.)+".TXT" //Nome do Arquivo a Gerar
	PRIVATE cPath               := GetTempPath() + cArq //Local de Geração do Arquivo
	Private nHdl                := NIL
	Private cVar                := ''
	Private cQuery              := ''
	Private cQuery1             := ''
	Private cQuery2             := ''  
	Private lGravaLog           := .F.
	
	FT_FUse( cFile ) 
	nTam += FT_FlastRec()
	nTam ++
	FT_FGoTop()
	ProcRegua( nTam )
	
	While ! ( FT_FEof() )
	
		IncProc( cvaltochar(nTam) + '/' + cvaltochar(nLinha) + ' Aguarde, importando registros..' )
		
		// *** INICIO - CARREGA VARIAVEIS DO TXT DA CISP *** //
		
		cTxt :=  FT_FReadLN()
		
		// *** Inicio chamado 039738 - WILLIAM COSTA 09/02/2018 *** //
		
		IF lGravaLog == .F.
		
			u_GrLogZBE (Date(), ;
				        TIME(), ;
				        cUserName, ;
				        "RISK RATING PLUS, Data Geração do Arquivo: "+DTOC(STOD(SUBSTR(cTxt,304,008))), ;
				        "FINANCEIRO",;
				        "ADFIN027P",;
			         	"RISK RATING PLUS",;
			           	ComputerName(),;
			           	LogUserName()) 
		
			lGravaLog := .T.
		
		ENDIF
		// *** Final chamado 039738 - WILLIAM COSTA 09/02/2018 *** //
	           
	    nCodAssociado       := VAL(SUBSTR(cTxt,001,003))
		cTipoPessoa         := SUBSTR(cTxt,004,001)
		cCNPJ               := STRZERO(VAL(SUBSTR(cTxt,005,020)),14)
		cNome               := SUBSTR(cTxt,025,040)
		cRiscoAtual         := SUBSTR(cTxt,065,001)
		nRiscoPontualidade  := VAL(SUBSTR(cTxt,066,001))
		nRiscoRelacMercado  := VAL(SUBSTR(cTxt,067,001))
		nRiscoOcorrencias   := VAL(SUBSTR(cTxt,068,001))
		nRiscoCredPraca     := VAL(SUBSTR(cTxt,069,001))
		nRiscoDensComercial := VAL(SUBSTR(cTxt,070,001))
		cSitRecFederal      := SUBSTR(cTxt,071,050)
		dSitRFederal        := STOD(SUBSTR(cTxt,121,008))
		cSitSINTEGRA        := SUBSTR(cTxt,129,050)
		cInscrSINTEGRA      := STRZERO(VAL(SUBSTR(cTxt,179,020)),14)
		dSitSINTEGRA        := STOD(SUBSTR(cTxt,199,008))
		nDebAtualTotal      := VAL(SUBSTR(cTxt,207,013) + '.' + SUBSTR(cTxt,220,002))
		nQtdAssDebito       := VAL(SUBSTR(cTxt,222,004))
		nQtdAssGrupo        := VAL(SUBSTR(cTxt,226,004))
		nTotDeb05           := VAL(SUBSTR(cTxt,230,013) + '.' + SUBSTR(cTxt,243,002))
		nQtdAss05           := VAL(SUBSTR(cTxt,245,004))
		nTotDeb15           := VAL(SUBSTR(cTxt,249,013) + '.' + SUBSTR(cTxt,262,002))
		nQtdVenc15          := VAL(SUBSTR(cTxt,264,004))
		nTotDeb30           := VAL(SUBSTR(cTxt,268,013) + '.' + SUBSTR(cTxt,281,002))
		nQtdVenc30          := VAL(SUBSTR(cTxt,283,004))
		nQtdVen02           := VAL(SUBSTR(cTxt,287,004))
		nQtdChequeSemFundo  := VAL(SUBSTR(cTxt,291,005))
		dAtuCheque          := STOD(SUBSTR(cTxt,296,008))
		dGerArq             := STOD(SUBSTR(cTxt,304,008))
		cHoraGerArq         := SUBSTR(cTxt,312,006)
		
		// *** FINAL - CARREGA VARIAVEIS DO TXT DA CISP *** //
		
		// *** INICIO - CARREGA CAMPO NO PB3 - PROSPECT CLIENTES *** //
		
		IncProc( cvaltochar(nTam) + '/' + cvaltochar(nLinha) + ' ANTES TRB-CNPJRAIZ: ' + cCNPJRAIZ )
		
		cCNPJRAIZ := SUBSTR(cCNPJ,1,8)
		SqlBuscaPB3(cCNPJRAIZ)
		
		While TRB->(!EOF())
		
			IncProc( cvaltochar(nTam) + '/' + cvaltochar(nLinha) + ' TRB-CNPJRAIZ: ' + cCNPJRAIZ )
			
			cQuery := " UPDATE " +RetSqlName("PB3") + " "
			cQuery += "    SET " + "PB3_XRISCO" + " = " + "'" + UPPER(cRiscoAtual) + "',"
			cQuery += "        " + "PB3_XDTRIS" + " = " + "'" + DTOS(dGerArq)      + "'"
			cQuery += " WHERE PB3_COD               = " + "'"  + TRB->PB3_COD         + "'" 
			cQuery += "   AND PB3_LOJA              = " + "'"  + TRB->PB3_LOJA        + "'" 
			cQuery += "   AND D_E_L_E_T_           <> '*' " 
	

			TCSQLExec(cQuery) 
    	    TRB->(dbSkip())
		ENDDO
		TRB->(dbCloseArea())
		
		// *** FINAL - CARREGA CAMPO NO PB3 - PROSPECT CLIENTES *** //
		
		// *** INICIO - CARREGA CAMPO NA SA1 - CLIENTES *** //
		
		SqlBuscaSA1(cCNPJRAIZ)
		While TRC->(!EOF())
		
			IncProc( cvaltochar(nTam) + '/' + cvaltochar(nLinha) + ' TRC-CNPJRAIZ: ' + cCNPJRAIZ )
			
			cQuery1 := " UPDATE " +RetSqlName("SA1") + " "
			cQuery1 += "    SET " + "A1_XRISCO"  + " = " + "'" + UPPER(cRiscoAtual) + "',"
			cQuery1 += "        " + "A1_XDTRISC" + " = " + "'" + DTOS(dGerArq)      + "'"
			cQuery1 += " WHERE A1_COD                = " + "'"  + TRC->A1_COD        + "'" 
			cQuery1 += "   AND A1_LOJA               = " + "'"  + TRC->A1_LOJA       + "'" 
			cQuery1 += "   AND D_E_L_E_T_           <> '*' " 
	
			TCSQLExec(cQuery1)
		    TRC->(dbSkip())
		ENDDO
		TRC->(dbCloseArea())
		
		// *** FINAL - CARREGA CAMPO NA SA1 - CLIENTES *** //
		
		// *** INICIO - CARREGA CAMPO NA SZF - REDES DE LOJAS DE CLIENTES *** //
		
		IncProc( cvaltochar(nTam) + '/' + cvaltochar(nLinha) + ' SZF-CNPJRAIZ: ' + cCNPJRAIZ )
		
		cQuery2 := " UPDATE " +RetSqlName("SZF") + " "
		cQuery2 += "    SET " + "ZF_XRISCO"  + " = " + "'" + UPPER(cRiscoAtual) + "'"
		cQuery2 += " WHERE ZF_CGCMAT             = " + "'"  + cCNPJRAIZ          + "'" 
		cQuery2 += "   AND D_E_L_E_T_           <> '*' " 
	
		TCSQLExec(cQuery2)
		
		// *** FINAL - CARREGA CAMPO NA SZF - REDES DE LOJAS DE CLIENTES *** //
        
        nLinha ++   
	    FT_FSkip()       
	ENDDO
	
	FT_FUse()
	fClose(nHdl) 
	
Return( NIL )

Static Function SqlBuscaPB3(cCNPJRAIZ)

	BeginSQL Alias "TRB"
			%NoPARSER%
			SELECT PB3_COD,PB3_LOJA,PB3_NOME 
			  FROM %Table:PB3%
			 WHERE LEFT(PB3_CGC,8) = %exp:cCNPJRAIZ%
			   AND D_E_L_E_T_     <> '*'
			
	EndSQl             
RETURN(NIL)

Static Function SqlBuscaSA1(cCNPJRAIZ)

	BeginSQL Alias "TRC"
			%NoPARSER%
			SELECT A1_COD,A1_LOJA,A1_NOME 
			  FROM %Table:SA1%
			 WHERE LEFT(A1_CGC,8) = %exp:cCNPJRAIZ%
			   AND D_E_L_E_T_     <> '*'
			
	EndSQl             
RETURN(NIL)