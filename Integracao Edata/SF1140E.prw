#INCLUDE "rwmake.ch"
#INCLUDE "Protheus.ch"
#INCLUDE "ParmType.ch"

/*
	Programa  ³SF1140E   ºAutor  ³Microsiga           º Data ³  11/21/13
	Desc.     ³ Utilizado na entrada da pre-nota para o ISS ser retido  
						³ corretamente quando classifica a pre-nota               
	Uso       ³ Adoro                                                   
	@history Ticket 69574   - Abel Babini          - 25/04/2022 - Projeto FAI
*/

User Function SF1140E()

Local Area := GetArea() 
Local _cChave := SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)
Local cMens	  := ""
Local lOk	  := .F.
Local cLnkSrv		:= Alltrim(SuperGetMV("MV_#UEPSRV",,"LNKMIMS")) //Ticket 69574   - Abel Babini          - 25/04/2022 - Projeto FAI
Private cRotDesc	:= "Integracao eData"

//TRATAMENTO INTEGRAÇÃO EDATA - INICIO

If SF1->F1_TIPO=="D"

	SD1->(dbSetOrder(1))
	SD1->(dbSeek(_cChave))
	While SD1->(!Eof()) .and. _cChave == SD1->(D1_FILIAL + D1_DOC+ D1_SERIE + D1_FORNECE + D1_LOJA)
	    
		If !EmpTy(SD1->D1_X_PEDED)
			lOk:=.T.
		EndIf
		
		SD1->(dbSkip())
	EndDo
	
	If lOk
		BeginTran()
			
			//Executa a Stored Procedure
			TcSQLExec('EXEC ['+cLnkSrv+'].[SMART].[dbo].[FD_PEDIDEVOVEND_01] ' + Str(SF1->(Recno())) )
			cErro := ""
			cErro := U_RetErroED()
			
			If !Empty(cErro)			
				DisarmTransaction()
				cMens += "- Estorno da Devolução não Integrada com Edata: [" + AllTrim(aLstPED[ni][2]) + "]" + CRLF + "- Erro : [" + cErro + "]"  + CRLF						
				U_ExTelaMen(cRotDesc,cMens,"Arial",10,,.F.,.T.)				
			EndIf 
			
		EndTran()					  
				
	EndIf
EndIf

//TRATAMENTO INTEGRAÇÃO EDATA - FIM   

RestArea(Area) 
Return
