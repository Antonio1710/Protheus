#Include "RwMake.ch"
#Include "Protheus.ch"
#Include "Topconn.ch"
#Include "TbiConn.ch"
#Include "TbiCode.ch"

/*/{Protheus.doc} User Function ADFAT041P
	Faturamento de pedidos gerados pelo controle de pátio. 
    Chamado 18465.
	@type  Function
	@author Everson
	@since 11/03/2022
	@version 01
	@history Everson, 27/05/2022. Ticket 18465. Tratamento para não faturar pedido com bloqueio de corte.
/*/
User Function ADFAT041P()

	//Variáveis.
	Local aArea		:= GetArea()
	Local  oFechar	:= Nil
	
	Private oInterface		:= Nil
	Private aAltInterface	:= {}
	Private aHInterface		:= {}
	Private aColsInterface	:= {}
	Private oRegistros		:= Nil
	Private oQtdReg			:= Nil
	Private nQtdReg			:= 0
	Private cBusca 			:= Space(TamSX3("C5_NUM")[1])
	Private oBtnBusca		:= Nil
	Private dDataIni		:= dDataBase
	Private oDataIni		:= Nil
	
	oInterface:= MsDialog():Create()
	oInterface:cName     := "oInterface"
	oInterface:cCaption  := "Pedidos de Saída"
	oInterface:nLeft     := 34
	oInterface:nTop      := 222
	oInterface:nWidth    := 1100
	oInterface:nHeight   := 460
	oInterface:lShowHint := .F.
	oInterface:lCentered := .T.

		oDataIni := TGet():New(005,004,{|u|If(PCount() == 0,dDataIni,dDataIni := u)},oInterface,050,010,"@D",,0,16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"dDataIni",,,,.T.,,,"Data Início",1) 
		oDataIni:bChange := {|| MsAguarde({|| pendenciaNF() },"Aguarde","Carregando registros...") }
        TButton():New( 012, 059, "Atualizar", oInterface,{|| MsAguarde({|| pendenciaNF() },"Aguarde","Carregando registros...") }, 40,12,,,.F.,.T.,.F.,,.F.,,,.F. )
        TButton():New( 012, 104, "Legenda"  , oInterface,{|| lngProth() }, 40,12,,,.F.,.T.,.F.,,.F.,,,.F. )
		
        TButton():New( 042, 004, "Lib. Estoque"    , oInterface,{|| MsAguarde({|| xLibEst() },"Aguarde","Acessando rotina Lib. Estoque...") }, 40,12,,,.F.,.T.,.F.,,.F.,,,.F. )
        TButton():New( 042, 049, "Emitir NF"       , oInterface,{|| MsAguarde({|| emitNfGrp( oRegistros:aCols[oRegistros:nat][Ascan(aHInterface,{|x| AllTrim(x[2]) == "PED"})] )  },"Aguarde","Acessando rotina Emissão de NF...") }, 40,12,,,.F.,.T.,.F.,,.F.,,,.F. )
        TButton():New( 042, 094, "SPED"            , oInterface,{|| MsAguarde({|| SPEDNFe()    },"Aguarde","Acessando rotina SPEDNFe..."), MsAguarde({|| pendenciaNF() },"Aguarde","Carregando registros...") }, 40,12,,,.F.,.T.,.F.,,.F.,,,.F. )
        TButton():New( 042, 139, "Boleto"          , oInterface,{|| MsAguarde({|| U_HCRFIBLT() },"Aguarde","Acessando Emissão de Boleto..."), MsAguarde({|| pendenciaNF() },"Aguarde","Carregando registros...") }, 40,12,,,.F.,.T.,.F.,,.F.,,,.F. )
        TButton():New( 042, 184, "Imprimir NF"     , oInterface,{|| MsAguarde({|| imprimeNF("","") },"Aguarde","Acessando Impressão de NF...") }, 40,12,,,.F.,.T.,.F.,,.F.,,,.F. )
        
        TButton():New( 042, 249, "Visualizar Ped." , oInterface,{|| MsAguarde({|| visualPed(oRegistros:aCols[oRegistros:nat][Ascan(aHInterface,{|x| AllTrim(x[2]) == "PED"})])  },"Aguarde","Acessando pedido " + Alltrim(cValToChar(oRegistros:aCols[oRegistros:nat][Ascan(aHInterface,{|x| AllTrim(x[2]) == "PED"})])) + "...") }, 40,12,,,.F.,.T.,.F.,,.F.,,,.F. )
        TButton():New( 042, 294, "Excluir Ped."    , oInterface,{|| MsAguarde({|| exclPedido( oRegistros:aCols[oRegistros:nat][Ascan(aHInterface,{|x| AllTrim(x[2]) == "PED"})] ) },"Aguarde","Excluindo pedido..."), MsAguarde({|| pendenciaNF() },"Aguarde","Carregando registros...") }, 40,12,,,.F.,.T.,.F.,,.F.,,,.F. )
        TButton():New( 042, 339, "Cort. Man."      , oInterface,{|| MsAguarde({|| corteMan() },"Aguarde","Acessando corte manual de produtos..."), MsAguarde({|| pendenciaNF() },"Aguarde","Carregando registros...") }, 40,12,,,.F.,.T.,.F.,,.F.,,,.F. )
        
        TGet():New(035,474,{|u|If(PCount() == 0,cBusca,cBusca := u)},oInterface,050,010,"@C",,0,16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cBusca",,,,.T.,,,"Pedido",1) 
		oBtnBusca := TButton():New(042,525,"Ok",oInterface,,20,12,,,.F.,.T.,.F.,,.F.,,,.F. )
		oBtnBusca:bAction := {||;
		 						nBusca := Iif( nQtdReg <= 0, 0, Ascan(oRegistros:aCols,{|x| AllTrim(Upper(cBusca))$Upper(x[3])}) ),;
								Iif( nBusca > 0,Eval({||oRegistros:ForceRefresh(),oRegistros:GoTo(nBusca),oRegistros:Refresh()} ),;
								MsgAlert("Não foi possível localizar o registro","Função ADFAT041P"));
							 } 

		TGroup():Create(oInterface,162,433,185,545,"",,,.T.)
		
		oQtdReg := TGet():New(170,438, { | u | If( PCount() == 0, nQtdReg, nQtdReg := u ) },oInterface, ;
	    		   060, 010, "@E 999,999,999",, 0, 16777215,,.F.,,.T.,,.F.,{|| .F. },.F.,.F.,,.F.,.F. ,,"nQtdReg",,,,.F.,,,"Total de registros:",2,)
	
		Aadd(aHInterface,{" ","LEG"    	  ,"@BMP"    ,01     , 00,.T.,"","","","R","","",.F.,"V","","","",""})
		Aadd(aHInterface,{"DT Emissão"    ,"DTEMIS"	 ,""	 , 10,0,"","" ,"C","",""})
		Aadd(aHInterface,{"Ord Pesagem"   ,"ORDPES"  ,""	 , 12,0,"","" ,"C","",""})
		Aadd(aHInterface,{"Pedido"        ,"PED"     ,""	 , 12,0,"","" ,"C","",""})
		Aadd(aHInterface,{"Placa"         ,"PLC"     ,""	 , 07,0,"","" ,"C","",""})
		Aadd(aHInterface,{"Granja"        ,"GRJ"     ,""	 , 06,0,"","" ,"C","",""})
		Aadd(aHInterface,{"Qtd"           ,"QTD"     ,"@E 999,999,999.999999"	 , 18,6,"","" ,"N","",""})
		Aadd(aHInterface,{"Bloq Corte"    ,"BLQC"    ,""	 , 03,0,"","" ,"C","",""})
		Aadd(aHInterface,{"Bloq Est"      ,"BLEST"   ,""	 , 03,0,"","" ,"C","",""})
		Aadd(aHInterface,{"Bloq Fin"      ,"BLFIN"   ,""	 , 03,0,"","" ,"C","",""})
		Aadd(aHInterface,{"Operação"  	  ,"OPER"	 ,""	 , 10,0,"","" ,"C","",""})
		Aadd(aHInterface,{"Status Op"  	  ,"STOPER"	 ,""	 , 01,0,"","" ,"C","",""})
		Aadd(aHInterface,{"Cliente"       ,"CLI"     ,""	 , 06,0,"","" ,"C","",""})
		Aadd(aHInterface,{"Loja"          ,"LOJ"     ,""	 , 02,0,"","" ,"C","",""})
		Aadd(aHInterface,{"Nome"          ,"NOM"     ,""	 , 40,0,"","" ,"C","",""})
		Aadd(aHInterface,{"Tipo Ped"      ,"TPPED"   ,""	 , 01,0,"","" ,"C","",""})
		Aadd(aHInterface,{"Tipo Frete"    ,"TPFRT"   ,""	 , 07,0,"","" ,"C","",""})
		Aadd(aHInterface,{"Transp"    	  ,"TRANS"   ,""	 , 06,0,"","" ,"C","",""})
		Aadd(aHInterface,{"UF Placa"      ,"UFPLC"   ,""	 , 02,0,"","" ,"C","",""})
		Aadd(aHInterface,{"Granjada"      ,"GRJD"    ,""	 , 04,0,"","" ,"C","",""})
		Aadd(aHInterface,{"Valor"         ,"VLR"     ,"@E 999,999,999.999999"	 , 18,6,"","" ,"N","",""})
		
		oRegistros := MsNewGetDados():New(057,004,165,545,,"Allwaystrue()","Allwaystrue()","",aAltInterface,Nil,999,Nil,Nil,Nil,oInterface,aHInterface,@aColsInterface)
		
        TGroup():Create(oInterface,190,004,210,545,"",,,.T.)

            oFechar := TButton():New(195,500,"Fechar", oInterface,{|| oInterface:End() },040,010,,,.F.,.T.,.F.,,.F.,,,.F. )
            oFechar:SetCss("QPushButton{background-color: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1, stop: 0 #FF0000, stop: 1 #8C1717);color: white}")		
            
	oInterface:Activate(,,,.T.,{||.T.},,{|| MsAguarde({|| pendenciaNF() },"Aguarde","Carregando registros...") })
	
	RestArea(aArea)

Return Nil
/*/{Protheus.doc} pendenciaNF
	Carregar dados de pedidos importados, mas não faturados
	@type  Static Function
	@author Everson
	@since 11/03/2022
	@version 01
/*/
Static Function pendenciaNF()

	//Variáveis.
	Local aArea		:= GetArea()
	Local cQuery	:= ""
	Local nTotReg	:= 0
	Local cOrdPes	:= ""
	Local cNome		:= ""
	Local oVermelho := LoadBitmap( GetResources(), "BR_VERMELHO")
	Local oVerde 	:= LoadBitmap( GetResources(), "BR_VERDE")
	Local oAmarelo  := LoadBitmap( GetResources(), "BR_AMARELO")
	Local oAzul		:= LoadBitmap( GetResources(), "BR_AZUL")
	Local oLaranja 	:= LoadBitmap( GetResources(), "BR_LARANJA")

	nQtdReg := 0
	oQtdReg:Refresh()
	
	oRegistros:aCols := {}
	oRegistros:Refresh()
	
    cQuery += " SELECT  " 
        cQuery += " C5_EMISSAO, C5_FILIAL, C5_NUM, C5_XORDPES, C5_CLIENTE, C5_LOJACLI, "
        cQuery += " C5_TIPO, C5_PLACA, C5_GRANJA, C5_GRANJDA, C5_LIBEROK, C5_NOTA, C5_BLQ, " 
        cQuery += " SUM(C6_QTDVEN) AS C6_QTDVEN, SUM(C6_VALOR) AS C6_VALOR, C5_TRANSP, C5_TPFRETE, C5_UFPLACA, C5_PEDSAG, C5_XLIBSAG, C5_NOTA, C5_SERIE " 
    
    cQuery += " FROM " 
        cQuery += " " + RetSqlName("SC5") + " AS SC5 " 
        cQuery += " INNER JOIN " 
        cQuery += "  " + RetSqlName("SC6") + "  AS SC6 " 
        cQuery += " ON C5_FILIAL = C6_FILIAL " 
        cQuery += " AND C5_NUM = C6_NUM " 

        cQuery += " WHERE " 
            cQuery += " C5_FILIAL = '" + FWxFilial("SC5") + "' " 
            cQuery += " AND C5_EMISSAO >= '" + DToS(dDataIni) + "' " 
            cQuery += " AND C5_NOTA = '' " 
            cQuery += " AND ( C5_XORDPES <> '' OR  C6_XORDPES <> '' ) AND C5_PEDSAG = '' " 
            cQuery += " AND SC5.D_E_L_E_T_ = '' " 
            cQuery += " AND SC6.D_E_L_E_T_ ='' " 

    cQuery += " GROUP BY " 
        cQuery += " C5_EMISSAO,C5_FILIAL, C5_NUM, C5_XORDPES, C5_CLIENTE,C5_LIBEROK, C5_NOTA, C5_BLQ, C5_TRANSP, C5_TPFRETE, C5_UFPLACA, " 
        cQuery += " C5_LOJACLI, C5_TIPO, C5_PLACA, C5_GRANJA, C5_GRANJDA, C5_PEDSAG, C5_XLIBSAG, C5_NOTA, C5_SERIE "

    cQuery += " ORDER BY C5_NUM DESC " 
    
    If Select("PED_NF") > 0
        PED_NF->(DbCloseArea())
        
    EndIf
    
    MsAguarde({||DbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), "PED_NF", .F., .T.)},"Função pendenciaNF(ADFAT041P)","Carregando registros...")
    
    DbSelectArea("PED_NF")
    PED_NF->(DbGoTop())
    
    nTotReg := Contar("PED_NF","!EOF()")

    ProcRegua(nTotReg)

    If nTotReg <= 0
        fRegLin()
        
    Else
        
        PED_NF->(DbGoTop())
        While ! PED_NF->(Eof())
            
            IncProc("Pedido | " + Alltrim(cValToChar(PED_NF->C5_NUM)))
            
            If Alltrim(cValToChar(PED_NF->C5_TIPO)) $("B|D")
                cNome	:=  Posicione("SA2",1,FWxFilial("SA2") + Alltrim(cValToChar(PED_NF->C5_CLIENTE)) + Alltrim(cValToChar(PED_NF->C5_LOJACLI)),"A2_NOME")
                
            Else
                cNome	:=  Posicione("SA1",1,FWxFilial("SA1") + Alltrim(cValToChar(PED_NF->C5_CLIENTE)) + Alltrim(cValToChar(PED_NF->C5_LOJACLI)),"A1_NOME")
                
            EndIf

			cOrdPes := Alltrim(cValToChar(PED_NF->C5_XORDPES))

			If Empty(cOrdPes)
				cOrdPes := getOrdSa(PED_NF->C5_NUM)

			EndIf

            Aadd(oRegistros:aCols , Array(Len(aHInterface)+1) )
            oRegistros:aCols[Len(oRegistros:aCols), Len(oRegistros:aCols[1]) ] := .F.
            oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "DTEMIS"})] 	   := DToC(SToD(Alltrim(cValToChar(PED_NF->C5_EMISSAO))))
            oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "OPER"  })]     := "-"
            oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "STOPER"})]     := "-"
            oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "CLI"   })]     := Alltrim(cValToChar(PED_NF->C5_CLIENTE))
            oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "LOJ"   })]     := Alltrim(cValToChar(PED_NF->C5_LOJACLI))
            oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "NOM"   })] 	   := Alltrim(cValToChar(cNome))
            oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "ORDPES"})]     := cOrdPes
            oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "PED"   })]     := Alltrim(cValToChar(PED_NF->C5_NUM))
            oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "BLQC"})]       := Iif(Alltrim(cValToChar(PED_NF->C5_XLIBSAG)) == "1","Sim","Não")
            oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "BLEST"})]      := Iif(blqCrEst(Alltrim(cValToChar(PED_NF->C5_NUM)),1),"Sim","Não")
            oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "BLFIN"})]      := Iif(blqCrEst(Alltrim(cValToChar(PED_NF->C5_NUM)),2),"Sim","Não")
            oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "TPPED" })]     := Alltrim(cValToChar(PED_NF->C5_TIPO))
            oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "TRANS"})]      := Alltrim(cValToChar(PED_NF->C5_TRANSP))
            oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "TPFRT"})]      := Alltrim(cValToChar(PED_NF->C5_TPFRETE))
            oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "PLC"   })]     := Alltrim(cValToChar(PED_NF->C5_PLACA))
            oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "UFPLC"})]      := Alltrim(cValToChar(PED_NF->C5_UFPLACA))
            oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "GRJ"   })]     := Alltrim(cValToChar(PED_NF->C5_GRANJA))
            oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "GRJD"  })]     := Alltrim(cValToChar(PED_NF->C5_GRANJDA))
            oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "VLR"   })]     := Val(cValToChar(PED_NF->C6_VALOR))
            oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "QTD"   })]     := Val(cValToChar(PED_NF->C6_QTDVEN))

            If Empty(C5_LIBEROK).And.Empty(C5_NOTA) .And. Empty(C5_BLQ) //Pedido aberto.
                oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "LEG"   })]	:= oVerde
                
            ElseIf ! Empty(C5_NOTA).Or.C5_LIBEROK=='E' .And. Empty(C5_BLQ) //Pedido encerrado.
                oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "LEG"   })]	:= oVermelho
                
            ElseIf ! Empty(C5_LIBEROK).And.Empty(C5_NOTA).And. Empty(C5_BLQ) //Pedido aprovado.
                oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "LEG"   })]	:= oAmarelo
                
            ElseIf C5_BLQ == '1' //Bloqueado por regra.
                oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "LEG"   })]	:= oAzul
            
            ElseIf C5_BLQ == '2' //Bloqueado por verba.
                oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "LEG"   })]	:= oLaranja
                
            EndIf

            PED_NF->(DbSkip())
            nQtdReg++
            
        End
    
    EndIf
    
    PED_NF->(DbCloseArea())
	
	oRegistros:Refresh()
	oQtdReg:Refresh()
	
	RestArea(aArea)
	
