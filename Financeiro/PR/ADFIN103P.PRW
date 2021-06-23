#INCLUDE "TOTVS.CH"
/*/{Protheus.doc} User Function ADFIN103P()
  Análise de Crédito
  @type  Function
  @author Abel Babini
  @since 02/02/2021
  @history Ticket 8      - Abel Babini - 02/02/2021 - Criação de Rotina para cálculo da média de atraso e Perfil de Pagamento
  @history Ticket 8      - Abel Babini - 07/02/2021 - Correção no cálculo do Perfil de Pagamento. Retirando campo filial das cláusulas WHERE
  @history Ticket 8      - Abel Babini - 14/06/2021 - Correção no cálculo do Perfil de Pagamento para considerar redes no calculo de Inatividade e/ou NDA
/*/
User Function ADFIN103P()
    //Inicia o ambiente. 
	RPCSetType(3)
	RpcSetEnv("01","02",,,,GetEnvServer(),{ })

    U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Esta rotina atualiza media de atraso e perfil de pagamento dos clientes.')

    //
    xCalcMAt()

    //Fecha o ambiente.
	RpcClearEnv()

Return

//Ticket 8      - Abel Babini - 02/02/2021 - Criação de Rotina para cálculo da média de atraso e Perfil de Pagamento
/*/{Protheus.doc} User Function xCalcMAt
  Processa o envio dos relatórios.
  @type  Function
  @author user
  @since 02/02/2021
  @version 01
/*/
Static Function xCalcMAt()
  Local aArea := GetArea()
  Local nAux      := 1
  Local aEmp      := FWLoadSM0()
  Local cProc     := ""

  For nAux = 1 To Len(aEmp)

    If aEmp[nAux][16] == "0" .And. ! aEmp[nAux][1] $ cProc .AND. ! aEmp[nAux][1] $ '03/06/07/08/09/10' //As empresas 03/06/08/10/07/09 não possuem os campos necessários para execução da rotina nas tabelas SA1 e PB3
      cProc += aEmp[nAux][1] + "/"
      // startjob("U_xADFI103",getenvserver(),.T.,aEmp[nAux][1],aEmp[nAux][2])
      U_xADFI103(aEmp[nAux][1],aEmp[nAux][2])

    EndIf

  Next nAux

  RestArea(aArea)
Return

