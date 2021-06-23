
#include "protheus.ch"
#include "topconn.ch"


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MT160AOK  ºAutor  ³Fernando Macieira   º Data ³  12/29/17   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ponto Entrada Analise Cotacao para consistir saldo projetosº±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Adoro                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function MT160AOK()

Local lMT160Aok := .t.
Local lSldAtv   := GetMV("MV_#PRJSLD",,".T.")
Local cFasePrj  := GetMV("MV_PRJINIC",,"05")
Local nTtPrj    := 0
Local cCC       := SC8->C8_CC

Private cCodPrj      := SC8->C8_PROJETO


// Consiste exigência ou não do projeto
lPrjInv := Left(AllTrim(cCC),1) == "9"

If lPrjInv .and. !Alltrim(cCC) $ GetMV("MV_#CCPADR")
	
	If Empty(cCodPrj)
		lMT160Aok := .f.
		
		Aviso(	"MT160AOK-06",;
		"Centro de Custo: " + cCC + "." + Chr(13) + Chr(10) +;
		"É obrigatório o preenchimento do Projeto.",;
		{ "&Retorna" },,;
		"Conteúdo em Branco" )
	EndIf
	
Else
	
	If !Empty(cCodPrj)
		lMT160Aok := .f.
		
		Aviso(	"MT160AOK-07",;
		"Centro de Custo: " + cCC + "." + Chr(13) + Chr(10) +;
		"Não permitido o preenchimento do Projeto.",;
		{ "&Retorna" },,;
		"Não permitido informar projeto para CC que não é investimento" )
	EndIf
	
EndIf

If lMT160Aok
	
	// Se cotação possui projeto
	If !Empty(cCodPrj)
		
		// Controle Saldo Projeto ativo
		If lSldAtv
			
			AF8->( dbSetOrder(1) ) // AF8_FILIAL+AF8_PROJET
			AF8->( dbSeek(xFilial("AF8")+cCodPrj) )
			
			// Consiste apenas projetos que possuem valor
			If AF8->AF8_XVALOR > 0
				
				nTtPrj := UpVlrPrj()
				
				nSldPrj := u_ADCOM017P(cCodPrj)
				
				// Consiste saldo informado na cotacao x saldo do projeto (AF8)
				If nTtPrj > nSldPrj
					
					lMT160Aok := .f.
					
					Aviso(	"MT160AOK-01",;
					"Saldo do projeto n. " + AllTrim(cCodPrj) + " insuficiente! Verifique..." + chr(13) + chr(10) +  chr(13) + chr(10)+;
					"[Cotação] Total: " + Transform(nTtPrj, PesqPict("SC8","C8_TOTAL")) + chr(13) + chr(10) +;
					"[PRJ] Saldo: " + Transform(nSldPrj, PesqPict("SC8","C8_TOTAL")),;
					{ "&Retorna" },,;
					"Projeto sem saldo" )
					
				EndIf
				
			EndIf
			
			
		EndIf
		
	EndIf
EndIf

Return lMT160Aok



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MT160AOK  ºAutor  ³Fernando Macieira   º Data ³  12/29/17   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao para carregar o valor do projeto contido na cotacao º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Adoro                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function UpVlrPrj()

Local nVlrPrj := 0
Local cQuery  := ""
Local cCodFor := ""
Local cLojFor := ""

// Array contendo cotacoes com codigo/loja de fornecedor e valor - Nao possui codigo produto
For i:=1 to Len(PARAMIXB[1])
	If !Empty(PARAMIXB[1][i][1][1]) // Se o markbrowse estiver selecionado
		cCodFor += PARAMIXB[1][i][1][2] + "|"
		cLojFor += PARAMIXB[1][i][1][3] + "|"
	EndIf
Next i

// Retiro o "|" do ultimo caractere
cCodFor := Subs(AllTrim(cCodFor),1,Len(AllTrim(cCodFor))-1)
cLojFor := Subs(AllTrim(cLojFor),1,Len(AllTrim(cLojFor))-1)

// Totaliza COTACAO (SC8)
If Select("WorkSC8") > 0
	WorkSC8->( dbCloseArea() )
EndIf

cQuery := " SELECT ISNULL(SUM(SC8.C8_TOTAL),0) AS TOTAL "
cQuery += " FROM " + RetSqlName( "SC8" ) + " SC8 (NOLOCK) "
cQuery += " WHERE SC8.C8_FILIAL = '" + xFilial("SC8") + "' "
cQuery += " AND SC8.C8_PROJETO = '" + cCodPrj + "' "
cQuery += " AND SC8.C8_FORNECE IN " + FormatIn(cCodFor,"|")
cQuery += " AND SC8.C8_LOJA IN " + FormatIn(cLojFor,"|")
cQuery += " AND SC8.D_E_L_E_T_ = ' ' "

tcQuery cQuery new Alias "WorkSC8"

aTamSX3	:= TamSX3("C8_TOTAL")
tcSetField("WorkSC8", "TOTAL", aTamSX3[3], aTamSX3[1], aTamSX3[2])

nVlrPrj := WorkSC8->TOTAL

WorkSC8->( dbCloseArea() )


Return nVlrPrj
