#INCLUDE "PROTHEUS.CH" 
#INCLUDE "XMLXFUN.CH" 
#INCLUDE "TOPCONN.CH" 
#INCLUDE "FILEIO.CH"

/*/{Protheus.doc} User Function ADFIN009P
	WebService Cisp, inclusão de CNPJ's que serão feito consulta no webservice da CISP
	@type  Function
	@author William Costa
	@since 08/04/2020
	@version 01
	@history ticket T.I - Fernando Sigoli - 18/01/2021 - Correção error LOG  
	@history ticket T.I - Fernando Sigoli - 21/05/2021 - Alteração de senha de acesso Webservice CISP	
/*/

USER FUNCTION ADFIN009P() 

	Local 	aCores       := { { 'ZB5_INTEGR = .F.' , 'BR_VERDE'       } ,; // A Consultar no Webservice da Cisp
	                          { 'ZB5_INTEGR = .T. .AND. (ZB5_DTCONS == CTOD("  /  /  "))' , 'BR_LARANJA'       } ,; // A Consultar no Webservice da Cisp
                              { 'ZB5_INTEGR = .T. .AND. (ZB5_DTCONS <> CTOD("  /  /  "))' , 'BR_VERMELHO'   }}    // Ja Consultado no Webservice da Cisp
	Private cJson    := ''
	Private oJson         := NIL
	Private _cErro	     := ''
	Private _cAviso	     := ''
	Private aHeadOut     := {}
	Private cUrl         := ''    
	Private cHttpHeader  := ''
	Private aRating      := {}
	Private aRatings     := {}
	Private aSocio       := {}
	Private aSocios      := {}
	Private nCont        := 0
	Private nSegmento    := 0
	Private cQuery       := ''
	Private aRestr       := {}
	Private aRestris     := {} 
	Private aRotina      := { { OemToAnsi("Pesquisar")                     ,"AxPesqui"             , 0 , 1},; 
						      { OemToAnsi("Visualizar")                    ,"AxVisual"             , 0 , 2},; 
						      { OemToAnsi("Incluir")                       ,"AxInclui"             , 0 , 3},; 
						      { OemToAnsi("Alterar")                       ,"AxAltera"             , 0 , 4},; 
						      { OemToAnsi("Excluir")                       ,"AxDeleta"             , 0 , 5},; 
						      { OemToAnsi("Legenda")                       ,"u_LEGENDAWSC"         , 0 , 6},; 
						      { OemToAnsi("Consultar WebService")          ,"u_TELAWEBSERVICECISP" , 0 , 7},; 
						      { OemToAnsi("Importar Arq. CSV")             ,"u_IMPORTCSVWSCISP"    , 0 , 8},; 
						      { OemToAnsi("Carregar Clientes Filtros PB3") ,"u_IMPORTPB3WSCISP"    , 0 , 9} } 
	Private cCadastro    := OemToAnsi("CNPJ PARA CONSULTA CISP")  //"Criterios de Rateio					 
	Private oBrowse      := NIL
	Private oDlg         := Nil  
	Private oDlg2        := Nil  
	Private oGetLoteWS   := Nil
	Private nLoteWs      := 0
	Private nLoteWs1     := 0
	Private oGetVendde   := Nil
	Private cVendde      := SPACE(6)
	Private oGetVendAte  := Nil
	Private cVendAte     := 'ZZZZZZ'
	Private oGetSupde    := Nil
	Private cSupde       := SPACE(6)
	Private oGetSupAte   := Nil
	Private cSupAte      := 'ZZZZZZ'
	Private oCombo1      := Nil
	Private aItems       := {'Sim','Nao','Todos'}
	Private cCombo1      := ''
	Private cErro        := ''
		
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')
	
	mBrowse( 6,1,22,75,"ZB5",,,,,2,aCores)
	
RETURN (NIL)