/*/{Protheus.doc} User Function xADFI103
  Atualiza Media de Atraso e Perfil de Pagamento no Cadastro de Clientes
  @type  Function
  @author user
  @since 02/02/2021
  @version 01
/*/
User Function xADFI103(cEmpMAt,cFilMAt)
  Local cAls001   := GetNextAlias()
  Local cAuxRede  := ''
  Local aCalc     := Array(2)
  Local aMedPgt   := {}

  aCalc[1]  := 0 //Media de Atraso
  aCalc[2]  := '' //Perfil de Pagto

	RPCSetType(3)
	RpcSetEnv(cEmpMAt,cFilMAt,,,,GetEnvServer(),{ })

  BeginSql alias cAls001
    SELECT A1_COD, A1_LOJA, A1_CGC, A1_CODRED, ISNULL(ZF_REDE,'') AS ZF_REDE
    FROM %TABLE:SA1%  SA1 (NOLOCK)
	    LEFT JOIN %TABLE:SZF% SZF (NOLOCK) ON
		    SZF.D_E_L_E_T_ = ''
      AND SZF.ZF_FILIAL = SA1.A1_FILIAL
      AND SZF.ZF_CGCMAT = SUBSTRING(SA1.A1_CGC,1,8)
    WHERE A1_MSBLQL <> '1'
    AND SA1.D_E_L_E_T_ = ''
    ORDER BY ZF_REDE, A1_COD, A1_LOJA
  EndSql

  (cAls001)->(DBGoTop())
  WHILE !(cAls001)->(eof())
    IF Alltrim(cAuxRede) != Alltrim((cAls001)->ZF_REDE) .OR. Alltrim((cAls001)->ZF_REDE) == ''
      aCalc := {0,''}
      aCalc := fCalcAtr((cAls001)->A1_COD, (cAls001)->A1_LOJA)
    ELSE
      i := 0
    ENDIF
    
    aMedPgt := fMedPgt((cAls001)->A1_COD, (cAls001)->A1_LOJA) //Retorna a média de atraso e perfil de pagamento atual.
    IF aMedPgt[1] != aCalc[1] .OR. aMedPgt[2] != aCalc[2]
      dbSelectArea('ZG9')
      ZG9->(dbSetOrder(1))
      IF ZG9->(dbSeek(xFilial('ZG9')+(cAls001)->A1_COD+(cAls001)->A1_LOJA+DTOS(msDate())))
        IF (ZG9->ZG9_XMEDAT <> ROUND(aCalc[1],2) .OR. ZG9->ZG9_XPERPG <> aCalc[2])
          // GRAVA LOG DE ALTERAÇÃO DA MEDIA DE ATRASO E PERFIL DE PAGAMENTO QUANDO FOR DENTRO DO MESMO DIA A EXECUÇÃO
          u_GrLogZBE (Date(),TIME(),"SISTEMA"," REPROGRAMACAO","CREDITO","ADFIN103",;
                    "CLIENTE "+(cAls001)->A1_COD+;
                    " LOJA "+(cAls001)->A1_LOJA+;
                    " MEDIA DE "+Alltrim(Str(ZG9->ZG9_XMEDAT))+" PARA "+Alltrim(Str(aCalc[1]))+;
                    " PERFIL DE "+Alltrim(ZG9->ZG9_XPERPG)+" PARA "+Alltrim(aCalc[2]),ComputerName(),LogUserName())
          RecLock("ZG9",.F.)
            ZG9->ZG9_XMEDAT := Round(aCalc[1],2)
            ZG9->ZG9_XPERPG := aCalc[2]
          ZG9->(MsUnlock())
        ENDIF
      ELSE
        RecLock("ZG9",.T.)
          ZG9->ZG9_FILIAL := xFilial('ZG9')
          ZG9->ZG9_COD    := (cAls001)->A1_COD
          ZG9->ZG9_LOJA   := (cAls001)->A1_LOJA
          ZG9->ZG9_DATA   := msDate()
          ZG9->ZG9_XMEDAT := aCalc[1]
          ZG9->ZG9_XPERPG := aCalc[2]
        ZG9->(MsUnlock())
      ENDIF
    ENDIF

    cAuxRede := ALLTRIM((cAls001)->ZF_REDE)
    (cAls001)->(dbSkip())
  ENDDO

  RpcClearEnv()

Return Nil

