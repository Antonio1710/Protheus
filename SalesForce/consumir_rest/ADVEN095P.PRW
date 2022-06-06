#Include "Protheus.ch"
#include 'Fileio.ch'
#Include 'Totvs.ch'
#Include 'Topconn.ch'
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณADVEN095P      บAutor  ณEverson      บ Data ณ  21/06/2018   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFun็ใo para cadastro de visitas e liga็๕es.                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณChamado 037261.                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function ADVEN095P() // U_ADVEN095P()

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declaracao de Variaveis                                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู	
	Local aArea	:= GetArea()

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Fun็ใo para cadastro de visitas e liga็๕es.')
	
	//
	If ! Pergunte("SFCADVISLI",.T.)
		RestArea(aArea)
		Return Nil
		
	EndIf
	
	SetKey(VK_F12, {|| U_impCadLV() })
	
	//
	MsAguarde({|| cadastros(MV_PAR01) },"Aguarde","Carregando cadastro...")

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณcadastros      บAutor  ณEverson      บ Data ณ  21/06/2018   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFun็ใo escolha de cadastro.                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณChamado 037261.                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function cadastros(nOpc)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declaracao de Variaveis                                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู		
	
	//
	If nOpc == 1
		MsAguarde({|| cadLigacao()  },"Aguarde","Carregando cadastro de liga็๕es...")
		
	ElseIf nOpc == 2
		MsAguarde({|| cadVVendedor() },"Aguarde","Carregando cadastro de visita vendedor...")
		
	ElseIf nOpc == 3
		MsAguarde({|| cadVPromotor() },"Aguarde","Carregando cadastro de visita promotor...")
		
	EndIf

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณcadLigacao     บAutor  ณEverson      บ Data ณ  21/06/2018   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFun็ใo cadastro de liga็๕es.                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณChamado 037261.                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function cadLigacao()

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declaracao de Variaveis                                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local aArea		:= GetArea()
	Local aRotAdic 	:={} 
		
	Aadd(aRotAdic,{ "Exportar SF  ","U_lifExpSF(2)" , 0 , 6 })
	Aadd(aRotAdic,{ "Exportar SF L","U_lifExpLSF"   , 0 , 7 })
	Aadd(aRotAdic,{ "Importar CSV" ,"U_impCSVLV(1)" , 0 , 8 })
	//Aadd(aRotAdic,{ "Importar Cad.","U_impCadLV"    , 0 , 9 })
	
	AxCadastro("ZBC", "Cadastro de Liga็๕es",,, aRotAdic)
	
	//
	RestArea(aArea)
	
Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณcadVVendedor   บAutor  ณEverson      บ Data ณ  21/06/2018   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFun็ใo cadastro de visita vendedor.                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณChamado 037261.                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function cadVVendedor()
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declaracao de Variaveis                                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local aArea		:= GetArea()
	Local aRotAdic 	:={} 
	
	Aadd(aRotAdic,{ "Exportar SF  ","U_lifExpSF(3)" , 0 , 6 })
	Aadd(aRotAdic,{ "Exportar SF L","U_lifExpLSF"   , 0 , 7 })
	Aadd(aRotAdic,{ "Importar CSV" ,"U_impCSVLV(2)" , 0 , 8 })
	//Aadd(aRotAdic,{ "Importar Cad.","U_impCadLV"    , 0 , 9 })
	
	//
	DbSelectArea("ZC6")
	Set Filter To ZC6->ZC6_TIPO = 'V'
	AxCadastro("ZC6", "Cadastro de Visita Vendedor",,, aRotAdic)
	Set Filter To
	
	//
	RestArea(aArea)
	
Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณcadVPromotor   บAutor  ณEverson      บ Data ณ  21/06/2018   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFun็ใo cadastro de visita promotor.                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณChamado 037261.                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function cadVPromotor()

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declaracao de Variaveis                                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Local aArea		:= GetArea()
	Local aRotAdic 	:={} 
	
	Aadd(aRotAdic,{ "Exportar SF  ","U_lifExpSF(3)" , 0 , 6 })
	Aadd(aRotAdic,{ "Exportar SF L","U_lifExpLSF"   , 0 , 7 })
	Aadd(aRotAdic,{ "Importar CSV" ,"U_impCSVLV(3)" , 0 , 8 })
	//Aadd(aRotAdic,{ "Importar Cad.","U_impCadLV"    , 0 , 9 })
	
	//
	DbSelectArea("ZC6")
	Set Filter To ZC6->ZC6_TIPO = 'P'
	AxCadastro("ZC6", "Cadastro de Visita Promotor",,, aRotAdic)
	Set Filter To
	
	//
	RestArea(aArea)
		
Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณimpCSVLV       บAutor  ณEverson      บ Data ณ  21/06/2018   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFun็ใo para importa็ใo de CSV.                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณChamado 037261.                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function impCSVLV(nOPc)

	U_ADINF009P('ADVEN095P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Fun็ใo para cadastro de visitas e liga็๕es.')
	
	//
	Processa({|| procCSV(nOPc) },"Aguarde","Processando registros...")
	
Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณprocCSV        บAutor  ณEverson      บ Data ณ  21/06/2018   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFun็ใo processa importa็ใo de CSV.                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณChamado 037261.                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function procCSV(nOPc)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declaracao de Variaveis                                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู	
	Local aArea		:= GetArea()
	Local cArq		:= ""
	Local nHdl  	:= 0
	Local nTotLinhas:= 0
	Local cBuffer	:= ""
	Local aCarga	:= {}
	
	//ALERT(nOPc)
	
	//
	cArq := cGetFile('Arquivo CSV|*.*|Arquivo *|*.*','Selecione arquivo',0,'C:\',.T.,GETF_LOCALHARD + GETF_NETWORKDRIVE,.T.)

	//Valida arquivo.  
	If Empty(cArq)
		MsgStop( "Nใo foi possํvel obter o arquivo.","Fun็ใo procCSV (ADVEN095P)")
		Return Nil

	Endif
	
	//Abre o arquivo.
	nHdl := FT_FUse(cArq)

	//Valida abertura do arquivo.
	If nHdl == -1
		MsgStop("Nใo foi possํvel abrir o arquivo " + Chr(13) + Chr(13) + cArq,"Fun็ใo lerArquivo")
		Return Nil

	Endif
	
	//
	FT_FGoTop()

	//Obt้m a quantidade de linhas.
	nTotLinhas := FT_FLastRec()

	//Atribui o tamanho da r้gua.
	ProcRegua(nTotLinhas)

	FT_FGoTop()
	FT_FGoto(1)

	//Percorre arquivo.
	While ! FT_FEof()
	
		//
		cBuffer  := Alltrim(cValToChar(DecodeUTF8(FT_FReadln())))

		If ! Empty(cBuffer)

			aDados	 := Separa(Alltrim(cValToChar(cBuffer)),";",.T.)
			
			If (nOPc == 1 .Or. nOPc == 2) .And. Len(aDados) <> 10
				If nHdl <> -1
					FT_FUse(cArq)
		
				EndIf
				
				MsgStop("Para cadastro de visitas/liga็๕es de vendedores, ้ necessแrio que haja 10 posi็๕es por registro.","Fun็ใo procCSV (ADVEN095P)")
				RestArea(aArea)
				Return Nil
				
			ElseIf nOPc == 3 .And. Len(aDados) <> 11
				If nHdl <> -1
					FT_FUse(cArq)
		
				EndIf
				
				MsgStop("Para cadastro de visitas de promotores, ้ necessแrio que haja 11 posi็๕es por registro.","Fun็ใo procCSV (ADVEN095P)")
				RestArea(aArea)
				Return Nil
				
			EndIf
			
			//Incrementa regua de processamento.
			IncProc("Cliente " + cValToChar(aDados[1]) + "-" + cValToChar(aDados[2]) )

			Aadd(aCarga,aDados)

		EndIf

		FT_FSkip()

	EndDo
	
	//
	If Len(aCarga) <= 0
		If nHdl <> -1
			FT_FUse(cArq)

		EndIf
		
		MsgStop("Nใo hแ dados a serem processados.","Fun็ใo procCSV (ADVEN095P)")
		RestArea(aArea)
		Return Nil
		
	EndIf
	
	//
	If ! MsgYesNo("Serใo processados " + cValToChar(Len(aCarga)) + " registros.Deseja prosseguir?","Fun็ใo procCSV (ADVEN095P)")
		If nHdl <> -1
			FT_FUse(cArq)

		EndIf
		RestArea(aArea)
		Return Nil
			
	EndIf
	
	//
	If nOPc == 1
		procAtLig(aCarga)
		
	ElseIf nOPc == 2
		procAtVVe(aCarga)
		
	ElseIf nOPc == 3
		procAtVPr(aCarga)
		
	EndIf
	
	//
	If nHdl <> -1
		FT_FUse(cArq)

	EndIf
	
	//
	MsgInfo("Processamento concluํdo.","Fun็ใo procCSV (ADVEN095P)")
	
	//
	RestArea(aArea)

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณprocAtLig      บAutor  ณEverson      บ Data ณ  21/06/2018   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFun็ใo para importa็ใo de inclu/atualiza็ใo de cadastros.   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณChamado 037261.                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function procAtLig(aCarga)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declaracao de Variaveis                                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู	
	Local aArea		:= GetArea()
	Local cCodCli	:= ""
	Local cLoja		:= ""
	
	//
	DbSelectArea("ZBC")
	ZBC->(DbSetOrder(1))
	ZBC->(DbGoTop())

	//
	For i := 1 To Len(aCarga)
	
		//
		aDados := aCarga[i]
		
		//
		cCodCli := aDados[1]
		cLoja   := aDados[2]
	
		If ! ZBC->(DbSeek( xFilial("ZC6") + cCodCli + cLoja))
		
			Reclock("ZBC",.T.)
				ZBC_FILIAL	:= xFilial("ZBC")
				ZBC_CODCLI	:= cCodCli
				ZBC_LOJA	:= cLoja
				ZBC_FREQUE	:= Alltrim(cValToChar(aDados[3]))
				ZBC_SEMANA  := Alltrim(cValToChar(aDados[4]))
				ZBC_SEG		:= Alltrim(cValToChar(aDados[5]))
				ZBC_TER		:= Alltrim(cValToChar(aDados[6]))
				ZBC_QUA		:= Alltrim(cValToChar(aDados[7]))
				ZBC_QUI		:= Alltrim(cValToChar(aDados[8]))
				ZBC_SEX		:= Alltrim(cValToChar(aDados[9]))
				ZBC_HORARI	:= Alltrim(cValToChar(aDados[10]))
				ZBC_ULTIMP 	:= Date()
			MsUnlock()
			
		Else
		
			Reclock("ZBC",.F.)
				ZBC_FREQUE	:= Alltrim(cValToChar(aDados[3]))
				ZBC_SEMANA  := Alltrim(cValToChar(aDados[4]))
				ZBC_SEG		:= Alltrim(cValToChar(aDados[5]))
				ZBC_TER		:= Alltrim(cValToChar(aDados[6]))
				ZBC_QUA		:= Alltrim(cValToChar(aDados[7]))
				ZBC_QUI		:= Alltrim(cValToChar(aDados[8]))
				ZBC_SEX		:= Alltrim(cValToChar(aDados[9]))
				ZBC_HORARI	:= Alltrim(cValToChar(aDados[10]))
				ZBC_ULTIMP 	:= Date()
			MsUnlock()
			
		EndIf
	
	Next i
	
	//
	RestArea(aArea)
	
Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณprocAtLig      บAutor  ณEverson      บ Data ณ  21/06/2018   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFun็ใo para importa็ใo de inclu/atualiza็ใo de cadastros.   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณChamado 037261.                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function procAtVVe(aCarga)
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declaracao de Variaveis                                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู	
	Local aArea		:= GetArea()
	Local i			:= 1
	Local aDados	:= {}
	Local cCodCli	:= ""
	Local cLoja		:= ""

	//
	DbSelectArea("ZC6")
	ZC6->(DbSetOrder(2))
	ZC6->(DbGoTop())

	//
	For i := 1 To Len(aCarga)
		
		//
		aDados := aCarga[i]
		
		//
		cCodCli := aDados[1]
		cLoja   := aDados[2]
	
		If ! ZC6->(DbSeek( xFilial("ZC6") + "V" + cCodCli + cLoja))
		
			If Reclock("ZC6",.T.)
			
					ZC6->ZC6_FILIAL		:= xFilial("ZC6")
					ZC6->ZC6_CODCLI		:= cCodCli
					ZC6->ZC6_LOJA		:= cLoja
					ZC6->ZC6_FREQUE		:= Alltrim(cValToChar(aDados[3]))
					ZC6->ZC6_SEMANA		:= Alltrim(cValToChar(aDados[4]))
					ZC6->ZC6_SEG		:= Alltrim(cValToChar(aDados[5]))
					ZC6->ZC6_TER		:= Alltrim(cValToChar(aDados[6]))
					ZC6->ZC6_QUA		:= Alltrim(cValToChar(aDados[7]))
					ZC6->ZC6_QUI		:= Alltrim(cValToChar(aDados[8]))
					ZC6->ZC6_SEX		:= Alltrim(cValToChar(aDados[9]))
					ZC6->ZC6_HORARI  	:= Alltrim(cValToChar(aDados[10]))
					ZC6->ZC6_ULTIMP 	:= Date()
					ZC6->ZC6_TIPO 	    := "V"
					
				MsUnlock()
				
			EndIf
			
		Else
			
			Reclock("ZC6",.F.)
			
				ZC6->ZC6_FREQUE		:= Alltrim(cValToChar(aDados[3]))
				ZC6->ZC6_SEMANA		:= Alltrim(cValToChar(aDados[4]))
				ZC6->ZC6_SEG		:= Alltrim(cValToChar(aDados[5]))
				ZC6->ZC6_TER		:= Alltrim(cValToChar(aDados[6]))
				ZC6->ZC6_QUA		:= Alltrim(cValToChar(aDados[7]))
				ZC6->ZC6_QUI		:= Alltrim(cValToChar(aDados[8]))
				ZC6->ZC6_SEX		:= Alltrim(cValToChar(aDados[9]))
				ZC6->ZC6_HORARI  	:= Alltrim(cValToChar(aDados[10]))
				ZC6->ZC6_ULTIMP 	:= Date()	
				ZC6->ZC6_TIPO 	    := "V"
					
			MsUnlock()
			
		EndIf
	
	Next i
		
	//
	RestArea(aArea)
	
Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณprocAtVPr      บAutor  ณEverson      บ Data ณ  21/06/2018   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFun็ใo para importa็ใo de inclu/atualiza็ใo de cadastros.   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณChamado 037261.                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function procAtVPr(aCarga)
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declaracao de Variaveis                                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู	
	Local aArea		:= GetArea()
	Local i			:= 1
	Local aDados	:= {}
	Local cCodCli	:= ""
	Local cLoja		:= ""

	//
	DbSelectArea("ZC6")
	ZC6->(DbSetOrder(2))
	ZC6->(DbGoTop())

	//
	For i := 1 To Len(aCarga)
		
		//
		aDados := aCarga[i]
	
		//
		cCodCli := aDados[1]
		cLoja   := aDados[2]
	
		If ! ZC6->(DbSeek( xFilial("ZC6") + "P" + cCodCli + cLoja))
		
			If Reclock("ZC6",.T.)
			
					ZC6->ZC6_FILIAL		:= xFilial("ZC6")
					ZC6->ZC6_CODCLI		:= cCodCli
					ZC6->ZC6_LOJA		:= cLoja
					ZC6->ZC6_FREQUE		:= Alltrim(cValToChar(aDados[3]))
					ZC6->ZC6_SEMANA		:= Alltrim(cValToChar(aDados[4]))
					ZC6->ZC6_SEG		:= Alltrim(cValToChar(aDados[5]))
					ZC6->ZC6_TER		:= Alltrim(cValToChar(aDados[6]))
					ZC6->ZC6_QUA		:= Alltrim(cValToChar(aDados[7]))
					ZC6->ZC6_QUI		:= Alltrim(cValToChar(aDados[8]))
					ZC6->ZC6_SEX		:= Alltrim(cValToChar(aDados[9]))
					ZC6->ZC6_SAB		:= Alltrim(cValToChar(aDados[10]))
					ZC6->ZC6_HORARI  	:= Alltrim(cValToChar(aDados[11]))
					ZC6->ZC6_ULTIMP 	:= Date()
					ZC6->ZC6_TIPO 	    := "P"
					
				MsUnlock()
				
			EndIf
			
		Else
		
			Reclock("ZC6",.F.)
			
				ZC6->ZC6_FREQUE		:= Alltrim(cValToChar(aDados[3]))
				ZC6->ZC6_SEMANA		:= Alltrim(cValToChar(aDados[4]))
				ZC6->ZC6_SEG		:= Alltrim(cValToChar(aDados[5]))
				ZC6->ZC6_TER		:= Alltrim(cValToChar(aDados[6]))
				ZC6->ZC6_QUA		:= Alltrim(cValToChar(aDados[7]))
				ZC6->ZC6_QUI		:= Alltrim(cValToChar(aDados[8]))
				ZC6->ZC6_SEX		:= Alltrim(cValToChar(aDados[9]))
				ZC6->ZC6_SAB		:= Alltrim(cValToChar(aDados[10]))
				ZC6->ZC6_HORARI  	:= Alltrim(cValToChar(aDados[11]))
				ZC6->ZC6_ULTIMP 	:= Date()	
				ZC6->ZC6_TIPO 	    := "P"
					
			MsUnlock()
			
		EndIf
	
	Next i
		
	//
	RestArea(aArea)

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณimpCadLV       บAutor  ณEverson      บ Data ณ  21/06/2018   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFun็ใo para importa็ใo de novos cadastros.                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณChamado 037261.                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function impCadLV()
	
	U_ADINF009P('ADVEN095P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Fun็ใo para cadastro de visitas e liga็๕es.')

	//
	Processa({|| processImpCad()},"Aguarde","Processando importa็ใo...")

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณprocessImpCad  บAutor  ณEverson      บ Data ณ  21/06/2018   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFun็ใo processa importa็ใo de cadastro da PB3.              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณChamado 037261.                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function processImpCad()

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declaracao de Variaveis                                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู	
	Local aArea	 := GetArea()
	Local nTotReg:= 0
	Local aDados := {}
	Local aCarga := {}
	Local cQuery := ""
	
/*	//
	DbSelectArea("ZBC")
	nTotReg := ZBC->(Reccount())
	ZBC->(DbSetOrder(1))
	ZBC->(DbGoTop())
	
	Procregua(nTotReg)
	
	DbSelectArea("PB3")
	PB3->(DbSetOrder(11))
	While ! ZBC->(Eof())
		
		//
		Incproc("Liga็๕es - Cliente " + Alltrim(cValToChar(ZBC->ZBC_CODCLI)) + "-" + Alltrim(cValToChar(ZBC->ZBC_LOJA)) )
		
		If PB3->(DbSeek( xFilial("PB3") + Alltrim(cValToChar(ZBC->ZBC_CODCLI)) + Alltrim(cValToChar(ZBC->ZBC_LOJA)) ))
			
			RecLock("ZBC",.F.)
			
				ZBC_SEG		:= PB3->PB3_TELSEG
				ZBC_TER		:= PB3->PB3_TELTER
				ZBC_QUA		:= PB3->PB3_TELQUA
				ZBC_QUI		:= PB3->PB3_TELQUI
				ZBC_SEX		:= PB3->PB3_TELSEX
				ZBC_SEMANA  := PB3->PB3_LIGSEM
				ZBC_FREQUE	:= PB3->PB3_LIGFRQ
				ZBC_HORARI	:= PB3->PB3_LIGHOR
				ZBC_ULTIMP 	:= Date()
				
			ZBC->(MsUnlock())
		
		EndIf
		
		ZBC->(DbSkip())
		
	EndDo
	
	//
	DbSelectArea("ZC6")
	nTotReg := ZC6->(Reccount())
	ZC6->(DbSetOrder(1))
	ZC6->(DbGoTop())
	
	Procregua(nTotReg)
	
	DbSelectArea("PB3")
	PB3->(DbSetOrder(11))
	While ! ZC6->(Eof())
		
		//
		Incproc("Visitas - Cliente " + Alltrim(cValToChar(ZC6->ZC6_CODCLI)) + "-" + Alltrim(cValToChar(ZC6->ZC6_LOJA)) )
		
		//
		cTipo := Alltrim(cValToChar(ZC6->ZC6_TIPO))
		
		If PB3->(DbSeek( xFilial("PB3") + Alltrim(cValToChar(ZC6->ZC6_CODCLI)) + Alltrim(cValToChar(ZC6->ZC6_LOJA)) ))
			
			RecLock("ZC6",.F.)
				
				ZC6->ZC6_SEMANA		:= Iif(cTipo == "V",PB3->PB3_VRDSEM,PB3->PB3_PRMSEM)
				ZC6->ZC6_FREQUE		:= Iif(cTipo == "V",PB3->PB3_VEDFRQ,PB3->PB3_PRMFRQ)
				ZC6->ZC6_SEG		:= Iif(cTipo == "P",PB3->PB3_PRMSEG,PB3->PB3_VEDSEG)
				ZC6->ZC6_TER		:= Iif(cTipo == "P",PB3->PB3_PRMTER,PB3->PB3_VEDTER)
				ZC6->ZC6_QUA		:= Iif(cTipo == "P",PB3->PB3_PRMQUA,PB3->PB3_VEDQUA)
				ZC6->ZC6_QUI		:= Iif(cTipo == "P",PB3->PB3_PRMQUI,PB3->PB3_VEDQUI)
				ZC6->ZC6_SEX		:= Iif(cTipo == "P",PB3->PB3_PRMSEX,PB3->PB3_VEDSEX)
				ZC6->ZC6_SAB		:= Iif(cTipo == "P",PB3->PB3_PRMSAB,"")
				ZC6->ZC6_HORARI  	:= Iif(cTipo == "V",PB3->PB3_VEDHOR,PB3->PB3_PRMHOR)
				ZC6->ZC6_ULTIMP 	:= Date()
				
			ZC6->(MsUnlock())
		
		EndIf
		
		ZC6->(DbSkip())
		
	EndDo*/
	
	//
	cQuery := " SELECT * FROM PB3BCKVISITA WHERE PB3_PRMSEM <> '' AND PB3_CODSA1 <> '' AND PB3_LOJSA1 <> '' AND LEN(RTRIM(LTRIM(PB3_CODSA1))) =6 "
	If Select("PB3BCK") > 0
		PB3BCK->(DbCloseArea())
	EndIf
	TcQuery cQuery New Alias "PB3BCK"
	DbSelectArea("PB3BCK")
	PB3BCK->(DbGoTop())
	nTotReg := Contar("PB3BCK","!Eof()")
	Procregua(nTotReg)
	PB3BCK->(DbGoTop())
	While ! PB3BCK->(Eof())
		
		//
		aDados := {}
		aCarga := {}
		
		//
		Incproc("PB3 - Cliente " + Alltrim(cValToChar(PB3BCK->PB3_CODSA1)) + "-" + Alltrim(cValToChar(PB3BCK->PB3_LOJSA1)) )
		
		//
		If !Empty(Alltrim(cValToChar(PB3BCK->PB3_CODSA1))) .And. !Empty(Alltrim(cValToChar(PB3BCK->PB3_LOJSA1))) .And. Alltrim(cValToChar(PB3BCK->PB3_BLOQUE)) == "2"
			
			/*//Liga็๕es.
			If !Empty(Alltrim(cValToChar(PB3BCK->PB3_LIGSEM)))
				aDados := {}
				aCarga := {}
				Aadd(aDados,Alltrim(cValToChar(PB3BCK->PB3_CODSA1)))
				Aadd(aDados,Alltrim(cValToChar(PB3BCK->PB3_LOJSA1)))
				Aadd(aDados,Alltrim(cValToChar(PB3BCK->PB3_LIGFRQ)))
				Aadd(aDados,Alltrim(cValToChar(PB3BCK->PB3_LIGSEM)))
				Aadd(aDados,Alltrim(cValToChar(PB3BCK->PB3_TELSEG)))
				Aadd(aDados,Alltrim(cValToChar(PB3BCK->PB3_TELTER)))
				Aadd(aDados,Alltrim(cValToChar(PB3BCK->PB3_TELQUA)))
				Aadd(aDados,Alltrim(cValToChar(PB3BCK->PB3_TELQUI)))
				Aadd(aDados,Alltrim(cValToChar(PB3BCK->PB3_TELSEX)))
				Aadd(aDados,Alltrim(cValToChar(PB3BCK->PB3_LIGHOR)))
				Aadd(aCarga,aDados)
				MsAguarde({|| procAtLig(aCarga) },"Aguarde","Atualizando liga็๕es " +Alltrim(cValToChar(PB3BCK->PB3_CODSA1)) + "-" + Alltrim(cValToChar(PB3BCK->PB3_LOJSA1)) )
			
			EndIf 
			
			//Visita vendedor
			If !Empty(Alltrim(cValToChar(PB3BCK->PB3_VRDSEM)))
				aDados := {}
				aCarga := {}
				Aadd(aDados,Alltrim(cValToChar(PB3BCK->PB3_CODSA1)))
				Aadd(aDados,Alltrim(cValToChar(PB3BCK->PB3_LOJSA1)))
				Aadd(aDados,Alltrim(cValToChar(PB3BCK->PB3_VEDFRQ)))
				Aadd(aDados,Alltrim(cValToChar(PB3BCK->PB3_VRDSEM)))
				Aadd(aDados,Alltrim(cValToChar(PB3BCK->PB3_VEDSEG)))
				Aadd(aDados,Alltrim(cValToChar(PB3BCK->PB3_VEDTER)))
				Aadd(aDados,Alltrim(cValToChar(PB3BCK->PB3_VEDQUA)))
				Aadd(aDados,Alltrim(cValToChar(PB3BCK->PB3_VEDQUI)))
				Aadd(aDados,Alltrim(cValToChar(PB3BCK->PB3_VEDSEX)))
				Aadd(aDados,Alltrim(cValToChar(PB3BCK->PB3_VEDHOR)))
				Aadd(aCarga,aDados)
				MsAguarde({|| procAtVVe(aCarga) },"Aguarde","Atualizando visitas vendedor " + Alltrim(cValToChar(PB3BCK->PB3_CODSA1)) + "-" + Alltrim(cValToChar(PB3BCK->PB3_LOJSA1)) )
			
			EndIf*/
			
			//Visita promotor.
			If !Empty(Alltrim(cValToChar(PB3BCK->PB3_PRMSEM)))
				aDados := {}
				aCarga := {}
				Aadd(aDados,Alltrim(cValToChar(PB3BCK->PB3_CODSA1)))
				Aadd(aDados,Alltrim(cValToChar(PB3BCK->PB3_LOJSA1)))
				Aadd(aDados,Alltrim(cValToChar(PB3BCK->PB3_PRMFRQ)))
				Aadd(aDados,Alltrim(cValToChar(PB3BCK->PB3_PRMSEM)))
				Aadd(aDados,Alltrim(cValToChar(PB3BCK->PB3_PRMSEG)))
				Aadd(aDados,Alltrim(cValToChar(PB3BCK->PB3_PRMTER)))
				Aadd(aDados,Alltrim(cValToChar(PB3BCK->PB3_PRMQUA)))
				Aadd(aDados,Alltrim(cValToChar(PB3BCK->PB3_PRMQUI)))
				Aadd(aDados,Alltrim(cValToChar(PB3BCK->PB3_PRMSEX)))
				Aadd(aDados,Alltrim(cValToChar(PB3BCK->PB3_PRMSAB)))
				Aadd(aDados,Alltrim(cValToChar(PB3BCK->PB3_PRMHOR)))
				Aadd(aCarga,aDados)
				MsAguarde({|| procAtVPr(aCarga) },"Aguarde","Atualizando visitas promotor " + Alltrim(cValToChar(PB3BCK->PB3_CODSA1)) + "-" + Alltrim(cValToChar(PB3BCK->PB3_LOJSA1)) )
				
			EndIf
			
		EndIf
				
		PB3BCK->(DbSkip())
		
	EndDo	
	
	//
	RestArea(aArea)
		
Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณenvSF          บAutor  ณEverson      บ Data ณ  21/06/2018   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFun็ใo para envio de cadastro ao SalesForce.                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณChamado 037261.                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function envSF(cDe,cAte)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declaracao de Variaveis                                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู	
	Local aArea	:= GetArea()
	
	//
	U_ADVEN076P("","",.F.," AND (RTRIM(LTRIM(A1_COD)) + RTRIM(LTRIM(A1_LOJA))) BETWEEN '" + cDe + "' AND '" + cAte + "'","",.T.,"")
	
	//
	RestArea(aArea)
	
Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณlifExpSF       บAutor  ณEverson      บ Data ณ  21/06/2018   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFun็ใo para envio de cadastro de cliente.                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณChamado 037261.                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function lifExpSF(nOpc)   

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declaracao de Variaveis                                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู	
	Local aArea	:= GetArea()

	U_ADINF009P('ADVEN095P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Fun็ใo para cadastro de visitas e liga็๕es.')
	
	//
	//Static Call(AD0080,intEnvSF,nOpc)
	//@history Ticket 70142  - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
	u_0080A0( nOpc )
	
	//
	RestArea(aArea)
	
Return Nil 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณlifExpLSF      บAutor  ณEverson      บ Data ณ  21/06/2018   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFun็ใo para envio de cadastro de cliente leitura txt.       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณChamado 037261.                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/     
User Function lifExpLSF()   

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declaracao de Variaveis                                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู	
	Local aArea	:= GetArea()

	U_ADINF009P('ADVEN095P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Fun็ใo para cadastro de visitas e liga็๕es.')
	
	//Static Call(AD0080,ProcessarL)
	//@history Ticket 70142  - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
	u_0080A1()	

	//
	RestArea(aArea)
		
Return Nil
