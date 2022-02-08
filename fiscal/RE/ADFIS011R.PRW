#INCLUDE "RFIN865.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "fwcommand.ch"

#DEFINE N_VALSEST		1
#DEFINE N_VALIRRF		2
#DEFINE N_VALISS 		3
#DEFINE N_VALINSS		4
#DEFINE N_VALPIS 		5
#DEFINE N_VALCOF 		6
#DEFINE N_VALCSLL		7

Static lIsIssBx := FindFunction("IsIssBx")

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ ADFIS011	³ Autor ³ Mauricio - MDS TEC    ³ Data ³ 04.01.17 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Customizacao relatorio padrao FINR865 trazendo os titulos  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³ dos impostos com suas datas de vencimento e nao somente ti-³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ tulo pai como o padrao faz.   							  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function ADFIS011()

Local oReport                              
Local aArea	:= GetArea()
Local cPerg := PadR( "FIS011", Len( SX1->X1_GRUPO ) )

AjustaSX1(cPerg)

Return U_RFIN865R3() 

RestArea(aArea)  

U_ADINF009P('ADFIS011R' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Customizacao relatorio padrao FINR865 trazendo os titulos')

Return


/*
---------------------------------------------- Release 3 ---------------------------------------------------------
*/

User Function RFIN865R3()

Local cDesc1    := STR0001 //"Imprime a relacao dos titulos a pagar que sofreram retencao de Impostos"
Local cDesc2    := ""
Local cDesc3    := ""
Local wnrel
Local cString   := "SE2" //Contas a Pagar
Local nRegEmp   := SM0->(RecNo())
Local aTam	    := TAMSX3("E2_NUM")
Local aCodRet	:= {}	// Codigos de retencao selecionados para filtro
Local lOk		:= .T.

Private titulo  := ""
Private cabec1  := ""
Private cabec2  := ""
Private aLinha  := {}
Private aReturn := { STR0002, 1,STR0003, 1, 2, 1, "",1 }   //"Zebrado"###"Administracao"
Private aOrd    := {STR0004,STR0005} //"Por Codigo Fornecedor"###"Por Nome Fornecedor"
Private cPerg	 := "FIS011"
Private nJuros  := 0
Private nLastKey:= 0
Private nomeprog:= "ADFIS011"
Private tamanho := "G"
Private lSest   := SE2->(FieldPos("E2_SEST"))	> 0  //Verifica campo de SEST                                        

U_ADINF009P('ADFIS011R' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Customizacao relatorio padrao FINR865 trazendo os titulos')

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SetKey (VK_F12,{|a,b| AcessaPerg("FIN865",.T.)})
			
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros ³
//³ mv_par01		 // Data de?   	     ³
//³ mv_par02		 // Data ate?          ³
//³ mv_par03		 // Organiza por?      ³
//³ mv_par04		 // Enviados?          ³
//³ mv_par05		 // De Emissao?	     ³
//³ mv_par06		 // Ate Emissao?       ³
//³ mv_par07		 // De Vencto?		     ³
//³ mv_par08		 // Ate Vencto?        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Pergunte("FIS011",.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Defini‡„o dos cabe‡alhos ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
titulo := STR0007 //"Relacao de Titulos a Pagar com retencao de Impostos"
cabec1 := STR0008 //"Codigo         Nome do Fornecedor             CGC"
If lSest  // So processa se existir o campo E2_SEST
	cabec2 := STR0009 //"     Prf Numero      Pc  Tipo  Dt.Emissao Dt.Vencto  Valor Original           Valor SEST         Valor IRFF           Valor ISS          Valor INSS           Valor PIS        Valor COFINS          Valor CSLL       Valor Liquido"
Else
	cabec2 := STR0010 //"     Prf Numero      Pc  Tipo  Dt Emissao Dt.Vencto  Valor Original                              Valor IRFF           Valor ISS          Valor INSS           Valor PIS        Valor COFINS          Valor CSLL       Valor Liquido"
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros	³
//³ mv_par01		 // Do Cliente			³
//³ mv_par02		 // Ate o Cliente		³
//³ mv_par03		 // Da loja				³
//³ mv_par04		 // Ate a loja			³
//³ mv_par05		 // Da DaTa				³
//³ mv_par06		 // Ate Data			³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a fun‡„o SETPRINT ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
wnrel := "ADFIS011"            //Nome Default do relatorio em Disco
wnrel := SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.T.,Tamanho,"",.T.)
If nLastKey == 27
	Return
Endif
SetDefault(aReturn,cString)
If nLastKey == 27
	Return
Endif
// Indica se deve realizar filtro de codigos de retencao
If mv_par09 == 1	// Sim
	lOk := FR865CodRet( @aCodRet )
EndIf	
If lOk
	RptStatus({|lEnd| FA865Imp(@lEnd,wnRel,cString,aCodRet)},titulo)  // Chamada do Relatorio
EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	  ³ FA865Imp ³ Autor ³ Nilton Pereira        ³ Data ³ 24.03.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o  ³ Imprime relat¢rio dos T¡tulos a Receber c/Retencao de INSS ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e  ³ FA865Imp(lEnd,WnRel,cString)						       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ lEnd	  - A‡Æo do Codeblock							   ³±±
±±³			  ³ wnRel   - T¡tulo do relat¢rio							   ³±±
±±³			  ³ cString - Mensagem										   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		  ³ Generico												   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FA865Imp(lEnd,WnRel,cString,aCodRet)

Local CbCont
Local CbTxt
Local cCGCAnt
Local cChaveSe2
Local lContinua		:= .T.
Local nTitCli		:= 0
Local nTitRel		:= 0
Local nVlCliOri		:= 0
Local nVlCliIns		:= 0
Local nVlCliLiq		:= 0
Local nVlTotOri		:= 0
Local nVlTotIns		:= 0
Local nVlTotPis		:= 0
Local nVlTotCof		:= 0
Local nVlTotCsl		:= 0
Local nVlTotIrf		:= 0 
Local nVlCliIrf		:= 0
Local nVlTotIss		:= 0 
Local nVlCliIss		:= 0
Local nVlTotSes		:= 0 
Local nVlCliSes		:= 0
Local nVlCliPis		:= 0
Local nVlCliCof		:= 0
Local nVlCliCsl		:= 0
Local nVlTotLiq		:= 0
Local nVlFilOri 	:= 0
Local nVlFilLiq 	:= 0
Local nVlFilIns 	:= 0
Local nVlFilPis 	:= 0
Local nVlFilCof 	:= 0
Local nVlFilCsl 	:= 0
Local nVlFilIrf 	:= 0
Local nVlFilIss 	:= 0
Local nVlFilSes 	:= 0
Local nTitFil		:= 0
Local nRegSM0		:= 0
Local aCampos		:= {}                                   
Local cCodFor		:= ""
Local cLojFor		:= ""
Local cNomFor		:= ""                       
Local aTamNum		:= TAMSX3("E2_NUM")
Local nOrdem		:= aReturn[8]   
Local nValBase		:= 0
Local nValLiq		:= 0
Local lFatura		:= .F.
Local lContrRet 	:= !Empty( SE2->( FieldPos( "E2_VRETPIS" ) ) ) .And. !Empty( SE2->( FieldPos( "E2_VRETCOF" ) ) ) .And. ; 
				 		!Empty( SE2->( FieldPos( "E2_VRETCSL" ) ) ) .And. !Empty( SE2->( FieldPos( "E2_PRETPIS" ) ) ) .And. ;
				 		!Empty( SE2->( FieldPos( "E2_PRETCOF" ) ) ) .And. !Empty( SE2->( FieldPos( "E2_PRETCSL" ) ) )

Local lConsFil		:= ( mv_par11 == 1 )	// Considera Filiais
Local cTipoForn		:= Iif( mv_par10 == 1, "F", Iif( mv_par10 == 2, "J", "" ) )	// Tipo de Fornecedor

#IFNDEF TOP
	Local nIndexSE2
	Local cIndexSe2
#ENDIF

Local lPCCBaixa 	:= SuperGetMv("MV_BX10925",.T.,"2") == "1"  .and. (!Empty( SE5->( FieldPos( "E5_VRETPIS" ) ) ) .And. !Empty( SE5->( FieldPos( "E5_VRETCOF" ) ) ) .And. ; 
				 		!Empty( SE5->( FieldPos( "E5_VRETCSL" ) ) ) .And. !Empty( SE5->( FieldPos( "E5_PRETPIS" ) ) ) .And. ;
				 		!Empty( SE5->( FieldPos( "E5_PRETCOF" ) ) ) .And. !Empty( SE5->( FieldPos( "E5_PRETCSL" ) ) ) .And. ;
				 		!Empty( SE2->( FieldPos( "E2_SEQBX"   ) ) ) .And. !Empty( SFQ->( FieldPos( "FQ_SEQDES"  ) ) ) )

Local lCalcIssBx 	:=	IIF(lIsIssBx, IsIssBx("P"), SuperGetMv("MV_MRETISS",.F.,"1") == "2" )
Local cFilterUser 	:= aReturn[7]
Local cFilADVPL   	:= ""
Local cFiltroSE2  	:= ""
Local lMultFil    	:= .F.	// Indica que existe mais de uma filial
Local lFilCRet    	:= ( Len( aCodRet ) > 0 )		// Indica se foram selecionados codigos de retencao para filtro
Local nTotFil     	:= 0
              
Local lTitPai     	:= SE2->( FieldPos( "E2_TITPAI" ) ) > 0
Local nX          	:= 0
Local nTotValImp  	:= 0
Local lImpFornec  	:= .T.	// Indica se imprimiu pelo menos um titulo para o fornecedor
Local cCodRet     	:= ""

Local lSE2Comp		:= Empty(FwFilial("SE2"))

Local lContRetIRF	:= !Empty(SE2->(FieldPos("E2_VRETIRF"))) .AND. !Empty(SE2->(FieldPos("E2_PRETIRF")))

Local nTotREG		:= 0

Local lIRPFBaixa :=  	! Empty( SE2->( FieldPos( "E2_VRETIRF" ) ) ) .And. ;
						! Empty( SE2->( FieldPos( "E2_PRETIRF" ) ) ) .And. ;
						! Empty( SE5->( FieldPos( "E5_VRETIRF" ) ) ) .And. ;
						! Empty( SE5->( FieldPos( "E5_PRETIRF" ) ) ) 
Local lIRPFBxAux  := .F.     
Local lDedInss		:= .T.
Local cChaveOld := ""


aCampos	:= {	{"CODIGO"	,"C",06,0 },;
				{"LOJA"	,"C",02,0 },;
				{"NOMEFOR"	,"C",40,0 },;
				{"CGC"		,"C",14,0 },;
				{"PREFIXO"	,"C",03,0 },;
				{"NUM"		,"C",aTamNum[1],0 },;
				{"PARCELA"	,"C",TamSx3("E2_PARCELA")[1],0 },;
				{"TIPO"		,"C",03,0 },;
				{"EMISSAO"	,"D",08,0 },;
				{"VENCTO"	,"D",08,0 },;
				{"VALBASE"  ,"N",17,2 },;
				{"VALINSS"	,"N",17,2 },;
				{"VALPIS"	,"N",17,2 },;
				{"VALCOF"	,"N",17,2 },;
				{"VALCSLL"	,"N",17,2 },;
				{"VALIRRF"	,"N",17,2 },;
				{"VALISS"	,"N",17,2 },;
				{"VALSEST"	,"N",17,2 },;
				{"VALLIQ"	,"N",17,2 },;
				{"VRETPIS"	,"N",17,2 },;
				{"VRETCOF"	,"N",17,2 },;
				{"VRETCSL"	,"N",17,2 },;
				{"PRETPIS"	,"C",01,0 },;
				{"PRETCOF"	,"C",01,0 },;
				{"PRETCSL"	,"C",01,0 },;
				{"PRETIRF"	,"C",01,0 },;
				{"TRETISS"	,"C",01,0 },;
				{"FATURA"	,"C",TamSx3("E2_FATURA")[1],0 },;
				{"PARCISS"  ,"C",TamSX3("E2_PARCPIS")[1],0 },;
				{"PARCINS"  ,"C",TamSX3("E2_PARCINS")[1],0 },;
				{"PARCIR"   ,"C",TamSX3("E2_PARCIR")[1],0 },;
				{"PARCPIS"  ,"C",TamSX3("E2_PARCPIS")[1],0 },;
				{"PARCCOF"  ,"C",TamSX3("E2_PARCCOF")[1],0 },;
				{"PARCSLL"  ,"C",TamSX3("E2_PARCSLL")[1],0 },;
				{"PARCSES"  ,"C",TamSX3("E2_PARCSES")[1],0 },;
				{"NATUREZ"  ,"C",TamSX3("E2_NATUREZ")[1],0 },;
				{"FILIAL"   ,"C",TamSX3("E2_FILIAL") [1],0 }}
				

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Vari veis utilizadas para Impress„o do Cabe‡alho e Rodap‚ ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cbtxt 	:= ""
cbcont	:= 1
li 		:= 80
m_pag 	:= 1

// Verifica se existe mais de uma filial para a empresa posicionada
SM0->( dbSeek( cEmpAnt ) )
SM0->( DBEval( { || nTotFil++ },, { || SM0->M0_CODIGO == cEmpAnt } ) )

lMultFil := ( nTotFil > 1 )

// Monta string com codigos de retencao selecionadas no filtro
lFilCRet := ( Len( aCodRet ) > 0 )

If lFilCRet
	AEval( aCodRet, { |x| cCodRet += ( x + "/" ) } )
	cCodRet := Left( cCodRet, Len( cCodRet ) - 1 )
EndIf

// Cons. Filiais Abaixo ?
If lConsFil
	cFilDe  := mv_par12	// De Filial ?
	cFilAte := mv_par13	// Ate Filial ?
Else
	cFilDe  := cFilAnt
	cFilAte := cFilAnt
EndIf

dbSelectArea("SM0")
dbSeek( cEmpAnt + cFilDe, .T. )

nRegSM0 := SM0->(Recno())

Do While SM0->( !Eof() .And. M0_CODIGO == cEmpAnt .And. M0_CODFIL <= cFilAte )

	cFilAnt := SM0->M0_CODFIL

	// Inicializa totalizadores por filial se considera filiais e utiliza mais de uma filial
	If lConsFil .And. lMultFil
		nTitFil	  := 0
		nVlFilOri := 0
		nVlFilLiq := 0
		nVlFilIns := 0
		nVlFilPis := 0
		nVlFilCof := 0
		nVlFilCsl := 0
		nVlFilIrf := 0
		nVlFilIss := 0
		nVlFilSes := 0
	EndIf

	If nOrdem == 1  //Por Codigo
		SE2->( dbSetOrder(6) )
	Else            //Por Nome
		SE2->( dbSetOrder(2) )
	Endif

	cChaveSe2 := SE2->( IndexKey() )

	#IFDEF TOP
		If !Empty(cFilterUser)
			//Transforma a expressão do filtro de ADVPL para Query SQL
			cFilADVPL := PcoParseFil(cFilterUser,"SE2") 
	    EndIf
		If nOrdem == 1  //Por Codigo
			cOrder := "CODIGO,LOJA"
		Else            //Por Nome
			cOrder := "NOMEFOR"
		Endif
		
		cQuery := "SELECT A2_COD CODIGO,A2_LOJA LOJA,A2_NOME NOMEFOR,A2_CGC CGC, E2_FILIAL FILIAL, E2_PREFIXO PREFIXO,"
		cQuery += "E2_NUM NUM,E2_PARCELA PARCELA,E2_TIPO TIPO,E2_EMISSAO EMISSAO,E2_VENCREA VENCTO,"
		cQuery += "E2_IRRF VALIRRF,"                          
		cQuery += "E2_ISS VALISS,E2_INSS VALINSS,E2_FATURA FATURA,E2_NATUREZ NATUREZ, "
		cQuery += "E2_PIS VALPIS,E2_COFINS VALCOF,E2_CSLL VALCSLL,"	
		//Se controla Retencao
		If lContrRet
			cQuery += "E2_VRETPIS VRETPIS,E2_VRETCOF VRETCOF,E2_VRETCSL VRETCSL,"
			cQuery += "E2_PRETPIS PRETPIS,E2_PRETCOF PRETCOF,E2_PRETCSL PRETCSL,"
			If lSest  // So processa se existir o campo E2_SEST
				cQuery += "(E2_VALOR) VALBASE,"
				cQuery += "E2_SEST VALSEST,"
			Else
				cQuery += "(E2_VALOR) VALBASE,"
			Endif	
		Else
			If lSest  // So processa se existir o campo E2_SEST
				cQuery += "(E2_VALOR) VALBASE,"
				cQuery += "E2_SEST VALSEST,"
			Else
				cQuery += "(E2_VALOR) VALBASE,"
			Endif
		Endif					
	
		IF lCalcIssBx
			cQuery += "E2_TRETISS TRETISS,"
		Endif

		If lContRetIRF
			cQuery += "E2_VRETIRF VRETIRF, E2_PRETIRF PRETIRF, "
		Endif			

		cQuery += "E2_VALOR VALLIQ, E2_PARCISS PARCISS, E2_PARCINS PARCINS, E2_PARCIR PARCIR, "
		cQuery += "E2_PARCPIS PARCPIS, E2_PARCCOF PARCCOF, E2_PARCSLL PARCSLL, E2_PARCSES PARCSES "
		cQuery += "FROM "+RetSqlName("SE2")+" SE2,"
		cQuery +=         RetSqlName("SA2")+" SA2 "
		cQuery += " WHERE SA2.A2_FILIAL = '" + xFilial("SA2") + "'"
		cQuery += " AND SA2.A2_COD = SE2.E2_FORNECE "
		cQuery += " AND SA2.A2_LOJA = SE2.E2_LOJA "
		If !Empty( cTipoForn )
			cQuery += " AND SA2.A2_TIPO = '" + cTipoForn + "' "
		EndIf	
		cQuery += " AND SA2.D_E_L_E_T_ = ' ' "
		cQuery += " AND SE2.E2_FILIAL = '" + xFilial("SE2") + "'"
		cQuery += " AND SE2.E2_FORNECE  between '" + mv_par01 + "' AND '" + mv_par02 + "'"
		cQuery += " AND SE2.E2_LOJA     between '" + mv_par03 + "' AND '" + mv_par04 + "'"					
		cQuery += " AND (SE2.E2_INSS > 0 "
		cQuery += " OR SE2.E2_ISS > 0 "
		cQuery += " OR SE2.E2_PIS > 0 "
		cQuery += " OR SE2.E2_COFINS > 0 "
		cQuery += " OR SE2.E2_CSLL > 0 "
		If lSest
			cQuery += " OR SE2.E2_SEST > 0 "
		EndIf  

		If lContRetIRRF
			cQuery += " OR (SE2.E2_IRRF > 0 OR (SE2.E2_VRETIRF > 0 AND SE2.E2_PRETIRF <> '1'))) "
		Else
			cQuery += " OR SE2.E2_IRRF > 0 ) "
		Endif
		//cQuery += " AND SE2.E2_VENCREA  between '" + DTOS(mv_par07)  + "' AND '" + DTOS(mv_par08) + "'"   //Retirado...filtro vencimento dos titulos de impostos abaixo
		cQuery += " AND SE2.E2_EMIS1  between '" + DTOS(mv_par15)  + "' AND '" + DTOS(mv_par16) + "'"       //Data contabil
		cQuery += " AND SE2.E2_EMISSAO  between '" + DTOS(mv_par05)  + "' AND '" + DTOS(mv_par06) + "'"
		//cQuery += " AND SE2.E2_EMISSAO  <= '"      + DTOS(dDataBase) + "'"
		// Se considera filiais e SE2 estah compartilhado, realiza filtro por filial origem
		If lConsFil .And. lSE2Comp
			cQuery += " AND SE2.E2_FILORIG = '" + cFilAnt + "' "
		EndIf
		If !Empty(cFilADVPL)
			cQuery += " AND (" + cFilADVPL + ")"
		Else
			//Coloco o filtro de usuário em outra variável, pois quando seleciona a tabela TRB
			//a variável cFilterUser é zerada.
			cFiltroSE2 := cFilterUser
		EndIf
		
		cQuery += " AND SE2.D_E_L_E_T_ = ' ' "
		cQuery += " ORDER BY "+ cOrder
		
		cQuery := ChangeQuery(cQuery)
	
		dbSelectArea("SE2")
		dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TRB", .F., .T.)
		TCSetField('TRB',"VENCTO","D",8,0)
		TCSetField('TRB',"EMISSAO","D",8,0)
	#ELSE
	    /*
		cFiltroSE2 := cFilterUser
		cIndexSe2 := CriaTrab(Nil,.F.)
		IndRegua("SE2",cIndexSe2,cChaveSe2,,FR865IndR(cFiltroSE2,cTipoForn,lSest,lConsFil,lSE2Comp,lContRetIRRF),STR0011)
		nIndexSE2 := RetIndex("SE2")
		SE2->(dbSetIndex(cIndexSe2+OrdBagExt()))
		SE2->(dbSetOrder(nIndexSE2+1))
		SE2->(dbSeek(xFilial("SE2")))
	
		cArqTrab := CriaTrab( aCampos )
		dbUseArea( .T.,, cArqTrab, "TRB", if(.F. .OR. .F., !.F., NIL), .F. )
		If nOrdem == 1  //Por Codigo
			IndRegua("TRB",cArqTrab,"CODIGO+LOJA",,,)
		Else            //Por Nome
			IndRegua("TRB",cArqTrab,"NOMEFOR",,,)
		Endif
		TRB->(dbSetIndex( cArqTrab +OrdBagExt()))
	
		dbSelectArea("SE2")
	
		While !SE2->(Eof())
		
			dbSelectArea("SA2")			
			SA2->(dbSetOrder(1))
			
			If SA2->(dbSeek(xFilial("SA2") + SE2->(E2_FORNECE+E2_LOJA)))

				If	lContrRet    
					dbSelectArea("SED")   
					dbsetorder(1)
					dbSeek( xFilial("SED") + SE2->E2_NATUREZ )
					If SED->(FieldPos("ED_DEDINSS")) > 0
						lDedInss:= (SED->ED_DEDINSS == "1")
					Endif	
				
					nValBase := SE2->(E2_VALOR+E2_IRRF+E2_ISS)+IF(lDedInss,SE2->E2_INSS,0)
					nValLiq := SE2->E2_VALOR
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³No que esta consolidado nao se pode determinar qual o    ³
					//³tipo de retencao de PCC estava em uso e nao se pode usar ³
					//³o parametro MV_BX10925 como referencia, entao utilizar   ³
					//³apenas os campos PRET para determinar se o PCC deve      ³
					//³ou nao ser agregado ao valor original do titulo.         ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If (Empty(SE2->E2_PRETPIS) .OR. Empty(SE2->E2_PRETCOF) .OR. Empty(SE2->E2_PRETCSL)) .AND. SE2->(E2_PIS+E2_COFINS+E2_CSLL) > 0
						//PCC retido na emissao nele mesmo, somar para compor o valor original.
						nValBase += SE2->(E2_PIS+E2_COFINS+E2_CSLL)
					Else
						//PCC retido na baixa ou na emissao nao nele mesmo, ou seja, o E2_VALOR nao sofreu abatimento, entao abater o PCC para obter o liquido
						nValLiq -= SE2->(E2_PIS+E2_COFINS+E2_CSLL)
					Endif
				Else 
				
					dbSelectArea("SED")   
					dbsetorder(1)
					dbSeek( xFilial("SED") + SE2->E2_NATUREZ )
					If SED->(FieldPos("ED_DEDINSS")) > 0
						lDedInss:= (SED->ED_DEDINSS == "1")
					Endif
					nValBase := SE2->(E2_VALOR+E2_IRRF+E2_ISS+E2_PIS+E2_COFINS+E2_CSLL)+IF(lDedInss,SE2->E2_INSS,0)
					nValLiq := SE2->E2_VALOR
				Endif
				If lSest
					nValBase += SE2->E2_SEST
				Endif
				
				dbSelectArea("TRB")
				RecLock("TRB",.T.)	
				TRB->CODIGO		:= SA2->A2_COD
				TRB->LOJA		:= SA2->A2_LOJA
				TRB->NOMEFOR	:= SA2->A2_NOME 
				TRB->CGC		:= SA2->A2_CGC
				TRB->PREFIXO	:= SE2->E2_PREFIXO
				TRB->NUM		:= SE2->E2_NUM
				TRB->PARCELA	:= SE2->E2_PARCELA
				TRB->TIPO		:= SE2->E2_TIPO
				TRB->EMISSAO	:= SE2->E2_EMISSAO
				TRB->VENCTO		:= SE2->E2_VENCREA
				TRB->VALBASE	:= nValBase
				TRB->VALINSS	:= SE2->E2_INSS
				TRB->VALPIS		:= SE2->E2_PIS
				TRB->VALCOF		:= SE2->E2_COFINS
				TRB->VALCSLL	:= SE2->E2_CSLL 
				TRB->VALIRRF	:= SE2->E2_IRRF
				TRB->VALISS		:= SE2->E2_ISS       
				TRB->FATURA		:= SE2->E2_FATURA
				TRB->TRETISS    := SE2->E2_TRETISS
				TRB->PARCISS	:= SE2->E2_PARCISS
				TRB->PARCINS	:= SE2->E2_PARCINS
				TRB->PARCIR		:= SE2->E2_PARCIR
				TRB->PARCPIS	:= SE2->E2_PARCPIS
				TRB->PARCCOF	:= SE2->E2_PARCCOF
				TRB->PARCSLL	:= SE2->E2_PARCSLL
				TRB->PARCSES	:= SE2->E2_PARCSES
				TRB->NATUREZ	:= SE2->E2_NATUREZ
				
				If lSest  // So processa se existir o campo E2_SEST
					TRB->VALSEST   := SE2->E2_SEST  
				Endif
				TRB->VALLIQ		:= nValLiq
	
				//Se controla retencao
				If lContrRet
					TRB->VRETPIS	:= SE2->E2_VRETPIS
					TRB->VRETCOF	:= SE2->E2_VRETCOF
					TRB->VRETCSL	:= SE2->E2_VRETCSL 
					TRB->PRETPIS	:= SE2->E2_PRETPIS
					TRB->PRETCOF	:= SE2->E2_PRETCOF
					TRB->PRETCSL	:= SE2->E2_PRETCSL 
				Endif			
				
				MSUnlock()
			Endif
			SE2->(dbSkip())
		EndDo
		*/
	#ENDIF
	
	TRB->(dbGoTop())
	TRB->(dbEval({|| nTotREG++}))
	TRB->(dbGoTop())
	SetRegua(nTotREG)

	While !TRB->(Eof())
		IF lEnd
			@PROW()+1,001 PSAY OemToAnsi(STR0012) //"CANCELADO PELO OPERADOR"
			lContinua := .F.
			Exit
		EndIF     

		If li > 58
			FR865Cabec(GetMv("MV_COMP"),nRegSM0,lFilCRet,cCodRet)
		EndIf
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Caso a funçao PcoParseFil() retorne vazio, posiciono na      ³
		//³ tabela SE2 para fazer o filtro do usuário.				     ³		
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ    
		/*
		If Empty(cFilADVPL)	.And. !Empty(cFiltroSE2)
	    	dbSelectArea("SE2")
	    	SE2->(dbSetOrder(1))
	    	SE2->(MsSeek(xFilial("SE2")+TRB->PREFIXO+TRB->NUM+TRB->PARCELA+TRB->TIPO+TRB->CODIGO+TRB->LOJA))
			If !SE2->(&cFiltroSE2)
				TRB->(dbSkip())
				Loop
			Endif
		EndIF
		*/
		nTitCli		:= 0
		nVlCliOri	:= 0
		nVlCliIns	:= 0
		nVlCliLiq	:= 0
		nVlCliPis	:= 0
		nVlCliCof	:= 0
		nVlCliCsl	:= 0
		nVlCliSes	:= 0
		nVlCliIrf	:= 0
		nVlCliIss	:= 0
		nValBase	:= 0
	
		cCodFor		:= TRB->CODIGO
		cLojFor		:= TRB->LOJA
		cNomFor		:= TRB->NOMEFOR
		cCGCAnt		:= TRB->CGC    
		lImpFornec  := .T.
		
		Do While !TRB->(Eof()) .And. cCodFor + cLojFor == TRB->(CODIGO+LOJA) .AND. cNomFor == TRB->NOMEFOR
			//Validação p/ não gerar duplicidade
			If TRB->(LOJA+FILIAL+PREFIXO+NUM+PARCELA+TIPO+CODIGO) == cChaveOld
				TRB->( dbSkip() )
				Loop
			EndIf
			cChaveOld := TRB->(LOJA+FILIAL+PREFIXO+NUM+PARCELA+TIPO+CODIGO)
						
		    _lVenc := .F.
			&&Mauricio - 04/01/17 - tratamento para imprimir apenas impostos na data de vencimento parametrizada...
			dbSelectArea("SE2")
			IF !Empty(cFilADVPL)
			   Set Filter to    &&Mauricio - 18/01/17 - retira filtro da SE2 qdo usuario utiliza filtro no relatorio....
			Endif   
	    	SE2->(dbSetOrder(1))
	    	dbgotop()
	    	SE2->(dbSeek(TRB->FILIAL+TRB->PREFIXO+TRB->NUM))
               
            aTITS := {}
            Do While SE2->( ! Eof() .And. E2_PREFIXO + E2_NUM  == TRB->PREFIXO+TRB->NUM )
	           // Faz a validacao da chave do titulo pai se existir o campo
	           If !Empty( SE2->E2_TITPAI )
	              If AllTrim( SE2->E2_TITPAI ) == AllTrim( TRB->( PREFIXO + NUM + PARCELA + TIPO + CODIGO + LOJA ) ) 
			         IF SE2->E2_VENCREA >= MV_PAR07 .AND. SE2->E2_VENCREA <= MV_PAR08
			            _lVenc := .T.
			            AADD(aTITS,{SE2->E2_VENCREA,STRZERO(SE2->E2_VALOR,14,2),Alltrim(SE2->E2_NATUREZ)})
			         ENDIF   
			      ENDIF
			   ENDIF   
			   SE2->(DbSkip())
			ENDDO
			
			If !_lVenc
			   TRB->( dbSkip() )
			   Loop			
			Endif
					
			IncRegua()
			
			IF li > 58
				FR865Cabec(GetMv("MV_COMP"),nRegSM0,lFilCRet,cCodRet)
			EndIF 

			If SA2->(! dbSeek(xFilial("SA2")+TRB->CODIGO+TRB->LOJA) )
				TRB->( dbSkip() )
				Loop
			EndIf

			lIRPFBAux  := lIRPFBaixa
			If SA2->( FieldPos( "A2_CALCIRF" ) ) > 0
				lIRPFBxAux := lIRPFBAux .And. ( SA2->A2_CALCIRF == "2" )
			Else
				lIRPFBxAux := .F.
			EndIf

			// Inicializa vetor com o valor dos impostos do titulo
			aValImp := {;
						TRB->VALSEST,;		// Valor SEST
						TRB->VALIRRF,;		// Valor IRRF 	
						TRB->VALISS ,;		// Valor ISS
						TRB->VALINSS,;		// Valor INSS
						TRB->VALPIS	,;		// Valor PIS
						TRB->VALCOF	,;		// Valor COFINS
						TRB->VALCSLL }		// Valor CSLL
			           
			// Se utiliza filtro por codigo de retencao, altera os valores do vetor 
			// de acordo com os codigos de retencao selecionados para filtro
			If lFilCRet

				nTotValImp := 0
				FR865FilCRet( @aValImp, aCodRet, lTitPai )
				AEval( aValImp, { |x| nTotValImp += x } )

				// Se todos os impostos estao com valor zero, vai para o proximo titulo
				If nTotValImp == 0
					TRB->( dbSkip() )
					Loop     
				EndIf

			EndIf

			lFatura := .F.
	
		 	If !Empty(TRB->FATURA) .And. TRB->FATURA == 'NOTFAT'
				lFatura := .T.
			EndIf 
                    
			If lImpFornec
				@li,  0 PSAY TRB->CODIGO+"-"+TRB->LOJA
				@li, 15 PSAY Substr(TRB->NOMEFOR,1,30)
				@li, 46 PSAY TRB->CGC Picture IIF(Len(Alltrim(TRB->CGC)) == 11 , "@R 999.999.999-99","@R 99.999.999/9999-99")
				li+=2
				lImpFornec := .F.
			EndIf	
	        
				
			@li, 05 PSAY TRB->PREFIXO
			@li, 09 PSAY TRB->NUM
			
			@LI, 021 PSAY TRB->PARCELA
			@li, 025 PSAY TRB->TIPO
	                                                              
			@li, 031 PSAY TRB->EMISSAO
															
			@li, 042 PSAY TRB->VENCTO
			_dDTVENC := TRB->VENCTO
			
			
			
			#IFDEF TOP
				If	lContrRet
					dbSelectArea("SED")   
					dbsetorder(1)
					dbSeek( xFilial("SED") + TRB->NATUREZ )
					If SED->(FieldPos("ED_DEDINSS")) > 0
						lDedInss:= (SED->ED_DEDINSS == "1")
					Endif	

					nValBase	:= TRB->(VALBASE+If(!lIRPFBxAux,VALIRRF,0)+IF(lDedInss,VALINSS,0)+VALISS)
					nValLiq := TRB->VALLIQ
					If !lPccBaixa
						If (Empty( TRB->PRETPIS) .OR. Empty( TRB->PRETCOF) .OR. Empty( TRB->PRETCSL)) .AND.  TRB->(VALPIS+VALCOF+VALCSLL)  > 0
						//PCC retido na emissao nele mesmo, somar para compor o valor original.
					   		nValBase += TRB->(VRETPIS+VRETCOF+VRETCSL) 
				  		Endif
				  	Endif
				  		
				  	If ( ( TRB->PRETPIS == '2')   .OR.  ( TRB->PRETCOF == '2') .OR. ( TRB->PRETCSL == '2')) .AND. TRB->( VALPIS + VALCOF + VALCSLL ) > 0
						//PCC retido na baixa ou na emissao nao nele mesmo, ou seja, o E2_VALOR nao sofreu abatimento, entao abater o PCC para obter o liquido
						nValLiq -= TRB->(VALPIS+VALCOF+VALCSLL) 
					EndIf 
					
							//Caso o calculo do ISS seja efetuado na baixa do titulo, nao somo o imposto para compor o valor base
					If lCalcIssBx .and. TRB->TRETISS == "2"
						nValBase -= TRB->VALISS
						nValLiq	 -= TRB->VALISS					
					Endif
					
					If lIRPFBxAux .and. TRB->PRETIRF $ "1/7/ /4"
	//					nValBase -= TRB->VALIRRF
						nValLiq	 -= TRB->VALIRRF
					Endif
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³No que esta consolidado nao se pode determinar qual o    ³
					//³tipo de retencao de PCC estava em uso e nao se pode usar ³
					//³o parametro MV_BX10925 como referencia, entao utilizar   ³
					//³apenas os campos PRET para determinar se o PCC deve      ³
					//³ou nao ser agregado ao valor original do titulo.         ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If	!(lPccBaixa .and. ( ( TRB->PRETPIS == '1' .And. TRB->PRETPIS == '1' )   .OR.  ;
						  ( TRB->PRETCOF == '1' .And. TRB->PRETCOF == '1' )   .OR.  ;
						  ( TRB->PRETCSL == '1' .And. TRB->PRETCSL == '1' ) ) .AND. ;
						  TRB->( VALPIS + VALCOF + VALCSLL ) > 0)
						If	( ( TRB->PRETPIS <> '2' .And. TRB->PRETPIS <> '3' .And. TRB->PRETPIS <> '4' )   .OR.  ;
							  ( TRB->PRETCOF <> '2' .And. TRB->PRETCOF <> '3' .And. TRB->PRETCOF <> '4' )   .OR.  ;
							  ( TRB->PRETCSL <> '2' .And. TRB->PRETCSL <> '3' .And. TRB->PRETCSL <> '4' ) ) .AND. ;
							  TRB->( VALPIS + VALCOF + VALCSLL ) > 0
	
							//PCC retido na emissao nele mesmo, somar para compor o valor original.
						
								
						    If	( ( TRB->PRETPIS <> '2' .And. TRB->PRETPIS <> '3' )   .OR.  ;
							  	  ( TRB->PRETCOF <> '2' .And. TRB->PRETCOF <> '3' )   .OR.  ;
							  	  ( TRB->PRETCSL <> '2' .And. TRB->PRETCSL <> '3' ) ) .AND. ;
								  TRB->( VALPIS + VALCOF + VALCSLL ) > 0
	                           	    	
						   		If nValBase > SuperGetMv( "MV_VL10925", ,5000 ) 
						       		nDescont:= TRB->(VRETPIS+VRETCOF+VRETCSL) - TRB->(VALPIS+VALCOF+VALCSLL) 
								   	nValLiq += nDescont
								   	If !lIRPFBxAux	.and. (!Empty( TRB->PRETPIS) .Or. !Empty( TRB->PRETCOF) .or. !Empty( TRB->PRETCSL))						
								  		nValBase+= nDescont
							  		EndIf
						   	  	Else
						  	 		nDescont:= TRB->(VRETPIS+VRETCOF+VRETCSL) - TRB->(VALPIS+VALCOF+VALCSLL) 
							   		nValLiq += nDescont
							   	EndIf
							EndIf			   	  		
	
						ElseIF lPccBaixa .and. (( TRB->PRETPIS <> '2') .OR. ( TRB->PRETCOF <> '2') .OR. ( TRB->PRETCSL <> '2' ))
	
							//PCC retido na baixa ou na emissao nao nele mesmo, ou seja, o E2_VALOR nao sofreu abatimento, entao abater o PCC para obter o liquido
							nValLiq -= TRB->(VALPIS+VALCOF+VALCSLL)
	
					   Endif
					ElseIf lPccBaixa //.and. ( nValBase > SuperGetMv( "MV_VL10925", ,5000 ) )							
						nValLiq-= TRB->( VALPIS + VALCOF + VALCSLL )
				   	Endif

			    Else

					nValBase := TRB->VALBASE
					nValLiq := TRB->VALLIQ 


		   				//Caso o calculo do ISS seja efetuado na baixa do titulo, nao somo o imposto para compor o valor base
		   			If lCalcIssBx .and. TRB->TRETISS == "2"
						nValBase -= TRB->VALISS
						nValLiq	 -= TRB->VALISS					
					Endif
					
					If lIRPFBxAux .and. TRB->PRETIRF $ "1/7/ /4"
	//					nValBase -= TRB->VALIRRF
						nValLiq	 -= TRB->VALIRRF
					Endif

				Endif
	
				If lSest   // So processa se existir o campo E2_SEST
					nValBase += aValImp[N_VALSEST]
				Endif
				@li, 053 PSAY nValBase Picture tm (TRB->VALBASE ,15)
			#ELSE        
				nValBase := TRB->VALBASE
				nValLiq := TRB->VALLIQ			                                                          
				//Caso o calculo do ISS seja efetuado na baixa do titulo, nao somo o imposto para compor o
				//valor base
				If lCalcIssBx .AND. TRB->TRETISS == "2"
					nValBase -= TRB->VALISS
					nValLiq	 -= TRB->VALISS					
				Endif
				
				If lIRPFBxAux .and. TRB->PRETIRF $ "1/7/ /4"
