#include "rwmake.ch"

/*/{Protheus.doc} User Function MTASF2
   Ponto de Entrada para gravar campos C5_PBRUTO,C5_PLIQUI Campos que sao calculado na Adoro
   @type  Function
   @author Marcos Bido
   @since 06/12/2001
   @history Chamado n.056630 - OS n.058090 - Abel Babini - 27/03/2020 - TRANSFERÊNCIA ATIVO. Geração de NF automaticamente. Verifica cotação apenas quando Moeda diferente de 0
   @history Ticket n. 1                    - Abel Babini - 04/01/2021 - TRANSFERÊNCIA ATIVO. Geração de NF automaticamente. Verifica cotação apenas quando Moeda diferente de 0
/*/

User Function MTASF2()     

   SetPrvt("_CALIAS,_CORDER,_CRECNO,_CNUMPED,_CCLIENTE,_CLOJA")
   SetPrvt("_CROTEIRO,_CSEQUENC")
   SetPrvt("_SF2cAliasSF2,_SF2cOrderSF2,_SF2cRecnoSF2,_SC5cAliasSC5,_SC5cOrderSC5,_SC5cRecnoSC5")

   _cAlias := Alias()
   _cOrder := IndexOrd()
   _cRecno := Recno()
   
   //Ticket n. 1                    - Abel Babini - 04/01/2021 - TRANSFERÊNCIA ATIVO. Geração de NF automaticamente. Verifica cotação apenas quando Moeda diferente de 0
   IF !IsInCallStack('ATFA036') .AND. !IsInCallStack('ATFA060')
      dbSelectArea("SF2")
      _SF2cAliasSF2 := Alias()
      _SF2cOrderSF2 := IndexOrd()
      _SF2cRecnoSF2 := Recno()
      _dEMISSAO := SF2->F2_EMISSAO
      _cNFISCAL := SF2->F2_DOC
      _cSERIE   := SF2->F2_SERIE
      //dbSetOrder(1)

      dbSelectArea("SC5")
      _SC5cAliasSC5 := Alias()
      _SC5cOrderSC5 := IndexOrd()
      _SC5cRecnoSC5 := Recno()
      //dbSetOrder(3)

      // Guarda o Pedido Posicionado (imediatamente apos a gravacao)  

      dbSelectArea("SC5")
      if cEmpAnt == "02"
         _cROTEIRO  := SC5->C5_ROTEIRO
         _cSEQUENC  := SC5->C5_SEQUENC
         _cPLACA    := SC5->C5_PLACA
         _cEstPLC   := SC5->C5_ESTPLAC
         _cCLIENTE  := SC5->C5_CLIENTE
         _cPEDIDO   := SC5->C5_NUM
         _cTPCLI    := SC5->C5_TIPOCLI
         _nPesoBr   := SC5->C5_PBRUTO  &&Mauricio Chamado 007169
         _nPesoLq   := SC5->C5_PESOL  &&Mauricio Chamado 007169
      else
         _cROTEIRO  := SC5->C5_ROTEIRO
         _cSEQUENC  := SC5->C5_SEQUENC
         _cPLACA    := SC5->C5_PLACA
         _cCLIENTE  := SC5->C5_CLIENTE
         _cPEDIDO   := SC5->C5_NUM
         _cTPCLI    := SC5->C5_TIPOCLI
         _nPesoBr   := SC5->C5_PBRUTO  &&Mauricio Chamado 007169
         _nPesoLq   := SC5->C5_PESOL 
      Endif      
      // Gravo no C5_MOK que a mercadoria foi faturada
      // Campo utilizado na tela AD0163 do atendimento
      // Alterado em 27/04/2006 - Werner
      RecLock("SC5",.F.)
      SC5->C5_MOK	    := "01"   // - 01 = Pedido faturado
      if IsInCallStack("U_CCSP_002")
         SC5->C5_XERRO := SC5->C5_XERRO+"// CCSP_002 - "+DTOC(Ddatabase)+" "+Time()+" por "+Alltrim(cusername)+" // Faturado" //incluido por Adriana em 23/04/15 para gravar log completo
      endif
      MSUNLOCK()

      //POSICIONA COTACAO DA MOEDA                                                                                       
      
      DBSELECTAREA("SM2")
      DBSETORDER(1)

      //Alterado por Adriana em 30/01/2018 para tratar outras moedas	
      IF DBSEEK(DTOS(_dEMISSAO)) .AND. SC5->C5_MOEDA <> 0 //Chamado n.056630 - OS n.058090 - Abel Babini - 27/03/2020 - TRANSFERÊNCIA ATIVO. Geração de NF automaticamente. Verifica cotação apenas quando Moeda diferente de 0
         //_nCOTAC  := SM2->M2_MOEDA2
         _nCota := &("M2_MOEDA"+STR(SC5->C5_MOEDA,1))
      ELSE
         _nCOTAC := 1
         IF _cTPCLI = "X"
            ALERT("Taxa moeda "+STR(_nMoeda,1)+" não foi cadastrada. Considerado valor do frete em Reais")
         ENDIF
      ENDIF

      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
      //³ BUSCA VALOR DO FRETE NA EXPORTACAO, SE HOUVER                ³
      //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

      /* Retirado 16/02/13. Ana - Ajuste para atualizacao Protheus 11. Pois nao existe indice 10, gerando erro na geracao da nfs
      DBSELECTAREA("EE7")
      DBSETORDER(10)
      IF DBSEEK(xFilial("EE7")+_cCLIENTE+_cPEDIDO)
         _nFRETEX  := EE7->EE7_FRPREV*_nCOTAC
      ELSE
         _nFRETEX  := 0
      ENDIF
      */
      _nFRETEX  := 0

      //Grava Informacoes em SF2                                            
      
      dbSelectArea("SF2")
      RecLock("SF2",.F.)
      _nVALBRUT:=F2_VALBRUT
      _nVALCONT:=_nFRETEX+_nVALBRUT
      Replace  F2_ROTEIRO    With  _CROTEIRO
      Replace  F2_SEQUENC  With  _CSEQUENC
      Replace  F2_PLACA       With  _cPLACA
      if cEmpAnt == "02"
         Replace  F2_ESTPLAC     With  _cEstPLC
      //   Replace F2_PBRUTO With _nPesoBr    &&Mauricio Chamado 007169
      //   Replace F2_PLIQUI With _nPesoLq    &&Mauricio Chamado 007169
      Endif
      Replace F2_PBRUTO With _nPesoBr    &&ALEX BORGES 03/04/12
      Replace F2_PLIQUI With _nPesoLq    &&ALEX BORGES 03/04/12
      //Replace  F2_FRETE       With  _nFRETEX
      Replace F2_VALBRUT With _nVALCONT
      MsUnlock()

      dbSelectArea(_SF2cAliasSF2)
      dbSetOrder(_SF2cOrderSF2)
      dbGoto(_SF2cRecnoSF2)

      dbSelectArea(_SC5cAliasSC5)
      dbSetOrder(_SC5cOrderSC5)
      dbGoto(_SC5cRecnoSC5)

   ENDIF

   dbSelectArea(_cAlias)
   dbSetOrder(_cOrder)
   dbGoto(_cRecno)

return()
