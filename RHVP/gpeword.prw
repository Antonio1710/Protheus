#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH" 
#INCLUDE "MSOLE.CH"
#INCLUDE "GPEWORD.CH"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Programa    ³ GPEWORD  ³ Autor ³Marinaldo de Jesus     ³ Data ³  05/07/00  ³
//ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´
//³Descri‡„o   ³ Impressao de Documentos tipo Word                            ³
//ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
//³Sintaxe     ³ Chamada padrao para programas em RdMake.                     ³
//ÃÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
//³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL                  ³
//ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
//³Programador ³Data      ³ FNC            ³Motivo da Alteracao               ³
//ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
//³Raquel Hager|14/10/2013³         M12RH01³Projeto Unificacao Folha de Paga- ³
//³        	   ³          ³         RQ0317³mento - Remocao de ajustas         ³ 
//³Christiane V|17/06/2013³TPUSEP   ³Correção da impressão dos         		  ³
//³        	   ³          ³         ³dependentes.                      		  ³
//³Renan Borges³18/08/2014³TQFCTS	³Ajuste na impressao da descricao 		  ³ 
//³            ³          ³         ³da função.						 		  ³  
//³Marcia Moura³04/09/2014³TQMI75	³Alterado o nome dos valids de perguntas  ³
//³Mariana M.  ³12/06/2015³TSPCXJ	³Ajuste para que ao gerar a integração    ³
//³            ³ 		  ³      	³com o Word, o sistema mostre arquivos    ³ 
//³            ³ 		  ³      	³.DOT ou .DOTX	                          ³
//³Matheus M.  ³12/02/2016³TUHKCM	³Ajuste para permitir a impressão do mês  ³
//³            ³ 		  ³      	³de admissão do funcionário por extenso.  ³
//³M. Silveira ³07/11/2016³TWLMEI	³Ajuste para obter o Centro de Custo da   ³
//³            ³ 		  ³      	³tabela CTT e nao utilizar mais a SI3.    ³
//³Cícero Alves³18/05/2017³DRHPAG-	³Retirada alteração na SX1				  ³
//³            ³ 		  ³1859		³										  ³ 
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
User Function GPEWORD()

Local   cCampo  	:= ""
Local	oDlg		:= Nil  
Local 	cMsgDic		:= ""	// Mensagem para validacao de dicionario de dados
// Declaracao de arrays para dimensionar tela		                         
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords	:= {}
Local aGDCoord		:= {}

Private	cPerg	:= "GPWORD"
Private aInfo	:= {}
Private aDepenIR:= {}
Private aDepenSF:= {}
Private aPerSRF := {}
Private nDepen	:= 0
Private lDepSf	:= Iif(SRA->(FieldPos("RA_DEPSF"))>0,.T.,.F.)

	// Tratando os espacos do novo tamanho do X1_GRUPO
	cPerg	:= cPerg + (Space( Len(SX1->X1_GRUPO)  - Len(cPerg) ) )
	
	Pergunte(cPerg,.F.)
	     
	OpenProfile()
	
	// Avalia o conteudo ja existente no profile e o altera se necessario   
	// para que o erro nao ocorra apos a atualizacao do sistema            
	If ( ProfAlias->( DbSeek( SM0->M0_CODIGO + Padl( CUSERNAME, 13 ) + "GPWORD    ") ) )
		cCampo := SubStr( AllTrim( ProfAlias->P_DEFS ), 487, 75 )
		If !( ".DOT" $ UPPER( cCampo ) )
			RecLock( "ProfAlias", .F. )
			ProfAlias->P_DEFS := ""
			ProfAlias->( MsUnLock() )
		EndIf
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³         Grupo  Ordem Pergunta Portugues     Pergunta Espanhol  Pergunta Ingles Variavel Tipo Tamanho Decimal Presel  GSC Valid                              Var01      Def01         DefSPA1   DefEng1 Cnt01             Var02  Def02    		 DefSpa2  DefEng2	Cnt02  Var03 Def03      DefSpa3    DefEng3  Cnt03  Var04  Def04     DefSpa4    DefEng4  Cnt04  Var05  Def05       DefSpa5	 DefEng5   Cnt05  XF3   GrgSxg ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	// Monta as Dimensoes dos Objetos         					   
	aAdvSize		:= MsAdvSize()
	aAdvSize[5]	:=	(aAdvSize[5]/100) * 60	// Horizontal
	aAdvSize[6]	:=  (aAdvSize[6]/100) * 40	// Vertical
	aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 0 , 0 }
	aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
	aObjSize	:= MsObjSize( aInfoAdvSize , aObjCoords )
	aGdCoord	:= { (aObjSize[1,1]+3), (aObjSize[1,2]+5), (((aObjSize[1,3])/100)*20), (((aObjSize[1,4])/100)*59) }	// 1,3 Vertical /1,4 Horizontal
	
	DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0001) From aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] OF oMainWnd PIXEL  
		
		@ aGdCoord[1],aGdCoord[2] TO aGdCoord[3],aGdCoord[4] PIXEL
		@ aGdCoord[1]+10,aGdCoord[2]+10 SAY OemToAnsi(STR0002) PIXEL						 												
		@ aGdCoord[1]+20,aGdCoord[2]+10 SAY OemToAnsi(STR0003) PIXEL
	
		@ (((aObjSize[1,3])/100)*25),(aGdCoord[4]/2)-95 BMPBUTTON TYPE 5 ACTION Eval( { || Pergunte(cPerg,.T.) } )	
			
		@ (((aObjSize[1,3])/100)*25),(aGdCoord[4]/2)-60 BUTTON OemToAnsi(STR0004) SIZE 55,11 ACTION Eval( { || (ndepen:= 0,fVarW_Imp() ) }  )      
		@ (((aObjSize[1,3])/100)*25),(aGdCoord[4]/2)+5 BUTTON OemToAnsi(STR0005) SIZE 55,11 ACTION Eval( { || fWord_Imp() } )
		     
		@ (((aObjSize[1,3])/100)*25),(aGdCoord[4]/2)+70 BMPBUTTON TYPE 2 ACTION Close(oDlg)
	ACTIVATE DIALOG oDlg CENTERED

Return( Nil)

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Funcao    ³fWord_Imp ³ Autor ³ Marinaldo de Jesus    ³ Data ³ 05/07/00 ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descricao ³Impressao do Documento Word                                 ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Static Function fWord_Imp()
// Definindo Variaveis Locais                                             
Local oWord			:= NIL
Local cExclui		:= ""
Local cFilAnt   	:= Space(FWGETTAMFILIAL)
Local aCampos		:= {}
Local nX			:= 0
Local nSvOrdem		:= 0
Local nSvRecno		:= 0
Local cAcessaSRA	:= &( " { || " + ChkRH( "GPEWORD" , "SRA" , "2" ) + " } " )

