#INCLUDE 'Protheus.ch'
#INCLUDE 'FILEIO.CH'

/*{Protheus.doc} User Function ADFIN077P
	Atualiza Grupo Financeiro no Cadastro de Produtos Uso no Fluxo de Caixa.
	@type  Function
	@author ABEL BABINI FILHO
	@since 27/08/2019
	@version 01
	@history Chamado T.I - Fw Macieira 26/09/2019- Analisar motivo da reclamacao da usuaria Driele que afirma nao ter funcionado 
	@history Chamado T.I - Fernando Sigoli 24/01/2020 - Deixa atualizar o grupo dos produtos listados em txt
	@history Chamado 14092 - Leonardo P. Monteiro - 24/01/2020 - Tratamento na importação da linha dos arquivos para evitar erro do tipo "Array out of bound".
*/

User Function ADFIN077P()

	Private cArq 		:= cGetFile('Arquivo CSV|*.CSV|Arquivo *|*.CSV','Selecione arquivo',0,'C:\',.T.,GETF_LOCALHARD + GETF_NETWORKDRIVE,.T.) 
	Private lAbortPrint:=.F.

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Atualiza Grupo Financeiro no Cadastro de Produtos Uso no Fluxo de Caixa.')
	
	If Empty(cArq)
		MsgStop( "Não foi possível obter o arquivo.","Processar - ADFIN077P")
		Return Nil
	Endif
	
	nHdl := FT_FUse(cArq)
		
	If nHdl == -1
		MsgStop("Não foi possível abrir o arquivo " + Chr(13) + Chr(13) + cArq,"Função lerArquivo")
		Return Nil
	Endif

	Processa( {|| xGrpFin() }, "Aguarde...", "Atualizando Grupo Financeiro de Produtos...",.T.)
	
	AVISO("Atualiza Grupo Financeiro","Processamento Finalizado!",{"Fechar"},1)	
	
Return

Static Function xGrpFin()
	Local aDados 	:= {}
	Local nLin		:= 1

	FT_FGoTop()
	nTotLinhas := FT_FLastRec()
	ProcRegua(nTotLinhas)
	FT_FGoTop()

	While ! FT_FEof() .AND. !lAbortPrint
		cBuffer  := Alltrim(cValToChar(DecodeUTF8(FT_FReadln())))
		If !Empty(cBuffer)
			aDados	 := StrToKarr(cBuffer,";")
			//Ticket 14092 - Leonardo P. Monteiro - 24/01/2020 - Tratamento na importação da linha dos arquivos para evitar erro do tipo "Array out of bound".
			if len(aDados) >= 3
				If !Empty(aDados[1]) .AND. Alltrim(aDados[1]) == Alltrim(cEmpAnt) .AND. !Empty(aDados[2]) .AND. !Empty(aDados[3])
					If SB1->(dbSeek(xFilial("SB1")+Alltrim(aDados[2])))
						//If Empty(alltrim(SB1->B1_XGRPFIN)) .AND. Alltrim(SB1->B1_COD) == Alltrim(aDados[2]) //Chamado T.I - Fernando Sigoli 24/01/2020
						If Alltrim(SB1->B1_COD) == Alltrim(aDados[2]) //Chamado T.I - Fernando Sigoli 24/01/2020
							// Chamado TI - Durante analise, aproveitei para criar esta consistencia e gravar apenas se o cadastro existir - FWNM - 26/09/2019
							cGrpFin := STRZERO(Val(Alltrim(aDados[3])), 3, 0) 
							ZFH->( dbSetOrder(1) ) // ZFH_FILIAL + ZFH_COD
							If ZFH->( dbSeek( FWxFilial("ZFH")+PadR(cGrpFin,TamSX3("ZFH_COD")[1]) ) )
								RecLock("SB1",.F.)     
									//SB1->B1_XGRPFIN := STRZERO(Val(Alltrim(aDados[3])), 3, 0) // Chamado TI - Durante analise, aproveitei para criar esta consistencia e gravar apenas se o cadastro existir - FWNM - 26/09/2019
									SB1->B1_XGRPFIN := cGrpFin
								SB1->( MsUnlock() )
							EndIf	
						Endif
					Endif
				Endif
			else
				MsgInfo("Erro na importação da linha " + cValtochar(nLin))
			endif
		Endif
		
		IncProc("Linha: " + Str(nLin) + " | Buffer: " + cBuffer)
		aDados:= {}
		FT_FSkip()
		nLin ++
	EndDo

Return
