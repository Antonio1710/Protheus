#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"

User Function ADAFIN03()

Local cTitulo	:= "Importacao Registros de Titulos a Pagar - Empresa: " + Alltrim(SM0->M0_NOME) + " Filial: "+ Alltrim(SM0->M0_FILIAL)
Local lRet		:= .T.                   

Private cGrupo	:= Space(03)
Private cArq1	:= ""                    
Private nTot	:= 0
Private bOk		:= {||Processa({||fAtualiza(_oDlg) } ) } 

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

DEFINE MSDIALOG _oDlg TITLE cTitulo  FROM 254,362 TO 370,991 PIXEL

@ 005,000 TO 058,317 LABEL "Importacao Registros de Titulos a Pagar " PIXEL OF _oDlg	&& Cria as Groups do Sistema
				                                                                                                                 				
@ 030,005 	Say "Arquivo: "											  				Size 082,008 COLOR CLR_BLUE 	PIXEL OF _oDlg
@ 030,60 	MSGet cArq1						Picture "@!"	Valid	AbreArq()		Size 102,008 COLOR CLR_BLACK 	PIXEL OF _oDlg

DEFINE SBUTTON FROM 040,250 TYPE 1 ENABLE OF _oDlg ACTION (EVAL(bOk))
DEFINE SBUTTON FROM 040,280 TYPE 2 ENABLE OF _oDlg ACTION _oDlg:End()
				
ACTIVATE MSDIALOG _oDlg CENTERED  

Return(lRet)


Static Function AbreArq()

Private _cFile := ""
Private _cType := ""

_cType 	:= "*.TXT | *.TXT"
_cFile 	:= cGetFile(_cType, OemToAnsi("Selecione o arquivo (*.TXT)"))

nHdl := fopen(_cFile,0)
nTot:= fSeek(nHdl,0,2)
fClose(nHdl)

cArq1 	:= _cFile

Return()


/* Funcao de atualizacao do campo C5_ATKEMCT */
Static Function fAtualiza(oDlg1)

Local lRet		:= .T.
Local cQuery	:= ""
Local cBuffer	:= ""
Local aLinha	:= {}
Local cTexto	:= ""
Local aArrayA	:= {}
Local aArrayB	:= {}
Local cDelimit	:= ";"

Begin Transaction
FT_FUSE(cArq1)
FT_FGOTOP()
cBuffer := FT_FREADLN()
--ProcRegua(nTot)                    

While !FT_FEOF()

	aLinha 	:= {}      

	If Len(cBuffer) >0
		
		aAdd( aLinha, Substr(cBuffer,01,06) )
		aAdd( aLinha, Substr(cBuffer,09,02) )
		aAdd( aLinha, Substr(cBuffer,13,06) )
		aAdd( aLinha, Substr(cBuffer,21,02) )
		aAdd( aLinha, Substr(cBuffer,24,13) )
		aAdd( aLinha, Substr(cBuffer,37,14) )
		aAdd( aLinha, Substr(cBuffer,52,13) )
		aAdd( aLinha, Substr(cBuffer,67,03) )
		aAdd( aLinha, Substr(cBuffer,72,03) )
		aAdd( aLinha, Substr(cBuffer,77,09) )
		aAdd( aLinha, Substr(cBuffer,88,30) )
		
		/*
		cTexto	:= ""
		For nX 	:= 1 to Len(cBuffer)
			If Substr(cBuffer,nX,1) == cDelimit
				aAdd(aLinha, cTexto )
				cTexto := ""
			Else
				cTexto += Substr(cBuffer,nX,1)
			Endif
		 Next nX
		If !Empty(cTexto)
			aAdd(aLinha, cTexto ) 
		Endif
		*/
	Endif
	aAdd( aArrayA, {	Alltrim(aLinha[1]),;
						Alltrim(aLinha[2]),;
						Alltrim(aLinha[3]),;
						Alltrim(aLinha[4]),;
						Alltrim(aLinha[5]),;
						Alltrim(aLinha[6]),;
						Alltrim(aLinha[7]),;
						Alltrim(aLinha[8]),;
						Alltrim(aLinha[9]),;
						Alltrim(aLinha[10]),;
						Alltrim(aLinha[11]) })
	               
	FT_FSKIP()
	cBuffer := FT_FREADLN()
End
FT_FUSE()
End Transaction             

ProcRegua(Len(aArrayA))

