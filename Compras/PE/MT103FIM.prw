#INCLUDE "PROTHEUS.CH"
#Include "RwMake.ch"
#Include "topconn.ch"
#INCLUDE "FILEIO.CH"
#INCLUDE "TBICONN.CH"

/*/{Protheus.doc} User Function MT103FIM
	Ponto entrada utilizado apos gravacao do documento de entrada
	@type  Function
	@author Cellvla
	@since 19/08/13
	@version version
	@history Chamado 044314 - Ricardo Lima    - 28/12/2018 - libera adiantamento de frete
	@history Chamado 044314 - Ricardo Lima    - 21/01/2019 - ajuste na variavel declarada
	@history Chamado TI     - FWNM            - 18/03/2019 - WF NF > PC
	@history Chamado TI     - FWNM            - 25/03/2019 - Retira os impostos da vl Total
	@history Chamado TI     - Adriana         - 24/05/2019 - Devido a substituicao email para shared relay, substituido MV_RELACNT p/ MV_RELFROM
	@history Ch.050616      - Abel Babini     - 20/08/2019 - MANIFESTAR NF INTEGRADA PELO SAG
	@history Ch.050616      - FERNANDO SIGOLI - 22/08/2019 - MANIFESTO CLASSIFICAÇÃO 
	@history Ch.051254      - FWNM            - 23/08/2019 - || OS 052617 || FISCAL || DEJAIME || 8921 || PED. COMPRA
	@history Ch.052277      - Everson         - 02/10/2019 - Tratamento para não bloquear títulos incluídos pela rotina ADFIS032P.
	@history Chamado TI     - Abel Babini     - 28/10/2019 - Alterada tratativa para manifestação automática do destinatária - 
	@history Ch. 049454     - Abel Babini     - 14/01/2020 - Gravar D1_VALFUN no campo F3_OBSERV - Valéria Fiscal
  @history Chamado 053259 - William Costa   - 23/01/2020 - Identificado que o boletim de entrada via email só é gerado, se os usuarios gerarem a impressão do boletim de Entrada, foi retirado a user function que envia email e enviado para o ponto de entrada da nota fiscal de entrada MT103FIM
  @history Chamado 053259 - William Costa   - 27/01/2020 - Identificado que as variaveis INCLUI e ALTERA não funcionam mais, foi alterado apra nOpcao == 3 or nOpcao == 4, assim carregou os if corretamente.
  @history Chamado 056192 - William Costa   - 28/02/2020 - Ajuste Error Log na Função de Responsavel.
  @history Chamado 052671 - Glauco/ Eleva   - 31/03/2020 - Grava dados para registro C197 do Sped Fiscal.
  @history Chamado 057811 - Abel Babini     - 04/05/2020 - || OS 059321 || FISCAL || DEJAIME || 8921 || Ajuste na Classificação contábil das NF´s de Devolução
  @history Chamado 052610 - Glauco/ Eleva   - 29/05/2020 - Grava dados para registro C113 do Sped Fiscal.
  @history Chamado 058740 - Adriana Oliveira- 04/06/2020 - Exclui gravacao C113 para especie de documento contido no MV_#C113ES (CTE/CTEOS).
  @history Chamado 058730 - Adriana Oliveira- 09/06/2020 - Grava dados para registro C113 do Sped Fiscal, quando NF incluída pela INTNFEB.
  @history Chamado 058730 - Adriana Oliveira- 23/06/2020 - Ajuste para gravar dados para registro C113 do Sped Fiscal, quando INTNFEB e opcoes 3 e 5.
  @history Chamado 052610 - Adriana Oliveira- 23/06/2020 - Ajuste na mensagem gravada para o C113.
	@history Chamado 058730 - Adriana Oliveira- 30/06/2020 - Complemento para INTNFEB.
  @history Chamado 058821 - Adriana Oliveira- 30/07/2020 - Grava dados para registro C197 do Sped Fiscal, por item, e fixa aliquota para Simples Nacional
  @history Chamado TI     - Abel Babini     - 30/07/2020 - O registro C110 apresentou chave duplicada por conta de registros duplicados na tabela CDT
  @history Ticket  1794   - Adriana Oliveira- 23/09/2020 - Correção aliquota quando produtor rural, e geração por item
  @history Ticket 11265   - Abel Babini     - 19/03/2021 - Ajuste na rotina que gera os registros C197 para gravar o campo D1_ITEM. A não gravação do campo causava a delação do registro no reprocessamento dos livros. Correção na formula da aliquota interestadual
  @history Ticket 15063   - Abel Babini     - 08/06/2021 - Criação de regra para garantir a baixa dos pedidos de Frete relacionados aos CTE´s de complemento de preço
  @history Chamado 15804  - Leonardo P. Mo  - 08/07/2021 - Grava informações adicionais do Pedido de Compra.
  @history Ticket 18347   - Abel Babini     - 16/08/2021 - Não era gravado o valor do ICMS 18% para notas de complemento
  @history Ticket 62250   - Everson         - 11/10/2021 - Tratamento para salvar a data no pedido de compra.
  @history Ticket 62250   - Everson         - 15/10/2021 - Tratamento para salvar a data no pedido de compra.
  @history Ticket 62276   - Fer Macieira    - 18/10/2021 - Endereçamento automático - Armazéns de terceiros 70 a 74 - Projeto Industrialização
  @history Ticket 62276   - Fer Macieira    - 01/12/2021 - Endereçamento automático - Armazéns de terceiros 70 a 74 - Projeto Industrialização - Alguns casos o EXECAUTO retorna ERRO
/*/

STATIC cResponsavel  := SPACE(60)

