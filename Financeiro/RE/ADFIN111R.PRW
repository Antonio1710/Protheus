#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} User Function ADFIN111R
  Relatório de Análise de Média de Atraso e Perfil de Pagamento
  @type  Function
  @author Abel babini
  @since 12/04/2021
  @version 1
  @history Ticket      9 - Abel Babini - 26/04/2021 - Correção de Error.log
  /*/
User Function ADFIN111R()
  Local aArea     := GetArea()
  Local aPergs	  := {}
  Local aRet      := {}
  Private lAbortPrint:=.F.

  aAdd( aPergs ,{1,"Data De "         ,Ctod(space(8)),"" ,'.T.',,'.T.',80,.T.})
	aAdd( aPergs ,{1,"Data Até"         ,Ctod(space(8)),"" ,'.T.',,'.T.',80,.T.})
  aAdd( aPergs ,{1,"Cliente De "      ,space(6),"" ,'.T.','SA1','.T.',80,.F.})
  aAdd( aPergs ,{1,"Loja De "         ,space(2),"" ,'.T.',,'.T.',80,.F.})
	aAdd( aPergs ,{1,"Cliente Até"      ,space(6),"" ,'.T.','SA1','.T.',80,.T.})
	aAdd( aPergs ,{1,"Loja Até"         ,space(2),"" ,'.T.',,'.T.',80,.T.})
	aAdd( aPergs ,{6,"Local de Gravação",Space(80),"","","",80,.T.,"Todos os arquivos (*.*) |*.*","C:\TEMP\",GETF_RETDIRECTORY + GETF_LOCALHARD + GETF_NETWORKDRIVE})

	//Executa as perguntas ao usuário e só executa o relatório caso o usuário confirme a tela de parâmetros;
	If ParamBox(aPergs ,"Parâmetros ",aRet,,,,,,,,.T.,.T.)
    Processa( {|| XFIN111R(aRet) }, "Aguarde...", "Processando o relatório...",.T.)
  Endif

  RestArea(aArea)

  //
  U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Relatório de Análise de Média de Atraso e Perfil de Pagamento')


Return nil

/*/{Protheus.doc} User Function nomeFunction
  (long_description)
  @type  Function
  @author user
  @since 13/04/2021
  @version version
  @param param_name, param_type, param_descr
  @return return_var, return_type, return_description
  @example
  (examples)
  @see (links_or_references)
  /*/
Static Function XFIN111R(aRet)
  Local cAlias    := GetNextAlias()
  Local oExcel    := FWMSEXCELEX():New()
  Local oMsExcel  := NIL
  Local cArquivo  := ''
  Local cWrkSht   := 'PERFIL_PGT'
  Local cTable    := 'Análise Perfil de Pagamento'
  Local aDPrfPgt  := {}
  Local nPos      := 0
  Local i         := 0

  BeginSQL alias cAlias
    column ZG9_DATA as Date
    SELECT
      ZG9.ZG9_COD,
      ZG9.ZG9_LOJA,
      SA1.A1_NOME,
      ZG9.ZG9_DATA,
      ZG9.ZG9_XMEDAT,
      ZG9.ZG9_XPERPG
    FROM %TABLE:ZG9% ZG9 (NOLOCK)
    INNER JOIN %TABLE:SA1% SA1 (NOLOCK) ON
      A1_COD = ZG9_COD
      AND A1_LOJA = ZG9_LOJA
      AND SA1.%notDel%
    WHERE ZG9.%notDel%
    AND ZG9.ZG9_COD BETWEEN %Exp:aRet[3]% AND %Exp:aRet[5]%
    AND ZG9.ZG9_LOJA BETWEEN %Exp:aRet[4]% AND %Exp:aRet[6]%
    AND ZG9.ZG9_DATA BETWEEN %Exp:DToS(aRet[1])% AND %Exp:DToS(aRet[2])%
    ORDER BY ZG9_COD ASC, ZG9_LOJA ASC, ZG9_DATA DESC
  ENDSQL


  DbSelectArea(cAlias)
  (cAlias)->(DbGoTop())

  ProcRegua((cAlias)->(RecCount()))
  While !(cAlias)->(eof()) .AND. !lAbortPrint
    IncProc()
    nPos := ASCAN(aDPrfPgt, {|X| X[1] == (cAlias)->ZG9_COD+(cAlias)->ZG9_LOJA})
    
    If nPos == 0
      nCntDt := 0
      AADD(aDPrfPgt,{ (cAlias)->ZG9_COD+(cAlias)->ZG9_LOJA,;
                      (cAlias)->ZG9_COD,;
                      (cAlias)->ZG9_LOJA,;
                      (cAlias)->A1_NOME,;
                      'SEM DADOS PARA ANÁLISE',;
                      DTOC((cAlias)->ZG9_DATA),;
                      (cAlias)->ZG9_XMEDAT,;
                      (cAlias)->ZG9_XPERPG,;
                      '',;
                      '',;
                      '',;
                      '',;
                      '',;
                      '',;
                      '',;
                      '',;
                      '',;
                      '',;
                      '',;
                      '',;
                      '',;
                      '',;
                      ''})

      nXMedAtr  := (cAlias)->ZG9_XMEDAT
      cPerPgt   := (cAlias)->ZG9_XPERPG
    Elseif nCntDt < 5 //Ticket      9 - Abel Babini - 26/04/2021 - Correção de Error.log
      nCntDt += 1
      // Preenche Análise
      IF nCntDt == 1

        IF  Alltrim(cPerPgt) == Alltrim((cAlias)->ZG9_XPERPG) .AND.;
            nXMedAtr  == (cAlias)->ZG9_XMEDAT
          aDPrfPgt[nPos,5] := 'ESTÁVEL'
        ELSEIF  (Alltrim(cPerPgt) == 'PDD - HISTORICO DE PERDAS' .AND. Alltrim((cAlias)->ZG9_XPERPG) $ 'CAR - COBRANCA EM CARTORIO OU ASSESSORIA|ANT - ANTECIPADO|ATR - PAGAMENTO EM ATRASO|ATP - PEQUENO ATRASO|PON - PONTUAL') .OR. ;
                (Alltrim(cPerPgt) == 'CAR - COBRANCA EM CARTORIO OU ASSESSORIA' .AND. Alltrim((cAlias)->ZG9_XPERPG) $ 'ANT - ANTECIPADO|ATR - PAGAMENTO EM ATRASO|ATP - PEQUENO ATRASO|PON - PONTUAL') .OR. ;
                (Alltrim(cPerPgt) == 'ANT - ANTECIPADO' .AND. Alltrim((cAlias)->ZG9_XPERPG) $ 'ATR - PAGAMENTO EM ATRASO|ATP - PEQUENO ATRASO|PON - PONTUAL') .OR. ;
                (Alltrim(cPerPgt) == 'ATR - PAGAMENTO EM ATRASO' .AND. Alltrim((cAlias)->ZG9_XPERPG) $ 'ATP - PEQUENO ATRASO|PON - PONTUAL') .OR. ;
                (Alltrim(cPerPgt) == 'ATP - PEQUENO ATRASO' .AND. Alltrim((cAlias)->ZG9_XPERPG) $ 'PON - PONTUAL')
          aDPrfPgt[nPos,5] := 'PIOROU PERFIL'
        ELSEIF  (Alltrim(cPerPgt) == 'PON - PONTUAL' .AND. Alltrim((cAlias)->ZG9_XPERPG) $ 'PDD - HISTORICO DE PERDAS|CAR - COBRANCA EM CARTORIO OU ASSESSORIA|ANT - ANTECIPADO|ATR - PAGAMENTO EM ATRASO|ATP - PEQUENO ATRASO') .OR. ;
                (Alltrim(cPerPgt) == 'ATP - PEQUENO ATRASO' .AND. Alltrim((cAlias)->ZG9_XPERPG) $ 'PDD - HISTORICO DE PERDAS|CAR - COBRANCA EM CARTORIO OU ASSESSORIA|ANT - ANTECIPADO|ATR - PAGAMENTO EM ATRASO') .OR. ;
                (Alltrim(cPerPgt) == 'ATR - PAGAMENTO EM ATRASO' .AND. Alltrim((cAlias)->ZG9_XPERPG) $ 'PDD - HISTORICO DE PERDAS|CAR - COBRANCA EM CARTORIO OU ASSESSORIA|ANT - ANTECIPADO') .OR. ;
                (Alltrim(cPerPgt) == 'ANT - ANTECIPADO' .AND. Alltrim((cAlias)->ZG9_XPERPG) $ 'PDD - HISTORICO DE PERDAS|CAR - COBRANCA EM CARTORIO OU ASSESSORIA') .OR. ;
                (Alltrim(cPerPgt) == 'CAR - COBRANCA EM CARTORIO OU ASSESSORIA' .AND. Alltrim((cAlias)->ZG9_XPERPG) $ 'PDD - HISTORICO DE PERDAS')
          aDPrfPgt[nPos,5] := 'MELHOROU PERFIL'
        ELSEIF  Alltrim(cPerPgt) == Alltrim((cAlias)->ZG9_XPERPG) .AND.;
                nXMedAtr < (cAlias)->ZG9_XMEDAT
          aDPrfPgt[nPos,5] := 'MELHOROU MÉDIA DE ATRASO'
        ELSEIF  Alltrim(cPerPgt) == Alltrim((cAlias)->ZG9_XPERPG) .AND.;
                nXMedAtr > (cAlias)->ZG9_XMEDAT
          aDPrfPgt[nPos,5] := 'PIOROU MÉDIA DE ATRASO'
        ELSEIF Alltrim(cPerPgt) == 'INA - INATIVO' .AND. Alltrim((cAlias)->ZG9_XPERPG) $ 'PDD - HISTORICO DE PERDAS|CAR - COBRANCA EM CARTORIO OU ASSESSORIA|ANT - ANTECIPADO|ATR - PAGAMENTO EM ATRASO|ATP - PEQUENO ATRASO|PON - PONTUAL'
          aDPrfPgt[nPos,5] := 'PERFIL INATIVADO'
        ELSEIF Alltrim(cPerPgt) == 'NDA - NAO DISPONIVEL' //.AND. Alltrim((cAlias)->ZG9_XPERPG) $ 'PDD - HISTORICO DE PERDAS|CAR - COBRANCA EM CARTORIO OU ASSESSORIA|ANT - ANTECIPADO|ATR - PAGAMENTO EM ATRASO|ATP - PEQUENO ATRASO|PON - PONTUAL|INA - INATIVO') .OR. ;
          aDPrfPgt[nPos,5] := 'SEM HISTÓRICO DE PERFIL'
        ELSE
          aDPrfPgt[nPos,5] := 'SEM DADOS PARA ANÁLISE'
        ENDIF
      ENDIF

      aDPrfPgt[nPos,nCntDt*3+6] := DTOC((cAlias)->ZG9_DATA)
      aDPrfPgt[nPos,nCntDt*3+7] := (cAlias)->ZG9_XMEDAT
      aDPrfPgt[nPos,nCntDt*3+8] := (cAlias)->ZG9_XPERPG
    Endif
    
    (cAlias)->(DbSkip())
  EndDo
  (cAlias)->(dbCloseArea())

  // Inicializa Excel
  cArquivo := alltrim(aRet[7]) +  'PERFPGT_' + DTOS(DATE()) + STRTRAN(TIME(),':','') + '.XML'
  oExcel:AddworkSheet(cWrkSht)
  oExcel:AddTable(cWrkSht,cTable)
  oExcel:AddColumn(cWrkSht,cTable,"Código",1,1)
  oExcel:AddColumn(cWrkSht,cTable,"Loja",1,1)
  oExcel:AddColumn(cWrkSht,cTable,"Cliente",1,1)
  
  oExcel:AddColumn(cWrkSht,cTable,"Análise",1,1)

  oExcel:AddColumn(cWrkSht,cTable,"Data 1",1,1)
  oExcel:AddColumn(cWrkSht,cTable,"Média Atr. 1",2,2)
  oExcel:AddColumn(cWrkSht,cTable,"Perfil Pgt. 1",1,1)

  oExcel:AddColumn(cWrkSht,cTable,"Data 2",1,1)
  oExcel:AddColumn(cWrkSht,cTable,"Média Atr. 2",2,2)
  oExcel:AddColumn(cWrkSht,cTable,"Perfil Pgt. 2",1,1)

  oExcel:AddColumn(cWrkSht,cTable,"Data 3",1,1)
  oExcel:AddColumn(cWrkSht,cTable,"Média Atr. 3",2,2)
  oExcel:AddColumn(cWrkSht,cTable,"Perfil Pgt. 3",1,1)

  oExcel:AddColumn(cWrkSht,cTable,"Data 4",1,1)
  oExcel:AddColumn(cWrkSht,cTable,"Média Atr. 4",2,2)
  oExcel:AddColumn(cWrkSht,cTable,"Perfil Pgt. 4",1,1)

  oExcel:AddColumn(cWrkSht,cTable,"Data 5",1,1)
  oExcel:AddColumn(cWrkSht,cTable,"Média Atr. 5",2,2)
  oExcel:AddColumn(cWrkSht,cTable,"Perfil Pgt. 5",1,1)

  oExcel:AddColumn(cWrkSht,cTable,"Data 6",1,1)
  oExcel:AddColumn(cWrkSht,cTable,"Média Atr. 6",2,2)
  oExcel:AddColumn(cWrkSht,cTable,"Perfil Pgt. 6",1,1)

  ProcRegua(Len(aDPrfPgt))
  For i := 1 to Len(aDPrfPgt)
    IncProc()
    oExcel:AddRow(cWrkSht,cTable,{aDPrfPgt[i,02],;
                                  aDPrfPgt[i,03],;
                                  aDPrfPgt[i,04],;
                                  aDPrfPgt[i,05],;
                                  aDPrfPgt[i,06],;
                                  aDPrfPgt[i,07],;
                                  aDPrfPgt[i,08],;
                                  aDPrfPgt[i,09],;
                                  aDPrfPgt[i,10],;
                                  aDPrfPgt[i,11],;
                                  aDPrfPgt[i,12],;
                                  aDPrfPgt[i,13],;
                                  aDPrfPgt[i,14],;
                                  aDPrfPgt[i,15],;
                                  aDPrfPgt[i,16],;
                                  aDPrfPgt[i,17],;
                                  aDPrfPgt[i,18],;
                                  aDPrfPgt[i,19],;
                                  aDPrfPgt[i,20],;
                                  aDPrfPgt[i,21],;
                                  aDPrfPgt[i,22],;
                                  aDPrfPgt[i,23]})
  Next i

    
  oExcel:AddRow(cWrkSht,cTable,{"","","","","","","","","","","","","","","","","","","","","",""})
  oExcel:Activate()
  oExcel:GetXMLFile(cArquivo)
  IF ( ApOleClient("MsExcel") )   // se nao existir o excel sai fora..
    oMsExcel := MsExcel():New()
    oMsExcel:WorkBooks:Open(cArquivo)
    oMsExcel:SetVisible( .T. )
    oMsExcel:Destroy()
  ELSE
    Alert("Nao Existe Excel Instalado ou não foi possível localizá-lo. Tente novamente!")
  ENDIF
Return nil