Return Nil
/*/{Protheus.doc} getPedSa
    Obtém pedidos de saída vinculados a ordem de pesagem.
    @type  Static Function
    @author Everson
    @since 14/03/2022
    @version 01
/*/
Static Function getOrdSa(cPedS)

    //Variáveis.
    Local aArea     := GetArea()
    Local cOrdens   := ""

	DbSelectArea("SC6")
	SC6->(DbSetOrder(1))
	SC6->(DbGoTop())

	If SC6->(DbSeek( FWxFilial("SC6") + cPedS ))

		While ! SC6->(Eof()) .And. SC6->C6_FILIAL == FWxFilial("SC6") .And. SC6->C6_NUM == cPedS

			If ! ( SC6->C6_XORDPES $cOrdens)

				If Empty(cOrdens)
					cOrdens += SC6->C6_XORDPES 

				Else
					cOrdens += ", " + SC6->C6_XORDPES

				EndIf

			EndIf

			SC6->(DbSkip())

		End

	EndIf

    RestArea(aArea)

Return cOrdens
/*/{Protheus.doc} fRegLin
	Gera linha sem dados para o objeto MsNewGetDados.
	@type  Static Function
	@author Everson
	@since 11/03/2022
	@version 01
/*/
Static function fRegLin()

    //Variáveis.

	oRegistros:aCols := {}

	Aadd(oRegistros:aCols , Array(Len(aHInterface)+1) )
	oRegistros:aCols[Len(oRegistros:aCols), Len(oRegistros:aCols[1]) ] := .F.
	oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "DTEMIS"	})]  := ""
	oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "OPER"  	})]  := ""
	oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "STOPER"	})]  := ""
	oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "CLI"   	})]  := ""
	oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "LOJ"   	})]  := ""
	oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "NOM"   	})]  := ""
	oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "ORDPES" })]	 := ""
	oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "PED"   	})]  := ""
	oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "BLQC"	})]  := ""
	oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "BLEST"	})]  := ""
	oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "BLFIN"	})]  := ""
	oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "TPPED" 	})]  := ""
	oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "TRANS"	})]  := ""
	oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "TPFRT"	})]  := ""
	oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "PLC"   	})]  := ""
	oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "UFPLC"	})]  := ""
	oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "GRJ"   	})]  := ""
	oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "GRJD"  	})]  := ""
	oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "VLR"   	})]  := 0
	oRegistros:aCols[Len(oRegistros:aCols),Ascan(aHInterface,{|x| AllTrim(x[2]) == "QTD"   	})]  := 0

	oRegistros:Refresh()

