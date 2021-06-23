#Include "Protheus.ch"  
#Include "Fileio.ch"
#Include "TopConn.ch"  
#Include "Rwmake.ch"     

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ADCOM026R ºAutor  ³Fernando Sigoli     º Data ³  05/09/2018 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Relatorio Alçada de aprovação em excel                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGACOM                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function ADCOM026R()

 	Private aSays		:={}
	Private aButtons	:={}   
	Private cCadastro	:="Relatório Alçada de Aprovação"    
	Private oFontA06	:= TFont():New( "Arial",,10,,.f.,,,,,.f. )
	Private oFontA09	:= TFont():New( "Arial",,-9,,.f.,,,,,.f. )
	Private oFontA09b	:= TFont():New( "Arial",,-9,,.t.,,,,,.f. )
	Private oFontA07	:= TFont():New( "Arial",,12,,.T.,,,,,.f. )
	Private oPrn		:=TMSPrinter():New()
	Private nOpca		:=0
	Private cPerg		:= 'ADCOM026R'
	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')
	
	//+------------------------------------------------+
	//|Cria grupo de perguntas.                        |
	//+------------------------------------------------+
	 MontaPerg()
	 
	 //+-----------------------------------------------+
	//|Monta Form Batch - Interface com o usuário.     |            
	//+------------------------------------------------+
	Aadd(aSays,"Este programa tem a finalidade de Gerar um arquivo Excel " )
	Aadd(aSays,"Relatorio Alçada aprovação" )
    
	Aadd(aButtons, { 5,.T.,{|o| Pergunte(cPerg,.T.) }})
	Aadd(aButtons, { 1,.T.,{|o| nOpca:=1, o:oWnd:End(), Processa({||ComADCOM026R()},"Gerando arquivo","Aguarde...")}})
	Aadd(aButtons, { 2,.T.,{|o| nOpca:=2, o:oWnd:End() }})
	
	FormBatch(cCadastro, aSays, aButtons)  
	
Return Nil

Static Function ComADCOM026R() 

 	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
	Private oExcel      := FWMSEXCEL():New()
	Private cPath       := '\protheus_data\system\'
	Private cArquivo    := 'REL_ALCADA_APROV.XML'
	Private oMsExcel
	Private cPlanilha   := "Alçada Aprovação"
	Private cTitulo     := "Alçada Aprovação"
	Private cCodProdSql := '' 
	Private cFilSql     := ''
	Private aLinhas     := {}
   
	Begin Sequence
		
		//Verifica se há o excel instalado na máquina do usuário.
		If ! ( ApOleClient("MsExcel") ) 
		
			MsgStop("Não Existe Excel Instalado","Função ComADCOM026R(ADCOM026R)")   
		    Break
		    
		EndIF
		
		//Gera o cabeçalho.
		Cabec()  
		          
		If ! GeraExcel()
			Break
			
		EndIf
		
		Sleep(2000)
		SalvaXml()
		
		Sleep(2000)
		CriaExcel()
		
		MsgInfo("Arquivo Excel gerado!","Função ComADCOM026R(ADCOM026R)")    
	    
	End Sequence

Return Nil 
                        

Static Function Cabec() 

	oExcel:AddworkSheet(cPlanilha)
	
	//Alçadas de aprovação
	oExcel:AddTable (cPlanilha,cTitulo)
	oExcel:AddColumn(cPlanilha,cTitulo,"Usuario"		,1,1) // 01 A
	oExcel:AddColumn(cPlanilha,cTitulo,"Nome   "	    ,1,1) // 02 B
	oExcel:AddColumn(cPlanilha,cTitulo,"Grupo "			,1,1) // 03 C
	oExcel:AddColumn(cPlanilha,cTitulo,"Descricao"    	,1,1) // 04 D
	oExcel:AddColumn(cPlanilha,cTitulo,"Nivel "			,1,1) // 05 E
	oExcel:AddColumn(cPlanilha,cTitulo,"R$ Inicial"	    ,1,1) // 06 F
	oExcel:AddColumn(cPlanilha,cTitulo,"R$ Final "		,1,1) // 07 G
	oExcel:AddColumn(cPlanilha,cTitulo,"C.Custo INI "	,1,1) // 08 H
	oExcel:AddColumn(cPlanilha,cTitulo,"Descrição"		,1,1) // 09 I
	oExcel:AddColumn(cPlanilha,cTitulo,"C.Custo Fim" 	,1,1) // 10 J
	oExcel:AddColumn(cPlanilha,cTitulo,"Descricao"	    ,1,1) // 11 K
	
Return Nil

