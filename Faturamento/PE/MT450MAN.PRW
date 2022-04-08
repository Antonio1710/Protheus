#include "rwmake.ch"
#include "topconn.ch"

/*/{Protheus.doc} User Function MT450MAN
   Ponto de Entrada no MATA450 antes da liberacao manual de crédito - Apresenta Limite de Credito da "Rede" e Saldo da "Rede"
   @type  Function
   @author Rogerio Eduardo Nutti
   @since 30/01/2002
   @version version
   @param param_name, param_type, param_descr
   @return return_var, return_type, return_description
   @example
   (examples)
   @see (links_or_references)
   @history chamado TI     - Paulo TDS - 06/07/2011 - Mostrar, de fato, o total da Rede
   @history chamado TI     - Paulo TDS - 12/07/2011 - Para que funcione de acordo com a versão 10
   @history chamado 056247 - FWNM      - 09/04/2020 - || OS 057671 || FINANCEIRO || LUIZ || 8451 || BOLETO BRADESCO WS
   @history ticket 745 - FWNM - 30/09/2020 - C5_XWSPAGO com identificação para liberação manual
   @history ticket 71027 - Fernando Macieira - 07/04/2022 - Liberação Pedido Antecipado sem Aprovação Financeiro - PV 9BEGCC foi incluído depois que o job do boleto parou, não gerou FIE e SE1 (PR) e foi liberado manualmente pelo financeiro, sendo faturado como pv normal... por isso da dupla checagem
/*/
User Function MT450MAN()

   Local lContinua := .t. // Chamado n. 056247 || OS 057671 || FINANCEIRO || LUIZ || 8451 || BOLETO BRADESCO WS - FWNM - 09/04/2020
   Local _aArea := GetArea()                     // Incluído por Paulo - TDS - 12/07/2011 (Salva todas as áreas em aberto)
   Local _cRede := "",_cCnpj := "",_cQrFlt := "" // Incluído por Paulo - TDS - 06/07/2011
   Local _nTotRede := 0, _nTotSdRede := 0        // Incluído por Paulo - TDS - 06/07/2011

   // Chamado n. 056247 || OS 057671 || FINANCEIRO || LUIZ || 8451 || BOLETO BRADESCO WS - FWNM - 09/04/2020
   FIE->( dbSetOrder(1) ) // FIE_FILIAL, FIE_CART, FIE_PEDIDO
   If FIE->( dbSeek(SC9->C9_FILIAL+"R"+SC9->C9_PEDIDO) )
      //If AllTrim(Posicione("SC5",1,SC9->(C9_FILIAL+C9_PEDIDO),"C5_XWSPAGO")) <> "S"
      If Empty(AllTrim(Posicione("SC5",1,SC9->(C9_FILIAL+C9_PEDIDO),"C5_XWSPAGO"))) // ticket 745 - FWNM - 30/09/2020 - C5_XWSPAGO com identificação para liberação manual
			lContinua := .f.
			msgAlert("Pedido de Adiantamento " + SC9->C9_PEDIDO + " não foi pago! Liberação não permitida...","[MT450MAN-01] - Bradesco WS")
		EndIf
	EndIf
   //

   // @history ticket 71027 - Fernando Macieira - 07/04/2022 - Liberação Pedido Antecipado sem Aprovação Financeiro - PV 9BEGCC foi incluído depois que o job do boleto parou, não gerou FIE e SE1 (PR) e foi liberado manualmente pelo financeiro, sendo faturado como pv normal... por isso da dupla checagem
   If lContinua
      SC5->( dbSetOrder(1) ) // C5_FILIAL, C5_NUM, R_E_C_N_O_, D_E_L_E_T_
      If SC5->( dbSeek(SC9->(C9_FILIAL+C9_PEDIDO)) )
         If Posicione("SE4",1,FWxFilial("SE4")+SC5->C5_CONDPAG,"E4_CTRADT") == '1' // Condição Pagto Adiantamento
            If Empty(SC5->C5_XWSPAGO)
               lContinua := .f.
               msgAlert("Pedido de Adiantamento " + SC9->C9_PEDIDO + " não foi pago! Liberação não permitida...","[MT450MAN-02] - Bradesco WS")
            EndIf
         EndIf
      EndIf
   EndIf
   //

   dbSelectArea("SZF")
   dbSetOrder(1)

   If dbSeek(xFilial("SZF")+SubStr(AllTrim(Posicione("SA1",1,xFilial("SA1")+SC9->C9_CLIENTE+SC9->C9_LOJA,"A1_CGC")),1,8))

      // Carrega as variáveis com o nome da Rede e o CNPJ da Matriz
      // Paulo - TDS - 06/07/2011   
      _cRede := SZF->ZF_REDE
      _cCnpj := SZF->ZF_CGCMAT
      
      // Faz a somatória do valor da rede (via Query)
      // Paulo - TDS - 06/07/2011
      _cQrFlt := "SELECT ZF_REDE,SUM(ZF_LCREDE) AS LCREDE,SUM(ZF_SLDREDE) AS SLDREDE "
      _cQrFlt += "FROM "+RetSqlName("SZF")+" "
      _cQrFlt += "WHERE ZF_REDE = '"+AllTrim(_cRede)+"' AND D_E_L_E_T_ <> '*' "
      _cQrFlt += "GROUP BY ZF_REDE "
      _cQrFlt += "ORDER BY ZF_REDE" 
      
      TCQUERY _cQrFlt New Alias "TMP"

      dbSelectArea("TMP")
      dbGoTop()
      While !Eof()
         _nTotRede   += TMP->LCREDE
         _nTotSdRede += TMP->SLDREDE
         dbSkip()
      EndDo

      // Mostra na tela os limites da Rede
      // Paulo - TDS - 06/07/2011
      @ 200,051 TO 380,380 DIALOG oDlg1 TITLE "Atenção "
      @ 010,010 SAY "Matriz CNPJ (8 digitos): "+AllTrim(_cCnpj)
      @ 020,010 SAY "Rede: "+AllTrim(_cRede)
      @ 030,010 SAY "Limite de Credito desta Rede de Lojas: "+Transform(_nTotRede  ,"@E 999,999,999.99")
      @ 040,010 SAY "Saldo desta Rede de Lojas:             "+Transform(_nTotSdRede,"@E 999,999,999.99")
      @ 075,040 BMPBUTTON TYPE 01 ACTION Close(oDlg1)
      ACTIVATE DIALOG oDlg1 CENTERED     

      dbSelectArea("TMP")
      dbCloseArea() 
      
   EndIf

   RestArea(_aArea) // Incluído por Paulo - TDS - 12/07/2011 (Devolve todas as áreas em aberto)

Return lContinua
