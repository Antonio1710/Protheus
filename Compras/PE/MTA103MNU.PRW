#Include "Protheus.ch"
#Include "TopConn.ch"

/*/{Protheus.doc} User Function MTA103MNU
	Faz validacao referente usuarios que poderáo incluir alterar e excluir documentos de entrada.
	@type  Function
	@author EVERALDO CASAROLI
	@since 07/07/2008
	@version 01
	@history chamado 044314 - Everson       - 05/08/2019 - Tratamento para Inclusão de CT-e por Job.
	@history chamado 999    - William Costa - 10/09/2020 - Retirado o If da empresa 01 e filial 02, pois para as outras empresas e filiais estava aparecendo o botão de incluir e alterar onde não pode.
	@history Chamado 1860   - Everson       - 18/09/2020 - Tratamento para inclusão automática de CT-e na empresa 07.
/*/

USER FUNCTION MTA103MNU()

	Local _aArea	:= GetArea()

	IF !alltrim(__CUSERID) $ GETMV("MV_XUSER") .And. ! IsInCallStack("U_ADFIS032P") .And.; //Everson - 05/08/2019. Chamado 044314.
		! IsInCallStack("U_ADFIS039P") .And. ! IsInCallStack("U_ADFIS040P") //Chamado 1860   - Everson       - 18/09/2020
		aRotina		:= {}
		aAdd(aRotina,{"Pesquisar", "AxPesqui"   , 0 , 1, 0, .F.}) 		//"Pesquisar"
		aAdd(aRotina,{"Visualizar", "A103NFiscal", 0 , 2, 0, .F.}) 		//"Visualizar"
		aAdd(aRotina,{"Imprimir", "A103Impri"  , 0 , 4, 0, .F.})	//"Imprimir"
		aAdd(aRotina,{"Legenda", "A103Legenda", 0 , 2, 0, .F.})		//"Legenda"
		
	ELSE //ADICIONAR ESSA ROTINA DE REFATURAMENTO, PARA ENVIO DE EMAIL WILLIAM COSTA - TI 11/11/2014 
	
		aAdd(aRotina,{"REFATURAMENTO", "U_ADCOM004P"   , 0 , 1, 0, .F.}) 		//"REFATURAMENTO"
		
	ENDIF   

	RestArea( _aArea )

RETURN()
