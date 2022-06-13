#include "rwmake.ch"
#include "protheus.ch" 

/*/{Protheus.doc} User Function SACI008
	PONTO DE ENTRADA Baixa de Titulos a Receber Manual FINA070 - Especifico Ad'oro Alimenticia
	@type  Function
	@author Rogerio Nutti
	@since 12/04/2006
	@history Ticket 8       - Abel Babini  - 05/07/2021 - Efetua avaliação de crédito do cliente após a baixa.
	@history Ticket 70142   - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
	/*/
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava ambiente inicial     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
User Function SACI008()        

_sAlias := Alias()
_sIndex := IndexOrd()
_sRecno := Recno()

dbSelectArea("SA1")
_sAliasSA1 := Alias()
_sIndexSA1 := IndexOrd()
_sRecnoSA1 := Recno()

dbSelectArea("SE1")
_sAliasSE1 := Alias()
_sIndexSE1 := IndexOrd()
_sRecnoSE1 := Recno()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se é baixa por Perda/PDD (MV_MOTBXRE), altera risco para "E"  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If SE5->E5_MOTBX $ Alltrim( GETMV("MV_MOTBXRE") ) 

	dbSelectArea("SA1")	
	dbSetOrder(1)
	If dbSeek( xFilial("SA1")+SE5->(E5_CLIFOR+E5_LOJA ) ) 
		RecLock("SA1",.F.)
		Replace A1_RISCO With "E"
		MsUnlock()
	Endif

Endif

//Inicio Sigoli Chamado:027642 19/12/2016
DbSelectArea("SE1")	
DbSetOrder(1)
If dbSeek(xFilial("SE1")+SE5->E5_PREFIXO+SE5->E5_NUMERO+SE5->E5_PARCELA)
	// Ticket 8       - Abel Babini  - 05/07/2021 - Efetua avaliação de crédito do cliente após a baixa.
	//Static Call(M410STTS,fLibCred, SE1->E1_CLIENTE, SE1->E1_LOJA, MsDate()) 
	//@history Ticket 70142  - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
  	u_10STTSA1( SE1->E1_CLIENTE, SE1->E1_LOJA, MsDate() )  

	While !Eof() .and. E1_PREFIXO = SE5->E5_PREFIXO .and. E1_NUM = SE5->E5_NUMERO .and. E1_PARCELA = SE5->E5_PARCELA .and. SE5->E5_BANCO <> ''
		If !EMPTY(E1_BAIXA).and. EMPTY(E1_XDTDISP) 
			RecLock("SE1",.F.)
			Replace E1_XDTDISP With SE5->E5_DTDISPO
			MsUnlock()
		EndIF	
   	DbSkip() 
   	Enddo
Endif
//Fim Sigoli Chamado: 027642 19/12/2016

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura ambiente inicial  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

dbSelectArea(_sAliasSE1)
dbSetOrder(_sIndexSE1)
dbGoto(_sRecnoSE1)

dbSelectArea(_sAliasSA1)
dbSetOrder(_sIndexSA1)
dbGoto(_sRecnoSA1)

dbSelectArea(_sAlias)
dbSetOrder(_sIndex)
dbGoto(_sRecno)

Return  


 