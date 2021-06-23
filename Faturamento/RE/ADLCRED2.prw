#INCLUDE "rwmake.ch"
#include "protheus.ch"   
#include "topconn.ch"

/*{Protheus.doc} User Function ADLCRED2
	Emissao da Listagem de Limite de Credito Consolidado por Rede (SZF) - Atualizado On-Line 
	@type  Function
	@author Microsiga 
	@since 12/05/2006
	@version 01
	@history Chamado TI     - Paulo         - 13/07/2011 - Modificação da lógica de totalização de limite de crédito por REDE
	@history Chamado 056381 - William Costa - 17/03/2020 - Adicionado log em todos os reclock do campo ZF_LCREDE para descobrir seu valor antes e depois 
	@history Chamado 058873 - William Costa - 23/06/2020 - Voltado programação de quandoa rede tiver um unico raiz de CNPJ gravar o campo da data e valor do maior acumulo da SA1
*/

User Function ADLCRED2() 

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Emissao da Listagem de Limite de Credito Consolidado por Rede (SZF) - Atualizado On-Line')

	//*************************************  IMPORTANTE  ****************************************
	// Quando for dado manutençao neste fonte eh preciso dar manutenção tambem no fonte ADFIN006P - Mauricio MDS
	//*************************************  IMPORTANTE  ****************************************

	lBold      := .F.
	lItalic    := .F.
	lUnderLine := .F.
	nHeight    := 45
	lPixel     := .T.
	lPrint     := .T.
	oFontA10   := TFont():New( "Arial",,10,,.F.,,,,.F.,.F. )
	oFontA10B  := TFont():New( "Arial",,10,,.T.,,,,.F.,.F. )
	oFontA12B  := TFont():New( "Arial",,12,,.T.,,,,.F.,.F. )
	oPrn       := TMSPrinter():New()
	oPrn:SetLandScape() 

	aArea  := GetArea()  // Grava a area atual
	nPag   := 0
	_nLin  := 9000
	_cNome := "Consolidado Limite de Credito de Redes"
	_cPos  := 1800/2 - (len(_cNome)/2)
	Private oCheck1       := NIL
	Private lGeraAcumulo  := .F.    
	Private nContCgc      := 0   
	Private cLog          := ''

	SqlVerifLog()

	While TRC->(!EOF())        

		cLog := DTOC(STOD(TRC->ZBE_DATA)) + ' às ' + TRC->ZBE_HORA + CHR(13) + CHR(10) + ;
				'Usuário: ' + TRC->ZBE_USUARI
		
					
		TRC->(dbSkip())
	ENDDO
	TRC->(dbCloseArea())
	
	//Montagem da tela pra receber os dados preliminares                  
	
	cTitulo := ".: Consolidado Limite de Credito por Rede :."        
	DEFINE MSDIALOG oDlg1 TITLE cTitulo FROM (461),(438) TO (662),(806) PIXEL
	@ 10,010 SAY "Esta rotina ira emitir a Relacao de Limites de Credito" Color CLR_BLACK PIXEL OF oDlg1
	@ 20,010 SAY "Consolidado por Rede de Cliente - Atualizado          " Color CLR_BLACK PIXEL OF oDlg1
	@ 30,010 Say "ATENCAO !!!" Color CLR_HRED PIXEL OF oDlg1
	@ 40,010 Say PadC("Os LIMITES de CREDITO e SALDO serao ATUALIZADOS",56) Color CLR_HBLUE PIXEL OF oDlg1
	oCheck1 := TCheckBox():New(50,010,'Gera Maior Acumulo ?',{|u|if(PCount()>0,lGeraAcumulo:=u,lGeraAcumulo)},oDlg1,100,210,,,,,,,,.T.,,,) //chamado 034477
	@ 60,010 Say "Maior Acumulo Gerado em: " + cLog Color CLR_HRED PIXEL OF oDlg1 //chamado 034477
	DEFINE SBUTTON FROM  (75), (040) TYPE 1 ENABLE OF oDlg1 ACTION (Continua())
	DEFINE SBUTTON FROM  (75), (095) TYPE 2 ENABLE OF oDlg1 ACTION (ODLG1:END())

	ACTIVATE DIALOG oDlg1 CENTERED

