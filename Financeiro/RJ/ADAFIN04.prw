#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

User Function ADAFIN04()

Local cArqTMP1 		:= ""
Local cArqTMP2 		:= ""
Local aTitBrw  		:= {}
Local bOk			:= {|| fAtualiza(oDlg,aHeader,oGetDados) }                                                  
Local aAltera		:= {} &&{ "VENDDEST" } 
Local cForn			:= ''
Local cCess			:= ''

Private aHeader		:= {}
Private aCols		:= {}
Private oGetDados
Private oDlg	
Private nSaldo		:= fRetSaldo()
/*
dbSelectArea("ZAH")
ZAH->(dbSeek(xFilial("ZAH")+ZAF->ZAF_NUMERO))
cZAH_NUMERO := ZAH->ZAH_NUMERO
cZAH_FORNEC := ZAH->ZAH_FORNEC
cZAH_LOJA	:= ZAH->ZAH_LOJA
cZAH_CESSIO	:= ZAH->ZAH_CESSIO
cZAH_LOJA	:= ZAH->ZAH_LOJA
cZAH_VALOR	:= ZAH->ZAH_VALOR
cZAH_DESAGI := ZAH->ZAH_DESAGI
cZAH_CREDIT := ZAH->ZAH_CREDIT
cZAH_INDICE := ZAH->ZAH_INDICE
cZAH_COND	:= ZAH->ZAH_COND
cZAH_SALDO  := ZAH->ZAH_SALDO
*/

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

fSelect()
fAjuste()
                        
Define MsDialog oDlg Title "Consulta de Obrigacoes a Pagar - " + Alltrim(SM0->M0_NOME) From 00,00 To 36,86 Style 128 Of oMainWnd 
oDlg:lMaximized	:= .T.
oDlg:lEscClose	:= .F.

&&DEFINE MSDIALOG oDlg2 TITLE "Obrigacoes a Pagar" PIXEL FROM 010 , 010 TO 230 , 450 of oMainWnd

cForn := Posicione("SA2",1,xFilial("SA2")+TZAH->ZAH_FORNEC,"A2_NOME")
cCess := Posicione("SA2",1,xFilial("SA2")+TZAH->ZAH_CESSIO,"A2_NOME")

@ 020,002 SAY 'Fornecedor'									SIZE 080,011 	OF oDlg PIXEL
@ 020,202 SAY 'Cessionario'									SIZE 080,011 	OF oDlg PIXEL
@ 020,040 SAY TZAH->ZAH_FORNEC + ' - ' + cForn				SIZE 140,011 	OF oDlg PIXEL 
@ 020,240 SAY TZAH->ZAH_CESSIO + ' - ' + cCess				SIZE 140,011 	OF oDlg PIXEL 

@ 030,002 SAY 'Vlr. Original'								SIZE 080,011 	OF oDlg PIXEL
@ 030,102 SAY 'Vlr. Desagio'								SIZE 080,011 	OF oDlg PIXEL
@ 030,202 SAY 'Vlr. Cred. Inic.'							SIZE 080,011 	OF oDlg PIXEL
@ 030,040 SAY TZAH->ZAH_VALOR	PICTURE '@E 999,999,999.99'		SIZE 080,011 	OF oDlg PIXEL 
@ 030,140 SAY TZAH->ZAH_DESAGI	PICTURE '@E 999,999,999.99'		SIZE 080,011 	OF oDlg PIXEL 
@ 030,240 SAY TZAH->ZAH_CREDIT	PICTURE '@E 999,999,999.99'		SIZE 080,011 	OF oDlg PIXEL 

@ 040,002 SAY 'Indice Correc.'								SIZE 080,011 	OF oDlg PIXEL
@ 040,102 SAY 'Cond.Pagto.'									SIZE 080,011 	OF oDlg PIXEL
@ 040,202 SAY 'Saldo Atualiz.'								SIZE 080,011 	OF oDlg PIXEL
@ 040,040 SAY TZAH->ZAH_INDICE			 					SIZE 080,011 	OF oDlg PIXEL 
@ 040,140 SAY TZAH->ZAH_COND				 					SIZE 080,011 	OF oDlg PIXEL 
@ 040,240 SAY nSaldo		 	PICTURE '@E 99,999,999.99'	SIZE 080,011 	OF oDlg PIXEL 
&&@ 060,240 SAY ZAH->ZAH_SALDO 	PICTURE '@E 99,999,999.99'	SIZE 080,011 	OF oDlg PIXEL 

