#INCLUDE "RWMAKE.Ch"
#include "TOPCONN.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ADGPE07   ºAutor  ³Adalberto Althoff   º Data ³  11/04/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ RELATORIO DE ETIQUETA DE CONTRATO DE TRABALHO (GRAFICA)    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ ADORO                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

USER FUNCTION ADGPE07()

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'RELATORIO DE ETIQUETA DE CONTRATO DE TRABALHO (GRAFICA)')

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define variaveis                                                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cDesc1  := "Este relatorio tem o objetivo de imprimir a"
cDesc2  := "etiqueta de contrato de trabalho "
cDesc3  := ""
cString := 'SRA'
cTamanho := 'P'
Titulo  := 'ETIQUETA DE CONTRATO DE TRABALHO'
wnRel   := 'AAJ0035'
limite    :=80
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para montar Get.                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Private aReturn         := { "Zebrado", 1,"Administracao", 2, 2, 1,"",1 }
Private cPerg           := "GPR320"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Janela Principal                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cTitulo:="Etiqueta de contrato de trabalho"
cText1:="Neste relatorio sera impresso a etiqueta de contrato de trabalho"

Pergunte(cPerg,.f.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
wnRel := SetPrint(cString, wnRel, cPerg, Titulo, cDesc1, cDesc2, cDesc3, .F.,, .F.,cTamanho)

nView    := 1

If nLastKey == 27
	Set Filter To
	Return Nil
Endif

SetDefault(aReturn, cString)

If nLastKey == 27
	Set Filter To
	Return Nil
Endif

RptStatus({|lEnd| AAJ35Imp(@lEnd, wnRel,cTamanho, Titulo)}, Titulo)

Set Filter To

Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AAJ35Imp(lEnd, wnRel, cTamanho, Titulo)

Local lImpAug :=.T.
Local cTxtFoot := Space(10)
Local cNomAudLid
Local cNomeAud

Private nLin :=01
Private nREG := 0
Private m_pag   := 1
Private cCabec1 := ""
Private cCabec2 :=  ""
Private nPag    := 1
Private lPagPrint := .T.
Private lInicial := .F.
Private nEspLarg := GetMv("MV_ETCEL") // espaçamento entre etiquetas na largura (em pixels)
Private nEspAlt  := GetMv("MV_ETCEA") // espaçamento entre etiquetas na altura  (em pixels)
Private nVertMax := GetMv("MV_ETCQL") // Qtde vertical de etiquetas por página
Private nVertical:= 1
Private nHorizMax:= mv_par13
Private nHorizont:= 1
Private cEmpEtiq := SM0->M0_CODIGO


oFont1    := TFont():New( "Arial",,08,,.F.,,,,,.f. )
oFont2    := TFont():New( "Arial",,10,,.t.,,,,,.f. )
oFont3    := TFont():New( "Arial",,12,,.t.,,,,.T.,.f. )
oFont4    := TFont():New( "Arial",,14,,.t.,,,,.T.,.f. )

If !lInicial
	lInicial := .T.
	oprn:=TMSPrinter():New( Titulo )
Endif

DBSELECTAREA("SM0")
nRecM0 := recno()

cQuery := "Select RA_FILIAL,RA_MAT,RJ_DESC,RA_ADMISSA,RA_SALARIO,RJ_CODCBO,RA_CATFUNC,RA_SINDICA,RA_SITFOLH "
cQuery += "FROM "+retsqlname("SRA")+","+retsqlname("SRJ")+" "
cQuery += "WHERE RA_FILIAL=RJ_FILIAL AND RA_CODFUNC=RJ_FUNCAO AND "+retsqlname("SRA")+".D_E_L_E_T_<>'*' AND "
cQuery += "RA_FILIAL  >= '" + MV_PAR01 + "' AND "
cQuery += "RA_FILIAL  <= '" + MV_PAR02 + "' AND "
cQuery += "RA_CC      >= '" + MV_PAR03 + "' AND "
cQuery += "RA_CC      <= '" + MV_PAR04 + "' AND "
cQuery += "RA_MAT     >= '" + MV_PAR05 + "' AND "
cQuery += "RA_MAT     <= '" + MV_PAR06 + "' AND "
cQuery += "RA_NOME    >= '" + MV_PAR07 + "' AND "
cQuery += "RA_NOME    <= '" + MV_PAR08 + "' AND "
cQuery += "RA_ADMISSA >= '" + DTOS(MV_PAR10) + "' AND "
cQuery += "RA_ADMISSA <= '" + DTOS(MV_PAR11) + "' "


If Select("AJ35") > 0
	DbSelectArea("AJ35")
	DbCloseArea()
Endif
TCQUERY cQuery NEW ALIAS "AJ35"
DbSelectArea("AJ35")
DBGOTOP()


lPagPrint := .T.
oprn:StartPage() // Inicia uma nova pagina


do while !eof()
	if mv_par12 != '99'
		if RA_SINDICA != MV_PAR12
			DBSKIP()
			LOOP
		ENDIF
	ENDIF
	IF !(RA_CATFUNC $ MV_PAR09)
		DBSKIP()
		LOOP
	ENDIF
	IF !(RA_SITFOLH $ MV_PAR16)
		DBSKIP()
		LOOP
	ENDIF
	
	nREG++
	
	*-----------\/----lógica da impressão
	SM0->(dbseek(cEmpEtiq+AJ35->RA_FILIAL))
	
	nLP := ((nVertical-1)*nEspAlt ) + 170
	nCP := ((nHorizont-1)*nEspLarg) + 40
		
	//oprn:Say(nLP,nCP,RA_FILIAL+'-'+RA_MAT,oFont3,100)

    cLinhaA := SM0->M0_NOMECOM
    cLinhaB := SM0->M0_ENDCOB
    cLinhaC := ALLTRIM(SM0->M0_CIDCOB)+' - '+SM0->M0_ESTCOB
    cLinhaC1:= 'CGC '+Transform(SM0->M0_CGC,"@R 99.999.999/9999-99")    
    cLinhaD := 'Cargo: ' + ALLTRIM(RJ_DESC) + ', CBO ' + RJ_CODCBO               
    cLinhaE := 'Data Admissao: '+DTOC(StoD(RA_ADMISSA)) 
    cLinhaE1:= 'Reg.: '+RA_MAT 

    xSal := ALLTRIM(STR(RA_SALARIO*100))                 
    xSal := SUBS(xSal,1,len(xSal)-2)+','+right(xSal,2)
    xSalEx := '('+alltrim(extenso(RA_SALARIO))+')'       
    nQuebra := 0
    
    cLinhaF := 'Remuneração R$ '+xSal+' '+'por mes'
    cLinhaF1:= xSalEx
    
    //if len(cLinhaF1)>40
    if len(cLinhaF1)>35
    	//i := 39
    	i := 34
    	do while i>1
    		if subs(cLinhaF1,i,1)==' '
    			nQuebra := i
    			exit
    		endif
    		i--
    	enddo	
    	cLinhaG := subs(cLinhaF1,nQuebra+1)
    	cLinhaF1 := left(cLinhaF1,nQuebra-1)
    else
    	cLinhaG := ''
    endif		
    nQuebra := 0
    //if len(cLinhaG)>40
    if len(cLinhaG)>35
    	//i := 39
    	i := 34
    	do while i>1
    		if subs(cLinhaG,i,1)==' '
    			nQuebra := i
    			exit
    		endif
    		i--
    	enddo	
    	cLinhaH := subs(cLinhaG,nQuebra+1)
    	cLinhaG := left(cLinhaG,nQuebra-1)
    else
    	cLinhaH := ''
    endif
    		

	oprn:Say(nLP+0100,nCP,cLinhaA,oFont4,100)
	oprn:Say(nLP+0150,nCP,cLinhaB,oFont2,100)
	oprn:Say(nLP+0200,nCP,cLinhaC,oFont2,100)
	oprn:Say(nLP+0250,nCP,cLinhaC1,oFont2,100)
	oprn:Say(nLP+0300,nCP,cLinhaD,oFont2,100)
	oprn:Say(nLP+0350,nCP,cLinhaE,oFont2,100)
	oprn:Say(nLP+0400,nCP,cLinhaE1,oFont2,100)
	oprn:Say(nLP+0450,nCP,cLinhaF,oFont2,100)
	oprn:Say(nLP+0500,nCP,cLinhaF1,oFont2,100)
	oprn:Say(nLP+0550,nCP,cLinhaG,oFont2,100)
	oprn:Say(nLP+0600,nCP,cLinhaH,oFont2,100)

	//oprn:Say(nLP+0650,nCP+300,SM0->M0_NOMECOM,oFont1,100)	

	nHorizont++

	if nHorizont >  nHorizMax
		nHorizont := 1
		nVertical++
	endif
	if nVertical > 	nVertMax
		nVertical := 1
		oprn:EndPage()
		oprn:StartPage()
	endif
		
	*-----------/\----lógica da impressão
	
	
	
	dbselectarea("AJ35")
	dbskip()
enddo







//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Devolve a condicao original do arquivo principal                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Set device to Screen
IF nREG <= 0
	Msginfo("Nao ha registro validos para Relatorio")
	dbSelectArea("AJ35")
	DBCLOSEAREA()
	RETURN
ENDIF
dbSelectArea("AJ35")
DBCLOSEAREA()
IF nView == 1
	oprn:Preview()  // Visualiza antes de imprimir
Else
	oprn:Print() // Imprime direto na impressora default Protheus
Endif



MS_FLUSH()

DBSELECTAREA("SM0")
dbgoto(nRecM0)

Return(nil)