/*/{Protheus.doc} User Function fCalcAtr
  Calcula Media de Atraso e Perfil de Pagamento no Cadastro de Clientes
  @type  Function
  @author user
  @since 02/02/2021
  @version 01
/*/
Static Function fCalcAtr(cCodCli, cLojCli)
  Local aRet    := Array(2)
  Local cAls002 := GetNextAlias()
  Local nMVPrz  := GetMV("MV_#NDATRS",,90)
  Local dDtCorte  := dDataBase - nMVPrz
  Local nVlAcPon := 0
  Local nVlSmPon := 0
  Local nDiasAtr := 0
  Local nMedAtr := 0
  // Local i := 0
  Local _cCdClIn := ''


  aRet[1] := 0    //Média de Atraso
  aRet[2] := ''   //Perfil de Pagamento

  aRetRede := StaticCall(M410STTS,fRetClRd,cCodCli,cLojCli)
	_cCdClIn	:= '%'+FormatIn(aRetRede[1],",")+'%'

  
  BeginSQL alias cAls002
    SELECT E1_FILIAL, E1_NUM, E1_VALOR, E1_VENCREA, E1_BAIXA
    FROM %TABLE:SE1% SE1 (NOLOCK)
    WHERE SE1.%notDel%
      AND SE1.E1_CLIENTE+SE1.E1_LOJA IN %Exp:_cCdClIn%
      AND SE1.E1_TIPO NOT IN ('NCC','RA') "
      AND SE1.E1_EMISSAO >= %Exp:DtoS(dDtCorte)%
      AND SE1.E1_VENCREA < E1_BAIXA
      AND E1_BAIXA <> ''
    ORDER BY E1_VENCREA, E1_NUM
  EndSQL
      
    
  (cAls002)->(dbGoTop())
  WHILE !(cAls002)->(eof())
    nDiasAtr := STOD((cAls002)->E1_BAIXA)-STOD((cAls002)->E1_VENCREA)
    nVlAcPon += (cAls002)->E1_VALOR*nDiasAtr
    nVlSmPon += (cAls002)->E1_VALOR*nDiasAtr*nDiasAtr
    (cAls002)->(dbSkip())
  ENDDO
  (cAls002)->(dbCloseArea())

  nMedAtr := ROUND(nVlSmPon / nVlAcPon,2)

  aRet[1]:= nMedAtr
  aRet[2]:= fCPerPgt(nMedAtr, cCodCli, cLojCli, _cCdClIn)

Return aRet


