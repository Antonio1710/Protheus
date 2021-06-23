#INCLUDE "rwmake.ch"
#include "colors.ch"
#include "protheus.ch"        
#INCLUDE "TOPCONN.CH"

/*{Protheus.doc} User Function SF1100I
	Grava dados referente nota fiscal original na nota devolucao de vendas para ser utilizado na contabilizacao.
	@type  Function
	@author hcconsys
	@since 05/05/07
	@version 01
	@history Chamado 020821 - Heverson      - 31/08/2009 - Alteracao referente a mensagens na nota fiscal de entrada proprio e alteracao para nf de importacao de SC
	@history Chamado 058391 - William Costa - 29/05/2020 - Devido falha na gravação do campo F1_TPCTE atráves do ponto de entrada na PRÉ-NOTA DE ENTRADA, foi adicionado também o RECLOCK no DOCUMENTO DE ENTRADA para garantir o processo
*/	

User Function SF1100I()

	Local  _aArea   := GetArea()
	Local _aAreaSF1	:= SF1->(GetArea())
	Local _aAreaSD1	:= SD1->(GetArea())
	Local _aAreaSD2	:= SD2->(GetArea())
	Local _aAreaSE2	:= SE2->(GetArea())
	Local _aAreaSDE	:= SDE->(GetArea())
	Local _aAreaSED	:= SED->(GetArea())
	Local _cConta	:= ""
	Local _cCC		:= ""
	Local _ItemCC	:= ""
	Local _ClVl		:= ""
	Local _cCredit	:= ""
	Local _cEspNf   := ""
	Local _aAlias   := GetArea()
	Local cAlameda  := ""
	Local cCodSAG	:= "" //Everson - 28/11/2018. 045465
	Private _cMensA		:= ""
	Private _cMensB		:= ""
	Private _nPesol		:= 0
	Private _nPesob		:= 0
	Private _cEspecie   := ""
	Private _nqtdvol 	:= 0
	Private bGrava     	:= { || gravaDados() }
	Private _nPDescR  	:= 0	//por Adriana em 24/05/17 chamado 035167
	Private _cUser		:= ""	//por Adriana em 24/05/17 chamado 035167

	//Salvando ambiente antes do gatilho                                  
	
	IF SF1->F1_TIPO == "D"

		dbSelectArea("SD1")
		dbSetOrder(1)
		dbSeek(xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA,.T.)	

		WHILE !Eof() .And. 	SD1->D1_DOC + SD1->D1_SERIE + SD1->D1_FORNECE + SD1->D1_LOJA == ;
			SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA

			dbSelectArea("SD2")
			dbSetOrder(3)//D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM		

			IF dbSeek(xFilial("SD2")+SD1->(D1_NFORI + D1_SERIORI + D1_FORNECE + D1_LOJA + D1_COD + D1_ITEMORI),.T.)			

				Reclock("SD1",.F.)
				SD1->D1_ITEMCTA 	:= SD2->D2_ITEMCC
				SD1->D1_CLVL		:= SD2->D2_CLVL			
				MsUnlock("SD1")			
				dbSelectArea("SD1")
				dbSkip()

			ENDIF
		ENDDO
	ELSE

		// GRAVAR DADOS NO SE2	
		dbSelectArea("SD1")
		dbSetOrder(1)
		dbSeek(xFilial("SD1") + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA,.T.)	

		IF SD1->D1_RATEIO <> "1"
			_cConta		:= SD1->D1_CONTA
			_cCC		:= SD1->D1_CC
			_cItemCta	:= SD1->D1_ITEMCTA
			_cClVl		:= SD1->D1_CLVL		

		ELSE

			//LER ARQUIVO DE RATEIO		
			dbSelectArea("SDE")
			dbSetOrder(1)
			dbSeek(xFilial("SDE") + SD1->D1_DOC + SD1->D1_SERIE + SD1->D1_FORNECE + SD1->D1_LOJA + SD1->D1_ITEM,.T.)		
			_cConta		:= SDE->DE_CONTA
			_cCC		:= SDE->DE_CC
			_cItemCta	:= SDE->DE_ITEMCTA
			_cClVl		:= SDE->DE_CLVL		

		ENDIF	                                        
		
		IF cempant = "01"    //por Adriana em 24/05/17 chamado 035167    

			_nPDescR  	:= Posicione("SC7",1,xFilial("SC7")+SD1->D1_PEDIDO,"C7_XPDESCR")    
			_cUser  	:= Posicione("SC7",1,xFilial("SC7")+SD1->D1_PEDIDO,"C7_USER")		 
			dbSelectArea("SF1")
			RecLock("SF1",.F.)			
			SF1->F1_XPDESCR	:= _nPDescR
			MsUnlock("SF1")						

		ENDIF               //fim - chamado 035167
			
		dbSelectArea("SE2")            //Contas a Pagar
		dbSetOrder(6)                 ////E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO	

		IF dbSeek(Xfilial("SE2")+SF1->F1_FORNECE + SF1->F1_LOJA + SF1->F1_SERIE + SF1->F1_DOC,.T. )

			//Mauricio - Chamado 036044 - aplica o desconto apenas na primeira parcela.
			_nContPar := 1		

			DO WHILE .not. eof() .and. SF1->(F1_FORNECE + F1_LOJA + F1_SERIE + F1_DOC) == SE2->(E2_FORNECE + E2_LOJA + E2_PREFIXO + E2_NUM )			

				// LER ARQUIVO DE NATUREZA PARA ATUALIZAR CONTA A CREDITO ALTERACAO FEITA EM 17/05/07 PELA HCCONSYS(HEVERSON)						
				dbSelectArea("SED")
				dbSetOrder(1)

				IF dbSeek(xFilial("SED")+SE2->E2_NATUREZ)

					_cCredit := SED->ED_CONTA

				ENDIF
				// FIM DA ALTERACAO						

				dbSelectArea("SE2")
				RecLock("SE2",.F.)			
					SE2->E2_DEBITO	:= _cConta
					SE2->E2_ITEMD 	:= _cItemCta
					SE2->E2_ITEMC 	:= _cItemCta
					SE2->E2_CREDIT	:= _cCredit	
					SE2->E2_LOGDTHR	:= IIF(EMPTY(SE2->E2_LOGDTHR),DTOC(DATE()) + ' ' + TIME(),SE2->E2_LOGDTHR) //chamado 040723 WILLIAM COSTA 03/04/2018

					IF _nPDescR > 0 .And. _nContPar == 1		 //por Adriana em 24/05/17 chamado 035167 //Mauricio - Chamado 036044 - aplica o desconto apenas na primeira parcela.

						SE2->E2_DECRESC		:= Round(SF1->F1_VALMERC*(_nPDescR/100),0)
						SE2->E2_SDDECRESC	:= Round(SF1->F1_VALMERC*(_nPDescR/100),0)			
						SE2->E2_HIST   		:= "Decresc.Prod.Rural"
						_nContPar ++

					ENDIF                //fim - chamado 035167

				MsUnlock("SE2")						
				dbSkip()			
			ENDDO		
		ENDIF	
	ENDIF
	// Condicao Acrescentada para trara NF Importacao da Adoro em 05/12/08
	// Inicio

	IF Alltrim(FunName()) == "ADRANFIMP"	

		dbselectarea("SD1")
		dbsetorder(1)	
		SD1->(dbseek(xFilial("SD1") + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA,.t. ))	
		DbSelectArea("ZZB")
		DbSetOrder(2)

		IF DbSeek(xfilial("ZZB")+SD1->D1_DOC+SD1->D1_ITEM)		

			_nD1Total    := 0
			_nD1ValIpi   := 0
			_nD1ValIcm   := 0
			_nD1BasIcm   := 0
			_nD1BasIpi   := 0
			_nD1Bas6	 := 0
			_nD1imp6	 := 0
			_nD1Bas5	 := 0
			_nD1imp5 	 := 0
			_nD1Valii	 := 0
			_nD1ValCont	 := 0
			_nD1Despesa  := 0
			nValFrete	 := 0
			nValDesp	 := 0
			nValSeguro	 := 0		

			WHILE SD1->(!Eof()) .AND. 	SD1->D1_DOC == SF1->F1_DOC .AND. SD1->D1_SERIE == SF1->F1_SERIE .AND. ;
				SD1->D1_FORNECE == SF1->F1_FORNECE .AND. SD1->D1_LOJA == SF1->F1_LOJA			

				DbSelectArea("ZZB")
				DbSetOrder(2)

				IF DbSeek(xfilial("ZZB")+SD1->D1_DOC+SD1->D1_ITEM)				

					DbSelectArea("SF4")
					DbSetOrder(1)
					DbSeek(xfilial("SF4")+SD1->D1_TES )				
					DbSelectArea("SD1")
					RecLock("SD1",.F.)				
					SD1->D1_VUNIT	:= ZZB->ZZB_VUNIT
					SD1->D1_TOTAL	:= ZZB->ZZB_TOTAL
					SD1->D1_CUSTO	:= ZZB->ZZB_BASEIC //CHAMADO 025285 WILLIAM COSTA //ZZB->ZZB_VUNIT+ZZB->ZZB_II+ZZB->ZZB_DESPES
					SD1->D1_DESPESA := ZZB->ZZB_DESPES
					SD1->D1_PICM	:= ZZB->ZZB_PICM
					SD1->D1_IPI		:= ZZB->ZZB_IPI
					SD1->D1_BASEICM	:= ZZB->ZZB_BASEIC
					SD1->D1_VALICM	:= ZZB->ZZB_VALICM
					SD1->D1_BASEIPI	:= Iif(ZZB->ZZB_VALIPI==0,0,ZZB->ZZB_BASEIP)
					SD1->D1_VALIPI	:= ZZB->ZZB_VALIPI
					SD1->D1_ALQIMP6	:= ZZB->ZZB_ALIMP5 	// pis
					SD1->D1_BASIMP6	:= ZZB->ZZB_BSIMP5
					SD1->D1_VALIMP6	:= ZZB->ZZB_VLIMP5
					SD1->D1_II		:= ZZB->ZZB_II
					SD1->D1_BASIMP5	:= ZZB->ZZB_BSIMP6 	//  cofins
					SD1->D1_VALIMP5	:= ZZB->ZZB_VLIMP6
					SD1->D1_ALQIMP5	:= ZZB->ZZB_ALIMP6
					SD1->D1_SEGURO	:= ZZB->ZZB_SEGURO
					SD1->D1_VALFRE	:= ZZB->ZZB_FRETE
					//SD1->D1_PEDIDO 	:= SZD->ZD_PEDIDO
					//SD1->D1_ITEMPC  := SZD->ZD_ITEMPC
					//SD1->D1_QTDPEDI := SZD->ZD_QUANT				
					Msunlock("SD1")				
					nValFrete	 += ZZB->ZZB_FRETE
					nValDesp	 += ZZB->ZZB_DESPES
					nValSeguro	 += ZZB->ZZB_SEGURO				
					_nD1Total    := _nD1Total 	+ SD1->D1_total
					_nD1ValIpi   := _nD1ValIpi 	+ SD1->D1_valipi
					_nD1ValIcm   := _nD1ValIcm 	+ SD1->D1_valicm
					_nD1BasIcm   := _nD1BasIcm 	+ SD1->D1_baseicm
					_nD1BasIpi   := _nD1BasIpi 	+ SD1->D1_baseipi
					_nD1bas6	 := _ND1bas6		+ SD1->D1_BASIMP6 //PIS
					_nD1imp6	 :=	_nD1imp6 	+ SD1->D1_VALIMP6
					_nD1bas5	 :=	_nD1bas5 	+ SD1->D1_BASIMP5 //COFINS
					_nD1imp5	 := _nD1imp5 	+ SD1->D1_VALIMP5
					_nD1ValII	 := _nD1ValII 	+ SD1->D1_II
					_nd1Despesa	 := _nD1Despesa + SD1->D1_DESPESA				
					//				If 	SF4->F4_DESPICM == "1"
					_nD1ValCont  := _nD1BasICM
					//				Else
					//					_nD1ValCont    := _nD1Total   + _nd1Despesa
					//				Endif

				ENDIF			

				SD1->(dbSkip())			

			ENDDO		

	//		if cfilant $ "02/03"
				_cEspNf := "SPED"
	//		else
	//			_cEspNf := "NF"
	//		endif		

			dbSelectArea("SF1")
			Reclock("SF1",.f.)		
			SF1->F1_BASEICM				:= _nD1BasIcm
			SF1->F1_VALICM 				:= _nD1ValIcm
			SF1->F1_BASEIPI				:= _nD1BasIPI
			SF1->F1_VALIPI 			  	:= _nD1ValIPI
			SF1->F1_VALMERC				:= _nD1Total
			SF1->F1_VALBRUT 			:= _nD1ValCont
			SF1->F1_II					:= _nD1ValII
			SF1->F1_BASIMP5				:= _nD1bas6				// COFINS
			SF1->F1_BASIMP6				:= _nD1bas5 			// PIS
			SF1->F1_VALIMP5				:= _nD1imp6 			// VALOR pis
			SF1->F1_VALIMP6				:= _nD1imp5 			// VALOR cofins
			SF1->F1_VALBRUT				:= _nD1BasIcm
			//SF1->F1_ORIGEM			:= "ADRANFIMP"
			SF1->F1_FRETE				:= nValFrete
			SF1->F1_DESPESA				:= nValDesp
			SF1->F1_SEGURO				:= nValSeguro
			SF1->F1_ESPECIE				:= _cEspNf		
			MsUnlock("SF1")		

			/// regravar se2 baseado na nota fiscal de entrada HCCONSYS 25/03/09		
			dbSelectArea("SE2")            //Contas a Pagar
			dbSetOrder(6)                 ////E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO		

			IF dbSeek(Xfilial("SE2")+SF1->F1_FORNECE + SF1->F1_LOJA + SF1->F1_SERIE + SF1->F1_DOC,.T. )						

				DO WHILE .not. eof() .and. SF1->(F1_FORNECE + F1_LOJA + F1_SERIE + F1_DOC) == SE2->(E2_FORNECE + E2_LOJA + E2_PREFIXO + E2_NUM )								

					dbSelectArea("SE2")				
					RecLock("SE2",.F.)				
					SE2->E2_VALOR		:= _nD1ValCont
					SE2->E2_SALDO		:= _nD1ValCont
					SE2->E2_VLCRUZ		:= _nD1ValCont				
					MsUnlock("SE2")								
					dbSkip()	

				ENDDO			
			ENDIF				
		ENDIF	
	ENDIF
	
	//TELA DE DIGITACAO DE MENSAGENS NA NOTA REFERENTE A NOTA DE ENTRADA FORMULARIO PROPRIO = SIM
	// MENSAGEM,PESOL,PESOB,TRANSP                                										       ³
	
	//Declaração de Variaveis Private dos Objetos                             
	SetPrvt("oDlg1","oGrp1","oSay1","oSay2","oSay3","oSay4","oSay5","oGet1","oGet2","oGet3","oGet4","oGet5")
	SetPrvt("oSBtn1")

	//Everson - 28/11/2018. 045465
	cCodSAG := ""
	IF cEmpAnt = "01"

		cCodSAG := Alltrim(cValToChar(SF1->F1_NOTASAG))

	ENDIF
	
	IF SF1->F1_FORMUL == "S" .AND. GetRemoteType() <> -01 .And. Empty(cCodSAG)//Execucao por JOB	//Everson - 09/11/2018.

		_cMensA		:= SF1->F1_MENNOTA
		_cMensB		:= SF1->F1_MENNOTB

		IF cempant <> "02"       //incluido para atender nota de devolucao

			_nPesol		:= SF1->F1_PLIQUI
			_nPesob		:= SF1->F1_PBRUTO
			_cEspecie   := SF1->F1_ESPECI1
			_nqtdvol 	:= SF1->F1_VOLUME1

		ELSE //incluido para atender nota de devolucao
			_nPesol   := 0//incluido para atender nota de devolucao
			_nPesob	 := 0//incluido para atender nota de devoluca
			_cEspecie := 0//incluido para atender nota de devoluca
			_nqtdvol  := 0//incluido para atender nota de devoluca

		ENDIF

		//	oDlg1      := MSDialog():New( 150,401,413,697,"Dados Nota de Entrada Adoro",,,.F.,,,,,,.T.,,,.T. )
		oDlg1      := MSDialog():New( 30,1400,350,2200,"Dados Nota de Entrada Adoro",,,.F.,,,,,,.T.,,,.T. )
		//	oGrp1      := TGroup():New( 004,004,108,136," Dados Complementares ",oDlg1,CLR_BLACK,CLR_WHITE,.T.,.F. )
		oGrp1      := TGroup():New( 004,004,160,400," Dados Complementares ",oDlg1,CLR_BLACK,CLR_WHITE,.T.,.F. )	
		//	oSay1      := TSay():New( 020,012,{||"Qtd Volumes  "},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLUE,CLR_WHITE,040,008)
		oSay2      := TSay():New( 020,012,{||"Mensagem 1 "},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLUE,CLR_WHITE,036,008)
		oSay3      := TSay():New( 036,012,{||"Mensagem 2 "},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLUE,CLR_WHITE,036,008)
		oSay4      := TSay():New( 050,012,{||"Peso Líquido"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLUE,CLR_WHITE,036,008)
		oSay5      := TSay():New( 066,012,{||"Peso Bruto "},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLUE,CLR_WHITE,036,008)
		oSay6      := TSay():New( 079,012,{||"Espécie "},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLUE,CLR_WHITE,036,008)
		oSay7      := TSay():New( 094,012,{||"Qtd Volumes"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLUE,CLR_WHITE,036,008)
		oGet1      := TGet():New( 018,051,{|u| If(PCount()>0,_cMensA:=u,_cMensA)},oGrp1,330,008,'@s70',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","_cMensA",,)
		oGet3      := TGet():New( 034,051,{|u| If(PCount()>0,_cMensB:=u,_cMensB)},oGrp1,330,008,'@s70',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","_cMensB",,)
		//	oGet4      := TGet():New( 034,110,{|u| If(PCount()>0,cUF:=u,cUF)},oGrp1,014,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","cUF",,)
		oGet5      := TGet():New( 048,051,{|u| If(PCount()>0,_nPesol:=u,_nPesol)},oGrp1,045,008,'999,999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","_nPesol",,)
		oGet6      := TGet():New( 063,051,{|u| If(PCount()>0,_nPesob:=u,_nPesob)},oGrp1,045,008,'999,999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","_nPesob",,)
		oGet2      := TGet():New( 077,051,{|u| If(PCount()>0,_cEspecie:=u,_cEspecie)},oGrp1,045,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","_cEspecie",,)
		oGet7      := TGet():New( 092,051,{|u| If(PCount()>0,_nqtdvol:=u,_nqtdvol)},oGrp1,045,008,'99999.9999',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","_nqtdvol",,)
		oSBtn1     := SButton():New( 112,108,1,{ || nOpcA := 1 , Eval( bGrava ) },oDlg1,,"", )
		oDlg1:Activate(,,,.T.)	

	ENDIF

	IF Alltrim(cValToChar(CESPECIE)) == "CTE" .AND. ALLTRIM(SF1->F1_TPCTE) = ''

		RecLock("SF1",.F.)

			SF1->F1_TPCTE := "N - Normal"
			
		MsUnLock()

	ENDIF

	RestArea(_aArea)
	RestArea(_aAreaSF1)
	RestArea(_aAreaSD1)
	RestArea(_aAreaSD2)
	RestArea(_aAreaSE2)
	RestArea(_aAreaSDE)
	RestArea(_aAreaSED)

	//-------------------------------------------------------------------------------------------------------------
	// ROTINA INSERIDA PARA GERAÇÃO DO TITULOS DE PCC DOS FORNECEDORES CADASTRADOS NO PARAMETRO MV_XFORPCC
	//-------------------------------------------------------------------------------------------------------------
	IF cEmpAnt == "01" .and. cFormul == "N" .And. SF1->F1_TIPO=="N" .And. Alltrim(SF1->(F1_FORNECE+F1_LOJA)) $GetMv("MV_XFORPCC") // Verifica se a nota é tipo normal e o fornecedor da nota está contido no parâmetro

		_wArea       := GetArea()
		_wAreaSF1    := SF1->(GetArea())
		_wAreaSE2    := SE2->(GetArea())
		_wGeraPcc    := 0
		_wParcela    := "000"
		_wParcPcc    := ""
		_wParcPis    := ""
		_wParcCof    := ""
		_wParcCsl    := ""
		_wValPis     := 0
		_wValCof     := 0
		_wValCsl     := 0
		_wValTotPcc  := 0
		_wEmisTitPai := Ctod("  /  /  ")
		_wContTitPai := Ctod("  /  /  ")
		_wVencTitPai := Ctod("  /  /  ")
		_wTitPai     := ""
		_wLogDtHr    := ""
		_wMsIdent    := ""
	// --------------------------------------------------Eof - Definição de Variáveis a serem utilizadas
		_ChaveSe2 := xFilial("SE2")+Sf1->(F1_Fornece+F1_Loja+F1_Serie+F1_Doc)+"   "+"NF "	
		DbSelectarea("SE2")
		DbSetOrder(6)
		DbGotop()

		IF DbSeek(_ChaveSe2)

			//Verifica se tem retenção e se foi provisionada.
			IF (Se2->E2_Pis<>0 .And. Se2->E2_Cofins<>0 .And. Se2->E2_Csll<>0 .And. Se2->E2_PretPis=="1" .And. Se2->E2_PretCof=="1" .And. Se2->E2_PretCsl=="1")
				
				//Verifica parcelas
				IF !EMPTY(Se2->E2_ParcIr)

					_wParcela := StrZero(Val(Se2->E2_ParcIr),3)

				ENDIF

				_wParcPis 	 := StrZero(Val(_wParcela)+1,3)
				_wParcCof 	 := StrZero(Val(_wParcela)+2,3)
				_wParcCsl 	 := StrZero(Val(_wParcela)+3,3)
				_wValPis  	 := Se2->E2_Pis
				_wValCof  	 := Se2->E2_Cofins
				_wValCsl  	 := Se2->E2_Csll			
				_wEmisTitPai := Se2->E2_Emissao
				_wContTitPai := Se2->E2_Emis1
				_wVencTitPai := Se2->E2_VencRea
				_wUserLgi    := Se2->E2_UserLgi
				_wTitPai     := Se2->(E2_Prefixo+E2_Num+E2_Parcela+E2_Tipo+E2_Fornece+E2_Loja)
				_wLogDtHr    := Se2->E2_LOGDTHR
				_wMsIdent    := Se2->E2_MSIDENT			                           
				_wValTotPcc  := (_wValPis + _wValCof + _wValCsl)
				RecLock("SE2",.F.)       
				Se2->E2_Valor   := Se2->E2_Valor - _wValTotPcc
				Se2->E2_Saldo   := Se2->E2_Saldo - _wValTotPcc
				Se2->E2_VlCruz  := Se2->E2_Vlcruz - _wValTotPcc
				Se2->E2_VRetPis := _wValPis
				Se2->E2_VRetCof := _wValCof
				Se2->E2_VRetCsl := _wValCsl
				Se2->E2_PretPis := ""
				Se2->E2_PretCof := ""
				Se2->E2_PretCsl := ""
				Se2->E2_ParcPis := _wParcPis
				Se2->E2_ParcCof := _wParcCof
				Se2->E2_ParCsll := _wParcCsl
				MsUnlock()		

				FOR _wGeraPcc := 1 to 3				

					IF _wGeraPcc == 1

						_wImposto:=	"PIS" 
						_wParcPcc:= _wParcPis

					ELSEIF _wGeraPcc == 2

						_wImposto:=	"COFINS" 
						_wParcPcc:= _wParcCof

					ELSEIF _wGeraPcc == 3

						_wImposto:=	"CSLL"   
						_wParcPcc:= _wParcCsl					

					ENDIF				

					_wMsIdent := Strzero(Val(_wMsIdent)+1,10)	

					DbSelectArea("SE2")
					Reclock("SE2",.T.)
					Se2->E2_FILIAL   	:=  xFilial("SE2")
					Se2->E2_PREFIXO 	:=  ALLTRIM(Sf1->F1_Serie)
					Se2->E2_NUM   		:=  Sf1->F1_Doc
					Se2->E2_PARCELA  	:=  _wParcPcc
					Se2->E2_TIPO  		:=  "TX"
					Se2->E2_NATUREZ  	:= IF(_wGeraPCC==1,Getmv("MV_PISNAT"),If(_wGeraPCC==2,Getmv("MV_COFINS"),Getmv("MV_COFINS")))
					Se2->E2_FORNECE  	:= Getmv("MV_UNIAO")
					Se2->E2_LOJA  		:= "00"
					Se2->E2_NOMFOR  	:= Getmv("MV_UNIAO")
					Se2->E2_EMISSAO  	:= Sf1->F1_Emissao
					Se2->E2_VENCTO  	:= F050VImp(_wImposto,_wEmisTitPai,_wContTitPai,_wVencTitPai) // Calcula o vencimento do imposto
					Se2->E2_VENCREA  	:= F050VImp(_wImposto,_wEmisTitPai,_wContTitPai,_wVencTitPai) // Calcula o vencimento do imposto
					Se2->E2_VALOR  		:= IF(_wGeraPCC==1,_wValPis,If(_wGeraPCC==2,_wValCof,_wValCsl))
					Se2->E2_EMIS1  		:= _wContTitPai
					Se2->E2_HIST  		:= "Imposto gerado"
					Se2->E2_LA  		:= "S"
					Se2->E2_SALDO  		:= IF(_wGeraPCC==1,_wValPis,If(_wGeraPCC==2,_wValCof,_wValCsl))
					Se2->E2_VENCORI  	:= Se2->E2_Vencto
					Se2->E2_MOEDA  		:= 1
					Se2->E2_VLCRUZ  	:= IF(_wGeraPCC==1,_wValPis,If(_wGeraPCC==2,_wValCof,_wValCsl))
					Se2->E2_ORIGEM  	:= "MATA100"
					Se2->E2_USERLGI  	:= _wUserLgi
					Se2->E2_DATALIB 	:= _wEmisTitPai
					Se2->E2_CODRET  	:= "5952"
					Se2->E2_DIRF  		:= "2"
					Se2->E2_FILORIG  	:= xFilial("SE2")
					Se2->E2_TITPAI  	:= _wTitPai
					Se2->E2_LOGDTHR  	:= _wLogDtHr
					Se2->E2_MSIDENT  	:= Strzero(Val(_wMsIdent),10)
					Se2->E2_PROCPCC  	:= ""
					Se2->E2_FORNPAI  	:= ""
					//Se2->E2_NOMOPE  	:=
					MsUnlock()
				NEXT
			ENDIF
		ENDIF
		RestArea(_wArea)
		RestArea(_wAreaSF1)
		RestArea(_wAreaSE2)
	ENDIF                           
	
	// chamado retirado apos o almoxarifado solicitar utilizar
	// a tela de enderecamento 037315 - William Costa
	// para o SIGAACD chamado 021763
	// 24/09/2018 Liberação realizada novamente para o Almoxarifado em localização chamado 043529 - William Costa

	IF SuperGetMV("MV_LOCALIZ",.F.,"N")=="S" .AND. SF1->F1_TIPO == "N" 

		GerSldSDB ()	// Função especifica pace para endereçamento

	ENDIF
		
	RestArea(_aAlias)

	// Fim

RETURN()

//--------------------------------------------
// Grava dados adicionais
//--------------------------------------------
STATIC FUNCTION gravaDados()

	IF CEMPANT == "02"

		RecLock("SF1",.F.)
		SF1->F1_MENNOTA  := _cMensA
		SF1->F1_MENNOTB  := _cMensB
		msUnlock()

	ELSE

		RecLock("SF1",.F.)
		SF1->F1_MENNOTA  := _cMensA
		SF1->F1_MENNOTB  := _cMensB
		SF1->F1_PBRUTO   := _nPesob
		SF1->F1_PLIQUI	 := _nPesol
		SF1->F1_VOLUME1  := _nqtdVol
		SF1->F1_ESPECI1  := _cEspecie
		msUnlock()

	ENDIF

	Close(oDlg1)

RETURN(.T.)

/*{Protheus.doc} Static Function GerSldSDB
	Gera o Saldo por Endereco para notas fiscais de entrada
	@type  Function
	@author hcconsys
	@since 19/07/2006
	@version 01
*/	

Static Function GerSldSDB()

	Local cArea       := GetArea()
	Local cQuery      := ""
	Local cNota       := SF1->F1_DOC
	Local cSerie      := SF1->F1_SERIE
	Local cFornec     := SF1->F1_FORNECE
	Local cLoja       := SF1->F1_LOJA
	Local cEndereco   := ""
	Local cProduto    := ""
	Local cLocal      := ''
	Local lMsErroAuto := .F.
	Local aCab        := {}
	Local aItem       := {}
	
	cQuery := " SELECT DA_PRODUTO, "
	cQuery += "        DA_DOC,     "
	cQuery += "        DA_SERIE,   "
	cQuery += "        DA_NUMSEQ,  "
	cQuery += "        DA_CLIFOR,  "
	cQuery += "        DA_LOJA,    "
	cQuery += "        DA_SALDO,   "
	cQuery += "        DA_LOCAL,   "
	cQuery += "        DA_DATA     "
	cQuery += " FROM " + RetSQLName( "SDA" ) + " SDA "
	cQuery += " WHERE DA_FILIAL      = '" + xFilial("SDA") + "' "
	cQuery += "   AND DA_DOC         = '" + cNota          + "' "
	cQuery += "   AND DA_SERIE       = '" + cSerie         + "' "
	cQuery += "   AND DA_CLIFOR      = '" + cFornec        + "' "
	cQuery += "   AND DA_LOJA        = '" + cLoja          + "' "
	cQuery += "   AND DA_ORIGEM      = 'SD1' "
	cQuery += "   AND SDA.D_E_L_E_T_ = ' ' "
	cQuery += " ORDER BY DA_NUMSEQ "
	
	IF Select("TRBSDA") > 0

		dbSelectArea("TRBSDA")
		dbCloseArea()

	ENDIF
	
	TCQUERY cQuery NEW ALIAS "TRBSDA"
	
	DbSelectArea("TRBSDA")
	TRBSDA->(DBGoTop())
	
	IF !EOF()
		WHILE !TRBSDA->(EOF())
			
			IF !Localiza(TRBSDA->DA_PRODUTO)
			
				TRBSDA->(DbCloseArea())
				RestArea(cArea)
				RETURN

			ENDIF
			
			cEndereco := ''
			cProduto  := ''
			cLocal    := ''
			cEndereco := Posicione("SBE",10,xFilial("SBE")+TRBSDA->DA_PRODUTO+TRBSDA->DA_LOCAL,"BE_LOCALIZ")
			cProduto  := Posicione("SBE",10,xFilial("SBE")+TRBSDA->DA_PRODUTO+TRBSDA->DA_LOCAL,"BE_CODPRO")
			cLocal    := Posicione("SBE",10,xFilial("SBE")+TRBSDA->DA_PRODUTO+TRBSDA->DA_LOCAL,"BE_LOCAL") 
			// se nao encontrar/criar o endereco
			
			IF ALLTRIM(cEndereco) <> '' .AND. ;
			   ALLTRIM(cProduto)  <> '' .AND. ;
			   ALLTRIM(cLocal)    <> '' 
			
			    // Carrega o cabecalho (SDA)
				aAdd(aCab,{"DA_FILIAL ", xFilial("SDA")    ,NIL}) // Filial do sistema
				aAdd(aCab,{"DA_PRODUTO", cProduto   	   ,NIL}) // Produto
				aAdd(aCab,{"DA_LOCAL"  , cLocal            ,NIL}) // Local Padrao
				aAdd(aCab,{"DA_NUMSEQ" , TRBSDA->DA_NUMSEQ ,NIL}) // Numero Sequencial
				aAdd(aCab,{"DA_DOC"    , TRBSDA->DA_DOC    ,NIL}) // Nota Fiscal
				aAdd(aCab,{"DA_SERIE"  , TRBSDA->DA_SERIE  ,NIL}) // Serie
				aAdd(aCab,{"DA_CLIFOR" , TRBSDA->DA_CLIFOR ,NIL}) // Fornecedor
				aAdd(aCab,{"DA_LOJA"   , TRBSDA->DA_LOJA   ,NIL}) // Loja
								
				// Carrega os Itens (SDB)
				aAdd(aItem,{{"DB_FILIAL"  , xFilial("SDB")       ,NIL},;  // Filial do sistema
				            {"DB_ITEM"   , "001"                 ,NIL},;  // Item
				            {"DB_LOCALIZ", cEndereco             ,NIL},;  // Endereco
				            {"DB_DATA"   , STOD(TRBSDA->DA_DATA) ,NIL},;  // Data
				            {"DB_QUANT"  , TRBSDA->DA_SALDO      ,NIL}} ) // Quantidade
				
				Begin Transaction
				lMSErroAuto := .F.
				MSExecAuto({|x,y,z| Mata265(x,y,z)},aCab,aItem,3)
				
				IF lMSErroAuto  // Se der erro

					DisarmTransaction()
					MostraErro()
					RETURN .F.

				ELSE // naum deu erro

					EvalTrigger()
					Commit

				ENDIF
				
				END Transaction
				
				aCab := {}
				aItem:= {}
			
			ENDIF
					
			TRBSDA->(DBSkip())
		END
	ENDIF
	
	TRBSDA->(DbCloseArea())
	RestArea(cArea)

RETURN()