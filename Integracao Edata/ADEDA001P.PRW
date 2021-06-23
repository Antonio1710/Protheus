/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ADEDA001P ºAutor  ³William COSTA       º Data ³  14/04/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Programa de Ajustes de Cargas                              º±±
±±º          ³ Relatorio para acompanhamento de troca de cargas que o     º±±
±±º          ³ protheus faz, esse relatorio e para reorganizar novamente  º±±
±±º          ³ os numeros da cargas ficando carga protheus e carga edata  º±±
±±º          ³ igual Programa Relatorio em Excel.                         º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGACOM                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
#INCLUDE "PROTHEUS.CH"  
#INCLUDE "FILEIO.CH"
#INCLUDE "TopConn.CH"  
#INCLUDE "rwmake.ch"     

User Function ADEDA001P()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Private aSays		:= {}
	Private aButtons	:= {}   
	Private cCadastro	:= "Programa de Ajustes de Cargas"    
	PRIVATE oFontA06	:= TFont():New( "Arial",,10,,.f.,,,,,.f. )
	PRIVATE oFontA09	:= TFont():New( "Arial",,-9,,.f.,,,,,.f. )
	PRIVATE oFontA09b	:= TFont():New( "Arial",,-9,,.t.,,,,,.f. )
	PRIVATE oFontA07	:= TFont():New( "Arial",,12,,.T.,,,,,.f. )
	PRIVATE oPrn		:= TMSPrinter():New()
	Private nOpca		:= 0
	Private cPerg		:= 'ADEDA001P'
	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Programa de Ajustes de Cargas Relatorio para acompanhamento de troca de cargas que o protheus faz, esse relatorio e para reorganizar novamente os numeros da cargas ficando carga protheus e carga edata igual Programa Relatorio em Excel.')
	
	//+------------------------------------------------+
	//|Cria grupo de Perguntas                         |
	//+------------------------------------------------+
	 MontaPerg()
	 
	 //+-----------------------------------------------+
	//|Monta Form Batch - Interface com o Usuario     |
	//+-----------------------------------------------+
	AADD(aSays,"Este Programa de Ajustes de Cargas e enviar para o excel as alteracoes " )
	AADD(aSays,"Programa de Ajustes de Cargas" )
    
	AADD(aButtons, { 5,.T.,{|o| Pergunte(cPerg,.T.) }})
	AADD(aButtons, { 1,.T.,{|o| nOpca:=1, o:oWnd:End(), Processa({||EDAADEDA001P()},"Gerando arquivo","Aguarde...")    }})
	AADD(aButtons, { 2,.T.,{|o| nOpca:=2, o:oWnd:End() }})
	
	FormBatch( cCadastro, aSays, aButtons )  
	
Return (Nil)  
         

Static Function EDAADEDA001P()    
  
	Public oExcel      := FWMSEXCEL():New()
	Public cPath       := 'D:\Totvs\Protheus11_Homolog\protheus_data\system\'
	Public cArquivo    := 'AJUSTE_CARGAS_EDATA_PROTHEUS.XML'
	Public oMsExcel    := NIL
	Public cPlanilha   := 'Programa de Ajustes de Cargas'
    Public cTitulo     := 'Programa de Ajustes de Cargas'
    Public cCodProdSql := ''
    Public aLinhas     := {}
   
	BEGIN SEQUENCE
		
		IF .NOT.( ApOleClient("MsExcel") )   // se nao existir o excel sai fora..
		    Alert("Não Existe Excel Instalado")
            BREAK
        EndIF
		
		Cabec()             
		GeraExcel()
	          
		SalvaXml()
		CriaExcel()
	
	    MsgInfo("Arquivo Excel gerado!")    
	    
	END SEQUENCE
     
Return(NIL) 

