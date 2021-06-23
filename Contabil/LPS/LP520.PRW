#Include "TOTVS.CH"
/*/{Protheus.doc} User Function LP520001
  Para atendimento do chamado 058353 conforme alinhamento entre Wagner e Danielle Meira
  Encontra o valor do juros a ser debitado da conta transitória referente à baixa quando
  o título for do tipo REN (RENEGOCIACAO DE DIVIDAS)
  @type  Function
  @author Abel Babini
  @since 01/09/2020
  @history Chamado 058353 - Abel Babini - 01/09/2020 - Versão inicial
  /*/            
User Function LP520001()    
  Local _nRet   := 0
  Local _nVlJrs := 0
  Local _nQtTit := 0
  Local cQr1    := ''
  Local cQr2    := ''
  Local cNumLiq := ''

  U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

  IF SE5->E5_TIPO == "REN"
    cNumLiq := SE1->E1_NUMLIQ

    cQr1:=GetNextAlias()

    BeginSQL  Alias cQr1
      SELECT SUM(FO1.FO1_VLJUR+FO1.FO1_VLMUL) AS VLJUR
      FROM %TABLE:FO0% FO0 (NOLOCK)
      LEFT JOIN %TABLE:FO1% FO1 (NOLOCK) ON
        FO1.FO1_FILIAL = FO0.FO0_FILIAL
      AND FO1.FO1_PROCES = FO0.FO0_PROCES
      AND FO1.%notDel%
      WHERE
      FO0.%notDel%
      AND FO0.FO0_FILIAL=%xFilial:FO0%
      AND FO0.FO0_NUMLIQ = %Exp:cNumLiq%
    EndSQL
    DbSelectArea(cQr1)
    (cQr1)->(DbGoTop())
    While !(cQr1)->(eof())
      _nVlJrs := _nVlJrs+(cQr1)->VLJUR
      (cQr1)->(DbSkip())
    EndDo
    (cQr1)->(dbCloseArea())

    IF _nVlJrs > 0 
      cQr2:=GetNextAlias()

      BeginSQL  Alias cQr2
        SELECT COUNT(FO2.FO2_PROCES) AS QTTITS
        FROM %TABLE:FO0% FO0 (NOLOCK)
        LEFT JOIN %TABLE:FO2% FO2 (NOLOCK) ON
          FO2.FO2_FILIAL = FO0.FO0_FILIAL
        AND FO2.FO2_PROCES = FO0.FO0_PROCES
        AND FO2.%notDel%
        WHERE
          FO0.FO0_FILIAL = %xFilial:FO0%
        AND FO0.FO0_NUMLIQ = %Exp:cNumLiq%
        AND FO0.%notDel%
      EndSQL

      DbSelectArea(cQr2)
      (cQr2)->(DbGoTop())
      While !(cQr2)->(eof())
        _nQtTit := _nQtTit+(cQr2)->QTTITS
        (cQr2)->(DbSkip())
      EndDo
      (cQr2)->(dbCloseArea())

      IF _nQtTit > 0
        _nRet := Round(_nVlJrs / _nQtTit,2)
      ENDIF
    ENDIF
  ENDIF
  
Return(_nRet)
