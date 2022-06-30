#Include "Protheus.ch" 
#Include "Topconn.ch"
#Include "Rwmake.ch"
#Include "Tbiconn.ch"
#Include "Totvs.ch"
#Include "Font.Ch"
#Include "Colors.Ch"

#Define DS_MODALFRAME 128                 
#Define CRLF CHR(13)+CHR(10)

/*/{Protheus.doc} User Function ADLFV009P
	Programação de Retirada/Apanha de Aves.
	@type Function
	@author Fernando Sigoli 
	@since 18/04/17
	@version 01
	@history Chamado T.I -Fernando sigoli 24/06/2019 Adicionado controle de Lote nas Ordem Carregamento
	@history Chamado T.I -Fernando sigoli 05/07/2019 AJUSTADO Ajustado coluna na impressao da ordem
	@history Chamado 029058 -Everson 10/12/2019 Tratamento para validação de movimento de frete e informar nota fiscal e série.
	@history Chamado 029058 -Everson (2)10/12/2019 Correção posição do Acols.
	@history Chamado 029058 -Everson 11/12/2019 Tratamento na validação de nota fiscal já utilizada e adicionada rotina de lançamento de frete ao menu.
	@history Chamado 050729 - FWNM - 07/07/2020 - || OS 052035 || TECNOLOGIA || LUIZ || 8451 || REDUCAO DE BASE - Somente esta rotina não estava sendo compilada no R27
	@history Chamado 050729 - FWNM - 15/07/2020 - || OS 052035 || TECNOLOGIA || LUIZ || 8451 || REDUCAO DE BASE - Tratativa na função U_TAKECHAR que é utilizada também no X3_VLDUSER mas retorna string, dando error log
	@history Chamado 326334 - Everson - 15/09/2021 - Correção de erro variable does not exist _I on U_VALVEICB
	@history TICKET: 62797  - ADRIANO SAVOINE   - 26/10/2021 - Alteração no campo para novo modelo de checagem.
	@history ticket  69945  - Fernando Macieira - Projeto FAI - Ordens Carregamento - Frango vivo
	@history ticket  75561  - Everson, 30/06/2022, inclusão da informação de linhagem. 
/*/
User Function ADLFV009P()  //u_ADLFV009P()
	
	Local aCores      	:= {{'TRIM( ZFB_STATUS )== "1"','BR_VERDE'}	,;
							{'TRIM( ZFB_STATUS )== "2"','BR_AMARELO'},;
							{'TRIM( ZFB_STATUS )== "3"','BR_VERMELHO'},;
							{'TRIM( ZFB_STATUS )== "4"','BR_BRANCO'}}  
		
	Private cPerg	  	:= "ADLFV9A"

	Private cCadastro 	:= "Cadastro de Aves x Granja"

	Private aRotina 	:= {{"Vis. Retirada"      ,"U_ADLFV9A('V')",0,02},; 
							{"Prog.Retirada"      ,"U_ADLFV9A('I')",0,04},; 
							{"Gerar OC'S"         ,"U_ADLFV9B(0)"  ,0,04},; 
							{"Impr. Ordens"       ,"U_ADLFV9B(1)"  ,0,04},; 
							{"Legenda"            ,"U_ADLFV9F()"   ,0,12},;
							{"Lanc. Frt."         ,"U_ADLFV013P()" ,0,13}} //Everson - 11/12/2019 - Chamado 029058.
							//{"Fecha OC's"         ,"U_ADLFV9E()"   ,0,05},; //fecha a orderm e faz a integração 
						
		
							//{"Cancelar Coleta"    ,"U_ADLFV9C()"   ,0,10},;
								
							
	Private cDelFunc 	:= ".T." // Validacao para a exclusao. Pode-se utilizar ExecBlock
	Private cString		:= "ZFB"
	Private cFiltroSql	:= ""

	Private lVldNF	:= GetMv("MV_#VLFRTV",,.F.) //Everson - 10/12/2019 - Chamado 029058.

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Programação de Retirada/Apanha de Aves.')
		
		//ValidPerg()
	lResp	:=pergunte(cPerg,.T.)

		//Monta expressao de filtro
	cFiltroSql:="ZFB_ABTPRE >='"+DTOS(MV_PAR01)+"' AND ZFB_ABTPRE <='"+DTOS(MV_PAR02)+"'"
		
	DbSelectArea("ZFB")
	DbGotop() 
	DbSetOrder(1)

	If lResp
		DbSelectArea("ZFB")
		Mbrowse( 6,1,22,75,"ZFB",,,,,,aCores,,,,,,,,cFiltroSql)
	Endif

Return
/*/{Protheus.doc} User Function ADLFV9A
	Roteirizacao de veiculos para retirada de frangos de granjas
	@type Function
	@author Fernando Sigoli
	@since 18/04/17
	@version 01
	/*/  
User Function ADLFV9A(COPC)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.                                            |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	

	U_ADINF009P('ADLFV009P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Programação de Retirada/Apanha de Aves.')
	
	If COPC == "V" .and. ZFB->ZFB_STATUS == '1'
	   MsgStop("Não há dados a serem visualizados!")
	   Return
	EndIf
	
	DbSelectArea("ZFB")
	DbSetOrder(1)
	If COPC == "V"
		nOpcx := 1
	Else
		nOpcx:=3   && Não altera getdados so inclui linhas
	EndIf
	
	Private cAmarra 		:= ""	
	Private lComplemento	:= .F.
	Private nJaProgramado	:= 0
	Private nJaValorFrtKg   := 0
	Private nValoFrt        := 0
	Private nPesoFrt        := 0
	Private DADOSLOGISTIC   //DADOS LOGISTICOS
	
	Private cCodigoSZB      :=	ZFB->ZFB_CODIGO
	Private cGranja			:=	ZFB->ZFB_GRACOD
	Private cNumLote    	:=  ZFB->ZFB_NRLOTE
	Private cGalpao			:=	ZFB->ZFB_GALPAO
	Private cFilOrig        :=  ZFB->ZFB_FILORI
	Private cNome			:=  Posicione('ZF3', 1, xFilial('ZF3') + ZFB->ZFB_GRACOD, 'ZF3_GRADES')
	Private cTempo          :=  Posicione('ZF4', 1, xFilial('ZF4') + ZFB->ZFB_GRACOD, 'ZF4_TEMPO')
	Private nKilometro      := 	Posicione('ZF4', 1, xFilial('ZF4') + ZFB->ZFB_GRACOD, 'ZF4_KM')
	Private nPracas		    :=	Posicione('ZF4', 1, xFilial('ZF4') + ZFB->ZFB_GRACOD, 'ZF4_QTDPED')
	Private nVlrEixo        := 	Posicione('ZF4', 1, xFilial('ZF4') + ZFB->ZFB_GRACOD, 'ZF4_TOTPED')
	Private cEquipe 		:=	ZFB->ZFB_EQPCOD
    Private OpcSelec		:=	COPC 
   	Private nQuant			:=	ZFB->ZFB_QTDPRE
	Private nPeso			:=	ZFB->ZFB_PESPRE
	Private nFrtKg          :=  0
	Private aTpLinha  		:= RetSX3Box(GetSX3Cache("ZFB_LINHA", "X3_CBOX"),,,1)
	Private cLinhaZFB		:= ZFB->ZFB_LINHA
	Private cLinhagem		:= Iif(Empty(cLinhaZFB), "    ", aTpLinha[Val(cValToChar(cLinhaZFB)),3]) //Everson, 29/06/2022, ticket 75561.
	
	Public dDtPrev 			:=	ZFB->ZFB_ABTPRE //necessario como publico para colocar no inicializador do campo
	Public dDtCarr 			:=  ZFB->ZFB_DTACAR //necessario como publico para colocar no inicializador do campo
	
	//------------------------------------|
    //Controle - Dados do Integrado/Granja|
    //------------------------------------|
   	DbselectArea("ZF3")
	DbsetOrder(1)
	If Dbseek(xFilial("ZF3")+Alltrim(ZFB->ZFB_GRACOD))
		
		If ZF3_MSBLQL == '1'
			MsgInfo(" Granja sem Região Definida. Por Favor, verificar cadastro")
			Return
		EndIf  
		
		If Empty(ZF3_FORCOD)
			MsgInfo(" Granja sem Integrado/Fornecedor Definido. Por Favor, verificar cadastro")
			Return
		EndIf
		
		If Empty(ZF3_GRJREG)
			MsgInfo(" Granja sem Região Definida. Por Favor, verificar cadastro")
			Return
		EndIf
		
	
	Else
		MsgInfo(" Granja não encontrada. Por Favor, verificar!")
		Return
		
	EndIf 
 	
   	//------------------------------------------------------------------------|
    //Controle - Dados de Frete - Distancia/Pedagios da granjaIntegrado/Granja|
    //------------------------------------------------------------------------| 
   	DbselectArea("ZF4")
	DbsetOrder(1)
	If dbseek(xFilial("ZF4")+Alltrim(ZFB->ZFB_GRACOD))
    
    	If Empty(ZF4_LOCAL)
			MsgInfo(" Granja sem destino informado - FRETE")
			Return
		EndIf 
  		
  		If	ZF4_KM == 0
			MsgInfo(" Granja sem informação de Kilometragem/distancia percorrida - FRETE")
			Return
		EndIf 
        
        If	Empty(ZF4_TEMPO)
			MsgInfo(" Granja sem informação de tempo de viagem/percorrido - FRETE")
			Return
		EndIf    
    
    EndIF
   	
   	If Empty(ZFB->ZFB_AMARRA)
	
		cAmarra	:= GetSxeNum('ZFC', 'ZFC_CODIGO')
	
	Else
	
		cAmarra	:=	ZFB->ZFB_AMARRA
	
	Endif
  
  	DbSelectArea("ZFC")
	DbSetOrder(1)  
	
	If Dbseek(xFilial("ZFC")+cCodigoSZB+cGranja+cNumLote+cGalpao+DTOS(dDtPrev),.F.)
		While !Eof() .and. ZFC->ZFC_CODIGO == cCodigoSZB .and. ZFC->ZFC_GRANJA == cGranja .and. ZFC->ZFC_NRLOTE == cNumLote .and.;
			ZFC->ZFC_GALPAO == cGalpao .and. DTOS(ZFC->ZFC_DTAPRE) == DTOS(dDtPrev)
		    
		    If ZFC->ZFC_STATUS <> "3"
			    nJaProgramado += ZFC_TOTAL
			    
			    nValoFrt += ZFC_FRTVLR+ZFC_FRTPED
			    nPesoFrt += ZFC_PESPRE
			   
			EndIf
			
		DbSkip()
		End
		
		nJaValorFrtKg := Round(nValoFrt/nPesoFrt,2)
		
	EndIf 
	
	If ZFB->ZFB_STATUS	== "4" .and. !COPC $ ("V/F")
	    
		If Date() > ZFB->ZFB_ABTPRE
	       MsgStop("Operação não permitida, pois a data vigente é superior a data de abate prevista!")
	       Return
	       
	    EndIf
	    
		If nJaProgramado <> nQuant .and. ApMsgNoYes("Deseja fazer o complemento dessa coleta?"+CRLF+"Saldo da Coleta: "+Transform(nQuant-nJaProgramado,"@E 999,999,999") ,"Complemento de Coleta")
  			nQuant 			:= (nQuant-nJaProgramado) 
  			nJaProgramado 	:= 0 
  			lComplemento	:=.T.   
		
		ElseIf (nJaProgramado == nQuant .or. nJaProgramado > nQuant)
			MsgStop("Coleta ja finalizada e saldo totalmente atendido")
			Return(.F.)
		Else
			Return(.F.)
		EndIf

	ElseIf COPC == "F"
	
    	If ZFB->ZFB_STATUS <> "4"
        	MsgStop("A programação não está encerrada, a opção está indisponível!")
        	Return(.F.)
     	
     	EndIf
	    
	 	If MsgYesNo("Deseja efetuar alterações na programação já fechada?"+ Chr(13)+;
	  				"Somente as ordens não integradas serão carregadas!")
       				//VOU TRATAR AQUI AS TROCA DE PLACA/PARA MANTER A MESMO NUMERO DA ORDEM	
		Else
			Return
		EndIf
	    
	Endif
	
	Processa( {|| PROGRAMACAO(COPC) }, "Aguarde...", "Carregando Roteiros...",.F.)
	
Return
/*/{Protheus.doc} PROGRAMACAO
	Faz o processamento da rotina de programacao
	@type  Static Function
	@author Fernando Sigoli
	@since 18/04/17
	@version 01
	/*/
