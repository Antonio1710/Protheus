/*/{Protheus.doc} User Function FA040FIN
  Ponto de Entrada na inclusão de um título a receber, após o transaction
  Criado para bloquear título criados pela rotina de Liquidação do Contas a Receber
  @type  Function
  @author Abel Babini
  @since 26/05/2020
  @version 1
  @history 058353 - Abel Babini - 26/05/2020 - Bloquear títulos criados pela rotina de liquidação do contas a receber / renegociação
  @history TI - Leonardo P. Monteiro - 15/03/2022 - Gravação no campo XCODLOJ a concatenação do código do cliente e loja.
                                                    Rotina auxiliar para avaliação de crédito na emissão de PVs.
  /*/
User Function FA040FIN
  Local cTpDivf   := "000004"
  Local cE1VALOR   := SE1->E1_VALOR

  Local cE1DSCFINN := SE1->E1_DESCFIN

  local sDscBlq    := ""

  IF IsInCallStack("FINA460") .AND. Alltrim(Funname()) <> "CENTNFEXM"
   
    DbSelectArea("SX5")
    DbSetOrder(1)
    DbSeek( FwxFilial("SX5") + 'Z9' + cTpDivf )
    sDscBlq := Alltrim(SX5->X5_DESCRI)

    // Bloqueio por Renegociação
    IF SE1->E1_XDIVERG <> 'S'
      RECLOCK("SE1",.F.)
        SE1->E1_XDIVERG := 'S'
      SE1->(MSUNLOCK())
    ENDIF
          
    DbSelectArea("ZC7")
    DbSetOrder(2)
    IF DbSeek( FwxFilial("ZC7") + SE1->E1_CLIENTE + SE1->E1_LOJA + SE1->E1_PREFIXO + SE1->E1_NUM + SE1->E1_PARCELA + SE1->E1_TIPO)  //ZC7_FILIAL, ZC7_CLIFOR, ZC7_LOJA, ZC7_PREFIX, ZC7_NUM, ZC7_PARCEL, R_E_C_N_O_, D_E_L_E_T_
      IF EMPTY(ZC7->ZC7_USRAPR)
        RecLock("ZC7",.F.)
        ZC7->ZC7_CNABDE := cE1DSCFINN
        ZC7->ZC7_USRALT := __cUserID
        MSUnlock()
      ELSE
        RecLock("ZC7",.T.)
          ZC7->ZC7_FILIAL := FwxFilial("SE1")
          ZC7->ZC7_PREFIX	:= SE1->E1_PREFIXO
          ZC7->ZC7_NUM   	:= SE1->E1_NUM
          ZC7->ZC7_PARCEL	:= SE1->E1_PARCELA
          ZC7->ZC7_TIPO   := SE1->E1_TIPO
          ZC7->ZC7_CLIFOR	:= SE1->E1_CLIENTE
          ZC7->ZC7_LOJA  	:= SE1->E1_LOJA
          ZC7->ZC7_VLRBLQ := cE1VALOR
          ZC7->ZC7_CNABDE := cE1DSCFINN
          ZC7->ZC7_TPBLQ 	:= cTpDivf
          ZC7->ZC7_DSCBLQ	:= sDscBlq
          ZC7->ZC7_RECPAG := "R"
          ZC7->ZC7_USRALT := __cUserID
        MSUnlock()
      ENDIF
    ELSE
      RecLock("ZC7",.T.)
        ZC7->ZC7_FILIAL := FwxFilial("SE1")
        ZC7->ZC7_PREFIX	:= SE1->E1_PREFIXO
        ZC7->ZC7_NUM   	:= SE1->E1_NUM
        ZC7->ZC7_PARCEL	:= SE1->E1_PARCELA
        ZC7->ZC7_TIPO   := SE1->E1_TIPO
        ZC7->ZC7_CLIFOR	:= SE1->E1_CLIENTE
        ZC7->ZC7_LOJA  	:= SE1->E1_LOJA
        ZC7->ZC7_VLRBLQ := cE1VALOR
        ZC7->ZC7_CNABDE := cE1DSCFINN
        ZC7->ZC7_TPBLQ 	:= cTpDivf
        ZC7->ZC7_DSCBLQ	:= sDscBlq
        ZC7->ZC7_RECPAG := "R"
        ZC7->ZC7_USRALT := __cUserID
      MSUnlock()
    ENDIF

  ENDIF

  //@history TI - Leonardo P. Monteiro - 15/03/2022 - Gravação no campo XCODLOJ a concatenação do código do cliente e loja.
  RECLOCK("SE1",.F.)
    SE1->E1_XCODLOJ := SE1->E1_CLIENTE+SE1->E1_LOJA
  SE1->(MSUNLOCK())
Return 
