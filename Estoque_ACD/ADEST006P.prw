#INCLUDE "PROTHEUS.CH"
#INCLUDE "APVT100.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณADEST006P บAutor  ณMicrosiga           บ Data ณ  02/11/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณBaixa requisicao ao armazem pelo coletor de dados - VT100   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function ADEST006P()
	Local ckey04	:= VTDescKey(04)
	Local ckey09	:= VTDescKey(09)
	Local ckey12	:= VTDescKey(12)
	Local cKey16	:= VTDescKey(16)
	Local cKey22	:= VTDescKey(22)
	Local cKey24	:= VTDescKey(24)
	Local cKey21	:= VTDescKey(21)
	Local bkey04	:= VTSetKey(04)
	Local bkey09	:= VTSetKey(09)
	Local bkey12	:= VTSetKey(12)
	Local bkey16	:= VTSetKey(16)
	Local bKey22	:= VTSetKey(22)
	Local bKey21	:= VTSetKey(21)
	Local cNada		:= " "
	Local lRetPE	:= .T.
	
	Local  aEnder	:= {}
	Local nSaldo	:= 0
	Local lContinua	:= .T.
	Local cArmazem	:= Space(TamSX3('B1_LOCPAD')[1])
	Local cEndereco	:= Space(TamSX3('BF_LOCALIZ')[1])
	Local cProduto	:= Space(TamSX3('B1_COD')[1])
	Local cLoteCtl	:= Space(TamSX3('B8_LOTECTL')[1]) + Space(TamSX3('B8_NUMLOTE')[1])
	Local nQtde		:= 0
	Local cMvLocaliz:= SuperGetMV("MV_LOCALIZ")
	Local lEnder	:= .F.
	Local nI
	Local aItSCQ := {} //DRL
	Local nCnt
	
	Private cCodSA		:= Space(TamSX3('CP_NUM')[1])
	Private cConSXB		:= "XSA"
	Private cCodOpe     := CBRetOpe()
	Private lMSErroAuto := .F.
	Private lMSHelpAuto := .t.
	Private cTMBX		:= GetMV("MV_TMBXSA",.F.,"ZZZ")
	Private cArmTra		:= GetMV("MV_ARMTRA",.F.,"ZZ")
	Private cEndTra		:= GetMV("MV_ENDTRA",.F.,"ZZZZZZZZZZ")
	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Programa para criar as prioridades de endereco na tabela SBE e SBF')
	
	If cTMBX == "ZZZ"
		VTAlert("Parametro MV_TMBXSA nao existe! Impossivel continuar","Aviso",.T.,4000,3)
		Return
	Else
		If Posicione("SF5",1,xFilial("SF5")+Alltrim(cTMBX),"F5_TIPO") <> "R"
			VTAlert("Codigo TM " + Alltrim(cTMBX) + " invalido! Impossivel continuar","Aviso",.T.,4000,3)
			Return	
		Endif
	Endif
	
	If cArmTra == "ZZ"
		VTAlert("Parametro MV_ARMTRA nao existe! Impossivel continuar","Aviso",.T.,4000,3)
		Return
	Endif
	
	If cEndTra == "ZZZZZZZZZZ"
		VTAlert("Parametro MV_ENDTRA nao existe! Impossivel continuar","Aviso",.T.,4000,3)
		Return
	Endif
	 
	DBSELECTAREA("SBE")
	SBE->(DBGOTOP())
	SBE->(DbSetOrder(1)) //BE_FILIAL+BE_LOCAL+BE_LOCALIZ
	If !SBE->(DbSeek(xFilial("SBE")+Alltrim(cArmTra)+ "    "+Alltrim(cEndTra)))
		VTAlert("Endereco " +Alltrim(cArmTra)+"-"+Alltrim(cEndTra)+ " nao existe! Impossivel continuar","Aviso",.T.,4000,3)
		Return
	Endif
	
	If Empty(cCodOpe)
		VTAlert("Operador nao cadastrado","Aviso",.T.,4000,3)
		Return
	EndIf
	
	SCP->(DbSetOrder(1)) //CP_FILIAL+CP_NUM+CP_ITEM+DTOS(CP_EMISSAO)
	SCQ->(DbSetOrder(1)) //CQ_FILIAL+CQ_NUM+CQ_ITEM+CQ_NUMSQ
	
	//VTSetKey(09,{|| Informa()},"Informacoes")
	
	VTClear()
	@ 0,0 VtSay "Solic.Armazem"
	@ 1,0 VtSay "Infome Codigo"
	@ 2,0 VtSay "Solicitacao ao"
	@ 3,0 VtSay "Armazem"
	@ 5,0 VtGet cCodSA F3 cConSXB Valid VldSA(@cCodSA)
	VtRead
	If VtLastKey() == 27
		Return
	EndIf
	
	VTClear()
	SCP->(DbSeek(xFilial("SCP")+cCodSA))
	
	//Busca os itens que fora requisitados para respeitar quantidade e armazem
	If !SCQ->(DbSeek(xFilial("SCQ")+cCodSA))
		VtAlert("Nao existe pre requisicao para esta S.A.!","Aviso",.t.,4000,3)
		VtKeyboard(Chr(20))                            
		Return
	Endif
	
	SBF->(dbSetOrder(2)) //BF_FILIAL+BF_PRODUTO+BF_LOCAL+BF_LOTECTL+BF_NUMLOTE+BF_PRIOR+BF_LOCALIZ+BF_NUMSERI
	Do While SCQ->(!Eof() .and. CQ_FILIAL+CQ_NUM == xFilial("SCQ")+cCodSA)
	   SBF->(dbSeek(xFilial("SBF") + SCQ->CQ_PRODUTO + SCQ->CQ_LOCAL))
	   aAdd(aItSCQ,{SCQ->(RECNO()), SBF->BF_PRIOR})
	   SCQ->(dbSkip())
	EndDo
	
	aSort(aItSCQ,,,{|x,y| x[2] < y[2] })
	
	For nCnt:= 1 To Len(aItSCQ)
	    
	    SCQ->(dbGoTo(aItSCQ[nCnt,1]))
	    
		If !Empty(SCQ->CQ_NUMREQ)
			Loop
		Endif
			
		VTClear()
	
		If !SCP->(DbSeek(xFilial("SCP")+SCQ->(CQ_NUM+CQ_ITEM)))
			VtAlert("Cabecalho da S.A. nao localizado!","Aviso",.t.,4000,3)
			VtKeyboard(Chr(20))
	
			Loop
		Endif
		
		If !Empty(Substr(SCP->CP_OBS,1,6)) .and. !(Substr(SCP->CP_OBS,1,6) == cCodOpe)
			If ! VTYesNo("Solicitacao iniciada pelo operador "+Substr(SCP->CP_OBS,1,6)+".","Deseja continuar?",.T.)
				VtKeyboard(Chr(20))
				Return
			Else
				SCP->(Reclock("SCP",.F.))
				SCP->CP_OBS := cCodOpe + "-" + DtoC(dDatabase) + "-" + Time()
				SCP->(MsUnlock())
			EndIf
		EndIf
	
	
		If cMvLocaliz<>"S" .and. !Localiza(SCQ->CQ_PRODUTO)
			lEnder := .F.
		Else
			lEnder := .T.
		Endif
		
		///Busca os enderecos sem empenhar pois nao devera haver concorrencia para S.A.
		nSaldo := SCQ->CQ_QUANT
		nTotal := nSaldo
		aEnder := {}
		If lEnder
			BEGINSQL ALIAS "QSBF"
			%noparser%
			
			/*
			SELECT BF_LOCAL, BF_LOCALIZ,BF_LOTECTL,BF_NUMLOTE, BF_QUANT-BF_EMPENHO AS DISPONIVEL
			FROM %table:SBF% SBF
			WHERE BF_FILIAL = %xfilial:SBF%
			AND BF_PRODUTO = %exp:SCQ->CQ_PRODUTO%
			AND BF_LOCAL = %exp:SCQ->CQ_LOCAL%
			AND BF_QUANT-BF_EMPENHO > 0  
			AND SBF.%notDel%
			ORDER BY BF_PRIOR, BF_LOCALIZ
	        */
	
			SELECT DISTINCT ORDEM,BF_LOCAL, BF_LOCALIZ,BF_LOTECTL,BF_NUMLOTE, DISPONIVEL,BF_PRIOR
			FROM (
			SELECT '2' AS ORDEM,BF_LOCAL, BF_LOCALIZ,BF_LOTECTL,BF_NUMLOTE, BF_QUANT-BF_EMPENHO AS DISPONIVEL,BF_PRIOR
			FROM %table:SBF% SBF
			WHERE BF_FILIAL = %xfilial:SBF%
			AND BF_PRODUTO = %exp:SCQ->CQ_PRODUTO%
			AND BF_LOCAL = %exp:SCQ->CQ_LOCAL%
			AND BF_QUANT-BF_EMPENHO > 0  
			AND SBF.%notDel%
			
			AND BF_LOCALIZ NOT IN
			(
			SELECT BF_LOCALIZ
			FROM %table:SBF% SBF INNER JOIN %table:SBE% SBE ON
				BF_FILIAL = BE_FILIAL
				AND BF_LOCAL = BE_LOCAL
				AND BF_LOCALIZ = BE_LOCALIZ
				AND BF_PRODUTO = BE_CODPRO
				AND SBE.D_E_L_E_T_ = ''
			WHERE BF_FILIAL = %xfilial:SBF%
			AND BF_PRODUTO = %exp:SCQ->CQ_PRODUTO%
			AND BF_LOCAL = %exp:SCQ->CQ_LOCAL%
			AND BF_QUANT-BF_EMPENHO > 0  
			AND SBF.%notDel%
			)
			
			UNION ALL
			SELECT '1' AS ORDEM,BF_LOCAL, BF_LOCALIZ,BF_LOTECTL,BF_NUMLOTE, BF_QUANT-BF_EMPENHO AS DISPONIVEL, BF_PRIOR
			FROM %table:SBF% SBF INNER JOIN %table:SBE% SBE ON
				BF_FILIAL = BE_FILIAL
				AND BF_LOCAL = BE_LOCAL
				AND BF_LOCALIZ = BE_LOCALIZ
				AND BF_PRODUTO = BE_CODPRO
				AND SBE.%notDel%
			WHERE BF_FILIAL = %xfilial:SBF%
			AND BF_PRODUTO = %exp:SCQ->CQ_PRODUTO%
			AND BF_LOCAL = %exp:SCQ->CQ_LOCAL%
			AND BF_QUANT-BF_EMPENHO > 0  
			AND SBF.%notDel%
			) AS TEMP
			ORDER BY 1, BF_PRIOR, BF_LOCALIZ
			
			ENDSQL
	
		
			While QSBF->(!Eof() .and. nSaldo > 0)
				If QSBF->DISPONIVEL >= nSaldo
					QSBF->(Aadd(aEnder,{BF_LOCAL,BF_LOCALIZ,BF_LOTECTL,BF_NUMLOTE,QSBF->DISPONIVEL}))
					nSaldo := 0
				Else
					QSBF->(Aadd(aEnder,{BF_LOCAL,BF_LOCALIZ,BF_LOTECTL,BF_NUMLOTE,QSBF->DISPONIVEL}))
					nSaldo -= QSBF->DISPONIVEL
				Endif
				QSBF->(DbSkip())
			End
			QSBF->(DbCloseArea())
		Else
			If Rastro(SCQ->CQ_PRODUTO,"L") .or. Rastro(SCQ->CQ_PRODUTO,"S")
	
				BEGINSQL ALIAS "QSB8"
				%noparser%
				
				SELECT B8_PRODUTO,B8_LOCAL,B8_LOTECTL,B8_NUMLOTE,B8_SALDO-B8_EMPENHO AS DISPONIVEL
				FROM %table:SB8% SB8
				WHERE B8_FILIAL = %xfilial:SB8%
				AND B8_PRODUTO = %exp:SCQ->CQ_PRODUTO%
				AND B8_LOCAL = %exp:SCQ->CQ_LOCAL%
				AND B8_SALDO-B8_EMPENHO > 0  
				AND SB8.%notDel%
				ORDER BY B8_DTVALID
		
				ENDSQL
			
				While QSB8->(!Eof() .and. nSaldo > 0)
					If QSB8->DISPONIVEL >= nSaldo
						QSB8->(Aadd(aEnder,{B8_LOCAL,"",B8_LOTECTL,B8_NUMLOTE,QSB8->DISPONIVEL}))
						nSaldo := 0
					Else
						QSB8->(Aadd(aEnder,{B8_LOCAL,"",B8_LOTECTL,B8_NUMLOTE,QSB8->DISPONIVEL}))
						nSaldo -= QSB8->DISPONIVEL
					Endif
					QSB8->(DbSkip())
				End
				QSB8->(DbCloseArea())
			Else
				SCQ->(Aadd(aEnder,{CQ_LOCAL,"OK","","",CQ_QUANT}))
			Endif
		Endif
			
		If len(aEnder) == 0
			VtAlert("Nao existem enderecos disponiveis para o produto" + SCQ->CQ_PRODUTO ,"Aviso",.t.,4000,3)
			VtKeyboard(Chr(20))
			
			//SCQ->(DbSkip())
			Loop
		Endif
		
		For nI:=1 to len(aEnder)
			cArmazem	:= Space(TamSX3('B1_LOCPAD')[1])
			cEndereco	:= Space(TamSX3('BF_LOCALIZ')[1])
			cProduto	:= Space(TamSX3('B1_COD')[1])
			cLoteCtl	:= Space(TamSX3('B8_LOTECTL')[1]) + Space(TamSX3('B8_NUMLOTE')[1])
			nQtde		:= 0
	
			cNada := " "
			
			VtClear()
			nTamProd := Len(Alltrim(SCQ->CQ_PRODUTO))
			cDescPro := Posicione("SB1",1,xFilial("SB1")+SCQ->CQ_PRODUTO,"B1_DESC") 
			nQtdesa := Padr(Alltrim(Transform(SCQ->CQ_QUANT,PesqPict("SCQ","CQ_QUANT"))),6)//Padr(SCQ->CQ_QUANT,4)
			
			@ 0,0 VtSay "Separe o Produto:" VtGet cNada valid fPausa(@cNada)		
			//@ 1,0 VtSay Left(SCQ->CQ_PRODUTO,20)
			@ 1,0 VtSay Padr(Alltrim(SCQ->CQ_PRODUTO)+"-"+Substr(cDescPro,1,19-nTamProd),20)
			@ 2,0 VtSay Padr(Substr(cDescPro,19-nTamProd+1,20),20)
			@ 3,0 VtSay "Qt SA: "+nQtdesa
			@ 4,0 VtSay "Qt Disp: " + Padr(Alltrim(Transform(aEnder[nI,5],PesqPict("SCQ","CQ_QUANT"))),15)
			@ 5,0 VtSay "Armazem:" + Padr(aEnder[nI,1],2)
			If lEnder
				@ 6,0 VtSay "Ender.:" + Padr(Alltrim(aEnder[nI,2]),13)
			Endif
			If Rastro(SCQ->CQ_PRODUTO,"L")
				@ 7,0 VTSay "Lote:" + Padr(aEnder[nI,3],15)
			ElseIf Rastro(SCQ->CQ_PRODUTO,"S")
				@ 7,0 VTSay "Lote:" + Padr(aEnder[nI,3]+"-"+aEnder[nI,4],15)
			EndIf
			VtRead()
			
	        
			If VtLastKey() == 27
				If VTYesNo("Confirma a saida?","Atencao",.T.)
					Return .F.
				Endif
			Endif
			
			VtClearBuffer()		
			VtClear()
			@ 0,0 VtSay "Solic.Armazem"
			@ 2,0 VTSay "Confirme Endereco"
			If lEnder
				cArmazem := Padr(aEnder[nI,1],2)
				cEndereco := Alltrim(aEnder[nI,2])
				@ 3,0 VTSay Padr(aEnder[nI,1],2)+"-"+Alltrim(aEnder[nI,2])
				@ 5,0 VTGet cArmazem pict "@!" valid ! Empty(cArmazem)
				@ 5,3 VTSay "-" VTGet cEndereco pict "@!" valid VldEnd(@cArmazem,@cEndereco,Alltrim(aEnder[nI,1]),Alltrim(aEnder[nI,2]) )
				//VTGetSetFocus("cEndereco")			
			Else
				@ 3,0 VTSay aEnder[nI,1]
				@ 5,0 VTGet cArmazem pict "@!" valid VldEnd(@cArmazem,"OK",Alltrim(aEnder[nI,1]),"OK" )		
			Endif 
			VtKeyboard(Chr(13))
			VTRead()
	
			If VtLastKey() == 27
				If VTYesNo("Confirma a saida?","Atencao",.T.)
					Return .F.
				Endif
				Loop
			Endif
	
			VtClearBuffer()		
			VtClear()
			@ 0,0 VtSay "Solic.Armazem"
			@ 1,0 VTSay "Leia o produto:"
			@ 2,0 VtSay Padr(Alltrim(SCQ->CQ_PRODUTO)+"-"+Substr(cDescPro,1,19-nTamProd),20)
			@ 3,0 VtSay Padr(Substr(cDescPro,19-nTamProd+1,20),20)
			@ 5,0 VTGet cProduto pict "@!" VALID VTLastkey() == 5 .or. VldProduto(@cProduto,SCQ->CQ_PRODUTO,cArmazem)
			VTRead()
			
			If VtLastKey() == 27
				If VTYesNo("Aponta Falta do Item?","Atencao",.T.)
					Begin Transaction
						cProduto := SCQ->CQ_PRODUTO
						If! FBaixaSA(aEnder[nI,1],aEnder[nI,2],aEnder[nI,3],aEnder[nI,4],nQtde,6)
							DisarmTransaction()
							Return
						Endif
						If !FTransf(aEnder[nI,1],aEnder[nI,2],aEnder[nI,3],aEnder[nI,4],aEnder[nI,5],cProduto)
							DisarmTransaction()
							Return
						Endif
					End Transaction
					//SCQ->(DbSkip())
					Loop
				Else
					If VTYesNo("Confirma a saida?","Atencao",.T.)
						Return .F.
					Endif
					Loop
				Endif
			Endif
	
			VtClearBuffer()		
			VtClear()
			@ 0,0 VtSay "Solic.Armazem"
			
			If Rastro(SCQ->CQ_PRODUTO,"L")
				@ 2,0 VTSay "Lote:" + aEnder[nI,3]
				@ 5,0 VTGet cLoteCtl pict "@!" VALID VTLastkey() == 5 .or. VldLote(@cLoteCtl,aEnder[nI,3])
			ElseIf Rastro(SCQ->CQ_PRODUTO,"S")
				@ 2,0 VTSay "Lote/Sublote:"
				@ 3,0 VTSay Alltrim(aEnder[nI,3])+"-"+aEnder[nI,4]
				@ 5,0 VTGet cLoteCtl pict "@!" VALID VTLastkey() == 5 .or. VldLote(@cLoteCtl,Alltrim(aEnder[nI,3])+aEnder[nI,4])
			EndIf
			VTRead()
			
			If VtLastKey() == 27
				If VTYesNo("Aponta Falta do Item?","Atencao",.T.)
					Begin Transaction
						cProduto := SCQ->CQ_PRODUTO
						If! FBaixaSA(aEnder[nI,1],aEnder[nI,2],aEnder[nI,3],aEnder[nI,4],nQtde,6)
							DisarmTransaction()
							Return
						Endif
						If !FTransf(aEnder[nI,1],aEnder[nI,2],aEnder[nI,3],aEnder[nI,4],aEnder[nI,5],cProduto)
							DisarmTransaction()
							Return
						Endif
					End Transaction
					//SCQ->(DbSkip())
					Loop
				Else
					If VTYesNo("Confirma a saida?","Atencao",.T.)
						Return .F.
					Endif
					Loop
				Endif
			Endif
	
			
			VtClearBuffer()		
			VtClear()
			@ 0,0 VtSay "Solic.Armazem" 
			@ 2,0 VtSay "Qt SA: "+nQtdesa
			@ 3,0 VTSay "Confirme Qt Separada"
			@ 4,0 VTSay Transform(aEnder[nI,5],PesqPict("SCQ","CQ_QUANT"))
			@ 5,0 VTSAY "Qtde." VTGet nQtde pict PesqPict("SCQ","CQ_QUANT") valid VTLastkey() == 5 .or. VldQtde(@nQtde,aEnder[nI,5])
			VTRead()
			
			If VtLastKey() == 27
				If VTYesNo("Aponta Falta do Item?","Atencao",.T.)
					Begin Transaction
						cProduto := SCQ->CQ_PRODUTO
						If !FBaixaSA(aEnder[nI,1],aEnder[nI,2],aEnder[nI,3],aEnder[nI,4],nQtde,6)
							DisarmTransaction()
							Return
						Endif
						If !FTransf(aEnder[nI,1],aEnder[nI,2],aEnder[nI,3],aEnder[nI,4],aEnder[nI,5],cProduto)
							DisarmTransaction()
							Return
						Endif
					End Transaction
					//SCQ->(DbSkip())
					Loop				
				Else
					If VTYesNo("Confirma a saida?","Atencao",.T.)
						Return .F.
					Endif
					//Loop
				Endif
			Endif
			VTClear()
			//FBaixaSA(cLocal,cEndereco,cLote,cSublote,nQtde)
			If !FBaixaSA(aEnder[nI,1],aEnder[nI,2],aEnder[nI,3],aEnder[nI,4],nQtde,1)
				VtAlert("Nao foi possivel realizar a requisicao. Operacao abortada" ,"Aviso",.t.,4000,3)
			Else
				//Como pode ter gerado outro registro na SCQ, vou fazer o seek novamente
				//Mas verificar se realemte ha outro registro
				nTotal -= nQtde
				If nTotal > 0
					SCQ->(DbGoTop())
					SCQ->(DbSeek(xFilial("SCQ")+cCodSA))
				Endif
			Endif
	
			//SCQ->(DbSkip()) //sempre faz skip pois mesmo qdo baixa incompleta, eh gerado outro SCQ
		Next
	End
	
	IF lMsErroAuto == .T.   
	
		VtAlert("Separacao SA "+cCodSA+" Continua em Aberto " ,"Aviso",.t.,4000,3)
    
	ELSE
	
		VtAlert("Separacao SA "+cCodSA+" Finalizada" ,"Aviso",.t.,4000,3)
	
	ENDIF

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณXACDSA    บAutor  ณMicrosiga           บ Data ณ  02/11/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Verifica se a SA ja foi pre-requisitada e em aberto        บฑฑ
ฑฑบ          ณ e pre-requisita caso ainda nao tenha sido requisitada      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function VldSA(cCodSA)
	Local lRet		:= .T.
	Local lAchou	:= .F.
	Local lSaldo	:= .F.
	Local aTela
	Local aSCPArea	:= SCP->(GetArea())
	
	If VtLastKey() == 24 .or. VtLastKey() == 13
		fConSA(@cCodSA)
	Endif
	
	If Empty(cCodSa)
		Return .F.
	Endif
	
	SCP->(DbSetOrder(1)) //CP_FILIAL+CP_NUM+CP_ITEM+DTOS(CP_EMISSAO)
	SCQ->(DbSetOrder(1)) //CQ_FILIAL+CQ_NUM+CQ_ITEM+CQ_NUMSQ
	
	If SCP->(DbSeek(xFilial("SCP")+cCodSA))
	
		IF ALLTRIM(SCP->CP_XTIPO) == 'N' .OR. ALLTRIM(SCP->CP_XTIPO) == ''
	
			While SCP->(!Eof() .and. CP_FILIAL+CP_NUM == xFilial("SCP")+cCodSA )
				If Empty(SCP->CP_STATUS) .And. SCP->CP_PREREQU == "S" .And. QtdComp(SCP->CP_QUJE) > QtdComp(0) //Parcial
					lSaldo	:= .T.
				Endif
				If !SCQ->(DbSeek(xFilial("SCQ")+SCP->(CP_NUM+CP_ITEM)))
					lAchou := .T.
					lSaldo	:= .T.
				Else
					While SCQ->(!Eof() .and. CQ_FILIAL+CQ_NUM+CQ_ITEM == SCP->(CP_FILIAL+CP_NUM+CP_ITEM))
						If Empty(SCQ->CQ_NUMREQ)
							lSaldo := .T.
						Endif
						SCQ->(DbSkip())
					End
				Endif
				SCP->(DbSkip())
		    End
		ELSE
		
			lRet := .F.
			VtAlert("S.A. de Transferencia nใo pode ser feita pelo coletor!","Aviso",.t.,4000,3)
			cCodSA := Space(TamSX3('CP_NUM')[1])
		    
		ENDIF    
	Else
		lRet := .F.
		lSaldo := .T.
		VtAlert("S.A. nao encontrada!","Aviso",.t.,4000,3)
		cCodSA := Space(TamSX3('CP_NUM')[1])
	Endif
	
	If !lSaldo 
		lRet := .F.
		VtAlert("Solicitacao ja Atendida!","Aviso",.t.,4000,3)
		cCodSA := Space(TamSX3('CP_NUM')[1])
	ElseIf lAchou
		
		/*
		aTela := VtSave()
		VTCLear()
		@ 0,0 VTSAY "S.A SEM Pre-Requisicao..."
	
		
		//Faz a pre-requisicao do item
		Pergunte("MTA106",.F.)
		cFiltraSCP := "CP_NUM = '"+cCodSA+"' "
	
		PARAMIXB1   := .F. //Obrigatorio para chamada fora do MATA106/MATA185
		PARAMIXB2   := MV_PAR01==1
		PARAMIXB3   := If(Empty(cFiltraSCP), {|| .T.}, {|| &cFiltraSCP})
		PARAMIXB4   := .F. //Nunca considerar a previsao de entrada pois a separacao do item acontecera imediatamente //MV_PAR02==1
		PARAMIXB5   := MV_PAR03==1
		PARAMIXB6   := MV_PAR04==1
		PARAMIXB7   := MV_PAR05
		PARAMIXB8   := MV_PAR06
		PARAMIXB9   := MV_PAR07==1
		PARAMIXB10  := MV_PAR08==1
		PARAMIXB11  := MV_PAR09
		PARAMIXB12  := .T.
	
		Begin Transaction
			lRet:=MaSAPreReq(PARAMIXB1,PARAMIXB2,PARAMIXB3,PARAMIXB4,PARAMIXB5,PARAMIXB6,PARAMIXB7,PARAMIXB8,PARAMIXB9,PARAMIXB10,PARAMIXB11,PARAMIXB12)
		End Transaction
		If !lRet
			VtAlert("Problemas Pre Requisicao!","Aviso",.t.,4000,3)
			cCodSA := Space(TamSX3('CP_NUM')[1])
		Endif		
		VtRestore(,,,,aTela) */
	Endif
	
	RestArea(aSCPArea)
Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณXACDSA    บAutor  ณMicrosiga           บ Data ณ  02/11/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida o endereco informado                                 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function VldEnd(cArmazem,cEndereco,cArmOri,cEndOri)
	Local aRet
	Local lErro := .F.
	Local lRet	:= .T.
	
	Default cArmazem  :=""
	Default cEndereco :=""
	
	VtClearBuffer()
	If Empty(cArmazem+cEndereco)
		VTGetSetFocus("cArmazem")
		lRet := .F.
	EndIf
	
	If lRet
		If cArmazem+cEndereco <> cArmOri+cEndOri
			VtAlert("Endereco invalido","Aviso",.T.,4000,3)
			VTClearGet("cArmazem")
			VTClearGet("cEndereco")
			VTGetSetFocus("cArmazem")
			lRet := .F.
		EndIf
	EndIf
	
	If !CBEndLib(cArmazem,cEndereco) // verifica se o endereco esta liberado ou bloqueado
		VtAlert("Endereco Bloqueado.","Aviso",.T.,4000,3)
		VTClearGet("cArmazem")
		VTClearGet("cEndereco")
		VTGetSetFocus("cArmazem")
		lRet := .F.
	EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณXACDSA    บAutor  ณMicrosiga           บ Data ณ  02/11/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para validar o produto                               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function VldProduto(cProduto,cProdOri,cArmazem)
	Local lRet := .T.
	
	Default cProduto := ""
	
	VtClearBuffer()
	If Empty(cProduto)
		VTGetSetFocus("cProduto")
		lRet := .F.
	EndIf
	
	If Alltrim(cProduto) <> Alltrim(cProdOri)
		VtAlert("Produto invalido.","Aviso",.T.,4000,3)
		VTGetSetFocus("cProduto")
		lRet := .F.
	Endif
	
	If !CBProdLib(cArmazem,cProduto,.T.)
		VTGetSetFocus("cProduto")
		lRet := .F.
	Endif
Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณXACDSA    บAutor  ณMicrosiga           บ Data ณ  02/11/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para validar o lote                                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function VldLote(cLoteCtl,cLoteOri)
	Local lRet := .T.
	
	Default cLoteCtl := ""
	
	VtClearBuffer()
	If Empty(cLoteCtl)
		VTGetSetFocus("cLoteCtl")
		lRet := .F.
	EndIf
	
	If Alltrim(cLoteCtl) <> Alltrim(cLoteOri)
		VtAlert("Lote invalido.","Aviso",.T.,4000,3)
		VTGetSetFocus("cLoteCtl")
		lRet := .F.
	Endif

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณXACDSA    บAutor  ณMicrosiga           บ Data ณ  02/11/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para validar a quantidade                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function VldQtde(nQtde,nQtdOri)
	Local lRet := .T.
	
	Default nQtde := 0
	
	VtClearBuffer()
	If Empty(nQtde)
		VTGetSetFocus("nQtde")
		lRet := .F.
	EndIf
	
	If nQtde > nQtdOri
		VtAlert("Quantidade excede solicitacao.","Aviso",.T.,4000,3)
		VTGetSetFocus("nQtde")
		lRet := .F.
	Endif

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณXACDSA    บAutor  ณMicrosiga           บ Data ณ  02/12/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para baixar a pre-requisicao da S.A.                 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FBaixaSA(cLocal,cEndereco,cLote,cSublote,nQtde,nTipo)
	Local cCodDoc	:= cCodSA //NextNumero("SD3",2,"D3_DOC",.T.)
	Local aCamposSCP
	Local aCamposSD3
	
	Default nTipo := 1
	
	VTMsg("Aguarde...")
	
	lMSHelpAuto := .F.
	lMsErroAuto := .F.
	
	
	aCamposSCP := {	{"CP_NUM"	  ,SCP->CP_NUM	   ,Nil	},;
					{"CP_ITEM"	  ,SCP->CP_ITEM    ,Nil	},; 
					{"CP_CONPRJ"  ,SCP->CP_CONPRJ  ,Nil },;
					{"CP_CODPROJ" ,SCP->CP_CODPROJ ,Nil },;
					{"CP_QUANT"	  ,nQtde		   ,Nil	}} 
	
	aCamposSD3 := {	{"D3_TM"	  ,cTMBX		   ,Nil },;
					{"D3_COD"	  ,SCP->CP_PRODUTO ,Nil },;
					{"D3_LOCAL"	  ,cLocal		   ,Nil },;
					{"D3_DOC"	  ,cCodDoc		   ,Nil },;
					{"D3_LOCALIZ" ,cEndereco	   ,'.T.' },;
					{"D3_LOTECTL" ,cLote		   ,Nil },;
					{"D3_NUMLOTE" ,cSublote		   ,Nil },; 
					{"D3_CC"	  ,SCP->CP_CC      ,Nil },;
					{"D3_PROJETO" ,SCP->CP_CONPRJ  ,Nil },;
					{"D3_CODPROJ" ,SCP->CP_CODPROJ ,Nil },;
					{"D3_CONTA"	  ,SCP->CP_CONTA   ,Nil },;
					{"D3_EMISSAO" ,dDatabase	   ,Nil } }
	Begin Transaction
	MSExecAuto({|v,x,y,z| mata185(v,x,y)},aCamposSCP,aCamposSD3,nTipo)  // 1 = BAIXA (ROT.AUT)
	End Transaction

