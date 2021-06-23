#include "protheus.ch"

/*/{Protheus.doc} User Function MT120FOL
	Ponto Entrada PC para zerar o campo C7_PROJETO qdo COPIA
	@type  Function
	@author FWNM
	@since 29/12/2017
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@history chamado 049136 - Adriano Savoine - 13/05/2019 - Limpar CCusto na cópia
	@history chamado TI     - Adriana         - 02/07/2019 - Limpar Desconto P. Rural
	@history chamado 049136 - Adriano Savoine - 13/05/2019 - Limpar CCusto na cópia
	@history chamado 057440 - FWNM            - 17/04/2020 - || OS 058919 || TECNOLOGIA || LUIZ || 8451 || HIST. APROVACAO
	@history chamdo 4147    - Everson         - 30/10/2020 - Chamado 4147. Adicionada condicional para cópia do centro de custo.
	@history chamado 2562   - Everson         - 04/11/2020 - Chamado 2562. Tratamento para apagar o número do estudo do projeto.
/*/
User Function MT120FOL()

	//Variáveis.
	Local aArea	 := GetArea()
	Local lCopia := IsInCallStack("A120Copia")
	Local i      := 1
	Local lCpCC  := .F. //Everson - 30/10/2020. Chamado 4147.

	//
	If lCopia // Copia PC

		//Everson - 30/10/2020. Chamado 4147.
		lCpCC := MsgYesNo("Deseja copiar o centro de custo?","Função MT120FOL(MT120FOL)") //Everson - 30/10/2020. Chamado 4147.

		//
		For i:=1 to Len(aCols)

			If !gdDeleted(i)
			
				If !lSubsPC // Chamado n. 057440 || OS 058919 || TECNOLOGIA || LUIZ || 8451 || HIST. APROVACAO - FWNM - 17/04/2020 - Variável Pública inicializada no PE MT120CPE contido dentro do MT120F.PRW

					gdFieldPut("C7_XITEMST", Space( TAMSX3( "C7_XITEMST" )[1] ), i) //Everson - 04/11/2020. Chamado 2562.
					gdFieldPut("C7_PROJETO", Space( TAMSX3( "C7_PROJETO" )[1] ), i)
					gdFieldPut("C7_LOCAL", IIF(!RetArqProd(SB1->B1_COD),POSICIONE("SBZ",1,xFilial("SBZ")+Alltrim(aCols[i][2]),"BZ_LOCPAD"),POSICIONE("SB1",1,xFilial("SB1")+Alltrim(aCols[i][2]),"B1_LOCPAD")), i)     //chamado 039513 - Fernando Sigoli
					
					//
					If ! lCpCC //Everson - 30/10/2020. Chamado 4147.
						gdFieldPut("C7_CC", Space( TAMSX3( "C7_CC" )[1] ), i)   // CHAMADO : 049136 - ADRIANO SAVOINE 13/05/2019

					EndIf 

					gdFieldPut("C7_XPDESCR", 0, i)   //incluido por Adriana para não levar o desconto para novo pedido - 02/07/2019 
					gdFieldPut("C7_XVDESCR", 0, i)   //incluido por Adriana para não levar o desconto para novo pedido - 02/07/2019
					gdFieldPut("C7_XRESPON", Space( TAMSX3( "C7_XRESPON" )[1] ), i)   //incluido por Adriana para não levar o responsavel para novo pedido - 02/07/2019
					gdFieldPut("C7_OBS"    , Space( TAMSX3( "C7_OBS" )[1] ), i)
				
					gdFieldPut("C7_XQTDAPR", 0, i)
					gdFieldPut("C7_XPEDORI", Space( TAMSX3( "C7_XPEDORI" )[1] ), i)
					gdFieldPut("C7_XLEGAPP", Space( TAMSX3( "C7_XLEGAPP" )[1] ), i)
					gdFieldPut("C7_XOBSINT", Space( TAMSX3( "C7_XOBSINT" )[1] ), i)
									
				EndIf

			EndIf
		
		Next i

	EndIf

	//
	RestArea(aArea)

Return Nil