Static Function PROGRAMACAO(COPC)
	 
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.                                            |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
	Local aButtons := {}
	Local cTicket  := ""
	Local _I	   := 1

	Private cForCod  := Posicione('ZF3', 1, xFilial('ZF3') + cGranja, 'ZF3_FORCOD')
	Private cForLoj  := Posicione('ZF3', 1, xFilial('ZF3') + cGranja, 'ZF3_FORLOJ')
	Private lApanha	 :=.F.	&&Define se OC de Apanha

	DbSelectArea("SX3")
	DbSetOrder(1)
	DbSeek("ZFC")
	nUsado:=0
	aHeader:={}
	
	While !Eof() .And. (x3_arquivo == "ZFC")
	
		If	Alltrim(X3_CAMPO)== "ZFC_VEICUL"	.OR. ; 
			Alltrim(X3_CAMPO)== "ZFC_GAIOLA"  	.OR. ; 
			Alltrim(X3_CAMPO)== "ZFC_AVEGA"   	.OR. ;
			Alltrim(X3_CAMPO)== "ZFC_SEQUEN"  	.OR. ; 
			Alltrim(X3_CAMPO)== "ZFC_TOTAL" 	.OR. ;
			Alltrim(X3_CAMPO)== "ZFC_PESPRE"	.OR. ; 
			Alltrim(X3_CAMPO)== "ZFC_DTAPRE"	.OR. ;
			Alltrim(X3_CAMPO)== "ZFC_DTACAR"	.OR. ;
			Alltrim(X3_CAMPO)== "ZFC_HRAPRE"	.OR. ;
			Alltrim(X3_CAMPO)== "ZFC_TIPVIA"	.OR. ; 
			Alltrim(X3_CAMPO)== "ZFC_EQUIPE"   	.OR. ;
			Alltrim(X3_CAMPO)== "ZFC_LACRES"  	.OR. ; 
			Alltrim(X3_CAMPO)== "ZFC_HRCHEG"  	.OR. ;
			Alltrim(X3_CAMPO)== "ZFC_OBSERV"    .OR. ;
			Alltrim(X3_CAMPO)== "ZFC_FRTVLR"    .OR. ;
			Alltrim(X3_CAMPO)== "ZFC_FRTPED"    .OR. ;
			Alltrim(X3_CAMPO)== "ZFC_FRTTOT"    .OR. ;
			Alltrim(X3_CAMPO)== "ZFC_NUMERO"    .OR. ;
			Alltrim(X3_CAMPO)== "ZFC_NF"    	.OR. ; //Everson - 10/12/2019 - Chamado 029058.
			Alltrim(X3_CAMPO)== "ZFC_SERIE"          ; //Everson - 10/12/2019 - Chamado 029058.
			
			IF X3USO(x3_usado) .AND. cNivel >= x3_nivel
				nUsado	:=	nUsado	+	1
				If	ALLTRIM(X3_CAMPO)== "ZFC_VEICUL"
					AADD(aHeader,{ TRIM(x3_titulo), alltrim(x3_campo), x3_picture,;
					x3_tamanho, x3_decimal,"U_VALVEICA()",;
					x3_usado, x3_tipo, x3_arquivo, x3_context } )
				
				Elseif	Alltrim(X3_CAMPO)== "ZFC_TIPVIA"
					AADD(aHeader,{ TRIM(x3_titulo), alltrim(x3_campo), x3_picture,;
					x3_tamanho, x3_decimal,"U_VALVEICB()",;
					x3_usado, x3_tipo, x3_arquivo, x3_context } )
	
				Elseif	Alltrim(X3_CAMPO)== "ZFC_LACRES"
					AADD(aHeader,{ TRIM(x3_titulo), alltrim(x3_campo), x3_picture,;
					x3_tamanho, x3_decimal,"U_VALLACRE()",;
					x3_usado, x3_tipo, x3_arquivo, x3_context } )
				
				Elseif	Alltrim(X3_CAMPO)== "ZFC_EQUIPE"
					AADD(aHeader,{ TRIM(x3_titulo), alltrim(x3_campo), x3_picture,;
					x3_tamanho, x3_decimal,"U_VALEQUIPE()",;
						x3_usado, x3_tipo, x3_arquivo, x3_context } )
				
				Elseif	Alltrim(X3_CAMPO)== "ZFC_AVEGA"
					AADD(aHeader,{ TRIM(x3_titulo), alltrim(x3_campo), x3_picture,;
					x3_tamanho, x3_decimal,"U_VALAVEGA()",;
					x3_usado, x3_tipo, x3_arquivo, x3_context } )
				
				Elseif	Alltrim(X3_CAMPO)== "ZFC_TOTAL"
					AADD(aHeader,{ TRIM(x3_titulo), alltrim(x3_campo), x3_picture,;
					x3_tamanho, x3_decimal,"U_VALTOTAL()",;
					x3_usado, x3_tipo, x3_arquivo, x3_context } )
						                             
				Elseif	Alltrim(X3_CAMPO)== "ZFC_HRAPRE"
					AADD(aHeader,{ TRIM(x3_titulo), alltrim(x3_campo), x3_picture,;
					x3_tamanho, x3_decimal,"U_HORACAR()",;
					x3_usado, x3_tipo, x3_arquivo, x3_context } )

				Elseif	Alltrim(X3_CAMPO)== "ZFC_NF"    //Everson - 10/12/2019 - Chamado 029058.
					AADD(aHeader,{ TRIM(x3_titulo), alltrim(x3_campo), x3_picture,;
					x3_tamanho, x3_decimal,"U_009VL2(M->ZFC_NF)",;
					x3_usado, x3_tipo, x3_arquivo, x3_context } )

				Elseif	Alltrim(X3_CAMPO)== "ZFC_SERIE" //Everson - 10/12/2019 - Chamado 029058.
					AADD(aHeader,{ TRIM(x3_titulo), alltrim(x3_campo), x3_picture,;
					x3_tamanho, x3_decimal,"",;
					x3_usado, x3_tipo, x3_arquivo, x3_context } )

				Else
					AADD(aHeader,{ TRIM(x3_titulo), alltrim(x3_campo), x3_picture,;
					x3_tamanho, x3_decimal,"U_009VL1()",;
					x3_usado, x3_tipo, x3_arquivo, x3_context } )
					
				Endif
			Endif
			
		Endif
		dbSkip()
	Enddo
	
	nPosTota      	:= aScan(aHeader,{|x| x[2]=="ZFC_TOTAL"	})
	nPosVeic		:= aScan(aHeader,{|x| x[2]=="ZFC_VEICUL"})
	nPosGaio		:= aScan(aHeader,{|x| x[2]=="ZFC_GAIOLA"})
	nPosAves		:= aScan(aHeader,{|x| x[2]=="ZFC_AVEGA"	})
	nPosSequ		:= aScan(aHeader,{|x| x[2]=="ZFC_SEQUEN"})
	nPosPsPr		:= aScan(aHeader,{|x| x[2]=="ZFC_PESPRE"})
	nPosDtPr		:= aScan(aHeader,{|x| x[2]=="ZFC_DTAPRE"}) 
	nPosDtca		:= aScan(aHeader,{|x| x[2]=="ZFC_DTACAR"}) 
	nPosHrPr		:= aScan(aHeader,{|x| x[2]=="ZFC_HRAPRE"}) 
	nPosTpVa		:= aScan(aHeader,{|x| x[2]=="ZFC_TIPVIA"}) 
	nPosEqui		:= aScan(aHeader,{|x| x[2]=="ZFC_EQUIPE"}) 
	nPoslacr		:= aScan(aHeader,{|x| x[2]=="ZFC_LACRES"}) 
	nPosHrCh		:= aScan(aHeader,{|x| x[2]=="ZFC_HRCHEG"})
	nPosObse		:= aScan(aHeader,{|x| x[2]=="ZFC_OBSERV"})
	nPosFrtVlr      := aScan(aHeader,{|x| x[2]=="ZFC_FRTVLR"})
	nPosFrtPed      := aScan(aHeader,{|x| x[2]=="ZFC_FRTPED"})
	nPosFrtTot      := aScan(aHeader,{|x| x[2]=="ZFC_FRTTOT"})
	nPosNume      	:= aScan(aHeader,{|x| x[2]=="ZFC_NUMERO"})
	nPosNF      	:= aScan(aHeader,{|x| x[2]=="ZFC_NF"})     //Everson - 10/12/2019 - Chamado 029058.
	nPosSer      	:= aScan(aHeader,{|x| x[2]=="ZFC_SERIE"})  //Everson - 10/12/2019 - Chamado 029058.
	
	//Calcula o Saldo Disponível
	nSaldo	 := nQuant-nJaProgramado
	nFrtKg   := Round(nJaValorFrtKg,2)
	
	If nSaldo < 0
		nSaldo	:=0
	EndIf

	&& Montando aCols
	DbSelectArea("ZFC")
	DbSetOrder(1)
	If Dbseek(xFilial("ZFC")+cCodigoSZB+cGranja+cNumLote+cGalpao+DTOS(dDtPrev),.F.).and. !lComplemento

		aCols	:={}
		aOrig	:={}
		
		While !Eof() .and.	(ZFC->ZFC_CODIGO == cCodigoSZB .and. cGranja == ZFC->ZFC_GRANJA .and. cNumLote == ZFC->ZFC_NRLOTE     .and.  cGalpao == ZFC->ZFC_GALPAO .and. DTOS(dDtPrev)==DTOS(ZFC->ZFC_DTAPRE))   
			
			If ZFC->ZFC_STATUS <> "3"
    			
    			If COPC <> "F" .And. (ZFC->ZFC_STATUS <> "2" .or. COPC=="V" ) && Nao fechado
    			
    				aAdd(aCols,{Alltrim(ZFC->ZFC_VEICUL), ZFC->ZFC_GAIOLA , ZFC->ZFC_AVEGA, ZFC->ZFC_TOTAL, ZFC->ZFC_PESPRE,;
    							ZFC->ZFC_FRTVLR, ZFC->ZFC_FRTPED, ZFC->ZFC_FRTVLR+ZFC->ZFC_FRTPED , ZFC->ZFC_SEQUEN, Alltrim(ZFC->ZFC_EQUIPE),;
    							ZFC->ZFC_DTACAR,ZFC->ZFC_HRAPRE, ZFC->ZFC_DTAPRE,Alltrim(ZFC->ZFC_TIPVIA),;
    							Alltrim(ZFC->ZFC_LACRES),Alltrim(ZFC->ZFC_NUMERO), Alltrim(ZFC->ZFC_HRCHEG),;
    							Alltrim(ZFC->ZFC_OBSERV),ZFC->ZFC_NF,ZFC->ZFC_SERIE,.F.} ) //Everson - 10/12/2019 - Chamado 029058.
    					
    			ElseIf COPC == "F"                                                                                       
    			 
        			 If Empty(Alltrim(cCheckEdt)) 
        			 
                       	aAdd(aCols,{Alltrim(ZFC->ZFC_VEICUL), ZFC->ZFC_GAIOLA , ZFC->ZFC_AVEGA, ZFC->ZFC_TOTAL, ZFC->ZFC_PESPRE,;
    							ZFC->ZFC_FRTVLR, ZFC->ZFC_FRTPED, ZFC->ZFC_FRTVLR+ZFC->ZFC_FRTPED , ZFC->ZFC_SEQUEN, Alltrim(ZFC->ZFC_EQUIPE),;
    							ZFC->ZFC_DTACAR,ZFC->ZFC_HRAPRE, ZFC->ZFC_DTAPRE,Alltrim(ZFC->ZFC_TIPVIA),;
    							Alltrim(ZFC->ZFC_LACRES), Alltrim(ZFC->ZFC_NUMERO), Alltrim(ZFC->ZFC_HRCHEG),;
    							Alltrim(ZFC->ZFC_OBSERV),ZFC->ZFC_NF,ZFC->ZFC_SERIE,.F.} ) //Everson - 10/12/2019 - Chamado 029058.

        			 EndIf
    			 		
    			EndIf
    			
    			aAdd(aOrig,{ZFC->ZFC_VEICUL,ZFC->ZFC_TIPVIA} )
        			
    		EndIf &&Fecha checagem de status
    	
    		ZFC->(dbSkip())	
		
		Enddo 
		
	Else
		
		aCols:=Array(1,nUsado+1)
		aOrig:=Array(1,nUsado+1)
		
		DbSelectArea("SX3")
		DbSeek("ZFC")
		nUsado:=0
		While !Eof() .And. (x3_arquivo == "ZFC")
			
			If 	Alltrim(X3_CAMPO)== "ZFC_VEICUL"	.OR. ;
				Alltrim(X3_CAMPO)== "ZFC_GAIOLA"  	.OR. ;
				Alltrim(X3_CAMPO)== "ZFC_AVEGA"   	.OR. ;
				Alltrim(X3_CAMPO)== "ZFC_TOTAL" 	.OR. ;
				Alltrim(X3_CAMPO)== "ZFC_PESPRE"	.OR. ;
				Alltrim(X3_CAMPO)== "ZFC_DTACAR"	.OR. ;
				Alltrim(X3_CAMPO)== "ZFC_DTAPRE"	.OR. ;
				Alltrim(X3_CAMPO)== "ZFC_HRAPRE"	.OR. ;
				Alltrim(X3_CAMPO)== "ZFC_TIPVIA"	.OR. ;
				Alltrim(X3_CAMPO)== "ZFC_EQUIPE"  	.OR. ;
				Alltrim(X3_CAMPO)== "ZFC_LACRES"  	.OR. ;
				Alltrim(X3_CAMPO)== "ZFC_HRCHEG"	.OR. ;
				Alltrim(X3_CAMPO)== "ZFC_OBSERV"    .OR. ;
				Alltrim(X3_CAMPO)== "ZFC_FRTVLR"    .OR. ;
				Alltrim(X3_CAMPO)== "ZFC_FRTPED"    .OR. ;
				Alltrim(X3_CAMPO)== "ZFC_FRTTOT"    .OR. ;
				Alltrim(X3_CAMPO)== "ZFC_SEQUEN"    .OR. ;
				Alltrim(X3_CAMPO)== "ZFC_NUMERO"    .OR. ; 
				Alltrim(X3_CAMPO)== "ZFC_NF"        .OR. ;  //Everson - (2)10/12/2019 - Chamado 029058.
				Alltrim(X3_CAMPO)== "ZFC_SERIE"          ;  //Everson - 10/12/2019 - Chamado 029058.
								
				If X3USO(x3_usado) .AND. cNivel >= x3_nivel
					nUsado:=nUsado+1
					
					If nOpcx == 3
						
						If x3_tipo == "C"
							Conout(X3_CAMPO)
							aCOLS[1][nUsado] := SPACE(x3_tamanho)
						ElseIf x3_tipo == "N"
							aCOLS[1][nUsado] := 0
						ElseIf x3_tipo == "D"
							aCOLS[1][nUsado] := Iif(Alltrim(X3_CAMPO)== "ZFC_DTACAR",dDtCarr,dDtPrev)
						ElseIf x3_tipo == "M"
							aCOLS[1][nUsado] := ""
						Else
							aCOLS[1][nUsado] := .F.
						EndIf
						
					EndIf
				Endif
			Endif
			DbSkip()
		End
		aCOLS[1][nUsado+1] := .F.
	Endif
	
	nTC		:= Len(aHeader)+1
	cTitulo := "Roteirizacao de veiculos para retirada"
	aC		:= {}                                      
	
	AADD(aC,{"cCodigoSZB"			,{15,010}," Roteiro: " 	  											  ,"@!",,,.F.})
	AADD(aC,{"cGranja" 				,{15,085}," Granja: "												  ,"@!",,,.F.})
	AADD(aC,{"cNumLote"				,{15,150}," Lote: "		  											  ,"@!",,,.F.})
	AADD(aC,{"cGalpao" 				,{15,195}," Galpao: "												  ,"@!",,,.F.})
	AADD(aC,{"cLinhagem" 		    ,{15,335}," Linhagem: "												  ,"@!",,,.F.})
  	
  	AADD(aC,{"DADOSLOGISTIC"		,{12,475}," DADOS LOGISTICOS"										  ,"@!",,,.F.})   
  	AADD(aC,{"DADOSLOGISTIC"		,{21,450}," KM Ida/Volta --> "+Transform(nKilometro,"@E 999,999,999") ,"@!",,,.F.})
  	AADD(aC,{"DADOSLOGISTIC" 		,{21,515}," Tempo Viagem --> "+Transform(cTempo    ,"@E 99:99")  	  ,"@!",,,.F.})
  	AADD(aC,{"DADOSLOGISTIC" 		,{36,450}," Qtd Pedagios --> "+Transform(nPracas   ,"@E 999")  	      ,"@!",,,.F.})
  	AADD(aC,{"DADOSLOGISTIC" 		,{36,500}," R$ Eixo -------> "+Transform(nVlrEixo  ,"@E 999,999,999") ,"@!",,,.F.})
  	AADD(aC,{"substr(cNome,1,40)"	,{35,010}," Nome:  "       			  				   				  ,"@!",,,.F.})
  
	If COPC == "F"
 		cTitulo := "Remanejo de ordens fechadas"
   		AADD(aC,{"nQuant" ,{35,320},"Aves a remanejar"         ,"@E 999,999,999" ,,,.F.})	   
	
	ElseIf lComplemento == .T.
		cTitulo := "Complemento de ordens fechadas"
  		AADD(aC,{"nQuant" ,{35,335},"Aves a complementar"      ,"@E 999,999,999" ,,,.F.})
	
	Else
	   AADD(aC,{"nQuant" ,{35,335},"Aves:"          			,"@E 999,999,999" ,,,.F.})
	
	EndIf
	 
	//--------------------------------------------------------|
	//Array com descricao dos campos do Rodape do Modelo 2    |
	//--------------------------------------------------------|
	aR		:= {}	
	nSaldo	:= NQUANT-nJaProgramado
	nFrtKg  := nJaValorFrtKg
	
	If COPC == "F"
	   AADD(aR,{"nSaldo"  ,{060,010},"Saldo a remanejar"     		,"@E 999,999",,,.F.})   
	
	ElseIf lComplemento == .T.
	   AADD(aR,{"nSaldo"  ,{060,010},"Saldo a complementar"  		,"@E 999,999",,,.F.}) 
	
	Else
	   AADD(aR,{"nSaldo"    ,{060,010},"Saldo: "             		,"@E 999,999",,,.F.})
	   AADD(aR,{"cvaltochar(nFrtKg)"    ,{060,080},"Frete p/ KG: " ,"@E 9,99"   ,,,.F.})
	
	EndIf


	//Array com coordenadas da GetDados no modelo2                 ³
	aCGD	:={80,10,50,100}
	aView	:={050,050,450,800}
	
	cLinhaOk:="U_009LinOk()"
	cTudoOk:= "U_009TudoOk()"
	
	If !COPC $ ("V/F")
		
        //aAdd( aButtons, { 'RELACIONAMENTO_DIREITA', {|| U_ADLFV010P(cCodigoSZB,cGranja,cNumLote,cGalpao) }, 'Integraçoes', '* Integraçoes' } )
  	
  	Else
	
		aButtons:={}
	
	EndIf
	
	lRetMod2:=Modelo2(cTitulo,aC,aR,aCGD,nOpcx,cLinhaOk,cTudoOk,,,,,aView,,.t.,aButtons)

	nQtAves :=	0
	nTC		:=	Len(aHeader)+1
	
	If lRetMod2 .and. COPC <> "V"
		
		For _I := 1 To Len(aCols)
			
			If	! aCols[_I][nTC] //Verifica se o registro nao esta deletado                                         
			
				//verifica se ja nao existe a ordem de carregamento no sistema, se existe atualiza os dados se nao cria 
				DbSelectArea("ZFC")
				DbSetOrder(2)

				nVez	:= 0
				cNum	:= ""
				lErro	:= .F.
					
				//NOVA ORDERM DE CARREGAMENTO
				//+----------------------------------------------------------+
				//|Verifica qual tipo de viajem esta sendo feito             |
				//|1=Primeira viagem                                         |
				//|2=Comp.Pri.Viagem(Apanha)                                 |
				//|3=Retorno                                                 |
				//|4=Comp.Retorno                                            |
				//|                                                          |
				//|Caso seja Apanha utilizarei um mesmo numero de OC que ja  |
				//|foi utilizado para o mesmo veiculo no mesmo dia           |
				//+----------------------------------------------------------+
				If	aCols[_I,nPosTpVa] == "1" .or. aCols[_I,nPosTpVa] == "3"//Primeira viagem ou Retorno       
				
					If Empty(Alltrim(cValToChar(aCols[_I,nPosNume]))) 
						SX5->(DbSetOrder(1))
						SX5->(MsSeek(xFilial("SX5")+"Z6"))
						cNum	:= SX5->X5_CHAVE
						RecLock("SX5",.F.)
						Replace	SX5->X5_CHAVE	with	padl(alltrim(str(val(cNum)+1,6)),6,"0")
						MsUnlock()			
						lApanha:=.F.
					EndIf  
					
				Elseif aCols[_I,nPosTpVa] == "2" //Apanha
					
					
					//+------------------------------------------------------------+
					//|Procura pelo numero da ordem de carregamento que sera gerado|
					//|Utiliza o numero da orderm de carregamento de uma viagem ja |
					//|feita no dia para referenciar o complemeto.                 |
					//+------------------------------------------------------------+
					DbSelectArea("ZFC")
					DbSetOrder(2)                                                  					
					If Dbseek(xFilial("ZFC")+aCols[_I,nPosVeic]+dtos(aCols[_I,nPosDtPr]),.F.)   
					
						If ZFC->ZFC_STATUS <> "3" 
							nVez :=	ZFC->ZFC_VIAGEM + 1 //Imcrementa o numero de viagens  
						EndIf
																							
						While !Eof() .and. aCols[_I,nPosVeic]== ZFC->ZFC_VEICUL .and. ZFC->ZFC_DTAPRE == aCols[_I,nPosDtPr]
							
							If ZFC->ZFC_STATUS <> "3" 
							
								If	ZFC->ZFC_TIPVIA =="1"
									cNum := ZFC->ZFC_NUMERO
									Exit
								Endif
								DbSelectArea("ZFC")
							
							EndIf
							
						Dbskip()
						End
					Else
						nVez	:=	1
					Endif    
					lApanha:=.T.
					
				Elseif aCols[_I,nPosTpVa] == "4" //Complemento de Retorno (Tambem e um tipo de Apanha) 
				
					//+------------------------------------------------------------+
					//|Procura pelo numero da ordem de carregamento que sera gerado|
					//|Utiliza o numero da orderm de carregamento de uma viagem ja |
					//|feita no dia para referenciar o complemeto.                 |
					//+------------------------------------------------------------+
					DbSelectArea("ZFC")
					DbSetOrder(2)
					If dbseek(xFilial("ZFC")+aCols[_I,nPosVeic]+dtos(aCols[_I,nPosDtPr]),.F.)  
					
						If ZFC->ZFC_STATUS <> "3" 
							nVez	:=	ZFC->ZFC_VIAGEM + 1  //Incrementa o numero de viagens  
						EndIf
						
						While !Eof() .and. aCols[_I,nPosVeic]== ZFC->ZFC_VEICUL .and. ZFC->ZFC_DTAPRE == aCols[_I,nPosDtPr]
							
							If ZFC->ZFC_STATUS <> "3" 
								If	ZFC->ZFC_TIPVIA =="3" 
									cNum := ZFC->ZFC_NUMERO
									Exit
								Endif
							EndIf
								
							DbSelectArea("ZFC")
							Dbskip()
						End
					
					Else
					
						nVez	:=	1
					
					Endif
						
					lApanha:=.T.
				
				Endif                 
				
				//+------------------------------------------------------------+
				//|Gera a ordem de carregamento                                |
				//+------------------------------------------------------------+
				If	!lErro
					DbSelectArea("ZFC")
					DbSetOrder(4)
					If Empty(Alltrim(aCols[_I,nPosNume])) .And. aCols[_I,Len(aHeader)+1] == .F.
											
						If !Empty(StrTran( cValToChar(aCols[_I,nPosHrCh]),":","")) 
						
							RecLock("ZFC",.T.) //INCLUIR UMA NOVA ORDEM
							ZFC_FILIAL	:= xFilial("ZFC")
							ZFC_CODIGO	:= cCodigoSZB
							ZFC_GRANJA	:= cGranja
							ZFC_NRLOTE  := cNumLote
							ZFC_GALPAO	:= cGalpao
							ZFC_FILORI  := cFilOrig 
							ZFC_VEICUL	:= aCols[_I,nPosVeic]
							ZFC_GAIOLA	:= aCols[_I,nPosGaio]
							ZFC_AVEGA	:= aCols[_I,nPosAves]
							ZFC_TOTAL	:= aCols[_I,nPosTota]
							ZFC_SEQUEN	:= aCols[_I,nPosSequ]
							ZFC_PESPRE	:= aCols[_I,nPosPsPr]
							ZFC_DTACAR  := aCols[_I,nPosDtca]
							ZFC_DTAPRE	:= aCols[_I,nPosDtPr]
							ZFC_HRAPRE	:= STRTRAN(aCols[_I,nPosHrPr],'.',':')
							ZFC_TIPVIA	:= aCols[_I,nPosTpVa]
							ZFC_EQUIPE	:= aCols[_I,nPosEqui]
							ZFC_VIAGEM	:= nVez
							ZFC_NUMERO	:= cNum
							ZFC_STATUS	:= "1"
							ZFC_AMARRA	:= cAmarra   
							ZFC_LACRES	:= acols[_I,nPoslacr]
							ZFC_HRCHEG	:= acols[_I,nPosHrCh]
							ZFC_OBSERV  := acols[_I,nPosObse]
							ZFC_FRTVLR  := acols[_I,nPosFrtVlr]
							ZFC_FRTPED  := acols[_I,nPosFrtPed]
							ZFC_NF  	:= acols[_I,nPosNF]  //Everson - 10/12/2019 - Chamado 029058.
							ZFC_SERIE   := acols[_I,nPosSer] //Everson - 10/12/2019 - Chamado 029058.
							ZFC_LINHA   := cLinhaZFB //Everson - 29/06/2022 - Chamado 75561.
							MSUNLOCK()     
							cOrdemCarr  := ZFC->ZFC_NUMERO
							nQtAves	    += aCols[_I,nPosTota]
							
							//incluir registro no na tabela ZV1
							DbSelectArea("ZV1")

							RecLock("ZV1", .T.)
								ZV1->ZV1_FILIAL := FWxFilial("ZV1") // @history ticket 69945   - Fernando Macieira - Projeto FAI - Ordens Carregamento - Frango vivo
								ZV1_NUMOC  := cOrdemCarr 
								ZV1_NUMNFS := '1'
								ZV1_SERIE  := '02' 
								ZV1_DATA   := dDataBase
								ZV1_DTABAT := aCols[_I,nPosDtPr]
								ZV1_DTAREA := aCols[_I,nPosDtPr]
								ZV1_PCIDAD := AllTrim( Posicione( 'SA2',1, xFilial( 'SA2' ) + cForCod + cForLoj , 'A2_MUN' ) ) 
								ZV1_TURMA  := Alltrim(aCols[_I,nPosEqui])
								ZV1_PPLACA := aCols[_I,nPosVeic]
								ZV1_RPLACA := aCols[_I,nPosVeic]
								ZV1_PESOME := (aCols[_I,nPosPsPr]/aCols[_I,nPosTota])
								ZV1_RGRANJ := cGranja
								ZV1_PAVES  := aCols[_I,nPosTota]
								ZV1_FORREC := '000217'  //adoro
								ZV1_LOJREC := '01'      //loja adoro
								ZV1_CODPRO := cForCod
								ZV1_LOJPRO := cForLoj
								ZV1_CODFOR := cForCod 
								ZV1_LOJFOR := cForLoj
								ZV1_PGRANJ := cForCod
								ZV1_PHCARR := STRTRAN(aCols[_I,nPosHrPr],'.',':')
								ZV1_PRLOTE := cNumLote                           //Chamado T.I -Fernando sigoli 24/06/2019
							ZV1->( MsUnlock() )
						
						Else
							MsgAlert("Não foi possível gravar a ordem de carregamento do veículo "+ cValToChar(aCols[_I,nPosVeic])+", pois não foi informado o horário de carregamento!")
						
						EndIf
					
					ElseIf Dbseek(xFilial("ZFC")+Alltrim(cValToChar(aCols[_I,nPosNume])))

						//Everson - 10/12/2019 - Chamado 029058. Valida atualização do registro.
						If ! chkFrt(cFilOrig, Alltrim(cValToChar(aCols[_I,nPosNume])))
							Loop

						EndIf
						//
				
						RecLock("ZFC",.F.)    				//AQUI DA UPDATE 
						ZFC_FILIAL	:= xFilial("ZFC")
						ZFC_CODIGO	:= cCodigoSZB
						ZFC_GRANJA	:= cGranja
						ZFC_GALPAO	:= cGalpao
						ZFC_NRLOTE  := cNumLote             //Chamado T.I -Fernando sigoli 24/06/2019
						ZFC_FILORI  := cFilOrig 
						ZFC_VEICUL	:= aCols[_I,nPosVeic]
						ZFC_GAIOLA	:= aCols[_I,nPosGaio]
						ZFC_AVEGA	:= aCols[_I,nPosAves]
						ZFC_TOTAL	:= aCols[_I,nPosTota]
						ZFC_SEQUEN	:= aCols[_I,nPosSequ]
						ZFC_PESPRE	:= aCols[_I,nPosPsPr]
						ZFC_DTACAR  := aCols[_I,nPosDtca]
						ZFC_DTAPRE	:= aCols[_I,nPosDtPr]
						ZFC_HRAPRE	:= STRTRAN(aCols[_I,nPosHrPr],'.',':')
						ZFC_TIPVIA	:= aCols[_I,nPosTpVa]
						ZFC_EQUIPE	:= aCols[_I,nPosEqui]
						ZFC_VIAGEM	:= nVez
						ZFC_STATUS	:= "1"
						ZFC_AMARRA	:= cAmarra   
						ZFC_LACRES	:= acols[_I,nPoslacr]
						ZFC_HRCHEG	:= acols[_I,nPosHrCh]
						ZFC_OBSERV  := acols[_I,nPosObse]
						ZFC_FRTVLR  := acols[_I,nPosFrtVlr]
						ZFC_FRTPED  := acols[_I,nPosFrtPed]
						ZFC_NF      := acols[_I,nPosNF]  //Everson - 10/12/2019 - Chamado 029058.
						ZFC_SERIE   := acols[_I,nPosSer] //Everson - 10/12/2019 - Chamado 029058.
						ZFC_LINHA   := cLinhaZFB //Everson - 29/06/2022 - Chamado 75561.
						MSUNLOCK()
						
						nQtAves	+=	aCols[_I,nPosTota]   
						
						//faz atualização do zf1
						DbselectArea("ZV1")
						DbSetOrder(3)
						dbGoTop()			
						If dbseek(xFilial("ZV1")+Alltrim(cValToChar(aCols[_I,nPosNume])))//numero da ordem de carregamento
							
							RecLock("ZV1", .F.)
							ZV1_NUMOC  := Alltrim(cValToChar(aCols[_I,nPosNume])) 
							ZV1_NUMNFS := '1'
							ZV1_SERIE  := '02' 
							ZV1_DATA   := dDataBase
							ZV1_DTABAT := aCols[_I,nPosDtPr]
							ZV1_DTAREA := aCols[_I,nPosDtPr]
							ZV1_PCIDAD := AllTrim( Posicione( 'SA2',1, xFilial( 'SA2' ) + cForCod + cForLoj , 'A2_MUN' ) )  
							ZV1_TURMA  := Alltrim(aCols[_I,nPosEqui])
							ZV1_PPLACA := aCols[_I,nPosVeic]
							ZV1_RPLACA := aCols[_I,nPosVeic]
							ZV1_PESOME := (aCols[_I,nPosPsPr]/aCols[_I,nPosTota])
							ZV1_RGRANJ := cGranja
							ZV1_PAVES  := aCols[_I,nPosTota]
							ZV1_FORREC := '000217'  //adoro
							ZV1_LOJREC := '01'      //loja adoro
							ZV1_CODPRO := cForCod
							ZV1_LOJPRO := cForLoj
							ZV1_CODFOR := cForCod 
							ZV1_LOJFOR := cForLoj
							ZV1_PGRANJ := cForCod
							ZV1_PHCARR := STRTRAN(aCols[_I,nPosHrPr],'.',':')
							ZV1_PRLOTE := cNumLote                           //Chamado T.I -Fernando sigoli 24/06/2019
							MsUnlock()
						EndIf
						
					Endif	
				
				Else
					Return
				Endif
			Else 
			
				cTicket := Posicione('ZV1', 3 , xFilial('ZV1') + Alltrim(cValToChar(aCols[_I,nPosNume])), 'ZV1_GUIAPE')
				
				If Empty(cTicket)
				
					DbSelectArea("ZFC")
					DbSetOrder(4)
					If dbseek(xFilial("ZFC")+aCols[_I,nPosNume]).And. aCols[_I,Len(aHeader)+1] == .T.

						//Everson - 10/12/2019 - Chamado 029058. Valida exclusão do registro.
						If ! chkFrt(cFilOrig, Alltrim(cValToChar(aCols[_I,nPosNume])))
							Loop

						EndIf
						//
						
						If COPC <> "F"
							
							RecLock("ZFC",.F.)
							dbdelete()
							MSUNLOCK()
								
							DbselectArea("ZV1")
							DbSetOrder(3)
							DbGoTop()			
							If dbseek(xFilial("ZV1")+Alltrim(cValToChar(aCols[_I,nPosNume])))//numero da ordem de carregamento
								RecLock("ZV1",.F.)
								dbdelete()
								MSUNLOCK()
							EndIf
							
						Else
						
							RecLock("ZFC",.F.)
							ZFC_STATUS := "3"
							MSUNLOCK()
									
						EndIf
						
						If nQtAves > 0 
							nQtAves = NQUANT-aCols[_I,nPosTota]	
						EndIf
						
					Endif
				Else
					
					MsgStop("Exclusão não permitido,devido a ordem ja utilizada para pesagens de entrada de aves vivas: "+cTicket)
		
				EndIf
				
				cTicket := ""
			
			Endif
		
		Next _I
		
		DbSelectArea("ZFB")
		RecLock("ZFB",.F.)
		ZFB_STATUS:=IIF(nQtAves >= ZFB->ZFB_QTDPRE,"3",IIF(nQtAves <=0,"1","2"))
		ZFB_AMARRA:=cAmarra
		MsUnlock()
		ConfirmSX8()
		
		//If COPC == "F" .Or. lComplemento == .T. 
		//	U_ADLFV9E("F",cDATAZFB)
		//EndIf
				
		U_ADLFV9A('I') //chamada para abrir novamente a inclusao
		
	Endif

