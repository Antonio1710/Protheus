#Include 'Protheus.ch'
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMT110TEL บ Autor ณ ษverson             บ Data ณ  31/08/2016 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Este ponto tem a finalidade de manipular o cabe็alho da    บฑฑ
ฑฑบ          ณ Solicita็ใo de Compras permitindo a inclusใo e altera็ใo   บฑฑ
ฑฑบ          ณ de campos.													    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
User Function MT110TEL()

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declara็ใo de variแveis                                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local aArea		:= GetArea()
	Local oTelaSC		:= PARAMIXB[1]		//Objeto Dialog da solicita็ใo de compras.
	Local aPosGet    	:= PARAMIXB[2]		//Posi็ใo dos Gets da solicita็ใo de compras.
	Local nOpcx      	:= PARAMIXB[3]		//Op็ใo selecionada na solicita็ใo de compras.
	Local nReg       	:= PARAMIXB[4]		//N๚mero do recno do registro da solicita็ใo de compras selecionada.
	Local oGrpCompra							//Objeto ComboBox
	Local aGrCompra	:= {}	
	Local lAltera		:= .T.
	Local cGetFiliais	:= GetMv("MV_#SCFILI")
	
	Local oHoraSC
	
	//Variแvel p๚blica para que seja visํvel nos pontos de entrada MT110OK e MT110GRV.
	Public lRotHabil	:= .F.	//Variแvel define a utiliza็ใo da rotina.
	Public cGrCompra	:= ""	//Variแvel para armazenar a op็ใo selecionada.
	Public cHora	:= Substr(cValToChar(Time()),1,10)
	
	//Verifica se a regra ้ aplicada เ filial corrente.
	If !(cFilAnt $(Alltrim(cValToChar(cGetFiliais))))
		Return Nil
	
	EndIf
	
	//Obt้m os grupos de compra presentes no campo C1_XGRCOMP.
	aGrCompra	:= obterOpcGrComp()
	
	//Valida o retorno da fun็ใo obterOpcGrComp(). 
	//Se nใo hแ grupos de compra informados no campo C1_XGRCOMP, a rotina nใo ้ implementada.
	If Len(aGrCompra) == 0
		MsgStop("Por favor, verifique as op็๕es disponํveis para o campo Tp. Compra! A SC nใo poderแ ser salva!","Fun็ใo MT110TEL")
		RestArea(aArea)
		Return Nil
	
	EndIf
	
	//Verifica a opera็ใo selecionada para carregar valor no campo.
	If nOpcx <> 3 .And. ! Empty(Alltrim(cValToChar(SC1->C1_XGRCOMP)))//Se nใo for opera็ใo de inclusใo e o campo C1_XGRCOMP nใo estiver vazio.
		//Carrega op็ใo.
		cGrCompra:= Alltrim(cValToChar(SC1->C1_XGRCOMP))
		cHora  := SC1->C1_XHORASC
		
	//ElseIf nOpcx == 4 .And. Empty(Alltrim(cValToChar(SC1->C1_XGRCOMP))) //Altera็๕es de SC antes da implementa็ใo da rotina.
		//cGrCompra:= "1"
		
	Else //Se for opera็ใo de inclusใo ou o campo estiver vazio.
		cGrCompra:= aGrCompra[1]
			
	EndIf
	
	//Adiciona as posi็๕es da label do campo e ComboBox.
	Aadd(aPosGet[1],0) 
	Aadd(aPosGet[1],0)
	Aadd(aPosGet[1],0)
	Aadd(aPosGet[1],0)
	
	//Define a posi็ใo da label do campo.
	aPosGet[1,7]:=30
	aPosGet[1,9]:=312   //alterado por Adriana - Chamado 036032 - Projeto V12 
	
	//Define a posi็ใo do ComboBox e MsGet.
	aPosGet[1,8]:=74
	aPosGet[1,10]:= 360 //alterado por Adriana - Chamado 036032 - Projeto V12 
	
	//Valida altera็ใo do objeto ComboBox pela opera็ใo.
	If (nOpcx <> 3 .And. nOpcx <> 4) .Or. (nOpcx == 4 .And. ! Empty(Alltrim(cValToChar(SC1->C1_COTACAO))))
		lAltera := .F.
		
	EndIf
	
	//Habilita rotina.
	lRotHabil := .T.
	
	//Adiciona label e ComboBox a tela de soli็ใo de compras.
	//Alterada linha por Adriana 
	@63,aPosGet[1,7] Say RetTitle("C1_XGRCOMP") Pixel Size 30,09 Of oTelaSC
	@62,aPosGet[1,8] MsComboBox oGrpCompra Var cGrCompra Items aGrCompra Size 080, 20 Of oTelaSC Colors 0,16777215 Pixel;
					   on Change msgGrpComp(cGrCompra) When lAltera
					   
					  
	@63,aPosGet[1,9] Say "Hora" Pixel Size 30,09 Of oTelaSC
	@62,aPosGet[1,10] MsGet oHoraSC Var cHora  Size 50,10 Of oTelaSC Colors 0,16777215 Pixel When .F.   
        
	RestArea(aArea)
	
Return Nil
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณmsgGrpComp บ Autor ณ ษverson         บ   Data ณ  30/08/2016 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Fun็ใo existe mensagem conforme gurpo de compra			    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function msgGrpComp(cGrCompra)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declara็ใo de variแveis                                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local cMsg1		:= "Compra Normal" + Chr(13) + Chr(10) + "Sua SC serแ atendida em at้ 05 dias ๚teis."
	Local cMsg2		:= "Compra Urgente" + Chr(13) + Chr(10) + "Obrigat๓rio envio de autoriza็ใo da diretoria para atendimento da compra urgente (por e-mail)."
	
	If cGrCompra == "1"
		MsgInfo(cMsg1,"Fun็ใo msgGrpComp (MT110TEL)")
		
	ElseIf cGrCompra == "2"
		MsgInfo(cMsg2,"Fun็ใo msgGrpComp (MT110TEL)")
			
	EndIf

Return Nil
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณobterOpcGrComp บ Autor ณ ษverson        บ Data ณ  29/08/2016 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Obt้m os grupos de compra 									    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function obterOpcGrComp()

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declara็ใo de variแveis                                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local cGrOpcCompra	:= ""
	Local aGrCompra		:= {}
	Local aRetorno		:= {}
	Local i				:= 1

	//Obt้m as op็๕es (Grupo de compras).
	DbSelectArea("SX3")
	SX3->(DbSetOrder(2))
	If ! SX3->(dbSeek("C1_XGRCOMP"))
		Return aGrCompra
		
	Endif
	
	//Obt้m as op็๕es do campo C1_XGRCOMP.
	cGrOpcCompra  := X3Cbox()
	cGrOpcCompra	:= Alltrim(cValToChar(cGrOpcCompra))
	aGrCompra		:= StrToKarr(cGrOpcCompra,";")
	
	//Valida retorno da fun็ใo X3Cbox().
	If Len(aGrCompra) > 0 
		Aadd(aRetorno,"")
		For i := 1 To Len(aGrCompra)
			Aadd(aRetorno,aGrCompra[i])
			
		Next i
	
	EndIf
	
Return aRetorno