Return Nil
/*/{Protheus.doc} exclPedido
	Exclusão de pedido de venda.Chamado 033511.
	@type  Static Function
	@author Everson
	@since 11/03/2022
	@version 01
/*/
Static Function exclPedido(cNum)

	//Variáveis.
	Local aArea		:= GetArea()
	Local lRet		:= .F.	
	
	If ! MsgYesNo("Deseja excluir o pedido de venda " + cNum + ".","Função exclPedido(ADFAT041P)")
		RestArea(aArea)
		Return .F.
	
	EndIf
	
	If uExcPedB(cNum)
		lRet := .T.
		MsgInfo("Pedido " + cNum + " excluído.","Função exclPedido(ADFAT041P)")
		
	Else
		MsgStop("Pedido " + cNum + " não excluído.","Função exclPedido(ADFAT041P)")
		
	EndIf

	RestArea(aArea)
	
Return lRet
/*/{Protheus.doc} corteMan
	Rotina para corte manual de produtos.
	@type  Static Function
	@author Everson
	@since 23/03/2022
	@version 01
/*/
Static Function corteMan()

	//Variáveis.
	Local aArea		:= GetArea()	
	
	MsAguarde({|| ajtBlPed() },"Aguarde","Verificando bloqueio de pedido...")
	
	MsAguarde({|| MATA455() },"Aguarde","Acessando rotina lib estoque...")

	RestArea(aArea)
	
Return Nil
/*/{Protheus.doc} ajtBlPed
	Rotina para verificação de bloqueio de pedido por corte.
	@type  Static Function
	@author Everson
	@since 23/03/2022
	@version 01
/*/
Static Function ajtBlPed()

	//Variáveis.
	Local aArea		:= GetArea()
	Local cQuery	:= ""
	Local lAux		:= .F.	
	Local cProdutos	:= GetMv("MV_#PDLIBC")
	Local cFil		:= ""
	Local cNum		:= ""
	Local nRec		:= 0

	cQuery += " SELECT  " 
	cQuery += " DISTINCT C5_FILIAL, C5_NUM, SC5.R_E_C_N_O_ AS REC  "

    cQuery += " FROM " 
        cQuery += " " + RetSqlName("SC5") + " AS SC5 " 
        cQuery += " INNER JOIN " 
        cQuery += "  " + RetSqlName("SC6") + "  AS SC6 " 
        cQuery += " ON C5_FILIAL = C6_FILIAL " 
        cQuery += " AND C5_NUM = C6_NUM " 

        cQuery += " WHERE " 
            cQuery += " C5_FILIAL = '" + FWxFilial("SC5") + "' " 
            cQuery += " AND C5_EMISSAO >= '" + DToS(dDataIni) + "' " 
            cQuery += " AND C5_NOTA = '' " 
			cQuery += " AND C5_XLIBSAG = '1' " 
            cQuery += " AND ( C5_XORDPES <> '' OR  C6_XORDPES <> '' ) AND C5_PEDSAG = '' " 
            cQuery += " AND SC5.D_E_L_E_T_ = '' " 
            cQuery += " AND SC6.D_E_L_E_T_ ='' " 

    cQuery += " ORDER BY C5_NUM DESC " 
	
	If Select("CK_BQL") > 0
		CK_BQL->(DbCloseArea())
		
	EndIf
	
	TcQuery cQuery New Alias "CK_BQL"
	DbSelectArea("CK_BQL")
	CK_BQL->(DbGoTop())
	While ! CK_BQL->(Eof())
		
		cFil    := Alltrim(cValToChar(CK_BQL->C5_FILIAL))
		cNum	:= Alltrim(cValToChar(CK_BQL->C5_NUM))
		nRec	:= Val(cValToChar(CK_BQL->REC))
		
		DbSelectArea("SC6")
		SC6->(DbSetOrder(1))
		SC6->(DbGoTop())
		
		lAux := .F.
		If SC6->(DbSeek(cFil + cNum))
		
			While ! SC6->(Eof()) .And. Alltrim(cValToChar(SC6->C6_FILIAL)) == cFil .And. Alltrim(cValToChar(SC6->C6_NUM)) == cNum
				
				If Alltrim(cValToChar(SC6->C6_PRODUTO)) $cProdutos
					
					Reclock("SC6",.F.)
						Replace C6_XLIBSAG With "2"
					MsUnlock()
				
				ElseIf ! (Alltrim(cValToChar(SC6->C6_PRODUTO)) $cProdutos) .And. SC6->C6_XLIBSAG = '1'
					lAux := .T.
					
				EndIf
				
				SC6->(DbSkip())
				
			End
			
		EndIf
		
		If ! lAux .And. nRec > 0
			
			DbSelectArea("SC5")
			SC5->(DbSetOrder(1))
			SC5->(DbGoTop())
			SC5->(DbGoTo(nRec))
			
			Reclock("SC5",.F.)
				Replace C5_XLIBSAG With "2"
			MsUnlock()		
		
		EndIf
	
		CK_BQL->(DbSkip())
		
	End
	
	RestArea(aArea)
	
