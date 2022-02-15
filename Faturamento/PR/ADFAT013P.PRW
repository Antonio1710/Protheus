#INCLUDE "Protheus.ch"
#include "rwmake.ch"   
#include "topconn.ch"                                    
#include "AP5MAIL.CH"   

/*{Protheus.doc} User Function ADFAT013P
	Programa importador do txt EDI para todos os clientes usando schedules 
	@type  Function
	@author WILLIAM COSTA
	@since 02/06/2016
	@version 01
*/

User Function ADFAT013P()

	msAguarde( {|| fProcessa() },"Processando","Processandos..." )

	//
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Programa importador do txt EDI para todos os clientes usando schedules')
	//

RETURN lRet

Static Function fProcessa()
    Local aCabec        	:= {}
    Local aDados        	:= {} 
	Local aErros			:= {}
	
	Private nContArq      	:= 0
	Private aDirectory    	:= {}
    Private cPath         	:= "c:\pvs_producao\"

	setFunname("ADFAT013P")

	// *************INICIO PARA RODAR COM SCHEDULE************************************* //	
	/*
	RPCClearEnv()
	RPCSetType(3)  //Nao consome licensas
    RpcSetEnv("01","02",,,,GetEnvServer(),{ }) //Abertura do ambiente em rotinas automáticas              
	*/
	// **************FINAL PARA RODAR COM SCHEDULE************************************** //	
	
    ConOut("[ADFAT013P] "+ Dtoc(date())+"-"+ Time() +" - INICIO DO SCHEDULE ADFAT013P " + ALLTRIM(FUNNAME()) +"")
	
    // Garanto uma única thread sendo executada - // Adoro - Chamado n. 050729 || OS 052035 || TECNOLOGIA || LUIZ || 8451 || REDUCAO DE BASE - fwnm - 29/06/2020
	/*
	If !LockByName("ADFAT013P", .T., .F.)
		ConOut("[ADFAT013P] "+ Dtoc(date())+"-"+ Time() +" - Existe outro processamento sendo executado! Verifique...")
		RPCClearEnv()
		Return
	EndIf
	*/
	aDirectory 	:= DIRECTORY(cPath+"*.csv")
	nQtdArq		:= len(aDirectory)
	nContArq	:= 1

	While nContArq <= nQtdArq

		  
		
		ConOut("[ADFAT013P] "+ Dtoc(date())+"-"+ Time() +" - Lendo o arquivo: " + aDirectory[nContArq][1] +"")
		  
		aCabec := {}
        aItens := {}
		
		//Leitura dos arquivos.
        fReadArq(@aCabec, @aDados, @aErros)
		//Formata para a inclusão via Execauto.
		fFormArq(@aCabec, @aDados, @aErros)
		//Executa a geração dos PVs.
        fProcPed(@aCabec, @aDados, @aErros)

		
		nContArq += 1       
	enddo

	ConOut("[ADFAT013P] "+ Dtoc(date())+"-"+ Time() +" - FINAL DO SCHEDULE ADFAT013P " + ALLTRIM(FUNNAME())+"")
	//RpcClearEnv() 
	UnLockByName("ADFAT013P")

RETURN(NIL)  

Static Function fReadArq(aCabec, aDados, aErros)
    Local nLinha    := 1
	Local nLimite	:= 999999999
	Local lRet		:= .T.


	FT_FUse( cPath+aDirectory[nContArq][1] ) 
    FT_FGoTop() 
    
    While ! ( FT_FEof() ) .and. nLinha <= nLimite
		cTxt :=  FT_FReadLN()    
			
        if nLinha == 1
            fgetCabec(@aCabec, cTxt)
        else
            fgetDados(@aCabec, @aDados,cTxt)
        endif

		nLinha ++
	   	FT_FSkip()
	ENDDO
	FT_FUse()
return lRet

Static Function fgetCabec(aCabec, cTxt)
	
    aCabec   := Separa(cTxt,";")
   
return nil

Static Function fGetDados(aCabec, aDados, cTxt)
    Local lRet   	:= .T.
	Local nA		:= 1
    Local aDadTmp   := Separa(cTxt,";")
    Local nDadTmp   := Len(aDadTmp)
	Local nCabec	:= Len(aCabec)

    if nCabec == nDadTmp
		For nA := 1 To nDadTmp
			aDadTmp[nA] := Alltrim(aDadTmp[nA])
		next nA
        AADD(aDados, aDadTmp)
	else
		lRet := .F.
    endif

