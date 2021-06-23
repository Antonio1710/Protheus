#include 'rwmake.ch'

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  MA020ALT  º Autor ³ Ana Helena         º Data ³  19/11/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ P.E. para validacao dos dados na alteracao do              º±±
±±º          ³ cadastro de fornecedores. Tirado obrigatoriedade do campo  º±±
±±º          ³ A2_CGC, pois quando estado = "EX" nao precisa ser preenchidoº±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function MA020ALT()   
                       
Local _lRetCGC := .F.

If M->A2_EST = 'EX'
	_lRetCGC := .T.	
Else
	If Empty(M->A2_CGC)
		_lRetCGC := .F.                                   
	Else
		_lRetCGC := .T.	
	Endif
Endif

If !_lRetCGC
	Alert("Campo CGC é obrigatorio - PE MA020ALT")
Endif

//Chamado 032707 - WILLIAM COSTA 02/09/2017
If _lRetCGC

	IF ALLTRIM(M->A2_LOCAL) <> '' .AND. ;
		(ALLTRIM(M->A2_XTIPO) == '1' .OR. ALLTRIM(M->A2_XTIPO) == '2')
		
		DBSELECTAREA("NNR")
		NNR->(DBSETORDER(1))
		NNR->(DBGOTOP())
		IF !DBSEEK(xfilial("NNR") + ALLTRIM(M->A2_LOCAL))
			
			RecLock("NNR",.T.)  
				
				NNR->NNR_FILIAL	:= xFilial("NNR")
				NNR->NNR_CODIGO	:= ALLTRIM(M->A2_LOCAL)
				NNR->NNR_DESCRI	:= IIF(ALLTRIM(M->A2_XTIPO) == '1','INCUBATORIO-','INTEGRADO-') + ALLTRIM(M->A2_LOCAL)
				NNR->NNR_TIPO	:= '1'
					
			NNR->( MsUnLock() )    
			
						
			MsgINFO("Olá " + Alltrim(cusername) + ", Local de Armazém Criado: " + ALLTRIM(M->A2_LOCAL), "MA020ALT - Criação de Almoxarifado")
						
		ENDIF
			
		NNR->( DBCLOSEAREA() )  
			
	ENDIF
	
ENDIF
               
Return(_lRetCGC)