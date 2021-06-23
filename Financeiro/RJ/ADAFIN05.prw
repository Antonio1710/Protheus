#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
&&#INCLUDE "RWMAKE.CH"

User Function ADAFIN05()

Local cArqTMP1 		:= ""
Local cArqTMP2 		:= ""
Local aTitBrw  		:= {}    
Local oDlg5	
Local aAltera		:= {}  

Private aAreaZF		:= GetArea()
Private bOk			:= {||Processa({||fAtualiza(oDlg5) } ) } &&{||Processa({||fAtualiza(oDlg) } ) } 
&&Private aHeader		:= {}
&&Private aCols		:= {}
&&Private oGetDados
Private cFornec		:= Criavar("ZAH_FORNEC",.F.)
Private cCessio		:= Criavar("ZAH_CESSIO",.F.)
Private cLojaCess	:= Criavar("ZAH_LOJACE",.F.)
Private nValor		:= Criavar("ZAH_VALOR",.F.)
Private nDesagi		:= Criavar("ZAH_DESAGI",.F.)
Private nCredit		:= Criavar("ZAH_CREDIT",.F.)
Private nIndice		:= Space(03)
Private cCond		:= Criavar("ZAH_COND",.F.)
Private nSaldo		:= Criavar("ZAH_SALDO",.F.)
Private cNumero		:= Criavar("ZAH_NUMERO",.F.)
Private cTipo		:= Criavar("ZAH_TIPO",.F.)
Private aOpc1		:= {Space(30),"000=Resgate Exec. Judicial","001=Opcao 1        ","002=Opcao 2      "}

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')
                        
Define MsDialog oDlg5 Title "Inclusao de Obrigacoes a Pagar - " + Alltrim(SM0->M0_NOME) From 00,00 To 36,86 Style 128 Of oMainWnd 
oDlg5:lMaximized	:= .T.
oDlg5:lEscClose	:= .F.

&&DEFINE MSDIALOG oDlg2 TITLE "Inclusao de Obrigacoes a Pagar" PIXEL FROM 010 , 010 TO 230 , 450 of oMainWnd

@ 020,002 SAY 'Fornecedor'									SIZE 060,011 	OF oDlg5 PIXEL
@ 020,102 SAY 'Cessionario'									SIZE 060,011 	OF oDlg5 PIXEL
@ 020,202 SAY 'Loja Cess.'									SIZE 060,011 	OF oDlg5 PIXEL
@ 020,040 MSGET cFornec			F3 "SA2"					SIZE 060,011 	OF oDlg5 PIXEL 
@ 020,140 MSGET cCessio			F3 "SA2"					SIZE 060,011 	OF oDlg5 PIXEL 
@ 020,240 MSGET cLojaCess		         					SIZE 060,011 	OF oDlg5 PIXEL 

@ 040,002 SAY 'Vlr. Original'								SIZE 060,011 	OF oDlg5 PIXEL
@ 040,102 SAY 'Vlr. Desagio'								SIZE 060,011 	OF oDlg5 PIXEL
@ 040,202 SAY 'Vlr. Cred. Inic.'							SIZE 060,011 	OF oDlg5 PIXEL
@ 040,040 MSGET nVALOR 			PICTURE '@E 999,999,999.99'		SIZE 060,011 	OF oDlg5 PIXEL 
@ 040,140 MSGET nDESAGI			PICTURE '@E 999,999,999.99'		SIZE 060,011 	OF oDlg5 PIXEL 
@ 040,240 MSGET nCREDIT			PICTURE '@E 999,999,999.99'		SIZE 060,011 	OF oDlg5 PIXEL 

@ 060,002 SAY 'Indice Correc.'								SIZE 060,011 	OF oDlg5 PIXEL
@ 060,102 SAY 'Cond.Pagto.'									SIZE 060,011 	OF oDlg5 PIXEL
@ 060,202 SAY 'Saldo Atualiz.'								SIZE 060,011 	OF oDlg5 PIXEL

