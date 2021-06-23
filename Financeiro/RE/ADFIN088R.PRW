/*/{Protheus.doc} User Function ADFIN088R
  Relatório de Pedidos de Venda Liberados
  @type  Function
  @author Abel Babini
  @since 26/05/2020
  @version 1
  @history Chamado 057841 - Abel Babini - 26/05/2020 - Re. Pedidos Liberados, Versão inicial
  @history Chamado 059049 - Eveson - 18/06/2020. Removido (cQuery1)-> para carregar o valor da variável, pois não existe o campo NTTACUM 
  no retorno da consulta.
  /*/
User Function ADFIN088R()
	Local aArea		:= GetArea()
	Local aPergs	:= {}
  Local aRet    := {}

  aAdd( aPergs ,{1,"Data De "     ,Ctod(space(8)),"" ,'.T.',,'.T.',80,.T.})
	aAdd( aPergs ,{1,"Data Até"     ,Ctod(space(8)),"" ,'.T.',,'.T.',80,.T.})
	aAdd( aPergs ,{6,"Local de Gravação",Space(50),"","","",50,.T.,"Todos os arquivos (*.*) |*.*","C:\TEMP\",GETF_RETDIRECTORY + GETF_LOCALHARD + GETF_NETWORKDRIVE})

	//Executa as perguntas ao usuário e só executa o relatório caso o usuário confirme a tela de parâmetros;
	If ParamBox(aPergs ,"Parâmetros ",aRet,,,,,,,,.T.,.T.)


    MsgRun( "Carregando dados - Pedidos Liberados, aguarde...",,{ || RPEDLIB(aRet[1], aRet[2], aRet[3]) } )

  Endif

  RestArea(aArea)

Return

/*/{Protheus.doc} Static Function RPEDLIB
  (long_description)
  @type  Static Function
  @author Abel Babini
  @since 26/05/2020
  /*/
Static Function RPEDLIB(MVPAR01, MVPAR02, CRELPATH)
  Private cQuery1
  Private oExcel		:= FWMSEXCELEX():New()
  Private oMsExcel	:= NIL
  Private cWorksht	:= 'LibPedidos'
  Private cPlan01		:= 'Liberação de Pedidos - Detalhes'
  Private cArquivo  := Alltrim(CRELPATH) +  'LIBPEDIDOS_' + DTOS(DATE()) + STRTRAN(TIME(),':','') + '.XML'
  
  cQuery1:=GetNextAlias()

  BeginSql Alias cQuery1
    SELECT
      SC5.C5_CLIENTE  AS CODCLI,
      SC5.C5_LOJACLI  AS LOJACLI,
      SA1.A1_NOME     AS CLIENTE,
      SA1.A1_SATIV1   AS CODSEGMENTO,
      SX5.X5_DESCRI   AS SEGMENTO,
      SC5.C5_NUM      AS NUMPEDIDO,
      ''              AS PERFILPAGTO,
      SA1.A1_XRISCO   AS RCISP,
      (SELECT TOP 1 ZBH.ZBH_MOTIVO
        FROM %TABLE:ZBH% ZBH  (NOLOCK)
        WHERE 
          ZBH.ZBH_FILIAL = SC5.C5_FILIAL
        AND ZBH.ZBH_PEDIDO = SC5.C5_NUM
        AND ZBH.ZBH_CLIENT = SC5.C5_CLIENTE
        AND ZBH.ZBH_LOJA = SC5.C5_LOJACLI
        AND ZBH.%notDel%
      )               AS MOT_RETENCAO,
      ''              AS MED_ATRASO,
      (SELECT SUM(SC6.C6_VALOR)
        FROM %TABLE:SC6% SC6 (NOLOCK)
        WHERE 
          SC6.C6_FILIAL = SC5.C5_FILIAL
        AND SC6.C6_NUM = SC5.C5_NUM
        AND SC6.C6_CLI = SC5.C5_CLIENTE
        AND SC6.C6_LOJA = SC5.C5_LOJACLI
        AND SC6.%notDel%
      )               AS TOT_PEDIDO,
      (SELECT SUM(E1_VLCRUZ) 
        FROM %TABLE:SE1% SE1 (NOLOCK)
        WHERE
          SE1.E1_FILIAL = SC5.C5_FILIAL
        AND SE1.E1_CLIENTE = SC5.C5_CLIENTE
        AND SE1.E1_LOJA = SC5.C5_LOJACLI
        AND SE1.E1_SALDO > 0
        AND SE1.E1_VENCREA >= %Exp:ddatabase%
        AND SE1.%notDel%
      )               AS TIT_AVENCER,
      (SELECT SUM(E1_VLCRUZ) 
        FROM %TABLE:SE1% SE1 (NOLOCK)
        WHERE
          SE1.E1_FILIAL = SC5.C5_FILIAL
        AND SE1.E1_CLIENTE = SC5.C5_CLIENTE
        AND SE1.E1_LOJA = SC5.C5_LOJACLI
        AND SE1.E1_SALDO > 0
        AND SE1.E1_VENCREA < %Exp:ddatabase%
        AND SE1.%notDel%
      )               AS TIT_VENCIDO,
      SA1.A1_LC       AS LIMITE,
      (SELECT TOP 1 ZBE.ZBE_USUARI 
        FROM %TABLE:ZBE% ZBE (NOLOCK)
        WHERE ZBE_FILIAL = SC5.C5_FILIAL
        AND ZBE_MODULO = 'SC5'
        AND ZBE_ROTINA  IN ('ADFIN024P','ADFIN023P')
        AND SUBSTRING(ZBE_LOG,8,6) = SC5.C5_NUM
        AND ZBE.%notDel%
      )               AS LIBERADOR,
      ''              AS TXT_LIBERACAO
    FROM %TABLE:SC5% SC5 (NOLOCK)
    LEFT JOIN %TABLE:SA1% SA1 ON
	    SA1.A1_COD = SC5.C5_CLIENTE
    AND SA1.A1_LOJA = SC5.C5_LOJACLI
    AND SA1.%notDel%
    LEFT JOIN %TABLE:SX5% SX5 ON
	    SX5.X5_FILIAL = SC5.C5_FILIAL
    AND SX5.X5_TABELA = '_S'
    AND SX5.X5_CHAVE = SA1.A1_SATIV1
    AND SX5.%notDel%
    WHERE 
      SC5.C5_FILIAL = %xFilial:SC5%
    AND SC5.C5_DTENTR BETWEEN %EXP:DTOS(MVPAR01)% AND %EXP:DTOS(MVPAR02)%
    AND SC5.C5_TIPO NOT IN ('D','B')
    AND SC5.%notDel%
  EndSql

  // Cria estrutura do Excel
  BEGIN SEQUENCE
    
    IF .NOT.( ApOleClient("MsExcel") )   // se nao existir o excel sai fora..
      Alert("Nao Existe Excel Instalado")
      BREAK
    EndIF
          
    //Planilha1 - Detalhamento
    ExlCab01()             
    ExlDet01()					

    SalvaXml()
    CriaExcel()
  
  END SEQUENCE

  (cQuery1)->(dbCloseArea())
Return

/*/{Protheus.doc} Static Function ExlCab01
  Cabeçalho da Planilha - Relatório Pedidos Liberados
  @type  Static Function
  @author Abel Babini
  @since 01/06/2020
  /*/
Static Function ExlCab01()
  
	oExcel:AddworkSheet(cWorksht)
	oExcel:AddTable(cWorksht,cPlan01)
	oExcel:AddColumn(cWorksht,cPlan01,"Empresa"				        ,1,1)
	oExcel:AddColumn(cWorksht,cPlan01,"Filial"				        ,1,1)
	oExcel:AddColumn(cWorksht,cPlan01,"Cod.Cliente"		        ,1,1)
	oExcel:AddColumn(cWorksht,cPlan01,"Loja.Cliente"	        ,1,1)
	oExcel:AddColumn(cWorksht,cPlan01,"Cliente"			          ,1,1)
	oExcel:AddColumn(cWorksht,cPlan01,"Segmento"				      ,1,1)
	oExcel:AddColumn(cWorksht,cPlan01,"Nº Pedido"			        ,1,1)
	oExcel:AddColumn(cWorksht,cPlan01,"Perfil Pagto"			    ,1,1)
	oExcel:AddColumn(cWorksht,cPlan01,"Rating CISP"		        ,1,1)
	oExcel:AddColumn(cWorksht,cPlan01,"Motivo Retenção"	      ,1,1)
	oExcel:AddColumn(cWorksht,cPlan01,"Média Atraso Cliente"	,1,1)
	oExcel:AddColumn(cWorksht,cPlan01,"Vl.Pedido"				      ,2,2,.T.)
	oExcel:AddColumn(cWorksht,cPlan01,"Tit.A Vencer"			    ,2,3,.T.)
	oExcel:AddColumn(cWorksht,cPlan01,"Tit.Vencidos"			    ,2,3,.T.)
	oExcel:AddColumn(cWorksht,cPlan01,"Tit.Port.Especial"		  ,2,3,.T.)
	oExcel:AddColumn(cWorksht,cPlan01,"Tot. Acumulado"			  ,2,3,.T.)
	oExcel:AddColumn(cWorksht,cPlan01,"Limite Crédito"			  ,2,3,.T.)
  oExcel:AddColumn(cWorksht,cPlan01,"Login Liberador"			  ,1,1)
	oExcel:AddColumn(cWorksht,cPlan01,"Texto Liberação"			  ,1,1)

	
Return 

/*/{Protheus.doc} Static Function ExlDet01
  Conteúdo da Planilha - Relatório Pedidos Liberados
  @type  Static Function
  @author Abel Babini
  @since 01/06/2020
  /*/
Static Function ExlDet01()
  Local nTtAcum := 0
  DbSelectArea(cQuery1)
  (cQuery1)->(DbGoTop())
  While !(cQuery1)->(eof())
    IF Alltrim((cQuery1)->MOT_RETENCAO) <> '' .AND. (cQuery1)->MOT_RETENCAO <> nil
      nTtAcum := (cQuery1)->TOT_PEDIDO + (cQuery1)->TIT_AVENCER + (cQuery1)->TIT_VENCIDO
      oExcel:AddRow(cWorksht,cPlan01,{;
                                      cEmpAnt,;
                                      cFilAnt,;
                                      (cQuery1)->CODCLI,;
                                      (cQuery1)->LOJACLI,;
                                      (cQuery1)->CLIENTE,;
                                      (cQuery1)->SEGMENTO,;
                                      (cQuery1)->NUMPEDIDO,;
                                      (cQuery1)->PERFILPAGTO,;
                                      (cQuery1)->RCISP,;
                                      (cQuery1)->MOT_RETENCAO,;
                                      (cQuery1)->MED_ATRASO,;
                                      (cQuery1)->TOT_PEDIDO,;
                                      (cQuery1)->TIT_AVENCER,;
                                      (cQuery1)->TIT_VENCIDO,;
                                      nTtAcum,; //Tot Port Especial //Everson - 18/06/2020. Chamado 059049. Removido (cQuery1)->
                                      nTtAcum,; //Everson - 18/06/2020. Chamado 059049. Removido (cQuery1)->
                                      (cQuery1)->LIMITE,;
                                      (cQuery1)->LIBERADOR,;
                                      (cQuery1)->TXT_LIBERACAO})
    ENDIF 

    (cQuery1)->(DbSkip())
  EndDo
  
  oExcel:AddRow(cWorksht,cPlan01,{"","","","","","","","","","","","","","","","","","",""})

Return 

	/*/{Protheus.doc} Static Function SalvaXml  
	Salva Arquivo XML - Excel
	@author Abel Babini Filho
	@since 01/06/2020
	@version 01
	/*/
	Static Function SalvaXml()
	oExcel:Activate()
	oExcel:GetXMLFile(cArquivo)
Return()

/*/{Protheus.doc} Static Function CriaExcel  
	Cria Arquivo XML - Excel
	@author Abel Babini Filho
	@since 01/06/2020
	@version 01
	/*/
Static Function CriaExcel()
  oMsExcel := MsExcel():New()
	oMsExcel:WorkBooks:Open(cArquivo)
	oMsExcel:SetVisible( .T. )
	oMsExcel:Destroy()
Return() 