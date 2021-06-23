#INCLUDE 'PROTHEUS.CH'
#INCLUDE "FILEIO.CH"
#INCLUDE "TopConn.CH"  
#INCLUDE "RWMAKE.CH"
#INCLUDE "ADEST002P.ch"

/*/{Protheus.doc} User Function ADEST041P
	Programa chamador do ponto de entrada MTA015MNU no cadastro de enderecos esse botao vai gerar o saldo de localizacao automaticamente
	@type  Function
	@author William Costa
	@since 26/04/2019
	@version 01
	@history Chamado 057643 - William Costa - 24/04/2020 - Identificado que a variavel cErro não estava declarada, onde gerava o erro e também logica para bloquear a criação do saldo quando o cErro estive preenchido estava errado, ajustado as duas logicas no programa
/*/

USER FUNCTION ADEST041P()     
    
    Private n        := 1 
    Private lRet     := .T.    
    Private nCont    := 0
	Private cErro    := ''
	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Programa chamador do ponto de entrada MTA015MNU no cadastro de enderecos esse botao vai gerar o saldo de localizacao automaticamente ')
	
	// *** INICIO VALIDACAO *** //
	
	SqlEndereco(SBE->BE_FILIAL,SBE->BE_CODPRO,SBE->BE_LOCAL,SBE->BE_LOCALIZ)
	
	While TRB->(!EOF())
	
		nCont := nCont + 1
		TRB->(dbSkip())
				
	ENDDO 
		    	    
	TRB->(dbCloseArea())
	
	SqlVSBF(SBE->BE_FILIAL,SBE->BE_LOCAL,SBE->BE_CODPRO,SBE->BE_LOCALIZ)
    IF TRD->(!EOF())       
       
    	MSGSTOP('Olá ' + ALLTRIM(cUserName) + ', não é possivel criar Saldo de Endereço!!!'  + CHR(13) + CHR(10) + ;
			    'Esse produto já está com saldo localizado.'                                 + CHR(13) + CHR(10) + ; 
			    'Localização:' + TRD->BF_LOCALIZ + ' Saldo:' + CVALTOCHAR(TRD->BF_QUANT), 'ADEST041-01' )						
			    
   		lRet := .F.
		    	   			
	ENDIF
    TRD->(dbCloseArea())
    
	IF nCont > 1
	
		MsgStop("OLÁ " + Alltrim(cUserName) + ", Codigo de Produto Informado mais de uma vez, não permitido.", "ADEST041-02")
		lRet := .F.
		
	ENDIF
	
	IF ALLTRIM(SBE->BE_LOCAL) == '03'
	
		MsgStop("OLÁ " + Alltrim(cUserName) + ", Não é possivel crial Saldo de Endereço para o Armazém 03, favor criar manualmente.", "ADEST041-03")
		lRet := .F.
		
	ENDIF 
	
	SqlQtdAtual(SBE->BE_FILIAL,SBE->BE_CODPRO,SBE->BE_LOCAL)
	
	IF TRC->(EOF())       
       
    	MSGSTOP('Olá ' + ALLTRIM(cUserName) + ', não é possivel criar Saldo de Endereço!!!'  + CHR(13) + CHR(10) + ;
			    'Esse produto não tem Saldo no Produto ou não foi criado Saldo Inicial.'                                 + CHR(13) + CHR(10) + ; 
			    'favor verificar.', 'ADEST041-04' )
			    
   		lRet := .F.
		    	   			
	ENDIF       
			      
	While TRC->(!EOF())
	
		IF TRC->B2_QACLASS > 0
	
			MsgStop("OLÁ " + Alltrim(cUserName) + ", Não é possivel crial Saldo de Endereço existe Quantidade a Classificar maior que zero, abra chamado para T.I.", "ADEST041-05")
			lRet := .F.
			
		ENDIF
		
		IF TRC->B2_QEMPSA > 0
	
			MsgStop("OLÁ " + Alltrim(cUserName) + ", Não é possivel crial Saldo de Endereço existe Quantidade Empenhada de S.A maior que zero, abra chamado para T.I.", "ADEST041-06")
			lRet := .F.
			
		ENDIF
		
		IF TRC->B2_RESERVA > 0
	
			MsgStop("OLÁ " + Alltrim(cUserName) + ", Não é possivel crial Saldo de Endereço existe Quantidade de Reserva maior que zero, abra chamado para T.I.", "ADEST041-07")
			lRet := .F.
			
		ENDIF
		
		IF TRC->B2_QEMP > 0
	
			MsgStop("OLÁ " + Alltrim(cUserName) + ", Não é possivel crial Saldo de Endereço existe Quantidade de Empenho maior que zero, abra chamado para T.I.", "ADEST041-08")
			lRet := .F.
			
		ENDIF
		
		TRC->(dbSkip())
					
	ENDDO  

	TRC->(dbCloseArea())
	
	// *** FINAL VALIDACAO
	
	IF lRet == .T.
	   
		SqlEndereco(SBE->BE_FILIAL,SBE->BE_CODPRO,SBE->BE_LOCAL,SBE->BE_LOCALIZ)
		
		While TRB->(!EOF())  
		
			//Busca Quantidade Atual no Estoque
			SqlQtdAtual(SBE->BE_FILIAL,SBE->BE_CODPRO,SBE->BE_LOCAL)       
			      
		    While TRC->(!EOF()) 
		    
			    // *** INICIO VERIFICACAO CADASTRO DE PRODUTO *** //
				SqlProduto(SBE->BE_CODPRO)
				While TRE->(!EOF())
				
				    // *** INICIO AJUSTA CODIGO BAR DO PRODUTO  *** //
					IF ALLTRIM(TRE->B1_CODBAR) <> ALLTRIM(SBE->BE_CODPRO)
					
						DBSELECTAREA("SB1")
						DBSETORDER(1)
						IF DBSEEK(FWXFILIAL("SB1") +SBE->BE_CODPRO, .T.)
						
							RECLOCK("SB1",.F.)
							
								SB1->B1_CODBAR := TRE->B1_COD
							
							MSUNLOCK()
						
				        ENDIF          
			        ENDIF    
			        // *** FINAL AJUSTA CODIGO BAR DO PRODUTO *** //
			        
			        // *** INICIO AJUSTA CAMPO CONTROLE DE LOCALIZACAO PRODUTO *** //
			        IF ALLTRIM(TRE->B1_LOCALIZ) <> 'S'
					
						DBSELECTAREA("SB1")
						DBSETORDER(1)
						IF DBSEEK(FWXFILIAL("SB1") +SBE->BE_CODPRO, .T.)
						
							RECLOCK("SB1",.F.)
							
								SB1->B1_LOCALIZ := 'S'
							
							MSUNLOCK()
						
				        ENDIF          
				                  
			        ENDIF
			        // *** FINAL AJUSTA CAMPO CONTROLE DE LOCALIZACAO PRODUTO *** //
			        
			        // *** INICIO VERIFICA SE O PRODUTO TEM SBZ INDICADOR DE PRODUTO DO PRODUTO *** //
			        SqlIndicador(SBE->BE_CODPRO)
			        
			        IF TRF->(EOF())
			        
			        	cErro := cErro + ' Produto: ' + ALLTRIM(SBE->BE_CODPRO) + ' sem Indicador de Produtos, favor verificar!!!' + CHR(13) + CHR(10)
			            lRet  := .F. 
			            
			        ENDIF
			        
			        While TRF->(!EOF())
			        
			        	// *** INICIO AJUSTA CAMPO CONTROLE DE LOCALIZACAO PRODUTO *** //
				        IF ALLTRIM(TRF->BZ_LOCALIZ) <> 'S'
						
							DBSELECTAREA("SBZ")
							DBSETORDER(1)
							IF DBSEEK(FWXFILIAL("SBZ") +SBE->BE_CODPRO, .T.)
							
								RECLOCK("SBZ",.F.)
								
									SBZ->BZ_LOCALIZ := 'S'
								
								MSUNLOCK()
							
					        ENDIF          
					                  
				        ENDIF
				        // *** FINAL AJUSTA CAMPO CONTROLE DE LOCALIZACAO PRODUTO *** //
			        
			        	TRF->(dbSkip())
					ENDDO
					TRF->(dbCloseArea())
			        // *** FINAL VERIFICA SE O PRODUTO TEM SBZ INDICADOR DE PRODUTO DO PRODUTO *** //
			        
			        TRE->(dbSkip())
			        
				ENDDO
				TRE->(dbCloseArea())

				IF lRet == .T.
					
					CriaSaldo()
					
					MsgInfo("OLÁ " + Alltrim(cUserName) + ", Saldo de Endereço criado com sucesso" + CHR(13) + CHR(10) + ;
							"FILIAL: "      + ALLTRIM(SBE->BE_FILIAL)  + CHR(13) + CHR(10) + ;
							"Produto: "     + ALLTRIM(SBE->BE_CODPRO)  + CHR(13) + CHR(10) + ;
							"Local: "       + ALLTRIM(SBE->BE_LOCAL)   + CHR(13) + CHR(10) + ;
							"Localização: " + ALLTRIM(SBE->BE_LOCALIZ) + CHR(13) + CHR(10) + ;
							"Quantidade: "  + CVALTOCHAR(TRC->B2_QATU), "ADEST041-09")

				ELSE

					MsgInfo("OLÁ " + Alltrim(cUserName) + " " + cErro, "ADEST041-10") 


				ENDIF							
			    	
			    TRC->(dbSkip())
					
			ENDDO  
	
			TRC->(dbCloseArea()) 	    
			
			TRB->(dbSkip())
					
		ENDDO 
			    	    
		TRB->(dbCloseArea())
	
	END	 