return lRet

Static Function fFormArq(aCabec, aDados, aErros)
	Local lRet 		:= .T.
	Local nA		:= 1
	Local nB		:= 1
	Local nCabec 	:= Len(aCabec)
	Local aCabTmp	:= {}
	Local aDadTmp	:= {}
	Local aTmp		:= {}
	Local aArea		:= getArea()
	DbSelectArea("SX3")
    SX3->(DbSetOrder(2))

     for nA := 1 To nCabec
        //aTmp    := {}
        cCampo  := Alltrim(aCabec[nA])
        
        If SX3->( DbSeek( cCampo ))
            AADD(aCabTmp,{ GetSX3Cache(cCampo, "X3_ARQUIVO"),;
                        GetSX3Cache(cCampo, "X3_CAMPO"),;
                        GetSX3Cache(cCampo, "X3_TIPO"),;
                        GetSX3Cache(cCampo, "X3_TAMANHO"),;
                        GetSX3Cache(cCampo, "X3_DECIMAL"),;
						nA})
        endIF

    next nA

	// Reduz as colunas não mapeadas e formata os campos.
	aCabec 	:= aCabTmp
	nCabec 	:= Len(aCabec)
	
	if nCabec > 0
		nPosLin := Len(aCabec[01])
		
		nDados	:= Len(aDados)
		
		For nA := 1 To nDados
			aTmp 	:= Array(nCabec)

			for nB := 1 To nCabec
				aTmp[nB] := fFormat(aDados[nA][aCabec[nB][nPosLin]], aCabec[nB][03])
			next nB

			AADD(aDadTmp, aTmp)
		next nA

		aDados	:= aDadTmp
	else
		lRet := .F.
	endif
	RestArea(aArea)
return lRet

Static Function fFormat(cValor, cFormato)
	Local uRet
	
	if cFormato == "C" .or. cFormato == "M"
		uRet := cValor
	Elseif cFormato == "N"
		cValor := Replace(cValor,".","")
		cValor := Replace(cValor,",",".")
		uRet := Val(cValor)
	Elseif cFormato == "L"
		uRet := cValor
	Elseif cFormato == "D"
		If "/"$cValor
			uRet := ctod(cValor)
		Else
			uRet := stod(cValor)
		EndIf
	Else
		uRet := cValor
	EndIf
		
Return uRet