Static Function GeraExcel()

    Private nLinha := 0
	Private nExcel := 0

    SqlGeral() 
	
	DBSELECTAREA("TRB")
		TRB->(DBGOTOP())
		
		WHILE TRB->(!EOF()) 
		
			nLinha  := nLinha + 1                                       

            //===================== INICIO CRIA VETOR COM POSICAO VAZIA 
		   	AADD(aLinhas,{ "", ; // 01 A  
		   	               "", ; // 02 B   
		   	               "", ; // 03 C   
		   	               "", ; // 04 D  
		   	               "", ; // 05 E  
		   	               ""  ; // 06 F  
		   	                   })
			//===================== FINAL CRIA VETOR COM POSICAO VAZIA
			
			//======================================= INICIO ADICIONANDO OS CAMPOS NAS LINHAS ===================
			aLinhas[nLinha][01] := TRB->DT_ENTRPEDIVEND //A
			aLinhas[nLinha][02] := TRB->ROTEIRO         //B
			aLinhas[nLinha][03] := TRB->ID_CARGEXPE     //C
			aLinhas[nLinha][04] := 'NAO ALTERADO '      //D
			aLinhas[nLinha][05] := 'NAO ALTERADO'       //E
			aLinhas[nLinha][06] := TRB->IE_PEDIVEND     //F
			//======================================= FINAL ADICIONANDO OS CAMPOS NAS LINHAS ===================			
			
			DBSELECTAREA("SC5")
			DBSETORDER(1)
			IF DBSEEK('02'+ALLTRIM(TRB->IE_PEDIVEND),.T.)
			
				IF SC5->C5_XINT == '4' //ERRO NO CAMPO XINT
			        IF SC5->C5_X_SQED <> STRZERO(TRB->ID_CARGEXPE,10)      // CAMPOS DE CARGA DIFERENTE PROTHEUS x EDATA
			        	aLinhas[nLinha][04] := SC5->C5_X_SQED                    //D
			            aLinhas[nLinha][05] := STRZERO(TRB->ID_CARGEXPE,10) //E
						Reclock("SC5",.F.)
							SC5->C5_XINT   := "3"
							SC5->C5_X_SQED := STRZERO(TRB->ID_CARGEXPE,10)
							SC5->C5_XOBS   := "OK" 
							
							IF MV_PAR05 == 1 // SIM  --JA FOI ENVIADO PARA O FATURAMENTO 
								SC5->C5_XFLAGE := "2"
							ENDIF
								
						MsUnlock()
					ELSE // INFORMAR QUE A CARGAS SAO AS MESMAS
					
						MSGINFO("Pedido de Venda: " + TRB->IE_PEDIVEND + chr(10) + chr(13) + ;
					            " esta com os mesmos numeros de carga PROTHEUS X EDATA favor verificar com administrador do sistema")
					
						
					ENDIF //fecha if de sequencia edata
				
				ELSE  // else do xint
				
					MSGINFO("Pedido de Venda: " + TRB->IE_PEDIVEND + chr(10) + chr(13) + ;
					        " não está com erro no campo C5_XINT favor verificar com administrador do sistema")	
					
				ENDIF // fecha if de xint com erro
			ENDIF // fecha if dbseek
			DBCLOSEAREA("SC5")
			
			
			TRB->(dbSkip())    
		
		END //end do while TRB
		TRB->( DBCLOSEAREA() )
		
		//============================== INICIO IMPRIME LINHA NO EXCEL
		FOR nExcel := 1 TO nLinha
	   		oExcel:AddRow(cPlanilha,cTitulo,{aLinhas[nExcel][01],; // 01 A  
            	                             aLinhas[nExcel][02],; // 02 B  
            	                             aLinhas[nExcel][03],; // 03 C  
	   	        	                         aLinhas[nExcel][04],; // 04 D  
	   	            	                     aLinhas[nExcel][05],; // 05 E  
	   	                	                 aLinhas[nExcel][06] ; // 06 F  
                                                                  }) //GRAVANDO NA LINHA MANDANDO PARA O EXCEL O ARRAY COM AS LINHAS				
        NEXT 
	    //============================== FINAL IMPRIME LINHA NO EXCEL
