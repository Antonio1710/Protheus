#INCLUDE "PROTHEUS.CH"  
#INCLUDE "FILEIO.CH"
#INCLUDE "TopConn.CH"  
#INCLUDE "rwmake.ch"
#INCLUDE 'Totvs.ch'

/*/{Protheus.doc} User Function ADGPE043R
	Relatorio para fechamento de tempo de permanencia da portaria para controlar entrada e Saida Relatorio em Excel. 
	EQUIPAMENTOS: 4 - Catraca Portaria 5 - Cancela Entrada 6 - Cancela Saída
    @author William
    @since 06/02/2019
	@version 01
	@history chamado 053011 - William Costa - 01/11/2019 - Adicionado o Equipamento Restaurante 1 e Restaurante 2
	@history TICKET  224    - William Costa - 11/11/2020 - Alteração do Fonte na parte de Funcionários, trocar a integração do Protheus para a Integração do RM
    @history ticket  14365  - Fernando Macieir- 19/05/2021 - Novo Linked Server (de VPSRV17 para DIMEP)
/*/

User Function ADGPE043R()
	
	PRIVATE aSays		:={}
	PRIVATE aButtons	:={}   
	PRIVATE cCadastro	:= "Relatorio Fechamento Portaria Dimep"    
	PRIVATE nOpca		:= 0
	PRIVATE cPerg		:= 'ADGPE043R'

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Relatorio para fechamento de tempo de permanencia da portaria para controlar entrada e Saida Relatorio em Excel. ')
	
	MontaPerg()
	 
	AADD(aSays,"Este programa tem a finalidade de Gerar um arquivo Excel " )
	AADD(aSays,"Relatorio Fechamento Portaria Dimep" )
    
	AADD(aButtons, { 5,.T.,{|o| Pergunte(cPerg,.T.) }})
	AADD(aButtons, { 1,.T.,{|o| nOpca:=1, o:oWnd:End(), Processa({||GPE043R()},"Gerando arquivo","Aguarde...")    }})
	AADD(aButtons, { 2,.T.,{|o| nOpca:=2, o:oWnd:End() }})
	
	FormBatch( cCadastro, aSays, aButtons )  
	
Return (Nil)  

Static Function GPE043R()    

	PRIVATE oExcel     := FWMsExcel():New() //FWMSEXCEL():New()
	PRIVATE oMsExcel
	PRIVATE cPlanilha  := DTOC(MV_PAR01) + ' ate ' + DTOC(MV_PAR02)
	PRIVATE cTitulo    := "Relatorio Fechamento - " + DTOC(MV_PAR01) + ' ate ' + DTOC(MV_PAR02)
	PRIVATE aLinhas    := {}
    PRIVATE aLin2      := {}
    PRIVATE nLin2      := 0
    Private nExcel2    := 0
    PRIVATE cPlan2     := "Entrada X Saida 2" 
    Private cTit2      := "Entrada X Saida 2"
    PRIVATE aLin3      := {}
    PRIVATE nLin3      := 0
    Private nExcel3    := 0
    PRIVATE cPlan3     := "Entrada X Saida 3" 
    Private cTit3      := "Entrada X Saida 3"
    PRIVATE aLin4      := {}
    PRIVATE nLin4      := 0
    Private nExcel4    := 0
    PRIVATE cPlan4     := "Entrada X Saida 4" 
    Private cTit4      := "Entrada X Saida 4"
    Private lRet       := .T.
   
	BEGIN SEQUENCE
		
		IF .NOT.( ApOleClient("MsExcel") )   // se nao existir o excel sai fora..
		    Alert("Não Existe Excel Instalado")
            BREAK
        EndIF
		
		Cabec()             
		GeraExcel()
		
		IF lRet == .T.
	          
			SalvaXml()
			CriaExcel()
			
		    MsgInfo("Arquivo Excel gerado!")
	        
	    ENDIF
	    
	END SEQUENCE

Return(NIL) 