Return !lMsErroAuto

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณXACDSA    บAutor  ณMicrosiga           บ Data ณ  02/12/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRealiza a transferencia para o endereco de perda            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fTransf(cLocal,cEndereco,cLote,cSublote,nQtde,cProduto)
	Local lRet		:= .T.
	Local aSB1Area	:= SB1->(GetArea())
	Local aSB2Area	:= SB2->(GetArea())
	Local aSB8Area	:= SB8->(GetArea())
	Local aSBEArea	:= SBE->(GetArea())
	Local lTemLote	:= .F.
	Local aAuto		:= {}
	Local aItem		:= {}
	Local cCodDoc	:= cCodSA //NextNumero("SD3",2,"D3_DOC",.T.)
	Local dValid	:= CtoD("  /  /  ")
	
	VTMsg("Aguarde...")
	
	SB1->(DbSetOrder(1)) //B1_FILIAL+B1_COD
	SB2->(DbSetOrder(1)) //B2_FILIAL+B2_COD+B2_LOCAL
	SB8->(DbSetOrder(3)) //B8_FILIAL+B8_PRODUTO+B8_LOCAL+B8_LOTECTL+B8_NUMLOTE+DTOS(B8_DTVALID)
	SBE->(DbSetOrder(1)) //BE_FILIAL+BE_LOCAL+BE_LOCALIZ 
	
	If !SB1->(DbSeek(xFilial("SB1")+cProduto))
		lRet := .F.
		VtAlert("Produto "+cProduto+" nao localizado no cadastro de produtos.","Aviso",.T.,NIL,3)
	Endif
	dValid := dDatabase+SB1->B1_PRVALID
	
	If !SB2->(DbSeek(xFilial("SB2")+cProduto+cArmTra))
		CriaSB2(SD1->D1_COD,SD1->D1_LOCAL)
	Endif
	
	If !SBE->(DbSeek(xFilial("SBE")+Alltrim(cArmTra)+ "    "+Alltrim(cEndTra)))
		SBE->(RecLock("SBE",.T.))
		SBE->BE_FILIAL	:= xFilial("SBE")
		SBE->BE_LOCAL	:= cArmTra
		SBE->BE_LOCALIZ	:= cEndTra
		SBE->BE_DESCRIC	:= cEndTra
		SBE->BE_PRIOR	:= "ZZZ"
		SBE->BE_STATUS	:= "1"
		SBE->BE_DATGER	:= dDatabase
		SBE->(MsUnlock())
	Endif
	
	If lRet
		lMsErroAuto := .F.
		lMsHelpAuto := .T.
	
		Begin Transaction
	
			If Rastro(cProduto)
				lTemlote := .T.
				SB8->(DbSeek(xFilial("SB8")+cProduto+cLocal+cLote+cSublote))
				dValid := SB8->B8_DTVALID
			EndIf
	
			aTransf:=Array(2)
			aTransf[1] := {"",dDataBase}
			
			aTransf[2]:={SB1->B1_COD,;  			  // Produto Origem
							SB1->B1_DESC,;            // Descricao origem
							SB1->B1_UM,;              // UM Origem
							cLocal,;            // Almox Origem
							cEndereco,;            // Endereco Origem
							SB1->B1_COD,;             // Produto Destino
							SB1->B1_DESC,;            // Descricao Destino
							SB1->B1_UM,;              // UM Destino
							cArmTra,;                 // Almox Destino
							Iif(Empty(cEndereco),"",cEndTra),;                 // Endereco Destino
							"",;            // Numero Serie
							cLote,;            // Lote
							cSublote,;            // Sublote
							dValid,;                  // Validade
							criavar("D3_POTENCI"),;   // Potencia
							nQtde,;            // Quantidade
							criavar("D3_QTSEGUM"),;   // Quantidade 2a. UM
							criavar("D3_ESTORNO"),;   // Estornado
							criavar("D3_NUMSEQ"),;    // Sequencia
							cLote,;            // Lote Destino
							dValid,;                  // Data Validade Destino
							CriaVar("D3_ITEMGRD") }   // Item Grade		
	
	
			//MSExecAuto({|x,y| mata261(x,y)},aAuto,3)
			MSExecAuto({|x| MATA261(x)},aTransf)
	
			If lMsErroAuto
				VTALERT("Falha na gravacao da transferencia","ERRO",.T.,4000,3)
				mostraerro()
				DisarmTransaction()
				Break
			EndIf
		End Transaction
	Endif
	
	RestArea(aSBEArea)
	RestArea(aSB8Area)
	RestArea(aSB2Area)
	RestArea(aSB1Area)
Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณXACDSA    บAutor  ณMicrosiga           บ Data ณ  03/01/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณTela de consulta no caso de nao funcionamento da ctrl+W     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fConSA(cCodSA)
	Local aITSCP	:= {}
	Local aCab		:= {}
	Local aSize		:= {}
	Local aItens	:= {}
	Local aTela 	:= VtSave()
	Local nDiasRet	:= GetMv("MV_XSADRET",.F.,30)
	Local cDataIni	:= DtoS(dDatabase - nDiasRet)
	Local cAlias	:= "QSCP"
	//'SCP->(CP_QUJE<CP_QUANT) .AND. SCP->CP_STATUS <> "E" .AND. EMPTY(SCP->CP_NUMSC) .AND. DTOS(SCP->CP_DATPRF) >= "20150101"'
	
	Aadd(aCab,'CP_NUM')
	Aadd(aCab,'CP_ITEM')
	Aadd(aCab,'CP_PRODUTO')         
	Aadd(aCab,'B1_DESC')  
	Aadd(aCab,'CP_QUANT')
	Aadd(aCab,'CP_QUJE') 
	
	Aadd(aSize,TamSx3('CP_NUM')[1])
	Aadd(aSize,TamSx3('CP_ITEM')[1])
	Aadd(aSize,TamSx3('CP_PRODUTO')[1])
	Aadd(aSize,TamSx3('B1_DESC')[1])
	Aadd(aSize,TamSx3('CP_QUANT')[1])
	Aadd(aSize,TamSx3('CP_QUJE')[1]) 
	
	
	BEGINSQL alias cAlias //depois confiro essa sintaxe
	%noparser%
	
	SELECT  CP_NUM, CP_ITEM, CP_PRODUTO, CP_QUANT, CP_QUJE
	FROM %table:SCP% SCP
	WHERE CP_FILIAL = %exp:xFilial("SCP")%
	AND CP_QUJE<CP_QUANT
	AND CP_STATUS <> 'E'       
	AND CP_PREREQU = 'S'
	AND CP_NUMSC = ''
	AND CP_DATPRF >= %exp:cDataIni%
	AND SCP.%NotDel%
	
	ENDSQL
	
	While (cAlias)->(!Eof())
		(cAlias)->(Aadd(aITSCP,CP_NUM))
		(cAlias)->(Aadd(aITSCP,CP_ITEM))
		(cAlias)->(Aadd(aITSCP,CP_PRODUTO))
		(cAlias)->(Aadd(aITSCP,Posicione("SB1",1,xFilial("SB1")+CP_PRODUTO,"B1_DESC")))
		(cAlias)->(Aadd(aITSCP,CP_QUANT))
		(cAlias)->(Aadd(aITSCP,CP_QUJE))
	
		Aadd(aItens,aClone(aITSCP))
		aITSCP := {}	
		(cAlias)->(DbSkip())
	End
	
	(cAlias)->(DbCloseArea())
	
	//Ajusta Itens
	If len(aItens) == 0
		(cAlias)->(Aadd(aITSCP,''))
		(cAlias)->(Aadd(aITSCP,''))
		(cAlias)->(Aadd(aITSCP,''))
		(cAlias)->(Aadd(aITSCP,''))
		(cAlias)->(Aadd(aITSCP,0))
		(cAlias)->(Aadd(aITSCP,0))
	
		Aadd(aItens,aClone(aITSCP))
	Endif
	//Ajusta o nome do cabecalho
	For nI:=1 to len(aCab)
		aCab[nI] := Alltrim(RetTitle(aCab[nI]))
	Next 
	     
	VtClear()
	nPos := VTaBrowse(0,0,7,15,aCab,aItens,aSize,,,," ")
	
	If VTLastkey() == 13
		cCodSA := aItens[nPos,1]
	EndIf
	
	VtRestore(,,,,aTela)
	DbClearFilter()
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณXACDSA    บAutor  ณMicrosiga           บ Data ณ  03/09/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณA funcao VTPausa pode apresentar problemas em alguns        บฑฑ
ฑฑบ          ณcoletores. Essa funcao dummy emula a VTPausa                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fPausa(cNada)
	Local lRet := .F.
	
	If VtLastKey() == 24 .or. VtLastKey() == 13
		lRet := .T.
	Endif
	cNada := " "
	
Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณXACDSA    บAutor  ณMicrosiga           บ Data ณ  08/12/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida se o endereco informado corresponde ao relacionado   บฑฑ
ฑฑบ          ณcom o produto no SBE                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function XVALENDP(cProduto,cArmazem,cEndereco)
	Local lRet 		:= .T.
	Local lRejeita	:= GetMV("MV_VLDPREN",.F.,.T.)  // Valida o endereco padrao vinculado na SBE ao produto
	Local lRetEnd 	:=  GetMV("MV_DIGEND",.F.,.T.)  // Obriga a leitura do endereco na SA
	Local cEndRet	:= ""
	Local cEndPad	:= ""

	U_ADINF009P('ADEST006P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Programa para criar as prioridades de endereco na tabela SBE e SBF')
	
	BEGINSQL ALIAS "QSBE"
	%noparser%
		
	SELECT BE_LOCALIZ, BE_LOCAL
	FROM %table:SBE% SBE
	WHERE BE_FILIAL = %xfilial:SBE%
	AND BE_CODPRO = %exp:cProduto%
	AND BE_LOCAL = %exp:cArmazem%
	/*AND BE_LOCALIZ = %exp:cEndereco%*/
	AND SBE.%notDel%
	
	ENDSQL
	
	If QSBE->(Eof())
		If !lRejeita
			//lRet := .T.
		Else
			ApMsgAlert("Produto sem endereco padrao cadastrado!")	
		Endif
	Else
		cEndPad := QSBE->BE_LOCALIZ
	Endif
	
	QSBE->(DbCloseArea())
	
	cEndereco := cEndPad
	cLocRet	:= cArmazem
	
	If IsInCallStack("ACDV060")
	        aTela := VtSave()
	        
	        cTemp := cArmazem + Alltrim(cEndereco)+Space(10)
	        VtClear()
	        
	        @ 1, 00 VtSay aTela[1,2]
	        @ 2, 00 VtSay aTela[1,3]                                                                             
			nTamProd := Len(Alltrim(cProduto))
			cDescPro := Posicione("SB1",1,xFilial("SB1")+cProduto,"B1_DESC")
			@ 3,0 VtSay "Prod." + Padr(Alltrim(cProduto)+"-"+Substr(cDescPro,1,19-nTamProd),20)
			@ 4,0 VtSay Padr(Substr(cDescPro,19-nTamProd+1,20),20)
	        @ 5, 00 VtSay aTela[1,5]
	        @ 6, 00 VtGet cTemp
	        VtRead
	        cArmazem := Substr(cTemp,1,2)
	        cEndPad := Substr(cTemp,3,len(cEndPad)-2)+space(2)
	
	        VtClear()
	        VtRestore(,,,,aTela)
	        
		If VtLastKey() == 13
			VtGetSetFocus("cArmazem")
			VtKeyboard(cArmazem) 
			VtKeyboard(cEndPad)
			VtKeyboard(Chr(83))
		Else
			lRet := .F.
			VtRestore(,,,,aTela)
			cArmazem := Space(2)
			cEndereco := Space(15)
			aHisEti := {} 
			aDist := {}
			VtGetSetFocus("cProd")
		Endif
	Endif

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณXACDSA    บAutor  ณMicrosiga           บ Data ณ  08/17/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function XVALENPD(cProduto,cArmazem,cEndereco)
	Local lRet   := .F.
	Local lRejeita := GetMV("MV_VLDPREN",.F.,.T.)
	Local cEndRet := ""

	U_ADINF009P('ADEST006P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Programa para criar as prioridades de endereco na tabela SBE e SBF')
	
	BEGINSQL ALIAS "QSBE"
	%noparser%
	 
	SELECT BE_LOCALIZ
	FROM %table:SBE% SBE
	WHERE BE_FILIAL = %xfilial:SBE%
	AND BE_CODPRO = %exp:cProduto%
	AND BE_LOCAL = %exp:cArmazem%
	/*AND BE_LOCALIZ = %exp:cEndereco%*/
	AND SBE.%notDel%
	
	ENDSQL
	
	If QSBE->(Eof())
	 If !lRejeita
	  lRet := .T.
	 Else
	  ApMsgAlert("Produto sem endereco padrao cadastrado!") 
	 Endif
	Else
	 While QSBE->(!Eof())
		If Alltrim(QSBE->BE_LOCALIZ) == Alltrim(cEndereco)
		lRet := .T.
			Exit
		ElseIf !(Alltrim(QSBE->BE_LOCALIZ) == Alltrim(cEndereco)) .and. lRejeita
			ApMsgAlert("Endereco padrao do produto " + Alltrim(QSBE->BE_LOCALIZ) + ". O endereco lido e invalido!") 
			lRet := .F.
			If IsInCallStack("ACDV060")
				VtGetSetFocus("cProd")
				ITETMP->(DbGoTop())
				ITETMP->(RecLock("ITETMP",.F.))
				ITETMP->(DbDelete())
				ITETMP->(MsUnlock())
		        cProd := Space(TamSX3('B1_COD')[1])
		        VtGetSetFocus("cProd") 
		        VtGetRefresh("cProd")
	        
				aHisEti := {} 
				aDist := {}
	        Endif
			Exit
		Endif
	  
	  QSBE->(DbSkip())
	 End
	Endif
	
	QSBE->(DbCloseArea())
	
	
Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณADEST006P บAutor  ณMicrosiga           บ Data ณ  08/18/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณPrograma de inventแrio pelo coletor sigaacd                 บฑฑ
ฑฑบ          ณprograma de inventario da ADORO                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function ADEST007P()
	Local cCodProd	:= Space(TamSX3('B1_COD')[1])
	Local cEndPad	:= Space(TamSX3('BE_LOCALIZ')[1])
	Local cLocalPad	:= Space(TamSX3('BE_LOCAL')[1])
	Local cCodOpe	:= CBRetOpe()
	Local aCab		:= {}
	Local aSize		:= {}
	Local aItens	:= {}
	Local aTela 	:= VtSave()
	
	Private cCodInv	:= Space(9)

	U_ADINF009P('ADEST006P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Programa para criar as prioridades de endereco na tabela SBE e SBF')
	
	If Empty(cCodOpe)
		VTAlert("Operador nao cadastrado","Aviso",.T.,4000,3)
		Return
	EndIf
	
	
	Aadd(aCab,'CBA_CODINV')
	Aadd(aCab,'CBA_LOCAL')
	Aadd(aCab,'CBA_LOCALI')
	
	Aadd(aSize,TamSx3('CBA_CODINV')[1])
	Aadd(aSize,TamSx3('CBA_LOCAL')[1])
	Aadd(aSize,TamSx3('CBA_LOCALI')[1])
	
	VTClear()
	@ 0,0 VtSay "Inventario ADORO S/A"
	@ 1,0 VtSay "Infome Codigo"
	@ 2,0 VtSay "do Produto"
	@ 4,0 VtGet cCodProd Valid VldCPI(@cCodProd,@cEndPad,@cLocalPad)
	VtRead
	If VtLastKey() == 27
		Return
	EndIf
	
	VTClear()
	
	If !Empty(cEndPad)
	
	
		BEGINSQL ALIAS "QCBA"
		%noparser%
			
		SELECT CBA_CODINV
		FROM %table:CBA% CBA
		WHERE CBA_FILIAL = %xfilial:CBA%
		AND CBA_STATUS IN ('0','1','2','3')
		AND CBA_LOCALI   = %EXP:cEndPad%
		AND CBA_LOCAL    = %EXP:cLocalPad%
		AND CBA.%notDel%
		ORDER BY CBA_CODINV DESC
		
		ENDSQL
		
		If QCBA->(!Eof())
			cCodInv := QCBA->CBA_CODINV
		Endif
		
		QCBA->(DbCloseArea())
	
		If Empty(cCodInv)
			ApMsgAlert("Nao existe Mestre de Inventario aberto para o endereco padrao do produto!")
			
	
			BEGINSQL ALIAS "QCBA"
			%noparser%
				
			SELECT CBA_CODINV, CBA_LOCALI
			FROM %table:CBA% CBA
			WHERE CBA_FILIAL = %xfilial:CBA%
			AND CBA_STATUS IN ('0','1','2')
			AND CBA_LOCAL    = %EXP:cLocalPad%
			AND CBA.%notDel%
			AND CBA_LOCALI IN (
				SELECT BF_LOCALIZ FROM %table:SBF% SBF 
				WHERE BF_FILIAL  = %xfilial:SBF%
				  AND BF_PRODUTO = %exp:cCodProd%
				  AND BF_LOCAL   = %EXP:cLocalPad%
				AND SBF.%notDel%
			)
			ORDER BY CBA_CODINV DESC
			
			ENDSQL
		
			aITSCP:={}
			While QCBA->(!Eof())
				QCBA->(Aadd(aITSCP,CBA_CODINV))
				QCBA->(Aadd(aITSCP,CBA_LOCALI))		
				Aadd(aItens,aClone(aITSCP))
				aITSCP := {}	
				QCBA->(DbSkip())
			End
			
			QCBA->(DbCloseArea())
			
			//Ajusta Itens
			If len(aItens) == 0
				Aadd(aITSCP,'')
				Aadd(aITSCP,'')		
				Aadd(aItens,aClone(aITSCP))
			Endif
			//Ajusta o nome do cabecalho
			For nI:=1 to len(aCab)
				aCab[nI] := Alltrim(RetTitle(aCab[nI]))
			Next 
			     
			VtClear()
			nPos := VTaBrowse(0,0,7,15,aCab,aItens,aSize,,,," ")
			VtRestore(,,,,aTela)
	
		Else
			VtKeyBoard(cCodInv)
			VtKeyBoard(Chr(13))
			VtKeyBoard(Chr(13))				
			ACDV036()
		Endif
	Endif

