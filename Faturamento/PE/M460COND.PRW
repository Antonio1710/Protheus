#Include "Protheus.ch"
/*/{Protheus.doc} User Function nomeFunction
	Ponto de entrada Alterar data utilizada como base para calcular o vencimento
	do titulo.                                                                    
	@type  Function
	@author HCCONSYS
	@since 16/10/2007
	@version 01
	@history Everson, 14/10/2020, Chamado 2663 - Incluída filial 03.
	@history /Ticket 69574   - Abel Babini          - 21/03/2022 - Projeto FAI
	/*/
User Function M460COND()
	//PARA ALTERAR DATA DE VENCIMENTO, TENDO COMO BASE A DATA DA ENTREGA E NAO A DATA DE EMISSAO DA NOTA

	/*
	(...)
	Local dDataCnd  := SF2->F2_EMISSAO
	(...)
	If ( aEntry[EP_M460COND] )
	dDataCnd := ExecBlock("M460COND", .F., .F.,{dDataCnd})               
	*/ 
	Local aArea  := GetArea()
	Local _DtIni := paramixb[1]  

	//Ticket 69574   - Abel Babini          - 21/03/2022 - Projeto FAI
	if xFilial("SC9") $  "02/03/0B	" .and. Alltrim(cEmpAnt)=="01"  //para filial VARZEA //Everson - 14/10/2020. Chamado 2665.
		_DtIni := iif(Empty(SC9->C9_DTENTR), iif(Empty(SC6->C6_ENTREG), _DtIni, SC6->C6_ENTREG) , SC9->C9_DTENTR)    
		_DtIni := iif(_DtIni < Date(), Date(), _DtIni)  // por Adriana para não apresentar rejeicao na transmissao da nfe  em 01/08/2018 Chamado 042882
	endif 

	//
	RestArea(aArea) 

RETURN _DtIni