Return()

Static Function Continua()

	ODLG1:END()
	bBloco := {|lEnd| ProcSql()}  
	MsAguarde(bBloco,"Aguarde, Gerando Relatorio","Processando...",.F.)

Return()

Static Function ProcSql()
	
	MsProcTxt("Selecionando Dados, Aguarde.")
		
	nTotCredRede := nTotSaldRede := nTotCred := nTotSld := 0
	nTotVencRd   := nTotAvenRD   := nTotVCD   := nTotAVC  := 0

	/* Mauricio - 21/09/16 - query original
	cQuery := "SELECT ZF_REDE,ZF_NOMERED,SUBSTRING(A1_CGC,1,8) AS A1_CGC, "
	cQuery += "       (CASE WHEN A1_LC>ZF_LCREDE THEN A1_LC         ELSE ZF_LCREDE END) AS LC, "
	cQuery += "       (CASE WHEN E1_TIPO = 'RA'  THEN E1_SALDO*(-1) ELSE E1_SALDO  END) AS SALDO "
	cQuery += "FROM "+RetSQLName("SZF")+" AS SZF, "+RetSQLName("SA1")+" AS SA1 LEFT OUTER JOIN "+RetSQLName("SE1")+" AS SE1 "
	cQuery += "ON A1_COD = E1_CLIENTE AND A1_LOJA = E1_LOJA AND E1_TIPO NOT IN ('PR','NCC') AND E1_PORTADO NOT IN ('P00','P01','P02','P03','P14') AND E1_SALDO > 0  AND SE1.D_E_L_E_T_='' "
	cQuery += "WHERE LEFT(A1_CGC,8) = ZF_CGCMAT AND SZF.D_E_L_E_T_='' AND SA1.D_E_L_E_T_='' "
	cQuery += "ORDER BY ZF_REDE, LC DESC, ZF_NOMERED"
	*/

	//Mauricio - 21/09/16 implementado apuracao e gravacao dos campos ZF_VENCIDO e ZF_AVENCER solicitado por Alberto.
	//e ajustado o relatorio com novos campos.

	_dDT  := Date()
	_dDTA := (Date() + 1)
	cQuery := "SELECT ZF_REDE,ZF_NOMERED,ZF_XRISCO,SUBSTRING(A1_CGC,1,8) AS A1_CGC, A1_MSBLQL, "
	cQuery += "       (CASE WHEN A1_LC>ZF_LCREDE THEN A1_LC         ELSE ZF_LCREDE END) AS LC, "
	cQuery += "       (CASE WHEN E1_TIPO = 'RA'  THEN E1_SALDO*(-1) ELSE E1_SALDO  END) AS SALDO, "
	cQuery += "       (CASE WHEN E1_TIPO = 'RA' AND (E1_VENCREA < '"+DTOS(_dDT)+"') THEN E1_SALDO*(-1) ELSE 0  END) AS VENC1, "
	cQuery += "       (CASE WHEN E1_TIPO <> 'RA' AND (E1_VENCREA < '"+DTOS(_dDT)+"') THEN E1_SALDO ELSE 0  END) AS VENC2, "
	cQuery += "       (CASE WHEN E1_TIPO = 'RA' AND (E1_VENCREA BETWEEN '"+DTOS(_dDT)+"' AND '"+DTOS(_dDTA)+"') THEN E1_SALDO*(-1) ELSE 0  END) AS AVENC1, "
	cQuery += "       (CASE WHEN E1_TIPO <> 'RA' AND (E1_VENCREA BETWEEN '"+DTOS(_dDT)+"' AND '"+DTOS(_dDTA)+"') THEN E1_SALDO ELSE 0  END) AS AVENC2 "
	cQuery += "FROM "+RetSQLName("SZF")+" AS SZF, "+RetSQLName("SA1")+" AS SA1 LEFT OUTER JOIN "+RetSQLName("SE1")+" AS SE1 "
	cQuery += "ON A1_COD = E1_CLIENTE AND A1_LOJA = E1_LOJA AND E1_TIPO NOT IN ('PR','NCC','AB-') AND E1_PORTADO NOT IN ('P00','P01','P02','P03','P14') AND E1_SALDO > 0  AND SE1.D_E_L_E_T_='' "
	cQuery += "WHERE LEFT(A1_CGC,8) = ZF_CGCMAT AND SZF.D_E_L_E_T_='' AND SA1.D_E_L_E_T_='' "
	cQuery += "ORDER BY ZF_REDE, LC DESC, ZF_NOMERED"
		
	TCQUERY cQuery NEW ALIAS "ZF1"
	Processa( {|| RunRel()},"Aguarde ..." )
	