//					nValBase -= TRB->VALIRRF
					nValLiq	 -= TRB->VALIRRF
				Endif
				
				If lSest   // So processa se existir o campo E2_SEST
					nValBase += aValImp[N_VALSEST]
				Endif

				@li, 053 PSAY nValBase Picture tm (TRB->VALBASE ,15)			
			#ENDIF              
									
			If lSest  // So processa se existir o campo E2_SEST
				@li, 069 PSAY aValImp[N_VALSEST]	Picture tm (TRB->VALSEST ,15)
			EndIf
			//nImp := Ascan(aTITS,{|x|x[3]+x[4]+x[5]==SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_PLACA+SD1->D1_CF } )
			&&Mauricio - 18/01/2017 - Verifico se o imposto eh relativo ao IRF
			IF VALTYPE(aValImp[N_VALIRRF]) <> "U"
				//MSGINFO(STRZERO(aValImp[N_VALIRRF],14,2)+STRTRAN(Alltrim(Getmv("MV_IRF")),'"',''))		
			   nImp := Ascan(aTITS,{|x|x[2]+x[3] == STRZERO(aValImp[N_VALIRRF],14,2)+STRTRAN(Alltrim(Getmv("MV_IRF")),'"','') } )
			Else
			   nImp := 0 
			Endif   
			If nImp > 0			
			   If aTITS[nImp][1] <> _dDTVENC
			      Li ++
			      @li, 042 PSAY aTITS[nImp][1]
			      @li, 085 PSAY aValImp[N_VALIRRF]		Picture tm (TRB->VALIRRF ,15)
			      _dDTVENC := aTITS[nImp][1]
			   Else
			      @li, 085 PSAY aValImp[N_VALIRRF]		Picture tm (TRB->VALIRRF ,15)
			   Endif
			   nVlCliIrf += aValImp[N_VALIRRF]
			Else
			   @li, 085 PSAY 0		Picture tm (TRB->VALIRRF ,15)
			   nVlCliIrf += 0
			Endif
			IF VALTYPE(aValImp[N_VALISS]) <> "U"
			   nImp := Ascan(aTITS,{|x|x[2]+x[3] == STRZERO(aValImp[N_VALISS],14,2)+STRTRAN(Alltrim(Getmv("MV_ISS")),'"','') } )			   
			Else
			   nImp := 0 
			Endif			
			//nImp := Ascan(aTITS,{|x|x[2] == aValImp[N_VALISS] } )
			If nImp > 0			
			   If aTITS[nImp][1] <> _dDTVENC
			      Li ++
			      @li, 042 PSAY aTITS[nImp][1]
			      @li, 101 PSAY aValImp[N_VALISS]		Picture tm (TRB->VALISS  ,15)
			      _dDTVENC := aTITS[nImp][1]
			   Else
			      @li, 101 PSAY aValImp[N_VALISS]		Picture tm (TRB->VALISS  ,15)
			   Endif
			   nVlCliIss += aValImp[N_VALISS]
			Else
			   @li, 101 PSAY 0	Picture tm (TRB->VALISS  ,15)
			   nVlCliIss += 0
			Endif
			IF VALTYPE(aValImp[N_VALINSS]) <> "U"
			   nImp := Ascan(aTITS,{|x|x[2]+x[3] == STRZERO(aValImp[N_VALINSS],14,2)+STRTRAN(Alltrim(Getmv("MV_INSS")),'"','') } )						   
			Else
			   nImp := 0 
			Endif
			//nImp := Ascan(aTITS,{|x|x[2] == aValImp[N_VALINSS] } )
			If nImp > 0			
			   If aTITS[nImp][1] <> _dDTVENC
			      Li ++
			      @li, 042 PSAY aTITS[nImp][1]
			      @li, 117 PSAY aValImp[N_VALINSS]  		Picture tm (TRB->VALINSS ,15)
			      _dDTVENC := aTITS[nImp][1]
			   Else
			      @li, 117 PSAY aValImp[N_VALINSS]  		Picture tm (TRB->VALINSS ,15)
			   Endif
			   nVlCliIns += aValImp[N_VALINSS]
			Else
			   @li, 117 PSAY 0  		Picture tm (TRB->VALINSS ,15)
			   nVlCliIns += 0
			Endif
			IF VALTYPE(aValImp[N_VALPIS]) <> "U"
			   nImp := Ascan(aTITS,{|x|x[2]+x[3] == STRZERO(aValImp[N_VALPIS],14,2)+STRTRAN(Alltrim(Getmv("MV_PISNAT")),'"','') } )						   
			Else
			   nImp := 0 
			Endif
			//nImp := Ascan(aTITS,{|x|x[2] == aValImp[N_VALPIS] } )
			If nImp > 0			
			   If aTITS[nImp][1] <> _dDTVENC
			      Li ++
			      @li, 042 PSAY aTITS[nImp][1]
			      @li, 133 PSAY aValImp[N_VALPIS]		Picture tm (TRB->VALPIS  ,15)
			      _dDTVENC := aTITS[nImp][1]
			   Else
			      @li, 133 PSAY aValImp[N_VALPIS]		Picture tm (TRB->VALPIS  ,15)
			   Endif
			   If TRB->PRETPIS <> "1" .Or. TRB->PRETCOF <> "1" .Or. TRB->PRETCSL <> "1"
				  nVlCliPis += aValImp[N_VALPIS]
			   Endif
			Else
			   @li, 133 PSAY 0		Picture tm (TRB->VALPIS  ,15)
			   nVlCliPis += 0
			Endif
			IF VALTYPE(aValImp[N_VALCOF]) <> "U"
			   nImp := Ascan(aTITS,{|x|x[2]+x[3] == STRZERO(aValImp[N_VALCOF],14,2)+STRTRAN(Alltrim(Getmv("MV_COFINS")),'"','') } )						   
			Else
			   nImp := 0 
			Endif
			//nImp := Ascan(aTITS,{|x|x[2] == aValImp[N_VALCOF] } )
			If nImp > 0			
			   If aTITS[nImp][1] <> _dDTVENC
			      Li ++
			      @li, 042 PSAY aTITS[nImp][1]
			      @li, 149 PSAY aValImp[N_VALCOF]		Picture tm (TRB->VALCOF  ,15)
			      _dDTVENC := aTITS[nImp][1]
			   Else
			      @li, 149 PSAY aValImp[N_VALCOF]		Picture tm (TRB->VALCOF  ,15)
			   Endif
			   If TRB->PRETPIS <> "1" .Or. TRB->PRETCOF <> "1" .Or. TRB->PRETCSL <> "1"				  
				  nVlCliCof += aValImp[N_VALCOF]
			   Endif	  
			Else
			   @li, 149 PSAY 0	Picture tm (TRB->VALCOF  ,15)
			   nVlCliCof += 0
			Endif
			IF VALTYPE(aValImp[N_VALCSLL]) <> "U"
			   nImp := Ascan(aTITS,{|x|x[2]+x[3] == STRZERO(aValImp[N_VALCSLL],14,2)+STRTRAN(Alltrim(Getmv("MV_CSLL")),'"','') } )						   
			Else
			   nImp := 0 
			Endif
			//nImp := Ascan(aTITS,{|x|x[2] == aValImp[N_VALCSLL] } )
			If nImp > 0			
			   If aTITS[nImp][1] <> _dDTVENC
			      Li ++
			      @li, 042 PSAY aTITS[nImp][1]
			      @li, 165 PSAY aValImp[N_VALCSLL]		Picture tm (TRB->VALCSLL ,15)
			      _dDTVENC := aTITS[nImp][1]
			   Else
			      @li, 165 PSAY aValImp[N_VALCSLL]		Picture tm (TRB->VALCSLL ,15)
			   Endif
			   If TRB->PRETPIS <> "1" .Or. TRB->PRETCOF <> "1" .Or. TRB->PRETCSL <> "1"			
				  nVlCliCsl += aValImp[N_VALCSLL]
			   EndIf
			Else
			   @li, 165 PSAY 0		Picture tm (TRB->VALCSLL ,15)
			   nVlCliCsl += 0
			Endif
			@li, 181 PSAY nValLiq		   			Picture tm (TRB->VALLIQ  ,15)
			
			
			
			/*
			@li, 085 PSAY aValImp[N_VALIRRF]		Picture tm (TRB->VALIRRF ,15)
			@li, 101 PSAY aValImp[N_VALISS]		Picture tm (TRB->VALISS  ,15)
			@li, 117 PSAY aValImp[N_VALINSS]  		Picture tm (TRB->VALINSS ,15)
			@li, 133 PSAY aValImp[N_VALPIS]		Picture tm (TRB->VALPIS  ,15)
			@li, 149 PSAY aValImp[N_VALCOF]		Picture tm (TRB->VALCOF  ,15)
			@li, 165 PSAY aValImp[N_VALCSLL]		Picture tm (TRB->VALCSLL ,15)						
			@li, 181 PSAY nValLiq		   			Picture tm (TRB->VALLIQ  ,15)
			*/		
	
			If lContrRet // Verifica se o sistema esta fazendo controle de retencao de impostos
				If lPccBaixa	// Geracao dos impostos lei 10925 pela baixa
					If TRB->(VALPIS+VALCOF+VALCSLL) > 0  
						If TRB->TIPO $ MVPAGANT 
							If TRB->PRETPIS == "1" .or. TRB->PRETCOF == "1" .or. TRB->PRETCSL == "1"
								If TRB->(VRETPIS+VRETCOF+VRETCSL) == 0			                      
									@li, 197 PSAY "A"
								Endif
							Endif			                                               					
						Else
							If TRB->PRETPIS == "3" .or. TRB->PRETCOF == "3" .or. TRB->PRETCSL == "3"
								If TRB->(VRETPIS+VRETCOF+VRETCSL) == 0
									@li, 197 PSAY "A"			                                               
								Endif
							ElseIf TRB->PRETPIS == "1" .or. TRB->PRETCOF == "1" .or. TRB->PRETCSL == "1"
								@li, 197 PSAY "B"			
							Endif
						Endif
					Endif			
				Else
					If TRB->PRETPIS == "2" .or. TRB->PRETCOF == "2" .or. TRB->PRETCSL == "2"
						@li, 197 PSAY "A"
					ElseIf TRB->PRETPIS == "1" .or. TRB->PRETCOF == "1" .or. TRB->PRETCSL == "1"
						@li, 197 PSAY "B"			
					Endif
				Endif
			Endif
			
		 	If lFatura
			 	@li, 198 PSAY "/C"
			EndIf
	
			li++
			nTitCli++
			If !lFatura
				nVlCliOri += nValBase
			EndIf
	
			nVlCliLiq += nValLiq
			&&Passados totalizadores abaixo para a parte de cima...
			//nVlCliIns += aValImp[N_VALINSS]
			//nVlCliIrf += aValImp[N_VALIRRF]
			//nVlCliIss += aValImp[N_VALISS]
			
			//If TRB->PRETPIS <> "1" .Or. TRB->PRETCOF <> "1" .Or. TRB->PRETCSL <> "1"
				//nVlCliPis += aValImp[N_VALPIS]
				//nVlCliCof += aValImp[N_VALCOF]
				//nVlCliCsl += aValImp[N_VALCSLL]
			//EndIf	
			If lSest   // So processa se existir o campo E2_SEST
				nVlCliSes += aValImp[N_VALSEST]
			Endif
			TRB->(dbSkip())
		EndDo

		IF nVlCliOri > 0 
			li++
			SubTot865(nTitCli,nVlCliOri,nVlCliIns,nVlCliLiq,cNomFor,cCgcAnt,nVlCliPis,nVlCliCof,nVlCliCsl,nVlCliSes,nVlCliIrf,nVlCliIss)
			li++
		Endif
	
		nTitRel	  += nTitCli
		nVlTotOri += nVlCliOri
		nVlTotLiq += nVlCliLiq
		nVlTotIns += nVlCliIns       
		nVlTotPis += nVlCliPis
		nVlTotCof += nVlCliCof
		nVlTotCsl += nVlCliCsl
		nVlTotIrf += nVlCliIrf
		nVlTotIss += nVlCliIss
		If lSest  // So processa se existir o campo E2_SEST
			nVlTotSes += nVlCliSes                  
		Endif

		If lConsFil .And. lMultFil
			nTitFil	  += nTitCli
	        nVlFilOri += nVlCliOri
			nVlFilLiq += nVlCliLiq
			nVlFilIns += nVlCliIns
			nVlFilPis += nVlCliPis
			nVlFilCof += nVlCliCof
			nVlFilCsl += nVlCliCsl
			nVlFilIrf += nVlCliIrf
			nVlFilIss += nVlCliIss
			If lSest
				nVlFilSes += nVlCliSes
			EndIf
		EndIf
				
	Enddo
                 
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Imprimir TOTAL por filial somente quando houver mais do que 1 filial ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nTitFil > 0	.And. lConsFil .And. lMultFil 
		TRB->( dbGoTop() )
		If TRB->( ! EoF() ) 
			li--
			If li > 58
				FR865Cabec(GetMv("MV_COMP"),nRegSM0,lFilCRet,cCodRet)
			EndIf
			@li,000 PSAY	STR0042 + " ---> " + cFilAnt + " - " + AllTrim(SM0->M0_FILIAL) +;			 		// Total Filial ->
							" (" + AllTrim( Str(nTitFil) ) + " " + Iif( nTitFil > 1, STR0014, STR0015 ) + ")" 	// TITULOS ### TITULO
			@li,053 PSAY nVlFilOri Picture TM( nVlFilOri, 15 )
			If lSest  // So processa se existir o campo E2_SEST
				@li,069 PSAY nVlFilSes Picture TM( nVlFilSes, 15 )
			EndIf
			@li,085 PSAY nVlFilIrf Picture TM( nVlFilIrf, 15 )
			@li,101 PSAY nVlFilIss Picture TM( nVlFilIss, 15 )
			@li,117 PSAY nVlFilIns Picture TM( nVlFilIns, 15 )
			@li,133 PSAY nVlFilPis Picture TM( nVlFilPis, 15 )
			@li,149 PSAY nVlFilCof Picture TM( nVlFilCof, 15 )
			@li,165 PSAY nVlFilCsl Picture TM( nVlFilCsl, 15 )
			@li,181 PSAY nVlFilLiq Picture TM( nVlFilLiq, 15 )
			li++
			@li,000 PSAY Replicate("-",220)                            
			li+=2
		EndIf	
	EndIf
	
	#IFNDEF TOP
		dbSelectArea("SE2")
		dbClearFil()
		RetIndex( "SE2" )
		If !Empty(cIndexSE2)
			FErase (cIndexSE2+OrdBagExt())
		Endif
		dbSetOrder(1)
		TRB->(dbCloseArea())
		fErase( cArqTrab + GetDBExtension() )
		fErase( cArqTrab + OrdBagExt() )
	#ELSE
		dbSelectArea("SE2")
		dbCloseArea()
		ChKFile("SE2")
		dbSelectArea("SE2")
		dbSetOrder(1)
		TRB->(dbCloseArea())
	#ENDIF
	
	dbSelectArea("SM0")
	dbSkip()