Static Function GeraExcel()

	Local nLinha		:= 0
	Local nExcel     	:= 0
	Local nTotReg		:= 0
	Local cNumPC        := ''
	Local cConst        := ''	
	
	cConst := SqlPedidos()
	
    
    //
    If Select("ADCOMT026") > 0
 	    ADCOMT026->(DbCloseArea())
    EndIf	
    
    //
    TcQuery cConst New Alias "ADCOMT026"
              
    //Conta o Total de registros.
	nTotReg := Contar("ADCOMT026","!Eof()")
	
	//Valida a quantidade de registros.
	DbSelectArea("ADCOMT026")
    
	If nTotReg <= 0
		MsgStop("Não há registros para os parâmetros informados.","Função GeraExcel(ADCOMR002)")
		Return .F.
		
	EndIf
	
	//Atribui a quantidade de registros à régua de processamento.
	ProcRegua(nTotReg)
	
	ADCOMT026->(DbGoTop())
	While !ADCOMT026->(Eof()) 
	
		cNumGrp := Alltrim(cValToChar(ADCOMT026->PAF_CODGRP ))
	
		IncProc("Processando Grupo:. " + cNumGrp)     
					 
	    nLinha  := nLinha + 1                                       
	
	    //===================== INICIO CRIA VETOR COM POSICAO VAZIA 
	   	Aadd(aLinhas,{ "", ; // 01 A  
	   	               "", ; // 02 B   
	   	               "", ; // 03 C  
	   	               "", ; // 04 D  
	   	               "", ; // 05 E  
	   	               "", ; // 06 F   
	   	               "", ; // 07 G  
	   	               "", ; // 08 H  
	   	               "", ; // 09 I  
	   	               "", ; // 10 J   
	   	               ""  ; // 11 K  
	                      })
		//===================== FINAL CRIA VETOR COM POSICAO VAZIA
		
		//======================================= INICIO ADICIONANDO OS CAMPOS NAS LINHAS ===================   
		
		//Dados do pedido.
		aLinhas[nLinha][01] := ADCOMT026->PAG_IDUSER                                                                                                                // 01 A	
		aLinhas[nLinha][02] := UsrRetName( ADCOMT026->PAG_IDUSER )                                                                                                                   // 02 B
		aLinhas[nLinha][03] := ADCOMT026->PAF_CODGRP                                                                                                         // 03 C
		aLinhas[nLinha][04] := ADCOMT026->PAF_DESCRI                                                                                                               // 04 D
		aLinhas[nLinha][05] := ADCOMT026->PAG_NIVEL                                                                                                                    // 05 E
		aLinhas[nLinha][06] := Transform(ADCOMT026->PAG_VLRINI , "@E 9,999,999,999" )                                                                                                               // 06 F
		aLinhas[nLinha][07] := Transform(ADCOMT026->PAG_VLRFIM , "@E 9,999,999,999" )                                                                                                               // 07 G
		aLinhas[nLinha][08] := ADCOMT026->PAF_CCINI                                                                                                                // 08 H
		aLinhas[nLinha][09] := ADCOMT026->DCCINI  		                                                                                                          // 09 I
		aLinhas[nLinha][10] := ADCOMT026->PAF_CCFIM                                                                                                                 // 10 J
		aLinhas[nLinha][11] := ADCOMT026->DCCFIM                                                                                                                 // 11 K

		ADCOMT026->(DBSKIP())    
		
	ENDDO
	
	ADCOMT026->(DbCloseArea())    
	
	//============================== INICIO IMPRIME LINHA NO EXCEL
	For nExcel := 1 To nLinha
		
		IncProc("Carregando Dados para a Planilha1 de: " + cValtochar(nExcel) + ' até: ' + cValtochar(nLinha))
		
   		oExcel:AddRow(cPlanilha,cTitulo,{aLinhas[nExcel][01],;  // 01 A  
								         aLinhas[nExcel][02],;  // 02 B  
								         aLinhas[nExcel][03],;  // 03 C  
								         aLinhas[nExcel][04],;  // 04 D  
								         aLinhas[nExcel][05],;  // 05 E  
								         aLinhas[nExcel][06],;  // 06 F  
								         aLinhas[nExcel][07],;  // 07 G  
								         aLinhas[nExcel][08],;  // 08 H  
								         aLinhas[nExcel][09],;  // 09 I  
								         aLinhas[nExcel][10],;  // 10 J  
								         aLinhas[nExcel][11] ;  // 11 K  
													      	 }) 	
													      	 			
   Next nExcel 
 	//============================== FINAL IMPRIME LINHA NO EXCEL
 	
Return .T.  


//script sql
Static Function SqlPedidos()   

Local cQuery := ""


