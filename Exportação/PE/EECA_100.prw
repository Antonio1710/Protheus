User Function EECAC100()
Local _cFiltro := ""
//_cFiltro := "A1_TIPCLI $ '234'"           
_cFiltro := "A1_EST = 'EX'"           

If Type("ParamIXB") == "C"
	cRespAux := ParamIXB
ElseIf Type("ParamIXB") == "A"
	cRespAux := ParamIXB[1] 
Else
	cRespAux := ""
EndIf

IF cRespAux == "ANTES_BROWSE"
//	dbSelectArea("SA1")
//	Set Filter to &(_cFiltro)
	SA1->(dbSetFilter({|| &(_cFiltro) }, _cFiltro))          
//	SA1->(dbSetFilter(&("Unknown macro: {|| " + cFilter + " }"), cFilter))
elseif cRespAux = 'AC100VldOk_IncAltExc'
    if paramixb[2] .and. M->A1_TIPCLI $ "234"            //não está bloqueando
		lValImpCli  := .T.           //variavel private da rotina lValImpCli
    else
    	Alert("O campo TIPO CLIENTE na pasta Outros deve estar preenchido com 2=Consignee, 3=Notify ou 4=Todos")
    	lValImpCli := .F.     
    Endif
	
    // chamado 035622 - 09/06/2017 - fernando sigoli
    If M->A1_EST = 'EX' .and. Empty(M->A1_CONDPAG)
		Alert("Clientes de Exportação é obrigatorio informar a condiçao de pagamento especifico de export (VENDAS)")  
   		lValImpCli := .F.     
   	EndIf	

EndIf                                                       

Return NIL