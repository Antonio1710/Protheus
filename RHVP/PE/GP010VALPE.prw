#Include "Protheus.ch"  

//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
//±±ºPrograma  ³GP010VALPEº Autor ³ William Costa      º Data ³  21/09/2017 º±±
//±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
//±±ºDescricao ³ Ponto de Entrada para checar os dados de inclusão          º±±
//±±º          ³ /alteração de funcionários.                                º±±
//±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
//±±ºUso       ³ Chamado 033868 / SIGAGPE                                   º±±
//±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

User Function GP010VALPE() 

	Local aArea	:= GetArea()
	Local lRet  := .T.
	
	IF FUNNAME()      == 'GPEA010' .AND. ;
	   CEMPANT        == '01'      .AND. ;
	   XFILIAL("SRA") == '02'      .AND. ;
	   M->RA_XCREDEN  == 0
	   
	   MsgStop("OLÁ " + Alltrim(cUserName) + ", necessário informar a Credencial do Funcionário aba Controle de Ponto, favor verificar!!!", "GP010VALPE - Verifica Credencial")
	   
	   lRet  := .F.
	   
	ENDIF  	   
	
	IF FUNNAME()      == 'GPEA010' .AND. ;
	   CEMPANT        == '02'      .AND. ;
	   XFILIAL("SRA") == '01'      .AND. ;
	   M->RA_XCREDEN  == 0
	   
	   MsgStop("OLÁ " + Alltrim(cUserName) + ", necessário informar a Credencial do Funcionário aba Controle de Ponto, favor verificar!!!", "GP010VALPE - Verifica Credencial")
	   
	   lRet  := .F.
	   
	ENDIF  	   
	 
	//Restaura áreas de trabalho.
	RestArea(aArea)

RETURN(lRet)