Return Nil
/*/{Protheus.doc} lngProth
	Lengenda de pedidos. Chamado 033511.
	@type  Static Function
	@author Everson
	@since 11/03/2022
	@version 01
/*/
Static Function lngProth()

    //Variáveis.
    Local cTitulo := "Status pedido"
    Local aLegenda:= {}
     
    Aadd(aLegenda, {"BR_VERDE"    ,"Pedido em aberto"})
    Aadd(aLegenda, {"BR_VERMELHO" ,"Pedido encerrado"})
    Aadd(aLegenda, {"BR_AMARELO"  ,"Pedido liberado" })
    Aadd(aLegenda, {"BR_AZUL"     ,"Pedido bloqueado por regra"})
    Aadd(aLegenda, {"BR_LARANJA"  ,"Pedido bloqueado por verba" })
     
    BrwLegenda("Legenda do Browse",cTitulo,aLegenda)

Return Nil
/*/{Protheus.doc} blqCrEst
	Status pedido.
	@type  Static Function
	@author Everson
	@since 11/03/2022
	@version 01
/*/
Static Function blqCrEst(cNum, nOpc)

	//Variáveis.
	Local aArea		:= GetArea()
	Local lRet		:= .F.
		
	If nOpc == 1
		cQuery := " SELECT C9_BLEST AS CAMPO FROM " + RetSqlName("SC9") + " AS SC9 WHERE SC9.D_E_L_E_T_ = '' AND C9_FILIAL = '" + cFilAnt + "' AND C9_PEDIDO = '" + cNum + "' "
	
	Else
		cQuery := " SELECT C9_BLCRED AS CAMPO FROM " + RetSqlName("SC9") + " AS SC9 WHERE SC9.D_E_L_E_T_ = '' AND C9_FILIAL = '"+ cFilAnt + "' AND C9_PEDIDO = '" + cNum + "' "
	
	EndIf

	If Select("BL_PED") > 0
		BL_PED->(DbCloseArea())
		
	EndIf
	
	TcQuery cQuery New Alias "BL_PED"
	BL_PED->(DbGoTop())
	
	If BL_PED->(Eof())
		
		lRet := .T.
		
	Else
	
		While ! BL_PED->(Eof())
	
			If ! Empty(Alltrim(cValToChar(BL_PED->CAMPO)))
				lRet := .T.
				Exit
				
			EndIf
			
			
			BL_PED->(DbSkip())
		
		End
	
	EndIf

	RestArea(aArea)
	
Return lRet
/*/{Protheus.doc} uExcPedB
	Realiza exclusão do pedido de venda.
	@type  Static Function
	@author Everson
	@since 11/03/2022
	@version 01
/*/
Static Function uExcPedB(cNum)
	
	//Variáveis.
	Local aArea	 	:= GetArea()
	Local lRet		:= .F.
	Local aCabec 	:= {}
    Local aLinha    := ""
	Local aItens 	:= {}
	
	Private nVlrCred	:= 0
	Private lMsErroAuto := .F.
	
	DbSelectArea("SC5")
	SC5->(DbSetOrder(1))
	SC5->(DbGoTop())
	If ! SC5->(DbSeek( FWxFilial("SC5") + cNum ))
		MsgStop("Não foi possivel localizar o pedido " + cNum + " na tabela SC5.","Função uExcPedB(ADFAT041P)")
		RestArea(aArea)
		Return .F.
		
	EndIf
	
	DbSelectArea("SC6")
	SC6->(DbSetOrder(1))
	SC6->(DbGoTop())
	If ! SC6->(DbSeek( FWxFilial("SC6") + cNum ))
		MsgStop("Não foi possivel localizar o pedido " + cNum + " na tabela SC6.","Função uExcPedB(ADFAT041P)")
		RestArea(aArea)
		Return .F.
			
	EndIf

	DbSelectArea("SC9")
	SC9->(DbSetOrder(1))
	SC9->(DbGoTop())
	
	lRetSC9 := SC9->(DbSeek( FWxFilial("SC9") + cNum ))
	
	If lRetSC9
	
		While Alltrim(cValToChar(SC9->C9_FILIAL)) == Alltrim(cValToChar(SC5->C5_FILIAL)) .And.;
		      Alltrim(cValToChar(SC9->C9_PEDIDO)) == Alltrim(cValToChar(SC5->C5_NUM))
			
			nVlrCred := 0
			SC9->(A460Estorna(/*lMata410*/,/*lAtuEmp*/,@nVlrCred))

			SC9->(DbSkip())
			
		End
	
	ElseIf ! lRetSC9 .And. Alltrim(cValToChar(SC5->C5_LIBEROK)) == "S"
		MsgStop("Não foi possível estornar os itens do pedido " + Alltrim(cValToChar(SC5->C5_NUM)) + " na tabela SC9.","Função uExcPedB(ADFAT041P)")
		RestArea(aArea)
		Return .F.
				
	EndIf
	
	Aadd( aCabec, { "C5_FILIAL"	 , SC5->C5_FILIAL	, Nil } )
	Aadd( aCabec, { "C5_NUM"	 , SC5->C5_NUM		, Nil } )
	Aadd( aCabec, { "C5_TIPO"	 , SC5->C5_TIPO		, Nil } )
	Aadd( aCabec, { "C5_CLIENTE" , SC5->C5_CLIENTE	, Nil } )
	Aadd( aCabec, { "C5_LOJACLI" , SC5->C5_LOJACLI	, Nil } )
	Aadd( aCabec, { "C5_LOJAENT" , SC5->C5_LOJAENT	, Nil } )
	Aadd( aCabec, { "C5_CONDPAG" , SC5->C5_CONDPAG	, Nil } )
	Aadd( aCabec, { "C5_ENDERE"  , SC5->C5_ENDERE	, Nil } )
	Aadd( aCabec, { "C5_EST"     , SC5->C5_EST		, Nil } )
	Aadd( aCabec, { "C5_BAIRRO"  , SC5->C5_BAIRRO	, Nil } )
	Aadd( aCabec, { "C5_CIDADE"  , SC5->C5_CIDADE   , Nil } )
	
	While ! SC6->(Eof()) .And. SC6->C6_FILIAL == SC5->C5_FILIAL .And. SC6->C6_NUM == SC5->C5_NUM
	
		aLinha := {}

		Aadd( aLinha, { "C6_FILIAL"	 , SC6->C6_FILIAL												                                                                                                   , Nil } )
		Aadd( aLinha, { "C6_ITEM"	 , SC6->C6_ITEM					    							                                                                                                   , Nil } )
		Aadd( aLinha, { "C6_PRODUTO" , SC6->C6_PRODUTO				    							                                                                                                   , Nil } )
		Aadd( aLinha, { "C6_QTDVEN"	 , SC6->C6_QTDVEN												                                                                                                   , Nil } )
		Aadd( aLinha, { "C6_PRCVEN"	 , SC6->C6_PRCVEN		            							                                                                                                   , Nil } )
		Aadd( aLinha, { "C6_VALOR"	 , SC6->C6_VALOR				    							                                                                                                   , Nil } )
		Aadd( aLinha, { "C6_TES"	 , SC6->C6_TES					    							                                                                                                   , Nil } )
		Aadd( aLinha, { "C6_DESCRI"	 , SC6->C6_DESCRI											 	                                                                                                   , Nil } )
		Aadd( aLinha, { "C6_UM"	 	 , SC6->C6_UM					    							                                                                                                   , Nil } )
		Aadd( aLinha, { "C6_LOCAL"	 , Iif(!RetArqProd(SC6->C6_PRODUTO),POSICIONE("SBZ",1,FWxFilial("SBZ")+SC6->C6_PRODUTO,"BZ_LOCPAD"),POSICIONE("SB1",1,FWxFilial("SB1")+SC6->C6_PRODUTO,"B1_LOCPAD"))   , Nil } )
		Aadd( aLinha, { "C6_QTDEMP"	 , SC6->C6_QTDEMP												                                                                                                   , Nil } )
		Aadd( aLinha, { "C6_CF"	 	 , SC6->C6_CF					    						 	                                                                                                   , Nil } )
		Aadd( aLinha, { "C6_CLI"	 , SC6->C6_CLI					    							                                                                                                   , Nil } )
		Aadd( aLinha, { "C6_ENTREG"	 , SC6->C6_ENTREG												                                                                                                   , Nil } )
		Aadd( aLinha, { "C6_LOJA"	 , SC6->C6_LOJA					    							                                                                                                   , Nil } )
		Aadd( aLinha, { "C6_PRUNIT"	 , SC6->C6_PRUNIT												                                                                                                   , Nil } )
		
		Aadd(aItens, aLinha)
		
		SC6->(DbSkip())
		
	End
	
	RecLock("SC5",.F.)
		SC5->C5_PLACA	:= ""
	MsUnlock()
	
	MSExecAuto( { |x, y, z, p| mata410(x, y, z,,,,,,, p) }, aCabec, aItens, 5 )
	
	If lMsErroAuto
		MostraErro()

	Else
		lRet := .T.
		
	EndIF

	RestArea(aArea)