User Function MT103FIM()

  Local aAreaSE1 	   := SE1->(GetArea())
  Local aAreaSF1 	   := SF1->(GetArea())
  Local aAreaSD1     := SD1->( GetArea() )
  Local aAreaSC7     := SC7->( GetArea() )
  Local aEnvFT
  Local aEnvF3
  Local cLocPrd      := ""
  Local nOpcao       := PARAMIXB[1]   // Opção Escolhida pelo usuario no aRotina
  Local nConfirma    := PARAMIXB[2]
  Local lGrBlqIcm    := .T.
  Local lBlqICM      := SuperGetMv( "MV_#MT13F1" , .F. , .F. ,  )
  Local lBlqNvS      := SuperGetMv( "MV_#MT13F2" , .F. , .F. ,  )
  //Local nCdPed       := Ascan(aHeader, { |x| Alltrim(x[2]) == "D1_PEDIDO" } )
  //Local nAc          := 0
  Private cToBoletim := ''
  Private lEnviaMail := .F.
  
  If SF1->F1_TIPO == "D" .AND. !EMPTY(SF1->F1_DUPL) .AND. (nOpcao == 3 .or. nOpcao == 4) //Incluir e Classificar

    DbSelectArea("SE1")
    DbSetOrder(2)
    DbGotop()
    If DbSeek(xFilial("SE1")+SF1->(F1_FORNECE+F1_LOJA+F1_SERIE+F1_DOC))

      If SE1->E1_NUM == SF1->F1_DOC .AND. SE1->E1_CLIENTE == SF1->F1_FORNECE .AND. SE1->E1_LOJA == SF1->F1_LOJA

        Reclock("SE1", .F.)
        SE1->E1_TIPO := "NCC"
        SE1->(MsUnlock())
      EndIf

    Endif
  EndIf

  //chamado 036068 - Fernando 25/07/2017
  If Alltrim(cEmpAnt) == "01" .and. nConfirma == 1 //se confirmou a operação de entrada

    If Alltrim(cFilAnt) $ "03"

      CM130F1()  //Rotina de movimento interno na SD3 fazendo o lançamento ao contrário da remessa de ração

      //Inicio...Chamado: 036932 Fernando Sigoli 05/12/2017

      If SF1->F1_TIPO == "N"

        If nOpcao == 3 .or. nOpcao == 4 //3: Incluir/ 4: Classificar

          GeraComissaoArmazenagem()

        ElseIf nOpcao == 5 // 5= Estonar classificacao

          EstoComissaoArmazenagem()

        Endif

      EndIf

      //Inicio...Chamado: 036932 Fernando Sigoli 05/12/2017

    EndIf

    //Inicio Chamado: 036621 10/08/2017 - Fernando Sigoli
    If (Alltrim(FunName()) == "MATA103") .and. SF1->F1_TIPO == "D" .and. Alltrim(cFilAnt) $ "02"  .and. (nOpcao == 3 .or. nOpcao == 4) //Incluir e Classificar

      If	nOpcao == 3	//apenas inclusao ou retorno

        If ApMsgYesNo(OemToAnsi("Esta devolução ira gerar um refaturamento? "),OemToAnsi("A T E N ??O"))

          RecLock("SF1",.F.)
          SF1->F1_XREFATU := 'S'
          MsUnlock()

          //atualizar o local dos itens da devolução
          Dbselectarea("SD1")
          Dbsetorder(1)
          If SD1->(dbseek(xFilial("SD1") + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA,.t. ))

            While !Eof() .AND. xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA == SD1->D1_FILIAL+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA

              Reclock("SD1",.F.)
              SD1->D1_LOCAL 	:= GetMv("MV_#LCPCLI")
              MsUnlock("SD1")

              //tratamento para criar armazem no SB2 - destino
              SB2->(DbSetOrder(1))
              If !SB2->(DbSeek( xFilial("SB2") + SD1->(D1_COD) + SD1->(D1_LOCAL) ))
                CriaSB2(SD1->(D1_COD),SD1->(D1_LOCAL))
              EndIf

              //gera log de reprogramacao
              u_GrLogZBE (Date(),TIME(),cUserName," DOCUMENTO ENTRADA ","FATURAMENTO","MT103FIM",;
                "DOCUMENTO ENTRADA/DEVOLUCAO "+SF1->F1_DOC+" SERIE "+SF1->F1_SERIE+" PROD:"+Alltrim(SD1->D1_COD)+" LOCAL "+SD1->D1_LOCAL,ComputerName(),LogUserName())


              DbSelectArea("SD1")
              SD1->(dbSkip())
            EndDo
          Endif

        Else

          If SF1->F1_XREFATU == 'S'
            RecLock("SF1",.F.)
            SF1->F1_XREFATU := 'N'
            MsUnlock()
          EndIf

          //atualizar o local dos itens da devolução
          Dbselectarea("SD1")
          Dbsetorder(1)
          If SD1->(dbseek(xFilial("SD1") + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA,.t. ))
            While !Eof() .AND. xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA == SD1->D1_FILIAL+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA

              If SD1->D1_LOCAL $ GetMv("MV_#LCPCLI")

                If !RetArqProd(SD1->D1_COD)

                  cLocPrd := POSICIONE("SBZ",1,xFilial("SBZ")+SD1->D1_COD,"BZ_LOCPAD")

                Else
                  cLocPrd := POSICIONE("SB1",1,xFilial("SB1")+SD1->D1_COD,"B1_LOCPAD")

                EndIF

                //tratamento para criar armazem no SB2 - destino
                SB2->(DbSetOrder(1))
                If !SB2->(DbSeek( xFilial("SB2") + SD1->(D1_COD) + cLocPrd ))
                  CriaSB2(SD1->(D1_COD),cLocPrd)
                EndIf

                Reclock("SD1",.F.)
                SD1->D1_LOCAL 	:= cLocPrd
                MsUnlock("SD1")

                //gera log de reprogramacao
                u_GrLogZBE (Date(),TIME(),cUserName," DOCUMENTO ENTRADA ","FATURAMENTO","MT103FIM",;
                  "DOCUMENTO ENTRADA/DEVOLUCAO "+SF1->F1_DOC+" SERIE "+SF1->F1_SERIE+" PROD: "+Alltrim(SD1->D1_COD)+" LOCAL "+SD1->D1_LOCAL,ComputerName(),LogUserName())

              EndIf

              DbSelectArea("SD1")
              SD1->(dbSkip())
            EndDo

          Endif

        Endif //fechamento do else

      EndIf

      If !Empty(SF1->F1_X_SQED)
        BeginTran() //Executa a Stored Procedure
        TcSQLExec('EXEC [LNKMIMS].[SMART].[dbo].[FU_PEDIDEVOVEND_FATURA] ' +Str(SF1->(Recno()))+","+"'"+cEmpAnt+"'" )
	      EndTran()
	    EndIf
	  EndIf
	  //Fim Chamado: 036621 10/08/2017 - Fernando Sigoli

	  //Inicio Chamado: 043873 24/09/2018 - Adriana Oliveira
	  //Somente devolução com formulario proprio
	  If (Alltrim(FunName()) == "MATA103") .and. SF1->F1_TIPO == "D" .and. SF1->F1_FORMUL == "S" .and. (nOpcao == 3 .or. nOpcao == 4) //Incluir e Classificar
	
	    RecLock("SF1",.F.)
	    SF1->F1_TPFRETE := BuscaFret(SF1->F1_FILIAL,SF1->F1_SERIE,SF1->F1_DOC,SF1->F1_FORNECE,SF1->F1_LOJA,SF1->F1_TIPO)
	    MsUnlock()
	
	  Endif
	  //Fim Chamado: 043873 24/09/2018 - Adriana Oliveira
	
	  // Inicio Chamado: 036733 16/08/2017 - William Costa
	  IF !EMPTY(cResponsavel) .AND. (nOpcao == 3 .or. nOpcao == 4) //Incluir e Classificar
	
	    RecLock("SF1",.F.)
	    SF1->F1_XRESPON := cResponsavel
	    MsUnlock()
	
	  ENDIF
	  // Final Chamado: 036733 16/08/2017 - William Costa
	
	EndIf

	//chamado 037659 - Adriana 09/11/17
	ContaNfe(nOpcao)
	
	//chamado 044792 - William 05/11/2018
	ContaAtivo(nOpcao)
	
	// Chamado: 036729 - Estoque em trânsito - sempre 1 item
	// - FWNM - 04/06/2018
	If nOpcao == 5 // Excluir / Estornar Classificação
	
	  cFilEntr  := GetMV("MV_#TRAFIE",,"03")
	
	  If SF1->F1_FILIAL == cFilEntr
	
	    // - Gerar estorno no almoxarifado 95 (Estoque em Trânsito)
	    cForTran  := GetMV("MV_#TRAFOR",,"022503")
	    cLojFTran := GetMV("MV_#TRALOJ",,"21")
	    cProdTra  := GetMV("MV_#TRAPRD",,"383369")
	    cTESEntra := GetMV("MV_#TRATES",,"02T")
	
	    // Posiciono no item (sempre 1)
	    If AllTrim(SF1->F1_FORNECE) == AllTrim(cForTran) .and. AllTrim(SF1->F1_LOJA) == AllTrim(cLojFTran) .and. AllTrim(SD1->D1_COD) == AllTrim(cProdTra) .and. AllTrim(SD1->D1_TES) == AllTrim(cTESEntra)
	      msAguarde( { || GeraEstTran() }, "(MT103FIM) Gerando estorno na filial de origem do estoque em trânsito" )
	    EndIf
	
	  EndIf
	
	EndIf
	
	//Ricardo Lima
	//03/08/18
	if cEmpAnt = '01' .or. cEmpAnt = '02' .and. lBlqICM
	  If nConfirma == 1 .AND. nOpcao == 3
	    lGrBlqIcm := U_ADCOM023P( FWxFilial("SF1"), SF1->F1_DOC, SF1->F1_SERIE, SF1->F1_FORNECE, SF1->F1_LOJA, SF1->F1_TIPO )
	  endif
	endif
	if lBlqNvS .and. lGrBlqIcm .And. !IsInCallStack("U_ADFIS032P") //Everson - 02/10/2019. Chamado
	  if cEmpAnt = '01' .or. cEmpAnt = '02'
	    If nConfirma == 1 .AND. nOpcao == 3
	      u_ADCOM011P( SF1->F1_VALBRUT , FWxFilial("SF1") , SF1->F1_DOC , SF1->F1_SERIE , SF1->F1_FORNECE , SF1->F1_LOJA , SF1->F1_TIPO , SF1->F1_ESPECIE )
	    endif
	  endif
	Endif

	// Chamado n. TI     - FWNM - 18/03/2019
	// WF NF > PC (Quantidade e/ou Valor)
	If nConfirma == 1 .and. (nOpcao == 3 .or. nOpcao == 4) //3: Incluir/ 4: Classificar
				WFNFPC()
	EndIf
	// 
	
	//IF nOpcao == 4 //Classificar   - CHAMADO 050616 - MANIFESTAR SOMENTE NA CLASSIFICAÇÃO - FERNANDO SIGOLI - 22/08/2019 
	IF (nOpcao == 3 .or. nOpcao == 4) //3: Incluir/ 4: Classificar - Chamado   - TI     - Abel Babini - Alterada tratativa para manifestação automática do destinatária - 28/10/2019
				//INICIO CHAMADO 050616 - MANIFESTAR NF INTEGRADA PELO SAG - ABEL BABINI - 20/08/2019 
	  IF !EMPTY(ALLTRIM(SF1->F1_CHVNFE)) .AND. ;
					ALLTRIM(SF1->F1_ESPECIE) = 'SPED' .AND. ;
					IIF(ALLTRIM(SF1->F1_TIPO) $ "D/B" , Substr(Alltrim(POSICIONE("SA1",1,xFilial("SA1")+SF1->F1_FORNECE+SF1->F1_LOJA,"A1_CGC")),1,8) , Substr(Alltrim(POSICIONE("SA2",1,xFilial("SA2")+SF1->F1_FORNECE+SF1->F1_LOJA,"A2_CGC")),1,8)) $ GETMV("MV_#CNPJRE",,"")
				
					U_CEXMANAUT(SF1->(RECNO()))
	    ENDIF
	EndIF	
	
  // Inicio chamado 052671 - Glauco Oliveira - Eleva - 31/03/2020
	If (nOpcao == 3 .or. nOpcao == 4) .And. nConfirma == 1 //3: Incluir/ 4: Classificar
		fAjustaCDA()
	EndIf
  // Fim chamado 052671 - Glauco Oliveira - Eleva - 31/03/2020

  // Inicio chamado 052610 - Glauco Oliveira - Eleva - 29/05/2020
  IF SF1->F1_DTDIGIT >= CTOD("01/06/2020")
    If fAbTelaCpl(nOpcao, nConfirma)
		  fAjustaCDD()
	  EndIf     
  ENDIF
	// Fim chamado 052610 - Glauco Oliveira - Eleva - 29/05/2020

	//FIM CHAMADO 050616 - MANIFESTAR NF INTEGRADA PELO SAG - ABEL BABINI - 20/08/2019	

  //INICIO Ch. 049454 - Abel Babini - Fiscal - Gravar D1_VALFUN no campo F3_OBSERV - Valéria
  IF nOpcao == 3 .OR. nOpcao == 4 //3: Incluir/ 4: Classificar
    aEnvFT  := SFT->(GetArea())
    aEnvF3  := SF3->(GetArea())

    nVlFnrl	:= _VlFnrl(SF1->F1_SERIE, SF1->F1_DOC, SF1->F1_FORNECE, SF1->F1_LOJA)
    If nVlFnrl > 0
      dbSelectArea("SF3")
      SF3->(Dbsetorder(4))
      SF3->(dbseek(xfilial("SF3") + SF1->F1_FORNECE + SF1->F1_LOJA + SF1->F1_DOC + SF1->F1_SERIE,.t. ))
      WHILE SF3->(!Eof())	.AND. SF3->F3_NFISCAL == SF1->F1_DOC .AND. SF3->F3_SERIE == SF1->F1_SERIE .AND. ;
                    SF3->F3_CLIEFOR == SF1->F1_FORNECE .AND. SF3->F3_LOJA == SF1->F1_LOJA
        
        IF !("CONT.SEG.SOCIAL" $ SF3->F3_OBSERV)
          //Ajusta livro Fiscal
          Reclock("SF3",.F.)
            SF3->F3_OBSERV	:= Alltrim(SF3->F3_OBSERV) + "CONT.SEG.SOCIAL: "+ALLTRIM(TRANSFORM(nVlFnrl, "@E 999,999.99"))
          MsUnlock("SF3")
        ENDIF

        SF3->(dbskip())
      ENDDO

      dbselectarea("SFT")
      dbsetorder(1)

      dbselectarea("SD1")
      dbsetorder(1)
      SD1->(dbseek(xfilial("SD1") + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA,.T. ))

      While SD1->(!Eof())	.AND. SD1->D1_DOC == SF1->F1_DOC .AND. SD1->D1_SERIE == SF1->F1_SERIE .AND. ;
                    SD1->D1_FORNECE == SF1->F1_FORNECE .AND. SD1->D1_LOJA == SF1->F1_LOJA
                    
        IF SD1->D1_VALFUN > 0
        //Ajusta Livro Fiscal por Item SFT
          IF SFT->(dbseek(xfilial("SFT") + "E" + SD1->D1_SERIE + SD1->D1_DOC + SD1->D1_FORNECE + SD1->D1_LOJA + SD1->D1_ITEM + SD1->D1_COD,.t. ))
            If !("CONT.SEG.SOCIAL" $ SFT->FT_OBSERV)
              Reclock("SFT",.F.)
                SFT->FT_OBSERV	:= Alltrim(SFT->FT_OBSERV) + "CONT.SEG.SOCIAL: "+ALLTRIM(TRANSFORM(nVlFnrl, "@E 999,999.99"))
              MsUnlock("SFT")
            Endif
          ENDIF
        ENDIF

        SD1->(dbskip())
      EndDo
    Endif

    // *** INICIO CHAMADO 053259 - WILLIAM COSTA - 23/01/2020
    IF nOpcao == 3 .OR. nOpcao == 4 .AND. nConfirma == 1

      dbselectarea("SD1")
      dbsetorder(1)
      SD1->(dbseek(xfilial("SD1") + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA,.T. ))

      While SD1->(!Eof())	.AND. SD1->D1_DOC == SF1->F1_DOC .AND. SD1->D1_SERIE == SF1->F1_SERIE .AND. ;
            SD1->D1_FORNECE == SF1->F1_FORNECE .AND. SD1->D1_LOJA == SF1->F1_LOJA

        // //Everson - 11/10/2021. Chamado 62250.
        // If !Empty(SD1->D1_PEDIDO) .And. !Empty(SD1->D1_ITEMPC)
        
        //   Dbselectarea("SC7")
        //   SC7->(Dbsetorder(1))

        //   If SC7->(DbSeek(SD1->D1_FILIAL+SD1->D1_PEDIDO+SD1->D1_ITEMPC))
            
        //     Reclock("SC7",.F.)
        //       SC7->C7_XDTENTR := SF1->F1_DTDIGIT
        //     MsUnlock("SC7")

        //   EndIf

        // EndIf
        // //

        IF ALLTRIM(SD1->D1_CC) $ "8001" //estoque

          cToBoletim := AllTrim( SuperGetMv("MV_#USUBEA", .F., 0 )) 
          lEnviaMail := .T.
          EXIT

        ELSEIF ALLTRIM(SD1->D1_CC) $ "2104" //restaurante

          cToBoletim := AllTrim( SuperGetMv("MV_#USUBER", .F., 0 )) 
          lEnviaMail := .T.
          EXIT
        ENDIF

        //INICIO Ticket 15063   - Abel Babini     - 08/06/2021 - Criação de regra para garantir a baixa dos pedidos de Frete relacionados aos CTE´s de complemento de preço
        IF Alltrim(SF1->F1_TIPO) == 'C' .AND. Alltrim(SF1->F1_ESPECIE) == 'CTE' .AND. !Empty(Alltrim(SD1->D1_PEDIDO)) .AND. !Empty(Alltrim(SD1->D1_ITEMPC)) 
          dbselectarea("SC7")
          dbsetorder(1)
          IF SC7->(dbSeek(SD1->D1_FILIAL+SD1->D1_PEDIDO+SD1->D1_ITEMPC))
            IF SC7->C7_QUANT == 1 .AND. SC7->C7_QUJE == 0

              Reclock("SC7",.F.)
                SC7->C7_QUJE 	  := 1
                SC7->C7_XDTENTR := SF1->F1_DTDIGIT
              MsUnlock("SC7")
            ENDIF

          ENDIF
        //FIM Ticket 15063   - Abel Babini     - 08/06/2021 - Criação de regra para garantir a baixa dos pedidos de Frete relacionados aos CTE´s de complemento de preço
        //Início @history Chamado 15804  - Leonardo P. Monteiro  - 08/07/2021 - Grava informações adicionais do Pedido de Compra.
        
        ENDIF
        //Final @history Chamado 15804  - Leonardo P. Monteiro  - 08/07/2021 - Grava informações adicionais do Pedido de Compra.

        SD1->(dbskip())
      EndDo              

    ENDIF
    // *** FINAL CHAMADO 053259 - WILLIAM COSTA - 23/01/2020

    IF lEnviaMail == .T.

      SendMlBE(SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA)

    ENDIF

    RestArea(aEnvFT)
    RestArea(aEnvF3)
  EndIf
  //FIM Ch. 049454 - Abel Babini - Fiscal - Gravar D1_VALFUN no campo F3_OBSERV - Valéria

  //Everson - 15/10/2021. Chamado 62250.
  //Leonardo P. Monteiro - 16/11/2021. Chamado 62250.
  If nConfirma == 1 .and. (nOpcao == 3 .or. nOpcao == 4)
        atlSC7Dt(SF1->F1_FORNECE, SF1->F1_LOJA, SF1->F1_DOC, SF1->F1_SERIE)
  else
      //GrLogZBE(dDate,cTime,cUser,cLog,cModulo,cRotina,cParamer,cEquipam,cUserRed)
      u_GrLogZBE (Date(),; 
                  Time(),; 
                  cUserName,; 
                  "Não passou na gravação do pc " + SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_DOC+SF1->F1_SERIE + "-nConfirma: "+ CValToChar(nConfirma)+"-nOpcao: "+ CValToChar(nOpcao),;
                  " DOCUMENTO ENTRADA ",;
                  "FISCAL",;
                  "MT103FIM",;
                  ComputerName(),;
                  LogUserName())
  EndIf

	// @history Ticket 62276   - Fer Macieira    - 18/10/2021 - Endereçamento automático - Armazéns de terceiros 70 a 74 - Projeto Industrialização
  If nConfirma == 1 .and. (nOpcao == 3 .or. nOpcao == 4) .and. AllTrim(SF1->F1_TIPO) == "N"
    UpSDASDB()
  EndIf
  // 
  u_ChkSDA() // @history Ticket 62276   - Fer Macieira    - 01/12/2021 - Endereçamento automático - Armazéns de terceiros 70 a 74 - Projeto Industrialização - Alguns casos o EXECAUTO retorna ERRO
    
  RestArea(aAreaSE1)
	RestArea(aAreaSF1)
	
	// Chamado n. 051254 || OS 052617 || FISCAL || DEJAIME || 8921 || PED. COMPRA - FWNM - 23/08/2019
	RestArea(aAreaSD1)  
	RestArea(aAreaSC7) 
	//

Return

/*/{Protheus.doc} User Function _VlFnrl
	Verifica se os itens possuem valor de Funrural.
	@type  Static Function
	@author Abel Babini
	@since 14/01/20
	@history Ch. 049454 - Abel Babini - Fiscal - Gravar D1_VALFUN no campo F3_OBSERV - Valéria
	/*/
  
Static Function _VlFnrl(cSerNF, cNumNF, cFornece, cLoja)
	Local nVlFnrl	:= 0
	Local cAlFnrl

	If Select(cAlFnrl) > 0
		(cAlFnrl)->(dbCloseArea())
	Endif
	cAlFnrl:=GetNextAlias()

	BeginSQL Alias cAlFnrl
		SELECT
			SUM(D1_VALFUN) AS D1_VALFUN
		FROM %TABLE:SD1% SD1
		WHERE SD1.D1_FILIAL = %xFilial:SD1%
		AND SD1.D1_DOC = %Exp:cNumNF%
		AND SD1.D1_SERIE = %Exp:cSerNF%
		AND SD1.D1_FORNECE = %Exp:cFornece%
		AND SD1.D1_LOJA = %Exp:cLoja%
		AND SD1.%notDel%
	EndSQL

	DbSelectArea(cAlFnrl)
	(cAlFnrl)->(dbGoTop())

	nVlFnrl := (cAlFnrl)->D1_VALFUN
	
	(cAlFnrl)->(dbCloseArea())
Return nVlFnrl
//Fim Ch. 049454 - Abel Babini - Fiscal - Gravar D1_VALFUN no campo F3_OBSERV - Valéria

/*/{Protheus.doc} Static Function CM130F1
	Rotina de movimento interno na SD3 fazendo o lançamento ao contrário da remessa de ração para criação para os casos que h?uma NF de entrada para "anular" a saída: ³ Adoro - chamado 036068
	@type  Static Function
	@author Fernando
	@since 25/07/2017
	@version 01
	/*/