RETURN()

Static Function SqlEndereco(cFilAtu,cProd,cLocal,cEnd)
          
    BeginSQL Alias "TRB"
			%NoPARSER%
			SELECT BE_FILIAL,
			       BE_CODPRO,
				   BE_LOCAL,
				   BE_LOCALIZ
			  FROM %Table:SBE% SB1
			WHERE BE_FILIAL   = %EXP:cFilAtu%
			  AND BE_CODPRO   = %EXP:cProd%
			  AND BE_LOCAL    = %EXP:cLocal%
			  AND BE_LOCALIZ  = %EXP:cEnd%
			  AND D_E_L_E_T_ <> '*'
			  
	EndSQl
RETURN(NIL)    

Static Function SqlQtdAtual(cFilAtu,cCodItem,cLocal)

    BeginSQL Alias "TRC"
			%NoPARSER%   
			SELECT SB2.B2_FILIAL,
			       SB2.B2_COD,
			       SB2.B2_LOCAL,
			       SB2.B2_QATU,
			       SB2.B2_QACLASS,
			       SB2.B2_QEMP,
			       SB2.B2_QEMPN,
			       SB2.B2_RESERVA,
			       SB2.B2_QPEDVEN,
			       SB2.B2_QEMPSA,
			       SB2.B2_QEMPPRE,
			       SB2.B2_SALPPRE,
			       SB2.B2_QEMP2,
			       SB2.B2_QEMPN2,
			       SB2.B2_QEPRE2,
			       SB2.B2_QPEDVE2,
			       SB2.B2_RESERV2
			  FROM SB2010 SB2
			WHERE SB2.B2_FILIAL   = %EXP:cFilAtu%
			  AND SB2.B2_COD      = %EXP:cCodItem%
			  AND SB2.B2_LOCAL    = %EXP:cLocal% 
			  AND SB2.B2_QATU     > 0
			  AND SB2.D_E_L_E_T_ <> '*'
	EndSQl
	
RETURN(NIL)    

STATIC FUNCTION SqlVSBF(cFil,cLocal,cCod,cLocaliz)

	Local cTeste := ''

	BeginSQL Alias "TRD"
			%NoPARSER%        
			SELECT BF_PRODUTO,
			       BF_LOCALIZ,
			       BF_QUANT
			  FROM %Table:SBF% WITH (NOLOCK)
			WHERE  BF_FILIAL   = %EXP:cFil%
			   AND BF_LOCAL    = %EXP:cLocal%
			   AND BF_PRODUTO  = %EXP:cCod%
			   AND D_E_L_E_T_ <> '*'             
			   
			
	EndSQl
	
RETURN(NIL)

Static Function SqlProduto(cProd)

	Local cFilAtu := FWXFILIAL('SB1')

	BeginSQL Alias "TRE"
			%NoPARSER%
			SELECT B1_COD,
			       B1_DESC,
				   B1_CODBAR,
				   B1_LOCALIZ 
			  FROM %TABLE:SB1% 
			 WHERE B1_FILIAL   = %EXP:cFilAtu%
			   AND B1_COD      = %EXP:cProd%
			   AND D_E_L_E_T_ <> '*'
			
	EndSQl          
	
RETURN(NIL)

Static Function SqlIndicador(cProd)

	Local cFilAtu := FWXFILIAL('SBZ')

	BeginSQL Alias "TRF"
			%NoPARSER%
			SELECT BZ_FILIAL,
			       BZ_COD,
			       BZ_LOCALIZ 
			  FROM %TABLE:SBZ%
			   WHERE BZ_FILIAL   = %EXP:cFilAtu%
			     AND BZ_COD      = %EXP:cProd%
				 AND D_E_L_E_T_ <> '*'
			
	EndSQl          
	
