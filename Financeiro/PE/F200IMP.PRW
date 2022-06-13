#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} User Function F200IMP
  Ponto de Entrada que permite a gravação de dados adicionais no momento do recebimento do arquivo de retorno de cobrança
  @type  Function
  @author Abel Babini
  @since 05/07/2021
  @version 1
  @history Ticket 8       - Abel Babini - 05/07/2021 - Após a baixa, revalida crédito dos pedidos em aberto do cliente.
  /*/
User Function F200IMP()
  //Static Call(M410STTS,fLibCred, SE1->E1_CLIENTE, SE1->E1_LOJA, MsDate())
  //@history Ticket 70142  - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
  u_10STTSA1(SE1->E1_CLIENTE, SE1->E1_LOJA, MsDate())
Return 