Static Function GeraExcel()

	Local   nTotReg       := 0
    Private nLinha        := 0
	Private nExcel        := 0
	Private oTempTable    := NIL
	Private aCampos       := {}
	Private cEquip        := ''
	Private cCredencial   := ''
	
	// *** INICIO CRIA TABELA TEMPORARIA *** //
	
	oTempTable := FWTemporaryTable():New("TRD")
	
	// INICIO Monta os campos da tabela
	
	aadd(aCampos,{"LOG_ACESSO" ,"N",20,0})
	aadd(aCampos,{"TP_CRED"    ,"N",03,0})
	aadd(aCampos,{"DESC_CRED"  ,"C",50,0})
	aadd(aCampos,{"CD_EQUIP"   ,"N",06,0})
	aadd(aCampos,{"DS_EQUIP"   ,"C",50,0})
	aadd(aCampos,{"SENTIDO"    ,"C",07,0})
	aadd(aCampos,{"CONTAGEM"   ,"N",17,0})
    
    // FINAL Monta os campos da tabela
    
	oTemptable:SetFields(aCampos)
	oTempTable:AddIndex("01", {"LOG_ACESSO"} )
	
	//------------------
	//Criação da tabela
	//------------------
	oTempTable:Create()
	
	// *** FINAL CRIA TABELA TEMPORARIA *** //
	cEquip := ''
	
	IF MV_PAR03 == 1 //Catraca 4
	
		cEquip := IIF(ALLTRIM(cEquip) == '','4',cEquip+',4')
	
	ENDIF
	
	IF MV_PAR04 == 1 //Cancela Entrada 5
	
		cEquip := IIF(ALLTRIM(cEquip) == '','5',cEquip+',5')
	
	ENDIF
	
	IF MV_PAR05 == 1 //Cancela Saida 6
	
		cEquip := IIF(ALLTRIM(cEquip) == '','6',cEquip+',6')
	
	ENDIF

	IF MV_PAR06 == 1 //Refeitorio 1
	
		cEquip := IIF(ALLTRIM(cEquip) == '','1',cEquip+',1')
		
	ENDIF

	IF MV_PAR07 == 1 //Refeitorio 2
	
		cEquip := IIF(ALLTRIM(cEquip) == '','2',cEquip+',2')
		
	ENDIF

	IF MV_PAR08 == 1 //Balança Entrada Várzea
	
		cEquip := IIF(ALLTRIM(cEquip) == '','20',cEquip+',20')
		
	ENDIF

	IF MV_PAR09 == 1 //Balança Saída Várzea
	
		cEquip := IIF(ALLTRIM(cEquip) == '','21',cEquip+',21')
		
	ENDIF

	IF MV_PAR10 == 1 //Sala Motoristas
	
		cEquip := IIF(ALLTRIM(cEquip) == '','3',cEquip+',3')
		
	ENDIF

	IF MV_PAR11 == 1 //Portão Manutenção
	
		cEquip := IIF(ALLTRIM(cEquip) == '','17',cEquip+',17')
		
	ENDIF

	IF MV_PAR12 == 1 //Entrada Gerencia Industrial
	
		cEquip := IIF(ALLTRIM(cEquip) == '','13',cEquip+',13')
		
	ENDIF

	IF MV_PAR13 == 1 //Saída Gerencia Industrial
	
		cEquip := IIF(ALLTRIM(cEquip) == '','14',cEquip+',14')
		
	ENDIF

	IF MV_PAR14 == 1 //Entrada Prédio ADM
	
		cEquip := IIF(ALLTRIM(cEquip) == '','15',cEquip+',15')
		
	ENDIF

	IF MV_PAR15 == 1 //Saída Prédio ADM
	
		cEquip := IIF(ALLTRIM(cEquip) == '','16',cEquip+',16')
		
	ENDIF

	IF MV_PAR16 == 1 //Terceiros Manutenção
	
		cEquip := IIF(ALLTRIM(cEquip) == '','19',cEquip+',19')
		
	ENDIF
	
	IF (MV_PAR03 == 2 .AND. ;
	    MV_PAR04 == 2 .AND. ;
		MV_PAR05 == 2 .AND. ;
		MV_PAR06 == 2 .AND. ;
		MV_PAR07 == 2 .AND. ;
		MV_PAR08 == 2 .AND. ;
		MV_PAR09 == 2 .AND. ;
		MV_PAR10 == 2 .AND. ;
		MV_PAR11 == 2 .AND. ;
		MV_PAR12 == 2 .AND. ;
		MV_PAR13 == 2 .AND. ;
		MV_PAR14 == 2 .AND. ;
		MV_PAR15 == 2 .AND. ;
		MV_PAR16 == 2) .OR. ;
		ALLTRIM(cEquip) == '' 
	
		MsgStop("OLÁ " + Alltrim(cUserName) + ", Não é Permitido que todos os equipamentos estejam marcados como não, é preciso que pelo menos um equipamento esteja marcado com sim para continuar, favor verificar !!!", "ADGPE043R-01")
		lRet := .F.
		Return(lRet)
		
	ENDIF
	
	u_GrLogZBE (Date(),TIME(),cUserName," Relatorio de Fechamento Acessos","PORTARIA/DIMEP","ADGPE043R",;
				"Gerou o Relatorio",ComputerName(),LogUserName())
	
	SqlGeral(cEquip)
	
	//Conta o Total de registros.
	nTotReg := Contar("TRC","!Eof()") * 2
	
	//Valida a quantidade de registros.
	If nTotReg <= 0
		MsgStop("Não há registros para os parâmetros informados.","Função GeraExcel(ADGPE043R)")
		Return .F.
		
	EndIf
	
	//Atribui a quantidade de registros à régua de processamento.
	ProcRegua(nTotReg) 
	
	DBSELECTAREA("TRC")
	TRC->(DBGOTOP())
	WHILE TRC->(!EOF()) 
	
		nLinha  := nLinha + 1   
		
		IncProc("Gerando Planilha 1 " + DTOC(STOD(CVALTOCHAR(TRC->NU_DATA_REQUISICAO))) + '-' + TRC->NM_PESSOA)                                    

        //===================== INICIO CRIA VETOR COM POSICAO VAZIA 
	   	AADD(aLinhas,{ "", ; // 01 A  
	   	               "", ; // 02 B   
	   	               "", ; // 03 C   
	   	               "", ; // 04 D  
	   	               "", ; // 05 E  
	   	               "", ; // 06 F  
	   	               "", ; // 07 G  
	   	               "", ; // 08 H  
	   	               "", ; // 09 I
	   	               "", ; // 10 J
	   	               "", ; // 11 K
					   "", ; // 12 L
					   ""  ; // 13 M
	   	                   })
		//===================== FINAL CRIA VETOR COM POSICAO VAZIA
		
		//======================================= INICIO ADICIONANDO OS CAMPOS NAS LINHAS ===================
		
		aLinhas[nLinha][01] := TRC->NU_CREDENCIAL                                                                                      //A
		aLinhas[nLinha][02] := IIF(TRC->NU_MATRICULA == 0 .AND. TRC->CD_VISITANTE > 0,TRC->NU_DOCUMENTO,TRC->NU_MATRICULA)             //B
		aLinhas[nLinha][03] := TRC->NM_PESSOA                                                                                          //C
		aLinhas[nLinha][04] := STOD(CVALTOCHAR(TRC->NU_DATA_REQUISICAO))                                                               //D
		aLinhas[nLinha][05] := SUBSTR(STRZERO(TRC->NU_HORA_REQUISICAO,4),1,2) + ':' +  SUBSTR(STRZERO(TRC->NU_HORA_REQUISICAO,4),3,2) //E
		aLinhas[nLinha][06] := TRC->NM_ESTRUTURA                                                                                       //F
		aLinhas[nLinha][07] := TRC->CD_EQUIPAMENTO                                                                                     //G
		aLinhas[nLinha][08] := TRC->DS_EQUIPAMENTO                                                                                     //H
		aLinhas[nLinha][09] := TRC->TP_EVENTO                                                                                          //I
		aLinhas[nLinha][10] := TRC->TP_SENTIDO_CONSULTA                                                                                //J
		aLinhas[nLinha][11] := TRC->CD_TIPO_CREDENCIAL                                                                                 //K
		aLinhas[nLinha][12] := TRC->DS_TIPO_CREDENCIAL                                                                                 //L

		IF TRC->CD_TIPO_CREDENCIAL == 2 // VISITANTE 

			SqlCredencial(CVALTOCHAR(TRC->NU_CREDENCIAL))
			DBSELECTAREA("TRK")
			TRK->(DBGOTOP())
			WHILE TRK->(!EOF())

				cCredencial := CVALTOCHAR(TRK->CD_CREDENCIAL)

				IF ALLTRIM(cCredencial) <> ''

					SqlVisita(CVALTOCHAR(TRC->CD_VISITANTE),CVALTOCHAR(TRC->NU_DATA_REQUISICAO),cCredencial)
					DBSELECTAREA("TRL")
					TRL->(DBGOTOP())
					WHILE TRL->(!EOF())

						aLinhas[nLinha][13] := TRL->NM_CONTATO                                                                                 			   //M

						TRL->(dbSkip())    
			
					ENDDO //end do while TRL
					TRL->( DBCLOSEAREA() )

					IF ALLTRIM(aLinhas[nLinha][13]) == '' // se estiver vazio significa que o codigo da credencial não é igual da época

						SqlVis2(CVALTOCHAR(TRC->CD_VISITANTE),CVALTOCHAR(TRC->NU_DATA_REQUISICAO))
						DBSELECTAREA("TRM")
						TRM->(DBGOTOP())
						WHILE TRM->(!EOF())

							aLinhas[nLinha][13] := TRM->NM_CONTATO                                                                                 			   //M

							TRM->(dbSkip())    
				
						ENDDO //end do while TRL
						TRM->( DBCLOSEAREA() )

					ENDIF	

				ENDIF
				TRK->(dbSkip())    
		
			ENDDO //end do while TRK
			TRK->( DBCLOSEAREA() )

		ELSE

			aLinhas[nLinha][13] := ""                                                                                 			       //M
		
		ENDIF
		
		//======================================= FINAL ADICIONANDO OS CAMPOS NAS LINHAS ===================			
			
		// *** INICIO CARREGAR TABELA TEMPORARIA ***
		
		Reclock("TRD",.T.)
				    
	    	TRD->LOG_ACESSO := TRC->CD_LOG_ACESSO
	    	TRD->TP_CRED    := TRC->CD_TIPO_CREDENCIAL
	    	TRD->DESC_CRED  := TRC->DS_TIPO_CREDENCIAL
	    	TRD->CD_EQUIP   := TRC->CD_EQUIPAMENTO
	    	TRD->DS_EQUIP   := TRC->DS_EQUIPAMENTO
	    	TRD->SENTIDO    := TRC->TP_SENTIDO_CONSULTA
	    	TRD->CONTAGEM   := 1
	    	
	    TRD->(MSUNLOCK())
		
		// *** FINAL CARREGAR TABELA TEMPORARIA ***	
				
		TRC->(dbSkip())    
	
	ENDDO //end do while TRB
	TRC->( DBCLOSEAREA() )
			
	//============================== INICIO IMPRIME LINHA NO EXCEL
	FOR nExcel := 1 TO nLinha
	
		IncProc("Carregando Planilha 1 " + CVALTOCHAR(nExcel) + '/' + CVALTOCHAR(nLinha))
   		oExcel:AddRow(cPlanilha,cTitulo,{aLinhas[nExcel][01],; // 01 A  
        	                             aLinhas[nExcel][02],; // 02 B  
        	                             aLinhas[nExcel][03],; // 03 C  
   	        	                         aLinhas[nExcel][04],; // 04 D  
   	            	                     aLinhas[nExcel][05],; // 05 E  
   	                	                 aLinhas[nExcel][06],; // 06 F  
   	                	                 aLinhas[nExcel][07],; // 07 G  
   	                	                 aLinhas[nExcel][08],; // 08 H
   	                	                 aLinhas[nExcel][09],; // 09 I
   	                	                 aLinhas[nExcel][10],; // 10 J
   	                	                 aLinhas[nExcel][11],; // 11 K
										 aLinhas[nExcel][12],; // 12 L
										 aLinhas[nExcel][13] ; // 13 M
   	                	                                      }) //GRAVANDO NA LINHA MANDANDO PARA O EXCEL O ARRAY COM AS LINHAS				
   NEXT 
   //============================== FINAL IMPRIME LINHA NO EXCEL
   
   // *** INICIO PLANILHA 2
    
    nLin2 := 0
    SqlPlan2X()
    DBSELECTAREA("TRE")
	TRE->(DBGOTOP())
	WHILE TRE->(!EOF()) 
	
		nLin2  := nLin2 + 1
		   
		//===================== INICIO CRIA VETOR COM POSICAO VAZIA 
	   	AADD(aLin2,{ "", ; // 01 A  
	   	              0, ; // 02 B   
	   	              0, ; // 03 C   
	   	              0, ; // 04 D  
	   	              0, ; // 05 E  
	   	              0  ; // 06 F
	   	                   })
		//===================== FINAL CRIA VETOR COM POSICAO VAZIA
		
		//======================================= INICIO ADICIONANDO OS CAMPOS NAS LINHAS ===================
		
		IncProc("Gerando Planilha 2 " + TRE->DESC_CRED)
		
		aLin2[nLin2][01] := ALLTRIM(TRE->DESC_CRED) //A
		aLin2[nLin2][02] := TRE->TOTAL              //2
		
		SqlPlan2Y(TRE->TP_CRED)
		DBSELECTAREA("TRF")
		TRF->(DBGOTOP())
		WHILE TRF->(!EOF()) 
		
			aLin2[nLin2][03] := IIF(TRF->CD_EQUIP == 5, aLin2[nLin2][03]+ TRF->CONTAGEM,aLin2[nLin2][03])                                           //C
			aLin2[nLin2][04] := IIF(TRF->CD_EQUIP == 4 .AND. ALLTRIM(TRF->SENTIDO) == 'ENTRADA', aLin2[nLin2][04] + TRF->CONTAGEM,aLin2[nLin2][04]) //D
			aLin2[nLin2][05] := IIF(TRF->CD_EQUIP == 6,aLin2[nLin2][05] + TRF->CONTAGEM,aLin2[nLin2][05])                                           //E
			aLin2[nLin2][06] := IIF(TRF->CD_EQUIP == 4 .AND. ALLTRIM(TRF->SENTIDO) == 'SAIDA', aLin2[nLin2][06] + TRF->CONTAGEM,aLin2[nLin2][06])   //F
			
			TRF->(dbSkip())    
		
		ENDDO //end do while TRE
		TRF->( DBCLOSEAREA() )
		
		//======================================= FINAL ADICIONANDO OS CAMPOS NAS LINHAS ===================			
    
		TRE->(dbSkip())    
    
	ENDDO //end do while TRE
	TRE->( DBCLOSEAREA() )
	
	//============================== INICIO IMPRIME LINHA NO EXCEL
	FOR nExcel2 := 1 TO nLin2
	
		IncProc("Carregando Planilha 2 " + CVALTOCHAR(nExcel2) + '/' + CVALTOCHAR(nLin2))
   		oExcel:AddRow(cPlan2,cTit2,{aLin2[nExcel2][01],; // 01 A  
        	                        aLin2[nExcel2][02],; // 02 B  
        	                        aLin2[nExcel2][03],; // 03 C  
   	        	                    aLin2[nExcel2][04],; // 04 D  
   	            	                aLin2[nExcel2][05],; // 05 E  
   	            	                aLin2[nExcel2][06] ; // 06 F
   	                	                              }) //GRAVANDO NA LINHA MANDANDO PARA O EXCEL O ARRAY COM AS LINHAS				
   NEXT 
   //============================== FINAL IMPRIME LINHA NO EXCEL
   
   // *** FINAL PLANILHA 2
   
   // *** INICIO PLANILHA 3
    
   nLin3 := 0
   SqlPlan3X()
   DBSELECTAREA("TRG")
   TRG->(DBGOTOP())
   WHILE TRG->(!EOF()) 
	
		nLin3  := nLin3 + 1
		   
		//===================== INICIO CRIA VETOR COM POSICAO VAZIA 
	   	AADD(aLin3,{ "", ; // 01 A  
	   	              0, ; // 02 B   
	   	              0, ; // 03 C   
	   	              0, ; // 04 D  
	   	              0, ; // 05 E  
	   	              0, ; // 06 F   
	   	              0, ; // 07 G   
	   	              0, ; // 08 H  
	   	              0, ; // 09 I
	   	              0  ; // 10 J
	   	                   })
		//===================== FINAL CRIA VETOR COM POSICAO VAZIA
		
		//======================================= INICIO ADICIONANDO OS CAMPOS NAS LINHAS ===================
		
		IncProc("Gerando Planilha 3 " + TRG->DESC_CRED)
		
		aLin3[nLin3][01] := ALLTRIM(TRG->DESC_CRED) //A
		aLin3[nLin3][02] := TRG->TOTAL              //B
		
		SqlPlan3Y(TRG->TP_CRED)
	    DBSELECTAREA("TRH")
		TRH->(DBGOTOP())
		WHILE TRH->(!EOF()) 
			
			aLin3[nLin3][03] := IIF(TRH->CD_EQUIP == 5, aLin3[nLin3][03]+ TRH->CONTAGEM,aLin3[nLin3][03])                                          //C
			aLin3[nLin3][04] := IIF(TRH->CD_EQUIP == 4 .AND. ALLTRIM(TRH->SENTIDO) == 'ENTRADA', aLin3[nLin3][04] + TRH->CONTAGEM,aLin3[nLin3][04]) //D
			aLin3[nLin3][05] := IIF(TRH->CD_EQUIP == 20 .AND. ALLTRIM(TRH->SENTIDO) == 'ENTRADA', aLin3[nLin3][05] + TRH->CONTAGEM,aLin3[nLin3][05]) //E
			aLin3[nLin3][06] := 0
			aLin3[nLin3][07] := IIF(TRH->CD_EQUIP == 6,aLin3[nLin3][07] + TRH->CONTAGEM,aLin3[nLin3][07])                                           //F
			aLin3[nLin3][08] := IIF(TRH->CD_EQUIP == 4 .AND. ALLTRIM(TRH->SENTIDO) == 'SAIDA', aLin3[nLin3][08] + TRH->CONTAGEM,aLin3[nLin3][08])   //G
			aLin3[nLin3][09] := IIF(TRH->CD_EQUIP == 21 .AND. ALLTRIM(TRH->SENTIDO) == 'SAIDA', aLin3[nLin3][09] + TRH->CONTAGEM,aLin3[nLin3][09]) //H
			aLin3[nLin3][10] := 0
			
			TRH->(dbSkip())    
		
		ENDDO //end do while TRE
		TRH->( DBCLOSEAREA() )
		
		//======================================= FINAL ADICIONANDO OS CAMPOS NAS LINHAS ===================			
    
		TRG->(dbSkip())    
	
	ENDDO //end do while TRG
	TRG->( DBCLOSEAREA() )
	
	//============================== INICIO IMPRIME LINHA NO EXCEL
	FOR nExcel3 := 1 TO nLin3
	
		IncProc("Carregando Planilha 3 " + CVALTOCHAR(nExcel3) + '/' + CVALTOCHAR(nLin3))
   		oExcel:AddRow(cPlan3,cTit3,{aLin3[nExcel3][01],; // 01 A  
        	                        aLin3[nExcel3][02],; // 02 B  
        	                        aLin3[nExcel3][03],; // 03 C  
   	        	                    aLin3[nExcel3][04],; // 04 D  
   	            	                aLin3[nExcel3][05],; // 05 E
   	            	                aLin3[nExcel3][06],; // 06 F  
        	                        aLin3[nExcel3][07],; // 07 G  
   	        	                    aLin3[nExcel3][08],; // 08 H  
   	            	                aLin3[nExcel3][09],; // 09 I   
   	            	                aLin3[nExcel3][09] ; // 10 J
   	                	                              }) //GRAVANDO NA LINHA MANDANDO PARA O EXCEL O ARRAY COM AS LINHAS				
   NEXT 
   //============================== FINAL IMPRIME LINHA NO EXCEL
   
   // *** FINAL PLANILHA 3
   
   // *** INICIO PLANILHA 4
    
   nLin4 := 0
   SqlPlan4X()
   DBSELECTAREA("TRI")
   TRI->(DBGOTOP())
   WHILE TRI->(!EOF()) 
	
		nLin4  := nLin4 + 1
		   
		//===================== INICIO CRIA VETOR COM POSICAO VAZIA 
	   	AADD(aLin4,{ "", ; // 01 A  
	   	              0, ; // 02 B   
	   	              0, ; // 03 C   
	   	              0, ; // 04 D  
	   	              0, ; // 05 E  
	   	              0, ; // 06 F   
	   	              0, ; // 07 G   
	   	              0, ; // 08 H  
	   	              0, ; // 09 I
	   	              0  ; // 10 J
	   	                   })
		//===================== FINAL CRIA VETOR COM POSICAO VAZIA
		
		//======================================= INICIO ADICIONANDO OS CAMPOS NAS LINHAS ===================
		
		IncProc("Gerando Planilha 4 " + TRI->DESC_CRED)
		
		aLin4[nLin4][01] := ALLTRIM(TRI->DESC_CRED) //A
		aLin4[nLin4][02] := TRI->TOTAL              //B
		
		SqlPlan4Y(TRI->TP_CRED)
	    DBSELECTAREA("TRJ")
		TRJ->(DBGOTOP())
		WHILE TRJ->(!EOF())
		 	
			aLin4[nLin4][03] := IIF(TRJ->CD_EQUIP == 5, aLin4[nLin4][03]+ TRJ->CONTAGEM,aLin4[nLin4][03])                                           //C
			aLin4[nLin4][04] := IIF(TRJ->CD_EQUIP == 6,aLin4[nLin4][04] + TRJ->CONTAGEM,aLin4[nLin4][04])                                           //D
			aLin4[nLin4][05] := IIF(TRJ->CD_EQUIP == 20,aLin4[nLin4][05] + TRJ->CONTAGEM,aLin4[nLin4][05])                                          //E
			aLin4[nLin4][06] := IIF(TRJ->CD_EQUIP == 21,aLin4[nLin4][06] + TRJ->CONTAGEM,aLin4[nLin4][06])                                          //F
			aLin4[nLin4][07] := IIF(TRJ->CD_EQUIP == 4 .AND. ALLTRIM(TRJ->SENTIDO) == 'ENTRADA', aLin4[nLin4][07] + TRJ->CONTAGEM,aLin4[nLin4][07]) //G
			aLin4[nLin4][08] := IIF(TRJ->CD_EQUIP == 4 .AND. ALLTRIM(TRJ->SENTIDO) == 'SAIDA'  , aLin4[nLin4][08] + TRJ->CONTAGEM,aLin4[nLin4][08]) //H
			aLin4[nLin4][09] := 0                                                                                                                   //I
			aLin4[nLin4][10] := 0                                                                                                                   //J
			
			TRJ->(dbSkip())    
		
		ENDDO //end do while TRJ
		TRJ->( DBCLOSEAREA() )
		
		//======================================= FINAL ADICIONANDO OS CAMPOS NAS LINHAS ===================			
    
		TRI->(dbSkip())    
	
	ENDDO //end do while TRG
	TRI->( DBCLOSEAREA() )
	
	//============================== INICIO IMPRIME LINHA NO EXCEL
	FOR nExcel4 := 1 TO nLin4
	
		IncProc("Carregando Planilha 4 " + CVALTOCHAR(nExcel4) + '/' + CVALTOCHAR(nLin4))
   		oExcel:AddRow(cPlan4,cTit4,{aLin4[nExcel4][01],; // 01 A  
        	                        aLin4[nExcel4][02],; // 02 B  
        	                        aLin4[nExcel4][03],; // 03 C  
   	        	                    aLin4[nExcel4][04],; // 04 D  
   	            	                aLin4[nExcel4][05],; // 05 E
   	            	                aLin4[nExcel4][06],; // 06 F  
        	                        aLin4[nExcel4][07],; // 07 G  
   	        	                    aLin4[nExcel4][08],; // 08 H  
   	            	                aLin4[nExcel4][09],; // 09 I   
   	            	                aLin4[nExcel4][10] ; // 10 J
   	                	                              }) //GRAVANDO NA LINHA MANDANDO PARA O EXCEL O ARRAY COM AS LINHAS				
   NEXT 
   //============================== FINAL IMPRIME LINHA NO EXCEL
   
   // *** FINAL PLANILHA 4
   
   //Exclui a tabela
   
   oTempTable:Delete()
   
