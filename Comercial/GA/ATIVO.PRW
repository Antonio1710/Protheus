#include "rwmake.ch"

User Function Ativo()
                     
U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Valida se o vendedor pode incluir pedido para o cliente Escolhido')

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ATIVO     ³ Autor ³ DANIEL             ³ Data ³  01/02/07   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Desc.     ³Valida se o vendedor pode incluir pedido para o cliente     ³±±
±±³          ³Escolhido                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Comercial                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.          	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador³ Data   ³ BOPS ³  Motivo da Alteracao                  	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³           ³        ³      ³                                           ³±±
±±³           ³        ³      ³                                           ³±±
±±³           ³        ³      ³                                           ³±±
±±³           ³        ³      ³                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß  

*/

//+-------------------------------------------------+
//|Declaracao de variaveis                          |
//+-------------------------------------------------+
Private _aArea:=GetArea()   
//+----------------------------------+
//|Retorno da Consulta Padrao        |
//+----------------------------------+
Private _cCli			:= M->C5_CLIENTE				//CLIENTE
Private _cLoja			:= M->C5_LOJACLI				//CLIENTE
Private _cVend			:= ''								//VENDEDOR
//+----------------------------------+
//|Controle                          |
//+----------------------------------+
Private _lRet		  	:= .T.						//Retorno
Private _User			:= ALLTRIM(CUSERNAME)	//Usuario Logado
Private _cSup			:= ''							//Supervisor
Private _aVnds			:= {}							//Vendedores do supervisor
Private _nPos											//Retorno da Busca em Array

//+----------------------------------+
//|Ambiente                          |
//+----------------------------------+
Private SA3FIL			:= xFilial("SA3")
Private SZRFIL			:= xFilial("SZR")
Private SA1FIL			:= xFilial("SA1")
DbSelectArea("SA3")
DbSetOrder(2)				//FILIAL+CODIGO
      
DbSelectArea("SZR")
DbSetOrder(2)       		//FILIAL+CODIGO       

DbselectArea("SA1")
DbsetOrder(1)          //FILIAL+CODIGO+LOJA

//==========================================
//============PROGRAMA PRINCIPAL============
//==========================================

IF SM0->M0_CODIGO = '01' .AND. SM0->M0_FILIAL='02'


//+-----------------------------------+
//|Procurando Vendedor do cliente     |
//+-----------------------------------+
DbselectArea("SA1")
If dbSeek(SA1FIL+_cCli+_cLoja)
	_cVend:=A1_VEND
EndIf


//+-----------------------------------------+
//|Verificar se e' supervisor               |
//|Verifica se o vendedor faz parte do      |
//|supervisor                               |
//+-----------------------------------------+
DBSELECTAREA("SZR")
If DbSeek(SZRFIL+_User,.T.)
	_cSup:=ZR_CODIGO
	//+-------------------------------------+
	//|Procurando Supervisor nos Vendedores |
	//+-------------------------------------+	
	DbselectArea("SA3")	
	DbSetOrder(5)					//FILIAL+CODSUP
	If DbSeek(SA3FIL+_cSup,.T.)                
		//+-----------------------------------+
		//|Carrega vendedores do supervisor   | 
		//+-----------------------------------+		
		While !eof() .and. A3_CODSUP==_cSup
			AADD(_aVnds,{A3_COD})
			Dbskip()
		End          
		//+-------------------------------------+		
		//|Verificando se o vendedor do cliente |
		//|pertence ao supervisor               |
		//+-------------------------------------+
		_nPos:=Ascan(_aVnds,_cVend)
		If _nPos<>0  
			_lRet:=.T.
		Else 
			_lRet:=.F.
		EndIf		
	Else
		_lRet:=.T.
	EndIf
Else
	//+-----------------------------------------+
	//|Verifico se o usuario logado e vendedor  |
	//|Se for vendedor verifico se o clinete    |
	//|faz parte de sua carteira                |
	//+-----------------------------------------+  
	DbSelectArea("SA3")
	If Dbseek(SA3FIL+_User,.T.)
		If _cVend=SA3->A3_COD
			_lRet:=.T.
		Else 
			_lRet:=.F.
		EndIf	
	Else
		_lRet:=.T.
	EndIf                  
EndiF           

RestArea(_aArea)
If !_lRet
	MsgInfo("Cliente nao pertence a sua carteira")
	M->C5_CLIENTE:=""
EndIf
     

//===============================
//=============FIM===============
//===============================

ENDIF
Return(_lRet)