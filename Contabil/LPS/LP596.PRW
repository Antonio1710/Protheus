#Include "rwmake.ch"

User Function LP596(_cPar1,_cPar2)       

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LP596     ºAutor  ³Donizete            º Data ³  10/07/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Este LP retorna dados para o LP 596 (compensação contas a  º±±
±±º          ³ a receber. Trata o posicionamento dos títulos.             º±±
±±º          ³ Adaptado do rdmake originalmente elaborado por Martelli.  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Chamada no LP 596.                                         º±±
±±º          ³ Protheus 710/811                                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAtualiz.  ³ 22/01/05                                                   º±±
|±º          ³ - alterado lógica de memoriação dos alias (getarea).       º±±
|±º          ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

// Definição das variáveis.
Public _aArea   	:= GetArea()
Public _aAreaSE1	:= {}
Public _aAreaSE5	:= {}
Public _aAreaSA1	:= {}
Public _aAreaSED	:= {}
Public _cRet		:= Space(20)
Public _cCod		:= Space(TamSX3("A1_COD")[1])
Public _cLoja		:= Space(TamSX3("A1_LOJA")[1])
Public _cConta		:= Space(TamSX3("CT1_CONTA")[1])
Public _cNat		:= Space(TamSX3("ED_CODIGO")[1])
Public _cChavePA	:= Space(23)
Public _cChaveNF	:= Space(23)
Public _cChave		:= Space(23)
Public _cCliRA		:= Space(15)
Public _cCliNF		:= Space(15)
_cPar1 := Upper(Alltrim(_cPar1)) // Tipo de Dado a ser retornado.
_cPar2 := Upper(Alltrim(_cPar2)) // Tipo de Dado a ser retornado.

dbSelectArea("SE1")
_aAreaSE1 := GetArea()

dbSelectArea("SE5")
_aAreaSE5 := GetArea()

If Alltrim(SE5->E5_TIPO) $ "RA/NCC" // Usuário compensou posicionando na NF.
	_cChaveNF := SUBSTR(SE5->E5_DOCUMEN,1,13)+SE5->E5_CLIFOR+SE5->E5_LOJA
	_cChaveRA := SE5->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA)
	
	If _cPar1 == "VLR"                                  	                                              
		dbSelectArea("SE1")
		dbSetOrder(2)                                  	
		If dbSeek(xFilial("SE1")+SE5->E5_CLIFOR+SE5->E5_LOJA+SUBSTR(SE5->E5_DOCUMEN,1,18))
			If ALLTRIM(SE1->E1_PORTADO) == "KOB"		
				Return(SE5->E5_VALOR)
			Endif
		EndIf	
	Endif
	
	If _cPar1 == "HST"	
		Return("COMP. TIT. " + SE5->E5_PREFIXO + SE5->E5_NUMERO + SE5->E5_PARCELA + SE5->E5_TIPO + " - " + SE5->E5_CLIFOR + "-" + SE5->E5_LOJA + " C/ TIT. " + SUBSTR(SE5->E5_DOCUMEN,1,18))
	Endif	
	
	If _cPar1 == "CTC"	
		dbSelectArea("SE1")
		dbSetOrder(2)                                  	
		If dbSeek(xFilial("SE1")+SE5->E5_CLIFOR+SE5->E5_LOJA+SUBSTR(SE5->E5_DOCUMEN,1,18))
			dbSelectArea("SA6")
			dbSetOrder(1)                                  	
	   		If dbSeek(xFilial("SA6")+ALLTRIM(SE1->E1_PORTADO)+SUBSTR(SE1->E1_AGEDEP,1,5)+SUBSTR(SE1->E1_CONTA,1,10))
				Return(SA6->A6_CONTA)
			Endif	
		Endif
	Endif				
		
Else // Usuário compensou posicionando no RA/NCC
	_cChaveNF := SE5->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA)
	_cChaveRA := SUBSTR(SE5->E5_DOCUMEN,1,13)+SE5->E5_CLIFOR+SE5->E5_LOJA
	    
	If _cPar1 $ "VLR"	
		If ALLTRIM(SE1->E1_PORTADO) == "KOB"
			Return(SE5->E5_VALOR)
		Endif
	Endif		
		
	If _cPar1 == "HST"	
		Return("COMP. TIT. " + SE5->E5_PREFIXO + SE5->E5_NUMERO + SE5->E5_PARCELA + SE5->E5_TIPO + " - " + SE5->E5_CLIFOR + "-" + SE5->E5_LOJA + " C/ TIT. " + SUBSTR(SE5->E5_DOCUMEN,1,18))
	Endif	
	
	If _cPar1 == "CTC"	
		dbSelectArea("SA6")
		dbSetOrder(1)                                  	
   		If dbSeek(xFilial("SA6")+ALLTRIM(SE1->E1_PORTADO)+SUBSTR(SE1->E1_AGEDEP,1,5)+SUBSTR(SE1->E1_CONTA,1,10))
			Return(SA6->A6_CONTA)
		Endif
	Endif
		 
	If _cPar1 == "CTD"
		_cCtd006 := ""
		If ALLTRIM(SUBSTR(SE5->E5_DOCUMEN,16,3)) == "NCC"
			_cCtd006 := TABELA("Z@","A02",.F.)
		ElseIf ALLTRIM(SUBSTR(SE5->E5_DOCUMEN,16,3)) == "RA"	
			dbSelectArea("SE1")
	   		dbSetOrder(1)                                  	
			If dbSeek(xFilial("SE1")+ALLTRIM(SUBSTR(SE5->E5_DOCUMEN,1,18)))		
				dbSelectArea("SED")
				dbSetOrder(1)                                  	
   	   			If dbSeek(xFilial("SED")+ALLTRIM(SE1->E1_NATUREZ))
					_cCtd006 := SED->ED_CONTA
				Endif
			Endif		
		Endif
		Return(_cCtd006)
	Endif		
			