EndDo

SM0->( dbGoTo( nRegSM0 ) )
cFilAnt := SM0->M0_CODFIL

IF li != 80
	IF li > 58
		FR865Cabec(GetMv("MV_COMP"),nRegSM0,lFilCRet,cCodRet)
	EndIF
	TotGeR865(nVlTotOri,nVlTotIns,nVlTotPis,nVlTotCof,nVlTotCsl,nVlTotLiq,nTitRel,nVlTotIrf,nVlTotIss,nVlTotSes)
    /*
	If lContrRet
		IF li > 58
			FR865Cabec(GetMv("MV_COMP"),nRegSM0,lFilCRet,cCodRet)
		EndIF
		@li, 001 PSAY STR0017 // A = Os valores de Pis,Cofins e Csll deste titulo foram retidos em outro titulo.
		@li++            
		@li, 001 PSAY STR0018+STR0041 // B = Os valores de Pis,Cofins e Csll deste titulo se referem a uma previsao, ainda nao foram retidos.
		@li++
		@li, 001 PSAY STR0019  // C = Os registros referentes a fatura não são incluidos nos totalizadores.
	Endif
    */
	Roda(cbcont,cbtxt,"G")
EndIF

Set Device To Screen

If aReturn[5] = 1
	Set Printer TO
	dbCommitAll()
	Ourspool(wnrel)