RETURN(NIL)

Static Function CriaSaldo()

	//Salva a Integridade dos dados de Entrada                     
	LOCAL oDlg,nOpca :=0
	
	//Variaveis utilizadas pelo programa                           
	
	Local cAlert     :=STR0001   //"Atencao"
	Local cMens      :=""
	Local cAlias     :="SDA"
	Local cTitulo    :=STR0002 //"Criacao de Saldos por Localizacao"
	Local aObjects   :={},aPosObj  :={}
	Local aSize      :=MsAdvSize()
	Local aInfo      :={aSize[1],aSize[2],aSize[3],aSize[4],3,3}
	
	PRIVATE cDoc805    :=CriaVar("DA_DOC")
	PRIVATE cSerie805  :=CriaVar("DA_SERIE")
	PRIVATE aRotina    := { { "" , "        ", 0 , 3}}
	PRIVATE nPosLotCtl := 6
	PRIVATE nPosLote   := 7
	PRIVATE nPosdValid := 9
	PRIVATE aProd      := {}
	
	#IFDEF TOP
		TCInternal(5,"*OFF")   // Desliga Refresh no Lock do Top
	#ENDIF
	
	//Montagem de um aHeader fixo para inclusao dos saldos         
	
	nUsado:=0
	aHeader:={}  
	dbSelectArea("SX3")
	dbSetOrder(1)
	dbSeek("SDA")
	While SX3->X3_Arquivo == "SDA" .And. !SX3->(EOF())
		 
		If Trim(SX3->X3_Campo) $ "DA_PRODUTO/DA_LOCAL"  // Campos que ficarao na GetDados.
			AAdd(aHeader, {Trim(SX3->X3_Titulo)     ,;
	 		                    SX3->X3_Campo       ,;
			                    SX3->X3_Picture     ,;
			                    SX3->X3_Tamanho     ,;
			                    SX3->X3_Decimal     ,;
			                    SX3->X3_Valid       ,;
			                    SX3->X3_Usado       ,;
			                    SX3->X3_Tipo        ,;
			                    SX3->X3_Arquivo     ,;
			                    SX3->X3_Context})
			
		       EndIf
		
		  SX3->(dbSkip())
	EndDO
	                 
	dbSelectArea("SX3")
	dbSetOrder(1)
	dbSeek("SDB")
	While SX3->X3_Arquivo == "SDB" .And. !SX3->(EOF())
		 
		If Trim(SX3->X3_Campo) $ "DB_QUANT/DB_LOCALIZ/DB_QTSEGUM"  // Campos que ficarao na GetDados.
			AAdd(aHeader, {Trim(SX3->X3_Titulo)     ,;
	 		                    SX3->X3_Campo       ,;
			                    SX3->X3_Picture     ,;
			                    SX3->X3_Tamanho     ,;
			                    SX3->X3_Decimal     ,;
			                    SX3->X3_Valid       ,;
			                    SX3->X3_Usado       ,;
			                    SX3->X3_Tipo        ,;
			                    SX3->X3_Arquivo     ,;
			                    SX3->X3_Context})
			
		EndIf
		
	 SX3->(dbSkip())
	EndDO
	
	IF UPPER(ALLTRIM(aHeader[3][2])) == 'DB_LOCAL'
		
		ADEL(aHeader, 3)
		ASIZE(aHeader, 5)
		
	ENDIF
	
	dbSelectArea("SX3")
	dbSetOrder(1)
	dbSeek("SDA")
	While SX3->X3_Arquivo == "SDA" .And. !SX3->(EOF())
		 
		If Trim(SX3->X3_Campo) $ "DA_LOTECTL/DA_NUMLOTE"  // Campos que ficarao na GetDados.
			AAdd(aHeader, {Trim(SX3->X3_Titulo)     ,;
	 		                    SX3->X3_Campo       ,;
			                    SX3->X3_Picture     ,;
			                    SX3->X3_Tamanho     ,;
			                    SX3->X3_Decimal     ,;
			                    SX3->X3_Valid       ,;
			                    SX3->X3_Usado       ,;
			                    SX3->X3_Tipo        ,;
			                    SX3->X3_Arquivo     ,;
			                    SX3->X3_Context})
			
		       EndIf
		
		  SX3->(dbSkip())
	EndDO
	
	dbSelectArea("SX3")
	dbSetOrder(1)
	dbSeek("SDB")
	While SX3->X3_Arquivo == "SDB" .And. !SX3->(EOF())
		 
		If Trim(SX3->X3_Campo) $ "DB_NUMSERI"  // Campos que ficarao na GetDados.
			AAdd(aHeader, {Trim(SX3->X3_Titulo)     ,;
	 		                    SX3->X3_Campo       ,;
			                    SX3->X3_Picture     ,;
			                    SX3->X3_Tamanho     ,;
			                    SX3->X3_Decimal     ,;
			                    SX3->X3_Valid       ,;
			                    SX3->X3_Usado       ,;
			                    SX3->X3_Tipo        ,;
			                    SX3->X3_Arquivo     ,;
			                    SX3->X3_Context})
			
		       EndIf
		
		  SX3->(dbSkip())
	EndDO
	
	dbSelectArea("SX3")
	dbSetOrder(1)
	dbSeek("SB8")
	While SX3->X3_Arquivo == "SB8" .And. !SX3->(EOF())
		 
		If Trim(SX3->X3_Campo) $ "B8_DTVALID"  // Campos que ficarao na GetDados.
			AAdd(aHeader, {Trim(SX3->X3_Titulo)     ,;
	 		                    SX3->X3_Campo       ,;
			                    SX3->X3_Picture     ,;
			                    SX3->X3_Tamanho     ,;
			                    SX3->X3_Decimal     ,;
			                    SX3->X3_Valid       ,;
			                    SX3->X3_Usado       ,;
			                    SX3->X3_Tipo        ,;
			                    SX3->X3_Arquivo     ,;
			                    SX3->X3_Context})
			
		       EndIf
		
		  SX3->(dbSkip())
	EndDO
	
	//Montagem do ACols                                            
	aCols:={}
	aCols:={{CriaVar("DA_PRODUTO"),CriaVar("DA_LOCAL"),CriaVar("DB_LOCALIZ"),CriaVar("DB_QUANT"),CriaVar("DB_QTSEGUM"),CriaVar("DA_LOTECTL"),CriaVar("DA_NUMLOTE"),CriaVar("DB_NUMSERI"),dDataBase,.F.}}
	                   
	aCols[1][1] := SBE->BE_CODPRO   //DA_PRODUTO
	aCols[1][2] := SBE->BE_LOCAL    //DA_LOCAL
	aCols[1][3] := SBE->BE_LOCALIZ  //DB_LOCALIZ
	aCols[1][4] := TRC->B2_QATU     //DB_QUANT
	aCols[1][5] := 0                //DB_QTSEGUM
	aCols[1][6] := ''               //DA_LOTECTL
	aCols[1][7] := ''               //DA_NUMLOTE
	aCols[1][8] := ''               //DB_NUMSERI
	
	dbSelectArea(cAlias)
	
	//ATIVA tecla F4 para comunicacao com Saldos dos Lotes       
	
	Set Key VK_F4 TO ShowF4()
	nOpca := 0   
	
	IF lRet == .T.
		A805Linok()  
		
	ELSE 
		RETURN(NIL)
		
	ENDIF		
	
	IF lRet == .T.
		A805TudOk()
		
	ELSE 
		RETURN(NIL)
			
	ENDIF		
	
	//DESATIVA tecla F4 para comunicacao com Saldos dos Lotes      
	Set Key VK_F4 TO
	
	//Executa gravacao dos saldos no SBF                           
	
	nOpca := 1 // alteração will
	
	If nOpca == 1
		Processa({|lEnd| MA805Process(@lEnd)},STR0010,STR0011,.F.) //"Saldos por Localizacao"###"Criando saldos no SBF..."
	EndIf
	