Return lRet
/*/{Protheus.doc} emitNfGrp
	Interface para seleção de pedidos a serem faturados.
	@type  Static Function
	@author Everson
	@since 11/03/2022
	@version 01
/*/
Static Function emitNfGrp(cPedProth)

	//Variáveis.	
	Local aArea		:= GetArea() 
	Local cQuery	:= ""
	Local cPlaca	:= ""
	Local cNumIni	:= ""
	Local cNumFim	:= ""
	Local cPerg		:= "ADFAT411"
	Local nNFGer	:= 0
	Local nNFErr    := 0
	Local lRetNf	:= .F.
	Local cNota     := ""
	Local cSerie	:= Alltrim(cValToChar(GETMV("MV_#SRNFIT",,"")))
	Local aNFTrans	:= {}
	Local cNFErro	:= ""
	Local cAliasF2	:= ""
	
	Private aNfGerada 	:= {}
	
	If Empty(cSerie)
		MsgStop("Série da nota fiscal não definida no parâmetro MV_#SRNFIT.","Função emitNfGrp(ADFAT041P)")
		RestArea(aArea)
		Return aNFTrans
			
	EndIf

    If ! Empty(cPedProth)
        zAtuPerg(cPerg, "MV_PAR01", Space(8))
        zAtuPerg(cPerg, "MV_PAR02", cPedProth)
        zAtuPerg(cPerg, "MV_PAR03", cPedProth)
        
    EndIf

    If ! Pergunte(cPerg,.T.)
        RestArea(aArea)
        Return aNFTrans
        
    EndIf
    
    cPlaca := MV_PAR01
    cNumIni:= MV_PAR02
    cNumFim:= MV_PAR03
	
	// cQuery := ""
	// cQuery += " SELECT " 
	// cQuery += " C5_FILIAL, CONVERT(VARCHAR(10),CAST(C5_EMISSAO AS DATE),103) AS C5_EMISSAO, C5_NUM, C5_PEDSAG, C5_CLIENTE, C5_LOJACLI, C5_NOMECLI, C5_PLACA, C5_TRANSP " 
	// cQuery += " FROM " 
	// cQuery += " " + RetSqlName("SC5") + " AS SC5 (NOLOCK) " 
	// cQuery += " WHERE " 
	// cQuery += " SC5.D_E_L_E_T_ = '' " 
	// cQuery += " AND C5_NOTA = '' " 
	// cQuery += " AND C5_SERIE = '' " 
	// cQuery += " AND C5_FILIAL = '" + FWxFilial("SC5") + "' " 
	// cQuery += " AND C5_XORDPES <> '' "
    
    // If ! Empty(cPlaca)
    //     cQuery += " AND C5_PLACA = '" + cPlaca + "' " 
    
    // EndIf
    
    // cQuery += " AND C5_NUM >= '" + cNumIni + "' " 
    // cQuery += " AND C5_NUM <= '" + cNumFim + "' " 

	cQuery := ""
	cQuery += " SELECT  " 
        cQuery += "  DISTINCT C5_FILIAL, CONVERT(VARCHAR(10),CAST(C5_EMISSAO AS DATE),103) AS C5_EMISSAO, C5_NUM, C5_PEDSAG, C5_CLIENTE, C5_LOJACLI, C5_NOMECLI, C5_PLACA, C5_TRANSP "

    cQuery += " FROM " 
        cQuery += " " + RetSqlName("SC5") + " AS SC5 " 
        cQuery += " INNER JOIN " 
        cQuery += "  " + RetSqlName("SC6") + "  AS SC6 " 
        cQuery += " ON C5_FILIAL = C6_FILIAL " 
        cQuery += " AND C5_NUM = C6_NUM " 

	cQuery += " WHERE " 
		cQuery += " C5_FILIAL = '" + FWxFilial("SC5") + "' " 
		cQuery += " AND C5_EMISSAO >= '" + DToS(dDataIni) + "' " 
		cQuery += " AND C5_NOTA = '' " 
		cQuery += " AND C5_XLIBSAG <> '1' " 
		cQuery += " AND ( C5_XORDPES <> '' OR  C6_XORDPES <> '' ) AND C5_PEDSAG = '' " 

		If ! Empty(cPlaca)
			cQuery += " AND C5_PLACA = '" + cPlaca + "' " 
		
		EndIf

		cQuery += " AND C5_NUM >= '" + cNumIni + "' " 
		cQuery += " AND C5_NUM <= '" + cNumFim + "' "

		cQuery += " AND SC5.D_E_L_E_T_ = '' " 
		cQuery += " AND SC6.D_E_L_E_T_ ='' " 

    cQuery += " ORDER BY C5_NUM "
	
	cAliasF2 := GetNextAlias()

	MsAguarde({||DbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cAliasF2, .F., .T.)},"Função emitNfGrp(ADFAT041P)","Carregando registros...")
	
	DbSelectArea(cAliasF2)
	(cAliasF2)->(DbGoTop())
	
	If (cAliasF2)->(Eof())
		(cAliasF2)->(DbCloseArea())
		MsgStop("Não há pedidos para emissão doc de saída.","Função emitNfGrp(ADFAT041P)")
		RestArea(aArea)
		Return aNFTrans
		
	EndIf
	
	While ! (cAliasF2)->(Eof())
		
		lRetNf := .F.
		MsAguarde({|| NfLot(Alltrim(cValToChar((cAliasF2)->C5_NUM)), @cNota, @lRetNf,cSerie) },"Aguarde","Emitindo NF, pedido " + Alltrim(cValToChar((cAliasF2)->C5_NUM + "...")))
		       
		Aadd(aNfGerada,{cNota,Alltrim(cValToChar((cAliasF2)->C5_NUM)),lRetNf,cSerie})
		
		If lRetNf
            nNFGer++
			Aadd(aNFTrans,{cNota,cSerie})
			
		Else
            nNFErr++
			cNFErro += Alltrim(cValToChar((cAliasF2)->C5_NUM)) + " " + cNota + Chr(13) + Chr(10)
		
		EndIf
		
		(cAliasF2)->(DbSkip())
		
	End
	
    MsAguarde({|| pendenciaNF() },"Aguarde","Carregando registros...")

	If ! Empty(cNFErro)
		cNFErro := "Não foram geradas as notas fiscais para os pedidos abaixo: " + Chr(13) + Chr(10) + cNFErro
		MsgAlert(cNFErro)
	
	EndIf
	
	If Len(aNFTrans) > 0
	 	MsAguarde({|| transmNF(@aNFTrans,cSerie,.F.) },"Função emitNfGrp(ADFAT041P)","Transmitindo NF's")

	EndIf
	
	RestArea(aArea)
	