Return(lRet)    

Static Function SalvaXml()

	oExcel:Activate()
	oExcel:GetXMLFile("C:\temp\FECHAPORT.XLS")

Return()

Static Function CriaExcel()              

    oMsExcel := MsExcel():New()
	oMsExcel:WorkBooks:Open("C:\temp\FECHAPORT.XLS")
	oMsExcel:SetVisible( .T. )
	oMsExcel := oMsExcel:Destroy()

Return()       

Static Function MontaPerg() 
                                 
	Private bValid	:= Nil 
	Private cF3		:= Nil
	Private cSXG	:= Nil
	Private cPyme	:= Nil
	
    U_xPutSx1(cPerg,'01','Data De              ?','','','mv_ch1','D',08,0,00,'G',bValid,cF3,cSXG,cPyme,'MV_PAR01')
	U_xPutSx1(cPerg,'02','Data Ate             ?','','','mv_ch2','D',08,0,00,'G',bValid,cF3,cSXG,cPyme,'MV_PAR02')
	U_xPutSX1(cPerg,"03",'Catraca              ?','','','mv_ch3',"N",01,0,01,'C',bValid,cF3,cSXG,cPyme,'MV_PAR03','Sim','','','','Não','','','','','','','','','','')
	U_xPutSX1(cPerg,"04",'Cancela Entrada      ?','','','mv_ch4',"N",01,0,01,'C',bValid,cF3,cSXG,cPyme,'MV_PAR04','Sim','','','','Não','','','','','','','','','','')
	U_xPutSX1(cPerg,"05",'Cancela Saída        ?','','','mv_ch5',"N",01,0,01,'C',bValid,cF3,cSXG,cPyme,'MV_PAR05','Sim','','','','Não','','','','','','','','','','')
	U_xPutSX1(cPerg,"06",'Refeitório 1         ?','','','mv_ch6',"N",01,0,01,'C',bValid,cF3,cSXG,cPyme,'MV_PAR06','Sim','','','','Não','','','','','','','','','','')
	U_xPutSX1(cPerg,"07",'Refeitório 2         ?','','','mv_ch7',"N",01,0,01,'C',bValid,cF3,cSXG,cPyme,'MV_PAR07','Sim','','','','Não','','','','','','','','','','')
	U_xPutSX1(cPerg,"08",'Balança Entrada      ?','','','mv_ch8' ,"N",01,0,01,'C',bValid,cF3,cSXG,cPyme,'MV_PAR08','Sim','','','','Não','','','','','','','','','','')
	U_xPutSX1(cPerg,"09",'Balança Saida        ?','','','mv_ch9' ,"N",01,0,01,'C',bValid,cF3,cSXG,cPyme,'MV_PAR09','Sim','','','','Não','','','','','','','','','','')
	U_xPutSX1(cPerg,"10",'Catraca Logistica    ?','','','mv_ch10',"N",01,0,01,'C',bValid,cF3,cSXG,cPyme,'MV_PAR10','Sim','','','','Não','','','','','','','','','','')
	U_xPutSX1(cPerg,"11",'Portão Manutenção    ?','','','mv_ch11',"N",01,0,01,'C',bValid,cF3,cSXG,cPyme,'MV_PAR11','Sim','','','','Não','','','','','','','','','','')
	U_xPutSX1(cPerg,"12",'Industrial Entrada   ?','','','mv_ch12',"N",01,0,01,'C',bValid,cF3,cSXG,cPyme,'MV_PAR12','Sim','','','','Não','','','','','','','','','','')
	U_xPutSX1(cPerg,"13",'Industrial Saida     ?','','','mv_ch13',"N",01,0,01,'C',bValid,cF3,cSXG,cPyme,'MV_PAR13','Sim','','','','Não','','','','','','','','','','')
	U_xPutSX1(cPerg,"14",'Adm Entrada          ?','','','mv_ch14',"N",01,0,01,'C',bValid,cF3,cSXG,cPyme,'MV_PAR14','Sim','','','','Não','','','','','','','','','','')
	U_xPutSX1(cPerg,"15",'Adm Saida            ?','','','mv_ch15',"N",01,0,01,'C',bValid,cF3,cSXG,cPyme,'MV_PAR15','Sim','','','','Não','','','','','','','','','','')
	U_xPutSX1(cPerg,"16",'Terceiros Manutenção ?','','','mv_ch16',"N",01,0,01,'C',bValid,cF3,cSXG,cPyme,'MV_PAR16','Sim','','','','Não','','','','','','','','','','')
	
	Pergunte(cPerg,.F.)
	