Return(NIL)

/*/{Protheus.doc} Static Function MA805Process
	Processa a inclusao de saldos por localizacao fisica no SBF
	@type  Function
	@author Rodrigo de A. Sartorio
	@since 13/09/2000
	@version 01
	
/*/

Static Function MA805Process(lEnd)

	// Obtem numero sequencial do movimento
	LOCAL cNumSeq:=ProxNum(),i
	// Numero do Item do Movimento
	Local cCounter	:=	StrZero(0,TamSx3('DB_ITEM')[1])
	
	ProcRegua(Len(aCols))
	
	// Varre o ACols gravando o SDB
	For i:=1 to Len(aCols)
		IncProc()
		If !(aCols[i,Len(aCols[i])])
			cCounter := Soma1(cCounter)
			
			//Cria registro de movimentacao por Localizacao (SDB)           
			
			CriaSDB(aCols[i,1],;	// Produto
					aCols[i,2],;	// Armazem
					aCols[i,4],;	// Quantidade
					aCols[i,3],;	// Localizacao
					aCols[i,8],;	// Numero de Serie
					cDoc805,;		// Doc
					cSerie805,;		// Serie
					"",;			// Cliente / Fornecedor
					"",;			// Loja
					"",;			// Tipo NF
					"ACE",;			// Origem do Movimento
					dDataBase,;		// Data
					aCols[i,6],;	// Lote
					If(Rastro(aCols[i,1],"S"),aCols[i,7],""),; // Sub-Lote
					cNumSeq,;		// Numero Sequencial
					"499",;			// Tipo do Movimento
					"M",;			// Tipo do Movimento (Distribuicao/Movimento)
					cCounter,;		// Item
					.F.,;			// Flag que indica se e' mov. estorno
					0,;				// Quantidade empenhado
					aCols[i,5])		// Quantidade segunda UM
			
			//Soma saldo em estoque por localizacao fisica (SBF)            
			
			GravaSBF("SDB")
		EndIf
	Next i

Return(NIL)

/*/{Protheus.doc} Static Function A805LinOK
	Valida linha da GetDados do programa CRIALOC
	@type  Function
	@author Rodrigo de A. Sartorio
	@since 13/09/2000
	@version 01
	
/*/

