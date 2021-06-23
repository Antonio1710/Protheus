#Include "Totvs.ch"

/*/{Protheus.doc} User Function AF240CLA
  PE executado após a classificação do bem para validações adicionais
  @type  Function
  @author Abel Babini
  @since 22/09/2020
  @history Ticket   0019 - Abel Babini - 22/09/2020 - Permite a controladoria informar a vida útil do bem no momento da classificação e salvar a informação no registro do CIAP
  /*/
User Function AF240CLA()
	Local oDlg1Frm := Nil
	Local oSay1Frm := Nil
	Local oGet1Frm := Nil
	Local oBtn1Frm := Nil
	Local oBtn2Frm := Nil
  Local nGet1Frm := 0
  Local lRet  := .F.

  IF !Empty(ALLTRIM(SN1->N1_CODCIAP))
    If MsgYesNo(OemToAnsi("Deseja informar a vida útil"),OemToAnsi("SPED Fiscal - Reg 0305 - Vida útil"))

      oDlg1Frm := MSDialog():New( 091, 232, 225, 574, "SPED Fiscal - Reg 0305 - Vida útil do bem" ,,, .F.,,,,,, .T.,,, .T. )

      //-> Rótulo. 
      oSay1Frm := TSay():New( 008 ,008 ,{ || "Vida útil do bem em meses:" } ,oDlg1Frm ,,,.F. ,.F. ,.F. ,.T. ,CLR_BLACK ,CLR_WHITE ,084 ,008 )

      //-> Campo.
      @ 020,008 GET oGet1 VAR nGet1Frm SIZE 100,008 OF oDlg1Frm PIXEL PICTURE '@<E 999'

      //-> Botões.
      oBtn1Frm := TButton():New( 040 ,008 ,"Gravar" ,oDlg1Frm ,{ || (lRet := .T.,oDlg1Frm:End())  } ,047 ,012 ,,,,.T. ,,"" ,,,,.F. )
      oBtn2Frm := TButton():New( 040 ,120 ,"Sair sem gravar"     ,oDlg1Frm ,{ || oDlg1Frm:End() } ,047 ,012 ,,,,.T. ,,"" ,,,,.F. )

      //-> Ativação da interface.
      oDlg1Frm:Activate( ,,,.T.)
    ENDIF

    IF lRet .AND. SF9->(MsSeek( xFilial("SF9") + SN1->N1_CODCIAP , .f. ))
      RECLOCK("SF9",.F.)
        SF9->F9_VIDUTIL := nGet1Frm
      SF9->(msUnlock())
    ENDIF
  ENDIF
Return .T.