Endif
MS_FLUSH()

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³SubTot865 ³ Autor ³ Nilton Pereira        ³ Data ³ 24.03.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Imprimir SubTotal do Relatorio							           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ SubTot865()												              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³															                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico													              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
STATIC Function SubTot865(nTitCli,nVlCliOri,nVlCliIns,nVlCliLiq,cNomFor,cCgcAnt,nVlCliPis,nVlCliCof,nVlCliCsl,nVlCliSes,nVlCliIrf,nVlCliIss)

@li,000 PSAY Replicate("-",220)                              
li+=1     
@li,000 PSAY STR0013 + Substr(cNomFor,1,09) //"Total Fornecedor  - "

@li,030 PSAY " ("+ALLTRIM(STR(nTitCli))+" "+IiF(nTitCli > 1,STR0014,STR0015)+")" //"TITULOS"###"TITULO"

@li,053 PSAY nVlCliOri		Picture TM(nVlCliOri,15)
If lSest  // So processa se existir o campo E2_SEST
	@li,069 PSAY nVlCliSes		Picture TM(nVlCliSes,15)
Endif
@li,085 PSAY nVlCliIrf		Picture TM(nVlCliIrf,15)
@li,101 PSAY nVlCliIss		Picture TM(nVlCliIss,15)
@li,117 PSAY nVlCliIns		Picture TM(nVlCliIns,15)
@li,133 PSAY nVlCliPis		Picture TM(nVlCliLiq,15)
@li,149 PSAY nVlCliCof		Picture TM(nVlCliLiq,15)
@li,165 PSAY nVlCliCsl		Picture TM(nVlCliLiq,15)
@li,181 PSAY nVlCliLiq		Picture TM(nVlCliLiq,15)