Return Nil            
                                
Static Function Cabec() 

	//Planilha 1
    oExcel:AddworkSheet(cPlanilha)
	oExcel:AddTable (cPlanilha,cTitulo)                                    
	oExcel:AddColumn(cPlanilha,cTitulo,"Num Credencial "            ,1,1) // 01 A
    oExcel:AddColumn(cPlanilha,cTitulo,"Matricula / CPF. Visitante" ,1,1) // 02 B
    oExcel:AddColumn(cPlanilha,cTitulo,"Nome "                      ,1,1) // 03 C    
    oExcel:AddColumn(cPlanilha,cTitulo,"Data "                      ,1,1) // 04 D
    oExcel:AddColumn(cPlanilha,cTitulo,"Hora "                      ,1,1) // 05 E
    oExcel:AddColumn(cPlanilha,cTitulo,"Nome Estrutura "            ,1,1) // 06 F
  	oExcel:AddColumn(cPlanilha,cTitulo,"Codigo Equipamento "        ,1,1) // 07 G
	oExcel:AddColumn(cPlanilha,cTitulo,"Descricão Equipamento "     ,1,1) // 08 H
	oExcel:AddColumn(cPlanilha,cTitulo,"Tipo Evento "               ,1,1) // 09 I
	oExcel:AddColumn(cPlanilha,cTitulo,"Sentido "                   ,1,1) // 10 J
	oExcel:AddColumn(cPlanilha,cTitulo,"Codigo Credencial "         ,1,1) // 11 K
	oExcel:AddColumn(cPlanilha,cTitulo,"Tipo Credencial "           ,1,1) // 12 L
	oExcel:AddColumn(cPlanilha,cTitulo,"Nome Autorizador "          ,1,1) // 13 M
	
	//Planilha 2
	oExcel:AddworkSheet(cPlan2)
		
	oExcel:AddTable (cPlan2,cTit2)
	oExcel:AddColumn(cPlan2,cTit2,"Tipos Credenciais " ,1,1) // 01 A
	oExcel:AddColumn(cPlan2,cTit2,"Total             " ,1,1) // 02 B
	oExcel:AddColumn(cPlan2,cTit2,"Cancela Entrada   " ,1,1) // 03 C
	oExcel:AddColumn(cPlan2,cTit2,"Catraca Entrada "   ,1,1) // 04 D
	oExcel:AddColumn(cPlan2,cTit2,"Cancela Saída "	   ,1,1) // 05 E
	oExcel:AddColumn(cPlan2,cTit2,"Catraca Saída "	   ,1,1) // 06 F
	
	//Planilha 3
	oExcel:AddworkSheet(cPlan3)
		
	oExcel:AddTable (cPlan3,cTit3)
	oExcel:AddColumn(cPlan3,cTit3,"Tipos Credenciais " ,1,1) // 01 A
	oExcel:AddColumn(cPlan3,cTit3,"Total             " ,1,1) // 02 B
	oExcel:AddColumn(cPlan3,cTit3,"Cancela Entrada   " ,1,1) // 03 C
	oExcel:AddColumn(cPlan3,cTit3,"Catraca Entrada "   ,1,1) // 04 D
	oExcel:AddColumn(cPlan3,cTit3,"Balanca Entrada "   ,1,1) // 05 E
	oExcel:AddColumn(cPlan3,cTit3,"Fretado Entrada "   ,1,1) // 06 F
	oExcel:AddColumn(cPlan3,cTit3,"Cancela Saída "	   ,1,1) // 07 G
	oExcel:AddColumn(cPlan3,cTit3,"Catraca Saída "	   ,1,1) // 08 H
	oExcel:AddColumn(cPlan3,cTit3,"Balanca Saída "	   ,1,1) // 09 I
	oExcel:AddColumn(cPlan3,cTit3,"Fretado Saída "	   ,1,1) // 10 J
	
	//Planilha 4
	oExcel:AddworkSheet(cPlan4)
		
	oExcel:AddTable (cPlan4,cTit4)
	oExcel:AddColumn(cPlan4,cTit4,"Tipos Credenciais " ,1,1) // 01 A
	oExcel:AddColumn(cPlan4,cTit4,"Total             " ,1,1) // 02 B
	oExcel:AddColumn(cPlan4,cTit4,"Cancela Entrada   " ,1,1) // 03 C
	oExcel:AddColumn(cPlan4,cTit4,"Cancela Saída "     ,1,1) // 04 D
	oExcel:AddColumn(cPlan4,cTit4,"Balanca Entrada "   ,1,1) // 05 E
	oExcel:AddColumn(cPlan4,cTit4,"Balanca Saída "     ,1,1) // 06 F
	oExcel:AddColumn(cPlan4,cTit4,"Catraca Entrada "   ,1,1) // 07 G
	oExcel:AddColumn(cPlan4,cTit4,"Catraca Saída "	   ,1,1) // 08 H
	oExcel:AddColumn(cPlan4,cTit4,"Fretado Entrada "   ,1,1) // 09 I
	oExcel:AddColumn(cPlan4,cTit4,"Fretado Saída "	   ,1,1) // 10 J
			
