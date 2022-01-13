#Include 'protheus.ch'
#Include "RwMake.ch"
#Include "topconn.ch"

/*/{Protheus.doc} User Function MT120OK
	LOCALIZAÇÃO : Function A120TudOk() responsável pela validação de todos os itens da GetDados 
	do Pedido de Compras / Autorização de Entrega.
	EM QUE PONTO : O ponto se encontra no final da função e é disparado após a confirmação dos itens da getdados e antes
	do rodapé da dialog do PC, deve ser utilizado para validações especificas do usuario onde será controlada pelo 
	retorno do ponto de entrada oqual se for .F. o processo será interrompido e se .T. será validado.                  
	@type  Function
	@author William Costa
	@since 16/08/2017
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@history chamado TI       - FWNM         - 23/01/2019 - Consistencia pedidos sem alcada
	@history chamado 056195   - FWNM         - 28/02/2020 - OS 057640 || ADM || EVERTON || 45968485 || PC.ORIGEM SIGAEEC
	@history Ticket  n.64674  - Abel Babini  - 27/12/2021 - Não permitir alterar Pedidos de compra com produtos do tipo serviço caso já exista Solicitação de PA
	@history Ticket  n.64674  - Abel Babini  - 10/01/2022 - Não permitir alterar Pedidos de compra com produtos do tipo serviço caso já exista Solicitação de PA
/*/
User Function MT120OK()

	Local nPosXRespon := aScan(aHeader,{|x| AllTrim(x[2]) == "C7_XRESPON"})
	Local nPosNumSc   := aScan(aHeader,{|x| AllTrim(x[2]) == 'C7_NUMSC'})
	Local nPosNumPd   := aScan(aHeader,{|x| AllTrim(x[2]) == 'C7_NUM'})
	
	Local lRet        := .T.
	Local nCont       := 0
	Local aAreaATU    := GetArea()
	
	// FWNM - 23/01/2019
	Local nTotPed   := 0
	Local nC7Total  := 0
	Local nC7VlDesc := 0
	Local cCCusto   := ""
	Local cItemCta  := ""
	Local aAprov    := {}
	Local lSolPdPA	:= .F.
	Local i := 0
	//

	If lRet
		
		For nCont :=1 To Len(aCols)
			
			If !gdDeleted(nCont)

				IF EMPTY(aCols[nCont][nPosNumSc]) .AND. Empty(aCols[nCont][nPosXRespon])
					
					If cmodulo = "EEC" //Incluido por Adriana para preencher com nome do usuario logado quando pedido incluido pelo modulo EEC - chamado 036819
						aCols[nCont][nPosXRespon] := cUserName
						lRet := .T.
					Else
						MsgAlert("OLÁ " + Alltrim(cUserName) + ", VOCÊ NÃO DIGITOU O RESPONSAVEL DO PEDIDO, PARA DIGITAR CLIQUE EM AÇÕES RELACIONADAS RESPONSÁVEL", "MT120OK - Digitação do Responsável")
						lRet := .F.
						Exit
					EndIf
					
				ENDIF
				
			EndIf
			
		NEXT nCont
		
	EndIf
	
	// fwnm - 23/01/2019
	If lRet
	
		For i:=1 To Len(aCols)
			
			If !gdDeleted(i)

				// 056195 || OS 057640 || ADM || EVERTON || 45968485 || PC.ORIGEM SIGAEEC - FWNM - 28/02/2020
				If AllTrim(FunName()) == "MATA121" 
					If PCEEC(i)
						lRet := .f.
						Aviso(	"MT120OK-02",;
						"Pedido de Compra foi gerado pelo EEC... Alteração não permitida por esta rotina!",;
						{ "&Retorna" },,;
						"Origem: SIGAEEC" )
						Exit
					EndIf
				EndIf
				//

				// Totalizo PC
				nC7Total  := gdFieldGet("C7_TOTAL", i)
				nC7VlDesc := gdFieldGet("C7_VLDESC", i)
				
				nTotPed += (nC7Total - nC7VlDesc)
				
				// Carrego CC e Item - Regra antiga encontrada no PE MT120F onde define que deve exitir apenas 1 CC e Item no PC!
				cCCusto   := gdFieldGet("C7_CC", i)
				cItemCta  := gdFieldGet("C7_ITEMCTA", i)
			EndIf
			
		Next i
		
		// Obtem os aprovadores para os centros de custo
		If lRet
			
			aAprov	:= u_GetAprov( cCCusto, cItemCta, nTotPed )
			
			If Len(aAprov)==0

				lRet := .f.

				Aviso(	"MT120OK-01",;
				"Não foi localizado controle de alçada para o centro de custo.",;
				{ "&Retorna" },,;
				"CCusto/ItemCta: " + AllTrim(cCCusto) + "/" + AllTrim(cItemCta) )

			EndIf

		EndIf

	EndIf
	//
	
	//INICIO Ticket  n.64674  - Abel Babini  - 27/12/2021 - Não permitir alterar Pedidos de compra com produtos do tipo serviço caso já exista Solicitação de PA
	If lRet

		lSolPdPA := xVrSolPA(nPosNumPd)

		For i:=1 To Len(aCols)
			//Ticket  n.64674  - Abel Babini  - 10/01/2022 - Não permitir alterar Pedidos de compra com produtos do tipo serviço caso já exista Solicitação de PA
			If !gdDeleted(i) .AND. Alltrim(Posicione("SB1",1,xFilial("SB1")+Alltrim(gdFieldGet("C7_PRODUTO", i)),"B1_TIPO")) == "SV" .AND. lSolPdPA
				lRet := .f.
				Aviso(	"MT120OK-03",;
				"Não é permitido alterar Pedidos de compra com produtos do tipo serviço caso já exista Solicitação de PA.",;
				{ "&Retorna" },,;
				"Pedido: " + AllTrim(gdFieldGet("C7_NUM", i)) )
				Exit
			EndIf
			
		Next i

	EndIf
	//FIM Ticket  n.64674  - Abel Babini  - 27/12/2021 - Não permitir alterar Pedidos de compra com produtos do tipo serviço caso já exista Solicitação de PA

	RestArea( aAreaATU )

