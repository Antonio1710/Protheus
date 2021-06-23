#Include "Protheus.ch"

//teste de tela....

User Function TabMatriz()

Local cTitulo := "Tabela Matriz"
Local aCpo := {"ZZK_CODIGO","ZZK_REVISA","ZZK_PRODUT","ZZK_DESCRI","ZZK_UNIDAD","ZZK_FOBLIQ"}
Local aTit := {}
Local aDad := {}
Local aPict := {}
Local i := 0
Local nCpo := 0
Local oDlg
Local oLbx
Local aAreaSX3 := {}
Local aAreaZZK := {}
Local oFntLbx := TFont():New("Courier New",6,0)
Local aTam := {}

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Tabela Matriz')

dbSelectArea("SX3")
aAreaSX3 := GetArea()
dbSetOrder(2)

aEval(aCpo,{|x,y| dbSeek(x), ;
                  aAdd(aTit ,AllTrim(SX3->X3_TITULO)), ;
                  aAdd(aPict,AllTrim(SX3->X3_PICTURE)),;
                  aAdd(aTAM ,GetTextWidth( 0, Replicate( ";", 5+Max( TamSX3( x )[1], Len( aPict[y] ) ) ) ) ) } )
RestArea(aAreaSX3)

dbSelectArea("ZZK")
aAreaZZK := GetArea()
dbSetOrder(1)
ZZK->(dbSeek(xFilial("ZZK")))

dbEval({|| aAdd(aDad,Array(Len(aCpo))),;
           aEval(aCpo,{|nX,nI| aDad[Len(aDad),nI] := TransForm(FieldGet(FieldPos(aCpo[nI])),aPict[nI])})},,;
           {|z| !Eof().And.ZZK->ZZK_FILIAL==xFilial("ZZK")})
RestArea(aAreaZZK)

DEFINE MSDIALOG oDlg TITLE cTitulo FROM 0,0 TO 240,500 PIXEL

   //oLbx := TwBrowse():New(13,1,250,108,,aTit,,oDlg,,,,,,,oFntLbx,,,,,.F.,,.T.,,.F.,,,)
   oLbx := TwBrowse():New(0,0,0,0,,aTit,,oDlg,,,,,,,oFntLbx,,,,,.F.,,.T.,,.F.,,,)
   oLbx:Align := CONTROL_ALIGN_ALLCLIENT
   oLbx:SetArray(aDad)
   oLbx:aColSizes := aTam
   oLbx:bLine := {|| aEval( aDad[oLbx:nAt],{|z,w| aDad[oLbx:nAt,w]})}

ACTIVATE MSDIALOG oDlg CENTER ON INIT EnchoiceBar(oDlg,{||oDlg:End()},{||oDlg:End()})

Return