li++
@li,000 PSAY Replicate("-",220)                            
li++
Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ TotGeR865³ Autor ³ Nilton Pereira		³ Data ³ 24.03.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Imprimir total do relatorio								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ TotGeR865()												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³															  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
STATIC Function TotGeR865(nVlTotOri,nVlTotIns,nVlTotPis,nVlTotCof,nVlTotCsl,nVlTotLiq,nTitRel,nVlTotIrf,nVlTotIss,nVlTotSes)

@li,000 PSAY Replicate("_",220)
li+= 2
@li,000 PSAY STR0016  //"TOTAL GERAL      ----> "
@li,030 PSAY "("+ALLTRIM(STR(nTitRel))+" "+IIF(nTitRel > 1,STR0014,STR0015)+")"	 //"TITULOS"###"TITULO"
@li,053 PSAY nVlTotOri	   Picture TM(nVlTotOri,15)
If lSest  // So processa se existir o campo E2_SEST
	@li,069 PSAY nVlTotSes		Picture TM(nVlTotSes,15)
Endif
@li,085 PSAY nVlTotIrf		Picture TM(nVlTotIrf,15)
@li,101 PSAY nVlTotIss		Picture TM(nVlTotIss,15)
@li,117 PSAY nVlTotIns	   Picture TM(nVlTotIns,15)
@li,133 PSAY nVlTotPis		Picture TM(nVlTotPis,15)
@li,149 PSAY nVlTotCof		Picture TM(nVlTotCof,15)
@li,165 PSAY nVlTotCsl		Picture TM(nVlTotCsl,15)
@li,181 PSAY nVlTotLiq	   Picture TM(nVlTotLiq,15)
li++
@li,000 PSAY Replicate("_",220)
li++
Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³FR865IndR ³ Autor ³ Nilton Pereira		³ Data ³ 24.03.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Monta Indregua para impressao do relat¢rio				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±                 
±±³ Uso		 ³ Generico													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±                           
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/                                              
#IFNDEF TOP
	Static Function FR865IndR(cFilterSE2,cTipoForn,lSest,lConsFil,lSE2Comp,lContRetIRRF)
	Local cFiltro
		
	Default lSest := .F.
	
	cFiltro := 'E2_FILIAL=="'+xFilial("SE2")+'".And.'
	If !Empty(cTipoForn)
		cFiltro += 'E2_TIPO=="'+cTipoForn+'".And.'
	EndIf
	cFiltro += 'E2_FORNECE>="'+mv_par01+'".and.E2_FORNECE<="'+mv_par02+'".And.'
	cFiltro += 'E2_LOJA>="'+mv_par03+'".And.E2_LOJA<="'+mv_par04+'".And.'
	cFiltro += '(E2_ISS>0.OR.E2_INSS>0.OR.E2_PIS>0.OR.E2_COFINS>0.OR.E2_CSLL>0.OR.'
	If lSest
		cFiltro += 'E2_SEST>0.OR.'
	EndIf

	If lContRetIRRF
		cFiltro += '(E2_IRRF > 0 .OR. (E2_VRETIRF > 0 .AND. E2_PRETIRF <> "' + "1" + '"))) .AND. '
	Else
		cFiltro += 'E2_IRRF > 0) .AND.'
	Endif
	// Se considera filiais e SE2 estah compartilhado, realiza filtro por filial origem
	If lConsFil .And. lSE2Comp
		cFiltro += 'E2_FILORIG == "' + cFilAnt + '".And. '
	EndIf
	cFiltro += 'DTOS(E2_VENCREA) >="'+DTOS(mv_par07)+'".And.DTOS(E2_VENCREA)<="'+DTOS(mv_par08)+'".And.'
	cFiltro += 'DTOS(E2_EMISSAO)>="'+DTOS(mv_par05)+'".And.DTOS(E2_EMISSAO)<="'+DTOS(mv_par06)+'".And.'
	cFiltro += 'DTOS(E2_EMISSAO)<="'+DTOS(dDataBase)+'"'
	If !Empty(cFilterSE2)
		cFiltro += ' .And. ' + cFilterSE2
	EndIf
	
	Return cFiltro
