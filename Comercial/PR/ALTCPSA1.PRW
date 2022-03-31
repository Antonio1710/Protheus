#INCLUDE "Protheus.ch"

/*/{Protheus.doc} ALTCPSA1
	Efetua leitura de arquivo TXT e altera campos na SA1 e PB3
	@type  ALTCPSA1
	@author Mauricio - MDS TEC
	@since 03/07/2013
	@version 01
	@history Everson - 16/05/2019. Chamado 049064. Incluída a opção de atualização de pedido mínimo do cliente. 
	@history Everson - 19/01/2021. Chamado TI. Correção nas nomenclaturas dos descontos.
	@history Tkt 16833 - Leonardo P. Monteiro - 31/03/2022 - Adição da nova opção para atualização do Local de Expedição.
	/*/
User Function ALTCPSA1() // U_ALTCPSA1()

	//Variáveis.
	Local i := 1
	Private aCombo1  := {}
	Private cCombo1  := Space(2)
	Private oCombo1  := Nil
	Private _cVar    := Space(15)
	Private cComp	 := ""
	Private cClientes:= ""
	Private cTagEnvSF:= ""

	Private nCombo1  := 1
	Private cChkVar	 := ""
	Private aContra  := {}

	Private cTel2 	 := ""
	Private cTel3 	 := ""
	Private cTel4 	 := ""

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Efetua leitura de arquivo TXT e altera campos na SA1 e PB3')

	aAdd( aCombo1, "01-Telefone" )
	aAdd( aCombo1, "02-Contrato" )
	aAdd( aCombo1, "03-Segmento1" )
	aAdd( aCombo1, "04-Segmento2" )
	aAdd( aCombo1, "05-EDI" )
	aAdd( aCombo1, "06-Grp Compra" )
	aAdd( aCombo1, "07-Promotor" )
	aAdd( aCombo1, "08-Vendedor 1" )
	aAdd( aCombo1, "09-Vendedor 2" )
	aAdd( aCombo1, "10-Ag. Ligação" )
	aAdd( aCombo1, "11-Ag. vis vendendor")
	aAdd( aCombo1, "12-Ag. vis promotor")
	aAdd( aCombo1, "13-Tab Preço cliente")
	aAdd( aCombo1, "14-Rede do cliente")
	aAdd( aCombo1, "15-E-mail cliente")
	aAdd( aCombo1, "16-Contato")
	aAdd( aCombo1, "17-Tel2,Tel3,Tel4")
	aAdd( aCombo1, "18-Pedido Mínimo")
	aAdd( aCombo1, "19-Filial de Expedição")

	nTamLin  := 23 
	_cArq    := space(40)      
	nHdl     := NIL             
	cBuffer  := Space(nTamLin+1)                
	_cPath   := ""
	nOpc     := 0
	cChar    := ' '

	DEFINE MSDIALOG _oDlg TITLE OemToAnsi("Altera dados de clientes contidos no arquivo texto") From 100,0 To 225,575 PIXEL

	@ 03,020 SAY      "Arquivo TXT:"	                SIZE 030,007      OF _oDlg PIXEL
	@ 03,100 MSGet    oArq    VAR _cArq                 SIZE 100,10       OF _oDlg PIXEL
	@ 18,020 SAY      "Escolha campo p/alterar : "                        OF _oDlg PIXEL
	@ 18,100 COMBOBOX oCombo1 VAR cCombo1 ITEMS aCombo1 SIZE 100,10 PIXEL OF _oDlg on change nCombo1 := oCombo1:nAt
	@ 33,020 SAY      "Atualiza cadastro (S/N)? "	    SIZE 200,007      OF _oDlg PIXEL
	@ 33,100 MSGet    ochar   VAR cChar                 SIZE 030,10       OF _oDlg PIXEL

	DEFINE SBUTTON FROM 40,190 TYPE 1 ACTION (Processa({|lEnd|ProcArq(@lEnd)},"Aguarde","Processando registros....",.T.) ,_oDlg:End()) ENABLE OF _oDlg PIXEL
	DEFINE SBUTTON FROM 40,240 TYPE 2 ACTION ( _oDlg:End()) ENABLE OF _oDlg PIXEL

	ACTIVATE MSDIALOG  _oDlg CENTERED

Return Nil