@ 050,002 SAY 'Numero'										SIZE 080,011 	OF oDlg PIXEL
@ 050,102 SAY 'Tipo'										SIZE 080,011 	OF oDlg PIXEL
//@ 050,040 SAY TZAF->ZAF_NUMERO			 					SIZE 080,011 	OF oDlg PIXEL 
@ 050,040 SAY TZAH->ZAH_NUMERO			 					SIZE 080,011 	OF oDlg PIXEL 
@ 050,140 SAY TZAH->ZAH_TIPO			 					SIZE 120,011 	OF oDlg PIXEL 

&&Activate MsDialog oDlg On Init fEnchBar(oDlg,bOk) Centered                  

oGetDados := MsNewGetDados():New(060,000,300,630,GD_UPDATE+ GD_DELETE ,"AllwaysTrue()","AllwaysTrue()", "" ,aAltera,,Len(aCols),"AllwaysTrue()","AllwaysTrue()","AllwaysTrue()",oDlg,aHeader,aCols)

Activate MsDialog oDlg On Init fEnchBar(oDlg,bOk) Centered                  


TZAH->(dbCloseArea())
TZAF->(dbCloseArea())

&&TMP1->(dbCloseArea())
&&FErase(cArqTMP1+GetDBExtension())
&&FErase(cArqTMP1+OrdBagExt())

Return()



Static Function fAjuste()

Local cQuery	:= ""
Local nUsado	:= 0
Local cCond	:= "ZAF_NUMERO/ZAF_PARCEL/ZAF_FORNEC/ZAF_CESSIO/ZAF_VENCTO/ZAF_VALOR/ZAF_CORREC/ZAF_SALDO/ZAF_BAIXA"
&&Local cCond		:= "ZAF_NUMERO/ZAF_PREFIX/ZAF_PARCEL"
Local nPosOper	:= 0

nUsado	:= 0
aHeader	:= {}
aCols	:= {}
             

cCond		:= "E1_PREFIXO"

DbSelectArea("SX3")
Set Filter To
SX3->(DbSeek("SE1"))

While SX3->(!Eof()) .And. (X3_ARQUIVO=="SE1")

	If Alltrim(X3_CAMPO) $ cCond
	
		If X3USO(X3_USADO) .And. cNivel >= X3_NIVEL
    		nUsado:=nUsado+1   
	    		
        	aAdd(aHeader,{	AllTrim(X3_TITULO), X3_CAMPO, "@!",;
			   	X3_TAMANHO, X3_DECIMAL, '',;
			   	X3_USADO, X3_TIPO, X3_F3, X3_ARQUIVO, X3_CONTEXT } )
		Endif
	Else
		SX3->(DbSkip())
		Loop
	Endif
	
	SX3->(DbSkip())
EndDo

cCond		:= "E2_NUMERO/E2_PARCELA"

DbSelectArea("SX3")
SX3->(DbSeek("SE2"))
While SX3->(!Eof()) .And. (X3_ARQUIVO=="SE2")

	If Alltrim(X3_CAMPO) $ cCond
	
		If X3USO(X3_USADO) .And. cNivel >= X3_NIVEL
    		nUsado:=nUsado+1   
	    		
        	aAdd(aHeader,{	AllTrim(X3_TITULO), X3_CAMPO, X3_PICTURE,;
			   	X3_TAMANHO, X3_DECIMAL, X3_VALID,;
			   	X3_USADO, X3_TIPO, X3_F3, X3_ARQUIVO, X3_CONTEXT } )
		Endif
	Else
		SX3->(DbSkip())
		Loop
	Endif
	
	SX3->(DbSkip())
EndDo

cCond	:= "ZAF_FORNEC/ZAF_CESSIO/ZAF_VENCTO/ZAF_VALOR/ZAF_CORREC/ZAF_SALDO/ZAF_BAIXA"

DbSelectArea("SX3")
SX3->(DbSeek("ZAF"))
While SX3->(!Eof()) .And. (X3_ARQUIVO=="ZAF")

	If Alltrim(X3_CAMPO) $ cCond
	
		If X3USO(X3_USADO) .And. cNivel >= X3_NIVEL
    		nUsado:=nUsado+1   
	    		
        	aAdd(aHeader,{	AllTrim(X3_TITULO), X3_CAMPO, X3_PICTURE,;
			   	X3_TAMANHO, X3_DECIMAL, X3_VALID,;
			   	X3_USADO, X3_TIPO, X3_F3, X3_ARQUIVO, X3_CONTEXT } )
		Endif
	Else
		SX3->(DbSkip())
		Loop
	Endif
	
	SX3->(DbSkip())
