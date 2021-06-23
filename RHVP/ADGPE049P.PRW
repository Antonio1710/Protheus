#include "rwmake.ch"
#include "topconn.ch"
#include "REPORT.CH"

#DEFINE	 cEol        CHR(13)+CHR(10)

#DEFINE PAG_CNPJ    01      // - CNPJ da Empresa
#DEFINE PAG_NOME    02      // - Razใo Social
#DEFINE PAG_END     03      // - Endereco
#DEFINE PAG_NUM     04      // - Numero
#DEFINE PAG_COMPL   05      // - Complemento do Endereco
#DEFINE PAG_MUN     06      // - Municipio
#DEFINE PAG_CEP     07      // - CEP            //
#DEFINE PAG_UF      08      // - UF/Estado

/*/{Protheus.doc} User Function ADGPE049P
	Gera SISPAG/ITAU com Liquido e Holerite
	@type  Function
	@author FWNM
	@since 15/05/2019
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@chamado n. 048956 || OS 050224 || TECNOLOGIA || LUIZ || 8451 || FOLHA ITAU
	@history chamado 058273 - FWNM - 19/05/2020 - OS 059745 || FINANCAS || LUIZ || 8451 || CNAB FOLHA ITAU
/*/
User Function ADGPE049P()

	Local lParam      := .f.
	
	Private cPerg     := "ADGPE049P"
	Private cString   := "SRA"
	Private cPict2    := "@E 999.99"
	Private cID       := UpIDZFJ()
	Private oGeraTxt
	
	fAsrPerg()
	pergunte(cPerg,.F.)

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Gera SISPAG/ITAU com Liquido e Holerite')
	
	dbSelectArea( "SRA" )
	dbSetOrder(1)
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Montagem da tela de processamento.                                  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Do While .t.
	
		@ 200,001 TO 410,480 DIALOG oGeraTxt TITLE OemToAnsi( "Geracao do SISPAG de Salแrios" )
		@ 002,010 TO 095,230
		@ 010,018 Say OemToAnsi( " Esta rotina irแ gerar o arquivo SISPAG para pagamento de salแrios  " )
		@ 018,018 Say OemToAnsi( " pelo Banco Ita๚, com envio dos Holerites.                          " )
		@ 026,018 Say OemToAnsi( " Aten็ใo: Esta rotina atende o leiaute Ita๚ apenas para cr้dito em conta corrente " )
		
		@ 070,128 BMPBUTTON TYPE 05 ACTION {lParam := .t., Pergunte(cPerg,.T.)}
		@ 070,158 BMPBUTTON TYPE 01 ACTION OkGeraTxt(lParam)
		@ 070,188 BMPBUTTON TYPE 02 ACTION Close(oGeraTxt)
		
		Activate Dialog oGeraTxt Centered
		
		If lParam
			Exit
		EndIf
	
	EndDo

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณOKGERATXT บ Autor ณ Fernando Macieira  บ Data ณ  15/05/2019 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Funcao chamada pelo botao OK na tela inicial de processamenบฑฑ
ฑฑบ          ณ to. Executa a geracao do arquivo texto.                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function OkGeraTxt(lParam)

	If lParam
		Processa({|| RunCont() },"Processando...")
		Close(oGeraTxt)
	Else
		msgInfo("Informe e confira os parโmetros para que o processamento possa ser realizado...")
	EndIf
	
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณ RUNCONT  บ Autor ณ Fernando Macieira  บ Data ณ  15/05/2019 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Funcao auxiliar chamada pela PROCESSA.  A funcao PROCESSA  บฑฑ
ฑฑบ          ณ monta a janela com a regua de processamento.               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function RunCont

	Local lIgual                 //Variavel de retorno na comparacao do SRC
	Local cArqNew                //Variavel de retorno caso SRC #SX3
	Local cMesArqRef
	Local aOrdBag     := {}
	Local cArqMov     := ""
	Local cAliasMov   := ""
	Local cAcessaSR1  := &("{ || " + ChkRH("GPER030","SR1","2") + "}")
	Local cAcessaSRA  := &("{ || " + ChkRH("GPER030","SRA","2") + "}")
	Local c_DbAgencia := StrZero(Val(AllTrim(GetNewPar("MV_FOLAGE", ""))), 5)  // Agencia do Itau debitada 
	Local c_DbConta   := StrZero(Val(AllTrim(GetNewPar("MV_FOLCCD", ""))),12)  // Conta do Itau debitada   
	Local c_DbDigito  := SubStr(     AllTrim(GetNewPar("MV_FOLDIG", "")),1,1)  // Digito da conta debitada 
	Local a_CposEmp   := RetSM0("01",0) // Retorna Detalhes da Filial Matriz 

	Private Esc, Semana, cFilDe, cFilAte, cCcDe, cCcAte, cMatDe, dDataDe, dDataAte 
	Private cMatAte, Mensag1, Mensag2, Mensag3, cSit, cCat, cNomeArq
	Private lAtual, cCond
	Private cBancoDe, cBancoAte, cContaDe, cContaAte, nSRCSRD
	Private nHdl, cLin
	Private cFinPgt, nSequenc, dDataPagto
	Private aTotLote := {0,0}
	Private TOTVENC, TOTDESC, FLAG, CHAVE
	Private Desc_Fil, Desc_End, DESC_CGC, DESC_FUNC
	Private DESC_MSG1, DESC_MSG2, DESC_MSG3
	Private c_FilialAnt, cFuncaoAnt, cCcAnt, Vez, OrdemZ
	Private aLanca, aProve, aDesco, aBases
	Private nAteLim, nBaseFgts, nFgts, nBaseIr, nBaseIrFe, nLiquido
	Private nHdl2
	Private aLanca  := {}
	Private aProve  := {}
	Private aDesco  := {}
	Private aBases  := {}
	Private aInfo   := {}
	Private aCodFol := {}
	Private n_QtdeLotes   := 0       // Conta a qtde e a numeracao de lotes do arquivo - .
	Private n_QtdRegsArq  := 0       // Acumula o Total de Registros do Arquivo - .
	Private l_FirstBreak  := .F.    // Controla Impressao do trailer do lote - .
	Private l_EnviaFunc   := .T.     // Valida a exist๊ncia de campos chave para o SISPAG - .
	Private cPeriodo      := mv_par01 //incluida a variavel para gravar o periodo conforme a data de referencia 
	Private n_RegConsD    := 0
	Private cNomArqC      := ''

	// Chamado TI - FWNM - 04/06/2019 - Correcao error log - cAcessaSRC
	Private cAcessaSRC  := &("{ || " + ChkRH("GPER030","SRC","2") + "}")
	Private cAcessaSRI  := &("{ || " + ChkRH("GPER030","SRI","2") + "}")
	Private cAcessaSRD  := &("{ || " + ChkRH("GPER030","SRD","2") + "}")
	Private cAcessaSRR  := &("{ || " + ChkRH("GPER030","SRR","2") + "}")
	Private cAcessaSRG  := &("{ || " + ChkRH("GPER030","SRG","2") + "}")
	Private cAcessaSRH  := &("{ || " + ChkRH("GPER030","SRH","2") + "}")
	//
	
	Pergunte(cPerg,.F.)

	Esc        := mv_par02
	Semana     := mv_par03
	cFilDe     := mv_par04
	cFilAte    := mv_par05
	cCcDe      := mv_par06
	cCcAte     := mv_par07
	cMatDe     := mv_par08
	cMatAte    := mv_par09
	Mensag1    := mv_par10
	Mensag2    := mv_par11
	Mensag3    := mv_par12
	cSit       := mv_par13
	cCat       := mv_par14
	cNomeArq   := Alltrim(mv_par15)
	dDataPagto := mv_par16
	cBancoDe   := mv_par17
	cBancoAte  := mv_par18
	cContaDe   := mv_par19
	cContaAte  := mv_par20
	nSRCSRD    := MV_PAR21
	dDataDe    := MV_PAR22
	dDataAte   := MV_PAR23
	
	// S052 - Dados bancarios de debito
	RCC->( dbSetOrder(1) ) // RCC_FILIAL + RCC_CODIGO
	If RCC->( dbSeek( FWxFilial("RCC")+"S052" ) )
		c_DbAgencia := StrZero(Val(AllTrim(Subs(RCC->RCC_CONTEU,24,4))), 5)  // Agencia do Itau debitada
		c_DbConta   := StrZero(Val(AllTrim(Subs(RCC->RCC_CONTEU,30,6))),12)  // Conta do Itau debitada 
		c_DbDigito  := Right(AllTrim(RCC->RCC_CONTEU),1)  // Digito da conta debitada
	EndIf
	
	If Empty(AllTrim(Subs(RCC->RCC_CONTEU,24,4))) .or. Empty(AllTrim(Subs(RCC->RCC_CONTEU,30,6))) .or. Empty(Right(AllTrim(RCC->RCC_CONTEU),1))
		MsgAlert("Arquivo nใo serแ gerado pois serแ rejeitado! Cadastre os dados bancแrios da empresa na tabela S052...","Atencao!")
		Return 
	EndIf
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Cria o arquivo texto                                                ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	nHdl  := fCreate(cNomeArq)
	
	// 
	//cNomArqC := cNomeArq
	//nHdl2    := fCreate(STRTRAN(cNomArqC,'.','CONS.'))
	// 
	
	If nHdl == -1
		MsgAlert("O arquivo de nome "+cNomeArq+" nao pode ser executado! Verifique os parametros.","Atencao!")
		Return
	Endif
	
	// 
	/*
	If nHdl2 == -1
		MsgAlert("O arquivo de nome "+cNomArqC+" nao pode ser executado! Verifique os parametros.","Atencao!")
		Return
	Endif
	*/
	// 
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Selecionando a Ordem de impressao escolhida no parametro.    ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	dbSelectArea( "CTT" )
	dbSetOrder(1)
	dbSelectArea( "SRF" )
	dbSetOrder(1)
	dbSelectArea( "SRH" )
	dbSetOrder(1)
	dbSelectArea( "SRJ" )
	dbSetOrder(1)
	dbSelectArea( "SRA" )
	dbSetOrder(1)
	dbGoTop()

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Selecionando o Primeiro Registro e montando Filtro.          ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	dbSeek(cFilDe + cMatDe,.T.)
	cCond := "SRA->RA_FILIAL + SRA->RA_MAT <= cFilAte + cMatAte"
	
	dbSelectArea("SRA")
	ProcRegua(RecCount())
	
	TOTVENC     := TOTDESC   := FLAG      := CHAVE     := 0
	Desc_Fil    := Desc_End  := DESC_CGC  := DESC_FUNC := ""
	DESC_MSG1   := DESC_MSG2 := DESC_MSG3 := Space(01)
	c_FilialAnt := "  "
	cFuncaoAnt  := "    "
	cCcAnt      := Space(9)
	Vez         := 0
	OrdemZ      := 0
	nSequenc    := 0
	
	If Esc == "ADI"			// Adiantamento
		cFinPgt := "02"
	
	ElseIf Esc == "FOL"		// Folha
		cFinPgt := "01"
	
	ElseIf Esc == "131"		// 1a Parcela
		cFinPgt := "04"
	
	ElseIf Esc == "132"		// 2a Parcela
		cFinPgt := "04"
	
	Else					// Extras
		cFinPgt := "10"
	
	EndIf
	
	// Monta Header de Arquivo - Registro Tipo "0"
	fMonta0(c_DbAgencia, c_DbConta, c_DbDigito, a_CposEmp)
	
	// Monta Header de Lote - Registro Tipo "1"
	fMonta1(c_DbAgencia, c_DbConta, c_DbDigito)
	
	//  - Monta Header de Lote - Registro Tipo "0" HEADER DO CONSIGNADO
	//fConsH(c_DbAgencia, c_DbConta, c_DbDigito, a_CposEmp)
	// 
	
	dbSelectArea("SRA")
	Do While !Eof() .And. &cCond
	
		IncProc( SRA->RA_FILIAL + " - " + SRA->RA_NOME )
		
		If (SRA->RA_FILIAL   < cFilDe)  .Or. (SRA->RA_FILIAL   > cFilAte) .Or. ;
			(SRA->RA_CC       < cCcDe)   .Or. (SRA->RA_CC       > cCcAte)  .Or. ;
			(SRA->RA_MAT      < cMatDe)  .Or. (SRA->RA_MAT      > cMatAte) .Or. ;
			!(SRA->RA_SITFOLH $ cSit)    .Or. !(SRA->RA_CATFUNC $ cCat)
			dbSkip()
			Loop
		EndIf
		
		// Filtra Bancos e Contas
		If (SRA->RA_BCDEPSA < cBancoDe  .Or. SRA->RA_BCDEPSA > cBancoAte) .Or. ;
			(SRA->RA_CTDEPSA < cContaDe  .Or. SRA->RA_CTDEPSA > cContaAte)
			dbSkip()
			Loop
		EndIf
		
		// Consisto banco itau
		If Left(AllTrim(SRA->RA_BCDEPSA),3) <> "341"
			dbSkip() 
			Loop
		EndIf
		
		aLanca  := {}
		aProve  := {}
		aDesco  := {}
		aBases  := {}
		nAteLim := nBaseFgts := nFgts := nBaseIr := nBaseIrFe := nLiquido := 0.00
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Consiste controle de acessos e filiais validas		        |
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If !(SRA->RA_FILIAL $ fValidFil()) .Or. !Eval(cAcessaSRA)
			dbSkip()
			Loop
		EndIf
		
		If SRA->RA_CODFUNC # cFuncaoAnt           // Descricao da Funcao
			DescFun(Sra->Ra_Codfunc,Sra->Ra_Filial)
			cFuncaoAnt := Sra->Ra_CodFunc
		Endif
		
		If SRA->RA_CC # cCcAnt                   // Centro de Custo
			DescCC(Sra->Ra_Cc,Sra->Ra_Filial)
			cCcAnt := SRA->RA_CC
		Endif
		
		If SRA->RA_Filial # c_FilialAnt
			
			If !Fp_CodFol(@aCodFol,Sra->Ra_Filial) .Or. ! fInfo(@aInfo,Sra->Ra_Filial)
				Exit
			Endif
			
			TOTVENC       := 0
			TOTDESC       := 0
			FLAG          := 0
			CHAVE         := 0
			Desc_Fil      := ""
			Desc_End      := ""
			DESC_CGC      := ""
			DESC_FUNC     := ""
			DESC_MSG1     := Space(01)
			DESC_MSG2     := Space(01)
			DESC_MSG3     := Space(01)
			
			// Qtde para o trailer do arquivo e numero do lote para os detalhes do funcionario (Segmentos A, D, E, F).
			n_QtdeLotes := 1
			Desc_Fil := aInfo[3]
			Desc_End := aInfo[4]                // Dados da Filial
			Desc_CGC := aInfo[8]
			DESC_MSG1:= DESC_MSG2 := DESC_MSG3 := Space(01)
			
			// MENSAGENS
			If MENSAG1 # SPACE(1)
				If FPHIST82(SRA->RA_FILIAL,"06",SRA->RA_FILIAL+MENSAG1)
					DESC_MSG1 := Left(SRX->RX_TXT,30)
				ElseIf FPHIST82(SRA->RA_FILIAL,"06","  "+MENSAG1)
					DESC_MSG1 := Left(SRX->RX_TXT,30)
				Endif
			Endif
			
			If MENSAG2 # SPACE(1)
				If FPHIST82(SRA->RA_FILIAL,"06",SRA->RA_FILIAL+MENSAG2)
					DESC_MSG2 := Left(SRX->RX_TXT,30)
				ElseIf FPHIST82(SRA->RA_FILIAL,"06","  "+MENSAG2)
					DESC_MSG2 := Left(SRX->RX_TXT,30)
				Endif
			Endif
			
			If MENSAG3 # SPACE(1)
				If FPHIST82(SRA->RA_FILIAL,"06",SRA->RA_FILIAL+MENSAG3)
					DESC_MSG3 := Left(SRX->RX_TXT,30)
				ElseIf FPHIST82(SRA->RA_FILIAL,"06","  "+MENSAG3)
					DESC_MSG3 := Left(SRX->RX_TXT,30)
				Endif
			Endif
			
			dbSelectArea("SRA")
			
			c_FilialAnt := SRA->RA_FILIAL
			
		Endif
		
		Totvenc := Totdesc := 0
		
		//---------------------------------------------------------------------+
		// Verifica a exist๊ncia do centro de custos e do codigo funcionแrio   |
		// -- Avisa o usuแrio para evitar rejei็ใo do arquivo/lote pelo Banco. |
		//---------------------------------------------------------------------+
		l_EnviaFunc := .T.
		
		If Empty(FWxFilial("CTT"))
			If !CTT->( dbSeek( FWxFilial("CTT")+SRA->RA_CC ) )
				MsgAlert("O Centro de Custo ("+AllTrim(SRA->RA_CC)+") do Funcionแrio "+SRA->RA_MAT+"/"+AllTrim(SRA->RA_NOME)+", da Filial "+SRA->RA_FILIAL+", Nใo consta na tabela de Centros de Custos! Necessแrio cadastrแ-lo...","Atencใo!")
				l_EnviaFunc := .F.
			EndIf
		Else
			If !CTT->( dbSeek( SRA->RA_FILIAL+SRA->RA_CC ) )
				MsgAlert("O Centro de Custo ("+AllTrim(SRA->RA_CC)+") do Funcionแrio "+SRA->RA_MAT+"/"+AllTrim(SRA->RA_NOME)+", da Filial "+SRA->RA_FILIAL+", Nใo consta na tabela de Centros de Custos! Necessแrio cadastrแ-lo...","Atencใo!")
				l_EnviaFunc := .F.
			EndIf
		EndIf
		
		If Empty(FWxFilial("SRJ"))
			If !SRJ->( dbSeek( FWxFilial("SRJ")+SRA->RA_CODFUNC ) )
				MsgAlert("A Fun็ใo ("+AllTrim(SRA->RA_CODFUNC)+") do Funcionแrio "+SRA->RA_MAT+"/"+AllTrim(SRA->RA_NOME)+", da Filial "+SRA->RA_FILIAL+", Nใo consta na tabela de Fun็๕es! Necessแrio cadastrแ-la...","Atencใo!")
				l_EnviaFunc := .F.
			EndIf
		Else
			If !SRJ->( dbSeek( SRA->RA_FILIAL+SRA->RA_CODFUNC ) )
				MsgAlert("A Fun็ใo ("+AllTrim(SRA->RA_CODFUNC)+") do Funcionแrio "+SRA->RA_MAT+"/"+AllTrim(SRA->RA_NOME)+", da Filial "+SRA->RA_FILIAL+", Nใo consta na tabela de Fun็๕es! Necessแrio cadastrแ-la...","Atencใo!")
				l_EnviaFunc := .F.
			EndIf
		EndIf
		
		If l_EnviaFunc
			
			If Esc <> "RES" .and. Esc <> "FER" .and. Esc <> "VEX"
				
				If nSRCSRD == 1 // Aberto (SRC)
				
					dbSelectArea("SRC")
					If dbSeek(SRA->RA_FILIAL + SRA->RA_MAT)
					
						Do While !Eof() .And. SRC->RC_FILIAL+SRC->RC_MAT == SRA->RA_FILIAL+SRA->RA_MAT 
			
							If SRC->RC_SEMANA # Semana
								dbSkip()
								Loop
							Endif

		  					If SRC->RC_PERIODO # cPeriodo 
								dbSkip()
								Loop
							Endif   

						 	If (SRC->RC_ROTEIR # ESC)
						 		dbSkip()
						 		Loop
							Endif 					

							If !Eval(cAcessaSRC)
								dbSkip()
								Loop
							EndIf

							If PosSrv( SRC->RC_PD, SRA->RA_FILIAL, "RV_TIPOCOD" ) == "1"
								fSomaPd("P",SRC->RC_PD,SRC->RC_HORAS,SRC->RC_VALOR)
								TOTVENC += SRC->RC_VALOR
							Elseif PosSrv( SRC->RC_PD, SRA->RA_FILIAL, "RV_TIPOCOD" ) == "2"
								fSomaPd("D",SRC->RC_PD,SRC->RC_HORAS,SRC->RC_VALOR)
								TOTDESC += SRC->RC_VALOR
							Elseif PosSrv( SRC->RC_PD, SRA->RA_FILIAL, "RV_TIPOCOD" ) == "3"
								fSomaPd("B",SRC->RC_PD,SRC->RC_HORAS,SRC->RC_VALOR)
							Endif

							nLiquido := totvenc-totdesc

							// Bases IR, INSS e FGTS
							If ESC = "ADI"
							
								If SRC->RC_PD == aCodFol[10,1]
									nBaseIr := SRC->RC_VALOR
								Endif
							
							ElseIf ESC == "FOL" .OR. ESC == "131"
							
								If SRC->RC_PD == aCodFol[13,1] .OR. SRC->RC_PD == aCodFol[14,1]
									nAteLim += SRC->RC_VALOR
			
								Elseif SRC->RC_PD $ aCodFol[108,1]+'*'+aCodFol[17,1]
									nBaseFgts += SRC->RC_VALOR
								
								Elseif SRC->RC_PD $ aCodFol[109,1]+'*'+aCodFol[18,1]
									nFgts += SRC->RC_VALOR
								
								Elseif SRC->RC_PD == aCodFol[15,1]
									nBaseIr += SRC->RC_VALOR
								
								Elseif SRC->RC_PD == aCodFol[16,1]
									nBaseIrFe += SRC->RC_VALOR
								
								Elseif SRC->RC_PD == aCodFol[47,1]
									nLiquido := SRC->RC_VALOR
								
								Endif

							ElseIf ESC == "132"
							
								If SRC->RC_PD == aCodFol[19,1] .or. SRC->RC_PD == aCodFol[20,1]
									nAteLim += SRC->RC_VALOR

								Elseif SRC->RC_PD $ aCodFol[108,1]
									nBaseFgts += SRC->RC_VALOR

								Elseif SRC->RC_PD $ aCodFol[109,1]
									nFgts += SRC->RC_VALOR

								Elseif SRC->RC_PD == aCodFol[27,1]
									nBaseIr += SRC->RC_VALOR

								Elseif SRC->RC_PD == aCodFol[16,1]
									nBaseIrFe += SRC->RC_VALOR

								Elseif SRC->RC_PD == aCodFol[21,1]
									nLiquido := SRC->RC_VALOR

								Endif

							Endif
							
							dbSelectArea("SRC")
							dbSkip()
						
						Enddo
				
					Endif
					
				Else 
				
					dbSelectArea("SRD")
					If dbSeek(SRA->RA_FILIAL + SRA->RA_MAT)
					
						Do While !Eof() .And. SRD->RD_FILIAL+SRD->RD_MAT == SRA->RA_FILIAL+SRA->RA_MAT 
			
							If SRD->RD_SEMANA # Semana
								dbSkip()
								Loop
							Endif

		  					If SRD->RD_PERIODO # cPeriodo 
								dbSkip()
								Loop
							Endif   

						 	If (SRD->RD_ROTEIR # ESC)
						 		dbSkip()
						 		Loop
							Endif 					

							If !Eval(cAcessaSRD)
								dbSkip()
								Loop
							EndIf

							If PosSrv( SRD->RD_PD, SRA->RA_FILIAL, "RV_TIPOCOD" ) == "1"
								fSomaPd("P",SRD->RD_PD,SRD->RD_HORAS,SRD->RD_VALOR)
								TOTVENC += SRD->RD_VALOR
							Elseif PosSrv( SRD->RD_PD, SRA->RA_FILIAL, "RV_TIPOCOD" ) == "2"
								fSomaPd("D",SRD->RD_PD,SRD->RD_HORAS,SRD->RD_VALOR)
								TOTDESC += SRD->RD_VALOR
							Elseif PosSrv( SRD->RD_PD, SRA->RA_FILIAL, "RV_TIPOCOD" ) == "3"
								fSomaPd("B",SRD->RD_PD,SRD->RD_HORAS,SRD->RD_VALOR)
							Endif

							nLiquido := totvenc-totdesc

							// Bases IR, INSS e FGTS
							If ESC = "ADI"
							
								If SRD->RD_PD == aCodFol[10,1]
									nBaseIr := SRD->RD_VALOR
								Endif
							
							ElseIf ESC == "FOL" .OR. ESC == "131"
							
								If SRD->RD_PD == aCodFol[13,1] .OR. SRD->RD_PD == aCodFol[14,1] 
									nAteLim += SRD->RD_VALOR
			
								Elseif SRD->RD_PD $ aCodFol[108,1]+'*'+aCodFol[17,1]
									nBaseFgts += SRD->RD_VALOR
								
								Elseif SRD->RD_PD $ aCodFol[109,1]+'*'+aCodFol[18,1]
									nFgts += SRD->RD_VALOR
								
								Elseif SRD->RD_PD == aCodFol[15,1]
									nBaseIr += SRD->RD_VALOR
								
								Elseif SRD->RD_PD == aCodFol[16,1]
									nBaseIrFe += SRD->RD_VALOR
								
								Elseif SRD->RD_PD == aCodFol[47,1]
									nLiquido := SRD->RD_VALOR
								
								Endif

							ElseIf ESC == "132"
							
								If SRD->RD_PD == aCodFol[19,1] .or. SRD->RD_PD == aCodFol[20,1]
									nAteLim += SRD->RD_VALOR

								Elseif SRD->RD_PD $ aCodFol[108,1]
									nBaseFgts += SRD->RD_VALOR

								Elseif SRD->RD_PD $ aCodFol[109,1]
									nFgts += SRD->RD_VALOR

								Elseif SRD->RD_PD == aCodFol[27,1]
									nBaseIr += SRD->RD_VALOR

								Elseif SRD->RD_PD == aCodFol[16,1]
									nBaseIrFe += SRD->RD_VALOR

								Elseif SRD->RD_PD == aCodFol[21,1]
									nLiquido := SRD->RD_VALOR

								Endif

							Endif
							
							dbSelectArea("SRD")
							dbSkip()
							
						Enddo
				
					Endif
					
				EndIf
				
			Endif
			
			dbSelectArea("SRA")
			
			If Esc == "RES" .or. Esc == "FER" .or. Esc == "VEX"
				aAreaAtu := GetArea() 
				
				// CARREGANDO ARRAY AROTEIROS COM OS ROTEIROS SELECIONADOS
				If Len(MV_PAR02) > 0
					aRoteiros := {}
					SelecRoteiros()	
				EndIf		
		
				nLiquido  := 0
				aFunBenef := {}
				// BUSCA OS VALORES DE LIQUIDO E BENEFICIOS
				//yGp020BuscaLiq(@nLiquido,@aFunBenef)
				Gp020BuscaLiq(@nLiquido,@aFunBenef)
				
				RestArea( aAreaAtu )
			EndIf

			If TOTVENC = 0 .And. TOTDESC = 0 .and. nLiquido = 0
				SRA->( dbSkip() )
				Loop
			Endif
			
			//------------------------------------------------------------+
			// Valida o valor liquido a pagar antes de gerar os registros |
			// detalhe do Colaborador. Se zerar, nใo enviar para que seja |
			// evitada a rejei็ใo de todo o arquivo/lote(s) por causa de  |
			// um colaborador afastado, sem salแrio ou retornando de      |
			// f้rias.                                                    |
			//------------------------------------------------------------+
			If nLiquido > 0 .OR. TOTVENC > 0 .OR. TOTDESC > 0
				
				nSequenc++
				
				//------------------------------------------------------------+
				// Detalhes do Funcionario.                                   |
				//------------------------------------------------------------+
				
				// Monta Detalhe de Lote - Registro Tipo "3" Segmento "A"
				fMonta3A()
	
				//If Esc <> "RES" .and. Esc <> "FER" .and. Esc <> "VEX" // Chamado n. 048956 || OS 050224 || TECNOLOGIA || LUIZ || 8451 || FOLHA ITAU ณ FWNM - 12/06/2019 - Roteiro ADI nao deve gerar Holerite
				If Esc <> "RES" .and. Esc <> "FER" .and. Esc <> "VEX" .and. Esc <> "ADI" // Chamado n. 048956 || OS 050224 || TECNOLOGIA || LUIZ || 8451 || FOLHA ITAU ณ FWNM - 12/06/2019 - Roteiro ADI nao deve gerar Holerite

					/*
					Segmento D, E e F – (Opcionais. Necessแrio quando contratado o servi็o de Holerite – Demonstrativo de Pagamentos / Informe de Rendimentos via 30 Horas / Auto Atendimento)
					*/

					// Chamado n. 058273 || OS 059745 || FINANCAS || LUIZ || 8451 || CNAB FOLHA ITAU - FWNM - 19/05/2020
					If GetMV("MV_#HOLERI",,.F.)

						// Monta Detalhe de Lote - Registro Tipo "3" Segmento "D"
						fMonta3D()
				
						// Monta Detalhe de Lote - Registro Tipo "3" Segmento "E" --> Proventos
						fMonta3E( aProve, "1" )
				
						// Monta Detalhe de Lote - Registro Tipo "3" Segmento "E" --> Descontos
						fMonta3E( aDesco, "2" )
				
						// Monta Detalhe de Lote - Registro Tipo "3" Segmento "F"
						fMonta3F()
					
					EndIf
					
				EndIf
					
			EndIf
			
			//  - Monta Detalhe de Lote - Registro Tipo "1" - DETALHE DO CONSIGNADO
			IF SUBSTR(SRA->RA_BCDEPSA,1,3) == '341' // SOMENTE BANCO ITAU PARA O CONSIGINADO
				// Antes - Permitia consignado para funcionario em Experiencia e Demitidos
				//n_RegConsD++
				//fConsD(c_DbAgencia, c_DbConta, c_DbDigito)
				
				//---> Verifica se Funcionario ja passou na Experiencia e se nao esta Demitido, nao Gera Consignado 
				
				/*
				if (SRA->RA_ADMISSA + 90) < date() .AND. SRA->RA_SITFOLH <> "D"
					n_RegConsD++
					fConsD(c_DbAgencia, c_DbConta, c_DbDigito)
				Endif
				*/
			Endif
			// 
			
		Else
			
			MsgBox("Processamento abortado - Erro(s) de Cadastro(s) - Arquivo nใo gerado!","Erro Fatal!", "ERROR")
			
			fClose( nHdl )
			fErase(cNomeArq + OrdBagExt())
			
			// 
			// Fecha o arquivo TXT do consignado
			//fClose( nHdl2 )
			//fErase(cNomArqC + OrdBagExt())
			// 
			
			MS_FLUSH()
			
			RETURN
			
		EndIf
		
		// Log
		GrvZFJ() //-- VOLTAR QDO EM PRODUCAO, APOS TESTES!!!  -- VOLTAR - DEBUG !!!!!
		
		TOTDESC := TOTVENC := 0
		
		dbSelectArea("SRA")
		SRA->(dbSkip())
		
	EndDo

	// Monta trailer de Lote - Registro Tipo "5"
	fMonta5()
	
	// Monta trailer de Arquivo - Registro Tipo "9"
	fMonta9()

	//  Monta Trailler de Lote - TRAILLER DO CONSIGNADO
	//fConsT(c_DbAgencia, c_DbConta, c_DbDigito)
	// 
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Termino do relatorio                                         ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	dbSelectArea("SRC")
	dbSetOrder(1)          // Retorno a ordem 1
	dbSelectArea("SRI")
	dbSetOrder(1)          // Retorno a ordem 1
	dbSelectArea("SRA")
	SET FILTER TO
	
	fClose( nHdl )
	If !(Type("cNomeArq") == "U")
		fErase(cNomeArq + OrdBagExt())
	Endif
	
	// 
	fClose( nHdl2 )
	If !(Type("cNomeArq") == "U")
		fErase(cNomArqC + OrdBagExt())
	Endif
	// 
	
	MS_FLUSH()
	
	//----------------------------------------------------------------------------+
	// Aviso de T้rmino de Processamento.      |
	//----------------------------------------------------------------------------+
	MsgInfo("Arquivo " + cNomeArq + " gerado com sucesso!","FIM!")
	
	If msgYesNo("Deseja imprimir relat๓rio de log agora?")
		RelGPE049()
	EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณfSomaPd   ณ Autor ณ R.H. - Mauro          ณ Data ณ 24.09.95 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Somar as Verbas no Array                                   ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ fSomaPd(Tipo,Verba,Horas,Valor)                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ                                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function fSomaPd(cTipo,cPd,nHoras,nValor)

	Local Desc_paga
	
	Desc_paga := DescPd(cPd,Sra->Ra_Filial)  // mostra como pagto
	
	If cTipo #'B'
		//--Array para Recibo Pre-Impresso
		nPos := Ascan(aLanca,{ |X| X[2] = cPd })
		If nPos == 0
			Aadd(aLanca,{cTipo,cPd,Desc_Paga,nHoras,nValor})
		Else
			aLanca[nPos,4] += nHoras
			aLanca[nPos,5] += nValor
		Endif
	Endif
	
	//--Array para o Recibo Pre-Impresso
	If cTipo = 'P'
		cArray := "aProve"
	Elseif cTipo = 'D'
		cArray := "aDesco"
	Elseif cTipo = 'B'
		cArray := "aBases"
	Endif
	
	nPos := Ascan(&cArray,{ |X| X[1] = cPd })
	If nPos == 0
		Aadd(&cArray,{cPd+" "+Desc_Paga,nHoras,nValor })
	Else
		&cArray[nPos,2] += nHoras
		&cArray[nPos,3] += nValor
	Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRGPECNAB  บAutor  ณMicrosiga           บ Data ณ  05/15/19   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function fConvData( dData, xTipo )

	Local cRet := Space(08)
	
	If xTipo == "DDMMAAAA"
		cRet := StrZero(Day(dData),2) + StrZero(Month(dData),2) + StrZero(Year(dData),4)
	ElseIf xTipo == "MMAAAA"
		cRet := StrZero(Month(dData),2) + StrZero(Year(dData),4)
	EndIf

Return cRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRGPECNAB  บAutor  ณMicrosiga           บ Data ณ  05/15/19   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function fCheckFer( xTipoFer )

	Local aOld := GETAREA()
	Local cRet := SPACE(08) //Replicate("0",08)

	
	If SRA->RA_SITFOLH == "F"
		If SRH->(dbSeek( SRA->(RA_FILIAL+RA_MAT)))
			While !Eof() .And. SRH->((RH_FILIAL+RH_MAT)) == SRA->((RA_FILIAL+RA_MAT))
				
				If xTipoFer == "INI"
					cRet := fConvData( SRH->RH_DATAINI, "DDMMAAAA" )
				ElseIf xTipoFer == "FIM"
					cRet := fConvData( SRH->RH_DATAFIM, "DDMMAAAA" )
				EndIf
				
			dbSelectArea("SRH")
			dbSkip()
			Enddo
		EndIf
	EndIf
	
	
	RESTAREA( aOld )

Return cRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRGPECNAB  บAutor  ณMicrosiga           บ Data ณ  05/15/19   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function fConvHora( cHora )

	Local cRet := SubStr(cHora,1,2)+SubStr(cHora,4,2)+SubStr(cHora,7,2)

Return cRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRGPECNAB  บAutor  ณMicrosiga           บ Data ณ  05/15/19   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function fMonta0(c_DbAgencia, c_DbConta, c_DbDigito, a_CposEmp)

	cLin := "341"                  	                        	// 001 a 003 Codigo do Banco
	cLin += "0000"             	                            	// 004 a 007 Codigo do Lote
	cLin += "0"            	                                	// 008 a 008 Tipo do Registro
	cLin += Space(06)   	            	                    // 009 a 014 Brancos
	cLin += "080"                          	                	// 015 a 017 Lay-Out do Arquivo
	cLin += "2"                                	            	// 018 a 018 Tipo Inscricao Empresa
	cLin += a_CposEmp[PAG_CNPJ]                    	        	// 019 a 032 Cnpj Empresa
	cLin += Space(20)                                  	    	// 033 a 052 Brancos
	cLin += c_DbAgencia                                         // 053 a 057 Agencia Debitada
	cLin += Space(01)                                      		// 058 a 058 Brancos
	cLin += c_DbConta                                 	        // 059 a 070 Conta Corrente Debitada
	cLin += Space(01)                                      		// 071 a 071 Brancos
	cLin += c_DbDigito                                         	// 072 a 072 Digito Conta Corrente
	cLin += a_CposEmp[PAG_NOME]                    		        // 073 a 102 Nome da Empresa
	cLin += "BANCO ITAU S/A                "               		// 103 a 132 Nome do Banco
	cLin += Space(10)                                  	    	// 133 a 142 Brancos
	cLin += "1"                                            		// 143 a 143 Codigo Remessa
	cLin += fConvData( dDataBase, "DDMMAAAA" )                	// 144 a 151 Data Geracao Arquivo
	cLin += fConvHora( Time() )                             	// 152 a 157 Hora Geracao Arquivo
	cLin += "000000000"                                    		// 158 a 166 Zeros
	cLin += "00000"                                        		// 167 a 171 Densidade de Gravacao
	cLin += Space(69)                                  	    	// 172 a 240 Brancos
	cLin += cEol

	fGravaTxt()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRGPECNAB  บAutor  ณMicrosiga           บ Data ณ  05/15/19   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function fMonta1(c_DbAgencia, c_DbConta, c_DbDigito)

	Local a_CposEmp   := RetSM0("01",0)
	
	cLin := "341"                  	                        	// 001 a 003 Codigo do Banco
	cLin += "0001"    											// 004 a 007 Codigo do Lote
	cLin += "1"            	                                	// 008 a 008 Tipo do Registro
	cLin += "C"                        	                    	// 009 a 009 Tipo Operacao "C=Credito"
	cLin += "30"        	            	                    // 010 a 011 Tipo Pagamento "30=Salarios"
	cLin += "01"        	            	                    // 012 a 013 Forma Pagamento "01=Credito CC"
	cLin += "040"       	            	                    // 014 a 016 Lay-Out do Lote
	cLin += Space(01)                      	                	// 017 a 017 Brancos
	cLin += "2"                                	            	// 018 a 018 Tipo Inscricao Empresa
	cLin += a_CposEmp[PAG_CNPJ]                       	        // 019 a 032 Cnpj Empresa
	cLin += Space(20)                                  	    	// 033 a 052 Brancos
	cLin += c_DbAgencia                                         // 053 a 057 Agencia Debitada
	cLin += Space(01)                                      		// 058 a 058 Brancos
	cLin += c_DbConta                                      		// 059 a 070 Conta Corrente Debitada
	cLin += Space(01)                                      		// 071 a 071 Brancos
	cLin += c_DbDigito                                        	// 072 a 072 Digito Conta Corrente
	cLin += a_CposEmp[PAG_NOME]                              	// 073 a 102 Nome da Empresa
	cLin += cFinPgt + Space(28)                            		// 103 a 132 Finalidades do Lote
	cLin += Space(10)                                  	    	// 133 a 142 Historico da CC Debitada
	cLin += PADR(a_CposEmp[PAG_END],   30)                		// 143 a 172 Endereco da Empresa
	cLin += '00000'		                                   	    // 173 a 177 Numero do Endereco  //TI - FWNM - 29/05/2019
	cLin += PADR(a_CposEmp[PAG_COMPL], 15)                    	// 178 a 192 Compl do Endereco
	cLin += PADR(a_CposEmp[PAG_MUN],   20)                  	// 193 a 212 Cidade do Endereco
	cLin += PADR(a_CposEmp[PAG_CEP],    8)                    	// 213 a 220 Cep do Endereco
	cLin += a_CposEmp[PAG_UF]                                 	// 221 a 222 Estado do Endereco
	cLin += Space(08)                                  	    	// 223 a 230 Brancos
	cLin += Space(10)                                  	    	// 231 a 240 Ocorrencias de Retorno
	cLin += cEol
	
	fGravaTxt()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRGPECNAB  บAutor  ณMicrosiga           บ Data ณ  05/15/19   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function fMonta3A()

	cLin := "341"                  	                        	                // 001 a 003 Codigo do Banco
	cLin += StrZero(n_QtdeLotes,4)                                             // 004 a 007 Codigo do Lote
	cLin += "3"            	                                	                // 008 a 008 Tipo do Registro
	cLin += StrZero(nSequenc,5)           	                    	            // 009 a 013 Sequencial de Registros
	cLin += "A"        	            	                    	                // 014 a 014 Segmento "A"
	cLin += "000"       	            	                    	            // 015 a 017 Tipo Movimento
	cLin += "000"       	            	                           	        // 018 a 020 Zeros
	cLin += Left(SRA->RA_BCDEPSA,3)                         		            // 021 a 023 Banco Favorecido
	cLin += "0"						                         	                // 024 a 024 Zero						\
	cLin += PADL(ALLTRIM(SUBSTR(SRA->RA_BCDEPSA,4,4)),4,'0')      	            // 025 a 028 Agencia                     \
	cLin += Space(01)		                        				            // 029 a 029 Branco                       \
	cLin += StrZero(0,6)					                                    // 030 a 035 Zeros                         |---------->		(Nota 11 - Pag. 43)
	cLin += PadL(Left(AllTrim(SRA->RA_CTDEPSA),Len(AllTrim(SRA->RA_CTDEPSA))-1),6,'0') // 036 a 041 Conta Creditada              /  //TI - FWNM - 29/05/2019
	cLin += Space(01)                       						            // 042 a 042 Branco                      /
	cLin += Right(ALLTRIM(SRA->RA_CTDEPSA),1)               	                // 043 a 043 Digito da Conta Creditada	/
	cLin += Left(SRA->RA_NOME,30)                      			                // 044 a 073 Nome do Favorecido
	cLin += Space(20)					                         	            // 074 a 093 Numero do Documento atribuido pela Empresa
	cLin += fConvData( dDataPagto, "DDMMAAAA" )               		            // 094 a 101 Data do Pagamento
	cLin += "REA"                                	            	            // 102 a 104 Tipo Moeda
	cLin += Replicate("0",15)        	                        	            // 105 a 119 Zeros
	cLin += StrZero((nLiquido*100),15,0)                        	            // 120 a 134 Valor do Pagamento
	cLin += Space(20)                       						            // 135 a 149 Nosso Numero
	cLin += Replicate("0",08)//Space(08)                      	           // 155 a 162 Data Efetivacao Pagto  //TI - FWNM - 29/05/2019
	cLin += Replicate("0",15)        	                        	            // 163 a 177 Valor Efetivo Pagamento
	cLin += Space(20)                      	                	                // 178 a 197 Finalidade Detalhe
	cLin += Replicate("0",06)//Space(06)										/ 198 a 203 Numero Documento          //TI - FWNM - 29/05/2019
	cLin += PADL(ALLTRIM(SRA->RA_CIC),14,'0') //SRA->RA_CIC+SPACE(15)       // 204 a 217 (CPF/CNPJ)               //TI - FWNM - 29/05/2019
	cLin += Space(01)                                       			        // 218 a 218 Tipo de Identifica็ใo    //TI - FWNM - 29/05/2019
	cLin += Space(11)                                       			        // 219 a 229 Complemento de Registros //TI - FWNM - 29/05/2019 
	cLin += "0"                                        			                // 230 a 230 Aviso ao Favorecido
	cLin += Space(10)                                  	        	            // 231 a 240 Ocorrencias de Retorno
	cLin += cEol
	
	aTotLote[1] ++
	aTotLote[2] += nLiquido
	
	fGravaTxt()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRGPECNAB  บAutor  ณMicrosiga           บ Data ณ  05/15/19   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function fMonta3D()

	cLin := "341"                  	                        	  // 001 a 003 Codigo do Banco
	cLin += StrZero(n_QtdeLotes,4)                                // 004 a 007 Codigo do Lote
	cLin += "3"            	                                      // 008 a 008 Tipo do Registro
	cLin += StrZero(nSequenc,5)           	                      // 009 a 013 Sequencial de Registros
	cLin += "D"        	            	                    	  // 014 a 014 Segmento "D"
	cLin += Space(03)   	            	                      // 015 a 017 Brancos
	cLin += Right(AllTrim(cPeriodo),2)+Left(AllTrim(cPeriodo),4) // 018 a 023 Mes/Ano Referencia
	cLin += Left(SRA->RA_CC+Space(15),15)                    	  // 024 a 038 CODIGO DE Centro de Custo
	cLin += Left(SRA->RA_MAT+Space(15),15)                       // 039 a 053 Matricula
	cLin += Left(SRJ->RJ_DESC+Space(30),30)                      // 054 a 083 Funcao
	cLin += fCheckFer( "INI" )                                   // 084 a 091 Periodo Ferias De
	cLin += fCheckFer( "FIM" )                               	 // 092 a 099 Periodo Ferias Ate
	cLin += StrZero(Val(SRA->RA_DEPIR),2)                        // 100 a 101 Dependentes p/ IR
	cLin += StrZero(Val(SRA->RA_DEPSF),2)                     	 // 102 a 103 Dependentes p/ SF
	cLin += StrZero(Int(SRA->RA_HRSEMAN),2)                      // 104 a 105 Horas Semanais
	cLin += StrZero((nAteLim*100),15,0)                       	 // 106 a 120 Salario de Contribuicao
	cLin += StrZero((nFgts*100),15,0)                         	 // 121 a 135 Salario de Contribuicao
	cLin += StrZero((TOTVENC*100),15,0)                       	 // 136 a 150 Total dos Proventos
	cLin += StrZero((TOTDESC*100),15,0)                       	 // 151 a 165 Total dos Descontos
	cLin += StrZero(((TOTVENC-TOTDESC)*100),15,0)             	 // 166 a 180 Liquido a Pagar
	cLin += StrZero((SRA->RA_SALARIO*100),15,0)               	 // 181 a 195 Salario Base
	cLin += StrZero((nBaseIr*100),15,0)                       	 // 196 a 210 Base do IRRF
	cLin += StrZero((nBaseFgts*100),15,0)                     	 // 211 a 225 Base do FGTS
	cLin += "00"						                         // 226 a 227 Prazo p/ Disponibilizar Holerite
	cLin += Space(03)		                        			 // 228 a 230 Brancos
	cLin += Space(10)                                  	    	 // 231 a 240 Ocorrencias de Retorno
	cLin += cEol
	
	aTotLote[1]++
	
	fGravaTxt()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRGPECNAB  บAutor  ณMicrosiga           บ Data ณ  05/15/19   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function fMonta3E( aTemp, xTipo )

	Local i, nLen
	
	// Calcula Quantidade de Proventos
	nLen := Len(aTemp)
	If nLen == 0
		Return
	EndIf
	
	// Incrementa Contador com Multiplos de 4
	Do While .T.
		If nLen % 4 == 0
			Exit
		EndIf
		
		nLen++
	EndDo
	
	// Processa Array
	For i := 1 To nLen

		If i % 4 == 1
			cLin := "341"                  	                        	// 001 a 003 Codigo do Banco
			cLin += StrZero(n_QtdeLotes,4)                              // 004 a 007 Codigo do Lote
			cLin += "3"            	                                	// 008 a 008 Tipo do Registro
			cLin += StrZero(nSequenc,5)        	                    	// 009 a 013 Sequencial de Registros
			cLin += "E"        	            	                    	// 014 a 014 Segmento "E"
			cLin += Space(03)   	           	                    	// 015 a 017 Brancos
			cLin += xTipo                                          		// 018 a 018 Tipo do Movimento
		EndIf

		If i <= Len(aTemp)
			cLin += Left(aTemp[i,1]+Space(23),23)+"-"                 // 019 a 048 Salario de Contribuicao
			cValor := Transform(aTemp[i,2],cPict2)
			cLin += cValor       									   // 049 a 053 Brancos
			cLin += Space(05)     	// 049 a 053 Brancos
			
			cLin += StrZero((aTemp[i,3]*100),15,0)                    // 054 a 068 Salario de Contribuicao
		Else
			cLin += Space(30)					                       // 019 a 048 Salario de Contribuicao
			cLin += Space(05)                          	       	       // 049 a 053 Brancos
			cLin += StrZero(0,15)					                   // 054 a 068 Salario de Contribuicao
		EndIf

		If i % 4 == 0
			cLin += Space(12)                                  	       // 219 a 230 Brancos
			cLin += Space(10)                                  	       // 231 a 240 Ocorrencias de Retorno
			cLin += cEol
			
			aTotLote[1]++
			
			fGravaTxt()
		EndIf

	Next

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRGPECNAB  บAutor  ณMicrosiga           บ Data ณ  05/15/19   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function fMonta3F()

	cLin := "341"                  	                        	// 001 a 003 Codigo do Banco
	cLin += StrZero(n_QtdeLotes,4)                             // 004 a 007 Codigo do Lote
	cLin += "3"            	                                	// 008 a 008 Tipo do Registro
	cLin += StrZero(nSequenc,5)           	                    // 009 a 013 Sequencial de Registros
	cLin += "F"        	            	                    	// 014 a 014 Segmento "F"
	cLin += Space(03)   	            	                    // 015 a 017 Brancos
	cLin += Left(DESC_MSG1+Space(48),48) 	                    // 018 a 065 Mensagem 1
	cLin += Left(DESC_MSG2+Space(48),48) 	                    // 066 a 113 Mensagem 2
	cLin += Left(DESC_MSG3+Space(48),48) 	                    // 114 a 161 Mensagem 3
	cLin += Space(69)                                  	    	// 162 a 230 Brancos
	cLin += Space(10)                                  	    	// 231 a 240 Ocorrencias de Retorno
	cLin += cEol
	
	aTotLote[1]++
	
	fGravaTxt()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRGPECNAB  บAutor  ณMicrosiga           บ Data ณ  05/15/19   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function fMonta5()

	cLin := "341"                  	                        	// 001 a 003 Codigo do Banco
	cLin += StrZero(n_QtdeLotes,4)                             // 004 a 007 Codigo do Lote
	cLin += "5"            	                                	// 008 a 008 Tipo do Registro "5"
	cLin += Space(09)                                  	    	// 009 a 017 Brancos
	cLin += StrZero(aTotLote[1]+2,6)        	                // 018 a 023 Total de Registros do Lote
	cLin += StrZero((aTotLote[2]*100),18,0)                   	// 024 a 041 Valor Total do Lote
	cLin += StrZero(0,18)               	                    // 042 a 059 Zeros
	cLin += Space(171)   	            	                    // 060 a 230 Brancos
	cLin += Space(10)                                  	    	// 231 a 240 Ocorrencias de Retorno
	cLin += cEol

	// Acumular Qtde de Registros para o Trailer do Arquivo (Reg Tipo 9)
	n_QtdRegsArq += aTotLote[1]+2
	
	fGravaTxt()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRGPECNAB  บAutor  ณMicrosiga           บ Data ณ  05/15/19   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function fMonta9()

	cLin := "341"                  	                        	// 001 a 003 Codigo do Banco
	cLin += "9999"             	                            	// 004 a 007 Codigo do Lote
	cLin += "9"            	                                	// 008 a 008 Tipo do Registro "9"
	cLin += Space(09)                                  	    	// 009 a 017 Brancos
	cLin += StrZero(n_QtdeLotes,6)                             // 018 a 023 Total de Registros do Lote
	cLin += StrZero(n_QtdRegsArq+2,6)             	            // 024 a 029 Qtde de Registros do Arquivo
	cLin += Space(211)   	            	                    // 030 a 240 Brancos
	cLin += cEol
	
	fGravaTxt()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRGPECNAB  บAutor  ณMicrosiga           บ Data ณ  05/15/19   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function fGravaTxt()

	If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
		MsgAlert("Ocorreu um erro na gravacao do arquivo. Continua?","Atencao!")
	Endif
	
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณVALIDPERG บ Autor ณ AP5 IDE            บ Data ณ  27/10/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Verifica a existencia das perguntas criando-as caso seja   บฑฑ
ฑฑบ          ณ necessario (caso nao existam).                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿ */
Static Function fAsrPerg()

	Local aArea  := GetArea() // Chamado TI - FWNM - 29/05/2019 - Correcao error log
	Local aRegs	 := {}
	Local i, j
	
	dbSelectArea("SX1")
	dbSetOrder(1)
	
	cPerg := Padr(cPerg,Len(X1_GRUPO))

	// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
	aAdd(aRegs,{ cPerg,'01','Periodo                      ?','','','mv_ch1','C',06,0,0,'G','NaoVazio'   ,'mv_par01',''                 ,'','','','',''                 ,'','','','',''                    ,'','','','',''                 ,'','','','',''        ,'','','' ,'RCH','' })
	aAdd(aRegs,{ cPerg,'02','Roteiro de cแlculo           ?','','','mv_ch2','C',03,0,0,'G',''			 ,'mv_par02','' 			     ,'','','','',''            	  ,'','','','',''          			 ,'','','','',''  				  ,'','','','',''  		 ,'','','' ,'SRY','' })
	aAdd(aRegs,{ cPerg,'03','Numero do pagamento          ?','','','mv_ch3','C',02,0,0,'G','NaoVazio'   ,'mv_par03','01'                 ,'','','','',''               ,'','','','',''                    ,'','','','',''                 ,'','','','',''        ,'','','' ,'   ','' })
	aAdd(aRegs,{ cPerg,'04','Filial De                    ?','','','mv_ch4','C',02,0,0,'G',''           ,'mv_par04',''                 ,'','','','',''                 ,'','','','',''                    ,'','','','',''                 ,'','','','',''        ,'','','' ,'SM0','' })
	aAdd(aRegs,{ cPerg,'05','Filial Ate                   ?','','','mv_ch5','C',02,0,0,'G','NaoVazio'   ,'mv_par05',''                 ,'','','','',''                 ,'','','','',''                    ,'','','','',''                 ,'','','','',''        ,'','','' ,'SM0','' })
	aAdd(aRegs,{ cPerg,'06','Centro Custo De              ?','','','mv_ch6','C',09,0,0,'G',''           ,'mv_par06',''                 ,'','','','',''                 ,'','','','',''                    ,'','','','',''                 ,'','','','',''        ,'','','' ,'CTT','' })
	aAdd(aRegs,{ cPerg,'07','Centro Custo Ate             ?','','','mv_ch7','C',09,0,0,'G','NaoVazio'   ,'mv_par07',''                 ,'','','','',''                 ,'','','','',''                    ,'','','','',''                 ,'','','','',''        ,'','','' ,'CTT','' })
	aAdd(aRegs,{ cPerg,'08','Matricula De                 ?','','','mv_ch8','C',06,0,0,'G',''           ,'mv_par08',''                 ,'','','','',''                 ,'','','','',''                    ,'','','','',''                 ,'','','','',''        ,'','','' ,'SRA','' })
	aAdd(aRegs,{ cPerg,'09','Matricula Ate                ?','','','mv_ch9','C',06,0,0,'G','NaoVazio'   ,'mv_par09',''                 ,'','','','',''                 ,'','','','',''                    ,'','','','',''                 ,'','','','',''        ,'','','' ,'SRA','' })
	aAdd(aRegs,{ cPerg,'10','Mensagem 1                   ?','','','mv_cha','C',01,0,0,'G',''           ,'mv_par10',''                 ,'','','','',''                 ,'','','','',''                    ,'','','','',''                 ,'','','','',''        ,'','','' ,'   ','' })
	aAdd(aRegs,{ cPerg,'11','Mensagem 2                   ?','','','mv_chb','C',01,0,0,'G',''           ,'mv_par11',''                 ,'','','','',''                 ,'','','','',''                    ,'','','','',''                 ,'','','','',''        ,'','','' ,'   ','' })
	aAdd(aRegs,{ cPerg,'12','Mensagem 3                   ?','','','mv_chc','C',01,0,0,'G',''           ,'mv_par12',''                 ,'','','','',''                 ,'','','','',''                    ,'','','','',''                 ,'','','','',''        ,'','','' ,'   ','' })
	aAdd(aRegs,{ cPerg,'13','Situacoes                    ?','','','mv_chd','C',05,0,0,'G','fSituacao'  ,'mv_par13',''                 ,'','','','',''                 ,'','','','',''                    ,'','','','',''                 ,'','','','',''        ,'','','' ,'   ','' })
	aAdd(aRegs,{ cPerg,'14','Categorias                   ?','','','mv_che','C',12,0,0,'G','fCategoria' ,'mv_par14',''                 ,'','','','',''                 ,'','','','',''                    ,'','','','',''                 ,'','','','',''        ,'','','' ,'   ','' })
	aAdd(aRegs,{ cPerg,'15','Arquivo de Saida             ?','','','mv_chf','C',60,0,0,'G','NaoVazio'   ,'mv_par15',''                 ,'','','','',''                 ,'','','','',''                    ,'','','','',''                 ,'','','','',''        ,'','','' ,'   ','' })
	aAdd(aRegs,{ cPerg,'16','Data do Cr้dito              ?','','','mv_chg','D',08,0,0,'G','NaoVazio'   ,'mv_par16',''                 ,'','','','',''                 ,'','','','',''                    ,'','','','',''                 ,'','','','',''        ,'','','' ,'   ','' })
	aAdd(aRegs,{ cPerg,'17','Banco/Agencia De             ?','','','mv_chh','C',08,0,0,'G',''           ,'mv_par17',''                 ,'','','','',''                 ,'','','','',''                    ,'','','','',''                 ,'','','','',''        ,'','','' ,'SA6','' })
	aAdd(aRegs,{ cPerg,'18','Banco/Agencia Ate            ?','','','mv_chi','C',08,0,0,'G','NaoVazio'   ,'mv_par18',''                 ,'','','','',''                 ,'','','','',''                    ,'','','','',''                 ,'','','','',''        ,'','','' ,'SA6','' })
	aAdd(aRegs,{ cPerg,'19','Conta Corrente De            ?','','','mv_chj','C',12,0,0,'G',''           ,'mv_par19',''                 ,'','','','',''                 ,'','','','',''                    ,'','','','',''                 ,'','','','',''        ,'','','' ,'   ','' })
	aAdd(aRegs,{ cPerg,'20','Conta Corrente Ate           ?','','','mv_chk','C',12,0,0,'G','NaoVazio'   ,'mv_par20',''                 ,'','','','',''                 ,'','','','',''                    ,'','','','',''                 ,'','','','',''        ,'','','' ,'   ','' })
	aAdd(aRegs,{ cPerg,'21','Periodo Aberto/Fechado       ?','','','mv_chl','N',01,0,0,'C','NaoVazio'   ,'mv_par21','Aberto (SRC)'     ,'','','','','Fechado (SRD)'    ,'','','','',''                    ,'','','','',''                 ,'','','','',''        ,'','','' ,'   ','' })
	aAdd(aRegs,{ cPerg,'22','Data Pagamento De            ?','','','mv_chm','D',08,0,0,'G','NaoVazio'   ,'mv_par22',''                 ,'','','','',''                 ,'','','','',''                    ,'','','','',''                 ,'','','','',''        ,'','','' ,'   ','' })
	aAdd(aRegs,{ cPerg,'23','Data Pagamento Ate           ?','','','mv_chn','D',08,0,0,'G','NaoVazio'   ,'mv_par23',''                 ,'','','','',''                 ,'','','','',''                    ,'','','','',''                 ,'','','','',''        ,'','','' ,'   ','' })
		
	For i := 1 to Len(aRegs)
		If 	!dbSeek(cPerg + aRegs[i,2])
			RecLock("SX1", .t.)
			For j := 1 to FCount()
				If j <= Len(aRegs[i])
					FieldPut(j,aRegs[i,j])
				EndIf
			Next
			MsUnlock("SX1")
		EndIf
	Next
	
	RestArea( aArea ) // Chamado TI - FWNM - 29/05/2019 - Correcao error log

Return

//=====================================================+
// RETORNA campos do SIGAMAT de acordo com a Filial    |
// Ou campo indicado.                                  |
//=====================================================+
Static Function RetSM0(c_Filial, n_Field)

	Local a_Area        := GetArea()
	Local a_Ret         := {}
	Local a_CamposSM0   := {}
	Local c_EmpCorrente := SM0->M0_CODIGO
	Local c_FilCorrente := SM0->M0_CODFIL
	Local c_EndFull     := ""
	Local c_Endereco    := ""
	Local c_Numero      := ""

	SM0->(MsSeek(c_EmpCorrente+c_Filial,.T.))

	c_EndFull   := AllTrim(SM0->M0_ENDENT)
	n_Pos       := AT(",", c_EndFull)
	
	c_Endereco  := AllTrim(SubStr(c_EndFull, 1, n_Pos-1))
	c_Numero    := AllTrim(SubStr(c_EndFull, n_Pos+1, Len(c_EndFull)-n_Pos))
	
	Aadd(a_CamposSM0, SUBSTR(SM0->M0_CGC,1,14)     )
	Aadd(a_CamposSM0, SUBSTR(SM0->M0_NOMECOM,1,30) )
	Aadd(a_CamposSM0, c_Endereco                   )
	Aadd(a_CamposSM0, c_Numero                     )
	Aadd(a_CamposSM0, AllTrim(SM0->M0_CIDENT)      )
	Aadd(a_CamposSM0, AllTrim(SM0->M0_COMPENT)     )
	Aadd(a_CamposSM0, AllTrim(SM0->M0_CEPENT)      )
	Aadd(a_CamposSM0, SM0->M0_ESTENT               )
	
	If Empty(n_Field)
		a_Ret := Aclone(a_CamposSM0)
	Else
		a_Ret := { a_CamposSM0[n_Field] }
	EndIf
	
	SM0->(MsSeek(c_EmpCorrente + c_FilCorrente))

	RestArea(a_Area)
	
RETURN(a_Ret)


//// LAYOUT DE ARQUIVO EMPRESTIMO CONSIGNADO
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ fConsh   บAutor  ณ        			 บ Data ณ  18/06/2014 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Header do Arquivo de Consiganado                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP8                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿ */
Static Function fConsH(c_DbAgencia, c_DbConta, c_DbDigito, a_CposEmp)

	Local cLin := ''
	
	cLin := "341"                  	                        		// 001 a 003 Codigo do Banco
	cLin += "0000"             	                            		// 004 a 007 Codigo do Lote
	cLin += "0"            	                                		// 008 a 008 Tipo do Registro
	cLin += Space(09)   	            	                    	// 009 a 017 Brancos
	cLin += "2"                                	            		// 018 a 018 Tipo Inscricao Empresa
	cLin += a_CposEmp[PAG_CNPJ]                    	        		// 019 a 032 Cnpj Empresa
	cLin += "200000669648"                                	    	// 033 a 044 Convenio
	cLin += "000000000"                                  	    	// 045 a 053 Zeros
	cLin += substr(c_DbAgencia,2,4)                                	// 054 a 057 Agencia Debitada
	cLin += Space(01)                                      			// 058 a 058 Brancos
	cLin += c_DbConta                                 	        	// 059 a 070 Conta Corrente Debitada
	cLin += Space(01)                                      			// 071 a 071 Brancos
	cLin += c_DbDigito                                         		// 072 a 072 Digito Conta Corrente
	cLin += a_CposEmp[PAG_NOME]                    		        	// 073 a 102 Nome da Empresa
	cLin += Padr("BANCO ITAU S/A",30)		               			// 103 a 132 Nome do Banco
	cLin += Space(10)                                  	    		// 133 a 142 Brancos
	cLin += "3"                                            			// 143 a 143 Codigo Arquivo (3)Nova Vigencia (4)Atualizacao
	cLin += fConvData( dDataBase, "DDMMAAAA" )                		// 144 a 151 Data Geracao Arquivo
	cLin += fConvHora( Time() )                             		// 152 a 157 Hora Geracao Arquivo
	cLin += "000000"	                                    		// 158 a 163 Zeros
	cLin += "000"	                                        		// 164 a 166 Layout Arquivo
	cLin += "00000"                                        			// 167 a 171 Densidade de Gravacao
	cLin += Space(28)                                  	    		// 172 a 199 Brancos
	cLin += strzero(0,9)                                  	    	// 200 a 208 Uso do Banco
	cLin += Space(22)                                  	    		// 209 a 230 Brancos
	cLin += Space(10)                                  	    		// 231 a 240 Uso do Banco
	cLin += cEol
	
	fTxtCons(cLin)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ fConsD   บAutor  ณ           		 บ Data ณ  18/06/2014 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Detalhe do Arquivo de Consiganado                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP8                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿ */
Static Function fConsD(c_DbAgencia, c_DbConta, c_DbDigito)

	Local a_CposEmp   := RetSM0("01",0)
	Local cLin := ''
	
	cLin := "341"                  	                        		// 001 a 003 Codigo do Banco
	cLin += "0001"    								               	// 004 a 007 Codigo do Lote
	cLin += "1"            	                                		// 008 a 008 Tipo do Registro
	cLin += "0000000"     	            	                 		// 009 a 015 Numero Registro
	
	If SRA->RA_SITFOLH=="D"
		cCod := '03'
	ElseIf SRA->RA_SITFOLH=="A"
		cCod := '05'
	Else
		cCod := "01"
	Endif
	
	cLin += cCod 	                     	                		// 016 a 017 Cod. Atualiza็ใo Margem
	cLin += a_CposEmp[PAG_CNPJ]                    	        		// 018 a 031 Cnpj Empresa
	cLin += "000"                       	    					// 032 a 034 DDD Funcionario
	cLin += "000000000"                       	    				// 036 a 043 Fone Funcionario
	cLin += "000000"                       	    					// 044 a 049 Cod. Unidade
	cLin += StrZero(Val(SRA->RA_CIC),11)                       	// 050 a 060 CPF Funcionario
	cLin += "000000"+SRA->RA_MAT                  	        		// 061 a 072 Matricula Func.
	
	If SRA->RA_TPCONTR == '1'
		cCargo := "04"
	Else
		cCargo := "05"
	Endif
	
	cLin += cCargo				                  	                // 073 a 074 Cargo
	cLin += "N"				                  	                	// 075 a 075 Estatutario
	cLin += Space(1)			                  	                // 076 a 076 Branco
	
	If SRA->RA_TIPOPGT == 'M'
		nHrSal := SRA->RA_SALARIO / SRA->RA_HRSMES
		nSal := (nHrSal * (SRA->RA_HRSMES * 1.20) )
		nSal := nSal * 0.20
	Else
		nSal := (SRA->RA_SALARIO * (SRA->RA_HRSMES * 1.20) )
		nSal := nSal * 0.20
	Endif
	
	cLin += StrZero(nSal*100,9)					                  	// 077 a 085 Valor Margem Liquida
	cLin += PADL(ALLTRIM(SUBSTR(SRA->RA_BCDEPSA,4,4)),4,'0')      	// 086 a 089 Agencia                     \
	cLin += Space(01)		                        			 	// 090 a 090 Branco                       \
	cLin += StrZero(0,7)					                       	// 091 a 097 Zeros                         |---------->		(Nota 11 - Pag. 43)
	cLin += PADL(SUBSTR(SRA->RA_CTDEPSA,1,5),05,'0')  	   			// 098 a 102 Conta Creditada              /
	cLin += Space(01)                       						// 103 a 103 Branco                      /
	cLin += c_DbDigito                                         		// 104 a 104 Digito Conta Corrente
	cLin += "000" 		                                        	// 105 a 107 Codigo Banco Compes.
	cLin += "00000000"	                                        	// 108 a 115 Data Ultima Contrat. com banco
	cLin += Space(26)                      	                		// 116 a 141 Uso do Banco
	cLin += "000000"	                      	                	// 142 a 147 Uso do Banco
	cLin += Space(12)	                      	                	// 148 a 159 Uso do Banco
	cLin += SUBSTR(c_DbAgencia,2,4)                               	// 160 a 163 Agencia Pagadora/Debitada
	cLin += Space(01)	                      	                	// 164 a 164 Brancos
	cLin += StrZero(0,7)					                       	// 165 a 171 Zeros
	cLin += substr(c_DbConta,8,5)                          	   		// 172 a 176 Conta Corrente Debitada
	cLin += c_DbDigito                                         		// 177 a 177 Digito Conta Corrente
	cLin += "01"							                       	// 178 a 179 Quant. de contratos
	cLin += StrZero(nLiquido*100,9)	                        		// 180 a 188 Renda Liquida
	cLin += StrZero(nSal*100,9)							           	// 189 a 197 Valor da Parcela
	cLin += Space(02)	                      	                	// 198 a 199 Brancos
	cLin += "000000000"                                  	    	// 200 a 208 Uso do Banco
	cLin += Space(10)	                      	                	// 209 a 218 Brancos
	cLin += fConvData( SRA->RA_ADMISSA, "DDMMAAAA" )           		// 219 a 226 Data Admissao func.
	cLin += Space(04)	                      	                	// 227 a 230 Uso do Banco
	cLin += Space(10)	                      	                	// 231 a 240 Uso do Banco
	cLin += cEol
	
	fTxtCons(cLin)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ fConsT   บAutor  ณ           		 บ Data ณ  18/06/2014 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Trailler do Arquivo de Consiganado                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP8                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿ */
Static Function fConsT()

	Local cLin := ''
	
	cLin := "341"                  	                        		// 001 a 003 Codigo do Banco
	cLin += "9999"             	                            		// 004 a 007 Codigo do Lote
	cLin += "9"            	                                		// 008 a 008 Tipo do Registro "9"
	cLin += Strzero(0,6)                                  	    	// 009 a 014 Zeros
	cLin += StrZero(n_RegConsD+2,7)       	                       	// 015 a 021 Total de Registros do Lote
	cLin += StrZero(n_RegConsD,7)	 	           	                // 022 a 028 Qtde de Registros do Detalhe
	cLin += Strzero(0,68)                                	    	// 029 a 096 Zeros
	cLin += Space(103)   	            	                    	// 097 a 199 Brancos
	cLin += Strzero(0,9)                                	    	// 200 a 208 Zeros
	cLin += Space(32)   	            	                    	// 209 a 240 Brancos
	cLin += cEol
	
	fTxtCons(cLin)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ fTXTCons บAutor  ณ           		 บ Data ณ  18/06/2014 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Grava TXT do Consignado                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP8                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿ */
Static Function fTxtCons(cLin)

	If fWrite(nHdl2,cLin,Len(cLin)) != Len(cLin)
		MsgAlert("Ocorreu um erro na gravacao do arquivo. Continua?","Atencao!")
	Endif
	
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRGPECNAB  บAutor  ณMicrosiga           บ Data ณ  05/22/19   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GrvZFJ()

	RecLock("ZFJ", .t.)
		ZFJ->ZFJ_FILIAL := FWxFilial("ZFJ")
		ZFJ->ZFJ_DATA   := msDate()
		ZFJ->ZFJ_HORA   := time()
		ZFJ->ZFJ_LOGIN  := __cUserID + " - " + AllTrim(UsrRetName(__cUserID))
		ZFJ->ZFJ_PARAMS := "MV_PAR01: " + MV_PAR01 + " , MV_PAR02: " + MV_PAR02 + " , MV_PAR03: " + MV_PAR03 + " , MV_PAR04: " + MV_PAR04 + " , MV_PAR05: " + MV_PAR05 + " , MV_PAR06: " + MV_PAR06 + " , MV_PAR07: " + MV_PAR07 + " , MV_PAR08: " + MV_PAR08 + " , MV_PAR09: " + MV_PAR09 + " , MV_PAR10: " + MV_PAR10 + " , MV_PAR11: " + MV_PAR11 + " , MV_PAR12: " + MV_PAR12 + " , MV_PAR13: " + MV_PAR13 + " , MV_PAR14: " + MV_PAR14 
		ZFJ->ZFJ_PARAM2 := "MV_PAR15: " + AllTrim(MV_PAR15) + " , MV_PAR16: " + DtoC(MV_PAR16) + " , MV_PAR17: " + MV_PAR17 + " , MV_PAR18: " + MV_PAR18 + " , MV_PAR19: " + MV_PAR19 + " , MV_PAR20: " + MV_PAR20 + " , MV_PAR21: " + AllTrim(Str(MV_PAR21)) + " , MV_PAR22: " + DtoC(MV_PAR22) + " , MV_PAR23: " + DtoC(MV_PAR23)
		ZFJ->ZFJ_LOG    := "Filial: " + SRA->RA_FILIAL + " , Matricula: " + SRA->RA_MAT + " , Nome: " + SRA->RA_NOME + " , C.Custo: " + SRA->RA_CC + " , Dados Bancarios: " + SRA->RA_BCDEPSA + SRA->RA_CTDEPSA
		ZFJ->ZFJ_PROVEN := TOTVENC
		ZFJ->ZFJ_DESCON := TOTDESC
		ZFJ->ZFJ_LIQUID := nLiquido
		ZFJ->ZFJ_IDSEQ  := cID
	ZFJ->( msUnLock() )

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRGPECNAB  บAutor  ณMicrosiga           บ Data ณ  05/22/19   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function UpIDZFJ()

	Local cNextID := 0
	Local cQuery  := ""
	
	If Select("WorkZFJ") > 0
		WorkZFJ->( dbCloseArea() )
	EndIf
	
	cQuery := " SELECT ISNULL(MAX(ZFJ_IDSEQ),0) AS LASTID "
	cQuery += " FROM " + RetSqlName("ZFJ") + " WITH (NOLOCK) "
	cQuery += " WHERE ZFJ_FILIAL='"+FWxFilial("ZFJ")+"' "
	cQuery += " AND D_E_L_E_T_='' "
	
	tcQuery cQuery New Alias "WorkZFJ"

	cNextID := Soma1(WorkZFJ->LASTID)

	If Select("WorkZFJ") > 0
		WorkZFJ->( dbCloseArea() )
	EndIf

Return cNextID

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao    ณ Gp020BuscaLiq ณ Autor ณ Tatiane Matias       ณ Data ณ 23/03/05 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ Busca os valores de liquido e beneficios                       ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ Gp020BuscaLiq(nValLiq,aValBenef)                               ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ nValLiq     - Valor do liquido a receber                   	  ณฑฑ
ฑฑณ          ณ aValBenef   - 1-Nome/2-Banco/3-Conta/4-Verba/5-Valor Benef 	  ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function yGp020BuscaLiq(nValLiq,aValBenef,cVerba)

	Local aCodBenef   	:= {}
	Local aCodBenefAux  := {}
	Local aChaveBusca 	:= {}
	Local aAreaSra    	:= SRA->( GetArea() )
	Local aPensPd		:= {} //{ cRoteiro, PERIODO, SEMANA, ORIGEM, DATAPAG, DTREF, PD }
	Local cVerbaBusca 
	Local cRoteiro
	Local lResArea 		:= .F.
	Local nCntP,nCntP2,nPosBenef
	Local nRoteiro   
	Local nPosFol
	Local nValVrb   := 0
	Local nValBenef := 0
	Local lRatItm   := SuperGetMv("MV_RATITM",, .F.)
	Local nx		:= 0
	Local nY		:= 0
	
	Private nLiqAux 	:= 0 // Variavel para acumular outros valores de liquidos para utilizacao no Ponto de Entrada.
	Private	cTipoRot	:= ""	
	
	If Empty(cAcessaSRC)
		cAcessaSRC	:= &( " { || " + ChkRH( "GPER020" , "SRC" , "2" ) + " } " )
	EndIf

	If Empty(cAcessaSRD)
		cAcessaSRD	:= &( " { || " + ChkRH( "GPER020" , "SRD" , "2" ) + " } " )
	EndIf
	
	If Empty(cAcessaSRR)
		cAcessaSRR	:= &( " { || " + ChkRH( "GPER020" , "SRR" , "2" ) + " } " )
	EndIf
	
	If Empty(cAcessaSRG)
		cAcessaSRG	:= &( " { || " + ChkRH( "GPER020" , "SRG" , "2" ) + " } " )
	EndIf
	
	If Empty(cAcessaSRH)
		cAcessaSRH	:= &( " { || " + ChkRH( "GPER020" , "SRH" , "2" ) + " } " )  
	EndIf
	
	lImprFunci := .T.
	lImprBenef := .T.
	cVerba := ""

	For nRoteiro := 1 to Len(aRoteiros)
	
		cRoteiro 	:= aRoteiros[nRoteiro, 1]
		cTipoRot 	:= aRoteiros[nRoteiro, 2]
		cVerbaBusca := If(Empty(cVerba),aRoteiros[nRoteiro, 3],cVerba)	
	
		// Busca liquido e beneficios das Ferias			   			 
		If cTipoRot == "3"		
			dbSelectArea( "SRH" )
			SRH->(dbSetOrder( 3 )) 
			If lImprFunci // Busca Liquido
				If dbSeek( SRA->RA_FILIAL + SRA->RA_MAT + cRoteiro ) .And. Eval(cAcessaSRH)
					While !Eof() .And. Alltrim(SRA->RA_FILIAL + SRA->RA_MAT + cRoteiro) = Alltrim(SRH->RH_FILIAL + SRH->RH_MAT + SRH->RH_ROTEIR)
						If (SRH->RH_DTRECIB >= dDataDe .And. SRH->RH_DTRECIB <= dDataAte ) 
							dDtBusFer := SRH->RH_DATAINI
							dbSelectArea( "SRR" )
							dbSetOrder( 3 )
							If dbSeek( SRA->RA_FILIAL + SRA->RA_MAT + "F" + DTOS(dDtBusFer) + cVerbaBusca + cRoteiro )
								nValLiq += SRR->RR_VALOR
								If !Empty(cVerba)
									nValVrb += SRR->RR_VALOR
								EndIf
								
								If ( FunName() == "GPEM650" ) .AND. lRatItm //se geracao de titulo e rateio por Item
									fRatPensao(RetSqlName("SRR"), "RR_", SRR->RR_PD, dDataDe, dDataAte, SRA->RA_FILIAL, SRA->RA_MAT)
								EndIf
							EndIf
						EndIf
						dbSelectArea("SRH")
						dbSkip()
					Enddo
				EndIf
			EndIf
			
			If lImprBenef // Busca beneficios
				aRot:= {"131","132","FER"}
				For nx:= 1 to Len (aRot)
					cRoteiro:= aRot[nx]
					fBusCadBenef(@aCodBenefAux,cRoteiro,, .T.)
					For nY:= 1 to Len(aCodBenefAux)
						If !Empty(aCodBenefAux[nY])
							Aadd(aCodBenef,aCodBenefAux[nY])
						Endif
					Next nY
				Next 
				
				If dbSeek( SRA->RA_FILIAL + SRA->RA_MAT + cRoteiro ) .And. Eval(cAcessaSRH)
					While !Eof() .And. Alltrim(SRA->RA_FILIAL + SRA->RA_MAT + cRoteiro) = Alltrim(SRH->RH_FILIAL + SRH->RH_MAT + SRH->RH_ROTEIR)
						If (SRH->RH_DTRECIB >= dDataDe .And. SRH->RH_DTRECIB <= dDataAte )
							dDtBusFer := SRH->RH_DATAINI
							dbSelectArea( "SRR" )
							dbSetOrder( 3 )
							For nCntP := 1 To Len(aCodBenef)
								If dbSeek( SRA->RA_FILIAL + SRA->RA_MAT + "F" + DTOS(dDtBusFer) + aCodBenef[nCntP,1] + cRoteiro )
									nPosBenef := Ascan( aValBenef, { |x| x[2]+x[3] == aCodBenef[nCntP,10]+aCodBenef[nCntP,11]+aCodBenef[nCntP,12]+aCodBenef[nCntP,01] } )
									If nPosBenef == 0
										Aadd(aValBenef, {  aCodBenef[nCntP,09],  aCodBenef[nCntP,10], aCodBenef[nCntP,11], SRR->RR_PD, SRR->RR_VALOR,aCodBenef[nCntP,12],aCodBenef[nCntP,19],"SRQ", If(Len(aCodBenef[nCntP]) >= 22, aCodBenef[nCntP,22], ""),aCodBenef[nCntP,23],aCodBenef[nCntP,24] } ) 
									Else
										aValBenef[nPosBenef,5] += SRR->RR_VALOR
									EndIf
									
									If ( FunName() == "GPEM650" ) .AND. lRatItm //se geracao de titulo e rateio por Item
										fRatPensao(RetSqlName("SRR"), "RR_", SRR->RR_PD, dDataDe, dDataAte, SRA->RA_FILIAL, SRA->RA_MAT)
									EndIf
									
									If Empty(aPensPd) .Or. aScan(aPensPd, { |x| x[1] == cRoteiro .And. x[2] == SRR->RR_PERIODO .And. x[3] == SRR->RR_SEMANA .And. x[4] == SRR->RR_TIPO3 .And. x[5] == SRR->RR_DATAPAG .And. x[6] == SRR->RR_DTREF .And. x[7] == SRR->RR_PD } ) == 0
										Aadd(aPensPd, { cRoteiro, SRR->RR_PERIODO, SRR->RR_SEMANA, SRR->RR_TIPO3, SRR->RR_DATAPAG, SRR->RR_DTREF, SRR->RR_PD } )
									Endif
								EndIf
							Next nCntP
						EndIf
						dbSelectArea("SRH")
						dbSkip()
					Enddo
				EndIf
			EndIf							 
		
		ElseIf cTipoRot $ "4*A" // Busca liquido e beneficios da Rescisao	
			// Verifica Todos os Registros do Funcionario no "SRG"          
			dbSelectArea("SRG")                                                       
			dbSetOrder( 2 )
			If dbSeek( SRA->RA_FILIAL + SRA->RA_MAT + cRoteiro) .And. Eval(cAcessaSRG)
				aChaveBusca := {}
				While !Eof() .And. ( AllTrim(SRA->RA_FILIAL + SRA->RA_MAT + cRoteiro) ) == ( AllTrim(SRG->RG_FILIAL + SRG->RG_MAT + SRG->RG_ROTEIR) )
					If SRG->RG_DATAHOM >= dDataDe .And. SRG->RG_DATAHOM <= dDataAte
						Aadd(aChaveBusca, SRG->RG_FILIAL + SRG->RG_MAT + "R" + DTOS(SRG->RG_DTGERAR))
					EndIf
					dbSkip()
				Enddo
				
				// Verifica Qual Registro Deve Buscar no "SRR"                  
				nBusca := If( Len(aChaveBusca) == 1, 1, Len(aChaveBusca) )
				If nBusca > 0
					If lImprFunci // Busca Liquido
						dbSelectArea( "SRR" )
							
						If dbSeek( aChaveBusca[nBusca] + cVerbaBusca )
							nValLiq += SRR->RR_VALOR
						EndIf
					EndIf
					
					//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
					//ณ Busca os beneficios definidos no cadastro beneficiarios		 ณ
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
					nValBenef := 0
					If lImprBenef // Busca beneficios 
						fBusCadBenef(@aCodBenef, cRoteiro,,.T.)
						
						For nCntP := 1 To Len(aCodBenef)
							cCodPdBenef		:= aCodBenef[nCntP, 16 ] //-- Todas as verbas dos beneficiarios
							//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
							//ณ Busca todas a verbas de pensao da rescisao              	 ณ
							//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
							For nCntP2:= 1 To Len(cCodPdBenef) Step 6
								
								cCodVerba	:= substr(cCodPdBenef,nCntP2+3,3)
								dbSelectArea( "SRR" )
								
								If dbSeek( aChaveBusca[nBusca] + cCodVerba ) .And. Eval(cAcessaSRR)
									nValBenef	+= SRR->RR_VALOR
									
									If Empty(aPensPd) .Or. aScan(aPensPd, { |x| x[1] == cRoteiro .And. x[2] == SRR->RR_PERIODO .And. x[3] == SRR->RR_SEMANA .And. x[4] == SRR->RR_TIPO3 .And. x[5] == SRR->RR_DATAPAG .And. x[6] == SRR->RR_DTREF .And. x[7] == SRR->RR_PD } ) == 0
										Aadd(aPensPd, { cRoteiro, SRR->RR_PERIODO, SRR->RR_SEMANA, SRR->RR_TIPO3, SRR->RR_DATAPAG, SRR->RR_DTREF, SRR->RR_PD } )
									Endif
								EndIf
							Next nPd
							
							nPosBenef := Ascan( aValBenef, { |x| x[2] + x[3] + x[4] == aCodBenef[nCntP,10] + aCodBenef[nCntP,11] + aCodBenef[nCntP,01] } )
							
							If nPosBenef == 0
								Aadd(aValBenef, {  aCodBenef[nCntP,09],  aCodBenef[nCntP,10], aCodBenef[nCntP,11], SRR->RR_PD, nValBenef ,aCodBenef[nCntP,12],aCodBenef[nCntP,19],"SRQ",If(Len(aCodBenef[nCntP]) >= 22, aCodBenef[nCntP,22], ""),aCodBenef[nCntP,23],aCodBenef[nCntP,24]} ) 
							Else
								aValBenef[nPosBenef,5]	+= 	nValBenef
							EndIf
							
							If ( FunName() == "GPEM650" ) .AND. lRatItm //se geracao de titulo e rateio por Item
								fRatPensao(RetSqlName("SRR"), "RR_", SRR->RR_PD, dDataDe, dDataAte, SRA->RA_FILIAL, SRA->RA_MAT)
							EndIf
							
							nValBenef		:= 0
			
						Next nCntP
						
						dbSelectArea("SRG")
					EndIf				
				EndIf
			EndIf
		
		Else
			// Movimento Aberto
			dbSelectArea( "SRC" )
			dbSetOrder( 8 )
			If lImprFunci // Busca Liquido
				If SRC->(dbSeek(SRA->RA_FILIAL + SRA->RA_MAT + cVerbaBusca + cRoteiro))  .And. Eval(cAcessaSRC)
					While !Eof() .And. ( Alltrim(SRA->RA_FILIAL + SRA->RA_MAT + cVerbaBusca + cRoteiro) = ;
						AllTrim(SRC->RC_FILIAL + SRC->RC_MAT + SRC->RC_PD + SRC->RC_ROTEIR) )
						If SRC->RC_DATA >= dDataDe .And. SRC->RC_DATA <= dDataAte
							nValLiq += SRC->RC_VALOR
							If !Empty(cVerba)
								nValVrb += SRC->RC_VALOR
							EndIf
							
							If ( FunName() == "GPEM650" ) .AND. lRatItm //se geracao de titulo e rateio por Item
								fRatPensao(RetSqlName("SRC"), "RC_", SRC->RC_PD, dDataDe, dDataAte, SRA->RA_FILIAL, SRA->RA_MAT)
							EndIf
						EndIf
						dbSkip()
					EndDo
				EndIf
			EndIf

			If lImprBenef // Busca beneficios
				fBusCadBenef(@aCodBenef, cRoteiro,,.T.) 
				If cTipoRot $ "1/2/5/6/F"  // FOL/ADI/131/132/PLR (Roteiros que tem pensao)
					For nCntP := 1 To Len(aCodBenef)
						For nCntP2 := 1 To 3
							nPosVb := If( nCntP2 == 1, 1,If( nCntP2 == 2, 8, 7 ) ) // 1-Pensao Folha   2-Pensao PLR 3-Pensao Dif.13sal.
							If dbSeek(SRA->RA_FILIAL + SRA->RA_MAT + aCodBenef[nCntP,nPosVb] + cRoteiro) .And. Eval(cAcessaSRC)
								While !Eof() .And. ( Alltrim(SRA->RA_FILIAL + SRA->RA_MAT + aCodBenef[nCntP,nPosVb] + cRoteiro) = ;
									Alltrim(SRC->RC_FILIAL + SRC->RC_MAT + SRC->RC_PD + SRC->RC_ROTEIR) )
									If (SRC->RC_DATA >= dDataDe .And. SRC->RC_DATA <= dDataAte) .And.;
									   PosSrv(SRC->RC_PD,SRC->RC_FILIAL,"RV_TIPOCOD") == "2"
									   
									   	If Empty(aPensPd) .Or. SRC->RC_TIPO2 # "G" .Or. aScan(aPensPd, { |x| x[2] == SRC->RC_PERIODO .And. x[3] == SRC->RC_SEMANA .And. x[5] == SRC->RC_DATA .And. x[7] == SRC->RC_PD }) == 0
											
											nPosBenef := Ascan( aValBenef, { |x| x[2]+x[3] == aCodBenef[nCntP,10]+aCodBenef[nCntP,11]+aCodBenef[nCntP,12]+aCodBenef[nCntP,01] } )
											If nPosBenef == 0
												Aadd(aValBenef, {  aCodBenef[nCntP,09],  aCodBenef[nCntP,10], aCodBenef[nCntP,11], SRC->RC_PD, SRC->RC_VALOR,aCodBenef[nCntP,12],aCodBenef[nCntP,19],"SRQ", If(Len(aCodBenef[nCntP]) >= 22, aCodBenef[nCntP,22], ""),aCodBenef[nCntP,23],aCodBenef[nCntP,24]  } ) 					
											Else
												aValBenef[nPosBenef,5] += SRC->RC_VALOR
											EndIf
											
											If ( FunName() == "GPEM650" ) .AND. lRatItm //se geracao de titulo e rateio por Item
												fRatPensao(RetSqlName("SRC"), "RC_", SRC->RC_PD, dDataDe, dDataAte, SRA->RA_FILIAL, SRA->RA_MAT)
											EndIf
										EndIf
									EndIf
									dbSkip()
								EndDo
							EndIf
						Next nCntP2
					Next nCntP 
				Else  
					For nCntP := 1 To Len(aCodBenef)
						If dbSeek(SRA->RA_FILIAL + SRA->RA_MAT + aCodBenef[nCntP,1] + cRoteiro) .And. Eval(cAcessaSRC)
							While !Eof() .And. ( Alltrim(SRA->RA_FILIAL + SRA->RA_MAT + aCodBenef[nCntP,1] + cRoteiro) = ;
								Alltrim(SRC->RC_FILIAL + SRC->RC_MAT + SRC->RC_PD + SRC->RC_ROTEIR) )
								If (SRC->RC_DATA >= dDataDe .And. SRC->RC_DATA <= dDataAte) .And.;
								    PosSrv(SRC->RC_PD,SRC->RC_FILIAL,"RV_TIPOCOD") == "2"
									
									If Empty(aPensPd) .Or. SRC->RC_TIPO2 # "G" .Or. aScan(aPensPd, { |x| x[2] == SRC->RC_PERIODO .And. x[3] == SRC->RC_SEMANA .And. x[5] == SRC->RC_DATA .And. x[7] == SRC->RC_PD }) == 0	
										nPosBenef := Ascan( aValBenef, { |x| x[2]+x[3] == aCodBenef[nCntP,10]+aCodBenef[nCntP,11]+aCodBenef[nCntp,12]+aCodBenef[nCntp,01]  } ) 
										If nPosBenef == 0
											Aadd(aValBenef, {  aCodBenef[nCntP,09],  aCodBenef[nCntP,10], aCodBenef[nCntP,11], SRC->RC_PD, SRC->RC_VALOR,aCodBenef[nCntP,12],aCodBenef[nCntP,19],"SRQ", If(Len(aCodBenef[nCntP]) >= 22, aCodBenef[nCntP,22], "") } ) 
										Else
											aValBenef[nPosBenef,5] += SRC->RC_VALOR
										EndIf
										
										If ( FunName() == "GPEM650" ) .AND. lRatItm //se geracao de titulo e rateio por Item
											fRatPensao(RetSqlName("SRC"), "RC_", SRC->RC_PD, dDataDe, dDataAte, SRA->RA_FILIAL, SRA->RA_MAT)
										EndIf
									EndIf
								Endif
								dbSkip()
							EndDo
						Endif
						lResArea := .T.
					Next nCntP
				EndIf
			EndIf
	
			// Movimento Fechado  
			dbSelectArea( "SRD" )
			dbSetOrder( 6 )
			If lImprFunci // Busca Liquido
				If dbSeek(SRA->RA_FILIAL + SRA->RA_MAT + cVerbaBusca + cRoteiro) .And. Eval(cAcessaSRD)
					While !Eof() .And. ( Alltrim(SRA->RA_FILIAL + SRA->RA_MAT + cVerbaBusca + cRoteiro) = ;
						Alltrim(SRD->RD_FILIAL + SRD->RD_MAT + SRD->RD_PD + SRD->RD_ROTEIR) )
						If SRD->RD_DATPGT >= dDataDe .And. SRD->RD_DATPGT <= dDataAte
							nValLiq += SRD->RD_VALOR
							If !Empty(cVerba)
								nValVrb += SRD->RD_VALOR
							EndIf
							
							If ( FunName() == "GPEM650" ) .AND. lRatItm //se geracao de titulo e rateio por Item
								fRatPensao(RetSqlName("SRD"), "RD_", SRD->RD_PD, dDataDe, dDataAte, SRA->RA_FILIAL, SRA->RA_MAT)
							EndIf
						EndIf
						dbSkip()
					EndDo
				EndIf
			EndIf
			
			If lImprBenef // Busca beneficios
				fBusCadBenef(@aCodBenef,cRoteiro,, .T.) //"FOL"
				For nCntP := 1 To Len(aCodBenef)
					For nCntP2 := 1 To 3
						nPosVb := If( nCntP2 == 1, 1,If( nCntP2 == 2, 8, 7 ) ) // 1-Pensao Folha   2-Pensao PLR 3-Pensao Dif.13sal.
						dbSelectArea( "SRD" )
						dbSetOrder( 6 )
						If dbSeek(SRA->RA_FILIAL + SRA->RA_MAT + aCodBenef[nCntP,nPosVb] + cRoteiro) .And. Eval(cAcessaSRD)
							While !Eof() .And. ( Alltrim(SRA->RA_FILIAL + SRA->RA_MAT + aCodBenef[nCntP,nPosVb] + cRoteiro) = ;
								Alltrim(SRD->RD_FILIAL + SRD->RD_MAT + SRD->RD_PD + SRD->RD_ROTEIR) )
								If (SRD->RD_DATPGT >= dDataDe .And. SRD->RD_DATPGT <= dDataAte) .And.;
								   PosSrv(SRD->RD_PD,SRD->RD_FILIAL,"RV_TIPOCOD") == "2"
									
									If Empty(aPensPd) .Or. SRD->RD_TIPO2 # "G" .Or. aScan(aPensPd, { |x| x[2] == SRD->RD_PERIODO .And. x[3] == SRD->RD_SEMANA .And. x[5] == SRD->RD_DATPGT .And. x[7] == SRD->RD_PD }) == 0
										
										nPosBenef := Ascan( aValBenef, { |x| x[2]+x[3] == aCodBenef[nCntP,10]+aCodBenef[nCntP,11]+aCodBenef[nCntP,12]+aCodBenef[nCntP,01] } )
										If nPosBenef == 0
											Aadd(aValBenef, {  aCodBenef[nCntP,09],  aCodBenef[nCntP,10], aCodBenef[nCntP,11], SRD->RD_PD, SRD->RD_VALOR,aCodBenef[nCntP,12],aCodBenef[nCntP,19],"SRQ", If(Len(aCodBenef[nCntP]) >= 22, aCodBenef[nCntP,22], ""),aCodBenef[nCntP,23],aCodBenef[nCntP,24] } ) 
										Else
											aValBenef[nPosBenef,5] += SRD->RD_VALOR
										EndIf
										
										If ( FunName() == "GPEM650" ) .AND. lRatItm //se geracao de titulo e rateio por Item
											fRatPensao(RetSqlName("SRD"), "RD_", SRD->RD_PD, dDataDe, dDataAte, SRA->RA_FILIAL, SRA->RA_MAT)
										EndIf
									EndIf
								EndIf
								dbSkip()
							EndDo
						EndIf
					Next nCntP2
				Next nCntP
			EndIf              
		EndIf
		
	Next nRoteiro      
	
	If nValVrb > 0
		nValLiq := nValVrb
	EndIf

Return( Nil )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณADSIG009P บAutor  ณMicrosiga           บ Data ณ  11/05/18   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function RelGPE049()

	Private cAliasTRB   := ""
	Private cDescrRel	:= "Impressใo dos registros processados na gera็ใo do arquivo CNAB Folha Ita๚ " + " - " + cID
	
	oReport := ReportDef(@cAliasTRB)
	oReport:oPage:lPageTotal := .t.
	oReport:PrintDialog()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณADSIG009P บAutor  ณMicrosiga           บ Data ณ  11/05/18   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function ReportDef(cAliasTRB)

	Local oReport
	Local oProjeto
	Local aOrdem := {}
	  
	Local oBreak1
	Local oBreak2
	Local oFunc1
	Local oFunc2
	
	 // Chamado TI - FWNM - 29/05/2019 - Correcao error log
	Local cRotina := "CNABFOLITAU" 
	Local cTitulo := "[ ADGPE049P ] - CNAB Folha Ita๚ com Holerite"
	//
	
	cAliasTRB := "QRY"
	
	oReport := TReport():New(cRotina,OemToAnsi(cDescrRel), cPerg, ;
	{|oReport| ReportPrint(cAliasTRB)},;
	OemToAnsi(" ")+cEol+;
	OemToAnsi("")+cEol+;
	OemToAnsi("") )
	
	
	oReport:SetLandscape() // sugere formato paisagem
	//oReport:nFontBody := 9.5
	//oReport:lBold := .T.

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Definicao do relatorio															  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	oProjeto := TRSection():New(oReport, OemToAnsi(cTitulo),{"QRY"}, aOrdem /*{}*/, .F., .F.)
		
	TRCell():New(oProjeto,"ZFJ_IDSEQ" ,"",""    /*Titulo*/,/*Picture*/    ,1 /*Tamanho*/,/*lPixel*/,/*{|| QRY->ZS5_TABELA }*/)
	TRCell():New(oProjeto,"ZFJ_LOG"   ,"","Funcionแrio"    /*Titulo*/,/*Picture*/    ,150 /*Tamanho*/,/*lPixel*/,/*{|| QRY->ZS5_TABELA }*/)
	TRCell():New(oProjeto,"ZFJ_PROVEN","","Proventos"      /*Titulo*/,"@E 999,999.99",15 /*Tamanho*/,/*lPixel*/,/*{|| QRY->ZS5_QTDORI }*/)
	TRCell():New(oProjeto,"ZFJ_DESCON","","Descontos"      /*Titulo*/,"@E 999,999.99",15 /*Tamanho*/,/*lPixel*/,/*{|| QRY->ZS5_QTDORI }*/)
	TRCell():New(oProjeto,"ZFJ_LIQUID","","Lํquido"       /*Titulo*/ ,"@E 999,999.99",15 /*Tamanho*/,/*lPixel*/,/*{|| QRY->ZS5_QTDORI }*/)

	DEFINE BREAK oBreak2 OF oProjeto When {|| QRY->ZFJ_IDSEQ } TOTAL IN LINE // para pular linha a cada tabela

	oBreak1 := TRBreak():New(oProjeto,oProjeto:Cell("ZFJ_IDSEQ"),"S",.F.)
	oBreak1:SetTitle('Total Geral')

	TRFunction():New(oProjeto:Cell("ZFJ_PROVEN"),NIL,"SUM",oBreak1,"","@E 999,999,999.99",/*uFormula*/,.F.,.F.)
	TRFunction():New(oProjeto:Cell("ZFJ_DESCON"),NIL,"SUM",oBreak1,"","@E 999,999,999.99",/*uFormula*/,.F.,.F.)
	TRFunction():New(oProjeto:Cell("ZFJ_LIQUID"),NIL,"SUM",oBreak1,"","@E 999,999,999.99",/*uFormula*/,.F.,.F.)

Return (oReport) 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณADSIG009P บAutor  ณMicrosiga           บ Data ณ  11/05/18   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function ReportPrint(cAliasTRB)

	Local cQuery    := ""
	Local oProjeto  := oReport:Section(1)

	MakeSqlExpr(cPerg)

	If Select("QRY") > 0
		QRY->( dbCloseArea() )
	EndIf

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Inicia Query 																	  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	cQuery := " SELECT * "
	cQuery += " FROM " + RetSqlName("ZFJ") + " WITH (NOLOCK) "
	cQuery += " WHERE ZFJ_FILIAL = '"+FWxFilial("ZFJ")+"' "
	cQuery += " AND ZFJ_IDSEQ = '"+cID+"' "
	cQuery += " AND D_E_L_E_T_ = '' "
	cQuery += " ORDER BY ZFJ_LOG "
	
	TcQuery cQuery New Alias "QRY"
	
	QRY->( dbGoTop() )
	aEval( ( "ZFJ" )->( dbStruct() ) ,{ |x| If( x[2] != "C" , tcSetField( ( "QRY" ) , AllTrim( x[1] ), x[2] , x[3] , x[4] ) , Nil ) } )
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Salva Query																		  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	
	dbSelectArea("QRY")
	
	QRY->( dbGoTop() )
	Do While QRY->( !EOF() )
		
		oReport:SetMeter(QRY->(LastRec()))
		
		oProjeto:Init()
		
		If oReport:Cancel()
			oReport:PrintText(OemToAnsi("Cancelado"))
			Exit
		EndIf
		
		//impressao propriamente dita....
		oProjeto:Cell("ZFJ_IDSEQ")	  :SetBlock( {|| "" } )
		oProjeto:Cell("ZFJ_LOG")	  :SetBlock( {|| QRY->ZFJ_LOG } )
		oProjeto:Cell("ZFJ_PROVEN")	  :SetBlock( {|| QRY->ZFJ_PROVEN } )
		oProjeto:Cell("ZFJ_DESCON")	  :SetBlock( {|| QRY->ZFJ_DESCON } )
		oProjeto:Cell("ZFJ_LIQUID")	  :SetBlock( {|| QRY->ZFJ_LIQUID } )
	
		oProjeto:PrintLine()
		oReport:IncMeter()
		
		QRY->( dbSkip() )
	
	Enddo
	
	oProjeto:Finish()
	
	QRY->( dbCloseArea() )

Return