Return
/*/{Protheus.doc} User Function 009VL1
	Valida linha.
	@type Function
	@author Fernando Sigoli
	@since 18/04/17
	@version 01
	/*/    
User Function 009VL1 ()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.                                            |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local lRet := .T.

	U_ADINF009P('ADLFV009P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Programação de Retirada/Apanha de Aves.')
	
	If !Empty(aCols[n,nPosNume])
		
		DbSelectArea("ZFC")
		DbSetOrder(4)
		If DbSeek(xFilial("ZFC")+aCols[n,nPosNume],.F.)
		    If !Empty(ZFC->ZFC_PEDVEN)
				MsgStop("Alteração nao permitida,devido a exitencia de Pedido de venda: "+ZFC->ZFC_PEDVEN)
            	lRet := .F.
            EndIf
    	Endif   
    	
    	//verifico se ja foi utilizado para entrada de veiculos e nao deixamos alterar 
    	DbselectArea("ZV1")
     	DbSetOrder(3)
		DbGoTop()			
		If dbseek(xFilial("ZV1")+Alltrim(cValToChar(aCols[n,nPosNume])))//numero da ordem de carregamento
			If !Empty(ZV1->ZV1_GUIAPE)
				MsgStop("Alteração nao permitida,devido a ordem ja utilizada para pesagens de entrada de aves vivas. Ticket: "+ZV1->ZV1_GUIAPE) 
				Return(.F.)
       		EndIF				
        EndIF
        
    EndIF

