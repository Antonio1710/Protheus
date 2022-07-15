#include "protheus.ch"

/*/{Protheus.doc} User Function F290BROW
	Esta contabilização não é realizada Off-Line, conforme link abaixo:
	http://tdn.totvs.com/pages/releaseview.action?pageId=145362219
	Garante uma unica thread por empresa
	@type  Function
	@author FWNM
	@since 21/08/2019
	@version 01
	@history Chamado 051145 - FWNM              - 21/08/2019 - 051145 || OS 052497 || CONTROLADORIA || MONIK_MACEDO || 8956 || LP 530 E LP 532    
	@history Chamado 049953 - FWNM              - 31/10/2019 - 049953 || OS 051296 || CONTROLADORIA || MONIK_MACEDO || 8956 || CONTAB. IMBOLIZADO  
	@history Chamado 76254  - Fernando Macieira - 12/07/2022 - GERAÇÃO DE FATURAS - CONTAS A PAGAR - bloqueio por filial
/*/
User Function F290BROW()

	Local cPergAux := "AFI290"
	Local cKeyBloq := "FINA290" // Fatura a pagar

	// @history Chamado 76254  - Fernando Macieira - 12/07/2022 - GERAÇÃO DE FATURAS - CONTAS A PAGAR
	/*
	Detalhamento:
	- essa trava é uma customização que foi implementada em Agosto de 2019 após vários casos em que o sistema Protheus se perdia e causava ônus a empresa/departamento/negócio quando o mesmo título era inserido em faturas diferentes sendo feitas simultaneamente
	- é uma trava por empresa uma vez que o usuário consegue selecionar filiais diferentes
	A recomendação é mantermos!
	Caso optem por retirar, teremos que pedir autorização dos gestores.

	ANTONIO AMADEU SURIANI
	12/07/2022 11:09
	E-mail
	De: ANTONIO AMADEU SURIANI <antonio.suriani@adoro.com.br>
	Para: atendimento@adoro.com.br <atendimento@adoro.com.br> em 12/07/2022 11:08
	Cc:
	Bom dia.
	Por favor liberar, esta trava compromete o bom funcionamento da área.
	Obrigado.
	Antônio Amadeu Suriani
	Ad’oro S/A – Financeiro
	Tel: (11) 94028-3101
	antonio.suriani@adoro.com.br
	*/
	
	// Garanto uma unica thread sendo executada por empresa e filial
	/*
	https://tdn.totvs.com/pages/releaseview.action?pageId=6814894

	Parâmetros:
 	Nome	 	 	Tipo	 	 	Descrição	 	 										Default	 	 	Obrigatório	 	 	Referência	 
 	cName	 	 	Caracter	 	Nome do semáforo a ser criado.	 	 	 	 	 						X	 	 	 	 
 	lEmpresa	 	Lógico	 	 	Se verdadeiro (.T.), o controle será feito por empresa.	 	 	 	 	X	 	 	 	 
 	lFilial	 	 	Lógico	 	 	Se verdadeiro (.T.), o controle será feito por filial.	 	 	 	 	X	 	 	 	 
	*/
	//If !LockByName(cKeyBloq, .T., .F.)
	If !LockByName(cKeyBloq, .T., .T.) // @history Chamado 76254  - Fernando Macieira - 12/07/2022 - GERAÇÃO DE FATURAS - CONTAS A PAGAR - bloqueio por filial
		msgAlert("[F290BROW-01] - Existe outro processamento sendo executado na mesma empresa/filial! Aguarde ou peça para seu colega de trabalho fechar a rotina... Esta rotina será desconectada pelo administrador...")
		KillApp(.T.)
	EndIf
	//

	cPergAux := PadR(cPergAux, Len(SX1->X1_GRUPO))
		
	Pergunte(cPergAux, .f.)
	
	MV_PAR03 := 1
	MV_PAR04 := 1

Return