Static Function CM130F1()

	Local aArea		:= GetArea()
	Local aAreaSA2  := SA2->(GetARea())
	Local aAreaSA1  := SA1->(GetARea())
	Local cTesRem	:= GetMv("MV_#TESENT")
	//Local cAlDes	:= cAlOri := ""
	Local lContinua :=.F.
	Local cNumseq   := ""
	Local cDoc		:= GetSXENum("SD3","D3_DOC")
	Local aItens	:= {}
	Local cLocPad   := ""
	Local cLocSb1   := ""
	Local cLocSbz   := ""
	Local cLocDest  := ""
	
	Private lMsErroAuto := .F.  
		
  If SF1->F1_TIPO == "N"   //Entrada normal Castro de Fornecedor
		SA2->(dbSetOrder(1))
		SA2->(dbSeek(xFilial("SA1")+SF1->F1_FORNECE+SF1->F1_LOJA))
    If SA2->(!EOF())
      If !Empty(SA2->A2_LOCAL)
				cAlDes := SA2->A2_LOCAL
				lContinua:=.T.
      EndIf
    EndIf
  ElseIf SF1->F1_TIPO == "B"  //devolução  - Cadastro de cliente
		SA1->(dbSetOrder(1))
		SA1->(dbSeek(xFilial("SA1")+SF1->F1_FORNECE+SF1->F1_LOJA))
    If SA1->(!EOF())
      If !Empty(SA1->A1_LOCAL)
				cAlDes := SA1->A1_LOCAL
				lContinua:=.T.
      EndIf
    EndIf
  EndIf
	
  If lContinua
		
		SD1->(dbSetOrder(1))
		SD1->(dbSeek(xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA))
    While SD1->(!EOF()) .and. xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA == SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA)
			
      If !Empty(SD1->D1_NFORI) .and. Alltrim(SD1->D1_TES) $ cTesRem
					
        Begin Transaction
				
					cDoc:= GetSXENum("SD3","D3_DOC")
					
					cNumseq := ProxNum()
					
					aadd (aItens,{cDoc	 ,ddatabase})
					aadd (aItens,{})
					
					SB1->(DbSetOrder(1))
					SB1->(DbSeek( xFilial("SB1") + SD1->(D1_COD) ))
					
					cLocSb1 := SB1->B1_LOCPAD
				
					SBZ->(DbSetOrder(1))
				    SBZ->(DbSeek( xFilial("SBZ") + SD1->(D1_COD) ))
						
					cLocSbz := SBZ->BZ_LOCPAD
						
          If Empty(cLocSbz)
						cLocPad := cLocSb1
          Else
						cLocPad := cLocSbz
          EndIf
					
					cLocDest :=IIF(Empty(SD1->D1_LOCAL),cLocPad,SD1->D1_LOCAL)
					
					//tratamento para criar armazem no SB2 - destino
					SB2->(DbSetOrder(1))
          If !SB2->(DbSeek( xFilial("SB2") + SD1->(D1_COD) + cLocDest ))
						CriaSB2(SD1->(D1_COD),cLocDest)
          EndIf
					
					aItens[2] :=  {{"D3_COD" 		, SB1->B1_COD			,NIL}}// 01.Produto Origem
					aAdd(aItens[2],{"D3_DESCRI" 	, SB1->B1_DESC			,NIL})// 02.Descricao
					aAdd(aItens[2],{"D3_UM"     	, SB1->B1_UM			,NIL})// 03.Unidade de Medida
					aAdd(aItens[2],{"D3_LOCAL"  	, cAlDes			    ,NIL})// 04.Local Origem
					aAdd(aItens[2],{"D3_LOCALIZ"	, CriaVar("D3_LOCALIZ")	,NIL})// 05.Endereco Origem
					aAdd(aItens[2],{"D3_COD"    	, SB1->B1_COD			,NIL})// 06.Produto Destino
					aAdd(aItens[2],{"D3_DESCRI" 	, SB1->B1_DESC			,NIL})// 07.Descricao
					aAdd(aItens[2],{"D3_UM"     	, SB1->B1_UM			,NIL})// 08.Unidade de Medida 
					
					aAdd(aItens[2],{"D3_LOCAL"  	, cLocDest			    ,NIL})// 09.Armazem Destino
					aAdd(aItens[2],{"D3_LOCALIZ"	, CriaVar("D3_LOCALIZ")	,NIL})// 10.Endereco Destino
					aAdd(aItens[2],{"D3_NUMSERI"	, CriaVar("D3_NUMSERI")	,NIL})// 11.Numero de Serie
					aAdd(aItens[2],{"D3_LOTECTL"	, CriaVar("D3_LOTECTL")	,NIL})// 12.Lote Origem
					aAdd(aItens[2],{"D3_NUMLOTE"	, CriaVar("D3_NUMLOTE")	,NIL})// 13.Sub-Lote
					aAdd(aItens[2],{"D3_DTVALID"	, CriaVar("D3_DTVALID")	,NIL})// 14.Data de Validade
					aAdd(aItens[2],{"D3_POTENCI"	, CriaVar("D3_POTENCI")	,NIL})// 15.Potencia do Lote
					aAdd(aItens[2],{"D3_QUANT"  	, SD1->(D1_QUANT)		,NIL})// 16.Quantidade
					aAdd(aItens[2],{"D3_QTSEGUM"	, CriaVar("D3_QTSEGUM")	,NIL})// 17.Quantidade na 2 UM
					aAdd(aItens[2],{"D3_ESTORNO"	, CriaVar("D3_ESTORNO")	,NIL})// 18.Estorno
					aAdd(aItens[2],{"D3_NUMSEQ" 	, cNumseq				,NIL})// 19.NumSeq
					aAdd(aItens[2],{"D3_LOTECTL"	, CriaVar("D3_LOTECTL")	,NIL})// 20.Lote Destino
					aAdd(aItens[2],{"D3_DTVALID"	, CriaVar("D3_DTVALID")	,NIL})// 21.Data de Validade Destino
					
					lMsErroAuto := .F.
					
					MsExecAuto({|x| MATA261(x)},aItens)
					
          If lMsErroAuto
						DisarmTransaction()
					    MostraErro()
          EndIf
				
        End Transaction
			
      EndIf
			SD1->(DbSkip())
		
    EndDo
		
  Endif
	
	SA2->(RestArea(aAreaSA2))
	SA1->(RestArea(aAreaSA1))
	
	RestArea(aArea)

Return(.T.)    

/*/{Protheus.doc} Static Function RespDocEntrada
	Janela para digitacao Responsavel Adoro - chamado 036682   
	@type  Static Function
	@author William Costa
	@since 26/08/2017
	@version 01
	/*/

User Function RespDocEntrada()

  Local aAreaAnt 	 := GetArea()
  Local nOpcaoTela := 0
  Private oDlg

  IF !EMPTY(CNFISCAL) .AND. ;
     !EMPTY(CSERIE)   .AND. ;
     !EMPTY(CA100FOR) .AND. ;
     !EMPTY(CLOJA)

    SqlNfEntrada(xFilial("SF1"),CNFISCAL,CSERIE,CA100FOR,CLOJA)
    While TRB->(!EOF())

      cResponsavel := IIF(!EMPTY(TRB->F1_XRESPON),TRB->F1_XRESPON,cResponsavel)

      TRB->(dbSkip())

    ENDDO
    TRB->(dbCloseArea())

  ENDIF

    @0,0 TO 110,300 DIALOG oDlg TITLE "Responsável"
    @10,20 SAY "Digite o Responsável pela Nota: "
    @20,20 MSGET cResponsavel picture "@!" SIZE 120,10 PIXEL OF oDlg

    @ 40,050 BUTTON "&Gravar" SIZE 33,14 PIXEL ACTION (nOpcaoTela := 1,oDlg:End())
    @ 40,108 BUTTON "&Sair" SIZE 33,14 PIXEL ACTION oDlg:End()

    ACTIVATE DIALOG oDlg CENTER

  RestArea(aAreaAnt)

Return

/*/{Protheus.doc} Static Function SqlNfEntrada
	@type  Static Function
	@author 
	@since 
	@version 01
	/*/

STATIC FUNCTION SqlNfEntrada(cFil,cDoc,cSerie,cFornece,cLoja)

  BeginSQL Alias "TRB"
    %NoPARSER%
    SELECT F1_XRESPON
    FROM %Table:SF1% WITH(NOLOCK)
    WHERE F1_FILIAL               = %EXP:cFil%
      AND F1_DOC                  = %EXP:cDoc%
      AND F1_SERIE                = %EXP:cSerie%
      AND F1_FORNECE              = %EXP:cFornece%
      AND F1_LOJA                 = %EXP:cLoja%
      AND %Table:SF1%.D_E_L_E_T_ <> '*'

    EndSQl

RETURN(NIL)

/*/{Protheus.doc} Static Function ContaNfe
	Atualizar a conta contabil para notas de devolucao - Adoro - chamado 037659
	@type  Static Function
	@author Adriana Oliveira
	@since 29/11/2017
	@version 01
	/*/

Static Function ContaNfe(nopcao)

  //chamado 037659 - Adriana 09/11/17
  Local _cConta 		:= ''
  Local _aAreaAnt		:= GetArea()

  //@history Chamado 057811 - Abel Babini     - 04/05/2020 - || OS 059321 || FISCAL || DEJAIME || 8921 || Ajuste na Classificação contábil das NF´s de Devolução
  If  (Alltrim(FunName()) == "MATA103" .OR. IsInCallStack( "U_CENTNFEXM" )) .and. SF1->F1_TIPO == "D" .and. (nOpcao == 3 .or. nOpcao == 4) //Incluir e Classificar

    //atualizar a conta contabil para notas de devolucao
    Dbselectarea("SD1")
    Dbsetorder(1)
    If SD1->(dbseek(xFilial("SD1") + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA,.t. ))

      While !Eof() .and. xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA == SD1->D1_FILIAL+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA

        //@history Chamado 057811 - Abel Babini     - 04/05/2020 - || OS 059321 || FISCAL || DEJAIME || 8921 || Ajuste na Classificação contábil das NF´s de Devolução
        _cConta := Alltrim(Posicione("SF4",1,xFilial("SF4")+SD1->D1_TES,"F4_XCONTA"))

        Reclock("SD1",.F.)
        SD1->D1_CONTA 	:= iif(!Empty(_cConta),_cConta, SD1->D1_CONTA)
        MsUnlock("SD1")

        DbSelectArea("SFT")
        DbSetOrder(1)
        //FT_FILIAL+FT_TIPOMOV+FT_SERIE+FT_NFISCAL+FT_CLIEFOR+FT_LOJA+FT_ITEM+FT_PRODUTO
        if dbseek(SD1->D1_FILIAL+"E"+SD1->D1_SERIE+SD1->D1_DOC+SD1->D1_FORNECE+SD1->D1_LOJA+SD1->D1_ITEM+SD1->D1_COD)
          Reclock("SFT",.F.)
          SFT->FT_CONTA 	:= iif(!Empty(_cConta),_cConta, SFT->FT_CONTA)
          MsUnlock("SFT")
        endif

        DbSelectArea("SD1")
        SD1->(dbSkip())

      EndDo

    Endif

  Endif
  //Fim Chamado: 037659 - Adriana 09/11/17

  RestArea(_aAreaAnt)

Return Nil

/*/{Protheus.doc} Static Function GeraComissaoArmazenagem
	Rotina de custeio de Armazenagem e comissao de materia prima - Gera Movimentação - Chamado: 036932
	@type  Static Function
	@author Fernando Sigoli
	@since 05/12/2017
	@version 01
	/*/      

Static Function GeraComissaoArmazenagem()

  Local aArea	    := GetArea()
  Local aAreaSF1	:= SF1->(GetArea())
  Local aAreaSD1	:= SD1->(GetArea())
  Local aItens    := {}
  Local nVlrItem  := 0
  Local cKeySd1   := 0
  Local cTMPadrao := GetMv('MV_#TMPADR') 			//tipo movimentacao
  Local cPrdTroca := GetMv('MV_#PRDTRO')+SPACE(9) //produto de troca/destino
  Local nRecSD1   := 0

  Private lMsErroAuto := .F.

  //informaçoe nota atual que esta sendo incluido no documento de entrada
  Dbselectarea("SD1")
  Dbsetorder(1)
  DBGoTop()
  If SD1->(dbseek(xFilial("SD1") + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA,.T. ))
    While SD1->(!EOF()) .and. xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA == SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA)

      aItens   := {}
      nVlrItem := 0
      nRecSD1  := SD1->(Recno())

      If  Alltrim(SD1->(D1_COD)) $ GetMv("MV_#ARMAZE") //produtos que estao nesse parametro, na movimentacao
        //subtituido pelo produto que esta no paramtro MV_#PRDTRO(CODIGO DO PRODUTO DE TROCA)
        Begin Transaction                            //nesse caso esta trocando pela produto milho

          cDoc	 := GetSXENum("SD3","D3_DOC")

          nVlrItem := SD1->D1_TOTAL
          cKeySd1  := SD1->(D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA)

          SB1->(DbSetOrder(1))
          SB1->(DbSeek( xFilial("SB1") + cPrdTroca ))

          cLocSb1 := SB1->B1_LOCPAD

          SBZ->(DbSetOrder(1))
          SBZ->(DbSeek( xFilial("SBZ") + cPrdTroca ))

          cLocSbz := SBZ->BZ_LOCPAD

          If Empty(cLocSbz)
            cLocPad := cLocSb1
          Else
            cLocPad := cLocSbz
          EndIf

          SB1->(DbSetOrder(1))
          SB1->(DbSeek( xFilial("SB1") + cPrdTroca ))

          //tratamento para criar armazem no SB2 - destino
          SB2->(DbSetOrder(1))
          If !SB2->(DbSeek( xFilial("SB2") + cPrdTroca + cLocPad ))
            CriaSB2( cPrdTroca , cLocPad  )
          EndIf

          AADD(aItens, {"D3_DOC"		,cDoc            , Nil})
          AADD(aItens, {"D3_TM"		,cTMPadrao   	 , Nil})
          AADD(aItens, {"D3_COD"		,SB1->B1_COD     , Nil})
          AADD(aItens, {"D3_UM"       ,SB1->B1_UM      , Nil})
          AADD(aItens, {"D3_QUANT"	,0				 , Nil})
          AADD(aItens, {"D3_CUSTO1"	,nVlrItem        , Nil})
          AADD(aItens, {"D3_LOCAL"	,cLocPad         , Nil})
          AADD(aItens, {"D3_EMISSAO"	,dDatabase	     , Nil})
          AADD(aItens, {"D3_XSD1KEY"	,cKeySd1	   	 , Nil})
          AADD(aItens, {"D3_XRECSD1"	,nRecSD1	   	 , Nil})

          lMsErroAuto := .F.

          MSExecAuto({|x,y| MATA240(x,y)}, aItens, 3) //opcao 3: incluir 5: estornar

          If lMsErroAuto
            DisarmTransaction()
            MostraErro()
          EndIf

        End Transaction

      EndIf

      nRecSD1 := 0

      SD1->(dbSkip())
    EndDo

  EndIf

  RestArea(aArea)
  RestArea(aAreaSF1)
  RestArea(aAreaSD1)