Return(lRet)
/*/{Protheus.doc} User Function LACRENU
	Inseri a informacao de Lacre nao usado.
	@type Function
	@author Fernando Sigoli
	@since 18/04/17
	@version 01
	/*/  
User Function LACRENU
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.                                            |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local cNumLacres 	:= Alltrim(M->ZFC_LACRES)
	Local cGet1	 		:= Space(10)
	Local cGet2			:= Space(10)
	Local cGet3			:= Space(10)
	Local cGet4	 		:= Space(10)
	Local cGet5	 		:= Space(10) 
	Local lCheckBox1	:= .F.
	Local cLacres       := ""

	Private oDlg	

	U_ADINF009P('ADLFV009P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Programação de Retirada/Apanha de Aves.')
				
	If cNumLacres == "NAO INFORMADO"
		lCheckBox1	:= .T.

	Else 
		If Len(cNumLacres) >= 10
			cGet1  := Substr(cNumLacres,01,10)	
		EndIF
		
		If Len(cNumLacres) >= 20
			cGet2  := Substr(cNumLacres,12,10)
		EndIf
		
		If Len(cNumLacres) >= 30
			cGet3  := Substr(cNumLacres,23,10)
		EndIf
		
		If Len(cNumLacres) >= 40 
			cGet4  := Substr(cNumLacres,35,10)
		EndIf
		
		If Len(cNumLacres) >= 50 
			cGet5  := Substr(cNumLacres,47,10)
		EndIf

	EndIf	

	DEFINE MSDIALOG oDlg TITLE "Cadastro de Lacres" FROM C(234),C(327) TO C(527),C(682) PIXEL

		// Cria Componentes Padroes do Sistema
		@ C(007),C(065) Say "Cadastros de Lacres" Size C(054),C(008) COLOR CLR_BLACK PIXEL OF oDlg
		@ C(024),C(068) MsGet oGet1 Var cGet1 Size C(060),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
		@ C(025),C(043) Say "Lacre 1" Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
		
		@ C(040),C(068) MsGet oGet2 Var cGet2 Size C(060),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
		@ C(041),C(043) Say "Lacre 2" Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
		
		@ C(055),C(068) MsGet oGet3 Var cGet3 Size C(060),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
		@ C(057),C(043) Say "Lacre 3" Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
		
		@ C(070),C(068) MsGet oGet4 Var cGet4 Size C(060),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
		@ C(071),C(043) Say "Lacre 4" Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
		
		@ C(083),C(068) MsGet oGet5 Var cGet5 Size C(060),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
		@ C(086),C(043) Say "Lacre 5" Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg    
		
		@ C(098),C(069) CheckBox oCheckBox1 Var lCheckBox1 Prompt "Nao Informado" Size C(048),C(008) PIXEL OF oDlg
		
		@ C(112),C(037) Button "OK" Size C(037),C(012) PIXEL OF oDlg    ACTION oDlg:end()

	ACTIVATE MSDIALOG oDlg CENTERED 

		
	If lCheckBox1 
		
		cLacres := "NAO INFORMADO"
		
	Else	
			
		If !Empty(ALLTRIM(cGet1))
			cLacres += PADL(ALLTRIM(cGet1),10,"0")+"/"
		EndIF
			
		If !Empty(ALLTRIM(cGet2))                   
			cLacres += PADL(ALLTRIM(cGet2),10,"0")+"/"
		EndIF
			
		If !Empty(ALLTRIM(cGet3))
			cLacres += PADL(ALLTRIM(cGet3),10,"0")+"/"
		EndIf
			
		If !Empty(ALLTRIM(cGet4))
			cLacres += PADL(ALLTRIM(cGet4),10,"0")+"/"
		EndIf
			
		If !Empty(ALLTRIM(cGet5))
			cLacres += PADL(ALLTRIM(cGet5),10,"0")+"/"
		Endif 	 
		
	EndIf

	If !lCheckBox1
		If Empty(alltrim(cGet1)+alltrim(cGet2)+alltrim(cGet3)+alltrim(cGet4)+alltrim(cGet5))
			MsgStop("Atenção! lacres não informado")
			Return 
		EndIf		
	EndIf
            
Return cLacres                      
/*/{Protheus.doc} User Function VALVEICA
	Controle cadastro de veiculos -  verificar veiculo e as viagens realizada no dia.
	@type Function
	@author Fernando Sigoli
	@since 18/04/17
	@version 01
	/*/  
User Function VALVEICA()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.                                            |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local cAlias 	:= Alias()
	Local cPlaca	:= M->ZFC_VEICUL
	Local lRr		:= .T.
	Local cVecAloc	:= aCols[n,nPosNume]
	Local nCheckV   := ""
	Local cTpViag	:= ""
	Local _po		:= 1

	Local nPosPlaca	:= aScan(aHeader,{|x| ALLTRIM(X[2])=="ZFC_VEICUL"})
	Local nPosEqApa := aScan(aHeader,{|x| ALLTRIM(X[2])=="ZFC_EQUIPE"})
	Local nTotalPrg	:=	0

	U_ADINF009P('ADLFV009P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Programação de Retirada/Apanha de Aves.')

		
		aCols[n,nPosTpVa]  := "1" 
		aCols[n,nPosEqApa] := cEquipe
		
		If Empty(cPlaca)
			MsgStop("Informar Placa do veiculo. Atenção")
			Return(.F.)
		Endif
		
		If OpcSelec == "F" .and. !Empty(Alltrim(cVecAloc)) 
			MsgStop("Alteração não permitida!")
			Return(.F.)
		EndIf

		If !Empty(aCols[n,nPosNume])
			DbSelectArea("ZFC")
			DbSetOrder(4)
			If DbSeek(xFilial("ZFC")+aCols[n,nPosNume],.F.)
				If !Empty(ZFC->ZFC_PEDVEN)
					MsgStop("Alteração nao permitida,devido a exitencia de Pedido de venda: "+ZFC->ZFC_PEDVEN)
					Return(.F.)
				EndIf
			Endif
			
			//verifico se ja foi utilizado para entrada de veiculos e nao deixamos alterar 
			DbselectArea("ZV1")
			DbSetOrder(3)
			DbGoTop()			
			If dbseek(xFilial("ZV1")+Alltrim(cValToChar(aCols[n,nPosNume])))//numero da ordem de carregamento
				If !Empty(ZV1->ZV1_GUIAPE)
					MsgStop("Alteração nao permitida,devido a ordem ja utilizada para pesagens de entrada de aves vivas. Ticket: "+ZV1->ZV1_GUIAPE) 
					Return(.F.)
				EndIF				
			EndIF
		EndIF 
		
		If aScan(aOrig,{|x| x[1]== cPlaca }) <> 0
				
			If !MsgYesNo("O veículo " +cPlaca+ " já foi alocado nesta coleta!!!" + Chr(13) + "Deseja prosseguir?") 
			Return(.F.)
			Else
				aCols[n,nPosTpVa] := "3"
			EndIf
		
		EndIf	
				
		DbSelectArea("DA3")
		DbSetOrder(1)
		If DbSeek(xFilial("DA3")+cPlaca,.F.)
			If Empty(DA3->DA3_TARA) .or. Empty(DA3->DA3_XTARM)
				MsgStop("Veiculo "+cPlaca+" sem valor de Tara. Atualizar cadastro")
				Return(.F.)
			
			Endif
			
			If DA3->DA3_QTDUNI = 0
				MsgStop("Veiculo "+cPlaca+" sem informação de Quantidade de Gaiolas. Atualizar cadastro")
				Return(.F.)

			Endif
		
			If Empty(DA3->DA3_XFRET)
				MsgStop("Veiculo " +cPlaca+ " sem tabela de Frete Cadastrado!!!FAVOR, VERIFICAR CADASTRO")
				Return(.F.)
			
			ElseIf Empty(DA3->DA3_TARA) .or. Empty(DA3->DA3_XTARM)
				MsgStop("Veiculo " +cPlaca+ " sem peso de Tara/Tara Molhada Cadastrado!!FAVOR, VERIFICAR CADASTRO!")
				Return(.F.)
		
			ElseIf Empty(DA3->DA3_QTDUNI)
				MsgStop("Veiculo " +cPlaca+ "  sem quantidade de Caixas Cadastrado!!!FAVOR, VERIFICAR CADASTRO")
				Return(.F.)
			
			EndIf
				
			//Verifica se ja existem outras viagens para o veiculo fora desse programaçao aberta
			cQuery	:=	"SELECT ZFC_TOTAL,ZFC_TIPVIA FROM " + Retsqlname("ZFC") +" "
			cQuery	+=	"WHERE D_E_L_E_T_ <> '*' "
			cQuery	+=	"AND ZFC_VEICUL =  '"+cPlaca+"' "
			cQuery	+=	"AND ZFC_DTAPRE =  '"+dtos(aCols[N,nPosDtPr])+"' "
			cQuery	+=	"AND ZFC_CODIGO <> '"+cCodigoSZB+"' "
			cquery 	+=  "AND ZFC_FILIAL =  '"+xfilial("ZFC")+"' "
			cquery 	+=  "AND ZFC_STATUS <> '3' "        
			cQuery	+=	"ORDER BY ZFC_TIPVIA"
			
			TCQUERY cQuery new alias "XVA"

			DbSelectArea("XVA")
			DbGotop()
			If !Eof()
				While !Eof()
					nCheckV   := XVA->ZFC_TIPVIA 
					cTpViag	  := XVA->ZFC_TIPVIA//Obtem o tipo de viajem dos veiculos ja programados
					nTotalPrg += XVA->ZFC_TOTAL //Soma o total programado
				Dbskip()
				Enddo
				
				//Percorre todo o acols para as linhas NAO deletadas e verifica se a placa ja foi digitada
				//Se ja foi, acumula o total programado 
				For _po	:=	1 TO  Len(aCols)
					If	aCols[_po][nPosPlaca] == cPlaca  .and. !aCols[_po][Len(aHeader)+1]
						nTotalPrg += aCols[_po][4]
					Endif
				Next

				aCols[N][nPosTota]	:=	(DA3->DA3_QTDUNI*MV_PAR03) - nTotalPrg //Grava o saldo de aves programados na linha
				M->ZFC_TOTAL		:=	(DA3->DA3_QTDUNI*MV_PAR03) - nTotalPrg //Atualiza o total de aves programadas
				
				If !Empty(Alltrim(nCheckV)) //Checa viagem para o dia de abate
					MsgInfo("Este veículo já foi utilizado na roteirização deste dia de abate." + chr(13) +;
							"A viagem será considerada do tipo retorno.") 
					aCols[n,nPosTpVa]	:= "3"
				
				Endif
						
			Endif    
			
			DbSelectArea("XVA")
			XVA->(Dbclosearea())
			
			//calculo do frete+pedagio
			nVlrFrete := CalculoFrete(DA3->DA3_XFRET,nKilometro)
			aCols[n,nPosFrtVlr] := nVlrFrete
		
			If DA3->DA3_TIPVEI == '01'
				aCols[n,nPosFrtPed] := ((nVlrEixo*3)*nPracas)
				aCols[n,nPosFrtTot] := nVlrFrete+((nVlrEixo*3)*nPracas)
			EndIf
		
		Else
		
			MsgStop("Veiculo não Cadastrado, Verificar!")
			lRr	:=	.F.
		
		Endif  
		
		
		If (DA3->DA3_QTDUNI*MV_PAR03) > 0 
			aCols[n,nPosPsPr] := (DA3->DA3_QTDUNI*MV_PAR03)*nPeso
		EndIf
		
		
	DbSelectArea(cAlias)

Return(lRr)
/*/{Protheus.doc} User Function VALEQUIPE
	Valida equipe de carregamento.
	@type Function
	@author Fernando Sigoli
	@since 18/04/17
	@version 01
	/*/  