Return aNFTrans
/*/{Protheus.doc} transmNF
	Transmissão de nota fiscal.
	@type  Static Function
	@author Everson
	@since 11/03/2022
	@version 01
/*/
Static Function transmNF(aNFTrans,cSerie,lAut)

    //Variáveis.
	Local aArea		:= GetArea()
	Local cIdent    := ""
    Local oWs       := Nil
	Local cURL		:= ""
	Local cNFIni	:= aNFTrans[1][1]
	Local cNFFim	:= aNFTrans[Len(aNFTrans)][1]
	Local cNFT 		:= ""
	Local cAmbiTrans:= ""
	Local nAux		:= 1
	Local lTAut  	:= GetMv("MV_#TRAUT",,.F.)
	
	If lAut .And. ! lTAut
		aNFTrans := {}
		RestArea(aArea)
		Return .F.

	EndIf

	Default lAut	:= .F.
	
	MsgInfo("Notas geradas de " + cNFIni + " até " + cNFFim + ".","Função transmNF(ADFAT041P)")

    If ! CTIsReady()
		Conout( DToC(Date()) + " " + Time() + " ADFAT041P - transmNF - CTIsReady retornou .F. " )
        MsgSTop( "A função CTIsReady retornou .F. . Não será possível fazer a transmissão automática, faça a transmissão manual." ,"Função transmNF(ADFAT041P)")
		RestArea(aArea)
        Return .F. 

    EndIf

    cIdent := RetIdEnti()

    oWs := WsSpedCfgNFe():New()

    cURL := PadR(GetMv("MV_SPEDURL"),250)

    oWS:cUSERTOKEN := "TOTVS"
    oWS:cID_ENT := cIdent
    oWS:nAmbiente := 0
    oWS:_URL := AllTrim(cURL)+"/SPEDCFGNFe.apw"
    
    If oWS:CFGAMBIENTE()
        cAmbiTrans := oWS:cCfgAmbienteResult
        cAmbiTrans := Substr(cAmbiTrans,1,1)

    EndIf

	If Empty(cAmbiTrans)
		Conout( DToC(Date()) + " " + Time() + " ADFAT041P - transmNF - Não foi possível obter o ambiente de transmissão de nota fiscal.")
		MsgStop("Não foi possível obter o ambiente de transmissão de nota fiscal.","Função transmNF(ADFAT041P)")
		RestArea(aArea)
		Return .F.
		
	EndIf

	DbSelectArea("SF2")
	SF2->(DbSetOrder(1))
	
	For nAux := 1 To Len(aNFTrans) 

		cNFT := aNFTrans[nAux][1]

		SF2->(DbGoTop())
		If SF2->(DbSeek( FWxFilial("SF2") + cNFT + cSerie ))
			
			If SM0->M0_CODFIL == SF2->F2_FILIAL
				MsAguarde({|| AutoNfeEnv(FWCodEmp(),SF2->F2_FILIAL,"1",cAmbiTrans,SF2->F2_SERIE,SF2->F2_DOC,SF2->F2_DOC) },"Transmitindo NF","De " + cNFT + " até " + cNFT + " Série: " + cSerie + " ..." )
			Else
				MsgStop("A filial corrente está divergente da NF para transmissão " + cNFT + cSerie + ".", "Função transmNF(ADFAT041P)")
			Endif

		Else 
			MsgStop("NF não encontrada para transmissão " + cNFT + cSerie + ".", "Função transmNF(ADFAT041P)")
			

		EndIf 

	Next nAux 

	If ! lAut
		MsAguarde({|| imprimeNF(cValToChar(aNFTrans[1][1]),cValToChar(aNFTrans[Len(aNFTrans)][1])) },"Função transmNF(ADFAT041P)","Imprimindo notas fiscais...")

	EndIf
	
	RestArea(aArea)
	
Return .T.
/*/{Protheus.doc} imprimeNF
	Carrega o conteúdo na variável da pergunta.
	@type  Static Function
	@author Everson
	@since 11/03/2022
	@version 01
/*/
Static Function imprimeNF(cNFIni,cNFFim)

	//Variáveis.
	Local aArea 	:= GetArea()
	Local cCondicao := "F2_FILIAL=='"+FWxFilial("SF2")+"'"

	Private aFilBrw	:=	{'SF2', cCondicao} //Variável necessária para função SpedDanfe.

	Default cNFIni	:= ""
	Default cNFFim	:= ""
	
	If ! Empty(cNFIni) .And. ! Empty(cNFFim)
		zAtuPerg("NFSIGW", "MV_PAR01", cNFIni)
		zAtuPerg("NFSIGW", "MV_PAR02", cNFFim)
		
	EndIf
	
	SpedDanfe()
	
	RestArea(aArea)
	
Return Nil
/*/{Protheus.doc} zAtuPerg
	Carrega o conteúdo na variável da pergunta. 
	@type  Static Function
	@author Everson
	@since 11/03/2022
	@version 01
/*/
Static Function zAtuPerg(cPergAux, cParAux, xConteud)

	//Variáveis.
	Local aArea      := GetArea()
	Local nPosPar    := 14
	Local nLinEncont := 0
	Local aPergAux   := {}

	Default xConteud := ""

	//Se não tiver pergunta, ou não tiver ordem.
	If Empty(cPergAux) .Or. Empty(cParAux)
		Return Nil

	EndIf

	//Chama a pergunta em memória.
	Pergunte(cPergAux, .F., /*cTitle*/, /*lOnlyView*/, /*oDlg*/, /*lUseProf*/, @aPergAux)

	//Procura a posição do MV_PAR.
	nLinEncont := aScan(aPergAux, {|x| Upper(Alltrim(x[nPosPar])) == Upper(cParAux) })

	//Se encontrou o parâmetro
	If nLinEncont > 0
		//Caracter
		If ValType(xConteud) == 'C'
			&(cParAux+" := '"+xConteud+"'")

		//Data
		ElseIf ValType(xConteud) == 'D'
			&(cParAux+" := sToD("+dToS(xConteud)+")")

		//Numérico ou Lógico
		ElseIf ValType(xConteud) == 'N' .Or. ValType(xConteud) == 'L'
			&(cParAux+" := "+cValToChar(xConteud)+"")

		EndIf

		//Chama a rotina para salvar os parâmetros
		__SaveParam(cPergAux, aPergAux)

	EndIf

	RestArea(aArea)

Return Nil
/*/{Protheus.doc} visualPed
	Visualiza o pedido. Chamado 033511.
	@type  Static Function
	@author Everson
	@since 11/03/2022
	@version 01
/*/
Static Function visualPed(cNum)

	//Variáveis.
	Local aArea := GetArea()

	//Variáveis necessárias para função MatA410.
	Private Inclui    	:= .F.
	Private Altera    	:= .T.
	Private nOpca     	:= 1
	Private cCadastro 	:= "Pedido de Venda"
	Private aRotina 	:= {}
 
	DbSelectArea("SC5")
	SC5->(DbSetOrder(1))
	If ! SC5->(DbSeek(FWxFilial("SC5") + cNum))
		MsgStop("Não foi possível localizar o pedido " + cNum + " (SC5).","Função visualPed(ADFAT041P)")
		RestArea(aArea)
		Return Nil	
	
	EndIf

	SC5->(DbGoTo(Recno()))
	
	MatA410(Nil, Nil, Nil, Nil, "A410Visual")

	SC5->(DbCloseArea())
	
	RestArea(aArea)