/*/{Protheus.doc} User Function fCPerPgt
  Calcula o Pergil de Pagamento conforme a média de atrazo do cliente.
  @type  Function
  @author user
  @since 02/02/2021
  @version 01
/*/
Static Function fCPerPgt(nMedAtr, cCodCli, cLojCli, _cCdClIn)
	Local aArea		:= GetArea()
  Local cRet    := ''
	// Local aRet		:= Array(4)
  // Local cCdPgt  := Posicione('SA1',1,xFilial('SA1')+cCodCli+cLojCli,'A1_COND')
	// Local dUltCom	:= Posicione('SA1',1,xFilial('SA1')+cCodCli+cLojCli,'A1_ULTCOM')
	//Local medAtrz	:= Posicione('SA1',1,xFilial('SA1')+cCodCli+cLojCli,'A1_METR')
	// Local nPgto90	:= Val(DTOS(dDataBase)) - Val(DTOS(dUltCom))
  // Local cCpAd   := Posicione('SE4',1,xFilial('SE4')+cCdPgt,'E4_CTRADT')
  Local lCpAd   := fVerCPag(cCodCli, cLojCli, _cCdClIn)
  Local nPgtoHst:= 0
	Local nValPDD	:= 0
	// Local nValTEsp:= 0 

  Local cQuery2 := '' //NDA
	Local cQuery3	:= '' //PDD
	Local cQuery4	:= '' //CAR

	Local _nMVPrz1	:= GETMV("MV_#PRZP01",,90) //Quantidade de dias sem emissão de títulos para cliente ser considerado inativo
	Local _nMVPrz2	:= GETMV("MV_#PRZP02",,180) //Quantidade de dias sem emissão de títulos para verificar clientes inativados.
	Local _nMVPrz3	:= GETMV("MV_#PRZP03",,8) //Quantidade de pagamentos mínimos para considerar sem histórico.

	Local dDtInat	:= dDatabase-_nMVPrz1
	Local dDtNDA	:= dDatabase-_nMVPrz2
	Local lPrimReg:= .T.
	Local lInativo:= .F.
	Local lNDA		:= .F.
	Local dDtPrCom:= dDatabase

  Local _cMVPrtE	:= GETMV("MV_#PRTESP",,'P07,P08,P11,P15,P16,P99') //Código dos Portadores Especiais para Relatório de Pedidos Liberados ADFIN088R
	Local _cPrtEsp	:= '%'+FormatIn(_cMVPrtE,",")+'%'

  Local _cMVTpTt	:= GETMV("MV_#TPTIT",,'NF ,REN') //Tipos de Títulos considerados no relatório ADFIN088R
	Local _cTipoTt	:= '%'+FormatIn(_cMVTpTt,",")+'%'  //Utiliar lógica desenvolvida anteriormente. Histórico ADFIN023P

	//NDA e/ou INA
	cQuery2:=GetNextAlias()
  //Ticket 8      - Abel Babini - 07/02/2021 - Correção no cálculo do Perfil de Pagamento. Retirando campo filial das cláusulas WHERE
  //INICIO Ticket 8      - Abel Babini - 14/06/2021 - Correção no cálculo do Perfil de Pagamento para considerar redes no calculo de Inatividade e/ou NDA
  /*
  BEGINSQL Alias cQuery2
		COLUMN EMISSAO AS DATE
		COLUMN ANTERIOR AS DATE
		SELECT 
			SE1.E1_EMISSAO  AS EMISSAO,
			MAX(SE1B.E1_EMISSAO) AS ANTERIOR,
			DATEDIFF(DAY,SE1.E1_EMISSAO, MAX(SE1B.E1_EMISSAO)) AS DIASDIFF
		FROM %TABLE:SE1% SE1 (NOLOCK)
		LEFT JOIN %TABLE:SE1% SE1B (NOLOCK) ON
			SE1B.E1_FILIAL = SE1.E1_FILIAL
			AND SE1B.E1_CLIENTE = SE1.E1_CLIENTE
			AND SE1B.E1_LOJA = SE1.E1_LOJA
			AND SE1B.E1_EMISSAO < SE1.E1_EMISSAO
			AND SE1B.%notDel%
		WHERE 
      SE1.E1_CLIENTE+SE1.E1_LOJA IN %Exp:_cCdClIn%
			AND SE1.E1_EMISSAO >= %Exp:dDtNDA%
			AND SE1.E1_TIPO IN %Exp:_cTipoTt%
			AND SE1.%notDel%
		GROUP BY SE1.E1_EMISSAO
		ORDER BY SE1.E1_EMISSAO DESC
  ENDSQL
  */
	
  BEGINSQL  Alias cQuery2
		COLUMN EMISSAO AS DATE
		COLUMN ANTERIOR AS DATE
    SELECT 
    CLIENTE,
    EMISSAO,
    ANTERIOR = LAG(EMISSAO) OVER (PARTITION BY CLIENTE ORDER BY EMISSAO DESC),
    DATEDIFF(DAY, EMISSAO, LAG(EMISSAO) OVER (PARTITION BY CLIENTE ORDER BY EMISSAO DESC)) AS DIASDIFF
  FROM (
    SELECT
      '1' AS CLIENTE,
      SE1.E1_EMISSAO AS EMISSAO
    FROM SE1010 SE1 (NOLOCK)
    WHERE 
    SE1.E1_CLIENTE+SE1.E1_LOJA IN %Exp:_cCdClIn%
    AND SE1.E1_EMISSAO >= %Exp:dDtNDA%
		AND SE1.E1_TIPO IN %Exp:_cTipoTt%
    AND SE1.%notDel%
    GROUP BY SE1.E1_EMISSAO
    ) AS RES
    ORDER BY EMISSAO DESC
  ENDSQL
  //FIM Ticket 8      - Abel Babini - 14/06/2021 - Correção no cálculo do Perfil de Pagamento para considerar redes no calculo de Inatividade e/ou NDA

  DbSelectArea(cQuery2)
  //Se já existiu títulos não é um cliente novo
  nPgtoHst := Contar(cQuery2,"!Eof()")
	(cQuery2)->(dbGoTop())

	WHILE !(cQuery2)->(eof())
		//Verifica se o Cliente está inativo, ou seja, não foi emitido nenhum titulo nos últimos 90 dias
		IF lPrimReg
			lPrimReg := .F.
			// dDtUlCom := (cQuery2)->EMISSAO
			IF (cQuery2)->EMISSAO < dDtInat
				lInativo	:= .T.
			ENDIF
		ENDIF

		dDtPrCom := (cQuery2)->EMISSAO

		// Se ficou 180 dias sem comprar e a data da compra estiver dentro dos 270 dias, será considerado NDA
		IF (cQuery2)->DIASDIFF < -_nMVPrz2 .AND. (cQuery2)->ANTERIOR >= dDtNDA
			lNDA	:= .T.
		ENDIF
		(cQuery2)->(dbSkip())
	ENDDO
  (cQuery2)->(dbCloseArea())
	
	IF (nPgtoHst == 0) .OR. (nPgtoHst > 0 .AND. dDtPrCom > dDtInat) .or. nPgtoHst < _nMVPrz3
		lNDA	:= .T.
	ENDIF

  cQuery3:=GetNextAlias()
  //Ticket 8      - Abel Babini - 07/02/2021 - Correção no cálculo do Perfil de Pagamento. Retirando campo filial das cláusulas WHERE
  BEGINSQL Alias cQuery3
    SELECT SUM(E1_VALOR) AS VALPDD
      FROM %TABLE:SE1% SE1 (NOLOCK)
      WHERE
				SE1.E1_CLIENTE+SE1.E1_LOJA IN %Exp:_cCdClIn%
				AND SE1.E1_PORTADO = 'P99'
				AND SE1.E1_TIPO IN %Exp:_cTipoTt%
				AND SE1.%notDel%
  ENDSQL
	(cQuery3)->(dbGoTop())
	IF !(cQuery3)->(eof())
  	nValPDD  := (cQuery3)->VALPDD
	ENDIF
  (cQuery3)->(dbCloseArea())

	cQuery4:=GetNextAlias()
  //Ticket 8      - Abel Babini - 07/02/2021 - Correção no cálculo do Perfil de Pagamento. Retirando campo filial das cláusulas WHERE
  BEGINSQL Alias cQuery4
    SELECT 
			COUNT(E1_VALOR) AS NUMESP,
			SUM(E1_VALOR) AS VALESP
      FROM %TABLE:SE1% SE1 (NOLOCK)
      WHERE
				SE1.E1_CLIENTE+SE1.E1_LOJA IN %Exp:_cCdClIn%
				AND SE1.E1_PORTADO IN %Exp:_cPrtEsp%
				AND SE1.E1_TIPO IN %Exp:_cTipoTt%
				AND SE1.%notDel%
  ENDSQL
	(cQuery4)->(dbGoTop())
	IF !(cQuery4)->(eof())
  	//nValTEsp  := (cQuery4)->VALESP
		nQtdEsp		:= (cQuery4)->NUMESP
	ENDIF
  (cQuery4)->(dbCloseArea())

  // PERFIL CLIENTES COM HISTORICO DE PERDAS - PDD
  // Clientes tiveram títulos lançados em perdas ou que foram bloqueados por este motivo.
  // Sistema devera incluir este perfil em seu cadastro para avisar ao analista de credito que o cliente tem dpl lançada em perdas e ainda continua devedor à Ad’oro.
	IF nValPDD > 0
	  cRet  := 'PDD - HISTORICO DE PERDAS'

	// Perfil CAR – Cobrança em Cartório ou Assessoria
	// Se o cliente possuir títulos emitidos nos últimos 365 dias cuja carteira seja “P07, P08, P11, P15, P16” 
	// ele será classificado como CAR.
	ELSEIF nQtdEsp > 0
	  cRet  := 'CAR - COBRANCA EM CARTORIO OU ASSESSORIA'

  // PERFIL CLIENTE INATIVO - INA
  // Se o cliente teve o último título emitido a mais de 180 dias ele será classificado como INA.
	// Caso um cliente seja classificado como INA e volte a realizar compras, ele será classificado como NDA por 90 dias.
  ELSEIF lInativo
    cRet  := 'INA - INATIVO'

	//PERFIL PAGAMENTO AINDA NÃO DISPONIVEL – NDA
  //Cliente novo, Por exemplo, serão considerados os pagamentos dos últimos 90 dias.
  ELSEIF lNDA
    cRet  := 'NDA - NAO DISPONIVEL'
  
  // PERFIL PAGAMENTO ANTECIPADO – ANT
  // Clientes com perfil de pagamento com liberação de credito somente após a confirmação do pagamento antecipado do cliente.
  ELSEIF lCpAd
    cRet  := 'ANT - ANTECIPADO'

  // PERFIL PAGAMENTO PONTUAL - PON
  // Clientes com media de atrasos de pagamento de até 1 dia atraso
  ELSEIF nMedAtr <= 1
    cRet  := 'PON - PONTUAL'

  // PERFIL PAGAMENTO PEQUENO ATRASO – ATP
  // Clientes com media de atrasos de pagamento de 1,01 a 3 dias de atraso
  ELSEIF nMedAtr <= 3
    cRet  := 'ATP - PEQUENO ATRASO'

  // PERFIL PAGAMENTO GRANDE ATRASO – ATG
  // Clientes com media de atrasos de pagamento de 3,01 acima e com 3 meses ou mais de pagamentos ininterruptos.
  ELSEIF nMedAtr > 3
    cRet  := 'ATR - PAGAMENTO EM ATRASO'

  ENDIF
  RestArea(aArea)