Return()    

Static Function SqlGeral()

    Local cDataIni := DTOS(MV_PAR03)
    Local cDataFin := DTOS(MV_PAR04)
    Local cQuery   := ''
    
    cQuery := " SELECT IE_PEDIVEND, "
    cQuery += "        ID_CARGEXPE, "
    cQuery += "        GN_PLACVEICTRAN, "
    cQuery += "        ROTEIRO, " 
    cQuery += "        DT_ENTRPEDIVEND "
  	cQuery += "   FROM [LNKMIMS].[SMART].[dbo].[VW_ERRO_02] "
	cQuery += "  WHERE DT_ENTRPEDIVEND >= " + "'" + ALLTRIM(cDataIni) + "'" 
    cQuery += "    AND DT_ENTRPEDIVEND <= " + "'" + ALLTRIM(cDataFin) + "'" 
    cQuery += "    AND ROTEIRO         >= " + "'" + ALLTRIM(MV_PAR01) + "'" 
    cQuery += "    AND ROTEIRO         <= " + "'" + ALLTRIM(MV_PAR02) + "'" 
    
    dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TRB", .F., .T.)  
   

RETURN()    

Static Function SalvaXml()

	oExcel:Activate()
	oExcel:GetXMLFile("C:\temp\AJUSTE_CARGAS_EDATA_PROTHEUS.XML")

Return()

Static Function CriaExcel()              

    oMsExcel := MsExcel():New()
	oMsExcel:WorkBooks:Open("C:\temp\AJUSTE_CARGAS_EDATA_PROTHEUS.XML")
	oMsExcel:SetVisible( .T. )
	oMsExcel := oMsExcel:Destroy()

Return()       

Static Function MontaPerg()                                  
	Private bValid	:=Nil 
	Private cF3		:=Nil
	Private cSXG	:=Nil
	Private cPyme	:=Nil
	
    PutSx1(cPerg,'01','Roteiro de                   ?','','','mv_ch1','C',03,0,0,'G',bValid,cF3,cSXG,cPyme,'MV_PAR01')
	PutSx1(cPerg,'02','Roteiro Ate                  ?','','','mv_ch2','C',03,0,0,'G',bValid,cF3,cSXG,cPyme,'MV_PAR02')
	PutSx1(cPerg,'03','Data De                      ?','','','mv_ch3','D',08,0,0,'G',bValid,cF3,cSXG,cPyme,'MV_PAR03')
	PutSx1(cPerg,'04','Data Ate                     ?','','','mv_ch4','D',08,0,0,'G',bValid,cF3,cSXG,cPyme,'MV_PAR04')
	PutSx1(cPerg,'05','Ja liberado para faturamento ?','Ja liberado para faturamento ?','Ja liberado para faturamento ?','MV_PAR05','N',2,0,1,'C','','','','S','MV_PAR05','SIM','SIM','SIM','','NÃO','NÃO','NÃO','','','','','','','','','','','','')    

	Pergunte(cPerg,.F.)
Return Nil            
                                
Static Function Cabec() 

    oExcel:AddworkSheet(cPlanilha)
	oExcel:AddTable (cPlanilha,cTitulo)
    oExcel:AddColumn(cPlanilha,cTitulo,"Data Entrega "          ,1,1) // 01 A
    oExcel:AddColumn(cPlanilha,cTitulo,"Roteiro "               ,1,1) // 02 B
    oExcel:AddColumn(cPlanilha,cTitulo,"Carga Edata  "          ,1,1) // 03 C
  	oExcel:AddColumn(cPlanilha,cTitulo,"Carga Protheus Antes "  ,1,1) // 04 D
	oExcel:AddColumn(cPlanilha,cTitulo,"Carga Protheus Depois " ,1,1) // 05 E
	oExcel:AddColumn(cPlanilha,cTitulo,"Num Pedido "            ,1,1) // 06 F
	
RETURN(NIL)