RETURN(NIL)

Static Function SqlGeral(cEquip) 

	Local nFil     := 0   
	Local cDtIni   := ''
	Local cDtFin   := ''                                    
	Local cQuery   := ''
	
	IF CEMPANT == '01' .AND. xFilial("SRA") == '02'
	
		nFil := 9 //Emresa Adoro codigo da filial de Varzea no Dimep
		
	ELSEIF CEMPANT == '02' .AND. xFilial("SRA") == '01'	
	
		nFil := 17 //Empresa Ceres codigo da filial de Varzea	
	
	ENDIF	

	cDtIni   := DTOS(MV_PAR01)
	cDtFin   := DTOS(MV_PAR02)
	
	cQuery := "SELECT CD_LOG_ACESSO, "
	cQuery += "       NU_CREDENCIAL, "
	cQuery += "       NU_MATRICULA,  "
	cQuery += "       CD_VISITANTE,  "
	cQuery += "       NU_DOCUMENTO,  "
	cQuery += "       NM_PESSOA,  "
	cQuery += "       NU_DATA_REQUISICAO,  "
	cQuery += "       NU_HORA_REQUISICAO,  "
	cQuery += "       NM_ESTRUTURA,  "
	cQuery += "       CD_EQUIPAMENTO, " 
	cQuery += "       DS_EQUIPAMENTO,  "
	cQuery += "       CASE WHEN TP_EVENTO = 27 THEN 'ACESSO MASTER' ELSE CASE WHEN TP_EVENTO = 10 THEN 'ACESSO CONCLUIDO' ELSE CASE WHEN TP_EVENTO = 12 THEN 'ACESSO BATCH' ELSE 'ACESSO AUTORIZACAO EXCEPCIONAL' END END END AS TP_EVENTO,  "
	cQuery += "       CASE WHEN TP_SENTIDO_CONSULTA = 1 THEN 'ENTRADA' ELSE 'SAIDA' END AS  TP_SENTIDO_CONSULTA,  "
	cQuery += "       LOG_ACESSO.CD_TIPO_CREDENCIAL, "
	cQuery += "       (SELECT DS_TIPO_CREDENCIAL FROM [DIMEP].[DMPACESSOII].[DBO].[TIPO_CREDENCIAL] AS TIPO_CREDENCIAL WHERE TIPO_CREDENCIAL.CD_TIPO_CREDENCIAL = LOG_ACESSO.CD_TIPO_CREDENCIAL)  AS DS_TIPO_CREDENCIAL "
	cQuery += "       FROM [DIMEP].[DMPACESSOII].[DBO].[LOG_ACESSO] AS LOG_ACESSO "
	cQuery += " WHERE NU_DATA_REQUISICAO >= '" + cDtIni   + "' "
	cQuery += "   AND NU_DATA_REQUISICAO <= '" + cDtFin   + "' "
	cQuery += "   AND CD_EQUIPAMENTO     IN (" + cEquip + ") " 
	cQuery += "   AND (TP_EVENTO          = '27'  " // Acesso Master
	cQuery += "    OR TP_EVENTO           = '10'  " // Acesso Concluido
	cQuery += "    OR TP_EVENTO           = '12'  " // Acesso Batch
	cQuery += "    OR TP_EVENTO           = '23') " // Acesso Autorizacao
	cQuery += "   ORDER BY LOG_ACESSO.CD_LOG_ACESSO " 
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRC",.F.,.T.)
	
