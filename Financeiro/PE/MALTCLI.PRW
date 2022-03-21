#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ ADVEN045P   º Autor ³ Mauricio - MDS TEC º Data ³  05/04/17º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Ponto de entrada executado após a alteração do cadastro do º±±
±±º          ³ de clientes.                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
/*/{Protheus.doc} User Function ADVEN045P
  Ponto de entrada executado após a alteração do cadastro do de clientes.
  @type  Function
  @author Mauricio
  @since 26/05/2020
  @version 1
  @history TI - Leonardo P. Monteiro - 16/03/2022 - Gravação no campo XCODLOJ a concatenação do código do cliente e loja.
													Rotina auxiliar para avaliação de crédito na emissão de PVs.
  @history Everson, 18/10/2020, Chamado 18465. Envio de informações ao barramento.  
/*/
User Function MALTCLI()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
	Local aArea      := GetArea()
	
	//
	If FindFunction("U_ADVEN076") .And. cEmpAnt == "01"
		U_ADVEN076("","",.F.," AND A1_COD = '" + Alltrim(cValToChar(A1_COD)) + "' AND A1_LOJA = '" + Alltrim(cValToChar(A1_LOJA)) + "' ","",.T.)
	
	EndIf
	
	RECLOCK("SA1",.F.)
        SA1->A1_XCODLOJ := SA1->A1_COD+SA1->A1_LOJA
    SA1->(MSUNLOCK())

	grvBarr() //Everson, 18/10/2020, Chamado 18465.

	RestArea(aArea)
	
Return Nil
/*/{Protheus.doc} grvBarr
    Salva o registro para enviar ao barramento.
    @type  User Function
    @author Everson
    @since 18/03/2022
    @version 01
/*/
Static Function grvBarr()

    //Variáveis.
    Local aArea := GetArea()

	U_ADFAT27C("SA1", 1, "cadastro_de_clientes_protheus", "A", FWxFilial("SA1") + SA1->A1_COD)

    RestArea(aArea)

Return Nil
