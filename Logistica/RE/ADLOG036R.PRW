#INCLUDE "PROTHEUS.CH"  
#INCLUDE "FILEIO.CH"
#INCLUDE "TopConn.CH"  
#INCLUDE "rwmake.ch" 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ADLOG036R ºAutor  ³William COSTA       º Data ³  30/04/2018 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ RELATORIO LOGISTICA - TRAZER FRETES QUE ESTAO NO PEDIDO DE º±±
±±º          ³ VENDA E NAO ESTAO NO CONTROLE DE FRETES SC5 x SZK          º±±
±±º          ³ OBJETIVO - MOSTRAR SE ALGUMA VIAGEM NAO ESTA CADASTRADA SZKº±±
±±º          ³ Relatorio em Excel.                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAlteracao ³ 10/01/2019 - William - chamado 046345 - Adicionado regra   º±±
±±º          ³ para verificar as placas de pagamento entre SZK X SF2      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAlteracao ³ 31/01/2019 - William - chamado 046814 - Adicionado regra   º±±
±±º          ³ para verificar se o Roteiro e Data de entrega que esta na  º±±
±±º          ³ SZK tambem esta na SC5                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAFAT                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
 
User Function ADLOG036R()
	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'RELATORIO LOGISTICA - TRAZER FRETES QUE ESTAO NO PEDIDO DE VENDA E NAO ESTAO NO CONTROLE DE FRETES SC5 x SZK OBJETIVO - MOSTRAR SE ALGUMA VIAGEM NAO ESTA CADASTRADA SZK Relatorio em Excel')
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Private aSays		:= {}
	Private aButtons	:= {}   
	Private cCadastro	:= "Relatorio de Controle de Fretes nao Cadastrados"    
	PRIVATE oFontA06	:= TFont():New( "Arial",,10,,.f.,,,,,.f. )
	PRIVATE oFontA09	:= TFont():New( "Arial",,-9,,.f.,,,,,.f. )
	PRIVATE oFontA09b	:= TFont():New( "Arial",,-9,,.t.,,,,,.f. )
	PRIVATE oFontA07	:= TFont():New( "Arial",,12,,.T.,,,,,.f. )
	PRIVATE oPrn		:= TMSPrinter():New()
	Private nOpca		:= 0
	Private cPerg		:= 'ADLOG036R'
	//+------------------------------------------------+
	//|Cria grupo de Perguntas                         |
	//+------------------------------------------------+
	 MontaPerg()
	 
	 //+-----------------------------------------------+
	//|Monta Form Batch - Interface com o Usuario     |
	//+-----------------------------------------------+
	AADD(aSays,"Este Relatorio de Controle de Fretes nao Cadastrados " )
	AADD(aSays,"Programa de Controle de Fretes nao Cadastrados" )
    
	AADD(aButtons, { 5,.T.,{|o| Pergunte(cPerg,.T.) }})
	AADD(aButtons, { 1,.T.,{|o| nOpca:=1, o:oWnd:End(), Processa({||GERA_ADLOG036R()},"Gerando arquivo","Aguarde...")    }})
	AADD(aButtons, { 2,.T.,{|o| nOpca:=2, o:oWnd:End() }})
	
	FormBatch( cCadastro, aSays, aButtons )  
	
Return (Nil)  