USER Function TELAWEBSERVICECISP() 

	U_ADINF009P('ADFIN009P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

	SqlCountCGC() 
	While TRC->(!EOF()) 
	
		nLoteWs1  := TRC->COUNT_ZB5_RAICGC
		
		TRC->(dbSkip())   
			
   	ENDDO 
	TRC->( DBCLOSEAREA() )

	DEFINE MSDIALOG oDlg TITLE "Consultar Web Service Cisp" FROM 0,0 TO 135,230 OF oDlg PIXEL
		
		@ 06,06 TO 65,115 LABEL "Preencha as Informacoes:" OF oDlg PIXEL
		
		@ 15, 15 SAY "Qtd Lote de Consulta Web Service:" SIZE  65,8 PIXEL
		@ 25, 15 MSGET oGetLoteWS VAR nLoteWs1 SIZE 30,10 PICTURE "9999999999" PIXEL
		
		//+-------------------
		//| Botoes da MSDialog
		//+-------------------
		@ 45,015 BUTTON "Sair" SIZE 36,16 PIXEL ACTION EVAL({|| oDlg:End()}) 
		@ 45,065 BUTTON "OK"   SIZE 36,16 PIXEL ACTION PROCESSA({|| IMPORTWEBSERVICECISP(nLoteWs1),oDlg:End()}) 
		
		ACTIVATE MSDIALOG oDlg CENTER
		
		oBrowse := GetObjBrow()
		oBrowse:Default()
		oBrowse:Refresh()  
		oBrowse:GOTOP()
		oBrowse:Refresh()
	
RETURN(NIL)           

USER Function IMPORTCSVWSCISP()

	Local cBuffer    := ""
	Local cFileOpen  := ""
	Local cTitulo1   := "Selecione o arquivo"
	Local cExtens	 := "Arquivo CSV | *.csv" 
	Local cCnpj      := '' 
	Local nPosCnpj   := 0 
	Local cCadastro  := ''

	U_ADINF009P('ADFIN009P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')
	
	cFileOpen := cGetFile(cExtens,cTitulo1,2,,.T.,GETF_LOCALHARD+GETF_NETWORKDRIVE,.T.)
	
	If !File(cFileOpen)
		MsgAlert("Arquivo texto: "+cFileOpen+" não localizado",cCadastro)
		Return(.F.)
	EndIf
	
	FT_FUSE(cFileOpen)   //ABRIR
	FT_FGOTOP()          //PONTO NO TOPO
	ProcRegua(FT_FLASTREC()) //QTOS REGISTROS LER
	
	While !FT_FEOF()  //FACA ENQUANTO NAO FOR FIM DE ARQUIVO

		IncProc()
		
		// Capturar dados
		cBuffer    := FT_FREADLN() //LENDO LINHA
		
		nPosCnpj := at(";",cBuffer)
	    cCnpj    := STRZERO(VAL(SUBSTR(cBuffer,1,8)),8)
		
		
	    //IMPORTA DADOS PARA A TABELA
	    DbSelectArea("ZB5")
        dbSetOrder(1) 
        
		RecLock("ZB5",.T.)  
                     
			ZB5->ZB5_RAICGC := cCnpj
            	
            ZB5->( MsUnLock() ) 
        
        ZB5->( DBCLOSEAREA() )
	    
			
		FT_FSKIP()   //proximo registro no arquivo txt
		
	EndDo
	
	FT_FUSE() //fecha o arquivo txt
   
    oBrowse := GetObjBrow()
	oBrowse:Default()
	oBrowse:Refresh()  
	oBrowse:GOTOP()
	oBrowse:Refresh()
	
RETURN(NIL)

USER Function IMPORTPB3WSCISP()
    
	cVendde  := SPACE(6)
	cVendAte := 'ZZZZZZ'
	cSupde   := SPACE(6)
	cSupAte  := 'ZZZZZZ'
	cCombo1  := aItems[1]

	U_ADINF009P('ADFIN009P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

	DEFINE MSDIALOG oDlg2 TITLE "IMPORT PB3" FROM 0,0 TO 350,310 OF oDlg2 PIXEL
		
		@ 06,06 TO 170,155 LABEL "Preencha as Informações:" OF oDlg2 PIXEL
		
		@ 15, 15 SAY "Vendedor de:"           SIZE  65,8 PIXEL
		@ 25, 15 MSGET oGetVendde VAR cVendde SIZE 30,10 PICTURE PesqPict("SA3","A3_COD") PIXEL
		
		@ 50, 15 SAY "Vendedor Ate:"            SIZE  65, 8 PIXEL
		@ 60, 15 MSGET oGetVendAte VAR cVendAte SIZE 30,10 PICTURE PesqPict("SA3","A3_COD") PIXEL
		
		@ 75, 15 SAY "Supervisor de:"       SIZE  65, 8 PIXEL
		@ 85, 15 MSGET oGetSupde VAR cSupde SIZE 35,10 PICTURE PesqPict("SA3","A3_COD")  PIXEL
		
		@ 100, 15 SAY "Supervisor Ate:"        SIZE  65, 8 PIXEL
		@ 110, 15 MSGET oGetSupAte VAR cSupAte SIZE 35,10 PICTURE PesqPict("SA3","A3_COD") PIXEL
		
		@ 125, 15 SAY "Bloqueados:"        SIZE  65, 8 PIXEL
		oCombo1 := TComboBox():New(135,15,{|u|if(PCount()>0,cCombo1:=u,cCombo1)},aItems,100,20,oDlg,,,,,,.T.,,,,,,,,,'cCombo1')
		
		//+-------------------
		//| Botoes da MSDialog
		//+-------------------
		@ 150,015 BUTTON "Sair" SIZE 36,16 PIXEL ACTION EVAL({|| oDlg2:End()}) 
		@ 150,065 BUTTON "OK"   SIZE 36,16 PIXEL ACTION EVAL({|| CarregaCNPJPB3(),oDlg2:End()}) 

		
		ACTIVATE MSDIALOG oDlg2 CENTER
		
		oBrowse := GetObjBrow()
		oBrowse:Default()
		oBrowse:Refresh()  
		oBrowse:GOTOP()
		oBrowse:Refresh()

RETURN(NIL)

Static Function CarregaCNPJPB3() 

	SqlCargaPB3() 
	While TRD->(!EOF()) 
	
		//IMPORTA DADOS PARA A TABELA
	    DbSelectArea("ZB5")
        dbSetOrder(1) 
        
			RecLock("ZB5",.T.)  
                     
				ZB5->ZB5_RAICGC := TRD->PB3_CGC
            	
        	ZB5->( MsUnLock() ) 
        
        ZB5->( DBCLOSEAREA() )
	
		
		
		TRD->(dbSkip())   
			
   	ENDDO 
	TRD->( DBCLOSEAREA() )

RETURN(NIL)	
	
STATIC FUNCTION IMPORTWEBSERVICECISP(nLoteWs)

	Local nContCNPJ := 0
	
	ProcRegua(nLoteWs)
	SqlListaCGC(nLoteWs)
   	While TRB->(!EOF())   

	   	nContCNPJ := nContCNPJ + 1

	   	IncProc("Consultando CNPJ " + TRB->ZB5_RAICGC + ' || ' + CVALTOCHAR(nContCNPJ) + '/' +CVALTOCHAR(nLoteWs))
   		
		cJson        := ''
		_cErro	     := ''
		_cAviso	     := ''
		aHeadOut     := {}
		cUrl         := ''    
		cHttpHeader  := ''
		aRating      := {}
		aRatings     := {}
		aSocio       := {}
		aSocios      := {}
		nCont        := 0
		nSegmento    := 0
		cQuery       := ''
		aRestr       := {}
		aRestris     := {}  
		oJson        := NIL
		DelClassIntF()
		
		conout("ADFIN009P - " + TRB->ZB5_RAICGC)
		
		IF ALLTRIM(TRB->ZB5_RAICGC) = '00000000' .OR. ;
		   ALLTRIM(TRB->ZB5_RAICGC) = ''
		   
		    DbSelectArea("ZB5")
		    ZB5->(DBGOTOP())
			dbSetOrder(1) 
			IF DbSeek(xFilial("ZB5") + TRB->ZB5_RAICGC,.T.) // Busca exata
				WHILE ZB5->(!EOF()) .AND. TRB->ZB5_RAICGC == ZB5->ZB5_RAICGC
				
					RecLock("ZB5",.F.)  
			
						ZB5->ZB5_INTEGR := .T.
						
					ZB5->( MsUnLock() ) 
					ZB5->(dbSkip()) 
				ENDDO //end do while ZB5  
			ENDIF 
			ZB5->( DBCLOSEAREA() )                      
		   
		    TRB->(dbSkip())
			LOOP //SE A RAIZ DE CNPJ FOR IGUAL A 0 OU BRANCO PULA
		   
		
		ENDIF 

		SLEEP(5000)
		
		cUrl := 'https://servicos.cisp.com.br/v1/avaliacao-analitica/raiz/' + TRB->ZB5_RAICGC     
        aAdd( aHeadOut , "Authorization: Basic "+Encode64("ws13801"+":"+"Ad@r13821" ) )
	    cJson := HttpGet(cUrl,"",NIL,aHeadOut,@cHttpHeader) 
	    
	    IF TYPE("cJson") == 'U'
	    
	    	conout("ADFIN009P - cJson IGUAL NIL, DEVE ESTAR SEM INTERNET O SERVIDOR")
	    
	    	TRB->(dbSkip())
			LOOP //SE O oJson for igual a nil vai para o proximo
		
		ENDIF

		IF !FWJsonDeserialize(cJson, @oJson)

			cErro := 'Não foi possivel montar o Json'

		ENDIF

	    IF !EMPTY(cErro)

			CONOUT("Falha ao transformar texto em objeto json. Erro: ")
			DbSelectArea("ZB5")
			ZB5->(DBGOTOP())
			dbSetOrder(1) 
			IF DbSeek(xFilial("ZB5") + TRB->ZB5_RAICGC,.T.) // Busca exata
				WHILE ZB5->(!EOF()) .AND. TRB->ZB5_RAICGC == ZB5->ZB5_RAICGC
				
					RecLock("ZB5",.F.)  
			
						ZB5->ZB5_INTEGR := .T.
						
					ZB5->( MsUnLock() ) 
					ZB5->(dbSkip()) 
				ENDDO //end do while ZB5  
			ENDIF 
			ZB5->( DBCLOSEAREA() )   
		
			TRB->(dbSkip())
			LOOP //SE O oJson for igual a nil vai para o proximo
			
		ENDIF

		IF TYPE("oJson:MENSAGEM") <> 'U'

			IF SUBSTR(oJson:MENSAGEM,1,32) $ 'Cliente nao Cadastrado Raiz CNPJ'
			
				DbSelectArea("ZB5")
				ZB5->(DBGOTOP())
				dbSetOrder(1) 
				IF DbSeek(xFilial("ZB5") + TRB->ZB5_RAICGC,.T.) // Busca exata
					WHILE ZB5->(!EOF()) .AND. TRB->ZB5_RAICGC == ZB5->ZB5_RAICGC
					
						RecLock("ZB5",.F.)  
				
							ZB5->ZB5_INTEGR := .T.
							
						ZB5->( MsUnLock() ) 
						ZB5->(dbSkip()) 
					ENDDO //end do while ZB5  
				ENDIF 
				ZB5->( DBCLOSEAREA() )  
			
				TRB->(dbSkip())
				LOOP //SE O oJson for igual a nil vai para o proximo
			
			ENDIF
		ENDIF
		
		nCont := 0

		IF TYPE("oJson:QUADROSOCIO:SOCIOS") <> 'U' 
		
			IF VALTYPE(oJson:QUADROSOCIO:SOCIOS) == 'O'
									
				aSocio     := {}
				Aadd(aSocio,CVALTOCHAR(oJson:QUADROSOCIO:SOCIOS:IDENTIFICACAOSOCIO)) 
				Aadd(aSocio,oJson:QUADROSOCIO:SOCIOS:RAZAOSOCIAL) 
				Aadd(aSocio,oJson:QUADROSOCIO:SOCIOS:QUALIFICACAOSOCIO) 
				Aadd(aSocio,oJson:QUADROSOCIO:SOCIOS:PERCENTUALPARTICIPACAO) 
				Aadd(aSocio,STOD(STRTRAN(oJson:QUADROSOCIO:SOCIOS:DATAENTRADASOCIO,'-',''))) 		    
                Aadd(aSocios,aSocio)  
			
			ELSE 
			
				IF LEN(oJson:QUADROSOCIO:SOCIOS) >= 1 
				
					FOR nCont := 1 TO LEN(oJson:QUADROSOCIO:SOCIOS)
			
						aSocio     := {}
					    Aadd(aSocio,CVALTOCHAR(oJson:QUADROSOCIO:SOCIOS[nCont]:IDENTIFICACAOSOCIO)) 
					    Aadd(aSocio,oJson:QUADROSOCIO:SOCIOS[nCont]:RAZAOSOCIAL) 
					    Aadd(aSocio,oJson:QUADROSOCIO:SOCIOS[nCont]:QUALIFICACAOSOCIO) 
					    Aadd(aSocio,oJson:QUADROSOCIO:SOCIOS[nCont]:PERCENTUALPARTICIPACAO) 
					    Aadd(aSocio,STOD(STRTRAN(oJson:QUADROSOCIO:SOCIOS[nCont]:DATAENTRADASOCIO,'-',''))) 		    
					    Aadd(aSocios,aSocio)  
					    
				 	NEXT
				ENDIF
			ENDIF
		ENDIF	

	 	nCont := 0
	 	
		IF TYPE("oJson:RATINGS") <> 'U' 
		
			IF VALTYPE(oJson:RATINGS) == 'O'
									
				aRating     := {}
			    Aadd(aRating,'M-1')
				Aadd(aRating,oJson:RATINGS:CLASSIFICACAO) 
				Aadd(aRating,oJson:RATINGS:QUESITOS:NOTAPONTUALIDADENIVELATRASO) 
			    Aadd(aRatings,aRating)  
			
			ELSE 
			
				IF LEN(oJson:RATINGS) >= 1 
				
					FOR nCont := 1 to LEN(oJson:RATINGS)
	
						aRating     := {}
					    Aadd(aRating,IIF(nCont == 1, 'M', 'M-'+CVALTOCHAR(nCont-1))) 
					    Aadd(aRating,oJson:RATINGS[nCont]:CLASSIFICACAO) 
					    Aadd(aRating,oJson:RATINGS[nCont]:QUESITOS:NOTAPONTUALIDADENIVELATRASO) 
					    Aadd(aRatings,aRating)  
					    
				 	NEXT    
				ENDIF
			ENDIF
		ENDIF	
	 	
	 	nCont := 0
		                
		IF TYPE("oJson:RESTRITIVAS") <> 'U' 
		
			IF VALTYPE(oJson:RESTRITIVAS) == 'O'
									
				aRestr := {}
			    Aadd(aRestr,STOD(STRTRAN(oJson:RESTRITIVAS:DATAINFORMACAO,'-',''))) 
				Aadd(aRestr,oJson:RESTRITIVAS:CODIGOASSOCIADA) 
				Aadd(aRestr,oJson:RESTRITIVAS:CODIGOPRIMEIRARESTRITIVA) 
				Aadd(aRestr,oJson:RESTRITIVAS:DESCRICAOPRIMEIRARESTRITIVA) 
				Aadd(aRestr,oJson:RESTRITIVAS:CODIGOSEGUNDARESTRITIVA)
				Aadd(aRestr,oJson:RESTRITIVAS:DESCRICAOSEGUNDARESTRITIVA) 		    
			    Aadd(aRestris,aRestr)  
			
			ELSE 
			
				IF LEN(oJson:RESTRITIVAS) >= 1 
				
					FOR nCont := 1 to LEN(oJson:RESTRITIVAS)
			
						aRestr := {}
					    Aadd(aRestr,STOD(STRTRAN(oJson:RESTRITIVAS[nCont]:DATAINFORMACAO,'-',''))) 
					    Aadd(aRestr,CVALTOCHAR(oJson:RESTRITIVAS[nCont]:CODIGOASSOCIADA)) 
					    Aadd(aRestr,CVALTOCHAR(oJson:RESTRITIVAS[nCont]:CODIGOPRIMEIRARESTRITIVA)) 
					    Aadd(aRestr,oJson:RESTRITIVAS[nCont]:DESCRICAOPRIMEIRARESTRITIVA) 
					    Aadd(aRestr,CVALTOCHAR(oJson:RESTRITIVAS[nCont]:CODIGOSEGUNDARESTRITIVA))
					    Aadd(aRestr,oJson:RESTRITIVAS[nCont]:DESCRICAOSEGUNDARESTRITIVA) 		    
					    Aadd(aRestris,aRestr)  
					    
					NEXT
				ENDIF
			ENDIF
		ENDIF	
	 	
	 	nCont := 0
	 	
	 	IF VALTYPE(oJson:POSITIVASEGMENTOS) <> 'O' 
	 	    
	 	    nCont     := 0
	 		nSegmento := 0                                                                                                          
	 		FOR nSegmento := 1 TO LEN(oJson:POSITIVASEGMENTOS)              
	 		
	 		    IF VALTYPE(oJson:POSITIVASEGMENTOS) == 'A'
	 		    
		 			FOR nCont := 1 TO LEN(oJson:POSITIVASEGMENTOS[nSegmento]:POSITIVAS)
			 	
				 	    DbSelectArea("ZB6")
							RecLock("ZB6",.T.) 
							
								ZB6->ZB6_FILIAL := ""
								ZB6->ZB6_DTCONS := DATE()
								ZB6->ZB6_RAICGC := SUBSTR(STRZERO(oJson:CLIENTE:IDENTIFICACAOCLIENTE,14),1,8)
								ZB6->ZB6_CGC    := STRZERO(oJson:CLIENTE:IDENTIFICACAOCLIENTE,14)
								ZB6->ZB6_NOME   := oJson:CLIENTE:RAZAOSOCIAL
								ZB6->ZB6_NOMFAN := oJson:CLIENTE:NOMEFANTASIA
								ZB6->ZB6_END    := oJson:CLIENTE:ENDERECO
								ZB6->ZB6_BAIRRO := oJson:CLIENTE:BAIRRO
								ZB6->ZB6_CIDADE := oJson:CLIENTE:CIDADE
								ZB6->ZB6_UF     := oJson:CLIENTE:UF
								ZB6->ZB6_CEP    := STRZERO(oJson:CLIENTE:CEP,8)
								ZB6->ZB6_TEL    := oJson:CLIENTE:TELEFONE
								ZB6->ZB6_DTCAD  := STOD(STRTRAN(oJson:CLIENTE:DATACADASTRAMENTO,'-',''))
								ZB6->ZB6_DTFUND := STOD(STRTRAN(oJson:CLIENTE:DATAFUNDACAO,'-',''))
								ZB6->ZB6_CNAE   := IIF(TYPE("oJson:RECEITAFEDERAL")  == 'U','',STRTRAN(STRTRAN(oJson:RECEITAFEDERAL:CNAE,'-',''),'.','')) //T.I Fernando Sigoli 18/11/2021
								ZB6->ZB6_DESCCN := IIF(TYPE("oJson:RECEITAFEDERAL")  == 'U','',oJson:RECEITAFEDERAL:DESCRICAOATIVIDADEFISCAL) //T.I Fernando Sigoli 18/11/2021
								ZB6->ZB6_NOMEAN := ''
								ZB6->ZB6_SIMNAC := IIF(TYPE("oJson:SIMPLESNACIONAL") == 'U','',oJson:SIMPLESNACIONAL:DESCRICAOOPTANTE)
								ZB6->ZB6_SIMEI  := IIF(TYPE("oJson:SIMPLESNACIONAL") == 'U','',oJson:SIMPLESNACIONAL:DESCRICAOSIMEI)
								ZB6->ZB6_SITREC := IIF(TYPE("oJson:RECEITAFEDERAL")  == 'U','',oJson:RECEITAFEDERAL:SITUACAOCADASTRAL)
 
								IF TYPE("oJson:SINTEGRAS")  <> 'U' 
									
									IF LEN(oJson:SINTEGRAS) >= 1 
									
										ZB6->ZB6_CGCSIN := STRZERO(oJson:SINTEGRAS[1]:IDENTIFICACAOCLIENTE,14)
										ZB6->ZB6_INSEST := oJson:SINTEGRAS[1]:INSCRICAOESTADUAL
										ZB6->ZB6_SITSIN := oJson:SINTEGRAS[1]:SITUACAOCADASTRAL

									ENDIF
									
								ENDIF

								IF LEN(aSocios) >= 1   
								
									ZB6->ZB6_CGCSO1 := aSocios[1][1]
									ZB6->ZB6_NOMSO1 := aSocios[1][2]
									ZB6->ZB6_QSOC1  := aSocios[1][3]
									ZB6->ZB6_POSOC1 := aSocios[1][4]
									ZB6->ZB6_DTSOC1 := aSocios[1][5]
								
								ENDIF                  
								
								IF LEN(aSocios) >= 2   
								
									ZB6->ZB6_CGCSO2 := aSocios[2][1]
									ZB6->ZB6_NOMSO2 := aSocios[2][2]
									ZB6->ZB6_QSOC2  := aSocios[2][3]
									ZB6->ZB6_POSOC2 := aSocios[2][4]
									ZB6->ZB6_DTSOC2 := aSocios[2][5]
								
								ENDIF
								                       
								IF LEN(aSocios) >= 3   
								
									ZB6->ZB6_CGCSO3 := aSocios[3][1]
									ZB6->ZB6_NOMSO3 := aSocios[3][2]
									ZB6->ZB6_QSOC3  := aSocios[3][3]
									ZB6->ZB6_POSOC3 := aSocios[3][4]
									ZB6->ZB6_DTSOC3 := aSocios[3][5]
								
								ENDIF
								                       
								IF LEN(aRatings) >= 1
								   
									ZB6->ZB6_RDT01  := aRatings[1][1]
									ZB6->ZB6_RRIS01 := aRatings[1][2]
									ZB6->ZB6_PONT01 := aRatings[1][3]
								
								ENDIF
								                     
								IF LEN(aRatings) >= 2
								
									ZB6->ZB6_RDT02  := aRatings[2][1]
									ZB6->ZB6_RRIS02 := aRatings[2][2]
									ZB6->ZB6_PONT02 := aRatings[2][3]
								
								ENDIF
								  
								IF LEN(aRatings) >= 3
								
									ZB6->ZB6_RDT03  := aRatings[3][1]
									ZB6->ZB6_RRIS03 := aRatings[3][2]
									ZB6->ZB6_PONT03 := aRatings[3][3]
								
								ENDIF
								                     
								IF LEN(aRatings) >= 4
								
									ZB6->ZB6_RDT04  := aRatings[4][1]
									ZB6->ZB6_RRIS04 := aRatings[4][2]
									ZB6->ZB6_PONT04 := aRatings[4][3]
								
								ENDIF
								                     
								IF LEN(aRatings) >= 5
								
									ZB6->ZB6_RDT05  := aRatings[5][1]
									ZB6->ZB6_RRIS05 := aRatings[5][2]
									ZB6->ZB6_PONT05 := aRatings[5][3]
									
								ENDIF	   
								
								IF LEN(aRatings) >= 6
								
									ZB6->ZB6_RDT06  := aRatings[6][1]
									ZB6->ZB6_RRIS06 := aRatings[6][2]
									ZB6->ZB6_PONT06 := aRatings[6][3]
									
								ENDIF
								                     
								IF LEN(aRatings) >= 7
								
									ZB6->ZB6_RDT07  := aRatings[7][1]
									ZB6->ZB6_RRIS07 := aRatings[7][2]
									ZB6->ZB6_PONT07 := aRatings[7][3]
								
								ENDIF    
								
								IF LEN(aRatings) >= 8
								
									ZB6->ZB6_RDT08  := aRatings[8][1]
									ZB6->ZB6_RRIS08 := aRatings[8][2]
									ZB6->ZB6_PONT08 := aRatings[8][3]
								
								ENDIF 
								                     
								IF LEN(aRatings) >= 9
								
									ZB6->ZB6_RDT09  := aRatings[9][1]
									ZB6->ZB6_RRIS09 := aRatings[9][2]
									ZB6->ZB6_PONT09 := aRatings[9][3]
								                  
								ENDIF
								                     
								IF LEN(aRatings) >= 10
								
									ZB6->ZB6_RDT10  := aRatings[10][1]
									ZB6->ZB6_RRIS10 := aRatings[10][2]
									ZB6->ZB6_PONT10 := aRatings[10][3]
								
								ENDIF
								                     
								IF LEN(aRatings) >= 11
								
									ZB6->ZB6_RDT11  :=aRatings[11][1]
									ZB6->ZB6_RRIS11 :=aRatings[11][2]
									ZB6->ZB6_PONT11 :=aRatings[11][3]
									
								ENDIF
								
								IF LEN(aRatings) >= 12
								
									ZB6->ZB6_RDT12  := aRatings[12][1]
									ZB6->ZB6_RRIS12 := aRatings[12][2]
									ZB6->ZB6_PONT12 := aRatings[12][3]
								
								ENDIF
								                                  
								IF LEN(aRatings) >= 13
								
									ZB6->ZB6_RDT13  := aRatings[13][1]
									ZB6->ZB6_RRIS13 := aRatings[13][2]
									ZB6->ZB6_PONT13 := aRatings[13][3] 
								
								ENDIF 
								
								//Inicio T.I Fernando Sigoli 18/11/2021
								IF VALTYPE(oJson:INFORMACOESCOMPORTAMENTAISSEGMENTOS) == 'U' 
								
									ZB6->ZB6_CODSEG := oJson:INFORMACOESCOMPORTAMENTAISSEGMENTOS[nSegmento]:COMPORTAMENTOSSEGMENTOS[1]:CODIGOSEGMENTO
									ZB6->ZB6_DESSEG := oJson:INFORMACOESCOMPORTAMENTAISSEGMENTOS[nSegmento]:COMPORTAMENTOSSEGMENTOS[1]:DESCRICAOSEGMENTO
								
								ENDIF
								//Fim T.I Fernando Sigoli 18/11/2021
								
								ZB6->ZB6_QTDASS := oJson:POSITIVASEGMENTOS[nSegmento]:TOTALASSOCIADASSEGMENTO
								ZB6->ZB6_VLDEBT := oJson:POSITIVASEGMENTOS[nSegmento]:VALORTOTALDEBITOSEGMENTO
								ZB6->ZB6_VLDEB5 := oJson:POSITIVASEGMENTOS[nSegmento]:VALORTOTALDEBITOVENCIDOMAIS05DIASSEGMENTO
								
								ZB6->ZB6_PDTINF := STOD(STRTRAN(oJson:POSITIVASEGMENTOS[nSegmento]:POSITIVAS[nCont]:DATAINFORMACAO,'-',''))
								ZB6->ZB6_PCODAS := CVALTOCHAR(oJson:POSITIVASEGMENTOS[nSegmento]:POSITIVAS[nCont]:CODIGOASSOCIADA)
								ZB6->ZB6_PDTCLI := STOD(STRTRAN(oJson:POSITIVASEGMENTOS[nSegmento]:POSITIVAS[nCont]:DATACLIENTEDESDE,'-',''))
								ZB6->ZB6_PDTULT := STOD(STRTRAN(oJson:POSITIVASEGMENTOS[nSegmento]:POSITIVAS[nCont]:DATAULTIMACOMPRA,'-',''))
								ZB6->ZB6_PDTMAI := STOD(STRTRAN(oJson:POSITIVASEGMENTOS[nSegmento]:POSITIVAS[nCont]:DATAMAIORACUMULO,'-',''))
								ZB6->ZB6_PVLMAI := oJson:POSITIVASEGMENTOS[nSegmento]:POSITIVAS[nCont]:VALORMAIORACUMULO
								ZB6->ZB6_PVLATU := oJson:POSITIVASEGMENTOS[nSegmento]:POSITIVAS[nCont]:VALORDEBITOATUAL
								ZB6->ZB6_PVLV05 := oJson:POSITIVASEGMENTOS[nSegmento]:POSITIVAS[nCont]:VALORDEBITOVENCIDOMAIS05DIAS
								ZB6->ZB6_PVLV15 := oJson:POSITIVASEGMENTOS[nSegmento]:POSITIVAS[nCont]:VALORDEBITOVENCIDOMAIS15DIAS
								ZB6->ZB6_PVLV30 := oJson:POSITIVASEGMENTOS[nSegmento]:POSITIVAS[nCont]:VALORDEBITOVENCIDOMAIS30DIAS
								ZB6->ZB6_PPMEDV := oJson:POSITIVASEGMENTOS[nSegmento]:POSITIVAS[nCont]:PRAZOMEDIODEVENDAS
								ZB6->ZB6_PVMPAP := oJson:POSITIVASEGMENTOS[nSegmento]:POSITIVAS[nCont]:VALORMEDIAPONDERADAATRASOPAGAMENTOS
								ZB6->ZB6_PMPTV5 := oJson:POSITIVASEGMENTOS[nSegmento]:POSITIVAS[nCont]:MEDIAPONDERADATITULOSVENCIDOSMAIS05DIAS
								ZB6->ZB6_PCODLI := CVALTOCHAR(oJson:POSITIVASEGMENTOS[nSegmento]:POSITIVAS[nCont]:CODIGOLIMITECREDITO)
								ZB6->ZB6_PVLLIM := oJson:POSITIVASEGMENTOS[nSegmento]:POSITIVAS[nCont]:VALORLIMITECREDITO
								
								IF LEN(aRestris) >= 1
								
									
									ZB6->ZB6_DTRES1 := aRestris[1][1]
									ZB6->ZB6_CODRE1 := aRestris[1][2]
									ZB6->ZB6_PRIRE1 := aRestris[1][3]
									ZB6->ZB6_DEREP1 := aRestris[1][4]
									ZB6->ZB6_SEGRE1 := aRestris[1][5]
									ZB6->ZB6_DERES1 := aRestris[1][6]
									
								
								ENDIF 
								
								IF LEN(aRestris) >= 2
								
									ZB6->ZB6_DTRES2 := aRestris[2][1]
									ZB6->ZB6_CODRE2 := aRestris[2][2]
									ZB6->ZB6_PRIRE2 := aRestris[2][3]
									ZB6->ZB6_DEREP2 := aRestris[2][4]
									ZB6->ZB6_SEGRE2 := aRestris[2][5]
									ZB6->ZB6_DERES2 := aRestris[2][6]
								    
								
								ENDIF 
								       
								ZB6->ZB6_DEVCHE := oJson:CHEQUESEMFUNDO:TOTALDEVOLUCOES
								
								IF TYPE("oJson:ALERTAS")  <> 'U'

									IF VALTYPE(oJson:ALERTAS) == 'O'
									
										ZB6->ZB6_ALECGC := CVALTOCHAR(oJson:ALERTAS:IDENTIFICACAOCLIENTE)
										ZB6->ZB6_ALEDAT := STOD(STRTRAN(SUBSTR(oJson:ALERTAS:DATAATUALIZACAO,1,10),'-',''))
										ZB6->ZB6_ALEASS := CVALTOCHAR(oJson:ALERTAS:ASSOCIADAINFORMANTE)
										ZB6->ZB6_TPALER := oJson:ALERTAS:CODIGOALERTA
										ZB6->ZB6_DESALE := oJson:ALERTAS:DESCRICAOALERTA
									
									ELSE
										IF LEN(oJson:ALERTAS) >= 1 
										
											ZB6->ZB6_ALECGC := CVALTOCHAR(oJson:ALERTAS[1]:IDENTIFICACAOCLIENTE)
											ZB6->ZB6_ALEDAT := STOD(STRTRAN(SUBSTR(oJson:ALERTAS[1]:DATAATUALIZACAO,1,10),'-',''))
											ZB6->ZB6_ALEASS := CVALTOCHAR(oJson:ALERTAS[1]:ASSOCIADAINFORMANTE)
											ZB6->ZB6_TPALER := oJson:ALERTAS[1]:CODIGOALERTA
											ZB6->ZB6_DESALE := oJson:ALERTAS[1]:DESCRICAOALERTA

										ENDIF
									ENDIF
								ENDIF
								                  
								ZB6->ZB6_QTDCON := 0
								ZB6->ZB6_VLTDAT := oJson:INFORMACAOSUPORTE:VALORTOTALDEBITOATUAL
								ZB6->ZB6_QTDADA := oJson:INFORMACAOSUPORTE:QUANTIDADEASSOCIADASDEBITOATUAL
								ZB6->ZB6_VLDV05 := oJson:INFORMACAOSUPORTE:VALORTOTALDEBITOVENCIDOMAIS05DIAS
								ZB6->ZB6_QTDV05 := oJson:INFORMACAOSUPORTE:QUANTIDADEASSOCIADASDEBITOVENCIDOMAIS05DIAS
								ZB6->ZB6_VLDV15 := oJson:INFORMACAOSUPORTE:VALORTOTALDEBITOVENCIDOMAIS15DIAS
								ZB6->ZB6_QTDV15 := oJson:INFORMACAOSUPORTE:QUANTIDADEASSOCIADASDEBITOVENCIDOMAIS15DIAS
								ZB6->ZB6_VLDV30 := oJson:INFORMACAOSUPORTE:VALORTOTALDEBITOVENCIDOMAIS30DIAS
								ZB6->ZB6_QTDV30 := oJson:INFORMACAOSUPORTE:QUANTIDADEASSOCIADASDEBITOVENCIDOMAIS30DIAS
								ZB6->ZB6_QTINFN := oJson:INFORMACAOSUPORTE:QUANTIDADEASSOCIADASINFORMACOESNEGOCIAIS
								ZB6->ZB6_QTDAVU := oJson:INFORMACAOSUPORTE:QUANTIDADEASSOCIADASVENDASULTIMOS2MESES
								//ZB6->ZB6_NCCRED := oJson:ASSOCIADANAOCONCEDERAMCREDITO
								
								IF TYPE("oJson:INDICADORES")  <> 'U' 

									IF VALTYPE(oJson:INDICADORES) == 'O'
									
										ZB6->ZB6_CODIND := oJson:INDICADORES:CODIGOSEGMENTO
										ZB6->ZB6_DESCIN := oJson:INDICADORES:DESCRICAOSEGMENTO
										ZB6->ZB6_ALERTA := oJson:INDICADORES:INDICEALERTA
										ZB6->ZB6_ATRASO := oJson:INDICADORES:INDICEATRASO
										ZB6->ZB6_INADIM := oJson:INDICADORES:INDICEINADIMPLENCIA
									
									ELSE
										IF LEN(oJson:INDICADORES) >= 1 
										
											ZB6->ZB6_CODIND := CVALTOCHAR(oJson:INDICADORES[1]:CODIGOSEGMENTO)
											ZB6->ZB6_DESCIN := oJson:INDICADORES[1]:DESCRICAOSEGMENTO
											ZB6->ZB6_ALERTA := oJson:INDICADORES[1]:INDICEALERTA
											ZB6->ZB6_ATRASO := oJson:INDICADORES[1]:INDICEATRASO
											ZB6->ZB6_INADIM := oJson:INDICADORES[1]:INDICEINADIMPLENCIA
										ENDIF
									ENDIF
								ENDIF
								
								ZB6->ZB6_IMPORT := ''
								
							ZB6->( MsUnLock() ) // Confirma e finaliza a operação
						
						ZB6->( DBCLOSEAREA() )	
					NEXT		
				ENDIF
		 	NEXT
		ENDIF
		
		DbSelectArea("ZB5")
		ZB5->(DBGOTOP())
		dbSetOrder(1) 
		IF DbSeek(xFilial("ZB5") + TRB->ZB5_RAICGC,.T.) // Busca exata
			WHILE ZB5->(!EOF()) .AND. TRB->ZB5_RAICGC == ZB5->ZB5_RAICGC
			
				RecLock("ZB5",.F.)  
				
					ZB5->ZB5_DTCONS := DATE()
					ZB5->ZB5_INTEGR := .T.
					
				ZB5->( MsUnLock() ) 
				ZB5->(dbSkip()) 
			ENDDO //end do while ZB5  
		ENDIF 
		ZB5->( DBCLOSEAREA() )    
        
		TRB->(dbSkip())

	ENDDO
	TRB->(dbCloseArea())
	
RETURN(NIL)   

User Function LEGENDAWSC()

	U_ADINF009P('ADFIN009P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

	BrwLegenda("CNPJ PARA CONSULTA CISP","Legenda",{	{"BR_VERDE"   ,"Em Aberto - Aguardando envio para WebService da Cisp"},;
	                                                    {"BR_LARANJA" ,"Fechado - Não existe no WebService da Cisp"},;
	                                                    {"BR_VERMELHO","Concluido - Enviado para WebService da Cisp"         } } )
	
Return (.T.)                    

Static Function SqlListaCGC(nLoteWs) 

	Local cLoteWs := cvaltochar(nLoteWs) 

	cQuery := 	" SELECT TOP(" + cLoteWs + ") ZB5_RAICGC, "
	cQuery +=	"                             ZB5_DTCONS, "
	cQuery +=	"                             ZB5_INTEGR " 
	cQuery +=	"                        FROM "+RetSqlName("ZB5")+ " "
	cQuery +=	"                       WHERE D_E_L_E_T_ <> '*' "
	cQuery +=	"                         AND ZB5_INTEGR = 'F'"  
	cQuery +=	" ORDER BY ZB5_RAICGC   "

	
	TCQUERY cQuery new alias "TRB"

RETURN(NIL)       

Static Function SqlCountCGC() 

	BeginSQL Alias "TRC"
		%NoPARSER% 
		SELECT COUNT(ZB5_RAICGC) AS COUNT_ZB5_RAICGC
		  FROM %Table:ZB5%
		 WHERE D_E_L_E_T_ <> '*' 
		   AND ZB5_INTEGR  = 'F'  
	EndSQl    

RETURN(NIL) 


Static Function SqlCargaPB3()

	IF cCombo1 == 'Sim' 
	
		BeginSQL Alias "TRD"
			%NoPARSER% 
			SELECT A3_COD,
			       A3_SUPER,
				   LEFT(PB3_CGC,8)  AS PB3_CGC
			  FROM %Table:SA3% SA3, %Table:PB3% PB3
			 WHERE A3_COD         >= %EXP:cVendde%
			   AND A3_COD         <= %EXP:cVendAte%
			   AND A3_SUPER       >= %EXP:cSupde%
			   AND A3_SUPER       <= %EXP:cSupAte%
			   AND A3_COD          = PB3_CODVEN
			   AND PB3_BLOQUE      = '1'
			   AND SA3.D_E_L_E_T_ <> '*'
			   AND PB3.D_E_L_E_T_ <> '*'
			
			   GROUP BY A3_COD,A3_SUPER,LEFT(PB3_CGC,8)
		EndSQl    
	
	ELSEIF cCombo1 == 'Nao' 
	
		BeginSQL Alias "TRD"
			%NoPARSER% 
			SELECT A3_COD,
			       A3_SUPER,
				   LEFT(PB3_CGC,8)  AS PB3_CGC
			  FROM %Table:SA3% SA3, %Table:PB3% PB3
			 WHERE A3_COD         >= %EXP:cVendde%
			   AND A3_COD         <= %EXP:cVendAte%
			   AND A3_SUPER       >= %EXP:cSupde%
			   AND A3_SUPER       <= %EXP:cSupAte%
			   AND A3_COD          = PB3_CODVEN
			   AND PB3_BLOQUE      = '2'
			   AND SA3.D_E_L_E_T_ <> '*'
			   AND PB3.D_E_L_E_T_ <> '*'
			
			   GROUP BY A3_COD,A3_SUPER,LEFT(PB3_CGC,8)
		EndSQl    
	
	ELSE          
	
		BeginSQL Alias "TRD"
			%NoPARSER% 
			SELECT A3_COD,
			       A3_SUPER,
				   LEFT(PB3_CGC,8)  AS PB3_CGC
			  FROM %Table:SA3% SA3, %Table:PB3% PB3
			 WHERE A3_COD         >= %EXP:cVendde%
			   AND A3_COD         <= %EXP:cVendAte%
			   AND A3_SUPER       >= %EXP:cSupde%
			   AND A3_SUPER       <= %EXP:cSupAte%
			   AND A3_COD          = PB3_CODVEN
			   AND SA3.D_E_L_E_T_ <> '*'
			   AND PB3.D_E_L_E_T_ <> '*'
			
			   GROUP BY A3_COD,A3_SUPER,LEFT(PB3_CGC,8)
		EndSQl    
	
	ENDIF

RETURN(NIL)      
