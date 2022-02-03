#INCLUDE 'PROTHEUS.CH'

/*/{Protheus.doc} User Function MNTA400I
	LOCALIZAÇÃO : Function MNTA400I() - Adição de botões no retorno de O.S.
	@type  Function
	@author Tiago Sttoco
	@since 25/05/2020
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/

User Function MNTA400I

Local aRot :=  aClone(ParamIXB[1])

aAdd(aRot,{"GERA OP","U_GEROPMNT()" ,0,4,,.F.})

Return aRot


/*/{Protheus.doc} User Function GEROPMNT
	LOCALIZAÇÃO : Function GEROPMNT() - Criada a ordem para prosseguir com finalização da OS
	@type  Function
	@author Tiago Sttoco
	@since 25/05/2020
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/

User Function GEROPMNT()
Local cOs	:= STJ->TJ_ORDEM
	
	dbSelectArea("SC2")
	dbSetOrder(01)
	If !dbSeek(xFilial("SC2")+STJ->TJ_ORDEM+'OS001')

		cCODPRO := GetMv("MV_PRODMNT")
		cOP     := cOs + "OS001"
		cOP 	:= Alltrim(cOP)
		GERAOP(cCODPRO, 1, cOP, STJ->TJ_DTORIGI, STJ->TJ_DTORIGI,Nil)
		//-- Grava os Campos Especificos na OP
		dbSelectArea('SC2')
		RecLock('SC2', .F.)
		SC2->C2_CC      := STJ->TJ_CCUSTO
		SC2->C2_EMISSAO := STJ->TJ_DTMPINI
		SC2->C2_STATUS  := 'U'
		SC2->C2_OBS     := 'PLANO 000000'
		MsUnlock('SC2')
		MsgInfo("Ordem Criada com sucesso prosseguir com finalização da OS","Atencao")
	Else
		MsgInfo("Já existe Ordem criada para essa OS","Atencao")
	EndIf

Return