Static Function GERA_ADLOG036R() 
   
	Public oExcel      := FWMSEXCEL():New()
	Public cPath       := 'D:\Totvs\Protheus12\protheus_data\system\'
	Public cArquivo    := 'Controle_de_Fretes_nao_Cadastrados.XML'
	Public oMsExcel    := NIL
	Public cPlanilha   := 'Controle de Fretes'
    Public cTitulo     := 'Controle de Fretes'
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
						   ""  ; // 04 D
						       })
			//===================== FINAL CRIA VETOR COM POSICAO VAZIA
			
			//======================================= INICIO ADICIONANDO OS CAMPOS NAS LINHAS ===================
		    aLinhas[nLinha][01] := TRB->C5_FILIAL     //A
			aLinhas[nLinha][02] := TRB->C5_DTENTR     //B
			aLinhas[nLinha][03] := TRB->C5_ROTEIRO    //C
			aLinhas[nLinha][04] := 'Roteiro Faltante' //D
			
            //======================================= FINAL ADICIONANDO OS CAMPOS NAS LINHAS ===================			
			
			TRB->(dbSkip())    
		
		END //end do while TRB
	TRB->( DBCLOSEAREA() )
		
	// *** INICIO 10/01/2019 CHAMADO 046345 || OS 047570 || ADM.LOG || BRUNA || 8446 || REGISTRO DE FRETE *** //	
	SqlControleFrete()
	DBSELECTAREA("TRC")
	TRC->(DBGOTOP())
		
		WHILE TRC->(!EOF()) 
		
			SqlNotas(TRC->ZK_DTENTR,TRC->ZK_ROTEIRO)
			WHILE TRD->(!EOF())
			
				IF TRC->ZK_PLACAPG <> TRD->F2_PLACA
			
					nLinha  := nLinha + 1                                       
		
		            //===================== INICIO CRIA VETOR COM POSICAO VAZIA 
				   	AADD(aLinhas,{ "", ; // 01 A
								   "", ; // 02 B
								   "", ; // 03 C
								   ""  ; // 04 D
								       })
					//===================== FINAL CRIA VETOR COM POSICAO VAZIA
					
					//======================================= INICIO ADICIONANDO OS CAMPOS NAS LINHAS ===================
				    aLinhas[nLinha][01] := TRD->C5_FILIAL     																												  //A
					aLinhas[nLinha][02] := TRD->C5_DTENTR     																												  //B
					aLinhas[nLinha][03] := TRD->C5_ROTEIRO    																												  //C
					aLinhas[nLinha][04] := 'Placa Pagto Errada ' + 'Placa Controle de Frete: ' +  TRC->ZK_PLACAPG + ' Placa da Nota: ' + TRD->F2_PLACA + ' favor corrigir!!!' //D
					
		            //======================================= FINAL ADICIONANDO OS CAMPOS NAS LINHAS ===================
		            
		        ENDIF    			
				TRD->(dbSkip())    
			
			ENDDO //end do while TRB
			TRD->( DBCLOSEAREA() )
			
			TRC->(dbSkip())    
		
		ENDDO //end do while TRB
	TRC->( DBCLOSEAREA() )
	// *** FINAL 10/01/2019 CHAMADO 046345 || OS 047570 || ADM.LOG || BRUNA || 8446 || REGISTRO DE FRETE *** //
	
	// *** INICIO 30/01/2019 CHAMADO 046814 || OS 048053 || ADM.LOG || BRUNA || 8446 || CONTROLE DE FRETE VERIFICA SE TODOS OS ROTEIROS TEM NOS PEDIDOS  *** //
	
	SqlPedido()
	
	WHILE TRE->(!EOF()) 
	
		nLinha  := nLinha + 1                                       

        //===================== INICIO CRIA VETOR COM POSICAO VAZIA 
	   	AADD(aLinhas,{ "", ; // 01 A
					   "", ; // 02 B
					   "", ; // 03 C
					   ""  ; // 04 D
					       })
		//===================== FINAL CRIA VETOR COM POSICAO VAZIA
		
		//======================================= INICIO ADICIONANDO OS CAMPOS NAS LINHAS ===================
	    aLinhas[nLinha][01] := TRE->ZK_FILIAL           //A
		aLinhas[nLinha][02] := TRE->ZK_DTENTR           //B
		aLinhas[nLinha][03] := TRE->ZK_ROTEIRO          //C
		aLinhas[nLinha][04] := 'Roteiro não tem pedido' //D
		
        //======================================= FINAL ADICIONANDO OS CAMPOS NAS LINHAS ===================			
		
		TRE->(dbSkip())    
	
	END //end do while TRE
	TRE->( DBCLOSEAREA() )
	
	// *** FINAL 30/01/2019 CHAMADO 046814 || OS 048053 || ADM.LOG || BRUNA || 8446 || CONTROLE DE FRETE VERIFICA SE TODOS OS ROTEIROS TEM NOS PEDIDOS    *** //
	
	//============================== INICIO IMPRIME LINHA NO EXCEL
	FOR nExcel := 1 TO nLinha
   		oExcel:AddRow(cPlanilha,cTitulo,{aLinhas[nExcel][01],; // 01 A 
										 aLinhas[nExcel][02],; // 02 B 
										 aLinhas[nExcel][03],; // 03 C 
										 aLinhas[nExcel][04] ; // 04 D
                                                              }) //GRAVANDO NA LINHA MANDANDO PARA O EXCEL O ARRAY COM AS LINHAS				
    NEXT 
    //============================== FINAL IMPRIME LINHA NO EXCEL
    
