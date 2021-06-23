#INCLUDE "PROTHEUS.CH"
#INCLUDE 'rwmake.ch' 
#INCLUDE "topconn.ch" 

/*/{Protheus.doc} User Function MA030BUT
	Inclui botao no Cadastro de Clientes.
	@type  Function
	@author Adriana Oliveira
	@since 03/09/2020
	@version 01
	@history Ticket 692 	- Adriana Oliveira 	- 03/09/2020 - Incluir botao Consulta dados do Regime Especial 57608/11
/*/

User Function MA030BUT 

Local aBotao := {}

aAdd( aBotao, {"POSCLI",{|| U_Reg57608()},"Reg.Esp.57608/11","Reg.Esp.57608/11"} )

RETURN(aBotao)

/*{Protheus.doc} User Function Reg57608
	Mostra dados do regime especial na ZG4 - Ticket 692
	@type  Function
	@author Adriana Oliveira
	@since 03/09/2020
	@version 01
*/

User Function Reg57608

    Local _c57608   := ""
    Local _d57608   := ""
    Local _cmsg     := ""
    Local STR_LF    := Chr(13)+ Chr(10)

	DbSelectArea("ZG4")
	If Dbseek(xFilial("ZG4")+SA1->A1_COD+SA1->A1_LOJA)
    	_c57608 := Alltrim(ZG4->ZG4_NUMERO)
    	_d57608 := dToC(ZG4->ZG4_DTINI)
	    _cMsg := "Contribuinte detentor do Reg. Especial Eletronico nos termos do Decreto nr 57608/2011" + STR_LF + STR_LF + ;
			     "PROTOCOLO "+_c57608 + " INICIO EM "+_d57608 +"."
    else
        _cMsg := "Não Contribuinte do Reg. Especial Eletronico nos termos do Decreto nr 57608/2011" + STR_LF + STR_LF + ;
			    "Para enquadrar este cliente, solicitar ao Financeiro." + STR_LF
	Endif

	Aviso("MA030BUT-01", _cMsg, { "&Retorna" },,"Cliente: "+SA1->A1_COD+"/"+SA1->A1_LOJA+"-"+Alltrim(SA1->A1_NOME ) )

    ZG4->(DbCloseArea())

Return
