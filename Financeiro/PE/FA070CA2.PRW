#include "protheus.ch" 

/*/{Protheus.doc} User Function FA070CA2
  O ponto de entrada FA070CA2 sera executado após a rotina de cancelamento de baixas do contas a receber, apos a gravacao de todos os dados e finalizada a contabilizacao.
  @type  Function
  @author Abel Babini Filho
  @since 05/07/2021
  @history Ticket 8       - Abel Babini  - 05/07/2021 - Efetua avaliação de crédito do cliente após cancelamento da baixa.
  @history Ticket 70142   - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
  /*/
User Function FA070CA2()
  // Ticket 8       - Abel Babini  - 05/07/2021 - Efetua avaliação de crédito do cliente após cancelamento da baixa.
	//Static Call(M410STTS,fLibCred, SE1->E1_CLIENTE, SE1->E1_LOJA, MsDate()) 
  //@history Ticket 70142  - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
  u_10STTSA1( SE1->E1_CLIENTE, SE1->E1_LOJA, MsDate() )
Return 
