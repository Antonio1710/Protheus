#INCLUDE "PROTHEUS.CH"
User Function MBRWBTN()

Local lRet	:= .T.

if cEmpAnt != "06"                  
	If Alltrim(FunName()) == "AD0079"
		DDatabase := Date()
	Endif
Endif	
                   
//09/10/12 - Incluido por solicitacao do Vagner - chamado 015061
If Alltrim(FunName()) == "OMSA010" //Rotina: Tabela de Precos
	If ! Alltrim(__CUSERID) $ GetMV("MV_#USUTPR")
		Alert("Usuario nao Autorizado - MBRWBTN")
		lRet := .F.
	Endif
Endif   

If Alltrim(FunName()) == "MATA010" //Rotina: Produtos
	If Altera
		If ! Alltrim(__CUSERID) $ GetMV("MV_#USUPRO")
			Alert("Usuario nao Autorizado - MBRWBTN")
			lRet := .F.
		Endif
	Endif	
Endif

Return lRet