Return Nil
/*/{Protheus.doc} NfLot
	Gera nota fiscal de saída.
	@type  Static Function
	@author Everson
	@since 11/03/2022
	@version 01
/*/
Static Function NfLot(cNumPed,cNota,lRetNf,cSerie)

    //Variáveis.
	Local aArea	  	:= GetArea()
	Local aPvlNfs 	:= {}
	Local lRet		:= .F.
	Local lNF912Ok  := .f.

	DbSelectArea("SC5")
	SC5->(DbSetOrder(1))
	SC5->(MsSeek(FWxFilial("SC5") + cNumPed))
	If SC5->(Eof())
		cNota := "Pedido não localizado (SC5)."
		RestArea(aArea)
		Return lRet

	EndIf

	DbSelectArea("SE4")
	SE4->(DbSetOrder(1))
	SE4->(MsSeek(FWxFilial("SE4") + SC5->C5_CONDPAG))
	If SE4->(Eof())
		cNota := "Condição de pagamento não localizada (SE4): " + Alltrim(cValToChar(SC5->C5_CONDPAG)) + "."
		RestArea(aArea)
		Return lRet

	EndIf

	DbSelectArea("SC6")
	SC6->(DbSetOrder(1))
	SC6->(MsSeek(FWxFilial("SC6") + cNumPed))
	If SC6->(Eof())
		cNota := "Pedido não localizado (SC6)."
		RestArea(aArea)
		Return lRet

	EndIf
	
	DbSelectArea("SC9")
	SC9->(DbSetOrder(1))
	
	DbSelectArea("SB1")
	SB1->(DbSetOrder(1))
	
	DbSelectArea("SB2")
	SB2->(DbSetOrder(1))	

	DbSelectArea("SF4")
	SF4->(DbSetOrder(1))
	
	While ! SC6->(Eof()) .And. Alltrim(cValToChar(SC6->C6_NUM)) == cNumPed
	
	 	If SC9->(MsSeek(FWxFilial("SC9") + SC6->(C6_NUM + C6_ITEM)))
	 		
	 		If Empty(Alltrim(cValToChar(SC9->C9_BLCRED))) .And. Empty(Alltrim(cValToChar(SC9->C9_BLEST))) // Valida se o item está liberado pelo financeiro e estoque.
	 			
				SB1->(MsSeek(FWxFilial("SB1") + SC6->C6_PRODUTO))
				If SB1->(Eof())
					cNota := "Produto não localizado: " + Alltrim(cValToChar(SC6->C6_PRODUTO)) + "."
					RestArea(aArea)
					Return lRet

				EndIf
				
				SB2->(MsSeek(FWxFilial("SB2") + SC6->(C6_PRODUTO + C6_LOCAL)))
				If SB2->(Eof())
					cNota := "Produto sem cadastro de saldos físicos e financeiros (SB2): " + Alltrim(cValToChar(SC6->C6_PRODUTO)) + " Local: " + Alltrim(cValToChar(SC6->C6_LOCAL)) + "."
					RestArea(aArea)
					Return lRet

				EndIf
						
				SF4->(MsSeek(FWxFilial("SF4") + SC6->C6_TES))
				If SF4->(Eof())
					cNota := "TES não localizado (SF4): " + Alltrim(cValToChar(SC6->C6_TES)) + "."
					RestArea(aArea)
					Return lRet

				EndIf
						 	
				Aadd(aPvlNfs,{ 	SC9->C9_PEDIDO,;
								SC9->C9_ITEM,;
								SC9->C9_SEQUEN,;
								SC9->C9_QTDLIB,;
								SC9->C9_PRCVEN,;
								SC9->C9_PRODUTO,;
								.F.,;
								SC9->(RecNo()),;
								SC5->(RecNo()),;
								SC6->(RecNo()),;
								SE4->(RecNo()),;
								SB1->(RecNo()),;
								SB2->(RecNo()),;
								SF4->(RecNo())})
			
			Else
				cNota := "Item não liberado: " + Alltrim(cValToChar(SC6->C6_NUM)) + " " + Alltrim(cValToChar(SC6->C6_ITEM)) + " " + Alltrim(cValToChar(SC6->C6_PRODUTO)) + "."
				RestArea(aArea)
				Return lRet	
			
			EndIf
			
		Else
			cNota := "Item não liberado: " + Alltrim(cValToChar(SC6->C6_NUM)) + " " + Alltrim(cValToChar(SC6->C6_ITEM)) + " " + Alltrim(cValToChar(SC6->C6_PRODUTO)) + "."
			RestArea(aArea)
			Return lRet			
			
		EndIf
		
		SC6->(DbSkip())
	
	End
	
	/*
	±±³Descri‡…o ³Inclusao de Nota fiscal de Saida atraves do PV liberado     ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Retorno   ³                                                            ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Parametros³ExpA1: Array com os itens a serem gerados                   ³±±
	±±³          ³ExpC2: Serie da Nota Fiscal                                 ³±±
	±±³          ³ExpC3: Numero da Nota Fiscal                                ³±±
	±±³          ³ExpL4: Lancamento 610                                       ³±±
	±±³          ³ExpL5: Lancamento 620                                       ³±±
	±±³          ³ExpN6: Controle de contabilizacao                           ³±±
	±±³          ³ExpN7: Handle do arquivo de contabilizacao                  ³±±
	±±³          ³ExpL8: Reajuste de preco na nota fiscal                     ³±±
	±±³          ³ExpN9: Tipo de Acrescimo Financeiro                         ³±±
	±±³          ³ExpNA: Tipo de Arredondamento                               ³±±
	±±³          ³ExpLB: Atualiza Amarracao Cliente x Produto                 ³±±
	±±³          ³ExplC: Cupom Fiscal                                         ³±±
	±±³          ³ExpCD: Numero do Embarque de Exportacao                     ³±±
	±±³          ³ExpBE: Code block para complemento de atualizacao dos titu- ³±±
	±±³          ³       los financeiros.                                     ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	*/
	If Len(aPvlNfs) > 0

		If AllTrim(SC5->C5_TABEGENE) <> "PO16MVES"

			DbSelectArea("SX5")
			cNota  := MaPvlNfs(aPvlNfs,cSerie,/* cNota */, .F., .F., .F., .F., 0, 0, .F.)
			lRet   := .T.
			lRetNf := lRet

		Else

			// Checo se a NF é Remessa Ordem TES 912, pois deverá ser emitida apenas se a 710#734 existirem - combo 12
			l912 := Posicione("SC6",1,FWxFilial("SC6")+SC5->C5_NUM,"C6_TES") $ cTESRemGra
			If l912
				
				lNF912Ok := UpNF710734()
				
				If lNF912Ok

					DbSelectArea("SX5")
					cNota  := MaPvlNfs(aPvlNfs,cSerie,/* cNota */, .F., .F., .F., .F., 0, 0, .F.)
					lRet   := .T.
					lRetNf := lRet

				Else
				
					cNota := "NF Remessa Ordem (5923) e/ou Outras Saídas (5949) não foi gerada, pois NF premissa (TES 710/734) não foi encontrada! "
				
				EndIf

			Else

				DbSelectArea("SX5")
				cNota  := MaPvlNfs(aPvlNfs,cSerie,/* cNota */, .F., .F., .F., .F., 0, 0, .F.)
				lRet   := .T.
				lRetNf := lRet

			EndIf

		EndIf
		
	Else
		cNota := "Pedido de venda não liberado (SC9)."
		
	EndIf

	RestArea(aArea)