Return()

Static Function SalvaXml()

	oExcel:Activate()
	oExcel:GetXMLFile("C:\temp\Controle_de_Fretes_nao_Cadastrados.XML")

Return()

Static Function CriaExcel()              

    oMsExcel := MsExcel():New()
	oMsExcel:WorkBooks:Open("C:\temp\Controle_de_Fretes_nao_Cadastrados.XML")
	oMsExcel:SetVisible( .T. )
	oMsExcel := oMsExcel:Destroy()

Return()       

Static Function MontaPerg()
                                  
	Private bValid	:= Nil 
	Private cF3		:= Nil
	Private cSXG	:= Nil
	Private cPyme	:= Nil
	
    u_xPutSx1(cPerg,'01','Data Entrega De   ?','','','mv_ch1','D',08,0,0,'G',bValid,cF3,cSXG,cPyme,'MV_PAR01')
	u_xPutSx1(cPerg,'02','Data Entrega Ate ?' ,'','','mv_ch2','D',08,0,0,'G',bValid,cF3,cSXG,cPyme,'MV_PAR02')
	u_xPutSx1(cPerg,'03','Roteiro De   ?'     ,'','','mv_ch1','C',03,0,0,'G',bValid,cF3,cSXG,cPyme,'MV_PAR03')
	u_xPutSx1(cPerg,'04','Roteiro Ate ?'      ,'','','mv_ch2','C',03,0,0,'G',bValid,cF3,cSXG,cPyme,'MV_PAR04')
	
	Pergunte(cPerg,.F.)
	
Return(Nil)            
                                
Static Function Cabec() 

    oExcel:AddworkSheet(cPlanilha)
	oExcel:AddTable (cPlanilha,cTitulo)
    oExcel:AddColumn(cPlanilha,cTitulo,"Filial "       ,1,1) // 01 A
    oExcel:AddColumn(cPlanilha,cTitulo,"Data Entrega " ,1,1) // 02 B
    oExcel:AddColumn(cPlanilha,cTitulo,"Roteiro "      ,1,1) // 03 C
    oExcel:AddColumn(cPlanilha,cTitulo,"Erro "         ,1,1) // 04 D
	
RETURN(NIL)    

Static Function SqlGeral()

    Local cFil     := FWFILIAL('SC5')
    Local cDataIni := DTOS(MV_PAR01)
    Local cDataFin := DTOS(MV_PAR02)
    
    BeginSQL Alias "TRB"
			%NoPARSER% 
			 SELECT C5_FILIAL,C5_DTENTR,C5_ROTEIRO 
			   FROM %TABLE:SC5% WITH(NOLOCK)
		      WHERE C5_FILIAL               = %EXP:cFil%
		        AND C5_DTENTR              >= %EXP:cDataIni%
			    AND C5_DTENTR              <= %EXP:cDataFin%
				AND C5_ROTEIRO             >= %EXP:MV_PAR03%
				AND C5_ROTEIRO             <= %EXP:MV_PAR04%
				AND C5_NOTA                <> ''
				AND C5_PLACA               <> ''
				AND %TABLE:SC5%.D_E_L_E_T_      <> '*'
				AND (C5_DTENTR+C5_ROTEIRO) NOT IN(SELECT (ZK_DTENTR+ZK_ROTEIRO) FROM %TABLE:SZK% WITH(NOLOCK) WHERE %TABLE:SZK%.D_E_L_E_T_ <> '*')
		
		GROUP BY C5_FILIAL,C5_DTENTR,C5_ROTEIRO
		
		ORDER BY C5_FILIAL,C5_DTENTR,C5_ROTEIRO		  
    EndSQl
   
