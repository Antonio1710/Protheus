#INCLUDE "Topconn.ch"
#INCLUDE "Protheus.ch" 

/*/{Protheus.doc} User Function M185MOD2
	PE utilizado para validar a baixa da pre-requisição, quando for utilizado "baixar por toda a pre-requisição"
	@type  Function
	@author Wesley Candido Silva
	@since 05/07/2016
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@history Chamado 054816 - FWNM             - 09/01/2020 - OS 056218 || ALMOXARIFADO || CRISTIANO || 3547 || BAIXA REQUISICAO-RNX
	@history Chamado 055729 - FERNANDO SIGOLI  - 10/02/2020 - OS 057128 || CONTROLADORIA || FRED_SANTOS || 8947 || ESTOQUE NEGATIVO  
/*/
User Function M185MOD2()

	Private nEst	 := 0
	Private lGerar   := .T.
	Private nCont    := 0
	Private cProduto := ''  
	Private cLocal   := ''
	Private cQuant   := ''

	FOR nCont:=1 TO LEN(PARAMIXB)

		If PARAMIXB[nCont][1] == .T.
			cProduto := PARAMIXB[nCont][4] 
			cLocal   := PARAMIXB[nCont][6] 
			cQuant   := PARAMIXB[nCont][9]  
		
			//If cFilAnt $ '02|03' .and. alltrim(cLocal) $ '02|04' // Chamado n. 054816 || OS 056218 || ALMOXARIFADO || CRISTIANO || 3547 || BAIXA REQUISICAO-RNX - FWNM - 09/01/2020
            
            If Alltrim(cLocal) $ '02|04|09|29'  //Chamado n. 055729 || OS 057128 || CONTROLADORIA || FRED_SANTOS || 8947 || ESTOQUE NEGATIVO - Fernando Sigoli 10/02/2020  
			
				dbSelectArea("SB2")
				dbSeek(xFilial("SB2")+cProduto+cLocal)
				nEst:=SaldoMov(Nil,Nil,Nil,.T.,Nil,Nil,Nil,dDatabase) - cQuant
			
				If nEst< 0 
					MsgInfo("Operação não permitida! Produto ficara com estoque negativo!" + " ["+ alltrim(M->D3_COD)+"/"+ Alltrim(M->D3_LOCAL) + "]" ,"[M185MOD2-01] - Estoque Negativo")
					lGerar := .F.
				EndIf

			EndIf 

		Endif                                             
	
	NEXT

RETURN(lGerar)