RETURN()

Static Function SqlPlan2X() 

	cQuery := "SELECT TP_CRED, "
	cQuery += "       DESC_CRED, "
	cQuery += "       SUM(CONTAGEM) AS TOTAL "
	cQuery += "FROM " + oTempTable:GetRealName() + " WITH (NOLOCK) " 
	cQuery += " WHERE (CD_EQUIP = '4'   " // 4-Catraca Portaria  
	cQuery += "    OR CD_EQUIP  = '5'   " // 5-Cancela Entrada Portaria
	cQuery += "    OR CD_EQUIP  = '6'   " // 6-Cancela Saída Portaria 
	cQuery += "    OR CD_EQUIP  = '20'  " // 20-Balança de Entrada
	cQuery += "    OR CD_EQUIP  = '21') " // 21-Balança de Saída
	cQuery += "    GROUP BY  TP_CRED,DESC_CRED  " 
	cQuery += "    ORDER BY  TP_CRED,DESC_CRED  " 
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRE",.F.,.T.)
	
RETURN()

Static Function SqlPlan2Y(nTpCred) 

	cQuery := "SELECT TP_CRED, "
	cQuery += "       DESC_CRED, "
	cQuery += "       CD_EQUIP, "
	cQuery += "       SENTIDO, "
	cQuery += "       DS_EQUIP, "
	cQuery += "       SUM(CONTAGEM) AS CONTAGEM  "
	cQuery += "FROM " + oTempTable:GetRealName() + " WITH (NOLOCK) " 
	cQuery += " WHERE TP_CRED   = " + CVALTOCHAR(nTpCred) + " "  
	cQuery += "   AND (CD_EQUIP = '4'   " // 4-Catraca Portaria  
	cQuery += "    OR CD_EQUIP  = '5'   " // 5-Cancela Entrada Portaria
	cQuery += "    OR CD_EQUIP  = '6'   " // 6-Cancela Saída Portaria 
	cQuery += "    OR CD_EQUIP  = '20'  " // 20-Balança de Entrada
	cQuery += "    OR CD_EQUIP  = '21') " // 21-Balança de Saída
	cQuery += "    GROUP BY  TP_CRED,DESC_CRED,CD_EQUIP,SENTIDO,DS_EQUIP  " 
	cQuery += "    ORDER BY  TP_CRED,DESC_CRED  " 
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRF",.F.,.T.)
	