RETURN()

Static Function SqlControleFrete()

    Local cFilAtual := FWFILIAL('SZK')
    Local cDataIni  := DTOS(MV_PAR01)
    Local cDataFin  := DTOS(MV_PAR02)
    
    BeginSQL Alias "TRC"
			%NoPARSER% 
			SELECT ZK_DTENTR,ZK_ROTEIRO,ZK_PLACAPG, R_E_C_N_O_ 
			  FROM %TABLE:SZK% WITH(NOLOCK)
			  WHERE ZK_FILIAL   = %EXP:cFilAtual%
			    AND ZK_DTENTR  >= %EXP:cDataIni%
				AND ZK_DTENTR  <= %EXP:cDataFin%
				AND ZK_ROTEIRO >= %EXP:MV_PAR03%
				AND ZK_ROTEIRO <= %EXP:MV_PAR04%
				AND D_E_L_E_T_ <> '*'
				
				ORDER BY ZK_DTENTR,ZK_ROTEIRO
						  
    EndSQl
   
RETURN()

Static Function SqlNotas(cData,cRoteiro)

    Local cFilAtual := FWFILIAL('SC5')
    
    BeginSQL Alias "TRD"
			%NoPARSER%
			  SELECT TOP(1) SF2.F2_PLACA,SF2.F2_DOC,SC5.C5_NOTA,SC5.C5_ROTEIRO,SC5.C5_DTENTR,F2_ROTEIRO,SC5.C5_FILIAL
				FROM %TABLE:SC5% SC5 WITH(NOLOCK), %TABLE:SF2% SF2 WITH(NOLOCK)
				WHERE SC5.C5_FILIAL   = %EXP:cFilAtual%
				  AND SC5.C5_DTENTR   = %EXP:cData%
				  AND SC5.C5_ROTEIRO  = %EXP:cRoteiro%
				  AND SC5.D_E_L_E_T_ <> '*'
				  AND SC5.C5_FILIAL   = SF2.F2_FILIAL
				  AND SC5.C5_NOTA     = SF2.F2_DOC
				  AND SC5.C5_SERIE    = SF2.F2_SERIE
				  AND SC5.C5_CLIENT   = SF2.F2_CLIENT
				  AND SC5.C5_LOJACLI  = SF2.F2_LOJA
				  AND SF2.F2_PLACA   <> ''   
				  AND SF2.D_E_L_E_T_ <> '*'
										  
    EndSQl
   
RETURN()  

Static Function SqlPedido()

    Local cFilatual := FWFILIAL('SC5')
    Local cDataIni  := DTOS(MV_PAR01)
    Local cDataFin  := DTOS(MV_PAR02)
    
    BeginSQL Alias "TRE"
			%NoPARSER% 
			SELECT ZK_FILIAL,ZK_DTENTR,ZK_ROTEIRO
			  FROM %TABLE:SZK%  WITH(NOLOCK)
			  WHERE ZK_DTENTR  >= %EXP:cDataIni%
			    AND ZK_DTENTR  <= %EXP:cDataFin%
			    AND ZK_ROTEIRO >= %EXP:MV_PAR03%
			    AND ZK_ROTEIRO <= %EXP:MV_PAR04%
				AND %TABLE:SZK%.D_E_L_E_T_ <> '*'
				AND ZK_DTENTR+ZK_ROTEIRO NOT IN (SELECT (C5_DTENTR+C5_ROTEIRO) FROM %TABLE:SC5% WITH(NOLOCK) WHERE C5_FILIAL = %EXP:cFilatual% AND C5_DTENTR = ZK_DTENTR AND C5_ROTEIRO = ZK_ROTEIRO AND %TABLE:SC5%.D_E_L_E_T_ <> '*')
			
				GROUP BY ZK_FILIAL,ZK_DTENTR,ZK_ROTEIRO
				ORDER BY ZK_FILIAL,ZK_DTENTR,ZK_ROTEIRO
		  
    EndSQl
   
RETURN()      