Return .T.

/*/{Protheus.doc} Static Function EstoComissaoArmazenagem
	Realiza o estorno da movimentacao da SD3, relacionado a armazenagem e comissao de milho
	Especifico para a filial 03 e somente o produto milho que tem essa caracteristica - Chamado: 036932
	@type  Static Function
	@author Fernando Sigoli
	@since 05/12/2017
	@version 01
	/*/ 

Static Function EstoComissaoArmazenagem()

  Local aArea	    := GetArea()
  Local aAreaSF1	:= SF1->(GetArea())
  Local aAreaSD3	:= SD3->(GetArea())
  Local aCampos   := {}
  Local cKeySd1   := ''

  Private lMsErroAuto := .F.

  cKeySd1 := SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA

  DbSelectArea("SD3")
  SD3->(DbOrderNickName("XSD1KEY"))
  SD3->(DbGoTop())
  SD3->(DbSeek( xFilial("SD3") + cKeySd1 ))
  While SD3->(!EOF()) .and. SD3->(D3_XSD1KEY) == cKeySd1

    If Empty(SD3->(D3_ESTORNO))

      aCampos	:= {}

      AADD(aCampos, {"D3_FILIAL"	,SD3->D3_FILIAL		, Nil})
      AADD(aCampos, {"D3_TM"		,SD3->D3_TM			, Nil})
      AADD(aCampos, {"D3_COD"		,SD3->D3_COD		, Nil})
      AADD(aCampos, {"D3_QUANT"	,SD3->D3_QUANT		, Nil})
      AADD(aCampos, {"D3_LOCAL"	,SD3->D3_LOCAL		, Nil})
      AADD(aCampos, {"D3_EMISSAO"	,SD3->D3_EMISSAO	, Nil})
      AADD(aCampos, {"D3_DOC"		,SD3->D3_DOC		, Nil})
      AADD(aCampos, {"D3_NUMSEQ"	,SD3->D3_NUMSEQ		, Nil})
      AADD(aCampos, {"INDEX"     , 4       			, Nil})

      lMsErroAuto := .F.

      MSExecAuto({|x,y| MATA240(x,y)}, aCampos, 5)

      If lMsErroAuto
        DisarmTransaction()
        MOSTRAERRO()
      EndIf

    EndIf

    SD3->(Dbskip())
  EndDo

  RestArea(aArea)
  RestArea(aAreaSF1)
  RestArea(aAreaSD3)

Return NIL

/*/{Protheus.doc} Static Function GeraEstTran
	Gera estorno do estoque em transito na filial de origem
	@type  Static Function
	@author Fernando Macieira
	@since 05/22/18
	@version 01
	/*/

Static Function GeraEstTran()

  Local aItens    := {}

  Local cLocTran  := GetMV("MV_LOCTRAN",,"95")
  Local cFilOrig  := GetMV("MV_#TRAFIL",,"08")
  //Local cTMEntrad := GetMV("MV_#TRATME",,"201")
  Local cTMSaida  := GetMV("MV_#TRATMS",,"701")

  // Movimento Interno - Entrada Almoxarifado em Transito
  cNumSeqD3 := ""
  cNumSeqD3 := BscD3Seq(cFilOrig, cLocTran, cTMSaida)

  AADD(aItens, {"D3_TM"		,cTMSaida      	 , Nil})
  AADD(aItens, {"D3_COD"		,SD1->D1_COD     , Nil})
  AADD(aItens, {"D3_UM"       ,SD1->D1_UM      , Nil})
  AADD(aItens, {"D3_QUANT"	,SD1->D1_QUANT   , Nil})
  AADD(aItens, {"D3_OP"   	,CriaVar("D3_OP"), Nil})
  AADD(aItens, {"D3_LOCAL"	,cLocTran        , Nil})
  AADD(aItens, {"D3_DOC"		,SD1->D1_DOC     , Nil})
  AADD(aItens, {"D3_EMISSAO"	,SD1->D1_DTDIGIT , Nil})
  AADD(aItens, {"D3_FILIAL"	,cFilOrig        , Nil})
  aAdd(aItens, {"D3_NUMSEQ"   ,cNumSeqD3       , Nil})
  aAdd(aItens, {"INDEX"       ,4               , Nil})

  Begin Transaction

    lMsErroAuto := .F.

    msExecAuto({|x,y| MATA240(x,y)}, aItens, 5) // Movimento Interno

    If lMsErroAuto

      DisarmTransaction()

      Aviso("MT103FIM-01", "Ser?necessário lançar manualmente o estorno do estoque em trânsito..." + chr(10) + chr(13) +;
        "Verifique os CADASTROS... " + chr(10) + chr(13) + chr(10) + chr(13) +;
        "Abaixo, dados da Nota excluída/estornada que NÃO gerou estorno na filial de origem do estoque em trânsito: " + chr(10) + chr(13) +;
        "Filial Origem: " + cFilOrig + chr(10) + chr(13) +;
        "Documento: " + SD1->D1_DOC  + chr(10) + chr(13) +;
        "Produto: " + SD1->D1_COD + chr(10) + chr(13) +;
        "Almoxarifado Entrada: " + SD1->D1_LOCAL + chr(10) + chr(13) +;
        "Almoxarifado Trânsito: " + cLocTran + chr(10) + chr(13) +;
        "", {"&Ok"}, 3, "ESTORNO do Estoque em Trânsito na filial de origem NÃO foi Gerado! Cadastros inconsistentes!")

      MostraErro()

    EndIf

  End Transaction

Return

/*/{Protheus.doc} Static Function SF2520E
	Busca Tipo de Frete da nota original
	@type  Static Function
	@author Adriana Oliveira
	@since 06/04/18
	@version 01
	/*/

Static Function BscD3Seq(cFilOrig, cLocTran, cTM)

  Local cSeqD3 := ""
  Local cQuery := ""

  If Select("Work") > 0
    Work->( dbCloseArea() )
  EndIf

  cQuery := " SELECT D3_NUMSEQ "
  cQuery += " FROM " + RetSqlName("SD3")
  cQuery += " WHERE D3_FILIAL='"+cFilOrig+"' "
  cQuery += " AND D3_COD='"+SD1->D1_COD+"' "
  cQuery += " AND D3_LOCAL='"+cLocTran+"' "
  cQuery += " AND D3_EMISSAO='"+DtoS(SD1->D1_DTDIGIT)+"' "
  cQuery += " AND D3_DOC='"+SD1->D1_DOC+"' "
  cQuery += " AND D3_TM='"+cTM+"' "
  cQuery += " AND D3_ESTORNO='' "
  cQuery += " AND D_E_L_E_T_='' "
  cQuery += " ORDER BY R_E_C_N_O_ DESC "

  tcQuery cQuery new alias "Work"

  Work->( dbGoTop() )
  If Work->( !EOF() )
    cSeqD3 := Work->D3_NUMSEQ
  EndIf

  If Select("Work") > 0
    Work->( dbCloseArea() )
  EndIf

Return cSeqD3

/*/{Protheus.doc} Static Function BuscaFret
	Busca Tipo de Frete da nota original
	@type  Static Function
	@author Adriana Oliveira
	@since 24/09/2018
	@version 01
	@history Adoro - chamado 043873
	/*/

Static Function BuscaFret(cFILIAL,cSERIE,cDOC,cFORNECE,cLOJA,cTIPO)

  Local cTpFrete := ""
  Local cQuery   := ""

  If Select("Work_Fret") > 0
    Work_Fret->( dbCloseArea() )
  EndIf

  //busco tipo de frete da nota origem
  cQuery := " SELECT F2_TPFRETE "
  cQuery += " FROM " + RetSqlName("SF2")
  cQuery += " INNER JOIN "
  //assumo a nota origem do primeiro item retornado pela query
  cQuery += " (SELECT TOP 1 D1_FILIAL,D1_SERIORI,D1_NFORI FROM " + RetSqlName("SD1")
  cQuery += " WHERE D1_FILIAL = '"	+cFILIAL+"' "
  cQuery += " AND D1_SERIE = '"		+cSERIE+"' "
  cQuery += " AND D1_DOC = '"			+cDOC+"' "
  cQuery += " AND D1_FORNECE = '"		+cFORNECE+"' "
  cQuery += " AND D1_LOJA = '"		+cLOJA+"' "
  cQuery += " AND D1_TIPO = '"		+cTIPO+"' "
  cQuery += " AND "+ RetSqlName("SD1")+".D_E_L_E_T_='') AS SD1TMP "
  cQuery += " ON SD1TMP.D1_FILIAL = F2_FILIAL AND SD1TMP.D1_SERIORI = F2_SERIE AND SD1TMP.D1_NFORI = F2_DOC "
  cQuery += " WHERE "+ RetSqlName("SF2") +".D_E_L_E_T_='' "

  tcQuery cQuery new alias "Work_Fret"

  Work_Fret->( dbGoTop() )
  If Work_Fret->( !EOF() )
    cTpFrete := Work_Fret->F2_TPFRETE
  EndIf

  If Select("Work_Fret") > 0
    Work_Fret->( dbCloseArea() )
  EndIf

Return cTpFrete

/*/{Protheus.doc} Static Function ContaAtivo
	atualizar a conta contabil para notas de ativo fixo
	@type  Static Function
	@author WILLIAM COSTA
	@since 25/11/2018
	@version 01
	@history Adoro - chamado 044792 
	/*/

Static Function ContaAtivo(nopcao)

  //chamado 037659 - Adriana 09/11/17
  Local _cConta 	:= ''
  Local _aAreaAnt	:= GetArea()
  Local cAtuATF   := ''

  If (Alltrim(FunName()) == "MATA103" .OR. IsInCallStack( "U_CENTNFEXM" )) .AND. ;
      SF1->F1_TIPO == "N"                                                  .AND. ;
      (nOpcao == 3 .OR. nOpcao == 4) //Incluir e Classificar

    //atualizar a conta contabil para notas de devolucao
    Dbselectarea("SD1")
    Dbsetorder(1)
    If SD1->(dbseek(xFilial("SD1") + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA,.T. ))

      While !Eof() .and. xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA == SD1->D1_FILIAL+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA

        _cConta := Posicione("SF4",1,xFilial("SF4")+SD1->D1_TES,"F4_XCONTA")
        cAtuATF := Posicione("SF4",1,xFilial("SF4")+SD1->D1_TES,"F4_ATUATF")

        IF cAtuATF = 'S' //Quando e S significa que a TES e de ATIVO FIXO

          Reclock("SD1",.F.)
          SD1->D1_CONTA 	:= iif(!Empty(_cConta),_cConta, SD1->D1_CONTA)
          MsUnlock("SD1")

          DbSelectArea("SFT")
          DbSetOrder(1)
          //FT_FILIAL+FT_TIPOMOV+FT_SERIE+FT_NFISCAL+FT_CLIEFOR+FT_LOJA+FT_ITEM+FT_PRODUTO
          IF dbseek(SD1->D1_FILIAL+"E"+SD1->D1_SERIE+SD1->D1_DOC+SD1->D1_FORNECE+SD1->D1_LOJA+SD1->D1_ITEM+SD1->D1_COD)
            Reclock("SFT",.F.)
            SFT->FT_CONTA 	:= iif(!Empty(_cConta),_cConta, SFT->FT_CONTA)
            MsUnlock("SFT")
          ENDIF

        ENDIF

        SD1->(dbSkip())

      EndDo

    Endif

  Endif
  //Fim Chamado: 037659 - Adriana 09/11/17

  RestArea(_aAreaAnt)

Return Nil

/*/{Protheus.doc} Static Function WFNFPC
	Configurações de e-mail.
	@type  Static Function
	@author Fernando Sigoli
	@since 02/01/2019
	@version version
	/*/