#ENDIF


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ AjustaSX1 º Autor ³ Gustavo Henrique  º Data ³ 29/06/2009  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Ajusta perguntas da tabela SX1                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ FINR865                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AjustaSX1(cPerg)
                     
Local aArea		:= GetArea()
Local aTamSX3	:= TamSX3( "E2_FILIAL" )
Local aHelpPor	:= {}
Local aHelpSpa	:= {}
Local aHelpEng	:= {}

DbSelectArea( "SX1" )
SX1->( dbSetOrder( 1 ) )

// Filtra Codigos de Retencao? (mv_par09)
If !SX1->( MsSeek( cPerg + "09" ) )
      
	aHelpPor := {}
	aHelpSpa := {}
	aHelpEng := {}

    Aadd( aHelpPor, "Selecione a opção 'Sim' para que a"   )	
    Aadd( aHelpPor, "geração do relatorio considere os"    )
    Aadd( aHelpPor, "códigos de reteção a serem "          )
    Aadd( aHelpPor, "informados, ou 'Nao', caso contrário.")

    Aadd( aHelpSpa, "Elija la opcion 'Si' para que la "    )
    Aadd( aHelpSpa, "generacion del informe considere los" )
    Aadd( aHelpSpa, "códigos de retencion que se deben"    )
    Aadd( aHelpSpa, "informar, o en caso contrario, "      )
    Aadd( aHelpSpa, "elija 'No'."                          )

    Aadd( aHelpEng, "Select the option 'Yes' for the "     )
    Aadd( aHelpEng, "generation of the report considers "  )
    Aadd( aHelpEng, "the Withholding Codes that are "      )
    Aadd( aHelpEng, "going to be informed, otherwise, "    )
    Aadd( aHelpEng, "select 'No'."                         )

	PutSx1(	cPerg,	"09", "Filtra Cod. de Retencao ?", "¿Filtra Cod. de Retencion?", "Filter Withholding Code?", "mv_ch9", "N", 1, 0, 2, "C", "", "", "", "",;
					"mv_par09", "Sim", "Si", "Yes", "", "Nao", "No", "No", "", "", "", "", "", "", "", "", "", , , , "." + RTrim(cPerg) + "09." )

	PutSX1Help( "P." + RTrim(cPerg) + "09.", aHelpPor, aHelpEng, aHelpSpa )
		