EndIf

RestArea(_aAreaSE5)
RestArea(_aAreaSE1)
RestArea(_aArea)

Return()

User Function LP588(_cPar1)

Public _aArea   	:= GetArea()
Public _aAreaSE1	:= {}
Public _aAreaSE5	:= {}

U_ADINF009P('LP596' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

_cPar1 := Upper(Alltrim(_cPar1)) // Tipo de Dado a ser retornado.

dbSelectArea("SE1")
_aAreaSE1 := GetArea()

dbSelectArea("SE5")
_aAreaSE5 := GetArea()

If Alltrim(SE5->E5_TIPO) $ "RA/NCC" // Usuário compensou posicionando na NF.
	_cChaveNF := SUBSTR(SE5->E5_DOCUMEN,1,13)+SE5->E5_CLIFOR+SE5->E5_LOJA
	_cChaveRA := SE5->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA)
	
	If _cPar1 $ "VLR/VLR006"
		If ALLTRIM(SE1->E1_PORTADO) == "KOB"
			Return(SE5->E5_VALOR)
		Endif
	Endif	
	
	If _cPar1 == "HST"	
		Return("EST. COMP. " + SE5->E5_PREFIXO + SE5->E5_NUMERO + SE5->E5_PARCELA + SE5->E5_TIPO + " - " + SE5->E5_CLIFOR + "-" + SE5->E5_LOJA + " C/ TIT. " + SUBSTR(SE5->E5_DOCUMEN,1,18))
	Endif	
	
	If _cPar1 == "CTD"
		dbSelectArea("SA6")
		dbSetOrder(1)                                  	
	   	If dbSeek(xFilial("SA6")+ALLTRIM(SE1->E1_PORTADO)+SUBSTR(SE1->E1_AGEDEP,1,5)+SUBSTR(SE1->E1_CONTA,1,10))
			Return(SA6->A6_CONTA)
		Endif	
	Endif
	
	If _cPar1 == "CTC"
		_cCtd006 := ""
		If ALLTRIM(SE5->E5_TIPO) == "NCC"
			_cCtd006 := TABELA("Z@","A02",.F.)
		ElseIf ALLTRIM(SE5->E5_TIPO) == "RA"	
			dbSelectArea("SE1")
	   		dbSetOrder(1)                                  	
			If dbSeek(xFilial("SE1")+SE5->E5_PREFIXO+SE5->E5_NUMERO+SE5->E5_PARCELA+SE5->E5_TIPO)		
				dbSelectArea("SED")
				dbSetOrder(1)                                  	
   	   			If dbSeek(xFilial("SED")+ALLTRIM(SE1->E1_NATUREZ))
					_cCtd006 := SED->ED_CONTA		
		   		Endif
		   	Endif	
		Endif
		Return(_cCtd006)
	Endif		
	
Else // Usuário compensou posicionando no RA/NCC
	_cChaveNF := SE5->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA)
	_cChaveRA := SUBSTR(SE5->E5_DOCUMEN,1,13)+SE5->E5_CLIFOR+SE5->E5_LOJA
	
	If _cPar1 == "VLR"                                  	                                              
		dbSelectArea("SE1")
		dbSetOrder(1)                                  	
		If dbSeek(xFilial("SE1")+SE5->E5_PREFIXO+SE5->E5_NUMERO+SE5->E5_PARCELA+SE5->E5_TIPO)
			If ALLTRIM(SE1->E1_PORTADO) == "KOB"		
				Return(SE5->E5_VALOR)
			Endif
		EndIf	
	Endif	
	
	If _cPar1 == "HST"	
		Return("EST. COMP. " + SE5->E5_PREFIXO + SE5->E5_NUMERO + SE5->E5_PARCELA + SE5->E5_TIPO + " - " + SE5->E5_CLIFOR + "-" + SE5->E5_LOJA + " C/ TIT. " + SUBSTR(SE5->E5_DOCUMEN,1,18))
	Endif				
	
	If _cPar1 == "CTC" 
		dbSelectArea("SED")
		dbSetOrder(1)                                  	
		If dbSeek(xFilial("SED")+ALLTRIM(SE1->E1_NATUREZ))
			Return(SED->ED_CONTA)		
		Endif
	Endif
	
	If _cPar1 == "CTD"
		dbSelectArea("SA6")
		dbSetOrder(1)                                  	
	   	If dbSeek(xFilial("SA6")+ALLTRIM(SE1->E1_PORTADO)+SUBSTR(SE1->E1_AGEDEP,1,5)+SUBSTR(SE1->E1_CONTA,1,10))
			Return(SA6->A6_CONTA)
		Endif	
	Endif				
	
Endif		

RestArea(_aAreaSE5)
RestArea(_aAreaSE1)
RestArea(_aArea)

Return()