Return

Static Function RunRel

	dbSelectArea("ZF1")
	dbGoTop()
	ProcRegua(RecCount())

	While !Eof()
	
	nSld     := 0
	_nVenc   := 0
	_nAvenc  := 0
	
	IncProc(OemToAnsi("Processando: "+AllTrim(ZF1->ZF_REDE)+" - "+AllTrim(ZF1->ZF_NOMERED)))   
		
	If _nLin > 2000                      //2700 //3100  tamanho das linhas quando relatorio era paisagem
		PrintCabec()
	EndIf
	
	// Atribui valores as variáveis para impressão
	cRede     := ZF1->ZF_REDE 
	cNomeRede := Substr(ZF1->ZF_NOMERED,1,28)
	cRisco    := ZF1->ZF_XRISCO
	cCGC      := ZF1->A1_CGC
	nLC       := ZF1->LC
	_cAtivo := " "
	If ZF1->A1_MSBLQL == "1"   //Bloqueado SIM
		_cAtivo := "N"
	Elseif ZF1->A1_MSBLQL == "2"   //Bloqueado NAO
		_cAtivo := "S"   
	Endif   
	
	// Efetua a somatória do Saldo, buscando o código da Rede mais o CNPJ - Paulo - TDS - 13/07/2011
	While ZF1->ZF_REDE+ZF1->A1_CGC == cRede+cCGC
		nSld    += ZF1->SALDO
		_nVenc  += (ZF1->VENC1 + ZF1->VENC2) 
		_nAVenc += (ZF1->AVENC1 + ZF1->AVENC2)
		dbSkip()
	EndDo
	
	GravaSZF()
	
	oPrn:Say(_nLin,0070,cRede    ,oFontA10,100 )                                //70
	oPrn:Say(_nLin,0300,cNomeRede,oFontA10,100 )                                //0300
	oPrn:Say(_nLin,0950,cCGC     ,oFontA10,100 )	                               //0850
	
	oPrn:Say(_nLin,1150,_cAtivo  ,oFontA10,100 )	                               //1050
	
	oPrn:Say(_nLin,1300,Transform(nLC ,"@E 999,999,999.99"),oFontA10,100)       //1200
	oPrn:Say(_nLin,1600,Transform(nSld,"@E 999,999,999.99"),oFontA10,100)       //1500
	oPrn:Say(_nLin,1900,Transform(_nVenc,"@E 999,999,999.99"),oFontA10,100)     //1800
	oPrn:Say(_nLin,2200,Transform(_nAVenc,"@E 999,999,999.99"),oFontA10,100)    //2100
	_nPerc := ((nSld/nLC) * 100)
	oPrn:Say(_nLin,2500,Transform(_nPerc,"@E 999.99%"),oFontA10,100)    //2400
	
	oPrn:Say(_nLin,2750,cRisco,oFontA10,100)    //2400
	
	_nLin += nHeight
	
	// Ao invés de somente "atribuir" o saldo no total do LC da rede e estando na mesma rede, soma-se o total do LC da rede 
	// Paulo - TDS - 13/07/2011
	nTotCredRede += nLC 
	nTotSaldRede += nSld
	nTotVencRd   += _nVenc
	nTotAvenRd   += _nAvenc
		
	If ZF1->ZF_REDE != cRede
		PrintSub()
	EndIf   
	
	EndDo

	PrintSub()

	_nLin2 := _nLin + nHeight
	oPrn:Box(_nLin-5,0050,_nLin2+5,0300)
	oPrn:Box(_nLin,1300,_nLin2,1590)
	oPrn:Box(_nLin,1600,_nLin2,1890)
	oPrn:Box(_nLin,1900,_nLin2,2190)
	oPrn:Box(_nLin,2200,_nLin2,2490)
	oPrn:Box(_nLin,2500,_nLin2,2670)
				
	oPrn:Say(_nLin,0070,"Total Geral:", oFontA10B, 100 )
	oPrn:Say(_nLin,1300,Transform(nTotCred,"@E 999,999,999.99"), oFontA10B, 100 )  //1500
	oPrn:Say(_nLin,1600,Transform(nTotSld ,"@E 999,999,999.99"), oFontA10B, 100 )  //2000
	oPrn:Say(_nLin,1900,Transform(nTotVCD ,"@E 999,999,999.99"), oFontA10B, 100 )  //2500
	oPrn:Say(_nLin,2200,Transform(nTotAVC ,"@E 999,999,999.99"), oFontA10B, 100 )  //3000
	_nPerc := ((nTotSld/nTotCred) * 100)
	oPrn:Say(_nLin,2500,Transform(_nPerc ,"@E 999.99%"), oFontA10B, 100 )  //3000

	_nLin := _nLin2 + nHeight

	oPrn:Line( _nLin, 0050, _nLin, 2940 )	

	// *** INICIO chamado 034477 GRAVA LOG *** //
	IF lGeraAcumulo == .T.

		GRAVARLOGZBE()        
		
	ENDIF

	// *** FINAL chamado 034477 GRAVA LOG *** //

	oPrn:Preview()

	// Fecha o temporário - Paulo - TDS - 13/07/2011
	dbSelectArea("ZF1")
	dbCloseArea()   

	RestArea(aArea)

	MS_FLUSH()	