EndDo

TZAF->(dbGoTop())

While TZAF->(!Eof())				&& Preenche aCols

		aAux 	:= {}

		AAdd(aAux, "ADR") 		        

		AAdd(aAux, Alltrim(TZAF->ZAF_NUMERO))
		AAdd(aAux, Alltrim(TZAF->ZAF_PARCEL))

		AAdd(aAux, Stod(TZAF->ZAF_VENCTO))
		AAdd(aAux, TZAF->ZAF_VALOR)			
		AAdd(aAux, TZAF->ZAF_CORREC) 
		/*
		If TZAF->ZAF_SALDO == 0
			AAdd(aAux, TZAF->ZAF_SALDO)
		Else
			AAdd(aAux, TZAF->ZAF_VALOR+TZAF->ZAF_CORREC)
		EndIf	
		*/                             
		AAdd(aAux, TZAF->ZAF_SALDO)
		AAdd(aAux, Stod(TZAF->ZAF_BAIXA))			
		AAdd(aAux, TZAF->ZAF_FORNEC)
		AAdd(aAux, TZAF->ZAF_CESSIO)			

		AAdd(aAux, .F.)							&& Indica que o registro nao foi deletado
		AAdd(aCols, aAux)       				&& incrementa Acols

	TZAF->(DbSkip())

EndDo

Return()


Static Function fAtualiza(oDlg1,aHeader1,oGetDados1)

Local lRet			:= .T.
Local nPosFunc		:= 0 

&&fAtuHist()							&& Executa atualizacao na tabela de ocorrencias 

oDlg1:End()							&& Finaliza tela de chamada principal

Return(lRet)



Static Function fEnchBar(oDlg1,bOk)

Local oBar, oBtOk

Define ButtonBar oBar SIZE 25,25 3D TOP Of oDlg1                                             

Define Button Resource "S4WB008N"	Of oBar Group	Action Calculadora()		&&Tooltip "Calc"
&&Define Button Resource "S4WB010N"	Of oBar 		Action OurSpool() 			Tooltip "Spool"
&&Define Button Resource "S4WB016N"	Of oBar Group	Action HelProg() 			Tooltip "Help"
Define Button Resource "OK"			Of oBar Group	Action Eval(bOk)			&&Tooltip "Ok"
Define Button Resource "Cancel"		Of oBar Group	Action oDlg1:End()			&&Tooltip "Cancel"
	
Return()

Static Function fSelect()
Local cQuery := ""

cQuery := "SELECT * FROM " + RETSQLNAME("ZAF") + "   "
cQuery += "WHERE  D_E_L_E_T_ = '' AND ZAF_FILIAL = '" + XFILIAL("ZAF") + "'  "
cQuery += "AND ZAF_NUMERO = '" + ZAF->ZAF_NUMERO + "'  " 
cQuery += "ORDER BY ZAF_NUMERO,ZAF_PARCEL "

TcQuery cQuery New Alias "TZAF"

TZAF->(dbGoTop())

cQuery := "SELECT * FROM " + RETSQLNAME("ZAH") + "   "
cQuery += "WHERE  D_E_L_E_T_ = '' AND ZAH_FILIAL = '" + XFILIAL("ZAH") + "'  "
cQuery += "AND ZAH_NUMERO = '" + TZAF->ZAF_NUMERO + "'  " 
cQuery += "ORDER BY ZAH_NUMERO "

TcQuery cQuery New Alias "TZAH"

TZAH->(dbGoTop())
	              
Return()
                       
Static Function fRetSaldo()
Local nRet 	:= 0
Local cQuery:= ''

cQuery := " SELECT SUM(ZAF_SALDO) AS SALDO FROM " + RetSqlName("ZAF") + "  WHERE D_E_L_E_T_ = '' "
cQuery += "AND ZAF_NUMERO = '" + ZAF->ZAF_NUMERO + "'  " 

TcQuery cQuery New Alias "TQQ"

nRet := TQQ->SALDO

TQQ->(dbCloseArea())
 
Return(nRet)  