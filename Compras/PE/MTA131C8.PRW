#INCLUDE "RWMAKE.CH"

/*/{Protheus.doc} User Function MTA131C8
	Ponto de Entrada para gravar campos especificos C8_CONTA e C8_CC na Cotacao a partir da digitacao na Solicitacao
	@type  Function
	@author Rogerio Nutti
	@since 02/10/2000
	@version 01
   @history Chamado 047826 - WILLIAM COSTA - 12/03/2019 - Retirado IF do campo C8_USAR para carregar somente na empresa 01 campo criado em todas as empresas para nao ter mais esse problema
   @history TICKET    2364 - WILLIAM COSTA - 02/10/2020 - Alterado regra para carregar os campos C8_UPRC e C8_UCOM, pois agora trabalhamos com a SBZ não mais a SB1, então a formula adicionada busca na SBZ  
   @history Everson, 04/11/2020, Chamado 2562. Tratamento para gravar o número do estudo do projeto.
/*/

User Function MTA131C8()     

   Local _cAlias := Alias()
   Local _cOrder := IndexOrd()
   Local _cRecno := Recno()
   Local _lGrvUltCom := .F.
   Local oModFor := PARAMIXB[1]

   SetPrvt("_CALIAS,_CORDER,_CRECNO,")

   // Inclusao RNUTTI 16/08/2001 - Gravar na cotacao o preco/data da ultima compra
   dbSelectArea("SB1")
   _cAliasSB1 := Alias()
   _cOrderSB1 := IndexOrd()
   _cRecnoSB1 := Recno()
   dbSetOrder(1)

   If dbSeek( xFilial("SB1")+SC1->C1_PRODUTO )
      _lGrvUltCom := .T.
   Endif
   // Fim das Inclusoes

   oModFor:LoadValue("C8_CONTA"  ,SC1->C1_CONTA )
   oModFor:LoadValue("C8_CC"     ,SC1->C1_CC )
   oModFor:LoadValue("C8_PROJETO",SC1->C1_PROJADO )
   oModFor:LoadValue("C8_CODPROJ",SC1->C1_CODPROJ )
   oModFor:LoadValue("C8_XITEMST",SC1->C1_XITEMST ) //Everson - 04/11/2020. Chamado 2562.

   //Mauricio - MDS - 19/03/14 - grava codigo do usuario que esta gerando a cotação....

   oModFor:LoadValue("C8_USUAR" , __cUserID ) // Chamado 047826 WILLIAM COSTA 12/03/2019 - Retirado IF de empresa para o campo C8_USUAR

   // Inclusao RNUTTI 16/08/2001 - Gravar na cotacao o preco/data da ultima compra
   IF _lGrvUltCom

      oModFor:LoadValue("C8_UPRC" , IIF(!RetArqProd(SC1->C1_PRODUTO),POSICIONE("SBZ",1,FWxFilial("SBZ")+SC1->C1_PRODUTO,"BZ_UPRC"),POSICIONE("SB1",1,FWxFilial("SB1")+SC1->C1_PRODUTO,"B1_UPRC")))
      oModFor:LoadValue("C8_UCOM" , IIF(!RetArqProd(SC1->C1_PRODUTO),POSICIONE("SBZ",1,FWxFilial("SBZ")+SC1->C1_PRODUTO,"BZ_UCOM"),POSICIONE("SB1",1,FWxFilial("SB1")+SC1->C1_PRODUTO,"B1_UCOM")))

   ENDIF

   // Fim das Inclusoes 

   // Inclusao RNUTTI 16/08/2001 - Gravar na cotacao o preco/data da ultima compra
   dbSelectArea(_cAliasSB1)
   dbSetOrder(_cOrderSB1)
   dbGoto(_cRecnoSB1)
   // Fim das Inclusoes 

   dbSelectArea(_cAlias)
   dbSetOrder(_cOrder)
   dbGoto(_cRecno)

RETURN()        