Return Nil

Static Function PrintCabec                                                                

	oPrn:Endpage()
	oPrn:Startpage()
	_nLin  := 50
	nPag++   
	
	oPrn:Line( _nLin - 15, 0050, _nLin - 15, 2940 )	

	// Logotipo
	If file("adoro.bmp")
	cBitMap := "adoro.bmp"
	oPrn:SayBitmap( _nLin - 7, 0050, cBitMap, 120, 75 )                         
	Else
	oPrn:Say( _nLin, 0050, "ADORO", oFontA10, 100 )
	EndIf	

	oPrn:Say(_nLin,_cPos,Upper(_cNome),oFontA12B,100)	
	oPrn:Say( _nLin, 2000, "Folha.....: " + StrZero(nPag,3), oFontA10 , 100)	
	_nLin += nHeight
		
	oPrn:Say(_nLin,0050,"Protheus/ADLCRED2/V.10",oFontA10,100)
	oPrn:Say(_nLin,2000,"Emissao: " + DtoC(dDataBase),oFontA10,100) 
	_nLin += nHeight
		
	oPrn:Line(_nLin,0050,_nLin,2940)
	oPrn:Say(_nLin, 0050, "REDE",           oFontA10B, 100)
	oPrn:Say(_nLin, 0300, "NOME DA REDE",   oFontA10B, 100)
	oPrn:Say(_nLin, 0950, "CGC",            oFontA10B, 100)
	oPrn:Say(_nLin, 1150, "ATIVO",          oFontA10B, 100)
	oPrn:Say(_nLin, 1300, "LIMITE CREDITO", oFontA10B, 100)
	oPrn:Say(_nLin, 1600, "SLD EM ABERTO",oFontA10B, 100)
	oPrn:Say(_nLin, 1930, "VENCIDO", oFontA10B, 100)
	oPrn:Say(_nLin, 2200, "PROX.2 DIAS",oFontA10B, 100)
	oPrn:Say(_nLin, 2500, "% Utiliz.", oFontA10B, 100)
	oPrn:Say(_nLin, 2750, "Risco Cisp", oFontA10B, 100)

	_nLin += nHeight

	oPrn:Line(_nLin,0050,_nLin,2940)
	_nLin += nHeight