If Len(aArrayA) > 0

	For n1 := 1 to Len(aArrayA)
		
		aParcela := {}
		IncProc()

		RecLock("ZAH",.T.)
			ZAH->ZAH_FILIAL		:= xFilial("ZAH")
			ZAH->ZAH_NUMERO		:= Alltrim(aArrayA[n1,10]) &&StrZero(N1,9)
			ZAH->ZAH_FORNEC		:= Alltrim(aArrayA[n1,01])
			ZAH->ZAH_LOJA		:= Alltrim(aArrayA[n1,02])
			ZAH->ZAH_CESSIO		:= Alltrim(aArrayA[n1,03])
			ZAH->ZAH_LOJA		:= Alltrim(aArrayA[n1,04])
			ZAH->ZAH_VALOR		:= Val(aArrayA[n1,05])
			ZAH->ZAH_DESAGI		:= Val(aArrayA[n1,06])
			ZAH->ZAH_CREDIT		:= Val(aArrayA[n1,07])
			ZAH->ZAH_INDICE		:= Alltrim(aArrayA[n1,08])
			ZAH->ZAH_COND		:= Alltrim(aArrayA[n1,09])
			ZAH->ZAH_SALDO		:= Val(aArrayA[n1,07])
			ZAH->ZAH_TIPO		:= Alltrim(aArrayA[n1,11])
		MsUnlock("ZAH")                                                     
		
		cFornec2	:= ZAH->ZAH_FORNEC
		cCessio		:= ZAH->ZAH_CESSIO

 		&& Calculo parcelas e geracao de titulos a pagar.
 		aParcela := Condicao(Val(aArrayA[n1,07]),Alltrim(aArrayA[n1,09]),,dDataBase) 

		cFornec := Iif(!Empty(aArrayA[n1,03]),aArrayA[n1,03],aArrayA[n1,01])
		cLoja	:= Iif(!Empty(aArrayA[n1,03]),aArrayA[n1,04],aArrayA[n1,02])

		If Len(aParcela) > 0 
			cParcela := "001"
			For n2:= 1 to Len(aParcela) 
			
				cHist := 'CRED.'+cFornec2+' CESS:' +cCessio			
			
				aVetor:={   {"E2_FILIAL"   	,xFilial("SE2")				,NIL},;
							{"E2_PREFIXO" 	,'ADR'		 	 			,NIL},;	
							{"E2_NUM"     	,Alltrim(aArrayA[n1,10])	,NIL},;
							{"E2_PARCELA" 	,cParcela 		 			,NIL},;
							{"E2_TIPO"    	,"RJ"          				,NIL},;
							{"E2_NATUREZ" 	,"26001"					,NIL},;
							{"E2_DEBITO" 	,"221510006"				,NIL},;
							{"E2_FORNECE" 	,cFornec				  	,NIL},;
							{"E2_LOJA"    	,cLoja						,NIL},;
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
								ZAF->ZAF_NUMERO		:= Alltrim(aArrayA[n1,10]) &&StrZero(N1,9) &&StrZero(Val(aArrayA[n1,01]),9)&&SE2->E2_NUM
								ZAF->ZAF_FORNEC		:= Alltrim(aArrayA[n1,01]) //Alltrim(cFornec)
								ZAF->ZAF_LOJA		:= Alltrim(aArrayA[n1,02]) //cLoja
								ZAF->ZAF_CESSIO		:= Alltrim(aArrayA[n1,03])
								ZAF->ZAF_LOJACE		:= Alltrim(aArrayA[n1,04])
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
					/*
					If Len(cParcela) > 1
						cParcela := 'A'
					EndIf
					*/	
	      	Next n2
		EndIf	

    	&&n1:= Len(aArrayA)

	Next n1
	
EndIf

oDlg1:End()

Return(lRet)                     


/*

		aVetor:={  {"E2_FILIAL"   	,xFilial("SE2")		,NIL},;
					{"E2_PREFIXO" 	,SF2->F2_SERIE 		,NIL},;	
					{"E2_NUM"     	,SF2->F2_DOC   	 	,NIL},;
					{"E2_PARCELA" 	,""		       	 	,NIL},;
					{"E2_TIPO"    	,"FT"          		,NIL},;
					{"E2_NATUREZ" 	,"370202"			,NIL},;
					{"E2_FORNECE" 	,"GNRE  "  			,NIL},;
					{"E2_LOJA"    	,"00"			   	,NIL},;
					{"E2_EMISSAO" 	,SF2->F2_EMISSAO 	,NIL},;
					{"E2_VENCTO"  	,SF2->F2_EMISSAO 	,NIL},;
					{"E2_VALOR"   	,nValTit		  	,NIL},;
					{"E2_MOEDA"   	,1	            	,NIL},;
					{"E2_FILORIG" 	,xFilial("SE2")		,NIL}}
		                                                     
		
	EndIf
	
	MSExecAuto({|x,y| FINA050(x,y)},aVetor,3) 
	
	If lMsErroAuto
		Mostraerro()
	Endif                  

*/
