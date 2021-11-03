/*/{Protheus.doc} User Function M310ITENS
	Ponto de Entrada para realizar a entrada de informações complementares
    na transferencia entre filiais
	@type  Function 
	@author Andre Mendes - Obify
	@since  28/04/21 
	@version 01
    @history Chamado 8566 	- André Mendes 	- 29/04/2021 - Transferência entre Filiais 
    @history Ticket  16982  - Abel Babini   - 27/07/2021 - Ajuste no armazém padrão de destino
    @history Ticket  16982  - Abel Babini   - 03/08/2021 - Acrescentar aviso para o usuário sobre o armazém de destino padrão.
/*/
User Function M310ITENS
    Local cPrograma:=PARAMIXB[1]
    Local aItens   :=PARAMIXB[2]
    Local lRet
    Local aCpos := {}
    //Ticket  16982  - Abel Babini   - 27/07/2021 - Ajuste no armazém padrão de destino
    Local i := 0
    Local j := 0
    Local cLocPad := ''

    If cPrograma $ "MATA140,MATA103" // Pedido de venda
    // ARRAY AITENS (PADRAO DAS ROTINAS AUTOMATICAS)
    // [1]       ITEM 1
    // [1][1]    CAMPO 1 DO ITEM 1
    // [1][1][1] NOME DO CAMPO
    // [1][1][2] CONTEUDO DO CAMPO
    // [1][1][3] VALIDACAO A SER UTILIZADA

    // Exemplo MUDANDO ARMAZEM
        aCpos:={"D1_CC","D1_ITEMCTA"}
        // aItens
        lRet := fGetCps(@aItens, aCpos, cPrograma)
        //INICIO Ticket  16982  - Abel Babini   - 27/07/2021 - Ajuste no armazém padrão de destino
        for i:=1 to Len(aItens)
            for j:=1 to Len(aItens[i])
                if Alltrim(aItens[i][j][1]) == 'D1_COD'
                    dbSelectArea("SBZ")
                    SBZ->(dbSetOrder(1))
                    if SBZ->(dbSeek(cFilAnt+Alltrim(aItens[i][j][2])))
                        cLocPad := SBZ->BZ_LOCPAD
                    endif
                    exit
                endif
            next j
        next i
        if cLocPad <> ''
            for i:=1 to Len(aItens)
                for j:=1 to Len(aItens[i])
                    //Ticket  16982  - Abel Babini   - 03/08/2021 - Acrescentar aviso para o usuário sobre o armazém de destino padrão.
                    if Alltrim(aItens[i][j][1]) == 'D1_LOCAL' .AND. Alltrim(aItens[i][j][2]) <> Alltrim(cLocPad)
                        Aviso(	"M310ITENS-01",;
						"Armazém de destino alterado conf. Indicador de Produtos (SBZ) para : " + Alltrim(cLocPad) + "." + Chr(13) + Chr(10) +;
						"Armazém substituído: " + Alltrim(aItens[i][j][2]) + ".",;
						{ "&Retorna" },,;
						"Aviso Controladoria" )
                        aItens[i][j][2]:=cLocPad
                        exit
                    endif
                next j
            next i
        endif
        //FIM Ticket  16982  - Abel Babini   - 27/07/2021 - Ajuste no armazém padrão de destino
    ElseIf cPrograma $ "MATA410"
        If MsgYesNo("Deseja informar Lote x CC para os itens do pedido de venda?", "Lote x CC")
            aCpos:={"C6_XLOTECC"}
            
            lRet := fGetCps(@aItens, aCpos, cPrograma)
        Endif
    EndIf
RETURN aItens



Static Function fGetCps(aItens, aCpos, cPrograma)
Local aArea := GetArea()

Local nX := 0
//Local nTamAc := 0
//Local nDel := 0
Local nOpc := 0
Local oDlg, oGetD1
Local lRet := .F.
Local nz
Local nC
Local aAlter
Local aHTab := {}

If Empty(aHTab)
	
    aAlter := aClone(aCpos)
    For nx:=1 to Len(aItens)
        For nz:=1 to Len(aItens[nx])
            aAdd(aCpos,aItens[nx,nz,1])
         
        Next nz
    Next nx

	aHTab:={}
	aCTab:={}
	DbSelectArea("SX3")
	DbSetOrder(2)
	For nX:=1 To Len(aCpos)
		If MsSeek(aCpos[nX])
			If (X3USO(SX3->X3_USADO) .AND. cNivel >= SX3->X3_NIVEL )
				Aadd(aHTab,{AllTrim(X3Titulo()),;
								SX3->X3_CAMPO,;
								SX3->X3_PICTURE,;
								SX3->X3_TAMANHO,;
								SX3->X3_DECIMAL,;
								SX3->X3_VALID,;
								SX3->X3_USADO,;
								SX3->X3_TIPO,;
								SX3->X3_F3,;
								SX3->X3_CONTEXT,;
								X3CBOX(),;
								SX3->X3_RELACAO,;
								".T."})
			EndIf
		Endif
	Next
    For nz:= 1 To Len(aItens)
        Aadd(aCTab,Array(Len(aHTab)+1))
        For nX:=1 To Len(aHTab)
            nC := aScan( aItens[nz],{ | x | x[01] == Alltrim(aHTab[nX][2])  }) 
            If  nC > 0
                aCTab[nz][nX]:= aItens[nz][nC][02]
            Else
                aCTab[nz][nX]:=Criavar(aHTab[nX][2])
            Endif
        Next
        aCTab[1][Len(aCTab[1])]:=.F.
    Next nz
Endif

DEFINE MSDIALOG oDlg TITLE "Informar Campos Complementares - Itens "+cPrograma From 0,0 To 400,400 Of oMainWnd Pixel
	oGetD1 := MsNewGetDados():New(050,030,175,175,GD_UPDATE,,"AllwaysTrue()" ,,aAlter,/*freeze*/,,/*fieldok*/,/*superdel*/,/*delok*/,oDlg,@aHTab,@aCTab)
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||aCTab:=oGetD1:aCols,nOpc:=1,oDlg:End()},{||nOpc:=0,oDlg:End()}) CENTERED

lRet:=(nOpc==1)
If nOpc==1

    For nX := 1 To Len(aAlter)
        nC := aScan(aHTab, { |x| Alltrim(x[2]) ==  Alltrim(aAlter[nX])  })
        If nC >0
            for nz := 1 to Len(aCTab)
                aAdd(aItens[nz], {aAlter[nX]	,aCTab[nz][nC],Nil} )
                
            next


        Endif
    Next nX

/*
	nOpc:=Len(aCTab)
	nLenAc:=Len(aCTab[1])
	nDel:=0
	For nX:=nOpc To 1 Step -1
		If aCTab[nX][nLenAc]
			nDel++
			Adel(aCTab,nX)
		Endif
	Next
	If nDel>0
		aCTab:=aSize(aCTab,nOpc-nDel)
	Endif
    */
Endif

RestArea(aArea)
Return(lRet)