return lRet
/*/{Protheus.doc} gerNFLt
	Função gera nota fiscal. Chamado 046285.
	@type  Static Function
	@author Everson
	@since 11/03/2022
	@version 01
/*/
Static Function gerNFLt(cTemp)

	//Variáveis.		
	Local aArea      := GetArea()
	Local aPedSelect := {}
	Local i          := 1
	Local aNfGerada  := {}
	Local lRetNf     := .F.
	Local cNota      := ""
	Local cSerie     := Alltrim(cValToChar(GETMV("MV_#SRNFIT",,"")))
	Local nNFGer     := 0
	Local nNFErr     := 0
	Local cNFErro    := ""
	Local aNFTrans   := {}

	If Empty(cSerie)
		MsgStop("Série da nota fiscal não definida no parâmetro MV_#SRNFIT.","Função gerNFLt(ADFAT041P)")
		RestArea(aArea)
		Return Nil

	EndIf

	(cTemp)->(DbGoTop())
	While ! (cTemp)->(Eof())

		If ! Empty(Alltrim(cValToChar((cTemp)->OK)))
			Aadd(aPedSelect,{(cTemp)->PEDIDO})

		EndIf

		(cTemp)->(DbSkip())

	End

	If ! MsgYesNo("Serão faturados " + cValToChar(Len(aPedSelect)) + " pedidos. Deseja prosseguir?","Função gerNFLt(ADFAT041P)")
		RestArea(aArea)
		Return Nil

	EndIf

	For i := 1 To Len(aPedSelect)

		lRetNf := .F.
		cNota  := ""
		MsAguarde({|| NfLot(Alltrim(cValToChar(aPedSelect[i][1]) ), @cNota, @lRetNf,cSerie) },"Aguarde","Emitindo NF, pedido " + Alltrim(cValToChar(aPedSelect[i][1])) + "...")
		If lRetNf
			nNFGer++

		Else
			nNFErr++

		EndIf
		Aadd(aNfGerada,{cNota, Alltrim(cValToChar(aPedSelect[i][1])) ,lRetNf,cSerie})

		If lRetNf
			Aadd(aNFTrans,{cNota,cSerie})

		EndIf

		If ! lRetNf
			cNFErro += Alltrim(cValToChar(aPedSelect[i][1]) ) + " " + cNota + Chr(13) + Chr(10)

		EndIf

	Next i

	If ! Empty(cNFErro)
		cNFErro := "Não foram geradas as notas fiscais para os pedidos abaixo: " + Chr(13) + Chr(10) + cNFErro
		MsgAlert(cNFErro)

	EndIf

	If Len(aNFTrans) > 0
	 	MsAguarde({|| transmNF(aNFTrans,cSerie) },"Aguarde","Transmitindo NF's")

	EndIf

	MsgInfo("Processo finalizado.","Função gerNFLt (ADFAT041P)")

	RestArea(aArea)

Return Nil
/*/{Protheus.doc} libEst
    Libera estoque.
    @type  Static Function
    @author Everson
    @since 11/03/2022
    @version 01
/*/
Static Function libEst()

    //Variáveis.
	Local aArea	:= GetArea()

	Private _dData1 := Date()-1    				
	Private _dData2	:= Date()+5                    
	Private _cFil1	:= FWxFilial("SC5")                           
	Private _cFil2	:= FWxFilial("SC5") 

	MsAguarde({|| MATA455() },"Aguarde","Acessando rotina lib estoque...")

	RestArea(aArea)

Return Nil
/*/{Protheus.doc} chkSefaz
    Checa se o serviço de emissão de nota fiscal eletrônica tipo 55.
    @type  Static Function
    @author Everson
    @since 11/03/2022
    @version 01
/*/
Static Function chkSefaz()

    //Variáveis.
    Local aArea 	:= GetArea()
	Local cIdent 	:= RetIdEnti()
    Local lRet  	:= .F.
    Local oWS   	:= Nil
    Local cURL  	:= PadR(GetNewPar("MV_SPEDURL","http://"),250)
    Local lOk   	:= .F.
    Local aXML  	:= {}
    Local nAux  	:= 1
    Local cMsg  	:= ""

    If ! CTIsReady()
		Conout( DToC(Date()) + " " + Time() + " ADFAT041P - chkSefaz - CTIsReady retornou .F. " )
        MsgSTop( "A função CTIsReady retornou .F. . Não será possível fazer a emissão de NF automática, faça a emissão manual." ,"Função chkSefaz(ADFAT041P)")
		RestArea(aArea)
        Return lRet 

    EndIf

    oWS:= WSNFeSBRA():New()
    oWS:cUSERTOKEN := "TOTVS"
    oWS:cID_ENT    := cIdEnt
    oWS:_URL       := AllTrim(cURL)+"/NFeSBRA.apw"
    lOk := oWS:MONITORSEFAZMODELO()

    If lOk

        aXML := oWS:oWsMonitorSefazModeloResult:OWSMONITORSTATUSSEFAZMODELO
        For nAux := 1 To Len(aXML)

			cMsg :=  Upper(Alltrim(aXML[nAux]:cStatusMensagem))
            If aXML[nAux]:cModelo == "55" .And. cMsg == "SERVIÇO EM OPERAÇÃO"
                lRet := .T.

            EndIf
            
        next Aux

    Else 
        Conout( DToC(Date()) + " " + Time() + " ADFAT041P - chkSefaz - falha no consumo do web service." )

    EndIf

    RestArea(aArea)

Return lRet 
/*/{Protheus.doc} Static Function UpNF710734
	Se for NF com TES 912, terá que existir NF com TES 710#734
	@type  Function
	@author FWNM
	@since 23/02/2021
	@version 01
/*/
Static Function UpNF710734()

	Local lRet      := .F.
	Local cQuery    := ""
	Local cTESEmp09 := GetMV("MV_TESEMP9",,"734")
	Local cTESEmp01 := GetMV("MV_TESEMP1",,"710")

	If Posicione("SC6",1,FWxFilial("SC6")+SC5->C5_NUM,"C6_TES") $ cTESRemGra 
		
		// NF 912
		cAlias912 := GetNextAlias()

		cQuery := " SELECT C5_XAGRUPA
		cQuery += " FROM SGPED010 (NOLOCK)
		cQuery += " WHERE TABEGENE = 'PO16MVES' 
		cQuery += " AND C5_NUM='"+SC5->C5_PEDSAG+"'

		dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cAlias912, .F., .T.)

		// NF PREMISSA 710#734
		cAliasTES := GetNextAlias()

		cQuery := " SELECT ISNULL(C5_NOTA,'') C5_NOTA, ISNULL(C5_SERIE,'') C5_SERIE
		cQuery += " FROM SGPED010 (NOLOCK)
		cQuery += " WHERE TABEGENE = 'PO16MVES' 
		cQuery += " AND C6_TES IN " + FormatIn(cTESPreGra,"#")
		cQuery += " AND C6_TES = '" + Iif(cEmpAnt=="09",cTESEmp09,cTESEmp01) + "' 
		cQuery += " AND C5_TIPO='B'
		cQuery += " AND C5_XAGRUPA='"+AllTrim(Str((cAlias912)->C5_XAGRUPA))+"'

		dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cAliasTES, .F., .T.)

		If (cAliasTES)->( !EOF() )

			If !Empty((cAliasTES)->C5_NOTA) .and. !Empty((cAliasTES)->C5_SERIE)

				lRet    := .T.

			EndIf
		
		EndIf

	EndIf

Return lRet
/*/{Protheus.doc} Static Function xLibEst
	Faz chamada na rotina de liberação manual de pedidos
	@type  Function
	@author Abel Babini
	@since 10/05/2021
	@history Ticket 13852 - Abel Babini - Retirada a chamada da Função LIMPAEST() e direcionada para função padrão
/*/
Static Function xLibEst()

    //Variáveis.
	Local aAreaSC5 := SC5->(GetArea())
	Local aAreaSC9 := SC9->(GetArea())
	Local nAux     := 1

	DbSelectArea("SC5")
	SC5->(DbSetOrder(1))
	SC5->(DbGoTop())

	DbSelectArea("SC9")
	SC9->(DbSetOrder(1))
	SC9->(DbGoTop())

	For nAux := 1 to Len(oRegistros:aCols)

		If SC5->( DbSeek( FWxFilial('SC5')+oRegistros:aCols[nAux][Ascan(aHInterface,{|x| AllTrim(x[2]) == "PED"} )]))

            If SC9->(DbSeek(FWxFilial('SC9')+oRegistros:aCols[nAux][Ascan(aHInterface,{|x| AllTrim(x[2]) == "PED"})]))

                While !SC9->(eof()) .AND. SC9->C9_PEDIDO == oRegistros:aCols[nAux][Ascan(aHInterface,{|x| AllTrim(x[2]) == "PED"})]
                    
                    If Alltrim(SC9->C9_BLEST) <> '' .AND. Alltrim(SC9->C9_BLEST) <> '10'
                        MATA455(3,.T.)
                        oRegistros:aCols[nAux][Ascan(aHInterface,{|x| AllTrim(x[2]) == "BLEST"})] := "Não"

                    EndIf

                    SC9->(DbSkip())

                End

            EndIf

        EndIf

	Next nAux

	oRegistros:Refresh()

	RestArea(aAreaSC5)
	RestArea(aAreaSC9)

Return Nil