Return

Static Function PrintSub()
                          
	_nLin2 := _nLin + nHeight
	oPrn:Box(_nLin,0050,_nLin2,0270)
	oPrn:Box(_nLin,1300,_nLin2,1590)
	oPrn:Box(_nLin,1600,_nLin2,1890)
	oPrn:Box(_nLin,1900,_nLin2,2190)
	oPrn:Box(_nLin,2200,_nLin2,2490)
	oPrn:Box(_nLin,2500,_nLin2,2670)			
	oPrn:Box(_nLin,2700,_nLin2,2930)			

	oPrn:Say(_nLin,0070,cRede,oFontA10B,100)
	oPrn:Say(_nLin,1300,Transform(nTotCredRede,"@E 9,999,999.99") ,oFontA10B,100)    //1500
	oPrn:Say(_nLin,1600,Transform(nTotSaldRede,"@E 9,999,999.99") ,oFontA10B,100)    //2000
	oPrn:Say(_nLin,1900,Transform(nTotVencRD,"@E 9,999,999.99") ,oFontA10B,100)      //2500
	oPrn:Say(_nLin,2200,Transform(nTotAvenRD,"@E 9,999,999.99") ,oFontA10B,100)      //3000
	_nPerc := ((nTotSaldRede/nTotCredRede) * 100)
	oPrn:Say(_nLin,2500,Transform(_nPerc,"@E 999.99%") ,oFontA10B,100)      //3000

	_nLin := _nLin2 + nHeight

	oPrn:Line(_nLin,0050,_nLin,2940)
	_nLin += nHeight
		
	nTotCred += nTotCredRede
	nTotSld  += nTotSaldRede
	nTotVCD  += nTotVencRD
	nTotAVC  += nTotAvenRD               
		
	// *** INICIO CHAMADO 034477 *** //
	IF lGeraAcumulo == .T.

		GRAVAMAIORACUMULO()
		
	ENDIF	
									
	// *** FINAL CHAMADO 034477 *** //
	nTotCredRede := nTotSaldRede := nTotVencRD := nTotAvenRD := 0

Return

Static Function GravaSZF

	dbSelectArea("SZF")
	dbSetOrder(1)
	If dbSeek( xFilial() + cCGC )

		u_GrLogZBE (Date(),TIME(),cUserName,"Saldo de Rede ZF_LCREDE","FINANCEIRO","ADLCRED2",;
					"CNPJ: "+ SZF->ZF_CGCMAT + " Saldo de: " + CVALTOCHAR(SZF->ZF_LCREDE) + " Saldo para: " + CVALTOCHAR(nLC),ComputerName(),LogUserName())
		
	RecLock("SZF",.F.)
	SZF->ZF_LCREDE  := nLC
	SZF->ZF_SLDREDE := nSld 
	SZF->ZF_VENCIDO := _nVenc
	SZF->ZF_AVENCER := _nAVENC
	SZF->(MsUnlock())
	
	EndIf
	dbSelectArea("ZF1")
	
Return     
          