Static Function WFNFPC()

  Local cPC      := ""
  Local cPCItem  := ""
  Local cQuery   := ""
  Local nNFTot   := 0
  Local nNFQtd   := 0
  Local nPCQtd   := 0
  Local nPCTot   := 0
  Local aDadWF   := {}
  Local aAreaSC7 := SC7->( GetArea() )

  If Select("Work") > 0
    Work->( dbCloseArea() )
  EndIf

  // Carrego PCs da NF
  cQuery := " SELECT DISTINCT D1_PEDIDO, D1_ITEMPC "
  cQuery += " FROM " + RetSqlName("SD1") + " SD1 (NOLOCK), " + RetSqlName("SF1") + " SF1 (NOLOCK)"
  cQuery += " WHERE D1_FILIAL=F1_FILIAL "
  cQuery += " AND D1_DOC=F1_DOC "
  cQuery += " AND D1_SERIE=F1_SERIE "
  cQuery += " AND D1_TIPO=F1_TIPO "
  cQuery += " AND D1_FORNECE=F1_FORNECE "
  cQuery += " AND D1_LOJA=F1_LOJA "
  cQuery += " AND F1_FILIAL='"+SF1->F1_FILIAL+"' "
  cQuery += " AND F1_DOC='"+SF1->F1_DOC+"' "
  cQuery += " AND F1_SERIE='"+SF1->F1_SERIE+"' "
  cQuery += " AND F1_TIPO='"+SF1->F1_TIPO+"' "
  cQuery += " AND F1_FORNECE='"+SF1->F1_FORNECE+"' "
  cQuery += " AND F1_LOJA='"+SF1->F1_LOJA+"' "
  cQuery += " AND SD1.D_E_L_E_T_='' "
  cQuery += " AND SF1.D_E_L_E_T_='' "
  cQuery += " ORDER BY 1,2 "

  tcquery cQuery new alias "Work"

  // Checo QTD e VALOR para disparar WF
  Work->( dbGoTop() )
  Do While Work->( !EOF() )

    cPC     := Work->D1_PEDIDO
    cPCItem := Work->D1_ITEMPC

    If Select("WorkWF") > 0
      WorkWF->( dbCloseArea() )
    EndIf

    // 25/03/2019 => Retirado impostos conforme diretriz da Adoro devido departamento de compras nao informar impostos no pedido e o mesmo não ser passível de fraude
    //		cQuery := " SELECT ISNULL(SUM(D1_TOTAL+D1_VALIPI+D1_VALFRE+D1_DESPESA+D1_SEGURO+D1_ICMSRET-D1_VALDESC),0) AS TOTAL, ISNULL(SUM(D1_QUANT),0) AS QTD "
    cQuery := " SELECT ISNULL(SUM(D1_TOTAL+D1_VALFRE+D1_DESPESA+D1_SEGURO-D1_VALDESC),0) AS TOTAL, ISNULL(SUM(D1_QUANT),0) AS QTD "
    cQuery += " FROM " + RetSqlName( "SD1" ) + " SD1 (NOLOCK), " + RetSqlName("SF4") + " SF4 (NOLOCK) "
    cQuery += " WHERE D1_TES=F4_CODIGO "
    cQuery += " AND SD1.D1_FILIAL='"+FWxFilial("SD1")+"' "
    cQuery += " AND SD1.D1_PEDIDO = '" + cPC + "' "
    cQuery += " AND SD1.D1_ITEMPC = '" + cPCItem + "' "
    cQuery += " AND SD1.D_E_L_E_T_ = '' "
    cQuery += " AND F4_FILIAL='"+FWxFilial("SF4")+"' "
    cQuery += " AND F4_DUPLIC = 'S' "
    cQuery += " AND SF4.D_E_L_E_T_ = '' "

    tcQuery cQuery new Alias "WorkWF"

    aTamSX3	:= TamSX3("D1_TOTAL")
    tcSetField("WorkWF", "TOTAL", aTamSX3[3], aTamSX3[1], aTamSX3[2])

    aTamSX3	:= TamSX3("D1_QUANT")
    tcSetField("WorkWF", "QTD", aTamSX3[3], aTamSX3[1], aTamSX3[2])

    nNFTot := WorkWF->TOTAL
    nNFQtd := WorkWF->QTD

    // Posiciono PC
    SC7->( dbSetOrder(1) ) // C7_FILIAL+C7_NUM+C7_ITEM+C7_SEQUEN
    If SC7->( dbSeek( FWxFilial("SC7")+cPC+cPCItem ) )

      nPCQtd := SC7->C7_QUANT
      nPCTot := SC7->(C7_TOTAL+C7_VALFRE+C7_DESPESA+C7_SEGURO-C7_VLDESC)
      // 25/03/2019 => Retirado impostos conforme diretriz da Adoro devido departamento de compras nao informar impostos no pedido e o mesmo não ser passível de fraude
      //		 	nPCTot := SC7->(C7_TOTAL+C7_VALFRE+C7_DESPESA+C7_SEGURO+C7_VALIPI+C7_ICMSRET-C7_VLDESC)

      // Checo Qtd
      If nNFQtd > nPCQtd

        // Gravo Log ZBE
        u_GrLogZBE (Date(),TIME(),cUserName,"DOC/SERIE " + SF1->F1_DOC + "/" + SF1->F1_SERIE + " PC/ITEM " + SC7->C7_NUM + "/" + SC7->C7_ITEM + " PC(QTD) " + AllTrim(Str(nPCQtd)) + " NF(QTD) " + AllTrim(Str(nNFQtd)),"COMPRAS","MT103FIM ",;
          "WF NF > PC (Quantidade) ",ComputerName(),LogUserName())

        // Populo Array para envio de email - QUANTIDADE
        aAdd( aDadWF, { cEmpAnt, cFilAnt, msDate(), SF1->F1_DOC+"/"+SF1->F1_SERIE, SC7->C7_NUM+"/"+SC7->C7_ITEM, nPCQtd, nNFQtd, nPCTot, nNFTot, AllTrim(SC7->C7_PRODUTO) + " - " + AllTrim(SC7->C7_DESCRI), "Quantidade", SC7->C7_MOEDA, SF1->F1_MOEDA } )

      EndIf

      // Checo Valor
      If nNFTot > nPCTot

        // Gravo Log ZBE
        u_GrLogZBE (Date(),TIME(),cUserName,"DOC/SERIE " + SF1->F1_DOC + "/" + SF1->F1_SERIE + " PC/ITEM " + SC7->C7_NUM + "/" + SC7->C7_ITEM + " PC(VLR) " + AllTrim(Str(nPCTot)) + " NF(VLR) " + AllTrim(Str(nNFTot)),"COMPRAS","MT103FIM ",;
          "WF NF > PC (Valor) ",ComputerName(),LogUserName())

        // Populo Array para envio de email
        aAdd( aDadWF, { cEmpAnt, cFilAnt, msDate(), SF1->F1_DOC+"/"+SF1->F1_SERIE, SC7->C7_NUM+"/"+SC7->C7_ITEM, nPCQtd, nNFQtd, nPCTot, nNFTot, AllTrim(SC7->C7_PRODUTO) + " - " + AllTrim(SC7->C7_DESCRI), "Valor", SC7->C7_MOEDA, SF1->F1_MOEDA } )

      EndIf

    EndIf

    Work->( dbSkip() )

  EndDo

  // Disparo WF
  If Len(aDadWF) > 0
    MsgRun( "Enviando email para diretoria/gerência...","NF maior que PC autorizado...", { || SendWF(aDadWF) } )
  EndIf

  // Fecho arquivos tmp
  If Select("Work") > 0
    Work->( dbCloseArea() )
  EndIf

  If Select("WorkWF") > 0
    WorkWF->( dbCloseArea() )
  EndIf

  RestArea( aAreaSC7 )

Return

/*/{Protheus.doc} Static Function SendWF
	Configurações de e-mail.
	@type  Static Function
	@author Fernando Sigoli
	@since 02/01/2019
	@version version
	/*/

Static Function SendWF(aDadWF)

  Local nPerc1     := 0
  Local nPerc2     := 0
  Local cAssunto	 := "[ MT103FIM ] - NF superior PC - " + DtoC(msDate()) + " - " + time()
  Local cMensagem	 := ""
  Local cMails     := GetMV("MV_#WFNFPC",,"fwnmacieira@gmail.com")
  Local i          := 1

  // Cabecalho corpo email
  cMensagem += '<html>'
  cMensagem += '<body>'
  cMensagem += '<p style="color:red">'+cValToChar(cAssunto)+'</p>'
  cMensagem += '<hr>'
  cMensagem += '<table border="1">'
  cMensagem += '<tr style="background-color: black;color:white">'
  cMensagem += '<td>Empresa</td>'
  cMensagem += '<td>Filial</td>'
  cMensagem += '<td>Data</td>'
  cMensagem += '<td>Documento/Série</td>'
  cMensagem += '<td>PC/Item</td>'
  cMensagem += '<td>Produto</td>'
  cMensagem += '<td>Superior em</td>'
  cMensagem += '<td>Quantidade PC</td>'
  cMensagem += '<td>Quantidade NFs (Somatório Todas)</td>'
  cMensagem += '<td>Quantidade (Diferença em %)</td>'
  cMensagem += '<td>Valor PC</td>'
  cMensagem += '<td>Valor NFs (Somatório Todas) </td>'
  cMensagem += '<td>Valor (Diferença em %)</td>'
//	cMensagem += '<td>Computador</td>'
  cMensagem += '<td>Moeda PC</td>'
  cMensagem += '<td>Moeda NF</td>'
  cMensagem += '<td>Login</td>'
  cMensagem += '</tr>'

  For i:=1 to Len(aDadWF)

    nPerc1 := (aDadWF[i,7]/aDadWF[i,6])*100
    nPerc2 := (aDadWF[i,9]/aDadWF[i,8])*100

    cMensagem += '<tr>'
    cMensagem += '<td>' + cValToChar(aDadWF[i,1]) + '</td>'
    cMensagem += '<td>' + cValToChar(aDadWF[i,2]) + '</td>'
    cMensagem += '<td>' + cValToChar(aDadWF[i,3]) + '</td>'
    cMensagem += '<td>' + cValToChar(aDadWF[i,4]) + '</td>'
    cMensagem += '<td>' + cValToChar(aDadWF[i,5]) + '</td>'
    cMensagem += '<td>' + cValToChar(aDadWF[i,10]) + '</td>'
    cMensagem += '<td>' + cValToChar(aDadWF[i,11]) + '</td>'
    cMensagem += '<td>' + cValToChar(aDadWF[i,6]) + '</td>'
    cMensagem += '<td>' + cValToChar(aDadWF[i,7]) + '</td>'

    If nPerc1 > 100
//			cMensagem += '<td>' + cValToChar(Transform((aDadWF[i,7]/aDadWF[i,6]*100),"@E 999,999.99 %")) + '</td>'
      cMensagem += '<td>' + cValToChar(Transform((aDadWF[i,7]/aDadWF[i,6]*100),"@E 999,999%")) + '</td>'
    Else
//			cMensagem += '<td>' + cValToChar("") + '</td>'
      cMensagem += '<td>' + cValToChar("0%") + '</td>'
    EndIf

    cMensagem += '<td>' + cValToChar(Transform(aDadWF[i,8], "@E 999,999,999,999.99")) + '</td>'
    cMensagem += '<td>' + cValToChar(Transform(aDadWF[i,9], "@E 999,999,999,999.99")) + '</td>'

    If nPerc2 > 100
//			cMensagem += '<td>' + cValToChar(Transform((aDadWF[i,9]/aDadWF[i,8]*100),"@E 999,999.99 %")) + '</td>'
      cMensagem += '<td>' + cValToChar(Transform((aDadWF[i,9]/aDadWF[i,8]*100),"@E 999,999%")) + '</td>'
    Else
//			cMensagem += '<td>' + cValToChar("") + '</td>'
      cMensagem += '<td>' + cValToChar("0%") + '</td>'
    EndIf

    cMensagem += '<td>' + cValToChar(aDadWF[i,12]) + '</td>'
    cMensagem += '<td>' + cValToChar(aDadWF[i,13]) + '</td>'

//		cMensagem += '<td>' + cValToChar(ComputerName()) + '</td>'
    cMensagem += '<td>' + cValToChar(cUserName)  + '</td>'

    cMensagem += '</tr>'

  Next i

  cMensagem += '</table>'
  cMensagem += '</body>'
  cMensagem += '</html>'

  //
  ProcEmail(cAssunto,cMensagem,cMails)

Return

/*/{Protheus.doc} Static Function ProcEmail
	Configurações de e-mail.
	@type  Static Function
	@author Fernando Sigoli
	@since 02/01/2019
	@version version
	/*/

Static Function ProcEmail(cAssunto,cMensagem,email)

  Local lOk           := .T.
  Local lAutOk        := .F.
  Local aArea			:= GetArea()
  Local cBody         := cMensagem
  Local cTo           := email
  Local cErrorMsg     := ""
  Local cAtach        := ""
  Local cSubject      := ""
  //Local aFiles        := {}
  Local cServer       := Alltrim(GetMv("MV_RELSERV"))
  Local cAccount      := AllTrim(GetMv("MV_RELACNT"))
  Local cPassword     := AllTrim(GetMv("MV_RELPSW"))
  Local cFrom         := AllTrim(GetMv("MV_RELFROM")) //Por Adriana em 24/05/2019 substituido MV_RELACNT por MV_RELFROM
  Local lSmtpAuth     := GetMv("MV_RELAUTH",,.F.)

  cSubject := cAssunto

  Connect Smtp Server cServer Account cAccount  Password cPassword Result lOk

  If !lAutOk
    If ( lSmtpAuth )
      lAutOk := MailAuth(cAccount,cPassword)
    Else
      lAutOk := .T.
    EndIf
  EndIf

  If lOk .And. lAutOk

    Send Mail From cFrom To cTo Subject cSubject Body cBody ATTACHMENT cAtach Result lOk

    If !lOk
      Get Mail Error cErrorMsg
      ConOut("3 - " + cErrorMsg)
    EndIf

  Else
    Get Mail Error cErrorMsg
    ConOut("4 - " + cErrorMsg)

  EndIf

  If lOk
    Disconnect Smtp Server
  EndIf

  RestArea(aArea)

Return

STATIC Function SendMlBE(cChaveEml)  
   
  Local lOk       := .T.
	Local cBody			:= RetHTML(cChaveEml)
	Local cErrorMsg	:=	""
	//Local aFiles 		:= {}
	Local cServer   := Alltrim(GetMv("MV_RELSERV"))
	Local cAccount  := AllTrim(GetMv("MV_RELACNT"))
	Local cPassword := AllTrim(GetMv("MV_RELPSW"))
	Local cFrom     := AllTrim(GetMv("MV_RELFROM")) //Por Adriana em 24/05/2019 substituido MV_RELACNT por MV_RELFROM
	Local lSmtpAuth := GetMv("MV_RELAUTH",,.F.)
	Local lAutOk    := .F.
	Local cAtach 		:= ""
	Local cSubject  := "Boletim de Entrada " + Substr(cChaveEml,1,9) + " - " + Substr(cChaveEml,10,3) + " Fornecedor: "+ Substr(cChaveEml,13,6) + "-" + Substr(cChaveEml,19,2)

	Connect Smtp Server cServer Account cAccount 	Password cPassword Result lOk
				
	If !lAutOk
		If ( lSmtpAuth )
			lAutOk := MailAuth(cAccount,cPassword)
		Else
			lAutOk := .T.
		EndIf
	EndIf

	If lOk .And. lAutOk
		
		Send Mail From cFrom To cToBoletim Subject cSubject Body cBody ATTACHMENT cAtach Result lOk
		
		If !lOk
			Get Mail Error cErrorMsg
			ConOut("3 - " + cErrorMsg)
		EndIf
	Else
		Get Mail Error cErrorMsg
		ConOut("4 - " + cErrorMsg)
	EndIf

	If lOk
		Disconnect Smtp Server
	Endif

Return