Return(lRet)

/*/{Protheus.doc} Static Function PCEEC()
	(long_description)
	@type  Static Function
	@author FWNM
	@since 28/02/2020
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@chamado 056195 || OS 057640 || ADM || EVERTON || 45968485 || PC.ORIGEM SIGAEEC
/*/
Static Function PCEEC(nLinha)

	Local lPCEEC := .f.
	Local cQuery := ""

	If Select("Work") > 0
		Work->( dbCloseArea() )
	EndIf

	cQuery := " SELECT COUNT(1) TT 
	cQuery += " FROM " + RetSqlName("SC7") + " (NOLOCK)
	cQuery += " WHERE C7_FILIAL='"+FWxFilial("SC7")+"'
	cQuery += " AND C7_NUM='"+cA120Num+"'
	cQuery += " AND C7_ORIGEM='SIGAEEC'
	cQuery += " AND D_E_L_E_T_=''

	tcQuery cQuery New Alias "Work"

	Work->( dbGoTop() )

	If Work->TT >= 1
		lPCEEC := .t.
	EndIf

	If Select("Work") > 0
		Work->( dbCloseArea() )
	EndIf
	
Return lPCEEC

/*/{Protheus.doc} Static Function xVrSolPA()
	(long_description)
	@type  Static Function
	@author Abel Babini
	@since 27/12/2021
	@Ticket  n.64674  - Abel Babini  - 27/12/2021 - Não permitir alterar Pedidos de compra com produtos do tipo serviço caso já exista Solicitação de PA
/*/
Static Function xVrSolPA(cNumPdCp)

	Local lRet := False
	Local cQuery := GetNextAlias()

	BeginSQL alias cQuery
		SELECT COUNT(*) AS NUM_SOL_PA
		FROM %TABLE:ZFQ% ZFQ 
		WHERE 
			ZFQ_FILIAL = %xFilial:SC7% AND 
			ZFQ_NUM = %Exp:cNumPdCp% AND 
			ZFQ.%notDel%
	EndSQL

	If (cQuery)->NUM_SOL_PA > 0
		lRet := .t.
	Endif
	(cQuery)->(dbCloseArea())


	
Return lRet