EndIf

// Tipo Fornecedor? (mv_par10)
If !SX1->( MsSeek( cPerg + "10" ) )
      
	aHelpPor := {}
	aHelpSpa := {}
	aHelpEng := {}

    Aadd( aHelpPor, "Selecionar o tipo do fornecedor que" )	
    Aadd( aHelpPor, "será impresso no relatório." )

    Aadd( aHelpSpa, "Elija lo tipo del proveedor que " )
    Aadd( aHelpSpa, "debe ser impreso en informe." )

    Aadd( aHelpEng, "Select the type of supplier to" )
    Aadd( aHelpEng, "be considered in the print." )

	PutSx1(	cPerg,	"10", "Tipo Fornecedor ?", "¿Tipo Proveedor?", "Supplier type ?", "mv_cha", "N", 1, 0, 3, "C", "", "", "", "",;
					"mv_par10", "Pessoa Fisica", "Persona Fisica", "Natual Person", "", "Pessoa Juridica", "Persona Juridica",;
					"Company Entity", "Ambas", "Ambas", "Both", "", "", "", "", "", "", , , , "." + RTrim(cPerg) + "10." )

	PutSX1Help( "P." + RTrim(cPerg) + "10.", aHelpPor, aHelpEng, aHelpSpa )
		
EndIf
             
// Considera Filiais Abaixo? (mv_par11)
If !SX1->( MsSeek( cPerg + "11" ) )
      
	PutSx1(	cPerg,	"11", "Cons.Filiais abaixo ?", "¿Considera Siguientes Suc ?", "Cons.Branches below ?", "mv_chb", "N", 1, 0, 2, "C", "", "", "", "",;
					"mv_par11", "Sim", "Si", "Yes", "", "Nao", "No", "No", "", "", "", "", "", "", "", "", "", , , , "." + RTrim(cPerg) + "11." )
EndIf