User Function VALEQUIPE()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.                                            |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local lRet    := .T.

	U_ADINF009P('ADLFV009P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Programação de Retirada/Apanha de Aves.')

	DbselectArea("ZF1")
	Dbsetorder(1)
	If !DbSeek(xFilial("ZF1")+M->ZFC_EQUIPE,.F.)
		MsgStop("ATENÇÃO! Equipe de Carregamento nao encontrado no cadastro")
		lRet := .F.
	EndIf 
	
	If !Empty(aCols[n,nPosNume])
	
	    DbselectArea("ZV1")
	    DbSetOrder(3)
		DbGoTop()			
		If dbseek(xFilial("ZV1")+Alltrim(cValToChar(aCols[n,nPosNume])))//numero da ordem de carregamento
			If !Empty(ZV1->ZV1_GUIAPE)
				MsgStop("Alteração nao permitida,devido a ordem ja utilizada para pesagens de entrada de aves vivas. Ticket: "+ZV1->ZV1_GUIAPE) 
				Return(.F.)
        	EndIF				
	    EndIF
	
	EndIf
	
Return lRet
/*/{Protheus.doc} User Function VALAVEGA
	Valida quantidade de aves- gatilho.
	@type Function
	@author Fernando Sigoli
	@since 18/04/17
	@version 01
	/*/  
User Function VALAVEGA()       
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.                                            |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local nAVEGA	:= M->ZFC_AVEGA

	U_ADINF009P('ADLFV009P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Programação de Retirada/Apanha de Aves.')
	
	If !Empty(aCols[n,nPosNume])
	
	    DbselectArea("ZV1")
	    DbSetOrder(3)
		DbGoTop()			
		If dbseek(xFilial("ZV1")+Alltrim(cValToChar(aCols[n,nPosNume])))//numero da ordem de carregamento
			If !Empty(ZV1->ZV1_GUIAPE)
				MsgStop("Alteração nao permitida,devido a ordem ja utilizada para pesagens de entrada de aves vivas. Ticket: "+ZV1->ZV1_GUIAPE) 
				Return(.F.)
        	EndIF				
	    EndIF
	
	EndIf
	
	If (aCols[n,nPosGaio]*nAVEGA) > 0  
   		aCols[n,nPosPsPr] := (aCols[n,nPosGaio]*nAVEGA)*nPeso
	EndIf

      
Return .T.
/*/{Protheus.doc} User Function VALTOTAL
	Valida quantidade de aves- gatilho.
	@type Function
	@author Fernando Sigoli
	@since 18/04/17
	@version 01
	/*/ 
User Function VALTOTAL()       
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.                                            |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local nTOTAL	:= M->ZFC_TOTAL

	U_ADINF009P('ADLFV009P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Programação de Retirada/Apanha de Aves.')
	
	If !Empty(aCols[n,nPosNume])
	
	    DbselectArea("ZV1")
	    DbSetOrder(3)
		DbGoTop()			
		If dbseek(xFilial("ZV1")+Alltrim(cValToChar(aCols[n,nPosNume])))//numero da ordem de carregamento
			If !Empty(ZV1->ZV1_GUIAPE)
				MsgStop("Alteração nao permitida,devido a ordem ja utilizada para pesagens de entrada de aves vivas. Ticket: "+ZV1->ZV1_GUIAPE) 
				Return(.F.)
        	EndIF				
	    EndIF
	
	EndIf
    //
    If (nTOTAL*nPeso) > 0  
   		aCols[n,nPosPsPr] := nTOTAL*nPeso
	EndIf
	  
Return .T.
/*/{Protheus.doc} Static Function CalculoFrete
	Pesquisa na tabela qual o valor do frete para determinado KM.
	@type Function
	@author Fernando Sigoli
	@since 18/04/17
	@version 01
	/*/ 
Static Function CalculoFrete(cTabFrete,nKmFrete,nPraca,nVlreixo)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.                                            |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local nVlrFrete := 0

	cQryFrt := " SELECT * FROM " + Retsqlname("ZF6")+" ZF6"
	cQryFrt += " WHERE 
	cQryFrt += " (
	cQryFrt += " (ZF6.ZF6_TABKMI BETWEEN "+cValtoChar(nKmFrete)+" AND "+cValtoChar(nKmFrete)+" ) OR " 
	cQryFrt += " (ZF6.ZF6_TABKMF    BETWEEN "+cValtoChar(nKmFrete)+" AND "+cValtoChar(nKmFrete)+" ) OR " 
	cQryFrt += " ("+cValtoChar(nKmFrete)+" BETWEEN ZF6.ZF6_TABKMI AND ZF6.ZF6_TABKMF ) OR 
	cQryFrt += " ("+cValtoChar(nKmFrete)+" BETWEEN ZF6.ZF6_TABKMI AND ZF6.ZF6_TABKMF )
	cQryFrt += "    )
	cQryFrt += " AND ZF6.ZF6_TABCOD = '"+cTabFrete+"'"
	                   
	If Select("XZF6") > 0
		XZF6->(DbCloseArea())
  	EndIf
                    
	TCQUERY cQryFrt new alias "XZF6"

	DbSelectArea("XZF6")
    
    nVlrFrete := XZF6->ZF6_TABPRC

	XZF6->(DbClosearea())

Return nVlrFrete
/*/{Protheus.doc} User Function VALVEICB
	Funcao para os Status das viagens do veiculos.
	@type Function
	@author Fernando Sigoli
	@since 18/04/17
	@version 01
	/*/ 
User Function VALVEICB()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.                                            |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	U_ADINF009P('ADLFV009P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Programação de Retirada/Apanha de Aves.')
	If !Empty(aCols[n,nPosNume])
		
		DbSelectArea("ZFC")
		DbSetOrder(4)
		If DbSeek(xFilial("ZFC")+aCols[n,nPosNume],.F.)
			If !Empty(ZFC->ZFC_PEDVEN)
				MsgStop("Alteração nao permitida,devido a exitencia de Pedido de venda: "+ZFC->ZFC_PEDVEN)
            	Return(.F.)
            EndIf
    	Endif
    	//
    	//verifico se ja foi utilizado para entrada de veiculos e nao deixamos alterar 
    	DbselectArea("ZV1")
     	DbSetOrder(3)
		DbGoTop()
		//Everson - 15/09/2021. Chamado 32634.			
		//If dbseek(xFilial("ZV1")+Alltrim(cValToChar(aCols[_I,nPosNume])))//numero da ordem de carregamento //Everson - 15/09/2021. Chamado 32634. 
		If dbseek(xFilial("ZV1")+Alltrim(cValToChar(aCols[n,nPosNume])))//numero da ordem de carregamento 
			If !Empty(ZV1->ZV1_GUIAPE)
				MsgStop("Alteração nao permitida,devido a ordem ja utilizada para pesagens de entrada de aves vivas. Ticket: "+ZV1->ZV1_GUIAPE) 
				Return(.F.)
       		EndIF				
        EndIF
        
    EndIF

	DbSelectArea("ZFC")
	DbSetOrder(2)
	If Dbseek(xFilial("ZFC")+aCols[n][1]+dtos(aCols[n][13]),.F.)
	   If ZFC->ZFC_STATUS <> "3" 
    		
    		If	M->ZFC_TIPVIA == "1" .AND. ZFC->ZFC_TIPVIA == "1"
    			MSGSTOP("Já Existe Viagem! Altere a opção para complemento ou Retorno")
    			Return(.F.)
    		Elseif	M->ZFC_TIPVIA == "3" .AND. ZFC->ZFC_TIPVIA == "3"
    			MSGSTOP("Já Existe Retorno! Altere a opção para Viagem ou Complemento")
    			Return(.F.)
    		Endif
    		
		EndIf 
		
	Endif  
	
Return(.T.)
/*/{Protheus.doc} User Function 009LINOK
	Valida linha.
	@type Function
	@author Fernando Sigoli
	@since 18/04/17
	@version 01
	/*/                                 
User Function 009LINOK
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.                                            |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	Local aArea	    := GetArea()	
	Local lRet      := .T.
	Local aVecHr    := {}
	Local aVecHr2   := {}
	Local nMarc     := 0
	Local nFrtVlr   := 0

	Local cNFLn		:= ""
	Local cSrLn		:= ""
	Local ip		:= 1
	Local y			:= 1
	Local i 		:= 1

	U_ADINF009P('ADLFV009P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Programação de Retirada/Apanha de Aves.')

	nSaldo	:= NQUANT
	nFrtKg  :=  0

	//Everson - 10/12/2019 - Chamado 029058.
	If lVldNF .And. lRet .And. ! aCols[n,Len(aHeader)+1]

		//
		If Empty(Alltrim(aCols[n,nPosNF])) .Or. Empty(Alltrim(aCols[n,nPosSer]))
			MsgStop("Necessário informar o número da nota fiscal e série para ordem de carregamento " + cValToChar(aCols[n,nPosNume]) + ".","Função 009LINOK(ADLFV009P")
			RestArea(aArea)
			Return .F.

		Else
			If ! chkNF(cFilOrig, Alltrim(aCols[n,nPosNF]), Alltrim(aCols[n,nPosSer]),Alltrim(aCols[n,nPosNume])) //Everson - 11/12/2019 - chamado 029058.
				RestArea(aArea)
				Return .F.

			EndIf

			//
			cNFLn := Alltrim(aCols[n,nPosNF])
			cSrLn := Alltrim(aCols[n,nPosSer])

		EndIf

	EndIf
	//

	For	ip	:=	1 to len(acols)
		
		If	!aCols[ip,nTC]

			//Everson - 10/12/2019 - Chamado 029058.
			If lVldNF .And. Alltrim(aCols[ip,nPosNF]) = cNFLn .And. Alltrim(aCols[ip,nPosSer]) = cSrLn .And. ip <> n
				MsgStop("Nota fiscal já informada na linha " + cValToChar(ip) + ".","Função 009LINOK(ADLFV009P")
				RestArea(aArea)
				Return .F.

			EndIf
			//

			//Everson - 11/12/2019 - Chamado 029058.
			If lVldNF .And. aCols[ip][nPosFrtVlr] <= 0
				MsgStop("Valor de frete não informado na linha " + cValToChar(ip) + ".","Função 009LINOK(ADLFV009P")
				RestArea(aArea)
				Return .F.

			EndIf

			nSaldo  -= aCols[ip][nPosTota]
			
			nFrtVlr  += aCols[ip][nPosFrtVlr]+aCols[ip][nPosFrtPed]
			nFrtKg   += aCols[ip][nPosPsPr]
		
		Else
			
			DbSelectArea("ZFC")
			DbSetOrder(2)
			If Dbseek(xFilial("ZFC")+aCols[ip,nPosVeic]+DTOS(dDtPrev),.F.)
				While !Eof() .and. aCols[ip,nPosVeic] == ZFC->ZFC_VEICUL .and. dDtPrev == ZFC->ZFC_DTAPRE
					
					If ZFC->ZFC_STATUS <> "3" 
					
						If	cCodigoSZB	<>	 ZFC->ZFC_CODIGO .and. aCols[ip,nPosVeic] == ZFC->ZFC_VEICUL .and. (ZFC->ZFC_TIPVIA == "2" .or. ZFC->ZFC_TIPVIA == "4")
							Msgstop(" Veiculo com Complemento em Outra Granja!!! Excluir!")
							aCols[ip,nTC]:=.F.
							nSaldo	-= aCols[ip][nPosTota]
							Exit
						Endif
					
					EndIf
				
				Dbskip()
				End
			
			Endif
		
		Endif
							
		Aadd(aVecHr,{aCols[ip,nPosVeic],aCols[ip,nPosHrCh],nMarc++})
			
	Next     

	nFrtKg 	:= Round(nFrtVlr/nFrtKg,2)
	aVecHr2 := aClone(aVecHr)

	For i := 1 To Len(aVecHr)
			
		For y := 1 To Len(aVecHr2)
		
			If aVecHr[i][1] == aVecHr2[y][1] .And. aVecHr[i][2] == aVecHr2[y][2] .And. aVecHr[i][3] <> aVecHr2[y][3]
				lRet := .F.
				MsgAlert("Por favor, confira os horários de chegada das carga alocadas ao veículo "+cValToChar(aVecHr[i][1]) +".")
				Exit
			EndIf
		Next

	Next

	//
	RestArea(aArea)

Return(lRet)
/*/{Protheus.doc} User Function 009TUDOOK
	Valida tudo ok.
	@type Function
	@author Fernando Sigoli
	@since 18/04/17
	@version 01
	/*/             
User Function 009TUDOOK
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.                                            |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
	Local aVecHr    := {}
	Local aVecHr2   := {}
	Local nMarc     := 0
	Local nSaldo1	:= 0
	Local lVlrl		:=	.T.
	Local oDlg		:= Nil
	Local ip 		:= 1
	Local y			:= 1
	Local i			:= 1

	U_ADINF009P('ADLFV009P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Programação de Retirada/Apanha de Aves.')
		
	For	ip	:=	1 to len(acols)
		
		If	!aCols[ip,nTC]
		
			If Empty(Alltrim(aCols[ip,nPosEqui]))
				MsgStop("Por favor, verifique se foram informadas as equipes de carregamento para todos os registros!")
				Return(.F.)
			EndIf 
	
			If Empty(Alltrim(aCols[ip,nPosHrPr]))
				MsgStop("Por favor, verifique se foram informado os horario de carregamento para todos os registros!")
				Return(.F.)
			EndIf 
	
			If Empty(Alltrim(aCols[ip,nPosHrCh]))
				MsgStop("Por favor, verifique se foram informado os horario de chegada para todos os registros!")
				Return(.F.)
			EndIf 

			//Everson - 10/12/2019 - Chamado 029058.
			If lVldNF .And. ( Empty(Alltrim(aCols[ip,nPosNF])) .Or. Empty(Alltrim(aCols[ip,nPosSer])) )
				MsgStop("Necessário informar o número da nota fiscal e série para ordem de carregamento " + cValToChar(aCols[ip,nPosNume]) + ".","Função 009LINOK(ADLFV009P")
				Return .F.

			Else
				If ! chkNF(cFilOrig, Alltrim(aCols[ip,nPosNF]), Alltrim(aCols[ip,nPosSer]),Alltrim(aCols[ip,nPosNume])) //Everson - 11/12/2019 - chamado 029058.
					Return .F.

				EndIf 

			EndIf
			//

			//Everson - 11/12/2019 - Chamado 029058.
			If lVldNF .And. aCols[ip][nPosFrtVlr] <= 0
				MsgStop("Valor de frete não informado na linha " + cValToChar(ip) + ".","Função 009LINOK(ADLFV009P")
				RestArea(aArea)
				Return .F.

			EndIf
	
			nSaldo1	+= aCols[ip][nPosTota]
		
		Endif
		
		Aadd(aVecHr,{aCols[ip,nPosVeic],aCols[ip,nPosHrCh],nMarc++})
			
	Next

	aVecHr2 := aClone(aVecHr)
	For i := 1 To Len(aVecHr)
		
		For y := 1 To Len(aVecHr2)
		
			If 	aVecHr[i][1] <> aVecHr2[y][1] .and. aVecHr[i][2] == aVecHr2[y][2] .and. aVecHr[i][3] <> aVecHr2[y][3]
				MsgAlert("Por favor, confira os horários de chegada das carga alocadas ao veículo "+cValToChar(aVecHr[i][1]) +".")
				lVlrl  := .F.
				Exit
			EndIf
	
		Next

	Next
	
	If nSaldo1 > nQuant .And. (!__cUserID $ GETMV("MV_#USRFVR"))

		MSGSTOP("Quantidade programada nao pode ser superior a da granja")
		lVlrl	:=	.F.

	ElseIf	nSaldo1 > nQuant 

		lVlrl	:=	.F.
		
		DEFINE MSDIALOG oDlg TITLE "Mensagem de quantidade" FROM C(222),C(290) TO C(312),C(598) PIXEL
		
			@ C(005),C(009) Say "A quantidade roteirizada esta difere da quantidade programada." Size C(138),C(008) COLOR CLR_RED PIXEL OF oDlg
			@ C(017),C(038) Say "Confirma o processo?" Size C(066),C(008) COLOR CLR_RED PIXEL OF oDlg
			
		// Chamado n. 050729 || OS 052035 || TECNOLOGIA || LUIZ || 8451 || REDUCAO DE BASE - FWNM - 07/07/2020 - Retirado @ C do SBUTTON
		DEFINE SBUTTON FROM 031,030 TYPE 1 ACTION ( lVlrl := .T., oDlg:end() ) ENABLE OF oDlg 
		DEFINE SBUTTON FROM 031,087 TYPE 2 ACTION oDlg:End()                   ENABLE OF oDlg  
		//
		
		ACTIVATE MSDIALOG oDlg CENTERED

	Endif

