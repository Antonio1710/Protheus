#include 'protheus.ch'
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³SPDFIS07  ³ Autor ³ ADRIANA OLIVEIRA      ³ Data ³ 20/03/18 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Ponto de entrada que permite a customização do Código da    ³±±
±±³          ³da Conta Contábil no registro H010 do SPED Fiscal.          ³±±
±±³          ³MODELO PE PADRAO TOTVS-ATENCAO AO ALTERAR                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ºALTERAÇÃO ³Adriana Oliveira-14/03/2019-047912, ajuste conforme         º±±
±±º          ³documentacao Portal Totvs                                   º±±
±±º          ³tdn.totvs.com/pages/releaseview.action?pageId=60771763      º±±
±±ºALTERAÇÃO ³Adriana Oliveira-19/03/2019-047912, ajuste para outros      º±±
±±º          ³tipos de operacao                                           º±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function SPDFIS07()

	Local cCodProduto := PARAMIXB[1] //Codigo do Produto
	Local cSituacao := PARAMIXB[2] // Situação do inventario
	Local cRetorno    := ""
	
	If cSituacao == '0'  //0- Item de propriedade do informante e em seu poder // outros tipos de operacao por Adriana em 19/03/19
	
	      cRetorno := SB1->B1_CONTA
	
	ElseIf cSituacao== '1' .and. Alltrim(cCodProduto) = "383369" //    1- Item de propriedade do informante em posse de terceiros
	
	      cRetorno := "111580002"
	
	ElseIf cSituacao== '1' .and. Alltrim(cCodProduto) <> "383369" //    2- Item de propriedade de terceiros em posse do informante
	
	      cRetorno := "111580001"
	
	EndIf

Return cRetorno