Static Function A805Linok()

	Local aAreaAnt   := GetArea()
	Local cMsg1      := STR0022 //'O campo'
	Local cMsg2      := STR0023 //'deve ser preenchido'
	Local cMsg3      := STR0024 //'na criacao de Saldos por Endereco.'
	Local cCod       := ''
	Local cArmazem   := ''
	Local cEndereco  := ''
	Local cNumSeri   := ''
	Local cLote      := ''
	Local cSubLote   := ''
	Local cPicSB2    := ''
	Local cPicSB8    := ''
	Local cPicQtd    := ''
	Local cSeekSBF   := ''
	Local cSeek      := ''
	Local lRastro    := .F.
	Local lRastroS   := .F.
	Local lEndereca  := .F.
	Local nPosCod    := 0
	Local nPosArm    := 0
	Local nPosEnd    := 0
	Local nPosNSer   := 0
	Local nPosLote   := 0
	Local nPosSLote  := 0
	Local nPosQt2UM  := 0
	Local nQuant     := 0
	Local nQuant2UM  := 0
	Local nQuantTot  := 0
	Local nSaldoSB8  := 0
	Local nSaldoSBF  := 0
	Local nSaldoSB2  := 0
	Local nX         := 0
	Local nAchou     := 0
	
	Do While .T.
		
		//Valida se a linha do aCols esta deletada                     
		
		If aCols[n,Len(aCols[n])]
			Exit
		EndIf
		cCod      := If((nPosCod:=aScan(aHeader,{|x|Upper(Alltrim(x[2]))=='DA_PRODUTO'}))>0,aCols[n,nPosCod],'')	
		cArmazem  := If((nPosArm:=aScan(aHeader,{|x|Upper(Alltrim(x[2]))=='DA_LOCAL'}))>0,aCols[n,nPosArm],'')
		cEndereco := If((nPosEnd:=aScan(aHeader,{|x|Upper(Alltrim(x[2]))=='DB_LOCALIZ'}))>0,aCols[n,nPosEnd],'')
		cNumSeri  := If((nPosNSer:=aScan(aHeader,{|x|Upper(Alltrim(x[2]))=='DB_NUMSERI'}))>0,aCols[n,nPosNSer],'')
		cLote     := If((nPosLote:=aScan(aHeader,{|x|Upper(Alltrim(x[2]))=='DA_LOTECTL'}))>0,aCols[n,nPosLote],'')
		cSubLote  := If((nPosSLote:=aScan(aHeader,{|x|Upper(Alltrim(x[2]))=='DA_NUMLOTE'}))>0,aCols[n,nPosSLote],'')
		nQuant    := If((nPosQuant:=aScan(aHeader,{|x|Upper(Alltrim(x[2]))=='DB_QUANT'}))>0,aCols[n,nPosQuant],0)
		nQuant2UM := If((nPosQt2UM:=aScan(aHeader,{|x|Upper(Alltrim(x[2]))=='DB_QTSEGUM'}))>0,aCols[n,nPosQt2UM],0)	
		cPicSB2   := PesqPictQt('B2_QATU')
		cPicSB8   := PesqPictQt('B8_SALDO')
		cPicQtd   := If(nPosQuant>0,aHeader[nPosQuant,3],PesqPicQt('B2_QATU'))
		
		//Valida na linha o preench.e a exist. de campos obrigatorios  
		
		cCampos := If(nPosCod==0.Or.Empty(cCod),AllTrim(RetTitle('DA_PRODUTO')),'')
		cCampos += If(nPosArm==0.Or.Empty(cArmazem),If(!Empty(cCampos),', ','')+AllTrim(RetTitle('DA_LOCAL')),'')
		cCampos += If(nPosEnd==0.Or.Empty(cEndereco),If(!Empty(cCampos),', ','')+AllTrim(RetTitle('DB_LOCALIZ')),'')
		cCampos += If(nPosQuant==0.Or.QtdComp(nQuant)==Qtdcomp(0),If(!Empty(cCampos),', ','')+AllTrim(RetTitle('DB_QUANT')),'')
		If !Empty(cCampos)
			If At(', ',cCampos) > 0
				cMsg1   := STR0025 //'Os campos'
				cMsg2   := STR0026 //'devem ser preenchidos'
				cCampos := Stuff(cCampos, RAt(', ', cCampos), (Len(STR0027)-1), STR0027) //' e '###' e '
			EndIf
			Aviso('MATA805', cMsg1+' '+cCampos+' '+cMsg2+' '+cMsg3, {'Ok'})
			lRet := .F.
			Exit
		EndIf
		lRastro   := Rastro(cCod)
		lRastroS  := Rastro(cCod, 'S')
		lEndereca := .T. //Localiza(cCod)
		If !lEndereca
			Aviso('MATA805', STR0028+AllTrim(cCod)+'.', {'Ok'}) //'O Controle de Enderecamento nao foi ativado para o produto '
			lRet := .F.
			Exit
		ElseIf !Empty(cNumSeri) .And. !(QtdComp(nQuant)==QtdComp(1))
			Help(' ',1,'QUANTSERIE')
			lRet := .F.
			Exit
		EndIf
		If (lRastro.And.Empty(cLote)) .Or. (lRastroS.and.(Empty(cLote).Or.Empty(cSubLote)))
			Help(' ',1,'A240NUMLOT')
			lRet := .F.
			Exit
		EndIf
		
		//Verifica se o Produto possui Saldo Fisico Disponivel         
		
		If lRet   
		
			If TRC->B2_QEMP > 0
				If (Aviso(UPPER(STR0001)+" !!!",STR0040 + AllTrim(Transform(TRC->B2_QEMP,cPicSB2)) + "." + Chr(13) + Chr(13) + STR0041,{STR0042,STR0043})==1)  //ATENCAO ###"Produto com saldo empenhado de "###"Deseja Continuar o Processo ?"###"Sim"###"Nao"
					nSaldoSB2 := TRC->B2_QATU
				Else
					lRet := .F.
				EndIf
			Else
				nSaldoSB2 := TRC->B2_QATU
			EndIf
	
			
			For nX := 1 to Len(aCols)
				If !aCols[nX,Len(aCols[nX])] .And. cCod+cArmazem==aCols[nX, nPosCod]+aCols[nX, nPosArm]
					nQuantTot += aCols[nX, nPosQuant]
				EndIf
			Next nX
			nSaldoSBF := SaldoSBF(cArmazem, Nil, cCod, Nil, If(lRastro, cLote, Nil), If(lRastroS, cSubLote, Nil))
			If QtdComp(nSaldoSB2-nSaldoSBF) < QtdComp(nQuantTot)
				Aviso('MATA805', STR0029+AllTrim(cCod)+STR0030+AllTrim(cArmazem)+STR0031+Chr(13)+STR0032+AllTrim(Transform(nSaldoSB2-nSaldoSBF, cPicSB2))+STR0033+AllTrim(Transform(nQuantTot, cPicQtd))+'.', {'Ok'}) //'O Produto '###', do Armazem '###', nao possui Saldo em Estoque disponivel para criacao de Saldos por Endereco.'###'O Saldo disponivel para Enderecamento e de '###', e voce esta tentando Enderecar '
				lRet := .F.
				Exit
			EndIf
		EndIf
		
		//Verifica se o Produto possui Saldo por Lote/Slote Disponivel 
		
		If lRet .And. lRastro
			nSaldoSB8 := SaldoLote(cCod, cArmazem, cLote, cSubLote, Nil, Nil, Nil,dDataBase)
			nQuantTot := 0
			nSaldoSBF := 0
			For nX := 1 to Len(aCols)
				If !aCols[nX,Len(aCols[nX])] .And. cCod+cArmazem+cLote+If(lRastroS,cSubLote,'')==aCols[nX, nPosCod]+aCols[nX, nPosArm]+aCols[nx, nPosLote]+If(lRastroS,aCols[nX, nPosSLote],'')
					nQuantTot += aCols[nX, nPosQuant]
				EndIf
			Next nX
			nSaldoSBF := SaldoSBF(cArmazem, Nil, cCod, Nil, If(lRastro, cLote, Nil), If(lRastroS, cSubLote, Nil))
			If QtdComp(nSaldoSB8-nSaldoSBF) < QtdComp(nQuantTot)
				Aviso('MATA805', STR0029+AllTrim(cCod)+STR0030+AllTrim(cArmazem)+STR0034+AllTrim(cLote)+If(lRastroS,STR0035+AllTrim(cSubLote),'')+STR0036+Chr(13)+STR0032+AllTrim(Transform(nSaldoSB8-nSaldoSBF, cPicSB8))+STR0033+AllTrim(Transform(nQuantTot, cPicQtd))+'.', {'Ok'}) //'O Produto '###', do Armazem '###', nao possui saldo em Estoque no Lote '###'/ Sublote '###' disponivel para a criacao de Saldos po Endereco.'###'O Saldo disponivel para Enderecamento e de '###', e voce esta tentando Enderecar '
				lRet := .F.
				Exit
			EndIf
		EndIf
		
		//Verifica se o Endereco suporta a Quantidade da Linha do aCols
		
		If lRet
			lRet := Capacidade(cArmazem, cEndereco,(nQuant+SaldoSBF(cArmazem, cEndereco, cCod, cNumSeri)), cCod)
		EndIf
	
		//Valida quantidade IGUAL A 1 quando usa numero de serie       
		
		If lRet
			lRet:=MtAvlNSer(cCod,cNumSeri,nQuant,nQuant2UM)
		EndIf
	
		//Verifica se j  nao existe um numero de serie p/ este produto 
		//neste almoxarifado.                                          
		
		If lRet .And. !Empty(cNumSeri)
			dbSelectArea("SBF")
			dbSetOrder(1)
			cSeek:=xFilial("SBF")+cArmazem+cEndereco+cCod+cNumSeri+cLote+cSubLote
			nAchou:=ASCAN(aCols,{|x| !x[Len(x)] .And. x[nPosNSer] == aCols[n,nPosNSer] })
			If (nAchou > 0 .And. nAchou # n) .Or. dbSeek(cSeek)
				Help(" ",1,"NUMSERIEEX")
				lRet:=.F.
			EndIf
		EndIf
		
		Exit
	EndDo
	
	RestArea(aAreaAnt)

Return(lRet)

/*/{Protheus.doc} Static Function A805TudOk
	Valida a GetDados do programa CRIALOC
	@type  Function
	@author Fernando Joly Siquini
	@since 14/02/2002
	@version 01
/*/

Static Function A805TudOk()

	Local aAreaAnt   := GetArea()
	Local aSaldoSB2  := {}
	Local aSaldoSB8  := {}
	Local aSaldoSBF  := {}
	Local cMsg1      := STR0022 //'O campo'
	Local cMsg2      := STR0023 //'deve ser preenchido'
	Local cMsg3      := STR0024 //'na criacao de Saldos por Endereco.'
	Local cMsgItem   := ''
	Local cMsgItem1  := STR0037 //' (Item numero '
	Local cMsgItem2  := STR0038 //' do Documento)'
	Local cSeekSBF   := ''
	Local cCod       := ''
	Local cArmazem   := ''
	Local cEndereco  := ''
	Local cNumSeri   := ''
	Local cLote      := ''
	Local cSubLote   := ''
	Local cPicSB2    := ''
	Local cPicSB8    := ''
	Local cPicQtd    := ''
	Local lRastro    := .F.
	Local lRastroS   := .F.
	Local lEndereca  := .F.
	Local nPosCod    := 0
	Local nPosArm    := 0
	Local nPosEnd    := 0
	Local nPosNSer   := 0
	Local nPosLote   := 0
	Local nPosSLote  := 0
	Local nX         := 0
	Local nQuant     := 0
	Local nSaldoSB2  := 0
	Local nSaldoSB8  := 0
	Local nSaldoSBF  := 0
	Local aAreaSDB   := SDB->(GetArea())
	
	nPosCod   := aScan(aHeader,{|x|Upper(Alltrim(x[2]))=='DA_PRODUTO'})
	nPosArm   := aScan(aHeader,{|x|Upper(Alltrim(x[2]))=='DA_LOCAL'})
	nPosEnd   := aScan(aHeader,{|x|Upper(Alltrim(x[2]))=='DB_LOCALIZ'})
	nPosNSer  := aScan(aHeader,{|x|Upper(Alltrim(x[2]))=='DB_NUMSERI'})
	nPosLote  := aScan(aHeader,{|x|Upper(Alltrim(x[2]))=='DA_LOTECTL'})
	nPosSLote := aScan(aHeader,{|x|Upper(Alltrim(x[2]))=='DA_NUMLOTE'})
	nPosQuant := aScan(aHeader,{|x|Upper(Alltrim(x[2]))=='DB_QUANT'})
	cPicSB2   := PesqPictQt('B2_QATU')
	cPicSB8   := PesqPictQt('B8_SALDO')
	cPicQtd   := If(nPosQuant>0,aHeader[nPosQuant,3],PesqPicQt('B2_QATU'))
	
	//Valida a existencia de campos obrigatorios                   
	
	cCampos := If(nPosCod==0,AllTrim(RetTitle('DA_PRODUTO')),'')
	cCampos += If(nPosArm==0,If(!Empty(cCampos),', ','')+AllTrim(RetTitle('DA_LOCAL')),'')
	cCampos += If(nPosEnd==0,If(!Empty(cCampos),', ','')+AllTrim(RetTitle('DB_LOCALIZ')),'')
	cCampos += If(nPosQuant==0,If(!Empty(cCampos),', ','')+AllTrim(RetTitle('DB_QUANT')),'')
	If !Empty(cCampos)
		If At(', ',cCampos) > 0
			cMsg1   := STR0025 //'Os campos'
			cMsg2   := STR0026 //'devem ser preenchidos'
			cCampos := Stuff(cCampos, RAt(', ', cCampos), (Len(STR0027)-1), STR0027) //' e '###' e '
		EndIf
		Aviso('MATA805', cMsg1+' '+cCampos+' '+cMsg2+' '+cMsg3, {'Ok'})
		lRet := .F.
	EndIf
	
	If lRet
		For nX := 1 to Len(aCols)
			If !aCols[nX,Len(aCols[nX])]
				cMsgItem  := If(Len(aCols)>1,cMsgItem1+StrZero(nX, Len(aCols))+cMsgItem2,'')
				cCod      := aCols[nX,nPosCod]
				cArmazem  := aCols[nX,nPosArm]
				cEndereco := aCols[nX,nPosEnd]
				cNumSeri  := If(nPosNSer>0,aCols[nX,nPosNSer],'')
				cLote     := If(nPosLote>0,aCols[nX,nPosLote],'')
				cSubLote  := If(nPosSLote>0,aCols[nX,nPosSLote],'')
				nQuant    := If(nPosQuant>0,aCols[nX,nPosQuant],0)
				
				//Valida o preenchimento de campos obrigatorios                
				
				cCampos := If(Empty(cCod),AllTrim(RetTitle('DA_PRODUTO')),'')
				cCampos += If(Empty(cArmazem),If(!Empty(cCampos),', ','')+AllTrim(RetTitle('DA_LOCAL')),'')
				cCampos += If(Empty(cEndereco),If(!Empty(cCampos),', ','')+AllTrim(RetTitle('DB_LOCALIZ')),'')
				cCampos += If(QtdComp(nQuant)==Qtdcomp(0),If(!Empty(cCampos),', ','')+AllTrim(RetTitle('DB_QUANT')),'')
				If !Empty(cCampos)
					If At(', ',cCampos) > 0
						cMsg1   := STR0025 //'Os campos'
						cMsg2   := STR0026 //'devem ser preenchidos'
						cCampos := Stuff(cCampos, RAt(', ', cCampos), (Len(STR0027)-1), STR0027) //' e '###' e '
					EndIf
					Aviso('MATA805', cMsg1+' '+cCampos+' '+cMsg2+' '+cMsg3+cMsgItem, {'Ok'})
					lRet := .F.
					Exit
				EndIf
				lRastro   := Rastro(cCod)
				lRastroS  := Rastro(cCod, 'S')
				lEndereca := .T. //Localiza(cCod)
				If !lEndereca
					Aviso('MATA805', STR0028+AllTrim(cCod)+'.'+cMsgItem, {'Ok'}) //'O Controle de Enderecamento nao foi ativado para o produto '
					lRet := .F.
					Exit
				ElseIf !Empty(cNumSeri) .And. !(QtdComp(nQuant)==QtdComp(1))
					Help(' ',1,'QUANTSERIE')
					lRet := .F.
					Exit
				EndIf
				If (lRastro.And.Empty(cLote)) .Or. (lRastroS.and.(Empty(cLote).Or.Empty(cSubLote)))
					Help(' ',1,'A240NUMLOT')
					lRet := .F.
					Exit
				EndIf
				If lRet
					SDB->(dbSetOrder(7))
					If SDB->(dbSeek(xFilial("SDB")+cCod+cDoc805+cSerie805+Criavar("DB_CLIFOR",.F.)+Criavar("DB_LOJA",.F.)))
						Help(" ",1,"a24101")
						lRet:=.F.
						Exit
					EndIf
				EndIf
				
				//Armazena as Quantidades Distribuidas para analise do SB2     
				
				If (nPos:=aScan(aSaldoSB2, {|x|x[1]+x[2]==cCod+cArmazem}))>0
					aSaldoSB2[nPos, 3] += nQuant
				Else
					aAdd(aSaldoSB2, {cCod, cArmazem, nQuant})
				EndIf
				
				// Armazena as Quantidades Distribuidas para analise do SBF     
				
				If (nPos:=aScan(aSaldoSBF, {|x|x[1]+x[2]+x[3]+x[4]==cCod+cArmazem+cEndereco+cNumSeri}))>0
					aSaldoSBF[nPos, 5] += nQuant
				Else
					aAdd(aSaldoSBF, {cCod, cArmazem, cEndereco, cNumSeri, nQuant})
				EndIf
				If lRastro
					
					// Armazena as Quantidades Distribuidas para analise no SB8     
					
					If (nPos:=aScan(aSaldoSB8, {|x|x[1]+x[2]+x[3]+If(lRastroS,x[4],'')==cCod+cArmazem+cLote+If(lRastroS,cSubLote,'')}))>0
						aSaldoSB8[nPos, 5] += nQuant
					Else
						aAdd(aSaldoSB8, {cCod, cArmazem, cLote, cSubLote, nQuant})
					EndIf
				EndIf
			EndIf
		Next nX
	EndIf
	
	//Verifica se o Produto possui Saldo Fisico para Distribuicao  
	
	If lRet
		For nX := 1 to Len(aSaldoSB2)
			nSaldoSB2 := 0
			nSaldoSBF := 0
			
			If TRC->B2_QATU >= 0 //SB2->(MsSeek(xFilial('SB2')+aSaldoSB2[nX, 1]+aSaldoSB2[nX, 2], .F.))
				nSaldoSB2 := TRC->B2_QATU
				nSaldoSBF := SaldoSBF(aSaldoSB2[nX, 2], Nil, aSaldoSB2[nX, 1], Nil)
				If QtdComp(nSaldoSB2-nSaldoSBF) < QtdComp(aSaldoSB2[nX, 3])
					Aviso('MATA805', STR0029+AllTrim(aSaldoSB2[nX, 1])+STR0030+AllTrim(aSaldoSB2[nX, 2])+STR0031+Chr(13)+STR0032+AllTrim(Transform(nSaldoSB2-nSaldoSBF, cPicSB2))+STR0033+AllTrim(Transform(aSaldoSB2[nX, 3], cPicQtd))+'.', {'Ok'}) //'O Produto '###', do Armazem '###', nao possui Saldo em Estoque disponivel para criacao de Saldos por Endereco.'###'O Saldo disponivel para Enderecamento e de '###', e voce esta tentando Enderecar '
					lRet := .F.
					Exit
				EndIf
			Else
				Aviso('MATA805', STR0029+AllTrim(aSaldoSB2[nX, 1])+STR0039+AllTrim(aSaldoSB2[nX, 2])+'.', {'Ok'}) //'O Produto '###'nao possui saldo em estoque do Armazem '
				lRet := .F.
				Exit
			EndIf
		Next nX
	EndIf
	
	//Valida se o Produto possui Saldo por Lote a ser Distribuido  
	
	If lRet
		For nX := 1 to Len(aSaldoSB8)
			nSaldoSB8 := SaldoLote(aSaldoSB8[nX, 1], aSaldoSB8[nX, 2], aSaldoSB8[nX, 3], aSaldoSB8[nX, 4], Nil, Nil, Nil,dDataBase)
			If QtdComp(nSaldoSB8) < QtdComp(aSaldoSB8[nX, 5])
				lRastroS := Rastro(aSaldoSB8[nX, 1], 'S')
				Aviso('MATA805', STR0029+AllTrim(aSaldoSB8[nX, 1])+STR0030+AllTrim(aSaldoSB8[nX, 2])+STR0034+AllTrim(aSaldoSB8[nX, 3])+If(lRastroS,STR0035+AllTrim(aSaldoSB8[nX, 4]),'')+STR0036+Chr(13)+STR0032+AllTrim(Transform(nSaldoSB8, cPicSB8))+STR0033+AllTrim(Transform(aSaldoSB8[nX, 5], cPicQtd))+'.', {'Ok'}) //'O Produto '###', do Armazem '###', nao possui saldo em Estoque no Lote '###'/ Sublote '###' disponivel para a criacao de Saldos po Endereco.'###'O Saldo disponivel para Enderecamento e de '###', e voce esta tentando Enderecar '
				lRet := .F.
				Exit
			EndIf
		Next nX
	EndIf
	
	//Verifica se o Endereco possui capacidade para a Qtd Total    
	
	If lRet
		For nX := 1 to Len(aSaldoSBF)
			nSaldoSBF := SaldoSBF(aSaldoSBF[nX, 2], aSaldoSBF[nX, 3], aSaldoSBF[nX, 1], aSaldoSBF[nX, 4])
			If !(lRet:=Capacidade(aSaldoSBF[nX, 2], aSaldoSBF[nX, 3],(aSaldoSBF[nX, 5]+nSaldoSBF), aSaldoSBF[nX, 1]))
				Exit
			EndIf
		Next nX
	EndIf	
	SDB->(RestArea(aAreaSDB))
	RestArea(aAreaAnt)
	
Return(lRet)

/*/{Protheus.doc} Static Function A805Segum
	Converte segunda UNIDADE DE MEDIDA
	@type  Function
	@author Rodrigo de A. Sartorio
	@since 13/09/2000
	@version 01
/*/

Static Function A805Segum(nAtual)

	If nAtual == 1
		aCols[n,5]:=ConvUm(aCols[n,1],&(ReadVar()),aCols[n,5],2)
	ElseIf nAtual == 2
		aCols[n,4]:=ConvUm(aCols[n,1],aCols[n,4],&(ReadVar()),1)
	EndIf

RETURN .T.

/*/{Protheus.doc} Static Function SHOWF4
	Chamada da funcao F4LOTE e F4LOCALIZ
	@type  Function
	@author Nereu Humberto Junior
	@since 22/01/2007
	@version 01
/*/

Static Function ShowF4()

	If (Alltrim(ReadVar()) $ "M->DA_LOTECTL/M->DA_NUMLOTE")
		F4Lote(,,,"A650",aCols[n,1],aCols[n,2])
	EndIf
	
Return Nil 

STATIC Function SaldoSBF(cAlmox,cLocaliza,cCod,cNumSerie,cLoteCtl,cLote,lBaixaEmp,cEstFis,lPotMax,cOP)

	Local cAlias:=Alias(),nRecno:=Recno(),nOrder:=IndexOrd(),nRecnoSBF
	Local aAreaSB8:=SB8->(GetArea())
	Local nRet:=0,cSeek:="",cCompara:="",nOrderSbf
	Local cAliasSBF:="SBF",cQuery:=""
	Local lQuery := .F.
	Local aSldEmp := {}
	
	DEFAULT cEstFis := ""
	DEFAULT lPotMax := .F.
	DEFAULT cOP     := ""
	
	cLocaliza  := If(cLocaliza==Nil.Or.Empty(cLocaliza), CriaVar('BF_LOCALIZ', .F.), cLocaliza)
	cNumSerie  := If(cNumSerie==Nil.Or.Empty(cNumSerie), CriaVar('BF_NUMSERI', .F.), cNumSerie)
	cLoteCtl   := If(cLoteCtl==Nil .Or.Empty(cLoteCtl) , CriaVar('BF_LOTECTL', .F.), cLoteCtl)
	cLote      := If(cLote==Nil    .Or.Empty(cLote)    , CriaVar('BF_NUMLOTE', .F.), cLote)
	lBaixaEmp  := If(!(ValType(lBaixaEmp)=='L'), .F., lBaixaEmp)
	lPotMax    := (lPotMax.And.PotencLote(cCod))
	
	dbSelectArea("SBF")
	nRecnoSbF:=Recno()
	nOrderSbf:=IndexOrd()
	#IFDEF TOP
		lQuery    :=.T.
		SBF->(dbCommit())
		cAliasSBF := "SALDOSBF"
		cQuery    := "SELECT * FROM "+RetSqlName("SBF")+" SBF WHERE SBF.BF_FILIAL ='"+xFilial("SBF")+"' AND "
		// Considera endereco e numero de serie no filtro
		If !Empty(cLocaliza+cNumSerie)
			cQuery += "SBF.BF_LOCALIZ ='"+cLocaliza+"' AND SBF.BF_NUMSERI='"+cNumSerie+"' AND "
		EndIf
		// Considera Lote no filtro
		If !Empty(cLoteCtl)
			cQuery += "SBF.BF_LOTECTL ='"+cLoteCtl+"' AND "
		EndIf
		// Considera sub-lote no filtro
		If !Empty(cLote)
			cQuery += "SBF.BF_NUMLOTE ='"+cLote+"' AND "
		EndIf
		// Considera Estrutura fisica no filtro
		If !Empty(cEstFis)
			cQuery +="SBF.BF_ESTFIS ='"+cEstFis+"' AND " 
		EndIf	
		cQuery += "SBF.BF_PRODUTO ='"+cCod+"' AND SBF.BF_LOCAL='"+cAlmox+"' AND SBF.D_E_L_E_T_=' ' ORDER BY "+SqlOrder(SBF->(IndexKey())) 
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSBF,.T.,.T.)
		aEval(SBF->(dbStruct()), {|x| If(x[2] <> "C", TcSetField(cAliasSBF,x[1],x[2],x[3],x[4]),Nil)})
	#ELSE
		If !Empty(cLocaliza+cNumSerie)
			dbSetOrder(1)
			cSeek:=xFilial('SBF')+cAlmox+cLocaliza+cCod+cNumSerie
			cCompara:="BF_FILIAL+BF_LOCAL+BF_LOCALIZ+BF_PRODUTO+BF_NUMSERI"
			If !Empty(cLoteCtl)
				cSeek+=cLoteCtl
				cCompara+="+BF_LOTECTL"
				If !Empty(cLote)
					cSeek+=cLote
					cCompara+="+BF_NUMLOTE"
				EndIf
			EndIf
		Else
			dbSetOrder(2)
			cSeek:=xFilial('SBF')+cCod+cAlmox
			cCompara:="BF_FILIAL+BF_PRODUTO+BF_LOCAL"
			If !Empty(cLoteCtl)
				cSeek+=cLoteCtl
				cCompara+="+BF_LOTECTL"
				If !Empty(cLote)
					cSeek+=cLote
					cCompara+="+BF_NUMLOTE"
				EndIf
			EndIf
		EndIf
		dbSeek(cSeek)
	#ENDIF
	Do While !Eof() .And. If(!lQuery,cSeek == &(cCompara),.T.)
		If !lQuery .And. (!Empty(cEstFis) .And. !(cEstFis == (cAliasSBF)->BF_ESTFIS))
			dbSkip()
			Loop
		EndIf
		If !Empty(cOP)
			aSldEmp := (cAliasSBF)->(SldEmpOP(BF_PRODUTO,BF_LOCAL,BF_LOTECTL,BF_NUMLOTE,cOP,BF_LOCALIZ,BF_NUMSERI,"L"))
		EndIf
		If lPotMax
			SB8->(dbSetOrder(3))
			If Rastro((cAliasSBF)->BF_PRODUTO,"L")
				SB8->(dbSeek(xFilial("SB8")+(cAliasSBF)->BF_PRODUTO+(cAliasSBF)->BF_LOCAL+(cAliasSBF)->BF_LOTECTL))
			ElseIf Rastro((cAliasSBF)->BF_PRODUTO,"S")
				SB8->(dbSeek(xFilial("SB8")+(cAliasSBF)->BF_PRODUTO+(cAliasSBF)->BF_LOCAL+(cAliasSBF)->BF_LOTECTL+(cAliasSBF)->BF_NUMLOTE))
			EndIf
			nRet+=A250PotMax((cAliasSBF)->BF_PRODUTO,SB8->B8_POTENCI,SBFSaldo(lBaixaEmp,cAliasSBF))
		Else
			nRet+=SBFSaldo(lBaixaEmp,cAliasSBF) + If(!Empty(cOP),aSldEmp[1],0)
		EndIf
		dbSkip()
	EndDo
	
	//fecha query criada
	
	If lQuery
		dbSelectArea(cAliasSBF)
		dbCloseArea()
	EndIf
	
Return nRet