Return(lVlrl)
/*/{Protheus.doc} User Function 009DLINOK
	Valida linha.
	@type Function
	@author Fernando Sigoli
	@since 18/04/17
	@version 01
	/*/    
User Function 009DLINOK
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.                                            |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local nSaldo	:= nQuant
	Local ip		:= 1

	U_ADINF009P('ADLFV009P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Programação de Retirada/Apanha de Aves.')

	For	ip	:=	1 to len(acols)
		
		If	!aCols[ip,nTC]
			nSaldo	-= aCols[ip][nPosTota]
		Endif
		
	Next

Return(.T.)
/*/{Protheus.doc} User Function 009DTUDOOK
	Valida tudo.
	@type Function
	@author Fernando Sigoli
	@since 18/04/17
	@version 01
	/*/ 
User Function  009DTUDOOK
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.                                            |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local nSaldo1	:= 0
	Local lVlrl		:=.T.
	Local ip		:= 1

	U_ADINF009P('ADLFV009P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Programação de Retirada/Apanha de Aves.')

	For	ip	:=	1 to len(acols)
		If	!aCols[ip,nTC]
			nSaldo1	+= aCols[ip][nPosTota]
		Endif
	Next

	If nSaldo1 > nQuant
		MsgStop("Quantidade roteirizada difere da quantidade na granja ")
		lVlrl := .F.
	Endif

Return(lVlrl)
/*/{Protheus.doc} User Function ADLFV9B
	Impressao da ordem de carregamento.
	@type Function
	@author Fernando Sigoli
	@since 18/04/17
	@version 01
	/*/          