// De Filial ? (mv_par12)
If !SX1->( MsSeek( cPerg + "12" ) )

	PutSx1(	cPerg,	"12", "De Filial ?", "¿De Sucursal ?", "From Branch ?", "mv_chc", aTamSX3[3], aTamSx3[1], aTamSX3[2], 2, "G", "", "", "", "",;
					"mv_par12", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", , , , "." + RTrim(cPerg) + "12." )
EndIf				
             
// Ate Filial ? (mv_par12)
If !SX1->( MsSeek( cPerg + "13" ) )

	PutSx1(	cPerg,	"13", "Ate Filial ?", "¿A Sucursal ?", "To Branch ?", "mv_chd", aTamSX3[3], aTamSx3[1], aTamSX3[2], 2, "G", "", "", "", "",;
					"mv_par13", "", "", "", "ZZ", "", "", "", "", "", "", "", "", "", "", "", "", , , , "." + RTrim(cPerg) + "13." )
EndIf

//Gestao                
//Ajuste do help das perguntas 
//Considera Filiais abaixo
//Filial De/Até
If !SX1->( MsSeek(cPerg+"14") )

	aHelpPor := {"Selecione a opcao 'Sim' para que a","geracao do relatorio considere as","filiais a serem informadas nos","parâmetros seguintes, ou 'Nao',","caso contrário.","Esta pergunta não terá efeito em ","ambiente TOPCONNECT / TOTVSDBACCESS."}      
	aHelpSpa := {"Elija la opcion 'Si' para que la ","generacion del informe considere las","sucursales que se deben informar en","los siguientes parametros, o en caso","contrario, elija 'No'.","Esta pregunta no tendra efecto en el ","entorno TOPCONNECT / TOTVSDBACCES"}                    
	aHelpEng := {"Select the option 'Yes' so that the ","report generation can consider the","branches to be entered in the","following parameters.","This question does not work in ","TOPCONNECT/TOTVSDBACCESS environments."}
	//PutSX1Help("P.FIN86511.",aHelpPor,aHelpEng,aHelpSpa,.T.)
	
	aHelpPor := {"Informe o codigo inicial do intervalo","de filiais da sua empresa a serem","considerados na impressao.","Esta pergunta não terá efeito em ","ambiente TOPCONNECT / TOTVSDBACCESS."}
	aHelpSpa := {"Digite el codigo inicial del intervalo","de sucursales de su empresa que se","deben considerar en la impresion.","Esta pregunta no tendra efecto en el ","entorno TOPCONNECT / TOTVSDBACCES"}                    
	aHelpEng := {"Enter the initial code of your ","company's branches interval to ","be considered in the print.","This question does not work in ","TOPCONNECT/TOTVSDBACCESS environments."}
	//PutSX1Help("P.FIN86512.",aHelpPor,aHelpEng,aHelpSpa,.T.)

	aHelpPor := {"Informe o codigo final do intervalo","de filiais da sua empresa a serem","considerados na impressao.","Esta pergunta não terá efeito em ","ambiente TOPCONNECT / TOTVSDBACCESS."}
	aHelpSpa := {"Digite el codigo final del intervalo ","de sucursales de su empresa que se ","deben considerar en la impresion.","Esta pregunta no tendra efecto en el ","entorno TOPCONNECT / TOTVSDBACCES"}                    
	aHelpEng := {"Enter the final code of your ","company's branches interval to ","be considered in the print.","This question does not work in ","TOPCONNECT/TOTVSDBACCESS environments."}
	//PutSX1Help("P.FIN86513.",aHelpPor,aHelpEng,aHelpSpa,.T.)

	//Pergunta 13 - Seleciona Filiais
	aHelpPor := {"Escolha Sim se deseja selecionar ","as filiais. ","Esta pergunta somente terá efeito em","ambiente TOPCONNECT / TOTVSDBACCESS."}			
	aHelpEng := {"Enter Yes if you want to select ","the branches.","This question affects TOPCONNECT / ","TOTVSDBACCESS environment only."}
	aHelpSpa := {"La opción Sí, permite seleccionar ","las sucursales","Esta pregunta solo tendra efecto en el ","entorno TOPCONNECT / TOTVSDBACCESS."}

	PutSx1( "FIN865", "14", "Seleciona Filiais?" ,"¿Selecciona sucursales?" ,"Select Branches?","mv_che","N",1,0,2,"C","","","","S","mv_par14","Sim","Si ","Yes","","Nao","No","No","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

	//PutSX1Help("P.FIN86514.",aHelpPor,aHelpEng,aHelpSpa,.T.)
	
Endif
 
If !SX1->( MsSeek( cPerg + "15" ) )
   PutSX1(cPerg,"15","Data Contabil De "          ,"Data Contabil De"          ,"Data Contabil De"            ,"mv_chf","D",08,0,0,"G",""         ,"","","","mv_par15" ,"","","","","","","","","","","","","","",""," ")
ENDIF
If !SX1->( MsSeek( cPerg + "16" ) )   
   PutSX1(cPerg,"16","Data Contabil Ate"          ,"Data Contabil Ate"          ,"Data Contabil Ate"          ,"mv_chg","D",08,0,0,"G",""         ,"","","","mv_par16" ,"","","","","","","","","","","","","","",""," ")
Endif    

RestArea( aArea )

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ FR865CodRet º Autor ³ Gustavo Henrique º Data ³ 01/07/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Exibe dialogo para selecao dos codigos de retencao caso    º±±
±±º          ³ seja informado "Sim" na pergunta "Filtra Cod. Retencao?"   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ EXPA1 - Vetor com os codigos de retencao selecionados para º±±
±±º          ³         filtro dos valores de impostos impressos.          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Relatorio de Retencao de Impostos - FINR865                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FR865CodRet( aCodRet )
     
Local aArea		:= GetArea()
Local cTitulo	:= ""                     
Local lRet		:= .T.
Local cTabela	:= "37"		// Tabela 37 - Codigos de retencao
Local aBox		:= {}                        
Local nTam		:= TamSX3("E2_CODRET")[1]
                     
Local MvParDef	:= ""

// Posiciona na Tabela 37 para buscar a descricao da tabela do SX5
If SX5->( MsSeek( xFilial("SX5") + "00" + cTabela ) )
   cTitulo := SX5->( Alltrim( Left( X5Descri(), 20 ) ) )
EndIf

// Monta opcoes para selecao de acordo com os itens da tabela do SX5
If SX5->( MsSeek( xFilial("SX5") + cTabela ) )
	Do While SX5->( !Eof() .And. X5_TABELA == cTabela )
		AAdd( aBox, AllTrim( SX5->X5_CHAVE ) + " - " + Alltrim( SX5->( X5Descri() ) ) )
		MvParDef += AllTrim( SX5->X5_CHAVE )
		SX5->( dbSkip() )
	EndDo
EndIf

Do While lRet

	lRet := f_Opcoes(	@aCodRet,;		// uVarRet
						cTitulo,;		// cTitulo
						@aBox,;			// aOpcoes
						MvParDef,;		// cOpcoes
						,;				// nLin1
						,;				// nCol1
						,;				// l1Elem
						nTam,; 			// nTam
						Len( aBox ),;	// nElemRet
						,;				// lMultSelect
						,;				// lComboBox
						,;				// cCampo
						,;				// lNotOrdena
						,;				// NotPesq
						.T.,;			// ForceRetArr
						 )				// F3
			
	If lRet .And. Len( aCodRet ) == 0
		// Quando for informado "Sim" na pergunta "Filtra Códigos de Retenção?", deve ser selecionado ao menos um código de retenção.
		MsgInfo( STR0043 ) 
	Else
		Exit
	EndIf
	
EndDo

RestArea( aArea )

Return lRet



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ FR865FilCRet º Autor ³ Gustavo Henrique º Data ³ 01/07/09  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Realiza filtro por codigo de retencao se informados.       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ EXPA1 - Valores dos impostos do titulo a serem impressos.  º±±
±±º          ³ EXPA2 - Codigos de retencao selecionados no filtro.        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Relacao de Impostos                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FR865FilCRet( aValImp, aCodRet, lTitPai )
			                               
Local cNatImp := ""			   

// Verifica parcelas dos impostos do titulo principal para saber se tem o imposto			   
If !Empty( TRB->PARCPIS )	// Pis
	cNatImp := SuperGetMV( "MV_PISNAT" )
	// Se o codigo de retencao nao foi selecionado para filtro, grava zero no valor do imposto
	If ! FR865PesqImp( TRB->( PREFIXO + NUM + PARCPIS ), aCodRet, cNatImp, lTitPai )
		aValImp[ N_VALPIS ] := 0
	EndIf
Else
	aValImp[ N_VALPIS ] := 0
EndIf

If !Empty( TRB->PARCCOF )	// Cofins
	cNatImp := SuperGetMV( "MV_COFINS" )
	If ! FR865PesqImp( TRB->( PREFIXO + NUM + PARCCOF ), aCodRet, cNatImp, lTitPai )
		aValImp[ N_VALCOF ] := 0   
	EndIf
Else
	If !Empty(aValImp[ N_VALPIS ])
		aValImp[ N_VALPIS ] += aValImp[ N_VALCOF ]
	EndIf
	aValImp[ N_VALCOF ] := 0	
EndIf

If !Empty( TRB->PARCSLL )	// Csll
	cNatImp := SuperGetMV( "MV_CSLL" )
	If ! FR865PesqImp( TRB->( PREFIXO + NUM + PARCSLL ), aCodRet, cNatImp, lTitPai )
		aValImp[ N_VALCSLL ] := 0   
	EndIf
Else
	If !Empty(aValImp[ N_VALPIS ])
		aValImp[ N_VALPIS ] += aValImp[ N_VALCSLL ]
	EndIf 
	aValImp[ N_VALCSLL ] := 0	
EndIf

If !Empty( TRB->PARCIR ) .Or. !Empty( TRB->VALIRRF )	// Irrf
	cNatImp := &( SuperGetMV( "MV_IRF" ) )
	If ! FR865PesqImp( TRB->( PREFIXO + NUM + PARCIR ), aCodRet, cNatImp, lTitPai )
		aValImp[ N_VALIRRF ] := 0   
	EndIf	
ELSE 
	aValImp[ N_VALIRRF ] := 0	
EndIf

// ISS nao tem codigo de retencao, tem codigo de recolhimento pois eh uma contribuicao da previdencia 
// social. Por este motivo, nao imprime o imposto se selecionado filtro por codigos de retencao.
If !Empty( TRB->PARCISS ) .Or. !Empty( TRB->VALISS ) // Iss
	aValImp[ N_VALISS ] := 0  
EndIf

// INSS nao tem codigo de retencao, tem codigo de recolhimento pois eh uma contribuicao da previdencia 
// social. Por este motivo, nao imprime o imposto se selecionado filtro por codigos de retencao.
If !Empty( TRB->PARCINS ) .Or. !Empty( TRB->VALINSS )	// Inss
	aValImp[ N_VALINSS ] := 0
EndIf

If !Empty( TRB->PARCSES )	// Sest
	cNatImp := SuperGetMV( "MV_SEST" )
	If ! FR865PesqImp( TRB->( PREFIXO + NUM + PARCSES ), aCodRet, cNatImp, lTitPai )
		// Para o caso de Sest, verifica tambem se existe codigo de rentecao no titulo pai
		SE2->( dbSetOrder( 1 ) )     
		SE2->( MsSeek( xFilial("SE2") + TRB->( PREFIXO + NUM + PARCELA + TIPO + CODIGO + LOJA ) ) )
		If aScan( aCodRet, SE2->E2_CODRET ) == 0
			aValImp[ N_VALSEST ] := 0
		EndIf	
	EndIf	
EndIf
	
Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ FR865PesqImp º Autor ³ Gustavo Henrique º Data ³ 01/07/09  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Retornar se o valor do imposto deve ser impresso no        º±±
±±º          ³ relatorio a partir dos filtros de codigo de retencao       º±±
±±º          ³ selecionados.                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ EXPC1 - Chave parcial do titulo de imposto (Prefixo,       º±±
±±º          ³         Numero e Parcela do Imposto)                       º±±
±±º          ³ EXPA2 - Vetor com os codigos de retencao para filtro       º±±
±±º          ³ EXPC3 - Natureza do titulo de imposto.                     º±±
±±º          ³ EXPL4 - Indica se existe o campo E2_TITPAI.                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ EXPL1 - Retorna .T. se deve considerar o valor do imposto  º±±
±±º          ³         no relatorio ou .F. caso contrario.                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Relacao de Impostos                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FR865PesqImp( cChaveImp, aCodRet, cNatImp, lTitPai )

Local lRet := .T.

SE2->( dbSetOrder( 1 ) )     
SE2->( MsSeek( xFilial("SE2") + cChaveImp ) )

Do While SE2->( ! Eof() .And. E2_PREFIXO + E2_NUM + E2_PARCELA == cChaveImp )
	// Faz a validacao da chave do titulo pai se existir o campo
	If lTitPai .And. !Empty( SE2->E2_TITPAI )
		If AllTrim( SE2->E2_TITPAI ) == AllTrim( TRB->( PREFIXO + NUM + PARCELA + TIPO + CODIGO + LOJA ) ) 		   	
		   	If 	AllTrim( SE2->E2_NATUREZ ) == AllTrim( cNatImp ) .And. aScan( aCodRet, SE2->E2_CODRET ) == 0		   	
				lRet := .F.
				Exit 
			ElseIf aScan( aCodRet, SE2->E2_CODRET ) == 0                
					lRet := .F.	
				Else			 	                                           			
					lRet := .T.
			EndIf			                                 			
		EndIf                                                                                     
	Else            
		// Caso nao exista o campo ou existe mas esta vazio, verifica a natureza do imposto
		If AllTrim( SE2->E2_NATUREZ ) $ cNatImp .And. aScan( aCodRet, SE2->E2_CODRET ) == 0
			lRet := .F.
			Exit
		EndIf
	EndIf	
	SE2->( dbSkip() )
EndDo                  

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ FR865Cabec º Autor ³ Gustavo Henrique º Data ³  07/02/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Imprime o cabecalho do relatorio com os codigos de retencaoº±±
±±º          ³ selecionados, se informado filtro por codigo de retencao.  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Relacao de Impostos                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FR865Cabec( nMVComp, nRegSM0, lFilCRet, cCodRet )

Local nAtuSM0 := SM0->(Recno())

SM0->( dbGoto(nRegSM0) )
cabec( titulo, cabec1, cabec2, nomeprog, tamanho, nMVComp )
SM0->( dbGoTo(nAtuSM0) )

If lFilCRet          
	if tamanho == 'P'
		if len(cCodRet) > 130
			@li, 000 PSAY STR0044 + Substr(cCodRet,1,130)	// Codigos de Retencao Selecionados: 
			li++
			@li, 000 PSAY Space(len(STR0044)) + Substr(cCodRet,130,300)		// Codigos de Retencao Selecionados: 
			li++		
		Else
			@li, 000 PSAY STR0044 + cCodRet		// Codigos de Retencao Selecionados: 
			li++
		endiF		
	Else	
		if len(cCodRet) > 185
			@li, 000 PSAY STR0044 + Substr(cCodRet,1,185)	// Codigos de Retencao Selecionados: 
			li++
			@li, 000 PSAY Space(len(STR0044)) + Substr(cCodRet,185,300)		// Codigos de Retencao Selecionados: 
			li++		
		Else
			@li, 000 PSAY STR0044 + cCodRet		// Codigos de Retencao Selecionados: 
			li++
		endiF		
	EndIf
	@li,000 PSAY Replicate("_",220)
	li+=2
EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FR865AbreSM0³ Autor ³ Mauricio Pequim Jr  ³ Data ³ 16/10/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna um array com as informacoes das filias das empresas ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FR865AbreSM0(aSelFil)               

Local aArea			:= SM0->( GetArea() )
Local aRetSM0		:= {}
Local nLaco			:= 0
			
aRetSM0	:= FWLoadSM0()

If Len(aRetSM0) != Len(aSelFil)

	For nLaco := Len(aRetSM0) To 1 Step -1
		cFilx := aRetSm0[nLaco,SM0_CODFIL]
		nPosFil := Ascan(aSelFil,aRetSm0[nLaco,SM0_CODFIL])
	
		If nPosFil == 0 .Or. cEmpAnt != aRetSM0[nLaco,SM0_GRPEMP]
			ADel(aRetSM0,nLaco)
			aSize(aRetSM0, Len(aRetSM0)-1)
		Endif
	Next
Endif

aSort(aRetSm0,,,{ |x,y| x[SM0_CODFIL] < y[SM0_CODFIL] } )
RestArea( aArea )

Return aClone(aRetSM0)