RETURN()

Static Function SqlPlan3X() 

	cQuery := "SELECT TP_CRED, "
	cQuery += "       DESC_CRED, "
	cQuery += "       SUM(CONTAGEM) AS TOTAL "
	cQuery += "FROM " + oTempTable:GetRealName() + " WITH (NOLOCK) " 
	cQuery += " WHERE (CD_EQUIP = '4'   " // 4-Catraca Portaria  
	cQuery += "    OR CD_EQUIP  = '5'   " // 5-Cancela Entrada Portaria
	cQuery += "    OR CD_EQUIP  = '6'   " // 6-Cancela Saída Portaria 
	cQuery += "    OR CD_EQUIP  = '20'  " // 20-Balança de Entrada
	cQuery += "    OR CD_EQUIP  = '21') " // 21-Balança de Saída
	cQuery += "    GROUP BY  TP_CRED,DESC_CRED  " 
	cQuery += "    ORDER BY  TP_CRED,DESC_CRED  " 
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRG",.F.,.T.)
	
RETURN()

Static Function SqlPlan3Y(nTpCred) 

	cQuery := "SELECT TP_CRED, "
	cQuery += "       DESC_CRED, "
	cQuery += "       CD_EQUIP, "
	cQuery += "       SENTIDO, "
	cQuery += "       DS_EQUIP, "
	cQuery += "       SUM(CONTAGEM) AS CONTAGEM  "
	cQuery += "FROM " + oTempTable:GetRealName() + " WITH (NOLOCK) " 
	cQuery += " WHERE TP_CRED   = " + CVALTOCHAR(nTpCred) + " "  
	cQuery += "   AND (CD_EQUIP = '4'   " // 4-Catraca Portaria  
	cQuery += "    OR CD_EQUIP  = '5'   " // 5-Cancela Entrada Portaria
	cQuery += "    OR CD_EQUIP  = '6'   " // 6-Cancela Saída Portaria 
	cQuery += "    OR CD_EQUIP  = '20'  " // 20-Balança de Entrada
	cQuery += "    OR CD_EQUIP  = '21') " // 21-Balança de Saída 
	cQuery += "    GROUP BY  TP_CRED,DESC_CRED,CD_EQUIP,SENTIDO,DS_EQUIP  " 
	cQuery += "    ORDER BY  TP_CRED,DESC_CRED  " 
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRH",.F.,.T.)
	