@ 060,040 COMBOBOX nIndice		ITEMS aOpc1 				SIZE 060,011 	OF oDlg5 PIXEL 
&&@ 060,040 MSGET nINDICE		F3 "ZAG"  					SIZE 060,011 	OF oDlg PIXEL 
@ 060,140 MSGET cCOND			F3 "SE4" 					SIZE 060,011 	OF oDlg5 PIXEL 
@ 060,240 MSGET nSaldo		 	PICTURE '@E 99,999,999.99'	SIZE 060,011 	OF oDlg5 PIXEL 
&&@ 060,240 SAY ZAH->ZAH_SALDO 	PICTURE '@E 99,999,999.99'	SIZE 080,011 	OF oDlg PIXEL 

@ 080,002 SAY 'Numero'										SIZE 060,011 	OF oDlg5 PIXEL
@ 080,102 SAY 'Tipo'										SIZE 060,011 	OF oDlg5 PIXEL
@ 080,040 MSGET cNUMERO		   VALID fNumTit()				SIZE 060,011 	OF oDlg5 PIXEL 
@ 080,140 MSGET cTIPO						 				SIZE 120,011 	OF oDlg5 PIXEL 

Activate MsDialog oDlg5 On Init fEnchBar(oDlg5,bOk) Centered                  

&&oGetDados := MsNewGetDados():New(150,000,310,630,GD_UPDATE+ GD_DELETE ,"AllwaysTrue()","AllwaysTrue()", "" ,aAltera,,Len(aCols),"AllwaysTrue()","AllwaysTrue()","AllwaysTrue()",oDlg,aHeader,aCols)

&&Activate MsDialog oDlg On Init fEnchBar(oDlg,bOk) Centered                  

RestArea(aAreaZF)
Return()

Static Function fAtualiza(oDlg2)

Local lRet			:= .T.
Local nPosFunc		:= 0 
Local aParcela		:= {}
&& Processamento e geracao de titulos/parcelas conf. modelo de importacao de arquivo em formato TXT.
&&ProcRegua(28)

	RecLock("ZAH",.T.)
		ZAH->ZAH_FILIAL		:= xFilial("ZAH")
		ZAH->ZAH_NUMERO		:= StrZero(Val(cNumero),9)
		ZAH->ZAH_FORNEC		:= cFornec
		ZAH->ZAH_LOJA		:= '01'
		ZAH->ZAH_CESSIO		:= cCessio
		ZAH->ZAH_LOJACE		:= iif(Empty(cLojaCess),'01',cLojaCess)
		ZAH->ZAH_VALOR		:= nValor
		ZAH->ZAH_DESAGI		:= nDesagi
		ZAH->ZAH_CREDIT		:= nCredit
		ZAH->ZAH_INDICE		:= nIndice
		ZAH->ZAH_COND		:= cCond
		ZAH->ZAH_SALDO		:= nSaldo
		ZAH->ZAH_TIPO		:= cTipo
	MsUnlock("ZAH")

	&& Calculo parcelas e geracao de titulos a pagar.
 	aParcela := Condicao(nCredit,"RJ1",,dDataBase) 

	&&IncProc()
	
	If Len(aParcela) > 0 
		ProcRegua(Len(aParcela))
		cParcela := "001"
		For n2:= 1 to Len(aParcela)
			
			IncProc("Incluindo parcelas financeiras. Aguarde...")
			
			cHist := 'CRED:'+cFornec+' CESS:' +cCessio
			
			aVetor:={   {"E2_FILIAL"   	,xFilial("SE2")				,NIL},;
						{"E2_PREFIXO" 	,'ADR'		 	 			,NIL},;	
						{"E2_NUM"     	,StrZero(Val(cNumero),9)	,NIL},;
						{"E2_PARCELA" 	,cParcela 		 			,NIL},;
						{"E2_TIPO"    	,"RJ"          				,NIL},;
						{"E2_NATUREZ" 	,"26001"					,NIL},;
						{"E2_DEBITO" 	,"221510006"				,NIL},;
						{"E2_FORNECE" 	,Iif(Empty(cCessio),cFornec,cCessio)	  	,NIL},;
						{"E2_LOJA"    	,iif(Empty(cLojaCess),'01',cLojaCess)		,NIL},;
						{"E2_EMISSAO" 	,dDataBase		 			,NIL},;
						{"E2_VENCTO"  	,aParcela[n2,01] 			,NIL},;
						{"E2_VENCREA"  	,DataValida(aParcela[n2,01]),NIL},;
						{"E2_VALOR"   	,aParcela[n2,02] 		 	,NIL},;
						{"E2_HIST"   	,cHist 					 	,NIL},;
						{"E2_FILORIG" 	,xFilial("SE2")				,NIL}}	  

			lMsErroAuto := .F.
							
			MSExecAuto({|x,y| FINA050(x,y)},aVetor,3) 
	
			If lMsErroAuto
				Mostraerro()  
			Else                           
				nCorrec := 0
				RecLock("ZAF",.T.)
					ZAF->ZAF_FILIAL		:= xFilial("ZAF")
					ZAF->ZAF_NUMERO		:= StrZero(Val(cNumero),9)
					ZAF->ZAF_FORNEC		:= cFornec
					ZAF->ZAF_LOJA		:= '01'
					ZAF->ZAF_CESSIO		:= cCessio
					ZAF->ZAF_LOJACE		:= iif(Empty(cLojaCess),'01',cLojaCess)
					ZAF->ZAF_PREFIX		:= SE2->E2_PREFIXO
					ZAF->ZAF_PARCEL		:= SE2->E2_PARCELA
					ZAF->ZAF_VENCTO		:= SE2->E2_VENCTO
					ZAF->ZAF_VALOR		:= SE2->E2_VALOR
					ZAF->ZAF_CORREC		:= nCorrec
					ZAF->ZAF_SALDO		:= SE2->E2_SALDO
					ZAF->ZAF_BAIXA		:= SE2->E2_BAIXA
							
				MsUnlock("ZAF")	
			Endif                  									
			cParcela := Soma1(cParcela)	

		Next n2
	EndIf	