Static Function fProcPed(aCabec, aDados, aErros)
    Local nDados    := Len(aDados)
	Local nCabec	:= Len(aCabec)
    Local nX        := 0
	Local nY		:= 0
	Local nZ		:= 0
    Local nPosPed   := fGetfield("C5_NUM", aCabec)
	Local nPosTip   := fGetfield("C5_TIPO", aCabec)
	Local nPosQtd   := fGetfield("C6_QTDVEN", aCabec)
	Local nPosPrd   := fGetfield("C6_PRODUTO", aCabec) 
	Local nPosCli   := fGetfield("C5_CLIENTE", aCabec)  
	Local nPosLoj   := fGetfield("C5_LOJACLI", aCabec)   
	Local nPosFil   := fGetfield("C5_FILIAL", aCabec)   
	Local nPosnOr   := fGetfield("C6_NFORI", aCabec)   

    Local cPedAtu   := ""
    Local aCabC5    := {}
    Local aDadC6    := {}
	Local aExec		:= {}
	Local nItem		:= 1
	Local cTipo		:= ""
	

    if nPosPed == 0
        MsgInfo("O arquivo não possui campos obrigatórios para ser processado!")
    else
        aSort( aDados,,, { | x,y | x[ nPosPed ] > y[ nPosPed ] } )
	
        for  nX := 1 to nDados
                
            IF cPedAtu != aDados[nX][nPosPed]
				
				if !Empty(cPedAtu)
					AADD(aExec,{aCabC5,aDadC6})
				Endif
				
				aCabC5	:= {}
				aDadC6	:= {}
				aDadTmp := {}
				aCabTmp := {}
                nItem	:= 1
				
				for nY := 1 to nCabec
                    if aCabec[nY][01] == "SC5"
                        // Não carrega o campo C5_NUM, pois vai ser gerado o padrão.    
                        if nY == nPosPed
                            aCabTmp := {"C5_XOBSRFA", aDados[nX][nY],nil}
                        //Altera o tipo do Pedido.
                        elseif nY == nPosTip
                            aCabTmp := {Alltrim(aCabec[nY][02]), left(aDados[nX][nY],1),nil}
							cTipo := left(aDados[nX][nY],1)
						elseif nY == nPosLoj
							aCabTmp := {Alltrim(aCabec[nY][02]), aDados[nX][nY],nil}
							cLoja := aDados[nX][nY]
						elseif nY == nPosCli
							aCabTmp := {Alltrim(aCabec[nY][02]), aDados[nX][nY],nil}
							cCli := aDados[nX][nY]
                        else
                            aCabTmp := {Alltrim(aCabec[nY][02]), aDados[nX][nY],nil}
                        endif
						
						//aCabTmp := {"C5_EMISSAO", dDatabase,nil}
                        AADD(aCabC5, aCabTmp)
                    endif
                next nY
				
				cNum := GetSx8Num("SC5","C5_NUM")

				DbSelectArea("SA1")
				SA1->(DbSetOrder(1))
				SA1->(Dbseek(xFilial("SA1")+cCli+cLoja))
				AADD(aCabC5,{"C5_NUM", cNum,nil})
				AADD(aCabC5,{"C5_EMISSAO", dDatabase,nil})
				AADD(aCabC5,{"C5_CONDPAG", "0 ",nil})
				//AADD(aCabC5,{"C5_DTENTR", dDatabase,nil})
				AADD(aCabC5,{"C5_TIPOCLI", SA1->A1_TIPO,nil})
				AADD(aCabC5,{"C5_VEND1", SA1->A1_VEND,nil})
				AADD(aCabC5,{"C5_MOEDA", 1,nil})
				AADD(aCabC5,{"C5_PBRUTO", 0,nil})
				AADD(aCabC5,{"C5_PESOL", 0,nil})
				AADD(aCabC5,{"C5_DESC1", 0,nil})

				//AADD(aCabC5,{"C5_LOJACLI", cLoja,nil})

				aCabC5 := FWVetByDic(aCabC5,"SC5")

            endif
            
            aDadTmp := {}

			//AADD(aDadTmp,{"C6_FILIAL" , aDados[nX][nPosFil] ,nil})
            AADD(aDadTmp,{"C6_NUM", cNum,nil})
			AADD(aDadTmp,{"C6_ITEM", StrZero(nItem,2),nil})
			AADD(aDadTmp,{"C6_QTDVEN", 0 ,0 ,nil})
			//AADD(aDadTmp,{"C6_QTDLIB", 0 ,nil})
			//AADD(aDadTmp,{"C6_UNSVEN", 0 ,0 ,nil})
			AADD(aDadTmp,{"C6_DESCRI" , posicione("SB1",1,xFilial("SB1")+aDados[nX][nPosPrd],"B1_DESC") ,nil})
			AADD(aDadTmp,{"C6_UM" , posicione("SB1",1,xFilial("SB1")+aDados[nX][nPosPrd],"B1_UM") ,nil})
			//AADD(aDadTmp,{"C6_SEGUM" , posicione("SB1",1,xFilial("SB1")+aDados[nX][nPosPrd],"B1_SEGUM") ,nil})
			cProd 	:= aDados[nX][nPosPrd]
			cLocal 	:= Alltrim(fItemOri(aDados[nX][nPosNOr],"01",aDados[nX][nPosPrd],"D2_LOCAL"))
			
			if Empty(cLocal)
				IF !RetArqProd(cProd)
					cLocal:= POSICIONE("SBZ",1,xFilial("SBZ")+cProd,"BZ_LOCPAD")
				ELSE
					cLocal:= POSICIONE("SB1",1,xFilial("SB1")+cProd,"B1_LOCPAD")
					CriaSb2(cProd,cLocal)
				ENDIF
			endif
			
			AADD(aDadTmp,{"C6_LOCAL" , cLocal ,nil})
			//AADD(aDadTmp,{"C6_SEGUM" , "CX" ,nil})
			AADD(aDadTmp,{"C6_CLI" , aDados[nX][nPosCli] ,nil})
			//AADD(aDadTmp,{"C6_LOJ" , aDados[nX][nPosLoj] ,nil})
			//AADD(aDadTmp,{"C6_LOJA" , aDados[nX][nPosLoj] ,nil})
			//AADD(aDadTmp,{"C6_DESCONT" , 0 ,nil})
			//AADD(aDadTmp,{"C6_VALDESC" , 0 ,nil})
			
			//AADD(aDadTmp,{"C6_TPOP" , "F" ,nil})
    
			for nZ := 1 to nCabec
                if aCabec[nZ][01] == "SC6"
                    // Não carrega o campo C5_NUM, pois vai ser gerado o padrão.    
                    if !aLLTRIM(aCabec[nZ][02])$"C6_ITEM"

						if Alltrim(aCabec[nZ][02]) == "C6_PRODUTO"
							AADD(aDadTmp,{Alltrim(aCabec[nZ][02]), aDados[nX][nZ],nil})
						elseif Alltrim(aCabec[nZ][02]) == "C6_NFORI"
							AADD(aDadTmp,{"C6_NFORI", 	aDados[nX][nZ] ,nil})
							AADD(aDadTmp,{"C6_SERIORI", "01 " ,nil})
							AADD(aDadTmp,{"C6_ITEMORI", fItemOri(aDados[nX][nZ],"01",aDados[nX][nPosPrd],"D2_ITEM") ,nil})
						ELSE
							IF aCabec[nZ][03]$"N"
								AADD(aDadTmp,{aLLTRIM(aCabec[nZ][02]), aDados[nX][nZ], 0,nil})
							elseIF aCabec[nZ][03]$"D"
								AADD(aDadTmp,{ALLTRIM(aCabec[nZ][02]), aDados[nX][nZ],nil})
							Else
								AADD(aDadTmp,{ALLTRIM(aCabec[nZ][02]), Alltrim(aDados[nX][nZ]),nil})
							endif
						ENDIF
                    endif
                    
                endif
            next nZ
			AADD(aDadC6, aDadTmp)
			aDadC6 := FWVetByDic(aDadC6,"SC6",.T.)

			nItem	+= 1
			cPedAtu := aDados[nX][nPosPed]
        next nX
        
		AADD(aExec,{aCabC5,aDadC6})
		nExec := Len(aExec)
		for nX := 1 To nExec
        	fGeraPV(aExec[nX][1], aExec[nx][2])
        next nX
	endif
	