Return cRet

/*/{Protheus.doc} User Function fVerCPag
  Verifica se o cliente ou rede possui Condição de Pagamento Antecipada
  @type  Function
  @author Abel Babini
  @since 02/02/2021
  @version 01
/*/
Static Function fVerCPag(cCodCli, cLojCli, _cCdClIn)
  Local lRet := .F.
  Local cAls003 := GetNextAlias()

  BeginSql alias cAls003
    SELECT SUM(CASE WHEN E4_CTRADT = '1' THEN 1 ELSE 0 END) AS TEM_ADT
    FROM %TABLE:SA1% SA1 (NOLOCK)
    LEFT JOIN %TABLE:SE4% SE4 (NOLOCK) ON
      SE4.E4_CODIGO = SA1.A1_COND
      AND SE4.%notDel%
    WHERE SA1.%notDel%
      AND SA1.A1_MSBLQL <> '1'
      AND SA1.A1_COD+SA1.A1_LOJA IN %Exp:_cCdClIn%
    GROUP BY SA1.A1_CODRED
  EndSQL

  (cAls003)->(DBgOtOP())
  IF (cAls003)->TEM_ADT > 0 
    lRet := .T.
  ENDIF
  (cAls003)->(dbCloseArea())

Return lRet

/*/{Protheus.doc} User Function fMedPgt
  Retorna a média de atraso e perfil de pagamento atual.
  @type  Function
  @author Abel Babini
  @since 02/03/2021
  @version 01
/*/
Static Function fMedPgt(cCodCli, cLojCli)
  Local aRet := {0,''}
  Local cAlsMPgt := GetNextAlias()

  BeginSQL alias cAlsMPgt
    SELECT TOP 1 ZG9_XMEDAT, ZG9_XPERPG
    FROM %TABLE:ZG9% ZG9 (NOLOCK)
    WHERE ZG9.ZG9_COD = %Exp:cCodCli%
      AND ZG9.ZG9_LOJA = %Exp:cLojCli%
      AND ZG9.%notDel%
    ORDER BY ZG9_FILIAL ASC, ZG9_COD ASC, ZG9_LOJA ASC, ZG9_DATA DESC
  ENDSQL
  (cAlsMPgt)->(dbGoTop())

  IF ! (cAlsMPgt)->(EOF())
    aRet[1] := (cAlsMPgt)->ZG9_XMEDAT
    aRet[2] := (cAlsMPgt)->ZG9_XPERPG
  ENDIF
  (cAlsMPgt)->(dbCloseArea())

Return aRet