oDlg2:End()							&& Finaliza tela de chamada principal
RestArea(aAreaZF)
Return()



Static Function fEnchBar(oDlg2,bOk)

Local oBar, oBtOk

Define ButtonBar oBar SIZE 25,25 3D TOP Of oDlg2                                             

Define Button Resource "S4WB008N"	Of oBar Group	Action Calculadora()		&&Tooltip "Calc"
&&Define Button Resource "S4WB010N"	Of oBar 		Action OurSpool() 			Tooltip "Spool"
&&Define Button Resource "S4WB016N"	Of oBar Group	Action HelProg() 			Tooltip "Help"
Define Button Resource "OK"			Of oBar Group	Action Eval(bOk)			&&Tooltip "Ok"
Define Button Resource "Cancel"		Of oBar Group	Action oDlg2:End()			&&Tooltip "Cancel"
	
Return()



Static Function fNumTit()
Local aArea := GetArea()
Local lRet  := .T.
Local cQuery:= ''

cQuery := " SELECT * FROM " + RETSQLNAME("SE2") + "  "
cQuery += " WHERE D_E_L_E_T_ = '' AND E2_NUM = '" + StrZero(Val(CNUMERO),9) + "' " 
cQuery += " AND E2_PREFIXO = 'ADR' "
/*
If Empty(cFornec)
	cQuery += " AND E2_FORNECE = '" + cCessio + "'  "
Else
	cQuery += " AND E2_FORNECE = '" + cCessio + "'  "
Endif	
*/

Tcquery cQuery New Alias "TSE2" 

Count to nTot
TSE2->(dbCloseArea())
If nTot > 0
	lRet := .F.
	MsgInfo("Ja existe titulo com numero cadastrado. Informe um numero valido!!")
	cNumero := Space(09)
EndIf

RestArea(aArea)
Return(lRet)