Static Function RetHTML(cChaveEml)

  Local cRet	:=	""    

  dbSelectArea("SF1")
  dbSetOrder(1)
  If !dbSeek(xFilial("SF1")+cChaveEml)
    Return(cRet)
  Endif

  cRet := "<p <span style='"
  cRet += 'font-family:"MS Sans Serif"'
  cRet += "'><b>Nota Fiscal: </b>" + SF1->F1_SERIE + " " + SF1->F1_DOC + " </span></strong></b><o:p></o:p></span></p>"

  cRet += "<p style='mso-outline-level:1'><span style='font-family:"
  cRet += '"MS Sans Serif"'                                   
  cRet += "'><b>Emissao: </b>" + DTOC(SF1->F1_EMISSAO) + "<b> Filial: </b>" + SF1->F1_FILIAL

  cRet += "<p style='mso-outline-level:1'><span style='font-family:"
  cRet += '"MS Sans Serif"'                                   
  cRet += "'><b>Fornecedor: </b>" + SF1->F1_FORNECE + " / " + SF1->F1_LOJA

  dbSelectArea("SA2")
  dbSetOrder(1)
  dbGoTop() 
  If dbSeek(xFilial("SA2")+SF1->F1_FORNECE+SF1->F1_LOJA)                               
    cRet += " - " + SA2->A2_NOME + " </span></strong><b><o:p></o:p></b></span></p>"
  Endif

  cRet += "<p style='mso-outline-level:1'><span style='font-family:"
  cRet += '"MS Sans Serif"'
  cRet += "'><b>Produtos: </strong></b><o:p></o:p></span></p>"

  cRet += "<table border=1 bgcolor='SkyBlue'>"
  cRet += "<font size=2><b>"
  cRet += "<tr>"
  cRet += "<td width=100 align=center> CODIGO "
  cRet += "<td width=50 align=center> UN "
  cRet += "<td width=300 align=center> DESCRICAO DO PRODUTO "
  cRet += "<td width=100 align=center> QUANTIDADE "
  cRet += "<td width=100 align=center> VLR UNITARIO "
  cRet += "<td width=100 align=center> VLR TOTAL "
  cRet += "<td width=100 align=center> IPI "
  cRet += "<td width=100 align=center> ICMS "
  cRet += "<td width=100 align=center> CTA CONTABIL "
  cRet += "<td width=100 align=center> TES "
  cRet += "<td width=100 align=center> CFOP "
  cRet += "<td width=100 align=center> CUSTO UNIT "
  cRet += "</tr></b>"

  dbSelectArea("SD1")
  dbSetOrder(1)
  dbGoTop() 
  dbSeek(xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA)
  While !Eof() .and. SD1->D1_FILIAL == xFilial("SD1") .and. SF1->F1_DOC == SD1->D1_DOC .and. SF1->F1_SERIE == SD1->D1_SERIE .and.;
    SF1->F1_FORNECE == SD1->D1_FORNECE .and. SF1->F1_LOJA == SD1->D1_LOJA
              
    cRet += "<tr>"
    cRet += "<td width=100 align=center>"
    cRet += SD1->D1_COD + "   "
    cRet += "</td>"	
    cRet += "<td width=50 align=center>"	
    cRet += SD1->D1_UM  + "    "	
    cRet += "</td>"	
    dbSelectArea("SB1")	
    dbSetOrder(1)     
    dbGoTop()
    If dbSeek(xFilial("SB1")+SD1->D1_COD)
    cRet += "<td width=300 align=center>"	
      cRet += SUBSTR(SB1->B1_DESC,1,20) 	
      cRet += "</td>"		
    Endif		   
    cRet += "<td width=100 align=center>"	
    cRet += STR(SD1->D1_QUANT) + " "
    cRet += "</td>"	
    cRet += "<td width=100 align=center>"	
    cRet += STR(SD1->D1_VUNIT) + " "
    cRet += "</td>"	
    cRet += "<td width=100 align=center>"	
    cRet += STR(SD1->D1_TOTAL) + " "
    cRet += "</td>"	
    cRet += "<td width=100 align=center>"	
    cRet += STR(SD1->D1_IPI) + " "
    cRet += "</td>"
    cRet += "<td width=100 align=center>"	
    cRet += STR(SD1->D1_VALICM) + " "
    cRet += "</td>"
    cRet += "<td width=100 align=center>"	
    cRet += SD1->D1_CONTA + " "
    cRet += "</td>"					
    cRet += "<td width=100 align=center>"	
    cRet += SD1->D1_TES + " "
    cRet += "</td>"		
    cRet += "<td width=100 align=center>"	
    cRet += SD1->D1_CF + " "
    cRet += "</td>"		
    cRet += "<td width=100 align=center>"	
    cRet += STR(SD1->D1_CUSTO) + " "
    cRet += "</td>"		
    cRet += "</tr>"		

    SD1->(dbSkip())
  Enddo

  cRet += "</table>"

  cRet		+=	'</span>' 
  cRet		+=	'<br>'
  cRet		+=	'</body>'
  cRet		+=	'</html>'

Return(cRet)

/*/{Protheus.doc} fAjustaCDA
	Realiza o ajuste da gravação da CDA
	@type  Static Function
	@author  Glauco Oliveira - Eleva
	@since   31/03/2020
	@version 01
	@history Adoro - chamado 052671 
	/*/

Static Function fAjustaCDA()

	Local aArea		  := GetArea()
	//Local cEspecie 	:= SF1->F1_ESPECIE
	Local cFilSD1  	:= SF1->F1_FILIAL
	Local cNf	      := SF1->F1_DOC
	Local cSerie   	:= SF1->F1_SERIE
	Local cForn    	:= SF1->F1_FORNECE
	Local cLoja    	:= SF1->F1_LOJA
	//Local cTESAtlz 	:= ""

	DbSelectArea("SD1")
	SD1->(DbSetOrder(1))
	SD1->(DbGoTop())
	If SD1->(DbSeek( FWxFilial("SD1") + cNf + cSerie + cForn +  cLoja ))
	
		While ! SD1->(Eof()) .And. cFilSD1 == SD1->D1_FILIAL .And. cNf == SD1->D1_DOC .And.;
		cSerie == SD1->D1_SERIE .And. cForn == SD1->D1_FORNECE .And.;
		cLoja == SD1->D1_LOJA
			
			If SD1->D1_ICMSCOM > 0
				Processa({|| atlzCDA() }, "Atualizando tabela de complemento (CDA)...")
        //Exit //Ticket 1794 por Adriana em 23/09/2020
			EndIf

			SD1->(DbSkip())	
		EndDo	
	EndIf

	RestArea(aArea)

Return

/*/{Protheus.doc} atlzCDA
  Atualiza CDA
 	@type  Static Function
  @author  Glauco Oliveira - Eleva
  @since   31/03/2020
  @version 01
	@history Adoro - chamado 052671 
  /*/

Static Function atlzCDA()

	Local cTpMov	  := "E"
	Local nIx		    := 1 //Ticket 11265   - Abel Babini     - 19/03/2021 - Ajuste na rotina que gera os registros C197 para gravar o campo D1_ITEM. A não gravação do campo causava a delação do registro no reprocessamento dos livros. Correção na formula da aliquota interestadual
	Local nAliqICMS	:= 0
	Local nBaseICMS	:= SF1->F1_BASEICM
	Local nValICMS	:= 0
	Local cFormul	  := SF1->F1_FORMUL
	Local cEspecie 	:= SF1->F1_ESPECIE
	Local cNf	      := SF1->F1_DOC
	Local cSerie   	:= SF1->F1_SERIE
	Local cForn    	:= SF1->F1_FORNECE
	Local cLoja    	:= SF1->F1_LOJA
  Local lSimpNac  := POSICIONE("SA2",1,xFilial("SA2")+SF1->F1_FORNECE+SF1->F1_LOJA,"A2_SIMPNAC") = "1"
	Local cIfComp	  := "CCAT"
	Local cCalPro	  := "2"
	Local cTpLanc	  := "2"
	Local cVl197	  := "1"
  Local cEstICM   := GETMV("MV_ESTICM") //Ticket 1794 por Adriana em 23/09/2020
  //Ticket 11265   - Abel Babini     - 19/03/2021 - Ajuste na rotina que gera os registros C197 para gravar o campo D1_ITEM. A não gravação do campo causava a delação do registro no reprocessamento dos livros. Correção na formula da aliquota interestadual
  // Local cEst      := SF1->F1_EST //Ticket 1794 por Adriana em 23/09/2020

  //Inicio - Chamado 058821 - Adriana Oliveira- 30/07/2020
  If SD1->D1_ITEM = '0001'
		RecLock("CDA", .T.)
		cCodLan		:= "SP40090207"
		nAliqICMS	:= 18
    //INICIO Ticket 18347   - Abel Babini     - 16/08/2021 - Não era gravado o valor do ICMS 18% para notas de complemento quando
    IF Alltrim(SF1->F1_TIPO) $ 'I/C/P' .AND. nBaseICMS == 0
      nValICMS	:= ( SD1->D1_VALICM / (SD1->D1_PICM / 100) ) * ( nAliqICMS / 100 )
    ELSE
		  nValICMS	:= nBaseICMS * nAliqICMS / 100
    ENDIF
    //FIM Ticket 18347   - Abel Babini     - 16/08/2021 - Não era gravado o valor do ICMS 18% para notas de complemento quando
		CDA->CDA_FILIAL		:= xFilial("CDA")
		CDA->CDA_TPMOVI		:= cTpMov
		CDA->CDA_ESPECI		:= cEspecie
		CDA->CDA_FORMUL		:= cFormul
		CDA->CDA_NUMERO		:= cNf
		CDA->CDA_SERIE		:= cSerie
		CDA->CDA_CLIFOR		:= cForn
		CDA->CDA_LOJA		  := cLoja
    CDA->CDA_NUMITE		:= SD1->D1_ITEM //Ticket 11265   - Abel Babini     - 19/03/2021 - Ajuste na rotina que gera os registros C197 para gravar o campo D1_ITEM. A não gravação do campo causava a delação do registro no reprocessamento dos livros. Correção na formula da aliquota interestadual
		CDA->CDA_SEQ		  := PadL(cValToChar(nIx), TamSX3("CDA_SEQ")[1], "0")
		CDA->CDA_CODLAN		:= cCodLan
		CDA->CDA_ALIQ		  := nAliqICMS
		CDA->CDA_VALOR		:= nValICMS
		CDA->CDA_CALPRO		:= cCalPro
		CDA->CDA_BASE		  := nBaseICMS
		CDA->CDA_IFCOMP		:= cIfComp
		CDA->CDA_TPLANC		:= cTpLanc
		CDA->CDA_VL197		:= cVl197
		CDA->CDA_CLANC	  := 'COMPRA DE ATIVO PAGAMENTO DE DIFERENCIAL DE ALIQUOTAS'
			
		CDA->(MsUnlock())
    nIx := nIx + 1 //Ticket 11265   - Abel Babini     - 19/03/2021 - Ajuste na rotina que gera os registros C197 para gravar o campo D1_ITEM. A não gravação do campo causava a delação do registro no reprocessamento dos livros. Correção na formula da aliquota interestadual
	EndIf
	RecLock("CDA", .T.)
	cCodLan		:= "SP10090718"
	nAliqICMS	:= SD1->D1_PICM 
  nBaseICMS := SD1->D1_BASEICM
  If lSimpNac
    //Inicio Ticket 1794 por Adriana em 23/09/2020
    if nAliqICMS = 0
        // Ticket 11265   - Abel Babini     - 19/03/2021 - Ajuste na rotina que gera os registros C197 para gravar o campo D1_ITEM. A não gravação do campo causava a delação do registro no reprocessamento dos livros. Correção na formula da aliquota interestadual
        // nAliqICMS = Val(SUBSTR(cEstICM,AT(cEst,cEstICM)+2,2))
        IF !EMPTY(SM0->M0_ESTENT)
          nAliqICMS = Val(SUBSTR(cEstICM,AT(SM0->M0_ESTENT,cEstICM)+2,2))-ROUND(SD1->D1_ICMSCOM/SD1->D1_BASEICM,2)*100
        ELSE
          nAliqICMS = Val(SUBSTR(cEstICM,AT(SM0->M0_ESTCOB,cEstICM)+2,2))-ROUND(SD1->D1_ICMSCOM/SD1->D1_BASEICM,2)*100
        ENDIF
    endif
    //Fim Ticket 1794 por Adriana em 23/09/2020
    nValICMS	:= nBaseICMS * nAliqICMS / 100

  Else
 	  nValICMS	:= SD1->D1_VALICM
  EndIf
	CDA->CDA_FILIAL		:= xFilial("CDA")
	CDA->CDA_TPMOVI		:= cTpMov
	CDA->CDA_ESPECI		:= cEspecie
	CDA->CDA_FORMUL		:= cFormul
	CDA->CDA_NUMERO		:= cNf
	CDA->CDA_SERIE		:= cSerie
	CDA->CDA_CLIFOR		:= cForn
	CDA->CDA_LOJA		  := cLoja
	CDA->CDA_NUMITE		:= SD1->D1_ITEM
	CDA->CDA_SEQ		  := PadL(cValToChar(nIx), TamSX3("CDA_SEQ")[1], "0")
	CDA->CDA_CODLAN		:= cCodLan
	CDA->CDA_ALIQ		  := nAliqICMS
	CDA->CDA_VALOR		:= nValICMS 
	CDA->CDA_CALPRO		:= cCalPro
	CDA->CDA_BASE		  := nBaseICMS
	CDA->CDA_IFCOMP		:= cIfComp
	CDA->CDA_TPLANC		:= cTpLanc
	CDA->CDA_VL197		:= cVl197
	CDA->CDA_CLANC	  := 'COMPRA DE ATIVO PAGAMENTO DE DIFERENCIAL DE ALIQUOTAS'
	CDA->(MsUnlock())   
  //Fim - Chamado 058821 - Adriana Oliveira- 30/07/2020

Return

/*/{Protheus.doc} fAjustaCDD
  Realiza o ajuste da gravação da CDD
	@type  Static Function
  @author  Glauco Oliveira - Eleva
  @since   29/05/2020
  @version 01
	@history Adoro - chamado 052610 
  /*/