Static Function ProcArq(lEnd)

	Local aQrbTel := {}
	Local nAux	  := 0
	Local nTotReg := 0

	AutoGrLog("LOG DE ALTERACAO DO CADASTRO DE CLIENTES")
	AutoGrLog("-------------------------------------")
	AutoGrLog(" ")
	AutoGrLog(" ")
	lArqOK := .t.

	_cNomCpo := ""

	&&definiçao conforme campo escolhido
	If nCombo1 == 1

		nTamLin  := 24            &&definido com vagner 10 caracteres
		_cNomCpo := "Telefone"

	ElseIf nCombo1 == 2

		nTamLin  := 75            &&definido com vagner 5 caracteres (00,00)
		_cNomCpo := "Contrato"

	ElseIf nCombo1 == 3

		nTamLin  := 16            &&definido com vagner 6 caracteres
		_cNomCpo := "Segmento1"

	ElseIf nCombo1 == 4

		nTamLin  := 16            &&definido com vagner 6 caracteres
		_cNomCpo := "Segmento2"  

	ElseIf nCombo1 == 5

		nTamLin  := 9            &&definido com vagner 9 caracteres
		_cNomCpo := "EDI"   

	ElseIf nCombo1 == 6

		nTamLin  := 16            &&definido com vagner 6 caracteres
		_cNomCpo := "GrpCompra"  

	ElseIf nCombo1 == 7

		nTamLin  := 16            &&definido com vagner 6 caracteres
		_cNomCpo := "Promotor" 

	ElseIf nCombo1 == 8

		nTamLin  := 23
		_cNomCpo := "Vendedor1" 

	ElseIf nCombo1 == 9

		nTamLin  := 23
		_cNomCpo := "Vendedor2" 

	ElseIf nCombo1 == 10

		nTamLin  := 23
		_cNomCpo := "AgdLiga"

	ElseIf nCombo1 == 11

		nTamLin  := 27
		_cNomCpo := "AgdVVend"

	ElseIf nCombo1 == 12

		nTamLin  := 27
		_cNomCpo := "AgdVProm"

	ElseIf nCombo1 == 13

		nTamLin  := 27
		_cNomCpo := "TabPrc"

	ElseIf nCombo1 == 14

		nTamLin  := 27
		_cNomCpo := "rede"

	ElseIf nCombo1 == 15

		nTamLin  := 70
		_cNomCpo := "email"

	ElseIf nCombo1 == 16

		nTamLin  := 100
		_cNomCpo := "contato"

	ElseIf nCombo1 == 17

		nTamLin  := 100
		_cNomCpo := "telefones"

	ElseIf nCombo1 == 18 //Everson - 16/05/2019. Chamado 049064.

		nTamLin  := 100
		_cNomCpo := "pedMinimo"
	
	ElseIf nCombo1 == 19

		nTamLin  := 14
		_cNomCpo := "LocalExpedicao"

	EndIf

	//
	If _cNomCpo $("AgdVProm/AgdVVend/AgdLiga")
		MsgStop("Opção indisponível.","Função ALTCPSA1")
		Return Nil

	EndIf

	//
	If !MsgYesNo("Serão importados os dados de " + _cNomCpo + ". Deseja prosseguir?","Função ALTCPSA1")
		Return Nil

	EndIf      

	//nHdl := fOpen(_cArq,2) 
	nHdl := FT_FUse(_cArq) 

	//
	If nHdl == -1
		AutoGrLog("NAO FOI POSSIVEL ABRIR O ARQUIVO "+_cArq)
		lArqOK := .f.

	Else

		nlin := 1
		nTotReg := FT_FLastRec()
		ProcRegua( nTotReg )
		FT_FGoTop()
		While ! FT_FEof()

			If lEnd 

				_cFileLog := Left(_cArq,At(".",_cArq)-1)+".LOG"
				_cFileLog := Alltrim(Substr(_cFileLog,RAt("\",_cFileLog)+1,20))
				_cPath    := Substr(_cArq,1,RAt("\",_cArq))

				If nHdl <> -1
					FT_FUse(_cArq)

				EndIf

				MsgStop("Cancelado pelo usuário.", "Função ALTCPSA1") 

				MostraErro(_cPath,_cFileLog)

				Return Nil

			EndIf 

			cBuffer  := DecodeUTF8(FT_FReadln())

			_cCod    := Substr(cBuffer,1,6)
			_cLoja   := Substr(cBuffer,8,2)
			nAux++

			IncProc("Prc. " + cValToChar(nCombo1) + "-"  +  _cNomCpo + " | " + _cCod + "-" + _cLoja )

			&&atualiza SA1
			DbSelectArea("SA1")
			SA1->(DbSetOrder(1))
			SA1->(DbGoTop())

			If !DbSeek(xfilial("SA1")+_cCod+_cLoja)

				AutoGrLog("Linha "+strzero(nlin,5)+" Cliente "+_cCod+_cLoja+" nao encontrado na SA1.")
				lArqOk := .f.

			Else

				If _cNomCpo == "Telefone"

					_cDdd := Substr(cBuffer,11,3)
					_cVar := Substr(cBuffer,15,10)

					If Upper(cChar) = 'S'

						If Reclock("SA1",.f.)

							SA1->A1_DDD   := _cDdd
							SA1->A1_TEL   := _cVar
							Msunlock()

							logZBE("Linha "+strzero(nlin,5)+" Cliente "+_cCod+_cLoja+" "+SA1->A1_NOME+" Alterado campo "+_cNomCpo+" na SA1, conteudo: "+_cDdd+_cVar,"CLIENTE: " + SA1->A1_COD + " " +SA1->A1_LOJA)

							AutoGrLog("Linha "+strzero(nlin,5)+" Cliente "+_cCod+_cLoja+" "+SA1->A1_NOME+" Alterado campo "+_cNomCpo+" na SA1, conteudo: "+_cDdd+_cVar)
							cClientes += "'" + Alltrim(cValToChar(_cCod)) + Alltrim(cValToChar(_cLoja)) + "',"
							cTagEnvSF := "TEL"

						EndIf

					EndIf 

					&&Atualiza PB3
					DbSelectArea("PB3")
					PB3->(DbSetOrder(11))

					If ! PB3->(DbSeek(xfilial("PB3")+_cCod+_cLoja))

						AutoGrLog("Linha "+strzero(nlin,5)+" Cliente "+_cCod+_cLoja+" nao encontrado na PB3.")
						lArqOk := .f.

					Else

						If Reclock("PB3",.f.)

							PB3->PB3_DDD   := _cDdd
							PB3->PB3_TEL   := _cVar
							Msunlock()
							AutoGrLog("Linha "+strzero(nlin,5)+" Cliente "+_cCod+_cLoja+" "+PB3->PB3_NOME+" Alterado campo "+_cNomCpo+" na PB3, conteudo: "+_cDdd+_cVar)

						EndIf
					EndIf	  

				ElseIf _cNomCpo ==  "Promotor"   

					_cVar := Substr(cBuffer,11,6)

					cChkVar := Alltrim(cValToChar(Posicione("ZC4",1,xFilial("ZC4") + _cVar , "ZC4_COD")))
					If Empty(cChkVar)
						MsgStop("Promotor não encontrado " + cValToChar(_cVar) + ".","Função ALTCPSA1")
						FT_FSkip()
						Loop

					EndIf

					If Upper(cChar) = 'S'

						If Reclock("SA1",.f.)

							SA1->A1_XPROMOT   := _cVar
							Msunlock()

							logZBE("Linha "+strzero(nlin,5)+" Cliente "+_cCod+_cLoja+" "+SA1->A1_NOME+" Alterado campo "+_cNomCpo+" na SA1, conteudo: "+_cVar,"CLIENTE: " + SA1->A1_COD + " " +SA1->A1_LOJA)

							AutoGrLog("Linha "+strzero(nlin,5)+" Cliente "+_cCod+_cLoja+" "+SA1->A1_NOME+" Alterado campo "+_cNomCpo+" na SA1, conteudo: "+_cVar)
							cClientes += "'" + Alltrim(cValToChar(_cCod)) + Alltrim(cValToChar(_cLoja)) + "',"
							cTagEnvSF := "PRT"

						EndIf 

					EndIf  

					&&Atualiza PB3
					DbSelectArea("PB3")
					PB3->(DbSetOrder(11))

					If ! PB3->(DbSeek(xfilial("PB3")+_cCod+_cLoja))

						AutoGrLog("Linha "+strzero(nlin,5)+" Cliente "+_cCod+_cLoja+" nao encontrado na PB3.")
						lArqOk := .f.

					Else

						If Reclock("PB3",.f.)

							PB3->PB3_PROMOT := _cVar
							Msunlock()
							AutoGrLog("Linha "+strzero(nlin,5)+" Cliente "+_cCod+_cLoja+" "+PB3->PB3_NOME+" Alterado campo "+_cNomCpo+" na PB3, conteudo: "+_cVar)

						EndIf
					EndIf	 

				ElseIf _cNomCpo ==  "GrpCompra"   

					_cVar := Substr(cBuffer,11,6)

					If Upper(cChar) = 'S'

						If Reclock("SA1",.f.)

							Replace SA1->A1_XGRPCOM With _cVar

							logZBE("Linha "+strzero(nlin,5)+" Cliente "+_cCod+_cLoja+" "+SA1->A1_NOME+" Alterado campo "+_cNomCpo+" na SA1","CLIENTE: " + SA1->A1_COD + " " +SA1->A1_LOJA)

							AutoGrLog("Linha "+strzero(nlin,5)+" Cliente "+_cCod+_cLoja+" "+SA1->A1_NOME+" Alterado campo "+_cNomCpo+" na SA1, conteudo: "+_cVar)
							cClientes += "'" + Alltrim(cValToChar(_cCod)) + Alltrim(cValToChar(_cLoja)) + "'," 
							cTagEnvSF := "GRPC"

						EndIf  

					EndIf 

					&&Atualiza PB3
					DbSelectArea("PB3")
					PB3->(DbSetOrder(11))

					If ! PB3->(DbSeek(xfilial("PB3")+_cCod+_cLoja))

						AutoGrLog("Linha "+strzero(nlin,5)+" Cliente "+_cCod+_cLoja+" nao encontrado na PB3.")
						lArqOk := .f.

					Else

						If Reclock("PB3",.f.)

							Replace PB3->PB3_XGRPCO With _cVar

							AutoGrLog("Linha "+strzero(nlin,5)+" Cliente "+_cCod+_cLoja+" "+PB3->PB3_NOME+" Alterado campo "+_cNomCpo+" na PB3, conteudo: "+_cVar)

						EndIf

					EndIf		                    

				ElseIf _cNomCpo == "Contrato"  

					_cVar := Val(Substr(cBuffer,11,5))/100			   

					If Upper(cChar) = 'S'	

						//Everson - 13/12/2017. Chamado - 038633.
						logZBE("Alteração de desconto comercial (A1_DESC) de " + Alltrim(cValToChar(SA1->A1_DESC)) + " para " + Alltrim(cValToChar(_cVar)) + " ","CLIENTE:" + Alltrim(cValToChar(SA1->A1_COD)) + "-" + Alltrim(cValToChar(SA1->A1_LOJA)) )

						//Everson - 19/01/2021. Chamado TI.
						cComp := "" 
						cComp += "Aniversário" + ": "      + cValToChar( Val(Substr(cBuffer,29,5))/100) + " %" + Chr(13) + Chr(10)
						cComp += "Inauguração" + ": "       + cValToChar( Val(Substr(cBuffer,59,5))/100 ) + " %" + Chr(13) + Chr(10)

						cComp += "Fornecimento" + ": "       + cValToChar( Val(Substr(cBuffer,17,5))/100 ) + " %" + Chr(13) + Chr(10)
						cComp += "Logística" + ": "       + cValToChar( Val(Substr(cBuffer,23,5))/100 ) + " %" + Chr(13) + Chr(10)
						cComp += "Reinauguração" + ": "     + cValToChar( Val(Substr(cBuffer,41,5))/100 ) + " %" + Chr(13) + Chr(10)


						cComp += "Quebra/Troca" + ": "         + cValToChar( Val(Substr(cBuffer,35,5))/100 ) + " %" + Chr(13) + Chr(10)

						cComp += "Associação" + ": "      + cValToChar( Val(Substr(cBuffer,47,5))/100 ) + " %" + Chr(13) + Chr(10)
						cComp += "Crescimento" + ": " + cValToChar( Val(Substr(cBuffer,65,5))/100 ) + " %" + Chr(13) + Chr(10)

						cComp += "Verba Inv. Coorp." + ": "               + cValToChar( Val(Substr(cBuffer,71,5))/100 ) + " %" + Chr(13) + Chr(10)
						cComp += "Web" + ": "        + cValToChar( Val(Substr(cBuffer,53,5))/100 ) + " %" + Chr(13) + Chr(10)

						If Reclock("SA1",.f.)

							SA1->A1_XCCUSTC :=  cComp
							SA1->A1_DESC    := _cVar
							Msunlock()
							AutoGrLog("Linha "+strzero(nlin,5)+" Cliente "+_cCod+_cLoja+" "+SA1->A1_NOME+" Alterado campo "+_cNomCpo+" na SA1, conteudo: "+Alltrim(STR(_cVar)))
							cClientes += "'" + Alltrim(cValToChar(_cCod)) + Alltrim(cValToChar(_cLoja)) + "',"

							Aadd(aContra,{Alltrim(cValToChar(_cCod)) + Alltrim(cValToChar(_cLoja))})

						EndIf

					EndIf   

				ElseIf _cNomCpo == "Segmento1"

					_cVar := Substr(cBuffer,11,6)

					If Upper(cChar) = 'S'	

						If Reclock("SA1",.f.)
							SA1->A1_SATIV1   := _cVar
							AutoGrLog("Linha "+strzero(nlin,5)+" Cliente "+_cCod+_cLoja+" "+SA1->A1_NOME+" Alterado campo "+_cNomCpo+" na SA1, de: "+SA1->A1_SATIV1+" para: "+_cVar)

							logZBE("CAMPO A1_SATIV1 DE " + SA1->A1_SATIV1 + " PARA "+ _cVar,"CLIENTE: " + SA1->A1_COD + " " +SA1->A1_LOJA)

							Msunlock()

						EndIf  

					EndIf	

					&&Atualiza PB3
					DbSelectArea("PB3")
					PB3->(DbSetOrder(11))

					If ! PB3->(DbSeek(xfilial("PB3")+_cCod+_cLoja))                                                  

						AutoGrLog("Linha "+strzero(nlin,5)+" Cliente "+_cCod+_cLoja+" nao encontrado na PB3.")
						lArqOk := .f.

					Else

						If Reclock("PB3",.f.)

							AutoGrLog("Linha "+strzero(nlin,5)+" Cliente "+_cCod+_cLoja+" "+PB3->PB3_NOME+" Alterado campo "+_cNomCpo+" na PB3, de: "+PB3->PB3_SEGTO+" para: "+_cVar)
							PB3->PB3_SEGTO   := _cVar
							Msunlock()

						EndIf
					EndIf		

				ElseIf _cNomCpo == "Segmento2"

					_cVar := Substr(cBuffer,11,6)

					If Upper(cChar) = 'S'

						If Reclock("SA1",.f.)

							AutoGrLog("Linha "+strzero(nlin,5)+" Cliente "+_cCod+_cLoja+" "+SA1->A1_NOME+" Alterado campo "+_cNomCpo+" na SA1, de: "+SA1->A1_SATIV2+" para: "+_cVar)
							SA1->A1_SATIV2   := _cVar

							logZBE("CAMPO A1_SATIV2 DE " + SA1->A1_SATIV2 + " PARA "+ _cVar,"CLIENTE: " + SA1->A1_COD + " " +SA1->A1_LOJA)

							Msunlock()

						EndIf              				  

					EndIf

					&&Atualiza PB3
					DbSelectArea("PB3")
					PB3->(DbSetOrder(11))

					If ! PB3->(DbSeek(xfilial("PB3")+_cCod+_cLoja))   

						AutoGrLog("Linha "+strzero(nlin,5)+" Cliente "+_cCod+_cLoja+" nao encontrado na PB3.")
						lArqOk := .f.

					Else

						If Reclock("PB3",.f.)

							AutoGrLog("Linha "+strzero(nlin,5)+" Cliente "+_cCod+_cLoja+" "+PB3->PB3_NOME+" Alterado campo "+_cNomCpo+" na PB3, de: "+PB3->PB3_SUBSEG+" para: "+_cVar)
							PB3->PB3_SUBSEG   := _cVar
							Msunlock()

						EndIf
					EndIf

				ElseIf _cNomCpo == "EDI"

					If Upper(cChar) = 'S'	

						If Reclock("SA1",.f.)

							AutoGrLog("Linha "+strzero(nlin,5)+" Cliente "+_cCod+_cLoja+" "+SA1->A1_NOME+" Alterado campo "+_cNomCpo+" na SA1, de: "+CVALTOCHAR(SA1->A1_XEDI)+" para: " + ".T.")

							logZBE("Linha "+strzero(nlin,5)+" Cliente "+_cCod+_cLoja+" "+SA1->A1_NOME+" Alterado campo "+_cNomCpo+" na SA1, de: "+CVALTOCHAR(SA1->A1_XEDI)+" para: " + ".T.","CLIENTE:" + Alltrim(cValToChar(SA1->A1_COD)) + "-" + Alltrim(cValToChar(SA1->A1_LOJA)))

							SA1->A1_XEDI   := .T.
							Msunlock()

						EndIf

					EndIf 

				ElseIf _cNomCpo == "Vendedor1"

					cVend    := Substr(cBuffer,11,6)
					cIDVend  := Substr(cBuffer,18,6)

					cChkVar := Alltrim(cValToChar(Posicione("SA3",1,xFilial("SA3") + cVend , "A3_COD")))
					If Empty(cChkVar)
						MsgStop("Promotor não encontrado " + cValToChar(cVend) + ".","Função ALTCPSA1")
						FT_FSkip()
						Loop

					EndIf

					If Upper(cChar) = 'S'
						If Reclock("SA1",.f.)
							SA1->A1_VEND   := cVend
							Msunlock()
							cClientes += "'" + Alltrim(cValToChar(_cCod)) + Alltrim(cValToChar(_cLoja)) + "'," 
							cTagEnvSF := "VND"

							logZBE("CAMPO A1_VEND DE " + SA1->A1_VEND + " PARA "+ cVend,"CLIENTE: " + SA1->A1_COD + " " +SA1->A1_LOJA)

						EndIf

					EndIf

					AutoGrLog("Linha "+strzero(nlin,5)+" Cliente "+_cCod+_cLoja+" "+SA1->A1_NOME+" VEND1 PARA: "+cvend+" na SA1")

					// Atualiza a PB3  Alex Borges 28/06/2012
					DbSelectArea("PB3")
					PB3->(DbSetOrder(11))
					If ! PB3->(DbSeek(xfilial("PB3")+_cCod+_cLoja))
						AutoGrLog("Linha "+strzero(nlin,5)+" Cliente "+_cCod+_cLoja+" nao encontrado na PB3.")
						lArqOk := .f.
					Else
						AutoGrLog("Linha "+strzero(nlin,5)+" Cliente "+_cCod+_cLoja+" "+PB3_NOME+"  VEND1 DE: "+PB3_VEND+" na PB3")

						cVend    := Substr(cBuffer,11,6)
						cIDVend  := Substr(cBuffer,18,6)

						If Upper(cChar) = 'S'
							If Reclock("PB3",.f.)
								PB3->PB3_VEND     := cIDVend  //Id do vendedor
								PB3->PB3_CODVEN   := cVend	  //Codigo do vendedor
								Msunlock()
							EndIf

						EndIf

						//AutoGrLog("Linha "+strzero(nlin,5)+" Cliente "+_cCod+_cLoja+" "+SA1->A1_NOME+" PARA: "+cvend+"na PB3")
						lArqOk := .f.
					EndIf

				ElseIf  _cNomCpo == "Vendedor2"

					cVend    := Substr(cBuffer,11,6)
					cIDVend  := Substr(cBuffer,18,6)

					cChkVar := Alltrim(cValToChar(Posicione("SA3",1,xFilial("SA3") + cVend , "A3_COD")))
					If Empty(cChkVar)
						MsgStop("Promotor não encontrado " + cValToChar(cVend) + ".","Função ALTCPSA1")
						FT_FSkip()
						Loop

					EndIf

					If Upper(cChar) = 'S'

						If Reclock("SA1",.f.)
							SA1->A1_XVEND2   := cVend
							Msunlock()
							cClientes += "'" + Alltrim(cValToChar(_cCod)) + Alltrim(cValToChar(_cLoja)) + "'," 
							cTagEnvSF := "VND"

							logZBE("CAMPO A1_XVEND2 DE " + SA1->A1_XVEND2 + " PARA "+ cVend, "CLIENTE: " + SA1->A1_COD + " " +SA1->A1_LOJA)

						EndIf

					EndIf

					// Atualiza a PB3  Alex Borges 28/06/2012
					DbSelectArea("PB3")
					PB3->(DbSetOrder(11))
					If ! PB3->(DbSeek(xfilial("PB3")+_cCod+_cLoja))
						AutoGrLog("Linha "+strzero(nlin,5)+" Cliente "+_cCod+_cLoja+" nao encontrado na PB3.")
						lArqOk := .f.
					Else
						AutoGrLog("Linha "+strzero(nlin,5)+" Cliente "+_cCod+_cLoja+" "+PB3_NOME+"  VEND2 DE: "+PB3_XVEND2+" na PB3")

						cVend    := Substr(cBuffer,11,6)
						cIDVend  := Substr(cBuffer,18,6)

						If Upper(cChar) = 'S'
							If Reclock("PB3",.f.)
								//PB3->PB3_VEND     := cIDVend  //Id do vendedor     &&Conforme definido com Adriana(21/09/16) o ID do vendedor 2 nao sera atualizado(Campo nao existe).
								PB3->PB3_XVEND2  := cVend	  //Codigo do vendedor
								Msunlock()
							EndIf

						EndIf

						lArqOk := .f.

					EndIf

				ElseIf _cNomCpo == "AgdLiga"


					/*DbSelectArea("PB3")
					PB3->(DbSetOrder(11))
					If ! PB3->(DbSeek(xfilial("PB3")+_cCod+_cLoja))
					AutoGrLog("Linha "+strzero(nlin,5)+" Cliente "+_cCod+_cLoja+" nao encontrado na PB3.")
					lArqOk := .f.
					Else

					If Upper(cChar) = 'S'

					If Reclock("PB3",.f.)
					Replace PB3_TELSEG	With Substr(cBuffer,11,1)
					Replace PB3_TELTER	With Substr(cBuffer,13,1)
					Replace PB3_TELQUA	With Substr(cBuffer,15,1)
					Replace PB3_TELQUI	With Substr(cBuffer,17,1)
					Replace PB3_TELSEX	With Substr(cBuffer,19,1)
					Replace PB3_LIGFRQ	With Substr(cBuffer,21,1)
					Replace PB3_LIGSEM	With Substr(cBuffer,23,1)
					Replace PB3_LIGHOR	With Substr(cBuffer,25,5)
					MsUnlock()

					//Grava na tabela agendamento.								
					U_ADVEN029P(xFilial("SA1"),_cCod,_cLoja,3) 

					logZBE("Linha "+strzero(nlin,5)+" Cliente "+_cCod+_cLoja+" "+SA1->A1_NOME+" Alterado campo "+_cNomCpo+" na SA1, agendamento ligação ","CLIENTE:" + Alltrim(cValToChar(SA1->A1_COD)) + "-" + Alltrim(cValToChar(SA1->A1_LOJA)))

					//
					cClientes += "'" + Alltrim(cValToChar(_cCod)) + Alltrim(cValToChar(_cLoja)) + "'," 
					cTagEnvSF := "AGLIG"
					AutoGrLog("Linha "+strzero(nlin,5)+" Cliente "+_cCod+_cLoja+" "+PB3->PB3_NOME+" Alterado campo "+_cNomCpo+" na PB3")

					EndIf

					EndIf

					EndIf*/

				ElseIf _cNomCpo == "AgdVVend"

					/*DbSelectArea("PB3")
					PB3->(DbSetOrder(11))
					If ! PB3->(DbSeek(xfilial("PB3")+_cCod+_cLoja))
					AutoGrLog("Linha "+strzero(nlin,5)+" Cliente "+_cCod+_cLoja+" nao encontrado na PB3.")
					lArqOk := .f.
					Else

					If Upper(cChar) = 'S'

					If Reclock("PB3",.f.)
					Replace PB3_VEDSEG	With Substr(cBuffer,11,1)
					Replace PB3_VEDTER	With Substr(cBuffer,13,1)
					Replace PB3_VEDQUA	With Substr(cBuffer,15,1)
					Replace PB3_VEDQUI	With Substr(cBuffer,17,1)
					Replace PB3_VEDSEX	With Substr(cBuffer,19,1)
					Replace PB3_VEDFRQ	With Substr(cBuffer,21,1)
					Replace PB3_VRDSEM	With Substr(cBuffer,23,1)
					Replace PB3_VEDHOR	With Substr(cBuffer,25,5)
					MsUnlock()

					//Grava na tabela agendamento.
					U_ADVEN057P(xFilial("SA1"),_cCod,_cLoja,3,"V") 

					logZBE("Linha "+strzero(nlin,5)+" Cliente "+_cCod+_cLoja+" "+SA1->A1_NOME+" Alterado campo "+_cNomCpo+" na SA1, agendamento vendedor ","CLIENTE:" + Alltrim(cValToChar(SA1->A1_COD)) + "-" + Alltrim(cValToChar(SA1->A1_LOJA)))

					//
					cClientes += "'" + Alltrim(cValToChar(_cCod)) + Alltrim(cValToChar(_cLoja)) + "'," 
					cTagEnvSF := "AGVEND"
					AutoGrLog("Linha "+strzero(nlin,5)+" Cliente "+_cCod+_cLoja+" "+PB3->PB3_NOME+" Alterado campo "+_cNomCpo+" na PB3")

					EndIf

					EndIf

					EndIf*/

				ElseIf _cNomCpo == "AgdVProm"

					/*DbSelectArea("PB3")
					PB3->(DbSetOrder(11))
					If ! PB3->(DbSeek(xfilial("PB3")+_cCod+_cLoja))
					AutoGrLog("Linha "+strzero(nlin,5)+" Cliente "+_cCod+_cLoja+" nao encontrado na PB3.")
					lArqOk := .f.
					Else

					If Upper(cChar) = 'S'

					If Reclock("PB3",.f.)
					Replace PB3_PRMSEG	With Substr(cBuffer,11,1)
					Replace PB3_PRMTER	With Substr(cBuffer,13,1)
					Replace PB3_PRMQUA	With Substr(cBuffer,15,1)
					Replace PB3_PRMQUI	With Substr(cBuffer,17,1)
					Replace PB3_PRMSEX	With Substr(cBuffer,19,1)
					Replace PB3_PRMSAB	With Substr(cBuffer,21,1)
					Replace PB3_PRMFRQ	With Substr(cBuffer,23,1)
					Replace PB3_PRMSEM	With Substr(cBuffer,25,1)
					Replace PB3_PRMHOR	With Substr(cBuffer,27,5)
					MsUnlock()

					//Grava na tabela agendamento.
					U_ADVEN057P(xFilial("SA1"),_cCod,_cLoja,3,"P") 

					logZBE("Linha "+strzero(nlin,5)+" Cliente "+_cCod+_cLoja+" "+SA1->A1_NOME+" Alterado campo "+_cNomCpo+" na SA1, agendamento promotor ","CLIENTE:" + Alltrim(cValToChar(SA1->A1_COD)) + "-" + Alltrim(cValToChar(SA1->A1_LOJA)))

					//
					cClientes += "'" + Alltrim(cValToChar(_cCod)) + Alltrim(cValToChar(_cLoja)) + "'," 
					cTagEnvSF := "AGPRM"
					AutoGrLog("Linha "+strzero(nlin,5)+" Cliente "+_cCod+_cLoja+" "+PB3->PB3_NOME+" Alterado campo "+_cNomCpo+" na PB3")

					EndIf

					EndIf

					EndIf*/

				ElseIf _cNomCpo ==  "TabPrc"

					_cVar := Substr(cBuffer,11,4)

					cChkVar := Alltrim(cValToChar(Posicione("DA0",1,xFilial("DA0") + _cVar , "DA0_CODTAB")))
					If Empty(cChkVar)
						MsgStop("Tabela de preço não encontrada " + cValToChar(_cVar) + ".","Função ALTCPSA1")
						FT_FSkip()
						Loop

					EndIf

					If Upper(cChar) = 'S'

						If Reclock("SA1",.f.)

							SA1->A1_TABELA   := _cVar
							Msunlock()
							AutoGrLog("Linha "+strzero(nlin,5)+" Cliente "+_cCod+_cLoja+" "+SA1->A1_NOME+" Alterado campo "+_cNomCpo+" na SA1, conteudo: "+_cVar)

							logZBE("Linha "+strzero(nlin,5)+" Cliente "+_cCod+_cLoja+" "+SA1->A1_NOME+" Alterado campo "+_cNomCpo+" na SA1, conteudo: "+_cVar,"CLIENTE:" + Alltrim(cValToChar(SA1->A1_COD)) + "-" + Alltrim(cValToChar(SA1->A1_LOJA)))

							cClientes += "'" + Alltrim(cValToChar(_cCod)) + Alltrim(cValToChar(_cLoja)) + "',"
							cTagEnvSF := "TABPRC"

						EndIf 

					EndIf  

				ElseIf _cNomCpo ==  "rede"

					_cVar := Substr(alltrim(cBuffer),11,6)

					If cChar = 'S'	
						If Reclock("SA1",.f.)
							SA1->A1_REDE   := _cVar
							Msunlock()

							AutoGrLog("Linha "+strzero(nlin,5)+" Cliente "+_cCod+_cLoja+" "+SA1->A1_NOME+" REDE PARA: "+_cVar)
							logZBE("Linha "+strzero(nlin,5)+" Cliente "+_cCod+_cLoja+" "+Alltrim(cValToChar(SA1->A1_NOME))+" REDE PARA: "+_cVar,"CLIENTE:" + Alltrim(cValToChar(SA1->A1_COD)) + "-" + Alltrim(cValToChar(SA1->A1_LOJA)))

							cClientes += "'" + Alltrim(cValToChar(_cCod)) + Alltrim(cValToChar(_cLoja)) + "',"
							cTagEnvSF := "REDECLI"

						EndIf                

					EndIf

				ElseIf _cNomCpo ==  "email" 

					_cVar := Substr(cBuffer,11,70)

					If cChar = 'S'

						If Reclock("SA1",.f.)
							SA1->A1_EMAIL   := ALLTRIM(_cVar)
							Msunlock()
							dbselectarea("PB3")
							dbsetorder(11)
							If dbseek (xFilial("PB3")+_cCod+_cLoja)

								Reclock("PB3",.F.)
								PB3->PB3_EMAIL   := ALLTRIM(_cVar)
								Msunlock()					
							Endif
							AutoGrLog("Linha "+strzero(nlin,5)+" Cliente "+_cCod+_cLoja+" "+SA1->A1_NOME+" EMAIL PARA: "+Alltrim(_cVar))
							logZBE("Linha "+strzero(nlin,5)+" Cliente "+_cCod+_cLoja+" "+SA1->A1_NOME+" EMAIL PARA: "+Alltrim(_cVar),"CLIENTE:" + Alltrim(cValToChar(SA1->A1_COD)) + "-" + Alltrim(cValToChar(SA1->A1_LOJA)))

							cClientes += "'" + Alltrim(cValToChar(_cCod)) + Alltrim(cValToChar(_cLoja)) + "',"
							cTagEnvSF := "EMAIL"	

						EndIf                

					EndIf

				ElseIf _cNomCpo ==  "contato"

					_cVar := Substr(cBuffer,11,100)

					If cChar = 'S'

						If Reclock("SA1",.f.)
							SA1->A1_CONTATO   := ALLTRIM(_cVar)
							Msunlock()
							dbselectarea("PB3")
							dbsetorder(11)
							If dbseek (xFilial("PB3")+_cCod+_cLoja)

								Reclock("PB3",.F.)
								PB3->PB3_CONTAT   := ALLTRIM(_cVar)
								Msunlock()					
							Endif
							AutoGrLog("Linha "+strzero(nlin,5)+" Cliente "+_cCod+_cLoja+" "+SA1->A1_NOME+" CONTATO PARA: "+Alltrim(_cVar))
							logZBE("Linha "+strzero(nlin,5)+" Cliente "+_cCod+_cLoja+" "+SA1->A1_NOME+" CONTATO PARA: "+Alltrim(_cVar),"CLIENTE:" + Alltrim(cValToChar(SA1->A1_COD)) + "-" + Alltrim(cValToChar(SA1->A1_LOJA)))	

						EndIf                

					EndIf

				ElseIf _cNomCpo ==  "telefones"		

					aQrbTel := SEPARA(Alltrim(cValToChar(cBuffer)),";",.T.)//StrToKarr(Alltrim(cValToChar(cBuffer)),";")
					cTel2 := StrTran(Alltrim(cValToChar(aQrbTel[3]))," ","")
					cTel3 := StrTran(Alltrim(cValToChar(aQrbTel[4]))," ","")
					cTel4 := StrTran(Alltrim(cValToChar(aQrbTel[5]))," ","")

					If cChar = 'S'

						If Reclock("SA1",.f.)
							SA1->A1_TEL2 := cTel2
							SA1->A1_TEL3 := cTel3
							SA1->A1_TEL4 := cTel4
							Msunlock()

							dbselectarea("PB3")
							dbsetorder(11)
							If dbseek (xFilial("PB3")+_cCod+_cLoja)

								Reclock("PB3",.F.)
								PB3->PB3_TEL2   := cTel2
								PB3->PB3_TEL3   := cTel3
								PB3->PB3_TEL4   := cTel4
								Msunlock()					
							Endif

							AutoGrLog("Linha "+strzero(nlin,5)+" Cliente "+_cCod+_cLoja+" "+SA1->A1_NOME+" TEL2,TEL3,TEL4 PARA: " + (cTel2 + " " + cTel3 + " " + cTel4) )
							logZBE("Linha "+strzero(nlin,5)+" Cliente "+_cCod+_cLoja+" "+SA1->A1_NOME+" TEL2,TEL3,TEL4 PARA: " + (cTel2 + " " + cTel3 + " " + cTel4),"CLIENTE:" + Alltrim(cValToChar(SA1->A1_COD)) + "-" + Alltrim(cValToChar(SA1->A1_LOJA)))	

						EndIf                

					EndIf	
				
				//Everson - 16/05/2019. Chamado 049064.	
				ElseIf _cNomCpo ==  "pedMinimo" 
				
					//
					aVlrPed := SEPARA(Alltrim(cValToChar(cBuffer)),";",.T.)	
					nValor  := Val(StrTran(StrTran( cValToChar(aVlrPed[3]), ".", "" ),",","."))
					
					//
					If cChar = 'S'
					
						If Reclock("SA1",.F.)
							SA1->A1_XPEDMIN := nValor	
							Msunlock()

							AutoGrLog("Linha "+strzero(nlin,5)+" Cliente "+_cCod+_cLoja+" "+SA1->A1_NOME+" PED MIN PARA: " + cValToChar(aVlrPed[3]) )
							logZBE("Linha "+strzero(nlin,5)+" Cliente "+_cCod+_cLoja+" "+SA1->A1_NOME+" PED MIN PARA: " +  cValToChar(aVlrPed[3]) ,"CLIENTE:" + Alltrim(cValToChar(SA1->A1_COD)) + "-" + Alltrim(cValToChar(SA1->A1_LOJA)))	

						EndIf                

					EndIf		
				ElseIf _cNomCpo== "LocalExpedicao"
					aLocExp 	:= SEPARA(Alltrim(cValToChar(cBuffer)),";",.T.)	
					
					if Len(aLocExp) >=3

						cLocExp  	:= left(Alltrim(aLocExp[3]),4)
						cLocExp 	:= fLocPad(cLocExp)

						if !Empty(cLocExp)
							
							If Reclock("SA1",.F.)
								SA1->A1_XLOCEXP := cLocExp	
								Msunlock()

								AutoGrLog("Linha "+strzero(nlin,5)+" Cliente "+_cCod+_cLoja+" "+SA1->A1_NOME+" Loja Expedição PARA: " + cLocExp )
								logZBE("Linha "+strzero(nlin,5)+" Cliente "+_cCod+_cLoja+" "+SA1->A1_NOME+" PED MIN PARA: " +  cLocExp ,"CLIENTE:" + Alltrim(cValToChar(SA1->A1_COD)) + "-" + Alltrim(cValToChar(SA1->A1_LOJA)))	

							EndIf
						endif

					endif

				EndIf
				//

			EndIf //Fecha If !DbSeek(xfilial("SA1")+_cCod+_cLoja)

			lArqOk := .f.
			FT_FSkip()
			nLin++	

		EndDo // Fim While ! FT_FEof()

		_cFileLog := Left(_cArq,At(".",_cArq)-1)+".LOG"
		_cFileLog := Alltrim(Substr(_cFileLog,RAt("\",_cFileLog)+1,20))
		_cPath    := Substr(_cArq,1,RAt("\",_cArq))

		MostraErro(_cPath,_cFileLog)

		If nHdl <> -1
			FT_FUse(_cArq)

		EndIf

		/*//Envio de registros ao SalesForce.
		If ! Empty(cClientes) .And. Findfunction("U_ADVEN076P") .And. Findfunction("U_ADVEN055P")

		//If MsgYesNo("Deseja enviar os registros ao SalesForce?","Função ALTCPSA1")
		cClientes := Substr(cClientes,1,Len(cClientes) - 1)

		If _cNomCpo == "Contrato"
		For i := 1 To Len(aContra)
		U_ADVEN055P(aContra[i][1],.F.,"")

		Next i 

		Else
		U_ADVEN076P("","",.F.," AND (RTRIM(LTRIM(A1_COD)) + RTRIM(LTRIM(A1_LOJA))) IN (" + cClientes + ") ",cTagEnvSF,.T.)

		EndIf

		//EndIf

		EndIf// Fechar ! Empty(cClientes) .And. Findfunction("U_ADVEN076P") .And. Findfunction("U_ADVEN076P")
		*/
		Aviso( "Aviso",OemToAnsi("Importação realizada com sucesso!"),{"Sair"} )

	EndIf // Fechar nHdl == -1

Return Nil

/* Busca as informaes do cabealho. */
Static Function fgetSX3(cCampos)
    Local aRet      := {}
    Local cCampo    := ""
    Local nX        := 0
    Local nCampos   := 0
    Local bValid
    Local aCampos   := Separa(cCampos,",")
    
    dbselectarea("SX3")
    sx3->(dbsetorder(2)) // Campo
    nCampos := len(aCampos)
    
    for nx := 1 to nCampos

        cCampo := Alltrim(aCampos[nX])
        cUsado := GetSX3Cache(cCampo, "X3_USADO")
        
        if !Empty(GetSX3Cache(cCampo, "X3_CAMPO"))

            bValid := Alltrim(GetSX3Cache(cCampo, "X3_VALID"))

            if Empty(bValid)
                bValid := {|| .T. }
            ELSE
                bValid := &("{|| "+Alltrim(GetSX3Cache(cCampo, "X3_VALID")) +" }")
            endif

            aadd(aRet,{ alltrim(GetSX3Cache(cCampo, "X3_TITULO")),;
            GetSX3Cache(cCampo, "X3_CAMPO")	,;
            GetSX3Cache(cCampo, "X3_PICTURE"),;
            GetSX3Cache(cCampo, "X3_TAMANHO"),;
            GetSX3Cache(cCampo, "X3_DECIMAL"),;
            bValid,;
            GetSX3Cache(cCampo, "X3_USADO"),;
            GetSX3Cache(cCampo, "X3_TIPO"),;
            GetSX3Cache(cCampo, "X3_F3"),;
            GetSX3Cache(cCampo, "X3_CONTEXT"),;
            GetSX3Cache(cCampo, "X3_CBOX"),;
            GetSX3Cache(cCampo, "X3_RELACAO")})
        endif
    next nx

return aRet

Static Function fLocPad(cLocPad)
	Local cRet 	:= ""
	Local aRet 	:= fgetSX3("A1_XLOCEXP")
	Local nA	:= 0

	aXBOX	:= Separa(aRet[1][11],";")
	nXBOX	:= Len(aXBOX)

	cLocPad := Alltrim(cLocPad)

	for nA := 1 to nXBOX
		if cLocPad$Left(aXBOX[nA],4)
			cRet := Alltrim(aXBOX[nA])
		endif
	next nA


return cRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³logZBE         ºAutor  ³Everson      º Data ³  06/03/2018   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Gera log na tabela ZBE.                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Chamado 037261.                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function logZBE(cLog,cParam)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
	Local aArea   := GetArea()

	DbSelectArea("ZBE")
	RecLock("ZBE",.T.)
	Replace ZBE_FILIAL 	   	WITH xFilial("ZBE")
	Replace ZBE_DATA 	   	WITH dDataBase
	Replace ZBE_HORA 	   	WITH Time()
	Replace ZBE_USUARI	    WITH Upper(Alltrim(cUserName))
	Replace ZBE_LOG	        WITH cLog
	Replace ZBE_MODULO	    WITH "COMERCIAL"
	Replace ZBE_ROTINA	    WITH "ALTCPSA1" 
	Replace ZBE_PARAME      WITH cParam
	ZBE->( MsUnLock())

	//
	RestArea(aArea)

Return Nil
