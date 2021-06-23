#include 'protheus.ch'
#include 'parmtype.ch'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPEMVCCTBA180บAutor  ณFernando Macieira   บ Data ณ 11/12/2018  บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Ponto de Entrada MVC - CTBA180                               บฑฑ
ฑฑบ          ณ Chamado n. 044316 (SIG VELHO x PRODUCAO)                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Adoro                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function CTBA180()

	Local lRet    := .T.
	Local nStatus := ""
	
	If AllTrim(Alias()) == "CTT" // CENTRO DE CUSTO
		
		If FieldPos("CTT_XMSEXP") <= 0
					
			lRet := .f.
					
			Aviso(	"PEMVCCTBA180-01",;
			"Campo CTT_XMSEXP nใo existente! Registro nใo serแ integrado com o SIG ANTIGO..." + CRLF +;
			"Solicite a cria็ใo deste campo ao Administrador do sistema para prosseguir...",;
			{ "&Retorna" },,;
			"Conta Contแbil x SIG" )
				
		Else

			// Reclock nao funcionou e quando o registro for deletado tamb้m precisarแ ser desflegado! Por isso da utilizacao do UPDATE
			cSql := " UPDATE " +RetSqlName("CTT")+ " SET CTT_XMSEXP=' ' " 
			cSql += " WHERE CTT_FILIAL = '"+FWxFilial("CTT")+"' "
			cSql += " AND CTT_CUSTO = '"+M->CTT_CUSTO+"' "
			
			// NAO INSERIR O D_E_L_E_T_ NA QUERY (Os registros deletados tambem precisam ser desflegados)!!!
					
			nStatus := tcSqlExec(cSql)
				
			If nStatus < 0
				msgAlert("Limpeza do campo CTT_XMSEXP nใo foi realizada! Envie o erro que serแ mostrado na pr๓xima tela ao TI... ")
				MessageBox(tcSqlError(),"",16)
			EndIf
		
		EndIf
		
	ElseIf 	AllTrim(Alias()) == "CTD" // Item Contabil

		If FieldPos("CTD_XMSEXP") <= 0
					
			lRet := .f.
					
			Aviso(	"PEMVCCTBA180-02",;
			"Campo CTD_XMSEXP nใo existente! Registro nใo serแ integrado com o SIG ANTIGO..." + CRLF +;
			"Solicite a cria็ใo deste campo ao Administrador do sistema para prosseguir...",;
			{ "&Retorna" },,;
			"Conta Contแbil x SIG" )
				
		Else

			// Reclock nao funcionou e quando o registro for deletado tamb้m precisarแ ser desflegado! Por isso da utilizacao do UPDATE
			cSql := " UPDATE " +RetSqlName("CTD")+ " SET CTD_XMSEXP=' ' " 
			cSql += " WHERE CTD_FILIAL = '"+FWxFilial("CTD")+"' "
			cSql += " AND CTD_ITEM = '"+M->CTD_ITEM+"' "
			
			// NAO INSERIR O D_E_L_E_T_ NA QUERY (Os registros deletados tambem precisam ser desflegados)!!!
					
			nStatus := tcSqlExec(cSql)
				
			If nStatus < 0
				msgAlert("Limpeza do campo CTD_XMSEXP nใo foi realizada! Envie o erro que serแ mostrado na pr๓xima tela ao TI... ")
				MessageBox(tcSqlError(),"",16)
			EndIf
		
		EndIf
	
	EndIf
			
Return lRet