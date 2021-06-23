#include "protheus.ch"
#include "totvs.ch"

/*/{Protheus.doc} User Function ADFAT012P
	Rotina de preenchimento da GNRE automaticamente - GNRE de Clientes ONLINE
	@type  Function
	@author Abel Babini
	@since 28/01/19
	@version 1
	@history Abel Babini em 10/01/2020 - 053355 || OS 054727 || FISCAL || RENATA || 8404 || PREENCHIMENTO GNRE  
	/*/
User Function ADFAT012P()

	Local _aArea	:= GetArea()
	Local _cpar01	:= ''
	Local _cpar02	:= ''
	Local _cpar03	:= ''
	Local _cpar04	:= ''
	Local _cpar05	:= ''
	Local _cDtVenc	:= ''
	Local _cChvNfe	:= ''
	Local nErr 		:= 0
	Local _lPerg	:= .F. 
	Local aPergs := {}
	Local aRet := {}
	
	//@history Abel Babini em 10/01/2020 - 053355 || OS 054727 || FISCAL || RENATA || 8404 || PREENCHIMENTO GNRE  
	//Nใo ้ mais necessแrio utilizar UiPath
	//Private _cArqUipa	:= "M:\UiPath\Exe\UiRobot.exe"
	//Private _cArqBot	:= "M:\UiPath\Bot\GNREOnline\Main.xaml"
	Private _cArqUipa	:= "M:\GNRE\GNRE.exe"

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Rotina de preenchimento da GNRE automaticamente - GNRE de Clientes ONLINE')
	
	If IsInCallStack('U_PrtNfeSef') 
		_cpar01 := MV_PAR03 //Serie De
		_cpar02:= MV_PAR01 //Nota De
		_cpar03:= '' //Cliente De
		_cpar04:= '' //Loja De
		_lPerg := .T. 
	Else
	    aAdd( aPergs ,{1,"Serie : "    ,Space(3),"@!" ,'.T.',,'.T.',40,.F.})
	    aAdd( aPergs ,{1,"Nota Fiscal" ,Space(9),"@!" ,'.T.',,'.T.',40,.F.})
	    aAdd( aPergs ,{1,"Cliente"     ,Space(6),"@!" ,'.T.','SA1','.T.',40,.F.})
	    aAdd( aPergs ,{1,"Loja"        ,Space(2),"@!" ,'.T.',,'.T.',40,.F.})      
	    
	    If ParamBox(aPergs ,"Parametros ",aRet)
	       _lPerg := .T.      
	       _cpar01:= aRet[1] //Serie
	       _cpar02:= aRet[2] //Nota
	       _cpar03:= aRet[3] //Cliente
	       _cpar04:= aRet[4] //Loja
	    EndIf
	
	Endif
	
	//Verifica se UiPath estแ instalado e o arquivo do bot estแ disponivel na rede
	If !U_VerUiPat()
		_lPerg := .F.
	Endif 
	
	If _lPerg
		//posiciona na NF-e do produto
		DbSelectArea("SF2")
		dbSetOrder(1)
		If DbSeek(xFilial("SF2")+_cpar02+_cpar01+_cpar03+_cpar04)	    
			//Posiciona SA1 para retirar informa็๕es de identifica็ใo do contribuinte.
			dbSelectArea("SA1")
			dbSetOrder(1)
			dbGoTop()   
			If dbSeek(xFilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA)
				//Posiciona SE1 para retirar as informa็๕es de vencimento e valor do tํtulo de cobran็a do cliente referente ao ICMS ST
				dbSelectArea("SE1")
				dbSetOrder(1)
				If DbSeek(xFilial("SE1")+'MAN'+SF2->F2_DOC+'   '+'NDC')
					//Posiciona SF3 para localizar a Chave da NF-e
					dbSelectArea("SF3")
					dbSetOrder(4)
					If DbSeek(xFilial("SF3")+SF2->(F2_CLIENTE+F2_LOJA+F2_DOC+F2_SERIE))
						_cChvNfe := SF3->F3_CHVNFE
					Endif
					//A Data de Vencimento serแ no dia seguinte ao do tํtulo, pois ap๓s as 16horas o financeiro nใo realiza mais pagamentos.
					_cDtVenc := Repl('0',2-len(Alltrim(str(Day(SE1->E1_VENCREA+1)))))+Alltrim(str(Day(SE1->E1_VENCREA+1)))+Repl('0',2-len(Alltrim(str(Month(SE1->E1_VENCREA+1)))))+Alltrim(Str(Month(SE1->E1_VENCREA+1)))+Alltrim(Str(Year(SE1->E1_VENCREA+1))) 
					//_cpar05	:= ' -file "'+_cArqBot+'" -input "'+"{'A_GNRE_UF' :'"+AllTrim(SF2->F2_EST)+"','A_IE_Emitente' :'"+Alltrim(SA1->A1_INSCR)+"','A_GNRE_CodReceita' :'100099','A_Nota_Fiscal' :'"+SF2->(F2_SERIE+F2_DOC)+"','A_MesReferencia' :'"+UPPER(MesExtenso(SE1->E1_EMISSAO))+"','A_AnoReferencia' :'"+Alltrim(Str(Year(SE1->E1_EMISSAO)))+"','A_Convenio' :'DECRETO 49.527-2012','A_DataVencimento' :'"+_cDtVenc+"','A_DataPagamento' :'"+_cDtVenc+"','A_Valor' :'"+Alltrim(Str(SE1->E1_VALOR))+"','A_InformCompl' :'"+_cChvNfe+"'"+'}" --rdp'
					_cpar05	:= ' '+AllTrim(SF2->F2_EST)+" "+Alltrim(SA1->A1_INSCR)+' 100099 "'+SF2->(F2_SERIE+F2_DOC)+'" '+UPPER(MesExtenso(SE1->E1_EMISSAO))+" "+Alltrim(Str(Year(SE1->E1_EMISSAO)))+' "DECRETO 49.527-2012" '+_cDtVenc+" "+_cDtVenc+" "+Alltrim(Str(SE1->E1_VALOR))+" "+_cChvNfe
					shellExecute("Open",_cArqUipa, _cpar05,"M:\GNRE\",1)
				Endif
			Endif
		Endif
	Endif
	RestArea(_aArea)
Return 

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณVerUiPat  บAutor  ณAbel Babini Filho   บ Data ณ  01/04/2019 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณVerifica se o aplicativo UiPath estแ instalado na mแquina   บฑฑ
ฑฑบ          ณdo usuแrio                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
User Function VerUiPat()

	Local _lbot := .F.

	U_ADINF009P('ADFAT012P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Rotina de preenchimento da GNRE automaticamente - GNRE de Clientes ONLINE')

	//@history Abel Babini em 10/01/2020 - 053355 || OS 054727 || FISCAL || RENATA || 8404 || PREENCHIMENTO GNRE  
	//Nใo ้ mais necessแrio utilizar UiPath
	/*
	If File(_cArqUipa,2)
		If File(_cArqBot,2)
			_lbot := .T.
		Else
			MsgAlert("Contate o Depto. de TI. UiPath instalado, por้m arquivo rob๔ nใo encontrado em: "+_cArqBot,"ERRO 2 UiPath")
			_lbot := .F.
		Endif
	ELSE
		MsgAlert("Contate o Depto. de TI. UiPath nใo instalado no caminho: "+_cArqUipa,"ERRO 1 UiPath")
		_lbot := .F.
	ENDIF
	*/
	If File(_cArqUipa,2)
		_lbot := .T.
	ELSE
		MsgAlert("Contate o Depto. de TI. Arquivo Rob๔ GNRE.exe nใo instalado no caminho: "+_cArqUipa,"ERRO 1 Arquivo Robo")
		_lbot := .F.
	ENDIF
Return _lbot