RETURN()

Static Function SqlPlan4X() 

	cQuery := "SELECT TP_CRED, "
	cQuery += "       DESC_CRED, "
	cQuery += "       SUM(CONTAGEM) AS TOTAL "
	cQuery += "FROM " + oTempTable:GetRealName() + " WITH (NOLOCK) " 
	cQuery += " WHERE (CD_EQUIP = '4'   " // 4-Catraca Portaria  
	cQuery += "    OR CD_EQUIP  = '5'   " // 5-Cancela Entrada Portaria
	cQuery += "    OR CD_EQUIP  = '6'   " // 6-Cancela Saída Portaria 
	cQuery += "    OR CD_EQUIP  = '20'  " // 20-Balança de Entrada
	cQuery += "    OR CD_EQUIP  = '21') " // 21-Balança de Saída 
	cQuery += "    GROUP BY  TP_CRED,DESC_CRED  " 
	cQuery += "    ORDER BY  TP_CRED,DESC_CRED  " 
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRI",.F.,.T.)
	
RETURN()

Static Function SqlPlan4Y(nTpCred) 

	cQuery := "SELECT TP_CRED, "
	cQuery += "       DESC_CRED, "
	cQuery += "       CD_EQUIP, "
	cQuery += "       SENTIDO, "
	cQuery += "       DS_EQUIP, "
	cQuery += "       SUM(CONTAGEM) AS CONTAGEM  "
	cQuery += "FROM " + oTempTable:GetRealName() + " WITH (NOLOCK) " 
	cQuery += " WHERE TP_CRED   = " + CVALTOCHAR(nTpCred) + " "  
	cQuery += "   AND (CD_EQUIP = '4'   " // 4-Catraca Portaria  
	cQuery += "    OR CD_EQUIP  = '5'   " // 5-Cancela Entrada Portaria
	cQuery += "    OR CD_EQUIP  = '6'   " // 6-Cancela Saída Portaria 
	cQuery += "    OR CD_EQUIP  = '20'  " // 20-Balança de Entrada
	cQuery += "    OR CD_EQUIP  = '21') " // 21-Balança de Saída
	cQuery += "    GROUP BY  TP_CRED,DESC_CRED,CD_EQUIP,SENTIDO,DS_EQUIP  " 
	cQuery += "    ORDER BY  TP_CRED,DESC_CRED  " 
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRJ",.F.,.T.)
	
RETURN()

Static Function SqlCredencial(cCred) 

	cQuery := "SELECT CD_CREDENCIAL "
	cQuery += "       FROM [DIMEP].[DMPACESSOII].[DBO].[CREDENCIAL] AS CREDENCIAL "
	cQuery += " WHERE NU_CREDENCIAL = '" + cCred   + "' "
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRK",.F.,.T.)
	
RETURN()

Static Function SqlVisita(cCdVisitante,cDtVisita,cCredencial) 

	cQuery := "SELECT NM_CONTATO "
	cQuery += "       FROM [DIMEP].[DMPACESSOII].[DBO].[VISITA] AS VISITA "
	cQuery += " WHERE CD_VISITANTE  = '" + cCdVisitante + "' "
	cQuery += "   AND DT_VISITA     = '" + cDtVisita    + "' "
	cQuery += "   AND CD_CREDENCIAL = '" + cCredencial  + "' "
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRL",.F.,.T.)
	
RETURN()

Static Function SqlVis2(cCdVisitante,cDtVisita) 

	cQuery := "SELECT NM_CONTATO "
	cQuery += "       FROM [DIMEP].[DMPACESSOII].[DBO].[VISITA] AS VISITA "
	cQuery += " WHERE CD_VISITANTE  = '" + cCdVisitante + "' "
	cQuery += "   AND DT_VISITA     = '" + cDtVisita    + "' "
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRM",.F.,.T.)
	
RETURN()