Return



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณXACDSA    บAutor  ณMicrosiga           บ Data ณ  08/18/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function VldCPI(cCodProd,cEndPad,cLocalPad)
	Local lRet := .F.    
	Local cEnd := ''  
	
	Local aSB1Area	:= SB1->(GetArea())
	
	If VtLastKey() == 27
		lRet := .T.
	Else            
	
		cEnd := Posicione("SBE",10,xFilial("SBE")+cCodProd,"BE_LOCALIZ")
		If !Empty(cCodProd)
			SB1->(DbSetOrder(1))
			If SB1->(DbSeek(xFilial("SB1")+cCodProd))
		
				BEGINSQL ALIAS "QSBE"
				%noparser%
				SELECT CBA_PROD,
				       CBA_LOCAL,
				       CBA_LOCALI,
				       BE_LOCALIZ, 
				       BE_LOCAL,
				       CBA_TIPINV
				  FROM %Table:CBA% CBA, 
				       %Table:SBE% SBE
				 WHERE CBA_FILIAL    = %xfilial:SBE%
				   AND CBA_LOCALI    = %EXP:cEnd%
				   AND CBA_STATUS   <= '3'
				   AND CBA.%notDel%  
				   AND CBA_FILIAL    = BE_FILIAL
				   AND CBA_LOCALI    = BE_LOCALIZ
				   AND CBA_LOCAL     = BE_LOCAL  
				   AND SBE.%notDel%
				   
	            ENDSQL
				
				If QSBE->(Eof())
					ApMsgAlert("Produto nใo esta no mestre inventแrio ou nใo existe endere็o!")	
					cCodProd := Space(TamSX3('CBA_PROD')[1])
					cEndPad  := Space(TamSX3('BE_LOCALIZ')[1])
				Else 
					IF ALLTRIM(QSBE->CBA_TIPINV) == '1'
					
						ApMsgAlert("Mestre de Inventแrio nใo pode ser Tipo Produto, somente Tipo Endere็o!")	
						cCodProd := Space(TamSX3('CBA_PROD')[1])
						cEndPad  := Space(TamSX3('BE_LOCALIZ')[1])
					
					ELSE
					
						cEndPad   := QSBE->CBA_LOCALI
						cLocalPad := QSBE->CBA_LOCAL
						lRet := .T.
						
					ENDIF
				Endif
				
				QSBE->(DbCloseArea())
			Else
				ApMsgAlert("Produto Invalido")
				cCodProd := Space(TamSX3('CBA_PROD')[1])
				cEndPad  := Space(TamSX3('BE_LOCALIZ')[1])
			Endif
		Endif
	EndIf
		
	RestArea(aSB1Area)

Return lRet