// INICIO CHAMADO 033752 - WILLIAM COSTA 03/03/2017
Static Function GRAVAMAIORACUMULO()

	DBSELECTAREA("SZF")
	DBSETORDER(3)
	IF DBSEEK(xFilial("SZF") + cRede)
	
		While !SZF->(Eof()) .AND. SZF->(ZF_FILIAL+ZF_REDE) == (xFilial("SZF") + cRede)
	
			RecLock("SZF",.F.)
				   
				SZF->ZF_DTACUMU := CTOD("  /  /  ")
			    SZF->ZF_VLACUMU := 0
			 
			   
		    SZF->(MsUnlock())
		    SZF->(dbSkip())
		    
		ENDDO
	ENDIF
	
	nContCgc := 0

	DBSELECTAREA("SZF")
	DBSETORDER(3)
	IF DBSEEK(xFilial("SZF") + cRede)

		IncProc(OemToAnsi("Processando: "+AllTrim(SZF->ZF_REDE)+" - "+AllTrim(SZF->ZF_NOMERED)))   
	                                      
	    SqlVerifRede(SZF->ZF_REDE)
   		While TRB->(!EOF())
    				
    		nContCgc := nContCgc + 1
		       	
            TRB->(dbSkip())
		ENDDO
		TRB->(dbCloseArea()) 
		
   	    While !SZF->(Eof()) .AND. SZF->(ZF_FILIAL+ZF_REDE) == (xFilial("SZF") + cRede) 	
   	    
   	    	IF nContCgc >= 2 // SIGNIFICA QUE TEM VARIOS CNPJS NA REDE
   	    	
   	    		U_ADFIN052P(cRede)

		   	ELSE // SIGNIFICA QUE TEM UM CNPJ SO    
		   	
		   		SqlBuscaRedCli(SZF->ZF_REDE)
		   		While TRD->(!EOF())
    				
		    		RecLock("SZF",.F.)
			   
						SZF->ZF_DTACUMU := STOD(TRD->A1_DTACUMU)
					    SZF->ZF_VLACUMU := TRD->A1_VLACUMU
					   
				    SZF->(MsUnlock()) 
				   	
		            TRD->(dbSkip())
				ENDDO
				TRD->(dbCloseArea()) 
		   	
		   	ENDIF    
		   	
		   	SZF->(dbSkip())
	   	    
	    ENDDO
	ENDIF
	
	DBSELECTAREA("ZF1")
	
	
RETURN(NIL)     
// FINAL CHAMADO 033752 - WILLIAM COSTA 03/03/2017

// *** INICIO chamado 034477 GRAVA LOG *** //

STATIC FUNCTION GRAVARLOGZBE()

	DBSELECTAREA("ZBE")
	RecLock("ZBE",.T.)
		REPLACE ZBE_FILIAL 	   	WITH xFilial("ZBE")
		REPLACE ZBE_DATA 	   	WITH DATE()
		REPLACE ZBE_HORA 	   	WITH TIME()
		REPLACE ZBE_USUARI	    WITH UPPER(Alltrim(cUserName))
		REPLACE ZBE_LOG	        WITH ("ADLCRED2 " + " RODOU RELATÓRIO COM MAIOR ACUMULO")
		REPLACE ZBE_MODULO	    WITH "FINANCEIRO"
		REPLACE ZBE_ROTINA	    WITH "ADLCRED2" 
	MsUnlock()              

RETURN(NIL)

// *** FINAL chamado 034477 GRAVA LOG *** //

STATIC FUNCTION SqlVerifRede(cRede)

	BeginSQL Alias "TRB"
			%NoPARSER%  
			SELECT ZF_REDE,ZF_CGCMAT 
			  FROM %Table:SZF% WITH (NOLOCK)
			 WHERE ZF_REDE     = %EXP:cRede%
			   AND D_E_L_E_T_ <> '*'
			
			GROUP BY ZF_REDE,ZF_CGCMAT

	EndSQl             

RETURN(NIL)

STATIC FUNCTION SqlVerifLog()

	BeginSQL Alias "TRC"
			%NoPARSER%
			SELECT TOP(1) ZBE_DATA, ZBE_HORA, ZBE_USUARI
			  FROM %Table:ZBE% WITH (NOLOCK) 
			  WHERE ZBE_ROTINA = 'ADLCRED2'
			    AND D_E_L_E_T_ <> '*'
			
				ORDER BY ZBE_DATA DESC, ZBE_HORA DESC
				
	EndSQl             

RETURN(NIL)       

STATIC FUNCTION SqlBuscaRedCli(cRede)

	BeginSQL Alias "TRD"
			%NoPARSER%
			SELECT TOP(1) A1_DTACUMU, A1_VLACUMU
			  FROM %Table:SA1% WITH (NOLOCK) 
			  WHERE A1_CODRED = %EXP:cRede%
			    AND D_E_L_E_T_ <> '*'
			
				
	EndSQl             

RETURN(NIL)