User Function ADLFV9B(nOpca)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.                                            |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Private aArea	    := GetArea()
	Private titulo      := "Ordem de Carregamento"
	Private aReturn     := {"Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private cPerg	    := "ADLFV9B"

	Private oFont, cCode
	Private oFontA08N	:= TFont():New( "Arial",,08,,.F.,,,,,.F. )
	Private oFontA16N	:= TFont():New( "Arial",,16,,.F.,,,,,.F. )
	Private oFontA16B	:= TFont():New( "Arial",,16,,.T.,,,,,.F. )
	Private oFontA14N	:= TFont():New( "Arial",,14,,.F.,,,,,.F. )
	Private oFontA14B	:= TFont():New( "Arial",,14,,.T.,,,,,.F. )
	Private oFontA10N	:= TFont():New( "Arial",,10,,.F.,,,,,.F. )
	Private oFontA10B	:= TFont():New( "Arial",,10,,.T.,,,,,.F. )
	Private oFontA12N	:= TFont():New( "Arial",,12,,.F.,,,,,.F. )
	Private oFontA12B	:= TFont():New( "Arial",,12,,.T.,,,,,.F. )
	Private oFontA14BB	:= TFont():New( "Arial Black",,-14,,.f.,,,,,.F. )
	Private oFontA14BBB	:= TFont():New( "Arial Black",,-14,,.T.,,,,,.F. )
	Private oPrn		:= TMSPrinter():New()

	U_ADINF009P('ADLFV009P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Programação de Retirada/Apanha de Aves.')

	//Monta grupo de perguntas
	cMV1 := MV_PAR01
	cMV2 := MV_PAR02

	If nOpca==1             
		MontaPerg()
		If !Pergunte(cPerg,.t.)
			RestArea(aArea)    
			MV_PAR01:= cMV1
			MV_PAR02:= cMV2
			Return
		EndIf
	EndIf

	dbSelectArea("ZFB")

	Private cCodigoSZB  := ZFB->ZFB_CODIGO
	Private cGranja		:= ZFB->ZFB_GRACOD
	Private cGalpao		:= ZFB->ZFB_GALPAO
	Private dDtAbate    := ZFB->ZFB_ABTPRE  
	
	If nopca==1 .and. (Empty(MV_PAR01) .OR. Empty(MV_PAR02))
		Aviso("Atenção","Preenchimento Obrigatorio dos Parametros, Verifique",{"OK"},2)
		Return()
	EndIf

	If nopca==1
		
		cQuery	:=	" SELECT * "
		cQuery	+=	" FROM " + retsqlname("ZFC") +" "
		cQuery	+=	" WHERE D_E_L_E_T_ <> '*' "
		cQuery	+=	" AND ZFC_NUMERO BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' "
		cQuery	+=	" AND ZFC_FILIAL='"+XFILIAL("ZFC")+"' "
		cQuery 	+=  " AND ZFC_STATUS <> '3' "
		cQuery	+=	"ORDER BY ZFC_NUMERO "

	Else   

		cQuery	:=	" SELECT * "
		cQuery	+=	" FROM " + retsqlname("ZFC") +" "
		cQuery	+=	" WHERE D_E_L_E_T_ <> '*' "
		cQuery	+=	" AND ZFC_CODIGO = '"+cCodigoSZB+"' "
		cQuery	+=	" AND ZFC_GRANJA = '"+cGranja+"' "
		cQuery	+=	" AND ZFC_GALPAO = '"+cGalpao+"' "
		cQuery	+=	" AND ZFC_DTAPRE = '"+DTOS(dDtAbate)+"' "
		cQuery	+=	" AND ZFC_FILIAL='"+XFILIAL("ZFC")+"' "
		cQuery 	+=  " AND ZFC_STATUS <> '3' "
		cQuery	+=	"ORDER BY ZFC_NUMERO "

	EndIf	
	TCQUERY cQuery new alias "XZFC"

	DbSelectArea("XZFC")
	XZFC->(DbGotop())
	While ! XZFC->(Eof())

		RptStatus({|| RumOrdemCar() },Titulo)
		oPrn:Endpage()

		XZFC->(DbSkip())

	Enddo       

	oPrn:Preview()
	MS_FLUSH()

	MV_PAR01:= cMV1 
	MV_PAR02:= cMV2

	XZFC->(Dbclosearea())

	RestArea(aArea)
	
Return
/*/{Protheus.doc} Static Function RumOrdemCar
	Impressao de ordem de carregamento de frango vivo por granja.
	@type Function
	@author Fernando Sigoli
	@since 18/04/17
	@version 01
	/*/         
Static Function RumOrdemCar()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.                                            |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local cPlaca 	:= ""
	Local dDtaBase	:= RIGHT(DTOS(DDATABASE),2)+"/"+SUBSTR(DTOS(DDATABASE),5,2)+"/"+LEFT(DTOS(DDATABASE),4)
	Local cHora		:= time()
	Local nLin		:= 135
	Local cNomLogo  := "ADORO.BMP"
	Local nLarg     := 240
	Local nAlt      := 150    
	Local L			:= 1   

	//Everson, 30/06/2022, ticket 75561.
	Local aTpLinha  := RetSX3Box(GetSX3Cache("ZFB_LINHA", "X3_CBOX"),,,1)
	Local cLinhaZFC	:= XZFC->ZFC_LINHA  
	Local cLinhagem	:= Iif(Empty(cLinhaZFC), "    ", aTpLinha[Val(cValToChar(cLinhaZFC)),3])
	//                       

	oPrn:Startpage()
	oPrn:SetPaperSize(10)
	oPrn:SetPortrait()    // retrato

	//========= bloco 1 =========
	oPrn:SayBitmap( 0025,0060, cNomLogo, nLarg , nAlt )

	oPrn:Say(0082,0550,"ORDEM DE CARREGAMENTO - FRANGO VIVO ",oFontA14B,0100)
	oPrn:Say(0091,1775,"Data/Hora: ",oFontA10B,0100)
	oPrn:Say(0091,1985, dDtaBase +" - "+ cHora,oFontA10B,0100)
	oPrn:Say(0130,1775,"Usuário : ",oFontA10B,0100)
	oPrn:Say(0130,1985,Alltrim(UPPER(cusername)),oFontA10B,0100)

	//========= bloco 2 =========
	oPrn:Say(0189,1750,"NÚMERO:",oFontA14B,0100)
	oPrn:Say(0180,2080,XZFC->ZFC_NUMERO,oFontA16B,0100)

	MSBAR3('CODE128',21,10,alltrim(XZFC->ZFC_VEICUL+XZFC->ZFC_NUMERO),oPrn,.F.,,,0.030,0.7,.T.,,,.F.)    

	oPrn:Say(0189,0090,"DATA DO ABATE:",oFontA14B,0100)
	_cDta	:=	RIGHT(XZFC->ZFC_DTAPRE,2)+"/"+SUBSTR(XZFC->ZFC_DTAPRE,5,2)+"/"+LEFT(XZFC->ZFC_DTAPRE,4)
	oPrn:Say(0189,0570,_cDta,oFontA14B,0100)


	//========= bloco 3 =========

	//oPrn:Box(0260,0030,0720,2360) 		//150 x 2330
	oPrn:Box(0255,0030,0780,2360) 		//150 x 2330 Chamado T.I -Fernando sigoli 05/07/2019 

	oPrn:Say(0285,0080,"Veiculo:",oFontA12B,0100)
	oPrn:Say(0355,0080,"Motorista:",oFontA12B,0100)
	oPrn:Say(0435,0080,"INFORMAÇÕES DE COLETA: ",oFontA10B,0100)
	oPrn:Say(0285,0780,"Quantidade Gaiolas:",oFontA12B,0100)
	oPrn:Say(0355,0900,"Transportadora:",oFontA12B,0100)   //Chamado T.I -Fernando sigoli 05/07/2019 

	oPrn:Say(0285,0300,XZFC->ZFC_VEICUL,oFontA12B,0100)

	DbSelectArea("DA3")
	DA3->(DbSetOrder(1))
	DA3->(DbSeek(xFilial("DA3")+XZFC->ZFC_VEICUL,.F.))

	DbSelectArea("DA4")
	DA4->(DbSetOrder(1))
	DA4->(DbSeek(xFilial("DA4")+DA3->DA3_MOTORI,.F.))

	DbSelectArea("SA4")
	SA4->(DbSetOrder(1))
	SA4->(DbSeek(xFilial("SA4")+DA3->DA3_XTRANS,.F.))

	oPrn:Say(0355,0325,SUBSTR(DA4->DA4_NOME,1,25),oFontA10N,0100)
	oPrn:Say(0285,1240,transform(DA3->DA3_QTDUNI,"@E 9999"),oFontA12B,0100)
	oPrn:Say(0355,1240,SA4->A4_NOME,oFontA10N,0100)   //Chamado T.I -Fernando sigoli 05/07/2019 

	//========= bloco 4 =========
	DbselectArea("ZF3")
	ZF3->(DbsetOrder(1))
	ZF3->(Dbseek(xFilial("ZF3")+Alltrim(XZFC->ZFC_GRANJA)))
	
	DbSelectArea("SA2")
	SA2->(DbSetOrder(1))
	SA2->(DbSeek(xFilial("SA2")+ZF3->ZF3_FORCOD+ZF3->ZF3_FORLOJ,.F.))


	DbSelectArea("ZF1")
	ZF1->(DbSetOrder(1))
	ZF1->(DbSeek(xFilial("ZZ1")+XZFC->ZFC_EQUIPE,.F.))

	If	XZFC->ZFC_TIPVIA == "4"

		oPrn:Say(0270,1900,"TIPO: COMPL.RETORNO",oFontA12B,0100)

	Elseif	XZFC->ZFC_TIPVIA == "2"

		oPrn:Say(0270,1900,"TIPO: COMPL.VIAGEM",oFontA12B,0100)

	Elseif	XZFC->ZFC_TIPVIA == "3"

		oPrn:Say(0270,1900,"TIPO: RETORNO",oFontA12B,0100)

	Else

		oPrn:Say(0270,1900,"TIPO: VIAGEM",oFontA12B,0100)

	Endif

	oPrn:Say(0520,0080,"Integrado:"		 ,oFontA12B,0100)
	oPrn:Say(0660,0080,"Granja:"	 	 ,oFontA12B,0100)
	oPrn:Say(0520,1380,"Turma:"			 ,oFontA12B,0100)
	oPrn:Say(0590,0080,"Aves por gaiola:",oFontA12B,0100)
	oPrn:Say(0590,1600,"Total de aves:"	 ,oFontA12B,0100)
	oPrn:Say(0660,1600,"Linhagem:"	 	 ,oFontA12B,0100) //Everson, 30/06/2022, ticket 75561.
	oPrn:Say(0730,0080,"Municipio/UF:"	 ,oFontA12B,0100) //Chamado T.I -Fernando sigoli 05/07/2019 


	oPrn:Say(0590,0375,Transform(XZFC->ZFC_AVEGA,"@E 999,999"),oFontA10N,0100)
	oPrn:Say(0520,1580,XZFC->ZFC_EQUIPE+" - "+Posicione('ZF1', 1, xFilial('ZF1') + Alltrim(XZFC->ZFC_EQUIPE), 'ZF1_NOME'),oFontA12B,0100)

	oPrn:Say(0520,0300,SA2->A2_COD+" "+SA2->A2_LOJA+" - "+SA2->A2_NOME ,oFontA12B,0100)
	oPrn:Say(0590,1940,Transform(XZFC->ZFC_TOTAL,"@E 999,999"),oFontA10N,0100)
	oPrn:Say(0660,0300,XZFC->ZFC_GRANJA+" - "+Alltrim(Substr(SA2->A2_END,1,40)),oFontA12B,0100) //Chamado T.I -Fernando sigoli 24/06/2019
	oPrn:Say(0730,0375,Alltrim(SA2->A2_MUN)+" - "+Alltrim(SA2->A2_EST) + "    GALPAO: "+XZFC->ZFC_GALPAO +" LOTE: "+ XZFC->ZFC_NRLOTE,oFontA12B,0100) //Chamado T.I -Fernando sigoli 05/07/2019 

	oPrn:Say(0660,1940,cLinhagem,oFontA10N,0100) //Everson, 30/06/2022, ticket 75561.

	cPlaca	:=	XZFC->ZFC_VEICUL
																			
	//========= bloco 5 =========
	oPrn:Say(0795,0080,"KM na Saída:________________Hora:____:____",oFontA12B,0100)
	oPrn:Say(0795,1260,"KM no Retorno:_______________Hora:____:____",oFontA12B,0100)

	oPrn:Say(0890,0080,"INFORMAÇÕES MOTORISTA  ",oFontA12B,0100)
																oPrn:Say(0890,1260,"INFORMAÇÕES ABATEDOURO ",oFontA12B,0100)


	oPrn:Say(0980,0080,"Chegar no Local até as:",oFontA10N,0100)
																oPrn:Say(0980,1260,"Chegar no Abatedouro ás _____:_____Horas ",oFontA10N,0100)
	oPrn:Say(1090,0080,"Balança:"   		    ,oFontA10N,0100)
																oPrn:Say(1090,1260,"Pesou Tara:"   	,oFontA10N,0100)
	oPrn:Say(1200,0080,"Horário Granja:		  " ,oFontA10N,0100)
																oPrn:Say(1200,1260,"Pesou Bruto:" 	,oFontA10N,0100)

	oPrn:Say(1310,0080,"Horário Carregamento: " ,oFontA10N,0100)
																oPrn:Say(1310,1260,"Lacrado: " ,oFontA10N,0100)
																oPrn:Say(1410,1260,"Ordem Chegada Abate:________",oFontA10N,0100)

	//
	oPrn:Say(0980,0500,XZFC->ZFC_HRAPRE,oFontA14B,0100)
	oPrn:Say(1090,0500,"Chegada ___:___ Saída ___:___ ",oFontA10N,0100)
																oPrn:Say(1090,1460,"[  ] Sem Chuva [  ] Com Chuva",oFontA10N,0100)

	oPrn:Say(1200,0500,"Chegada ___:___ Saída ___:___ ",oFontA10N,0100) 
																oPrn:Say(1200,1460,"[  ] Sem Chuva [  ] Com Chuva",oFontA10N,0100) 

	oPrn:Say(1310,0500,"Inicio  ___:___  Fim  ___:___ ",oFontA10N,0100)
																oPrn:Say(1310,1460,"[  ] Sim       [  ] Não ",oFontA10N,0100)
																				
	//========= bloco 6 =========
	nLin	:=	1330

	// TICKET: 62797 - ADRIANO SAVOINE - 26/10/2021 - INICIO

	oPrn:Say(nLin+0080,0080,"ITENS PARA VERIFICAÇÃO:",oFontA12B,0100)
																oPrn:Say(nLin+0200,1460,"__________________________",oFontA10B,0100)
																oPrn:Say(nLin+0245,1460," ASS. RESPOSÁVEL PORTARIA ",oFontA10B,0100)
																oPrn:Say(nLin+0370,1260,"INFORMAÇÕES VIAGEM ",oFontA12B,0100)

	oPrn:Say(nLin+0180,0080,"Todas as gaiolas estão com as tampas fechadas?",oFontA10N,0100)
	oPrn:Say(nLin+0225,0080,"[   ] SIM",oFontA10N,0100)
	oPrn:Say(nLin+0225,0250,"[   ] NÃO",oFontA10N,0100)

	oPrn:Say(nLin+0280,0080,"Existe Gaiolas Quebradas no Veiculo?",oFontA10N,0100)
	oPrn:Say(nLin+0320,0080,"[   ] SIM se sim qty: [    ]",oFontA10N,0100)
	oPrn:Say(nLin+0320,0555,"[   ] NÃO",oFontA10N,0100)    
	oPrn:Say(nLin+0380,0080,"Existe Aves com Partes do Corpo (asas ou cabeça) para fora da gaiola?",oFontA10N,0100)      
																oPrn:Say(nLin+0490,1260,"Tempo Percurso:_____:_____Horas",oFontA10N,0100)      

	oPrn:Say(nLin+0450,0080,"[   ] SIM",oFontA10N,0100)  	
																oPrn:Say(nLin+0590,1260,"Na Ida:",oFontA10N,0100)
																oPrn:Say(nLin+0690,1260,"Na volta:",oFontA10N,0100)
																oPrn:Say(nLin+0790,1260,"Utilização Chuverão:",oFontA10B,0100)
																oPrn:Say(nLin+0890,1260,"Temperatura Ambiente:______cº",oFontA10N,0100)
																oPrn:Say(nLin+0990,1260,"Molhou o Frango:",oFontA10N,0100)
																
																oPrn:Say(nLin+0590,1460,"[  ] Sem Chuva   [  ] Com Chuva",oFontA10N,0100)
																oPrn:Say(nLin+0690,1460,"[  ] Sem Chuva   [  ] Com Chuva",oFontA10N,0100)
																oPrn:Say(nLin+0990,1540,"[  ] Sim 		   [  ] Não",oFontA10N,0100)
																															

	oPrn:Say(nLin+0450,0250,"[   ] NÃO",oFontA10N,0100) 
	oPrn:Say(nLin+0530,0080,"Checar toda a carga envolta do Veiculo para Garantir que nenhuma ave,",oFontA10N,0100)
	oPrn:Say(nLin+0590,0080,"esteja presa entre as gaiolas.",oFontA10N,0100)
	oPrn:Say(nLin+0590,0580,"[   ] SIM",oFontA10N,0100)
	oPrn:Say(nLin+0590,0750,"[   ] NÃO",oFontA10N,0100)

	// TICKET: 62797 - ADRIANO SAVOINE - 26/10/2021 - FIM

	oPrn:Say(nLin+0690,0080,"INFORMAÇÕES APANHA",oFontA12B,0100)
	oPrn:Say(nLin+0790,0080,"Apanha",oFontA10N,0100)
	oPrn:Say(nLin+0790,0500,"[   ] SIM",oFontA10N,0100)
	oPrn:Say(nLin+0790,0750,"[   ] NAO",oFontA10N,0100)

	oPrn:Say(nLin+0890,0080,"Molhou Frango",oFontA10N,0100)
	oPrn:Say(nLin+0890,0500,"[   ] SIM",oFontA10N,0100)
	oPrn:Say(nLin+0890,0750,"[   ] NAO",oFontA10N,0100)
					

	oPrn:Say(nLin+0990,0080,"Galpão",oFontA10B,0100)
	oPrn:Say(nLin+0990,0500,"Gaiolas",oFontA10B,0100)
	oPrn:Say(nLin+0990,0750,"Aves p/Gaiolas",oFontA10B,0100)
					
	oPrn:Say(nLin+1090,0080,"-----------------------------",oFontA10N,0100)
	oPrn:Say(nLin+1090,0500,"--------------------",oFontA10N,0100)
	oPrn:Say(nLin+1090,0750,"--------------------",oFontA10N,0100)
							
	oPrn:Say(nLin+1190,0080,"------------------------------",oFontA10N,0100)
	oPrn:Say(nLin+1190,0500,"--------------------",oFontA10N,0100)
	oPrn:Say(nLin+1190,0750,"--------------------",oFontA10N,0100)
	

	oPrn:Say(nLin+1290,0080,"Equipe___________________________",oFontA10N,0100)
	//oPrn:Say(nLin+1290,0750,"Equipe____________",oFontA10N,0100)
	oPrn:Say(nLin+1390,0080,"Frango Carregados________________________________",oFontA10N,0100)

	oPrn:Say(nLin+1485,0080,"___________________________________",oFontA10B,0100)
	oPrn:Say(nLin+1525,0080,"ASS. ENCARREGADO DO CARREGAMENTO"   ,oFontA10B,0100)

	oPrn:Say(nLin+1380,1360,"___________________________________",oFontA12B,0100)
	oPrn:Say(nLin+1420,1360,SUBSTR(DA4->DA4_NOME,1,25)			 ,oFontA10B,0100)
	oPrn:Say(nLin+1480,1360,"RG: "+DA4->DA4_RG			         ,oFontA10N,0100)

	//========= bloco 7 ========= 
	nLin	:=	2250
	oPrn:Box(nLin+0660,0030,3400,2360) 		//150 x 2330

	nLin	:=	2900 
	oPrn:Say(nLin+0025,0080,"OBSERVAÇÕES ",oFontA14B,0100)

	nLin+=100

	oPrn:Say(nLin,0075,"Lacres:",oFontA10B,0100)
	oPrn:Say(nLin,0200,XZFC->ZFC_LACRES,oFontA10B,0100)
	nLin+=050
	nLin+=075         
						
	nLines:=MlCount(XZFC->ZFC_OBSERV,60)

	For L:=1 To NLINES
		oPrn:Say(nLin,0055,MEMOLINE(XZFC->ZFC_OBSERV,60,L),oFontA14BBB,0100)    
		nLin+=050
	Next

Return
/*/{Protheus.doc} User Function ADLFV9E
	Faz o Fechamento das Ordens de Carregamento e integração nos sistemas EDATA e SAGs .
	@type Function
	@author Fernando Sigoli
	@since 18/04/17
	@version 01
	/*/ 
User Function ADLFV9E(cRotina,dData)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.                                            |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local lCanClose	:= .F.
	Local lCheca    := .T.

	Private cPerg	:= "ADLFV9E"
	Private dDatI	:= CTOD("//")
	Private dDatF	:= CTOD("//")

	U_ADINF009P('ADLFV009P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Programação de Retirada/Apanha de Aves.')

		
	//ValidPerg1()

		If cRotina <> "F" 
		
			If !Pergunte(cPerg,.T.)
				Return
			Endif
		
			dDatI := MV_PAR01
			dDatF := MV_PAR02
			
		Else

			dDatI := dData
			dDatF := dData
				
		EndIf

		DbSelectarea("ZFB")
		DbGotop()
		
		If cRotina <> "F" 
		
			If ApMsgYesNo("Deseja efetuar o fechamento das ordens de carregamento?","Fechamento de Ordens de Carregamento")
				lCanClose:=.T.
			Else
				lCanClose:=.F.
			EndIf
			
		Else
			lCanClose:=.T.
		
		EndIf	
		
		If lCanClose
			DbSelectArea("ZFB")
			DbsetOrder(1)
			If DbSeek(xFilial("ZFB")+dtos(dDatI),.T.)
				While !eof() .and. (dDatI	>=ZFB->ZFB_ABTPRE  .AND. dDatF	<=ZFB->ZFB_ABTPRE)
					lCheca	:=	.T.
					DbSelectArea("ZFC")
					DbSetOrder(1)
					If DbSeek(xFilial("ZFC")+ZFB->ZFB_CODIGO+ZFB->ZFB_LOJA+ZFB->ZFB_GRACOD+ZFB->ZFB_GALPAO+DTOS(ZFB->ZFB_ABTPRE),.T.)
						While !Eof() .and. ZFB->ZFB_CODIGO == ZFC->ZFC_CODIGO .and. ZFB->ZFB_GRACOD == ZFC->ZFC_GRANJA;
						.and. ZFB->ZFB_GALPAO == ZFC->ZFC_GALPAO .and. ZFB->ZFB_ABTPRE == ZFC->ZFC_DTAPRE
						
						If ZFC->ZFC_STATUS <> "3"
								
								If ZFC->ZFC_STATUS == "1" .and. !Empty(ZFC_LACRES)
									RecLock("ZFC",.F.)
									Replace ZFC_STATUS	With "2"
									MSUNLOCK()                              
									lCheca	:=	.T.
								Else
								
									If Empty(ZFC_LACRES)
										MsgAlert("Lacres não Associados a Ordem de carregamento")
										Return
										lCheca	:=	.F.
									Else
										lCheca	:=	.T.
									EndIf
								
								Endif
								DbSelectArea("ZFC")
							
							EndIf
							
						DbSkip()
						Enddo
					Else
						lCheca	:=	.F.
					Endif                       
					If lCheca
						DbSelectArea("ZFB")
						RecLock("ZFB",.F.)
						Replace ZFB->ZFB_STATUS		With	"4"
						MSUNLOCK()
					Endif

					DbSelectArea("ZFB")
					DbSkip()
				End
			Endif 
		Endif
	
Return      
/*/{Protheus.doc} User Function VALLACRE
	Faz a validacao de lacres.
	@type Function
	@author Fernando Sigoli
	@since 18/04/17
	@version 01
	/*/ 
User Function VALLACRE()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.                                            |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local cLacrest	:= " "  
	Local h 		:= 1

	U_ADINF009P('ADLFV009P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Programação de Retirada/Apanha de Aves.')                       

	If OpcSelec=="F" .And. !Empty(Alltrim(cValToChar(aCols[n,nPosNume])))  
    	MsgStop("Alteração não permitida! Verificar.")
    	Return(.F.)
	EndIf 
	//
	//verifico se ja foi utilizado para entrada de veiculos e nao deixamos alterar 
    If !Empty(Alltrim(cValToChar(aCols[n,nPosNume])))
	    DbselectArea("ZV1")
	    DbSetOrder(3)
		DbGoTop()			
		If dbseek(xFilial("ZV1")+Alltrim(cValToChar(aCols[n,nPosNume])))//numero da ordem de carregamento
			If !Empty(ZV1->ZV1_GUIAPE)
				MsgStop("Alteração nao permitida,devido a ordem ja utilizada para pesagens de entrada de aves vivas. Ticket: "+ZV1->ZV1_GUIAPE) 
				Return(.F.)
        	EndIF				
	    EndIF
	EndIf
	    
	//cTexto:= U_TAKECHAR(M->ZFC_LACRES)//Remover caracteres especiais
	cTexto:= U_xTAKECHAR(M->ZFC_LACRES)//Remover caracteres especiais // Chamado 050729 - FWNM - 15/07/2020 - || OS 052035 || TECNOLOGIA || LUIZ || 8451 || REDUCAO DE BASE - Tratativa na função U_TAKECHAR que é utilizada também no X3_VLDUSER mas retorna string, dando error log
	
	If Alltrim(M->ZFC_LACRES)=="NAO INFORMADO" .OR. ALLTRIM(M->ZFC_LACRES)=="NAOINFORMADO" .OR. ALLTRIM(M->ZFC_LACRES)=="NAO_INFORMADO" .OR. ("INFORMADO" $ ALLTRIM(M->ZFC_LACRES))
		aCols[n][nPoslacr]:=SPACE(LEN(M->ZFC_LACRES))
		Return(.T.)
	EndIf

	If !Empty(M->ZFC_LACRES)
	
		For h:=1 to Len(cTexto) step 10 
			If !Empty(cTexto)
				cLacresT+=Left(cTexto,10) 
				If Len(cTexto)>10
					cTexto:=Right(cTexto,Len(cTexto)-10)
				EndIf
			EndIf		
		Next   
		
		cLacresT:=Left(cLacresT,Len(cLacresT)-1)
		aCols[n][nPoslacr]:=LEFT(cLacresT+SPACE(LEN(M->ZFC_LACRES)),LEN(M->ZFC_LACRES))
	
	EndIf

Return(.T.)
/*/{Protheus.doc} User Function ADLFV9F
	Legenda.
	@type Function
	@author Fernando Sigoli
	@since 18/04/17
	@version 01
	/*/ 
User Function ADLFV9F()         
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.                                            |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	cCadastro 	:= "Programacao de retirada de aves"

	U_ADINF009P('ADLFV009P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Programação de Retirada/Apanha de Aves.')
	
	aCores2 	:= {{'BR_VERDE'	  , "Esperando montar a coleta"},;
					{'BR_AMARELO' , "Coleta parcialmente montada"},;
					{'BR_VERMELHO', "Coleta montada completa" },;
					{'BR_PRETO'	  , "Coleta fechada"}}

	BrwLegenda(cCadastro,"Legenda do Browse",aCores2)

Return
/*/{Protheus.doc} Static Function ValidPerg
	Monta o grupo de pergunta - ADLFV9.
	@type Function
	@author Fernando Sigoli
	@since 18/04/17
	@version 01
	/*/ 
Static Function ValidPerg
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.                                            |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	Local _sAlias := Alias()
	Local aRegs := {}
	Local i,j
	
	dbSelectArea("SX1")
	dbSetOrder(1)
	aAdd(aRegs,{cPerg,"01","Data Abate De ?"	,"","","mv_ch1","D",08 ,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"02","Data Abate Ate	?"	,"","","mv_ch2","D",08 ,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"03","Aves por gaiola ?"	,"","","mv_ch3","N",02 ,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","",""})
	
	For i:=1 to Len(aRegs)
		If !dbSeek(cPerg+aRegs[i,2])
			RecLock("SX1",.T.)
			For j:=1 to FCount()
				If j <= Len(aRegs[i])
					FieldPut(j,aRegs[i,j])
				Endif
			Next
			MsUnlock()
		Endif
	Next
	dbSelectArea(_sAlias)
Return
/*/{Protheus.doc} Static Function ValidPerg1
	Monta o grupo de pergunta - ADLFV9E.
	@type Function
	@author Fernando Sigoli
	@since 18/04/17
	@version 01
	/*/ 
Static Function ValidPerg1
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.                                            |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	Local _sAlias := Alias()
	Local aRegs   := {}
	Local i,j
		
	dbSelectArea("SX1")
	dbSetOrder(1)
	aAdd(aRegs,{cPerg,"01","Dt Carregamento De ?","","","mv_ch1","D",08 ,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"02","Dt Carregamento Ate?","","","mv_ch2","D",08 ,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	For i:=1 to Len(aRegs)
		If !dbSeek(cPerg+aRegs[i,2])
			RecLock("SX1",.T.)
			For j:=1 to FCount()
				If j <= Len(aRegs[i])
					FieldPut(j,aRegs[i,j])
				Endif
			Next
			MsUnlock()
		Endif
	Next
	dbSelectArea(_sAlias)

	Return

	//-----------========= Monta o grupo de pergunta =========-----------|
	Static Function MontaPerg()                                  

	Private bValid	:=Nil 
	Private cF3		:=Nil
	Private cSXG	:=Nil
	Private cPyme	:=Nil

	PutSx1(cPerg,'01','Ordem De Carregamento De ?'	,'','','mv_ch1','C',6,0,0		,'G',bValid,cF3,cSXG,cPyme,'MV_PAR01') 
	PutSx1(cPerg,'02','Ordem De Carregamento Ate?'	,'','','mv_ch2','C',6,0,0		,'G',bValid,cF3,cSXG,cPyme,'MV_PAR02') 

	Pergunte(cPerg,.F.)

Return

/*/{Protheus.doc} User Function TAKECHAR
	Remove qualquer tipo de caracter especial de acordo coma tabela ASCII.
	@type Function
	@author Fernando Sigoli
	@since 18/04/17
	@version 01
/*/ 
//User Function TAKECHAR(_cDesc) // Chamado 050729 - FWNM - 15/07/2020 - || OS 052035 || TECNOLOGIA || LUIZ || 8451 || REDUCAO DE BASE - Tratativa na função U_TAKECHAR que é utilizada também no X3_VLDUSER mas retorna string, dando error log
User Function xTAKECHAR(_cDesc)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.                                            |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local i := 1

	U_ADINF009P('ADLFV009P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Programação de Retirada/Apanha de Aves.')

	//Caracteres--> !''#$%&()*+,-.                          
	For i:=33 to 46 								   	     
		_cDesc:=StrTran(_cDesc,chr(i),"")                	
	Next                                                      
													                         		
	//Caracteres--> :;<=>?@			                          
	For i:=58 to 64                                            
		_cDesc:=StrTran(_cDesc,chr(i),"")                 	
	Next                                                      	
													                         					
	//Caracteres--> [\]^_`			                          			
	For i:=91 to 96                                           
		_cDesc:=StrTran(_cDesc,chr(i),"")                 		
	Next                                                      
												                         					
	//Caracteres--> {|}~ DEL		                          		
	For i:=123 to 127                                         
		_cDesc:=StrTran(_cDesc,chr(i),"")                 	
	Next                                                      

Return(TRIM(_cDesc))

/*/{Protheus.doc} User Function HORACAR
	Remove qualquer tipo de caracter especial de acordo coma tabela ASCII.
	@type Function
	@author Fernando Sigoli
	@since 18/04/17
	@version 01
	/*/ 
User Function HORACAR()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.                                            |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local cHrChegada := M->ZFC_HRAPRE 
	Local nPosHrch	 := aScan(aHeader,{|x| x[2]=="ZFC_HRCHEG"})

	U_ADINF009P('ADLFV009P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Programação de Retirada/Apanha de Aves.')  
			
	If !Empty(cHrChegada)  
	                      
		cHoraProx   := CVALTOCHAR(SomaHoras (cHrChegada,cTempo))
		cHoraProx   := IIF(LEN(cHoraProx) = 1, "0" + cHoraProx + '.' + '00', IIF(LEN(cHoraProx) = 2 .AND. At(".", cHoraProx) == 0,cHoraProx + '.' + '00',cHoraProx))
		cHoraProx   := IIF(At(".", cHoraProx) == 2, '0' + cHoraProx, cHoraProx)
		cHoraProx   := IIF(LEN(SUBSTR(cHoraProx, At(".", cHoraProx) + 1, LEN(cHoraProx))) == 1,  cHoraProx + '0', cHoraProx)
		cHoraProx   := STRTRAN(cHoraProx,'.',':')
	    
	    If cHoraProx > "23:59"
	         
	    	cHoraProx := CVALTOCHAR(SubHoras(cHoraProx, "24:00" ))
	    	cHoraProx := IIF(LEN(cHoraProx) = 1, "0" + cHoraProx + '.' + '00', IIF(LEN(cHoraProx) = 2 .AND. At(".", cHoraProx) == 0,cHoraProx + '.' + '00',cHoraProx))
			cHoraProx := IIF(At(".", cHoraProx) == 2, '0' + cHoraProx, cHoraProx)
			cHoraProx := IIF(LEN(SUBSTR(cHoraProx, At(".", cHoraProx) + 1, LEN(cHoraProx))) == 1,  cHoraProx + '0', cHoraProx)
			cHoraProx := STRTRAN(cHoraProx,'.',':')
	    
	    	
	    EndIf
		
		aCols[n,nPosHrch] := cHoraProx
	
	EndIf
	        
Return .T.
/*/{Protheus.doc} Static Function C
	Funcao responsavel por manter o Layout independente da
	resolucao horizontal do Monitor do Usuario.
	@type Function
	@author Norbert/Ernani/Mansano
	@since 10/05/2005
	@version 01
	/*/ 
Static Function C(nTam)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.                                            |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	Local nHRes	:=	oMainWnd:nClientWidth	// Resolucao horizontal do monitor

	If nHRes == 640	// Resolucao 640x480 (soh o Ocean e o Classic aceitam 640)
		nTam *= 0.8
	ElseIf (nHRes == 798).Or.(nHRes == 800)	// Resolucao 800x600
		nTam *= 1
	Else	// Resolucao 1024x768 e acima
		nTam *= 1.28
	EndIf

	&& Tratamento para tema "Flat"
	If "MP8" $ oApp:cVersion
		If (Alltrim(GetTheme()) == "FLAT") .Or. SetMdiChild()
			nTam *= 0.90
		EndIf
	EndIf    

Return Int(nTam)  
/*/{Protheus.doc} chkFrt
	Verifica status do lançamento de frete.
	@type  Static Function
	@author user
	@since 10/12/2019
	@version 01
   /*/      
Static Function chkFrt(cFilO,cCarga)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.                                            |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aArea  := GetArea()
	Local lRet  := .T.

	//
	If ! lVldNF
		RestArea(aArea)
		Return lRet

	EndIf
	
	//
	DbSelectArea("ZFA")
	ZFA->(DbSetOrder(17))
	If ZFA->( DbSeek( cFilO + "2" + cCarga ) ) //Buscar a carga nos registros de frete.
		lRet := .F.
		MsgStop("A ordem de carregamento " + cCarga + " já possui ocorrência de frete vinculada.","Função chkFrt(ADLFV009P)")
		
	EndIf

	//
	RestArea(aArea)

Return lRet
/*/{Protheus.doc} chkNF
	Valida o número de nota fiscal informado.
	@type  Static Function
	@author Everson
	@since 10/12/2019
	@version 01
	/*/
Static Function chkNF(cFilO, cNf, cSerie,cOc)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.                                            |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aArea := GetArea()
	Local lRet  := .T.
	Local cQuery:= ""
	Local cCNPJ	:= Alltrim(SM0->M0_CGC)

	//
	If ! lVldNF
		RestArea(aArea)
		Return lRet

	EndIf
	
	//
	DbSelectArea("SF2")
	SF2->(DbSetOrder(1))
	SF2->(DbGoTop())
	If ! SF2->( DbSeek(cFilO + cNf + Padr(cSerie,TamSX3("F2_SERIE")[1]," " ) ) )
		MsgStop("Nota fiscal " + cNf + "/" + Padr(cSerie,TamSX3("F2_SERIE")[1]," " ) + " não localizada na filial de origem.","Função chkNF(ADLFV009P")
		lRet := .F.

	Else

		//
		Conout( DToC(Date()) + " " + Time() + " ADLFV009P - chkNF - FWxFilial('SA1') + Alltrim(SF2->F2_CLIENTE) +  Alltrim(SF2->F2_LOJA) " + FWxFilial('SA1') + Alltrim(SF2->F2_CLIENTE) +  Alltrim(SF2->F2_LOJA) )

		//
		DbSelectArea("SA1")
		SA1->(DbSetOrder(1))
		SA1->(DbGoTop())
		If ! SA1->( DbSeek( FWxFilial("SA1") + Alltrim(SF2->F2_CLIENTE) +  Alltrim(SF2->F2_LOJA) ) )
			MsgStop("Cadastro de cliente não localizado na filial de origem.","Função chkNF(ADLFV009P")
			lRet := .F.

		EndIf

		//
		If lRet .And. cCNPJ <> Alltrim(SA1->A1_CGC)
			MsgStop("Nota fiscal " + cNf + "/" + Padr(cSerie,TamSX3("F2_SERIE")[1]," " ) + " não pertence à filial.","Função chkNF(ADLFV009P")
			lRet := .F.
			
		EndIf 

	EndIf

	//
	If lRet

		//
		cQuery := ""
		cQuery += " SELECT " 
		cQuery += " TOP 1 '1' AS CHK " 
		cQuery += " FROM " 
		cQuery += " " + RetSqlName("ZFC") + " (NOLOCK) AS ZFC " 
		cQuery += " WHERE " 
		cQuery += " ZFC_FILIAL = '" + FWxFilial("ZFC") + "' " 
		cQuery += " AND ZFC_NF = '" + cNf + "' " 
		cQuery += " AND ZFC_SERIE = '" + cSerie + "' AND ZFC_NUMERO <> '" + Alltrim(cValToChar(cOc)) + "' " //Everson - 11/12/2019 - chamado 029058.
		cQuery += " AND ZFC.D_E_L_E_T_ = '' " 

		//
		If Select("D_CHKNF") > 0
			D_CHKNF->(DbCloseArea())

		EndIf

		//
		TcQuery cQuery New Alias "D_CHKNF"
		DbSelectArea("D_CHKNF")
		D_CHKNF->(DbGoTop())
		If ! D_CHKNF->(Eof())
			lRet := .F.
			MsgStop("Nota fiscal " + cNf + "/" + Padr(cSerie,TamSX3("F2_SERIE")[1]," " ) + " já utilizada.","Função chkNF(ADLFV009P")

		EndIf 
		D_CHKNF->(DbCloseArea())

	EndIf

	//
	RestArea(aArea)

Return lRet
/*/{Protheus.doc} User Function 009VL2
	Validação da nota fiscal informada.
	@type  Function
	@author user
	@since 10/12/2019
	@version 01
	/*/
User Function 009VL2(cNF) // U_009VL2(M->ZFC_NF)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.                                            |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aArea 	:= GetArea()
	Local lRet  	:= .T.

	U_ADINF009P('ADLFV009P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Programação de Retirada/Apanha de Aves.')

	//
	If ! lVldNF
		RestArea(aArea)
		Return lRet

	EndIf

	//
	If ! Empty(Alltrim(cValToChar(cNF)))
		M->ZFC_NF := Padl(Alltrim(cValToChar(cNF)),TamSX3("F2_DOC")[1],"0")
	
	Else
		M->ZFC_NF := Space(TamSX3("F2_DOC")[1])

	EndIf

	//
	RestArea(aArea)

Return lRet

/*/{Protheus.doc} User Function TAKECHAR
	Remove qualquer tipo de caracter especial de acordo coma tabela ASCII. Utilizado no X3_VLDUSER do campo C5_MENNOTA
	@type Function
	@author FWNM
	@since 15/07/2020
	@version 01
	Chamado 050729 - FWNM - 15/07/2020 - || OS 052035 || TECNOLOGIA || LUIZ || 8451 || REDUCAO DE BASE - Tratativa na função U_TAKECHAR que é utilizada também no X3_VLDUSER mas retorna string, dando error log
/*/ 
User Function TAKECHAR(_cCmp, _cDesc) 

	Local lRet 	:= .t.
	Local i		:= 1

	Default _cCmp := ""
	Default _cDesc := ""

	U_ADINF009P('ADLFV009P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Programação de Retirada/Apanha de Aves.')

	If Empty(_cCmp) .or. Empty(_cDesc)
		Return lRet
	EndIf

	_cDesc := AllTrim(_cDesc)

	//Caracteres--> !''#$%&()*+,-.                          
	For i:=33 to 46 								   	     
		_cDesc:=StrTran(_cDesc,chr(i),"")                	
	Next                                                      
													                         		
	//Caracteres--> :;<=>?@			                          
	For i:=58 to 64                                            
		_cDesc:=StrTran(_cDesc,chr(i),"")                 	
	Next                                                      	
													                         					
	//Caracteres--> [\]^_`			                          			
	For i:=91 to 96                                           
		_cDesc:=StrTran(_cDesc,chr(i),"")                 		
	Next                                                      
												                         					
	//Caracteres--> {|}~ DEL		                          		
	For i:=123 to 127                                         
		_cDesc:=StrTran(_cDesc,chr(i),"")                 	
	Next

	// Preenche campo com string tratada
	If AllTrim(_cCmp) == "C5_MENNOTA"
		M->C5_MENNOTA := AllTrim(_cDesc)

	ElseIf AllTrim(_cCmp) == "C5_MENNOT2"
		M->C5_MENNOT2 := AllTrim(_cDesc)

	ElseIf AllTrim(_cCmp) == "C5_MENNOT3"
		M->C5_MENNOT3 := AllTrim(_cDesc)

	ElseIf AllTrim(_cCmp) == "C5_MENNOT4"
		M->C5_MENNOT4 := AllTrim(_cDesc)

	ElseIf AllTrim(_cCmp) == "C5_MENNOT5"
		M->C5_MENNOT5 := AllTrim(_cDesc)

	EndIf

Return lRet
