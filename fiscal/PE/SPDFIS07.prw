#include 'protheus.ch'
/*/{Protheus.doc} User Function SPDFIS07
	Ponto de entrada que permite a customização do Código da da Conta Contábil no registro H010 do SPED Fiscal.
	MODELO PE PADRAO TOTVS-ATENCAO AO ALTERAR
	@type  Function
	@author ADRIANA OLIVEIRA
	@since 20/03/18
	@history Chamado 047912  - Adriana Oliveira  - 14/03/2019 - ajuste conforme documentacao Portal Totvs (tdn.totvs.com/pages/releaseview.action?pageId=60771763)
	@history Chamado 047912  - Adriana Oliveira  - 19/03/2019 - ajuste para outros tipos de operacao
	@history Ticket 69236    - Abel Babini       - 15/03/2022 - criação de novas regras
	/*/
User Function SPDFIS07()

	Local cCodProduto := PARAMIXB[1] //Codigo do Produto
	Local cSituacao := PARAMIXB[2] // Situação do inventario
	Local cRetorno    := ""
	
	//Ticket 69236    - Abel Babini       - 15/03/2022 - criação de novas regras
	If cSituacao== '0' .and. cFilAnt = "02" .and. (Alltrim(cCodProduto) = "383368" .or. Alltrim(cCodProduto) = "383369")//    1- Item de propriedade do informante em posse de terceiros
		
		cRetorno := "111540002"

	ElseIf cSituacao == '0'  //0- Item de propriedade do informante e em seu poder // outros tipos de operacao por Adriana em 19/03/19
	
		cRetorno := SB1->B1_CONTA
	
	ElseIf cSituacao== '1' .and. Alltrim(cCodProduto) = "383369" //    1- Item de propriedade do informante em posse de terceiros
	
		cRetorno := "111580002"
	
	ElseIf cSituacao== '1' .and. Alltrim(cCodProduto) <> "383369" .and. Alltrim(cCodProduto) <> "100252"//    2- Item de propriedade de terceiros em posse do informante
	
		cRetorno := "111580001"
	
	ElseIf cSituacao== '1' .and. Alltrim(cCodProduto) = "100252" //    1- Item de propriedade do informante em posse de terceiros
	
		cRetorno := "111580004"
	
	EndIf

Return cRetorno
