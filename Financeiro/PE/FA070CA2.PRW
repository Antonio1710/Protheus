#include "protheus.ch" 

/*/{Protheus.doc} User Function FA070CA2
  O ponto de entrada FA070CA2 sera executado após a rotina de cancelamento de baixas do contas a receber, apos a gravacao de todos os dados e finalizada a contabilizacao.
  @type  Function
  @author Abel Babini Filho
  @since 05/07/2021
  @history Ticket 8       - Abel Babini  - 05/07/2021 - Efetua avaliação de crédito do cliente após cancelamento da baixa.
  /*/
  
User Function FA070CA2()
  // Ticket 8       - Abel Babini  - 05/07/2021 - Efetua avaliação de crédito do cliente após cancelamento da baixa.
	StaticCall(M410STTS,fLibCred, SE1->E1_CLIENTE, SE1->E1_LOJA, MsDate()) 
Return 