Static Function fAjustaCDD()

	Local aArea		 	:= GetArea()
	Local aAreaCDD 	:= CDD->(GetArea())
  Local aAreaCDT 	:= CDT->(GetArea())
	Local cFilSD1   := SF1->F1_FILIAL
	Local cNf	      := SF1->F1_DOC
	//Local dEmissao	:= SF1->F1_EMISSAO
	Local cSerie   	:= SF1->F1_SERIE
	Local cForn    	:= SF1->F1_FORNECE
	Local cLoja    	:= SF1->F1_LOJA
	Local cMenNota 	:= SF1->F1_MENNOTB
	Local cEntSai   := iif(SF1->F1_TIPO $ "CIP","1","2") //chamado 058730 por Adriana em 30/06/2020
  Local cNFOri	  := ""
	Local cSerOri	  := ""
	Local cChvOri	  := ""
	Local cDesc		  := ""
	Local cIfComp 	:= Space(TamSX3("CDD_IFCOMP")[1])
	Local nOpca		  := 0
	Local aDados	  := {}
	//Local dEmissOri	:= fEmissOri(SD1->D1_NFORI, SD1->D1_SERIORI, cForn, cLoja)
	Local cDescComp := "" //chamado 058730 por Adriana em 23/06/2020 

  // Inicio chamado 058730 por Adriana em 09/06/2020

  IF IsInCallStack("U_INTNFEB") 

    IF (nRadio = 3 .or. nRadio = 5) //ENTRADA POR TRANS. EMPRESA  e ENTRADA POR TRANS. INTEGRADO     
      cIfComp   := "CCAT01"
      cDesc     := "RETORNO DE MERCADORIA" //chamado 058730 por Adriana em 30/06/2020 
      cDescComp := "RETORNO DE MERCADORIA" //chamado 058821 por Adriana em 30/07/2020 
      nOpca		  := 1
      ConOut( "MT103FIM-com INTNFEB nradio="+str(nradio,1)+" - NF"+SF1->F1_DOC)
    ENDIF

  ELSE

 // Fim chamado 058730 por Adriana em 09/06/2020

    oModal := FWDialogModal():New()
    oModal:SetTitle("Complemento Bloco C113") 
    oModal:SetFreeArea( 500, 50 )
    oModal:SetEscClose( .T. )
    oModal:CreateDialog()

    @ 10,005	SAY "Cod.Inf.Compl."                                                    SIZE 73, 8	OF oModal:GetPanelMain() PIXEL
    @ 08,050	MSGET cIfComp		PICTURE "@!"	On change fChgIfComp(cIfComp, @cDesc, @cDescComp)	F3 "CCE"	SIZE 40,10	OF oModal:GetPanelMain() PIXEL	HASBUTTON //chamado 058730 por Adriana em 23/06/2020

    @ 10,095	SAY "Dsc.Inf.Compl."                                                    Size 73, 8	OF oModal:GetPanelMain() PIXEL
    @ 08,140	MSGET oGet01 VAR cDesc 																									SIZE 350,9 	OF oModal:GetPanelMain() PIXEL	WHEN .F.

    @ 30,005	SAY "Desc. Compl."		                                                  SIZE 73, 8	OF oModal:GetPanelMain() PIXEL
    @ 28,050	MSGET cDescComp	PICTURE "@!"																						SIZE 440,10	OF oModal:GetPanelMain() PIXEL

    oModal:AddButton( "Confirmar"	,{|| (nOpca := 1, fConfirma(oModal, cIfComp)) }, "Confirmar"	, , .T., .F., .T., )
    oModal:AddButton( "Fechar"		,{|| (nOpca := 2, oModal:Deactivate()) }, "Fechar"		, , .T., .F., .T., )

    oModal:Activate()

  ENDIF
  
	// Clicou OK
	If nOpca == 1
	//	If Empty(AllTrim(cMenNota))
	//		cMenNota	:= AllTrim(cDescComp)
	//	Else
			cMenNota	:= AllTrim(cMenNota) + " " + AllTrim(cDescComp)
	//	EndIf
		// Atualiza mensagem para nota
		RecLock("SF1", .F.)
		SF1->F1_MENNOTB		:= cMenNota
		SF1->(MsUnlock())

		// Tratativas para os complementos.
		dbSelectArea("SD1")
		SD1->(DbSetOrder(1))
		SD1->(DbGoTop())
		If SD1->(DbSeek( FWxFilial("SD1") + cNf + cSerie + cForn +  cLoja ))
      
			While !SD1->(Eof()) .And. cFilSD1 == SD1->D1_FILIAL .And. cNf == SD1->D1_DOC .And.;
        cSerie == SD1->D1_SERIE .And. cForn == SD1->D1_FORNECE .And.;
        cLoja == SD1->D1_LOJA
				If !Empty(SD1->D1_NFORI) .And. !Empty(SD1->D1_SERIORI) .And. (cNFOri+cSerOri # SD1->(D1_SERIORI+D1_NFORI))
					aDados		:= {}
					cNFOri		:= SD1->D1_NFORI
					cSerOri		:= SD1->D1_SERIORI
					cChvOri		:= fChvNfeOri(cNFOri, cSerOri, cForn, cLoja)

					// Dados para atualização das tabelas CDD e CDT
  			  aAdd(aDados, cNf)
					aAdd(aDados, cSerie)
					aAdd(aDados, cForn)
					aAdd(aDados, cLoja)
					aAdd(aDados, cNFOri)
					aAdd(aDados, cSerOri)
					aAdd(aDados, cIfComp)
					aAdd(aDados, cDescComp)
					aAdd(aDados, cChvOri)
          aAdd(aDados, cEntSai) //chamado 058730 por Adriana em 30/06/2020

					// Cria/Atualiza CDD
					Processa({|| atlzCDD(aDados) }, "Atualizando tabela de complemento (CDD)...")

					// Cria/Atualiza CDT
					Processa({|| atlzCDT(aDados) }, "Atualizando tabela de complemento (CDT)...")
				EndIf

				SD1->(DbSkip())	
			EndDo	
		EndIf
	EndIf

	RestArea(aAreaCDT)
	RestArea(aAreaCDD)
	RestArea(aArea)

Return

/*/{Protheus.doc} fConfirma
  Valida informações digitadas
 	@type  Static Function
  @author  Glauco Oliveira - Eleva
  @since   29/05/2020
  @version 01
 	@history Adoro - chamado 052610 
  /*/

Static Function fConfirma(oModal, cIfComp)
	If Empty(cIfComp)
		HELP(' ',1,"CODINFVAZIO" ,,"O campo Cod.Inf.Compl. é obrigatório.",2,0,,,,,, {"Preencha o campo Cod.Inf.Compl. e tente novamente."})
	Else
		dbSelectArea('CCE')
		CCE->(dbSetOrder(1))
		If !CCE->(dbSeek(xFilial('CCE') + cIfComp))
			HELP(' ',1,"CODINFNOREG" ,,"O Cod.Inf.Compl. não foi localizado.",2,0,,,,,, {"Verifique o Cod.Inf.Compl. digitado e tente novamente."})
		Else
			oModal:Deactivate()
		EndIf
	EndIf
Return

/*/{Protheus.doc} atlzCDD
  Atualiza tabela de complemento CDD
 	@type  Static Function
  @author  Glauco Oliveira - Eleva
  @since   29/05/2020
  @version 01
 	@history Adoro - chamado 052610 
  /*/

Static Function atlzCDD(aDados)

	// Cria/Atualiza CDD
	dbSelectArea('CDD')
	CDD->(dbSetOrder(1)) //CDD_FILIAL+CDD_TPMOV+CDD_DOC+CDD_SERIE+CDD_CLIFOR+CDD_LOJA+CDD_DOCREF+CDD_SERREF+CDD_PARREF+CDD_LOJREF
	If !CDD->(dbSeek(xFilial('CDD') + "E" + aDados[1] + aDados[2] + aDados[3] + aDados[4] + aDados[5] + aDados[6] + aDados[3] + aDados[4]))
		RecLock("CDD", .T.)
		CDD->CDD_FILIAL	:= xFilial("CDD")	
		CDD->CDD_TPMOV	:= "E"	
		CDD->CDD_DOC	  := aDados[1]	
		CDD->CDD_SERIE	:= aDados[2]	
		CDD->CDD_CLIFOR	:= aDados[3]	
		CDD->CDD_LOJA	  := aDados[4]									
		CDD->CDD_PARREF	:= aDados[3]
		CDD->CDD_LOJREF	:= aDados[4]
		CDD->CDD_DOCREF	:= aDados[5]
		CDD->CDD_SERREF	:= aDados[6]
		CDD->CDD_IFCOMP	:= aDados[7]
		CDD->CDD_CHVNFE	:= aDados[9]
		CDD->CDD_ENTSAI	:= aDados[10] //chamado 058730 por Adriana em 30/06/2020
		CDD->(MsUnlock())   
	Else   
		If Empty(CDD->CDD_IFCOMP)
			RecLock("CDD", .F.)
			CDD->CDD_IFCOMP	:= aDados[7]
			CDD->(MsUnlock())   
		EndIf
	EndIf	

Return

/*/{Protheus.doc} atlzCDT
  Atualiza tabela de complemento CDT
	@type  Static Function
  @author  Glauco Oliveira - Eleva
  @since   29/05/2020
  @version 01
	@history Adoro - chamado 052610 
  /*/

Static Function atlzCDT(aDados)

	// Cria/Atualiza CDT
	dbSelectArea('CDT')
	CDT->(dbSetOrder(1)) //CDT_FILIAL+CDT_TPMOV+CDT_DOC+CDT_SERIE+CDT_CLIFOR+CDT_LOJA+CDT_IFCOMP
 
  //Inicio - Chamado TI     - Abel Babini     - 30/07/2020 - O registro C110 apresentou chave duplicada por conta de registros duplicados na tabela CDT
 	If !CDT->(dbSeek(xFilial('CDT') + "E" + aDados[1] + aDados[2] + aDados[3] + aDados[4]+ aDados[7])) 
		RecLock("CDT", .T.)
		CDT->CDT_FILIAL	:= xFilial("CDT")	
		CDT->CDT_TPMOV	:= "E"	
		CDT->CDT_DOC	:= aDados[1]	
		CDT->CDT_SERIE	:= aDados[2]	
		CDT->CDT_CLIFOR	:= aDados[3]	
		CDT->CDT_LOJA	:= aDados[4]
    CDT->CDT_IFCOMP	:= aDados[7]
	  CDT->CDT_DCCOMP	:= aDados[8]
		CDT->(MsUnlock())
	EndIf
  //Fim - Chamado TI     - Abel Babini     - 30/07/2020 - O registro C110 apresentou chave duplicada por conta de registros duplicados na tabela CDT

Return

/*/{Protheus.doc} fChvNfeOri
  Retorna a chave da NF de origem
 	@type  Static Function
  @author  Glauco Oliveira - Eleva
  @since   29/05/2020
  @version 01
	@history Adoro - chamado 052610 
  /*/

Static Function fChvNfeOri(cNFOri, cSerOri, cForn, cLoja)

	Local cChaveNfe		:= ""
	Local cAliasQry		:= GetNextAlias()
	Local cQuery		  := ""

	BeginSQL Alias cAliasQry
		SELECT 
			SF2.F2_CHVNFE CHAVENFE
		FROM 
			%Table:SF2% SF2
		WHERE 
			SF2.F2_FILIAL	= %xFilial:SF2% AND 
			SF2.F2_DOC		= %Exp:cNFOri% AND
			SF2.F2_SERIE	= %Exp:cSerOri% AND
			SF2.F2_CLIENTE	= %Exp:cForn% AND 
			SF2.F2_LOJA		= %Exp:cLoja% AND
			SF2.%notDel%
	EndSQL

	cQuery	:= GetLastQuery()[2]
	ConOut(cQuery)

	dbSelectArea(cAliasQry)
	(cAliasQry)->(DbGoTop())
	If (cAliasQry)->(!Eof())
		cChaveNfe	:= (cAliasQry)->CHAVENFE
	EndIf

Return cChaveNfe

/*/{Protheus.doc} fEmissOri
  Retorna a emissão de origem
 	@type  Static Function
  @author  Glauco Oliveira - Eleva
  @since   29/05/2020
  @version 01
	@history Adoro - chamado 052610 
  /*/

// Static Function fEmissOri(cNFOri, cSerOri, cForn, cLoja)

// 	Local dEmissOri		:= dDataBase
// 	Local cAliasQry		:= GetNextAlias()
// 	Local cQuery		:= ""

// 	BeginSQL Alias cAliasQry
// 		SELECT 
// 			SF2.F2_EMISSAO EMISSAO_ORI
// 		FROM 
// 			%Table:SF2% SF2
// 		WHERE 
// 			SF2.F2_FILIAL	= %xFilial:SF2% AND 
// 			SF2.F2_DOC		= %Exp:cNFOri% AND
// 			SF2.F2_SERIE	= %Exp:cSerOri% AND
// 			SF2.F2_CLIENTE	= %Exp:cForn% AND 
// 			SF2.F2_LOJA		= %Exp:cLoja% AND
// 			SF2.%notDel%
// 	EndSQL

// 	cQuery	:= GetLastQuery()[2]
// 	ConOut(cQuery)

// 	dbSelectArea(cAliasQry)
// 	(cAliasQry)->(DbGoTop())
// 	If (cAliasQry)->(!Eof())
// 		dEmissOri	:= SToD((cAliasQry)->EMISSAO_ORI)
// 	EndIf

// Return dEmissOri

/*/{Protheus.doc} fChgIfComp
  Change do campo Inf. Compl.
	@type  Static Function
  @author  Glauco Oliveira - Eleva
  @since   29/05/2020
	@version 01
	@history Adoro - chamado 052610 
  /*/

Static Function fChgIfComp(cIfComp, cDesc, cDescComp) //chamado 058730 por Adriana em 23/06/2020

	dbSelectArea('CCE')
	CCE->(dbSetOrder(1))
	If CCE->(dbSeek(xFilial('CCE') + cIfComp))
		cDesc	:= CCE->CCE_DESCR
    cDescComp := CCE->CCE_DESCR //chamado 058730 por Adriana em 23/06/2020
	EndIf

Return

/*/{Protheus.doc} fAbTelaCpl
  Verifica se a tela se aberta para atualização/criação do CDD e CDT
	@type  Static Function
  @author  Glauco Oliveira - Eleva
  @since  29/05/2020
	@version 01
	@history Adoro - chamado 052610
  /*/

Static Function fAbTelaCpl(nOpcao, nConfirma)
	
	Local lRet		:= .F.

	dbSelectArea('SD1')
	SD1->(dbSetOrder(1))
	SD1->(dbSeek(xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA))
	While SD1->(!EOF()) .and. xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA == SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA)

    // Chamado 058730 por Adriana em 09/06/2020
    IF IsInCallStack( "U_INTNFEB" )  
      ConOut("MT103FIM com INTNFEB nOpcao="+str(nopcao,1)+" nConfirma="+str(nConfirma,1)+" SD1->D1_NFORI="+SD1->D1_NFORI+" SF1->F1_ESPECIE="+SF1->F1_ESPECIE)
    ENDIF 
    // Fim Chamado 058730 por Adriana em 09/06/2020
    
		If (ALLTRIM(FUNNAME()) = "MATA103"  .OR. IsInCallStack( "U_CENTNFEXM" ) .OR. IsInCallStack( "U_INTNFEB" ))  .and.; // Chamado 058730 por Adriana em 09/06/2020
			(nOpcao == 3 .Or. nOpcao == 4) .And.;
			nConfirma == 1 .And. ;
			!Empty(SD1->D1_NFORI) .and. ; 
      !Alltrim(SF1->F1_ESPECIE) $ Alltrim(GetMV("MV_#C113ES")) // Chamado 058740 por Adriana em 04/06/2020
				lRet	:= .T.
				Exit
		EndIf
		SD1->(DbSkip())
	EndDo