cQuery := " SELECT " 
cQuery += " PAG_IDUSER, "
cQuery += " PAF_CODGRP, "
cQuery += " PAF_DESCRI, "
cQuery += " PAG_NIVEL , "
cQuery += " PAG_VLRINI, "
cQuery += " PAG_VLRFIM, "
cQuery += " PAF_CCINI , "
cQuery += " (SELECT CTT_DESC01 FROM CTT010  (NOLOCK) WHERE CTT010.D_E_L_E_T_  = '' AND CTT_CUSTO = PAF_CCINI) AS 'DCCINI',  "
cQuery += " PAF_CCFIM, "
cQuery += " (SELECT CTT_DESC01 FROM CTT010  (NOLOCK) WHERE CTT010.D_E_L_E_T_  = '' AND CTT_CUSTO = PAF_CCINI) AS 'DCCFIM'  "
		
cQuery += " FROM " 
cQuery += " PAF010  WITH(NOLOCK)  LEFT JOIN PAG010  WITH(NOLOCK)  "
cQuery += " ON PAF_CODGRP = PAG_CODGRP "
cQuery += " WHERE PAF010.D_E_L_E_T_  = '' AND PAG010.D_E_L_E_T_  = '' AND PAG_MSBLQL = '2'  "
cQuery += " AND rtrim(ltrim(PAG_CODGRP))+rtrim(ltrim(PAF_CODGRP))+rtrim(ltrim(PAF_CCINI))+rtrim(ltrim(PAF_CCFIM)) IN  "
cQuery += " ( "
cQuery += " SELECT  "
cQuery += " 	rtrim(ltrim(PAG_CODGRP))+rtrim(ltrim(PAF_CODGRP))+rtrim(ltrim(PAF_CCINI))+rtrim(ltrim(PAF_CCFIM)) AS CHAVE "
cQuery += " FROM  "
cQuery += " 	PAF010 PAF LEFT JOIN PAG010 PAG WITH(NOLOCK)  ON PAF.PAF_CODGRP = PAG.PAG_CODGRP  "
cQuery += " WHERE PAF010.D_E_L_E_T_  = '' AND PAG010.D_E_L_E_T_  = '' AND PAG_MSBLQL = '2' "
cQuery += "  AND PAG_IDUSER >= '"+MV_PAR01+"' AND PAG_IDUSER <= '"+MV_PAR02+"' "
cQuery += "  AND PAF_CCINI  >= '"+MV_PAR03+"'   AND PAF_CCINI <= '"+MV_PAR04+"'  "
cQuery += "  AND PAF_CODGRP >= '"+MV_PAR05+"' AND PAF_CODGRP <= '"+MV_PAR06+"'  " 
cQuery += " GROUP BY rtrim(ltrim(PAG_CODGRP))+rtrim(ltrim(PAF_CODGRP))+rtrim(ltrim(PAF_CCINI))+rtrim(ltrim(PAF_CCFIM))   "  
cQuery += " ) "
cQuery += " ORDER BY PAG_CODGRP, PAG_NIVEL  "


Return (cQuery) 

 

Static Function SalvaXml()

	oExcel:Activate()
	oExcel:GetXMLFile("C:\temp\REL_ALCADA_APROV.XML")

Return Nil

Static Function CriaExcel()              

	oMsExcel := MsExcel():New()
	oMsExcel:WorkBooks:Open("C:\temp\REL_ALCADA_APROV.XML")
	oMsExcel:SetVisible( .T. )
	oMsExcel := oMsExcel:Destroy()

Return Nil

Static Function MontaPerg()  
                                
	Private bValid := Nil 
	Private cF3	   := Nil
	Private cSXG   := Nil
	Private cPyme  := Nil
	
	U_xPutSx1(cPerg,'01','Usuario de          ?','','','mv_ch01','C',06,0,0,'G',bValid,"USR",cSXG,cPyme,'MV_PAR01')
	U_xPutSx1(cPerg,'02','Usuario Ate         ?','','','mv_ch02','C',06,0,0,'G',bValid,"USR",cSXG,cPyme,'MV_PAR02')
	U_xPutSx1(cPerg,'03','Centro de Custo de  ?','','','mv_ch03','C',09,0,0,'G',bValid,"CTT",cSXG,cPyme,'MV_PAR03')
	U_xPutSx1(cPerg,'04','Centro de Custo Ate ?','','','mv_ch04','C',09,0,0,'G',bValid,"CTT",cSXG,cPyme,'MV_PAR04')
	U_xPutSx1(cPerg,'05','Grupo De            ?','','','mv_ch05','C',06,0,0,'G',bValid,cF3  ,cSXG,cPyme,'MV_PAR05')
	U_xPutSx1(cPerg,'06','Grupo Ate           ?','','','mv_ch06','C',06,0,0,'G',bValid,cF3  ,cSXG,cPyme,'MV_PAR06')
	
    Pergunte(cPerg,.F.)
	
Return Nil            