return

Static Function fItemOri(cNfOri,cSeriOri,cProduto, cCampo)
	Local cQuery 	:= " SELECT "+ cCampo +" FROM "+ RetSqlName("SD2") +" (NOLOCK) WHERE D_E_L_E_T_='' AND D2_FILIAL='02' AND D2_DOC='"+ cNfOri +"' AND D2_SERIE='"+ cSeriOri +"' AND D2_COD='"+ cProduto +"'; "
	Local cRet	:= ""
	Tcquery cQuery ALIAS "QD2" NEW

	if QD2->(!eof())
		cRet := &("QD2->"+cCampo)
	endif

	QD2->(DbcloseArea())

Return cRet

Static Function fGetfield(cField, aHeader)
    Local nRet  := 0
    Local nX    := 0

    cField := Alltrim(Upper(cField))

    for nX := 1 to len(aHeader)
        if cField == Alltrim(Upper(aHeader[nX][02]))
            nRet := nX
        endif
    next nX++

return nRet

Static Function fGeraPV(aCabec, aDados, aErros) 
	Private lMsHelpAuto := .F.                      
	Private lMsErroAuto := .F.

	DbSelectArea("SC5")
	DbSelectArea("SC6")
	//DbSelectArea("SX3")

	if Len(aCabec) > 0 .and. Len(adados) > 0
		
		BEGIN TRANSACTION 
		 
			MSExecAuto({|x,y,z| Mata410(x,y,z) }, aCabec, aDados, 3)                                                        
	                                                                      
	        IF !lMsErroAuto
	            cStatus := 'OK'
	        ELSE         

	        	DisarmTransaction()               
	            cStatus     := 'NOK'
	  			mostraerro()
				
	        ENDIF      
		END TRANSACTION	
    ENDIF
    
Return(NIL)     

  