Return lRet

/*/{Protheus.doc} Static Function UpSDASDB()
  Endereça automaticamente os insumos retornados de industrialização
  @type  Static Function
  @author FWNM
  @since 18/10/2021
  @version version
  @param param_name, param_type, param_descr
  @return return_var, return_type, return_description
  @example
  (examples)
  @see (links_or_references)
  @Ticket 62276   - Fer Macieira    - 18/10/2021 - Endereçamento automático - Armazéns de terceiros 70 a 74 - Projeto Industrialização  
/*/
Static Function UpSDASDB()

  Local aCabSDA    := {}
  Local aItSDB     := {}
  Local _aItensSDB := {} 
  Local cLocZAM    := GetMV("MV_#LOCZAM",,"PROD")
  Local aAreaSD1   := SD1->( GetArea() )
  Local aAreaSF1   := SF1->( GetArea() )
  Local aAreaSA2   := SA2->( GetArea() )
  Local nX

  PRIVATE lMsErroAuto := .F.// variável que define que o help deve ser gravado no arquivo de log e que as informações estão vindo à partir da rotina automática.
  Private lMsHelpAuto	:= .T.    // força a gravação das informações de erro em array para manipulação da gravação ao invés de gravar direto no arquivo temporário 
  Private lAutoErrNoFile := .T. 

  /////////////////////////////////
  // PROJETO INDUSTRIALIZAÇÃO 
  /////////////////////////////////

  // @history ticket  11639 	- Fernando Maciei - 19/05/2021 - Projeto - OPS Documento de entrada - Industrialização/Beneficiamento
  If cEmpAnt $ GetMV("MV_#BENEMP",,"01") .and. cFilAnt $ GetMV("MV_#BENFIL",,"02")

    SA2->(dbSetOrder(1))
    If SA2->(dbSeek(FWxFilial("SA2")+SF1->F1_FORNECE+SF1->F1_LOJA))

      If AllTrim(SA2->A2_XTIPO) == '4' // Terceiro

        SD1->( dbGoTop() )
        SD1->( dbsetorder(1) ) // D1_FILIAL, D1_DOC, D1_SERIE, D1_FORNECE, D1_LOJA, D1_COD, D1_ITEM, R_E_C_N_O_, D_E_L_E_T_
        If SD1->( dbSeek(FWxFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA) )

          Do While SD1->(!EOF()) .and. SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA) == SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA)

            If Localiza(SD1->D1_COD)

              SBE->( dbSetOrder(1) ) // BE_FILIAL, BE_LOCAL, BE_LOCALIZ, BE_ESTFIS, R_E_C_N_O_, D_E_L_E_T_
              If SBE->( !dbSeek(FWxFilial("SBE")+SD1->D1_LOCAL+PadR(cLocZAM,TamSX3("BE_LOCALIZ")[1])) )
                RecLock("SBE",.T.)
                  SBE->BE_FILIAL  := FWxFilial("SBE")
                  SBE->BE_LOCAL   := SD1->D1_LOCAL
                  SBE->BE_LOCALIZ := cLocZAM
                  SBE->BE_DESCRIC := "PROJETO INDUSTRIALIZACAO"
                  SBE->BE_STATUS  := "2"
                  SBE->BE_PRIOR   := "001"
                  SBE->BE_DATGER  := msDate()
                SBE->( msUnLock() )
              EndIf
              
              //Cabeçalho com a informação do item e NumSeq que sera endereçado.
              aCabSDA := {{"DA_PRODUTO" , SD1->D1_COD    , Nil},;	  
                          {"DA_NUMSEQ"  , SD1->D1_NUMSEQ , Nil}}

              //Dados do item que será endereçado
              aItSDB := {{"DB_ITEM"	   , "0001"	        , Nil},;                   
                        {"DB_ESTORNO"  , ""	            , Nil},;                   
                        {"DB_LOCALIZ"  , cLocZAM        , Nil},;                   
                        {"DB_DATA"	   , msDate()       , Nil},;                   
                        {"DB_QUANT"    , SD1->D1_QUANT  , Nil}}       

              aAdd(_aItensSDB, aitSDB)

              //Executa o endereçamento do item
              nModAux := nModulo
              nModulo := 4

              aAreaSF1 := SF1->( GetArea() )
              aAreaSD1 := SD1->( GetArea() )
              
              lMSErroAuto := .F.
              MATA265(aCabSDA, _aItensSDB, 3)
              
              RestArea( aAreaSF1 )
              RestArea( aAreaSD1 )

              nModulo := nModAux

              If lMSErroAuto

                u_GrLogZBE( msDate(), TIME(), cUserName,"ENDERECAMENTO AUTOMATICO NO RETORNO DA INDUSTRIALIZACAO NAO REALIZADO - MATA265","CONTROLADORIA","MT103FIM",;
                "NF/SERIE/FORNECE " + SF1->F1_DOC + "/" + SF1->F1_SERIE + "/" + SF1->F1_FORNECE + " PRODUTO/ARMAZEM/ENDERECO " + SD1->D1_COD + "/" + SD1->D1_LOCAL + "/" + cLocZAM, ComputerName(), LogUserName() )

                aLog := GetAutoGrLog()

                //grava as informações de log no arquivo especificado			
                For nX := 1 To Len(aLog)
                  u_GrLogZBE( msDate(), TIME(), cUserName,"ENDERECAMENTO AUTOMATICO NO RETORNO DA INDUSTRIALIZACAO NAO REALIZADO - MATA265","CONTROLADORIA","MT103FIM",;
                  "Linha Error log " + AllTrim(Str(nX)) + " - Erro " + aLog[nX], ComputerName(), LogUserName() )
                Next nX			
                    
                Alert("Endereçamento automático não realizado! Copie e envie a mensagem a seguir para sistemas@adoro.com.br e controladoria@adoro.com.br...")

                lMsErroAuto    := .T. 
                lMsHelpAuto	   := .F. 
                lAutoErrNoFile := .F.

                MostraErro()
                
              Else

                u_GrLogZBE( msDate(), TIME(), cUserName," RETORNO INDUSTRIALIZACAO - ENDERECAMENTO AUTOMATICO","CONTROLADORIA","MT103FIM",;
                "ENDERECAMENTO AUTOMATICO DO RETORNO DA INDUSTRIALIZACAO REALIZADO COM SUCESSO " + SD1->D1_LOCAL + " " + AllTrim(SD1->D1_COD) + " " + SD1->D1_DOC, ComputerName(), LogUserName() )

              Endif
        
              aCabSDA    := {}
              aItSDB     := {}
              _aItensSDB := {} 

            EndIf

            SD1->( dbSkip() )

          EndDo

        EndIf

      EndIf

    EndIf

  EndIf

	//

  RestArea( aAreaSF1 )
  RestArea( aAreaSD1 )
  RestArea( aAreaSA2 )
  
Return

/*/{Protheus.doc} atlSC7Dt
  Atualiza data de de baixa do no pedido de compra.
  Chamado 62250.
  @type  Static Function
  @author user
  @since 15/10/2021
  @version 01
/*/
Static Function atlSC7Dt(cForn, cLj, cDoc, cSerie)
  //StaticCall(MT103FIM,atlSC7Dt,'014769','01','000042477','1  ')
  //Variáveis.
  Local aArea := GetArea()
  Local cUpdt := ""

  //
  cUpdt := ""
  cUpdt += " UPDATE " + RetSqlName("SC7") + " " 
  cUpdt += " SET C7_XDTENTR = D1_DTDIGIT " 
  cUpdt += " FROM  " 
  cUpdt += " " + RetSqlName("SC7") + " AS SC7 " 
  cUpdt += " INNER JOIN " 
  cUpdt += " " + RetSqlName("SD1") + " AS SD1 ON " 
  cUpdt += " C7_FILIAL = D1_FILIAL " 
  cUpdt += " AND C7_NUM = D1_PEDIDO " 
  cUpdt += " AND C7_ITEM = D1_ITEMPC " 
  cUpdt += " WHERE  " 
  cUpdt += " C7_FILIAL = '" + FWxFilial("SC7") + "'  " 
  cUpdt += " AND D1_FORNECE = '" + cForn + "' " 
  cUpdt += " AND D1_LOJA = '" + cLj + "' " 
  cUpdt += " AND D1_DOC = '" + cDoc + "' " 
  cUpdt += " AND D1_SERIE = '" + cSerie + "' "
  cUpdt += " AND SC7.D_E_L_E_T_ = '' " 
  cUpdt += " AND SD1.D_E_L_E_T_ = '' " 

  //
  If TcSQLExec(cUpdt) < 0
    u_GrLogZBE (Date(), Time(), cUserName, " DOCUMENTO ENTRADA ","FISCAL","MT103FIM",;
                "Erro atualiza data de baixa pc " + cForn + cLj + cDoc + cSerie + " " + TCSQLError(),ComputerName(),LogUserName())

  Else
    u_GrLogZBE (Date(), Time(), cUserName, " DOCUMENTO ENTRADA ","FISCAL","MT103FIM",;
                "Atualiza data de baixa pc " + cForn + cLj + cDoc + cSerie,ComputerName(),LogUserName())
    
  EndIf

  //
  RestArea(aArea)

Return Nil
/*/{Protheus.doc} nomeStaticFunction
  (long_description)
  @type  Static Function
  @author FWNM
  @since 01/12/2021
  @version version
  @param param_name, param_type, param_descr
  @return return_var, return_type, return_description
  @example
  (examples)
  @see (links_or_references)
/*/
User Function ChkSDA()

  Local cQuery     := ""
  Local aCabSDA    := {}
  Local aItSDB     := {}
  Local _aItensSDB := {} 
  Local cLocZAM    := GetMV("MV_#LOCZAM",,"PROD")
  Local aAreaAtu   := GetArea()
  Local nX

  PRIVATE lMsErroAuto := .F.// variável que define que o help deve ser gravado no arquivo de log e que as informações estão vindo à partir da rotina automática.
  Private lMsHelpAuto	:= .T.    // força a gravação das informações de erro em array para manipulação da gravação ao invés de gravar direto no arquivo temporário 
  Private lAutoErrNoFile := .T. 

  If Select("Work3") > 0
    Work3->( dbCloseArea() )
  EndIf

  cQuery := " SELECT DA_FILIAL, DA_PRODUTO, DA_SALDO, DA_LOCAL, DA_NUMSEQ, DA_DOC, DA_SERIE, DA_CLIFOR
  cQuery += " FROM " + RetSqlName("SDA") + " SDA (NOLOCK)
  cQuery += " INNER JOIN " + RetSqlName("SA2") + " SA2 (NOLOCK) ON A2_FILIAL='"+FWxFilial("SA2")+"' AND A2_COD=DA_CLIFOR AND A2_LOJA=DA_LOJA AND SA2.D_E_L_E_T_=''
  cQuery += " WHERE DA_FILIAL='"+FWxFilial("SDA")+"' 
  cQuery += " AND DA_LOCAL BETWEEN '70' AND '74'
  cQuery += " AND DA_ORIGEM='SD1'
  cQuery += " AND DA_TIPONF='N'
  cQuery += " AND DA_SALDO>0
  cQuery += " AND SDA.D_E_L_E_T_=''
  cQuery += " AND A2_XTIPO='4'

  tcQuery cQuery New Alias "Work3"

  aTamSX3	:= TamSX3("DA_SALDO")
  tcSetField("Work3", "DA_SALDO", aTamSX3[3], aTamSX3[1], aTamSX3[2])

  Work3->( dbGoTop() )
  Do While Work3->( !EOF() )

    //Cabeçalho com a informação do item e NumSeq que sera endereçado.
    aCabSDA := {{"DA_PRODUTO" , Work3->DA_PRODUTO    , Nil},;	  
                {"DA_NUMSEQ"  , Work3->DA_NUMSEQ , Nil}}

    //Dados do item que será endereçado
    aItSDB := {{"DB_ITEM"	   , "0001"	        , Nil},;                   
              {"DB_ESTORNO"  , ""	            , Nil},;                   
              {"DB_LOCALIZ"  , cLocZAM        , Nil},;                   
              {"DB_DATA"	   , msDate()       , Nil},;                   
              {"DB_QUANT"    , Work3->DA_SALDO  , Nil}}       

    aAdd(_aItensSDB, aitSDB)

    //Executa o endereçamento do item
    nModAux := nModulo
    nModulo := 4

    lMSErroAuto := .F.
    MATA265(aCabSDA, _aItensSDB, 3)
    
    nModulo := nModAux

    If lMSErroAuto

      u_GrLogZBE( msDate(), TIME(), cUserName,"ENDERECAMENTO AUTOMATICO NO RETORNO DA INDUSTRIALIZACAO NAO REALIZADO - MATA265","CONTROLADORIA","CHKSDA",;
      "NF/SERIE/FORNECE " + SDA->DA_DOC + "/" + SDA->DA_SERIE + "/" + SDA->DA_CLIFOR + " PRODUTO/ARMAZEM/ENDERECO " + SDA->DA_PRODUTO + "/" + SDA->DA_LOCAL + "/" + cLocZAM, ComputerName(), LogUserName() )

      aLog := GetAutoGrLog()

      //grava as informações de log no arquivo especificado			
      For nX := 1 To Len(aLog)
        u_GrLogZBE( msDate(), TIME(), cUserName,"ENDERECAMENTO AUTOMATICO NO RETORNO DA INDUSTRIALIZACAO NAO REALIZADO - MATA265","CONTROLADORIA","CHKSDA",;
        "Linha Error log " + AllTrim(Str(nX)) + " - Erro " + aLog[nX], ComputerName(), LogUserName() )
      Next nX			
          
    Endif

    aCabSDA    := {}
    aItSDB     := {}
    _aItensSDB := {} 

    Work3->( dbSkip() )

  EndDo

  If Select("Work3") > 0
    Work3->( dbCloseArea() )
  EndIf

  RestArea( aAreaAtu )

Return
