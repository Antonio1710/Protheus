#INCLUDE "rwmake.ch"
#INCLUDE "Protheus.ch"
#INCLUDE "ParmType.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSF1140I   บAutor  ณMicrosiga           บ Data ณ  11/21/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Utilizado na entrada da pre-nota para o ISS ser retido     บฑฑ
ฑฑบ          ณ corretamente quando classifica a pre-nota                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Adoro                                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAltera็ใo ณ Ch.Interno TI - Abel Babini - Preenche Tipo CTe - 17/06/19 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑ Chamado: 47837 - Fernanado Sigoli 13/03/2019							   ฑฑ
ฑฑ Tratamento de integra็ใo com o Edata, apenas na empresa 01 (adoro)      ฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function SF1140I()

Local Area 		:= GetArea() 
Local _cChave 	:= SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)
Local cMens	  	:= ""
Local lOk	  	:= .F.
Local _CtrDevo	:= ""

Private cRotDesc := "Integracao eData"

RecLock("SF1",.F.)
SF1->F1_RECISS := "2"
//INICIO CHAMADO INTERNO TI - Abel Babini - 17/06/19 - Preenche Tipo CTe Automaticamente
If Alltrim(cValToChar(CESPECIE)) == "CTE"
	SF1->F1_TPCTE := "N - Normal"
EndIf
//FIM CHAMADO INTERNO TI - Abel Babini - 17/06/19 - Preenche Tipo CTe Automaticamente
MsUnLock()


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณTRATAMENTO INTEGRAวรO EDATA - INICIOณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

If cEmpant=="01"  // integra็oes com Edata, existe apenas na empresa 01 - Chamado: 47837 - Fernando Sigoli 13/03/2019

	If SF1->F1_TIPO=="D"
	
		SD1->(dbSetOrder(1))
		SD1->(dbSeek(_cChave))  
		_CtrDevo:= SD1->(D1_CTRDEVO)
		While SD1->(!Eof()) .and. _cChave == SD1->(D1_FILIAL + D1_DOC+ D1_SERIE + D1_FORNECE + D1_LOJA)
		    
			SD2->(DbSetOrder(3))
			If SD2->(DbSeek( SD1->(D1_FILIAL + D1_NFORI + D1_SERIORI + D1_FORNECE + D1_LOJA + D1_COD + D1_ITEMORI )))	
				While SD2->(!EOF()) .and. SD1->(D1_FILIAL + D1_NFORI + D1_SERIORI + D1_FORNECE + D1_LOJA + D1_COD + D1_ITEMORI) == SD2->(D2_FILIAL+ D2_DOC+ D2_SERIE+ D2_CLIENTE+ D2_LOJA +D2_COD+D2_ITEM)
		            //TRATAMENTO....
					SC5->(dbSetOrder(1))
					If SC5->(dbSeek(SD2->(D2_FILIAL+D2_PEDIDO))) .and. SC5->C5_XINT == '3'
						RecLock("SD1",.F.)
						SD1->D1_X_PEDED:= Alltrim(Str(SC5->(Recno())))
						MsUnLock()    
						lOk:=.T.
					EndIf
					SD2->(dbSkip())
				EndDo
			EndIf
			SD1->(dbSkip())
		EndDo
		
		If lOk                                    
		
			SZD->(DbSetOrder(4))
			SZD->(dbSeek(xFilial("SZD")+_CtrDevo))
			
			// INICIO CHAMADO 024498 - WILLIAM COSTA
			IF PARAMIXB[2] == .F. //ALTERACAO
			
				RecLock("SF1",.F.)
					SF1->F1_CTRDEVO :=_CtrDevo        
			        SF1->F1_PLACA   :=SZD->(ZD_PLACA)
			        SF1->F1_XFLAGE  := "1"
				MsUnLock()    
			
	        ENDIF
	        // FINAL CHAMADO 024498 - WILLIAM COSTA
	        
			/*BeginTran()
				
				//Executa a Stored Procedure
				TcSQLExec('EXEC [LNKMIMS].[SMART].[dbo].[FI_PEDIDEVOVEND_01] ' +Str(SF1->(Recno())) )
				cErro := ""
				cErro := U_RetErroED()
				
				If !Empty(cErro)			
					DisarmTransaction()
					cMens += "- Devolu็ใo nใo Integrada com Edata" + CRLF + "- Erro : [" + cErro + "]"  + CRLF						
					U_ExTelaMen(cRotDesc,cMens,"Arial",10,,.F.,.T.)
				EndIf 
				
			EndTran()					  */
		//Else
		//	Aviso("SF1140I","Nota fiscal de Origem nใo foi integrada com o Edata. Devolu็ใo no edata nใo serแ gerada!",{"OK"},3)		
		EndIf
	
	EndIf
	
EndIF
	
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณTRATAMENTO INTEGRAวรO EDATA - FIM   ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

RestArea(Area) 
Return