// Carregando mv_par para Variaveis Locais do Programa                    
Local cFilDe		:= mv_par01
Local cFilAte		:= mv_par02
Local cCcDe			:= mv_par03
Local cCcAte		:= mv_par04
Local cMatDe		:= mv_par05
Local cMatAte		:= mv_par06
Local cNomeDe		:= mv_par07
Local cNomeAte		:= mv_par08
Local cTnoDe		:= mv_par09
Local cTnoAte		:= mv_par10
Local cFunDe		:= mv_par11
Local cFunAte		:= mv_par12
Local cSindDe		:= mv_par13
Local cSindAte		:= mv_par14
Local dAdmiDe		:= mv_par15
Local dAdmiAte		:= mv_par16
Local cSituacao		:= mv_par17
Local cCategoria	:= mv_par18
Local nCopias		:= If ( Empty(mv_par23),1,mv_par23 )
Local nOrdem		:= mv_par24
Local cArqWord		:= mv_par25
Local cAux			:= ""
Local cPath 		:= GETTEMPPATH()
Local nAt			:= 0
Local lDepende		:= If (Mv_par26 = 1, .T., .F.)
Local nDepende  	:= mv_par27
Local lImpress      := ( mv_par28 == 1 )
Local cArqSaida     := AllTrim( mv_par29 )
nDepen				:= If ( ! lDepende, 4,nDepende )

	// Checa o SO do Remote (1=Windows, 2=Linux)
	If GetRemoteType() == 2
		MsgAlert(OemToAnsi(STR0167), OemToAnsi(STR0168))	// "Integracao Word funciona somente com Windows !!!")###"Atencao !"
		Return	
	EndIf

	// Verifica se o usuario escolheu um drive local (A: C: D:) caso contrario
	// busca o nome do arquivo de modelo,  copia para o diretorio temporario  
	// do windows e ajusta o caminho completo do arquivo a ser impresso.     
	If Substr(cArqWord,2,1) <> ":"
		cAux 	:= cArqWord
		nAT		:= 1
		For nx := 1 to len(cArqWord)
			cAux := substr(cAux,If(nx==1,nAt,nAt+1),len(cAux))
			nAt := at("\",cAux)
			If nAt == 0
				Exit
			EndIf
		Next nx
		CpyS2T(cArqWord,cPath, .T.)
		cArqWord	:= cPath+cAux
	EndIf
	
	// Bloco que definira a Consistencia da Parametrizacao dos Intervalos 
	// selecionados nas Perguntas De? Ate?                                      
	cExclui := cExclui + "{ || "
	cExclui := cExclui + "(RA_FILIAL  < cFilDe     .or. RA_FILIAL  > cFilAte    ).or."
	cExclui := cExclui + "(RA_MAT     < cMatDe     .or. RA_MAT     > cMatAte    ).or." 
	cExclui := cExclui + "(RA_CC      < cCcDe      .or. RA_CC      > cCCAte     ).or." 
	cExclui := cExclui + "(RA_NOME    < cNomeDe    .or. RA_NOME    > cNomeAte   ).or." 
	cExclui := cExclui + "(RA_TNOTRAB < cTnoDe     .or. RA_TNOTRAB > cTnoAte    ).or." 
	cExclui := cExclui + "(RA_CODFUNC < cFunDe     .or. RA_CODFUNC > cFunAte    ).or." 
	cExclui := cExclui + "(RA_SINDICA < cSindDe    .or. RA_SINDICA > cSindAte   ).or." 
	cExclui := cExclui + "(RA_ADMISSA < dAdmiDe    .or. RA_ADMISSA > dAdmiAte   ).or." 
	cExclui := cExclui + "!(RA_SITFOLH$cSituacao).or.!(RA_CATFUNC$cCategoria)"
	cExclui := cExclui + " } "
	
	// Inicializa o Ole com o MS-Word 97 ( 8.0 )						      
	oWord	:= OLE_CreateLink() ; OLE_NewFile( oWord , cArqWord )

	dbSelectArea("SRB")
	nSBOrdem := IndexOrd() ; nSBRecno := Recno()
	dbGotop()
	
	dbSelectArea("SRA")
	nSvOrdem := IndexOrd() ; nSvRecno := Recno()
	dbGotop()


	// Posicionando no Primeiro Registro do Parametro               
	If nOrdem == 1	 	//Matricula
		dbSetOrder(nOrdem)
		dbSeek( cFilDe + cMatDe , .T. )
		cInicio := '{ || RA_FILIAL + RA_MAT }'
		cFim    := cFilAte + cMatAte
	ElseIf nOrdem == 2		//Centro de Custo
		dbSetOrder(nOrdem)
		dbSeek( cFilDe + cCcDe + cMatDe , .T. )
		cInicio  := '{ || RA_FILIAL + RA_CC + RA_MAT }'
		cFim     := cFilAte + cCcAte + cMatAte
	ElseIf nOrdem == 3							//Nome 
		dbSetOrder(nOrdem)
		dbSeek( cFilDe + cNomeDe + cMatDe , .T. )
		cInicio := '{ || RA_FILIAL + RA_NOME + RA_MAT }'
		cFim    := cFilAte + cNomeAte + cMatAte
	ElseIf nOrdem == 4							//Turno
		dbSetOrder(nOrdem)
		dbSeek( cFilDe + cTnoDe ,.T. )
		cInicio  := '{ || RA_FILIAL + RA_TNOTRAB } '
		cFim     := cFilAte + cCcAte + cNomeAte
	ElseIf nOrdem == 5							//Admissao
		cIndCond:= "RA_FILIAL + DTOS (RA_ADMISSA)"
	   	cArqNtx  := CriaTrab(Nil,.F.)
	   	IndRegua("SRA",cArqNtx,cIndCond,,,STR0162)		//"Selecionando Registros..."
		dbSeek( cFilDe + DTOS(dAdmiDe) ,.T. )
		cInicio  :='{ || RA_FILIAL + DTOS(RA_ADMISSA)}' 
		cFim     := cFilAte + DTOS(dAdmiAte)
	EndIf

	cFilialAnt := Space(FWGETTAMFILIAL)

	// Ira Executar Enquanto Estiver dentro do Escopo dos Parametros
	While SRA->( !Eof() .and. Eval( &(cInicio) ) <= cFim )
	
		// Consiste Parametrizacao do Intervalo de Impressao           
		If SRA->( Eval ( &(cExclui) ) )
	       dbSelectArea("SRA")
	       dbSkip()
	       Loop
	    EndIf
		    
	
		// Consiste Filiais e Acessos                                             
		If !( SRA->RA_FILIAL $ fValidFil() .and. Eval( cAcessaSRA ) )
			dbSelectArea("SRA")
	      		dbSkip()
	       		Loop
		EndIf 
		
		
		// Consiste os dependentes  de Salario Familia                            
		If lDepende
			If nDepende == 1 //Salario Familia 
				// Consiste os dependentes  de Salario Familia                            
				If SRB->(dbSeek(SRA->RA_Filial+SRA->RA_Mat,.F.))         
			    	fDepSF( )
				Else
					SRA->(dbSkip())
					Loop
				EndIf		
			ElseIf nDepende == 2 //Imposto de Renda
				//	Consiste os dependentes  de Imposto de Renda                           
	   			If SRB->(dbSeek(SRA->RA_Filial+SRA->RA_Mat,.F.))
		    		fDepIR( )
		    	Else
					SRA->(dbSkip())
					Loop
				EndIf	
			ElseIf nDepende == 3 // Todos os Tipos de Dependente (Salario Familia e Imposto de Renda 
				//	Consiste todos os tipos de Dependentes                            
	   			If SRB->(dbSeek(SRA->RA_Filial+SRA->RA_Mat,.F.))         
		       		fDepIR( )
		       	Else
					SRA->(dbSkip())
					Loop
				Endif
				If SRB->(dbSeek(SRA->RA_Filial+SRA->RA_Mat,.F.))         
		    		fDepSF( )
		    	Else                                                                         
					SRA->(dbSkip())
					Loop
				Endif	
			EndIf
		
			If (nDepende == 1)
				If  Empty(aDepenSF[1,1])
					SRA->(dbSkip())
					Loop
				Endif	
			ElseIf	(nDepende == 2)
				If  Empty(aDepenIR[1,1])
					SRA->(dbSkip())
					Loop
				EndIf	          
			ElseIf	(nDepende == 3)
				If  Empty(aDepenIR[1,1])  .And. Empty(aDepenSF[1,1])
					SRA->(dbSkip())
					Loop
				EndIf
			EndIf	                                                          
		EndIf	
				
		If cPaisLoc == "COL"
		   fPesqSRF( ) //Busca Periodo Aquisitivo para Colombia
		EndIf   
		
		// Carregando Informacoes da Empresa                           
		If SRA->RA_FILIAL # cFilialAnt
			If !fInfo(@aInfo,SRA->RA_FILIAL)
	   			// Encerra o Loop se Nao Carregar Informacoes da Empresa        
				Exit
			EndIf		
			// Atualiza a Variavel cFilialAnt                               
			dbSelectArea("SRA")
			cFilialAnt := SRA->RA_FILIAL
		EndIf	
	
	   		// Carrega Campos Disponiveis para Edicao                       
		aCampos := fCpos_Word()   
	
		// Ajustando as Variaveis do Documento                          
		Aeval(	aCampos																								,; 
				{ |x| OLE_SetDocumentVar( oWord, x[1]  																,;
											IF( Subst( AllTrim( x[3] ) , 4 , 2 )  == "->"          					,; 
												Transform( x[2] , PesqPict( Subst( AllTrim( x[3] ) , 1 , 3 )		,;
																			Subst( AllTrim( x[3] )  				,;
										        			         			  - ( Len( AllTrim( x[3] ) ) - 5 )	 ;	
										          								 )	  	 							 ; 
																	      )                                          ;
												         )															,; 
												Transform( x[2] , x[3] )                                     		 ;
				  	 						  ) 														 	 		 ; 
										)																			 ;
				}     																 							 	 ;
			 )
	        	
	
		// Atualiza as Variaveis                                        
	 	OLE_UpDateFields( oWord )
	
		// Imprimindo o Documento                                                 
		If lImpress
			For nX := 1 To nCopias
				OLE_SetProperty( oWord, '208', .F. ) ; OLE_PrintFile( oWord )
			Next nX
		Else
			OLE_SaveAsFile( oWord, cArqSaida )
		EndIf
		
		dbSelectArea("SRA")                                               
	 	dbSkip() 
	        
	  	//Iniciliaza array 
	    aDepenIR:= {}
	    aDepenSF:= {}
	    aPerSRF := {}
	
	Enddo
		

	// Encerrando o Link com o Documento                                      
	OLE_CloseLink( oWord )
	If Len(cAux) > 0
		fErase(carqword)
	EndIf
 
	// Restaurando dados de Entrada                                           
	dbSelectArea('SRA')
	dbSetOrder( nSvOrdem )
	dbGoTo( nSvRecno )

Return( Nil )

//ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
//³Funcao    ³ fOpen_Word ³ Autor ³ Marinaldo de Jesus  ³ Data ³ 06/05/00 ³
//ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
//³Descricao ³ Selecionaro os Arquivos do Word.                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
User Function fOpWord()

	Local cSvAlias		:= Alias()
	Local cTipo			:= STR0006
	Local cNewPathArq	:= cGetFile( cTipo , STR0007, , , , nOR(GETF_MULTISELECT, GETF_NETWORKDRIVE, GETF_LOCALHARD) )

	If !Empty( cNewPathArq )
		If Len( cNewPathArq ) > 75
			MsgAlert( STR0187 ) // "O endereco completo do local onde está o arquivo do Word excedeu o limite de 75 caracteres!"
			Return
		Else
			If  Upper( Subst( AllTrim( cNewPathArq ), - 3 ) ) == Upper( AllTrim( STR0008 ) )
				Aviso( STR0009 , cNewPathArq , { STR0010 } )
			ElseIf	Upper( Subst( AllTrim( cNewPathArq ), - 4 ) ) == Upper( AllTrim( STR0294 ) )
					Aviso( STR0009 , cNewPathArq , { STR0010 } )
			Else
				MsgAlert( STR0011 )
				Return
			EndIf
		EndIf
	Else
		Aviso(STR0012 ,STR0007,{ STR0010 } )//Aviso(STR0012 ,{ STR0010 } )
		Return
	EndIf

	// Limpa o parametro para a Carga do Novo Arquivo
	mv_par25 := cNewPathArq

	dbSelectArea( cSvAlias )

Return(.T.)


//ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
//³Funcao    ³ fVarW_Imp ³ Autor ³ Marinaldo de Jesus   ³ Data ³ 07/05/00 ³
//ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
//³Descricao ³ Impressao das Variaveis disponiveis para uso.              ³
//ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function fVarW_Imp()

	Local cString	:= 'SRA'
	Local aOrd		:= {STR0142,STR0143}
	Local cDesc1	:= STR0144
	Local cDesc2	:= STR0145
	Local cDesc3	:= STR0146
	Local Tamanho	:= "P"

	Private aReturn		:= {STR0147, 1,STR0148, 2, 2, 1, '',1 }  
	Private aLinha		:= {}
	Private nomeprog	:= 'GPEWORD' 
	Private cBtxt		:= ""
	Private AT_PRG		:= nomeProg
	Private wCabec0		:= 1
	Private wCabec1		:= STR0149
	Private wCabec2		:= ""
	Private wCabec3		:= ""
	Private nTamanho	:= "P"
	Private lEnd		:= .F.
	Private Titulo		:= cDesc1
	Private Li			:= 0
	Private ContFl		:= 1 
	Private nLastKey	:= 0

	// Envia controle para a funcao SetPrint
	WnRel := "WORD_VAR" 
	WnRel := SetPrint(cString,Wnrel,"",Titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,,nTamanho,,.F.)

	If nLastKey == 27
		Return( Nil )
	EndIf

	SetDefault(aReturn,cString)

	If nLastKey == 27
		Return( Nil )
	EndIf

	// Chamada do Relatorio.
	RptStatus( { |lEnd| fImpVar() } , Titulo )

Return( Nil)

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Funcao    ³ fImpVar  ³ Autor ³ Marinaldo de Jesus    ³ Data ³ 07/05/00 ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descricao ³ Impressao das Variaveis disponiveis para uso.              ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Static Function fImpVar()
Local nOrdem	:= aReturn[8]
Local aCampos	:= {}
Local nX		:= 0
Local cDetalhe	:= ""
Local cDescr	:= ""

	// Carregando Informacoes da Empresa                            
	If !fInfo(@aInfo,xFilial("SRA"))
		Return( Nil )
	EndIf			

	// Carregando Variaveis                                         
	aCampos := fCpos_Word()

	// Ordena aCampos de Acordo com a Ordem Selecionada                   
	If nOrdem = 1
		aSort( aCampos , , , { |x,y| x[1] < y[1] } )
	Else
		aSort( aCampos , , , { |x,y| x[4] < y[4] } )
	EndIf

	// Carrega Regua de Processamento                                      
	SetRegua( Len( aCampos ) )


	// Impressao do Relatorio                                             
	For nX := 1 To Len( aCampos )
	
		// Movimenta Regua Processamento                                      
		IncRegua()  
	
		// Cancela Impressao                                             
		If lEnd
			@ Prow()+1,0 PSAY cCancel
			Exit
		EndIf            
		
        // Mascara do Relatorio                                         
        //        10        20        30        40        50        60        70        80
        //12345678901234567890123456789012345678901234567890123456789012345678901234567890
		//Variaveis                      Descricao
		//XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

        // Carregando Variavel de Impressao                             
		cDescr := AllTrim( aCampos[nX,4] )

        // Imprimindo Relatorio                                         
        Impr( Padr(aCampos[nX,1],31) + Left(cDescr,50) )
        
		If Len(cDescr) > 50
	        Impr( Space(31) + SubStr(cDescr,51,50) )
		EndIf        

		If Len(cDescr) > 100
	        Impr( Space(31) + SubStr(cDescr,101,50) )
		EndIf        
	
	Next nX

	If aReturn[5] == 1
	   Set Printer To
	   dbCommit()
	   OurSpool(WnRel)
	EndIf   

	// Apaga indices temporarios
	If nOrdem == 5
		fErase( cArqNtx + OrdBagExt() )
	EndIf                      
	
	MS_FLUSH()

Return( Nil )

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Funcao    ³ fDepIR   ³ Autor ³R.H.                   ³ Data ³ 02/04/01 ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descricao ³ Carrega Dependentes de Imp. de Renda.                      ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Static Function fDepIR( )
Local Nx,nVezes

	// Consiste os dependentes  de I.R.                                       
	aDepenIR:= {}
	Do  while SRB->RB_FILIAL+SRB->RB_MAT == SRA->RA_FILIAL+SRA->RA_MAT
		If  (SRB->RB_TipIr == '1') .Or.;
         	(SRB->RB_TipIr == '2' .And. Year(dDataBase)-Year(SRB->RB_DtNasc) <= 21) .Or. ;
            (SRB->RB_TipIr == '3' .And. Year(dDataBase)-Year(SRB->RB_DtNasc) <= 24)
			//	Nome do Depend., Dta Nascimento,Grau de parentesco
      		aAdd(aDepenIR,{left(SRB->RB_Nome,30),SRB->RB_DtNasc,If(SRB->RB_GrauPar=='C','Conjuge   ',If(SRB->RB_GrauPar=='F','Filho     ','Outros    '))   })
        EndIf
        SRB->(dbSkip())
	EndDo 
	
	If  Len(aDepenIR) < 10
      	nVezes := (10 - Len(aDepenIR))
		For Nx := 1 to nVezes
			 aAdd(aDepenIR,{Space(30),Space(10),Space(10) } )
		Next Nx
	EndIf  
	
Return(aDepenIR)

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Funcao    ³ fDepSF   ³ Autor ³ Equipe RH             ³ Data ³ 02/04/01 ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descricao ³ Carrega Dependentes de Salario Familia.                    ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Static Function  fDepSF()
Local Nx,nVezes
	
	// Consiste os dependentes  de Sal. Fam.                                  
	aDepenSF:= {}
   	Do While SRB->RB_FILIAL+SRB->RB_MAT == SRA->RA_FILIAL+SRA->RA_MAT
		If (SRB->RB_TipSf == '1') .Or. (SRB->RB_TipSf == '2' .And. ;
			Year(dDAtABase) - Year(SRB->RB_DtNasc) <= 14)
			//Nome do Depend., Dta Nascimento,Grau Parent.,Local Nascimento,Cartorio,Numero Regr.,Numero do Livro, Numero da Folha, Data Entrega,Data baixa. //
      		aAdd(aDepenSF,{left(SRB->RB_Nome,30),SRB->RB_DtNasc,If(SRB->RB_GrauPar=='C','Conjuge   ',If(SRB->RB_GrauPar=='F','Filho     ','Outros    ')),;
      						SRB->RB_LOCNASC,SRB->RB_CARTORI,SRB->RB_NREGCAR,SRB->RB_NUMLIVR,SRB->RB_NUMFOLH,SRB->RB_DTENTRA,SRB->RB_DTBAIXA})
		EndIf
		SRB->(dbSkip())
	Enddo  
	
   	If  Len(aDepenSF) < 10
      	nVezes := (10 - Len(aDepenSF))
		For Nx := 1 to nVezes
			 aAdd(aDepenSF,{Space(30),Space(10),Space(10),Space(10),Space(10),Space(10),Space(10),Space(10),Space(10),Space(10) } )
		Next Nx
	EndIf

Return(aDepenSF)


/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Funcao    ³ fPesqSRF ³ Autor ³ Equipe RH             ³ Data ³ 05/01/09 ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descricao ³ Carrega Periodo Aquisitivo SRF.                            ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Static Function  fPesqSRF()
Local cAliasSRF := "SRF"        

	// Rotina de Busca Periodo Aquisitivo SRF 
	aPerSRF := {}	
	dbSelectArea(cAliasSRF)	
	dbSetOrder(RETORDER(cAliasSRF,"RF_FILIAL+RF_MAT+DTOS(RF_DATABAS") )	
	If dbSeek(SRA->RA_FILIAL+SRA->RA_MAT)   
		While !Eof() .And. SRF->RF_MAT == SRA->RA_MAT			       				
			If SRF->RF_STATUS == "1" // 1= Ativo					
				//Verifica se o Periodo Aberto não esta Expirado (3 Anos)
				nAnoExp := DDATABASE - SRF->RF_DATAFIM					
				If (nAnoExp < 1080 )          			
		           //Data Inicial Periodo de Ferias, Data Final Periodo de Ferias
      		           aAdd(aPerSRF,{SRF->RF_DATABAS,SRF->RF_DATAFIM } )
				Else
				   ( cAliasSRF )->( dbSkip(1) )
				   Loop
				EndIf 
				Exit
			EndIf 
		   ( cAliasSRF )->( dbSkip(1) )
		EndDo
	EndIf 
		
Return(aPerSRF)

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿
³Funcao    ³ fTarProf ³ Autor ³ Jonatas A. T. Alves   ³ Data ³ 18/02/11   ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´
³Descricao ³ Carrega Informacoes dos lancamentos de tarefas p/ professor. ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Static Function  fTarProf(dDtRef)
Local nI		:= 0
Local nP		:= 0
Local nCont		:= 0
Local nQtTar	:= 2	
Local aArea		:= GetArea()
Local aCpos		:= Array(nQtTar,0)
Local aRet		:= Array(nQtTar,0)
Local bTar		:= { || .T. }

DEFAULT dDtRef := SRA->RA_ADMISSA

	For nI := 1 To nQtTar
		aAdd( aCpos[nI], { "RO_DESTAR",	} )
		aAdd( aCpos[nI], { "RO_QTDSEM",	} )
		aAdd( aCpos[nI], { "RO_QUANT",	} )
		aAdd( aCpos[nI], { "RO_VALOR",	} )
		aAdd( aCpos[nI], { "RO_VALTOT",	} )
	Next

	// Professores mensalistas so considerar tarefas fixas
	If SRA->RA_CATFUNC == "I"
		bTar := { || SRO->RO_TIPO == "1" }
	EndIf

	dbSelectArea("SRO")
	If dbSeek( SRA->( RA_FILIAL + RA_MAT ) )
		While !Eof() .And. SRA->( RA_FILIAL + RA_MAT ) == SRO->( RO_FILIAL + RO_MAT ) .And. nCont < nQtTar
			If MesAno(SRO->RO_DATA) == MesAno(dDtRef) .And. Eval(bTar) // Filtra data de referencia e tarefas fixas
				if cPaisLoc == "BRA"
					If SRO->RO_TPALT == "001" .And. SRO->RO_QUANT > 0 		// Considera apenas salario Inicial e despreza se for h.e./falta
						nCont++
						For nP := 1 To Len( aCpos[1] )
							If aCpos[nCont][nP][1] == "RO_DESTAR"
								aCpos[nCont][nP][2] := fDescTarefa(SRO->RO_CODTAR)
							Else
								aCpos[nCont][nP][2] := SRO->( &( aCpos[nCont][nP][1] ) )
							EndIf
						Next
					EndIf
				EndIf
			EndIf
			dbSkip()
		EndDo
	EndIf

	For nI := 1 To nQtTar
		aEval( aCpos[nI], { |x| aAdd( aRet[nI], x[2] ) } )
	Next

	RestArea( aArea )

Return( aRet )


//ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
//³Funcao    ³ fCpos_Word ³ Autor ³ Marinaldo de Jesus    ³ Data ³ 06/07/00 ³
//ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
//³Descricao ³ Retorna Array com as Variaveis Disponiveis para Impressao.   ³
//ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
//³          ³ aExp[x,1] - Variavel Para utilizacao no Word (Tam Max. 30)   ³
//³          ³ aExp[x,2] - Conteudo do Campo                (Tam Max. 49)   ³
//³          ³ aExp[x,3] - Campo para Pesquisa da Picture no X3 ou Picture  ³
//³          ³ aExp[x,4] - Descricao da Variaval                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
STATIC Function fCpos_Word()
Local aExp			:= {}
Local aRet			:= {}
Local cTexto_01		:= AllTrim( mv_par19 )
Local cTexto_02		:= AllTrim( mv_par20 )
Local cTexto_03		:= AllTrim( mv_par21 )
Local cTexto_04		:= AllTrim( mv_par22 ) 
Local cApoderado	:= ""
Local cRamoAtiv		:= ""   
Local cEstCiv		:= "" //Estado Civil para DCN/DMN - PIS
Local cTipCertd		:= "" //Tipo de Certidao Civil para DCN/DMN - PIS
Local cGrauInstr	:= "" //Grau de Instrucao conforme DCN/DMN - PIS
Local cTipNIS		:= ""

Local cDESMTSS		:=""
Local cDESCCSS		:=""
Local cDESINS		:=""
Local cDESCAN		:=""
Local cDESCIC		:=""
Local cDESJOR		:=""
Local cDESFON		:=""

Local cCodMunLP		:= ""
Local cCodReqFun	:= ""
Local cCodAtiv		:= ""

	If cPaisLoc == "BRA"
		cTipNIS := MV_PAR30  //Pergunte exclusivo do Brasil // Tipo PIS - DCN/DMN
	EndIf

	If cPaisLoc == "ARG"
		If fPHist82(xFilial(),"99","01")
			cApoderado := SubStr(SRX->RX_TXT,1,30)
		EndIf
		If fPHist82(xFilial(),"99","02")
			cRamoAtiv := SubStr(SRX->RX_TXT,1,50) 
		EndIf	           
	EndIf	

	aAdd( aExp, {'GPE_FILIAL'			   		,	SRA->RA_FILIAL 										  	, "SRA->RA_FILIAL"			,STR0013	} ) 
	aAdd( aExp, {'GPE_MATRICULA'		   		,	SRA->RA_MAT												, "SRA->RA_MAT"				,STR0014	} ) 
	aAdd( aExp, {'GPE_CENTRO_CUSTO'		   		,	SRA->RA_CC												, "SRA->RA_CC"				,STR0015	} ) 
	aAdd( aExp, {'GPE_DESC_CCUSTO'		   		,	fDesc("CTT",SRA->RA_CC,"CTT_DESC01")		 				, "@!"						,STR0016	} ) 
	aAdd( aExp, {'GPE_NOME'		   		   		,	SRA->RA_NOME											, "SRA->RA_NOME"			,STR0017	} ) 
	aAdd( aExp, {'GPE_NOMECMP'           		,   SRA->RA_NOMECMP											, "@!"           			,STR0017 	} )
	aAdd( aExp, {'GPE_CPF'		   				,	SRA->RA_CIC												, "SRA->RA_CIC"				,STR0018	} ) 
	aAdd( aExp, {'GPE_PIS'		   				,	SRA->RA_PIS												, "SRA->RA_PIS"				,STR0019	} ) 
	aAdd( aExp, {'GPE_RG'		   		   		,	SRA->RA_RG												, "SRA->RA_RG"				,STR0020	} ) 
	aAdd( aExp, {'GPE_RG_ORG'	   		   		,	SRA->RA_RGORG											, "@!"						,STR0152	} ) 
	aAdd( aExp, {'GPE_RG_ORGUF'	   		   		,	SRA->RA_RGUF											, "@!"						,STR0241	} ) 
	aAdd( aExp, {'GPE_CTPS'				   		,	SRA->RA_NUMCP							 				, "SRA->RA_NUMCP"			,STR0021	} ) 
	aAdd( aExp, {'GPE_SERIE_CTPS'				,	SRA->RA_SERCP							 				, "SRA->RA_SERCP"			,STR0022	} ) 
	aAdd( aExp, {'GPE_UF_CTPS'			   		,	SRA->RA_UFCP							 				, "SRA->RA_UFCP"			,STR0023	} ) 
	aAdd( aExp, {'GPE_CNH'   	  		   		,	SRA->RA_HABILIT							 				, "SRA->RA_HABILIT"			,STR0024	} ) 
	aAdd( aExp, {'GPE_RESERVISTA'		   		,	SRA->RA_RESERVI							 				, "SRA->RA_RESERVI"			,STR0025	} ) 
	aAdd( aExp, {'GPE_TIT_ELEITOR' 		   		,	SRA->RA_TITULOE							 				, "SRA->RA_TITULOE"			,STR0026	} ) 
	aAdd( aExp, {'GPE_ZONA_SECAO'  		   		,	SRA->RA_ZONASEC							 				, "SRA->RA_ZONASEC"			,STR0027	} ) 
	aAdd( aExp, {'GPE_ENDERECO'			   		,	SRA->RA_ENDEREC							 				, "SRA->RA_ENDEREC"			,STR0028	} ) 
	aAdd( aExp, {'GPE_COMP_ENDER'		   		,	SRA->RA_COMPLEM							 				, "SRA->RA_COMPLEM"			,STR0029	} )	

	If cPaisLoc == "PER"
		aAdd( aExp, {'GPE_BAIRRO'				,	RetContUbigeo("SRA->RA_CEP", "RA_BAIRRO") 				, "@!"						,STR0030	} ) 
		aAdd( aExp, {'GPE_MUNICIPIO'			,	RetContUbigeo("SRA->RA_CEP", "RA_MUNICIP") 				, "@!"						,STR0031	} )
		aAdd( aExp, {'GPE_DESC_ESTADO'			,	RetContUbigeo("SRA->RA_CEP", "RA_DEPARTA")				, "@!"						,STR0033	} )	
	Else
		aAdd( aExp, {'GPE_BAIRRO'				,	SRA->RA_BAIRRO							 				, "SRA->RA_BAIRRO"			,STR0030	} ) 
		aAdd( aExp, {'GPE_MUNICIPIO'			,	SRA->RA_MUNICIP							 				, "SRA->RA_MUNICIP"			,STR0031	} )	
	EndIf

	If cPaisLoc <> "PER"  
		aAdd( aExp, {'GPE_ESTADO'				,	SRA->RA_ESTADO											, "SRA->RA_ESTADO"			,STR0032	} )	
		aAdd( aExp, {'GPE_DESC_ESTADO'			,	fDesc("SX5","12"+SRA->RA_ESTADO,"X5_DESCRI")			, "@!"						,STR0033	} ) 
	EndIf
   
	aAdd( aExp, {'GPE_CEP'		   				,	SRA->RA_CEP												, "SRA->RA_CEP"				,STR0034	} ) 
	aAdd( aExp, {'GPE_TELEFONE'	   				,	SRA->RA_TELEFON										   	, "SRA->RA_TELEFON"			,STR0035	} ) 
	aAdd( aExp, {'GPE_NOME_PAI'	   		   		,	SRA->RA_PAI												, "SRA->RA_PAI"				,STR0036	} ) 
	aAdd( aExp, {'GPE_NOME_MAE'	   		   		,	SRA->RA_MAE											   	, "SRA->RA_MAE"				,STR0037	} ) 
	aAdd( aExp, {'GPE_COD_SEXO'	   				,	SRA->RA_SEXO											, "SRA->RA_SEXO"			,STR0038	} ) 
  //	aAdd( aExp, {'GPE_DESC_SEXO'   		   		,	SRA->(IF(RA_SEXO ="M","Masculino","Feminino"))			, "@!"						,STR0039	} ) 
  
	If cPaisLoc <> "ARG"
		aAdd( aExp, {'GPE_EST_CIVIL'  			,	SRA->RA_ESTCIVI											, "SRA->RA_ESTCIVI"			,STR0040	} ) 
	Else	
		aAdd( aExp, {'GPE_EST_CIVIL'  			,	fDesc("SX5","33"+SRA->RA_ESTCIVI,"X5DESCRI()")	   		, "SRA->RA_ESTCIVI"			,STR0040	} ) 
	EndIf
	
	aAdd( aExp, {'GPE_COD_NATURALIDADE'	   		,	If(SRA->RA_NATURAL # " ",SRA->RA_NATURAL," ")	    	, "SRA->RA_NATURAL"			,STR0041	} ) 
	aAdd( aExp, {'GPE_DESC_NATURALIDADE'		,	fDesc("SX5","12"+SRA->RA_NATURAL,"X5_DESCRI")			, "@!"						,STR0042	} ) 
	aAdd( aExp, {'GPE_COD_NACIONALIDADE'		,	SRA->RA_NACIONA											, "SRA->RA_NACIONA"			,STR0043	} ) 
	aAdd( aExp, {'GPE_DESC_NACIONALIDADE'  		,	fDesc("SX5","34"+SRA->RA_NACIONA,"X5_DESCRI")			, "@!"						,STR0044	} ) 
   
	If cPaisLoc <> "EQU"
		aAdd( aExp, {'GPE_ANO_CHEGADA' 			,	SRA->RA_ANOCHEG											, "SRA->RA_ANOCHEG"			,STR0045	} )
	EndIf

	aAdd( aExp, {'GPE_DEP_IR'   				,	SRA->RA_DEPIR										 	, "SRA->RA_DEPIR"			,STR0046	} )	
	
	If lDepSf
		aAdd( aExp, {'GPE_DEP_SAL_FAM'			,	SRA->RA_DEPSF											, "SRA->RA_DEPSF"			,STR0047 	} )
	EndIf   

	aAdd( aExp, {'GPE_DATA_NASC'  		   		,	SRA->RA_NASC											, "SRA->RA_NASC"			,STR0048	} )
	aAdd( aExp, {'GPE_DATA_ADMISSAO'			,	SRA->RA_ADMISSA											, "SRA->RA_ADMISSA"			,STR0049	} )
	aAdd( aExp, {'GPE_DIA_ADMISSAO' 	   		,	StrZero( Day( SRA->RA_ADMISSA ) , 2 )					, "@!"						,STR0050	} )
	aAdd( aExp, {'GPE_MES_ADMISSAO'		   		,	StrZero( Month( SRA->RA_ADMISSA ) , 2 )					, "@!"						,STR0051 	} )
	aAdd( aExp, {'GPE_ANO_ADMISSAO'				,	StrZero( Year( SRA->RA_ADMISSA ) , 4 )					, "@!"						,STR0052	} )
	aAdd( aExp, {'GPE_DT_OP_FGTS'  				,	SRA->RA_OPCAO											, "SRA->RA_OPCAO"			,STR0053	} )
	aAdd( aExp, {'GPE_DATA_DEMISSAO'	   		,	SRA->RA_DEMISSA											, "SRA->RA_DEMISSA"			,STR0054	} ) 
   
	If cPaisLoc <> "EQU"
		aAdd( aExp, {'GPE_DATA_EXPERIENCIA'		,	SRA->RA_VCTOEXP											, "SRA->RA_VCTOEXP"			,STR0055	} )
		aAdd( aExp, {'GPE_DIA_EXPERIENCIA' 		,	StrZero( Day( SRA->RA_VCTOEXP ) , 2 )					, "@!"						,STR0056	} )
		aAdd( aExp, {'GPE_MES_EXPERIENCIA'		,	StrZero( Month( SRA->RA_VCTOEXP ) , 2 )					, "@!"						,STR0057	} )
		aAdd( aExp, {'GPE_ANO_EXPERIENCIA'		,	StrZero( Year( SRA->RA_VCTOEXP ) , 4 ) 					, "@!"						,STR0058	} )
		aAdd( aExp, {'GPE_DIAS_EXPERIENCIA'		,	StrZero(SRA->(RA_VCTOEXP-RA_ADMISSA)+1,03)				, "@!"						,STR0059	} )
		aAdd( aExp, {'GPE_DATA_EXPERIENCIA2'	,	SRA->RA_VCTEXP2											, "SRA->RA_VCTEXP2"			,STR0245	} )
		aAdd( aExp, {'GPE_DIA_EXPERIENCIA2' 	,	StrZero( Day( SRA->RA_VCTEXP2 ) , 2 )					, "@!"						,STR0246	} )
		aAdd( aExp, {'GPE_MES_EXPERIENCIA2'		,	StrZero( Month( SRA->RA_VCTEXP2 ) , 2 )					, "@!"						,STR0247	} )
		aAdd( aExp, {'GPE_ANO_EXPERIENCIA2'		,	StrZero( Year( SRA->RA_VCTEXP2 ) , 4 ) 					, "@!"						,STR0248	} )
		aAdd( aExp, {'GPE_DIAS_EXPERIENCIA2'	,	StrZero(SRA->(RA_VCTEXP2-RA_ADMISSA)+1,03)				, "@!"						,STR0249	} )
		aAdd( aExp, {'GPE_DATA_EX_MEDIC'		,	SRA->RA_EXAMEDI											, "SRA->RA_EXAMEDI"			,STR0060	} )
	EndIf

	aAdd( aExp, {'GPE_BCO_AG_DEP_SAL'	   		, 	SRA->RA_BCDEPSA											, "SRA->RA_BCDEPSA"			,STR0061	} )
	aAdd( aExp, {'GPE_DESC_BCO_SAL'		   		, 	fDesc("SA6",SRA->RA_BCDEPSA,"A6_NOME")					, "@!"						,STR0062	} )
	aAdd( aExp, {'GPE_DESC_AGE_SAL'		   		, 	fDesc("SA6",SRA->RA_BCDEPSA,"A6_NOMEAGE")				, "@!"						,STR0063	} )
	aAdd( aExp, {'GPE_CTA_DEP_SAL'		   		,	SRA->RA_CTDEPSA											, "SRA->RA_CTDEPSA"			,STR0064	} )
	aAdd( aExp, {'GPE_BCO_AG_FGTS'				,	SRA->RA_BCDPFGT											, "SRA->RA_BCDPFGT"			,STR0065	} )
	aAdd( aExp, {'GPE_DESC_BCO_FGTS'	   		, 	fDesc("SA6",SRA->RA_BCDPFGT,"A6_NOME")					, "@!"						,STR0066	} )
	aAdd( aExp, {'GPE_DESC_AGE_FGTS'	   		, 	fDesc("SA6",SRA->RA_BCDPFGT,"A6_NOMEAGE")				, "@!"						,STR0067	} )
	aAdd( aExp, {'GPE_CTA_Dep_FGTS'		   		,	SRA->RA_CTDPFGT											, "SRA->RA_CTDPFGT"			,STR0068	} )
	aAdd( aExp, {'GPE_SIT_FOLHA'	  	   		,	SRA->RA_SITFOLH											, "SRA->RA_SITFOLH"			,STR0069	} )
	aAdd( aExp, {'GPE_DESC_SIT_FOLHA'  			,	fDesc("SX5","30"+SRA->RA_SITFOLH,"X5_DESCRI")			, "@!"						,STR0070	} )
	aAdd( aExp, {'GPE_HRS_MENSAIS'		   		,	SRA->RA_HRSMES											, "SRA->RA_HRSMES"			,STR0071	} )
	aAdd( aExp, {'GPE_HRS_SEMANAIS'				,	SRA->RA_HRSEMAN											, "SRA->RA_HRSEMAN"			,STR0072	} )
	aAdd( aExp, {'GPE_CHAPA'		  	   		,	SRA->RA_CHAPA											, "SRA->RA_CHAPA"			,STR0073	} )
	aAdd( aExp, {'GPE_TURNO_TRAB'	 	   		,	SRA->RA_TNOTRAB											, "SRA->RA_TNOTRAB"			,STR0074	} )
	aAdd( aExp, {'GPE_DESC_TURNO'	  			,	fDesc('SR6',SRA->RA_TNOTRAB,'R6_DESC',,SRA->RA_FILIAL)	, "@!"						,STR0075	} )
	aAdd( aExp, {'GPE_COD_FUNCAO'	 			,	SRA->RA_CODFUNC											, "SRA->RA_CODFUNC"			,STR0076 	} )
	aAdd( aExp, {'GPE_DESC_FUNCAO'				,	fDesc('SRJ',SRA->RA_CODfUNC,'RJ_DESC',,SRA->RA_FILIAL)	, "@!"						,STR0077	} )
	aAdd( aExp, {'GPE_CBO'			   	   		,	fCodCBO(SRA->RA_FILIAL,SRA->RA_CODFUNC,dDataBase)		, "@!"				        ,STR0078	} )
	aAdd( aExp, {'GPE_CONT_SINDIC'		   		,	SRA->RA_PGCTSIN											, "SRA->RA_PGCTSIN"			,STR0079	} )
	aAdd( aExp, {'GPE_COD_SINDICATO'			,	SRA->RA_SINDICA											, "SRA->RA_SINDICA"			,STR0080	} )
	aAdd( aExp, {'GPE_DESC_SINDICATPO'	   		,	AllTrim( fDesc("RCE",SRA->RA_SINDICA,"RCE_DESCRI",40) ), "@!"						,STR0081	} )
	aAdd( aExp, {'GPE_COD_ASS_MEDICA'			,	SRA->RA_ASMEDIC											, "SRA->RA_ASMEDIC"			,STR0082	} )
	aAdd( aExp, {'GPE_DEP_ASS_MEDICA'			,	SRA->RA_DPASSME											, "SRA->RA_DPASSME"			,STR0083	} )
	aAdd( aExp, {'GPE_ADIC_TEMP_SERVIC'			,	SRA->RA_ADTPOSE											, "SRA->RA_ADTPOSE"			,STR0084	} )
	aAdd( aExp, {'GPE_COD_CESTA_BASICA'			,	SRA->RA_CESTAB											, "SRA->RA_CESTAB"			,STR0085	} )
	aAdd( aExp, {'GPE_COD_VALE_REF' 			,	SRA->RA_VALEREF											, "SRA->RA_VALEREF"			,STR0086	} )

	If cPaisLoc $ ("ANG/ARG/BOL/BRA/CHI/COL/EQU/MEX/PER")
		aAdd( aExp, {'GPE_COD_SEG_VIDA' 		,	SRA->RA_SEGUROV											, "SRA->RA_SEGUROV"			,STR0087	} )
	EndIf     
	
	aAdd( aExp, {'GPE_%ADIANTAM'	 			,	SRA->RA_PERCADT											, "SRA->RA_PERCADT"			,STR0089	} )
	aAdd( aExp, {'GPE_CATEG_FUNC'	  	   		,	SRA->RA_CATFUNC											, "SRA->RA_CATFUNC"			,STR0090	} )
	aAdd( aExp, {'GPE_DESC_CATEG_FUNC'			,	fDesc("SX5","28"+SRA->RA_CATFUNC,"X5_DESCRI")			, "@!"						,STR0091	} )
	aAdd( aExp, {'GPE_POR_MES_HORA'		   		,	SRA->(IF(RA_CATFUNC$"H","P/Hora",IF(RA_CATFUNC$"J","P/Aula","P/Mes"))) 			, "@!"						,STR0092	} )
	aAdd( aExp, {'GPE_TIPO_PAGTO'  				,	SRA->RA_TIPOPGT								 			, "SRA->RA_TIPOPGT"			,STR0093	} )
	aAdd( aExp, {'GPE_DESC_TIPO_PAGTO'  		,	fDesc("SX5","40"+SRA->RA_TIPOPGT,"X5_DESCRI")			, "@!"						,STR0094	} )
	aAdd( aExp, {'GPE_SALARIO'		   	   		,	SRA->RA_SALARIO											, "SRA->RA_SALARIO"			,STR0095	} )
	
	If cPaisLoc <> "EQU"
		aAdd( aExp, {'GPE_SAL_BAS_DISS'			,	SRA->RA_ANTEAUM											, "SRA->RA_ANTEAUM"			,STR0096	} )
	EndIf  
	
	aAdd( aExp, {'GPE_HRS_PERICULO'  			,	SRA->RA_PERICUL											, "SRA->RA_PERICUL"			,STR0099	} )
	aAdd( aExp, {'GPE_HRS_INS_MINIMA'			,	SRA->RA_INSMIN											, "SRA->RA_INSMIN"			,STR0100	} )
	aAdd( aExp, {'GPE_HRS_INS_MEDIA'			,	SRA->RA_INSMED											, "@!"						,STR0101	} )
	aAdd( aExp, {'GPE_HRS_INS_MAXIMA'			,	SRA->RA_INSMAX											, "SRA->RA_INSMAX"			,STR0102	} )
	aAdd( aExp, {'GPE_TIPO_ADMISSAO'			,	SRA->RA_TIPOADM											, "SRA->RA_TIPOADM"			,STR0103	} )
	aAdd( aExp, {'GPE_DESC_TP_ADMISSAO'			,	fDesc("SX5","38"+SRA->RA_TIPOADM,"X5_DESCRI")			, "@!"						,STR0104	} )
	aAdd( aExp, {'GPE_COD_AFA_FGTS'		   		,	SRA->RA_AFASFGT											, "SRA->RA_AFASFGT"			,STR0105	} )
	aAdd( aExp, {'GPE_DESC_AFA_FGTS'	   		,	fDesc("SX5","30"+SRA->RA_AFASFGT,"X5_DESCRI")			, "@!"						,STR0106	} )

	If cPaisLoc <> "PER"
		aAdd( aExp, {'GPE_VIN_EMP_RAIS'			,	SRA->RA_VIEMRAI											, "SRA->RA_VIEMRAI"			,STR0107	} )
		aAdd( aExp, {'GPE_DESC_VIN_EMP_RAIS'	,	fDesc("SX5","25"+SRA->RA_VIEMRAI,"X5_DESCRI")			, "@!"						,STR0108	} )
	EndIf

	aAdd( aExp, {'GPE_COD_INST_RAIS'			,	SRA->RA_GRINRAI											, "SRA->RA_GRINRAI"			,STR0109	} )
	aAdd( aExp, {'GPE_DESC_GRAU_INST'			,	fDesc("SX5","26"+SRA->RA_GRINRAI,"X5_DESCRI")			, "@!"						,STR0110	} )
	aAdd( aExp, {'GPE_COD_RESC_RAIS'	   		,	SRA->RA_RESCRAI											, "SRA->RA_RESCRAI"			,STR0111	} )
	aAdd( aExp, {'GPE_CRACHA'		  	   		,	SRA->RA_CRACHA											, "SRA->RA_CRACHA"			,STR0112	} )
	aAdd( aExp, {'GPE_REGRA_APONTA'		   		,	SRA->RA_REGRA											, "SRA->RA_REGRA"			,STR0113	} )
	aAdd( aExp, {'GPE_NO_REGISTRO'	 	   		,	SRA->RA_REGISTR											, "SRA->RA_REGISTR"			,STR0115	} )
	aAdd( aExp, {'GPE_NO_FICHA'	    	   		,	SRA->RA_FICHA											, "SRA->RA_FICHA"			,STR0116	} )
	aAdd( aExp, {'GPE_TP_CONT_TRAB'		   		,	SRA->RA_TPCONTR											, "SRA->RA_TPCONTR"			,STR0117	} )
	aAdd( aExp, {'GPE_DESC_TP_CONT_TRAB'		,	SRA->(IF(RA_TPCONTR="1","Indeterminado","Determinado")), "@!"						,STR0118	} )
	aAdd( aExp, {'GPE_APELIDO'		   			,	SRA->RA_APELIDO											, "SRA->RA_APELIDO"			,STR0119	} )
	aAdd( aExp, {'GPE_E-MAIL'		 			,	SRA->RA_EMAIL											, "SRA->RA_EMAIL"			,STR0120	} )
	aAdd( aExp, {'GPE_TEXTO_01'			   		,	cTexto_01								   				, "@!"						,STR0121	} ) 
	aAdd( aExp, {'GPE_TEXTO_02'					,	cTexto_02												, "@!"						,STR0122	} )
	aAdd( aExp, {'GPE_TEXTO_03'					,	cTexto_03												, "@!"						,STR0123	} )
	aAdd( aExp, {'GPE_TEXTO_04'					,	cTexto_04												, "@!"						,STR0124	} )
	aAdd( aExp, {'GPE_EXTENSO_SAL'		   		,	Extenso( SRA->RA_SALARIO , .F. , 1 )					, "@!"						,STR0125 	} )
	aAdd( aExp, {'GPE_DDATABASE'				,	dDataBase                    	        				, "" 						,STR0126	} )
	aAdd( aExp, {'GPE_DIA_DDATABASE'			,	StrZero( Day( dDataBase ) , 2 )            				, "@!"						,STR0127	} )
	aAdd( aExp, {'GPE_MES_DDATABASE'			,	MesExtenso( dDataBase ) 								, "@!"						,STR0128	} )
	aAdd( aExp, {'GPE_ANO_DDATABASE'			,	StrZero( Year( dDataBase ) , 4 )            			, "@!"						,STR0129	} )
	aAdd( aExp, {'GPE_NOME_EMPRESA' 			,	aInfo[03]                              					, "@!"						,STR0130	} )
	aAdd( aExp, {'GPE_END_EMPRESA'				,	aInfo[04]                              					, "@!"						,STR0131	} )
	aAdd( aExp, {'GPE_CID_EMPRESA'		   		,	aInfo[05]                              					, "@!"						,STR0132	} )
	aAdd( aExp, {'GPE_CEP_EMPRESA'         		,   aInfo[07]                                              	, "!@R #####-###"          	,STR0034 	} )
	aAdd( aExp, {'GPE_EST_EMPRESA'         		,   aInfo[06]												, "@!"						,STR0032 	} )
	aAdd( aExp, {'GPE_CGC_EMPRESA' 		   		,	aInfo[08]             									, "@R ##.###.###/####-##"	,STR0134	} )
	aAdd( aExp, {'GPE_INSC_EMPRESA' 	   		,	aInfo[09]                              					, "@!" 						,STR0135	} )
	aAdd( aExp, {'GPE_TEL_EMPRESA'	 			,	aInfo[10]                              					, "@!" 						,STR0136	} )
	aAdd( aExp, {'GPE_FAX_EMPRESA'         		,   If(aInfo[11]#nil ,aInfo[11], "        ")              	, "@!"                     	,STR0136 	} )
	aAdd( aExp, {'GPE_BAI_EMPRESA'				,	aInfo[13]                              					, "@!" 						,STR0137	} )
	aAdd( aExp, {'GPE_DESC_RESC_RAIS'			,	fDesc("SX5","31"+SRA->RA_RESCRAI,"X5_DESCRI")			, "@!" 						,STR0138	} )
	aAdd( aExp, {'GPE_DIA_DEMISSAO'		   		,	StrZero( Day( SRA->RA_DEMISSA ) , 2 )					, "@!" 						,STR0139	} )
	aAdd( aExp, {'GPE_MES_DEMISSAO'				,	StrZero( Month( SRA->RA_DEMISSA ) , 2 )					, "@!" 						,STR0140 	} )
	aAdd( aExp, {'GPE_ANO_DEMISSAO'				,	StrZero( Year( SRA->RA_DEMISSA ) , 4 )					, "@!" 						,STR0141 	} )
   
	If cPaisLoc == "BRA"
		aAdd( aExp, {'GPE_MES_ADEXT'		    ,	MesExtenso( Month( SRA->RA_ADMISSA ) )					, "@!"						,STR0155	} )
		aAdd( aExp, {'GPE_RG_EMISSAO'			,	SRA->RA_DTRGEXP											, "SRA->RA_DTRGEXP"       	,STR0242	} )
		aAdd( aExp, {'GPE_CTPS_EMISSAO'			,	SRA->RA_DTCPEXP											, "SRA->RA_DTCPEXP"       	,STR0243	} )
		aAdd( aExp, {'GPE_FECREI'				, 	SRA->RA_FECREI											, "SRA->RA_FECREI" 			,STR0178	} ) 	
   		aAdd( aExp, {'GPE_HRDIA'				,	SRA->RA_HRSDIA											, "SRA->RA_HRSDIA"			,STR0218	} )													
	EndIf
	
	aAdd( aExp, {'GPE_FUNC_COR'					,	If( SRA->RA_RACACOR == "1" , "Indígena" , ( If( SRA->RA_RACACOR == "2" , "Branca" , ( If( SRA->RA_RACACOR == "4" , "Negra" , ( If( SRA->RA_RACACOR == "6" , "Amarela" , ( If( SRA->RA_RACACOR == "8" , "Parda" , "Não informado" ) ) ) ) ) ) ) ) ) 											, "@!"       	,STR0244	} )

	//Periodo Aquisitivo de Ferias
	If cPaisLoc == "COL"
	   aAdd( aExp, {'GPE_DIA_INIFERIAS'           ,   If(Len(aPerSRF) > 0,StrZero( Day( aPerSRF[1,1] ) , 2 ),Space(02))	, "@!"		,STR0188 	} )
	   aAdd( aExp, {'GPE_MES_INIFERIAS'           ,   If(Len(aPerSRF) > 0,MesExtenso(aPerSRF[1,1] ),Space(12))			, "@!"    	,STR0189 	} )
	   aAdd( aExp, {'GPE_ANO_INIFERIAS'           ,   If(Len(aPerSRF) > 0,StrZero( Year( aPerSRF[1,1] ) , 4 ),Space(04))	, "@!"		,STR0190 	} )	   
	   aAdd( aExp, {'GPE_DIA_FIMFERIAS'           ,   If(Len(aPerSRF) > 0,StrZero( Day( aPerSRF[1,2] ) , 2 ),Space(02))	, "@!"		,STR0191 	} )
	   aAdd( aExp, {'GPE_MES_FIMFERIAS'           ,   If(Len(aPerSRF) > 0,MesExtenso(aPerSRF[1,2] ),Space(12))			, "@!"		,STR0192 	} )
	   aAdd( aExp, {'GPE_ANO_FIMFERIAS'           ,   If(Len(aPerSRF) > 0,StrZero( Year( aPerSRF[1,2] ) , 4 ),Space(04))	, "@!"		,STR0193 	} )
	EndIf   

	// Salario Familia
	aAdd( aExp, {'GPE_CFILHO01'            		,   If(nDepen==1 .Or. nDepen==3,aDepenSF[1,1],Space(30))	, "@!"						,STR0150 	} )
	aAdd( aExp, {'GPE_DTFL01'              		,   If(nDepen==1 .Or. nDepen==3,aDepenSF[1,2],Space(08))	, ""						,STR0151 	} )
	aAdd( aExp, {'GPE_CFILHO02'            		,   If(nDepen==1 .Or. nDepen==3,aDepenSF[2,1],Space(30))	, "@!"						,STR0150 	} )
	aAdd( aExp, {'GPE_DTFL02'              		,   If(nDepen==1 .Or. nDepen==3,aDepenSF[2,2],Space(08))	, ""						,STR0151 	} )
	aAdd( aExp, {'GPE_CFILHO03'            		,   If(nDepen==1 .Or. nDepen==3,aDepenSF[3,1],Space(30))	, "@!"                      ,STR0150 	} )
	aAdd( aExp, {'GPE_DTFL03'              		,   If(nDepen==1 .Or. nDepen==3,aDepenSF[3,2],Space(08))	, ""                        ,STR0151 	} )
	aAdd( aExp, {'GPE_CFILHO04'            		,   If(nDepen==1 .Or. nDepen==3,aDepenSF[4,1],Space(30))	, "@!"                      ,STR0150 	} )
	aAdd( aExp, {'GPE_DTFL04'              		,   If(nDepen==1 .Or. nDepen==3,aDepenSF[4,2],Space(08))	, ""                        ,STR0151 	} )
	aAdd( aExp, {'GPE_CFILHO05'            		,   If(nDepen==1 .Or. nDepen==3,aDepenSF[5,1],Space(30))	, "@!"                      ,STR0150 	} )
	aAdd( aExp, {'GPE_DTFL05'              		,   If(nDepen==1 .Or. nDepen==3,aDepenSF[5,2],Space(08))	, ""                        ,STR0151 	} )
	aAdd( aExp, {'GPE_CFILHO06'            		,   If(nDepen==1 .Or. nDepen==3,aDepenSF[6,1],Space(30))	, "@!"                      ,STR0150 	} )
	aAdd( aExp, {'GPE_DTFL06'              		,   If(nDepen==1 .Or. nDepen==3,aDepenSF[6,2],Space(08))	, ""                        ,STR0151 	} )
	aAdd( aExp, {'GPE_CFILHO07'            		,   If(nDepen==1 .Or. nDepen==3,aDepenSF[7,1],Space(30))	, "@!"                      ,STR0150 	} )
	aAdd( aExp, {'GPE_DTFL07'              		,   If(nDepen==1 .Or. nDepen==3,aDepenSF[7,2],Space(08))	, ""                        ,STR0151 	} )
	aAdd( aExp, {'GPE_CFILHO08'            		,   If(nDepen==1 .Or. nDepen==3,aDepenSF[8,1],Space(30))	, "@!"                      ,STR0150 	} )
	aAdd( aExp, {'GPE_DTFL08'              		,   If(nDepen==1 .Or. nDepen==3,aDepenSF[8,2],Space(08))	, ""                        ,STR0151 	} )
	aAdd( aExp, {'GPE_CFILHO09'            		,   If(nDepen==1 .Or. nDepen==3,aDepenSF[9,1],Space(30))	, "@!"                      ,STR0150 	} )
	aAdd( aExp, {'GPE_DTFL09'              		,   If(nDepen==1 .Or. nDepen==3,aDepenSF[9,2],Space(08))	, ""                        ,STR0151 	} )
	aAdd( aExp, {'GPE_CFILHO10'            		,   If(nDepen==1 .Or. nDepen==3,aDepenSF[10,1],Space(30))	, "@!"                    	,STR0150 	} )
	aAdd( aExp, {'GPE_DESC_ESTEMP'         		,   Alltrim(fDesc("SX5","12"+aInfo[06],"X5_DESCRI"))      	, "@!"                     	,STR0134 	} ) 
	aAdd( aExp, {'GPE_cGrau01'			   		,	If(nDepen==1 .Or. nDepen==3,aDepenSF[1,3],Space(10))	, "@!"						,STR0153 	} ) 
	aAdd( aExp, {'GPE_cGrau02'			   		,	If(nDepen==1 .Or. nDepen==3,aDepenSF[2,3],Space(10))	, "@!"						,STR0153 	} ) 
	aAdd( aExp, {'GPE_cGrau03'			   		,	If(nDepen==1 .Or. nDepen==3,aDepenSF[3,3],Space(10))	, "@!"						,STR0153 	} ) 
	aAdd( aExp, {'GPE_cGrau04'			   		,	If(nDepen==1 .Or. nDepen==3,aDepenSF[4,3],Space(10))	, "@!"						,STR0153 	} ) 
	aAdd( aExp, {'GPE_cGrau05'			   		,	If(nDepen==1 .Or. nDepen==3,aDepenSF[5,3],Space(10))	, "@!"						,STR0153 	} ) 
	aAdd( aExp, {'GPE_cGrau06'			   		,	If(nDepen==1 .Or. nDepen==3,aDepenSF[6,3],Space(10))	, "@!"						,STR0153 	} )
	aAdd( aExp, {'GPE_cGrau07'			   		,	If(nDepen==1 .Or. nDepen==3,aDepenSF[7,3],Space(10))	, "@!"						,STR0153 	} )
	aAdd( aExp, {'GPE_cGrau08'					,	If(nDepen==1 .Or. nDepen==3,aDepenSF[8,3],Space(10))	, "@!"						,STR0153 	} )
	aAdd( aExp, {'GPE_cGrau09'			   		,	If(nDepen==1 .Or. nDepen==3,aDepenSF[9,3],Space(10))	, "@!"						,STR0153 	} ) 
	aAdd( aExp, {'GPE_cGrau10'			   		,	If(nDepen==1 .Or. nDepen==3,aDepenSF[10,3],Space(10))	, "@!"						,STR0153 	} ) 
	aAdd( aExp, {'GPE_LOCAL01'			   		,	If(nDepen==1 .Or. nDepen==3,aDepenSF[1,4],Space(10))	, "@!"						,STR0164 	} ) 
	aAdd( aExp, {'GPE_CARTORIO01'		  		,	If(nDepen==1 .Or. nDepen==3,aDepenSF[1,5],Space(10))	, "@!"						,STR0156 	} ) 
	aAdd( aExp, {'GPE_NREGISTRO01'		   		,	If(nDepen==1 .Or. nDepen==3,aDepenSF[1,6],Space(10))	, "@!"						,STR0165 	} ) 
	aAdd( aExp, {'GPE_NLIVRO01'			   		,	If(nDepen==1 .Or. nDepen==3,aDepenSF[1,7],Space(10))	, "@!"						,STR0158 	} ) 
	aAdd( aExp, {'GPE_NFOLHA01'			   		,	If(nDepen==1 .Or. nDepen==3,aDepenSF[1,8],Space(10))	, "@!"						,STR0159 	} ) 
	aAdd( aExp, {'GPE_DT_ENTREGA01'		   		,	If(nDepen==1 .Or. nDepen==3,aDepenSF[1,9],Space(10))	, "@!"						,STR0160 	} ) 
	aAdd( aExp, {'GPE_DT_BAIXA01'		   		,	if(nDepen==1 .Or. nDepen==3,aDepenSF[1,10],Space(10))	, "@!"						,STR0161 	} ) 
	aAdd( aExp, {'GPE_LOCAL02'			   		,	If(nDepen==1 .Or. nDepen==3,aDepenSF[2,4],Space(10))	, "@!"						,STR0164 	} ) 
	aAdd( aExp, {'GPE_CARTORIO02'		   		,	If(nDepen==1 .Or. nDepen==3,aDepenSF[2,5],Space(10))	, "@!"						,STR0156 	} ) 
	aAdd( aExp, {'GPE_NREGISTRO02'		   		,	If(nDepen==1 .Or. nDepen==3,aDepenSF[2,6],Space(10))	, "@!"						,STR0165 	} ) 
	aAdd( aExp, {'GPE_NLIVRO02'					,	If(nDepen==1 .Or. nDepen==3,aDepenSF[2,7],Space(10))	, "@!"						,STR0158 	} ) 
	aAdd( aExp, {'GPE_NFOLHA02'			   		,	If(nDepen==1 .Or. nDepen==3,aDepenSF[2,8],Space(10))	, "@!"						,STR0159 	} ) 
	aAdd( aExp, {'GPE_DT_ENTREGA02'		   		,	If(nDepen==1 .Or. nDepen==3,aDepenSF[2,9],Space(10))	, "@!"						,STR0160 	} ) 
	aAdd( aExp, {'GPE_DT_BAIXA02'		   		,	If(nDepen==1 .Or. nDepen==3,aDepenSF[2,10],Space(10))	, "@!"						,STR0161 	} ) 
	aAdd( aExp, {'GPE_LOCAL03'			   		,	If(nDepen==1 .Or. nDepen==3,aDepenSF[3,4],Space(10))	, "@!"						,STR0164 	} ) 
	aAdd( aExp, {'GPE_CARTORIO03'		   		,	If(nDepen==1 .Or. nDepen==3,aDepenSF[3,5],Space(10))	, "@!"						,STR0156 	} ) 
	aAdd( aExp, {'GPE_NREGISTRO03'		   		,	If(nDepen==1 .Or. nDepen==3,aDepenSF[3,6],Space(10))	, "@!"						,STR0165 	} ) 
	aAdd( aExp, {'GPE_NLIVRO03'			   		,	If(nDepen==1 .Or. nDepen==3,aDepenSF[3,7],Space(10))	, "@!"						,STR0158 	} ) 
	aAdd( aExp, {'GPE_NFOLHA03'			   		,	If(nDepen==1 .Or. nDepen==3,aDepenSF[3,8],Space(10))	, "@!"						,STR0159 	} ) 
	aAdd( aExp, {'GPE_DT_ENTREGA03'		   		,	If(nDepen==1 .Or. nDepen==3,aDepenSF[3,9],Space(10))	, "@!"						,STR0160 	} ) 
	aAdd( aExp, {'GPE_DT_BAIXA03'		   		,	If(nDepen==1 .Or. nDepen==3,aDepenSF[3,10],Space(10)) 	, "@!"						,STR0161 	} ) 
	aAdd( aExp, {'GPE_LOCAL04'			   		,	If(nDepen==1 .Or. nDepen==3,aDepenSF[4,4],Space(10)) 	, "@!"						,STR0164 	} ) 
	aAdd( aExp, {'GPE_CARTORIO04'				,	If(nDepen==1 .Or. nDepen==3,aDepenSF[4,5],Space(10)) 	, "@!"						,STR0156 	} ) 
	aAdd( aExp, {'GPE_NREGISTRO04'				,	If(nDepen==1 .Or. nDepen==3,aDepenSF[4,06],Space(10))	, "@!"						,STR0165 	} ) 
	aAdd( aExp, {'GPE_NLIVRO04'			   		,	If(nDepen==1 .Or. nDepen==3,aDepenSF[4,7],Space(10))	, "@!"						,STR0158 	} ) 
	aAdd( aExp, {'GPE_NFOLHA04'			   		,	If(nDepen==1 .Or. nDepen==3,aDepenSF[4,8],Space(10))	, "@!"						,STR0159 	} ) 
	aAdd( aExp, {'GPE_DT_ENTREGA04'		   		,	If(nDepen==1 .Or. nDepen==3,aDepenSF[4,9],Space(10))	, "@!"						,STR0160 	} ) 
	aAdd( aExp, {'GPE_DT_BAIXA04'		   		,	If(nDepen==1 .Or. nDepen==3,aDepenSF[4,10],Space(10)) 	, "@!"						,STR0161 	} ) 
	aAdd( aExp, {'GPE_LOCAL05'			   		,	If(nDepen==1 .Or. nDepen==3,aDepenSF[5,4],Space(10))	, "@!"						,STR0164 	} ) 
	aAdd( aExp, {'GPE_CARTORIO05'		   		,	If(nDepen==1 .Or. nDepen==3,aDepenSF[5,5],Space(10))	, "@!"						,STR0156 	} )
	aAdd( aExp, {'GPE_NREGISTRO05'		   		,	If(nDepen==1 .Or. nDepen==3,aDepenSF[5,6],Space(10))	, "@!"						,STR0165 	} ) 
	aAdd( aExp, {'GPE_NLIVRO05'			   		,	If(nDepen==1 .Or. nDepen==3,aDepenSF[5,7],Space(10))	, "@!"						,STR0158 	} ) 
	aAdd( aExp, {'GPE_NFOLHA05'			   		,	If(nDepen==1 .Or. nDepen==3,aDepenSF[5,8],Space(10))	, "@!"						,STR0159 	} ) 
	aAdd( aExp, {'GPE_DT_ENTREGA05'		   		,	If(nDepen==1 .Or. nDepen==3,aDepenSF[5,9],Space(10))	, "@!"						,STR0160 	} ) 
	aAdd( aExp, {'GPE_DT_BAIXA05'		   		,	If(nDepen==1 .Or. nDepen==3,aDepenSF[5,10],Space(10))	, "@!"						,STR0161 	} ) 
	aAdd( aExp, {'GPE_LOCAL06'			   		,	If(nDepen==1 .Or. nDepen==3,aDepenSF[6,4],Space(10))	, "@!"						,STR0164 	} ) 
	aAdd( aExp, {'GPE_CARTORIO06'		   		,	If(nDepen==1 .Or. nDepen==3,aDepenSF[6,5],Space(10))	, "@!"						,STR0156 	} ) 
	aAdd( aExp, {'GPE_NREGISTRO06'		   		,	If(nDepen==1 .Or. nDepen==3,aDepenSF[6,6],Space(10))	, "@!"						,STR0165 	} ) 
	aAdd( aExp, {'GPE_NLIVRO06'			   		,	If(nDepen==1 .Or. nDepen==3,aDepenSF[6,7],Space(10))	, "@!"						,STR0158 	} ) 
	aAdd( aExp, {'GPE_NFOLHA06'			   		,	If(nDepen==1 .Or. nDepen==3,aDepenSF[6,8],Space(10))	, "@!"						,STR0159 	} ) 
	aAdd( aExp, {'GPE_DT_ENTREGA06'		   		,	If(nDepen==1 .Or. nDepen==3,aDepenSF[6,9],Space(10))	, "@!"						,STR0160 	} ) 
	aAdd( aExp, {'GPE_DT_BAIXA06'		  		,	If(nDepen==1 .Or. nDepen==3,aDepenSF[6,10],Space(10))	, "@!"						,STR0161 	} ) 
	aAdd( aExp, {'GPE_LOCAL07'			  		,	If(nDepen==1 .Or. nDepen==3,aDepenSF[7,4],Space(10))	, "@!"						,STR0164 	} ) 
	aAdd( aExp, {'GPE_CARTORIO07'		  		,	If(nDepen==1 .Or. nDepen==3,aDepenSF[7,5],Space(10))	, "@!"						,STR0156 	} ) 
	aAdd( aExp, {'GPE_NREGISTRO07'		   		,	If(nDepen==1 .Or. nDepen==3,aDepenSF[7,6],Space(10))	, "@!"						,STR0165 	} ) 
	aAdd( aExp, {'GPE_NLIVRO07'			   		,	If(nDepen==1 .Or. nDepen==3,aDepenSF[7,7],Space(10))	, "@!"						,STR0158 	} ) 
	aAdd( aExp, {'GPE_NFOLHA07'			   		,	If(nDepen==1 .Or. nDepen==3,aDepenSF[7,8],Space(10))	, "@!"						,STR0159 	} ) 
	aAdd( aExp, {'GPE_DT_ENTREGA07'		   		,	If(nDepen==1 .Or. nDepen==3,aDepenSF[7,9],Space(10))	, "@!"						,STR0160 	} ) 
	aAdd( aExp, {'GPE_DT_BAIXA07'		   		,	If(nDepen==1 .Or. nDepen==3,aDepenSF[7,10],Space(10)) 	, "@!"						,STR0161 	} ) 
	aAdd( aExp, {'GPE_LOCAL08'			   		,	If(nDepen==1 .Or. nDepen==3,aDepenSF[8,4],Space(10))	, "@!"						,STR0164 	} ) 
	aAdd( aExp, {'GPE_CARTORIO08'		   		,	If(nDepen==1 .Or. nDepen==3,aDepenSF[8,5],Space(10))	, "@!"						,STR0156 	} ) 
	aAdd( aExp, {'GPE_NREGISTRO08'		   		,	If(nDepen==1 .Or. nDepen==3,aDepenSF[8,6],Space(10))	, "@!"						,STR0165 	} ) 
	aAdd( aExp, {'GPE_NLIVRO08'			   		,	If(nDepen==1 .Or. nDepen==3,aDepenSF[8,7],Space(10))	, "@!"						,STR0158 	} ) 
	aAdd( aExp, {'GPE_NFOLHA08'			   		,	If(nDepen==1 .Or. nDepen==3,aDepenSF[8,8],Space(10))	, "@!"						,STR0159 	} ) 
	aAdd( aExp, {'GPE_DT_ENTREGA08'		   		,	If(nDepen==1 .Or. nDepen==3,aDepenSF[8,9],Space(10))	, "@!"						,STR0160 	} ) 
	aAdd( aExp, {'GPE_DT_BAIXA08'		   		,	If(nDepen==1 .Or. nDepen==3,aDepenSF[8,10],Space(10)) 	, "@!"						,STR0161 	} ) 
	aAdd( aExp, {'GPE_LOCAL09'					,	If(nDepen==1 .Or. nDepen==3,aDepenSF[9,4],Space(10))	, "@!"						,STR0164 	} ) 
	aAdd( aExp, {'GPE_CARTORIO09'		   		,	If(nDepen==1 .Or. nDepen==3,aDepenSF[9,5],Space(10))	, "@!"						,STR0156 	} ) 
	aAdd( aExp, {'GPE_NREGISTRO09'		   		,	If(nDepen==1 .Or. nDepen==3,aDepenSF[9,6],Space(10))	, "@!"						,STR0165 	} ) 
	aAdd( aExp, {'GPE_NLIVRO09'			   		,	If(nDepen==1 .Or. nDepen==3,aDepenSF[9,7],Space(10))	, "@!"						,STR0158 	} ) 
	aAdd( aExp, {'GPE_NFOLHA09'					,	If(nDepen==1 .Or. nDepen==3,aDepenSF[9,8],Space(10))	, "@!"						,STR0159 	} ) 
	aAdd( aExp, {'GPE_DT_ENTREGA09'		   		,	If(nDepen==1 .Or. nDepen==3,aDepenSF[9,9],Space(10))	, "@!"						,STR0160 	} ) 
	aAdd( aExp, {'GPE_DT_BAIXA09'		   		,	If(nDepen==1 .Or. nDepen==3,aDepenSF[9,10],Space(10))	, "@!"						,STR0161 	} ) 
	aAdd( aExp, {'GPE_LOCAL10'			   		,	If(nDepen==1 .Or. nDepen==3,aDepenSF[10,4],Space(10))	, "@!"						,STR0164 	} ) 
	aAdd( aExp, {'GPE_CARTORIO10'		   		,	If(nDepen==1 .Or. nDepen==3,aDepenSF[10,5],Space(10))	, "@!"						,STR0156 	} ) 
	aAdd( aExp, {'GPE_NREGISTRO10'		   		,	If(nDepen==1 .Or. nDepen==3,aDepenSF[10,6],Space(10))	, "@!"						,STR0165 	} ) 
	aAdd( aExp, {'GPE_NLIVRO10'					,	If(nDepen==1 .Or. nDepen==3,aDepenSF[10,7],Space(10))	, "@!"						,STR0158 	} ) 
	aAdd( aExp, {'GPE_NFOLHA10'			   		,	If(nDepen==1 .Or. nDepen==3,aDepenSF[10,8],Space(10))	, "@!"						,STR0159 	} ) 
	aAdd( aExp, {'GPE_DT_ENTREGA10'		   		,	If(nDepen==1 .Or. nDepen==3,aDepenSF[10,9],Space(10))	, "@!"						,STR0160 	} ) 
	aAdd( aExp, {'GPE_DT_BAIXA10'		   		,	If(nDepen==1 .Or. nDepen==3,aDepenSF[10,10],Space(10))	, "@!"						,STR0161 	} ) 
	// Imposto de Renda
	aAdd( aExp, {'GPE_CDEPE01'             		,   If(nDepen==2 .Or. nDepen==3,aDepenIR[1,1],Space(30))	, "@!"						,STR0154   	} )
	aAdd( aExp, {'GPE_cGrDp01'			   		,	If(nDepen==2 .Or. nDepen==3,aDepenIR[1,3],Space(10))	, "@!"						,STR0153 	} ) 
	aAdd( aExp, {'GPE_DTFLIR01'            		,   If(nDepen==2 .Or. nDepen==3,aDepenIR[1,2],Space(08)) 	, ""						,STR0163 	} )
	aAdd( aExp, {'GPE_CDEPE02'			   		,	If(nDepen==2 .Or. nDepen==3,aDepenIR[2,1],Space(30))	, "@!" 						,STR0154 	} )
	aAdd( aExp, {'GPE_cGrDp02'			   		,	If(nDepen==2 .Or. nDepen==3,aDepenIR[2,3],Space(10))	, "@!"						,STR0153 	} ) 
	aAdd( aExp, {'GPE_DTFLIR02'            		,   If(nDepen==2 .Or. nDepen==3,aDepenIR[2,2],Space(08))	, ""						,STR0163 	} )
	aAdd( aExp, {'GPE_CDEPE03'					,	If(nDepen==2 .Or. nDepen==3,aDepenIR[3,1],Space(30))	, "@!"						,STR0154 	} )
	aAdd( aExp, {'GPE_cGrDp03'					,	If(nDepen==2 .Or. nDepen==3,aDepenIR[3,3],Space(10))	, "@!"						,STR0153 	} ) 
	aAdd( aExp, {'GPE_DTFLIR03'            		,   If(nDepen==2 .Or. nDepen==3,aDepenIR[3,2],Space(08)) 	, ""                        ,STR0163 	} )
	aAdd( aExp, {'GPE_CDEPE04'			   		,	If(nDepen==2 .Or. nDepen==3,aDepenIR[4,1],Space(30))	, "@!"						,STR0154 	} )
	aAdd( aExp, {'GPE_cGrDp04'			   		,	If(nDepen==2 .Or. nDepen==3,aDepenIR[4,3],Space(10))	, "@!"						,STR0153 	} ) 
	aAdd( aExp, {'GPE_DTFLIR04'            		,   If(nDepen==2 .Or. nDepen==3,aDepenIR[4,2],Space(08)) 	, ""                        ,STR0163 	} )
	aAdd( aExp, {'GPE_CDEPE05'			   		,	If(nDepen==2 .Or. nDepen==3,aDepenIR[5,1],Space(30))	, "@!"						,STR0154 	} )
	aAdd( aExp, {'GPE_cGrDp05'			   		,	If(nDepen==2 .Or. nDepen==3,aDepenIR[5,3],Space(10))	, "@!"						,STR0153 	} ) 
	aAdd( aExp, {'GPE_DTFLIR05'            		,   If(nDepen==2 .Or. nDepen==3,aDepenIR[5,2],Space(08))	, ""                        ,STR0163 	} )
	aAdd( aExp, {'GPE_CDEPE06'			   		,	If(nDepen==2 .Or. nDepen==3,aDepenIR[6,1],Space(30))	, "@!"						,STR0154 	} )
	aAdd( aExp, {'GPE_cGrDp06'			   		,	If(nDepen==2 .Or. nDepen==3,aDepenIR[6,3],Space(10))	, "@!"						,STR0153 	} ) 
	aAdd( aExp, {'GPE_DTFLIR06'			   		,   If(nDepen==2 .Or. nDepen==3,aDepenIR[6,2],Space(08)) 	, ""                        ,STR0163 	} )
	aAdd( aExp, {'GPE_CDEPE07'					,	If(nDepen==2 .Or. nDepen==3,aDepenIR[7,1],Space(30))	, "@!"						,STR0154 	} )
	aAdd( aExp, {'GPE_cGrDp07'			   		,	If(nDepen==2 .Or. nDepen==3,aDepenIR[7,3],Space(10))	, "@!"						,STR0153	} ) 
	aAdd( aExp, {'GPE_DTFLIR07'            		,   If(nDepen==2 .Or. nDepen==3,aDepenIR[7,2],Space(08))	, ""                        ,STR0163 	} )
	aAdd( aExp, {'GPE_CDEPE08'			   		,	If(nDepen==2 .Or. nDepen==3,aDepenIR[8,1],Space(30))	, "@!"						,STR0154 	} )
	aAdd( aExp, {'GPE_cGrDp08'			   		,	If(nDepen==2 .Or. nDepen==3,aDepenIR[8,3],Space(10))	, "@!"						,STR0153 	} ) 
	aAdd( aExp, {'GPE_DTFLIR08'            		,   If(nDepen==2 .Or. nDepen==3,aDepenIR[8,2],Space(08)) 	, ""                        ,STR0163 	} )
	aAdd( aExp, {'GPE_CDEPE09'					,	If(nDepen==2 .Or. nDepen==3,aDepenIR[9,1],Space(30))	, "@!"						,STR0154 	} )
	aAdd( aExp, {'GPE_cGrDp09'			   		,	If(nDepen==2 .Or. nDepen==3,aDepenIR[9,3],Space(10))	, "@!"						,STR0153 	} ) 
	aAdd( aExp, {'GPE_DTFLIR09'            		,   If(nDepen==2 .Or. nDepen==3,aDepenIR[9,2],Space(08)) 	, ""                        ,STR0163 	} )
	aAdd( aExp, {'GPE_CDEPE10'			   		,	If(nDepen==2 .Or. nDepen==3,aDepenIR[10,1],Space(30))	, "@!"						,STR0154 	} )
	aAdd( aExp, {'GPE_cGrDp10'					,	If(nDepen==2 .Or. nDepen==3,aDepenIR[10,3],Space(10))	, "@!"						,STR0153 	} ) 
	aAdd( aExp, {'GPE_DTFLIR10'            		,   If(nDepen==2 .Or. nDepen==3,aDepenIR[10,2],Space(08))	, ""                        ,STR0163 	} )

	If cPaisLoc == "ARG"
		aAdd( aExp, {'GPE_MES_ADEXT'		    ,	MesExtenso( Month( SRA->RA_ADMISSA ) )					 , "@!"						,STR0155	} )
		aAdd( aExp, {'GPE_APODERADO'		    ,	cApoderado												 , "@!"						,STR0156	} )
		aAdd( aExp, {'GPE_ATIVIDADE'		    ,	cRamoAtiv												 , "@!"						,STR0157	} )
	EndIf	

	aAdd( aExp, {'GPE_MUNICNASC'           		,   If(SRA->(FieldPos("RA_MUNNASC")) # 0  ,SRA->RA_MUNNASC,space(20)), "@!"           ,STR0166 	} )
	aAdd( aExp, {'GPE_PROCES'	,	SRA->RA_PROCES	,	"SRA->RA_PROCES"	,STR0173 	} )	//Codigo do Processo                                                                     
	aAdd( aExp, {'GPE_DEPTO'	,	SRA->RA_DEPTO	,	"SRA->RA_DEPTO"		,STR0181 	} )	//Codigo do Departamento

	If SRA->(FieldPos("RA_POSTO"  )) # 0
		aAdd( aExp, {'GPE_POSTO'	,	SRA->RA_POSTO  ,	"SRA->RA_POSTO"		,STR0182 	} )	//Codigo do Posto
	EndIf   
			
	If cPaisLoc == "MEX"
	
		cCodMunLP  := POSICIONE("RGC",1,XFILIAL("RGC")+SRA->RA_KEYLOC,"RGC_MUNIC")
		cCodReqFun := POSICIONE("SRJ",1,XFILIAL("SRJ")+SRA->RA_CODFUNC,"RJ_DESCREQ")
		
		aAdd( aExp, {'GPE_PRINOME'				, SRA->RA_PRINOME  											, "SRA->RA_PRINOME"			,STR0169	} ) 	//Primeiro Nome 
		aAdd( aExp, {'GPE_SECNOME'				, SRA->RA_SECNOME  											, "SRA->RA_SECNOME"			,STR0170	} ) 	//Segundo Nome
		aAdd( aExp, {'GPE_PRISOBR'				, SRA->RA_PRISOBR											, "SRA->RA_PRISOBR"			,STR0171	} ) 	//Primeiro Sobrenome
		aAdd( aExp, {'GPE_SECSOBR' 				, SRA->RA_SECSOBR  											, "SRA->RA_SECSOBR"			,STR0172	} ) 	//Segundo Sobrenome
		aAdd( aExp, {'GPE_KEYLOC'				, SRA->RA_KEYLOC   											, "SRA->RA_KEYLOC"			,STR0174	} ) 	//Codigo Local de Pagamento
		aAdd( aExp, {'GPE_TSIMSS'				, SRA->RA_TSIMSS   											, "SRA->RA_TSIMSS" 			,STR0175	} ) 	//Tipo de Salario IMSS
		aAdd( aExp, {'GPE_TEIMSS'				, SRA->RA_TEIMSS											, "SRA->RA_TEIMSS"			,STR0176	} ) 	//Tipo de Empregado IMSS
		aAdd( aExp, {'GPE_TJRNDA'				, SRA->RA_TJRNDA   											, "SRA->RA_TJRNDA"			,STR0177	} ) 	//Tipo de Jornada IMSS
		aAdd( aExp, {'GPE_FECREI'				, SRA->RA_FECREI   											, "SRA->RA_FECREI"			,STR0178	} ) 	//Data de Readmissao
		aAdd( aExp, {'GPE_DTBIMSS'				, SRA->RA_DTBIMSS  											, "SRA->RA_DTBIMSS"			,STR0179	} ) 	//Data de Baixa IMSS
		aAdd( aExp, {'GPE_CODRPAT'				, SRA->RA_CODRPAT											, "SRA->RA_CODRPAT"			,STR0180	} ) 	//Codigo do Registro Patronal
		aAdd( aExp, {'GPE_CURP'	   		   		, SRA->RA_CURP 	   											, "SRA->RA_CURP"			,STR0183	} ) 	//CURP
		aAdd( aExp, {'GPE_TIPINF'		   		, SRA->RA_TIPINF											, "SRA->RA_TIPINF"			,STR0184	} ) 	//Tipo de Infonavit
		aAdd( aExp, {'GPE_VALINF'		   		, SRA->RA_VALINF   											, "SRA->RA_VALINF" 			,STR0185	} ) 	//Valor do Infonavit
		aAdd( aExp, {'GPE_NUMINF'				, SRA->RA_NUMINF											, "SRA->RA_NUMINF"			,STR0186	} ) 	//Nro. de Credito Infonavit
		aAdd( aExp, {'GPE_IDADE'				, cValToChar(Year(DDATABASE)-Year(SRA->RA_NASC))			, "!@"			   			,STR0335	} ) 	//Idade
		aAdd( aExp, {'GPE_REQFUNC'				, MSMM(cCodReqFun,80)										,"!@"						,STR0334	} )		//Requisitos da Funcao
		aAdd( aExp, {'GPE_DESCMUNIC'			, POSICIONE("VAM",1,XFILIAL("VAM")+SRA->RA_MUNICIP,"VAM_DESCID"),	"!@"				,STR0031	} ) 	//Descricao do Municipio
		
		//Campos da Localidade de Pagamento
		aAdd( aExp, {'GPE_DESCLP',		POSICIONE("RGC",1,XFILIAL("RGC")+SRA->RA_KEYLOC,"RGC_DESLOC")		, "RGC->RGC_DESLOC"			,STR0216	} )		//Descricao do Local de Pagamento
		aAdd( aExp, {'GPE_ENDERECOLP',	POSICIONE("RGC",1,XFILIAL("RGC")+SRA->RA_KEYLOC,"RGC_ENDER")		, "RGC->RGC_ENDER" 			,STR0328	} )		//Endereco da Localidade de Pagamento
		aAdd( aExp, {'GPE_BAIRROLP',	POSICIONE("RGC",1,XFILIAL("RGC")+SRA->RA_KEYLOC,"RGC_BAIRRO")		, "RGC->RGC_BAIRRO"			,STR0329	} )		//Bairro da Localidade de Pagamento
		aAdd( aExp, {'GPE_CIDADELP',	POSICIONE("RGC",1,XFILIAL("RGC")+SRA->RA_KEYLOC,"RGC_CIDADE")		, "RGC->RGC_CIDADE"			,STR0330	} )		//Cidade da Localidade de Pagamento
		aAdd( aExp, {'GPE_ESTADOLP',	POSICIONE("RGC",1,XFILIAL("RGC")+SRA->RA_KEYLOC,"RGC_ESTADO")		, "RGC->RGC_ESTADO"			,STR0331	} )		//Estado da Localidade de Pagamento
		aAdd( aExp, {'GPE_CEPLP',		POSICIONE("RGC",1,XFILIAL("RGC")+SRA->RA_KEYLOC,"RGC_CODPOS")		, "RGC->RGC_CODPOS"			,STR0333	} )		//CEP da Localidade de Pagamento
		aAdd( aExp, {'GPE_DESCMUNICLP',	POSICIONE("VAM",1,XFILIAL("VAM")+cCodMunLP,"VAM_DESCID")			, "!@"						,STR0332	} )		//Municipio da Localidade de Pagamento
	                                                                                                                            		
	EndIf    
	
	If  cPaisLoc $ "COS/DOM"
		aAdd( aExp, {'GPE_DISTEMP'	,	POSICIONE("CC2",1,XFILIAL("CC2")+SRA->RA_ESTADO+SRA->RA_MUNICIP,"CC2_MUN")			,	"CC2->CC2_MUN"		,STR0220	} )//"Descripción del distrito"
	EndIf 

	If cPaisLoc == "COS" 
	
		cDESMTSS:=getQuery(	" SELECT SUBSTRING(RCC_CONTEU,5,40) CONTEU FROM "+InitSqlName("RCC") +" WHERE RCC_CODIGO= 'S006' AND SUBSTRING(RCC_CONTEU,1,4)= '"+POSICIONE("SRJ",1,XFILIAL("SRJ")+SRA->RA_CODFUNC,"RJ_CODMTSS")+"'")
		cDESCCSS:=getQuery(	" SELECT SUBSTRING(RCC_CONTEU,5,80) CONTEU FROM "+InitSqlName("RCC") +" WHERE RCC_CODIGO= 'S007' AND SUBSTRING(RCC_CONTEU,1,4)= '"+POSICIONE("SRJ",1,XFILIAL("SRJ")+SRA->RA_CODFUNC,"RJ_CODCCSS")+"'")
		cDESINS:=getQuery ( " SELECT SUBSTRING(RCC_CONTEU,6,80) CONTEU FROM "+InitSqlName("RCC") +" WHERE RCC_CODIGO= 'S008' AND SUBSTRING(RCC_CONTEU,1,5)= '"+POSICIONE("SRJ",1,XFILIAL("SRJ")+SRA->RA_CODFUNC,"RJ_CODINS")+"'")
		cDESCAN:=getQuery ( " SELECT SUBSTRING(RCC_CONTEU,6,40) CONTEU FROM "+InitSqlName("RCC") +" WHERE RCC_CODIGO= 'S013' AND SUBSTRING(RCC_CONTEU,1,5)= '"+SRA->RA_MUNICIP+"'")
		cDESCIC:=getQuery ( " SELECT SUBSTRING(RCC_CONTEU,5,40) CONTEU FROM "+InitSqlName("RCC") +" WHERE RCC_CODIGO= 'S014' AND SUBSTRING(RCC_CONTEU,1,4)= '"+SRA->RA_TPCIC+"'")
		cDESJOR:=getQuery ( " SELECT SUBSTRING(RCC_CONTEU,5,100) CONTEU FROM "+InitSqlName("RCC") +" WHERE RCC_CODIGO= 'S021' AND SUBSTRING(RCC_CONTEU,1,2)= '"+SRA->RA_TJRNDA+"'")
		cDESFON:=getQuery ( " SELECT SUBSTRING(RCC_CONTEU,5,40)  CONTEU FROM "+InitSqlName("RCC") +" WHERE RCC_CODIGO= 'S004' AND SUBSTRING(RCC_CONTEU,1,4)= '"+SRA->RA_FONSOL+"'")
	
		aAdd( aExp, {'GPE_CODRPAT'	,	SRA->RA_CODRPAT														,	"SRA->RA_CODRPAT"  		,STR0180	} )//Codigo do Registro Patronal
		aAdd( aExp, {'GPE_NRPAT'	,	POSICIONE("RCO",1,XFILIAL("RCO")+SRA->RA_CODRPAT,"RCO_NREPAT")		,	"RCO->RCO_NREPAT"  		,STR0207	} )//Codigo do Registro Patronal
		aAdd( aExp, {'GPE_POLRT'	,	POSICIONE("RCO",1,XFILIAL("RCO")+SRA->RA_CODRPAT,"RCO_POLRT")		,	"RCO->RCO_POLRT"   		,STR0208	} )//"Número de Póliza para MTSS"
		aAdd( aExp, {'GPE_SUCCSS'	,	POSICIONE("RCO",1,XFILIAL("RCO")+SRA->RA_CODRPAT,"RCO_SUCCSS")		,	"RCO->RCO_SUCCSS"		,STR0209	} )//"Número de Sucursal del CCSS"
			aAdd( aExp, {'GPE_CODMTSS'	,	POSICIONE("SRJ",1,XFILIAL("SRJ")+SRA->RA_CODFUNC,"RJ_CODMTSS")		,	"SRJ->RJ_CODMTSS"	,STR0210	} )//"Código Ocupación MTSS"
		aAdd( aExp, {'GPE_CODCCSS'	,	POSICIONE("SRJ",1,XFILIAL("SRJ")+SRA->RA_CODFUNC,"RJ_CODCCSS")		,	"SRJ->RJ_CODCCSS"  		,STR0211	} )//"Código Ocupación CCSS"
		aAdd( aExp, {'GPE_CODCINS'	,	POSICIONE("SRJ",1,XFILIAL("SRJ")+SRA->RA_CODFUNC,"RJ_CODINS")		,	"SRJ->RJ_CODINS"   		,STR0212	} )//"Código Ocupación INS"
		aAdd( aExp, {'GPE_DESMTSS'	,	cDESMTSS															,	"!@             "		,STR0213	} )//"Descripción de código Ocupación MTSS"
		aAdd( aExp, {'GPE_DESCCSS'	,	cDESCCSS															,	"!@            "		,STR0214	} )//"Descripción de código Ocupación CCSS"
		aAdd( aExp, {'GPE_DESINS'	,	cDESINS																,	"!@            "   		,STR0215	} )//"Descripción de código Ocupación INS" 	
		aAdd( aExp, {'GPE_KEYLOC'	,	SRA->RA_KEYLOC														,	"SRA->RA_KEYLOC"		,STR0174	} )//Codigo Local de Pagamento
		aAdd( aExp, {'GPE_DESLOC'	,	POSICIONE("RGC",1,XFILIAL("RGC")+SRA->RA_KEYLOC,"RGC_DESLOC")		,	"RGC->RGC_DESLOC"		,STR0216	} )//"Descripcion Localidad de Pago"
		aAdd( aExp, {'GPE_TNOTRAB'	,	SRA->RA_TNOTRAB														,	"SRA->RA_TNOTRAB"  		,STR0217	} )//"Turno Trabajado"
		aAdd( aExp, {'GPE_HRDIA'	,	POSICIONE("SR6",1,XFILIAL("SR6")+SRA->RA_TNOTRAB,"R6_HRDIA")		,	"SR6->R6_HRDIA"	   		,STR0218	} )//"Horas por Dia"
		aAdd( aExp, {'GPE_BAIRROEMP',	SRA->RA_BAIRRO														,	"SRA->RA_BAIRRO"   		,STR0219	} )//"Distrito donde vive el trabajador"
		aAdd( aExp, {'GPE_PRINOME'	,	SRA->RA_PRINOME														,	"SRA->RA_PRINOME"		,STR0169	} )//Primeiro Nome 
		aAdd( aExp, {'GPE_SECNOME'	,	SRA->RA_SECNOME														,	"SRA->RA_SECNOME"  		,STR0170	} )//Segundo Nome
		aAdd( aExp, {'GPE_PRISOBR'	,	SRA->RA_PRISOBR														,	"SRA->RA_PRISOBR"  		,STR0171	} )//Primeiro Sobrenome
		aAdd( aExp, {'GPE_SECSOBR'	,	SRA->RA_SECSOBR														,	"SRA->RA_SECSOBR"		,STR0172	} )//Segundo Sobrenome
		aAdd( aExp, {'GPE_CANTEMP'	,	SRA->RA_MUNICIP														,	"SRA->RA_MUNICIP"  		,STR0221	} )//"Cantón donde vive el Trabajador"
		aAdd( aExp, {'GPE_DESCCANEMP'	,cDESCAN															,	"!@             "  		,STR0222	} )//"Descripción del cantón donde vive el Trabjador"
		aAdd( aExp, {'GPE_PROVEMP'	,	SRA->RA_ESTADO														,	"SRA->RA_ESTADO"		,STR0223	} )//"Provincia donde vive el Trabjador"
		aAdd( aExp, {'GPE_TIPOFIN'	,	SRA->RA_TIPOFIN														,	"SRA->RA_TIPOFIN"  		,STR0225	} )//"Tipo de Baja de Acuerdo a la Empresa"
		aAdd( aExp, {'GPE_IDENEMP'	,	cDESCIC																,	"SRA->RA_CIC"  	   		,STR0226	} )//"Tipo número de identificación"
		aAdd( aExp, {'GPE_SEGSOC'	,	SRA->RA_RG															,	"SRA->RA_RG"   			,STR0227	} )//"Número de Seguridad Social"
		aAdd( aExp, {'GPE_DESTIPJOR',	cDESJOR																,	"!@            "   		,STR0228	} )//"Descripción Jornada"
		aAdd( aExp, {'GPE_FECAUM'	,	SRA->RA_FECAUM														,	"SRA->RA_FECAUM"   		,STR0229	} )//"Fecha de Modificación de Salario"
		aAdd( aExp, {'GPE_DOMICIL'	,	SRA->RA_DOMICIL														,	"SRA->RA_DOMICIL"		,STR0230	} )//"Extranjero viviendo en el Pais(1=Si; 2=No"
		aAdd( aExp, {'GPE_MOEDAPG'	,	SRA->RA_MOEDAPG														,	"SRA->RA_MOEDAPG"  		,STR0231	} )//Tipo de Moneda para el salario en contrato (1=Local, 2=Dólares)
		aAdd( aExp, {'GPE_FONSOL'	,	SRA->RA_FONSOL 														,	"SRA->RA_FONSOL"		,STR0232	} )//"Asociación Solidarista"
		
		aAdd( aExp, {'GPE_DESFONSOL',	cDESFON																,	"!@            "   		,STR0233	} )//"Descripción Asociación Solidarista"
		aAdd( aExp, {'GPE_TPCCSS'	,	SRA->RA_TPCCSS														,	"SRA->RA_TPCCSS"   		,STR0234	} )//"Clase Seguro"
		aAdd( aExp, {'GPE_NSEGURO'	,	SRA->RA_NSEGURO														,	"SRA->RA_NSEGURO"  		,STR0235	} )//"Número Asegurado"	
		aAdd( aExp, {'GPE_GROSSUP'	,	SRA->RA_GROSSUP														,	"SRA->RA_GROSSUP"		,STR0236	} )//"Tipo de Gross Up de Salario"
		aAdd( aExp, {'GPE_ANTEAUM'	,	SRA->RA_ANTEAUM														,	"SRA->RA_ANTEAUM"  		,STR0237	} )//"Salario Anterior"	
	
	EndIf                  

	If cPaisLoc == "ANG"
		aAdd( aExp, {'GPE_BIDENT'	     ,	SRA->RA_BIDENT                                					, "SRA->RA_BIDENT"			,STR0195	} ) // Nr. Bilhete Identidade
		aAdd( aExp, {'GPE_BIEMISS'	     ,	SRA->RA_BIEMISS                             					, "SRA->RA_BIEMISS"			,STR0196	} )	// Data de Emissao do Bilhete Identidade
	    aAdd( aExp, {'GPE_ESTADO'		 ,  Alltrim(fDescRCC("S001",SRA->RA_ESTADO,1,2,3,30))  			, "SRA->RA_ESTADO" 			,STR0032	} ) // Descricao do Distrito
	EndIf

	aAdd( aExp, {'GPE_DESC_EST_CIV'  ,	fDesc("SX5","33"+SRA->RA_ESTCIVI,"X5DESCRI()")	, "SRA->RA_ESTCIVI"	,STR0194	} ) //Descricao do Estado Civil
    
	If SRA->RA_CATFUNC $ "I*J"
		
		aRet := fTarProf()
		
		//Inclusao de variaveis contendo as tarefas fixas e aditamentos fixos dos professores
		aAdd( aExp, {'GPE_DESC_TAR_01'      	,   aRet[1,1], "@!"				, STR0197 	} ) // "Descricao da primeira tarefa"
		aAdd( aExp, {'GPE_AULS_TAR_01'         	,   aRet[1,2], "SRO->RO_QTDSEM"	, STR0198 	} ) // "Aulas por semana da primeira tarefa"
		aAdd( aExp, {'GPE_QTD_TAR_01'         	,   aRet[1,3], "SRO->RO_QUANT"	, STR0199 	} ) // "Quantidade da primeira tarefa"
		aAdd( aExp, {'GPE_VUNI_TAR_01'         	,   aRet[1,4], "SRO->RO_VALOR"	, STR0200 	} ) // "Valor unitario da primeira tarefa"
		aAdd( aExp, {'GPE_VTOT_TAR_01'         	,   aRet[1,5], "SRO->RO_VALTOT"	, STR0201	} ) // "Valor total da primeira tarefa"
		
		aAdd( aExp, {'GPE_DESC_TAR_02'         	,   aRet[2,1], "@!"          	, STR0202 	} ) // "Descricao da segunda tarefa"
		aAdd( aExp, {'GPE_AULS_TAR_02'         	,   aRet[2,2], "SRO->RO_QTDSEM"	, STR0203 	} ) // "Aulas por semana da segunda tarefa"
		aAdd( aExp, {'GPE_QTD_TAR_02'         	,   aRet[2,3], "SRO->RO_QUANT"	, STR0204 	} ) // "Quantidade da segunda tarefa"
		aAdd( aExp, {'GPE_VUNI_TAR_02'         	,   aRet[2,4], "SRO->RO_VALOR"	, STR0205 	} ) // "Valor unitário da segunda tarefa"
		aAdd( aExp, {'GPE_VTOT_TAR_02'         	,   aRet[2,5], "SRO->RO_VALTOT"	, STR0206 	} ) // "Valor total da segunda tarefa" 
		
	EndIf

	If cPaisLoc == "BRA"    
		//Variaveis criadas para utilizacao no DCN/DMN Documento de Cadastro/Manutencao do NIS - PIS   
	
		cEstCiv :=SRA->RA_ESTCIVI  					//Adequacao do estado civil conforme o leiaute do DCN/DMN - PIS
		Do Case
			Case cEstCiv$"C|M"
				cEstCiv :="CASADO(A)
			Case cEstCiv$"D"
				cEstCiv :="DIVORCIADO(A)
			Case cEstCiv$"Q"
				cEstCiv :="SEPARADO(A)
			Case cEstCiv$"S"
				cEstCiv :="SOLTEIRO(A)
			Case cEstCiv$"V"
				cEstCiv :="VIUVO(A)
		EndCase	
		
	    cTipCertd := SRA->RA_TIPCERT 				//Adequacao da descricao do certificado civil conforme o leiaute do DCN/DMN - PIS
	    Do Case
	    	Case cTipCertd == "1"
	    		cTipCertd :=OemToAnsi(STR0317)
	    	Case cTipCertd == "2"
	    		cTipCertd :=OemToAnsi(STR0318)
	    	Case cTipCertd == "3"
	    		cTipCertd :=OemToAnsi(STR0317)
	    	Case cTipCertd == "4"
	    		cTipCertd :=OemToAnsi(STR0320)
	    EndCase
	    		
		
		cGrauInstr :=SRA->RA_GRINRAI
		Do Case										//Adequacao da descricao do grau de instrucao conforme o leiaute do DCN/DMN - PIS
			Case cGrauInstr == "10"  
				cGrauInstr := OemToAnsi(STR0295)
			Case cGrauInstr == "20"  
				cGrauInstr := OemToAnsi(STR0296)
			Case cGrauInstr == "25"  
				cGrauInstr := OemToAnsi(STR0297)
			Case cGrauInstr == "30"  
				cGrauInstr := OemToAnsi(STR0298)
			Case cGrauInstr == "35"  
				cGrauInstr := OemToAnsi(STR0299)
			Case cGrauInstr == "40"  
				cGrauInstr := OemToAnsi(STR0300)
			Case cGrauInstr == "45"  
				cGrauInstr := OemToAnsi(STR0301)
			Case cGrauInstr == "50"  
				cGrauInstr := OemToAnsi(STR0302)
			Case cGrauInstr == "55"  
				cGrauInstr := OemToAnsi(STR0303)
			Case cGrauInstr == "65"  
				cGrauInstr := OemToAnsi(STR0304)
			Case cGrauInstr == "75"  
				cGrauInstr := OemToAnsi(STR0305)
			Case cGrauInstr == "85"  
				cGrauInstr := OemToAnsi(STR0306)
			Case cGrauInstr == "95"  
				cGrauInstr := OemToAnsi(STR0307)																											
		EndCase                                     
	
		aAdd( aExp, {'GPE_NACION_BRASILEIRA'	,SRA->(IF(RA_BRNASEX$"1","",(IF(RA_NACIONA$"10","x",""))))						 	 		,"SRA->RA_BRNASEX"	, STR0250   } ) // "Marca 'x' se Nacionalidade Brasileira"
		aAdd( aExp, {'GPE_NACION_ESTRANGEIRA'	,SRA->(IF(RA_BRNASEX$"1","",(IF(RA_NACIONA$"10","",(IF(RA_NACIONA$"20","","x"))))))			,"SRA->RA_BRNASEX"	, STR0251   } ) // "Marca 'x' se Nacionalidade Extrangeira"
		aAdd( aExp, {'GPE_NACION_BRA_NATURA'	,SRA->(IF(RA_BRNASEX$"1","",(IF(RA_NACIONA$"10","",(IF(RA_NACIONA$"20","x",""))))))			,"SRA->RA_BRNASEX"	, STR0252   } ) // "Marca 'x' se Nacionalidade Brasileira Naturalizada"
		aAdd( aExp, {'GPE_NACION_BRA_NASC_EXTE'	,SRA->(IF(RA_BRNASEX$"1","x",""))			 													,"SRA->RA_BRNASEX"	, STR0253   } ) // "Marca 'x' se Nacionalidade Brasileiro Nascido no Exterior"
		aAdd( aExp, {'GPE_EST_CIVIL_DCN'  		,cEstCiv																						,"SRA->RA_ESTCIVI"	, STR0254	} ) // "Estado civil de acordo com o NIS/PIS"
		aAdd( aExp, {'GPE_NOME_PAI_DCN'	   		,SRA->(IF(Empty (SRA->RA_PAI),"IGNORADO",SRA->RA_PAI))											,"SRA->RA_PAI"		, STR0255	} ) // "Nome do Pai, informa IGNORADO caso esteja em branco"
		aAdd( aExp, {'GPE_NOME_MAE_DCN'	   		,SRA->(IF(Empty (SRA->RA_MAE),"IGNORADA",SRA->RA_MAE))											,"SRA->RA_MAE"		, STR0256	} ) // "Nome da Mae, informa IGNORADO caso esteja em branco"
		aAdd( aExp, {'GPE_COMPLEM_RG'			,SRA->RA_COMPLRG																				,"SRA->RA_COMPLRG"	, STR0257   } ) // "Complemento do RG"
		aAdd( aExp, {'GPE_TIP_CERTID'			,cTipCertd																						,"SRA->RA_TIPCERT"	, STR0258   } ) // "Tipo de Certidao Civil"
		aAdd( aExp, {'GPE_EMIS_CERTID'			,SRA->RA_EMICERT																				,"SRA->RA_EMICERT"	, STR0259   } ) // "Data de Emissao da Certidao Civil"
		aAdd( aExp, {'GPE_MAT_CERTID'			,SRA->RA_MATCERT																				,"SRA->RA_MATCERT"	, STR0260   } ) // "Termo/Matricula da Certidao Civil"
		aAdd( aExp, {'GPE_LIVRO_CERT'			,SRA->RA_LIVCERT																				,"SRA->RA_LIVCERT"	, STR0261   } ) // "Livro da Certidao Civil"
		aAdd( aExp, {'GPE_FOLHA_CERT'			,SRA->RA_FOLCERT																				,"SRA->RA_FOLCERT"	, STR0262   } ) // "Folha da Certidao Civil"
		aAdd( aExp, {'GPE_CART_CERTID'			,SRA->RA_CARCERT																				,"SRA->RA_CARCERT"	, STR0263   } ) // "Cartorio da Certidao Civil"
		aAdd( aExp, {'GPE_UF_CERTIDAO'			,SRA->RA_UFCERT			 																		,"SRA->RA_UFCERT"	, STR0264   } ) // "UF da Certidao Civil"
		aAdd( aExp, {'GPE_MUN_CERTIDAO'			,fDesc("CC2",SRA->RA_UFCERT+SRA->RA_CDMUCER,"CC2_MUN")											,"SRA->RA_MUNCERT"	, STR0265   } ) // "Municipio da Certidao Civil"
		aAdd( aExp, {'GPE_NUM_PASSAPOR'			,SRA->RA_NUMEPAS																				,"SRA->RA_NUMEPAS"	, STR0266   } ) // "Numero do Passaporte"
		aAdd( aExp, {'GPE_EMIS_PASSAPOR'		,SRA->RA_EMISPAS																				,"SRA->RA_EMISPAS"	, STR0267   } ) // "Orgao Emissor do Passaporte"
		aAdd( aExp, {'GPE_UF_PASSAPORTE'		,SRA->RA_UFPAS  																				,"SRA->RA_UFPAS"	, STR0268   } ) // "UF do Passaporte"
		aAdd( aExp, {'GPE_DT_EMIS_PAS'			,SRA->RA_DEMIPAS																				,"SRA->RA_DEMIPAS"	, STR0269   } ) // "Data Emissao Passaporte"
		aAdd( aExp, {'GPE_DT_VALID_PAS'			,SRA->RA_DVALPAS																				,"SRA->RA_DVALPAS"	, STR0270   } ) // "Data Validade Passaporte"
		aAdd( aExp, {'GPE_PAIS_PASSAPOR'		,fDesc("CCH",SRA->RA_CODPAIS,"CCH_PAIS")														,"SRA->RA_PAISPAS"	, STR0271   } ) // "Pais de Emissao Passaporte"
		aAdd( aExp, {'GPE_NUM_NATURALIZ'		,SRA->RA_NUMNATU																				,"SRA->RA_NUMNATU"	, STR0272   } ) // "Numero de Naturalizacao"
		aAdd( aExp, {'GPE_DATA_NATURALIZ'		,SRA->RA_DATNATU																				,"SRA->RA_DATNATU"	, STR0273   } ) // "Data de Naturalizacao"
		aAdd( aExp, {'GPE_NUMERO_RIC'			,SRA->RA_NUMRIC 																				,"SRA->RA_NUMRIC" 	, STR0274   } ) // "Numero do RIC"
		aAdd( aExp, {'GPE_EMISSAO_RIC'			,SRA->RA_EMISRIC																				,"SRA->RA_EMISRIC"	, STR0275   } ) // "Orgao Emissor do RIC"
		aAdd( aExp, {'GPE_UF_RIC'				,SRA->RA_UFRIC  																				,"SRA->RA_UFRIC"  	, STR0276   } ) // "UF do RIC"
		aAdd( aExp, {'GPE_MUNICIPIO_RIC'		,fDesc("CC2",SRA->RA_UFRIC+SRA->RA_CDMURIC,"CC2_MUN")											,"SRA->RA_MUNIRIC"	, STR0277   } ) // "Municipio do RIC"
		aAdd( aExp, {'GPE_DATA_EXP_RIC'			,SRA->RA_DEXPRIC																				,"SRA->RA_DEXPRIC"	, STR0278   } ) // "Data de Expedicao do RIC"
		aAdd( aExp, {'GPE_TIPO_ENDERECO_COM'	,SRA->(IF(RA_TIPENDE$"1","x" ,""))																,"SRA->RA_TIPENDE"	, STR0279   } ) // "Marca 'x' se Endereco for Comercial"
		aAdd( aExp, {'GPE_TIPO_ENDERECO_RES'	,SRA->(IF(RA_TIPENDE$"2","x" ,""))																,"SRA->RA_TIPENDE"	, STR0280   } ) // "Marca 'x' se Endereco for Residencial"	
		aAdd( aExp, {'GPE_NUM_ENDERECO'			,SRA->RA_NUMENDE																				,"SRA->RA_NUMENDE"	, STR0281   } ) // "Numero do Endereco"
		aAdd( aExp, {'GPE_CAIXA_POSTAL'			,SRA->RA_CPOSTAL																				,"SRA->RA_CPOSTAL"	, STR0282  	} ) // "Caixa Postal"
	 	aAdd( aExp, {'GPE_CEP_CAIXA_POSTAL'		,SRA->RA_CEPCXPO																				,"SRA->RA_CEPCXPO"	, STR0283	} ) // "CEP da Caixa Postal" 
	 	aAdd( aExp, {'GPE_DDD_TELEFONE'			,SRA->RA_DDDFONE																				,"SRA->RA_DDDFONE"	, STR0284   } ) // "DDD do Telefone"
		aAdd( aExp, {'GPE_DDD_CELULAR'			,SRA->RA_DDDCELU																				,"SRA->RA_DDDCELU"	, STR0285   } ) // "DDD do Celular"
		aAdd( aExp, {'GPE_NUM_CELULAR'			,SRA->RA_NUMCELU																				,"SRA->RA_NUMCELU"	, STR0286   } ) // "Numero do Celular"
	   	aAdd( aExp, {'GPE_EMPRESA_TIPO_CNPJ'	,IF(aInfo[15]==2,"x","")																		,"@!"				, STR0287	} ) // "Marca 'x' se Empresa por CNPJ"
	   	aAdd( aExp, {'GPE_EMPRESA_TIPO_CEI'		,IF(aInfo[15]==1,"x","")																		,"@!"				, STR0288	} ) // "Marca 'x' se Empresa por CEI"
		aAdd( aExp, {'GPE_DATA_CHEGADA'			,SRA->RA_DATCHEG																				,"SRA->RA_DATCHEG"	, STR0289   } ) // "Data de Expedicao do RIC"   	
		aAdd( aExp, {'GPE_SECAO'				,SRA->RA_SECAO												  									,"SRA->RA_SECAO"	, STR0290  	} ) // "Secao Eleitoral"
		aAdd( aExp, {'GPE_INST_DCN'				,cGrauInstr																						,"@!"				, STR0291	} ) // "Grau de Instrucao conforme NIS/PIS"
		aAdd( aExp, {'GPE_PAIS_ORIGEM_PIS'		,SRA->(IF(RA_NACIONA<>"10" .OR. RA_BRNASEX=="1",fDesc("CCH",SRA->RA_CPAISOR,"CCH_PAIS"),""))	,"SRA->RA_PAISORI"	, STR0292   } ) // "Pais de Origem para o DCN/DMN"    
		aAdd( aExp, {'GPE_COD_UF_NASCTO_PIS'	,SRA->(IF(RA_NACIONA=="10" .AND. RA_BRNASEX<>"1",SRA->RA_NATURAL,""))	    					,"SRA->RA_NATURAL"	, STR0308   } ) // "Estado de Nascimento NIS/PIS"     
		aAdd( aExp, {'GPE_MUNICIPIO_NASCTO_PIS'	,SRA->(IF(RA_NACIONA=="10" .AND. RA_BRNASEX<>"1",SRA->RA_MUNNASC,""))							,"SRA->RA_MUNNASC"	, STR0309	} ) // "Municipio de Nascimento NIS/PIS"	
		aAdd( aExp, {'GPE_TIPO_MANUT_NIS_ALTER'	,IF(cTipNIS=="1","x","")																		,"@!"				, STR0310	} )	// "Marca 'x' para tipo de DMN - Alteracao"	
		aAdd( aExp, {'GPE_TIPO_MANUT_NIS_CADAS'	,IF(cTipNIS=="2","x","")																		,"@!"				, STR0311	} )	// "Marca 'x' para tipo de DMN - Cadastro Retroativo"	
		aAdd( aExp, {'GPE_TIPO_MANUT_NIS_CANCE'	,IF(cTipNIS=="3","x","")																		,"@!"				, STR0312	} )	// "Marca 'x' para tipo de DMN - Cancelamento"	
		aAdd( aExp, {'GPE_TIPO_MANUT_NIS_REATI'	,IF(cTipNIS=="4","x","")																		,"@!"				, STR0313	} )	// "Marca 'x' para tipo de DMN - Reativacao"
		aAdd( aExp, {'GPE_TIPO_MANUT_NIS_RETRO'	,IF(cTipNIS=="5","x","")																		,"@!"				, STR0314	} )	// "Marca 'x' para tipo de DMN - Retroacao Cadastral"	
		aAdd( aExp, {'GPE_COD_SEXO_MASCULINO'	,SRA->(IF(RA_SEXO=="M","x",""))																, "SRA->RA_SEXO"	, STR0315	} )	// "Marca 'x' se sexo for Masculino" 
		aAdd( aExp, {'GPE_COD_SEXO_FEMININO'	,SRA->(IF(RA_SEXO=="F","x",""))																, "SRA->RA_SEXO"	, STR0316	} )	// "Marca 'x' se sexo for Feminino" 
	   	aAdd( aExp, {'GPE_COD_SERVENTIA'		,SRA->RA_SERVENT 																				, "SRA->RA_SERVENT"	, STR0336	} )	// Codigo da Serventia
	  	aAdd( aExp, {'GPE_COD_ACERVO'			,SRA->RA_CODACER 																				, "SRA->RA_CODACER"	, STR0337	} )	// Codigo do Acervo
	   	aAdd( aExp, {'GPE_REG_CIVIL'			,SRA->RA_REGCIVI 																				, "SRA->RA_REGCIVI"	, STR0338	} )	// Registro Civil
	  	aAdd( aExp, {'GPE_TIPO_LIVRO'			,SRA->RA_TPLIVRO																				, "SRA->RA_TPLIVRO"	, STR0339	} )	// Tipo do Livro Reg.
	
	    cCodAtiv := POSICIONE("SQ3",1,XFILIAL("SQ3")+SRA->RA_CODFUNC,"Q3_DESCDET")
	    dbSelectArea("SQ3")
	    aAdd( aExp, {'GPE_CARGO_ATIVIDADE'			,MSMM(cCodAtiv,80)																			, "@!"	, "Descrição da atividade da função"	} )	// "Descrição da atividade da função"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  
	
	EndIf

Return( aExp )


//ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
//³Funcao    ³ GetQuery ³ Autor ³ Flor - HUB Mexico     ³ Data ³ 15/09/11 ³
//ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
//³Descricao ³ Retorna Informacoes da Definicao de Tabelas                ³
//ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
//³          ³ aExp[x,1] - Variavel Para utilizacao no Word (Tam Max. 30) ³
//³          ³ aExp[x,2] - Conteudo do Campo                (Tam Max. 49) ³
//³          ³ aExp[x,3] - Campo para Pesquisa da Picture no X3 ou Picture³
//³          ³ aExp[x,4] - Descricao da Variaval                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function GetQuery(cQuery)
Local cDes		:= ""
Local cAliasTmp	:= CriaTrab(Nil,.F.)

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.T.,.T.) 
	(cAliasTmp)->(dbgotop())
	IF(cAliasTmp)->(!EOF())
		cDes:=(cAliasTmp)->CONTEU
	EndIf  
	
	(cAliasTmp)->( dbCloseArea())  
	
Return( cDes )


//ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
//³Funcao    ³ fOpTpPIS ³ Autor ³ Claudinei Soares     ³ Data ³ 15/09/11 ³
//ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
//³Descricao ³ Retorna Informacoes da Definicao de Tabelas                ³
//ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
//³Uso       ³ GPEWORD													  ³
//ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
User Function fOpTpPis()
Local cTitulo	:= "" 
Local MvParDef	:= ""
Local MvPar
Local lRet	    := .T.

Private aInc	:={}

	If Alltrim(ReadVar() )= "MV_PAR30"	
	
		MvPar		:=	&(Alltrim(ReadVar()))	 		    // Carrega Nome da Variavel do Get em Questao
		mvRet		:=	Alltrim(ReadVar())			 	    // Iguala Nome da Variavel ao Nome variavel de Retorno
		aInc		:=	{STR0322,STR0323,STR0324,STR0325,STR0326,STR0327}// "Nenhum";"Alteracao";"Cadastro Retroativo";"Cancelamento";
															//"Reativacao";"Retroacao Cadastral"
		MvParDef	:=	"012345"
		cTitulo		:=	STR0321							  	// "Informe o Tipo de Alteracao do NIS-PIS"
	
		f_Opcoes(@MvPar,cTitulo,aInc,MvParDef,12,49,.T.)  	// Chama funcao f_Opcoes
	
		&MvRet := mvpar										// Devolve Resultado
	
	EndIf

Return( .T. )