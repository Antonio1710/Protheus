#INCLUDE "rwmake.ch"  
#include "topconn.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "JPEG.CH"            

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณPrograma  ณ RRPCP001 ณ Autor ณ Ricardo Lima          ณ Data ณ29/07/2015ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณLocacao   ณ                  ณContato ณ                                ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณSistema de pesagem em balanca rodov'iaria - RACAO           ณฑฑ
ฑฑณ          ณ                                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ                                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณ                                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณAplicacao ณBalanca rodoviaria - Sistema de Balanca Fabrica Racao       ณฑฑ
ฑฑณ          ณ                                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ                                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤมฤฤฤยฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณAnalista Resp.ณ  Data  ณ Manutencao Efetuada                           ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRICARDO LIMA  ณ01/08/11ณ EXCLUIDO A INCLUSAO DE OP                     ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRICARDO LIMA  ณ19/10/15ณ NOVO BOTAO PARA PROGAMACAO DE RACAO           ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/                                                                           

User Function RRPCP001 // U_RRPCP001()
// Variaveis Locais da Funcao
Local oFnt
Local oFontTit := TFont():New('ARIAL',,-16,.T.)

// Variaveis Private da Funcao
Private Dialo				// Dialog Principal
Private _oDlg				// Dialog pesagem manual
// Variaveis que definem a Acao do Formulario
Private VISUAL 		:= .F.
Private INCLUI 		:= .F.
Private ALTERA 		:= .F.
Private DELETA 		:= .F.            
Private _nHnd  		:= 0 					&&Adicionado por Rodrigo Sanches 16/03/2011
Private _nPeso 		:= 0 					&&Adicionado por Rodrigo Sanches 16/03/2011    
Private cEOF   		:= CHR(13) + CHR(10) 	&&Adicionado por Rodrigo Sanches 16/03/2011
Private aUsados 	:= {}
Private lOnlyRImp 	:= .F. //__CUSERID $ SuperGetMv("BR_RRPCP01",.F.,"000000")   //Verifica se o usuario e' somente para reimpressao
Private cNumGuia  	:= ""   

Private cNome := ""
Private cEnd  := ""
Private cMun  := ""
Private cEst  := ""
Private cLATGRAU := 0
Private cLATMINU := 0
Private cLATSEG  := 0
Private cLONGRAU := 0
Private cLONMIN  := 0
Private cLONSEG  := 0

_nPeso	:=	0
_cPeso	:=	""
_nEscolha	:=	0
_cModo	:=	"1"
_np	:=	30
_npi:=100
cEdit1	 := 0

_cGuia		:=	space(6)
_nPesoRota	:=	0
_lContinua	:=	.T.
_cTela	:=	" "
_cRei	:=	"1"
_lFrete	:=	.F.
_TPFRT  :=  ""
_aOP	:=	{}    
Public cMenNota	:=SPACE(100)
Public oMenNota
Public c_cPlaca	:=	 space(8) 
Public cEspecie	:= "SPED" + Space(LEN("SPED") - 20)
Public oEspecie 
Public cTRANSP	:=Space(06)

//31/08/2011 -  
//+--------------------------------------------------------+
//|Verifica se tera apenas acesso a reimpressao            |
//+--------------------------------------------------------+
If lOnlyRImp
	RRPCP001I()
	Return
EndIf

DEFINE FONT oFnt NAME "Arial" SIZE 050,120 BOLD

DEFINE MSDIALOG Dialo TITLE "" FROM C(242),C(284) TO C(480),C(820) PIXEL STYLE DS_MODALFRAME

// Cria as Groups do Sistema
@ C(002),C(002) TO C(013),C(269) LABEL "" PIXEL OF Dialo
oFontTit:Bold := .T.
oFontTit:Italic := .T.
@ C(005),C(095) Say "Balan็a Rodoviแria - Ra็ใo" Size C(200),C(008) COLOR CLR_RED Font oFontTit Pixel Of Dialo

@ C(014),C(219) TO C(095),C(269) LABEL "Tipo" PIXEL OF Dialo
@ C(096),C(002) TO C(118),C(152) LABEL "Pesos" PIXEL OF Dialo
@ C(096),C(154) TO C(118),C(215) LABEL "Guia" PIXEL OF Dialo

@ C(016),C(002) TO C(095),C(215) LABEL "" PIXEL OF Dialo
//@ C(062),C(001) TO C(085),C(152) LABEL "Transferencia" 	PIXEL OF Dialo
//@ C(004),C(154) TO C(085),C(215) LABEL "Abastecimento" PIXEL OF Dialo//INCLUSO POR BRUNO RODRIGUES 10/01/12 - CONTROLE DE ABASTECIMENTO PARA FABRICA DE RAวรO 

// Cria Componentes Padroes do Sistema
//	@ C(005),C(003) Say "Label1" Size C(210),C(074) COLOR CLR_BLACK PIXEL OF _oDlg
@ C(035),C(050) Say _nPeso Size C(210),C(074) Picture "@E 99,999"  FONT oFnt COLOR CLR_HRED PIXEL OF Dialo
@ C(020),C(226) Button "&Racao"   			Size C(037),C(012) PIXEL OF Dialo  	Action(RRPCP001D())
@ C(038),C(226) Button "&Insumos" 			Size C(037),C(012) PIXEL OF Dialo  	Action(RRPCP001E(_nPeso))
//@ C(056),C(226) Button "&Diversos" 			Size C(037),C(012) PIXEL OF Dialo  	Action(RRPCP001F())
//@ C(074),C(226) Button "&Pago" 				Size C(037),C(012) PIXEL OF Dialo  	Action(RRPCP001G())
//If CNIVEL>=8//upper(alltrim(cUserName)) !="PORTARIA" //.AND. upper(alltrim(cUserName)) !="ITATIBA"
	@ C(102),C(010) Button "&Manual" 			Size C(037),C(012) PIXEL OF Dialo	Action(RRPCP001H())
	//@ C(071),C(010) Button "&Transferir" 	Size C(037),C(012) PIXEL OF Dialo	Action(RRPCP001T())
//endif
//IF cFilant $ GetMv("BR_H156LGZ")
//	@ C(010),C(167) Button "Abertura" 			Size C(037),C(012) PIXEL OF Dialo  	Action(OpenTGas())
//	@ C(028),C(167) Button "Fechamento"			Size C(037),C(012) PIXEL OF Dialo  	Action(CloseTGas())
//	@ C(046),C(167) Button "Consulta"			Size C(037),C(012) PIXEL OF Dialo  	Action(CheckTGas())
//EndIf


@ C(102),C(060) Button "Le Peso" 			Size C(037),C(012) PIXEL OF Dialo  	Action(_nPeso:=RRPCP001B())
@ C(102),C(110) Button "Limpa Peso" 		Size C(037),C(012) PIXEL OF Dialo  	Action(RRPCP001C())
@ C(102),C(160) Button "Reimpressao Guia" 	Size C(049),C(012) PIXEL OF Dialo	Action(RRPCP001I())
@ C(102),C(225) Button "&Sair" 				Size C(037),C(012) PIXEL OF Dialo 	Action(RRPCP001A())

ACTIVATE MSDIALOG Dialo CENTERED

Return(.T.)
                    

//++====================================================++
//|| FECHA O DIALOGO                                    ||
//++====================================================++
STATIC FUNCTION RRPCP001A
Dialo:End()
RETURN


/*
ษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออป
บPrograma  ณHHR156    บAutor  ณMicrosiga           บ Data ณ  09/09/11   บ
ฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออน
บDesc.     ณVisualiza os Veiculos com abastecimento em aberto           บ
บ          ณ                                                            บ
ศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

Static Function CheckTGas()  
//+-------------------------------------------------+             
// Variaveis Locais da Funcao                       |
//+-------------------------------------------------+             
Private cdDtaAte	:= CTOD("//")
Private cdDtaDe	 	:= CTOD("//")
Private nRadioGrp1	:= 1
Private odDtaAte
Private odDtaDe
Private oRadioGrp1
Private oOk 	   := LoadBitmap( GetResources(), "BR_VERDE_OCEAN")
Private oNo 	   := LoadBitmap( GetResources(), "BR_BRANCO_OCEAN")
// Privates das ListBoxes
Private aListBox1 := {}
Private oListBox1
Private xCQ:=""

//+---------------------------------------------+
//|Monta a consulta de 7 dias atraz com todos os| 
//|Registros                                    |
//+---------------------------------------------+
CheckGasSql("ALL",(DDATABASE-7),DDATABASE,.f.)                        

	DEFINE MSDIALOG _oDlg TITLE "Consulta" FROM C(257),C(286) TO C(484),C(1072) PIXEL
	
		// Cria Componentes Padroes do Sistema
		@ C(003),C(293) TO C(058),C(386) LABEL "Filtro" PIXEL OF _oDlg
		@ C(007),C(296) Radio oRadioGrp1 Var nRadioGrp1 Items "Em Abastecimento","Abastecidos" 3D Size C(056),C(010) PIXEL OF _oDlg
		@ C(061),C(346) MsGet odDtaDe Var cdDtaDe Size C(040),C(009) COLOR CLR_BLACK PIXEL OF _oDlg
		@ C(062),C(294) Say "Data De:" Size C(023),C(008) COLOR CLR_BLACK PIXEL OF _oDlg
		@ C(076),C(294) Say "Data Ate:" Size C(024),C(008) COLOR CLR_BLACK PIXEL OF _oDlg
		@ C(076),C(346) MsGet odDtaAte Var cdDtaAte Size C(040),C(009) COLOR CLR_BLACK PIXEL OF _oDlg
		DEFINE SBUTTON FROM C(096),C(352) TYPE 1 ENABLE OF _oDlg ACTION (CheckGasSql(IF(nRadioGrp1==1,"ABT","FCH"),CdDtaDe,cdDtaAte,.T.)    )

// Para editar os Campos da ListBox inclua a linha abaixo          
	// na opcao de DuploClick da mesma, ou onde for mais conveniente   
	// lembre-se de mudar a picture respeitando a coluna a ser editada 
	// PS: Para habilitar o DuploClick selecione a op็ใo MarkBrowse da 
	//     ListBox para SIM.                                           
	// lEditCell( aListBox, oListBox, "@!", oListBox:ColPos )          

	@ C(000),C(000) ListBox oListBox1 Fields ;
		HEADER "","Placa","Cartao","Data de Entrada","Data de Saida","Peso 1","Peso 2 ","Peso Liq.";
		Size C(287),C(092) Of _oDlg Pixel;
		ColSizes 10,30,30,50,50,50,50,50
		CheckGasAux() //Define de Array
	
	ACTIVATE MSDIALOG _oDlg CENTERED 
		
Return 
                                                     
//+==============================================================+
//|Faz a consulta ao banco de dados                              |
//+==============================================================+
Static Function CheckGasSql(TpAbastece,DtaMin,DtaMax,lDlg)

//Valida se a Data foi preenchida
If Empty(DtaMin)
	DtaMin:=DDATABASE
EndIf

If Empty(DtaMax)
	DtaMax:=DDATABASE
EndIf


//Monta a Query de consulta
xCq:=" SELECT "
xCq+=" ZFE_VEICUL,ZFE_NCARD,ZFE_DATA_1,ZFE_DATA_2,ZFE_PESO_1,ZFE_PESO_2,ZFE_PESO_L,ZFE_STGAS "
xCq+=" FROM "+RetSqlName("ZFE")+" "
xCq+=" WHERE  ZFE_FILIAL='"+xFilial("ZFE")+"'  "
xCq+=" AND (ZFE_DATA_1 BETWEEN '"+DTOS(DtaMin)+"' AND '"+DTOS(DtaMax)+"') "

If TpAbastece=="FCH"//Fechadas-Abastecidas
	xCq+=" AND ZFE_STGAS='S' "
ElseIf TpAbastece=="ABT"
	xCq+=" AND ZFE_STGAS='' "
EndIf

xCq+="AND ZFE_NCARD<>''  "
xCq+=" AND D_E_L_E_T_='' "     
xCq+="   ORDER BY ZFE_DATA_1 DESC,ZFE_VEICUL "

TcQuery xCQ New Alias "TZFE"
DbSelectArea("TZFE")
DbGotop()                                                               


//+--------------------------------------------+         
//|Alimenta o array do listbox                 |
//+--------------------------------------------+         
aListBox1:={}
While !Eof()
	Aadd(aListBox1,{ZFE_STGAS,ZFE_VEICUL,ZFE_NCARD,STOD(ZFE_DATA_1),STOD(ZFE_DATA_2),ZFE_PESO_1,ZFE_PESO_2,ZFE_PESO_L})
	DbSkip()
End

        
//verifica se o array esta vazio
If Len(aListBox1)<=00
	Aadd(aListBox1,{"","","",ctod("//"),ctod("//"),0,0,0})
EndIf

If lDlg
	CheckGasAux() 
	oListBox1:Refresh()
EndIf


TZFE->(DbCloseArea())
Return


//+============================================+
//|Funcao auxiliar de define de array          |
//+============================================+
Static Function CheckGasAux

	oListBox1:SetArray(aListBox1)

	// Carrege aqui sua array da Listbox

	oListBox1:bLine := {|| {;
		If(aListBox1[oListBox1:nAT,1]=="S",oOk,oNo),;
		aListBox1[oListBox1:nAT,02],;
		aListBox1[oListBox1:nAT,03],;
		aListBox1[oListBox1:nAT,04],;
		aListBox1[oListBox1:nAT,05],;
		aListBox1[oListBox1:nAT,06],;
		aListBox1[oListBox1:nAT,07],;
		aListBox1[oListBox1:nAT,08]}}
Return	

/*
ษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออป
บPrograma  ณHHR156    บAutor  ณMicrosiga           บ Data ณ  09/08/11   บ
ฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออน
บDesc.     ณ Faz a abertura de Abastecimento                            บ
บ          ณ                                                            บ
ศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

Static Function OpenTGas
//+-----------------------------------------------------+
//|Declaracao de Variaveis                              |
//+-----------------------------------------------------+


//Valida o peso          
If _nPeso<=0
	ALERT("PESO ZERADO OU INVALIDO!")	
	Return
EndiF


    
//Monta a Tela de Digitacao - Inclusao
TGasScreen("OPEN") 
                               

//Apos Digitacao zera a pesagem
_nPeso:=0

Return


Static Function CloseTGas()
//Valida o peso          
If _nPeso<=0
	ALERT("PESO ZERADO OU INVALIDO!")	
	Return
EndiF
   
//Monta a Tela de Digitacao - Inclusao
TGasScreen("CLOSE")                             

//Apos Digitacao zera a pesagem
_nPeso:=0

Return


/*
ษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออป
บPrograma  ณHHR156    บAutor  ณMicrosiga           บ Data ณ  09/08/11   บ
ฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออน
บDesc.     ณ Monta a Tela de Digitacao de informacoes de abastecimento  บ
บ          ณ                                                            บ
ศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

Static Function TGasScreen(_Option)
//+-----------------------------------------------------+
//|Declaracao de Variaveis                              |
//+-----------------------------------------------------+ 
//Objetos do Dialogo
Private oDlg1,oSay1,oSay2,oSay3,oSay4,oSay5,oSay6,oGrp1,oSay7,oPlacaGas,oCardGas,oSBtn1,oSBtn2,oOBSGAs,oLTGas
Private oFontTgas		:=tFont():New('Arial',,-12,.F.,.T.) //Bold
Private cTypeText	:=IF(_Option=="CLOSE","ENCERRAMENTO DE ABASTECIMENTO","ABASTECIMENTO")
Private cTranspTxt	:=""   
Private cMotorTXT	:=""  
Private cPlacaGas	:=Space(Len(ZFE->ZFE_VEICUL))
Private cCardGas	:=Space(Len(ZFE->ZFE_NCARD))    
Private nLTGas		:=0
Private cObsGas     :=Space(Len(ZFE->ZFE_OBS))


//+--------------------------------------------------+
//|Se for encerramento muda da tela e adciona campos |
//+--------------------------------------------------+

If _Option=="CLOSE"  //Encerramento
	oDlg1      := MSDialog():New( 214,418,507,848,"Controle de Abastecimento - ENCERRAMENTO",,,.F.,,,,,,.T.,,,.T. )
Else
	oDlg1      := MSDialog():New( 214,418,444,848,"Controle de Abastecimento",,,.F.,,,,,,.T.,,,.T. )
EndIf

oSay1      := TSay():New( 008,004,{||"Placa :"},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,024,008)
oSay2      := TSay():New( 008,100,{||"Cartใo"},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
oSay3      := TSay():New( 028,004,{||"Transportadora"},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,040,008)
oSay4      := TSay():New( 028,048,{||cTranspTxt},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,148,008)
oSay5      := TSay():New( 044,004,{||"Motorista"},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
oSay6      := TSay():New( 044,048,{||cMotorTXT},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,152,008)
If _Option=="CLOSE"
	oSayPl     := TSay():New( 044,120,{||"P. Liq: "+Transform(PosToGetLiq(cCardGas,cPlacaGas),"@E 999,999,999")},oDlg1,,oFontTgas,.F.,.F.,.F.,.T.,CLR_GREEN,CLR_WHITE,152,008)
EndIf
If _Option=="CLOSE"//Encerramento
	oSay8      := TSay():New( 076,004,{||"Obs.:"},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
	oSay9      := TSay():New( 060,004,{||"Litros"},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
	oGrp1      := TGroup():New( 088,004,112,204,"Mensagens",oDlg1,CLR_BLACK,CLR_WHITE,.T.,.F. )
	oSay7      := TSay():New( 100,008,{||cTypeText},oGrp1,,oFontTgas,.F.,.F.,.F.,.T.,CLR_HRED,CLR_WHITE,192,008)
	oLTGas     := TGet():New( 060,048,{|u| If(PCount()>0,nLTGas:=u,nLTGas)},oDlg1,060,008,'@E 99,999.9999',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","",,)
	oOBSGAs    := TGet():New( 076,048,{|u| If(PCount()>0,cObsGas:=u,cObsGas)},oDlg1,156,008,'@!',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","",,)
Else
	oGrp1      := TGroup():New( 060,004,084,204,"Mensagens",oDlg1,CLR_BLACK,CLR_WHITE,.T.,.F. )
	oSay7      := TSay():New( 072,008,{|| cTypeText },oGrp1,,oFontTgas,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,192,008)
EndIF


oPlacaGas  := TGet():New( 008,036,{|u| If(PCount()>0,cPlacaGas:=u,cPlacaGas)},oDlg1,060,008,'@R !!!-9999',{|| CanTkGas(cPlacaGas,_Option)},CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"DA3","cPlacaGas",,)
oCardGas   := TGet():New( 008,136,{|u| If(PCount()>0,cCardGas:=u,cCardGas)},oDlg1,060,008,'999',{|| SCard(cCardGas,_Option)},CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","cCardGas",,)



//+---------------------------------+
//|Definicao de Botoes              |
//+---------------------------------+
If _Option=="CLOSE"//Encerramento
	oSBtn1     := SButton():New( 120,176,1,{|| oDlg1:END(),RecordGas(cCardGas,cPlacaGas,_Option)},oDlg1,,"", )
	oSBtn2     := SButton():New( 120,148,2,{|| oDlg1:END()},oDlg1,,"", )
Else
	oSBtn1     := SButton():New( 092,176,1,{|| oDlg1:END(),RecordGas(cCardGas,cPlacaGas,_Option)},oDlg1,,"", )
	oSBtn2     := SButton():New( 092,148,2,{|| oDlg1:END()},oDlg1,,"", )
EndIf        

//+-----------------------------+
//|Sets da Janela               |
//+-----------------------------+
oPlacaGas:SetFocus()

oDlg1:Activate(,,,.T.)



Return

//+-----------------------------------------+
//|Obtem o peso liquido                     |
//+-----------------------------------------+
Static Function PosToGetLiq(cNCard,cPlacaGas)
	xCQ:=""
	xCQ+=" SELECT R_E_C_N_O_ AS RECNOX FROM "+RetSqlName("ZFE")+" "
	xCQ+=" WHERE "
	xCQ+=" ZFE_FILIAL='"+xFilial("ZFE")+"' "
	xCQ+=" AND ZFE_NCARD='"+cNCard+"' "   
	xCQ+=" AND ZFE_VEICUL='"+cPlacaGas+"' "
	xCQ+=" AND ZFE_STGAS='' "
	xCQ+=" AND D_E_L_E_T_='' "
	
	TCQUERY xCQ NEW ALIAS "TZFE2" 
	DbSelectArea("TZFE2")
	DbGotop()
	_recno:=RECNOX
	TZFE2->(DbCloseArea())
	
	
	DbSelectArea("ZFE")
	DbGoto(_Recno)
	                  
Return((_nPeso-ZFE_PESO_1))

/*
ษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออป
บPrograma  ณHHR156    บAutor  ณMicrosiga           บ Data ณ  09/08/11   บ
ฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออน
บDesc.     ณ Faz a gravacao dos dados                                   บ
บ          ณ                                                            บ
ศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

Static Function RecordGas(cNCard,cPlacaGas,_Option)   
Local xCq:=""
Local _recno:=0

If _Option=="CLOSE"

	xCQ:=""
	xCQ+=" SELECT R_E_C_N_O_ AS RECNOX FROM "+RetSqlName("ZFE")+" "
	xCQ+=" WHERE "
	xCQ+=" ZFE_FILIAL='"+xFilial("ZFE")+"' "
	xCQ+=" AND ZFE_NCARD='"+cNCard+"' "   
	xCQ+=" AND ZFE_VEICUL='"+cPlacaGas+"' "
	xCQ+=" AND ZFE_STGAS='' "
	xCQ+=" AND D_E_L_E_T_='' "
	
	TCQUERY xCQ NEW ALIAS "TZFE2" 
	DbSelectArea("TZFE2")
	DbGotop()
	_recno:=RECNOX
	TZFE2->(DbCloseArea())
	
	
	DbSelectArea("ZFE")
	DbGoto(_Recno)
	                  
	
	RecLock("ZFE",.F.)
		ZFE_PESO_2	:=_nPeso   
		ZFE_PESO_T	:=_nPeso
		ZFE_PESO_L	:=(_nPeso-ZFE_PESO_1)
		ZFE_DATA_2	:=DDATABASE
		ZFE_DATA_T	:=DDATABASE
		ZFE_HORA_2	:=left(time(),5)
		ZFE_HORA_T	:=left(time(),5)
		ZFE_USER_2	:=CUSERNAME		
		ZFE_STGAS	:="S"
		ZFE_OBS		:=cObsGas   
		ZFE_LITROS	:=nLTGas
		ZFE_MODO_T	:=_cModo
	MsUnlock()
	
RRPCP001D4()		
Else

	cNumGuia:=GETSXENUM("ZFE")	//Obtem o proximo numero de Guia
	CONFIRMSX8()

	//+----------------------------------------------+
	//|Grava os dados da Pesagem de Abastecimento    |
	//+----------------------------------------------+
	RecLock("ZFE",.T.)    
		ZFE_FILIAL	:=xFilial("ZFE")
		ZFE_NUM		:=cNumGuia
		ZFE_TIPO	:="3"
		ZFE_VEICUL	:=cPlacaGas
		ZFE_VEIC_R	:=cPlacaGas
		ZFE_PESO_1	:=_nPeso
		ZFE_DATA_1	:=DDATABASE
		ZFE_HORA_1	:=left(time(),5)
		ZFE_USER_1	:=CUSERNAME		
		ZFE_MOTORI	:=DA3->DA3_MOTORI
		ZFE_NOMMOT	:=DA4->DA4_NOME
		ZFE_LOTE	:="DIESEL"
		ZFE_NCARD	:=cCardGas     
		ZFE_MODO_1	:=_cModo
	MsUnlock()
EndIf	
Return 

/*
ษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออป
บPrograma  ณHHR156    บAutor  ณMicrosiga           บ Data ณ  09/05/11   บ
ฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออน
บDesc.     ณ procura pelo numero do cartao na base de dados e verifica  บ
บ          ณ se nao esta em uso por algum veiculo                       บ
ศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

Static Function SCard(cNCard,_Option)
Local aArea	:=GetArea()
Local xCq	:=""
Local lRet	:=.T.

//Compatibiliza o campo
cNCard:=ALLTRIM(cNCard)

              
                                                        
//+---------------------------------------------------------+
//Verifica se o Cartao nao esta em uso por outro veiculo    |
//+---------------------------------------------------------+
xCQ+=" SELECT ZFE_VEICUL,ZFE_DATA_1 FROM "+RetSqlName("ZFE")+" "
xCQ+=" WHERE "
xCQ+=" ZFE_FILIAL='"+xFilial("ZFE")+"' "
xCQ+=" AND ZFE_NCARD='"+cNCard+"' "   
xCQ+=" AND ZFE_NCARD<>'' "   
xCQ+=" AND ZFE_VEICUL<>'"+cPlacaGas+"' "
xCQ+=" AND ZFE_STGAS='' "
xCQ+=" AND D_E_L_E_T_='' "

TCQUERY xCQ NEW ALIAS "TZFE" 
DbSelectArea("TZFE")
DbGotop()

If Eof()
	lRet:=.T.
	oSay7:SetText("")
	oSay7:CtrlRefresh() 	
Else
	lRet:=.F.         
	oSay7:SetText("CARTAO EM USO : "+ZFE_VEICUL+" ENTRADA: "+DTOC(STOD(ZFE_DATA_1)))     
	oSay7:CtrlRefresh() 	
EndIf
                
                  

If _Option=="CLOSE" 
	//+---------------------------------------------------------+
	//|Procura pelo numero do cartao + placa  e Valida se tudo  |
	//|Esta OK                                                  |
	//+---------------------------------------------------------+    
	xCQ:=""
	xCQ+=" SELECT ZFE_VEICUL,ZFE_DATA_1 FROM "+RetSqlName("ZFE")+" "
	xCQ+=" WHERE "
	xCQ+=" ZFE_FILIAL='"+xFilial("ZFE")+"' "
	xCQ+=" AND ZFE_NCARD='"+cNCard+"' "   
	xCQ+=" AND ZFE_VEICUL='"+cPlacaGas+"' "
	xCQ+=" AND ZFE_STGAS='' "
	xCQ+=" AND D_E_L_E_T_='' "
	
	TCQUERY xCQ NEW ALIAS "TZFE2" 
	DbSelectArea("TZFE2")
	DbGotop()
	
	If Eof()
		lRet:=.F.
		oSay7:SetText("CARTAO NAO ENCONTRADO PARA ESSA PLACA")     
		oSay7:CtrlRefresh()  
		oCardGas:SetFocus()
	Else
		lRet:=.T.
	EndIF
	
	TZFE2->(DbCloseArea())	
	
EndIF

//Verifica se o numero do cartao esta vazio
If Empty(cNCard)
	lRet:=.F.      
	oSay7:SetText("INFORME UM NUMERO DE CARTAO")     
	oSay7:CtrlRefresh()  
	oCardGas:SetFocus()
EndIf
        


//Controle de Foco     
If _Option=="CLOSE" .and. lret
	oLTGas:SetFocus()    
EndiF
     
     
TZFE->(DbCloseArea())

RestArea(aArea)
Return(lRet)


/*
ษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออป
บPrograma  ณHHR156    บAutor  ณMicrosiga           บ Data ณ  08/31/11   บ
ฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออน
บDesc.     ณ  Valida se o veiculo pode fazer abastecimento              บ
บ          ณ  De acordo com a transportadora                            บ
ศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

Static Function CanTkGas(cPlcVei,_Option)
Local aArea:=GetArea()  
Local lRet:=.T.  
Local xCQ:=""           

Private lopenPes:=.F.//Define se avalia pesagens em aberto
Private aOpenPes:={}
                   
//+------------------------------+
//Procura o veiculo              | 
//+------------------------------+
DbSelectArea("DA3")
If DbSeek(xFilial("DA3")+cPlcVei)
                                  
	//+------------------------------+
	//|Procura a transportadora      |
	//+------------------------------+	
	DbSelectArea("SA4")
	If DbSeek(xFilial("SA4")+DA3->DA3_TRANSP)
		IF SA4->A4_LTKGAS=="S"
			lRet:=.T.    
			oSay4:SetText(SA4->A4_NOME)
			oSay4:CtrlRefresh()
			
			
			//+----------------------------------------+
			//|Localiza o nome do motorista            |
			//+----------------------------------------+
			DbSelectArea("DA4")
			If DbSeek(xFilial("DA4")+DA3->DA3_MOTORI)  
				oSay6:SetText(DA4->DA4_NOME)     
				oSay6:CtrlRefresh()
			Else 
				oSay6:SetText("VEICULO SEM MOTORISTA")     
				oSay6:CtrlRefresh()
			EndiF
				
			
		Else
			oSay7:SetText("FROTA NAO AUTORIZADA A ABASTECIMENTO")     
			oSay7:CtrlRefresh()         
			lRet:=.F.
		EndIf
	Else     
		oSay7:SetText("VEICULO SEM TRANSPORTADORA!")     
		oSay7:CtrlRefresh()         
		lret:=.F.
	EndIf
Else 
	oSay7:SetText("VEICULO NAO CADASTRADO!")     
	oSay7:CtrlRefresh() 	
	lRet:=.F.
EndIf



//+-------------------------------------------+
//|Verifica se nao e' encerramento            |
//+-------------------------------------------+
If _Option<>"CLOSE" .and. lRet
	//+--------------------------------------------+
	//|Verifica se a placa ja nao tem um cartao    |
	//|em aberto                                   |
	//+--------------------------------------------+
	xCQ+=" SELECT ZFE_NCARD,ZFE_DATA_1 FROM "+RetSqlName("ZFE")+" "
	xCQ+=" WHERE "
	xCQ+=" ZFE_FILIAL='"+xFilial("ZFE")+"' "
	xCQ+=" AND ZFE_VEICUL='"+cPlcVei+"' "
	xCQ+=" AND ZFE_STGAS='' "
	xCQ+=" AND ZFE_NCARD<>'' "
	xCQ+=" AND D_E_L_E_T_='' "
	
	TCQUERY xCQ NEW ALIAS "TZFE" 
	DbSelectArea("TZFE")
	DbGotop()
	
	If Eof()
		lRet:=.T.
	Else
		lRet:=.F.      
		oSay7:SetText("Veiculo com abastecimento aberto, cartao: "+ZFE_NCARD)     
		oSay7:CtrlRefresh()	
	EndIf
	TZFE->(DbCloseArea())
	

    If lRet .and. lopenPes
		//+--------------------------------------------+
		//|Verifica se o veiculo contem outras pesagens|
		//|em aberto                                   |
		//+--------------------------------------------+
		xCQ:=""
		xCQ+=" SELECT * FROM "+RetSqlName("ZFE")+" "
		xCQ+=" WHERE "
		xCQ+=" ZFE_FILIAL='"+xFilial("ZFE")+"' "
		xCQ+=" AND ZFE_VEICUL='"+cPlcVei+"' "
		xCQ+=" AND (ZFE_PESO_1=0 OR ZFE_PESO_T=0) "
		xCQ+=" AND ZFE_TIPO<>'3' "
		xCQ+=" AND D_E_L_E_T_='' "
		
		TCQUERY xCQ NEW ALIAS "TZFE2" 
		DbSelectArea("TZFE2")
		DbGotop()
		
		IF Eof()
			lRet:=.T.
		Else           
		
			//+-------------------------------------------+
			//|Monta array de pesagens em aberto          |
			//+-------------------------------------------+
			While !Eof() 
				AADD(aOpenPes,{ZFE_NUM,ZFE_TIPO,ZFE_VEICUL,ZFE_PESO_T,ZFE_PESO_1,ZFE_PESO_2,ZFE_PESO_L,STOD(ZFE_DATA_1),STOD(ZFE_DATA_T),.F.})  
				DbSkip()
			End
			
			lRet:=.F.    
			oSay7:SetText("VEICULO COM OUTRA PESAGEM EM ABERTO!")     
			oSay7:CtrlRefresh() 	
			
			//+-------------------------------------------+
			//Lista as pesagens em abaerto                |
			//+-------------------------------------------+
			ALERT("VEICULO COM OUTRA PESAGEM EM ABERTO!")
			LstOpenP()
			
		EndIf                 
		
		TZFE2->(DbCloseArea())
	EndIf

EndIf


If !lRet //Se nao validar retorno o foco para a Placa
	oPlacaGas:SetFocus()
ELSE
	oSay7:SetText("")     
	oSay7:CtrlRefresh() 	
EndIf
         

RestArea(aArea)
Return(lRet)





/*
ษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออป
บPrograma  ณHHR156    บAutor  ณMicrosiga           บ Data ณ  10/11/11   บ
ฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออน
บDesc.     ณ  Lista as pesagens em aberto                               บ
บ          ณ                                                            บ
ศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

Static Function LstOpenP                       
Local aHeaderlst:={} 
Local oDlg2


//+----------------------------------------+
//|Montagem do Aheader                     |
//+----------------------------------------+
dbSelectArea("SX3")
dbSeek("ZFE")
While !eof() .and. X3_ARQUIVO=="ZFE" 
	If ALLTRIM(X3_CAMPO) $ "ZFE_TIPO,ZFE_VEICUL,ZFE_NUM,ZFE_DATA_T,ZFE_DATA_1,ZFE_PESO_1,ZFE_PESO_2,ZFE_PESO_T,ZFE_PESO_L"
		AADD(aHeaderlst,{X3_TITULO,X3_CAMPO,X3_PICTURE,X3_TAMANHO,X3_DECIMAL,"AllwaysTrue()","",X3_TIPO,"",""})
	EndIf
	DbSkip()
End




//+---------------------------------------+
//|Mostra caixa de dialogo                |
//+---------------------------------------+
oDlg2      := MSDialog():New( 129,285,363,980,"Pesagens em Aberto",,,.F.,,,,,,.T.,,,.T. )
oBrw1      := MsNewGetDados():New(016,004,104,336,0,'AllwaysTrue()','AllwaysTrue()','',,0,99,'AllwaysTrue()','','AllwaysTrue()',oDlg2,aHeaderlst,aOpenPes )
oDlg2:bInit := {|| EnchoiceBar(oDlg2, {|| oDlg2:End()}, {|| oDlg2:End()},,{})}

oDlg2:Activate(,,,.T.)
Return





/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRRPCP001  บAutor  ณ                    บ Data ณ  11/10/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ FAZ A LEITURA DA BALANCA                                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

static function RRPCP001B
//Static Function LeSerial()
// 0800-554211 SUPORTE BALANCAS TOLEDO
/*
Modelo 8530
DataRate = 4800
Paridade = Par
7 bits de dados
2 stop bits
*/
Local _nHnd := 0,_cPeso:="0", _lRet := .F., _cText := "", _i
Local _nqtx := 0
Local _lResult
_nPeso1:=0
DDATABASE	:=	DATE()


//Date: 07/11/2011
//Autor:
//Tratamento para leitura do arquivo texto da unidade de racao Descalvado
//Texto lido
//"8888888" 
//Local de leitura c:\ponto.txt

IF cfilant=='10' //descalvado racao 
	
	nHandle:=ft_fuse("c:\peso.txt")
	
	If nHandle==-1
		alert("Nao foi possivel ler o Peso. Abra o programa LEITURA")
		Return(0)
	Else 
		
		 ft_fgotop()   
		 xBuffer:=FT_FReadLn()

		 xBuffer:=StrTran(xBuffer,'"','')
		 _nPeso:=val(xBuffer)
		 ft_fuse()
	     
	     If File("c:\peso.txt")
		  fErase("c:\peso.txt")
	     EndIf
	     
		 Return(_nPeso)
	EndIf    
endif          





//monte alegre _lResult := MSOpenPort(@_nHnd, "COM1:9600,p,7,2")
_lResult := MSOpenPort(@_nHnd, GetMv("BR_BALCOM1"))


IF !_lResult    
	_nPeso	:= val(_cPeso)
	Return(_nPeso)
EndIf

	//Leitura do peso para Sao Carlos Racao
	If CFILANT=='12'
		wHILE vAL(_cPeso)==0
			MsRead(_nHnd, @_cText)
			INKEY(.5)
			_nqtx++
			if _nqtx>50000
				_cText:="0000000000000000000000000000"+CHR(13)
				exit
			EndIf		
			_cPeso:=Left(_cText,6) 
		END
	eLSE
		While At(chr(13),_cText)<=15
			MsRead(_nHnd, @_cText)
			INKEY(.5)
			_nqtx++
			if _nqtx>50000
				_cText:="0000000000000000000000000000"+CHR(13)
				exit
			EndIf
		EndDo                                           		
	eNDIF	

IF CFILANT<>'12'
	_cPeso := SubStr(_cText,At(chr(13),_cText)-12,6)
ENDIF
for _ii	:=	1 to 2000000
next
IF CFILANT<>'12'
	_cPeso1 := SubStr(_cText,At(chr(13),_cText)-12,6)
ENDIF
//MsClearBuffer(_nHnd)
MsClosePort(_nHnd)                        
IF CFILANT<>'12'
_nPeso	:= val(_cPeso)
_nPeso1	:= val(_cPeso1)
ELSE
_nPeso	:= val(_cPeso)
ENDIF


if _nPeso	<>	_nPeso1 .AND. CFILANT<>'12'
	MSGSTOP("BALANCA NAO ESTABILIZADA!!! PESE NOVAMENTE!!!")
	_nPeso	:= 0
endif
Return _nPeso


                
 
 
 
//++====================================================++
//||ZERA O PESO                                         ||
//++====================================================++
STATIC FUNCTION RRPCP001C
_nPeso	:=	0
RETURN


                                                          

//++====================================================++
//||PESAGEM RACAO                                       ||
//++====================================================++

STATIC FUNCTION RRPCP001D
Local oGet1
Local oGet2
Local oGet3
Local oGet4
Local oGet21
Local cGet21 	:= SPACE(9)   
Local _nVGcrg 	:= ""
Local _nVGseq 	:= ""
Local _clifor 	:= ""

//ษverson - 09/12/2015.
Local nPosSilo
Local nPosNome
Local nPosCodF
Local nPosProd
Local nPosLoja
Local nPosCliFor
Local nPosCodPrg
//

//ษverson - 17/12/2015
Local oGroup1
Local oGroup2
Local oGroup3
Local oGroup4
Local oGet22
Local oGet23
Local cGet23
Local oGet24
Local cGet24
Local oFontTit := TFont():New('ARIAL',,-14,.T.)
//

Private _PesoMaxVC := 0
Private cFiltro
Private oGet20
Private cGet20 := SPACE(6)

_cPlaca	:=	PEGAPLACA3(1)
if	_lContinua
	if _nPeso	> 0 .or.  !empty(c_cPlaca) 
	
	    IF SELECT("TZZ")>0
          TZZ->(DbCloseArea())
        ENDIF
	
	    cQuery	:= " SELECT * FROM "+retsqlname("ZFE")+" AS ZFE "
	    cQuery	+= " WHERE ZFE_VEICUL = '"+c_cPlaca+"' "
        cQuery	+= " AND ZFE_NF = '' AND ZFE_SERIE = '' "
        cQuery	+= " AND ZFE_FILIAL = '"+xFilial("ZFE")+"' AND ZFE_PESO_1 = 0 " 
        cQuery	+= " AND D_E_L_E_T_ = '' "
        
        TCQUERY cQuery new alias "TZZ"
		
  		dbSelectArea("ZFE")
		dbSetOrder(8)
   		dbSeek(xFilial("ZFE") + TZZ->ZFE_NUM + TZZ->ZFE_VEICUL)
		
		if	c_cPlaca == ZFE->ZFE_VEICUL .and. 	ZFE->ZFE_PESO_1	== 0 .and. ZFE->ZFE_PESO_T >0
			// SEGUNDA PESAGEM
			if ZFE->ZFE_TIPO	<> "5"
				MSGSTOP("VEICULO COM OUTRO TIPO PESAGEM EM ABERTO!!!")
				_lContinua	:=	.F.
				return
			endif
			if	_nPeso	< ZFE->ZFE_PESO_T
				MSGSTOP("PESO ATUAL NAO PODE SER MENOR QUE A TARA!!!")
				_lContinua	:=	.F.
				return
			endif      
			
			IF _PesoMaxVC > 0
			  IF _nPeso - ZFE->ZFE_PESO_T > _PesoMaxVC
			    MsgAlert("O peso atual excede a capacidade mแxima do veํculo!","Aten็ใo")
			  ENDIF            
			ENDIF
			
			dbSelectArea("SB1")
			dbSetOrder(1)
			dbSeek(xFilial("SB1")+ZFE->ZFE_PRODUTO,.F.)
			
			cGet1	:= ZFE->ZFE_PRODUTO
			cGet5	:= ALLTRIM(SB1->B1_DESC) + " do Local: "+ ZFE->ZFE_SILO
			
			IF  ZFE->ZFE_CLIFOR = "C"
			
			 dbSelectArea("SA1")
			 dbSetOrder(1)
			 dbSeek(xFilial("SA1")+ZFE->ZFE_COD_R + ZFE->ZFE_LJGR_R,.F.)
			
			 cGet4	:=	GETMV("BR_TSRCCLI")  // "532"
			 cGet2	 := ZFE->ZFE_COD_R
			 cGet6	 := +"-"+ ZFE->ZFE_LJGR_R+" - "+ SA1->A1_NREDUZ
			
			ELSE
			
			 dbSelectArea("SA2")
			 dbSetOrder(1)
			 dbSeek(xFilial("SA2")+ZFE->ZFE_COD_R + ZFE->ZFE_LJGR_R,.F.)
			
			 cGet4	:=	GETMV("BR_TSRCFOR")  // "600"
			 cGet2	 := ZFE->ZFE_COD_R
			 cGet6	 := +"-"+ ZFE->ZFE_LJGR_R+" - "+ SA2->A2_NREDUZ
			
			ENDIF
			
			cGet3	:= U_PEGA_CM(ZFE->ZFE_PRODUT,ZFE->ZFE_SILO,xFilial("ZFE"))
			cGet7	:=	SPACE(200)
			
			cGet20 	:= pegaLote(Alltrim(cValToChar(ZFE->ZFE_CODPRO))) //ษverson - 09/12/2015.
			cGet24 :=  pegaGalpao(Alltrim(cValToChar(ZFE->ZFE_CODPRO))) //ษverson - 22/12/2015.
			
			cGet23  := cGet2 + cGet6
			Private oDlgSeg
			
			DEFINE MSDIALOG oDlgSeg TITLE "Segunda Pesagem de Ra็ใo" FROM C(242),C(284) TO C(480),C(820) PIXEL STYLE DS_MODALFRAME
			
			// Cria Componentes Padroes do Sistema
			@ C(002),C(098) Say "Confirma็ใo De Carregamento" Size C(200),C(008) COLOR CLR_RED Font oFontTit Pixel Of oDlgSeg
			
			@ C(009),C(036) GROUP oGroup3 To C(048), C(241) Prompt "" Of oDlgSeg Color 0, 16777215 Pixel
			@ C(011),C(040) Say "Ra็ใo:" Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgSeg
			@ C(017),C(040) MsGet oGet1  Var cGet1 Size C(040),C(009) COLOR CLR_BLACK Picture "@!" Pixel Of oDlgSeg VALID ExistCpo("SB1",cGet1) When .F.
			@ C(011),C(096) Say "Local:" Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgSeg
			@ C(017),C(096) MsGet oGet22 Var cGet5 Size C(100),C(009) COLOR CLR_BLACK Picture "@!" Pixel Of oDlgSeg When .F.
			@ C(029),C(040) Say   "Destino:" Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgSeg
			@ C(035),C(040) MsGet oGet2  Var cGet23 Size C(147),C(009) COLOR CLR_BLACK Picture "@!" Pixel Of oDlgSeg When .F.  //ษverson - 05/11/2015 //ษverson - 05/11/2015
			@ C(029),C(190) Say "Lote:" Size C(055),C(008) COLOR CLR_BLACK PIXEL OF oDlgSeg
			@ C(035),C(190) MsGet oGet20 Var cGet20 Size C(030),C(009) COLOR CLR_BLACK PIXEL OF oDlgSeg When .F. //ษverson - 09/12/2015. Campo nใo serแ editแvel.
			@ C(029),C(224) Say "Galpใo:" Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlgSeg
			@ C(035),C(224) MsGet oGet24 Var cGet24 Size C(010),C(009) COLOR CLR_BLACK Picture "@!" Pixel Of oDlgSeg When .F.
			
			@ C(050),C(036) GROUP oGroup4 To C(085), C(241) Prompt "" Of oDlgSeg Color 0, 16777215 Pixel
			@ C(056),C(040) Say "TES:" Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgSeg
			@ C(054),C(055) MsGet oGet4 Var cGet4 Size C(013),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgSeg F3 "SF4" VALID (Existcpo("SF4").And.MaAvalTes("S",cGet4))
			@ C(071),C(040) Say "Lacres:" Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgSeg
			@ C(069),C(055) MsGet oGet7 var cGet7 Size C(150),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgSeg 
			
			@ C(087),C(036) GROUP oGroup2 To C(108), C(158) Prompt "" Of oDlgSeg Color 0, 16777215 Pixel
			@ C(090),C(090) Say "Aten็ใo!" Size C(028),C(008) COLOR CLR_RED Pixel Of oDlgSeg
			@ C(096),C(036) Say "A exclusใo indicarแ que o veํculo e/ou destino estใo incorretos." Size C(201),C(008) COLOR CLR_RED Pixel Of oDlgSeg
			@ C(100),C(036) Say "Serแ necessแrio refazer o processo de carregamento do inํcio."    Size C(155),C(008) COLOR CLR_RED   Pixel Of oDlgSeg
			
			@ C(091),C(160) GROUP oGroup1 To  C(108), C(241) Prompt "" Of oDlgSeg Color 0, 16777215 Pixel
			@ C(095),C(165) BMPBUTTON TYPE 01 ACTION (RRPCP001D1(cGet1,cGet2,cGet7,cGet4,cGet20,cGet21,ZFE->ZFE_CLIFOR,ZFE->ZFE_LJGR_R,oDlgSeg)) // racao/destino/lacre/tes //ษverson - 17/11/2015 adicionada a loja.
			@ C(095),C(190) BMPBUTTON TYPE 02 ACTION (Close(oDlgSeg),_lContinua	:=	.F.)
			@ C(095),C(215) BMPBUTTON TYPE 03 ACTION (Close(oDlgSeg),_lContinua	:=	.F.,RRPCP001DX())	//cancela a pesagem
			
			ACTIVATE MSDIALOG oDlgSeg CENTERED
			
		else
			//PRIMEIRA PESAGEM
			dbSelectArea("ZFE")
			dbSetOrder(1)
			nOpcx:=3    // inclusao

			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ Montando aHeader                                             ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			dbSelectArea("SX3")
			dbSetOrder(1)
			dbSeek("ZFE")
			nUsado:=0
			aHeader:={}
			While !Eof() .And. (x3_arquivo == "ZFE")
				IF ALLTRIM(X3_CAMPO) = "ZFE_PRODUT"	.OR. ALLTRIM(X3_CAMPO) = "ZFE_SILO" .OR. ALLTRIM(X3_CAMPO) = "ZFE_COD_R" .OR. ALLTRIM(X3_CAMPO) = "ZFE_LJGR_R"; //ษverson - 16/11/2015. Adicionado o campo ZFE_LJGR_R.
				.OR. ALLTRIM(X3_CAMPO) = "ZFE_NOM_R" .OR. ALLTRIM(X3_CAMPO) = "ZFE_CLIFOR" .OR. ALLTRIM(X3_CAMPO) = "ZFE_CODPRO"  // Ricardo Lima - 19/10/15
					IF X3USO(x3_usado) 
						nUsado	:=	nUsado	+	1
						AADD(aHeader,{ TRIM(x3_titulo), alltrim(x3_campo), x3_picture,;
						x3_tamanho, x3_decimal,"ExecBlock('BRWP001',.f.,.f.)",;
						x3_usado, x3_tipo, x3_arquivo, x3_context } )
					Endif       	
				Endif
				dbSkip()
			End

			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ Montando aCols                                               ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			aCols:=Array(1,nUsado+1)
			dbSelectArea("Sx3")
			dbSeek("ZFE")            
			nUsado:=0
			While !Eof() .And. (x3_arquivo == "ZFE")
				IF ALLTRIM(X3_CAMPO) = "ZFE_PRODUT" .OR. ALLTRIM(X3_CAMPO) = "ZFE_SILO" .OR. ALLTRIM(X3_CAMPO) = "ZFE_COD_R" .OR. ALLTRIM(X3_CAMPO) = "ZFE_LJGR_R";  //ษverson - 16/11/2015. Adicionado o campo ZFE_LJGR_R.
				.OR. ALLTRIM(X3_CAMPO) = "ZFE_NOM_R" .OR. ALLTRIM(X3_CAMPO) = "ZFE_CLIFOR".OR. ALLTRIM(X3_CAMPO) = "ZFE_CODPRO"  // Ricardo Lima - 19/10/15
					IF X3USO(x3_usado)
						nUsado:=nUsado+1
						IF nOpcx == 3
							IF x3_tipo == "C"
								aCOLS[1][nUsado] := SPACE(x3_tamanho)
							Elseif x3_tipo == "N"
								aCOLS[1][nUsado] := 0
							Elseif x3_tipo == "D"
								aCOLS[1][nUsado] := dDataBase
							Elseif x3_tipo == "M"
								aCOLS[1][nUsado] := ""
							Else
								aCOLS[1][nUsado] := .F.
							Endif
						ENDIF
					Endif
				endif
				dbSkip()
			End
	
			aCOLS[1][nUsado+1] := .F.

			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ Variaveis do Rodape do Modelo 2                              ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			nLinGetD:=0

			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ Titulo da Janela                                             ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			cTitulo:="Produtos de Pesagem a Faturar"

			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ Array com descricao dos campos do Cabecalho do Modelo 2      ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			aC:={}

			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ Array com descricao dos campos do Rodape do Modelo 2         ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			aR:={}

			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ Array com coordenadas da GetDados no modelo2                 ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			aCGD:={44,5,118,400}

			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ Validacoes na GetDados da Modelo 2                           ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			cLinhaOk:= "U_RRP001L()"
			cTudoOk:= "U_RRP001T()"
			
			// Ricardo Lima - 19/10/15
			aBut := {}			
			//AAdd(aBut,{ 'PEDIDO' ,{|| u_CRI021() }, 'Prog. Ra็ใos','Prog Racao' } ) 
			AAdd(aBut,{ 'PEDIDO' ,{|| U_CRI020() }, 'Prog. Ra็ใos','Prog Racao' } )  //ษverson - 09/12/2015.

			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ Chamada da Modelo2                                           ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

			lRetMod2:=Modelo2(cTitulo,aC,aR,aCGD,nOpcx,cLinhaOk,cTudoOk,,,,1,,,.T.,aBut)

			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ Grava tabela                                                 ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู


			_nTC	:=	len(aHeader)+1
			nPosSilo	:= AScan(aHeader,{|x|Alltrim(x[2]) == "ZFE_SILO"}) 
			nPosNome	:= AScan(aHeader,{|x|Alltrim(x[2]) == "ZFE_NOME"})
			nPosCodF	:= AScan(aHeader,{|x|Alltrim(x[2]) == "ZFE_COD_R"})
			nPosProd	:= AScan(aHeader,{|x|Alltrim(x[2]) == "ZFE_PRODUT"})
			nPosLoja	:= AScan(aHeader,{|x|Alltrim(x[2]) == "ZFE_LJGR_R"})
			nPosCliFor	:= AScan(aHeader,{|x|Alltrim(x[2]) == "ZFE_CLIFOR"})
			nPosCodPrg	:= AScan(aHeader,{|x|Alltrim(x[2]) == "ZFE_CODPRO"})
			
			If lRetMod2
				_nCtlin := 0
				For _I := 1 To Len(aCols)
					IF	!aCols[_I,_nTC]  // se for incluido mais campos no acols alterar o numero 7
						_nCtlin++
						_cGuia	:=	GETSXENUM("ZFE")
						dbSelectArea("ZFE")
						RecLock("ZFE",.T.)
						 ZFE->ZFE_FILIAL	:=	xFilial("ZFE")
						 ZFE->ZFE_TIPO		:=	"5"  //RACAO
						 ZFE->ZFE_MODO_T	:=	iif(empty(_cModo),"X",_cModo)
						 ZFE->ZFE_NUM		:=	_cGuia
						 ZFE->ZFE_VEICUL	:=	_cPlaca
						 ZFE->ZFE_PESO_T	:=	_nPeso
						 ZFE->ZFE_DATA_T	:=	DDATABASE
						 ZFE->ZFE_HORA_T	:=	left(time(),5)
						 ZFE->ZFE_USER_T	:=	CUSERNAME
						 ZFE->ZFE_PRODUT	:=	aCOLS[1][nPosProd]
						 ZFE->ZFE_SILO		:=	aCOLS[1][nPosSilo]
						 ZFE->ZFE_SEQENT	:=	000
						 ZFE->ZFE_VEIC_R	:=	_cPlaca
						 ZFE->ZFE_COD_R		:=	aCOLS[1][nPosCodF]
						 ZFE->ZFE_LJGR_R	:=  aCOLS[1][nPosLoja]
						 ZFE->ZFE_CLIFOR	:=	aCOLS[1][nPosCliFor]
						 ZFE->ZFE_CODPRO	:=	aCOLS[1][nPosCodPrg]
						MsUnLock()
					Endif
				NEXT _I
			Endif
			CONFIRMSX8()
			
			// IMPRIMI GUIA DE PRIMEIRA PESAGEM
			If lRetMod2
				RptStatus({|| RRPCP001D2()},"Imprimindo Ordem de Carregamento <Racao> ...")
			ENDIF	
			//FIM	
		endif
		TZZ->(dbclosearea())
	else
		msgstop("PESO OU PLACA INVALIDO!!! AV09")
		_lContinua	:=	.F.
	endif
endif
Return

user function RRP001L
	nLinGetD:=n
RETURN(.T.)       

USER FUNCTION RRP001T

Local lRet := .T.

IF EMPTY(aCOLS[1][1]) .OR. EMPTY(aCOLS[1][2]) .OR. EMPTY(aCOLS[1][5]) .OR. EMPTY(aCOLS[1][4]) .OR. EMPTY(aCOLS[1][6]) //ษverson - 05/11/2015. Valida็ใo adicionada em aCOLS[1][6].
 ALERT("Existe Campos em Branco, verifique antes de Continuar!")
 lRet := .F.
ENDIF

DbSelectArea("SB1")
DbSetOrder(1)
if DbSeek(xFilial("SB1") + aCOLS[1][1] )
  if SB1->B1_X_BLEPR = "S" .AND. EMPTY(aCOLS[1][6])
    ALERT("Produto Bloqueado para Expedi็ใo Sem Programa็ใo Cadastrada, Verifique antes de Continuar!")
    lRet := .F.
  ENDIF
endif


RETURN(lRet)                                      

USER FUNCTION BRWP001   //FAZ A VALIDACAO DE CAMPO A CAMPO DO ACOLS
	
	//ษverson - 16/11/2015.
	Local nPosSilo	:= AScan(aHeader,{|x|Alltrim(x[2]) == "ZFE_SILO"}) 
	Local nPosNome	:= AScan(aHeader,{|x|Alltrim(x[2]) == "ZFE_NOME"})
	Local nPosCodF	:= AScan(aHeader,{|x|Alltrim(x[2]) == "ZFE_COD_R"})
	Local nPosProd	:= AScan(aHeader,{|x|Alltrim(x[2]) == "ZFE_PRODUT"})
	Local cSilo		:= ''
	//
	
  nLinGetD:=n
  lEXTREG := .T.
  
  IF ALLTRIM(X3_CAMPO) = "ZFE_PRODUT" .OR. ALLTRIM(X3_CAMPO) = "B1_DESC" .OR. ALLTRIM(X3_CAMPO) = "B1_GRUPO"
  	aCOLS[n][nPosSilo] := U_ViewSB2(M->ZFE_PRODUT,xFilial("SB2"),)
  ENDIF
  
  IF EMPTY(aCOLS[n][nPosSilo]) 
     ALERT("O SILO NรO FOI SELECIONADO, INFORME UM SILO CORRETO.")
     lEXTREG := .F.
     RETURN (lEXTREG)
  ENDIF
      
  IF ALLTRIM(X3_CAMPO) = "ZFE_COD_R"
  	aCOLS[1][nPosNome] := Posicione("SA2",1,xFilial("SA2")+M->ZFE_COD_R+"01","A2_NREDUZ") //ษverson - 16/11/2015.
  	aCOLS[1][nPosCodF] := Posicione("ZFA",2,xFilial("ZFA")+M->ZFE_COD_R,"ZFA_CLIFOR") //ษverson - 16/11/2015.
  ENDIF
  
  IF ALLTRIM(X3_CAMPO) = "ZFE_SILO"
    dbSelecTArea("SB2")
    dbSetOrder(1)
    IF dbSeek(("SB2")+aCOLS[n][nPosProd]+M->ZFE_SILO) 
       IF !EMPTY(SB2->B2_LOCAL)
       ELSE
    	 ALERT("O SILO NรO EXISTE, INFORME UM SILO CORRETO.")
         lEXTREG := .F.
       ENDIF 
    ELSE
      ALERT("O SILO NรO EXISTE, INFORME UM SILO CORRETO.")
      lEXTREG := .F.
    ENDIF
  ENDIF
  
RETURN(lEXTREG)  	


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRRPCP001  บAutor  ณMicrosiga           บ Data ณ  03/16/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
STATIC FUNCTION RRPCP001D8(_cRacao,_cLocal,_cGranja,_nSeq,_dDt,_nQtd)
if empty(_cGranja) .or. empty(_cRacao)
	MSGSTOP("PROBLEMA ENCONTRADO NO PRODUTO OU NA GRANJA!!! AV4")
else
	_cGuia	:=	GETSXENUM("ZFE")
	dbSelectArea("ZFE")
	RecLock("ZFE",.T.)
	ZFE->ZFE_FILIAL		:=	xFilial("ZFE")
	ZFE->ZFE_TIPO		:=	"5"  //RACAO
	ZFE->ZFE_MODO_T		:=	iif(empty(_cModo),"X",_cModo)
	ZFE->ZFE_NUM		:=	_cGuia
	ZFE->ZFE_VEICUL		:=	_cPlaca
	ZFE->ZFE_PESO_T		:=	_nPeso
	ZFE->ZFE_DATA_T		:=	DDATABASE
	ZFE->ZFE_HORA_T		:=	left(time(),5)
	ZFE->ZFE_USER_T		:=	CUSERNAME
	ZFE->ZFE_PRODUTO	:=	_cRacao
	ZFE->ZFE_SILO		:=	_cLocal
	ZFE->ZFE_SEQENT		:=	_nSeq
	ZFE->ZFE_VEIC_R		:=	_cPlaca
	ZFE->ZFE_COD_R		:=	_cGranja
	ZFE->ZFE_LJGR_R		:=	"01"
	ZFE->ZFE_QTD_PR		:=	_nQtd
	MsUnLock()
	
	dbSelectArea("ZZ0")
	dbSetOrder(1)
	if	DbSeek(xFilial("ZZ0")+DTOS(_dDt)+STR(_nSeq,3,0)+_cGranja,.F.)
		RecLock("ZZ0",.F.)
		ZZ0->ZZ0_STATUS		:=	"2"
		ZZ0->ZZ0_GUIA		:=	_cGuia
		MsUnLock()
	else
		MSGSTOP("GRANJA NAO ENCONTRADA-AV1!!!")
	endif
	CONFIRMSX8()
endif
//GERANDO O FRETE PARA A GRANJA

RptStatus({|| RRPCP001D2()},"Imprimindo Ordem de Carregamento <Racao> ...")
_nPeso	:=	0

RETURN

Static Function RRPCP001DX()
/*dbSelectArea("ZZ0")
dbSetOrder(4)
if	DbSeek(xFilial("ZZ0")+ZFE->ZFE_NUM,.F.)
	RecLock("ZZ0",.F.)
	ZZ0->ZZ0_STATUS		:=	""
	MsUnLock()
else
	MSGSTOP("GRANJA NรO ENCONTRADA-AV2!!!")
endif*/
dbSelectArea("ZFE")
RecLock("ZFE",.F.)
dbdelete()
MsUnLock()
_nPeso	:=	0
RETURN

Static Function RRPCP001D1(cGet1,cGet2,cGet7,cGet4,cGet20,cGet21,_clifor,_cliloja,oJanela)  // racao/destino/lacre/tes/lote granjada //ษverson - 17/11/2015 - adicionada loja.

Local cEdit1	 := cGet1
Local cEdit2	 := _nPeso - ZFE->ZFE_PESO_T
Local cEdit3	 := 0
Local cEdit4	 := 0
Local oEdit1
Local oEdit2
Local oEdit3
Local oEdit4

//
Local oGroup1
Local oGroup2
Local cGroup3

Local oFontTit:= TFont():New('Courier new',,-14,.T.)
oFontTit:Bold := .T.

Public _cProd:=cGet1

//ษverson - 05/11/2015
If Empty(Alltrim(cValToChar(cGet20))) .Or. Empty(Alltrim(cValToChar(cGet7)))
	Alert("Aten็ใo! Lote/Lacre nใo informado!")
	Return	
EndIf
//
                              
//Daniel Pitthan Silveira - 22/02/2010
//+---------------------------------------+
//|Posiciona na tabela ZZ1 no produto     |
//+---------------------------------------+
//PosicionaZZ1(cGet1)

// Variaveis da Funcao de Controle e GertArea/RestArea
// Variaveis Private da Funcao
Private _oPre				// Dialog Principal
// Variaveis que definem a Acao do Formulario
Private VISUAL := .F.
Private INCLUI := .F.
Private ALTERA := .F.
Private DELETA := .F.
cEdit3	 :=  GETMV("BR_PRCERC") // U_PEGA_CM(cGet1,ZFE->ZFE_SILO,xFilial("ZFE"))
cEdit4	 := cEdit2 * cEdit3

//ษverson - 18/12/2015
If cEdit4 <= 0
	MsgAlert("Por favor, verifique as quantidades informadadas e pre็o unitแrio , pois nใo hแ valor total a ser faturado. Valor total " +;
	Transform(Val(cValToChar(cEdit4)),"@E 999,999,999.999"),"Valor Total invแlido")
EndIf
//
oJanela:Hide()
DEFINE MSDIALOG _oPre TITLE "Informa็๕es do Pedido" FROM C(178),C(181) TO C(390),C(601) PIXEL STYLE DS_MODALFRAME

// Cria Componentes Padroes do Sistema
@ C(005),C(001) GROUP oGroup2 To  C(021), C(211) Prompt "" Of _oPre Color 0, 16777215 PIXEL
@ C(007),C(006) Say "Produto: " Size C(025),C(008) COLOR CLR_RED FONT oFontTit Pixel Of _oPre
@ C(014),C(006) Say cEdit1 Size C(125),C(009) COLOR CLR_BLACK Pixel Of _oPre
@ C(007),C(059) Say "Quantidade: " Size C(038),C(008) COLOR CLR_RED FONT oFontTit Pixel Of _oPre
@ C(014),C(059) Say cEdit2 Size C(038),C(009) COLOR CLR_BLACK Picture "@E 999,999" Pixel Of _oPre
@ C(007),C(114) Say "Pre็o Unitแrio: " Size C(051),C(008) COLOR CLR_RED FONT oFontTit  Pixel Of _oPre
@ C(014),C(114) Say cEdit3 Size C(051),C(009) COLOR CLR_BLACK Picture "@E 999,999,999.9999" Pixel Of _oPre
@ C(008),C(170) Say "Valor Total: " Size C(055),C(008) COLOR CLR_RED FONT oFontTit  Pixel Of _oPre
@ C(014),C(170) Say cEdit4 Size     C(061),C(009) COLOR CLR_BLACK Picture "@E 999,999,999.9999" Pixel Of _oPre

@ C(033),C(001) GROUP oGroup1 To  C(063), C(211) Prompt "" Of _oPre Color 0, 16777215 Pixel
@ C(035),C(006) Say "Esp้cie: " Size C(035),C(008) COLOR CLR_BLUE PIXEL OF _oPre
@ C(035),C(059) MsGet oEspecie var cEspecie Valid(!Empty(cEspecie)) Size C(60),C(009) COLOR CLR_BLACK PIXEL OF _oDlg
@ C(051),C(006) Say "Mensagem para Nota: " Size C(050),C(008) COLOR CLR_BLUE PIXEL OF _oPre
@ C(050),C(059) MsGet oMenNota var cMenNota Size C(150),C(009) COLOR CLR_BLACK PIXEL OF _oDlg

//	@ C(016),C(117) MsGet oEdit3 Var cEdit3 Size C(051),C(009) COLOR CLR_BLACK Picture "@E 999,999,999.9999" PIXEL OF _oPre valid VALTTL(cEdit2,cEdit3)

@ C(089),C(153) GROUP oGroup3 To  C(103), C(211) Prompt "" Of _oPre Color 0, 16777215 Pixel
@ C(092),C(160) BMPBUTTON TYPE 01 ACTION (Close(_oPre),RRPCP1D1A(cGet1,cGet2,cGet7,cEdit3,cGet4,cGet20,cGet21,_clifor,_cliloja),oJanela:End()) //ษverson - 17/11/2015. Adicionada loja.
@ C(092),C(185) BMPBUTTON TYPE 02 ACTION (Close(_oPre),_lContinua	:=	.F.)

ACTIVATE MSDIALOG _oPre CENTERED

return

Static Function RRPCP1D1A(cGet1,cGet2,cGet7,cGet3,cGet4,cGet20,cGet21,_clifor,_cliloja) //ษverson - 17/11/2015 - adicionada loja.

Local cMensagem := ""

dbSelectArea("ZFE")
RecLock("ZFE",.F.)
ZFE->ZFE_MODO_1		:=	_cModo
ZFE->ZFE_PESO_1		:=	_nPeso
ZFE->ZFE_DATA_1		:=	DDATABASE
ZFE->ZFE_HORA_1		:=	left(time(),5)
ZFE->ZFE_USER_1		:=	CUSERNAME
ZFE->ZFE_PESO_L		:=	ZFE->ZFE_PESO_1 - ZFE->ZFE_PESO_T
ZFE->ZFE_OBS		:=	cGet7
ZFE->ZFE_PRODUTO	:= 	cGet1
ZFE->ZFE_COD_R 		:=	cGet2
ZFE->ZFE_LJGR_R		:=	_cliloja
MsUnLock()

//CONFIRMSX8()

DbSelectArea('DA3');DbSetOrder(3)
If DbSeek(xFilial('DA3')+c_cPlaca)
	cTransp:=DA3->DA3_CODFOR
Else
	cTransp:=""  
EndIf
Processa ({|| u_RRPCP002(cGet3,cGet4,_aOP,cMenNota,c_cPlaca,cTransp,cEspecie,cGet20,cGet21,_clifor,_cliloja)},"Gerando Pedido Vendas ...") //ษverson - 17/11/2015 - adicionada loja.

if CFILANT <> '03' .OR. CFILANT <> '10' .OR. CFILANT <> '04'
 //CHECAFRETE(_nPeso)
endif

RptStatus({|| RRPCP001D3(NIL,_clifor)},"Imprimindo Guia Racao <Racao> ...")

_nPeso	:=	0
_cAlias := Alias()
_cOrder := IndexOrd()
_cRecno := Recno()
_cNumNFX5:= GetAdvFVal("SX5",AllTrim("X5_DESCRI"),xFilial("SX5")+"01"+"6",1,"")  

// RICARDO LIMA - 12/07/2012 - ALTERADO PARA TRATAR CLIENTE E FORNECEDOR - CHAMADO 009483

IF _clifor = "F"

 DbSelectArea("SA2")
 DbSetOrder(1)
 DbSeek(xFilial("SA2")+ZFE->ZFE_COD_R+ZFE->ZFE_LJGR_R)
  cNome := SA2->A2_NOME
  cEnd  := SA2->A2_END
  cMun  := SA2->A2_MUN
  cEst  := SA2->A2_EST
  
ELSEIF _clifor = "C"

 DbSelectArea("SA1")
 DbSetOrder(1)
 DbSeek(xFilial("SA1")+ZFE->ZFE_COD_R+ZFE->ZFE_LJGR_R)
  cNome := SA1->A1_NOME
  cEnd  := SA1->A1_END
  cMun  := SA1->A1_MUN
  cEst  := SA1->A1_EST  

ENDIF
//


dbSelectArea(_cAlias)
dbSetOrder(_cOrder)
dbGoto(_cRecno)
RETURN

STATIC FUNCTION RRPCP001D2(_cRei)
// IMPRESSAO DE ORDEM DE CARREGAMENTO
aOrd             := {}
tamanho          := "P"
limite           := 120
nomeprog         := "RRPCP001D"
mv_tabpr         := ""
nTipo            := 18
aReturn          := { "Zebrado", 1,"Administracao", 2, 2, 1,"",1}
nLastKey         := 0
nlin             := 0
nItem            := 1
lContinua        := .T.
_cTipVei		:=	""
cString := "ZFE"
titulo  := "ORDEM DE CARREGAMENTO - RACAO"
cDesc1  := "Este programa tem como objetivo imprimir guias de pesagem"
cDesc2  := " "
cDesc3  := " Br-Aves"
nomerel := "RRPCP001D2"
cPerg:=""
nomerel := SetPrint(cString,nomerel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho)

If nLastKey == 27
	//	Close(_oDlg9)
	_nPeso	:= 0
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
	_nPeso	:= 0
	Return
Endif
/*
_________________________________________________________________________________
Br-Aves                                                  UNIDADE: ITATIBA
_________________________________________________________________________________
ORDEM DE CARREGAMENTO RACAO               REIMPRESSAO GUIA DE PESAGEM N.: 999.999
_________________________________________________________________________________
VEICULO:      XXXX9999                       			         DATA: 99/99/9999
HORA:   99:99:99
=================================================================================
PRODUTO: XXXXXXXXXXXXXXX - XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
=================================================================================
SILO: XX                						      QUANTIDADE: 999,999,999,999
=================================================================================
DADOS DA PESAGEM
PESO BRUTO  : 999.999 KGS.				99/99/9999  99:99:99  XXXXXXXXXXXXXX
TARA        : 999.999 KGS.				99/99/9999  99:99:99  XXXXXXXXXXXXXX
PESO LIQUIDO: 999.999 KGS.
=================================================================================
OBS.:
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXX
_________________________________________________________________________________
0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
1         2         3         4         5         6         7         8         9
*/

nLin	:=	0
for _i	:=	1	to 2
	@nLin,000 PSAY Replic("_",081)
	nLin++
	//@nLin,000 PSAY "Br-Aves                                                  UNIDADE: ITATIBA"
	@nLin,000 PSAY "Br-Aves"
	@nLin,050 Psay  "UNIDADE:"+ left(SM0->M0_FILIAL,22) 
	nLin++
	@nLin,000 PSAY Replic("_",081)
	nLin++
	@nLin,000 PSAY "ORDEM DE CARREGAMENTO RACAO"
	if _cRei	==	"2"
		@nLin,040 PSAY "REIMPRESSAO"
	endif
	@nLin,054 PSAY "GUIA DE PESAGEM N.:"
	@nLin,074 PSAY ZFE->ZFE_NUM
	nLin++
	@nLin,000 PSAY Replic("_",080)
	nLin++
	@nLin,000 PSAY "VEICULO: "
	@nLin,015 PSAY ZFE->ZFE_VEIC_R
	@nLin,065 PSAY "DATA:"
	@nLin,070 PSAY DDATABASE
	nLin++
	@nLin,065 PSAY "HORA: " + TIME()
	nLin++
	@nLin,000 PSAY Replic("=",080)
	nLin++
	@nLin,000 PSAY "PRODUTO:"
	@nLin,015 PSAY ALLTRIM(ZFE->ZFE_PRODUT)+" - "+Posicione("SB1",1,xFilial("SB1")+ZFE->ZFE_PRODUT,"B1_DESC")
	//@nLin,035 PSAY " - "+Posicione("SB1",1,xFilial("SB1")+ZFE->ZFE_PRODUT,"B1_DESC")
	nLin++
	@nLin,000 PSAY Replic("=",080)
	nLin++
	@nLin,000 PSAY "SILO: "
	@nLin,006 PSAY ZFE->ZFE_SILO
	@nLin,053 PSAY "QUANTIDADE: "
	@nLin,075 PSAY ZFE->ZFE_QTD_PR
	nLin++
	@nLin,000 PSAY Replic("=",080)
	nLin++
	@nLin,000 PSAY "DADOS DA PESAGEM"
	nLin++
	@nLin,000 PSAY Replic("-",080)
	nLin++
	@nLin,000 PSAY "PESO BRUTO  :"
	@nLin,014 PSAY ZFE->ZFE_PESO_1 PICTURE "@E 999,999"
	@nLin,022 PSAY "KGS." + " - " + IIF(ZFE->ZFE_MODO_1=="1","AUTO","MANUAL")
	@nLin,040 PSAY ZFE->ZFE_DATA_1
	@nLin,052 PSAY ZFE->ZFE_HORA_1
	@nLin,062 PSAY ZFE->ZFE_USER_1
	nLin++
	@nLin,000 PSAY "TARA        :"
	@nLin,014 PSAY ZFE->ZFE_PESO_T PICTURE "@E 999,999"
	@nLin,022 PSAY "KGS."+ " - " + IIF(ZFE->ZFE_MODO_T=="1","AUTO","MANUAL")
	@nLin,040 PSAY ZFE->ZFE_DATA_T
	@nLin,052 PSAY ZFE->ZFE_HORA_T
	@nLin,062 PSAY ZFE->ZFE_USER_T
	nLin++
	@nLin,000 PSAY "PESO LIQUIDO:"
	@nLin,014 PSAY ZFE->ZFE_PESO_L PICTURE "@E 999,999"
	@nLin,022 PSAY "KGS."
	nLin++
	@nLin,000 PSAY Replic("=",080)
	nLin++
	@nLin,000 PSAY "OBS.:"
	_cObs	:=	""
	nLin++
	@nLin,000 PSAY SUBSTR(_cObs,1,80)
	nLin++
	@nLin,000 PSAY SUBSTR(_cObs,81,80)
	nLin++
	@nLin,000 PSAY SUBSTR(_cObs,161,80)
	nLin++
	@nLin,000 PSAY SUBSTR(_cObs,241,10)
	nLin++
	@nLin,000 PSAY "_________________________________________________________________________________"
	if	_i	==	1
		nLin:=34
		@nLin,000 PSAY Replic("-",080)
		nLin++
	endif

next

Set Device to Screen

If aReturn[5]==1
	Set Printer to
	OurSpool(nomerel)
endif
_lContinua	:=	.F.
_nPeso	:=	0
MS_FLUSH()
RETURN

	

STATIC FUNCTION RRPCP001D4(_cRei)
// IMPRESSAO DE ORDEM DE CARREGAMENTO
aOrd             := {}
tamanho          := "P"
limite           := 120
nomeprog         := "RRPCP001D"
mv_tabpr         := ""
nTipo            := 18
aReturn          := { "Zebrado", 1,"Administracao", 2, 2, 1,"",1}
nLastKey         := 0
nlin             := 0
nItem            := 1
lContinua        := .T.
_cTipVei		:=	""
cString := "ZFE"
titulo  := "ORDEM DE CARREGAMENTO - RACAO"
cDesc1  := "Este programa tem como objetivo imprimir guias de pesagem"
cDesc2  := " "
cDesc3  := " Br-Aves"
nomerel := "RRPCP001D4"
cPerg:=""
nomerel := SetPrint(cString,nomerel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho)

If nLastKey == 27
	//	Close(_oDlg9)
	_nPeso	:= 0
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
	_nPeso	:= 0
	Return
Endif
/*
_________________________________________________________________________________
Br-Aves                                                  UNIDADE: ITATIBA
_________________________________________________________________________________
ORDEM DE CARREGAMENTO RACAO               REIMPRESSAO GUIA DE PESAGEM N.: 999.999
_________________________________________________________________________________
VEICULO:      XXXX9999                       			         DATA: 99/99/9999
HORA:   99:99:99
=================================================================================
PRODUTO: XXXXXXXXXXXXXXX - XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
=================================================================================
SILO: XX                						      QUANTIDADE: 999,999,999,999
=================================================================================
DADOS DA PESAGEM
PESO BRUTO  : 999.999 KGS.				99/99/9999  99:99:99  XXXXXXXXXXXXXX
TARA        : 999.999 KGS.				99/99/9999  99:99:99  XXXXXXXXXXXXXX
PESO LIQUIDO: 999.999 KGS.
=================================================================================
OBS.:
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXX
_________________________________________________________________________________
0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
1         2         3         4         5         6         7         8         9
*/

nLin	:=	0
for _i	:=	1	to 2

@nLin,000 PSAY Replic("_",080)
nLin++
@nLin,000 PSAY "Br-Aves                               UNIDADE: "+ left(SM0->M0_FILIAL,22)
nLin++
@nLin,000 PSAY SM0->M0_ENDENT
nLin++
@nLin,000 PSAY "CNPJ: " + SM0->M0_CGC + "                     I.E.: " + SM0->M0_INSC
nLin++
@nLin,000 PSAY SM0->M0_TEL + "                                                 www.rigor.com.br"
nLin++
@nLin,000 PSAY Replic("_",080)
nLin++
if _cRei	==	"2"
	@nLin,000 PSAY "HORA: " + TIME()
	nLin++
	@nLin,000 PSAY Replic("_",081)
	nLin++
endif
if _cRei	== "2"
	@nLin,042 PSAY "REIMPRESSAO"
endif
@nLin,054 PSAY "GUIA DE PESAGEM N.:"
@nLin,074 PSAY ZFE->ZFE_NUM
nLin++
@nLin,000 PSAY Replic("_",080)
nLin++
@nLin,000 PSAY "VEICULO: "
@nLin,015 PSAY ZFE->ZFE_VEICUL
nLin++
@nLin,000 PSAY "TRANSPORTADORA:"
@nLin,015 PSAY ZFE->ZFE_NOMTRA
nLin++
@nLin,000 PSAY "MOTORISTA:"
@nLin,015 PSAY ZFE->ZFE_MOTORI + "-" + ZFE->ZFE_NOMMOT
nLin++
@nLin,000 PSAY "CARREGAMENTO:"
@nLin,015 PSAY ALLTRIM(ZFE->ZFE_PRODUT)
@nLin,035 PSAY "OPERACAO:"
@nLin,045 PSAY ZFE->ZFE_LOTE
@nLin,060 PSAY "LITROS: " + TRANSFORM(ZFE->ZFE_LITROS,"@E 9,999.9999")
nLin++
@nLin,000 PSAY "NOTA FISCAL:"
@nLin,015 PSAY ALLTRIM(ZFE->ZFE_NF)
@nLin,035 PSAY "SERIE:"
@nLin,042 PSAY ZFE->ZFE_SERIE
nLin++
@nLin,000 PSAY Replic("=",080)
nLin++
@nLin,000 PSAY "DADOS DA PESAGEM"
nLin++
nLin++
@nLin,000 PSAY "PESO BRUTO  :"
@nLin,014 PSAY ZFE->ZFE_PESO_1 PICTURE "@E 999,999"
@nLin,022 PSAY "KGS." + " - " + IIF(ZFE->ZFE_PESO_1>0,IIF(ZFE->ZFE_MODO_1=="1","AUTO","MANUAL"),"")
@nLin,040 PSAY ZFE->ZFE_DATA_1
@nLin,052 PSAY ZFE->ZFE_HORA_1
nLin++
@nLin,000 PSAY "TARA        :"
@nLin,014 PSAY ZFE->ZFE_PESO_T PICTURE "@E 999,999"
@nLin,022 PSAY "KGS." + " - " + IIF(ZFE->ZFE_PESO_T>0,IIF(ZFE->ZFE_MODO_T=="1","AUTO","MANUAL"),"")
@nLin,040 PSAY ZFE->ZFE_DATA_T
@nLin,052 PSAY ZFE->ZFE_HORA_T
nLin++
@nLin,000 PSAY "PESO LIQUIDO:"
@nLin,014 PSAY ZFE->ZFE_PESO_L PICTURE "@E 999,999"
@nLin,022 PSAY "KGS."
nLin++
@nLin,000 PSAY Replic("=",080)
nLin++
@nLin,000 PSAY "DADOS DA OPERACAO:"  
nLin++                

@nLin,000 PSAY "OBSERVACOES:" 
@nLin,014 PSAY ZFE->ZFE_OBS
nLin++
nLin++
@nLin,000 PSAY "OPERADOR:"
@nLin,010 PSAY CUSERNAME
nLin++
nLin++
@nLin,000 PSAY "________________________________________________________________________________"
nLin++
nLin++
@nLin,000 PSAY Replic("-",080)
nLin++
nLin++

next

Set Device to Screen

If aReturn[5]==1
	Set Printer to
	OurSpool(nomerel)
endif
_lContinua	:=	.F.
_nPeso	:=	0
MS_FLUSH()
RETURN


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRRPCP001  บAutor  ณMicrosiga           บ Data ณ  03/16/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
STATIC FUNCTION RRPCP001D3(_cRei,_clifor)
// IMPRESSAO DE GUIA DE PESAGEM RACAO
aOrd:={}
tamanho          := "P"
limite           := 120
nomeprog         := "RRPCP001D"
mv_tabpr         := ""
nTipo            := 18
aReturn          := { "Zebrado", 1,"Administracao", 2, 2, 1,"",1}
nLastKey         := 0
nlin             := 0
nItem            := 1
lContinua        := .T.
_cTipVei		:=	""
cString := "ZFE"
titulo  := "GUIA DE PESAGEM - RACAO"
cDesc1  := "Este programa tem como objetivo imprimir guias de pesagem"
cDesc2  := " "
cDesc3  := " Br-Aves"
nomerel := "RRPCP001D"
cPerg:=""

nomerel := SetPrint(cString,nomerel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho)

If nLastKey == 27
	//	Close(_oDlg9)
	_nPeso	:= 0
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
	_nPeso	:= 0
	Return
Endif
/*
_________________________________________________________________________________
Br-Aves                                                  UNIDADE: ITATIBA
_________________________________________________________________________________
PESAGEM DE RACAO PARA INTEGRADOS          REIMPRESSAO GUIA DE PESAGEM N.: 999.999
_________________________________________________________________________________
VEICULO:      XXXX9999                       			         DATA: 99/99/9999
HORA:   99:99:99
=================================================================================
PRODUTO: XXXXXXXXXXXXXXX - XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
SILO: XX							                     SEQUENCIA DE ENTREGA: 99
LOCAL DE ENTREGA: XXXXXX-XX  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
=================================================================================
DADOS DA PESAGEM
PESO BRUTO  : 999.999 KGS.				99/99/9999  99:99:99  XXXXXXXXXXXXXX
TARA        : 999.999 KGS.				99/99/9999  99:99:99  XXXXXXXXXXXXXX
PESO LIQUIDO: 999.999 KGS.
=================================================================================
OBS.:
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXX
_________________________________________________________________________________
0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
1         2         3         4         5         6         7         8         9
*/

nLin	:=	0
For	_i	:=	1	to	2
	@nLin,000 PSAY Replic("_",081)
	nLin++
//	@nLin,000 PSAY "Br-Aves                                                  UNIDADE: ITATIBA
	@nLin,000 PSAY "Br-Aves"
	@nLin,050 Psay  "UNIDADE:"+ left(SM0->M0_FILIAL,22)
	nLin++
	@nLin,000 PSAY Replic("_",081)
	nLin++
	@nLin,000 PSAY "PESAGEM DE RACAO PARA MATRIZES"
	if _cRei	==	"2"
		@nLin,040 PSAY "REIMPRESSAO"
	endif
	@nLin,054 PSAY "GUIA DE PESAGEM N.:"
	@nLin,074 PSAY ZFE->ZFE_NUM
	nLin++
	@nLin,000 PSAY Replic("_",080)
	nLin++
	@nLin,000 PSAY "VEICULO: "
	@nLin,015 PSAY ZFE->ZFE_VEIC_R
	@nLin,066 PSAY "DATA:"
	@nLin,070 PSAY DDATABASE
	nLin++
	@nLin,066 PSAY "HORA: " + TIME()
	nLin++
	@nLin,000 PSAY Replic("=",080)
	nLin++
	@nLin,000 PSAY "PRODUTO:"
	@nLin,015 PSAY ALLTRIM(ZFE->ZFE_PRODUT)
	@nLin,035 PSAY " - "+Posicione("SB1",1,xFilial("SB1")+ZFE->ZFE_PRODUT,"B1_DESC")
	nLin++
	@nLin,000 PSAY "SILO: "
	@nLin,006 PSAY ZFE->ZFE_SILO
	@nLin,056 PSAY "SEQUENCIA DE ENTREGA: "
	@nLin,077 PSAY ZFE->ZFE_SEQENTE PICTURE "@E 999"
	nLin++
	@nLin,000 PSAY "LOCAL DE ENTREGA:"
	@nLin,015 PSAY ZFE->ZFE_COD_R + "-"+ZFE->ZFE_LJGR_R
	@nLin,029 PSAY IIF(_clifor="C",Posicione("SA1",1,xFilial("SA1")+ZFE->ZFE_COD_R+ZFE->ZFE_LJGR_R,"A1_NREDUZ"),Posicione("SA2",1,xFilial("SA2")+ZFE->ZFE_COD_R+ZFE->ZFE_LJGR_R,"A2_NREDUZ"))
	nLin++
	@nLin,000 PSAY "NOTA FISCAL:"
	@nLin,015 PSAY ALLTRIM(ZFE->ZFE_NF) + " - "+ALLTRIM(ZFE->ZFE_SERIE)
	nLin++
	@nLin,000 PSAY Replic("=",080)
	nLin++
	@nLin,000 PSAY "DADOS DA PESAGEM"
	nLin++
	@nLin,000 PSAY Replic("-",080)
	nLin++
	@nLin,000 PSAY "PESO BRUTO  :"
	@nLin,014 PSAY ZFE->ZFE_PESO_1 PICTURE "@E 999,999"
	@nLin,022 PSAY "KGS." + " - " + IIF(ZFE->ZFE_MODO_1=="1","AUTO","MANUAL")
	@nLin,040 PSAY ZFE->ZFE_DATA_1
	@nLin,052 PSAY ZFE->ZFE_HORA_1
	@nLin,062 PSAY ZFE->ZFE_USER_1
	nLin++
	@nLin,000 PSAY "TARA        :"
	@nLin,014 PSAY ZFE->ZFE_PESO_T PICTURE "@E 999,999"
	@nLin,022 PSAY "KGS."+ " - " + IIF(ZFE->ZFE_MODO_T=="1","AUTO","MANUAL")
	@nLin,040 PSAY ZFE->ZFE_DATA_T
	@nLin,052 PSAY ZFE->ZFE_HORA_T
	@nLin,062 PSAY ZFE->ZFE_USER_T
	nLin++
	@nLin,000 PSAY "PESO LIQUIDO:"
	@nLin,014 PSAY ZFE->ZFE_PESO_L PICTURE "@E 999,999"
	@nLin,022 PSAY "KGS."
	nLin++
	@nLin,000 PSAY Replic("=",080)
	nLin++
	@nLin,000 PSAY "OBS.:"
	_cObs	:=	ZFE->ZFE_OBS
	//_cObs	:=	"Peso Liquido Rigor: " + transform(ZFE->ZFE_PESO_L,"@E 999,999") + " - Peso Origem: " + transform(ZFE->ZFE_PESO_O,"@E 999,999")
	//_cObs	+=	"   % diferenca: " + transform(ZFE->ZFE_PESO_O/ZFE->ZFE_PESO_L,"@E 999,999") + " " + alltrim(ZFE->ZFE_OBS)
	nLin++
	@nLin,000 PSAY SUBSTR(_cObs,1,80)
	nLin++
	@nLin,000 PSAY SUBSTR(_cObs,81,80)
	nLin++
	@nLin,000 PSAY SUBSTR(_cObs,161,80)
	nLin++
	@nLin,000 PSAY SUBSTR(_cObs,241,10)
	 dbSelectArea("SD2")
	 dbSetOrder(3)
	 dbSeek(xFilial("SD2")+ZFE->ZFE_NF+ZFE->ZFE_SERIE,.T.)
	                                                       
	 dbSelectArea("SC5")
	 dbSetOrder(1)
	 IF dbSeek(xFilial("SC5")+SD2->D2_PEDIDO,.T.)
	  nLin++ 
	  @nLin,000 PSAY "Lote: " + SC5->C5_X_LTGRJ
	  nLin++ 
	  @nLin,000 PSAY "Programa็ใo de Ra็ใo: " + ZFE->ZFE_CODPRO 
	 ENDIF
	 DbSelectArea("ZFF")
	 DbSetOrder(1)
	if DbSeek(xFilial("ZFF") + Alltrim(cValToChar(ZFE->ZFE_CODPRO)))
	  nLin++ 
	  @nLin,000 PSAY "Fase da Ra็ใo: " + ZFF->ZFF_FASERA
	endif
	nLin++
	@nLin,000 PSAY "_________________________________________________________________________________"
	nLin++;nLin++;nLin++
	
next

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Finaliza a execucao do relatorio...                                 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

SET DEVICE TO SCREEN

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Se impressao em disco, chama o gerenciador de impressao...          ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

If aReturn[5]==1
   dbCommitAll()
   SET PRINTER TO
   OurSpool(nomerel)
Endif

MS_FLUSH()

_lContinua	:=	.F.
_nPeso	:=	0

Return

Static Function CANCELAD()
Close(_oPend)
_lContinua	:=	.F.
lLibera	:= .f.
return(.F.)

Static Function VALHORA(_cHora)
_lRet	:=	.T.
_nHr	:=	val(left(_cHora,2))
_nMn	:=	val(right(_cHora,2))

if _nHr > 23 .or. _nHr < 0 .or. _nMn > 59	.or. _nMn < 0
	MSGSTOP("HORA ERRADA ENTRE COM UM VALOR VALIDO!!!AV05")
	_lRet	:=	.F.
endif
return(_lRet)

Static Function VALFORNE(_cCod)
_lRet	:=	.T.
dbSelectArea("SA2")
dbSetOrder(1)
If dbSeek(xFilial("SA2")+_cCod,.F.)
	cEdit7	:=	SA2->A2_NREDUZ
else
	_lRet	:=	.F.
endif
return(_lRet)

Static Function VALIDA1(_c4)
_lRetorno	:=	.T.
dbSelectArea("DA4")
dbSetOrder(1)
If dbSeek(xFilial("DA4")+_c4,.F.)
	cEdit5	:=	DA4->DA4_NOME
else
	_lRetorno	:=	.F.
endif

Static Function VALIDA1A(_c4)
_lRetorno	:=	.T.
dbSelectArea("DA4")
dbSetOrder(1)
If dbSeek(xFilial("DA4")+_c4,.F.)
	cEditA7	:=	DA4->DA4_NOME
else
	_lRetorno	:=	.T.
endif

return(_lRetorno)

Static Function VALIDA2(_cPlaca)
_lRetorno	:=	.T.
if !empty(_cPlaca)
	dbSelectArea("DA4")
	dbSetOrder(1)
	If dbSeek(xFilial("DA4")+_cPlaca,.F.)
		cEditA5	:=	DA4->DA4_NOME
	else
		_lRetorno	:=	.F.
	endif
endif
return(_lRetorno)
/*
PESAGEM ABATIDOS
*/

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRRPCP001  บAutor  ณMicrosiga           บ Data ณ  16/03/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
STATIC FUNCTION RRPCP001E(_nPeso) &&alterado por rodrigo sanches 16/03/2001
//STATIC FUNCTION RRPCP001E

Local cGet1	 := Space(08)	//placa
Local cGet2	 := Space(06)
Local cGet3	 := Space(10)
Local cGet4	 := Space(15)
Local cGet5	 := Space(02)

//Local cGet6	 := 0 &&alterado por rodrigo sanches 16/03/2011
//Local cGet8	 := 0 &&alterado por rodrigo sanches 16/03/2011
Local cGet9	 := 0
Local cGetC	 := 0
Local oGet1
Local oGet2
Local oGet3
Local oGet4
Local oGet5
Local oGet6
Local oGet7
Local oGet8
Local oGet9

Private cGet6	 := 0   && adicionado por rodrigo sahcnes 16/03/2011
Private cGet8    := _nPeso

cGetA	:=	space(40)
cGetB	:=	space(50)
cGet7	 := 0

PEGAPLACA2()

If _nPeso	> 0 .AND.  !Empty(c_cPlaca)    

	If Select("TZZ")>0
         TZZ->(DbCloseArea())
	EndIf

	cQuery := " SELECT * FROM "+retsqlname("ZFE")+" AS ZFE "
	cQuery += " WHERE ZFE_VEICUL = '"+c_cPlaca+"' "      
	cQuery += " AND ZFE_FILIAL = '"+xFilial("ZFE")+"' AND ZFE_PESO_T = 0 " 
	cQuery += " AND D_E_L_E_T_ = '' "

	TcQuery cQuery new alias "TZZ"

	DbSelectArea("ZFE")
	DbSetOrder(8)
	DbSeek(xFilial("ZFE") + TZZ->ZFE_NUM + TZZ->ZFE_VEICUL)

	If (c_cPlaca == ZFE->ZFE_VEICUL .and. ZFE->ZFE_PESO_1 > 0 .and. ZFE->ZFE_PESO_T >0) .or. c_cPlaca <> ZFE->ZFE_VEICUL //abre uma nova guia
		Private _oInsumo
		Private VISUAL := .F.
		Private INCLUI := .F.
		Private ALTERA := .F.
		Private DELETA := .F.
		cGet1	:=	c_cPlaca

		PrimeiroPeso(c_cPlaca,nil) && adicionado por Rodrigo Sanches 16/03/2011
	ElseIf c_cPlaca == ZFE->ZFE_VEICUL .and. 	ZFE->ZFE_PESO_1 > 0 .and. ZFE->ZFE_PESO_T == 0 //segunda pesagem
		Private _oInsumo
		Private VISUAL := .F.
		Private INCLUI := .F.
		Private ALTERA := .F.
		Private DELETA := .F.

		// RICARDO LIMA - 07/11/2011 - VERIFICA SE O PESO LIQUIDO E COERENTE COM A NOTA FISCAL DE ENTRADA
		cQuery := " SELECT ZFE_SEQ, SUM(D1_QUANT) AS D1_QUANT "
		cQuery += "	FROM "+retsqlname("SD1")+" SD1, "+retsqlname("ZFE")+" ZFE "
		cQuery += " WHERE D1_DOC = ZFE_NF AND D1_SERIE = ZFE_SERIE "
		cQuery += " AND D1_FORNECE = ZFE_COD_R AND D1_FILIAL = ZFE_FILIAL "
		cQuery += " AND ZFE_SEQ = '"+ZFE->ZFE_SEQ+"' AND D1_FILIAL = '"+xFilial("SD1")+"' "
		cQuery += " AND SD1.D_E_L_E_T_ = '' AND ZFE.D_E_L_E_T_ = '' "
		cQuery += " GROUP BY ZFE_SEQ "                               

		TcQuery cQuery new alias "TOTSEQ"

		If (ZFE->ZFE_PESO_1 - _nPeso) < TOTSEQ->D1_QUANT - (TOTSEQ->D1_QUANT*0.03) .OR. (ZFE->ZFE_PESO_1 - _nPeso) > TOTSEQ->D1_QUANT + (TOTSEQ->D1_QUANT*0.03)
			If MsgYesNo("O Peso Liquido Calculado estแ Muito Diferente da Nota, Deseja Continuar?")
		Else
			TOTSEQ->(dbclosearea())
			Return()
		EndIf
	EndIf

	TOTSEQ->(dbclosearea())

	TDBTree(c_cPlaca,ZFE->ZFE_SEQ)

	EndIf 
	TZZ->(DbCloseArea())
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRRPCP001E1บAutor  ณMicrosiga           บ Data ณ  03/16/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function RRPCP001E1(_cvar2,_cvar3,_cvar4,_cvar5,_cvar6,_cvar8,cSeq,cPeso,cContrato,cPed,cItemPed,cPrcUni,cSerie,cTipo,cLojaFor,cItem,nPesOri) //ษverson - 17/11/2015 - adiciona cLojaFor e cItem.

	Local aArea	:= GetArea() //ษverson - 20/11/2015.
	_lContinua	:=	.T.

if _nPeso	> 0 .or.  !empty(c_cPlaca)
	_cGuia	:=	GETSXENUM("ZFE")
	dbSelectArea("ZFE")
	RecLock("ZFE",.T.)
		ZFE->ZFE_FILIAL		:=	xFilial("ZFE")
		ZFE->ZFE_TIPO		:=	"6"  //INSUMO RACAO
		ZFE->ZFE_MODO_1		:=	_cModo
		ZFE->ZFE_NUM		:=	_cGuia
		ZFE->ZFE_VEICUL		:=	c_cPlaca
		ZFE->ZFE_PESO_1		:=	_nPeso
		ZFE->ZFE_DATA_1		:=	DDATABASE
		ZFE->ZFE_HORA_1		:=	left(time(),5)
		ZFE->ZFE_USER_1		:=	CUSERNAME
		ZFE->ZFE_PRODUTO	:=	_cvar4
		ZFE->ZFE_SILO		:=	PADL(ALLTRIM(_cvar5),2,"0")
		ZFE->ZFE_VEIC_R		:=	c_cPlaca
		ZFE->ZFE_COD_R		:=	_cvar2
		ZFE->ZFE_LJGR_R		:=	cLojaFor
		ZFE->ZFE_NF			:=	_cvar3
		ZFE->ZFE_SERIE      := cSerie
		ZFE->ZFE_PC			:=	cPed
		ZFE->ZFE_QTD_NF		:=	_cvar6
		ZFE->ZFE_TOT_NF		:=	cPeso
		ZFE->ZFE_SEQ       	:= cSeq   
		ZFE->ZFE_CONTRA    	:= cContrato
		ZFE->ZFE_ITEMPC    	:= cItemPed
		ZFE->ZFE_PUN_NF    	:= cPrcUni
		ZFE->ZFE_PORIGE		:= nPesOri
		
		If cTipo == 1
			ZFE->ZFE_PESO_L	:= _nPeso
			ZFE->ZFE_TOT_NF	:= _nPeso
			ZFE->ZFE_PESO_T := _nPeso
			ZFE->ZFE_QBROBS	:= "Foi realizada a tranferencia usando a nota fiscal "+_cvar3+cSerie
		EndIf		
		
	MsUnLock()
	
	//ษverson - 20/11/2015
	DbSelectArea("SD1")
	SD1->(DbSetOrder(1))
	SD1->(DbGoTop())
	If SD1->(DbSeek( xFilial("SD1") + _cvar3 + cSerie + _cvar2 + cLojaFor + _cvar4 + cItem))
		RecLock("SD1" , .F.)
		Replace D1_X_SEQBL With cSeq
		Replace D1_X_ZZBAB With "S"
		MsUnlock()
	//
	EndIf
	CONFIRMSX8()
else
	msgstop("PESO OU PLACA INVALIDO!!! AV07")
	_lContinua	:=	.F.
endif

	RestArea(aArea) //ษverson - 20/11/2015.

RETURN
/*
Static Function RRPCP001E1(_cvar2,_cvar3,_cvar4,_cvar5,_cvar6,_cvar7,_cvar8,_cvar9,_cGetC)
_lContinua	:=	.T.
if _nPeso	> 0 .or.  !empty(c_cPlaca)
	_cGuia	:=	GETSXENUM("ZFE")
	dbSelectArea("ZFE")
	RecLock("ZFE",.T.)
	ZFE->ZFE_FILIAL		:=	xFilial("ZFE")
	ZFE->ZFE_TIPO		:=	"6"  //INSUMO RACAO
	ZFE->ZFE_MODO_1		:=	_cModo
	ZFE->ZFE_NUM		:=	_cGuia
	ZFE->ZFE_VEICUL		:=	c_cPlaca
	ZFE->ZFE_PESO_1		:=	_nPeso
	ZFE->ZFE_DATA_1		:=	DDATABASE
	ZFE->ZFE_HORA_1		:=	left(time(),5)
	ZFE->ZFE_USER_1		:=	CUSERNAME
	ZFE->ZFE_PRODUTO	:=	_cvar4
	ZFE->ZFE_SILO		:=	PADL(ALLTRIM(_cvar5),2,"0")
	ZFE->ZFE_VEIC_R		:=	c_cPlaca
	ZFE->ZFE_COD_R		:=	_cvar2
	ZFE->ZFE_LJGR_R		:=	"01"
	ZFE->ZFE_NF			:=	_cvar3
	ZFE->ZFE_PC			:=	_cvar2
	ZFE->ZFE_QTD_NF		:=	_cvar6
	ZFE->ZFE_PUN_NF		:=	_cvar7
	ZFE->ZFE_TOT_NF		:=	_cvar8
	ZFE->ZFE_IMP_NF		:=	_cvar9
	ZFE->ZFE_FRE_NF		:=	_cGetC
	MsUnLock()
	
	CONFIRMSX8()
	_nPeso	:=	0
else
	msgstop("PESO OU PLACA INVALIDO!!! AV07")
	_lContinua	:=	.F.
endif
RETURN
*/

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRRPCP001  บAutor  ณMicrosiga           บ Data ณ  16/03/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
STATIC FUNCTION VALSA2(_cNum)
DbSelectArea("SA2")
dbSetOrder(1)
If !dbSeek(xFilial("SA2")+_cNum,.F.)
	MSGSTOP("FORNECEDOR NAO EXISTE")
	RETURN(.F.)
else
	cGetA	:=	SA2->A2_NOME
endif
RETURN(.T.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRRPCP001  บAutor  ณMicrosiga           บ Data ณ  16/03/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
STATIC FUNCTION VALTOTAL(_nUnit,_nTotal)
cGet7	:=	_nTotal/_nUnit
RETURN(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRRPCP001  บAutor  ณMicrosiga           บ Data ณ  16/03/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
STATIC FUNCTION VALSILO(_cNum,_cCod)
if	empty(_cNum) .or. empty(_cCod)
	RETURN(.F.)
endif
_aLL	:=	{}
cQuery := "SELECT DISTINCT B2_COD, B2_LOCAL, B9_LOCAL "
cQuery += "FROM "+ retsqlname("SB2") +" AS SB2, "+ retsqlname("SB9") +" AS SB9 "
cQuery += "WHERE B2_COD = '"+_cCod+"' "
cQuery += "AND B9_COD = B2_COD "
cQuery += "AND SB2.D_E_L_E_T_ = '' "
cQuery += " AND B2_FILIAL='"+XFILIAL("SB2")+"' "
cQuery += " AND B9_FILIAL='"+XFILIAL("SB9")+"' "
cQuery += "ORDER BY B2_COD, B2_LOCAL"

TCQUERY cQuery new alias "EST"

dbSelectArea("EST")
dbGoTop()
While !eof()
	aadd(_aLL,{EST->B2_COD,EST->B2_LOCAL,EST->B9_LOCAL,.F.})
	dbSkip()
end
dbSelectArea("EST")
dbCloseArea("EST")
_nPos	:= aScan(_aLL,{|x| x[2]==_cNum})
_nPos1	:= aScan(_aLL,{|x| x[3]==_cNum})
if	_nPos	==	0	.and. _nPos1	== 0
	MSGSTOP("ALMOXARIFADO INVALIDO")
	RETURN(.F.)
endif

RETURN(.T.)                                 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRRPCP001  บAutor  ณMicrosiga           บ Data ณ  16/03/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
STATIC FUNCTION VALPC(_cNum)
DbSelectArea("SC7")
dbSetOrder(1)
If !dbSeek(xFilial("SC7")+_cNum,.F.)
	MSGSTOP("PEDIDO DE COMPRA NAO EXISTE")
	RETURN(.F.)
else
	cGetA	:=Posicione("SA2",1,xFilial("SA2")+SC7->C7_FORNECE+SC7->C7_LOJA,"A2_NOME")
endif
RETURN(.T.)  
                 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRRPCP001  บAutor  ณMicrosiga           บ Data ณ  16/03/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
STATIC FUNCTION VALZZM(_cNum)
DbSelectArea("ZFA")
dbSetOrder(1)
If !dbSeek(xFilial("ZFA")+_cNum,.F.)
	MSGSTOP("GRANJA NAO CADASTRADA")
	RETURN(.F.)
else
	cGet6	:= Posicione("SA2",1,xFilial("SA2")+_cNum,"A2_NOME")
	
endif
RETURN(.T.)
         

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRRPCP001  บAutor  ณMicrosiga           บ Data ณ  16/03/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
STATIC FUNCTION VALPROD(_cNum,_cNum1)
DbSelectArea("SB1")
dbSetOrder(1)
If !dbSeek(xFilial("SB1")+_cNum,.F.)
	MSGSTOP("PRODUTO NAO EXISTE")
	RETURN(.F.)
else
	cGet5	:=	+"-"+ ALLTRIM(SB1->B1_DESC) + " do Local: "+ ZFE->ZFE_SILO
endif
RETURN(.T.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRRPCP001  บAutor  ณMicrosiga           บ Data ณ  16/03/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
STATIC FUNCTION VALPROD1(_cProd)
DbSelectArea("SB1")
dbSetOrder(1)
If !dbSeek(xFilial("SB1")+_cProd,.F.)
	MSGSTOP("PRODUTO NAO EXISTE")
	RETURN(.F.)
else
	cGetB	:=	SB1->B1_DESC
	DbSelectArea("SC2")
	dbSetOrder(2)
	If !dbSeek(xFilial("SC2")+_cProd,.F.)
		MSGSTOP("PRODUTO SEM ORDEM DE PRODUCAO")
		RETURN(.F.)
	endif
endif

RETURN(.T.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRRPCP001  บAutor  ณMicrosiga           บ Data ณ  16/03/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
STATIC FUNCTION VALTTL(cEdit2,cEdit3)
cEdit4	:=	cEdit2	*	cEdit3
RETURN(.T.)

STATIC FUNCTION VALPROD2(_cProd,_cCli)
DbSelectArea("ZZ0")
dbSetOrder(2)
If !dbSeek(xFilial("ZZ0")+DTOS(DDATABASE)+_cProd+_cCli,.F.)
	while	!eof()	.and.	DTOS(DDATABASE)+_cProd+_cCli	==	DTOS(ZZ0->ZZ0_DATA)+ZZ0->ZZ0_RACAO+ZZ0->ZZ0_COD
		if	ZZ0->ZZ0_QT_REA == 0 .and. _cCli	== ZZ0->ZZ0_COD
			RETURN(.T.)
		endif
		DbSelectArea("ZZ0")
		dbskip()
	end
endif
MSGSTOP("PRODUTO/CLIENTE SEM PROGRAMACAO DE PRODUCAO!!!")
RETURN(.F.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRICOMA06  บAutor  ณMicrosiga           บ Data ณ  08/17/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
STATIC FUNCTION RRPCP001E2(aTicket)
Local nX        := 0
Local aCampo    := {}
Local aVetor    := {}
Local cProduto  := ""
Local nTotalNF  := 0
Local cQuant	:= 0
Local nPesoLiqT := 0
Local cTm       := ""   
Local cUM	    := ""
Local cGrupo    := ""
Local cConta    := ""
Local cLocal    := ""
Local cContra   := ""
Local nQuant    := 0
Local cAjustMP  := ""
Local nAcV := 0
Local nVarPs := 0  
Local lAjust  := .T.
Local cAjusta 

Local cPrcCom	//ษverson - 11/02/2016
Local cSerie	//ษverson - 26/02/2016

For nX := 1 to Len(aTicket)
	ZFE->(DbsetOrder(1))
	ZFE->(DbGoTop())
	ZFE->(Dbseek(xFilial("ZFE")+aTicket[nX]))

	cProduto  := ZFE->ZFE_PRODUT
	nTotalNF  += ZFE->ZFE_QTD_NF
	nPesoLiqT := ZFE->ZFE_PESO_1 - _nPeso  
	cAjustMP  := ALLTRIM(ZFE->ZFE_NF)+ALLTRIM(ZFE->ZFE_SERIE)+ALLTRIM(ZFE->ZFE_PRODUT)
	
	If Empty(cContra)
		cContra  := ZFE->ZFE_CONTRA	
		cNumGuia := ZFE->ZFE_NUM
		cPedCom  := ZFE->ZFE_PC
		cItemPed := ZFE->ZFE_ITEMPC		
	EndIf
	
Next nX

cDoc 	:= PegaDoc(aTicket)  

cSerie	:= PegaSerie(cDoc,aTicket,ZFE->ZFE_COD_R,ZFE->ZFE_LJGR_R)  	//ษverson - 26/02/2016

SB1->(dbSetOrder(1))
If SB1->(dbSeek(xFilial("SB1")+cProduto,.F.))
	cUM	   := SB1->B1_UM
	cGrupo := SB1->B1_GRUPO
	cConta := SB1->B1_CONTA      
	cLocal := SB1->B1_LOCPAD
	cAjusta:= SB1->B1_X_AJUST
else
	_lRetorno	:=	.F.
endif   

IF cAjusta = "1" // ษverson - 19/11/2015
  lAjust := .F.
ENDIF             

lMsErroAuto := .F.

IF nPesoLiqT != nTotalNF
	
	If nPesoLiqT > nTotalNF
		cQuant := 0
		cTm :=  GetMv("BR_TMDEV")
		cQuant	:=	nPesoLiqT - nTotalNF		
	Else
		cQuant := 0
		cTm :=  GetMv("BR_TMREQ")
		cQuant	:= (nPesoLiqT - nTotalNF) * -1		
	EndIf
	
	//ษverson - 11/02/2016
	cPrcCom := Val(cValToChar(ZFE->ZFE_PUN_NF))
	
	lMsErroAuto := .F. 
	
   IF lAjust //ษverson - 19/11/2015  
   		
		aAdd(aVetor,{"D3_TM"		,cTm		,NIL})
		aAdd(aVetor,{"D3_COD"		,cProduto	,NIL})
		aAdd(aVetor,{"D3_UM"		,cUM		,NIL})
		aAdd(aVetor,{"D3_QUANT"		,cQuant		,NIL})
		
		If nPesoLiqT > nTotalNF .And. cPrcCom > 0
			aAdd(aVetor,{"D3_CUSTO1",cQuant*cPrcCom	,NIL})
		EndIf
		
		aAdd(aVetor,{"D3_GRUPO"		,cGrupo		,NIL})
		aAdd(aVetor,{"D3_CONTA"		,cConta		,NIL})
		aAdd(aVetor,{"D3_LOCAL"		,cLocal		,NIL})
		aAdd(aVetor,{"D3_DOC"		,cDoc		,NIL})
		aAdd(aVetor,{"D3_EMISSAO"	,dDatabase	,NIL})
		aAdd(aVetor,{"D3_X_AJUST"   ,cAjustMP + " QUEBRA"	,NIL})  
		aAdd(aVetor,{"D3_HRINREG"   ,TIME()	    ,NIL})
			
		MsAguarde( { || MSExecAuto({|x,y| MATA240(x,y)},aVetor,3) } , "Aguarde" , "Gerando Movimento Interno referente เ quebra...." , .T. ) //Inclusao
   ENDIF
   
EndIf

If lMsErroAuto
	Alert("Erro!!! Nao foi possivel fazer o lancamento " + cProduto)
	Mostraerro()
	Return .f. 
Else
	For nX := 1 to Len(aTicket)
		ZFE->(DbSetOrder(1))
		If ZFE->(DbSeek(xFilial("ZFE")+aTicket[nX]))
			RecLock("ZFE",.F.)
				ZFE_PESO_T	:= 	_nPeso
				ZFE_DATA_T	:=	dDataBase
				ZFE_HORA_T	:=	left(time(),5)
				ZFE_USER_T	:=	cUserName
				ZFE_MODO_T	:=	iif(empty(_cModo),"X",_cModo)
				ZFE_PESO_L	:=	ZFE->ZFE_PESO_1	- ZFE->ZFE_PESO_T
				ZFE_AJUSTE  := cQuant
				ZFE_TM      := cTm

				If nQuant == 0
					nQuant := ZFE_PESO_L
				EndIf 

			ZFE->(MsUnLock())
		EndIf
	Next nX

	//RICARDO LIMA - grava uma entrada real na tabela de entregas para nota com contrato
	If !EMPTY(cContra) .AND. !EMPTY(cPedCom)
	//  GrvEntReal(cContra,cPedCom,cItemPed,cProduto,nQuant,cNumGuia,)
	EndIf
	
	//ษverson - 11/02/2016. Fun็ใo para lan็ar o desconto por umidade.
	tabClassProd(cProduto,cUM,cGrupo,cConta,cLocal,cDoc,cSerie,cAjustMP,nPesoLiqT,cPrcCom,ZFE->ZFE_COD_R,ZFE->ZFE_LJGR_R)
	
EndIf

RptStatus({|| RRPCP001E3()},"Imprimindo Guia Racao <Racao> ...")
_nPeso	:= 0

Return
/*
	ษverson - 26/02/2016
*/
Static Function PegaSerie(cDoc,aTicket,cFor,cLoja)  
	
	//Declara็ใo de variแveis.
	Local cRet		:= ""
	Local cQuery	:= ""
	Local nX		:= 0
	Local cNum		:= ""
	
	//Valida argumentos da fun็ใo.
	If Empty(cDoc)
		MsgStop("Fun็ใo que obt้m a s้rie da nota fiscal nใo recebeu o n๚mero da nota fiscal.","Fun็ใo PegaSerie")
		Return Nil
			
	EndIf

	If Empty(cFor)
		MsgStop("Fun็ใo que obt้m a s้rie da nota fiscal nใo recebeu o c๓digo do fornecedor.","Fun็ใo PegaSerie")
		Return Nil
			
	EndIf	
	
	If Empty(cLoja)
		MsgStop("Fun็ใo que obt้m a s้rie da nota fiscal nใo recebeu a loja do fornecedor.","Fun็ใo PegaSerie")
		Return Nil
			
	EndIf	
	
	If Len(aTicket) == 0
		MsgStop("Fun็ใo que obt้m a s้rie da nota fiscal nใo recebeu os n๚meros dos tickets de pesagem.","Fun็ใo PegaSerie")
		Return Nil
		
	EndIF
	
	//Cria string com os n๚meros dos tickets de pesagem.
	For nX := 1 to Len(aTicket)
	
		cNum += aTicket[nX]

		If nX <> Len(aTicket)
			cNum += ","
		EndIf	
	 
	Next nX   
	
	//Monta script sql.
	cQuery := ""
	cQuery += " SELECT  " 
	cQuery += " ZFE_SERIE " 
	cQuery += " FROM  " 
	cQuery += " " + RetSqlName("ZFE") + " AS ZFE " 
	cQuery += " WHERE " 
	cQuery += " ZFE.D_E_L_E_T_ = '' " 
	cQuery += " AND ZFE_COD_R  = '" + cFor + "' " 
	cQuery += " AND ZFE_LJGR_R = '" + cLoja + "' " 
	cQuery += " AND ZFE_NUM  IN (" + cNum + ")" 
	cQuery += " AND ZFE_NF     = '" + cDoc + "' " 
	
	//Verifica se o alias existe.
	If Select("SERIE_DOC") > 0
		SERIE_DOC->(DbCloseArea())
		
	EndIf
	
	TcQuery cQuery New Alias "SERIE_DOC"
	DbSelectArea("SERIE_DOC")
		cRet := SERIE_DOC->ZFE_SERIE
		
	DbCloseArea("SERIE_DOC")
	//Alert("Nota " + cNum + "S้rie " + cRet + " For " + cFor + " Loja " + cLoja + " Tickets " + cNum)
	
Return cRet
/*
	ษverson - 26/02/2016
*/
Static Function tabClassProd(cProduto,cUM,cGrupo,cConta,cLocal,cDoc,cSerie,cAjustMP,nPesoLiqT,cPrcCom,cForn,cLoja)
	
	//Declara็ใo de variแveis.
	Local lDesconto	:= GetMv("BR_UMIDA")
	Local cQuery	:= ""
	Local nVlQual	:= 0
	Local cMsgCpl	:= " Nใo serแ possํvel efetuar os lan็amentos de desconto."
	
	//Remove espa็os em branco.
	lDesconto 	:= Alltrim(cValToChar(lDesconto))
	cProduto 	:= Alltrim(cValToChar(cProduto))
	
	//Verifica se estแ habilitado o desconto.
	If lDesconto <> ".T."
		MsgStop("Parโmetro BR_UMIDA de desconto nใo estแ habilitado." + cMsgCpl,"Fun็ใo tabClassProd")
		Return Nil
		
	EndIf

	//Monta script sql para consultar todas as classifica็๕es de existentes para o produto.
	cQuery := ""
	cQuery += " SELECT " 
	cQuery += " DISTINCT ZF9_CPRODU, ZF9_CLASSI, ZF0_CHVDES     " 
	cQuery += " FROM      " 
	cQuery += " " + RetSqlName("ZF9") + "  AS ZF9   " 
	cQuery += " LEFT OUTER JOIN " 
	cQuery += " (SELECT ZF0_CHVCOD, ZF0_CHVDES FROM " + RetSqlName("ZF0") + " WHERE ZF0_TABCOD = '06' AND D_E_L_E_T_ = '') AS ZF0 ON " 
	cQuery += " ZF9_CLASSI = ZF0.ZF0_CHVCOD " 
	cQuery += " WHERE     " 
	cQuery += " ZF9.D_E_L_E_T_ = ''     " 
	cQuery += " AND ZF9_CPRODU = '" + cProduto + "'   " 
	cQuery += " ORDER BY ZF9_CLASSI " 

	//Verifica se o alias existe.
	If Select("TAB_CLASS") > 0
		TAB_CLASS->(DbCloseArea())
		
	EndiF

	//Executa consulta no BD.
	TcQuery cQuery New Alias "TAB_CLASS"
	
	DbSelectArea("TAB_CLASS")
	TAB_CLASS->(DbGoTop())
	
	While ! TAB_CLASS->(Eof())
		
		cTipoClass 	:= Alltrim(cValToChar(TAB_CLASS->ZF9_CLASSI))
		cTpDesc		:= Alltrim(cValToChar(TAB_CLASS->ZF0_CHVDES))
			
		//Obt้m dados da qualidade.
		nVlQual := obtDadosQuali(cForn,cLoja,cDoc,cSerie,cProduto,cTipoClass,cTpDesc)
		
		//Valida o retorno da fun็ใo obtDadosQuali.
		If nVlQual == 0
			TAB_CLASS->(DbSkip())
			Loop
		EndIf
		
		MsAguarde({||descClasProd(cProduto,cUM,cGrupo,cConta,cLocal,cDoc,nPesoLiqT,cPrcCom,cAjustMP,cTipoClass,cTpDesc,nVlQual)},"Aguarde...",;
				"Desconto: " + cTpDesc + " " + cProduto + ".",.F.)
		
		TAB_CLASS->(DbSkip())
		
	EndDo
	
	DbCloseArea("TAB_CLASS")
	
Return Nil
/*
	ษverson - 26/02/2016
*/
Static Function obtDadosQuali(cForn,cLoja,cDoc,cSerie,cProduto,cTipoClass,cTpDesc)
	
	//Declara็ใo de variแveis.
	Local nRet	:= 0
	Local cQuery:= ""
	
	//Remove espa็os em branco.
	cForn		:= Alltrim(cValToChar(cForn))
	cLoja		:= Alltrim(cValToChar(cLoja))
	cDoc		:= Alltrim(cValToChar(cDoc))
	cSerie		:= Alltrim(cValToChar(cSerie))
	cProduto	:= Alltrim(cValToChar(cProduto))
	cTipoClass	:= Alltrim(cValToChar(cTipoClass))
	cTpDesc		:= Alltrim(cValToChar(cTpDesc))
	
	//Alert(cForn + " " + cLoja + " " + cDoc + " " + cSerie + " " + cProduto + " " + cTipoClass + " " + cTpDesc)
	
	cQuery := ""
	cQuery += " SELECT " 
	cQuery += " ZFJ_VALOR " 
	
	cQuery += " FROM  " 
	cQuery += " " + RetSqlName("ZFJ") + " AS ZFJ " 
	
	cQuery += " WHERE  " 
	cQuery += " ZFJ.D_E_L_E_T_  = '' " 
	cQuery += " AND ZFJ_CPRODU = '" + cProduto + "' " 
	cQuery += " AND ZFJ_CODFOR = '" + cForn + "' " 
	cQuery += " AND ZFJ_LOJA = '" + cLoja + "' " 
	cQuery += " AND ZFJ_DOC = '" + cDoc + "' " 
	cQuery += " AND ZFJ_SERIE = '" + cSerie + "' " 
	cQuery += " AND ZFJ_CLASSI = '" + cTipoClass + "' " 
	
	If Select("DADOS_ZFJ") > 0
		DADOS_ZFJ->(DbCloseArea())
	EndIf
	
	TcQuery cQuery New Alias "DADOS_ZFJ"
	
	DbSelectArea("DADOS_ZFJ")
		nRet := Val(cValToChar(DADOS_ZFJ->ZFJ_VALOR))
	DbCloseArea("DADOS_ZFJ")
	
	//Valida o retorno da fun็ใo Posicione.
	If nRet == 0
		MsgAlert("Nใo hแ dados lan็ados de " + cTpDesc + " para o produto " + cProduto + ", ou o valor ้ 0. Assim, o valor de desconto nใo serแ lan็ado.")
		
	EndIf
	
Return nRet
/*
	ษverson - 11/02/2016
*/
Static Function descClasProd(cProduto,cUM,cGrupo,cConta,cLocal,cDoc,nPesoLiqT,cPrcCom,cAjustMP,cTipoClass,cTpDesc,cVlQual)
	
	//Declara็ใo de variแveis.
	Local cTm			:= GetMv("BR_TMREQ")
	Local cQuery		:= ""
	Local aVetor		:= {}
	Local nQtdLanc
	Local nPorcDesc		:= 0
	Local nVlDesc		:= 0
	
	Private lMsErroAuto := .F.
	
	//Remove espa็os em branco.
	cTm			:= Alltrim(cValToChar(cTm))
	cTipoClass	:= Alltrim(cValToChar(cTipoClass))
	cTpDesc		:= Alltrim(cValToChar(cTpDesc))
	cVlQual		:= Alltrim(cValToChar(cVlQual))
	
	//Valida conte๚do da Mv.
	If Empty(cTm)
		MsgStop("Nใo foi possํvel carregar o valor do parโmetro (Mv) BR_TMREQ.","Fun็ใo descClasProd")
		Return Nil
		
	EndIF
	
	//Monta Script Sql.
	cQuery := ""
	cQuery += " SELECT " 
	cQuery += " * " 
	
	cQuery += " FROM      " 
	cQuery += " " + RetSqlName("ZF9") + "  AS ZF9   " 
	cQuery += " WHERE  " 
	cQuery += " ZF9.D_E_L_E_T_ = ''   " 
	cQuery += " AND ZF9_CLASSI = '" + cTipoClass + "' " 
	cQuery += " AND ZF9_VALOR <= '" + cVlQual + "' " 
	cQuery += " AND ZF9_VALOR1 >= '" + cVlQual + "'   " 
	cQuery += " AND ZF9_CPRODU = '" + cProduto + "'   " 
	
	cQuery += " ORDER BY ZF9_CLASSI " 
	
	//Verifica se o alias jแ existe.
	If Select("VLR_TAB") > 0
		VLR_TAB->(DbCloseArea())
		
	EndIf
	
	TcQuery cQuery New Alias "VLR_TAB"
	DbSelectArea("VLR_TAB")
		nPorcDesc := Val(cValToChar(VLR_TAB->ZF9_DESCON))
		
	DbCloseArea("VLR_TAB")
	
	//Valida o percentual de desconto.
	If nPorcDesc <= 0
		MsgStop("Nใo hแ faixa/valor de desconto para o produto " + cProduto + "." + Chr(13) + Chr(10) + " Valor informado: " + cVlQual,"Fun็ใo descClasProd")
		Return Nil
		
	EndIf
	
	//Quantidade a ser lan็ada.
	nQtdLanc := Val(cValToChar(nPesoLiqT)) * (nPorcDesc/100)
	
	//Valor a ser lan็ado.
	nVlDesc := nQtdLanc * Val(cValToChar(cPrcCom))
	
	//Monta array para o MSExecauto.
	aAdd(aVetor,{"D3_TM"		,cTm		,NIL})
	aAdd(aVetor,{"D3_COD"		,cProduto	,NIL})
	aAdd(aVetor,{"D3_UM"		,cUM		,NIL})
	aAdd(aVetor,{"D3_QUANT"		,nQtdLanc	,NIL})
	aAdd(aVetor,{"D3_CUSTO1"	,nVlDesc	,NIL})
	aAdd(aVetor,{"D3_GRUPO"		,cGrupo		,NIL})
	aAdd(aVetor,{"D3_CONTA"		,cConta		,NIL})
	aAdd(aVetor,{"D3_LOCAL"		,cLocal		,NIL})
	aAdd(aVetor,{"D3_DOC"		,cDoc		,NIL})
	aAdd(aVetor,{"D3_EMISSAO"	,dDatabase	,NIL})
	aAdd(aVetor,{"D3_X_AJUST"   ,cAjustMP + " " + cTpDesc	,NIL})  
	aAdd(aVetor,{"D3_HRINREG"   ,TIME()	    ,NIL})
		
	MsAguarde( { || MSExecAuto({|x,y| MATA240(x,y)},aVetor,3) } , "Aguarde" , "Gerando Movimento Interno de desconto de " + cTpDesc + "....") 
   
	//Valida se o Execauto foi executado.
   	If lMsErroAuto
		Alert("Erro!!! Nao foi possivel fazer o lancamento " + cProduto)
		Mostraerro()
		
	EndIf
	
Return Nil
/*
STATIC FUNCTION RRPCP001E2(_cVar4,_cVar3,_cVar5,_cVar8,_cGetC)
dbSelectArea("SB1")
dbSetOrder(1)
If dbSeek(xFilial("SB1")+_cVar4,.F.)
	_cUM	:=	SB1->B1_UM
	_cGrupo	:=	SB1->B1_GRUPO
	_cConta	:=	SB1->B1_CONTA
else
	_lRetorno	:=	.F.
endif
_nPesoL	:=	ZFE->ZFE_PESO_1	- _nPeso
lMsErroAuto := .F.
aVetor:={ 		;
{"D3_TM"		,"010"	,NIL},;
{"D3_COD"		,_cVar4		,NIL},;
{"D3_UM"		,_cUM		,NIL},;
{"D3_QUANT"	,_nPesoL		,NIL},;
{"D3_GRUPO"	,_cGrupo		,NIL},;
{"D3_CUSTO1"		,_cVar8+_cGetC	,NIL},;
{"D3_CONTA"	,_cConta	,NIL},;
{"D3_LOCAL"	,_cVar5	,NIL},;
{"D3_DOC"		,_cVar3,NIL},;
{"D3_EMISSAO"	,DDATABASE		,NIL}}

MSExecAuto({|x,y| MATA240(x,y)},aVetor,3) //Inclusao
If lMsErroAuto
	Alert("Erro!!! Nao foi possivel fazer o lancamento"+_cVar4)
	Mostraerro()
	Return .f.
endif
dbSelectArea("ZFE")
RecLock("ZFE",.F.)
replace ZFE_PESO_T	with	_nPeso
replace ZFE_DATA_T	with	DDATABASE
replace ZFE_HORA_T	with	left(time(),5)
replace ZFE_USER_T	with	CUSERNAME
replace ZFE_MODO_T	with	iif(empty(_cModo),"X",_cModo)
replace ZFE_PESO_L	with	ZFE->ZFE_PESO_1	- ZFE->ZFE_PESO_T
MsUnLock()
RptStatus({|| RRPCP001E3()},"Imprimindo Guia Racao <Racao> ...")
_nPeso	:= 0
RETURN
*/


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRRPCP001  บAutor  ณMicrosiga           บ Data ณ  16/03/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
STATIC FUNCTION RRPCP001E3(_cRei)   
Local cGuia		:= "" && adicionado por Rodrigo Sanches 16/03/2011
Local cNF		:= "" && adicionado por Rodrigo Sanches 16/03/2011
Local cSerie	:= "" && adicionado por Rodrigo Sanches 16/03/2011
Local nQuantNf	:= 0  && adicionado por Rodrigo Sanches 16/03/2011

// IMPRESSAO DE ORDEM DE CARREGAMENTO
aOrd		:= {}
tamanho		:= "P"
limite		:= 120
nomeprog	:= "RRPCP001E"
mv_tabpr	:= ""
nTipo		:= 18
aReturn		:= { "Zebrado", 1,"Administracao", 2, 2, 1,"",1}
nLastKey	:= 0
nlin		:= 0
nItem		:= 1
lContinua	:= .T.
_cTipVei	:=	""
cString		:= "ZFE"
titulo		:= "ENTRADA DE PRODUTOS - INSUMOS"
cDesc1		:= "Este programa tem como objetivo imprimir guias de pesagem"
cDesc2		:= " "
cDesc3		:= "BARUFI"
nomerel		:= "RRPCP001E3"
cPerg		:= ""

nomerel := SetPrint(cString,nomerel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho)

If nLastKey == 27
	//	Close(_oDlg9)
	_nPeso	:= 0
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
	_nPeso	:= 0
	Return
Endif
/*
_________________________________________________________________________________
Br-Aves                                                  UNIDADE: ITATIBA
_________________________________________________________________________________
ENTRADA DE PRODUTOS - INSUMOS             REIMPRESSAO GUIA DE PESAGEM N.: 999.999
_________________________________________________________________________________
VEICULO:      XXXX9999                       			         DATA: 99/99/9999
HORA:   99:99:99
=================================================================================
PRODUTO: XXXXXXXXXXXXXXX - XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
                                                   QUANTIDADE NF: 999,999,999,999 //ษverson - 20/11/2015
SILO: XX                						      QUANTIDADE: 999,999,999,999
                                                       DIFERENCA: 999,999,999,999 //ษverson - 20/11/2015
=================================================================================
FORNECEDOR: XXXXXX - XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
NOTA FISCAL: XXXXXX          PEDIDO: XXXXXX
=================================================================================
DADOS DA PESAGEM
PESO BRUTO  : 999.999 KGS.				99/99/9999  99:99:99  XXXXXXXXXXXXXX
TARA        : 999.999 KGS.				99/99/9999  99:99:99  XXXXXXXXXXXXXX
PESO LIQUIDO: 999.999 KGS.
PESO ORIGEM	: 999.999 KGS.
=================================================================================
OBS.:
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXX
_________________________________________________________________________________
0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
1         2         3         4         5         6         7         8         9
*/

aGuias 		:= PegaGuias(ZFE->ZFE_NUM)   &&adicionado por Rodrigo Sanches 16/03/2011
aDadosSD1	:= PegaSD1(ZFE->ZFE_SEQ) //ษverson - 20/11/2015
If Len(aGuias) > 1
	For nX := 1 to Len(aGuias)
	
		cGuia  += aGuias[nX][1]
		cNf    += aGuias[nX][2]
		cSerie := aGuias[nX][3]
		
		If nX <> Len(aGuias)
			cNf   += ","
			cGuia += ","
		EndIf	
	Next nX                                        
Else
	cGuia  += aGuias[1][1]
	cNf    += aGuias[1][2]
	cSerie := aGuias[1][3]
EndIf								&&adicionado por Rodrigo Sanches 16/03/2011

//ษverson - 20/11/2015
If Len(aDadosSD1) > 0
	For nX := 1 To Len(aDadosSD1)
		nQuantNf += Val(cValToChar(aDadosSD1[nX][1]))
	Next nX
EndIf
//
nLin	:=	0
For _i	:=	1	to 2
	@nLin,000 PSAY Replic("_",081)
	nLin++
	//@nLin,000 PSAY "Br-Aves                                                  UNIDADE: ITATIBA"
	@nLin,000 PSAY  "GRANJA BARUFI"
	@nLin,050 Psay  "UNIDADE:"+ left(SM0->M0_FILIAL,22)	
	nLin++
	@nLin,000 PSAY Replic("_",081)
	nLin++
	@nLin,000 PSAY "ORDEM DE CARREGAMENTO RACAO"
	if _cRei	==	"2"
		@nLin,040 PSAY "REIMPRESSAO"
	endif
	@nLin,054 PSAY "GUIA DE PESAGEM N.:"
	@nLin,074 PSAY ZFE->ZFE_NUM
	nLin++
	@nLin,000 PSAY Replic("_",080)
	nLin++
	@nLin,000 PSAY "VEICULO: "
	@nLin,015 PSAY ZFE->ZFE_VEIC_R
	@nLin,065 PSAY "DATA:"
	@nLin,070 PSAY DDATABASE
	nLin++
	@nLin,065 PSAY "HORA: " + TIME()
	nLin++
	@nLin,000 PSAY Replic("=",080)
	nLin++
	@nLin,000 PSAY "PRODUTO:"
	@nLin,015 PSAY ALLTRIM(ZFE->ZFE_PRODUT)+" - "+Posicione("SB1",1,xFilial("SB1")+ZFE->ZFE_PRODUT,"B1_DESC")
	nLin++
	@nLin,000 PSAY "SILO: "
	@nLin,006 PSAY ZFE->ZFE_SILO
	@nLin,053 PSAY "QUANTIDADE: "
	@nLin,070 PSAY ZFE->ZFE_PESO_L PICTURE "@E 999,999"
	
	//ษverson - 20/11/2015.
	If  Val(cValToChar(ZFE->ZFE_PESO_L)) <> 0
		nLin++
		@nLin,050 PSAY "QUANTIDADE NF: "
		@nLin,070 PSAY nQuantNf PICTURE "@E 999,999"
		nLin++
		@nLin,054 PSAY "DIFERENCA: "
		@nLin,070 PSAY ZFE->ZFE_PESO_L - nQuantNf PICTURE "@E 999,999"
	EndIf
	//
	
	nLin++
	@nLin,000 PSAY Replic("=",080)
	nLin++
	nLin++
	@nLin,000 PSAY "FORNECEDOR:"
	@nLin,014 PSAY ALLTRIM(ZFE->ZFE_COD_R)+" - "+Posicione("SA2",1,xFilial("SA2")+ZFE->ZFE_COD_R,"A2_NOME")
	nLin++
	//@nLin,000 PSAY "NOTA FISCAL: " && alterado por Rodrigo Sanches 16/03/2011
	//@nLin,014 PSAY ZFE->ZFE_NF	 && alterado por Rodrigo Sanches 16/03/2011
	//@nLin,030 PSAY "PEDIDO: "		 && alterado por Rodrigo Sanches 16/03/2011
	//@nLin,038 PSAY ZFE->ZFE_PC     && alterado por Rodrigo Sanches 16/03/2011
	@nLin,000 PSAY "NOTA FISCAL: "+cNf+ "  PEDIDO: "+ZFE->ZFE_PC && Adicionado Por Rodrigo Sanches 16/03/2011
	nLin++
	
	@nLin,000 PSAY Replic("=",080)
	nLin++
	@nLin,000 PSAY "DADOS DA PESAGEM"
	nLin++
	@nLin,000 PSAY Replic("-",080)
	nLin++
	@nLin,000 PSAY "PESO BRUTO  :"
	@nLin,014 PSAY ZFE->ZFE_PESO_1 PICTURE "@E 999,999"
	@nLin,022 PSAY "KGS." + " - " + IIF(ZFE->ZFE_MODO_1=="1","AUTO","MANUAL")
	@nLin,040 PSAY ZFE->ZFE_DATA_1
	@nLin,052 PSAY ZFE->ZFE_HORA_1
	@nLin,062 PSAY ZFE->ZFE_USER_1
	nLin++
	@nLin,000 PSAY "TARA        :"
	@nLin,014 PSAY ZFE->ZFE_PESO_T PICTURE "@E 999,999"
	@nLin,022 PSAY "KGS."+ " - " + IIF(ZFE->ZFE_MODO_T=="1","AUTO","MANUAL")
	@nLin,040 PSAY ZFE->ZFE_DATA_T
	@nLin,052 PSAY ZFE->ZFE_HORA_T
	@nLin,062 PSAY ZFE->ZFE_USER_T
	nLin++
	@nLin,000 PSAY "PESO LIQUIDO:"
	@nLin,014 PSAY ZFE->ZFE_PESO_L PICTURE "@E 999,999"
	@nLin,022 PSAY "KGS."
	nLin++
	@nLin,000 PSAY "PESO ORIGEM :"
	@nLin,014 PSAY ZFE->ZFE_PORIGE PICTURE "@E 999,999"
	@nLin,022 PSAY "KGS."
	nLin++
	@nLin,000 PSAY Replic("=",080)
	nLin++
	@nLin,000 PSAY "OBS.:"
	_cObs	:=	""
	//_cObs	:=	"Peso Liquido Rigor: " + transform(ZFE->ZFE_PESO_L,"@E 999,999") + " - Peso Origem: " + transform(ZFE->ZFE_PESO_O,"@E 999,999")
	//_cObs	+=	"   % diferenca: " + transform(ZFE->ZFE_PESO_O/ZFE->ZFE_PESO_L,"@E 999,999") + " " + alltrim(ZFE->ZFE_OBS)
	nLin++
	@nLin,000 PSAY SUBSTR(_cObs,1,80)
	nLin++
	@nLin,000 PSAY SUBSTR(_cObs,81,80)
	nLin++
	@nLin,000 PSAY SUBSTR(_cObs,161,80)
	nLin++
	@nLin,000 PSAY SUBSTR(_cObs,241,10)
	nLin++
	@nLin,000 PSAY "_________________________________________________________________________________"
	if	_i	==	1
		nLin:=34
		@nLin,000 PSAY Replic("-",080)
		nLin++
	endif
next

Set Device to Screen

If aReturn[5]==1
	Set Printer to
	OurSpool(nomerel)
EndIf
_lContinua	:=	.F.
_nPeso	:=	0

MS_FLUSH()

Return
  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRRPCP001  บAutor  ณMicrosiga           บ Data ณ  16/03/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function LIBERAE()
Close(_oDlg)
_lContinua	:=	.T.
return(.T.)

Static Function CANCELAE()
Close(_oDlg)
_lContinua	:=	.F.
lLibera	:= .f.
return(.F.)



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRRPCP001  บAutor  ณMicrosiga           บ Data ณ  16/03/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
STATIC FUNCTION PEGAPLACA2()
c_cPlaca	:=	SPACE(08)
if _nPeso	> 0
	DEFINE FONT oFnt  NAME "Arial" SIZE 15,50 BOLD
	DEFINE FONT oFnt1 NAME "Arial" SIZE 07,30 BOLD
	DEFINE MSDIALOG _oDlg TITLE "Pesagem de veiculo" FROM C(342),C(360) TO C(492),C(560) PIXEL
	
	// Cria Componentes Padroes do Sistema
	@ C(001),C(004) Say "Placa do veiculo" 	Size C(100),C(100) COLOR CLR_BLACK PIXEL OF _oDlg FONT oFnt1
	@ C(015),C(003) MsGet o_cPlaca Var c_cPlaca Size C(097),C(023) COLOR CLR_BLACK PIXEL OF _oDlg FONT oFnt PICTURE "@!"   F3 "XA3" //VALID VALPL(c_cPlaca)
	@ C(060),C(050) BMPBUTTON TYPE 01 ACTION Close(_oDlg)
	@ C(060),C(080) BMPBUTTON TYPE 02 ACTION (Close(_oDlg),c_cPlaca	:=	SPACE(10),_lContinua	:=	.F.)
	
	ACTIVATE MSDIALOG _oDlg CENTERED
	
Else
	MsgStop("PESO NAO PODE SER ZERO!!! AV08")
	_lContinua	:=	.F.
EndIf

Return(c_cPlaca)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRRPCP001  บAutor  ณMicrosiga           บ Data ณ  16/03/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PEGAPLACA3(nOpc)

	//Declara็ใo de variแveis.
	Local oGroup1
	Local oGroup2
	
	c_cPlaca	:=	Space(08)
	If _nPeso	> 0
		DEFINE FONT oFnt  NAME "Arial" SIZE 15,50 BOLD
		DEFINE FONT oFnt1 NAME "Arial" SIZE 08,30 BOLD
		DEFINE MSDIALOG _oDlg TITLE "" From C(342),C(360) TO C(492),C(560) Pixel
		
		// Cria Componentes Padroes do Sistema
		@ C(001),C(001) GROUP oGroup2 To  C(015), C(100) Prompt "" Of _oDlg Color 0, 16777215 Pixel
		@ C(001),C(027) Say "Pesagem de veiculo" 	Size C(060),C(100) COLOR CLR_RED Pixel Of _oDlg FONT oFnt1
		@ C(020),C(035) Say "Placa do Veํculo" 	Size C(060),C(100) COLOR CLR_RED Pixel Of _oDlg
		@ C(025),C(003) MsGet o_cPlaca Var c_cPlaca Size C(097),C(023) COLOR CLR_BLACK Pixel Of _oDlg FONT oFnt PICTURE "@!"   F3 Iif(nOpc = 1,"ZFEDA3","DA3") VALID VALVEIC(c_cPlaca,1)
		
		@ C(057),C(045) GROUP oGroup1 To  C(070), C(100) Prompt "" Of _oDlg Color 0, 16777215 Pixel
		@ C(060),C(050) BMPBUTTON TYPE 01 ACTION (Close(_oDlg),_lContinua	:=	.T.)
		@ C(060),C(075) BMPBUTTON TYPE 02 ACTION (Close(_oDlg),c_cPlaca	:=	Space(10),_lContinua	:=	.F.)
		
		Activate MSDIALOG _oDlg Centered
		
	Else
		MSGSTOP("PESO NAO PODE SER ZERO!!! AV08")
		_lContinua	:=	.F.
	EndIf

Return(c_cPlaca)

/*
PESAGEM DIVERSOS
*/


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRRPCP001  บAutor  ณMicrosiga           บ Data ณ  16/03/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
STATIC FUNCTION RRPCP001F
// IMPRESSAO DE GUIA DE PESAGEM DIVERSOS
aOrd             := {}
tamanho          := "G"
limite           := 120
nomeprog         := "RRPCP001F"
mv_tabpr         := ""
nTipo            := 18
aReturn          := { "Zebrado", 1,"Administracao", 2, 2, 1,"",1}
nLastKey         := 0
nlin             := 0
nItem            := 1
_lContinua        := .T.
cString := "ZZK"
titulo  := "GUIA DE PESAGEM - DIVERSOS"
cDesc1  := "Este programa tem como objetivo imprimir guias de pesagem"
cDesc2  := " "
cDesc3  := " Br-Aves"
nomerel := "RRPCP001F"

_cGuia	:=	space(6)
cComboBx1	:=	""
cEditA1	 := space(8)
cEditA2	 := Space(30)
cEditA3	 := Space(6)
cEditA4	 := Space(6)
cEditA5	 := Space(30)
cEditA6	 := Space(3)
cEditA7	 := Space(30)
cEditA8	 := Space(30)
cEditA9	 := Space(200)
cEditA10	:=	Space(15)
c_cPlaca	:=	 space(8)

// Variaveis Private da Funcao
Private _oDlg				// Dialog Principal
// Variaveis que definem a Acao do Formulario
Private VISUAL := .F.
Private INCLUI := .F.
Private ALTERA := .F.
Private DELETA := .F.


_cTpTela	:=	"1"
aComboBx1	 := {"  "}

dbSelectArea("SX5")
dbSetOrder(1)
dbSeek(xFilial()+"ZN")
while !eof() .and. SX5->X5_TABELA == "ZN"
	aadd(aComboBx1,SX5->X5_DESCRI)
	dbskip()
enddo

//aComboBx1	 := {"  ","DIVERSOS","DEVOLUCAO","DIESEL","PATIO"}

PEGAPLACA1()
if _nPeso == 0
	MSGSTOP("PESO NAO PODE SER ZERO!!! AV08")
	return
endif
if _lContinua
	if 	_cTpTela	== "1"
		cEditA1:=c_cPlaca
		//	DEFINE MSDIALOG _oDlg TITLE "Pesagem diversos" FROM C(200),C(276) TO C(396),C(756) PIXEL
		DEFINE MSDIALOG _oDlg TITLE _cTela FROM C(302),C(378) TO C(498),C(858) PIXEL
		@ C(008),C(008) Say "Placa do veiculo" Size C(041),C(008) COLOR CLR_BLACK PIXEL OF _oDlg
		@ C(020),C(008) Say "Empresa" Size C(022),C(008) COLOR CLR_BLACK PIXEL OF _oDlg
		@ C(032),C(008) Say "Motorista" Size C(023),C(008) COLOR CLR_BLACK PIXEL OF _oDlg
		@ C(044),C(008) Say "Carregamento" Size C(035),C(008) COLOR CLR_BLACK PIXEL OF _oDlg
		@ C(058),C(008) Say "Nota fiscal" Size C(027),C(008) COLOR CLR_BLACK PIXEL OF _oDlg
		@ C(058),C(116) Say "Serie" Size C(015),C(008) COLOR CLR_BLACK PIXEL OF _oDlg
		@ C(072),C(008) Say "Observacao:" Size C(032),C(008) COLOR CLR_BLACK PIXEL OF _oDlg
		@ C(007),C(051) Say cEditA1 Size C(060),C(009) COLOR CLR_BLACK PIXEL OF _oDlg
		//	@ C(031),C(088) Say cEditA7 Size C(147),C(009) COLOR CLR_BLACK PIXEL OF _oDlg
		@ C(019),C(051) MsGet oEdit2 Var cEditA2 Size C(183),C(009) COLOR CLR_BLACK PIXEL OF _oDlg	PICTURE "@!"
		@ C(031),C(051) MsGet oEdit3 Var cEditA3 Size C(032),C(009) COLOR CLR_BLACK PIXEL OF _oDlg	PICTURE "@!" F3 "DA4"  VALID valida1A(cEditA3)
		@ C(031),C(088) MsGet oEdit7 Var cEditA7 Size C(147),C(009) COLOR CLR_BLACK PIXEL OF _oDlg	PICTURE "@!"
		@ C(057),C(157) ComboBox cComboBx1 Items aComboBx1 Size C(061),C(010) PIXEL OF _oDlg
		@ C(043),C(051) MsGet oEdit4 Var cEditA4 Size C(032),C(009) COLOR CLR_BLACK PIXEL OF _oDlg	PICTURE "@!" F3 "DAK"
		//	@ C(043),C(088) MsGet oEdit8 Var cEditA8 Size C(147),C(009) COLOR CLR_BLACK PIXEL OF _oDlg	PICTURE "@!"
		@ C(057),C(051) MsGet oEdit5 Var cEditA5 Size C(042),C(009) COLOR CLR_BLACK PIXEL OF _oDlg PICTURE "@!"
		@ C(057),C(124) MsGet oEdit6 Var cEditA6 Size C(028),C(009) COLOR CLR_BLACK PIXEL OF _oDlg	PICTURE "@!"
		@ C(081),C(009) MsGet oEdit9 Var cEditA9 Size C(093),C(009) COLOR CLR_BLACK PIXEL OF _oDlg
		@ C(086),C(145) BMPBUTTON TYPE 01 ACTION (RRPCP001F2(cComboBx1),Close(_oDlg))
		@ C(086),C(199) BMPBUTTON TYPE 02 ACTION FECHA2()
	else
		cEditA1:=c_cPlaca
		//	DEFINE MSDIALOG _oDlg TITLE "Pesagem diversos" FROM C(200),C(276) TO C(396),C(756) PIXEL
		DEFINE MSDIALOG _oDlg TITLE _cTela FROM C(302),C(378) TO C(498),C(858) PIXEL
		@ C(008),C(008) Say "Placa do veiculo" Size C(041),C(008) COLOR CLR_BLACK PIXEL OF _oDlg
		@ C(020),C(008) Say "Empresa" Size C(022),C(008) COLOR CLR_BLACK PIXEL OF _oDlg
		@ C(032),C(008) Say "Motorista" Size C(023),C(008) COLOR CLR_BLACK PIXEL OF _oDlg
		@ C(044),C(008) Say "Carregamento" Size C(035),C(008) COLOR CLR_BLACK PIXEL OF _oDlg
		@ C(058),C(008) Say "Nota fiscal" Size C(027),C(008) COLOR CLR_BLACK PIXEL OF _oDlg
		@ C(058),C(106) Say "Serie" Size C(015),C(008) COLOR CLR_BLACK PIXEL OF _oDlg
		@ C(072),C(008) Say "Observacao:" Size C(032),C(008) COLOR CLR_BLACK PIXEL OF _oDlg
		@ C(007),C(051) Say cEditA1 Size C(060),C(009) COLOR CLR_BLACK PIXEL OF _oDlg
		//	@ C(031),C(088) Say cEditA7 Size C(147),C(009) COLOR CLR_BLACK PIXEL OF _oDlg
		@ C(019),C(051) Say  cEditA2 Size C(183),C(009) COLOR CLR_BLACK PIXEL OF _oDlg	PICTURE "@!"
		@ C(031),C(051) Say  cEditA3 Size C(032),C(009) COLOR CLR_BLACK PIXEL OF _oDlg	PICTURE "@!"
		@ C(031),C(088) Say  cEditA7 Size C(147),C(009) COLOR CLR_BLACK PIXEL OF _oDlg	PICTURE "@!"
		@ C(043),C(051) Say  cEditA4 Size C(032),C(009) COLOR CLR_BLACK PIXEL OF _oDlg	PICTURE "@!"
		//	@ C(043),C(088) MsGet oEdit8 Var cEditA8 Size C(147),C(009) COLOR CLR_BLACK PIXEL OF _oDlg	PICTURE "@!"
		@ C(057),C(051) Say  cEditA5 Size C(042),C(009) COLOR CLR_BLACK PIXEL OF _oDlg PICTURE "@!"
		@ C(057),C(124) Say  cEditA6 Size C(028),C(009) COLOR CLR_BLACK PIXEL OF _oDlg	PICTURE "@!"
		@ C(081),C(009) MsGet  oEdit9 Var cEditA9 Size C(093),C(009) COLOR CLR_BLACK PIXEL OF _oDlg
		//		@ C(057),C(157) ComboBox cComboBx1 Items aComboBx1 Size C(061),C(010) PIXEL OF _oDlg
		@ C(057),C(145) Say  cEditA10 Size C(028),C(009) COLOR CLR_BLACK PIXEL OF _oDlg	PICTURE "@!"
		@ C(086),C(145) BMPBUTTON TYPE 01 ACTION (RRPCP001F2(cEditA10),Close(_oDlg))
		@ C(086),C(199) BMPBUTTON TYPE 02 ACTION FECHA2()
	endif
	
	ACTIVATE MSDIALOG _oDlg CENTERED
endif
_cModo	:=	"1"
Return(.T.)

Static Function RRPCP001F1()
Close(_oDlg)
_lContinua	:=	.T.
if _nPeso	> 0 .or.  !empty(c_cPlaca)
	dbSelectArea("ZFE")
	dbSetOrder(2)
	dbSeek(xFilial("ZFE")+c_cPlaca+"ZZZZZZZ",.T.)
	dbSkip(-1)
	if	c_cPlaca == ZFE->ZFE_VEICUL .and. 	(ZFE->ZFE_PESO_1	== 0 .or. 	ZFE->ZFE_PESO_T	== 0)
		if ZFE->ZFE_TIPO	<> "3"
			if 	 ZFE->ZFE_TIPO == "1"
				MSGSTOP("VEICULO COM PESAGEM DE FRANGO VIVO EM ABERTO!!!")
			elseif	ZFE->ZFE_TIPO == "2"
				MSGSTOP("VEICULO COM PESAGEM DE ABATIDO EM ABERTO!!!")
			else
				MSGSTOP("VEICULO COM OUTRA PESAGEM  EM ABERTO!!!")
			endif
			_lContinua	:=	.F.
			return
		endif
		cEditA2	:=	ZFE->ZFE_NOMTRA
		cEditA3	:=	ZFE->ZFE_MOTORI
		cEditA7	:=	ZFE->ZFE_NOMMOT
		cEditA4	:=	ZFE->ZFE_PRODUT
		cEditA5	:=	ZFE->ZFE_NF
		cEditA6	:=	ZFE->ZFE_SERIE
		_cGuia	:=	ZFE->ZFE_NUM
		cEditA9	:=	ZFE->ZFE_OBS
		cEditA10	:=	ZFE->ZFE_LOTE
		_cTela	:=	"Pesagem diversos - 2 pesagem"
		_cTpTela	:= "2"
	else
		dbSelectArea("DA3")
		dbSetOrder(1)
		If dbSeek(xFilial("DA3")+c_cPlaca,.F.)
			_cTransp	:=	DA3->DA3_TRANSP
			_cMotori	:=	DA3->DA3_MOTORI
			dbSelectArea("SA4")
			dbSetOrder(1)
			If dbSeek(xFilial("SA4")+_cTransp,.F.)
				cEditA2	:=	SA4->A4_NOME
			endif
			dbSelectArea("DA4")
			dbSetOrder(1)
			If dbSeek(xFilial("DA4")+_cMotori,.F.)
				cEditA3	:=	DA4->DA4_COD
				cEditA7	:=	DA4->DA4_NOME
			endif
		endif
		_cTela		:=	"Pesagem diversos - 1 pesagem"
		_cTpTela	:= "1"
	endif
else
	msgstop("PESO OU PLACA INVALIDO!!! AV09")
	_lContinua	:=	.F.
endif

return

STATIC FUNCTION RRPCP001F2(_cOpc)
if empty(_cOpc)
	MSGSTOP("ESCOLHA UM TIPO DE PESAGEM")
	return
endif
if empty(_cGuia)
	_cGuia	:=	GETSXENUM("ZFE")
	RecLock("ZFE",.T.)
	replace	ZFE_FILIAL	with	xFilial("ZFE")
	replace ZFE_VEICUL	with	c_cPlaca
	replace ZFE_NUM		with	_cGuia
	replace ZFE_TIPO	with	"3"
	replace ZFE_MODO_1	with	_cModo
	replace ZFE_NOMMOT	with	cEditA7
	replace ZFE_MOTORI	with	cEditA3
	replace ZFE_NOMTRA	with	cEditA2
	replace ZFE_PRODUT	with	cEditA4
	replace ZFE_NF		with	cEditA5
	replace ZFE_SERIE	with	cEditA6
	replace ZFE_PESO_1	with	_nPeso
	replace ZFE_DATA_1	with	DDATABASE
	replace ZFE_HORA_1	with	left(time(),5)
	replace ZFE_USER_1	with	CUSERNAME
	replace ZFE_LOTE	with 	_cOpc
	replace ZFE_OBS		with 	cEditA9
	MsUnLock()
	CONFIRMSX8()
else
	RecLock("ZFE",.F.)
	replace ZFE_MOTORI	with	cEditA3
	replace ZFE_NOMMOT	with	cEditA7
	replace ZFE_NOMTRA	with	cEditA2
	replace ZFE_PRODUT	with	cEditA4
	replace ZFE_NF		with	cEditA5
	replace ZFE_SERIE	with	cEditA6
	replace ZFE_OBS		with 	cEditA9
	if _nPeso	> 	ZFE->ZFE_PESO_1
		replace ZFE_PESO_T	with	ZFE->ZFE_PESO_1
		replace ZFE_DATA_T	with	ZFE->ZFE_DATA_1
		replace ZFE_HORA_T	with	ZFE->ZFE_HORA_1
		replace ZFE_USER_T	with	ZFE->ZFE_USER_1
		replace ZFE_MODO_T	with	iif(empty(ZFE->ZFE_MODO_1),"X",ZFE->ZFE_MODO_1)
		replace ZFE_PESO_1	with	_nPeso
		replace ZFE_DATA_1	with	DDATABASE
		replace ZFE_HORA_1	with	left(time(),5)
		replace ZFE_USER_1	with	CUSERNAME
		replace ZFE_PESO_L	with	ZFE->ZFE_PESO_1	- ZFE->ZFE_PESO_T
	else
		replace ZFE_PESO_T	with	_nPeso
		replace ZFE_DATA_T	with	DDATABASE
		replace ZFE_HORA_T	with	left(time(),5)
		replace ZFE_USER_T	with	CUSERNAME
		replace ZFE_MODO_T	with	_cModo
		replace ZFE_PESO_L	with	ZFE_PESO_1	- ZFE_PESO_T
	endif
	MsUnLock()
	RRPCP001F3("1")
endif
_nPeso :=	0
_cModo	:=	"1"
RETURN

STATIC FUNCTION RRPCP001F3(_cRei)

if 	(c_cPlaca <> ZFE->ZFE_VEICUL .OR. (ZFE->ZFE_PESO_1 == 0 .AND. ZFE->ZFE_PESO_T == 0) .or. empty(_cGuia)) .and. _cRei == "1"
	msgstop("FALTANDO PESAGEM-CONFIRME ANTES DE IMPRIMIR-ME30")
	return
endif

cPerg:=""
nomerel := SetPrint(cString,nomerel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho)

If nLastKey == 27
	Close(_oDlg)
	_nPeso	:= 0
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
	Close(_oDlg)
	_nPeso	:= 0
	Return
Endif
/*
_________________________________________________________________________________

_________________________________________________________________________________
GUIA DE PESAGEM N.: 999.999
_________________________________________________________________________________
VEICULO:      XXXX9999   - XXXXXXXXXXXXXXXXX
EMPRESA:      XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
MOTORISTA:	  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
CARREGAMENTO: XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
NOTA FISCAL:  XXXXXX     SERIE: XXX
=================================================================================
DADOS DA PESAGEM

PESO BRUTO  : 999.999 KGS.				99/99/9999  99:99:99
TARA        : 999.999 KGS.				99/99/9999  99:99:99
PESO LIQUIDO: 999.999 KGS.
=================================================================================
DADOS DA OPERACAO:

OPERADOR: XXXXXXXXXXXXXXX


_________________________________________________________________________________
0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
1         2         3         4         5         6         7         8         9
*/

nLin	:=	0
@nLin,000 PSAY Replic("_",080)
nLin++
@nLin,000 PSAY "Br-Aves                               UNIDADE: "+ left(SM0->M0_FILIAL,22)
nLin++
@nLin,000 PSAY SM0->M0_ENDENT
nLin++
@nLin,000 PSAY "CNPJ: " + SM0->M0_CGC + "                     I.E.: " + SM0->M0_INSC
nLin++
@nLin,000 PSAY SM0->M0_TEL + "                                                 www.rigor.com.br"
nLin++
@nLin,000 PSAY Replic("_",080)
nLin++
if _cRei	==	"2"
	@nLin,000 PSAY "HORA: " + TIME()
	nLin++
	@nLin,000 PSAY Replic("_",081)
	nLin++
endif
if _cRei	== "2"
	@nLin,042 PSAY "REIMPRESSAO"
endif
@nLin,054 PSAY "GUIA DE PESAGEM N.:"
@nLin,074 PSAY ZFE->ZFE_NUM
nLin++
@nLin,000 PSAY Replic("_",080)
nLin++
@nLin,000 PSAY "VEICULO: "
@nLin,015 PSAY ZFE->ZFE_VEICUL
nLin++
@nLin,000 PSAY "TRANSPORTADORA:"
@nLin,015 PSAY ZFE->ZFE_NOMTRA
nLin++
@nLin,000 PSAY "MOTORISTA:"
@nLin,015 PSAY ZFE->ZFE_MOTORI + "-" + ZFE->ZFE_NOMMOT
nLin++
@nLin,000 PSAY "CARREGAMENTO:"
@nLin,015 PSAY ALLTRIM(ZFE->ZFE_PRODUT)
@nLin,035 PSAY "OPERACAO:"
@nLin,045 PSAY ZFE->ZFE_LOTE
@nLin,060 PSAY "LITROS: " + TRANSFORM(ZFE->ZFE_LITROS,"@E 9,999.9999")
nLin++
@nLin,000 PSAY "NOTA FISCAL:"
@nLin,015 PSAY ALLTRIM(ZFE->ZFE_NF)
@nLin,035 PSAY "SERIE:"
@nLin,042 PSAY ZFE->ZFE_SERIE
nLin++
@nLin,000 PSAY Replic("=",080)
nLin++
@nLin,000 PSAY "DADOS DA PESAGEM"
nLin++
nLin++
@nLin,000 PSAY "PESO BRUTO  :"
@nLin,014 PSAY ZFE->ZFE_PESO_1 PICTURE "@E 999,999"
@nLin,022 PSAY "KGS." + " - " + IIF(ZFE->ZFE_PESO_1>0,IIF(ZFE->ZFE_MODO_1=="1","AUTO","MANUAL"),"")
@nLin,040 PSAY ZFE->ZFE_DATA_1
@nLin,052 PSAY ZFE->ZFE_HORA_1
nLin++
@nLin,000 PSAY "TARA        :"
@nLin,014 PSAY ZFE->ZFE_PESO_T PICTURE "@E 999,999"
@nLin,022 PSAY "KGS." + " - " + IIF(ZFE->ZFE_PESO_T>0,IIF(ZFE->ZFE_MODO_T=="1","AUTO","MANUAL"),"")
@nLin,040 PSAY ZFE->ZFE_DATA_T
@nLin,052 PSAY ZFE->ZFE_HORA_T
nLin++
@nLin,000 PSAY "PESO LIQUIDO:"
@nLin,014 PSAY ZFE->ZFE_PESO_L PICTURE "@E 999,999"
@nLin,022 PSAY "KGS."
nLin++
@nLin,000 PSAY Replic("=",080)
nLin++
@nLin,000 PSAY "DADOS DA OPERACAO:"
nLin++
@nLin,000 PSAY "OBSERVACOES:"
@nLin,014 PSAY ZFE->ZFE_OBS
nLin++
nLin++
@nLin,000 PSAY "OPERADOR:"
@nLin,010 PSAY CUSERNAME
nLin++
nLin++
@nLin,000 PSAY "________________________________________________________________________________"
nLin++
Set Device to Screen

If aReturn[5]==1
	Set Printer to
	OurSpool(nomerel)
endif
//Close(_oDlg)
_nPeso	:= 0
MS_FLUSH()
RETURN


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRRPCP001  บAutor  ณMicrosiga           บ Data ณ  16/03/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function RRPCP001F4()
Close(_oDlg)
_cGuia	:=	space(6)
_lContinua	:=	.T.
if _nPeso	> 0 .or.  !empty(c_cPlaca)
	dbSelectArea("DA3")
	dbSetOrder(1)
	If dbSeek(xFilial("DA3")+c_cPlaca,.F.)
		_cTransp	:=	DA3->DA3_TRANSP
		_cMotori	:=	DA3->DA3_MOTORI
		dbSelectArea("SA4")
		dbSetOrder(1)
		If dbSeek(xFilial("SA4")+_cTransp,.F.)
			cEditA2	:=	SA4->A4_NOME
		endif
		dbSelectArea("DA4")
		dbSetOrder(1)
		If dbSeek(xFilial("DA4")+_cMotori,.F.)
			cEditA3	:=	DA4->DA4_COD
			cEditA7	:=	DA4->DA4_NOME
		endif
	endif
else
	msgstop("PESO OU PLACA INVALIDO!!! AV10")
	_lContinua	:=	.F.
endif

return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRRPCP001  บAutor  ณMicrosiga           บ Data ณ  16/03/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
STATIC FUNCTION PEGAPLACA1()

DEFINE FONT oFnt  NAME "Arial" SIZE 15,50 BOLD
DEFINE FONT oFnt1 NAME "Arial" SIZE 5,30 BOLD
DEFINE MSDIALOG _oDlg TITLE "Pesagem de veiculo" FROM C(342),C(360) TO C(492),C(560) PIXEL

// Cria Componentes Padroes do Sistema
@ C(001),C(004) Say "Placa do veiculo" 	Size C(060),C(100) COLOR CLR_BLACK PIXEL OF _oDlg FONT oFnt1
@ C(015),C(003) MsGet o_cPlaca Var c_cPlaca Size C(097),C(023) COLOR CLR_BLACK PIXEL OF _oDlg FONT oFnt PICTURE "@!" F3 "DA3" //VALID VALPL(c_cPlaca)


//@ C(060),C(030) BMPBUTTON TYPE 04 ACTION RRPCP001F4()
@ C(060),C(050) BMPBUTTON TYPE 01 ACTION RRPCP001F1()
@ C(060),C(080) BMPBUTTON TYPE 02 ACTION (Close(_oDlg),_lContinua	:=	.F.)
/*
BMPBUTTON TYPE 01	OK
BMPBUTTON TYPE 02	CANCELA
BMPBUTTON TYPE 03   EXCLUIR
BMPBUTTON TYPE 04	INCLUIR
BMPBUTTON TYPE 05	PARAMETROS
BMPBUTTON TYPE 06	IMPRIMIR
BMPBUTTON TYPE 07	SUSPENDER A IMPRESSAO
BMPBUTTON TYPE 08	CANCELAR IMPRESSAO
BMPBUTTON TYPE 09	ORDEM
BMPBUTTON TYPE 10	PRIORIDADE
BMPBUTTON TYPE 11	EDITAR
BMPBUTTON TYPE 12	OUVIR
BMPBUTTON TYPE 13	SALVAR
BMPBUTTON TYPE 14	ABRIR
BMPBUTTON TYPE 15	VISUALIZAR
BMPBUTTON TYPE 16	CONDICAO NEGOCIADA
BMPBUTTON TYPE 17	FILTRO
BMPBUTTON TYPE 18	FINANCIAMENTO
BMPBUTTON TYPE 19	AVANCAR
BMPBUTTON TYPE 20	VOLTAR
BMPBUTTON TYPE 21	AVANCAR TUDO
BMPBUTTON TYPE 22	VOLTAR TUDO
BMPBUTTON TYPE 23	GRAFICO
*/

ACTIVATE MSDIALOG _oDlg CENTERED

RETURN

STATIC FUNCTION FECHA2()
Close(_oDlg)
_lContinua	:=	.F.
_nPeso	:= 0
return

STATIC FUNCTION FECHA3()
Close(_oDlg3)
_lContinua	:=	.F.
_nPeso	:= 0
return


/*
ROTINAS PARA PESAGEM PAGO
*/

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRRPCP001  บAutor  ณMicrosiga           บ Data ณ  16/03/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
STATIC FUNCTION RRPCP001G
// IMPRESSAO DE GUIA DE PESAGEM DIVERSOS
aOrd             := {}
tamanho          := "G"
limite           := 120
nomeprog         := "RRPCP001G"
mv_tabpr         := ""
nTipo            := 18
aReturn          := { "Zebrado", 1,"Administracao", 2, 2, 1,"",1}
nLastKey         := 0
nlin             := 0
nItem            := 1
lContinua        := .T.
cString := "ZZK"
titulo  := "GUIA DE PESAGEM-PAGO"
cDesc1  := "Este programa tem como objetivo imprimir guias de pesagem"
cDesc2  := " "
cDesc3  := "Br-Aves"
nomerel := "RRPCP001G"

cEditA1	 := Space(8)
cEditA2	 := Space(30)
cEditA3	 := Space(15)
cEditA4	 := Space(30)
c_cPlaca	:=	 space(8)

// Variaveis Private da Funcao
Private _oDlg				// Dialog Principal
// Variaveis que definem a Acao do Formulario
Private VISUAL := .F.
Private INCLUI := .F.
Private ALTERA := .F.
Private DELETA := .F.


PEGAPLACA()

if _lContinua
	cEditA1:=c_cPlaca
	DEFINE MSDIALOG _oDlg TITLE "Pesagem PAGA" FROM C(270),C(258) TO C(410),C(637) PIXEL
	
	// Cria Componentes Padroes do Sistema
	@ C(006),C(005) Say "Placa do veiculo" Size C(041),C(008) COLOR CLR_BLACK PIXEL OF _oDlg
	@ C(004),C(047) Say oEdit1 Var cEditA1 Size C(054),C(009) COLOR CLR_BLACK PIXEL OF _oDlg
	@ C(017),C(005) Say "Empresa" Size C(022),C(008) COLOR CLR_BLACK PIXEL OF _oDlg
	@ C(018),C(047) MsGet oEdit2 Var cEditA2 Size C(140),C(009) COLOR CLR_BLACK PIXEL OF _oDlg PICTURE "@!"
	@ C(030),C(005) Say "Motorista" Size C(023),C(008) COLOR CLR_BLACK PIXEL OF _oDlg
	@ C(030),C(047) MsGet oEdit3 Var cEditA3 Size C(055),C(009) COLOR CLR_BLACK PIXEL OF _oDlg PICTURE "@!"
	@ C(042),C(005) Say "Carregamento" Size C(035),C(008) COLOR CLR_BLACK PIXEL OF _oDlg
	@ C(042),C(047) MsGet oEdit4 Var cEditA4 Size C(140),C(009) COLOR CLR_BLACK PIXEL OF _oDlg PICTURE "@!"
	@ C(059),C(120) BMPBUTTON TYPE 06 ACTION RRPCP1G1()
	@ C(059),C(151) BMPBUTTON TYPE 02 ACTION Close(_oDlg)
	
	ACTIVATE MSDIALOG _oDlg CENTERED
endif
_cModo	:=	"1"
Return(.T.)

STATIC FUNCTION RRPCP1G1
dbSelectArea("ZFE")

if _nEscolha	==1    // peso bruto
	RecLock("ZFE",.F.)
	replace ZFE_PESO_T	with	ZFE_PESO_1
	replace ZFE_DATA_T	with	ZFE_DATA_1
	replace ZFE_HORA_T	with	ZFE_HORA_1
	replace ZFE_USER_T	with	ZFE_USER_1
	replace ZFE_PESO_1	with	_nPeso
	replace ZFE_DATA_1	with	DDATABASE
	replace ZFE_HORA_1	with	left(time(),5)
	replace ZFE_USER_1	with	CUSERNAME
	replace ZFE_PESO_L	with	ZFE->ZFE_PESO_1	-	ZFE->ZFE_PESO_T
	replace	ZFE_VLPESO	with	SuperGetMV("MV_VALPESO")
	MsUnLock()
elseif	_nEscolha	==2		// GUIA
	_NumGuia	:=	GETSXENUM("ZFE")
	RecLock("ZFE",.T.)
	replace	ZFE_FILIAL	with	xFilial("ZFE")
	replace ZFE_VEICUL	with	c_cPlaca
	replace ZFE_NUM		with	_NumGuia
	replace ZFE_TIPO	with	"4"
	replace ZFE_MODO_1	with	_cModo
	replace ZFE_NOMMOT	with	cEditA3
	replace ZFE_NOMTRA	with	cEditA2
	replace ZFE_PRODUT	with	cEditA4
	replace ZFE_PESO_1	with	_nPeso
	replace ZFE_DATA_1	with	DDATABASE
	replace ZFE_HORA_1	with	left(time(),5)
	replace ZFE_USER_1	with	CUSERNAME
	replace	ZFE_VLPESO	with	SuperGetMV("MV_VALPESO")
	MsUnLock()
	CONFIRMSX8()
elseif	_nEscolha	==3		// TARA
	RecLock("ZFE",.F.)
	replace ZFE_PESO_T	with	_nPeso
	replace ZFE_DATA_T	with	DDATABASE
	replace ZFE_HORA_T	with	left(time(),5)
	replace ZFE_USER_T	with	CUSERNAME
	replace ZFE_MODO_T	with	_cModo
	replace	ZFE_VLPESO	with	SuperGetMV("MV_VALPESO")
	if !empty(ZFE->ZFE_PESO_1)
		replace ZFE_PESO_L	with	ZFE->ZFE_PESO_1	-	ZFE->ZFE_PESO_T
	endif
	MsUnLock()
endif
RRPCP1G1A("1")
Close(_oDlg)
_nPeso	:= 0
_cModo	:=	"1"

RETURN

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRRPCP001  บAutor  ณMicrosiga           บ Data ณ  16/03/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
STATIC FUNCTION RRPCP1G1A(_cRei)
cPerg:=""
nomerel := SetPrint(cString,nomerel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho)

If nLastKey == 27
	Close(_oDlg)
	_nPeso	:= 0
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
	Close(_oDlg)
	_nPeso	:= 0
	Return
Endif
/*

_________________________________________________________________________________
GUIA DE PESAGEM N.: 999.999
_________________________________________________________________________________
VEICULO:      XXXX9999   - XXXXXXXXXXXXXXXXX
EMPRESA:      XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
MOTORISTA:	  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
CARREGAMENTO: XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
=================================================================================
DADOS DA PESAGEM

PESO BRUTO  : 999.999 KGS.				99/99/9999  99:99:99
TARA        : 999.999 KGS.				99/99/9999  99:99:99
PESO LIQUIDO: 999.999 KGS.
=================================================================================
DADOS DA OPERACAO:                            |  VALOR A COBRAR:
|
OPERADOR: XXXXXXXXXXXXXXX                     |  R$ 999,99
|
|
______________________________________________|__________________________________
0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
1         2         3         4         5         6         7         8         9
*/

nLin	:=	0
@nLin,000 PSAY Replic("_",080)
nLin++
@nLin,000 PSAY "Br-Aves                               UNIDADE: "+ left(SM0->M0_FILIAL,22)
nLin++
@nLin,000 PSAY SM0->M0_ENDENT
nLin++
@nLin,000 PSAY "CNPJ: " + SM0->M0_CGC + "                     I.E.: " + SM0->M0_INSC
nLin++
@nLin,000 PSAY SM0->M0_TEL + "                                                 www.rigor.com.br"
nLin++
@nLin,000 PSAY Replic("_",080)
nLin++
if _cRei	==	"2"
	@nLin,000 PSAY "HORA: " + TIME()
	nLin++
	@nLin,000 PSAY Replic("_",081)
	nLin++
endif
if _cRei=="2"
	@nLin,042 PSAY "REIMPRESSAO"
endif
@nLin,054 PSAY "GUIA DE PESAGEM N.:"
@nLin,074 PSAY ZFE->ZFE_NUM
nLin++
@nLin,000 PSAY Replic("_",080)
nLin++
@nLin,000 PSAY "VEICULO: "
@nLin,016 PSAY ZFE->ZFE_VEICUL
nLin++
@nLin,000 PSAY "TRANSPORTADORA:"
@nLin,016 PSAY ZFE->ZFE_NOMTRA
nLin++
@nLin,000 PSAY "MOTORISTA:"
@nLin,016 PSAY ZFE->ZFE_NOMMOT
nLin++
@nLin,000 PSAY "CARREGAMENTO:"
@nLin,016 PSAY ZFE->ZFE_PRODUT
nLin++
@nLin,000 PSAY Replic("=",080)
nLin++
@nLin,000 PSAY "DADOS DA PESAGEM"
nLin++
nLin++
@nLin,000 PSAY "PESO BRUTO  :"
@nLin,014 PSAY ZFE->ZFE_PESO_1 PICTURE "@E 999,999"
@nLin,022 PSAY "KGS." + " - " + IIF(ZFE->ZFE_PESO_1>0,IIF(ZFE->ZFE_MODO_1=="1","AUTO","MANUAL"),"")
@nLin,040 PSAY ZFE->ZFE_DATA_1
@nLin,052 PSAY ZFE->ZFE_HORA_1
nLin++
@nLin,000 PSAY "TARA        :"
@nLin,014 PSAY ZFE->ZFE_PESO_T PICTURE "@E 999,999"
@nLin,022 PSAY "KGS." + " - " + IIF(ZFE->ZFE_PESO_T>0,IIF(ZFE->ZFE_MODO_T=="1","AUTO","MANUAL"),"")
@nLin,040 PSAY ZFE->ZFE_DATA_T
@nLin,052 PSAY ZFE->ZFE_HORA_T
nLin++
@nLin,000 PSAY "PESO LIQUIDO:"
@nLin,014 PSAY ZFE->ZFE_PESO_L PICTURE "@E 999,999"
@nLin,022 PSAY "KGS."
nLin++
@nLin,000 PSAY Replic("=",080)
nLin++
@nLin,000 PSAY "DADOS DA OPERACAO:                            |  VALOR A COBRAR:"
nLin++
@nLin,000 PSAY "                                              |"
nLin++
@nLin,000 PSAY "OPERADOR:"
@nLin,010 PSAY CUSERNAME
@nLin,046 PSAY "|  R$ "
@nLin,052 PSAY SuperGetMV("MV_VALPESO") picture "@E 999.99"
nLin++
@nLin,000 PSAY "                                              |"
nLin++
@nLin,000 PSAY "                                              |"
nLin++
@nLin,000 PSAY "______________________________________________|_________________________________"
nLin++
Set Device to Screen

If aReturn[5]==1
	Set Printer to
	OurSpool(nomerel)
endif
MS_FLUSH()
RETURN
  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRRPCP001  บAutor  ณMicrosiga           บ Data ณ  16/03/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Botao1()
Close(_oDlg)
_lContinua	:=	.T.
if empty(c_cPlaca)
	msgstop("Placa nao pode ser vazia!!! ER08a")
	_lContinua	:=	.F.
	return
endif

dbSelectArea("ZFE")
dbSetOrder(2)
dbSeek(xFilial("ZFE")+c_cPlaca,.T.)
if eof()
	MSGSTOP("Nao ha guia aberta para esse veiculo, abra uma guia!!! ER11a")
	_lContinua	:=	.F.
else
	while !eof()
		if c_cPlaca <> ZFE->ZFE_VEICUL
			MSGSTOP("Nao ha guia aberta para esse veiculo, abra uma guia!!! ER10a")
			_lContinua	:=	.F.
			return
		endif
		if ZFE->ZFE_PESO_1 == 0 .or. ZFE->ZFE_PESO_T == 0
			cEditA3	:=	ZFE->ZFE_NOMMOT
			cEditA2	:=	ZFE->ZFE_NOMTRA
			cEditA4	:=	ZFE->ZFE_PRODUT
			_lContinua	:=	.T.
			exit
		endif
		
		dbSelectArea("ZFE")
		dbskip()
	enddo
	if _nEscolha	== 1 .and. ZFE->ZFE_PESO_1 > _nPeso
		MSGSTOP("Tara maior que peso bruto. ERRO!!! ER05")
		_lContinua	:=	.F.
	elseif	_nEscolha	== 3 .and. ZFE->ZFE_PESO_1 < _nPeso
		MSGSTOP("Tara maior que peso bruto. ERRO!!! ER12")
		_lContinua	:=	.F.
	endif
endif

return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRRPCP001  บAutor  ณMicrosiga           บ Data ณ  16/03/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function Botao2()
_nEscolha	:= 2
Close(_oDlg)
_lContinua	:=	.T.
if _nPeso	> 0
	if empty(c_cPlaca)
		msgstop("Placa nao pode ser vazia!!! ER08")
		_lContinua	:=	.F.
	endif
else
	msgstop("PESO INVALIDO!!! ER09")
	_lContinua	:=	.F.
endif
return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRRPCP001  บAutor  ณMicrosiga           บ Data ณ  16/03/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Peso()
_nPeso	:= cEdit1
Close(_oDlg)
_lContinua	:=	.T.
return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRRPCP001  บAutor  ณMicrosiga           บ Data ณ  16/03/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
STATIC FUNCTION PEGAPLACA()
if _nPeso	<	1
	msgstop("PESO INVALIDO!!! AV11")
	_lContinua	:=	.F.
	return
endif

DEFINE FONT oFnt  NAME "Arial" SIZE 15,50 BOLD
DEFINE FONT oFnt1 NAME "Arial" SIZE 5,30 BOLD
DEFINE MSDIALOG _oDlg TITLE "Pesagem de veiculo" FROM C(342),C(360) TO C(492),C(560) PIXEL

// Cria Componentes Padroes do Sistema
@ C(001),C(004) Say "Placa do veiculo" 	Size C(060),C(100) COLOR CLR_BLACK PIXEL OF _oDlg FONT oFnt1
@ C(015),C(003) MsGet o_cPlaca Var c_cPlaca Size C(097),C(023) COLOR CLR_BLACK PIXEL OF _oDlg FONT oFnt PICTURE "@!"
@ C(045),C(005) Button "&Bruto" 			Size C(037),C(012) PIXEL OF _oDlg ACTION (_nEscolha	:= 1,Botao1())
@ C(045),C(060) Button "&Guia" 			Size C(037),C(012) PIXEL OF _oDlg ACTION Botao2()
@ C(060),C(005) Button "&Tara" 			Size C(037),C(012) PIXEL OF _oDlg ACTION (_nEscolha	:= 3,Botao1())
@ C(060),C(060) Button "&Cancela" 		Size C(037),C(012) PIXEL OF _oDlg ACTION (Close(_oDlg),_lContinua	:=	.F.)

ACTIVATE MSDIALOG _oDlg CENTERED

RETURN

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRRPCP001  บAutor  ณMicrosiga           บ Data ณ  16/03/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
STATIC FUNCTION RRPCP001H
	
	//Declara็ใo de variแveis.
	Local oGroup1
	Local oGroup2
	Local oGroup3
	
	cEdit1	:=	0
	
	DEFINE FONT oFnt  NAME "Arial" SIZE 40,70 BOLD
	DEFINE FONT oFnt1 NAME "Arial" SIZE 08,30 BOLD
	
	DEFINE MSDIALOG _oDlg TITLE "" FROM C(242),C(284) TO C(480),C(820) PIXEL STYLE DS_MODALFRAME
	
	// Cria Componentes Padroes do Sistema
	@ C(001),C(005) GROUP oGroup3 To  C(014), C(265) Prompt "" Of _oDlg Color 0, 16777215 Pixel
	@ C(002),C(120) Say "Pesagem Manual" Size C(60),C(100) COLOR CLR_RED PIXEL OF _oDlg FONT oFnt1
	
	@ C(025),C(120) Say "Entre com o Peso" Size C(60),C(100) COLOR CLR_BLUE PIXEL OF _oDlg
	@ C(030),C(045) GROUP oGroup1 To  C(080), C(217) Prompt "" Of _oDlg Color 0, 16777215 Pixel
	@ C(035),C(050) MsGet oEdit1 Var cEdit1 Size C(163),C(040) Picture "@E 99,999" FONT oFnt COLOR CLR_BLUE PIXEL OF _oDlg
	
	@ C(100),C(005) GROUP oGroup2 To C(115), C(265) Prompt "" Of _oDlg Color 0, 16777215 Pixel
	//@ C(105),C(035) Say "PESAGEM MANUAL" Size C(60),C(100) COLOR CLR_BLUE PIXEL OF _oDlg
	@ C(103),C(115) BMPBUTTON TYPE 01 ACTION Peso()
	@ C(103),C(140) BMPBUTTON TYPE 02 ACTION Close(_oDlg)
	
	_oDlg:Activate(,,,.T.,{||.T.},,{|| } )
	_cModo	:=	"2"
	
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRRPCP001  บAutor  ณMicrosiga           บ Data ณ  16/03/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
static Function RRPCP001I()

//REIMPRESSAO DE GUIA
// Variaveis Locais da Funcao
Local cEdit1	 := Space(25)
Local cEdit2	 := Space(25)
Local oEdit1
Local oEdit2
// Variaveis Private da Funcao
Private _oDlg9				// Dialog Principal
// Variaveis que definem a Acao do Formulario
Private VISUAL	:= .F.
Private INCLUI	:= .F.
Private ALTERA	:= .F.
Private DELETA	:= .F.
aOrd			:= {}
tamanho			:= "G"
limite			:= 120
nomeprog		:= "RRPCP001I"
mv_tabpr		:= ""
nTipo			:= 18
aReturn			:= { "Zebrado", 1,"Administracao", 2, 2, 1,"",1}
nLastKey		:= 0
nlin			:= 0
nItem			:= 1
lContinua		:= .T.
_cTipVei		:= ""
cString			:= "ZZK"
titulo			:= "GUIA DE PESAGEM - ABATIDO"
cDesc1			:= "Este programa tem como objetivo imprimir guias de pesagem"
cDesc2			:= " "
cDesc3			:= " Br-Aves"
nomerel			:= "RRPCP001I"

DEFINE MSDIALOG _oDlg9 TITLE "Reimpressao de Guia" FROM C(215),C(259) TO C(336),C(474) PIXEL

// Cria Componentes Padroes do Sistema
@ C(005),C(005) Say "Guia" Size C(014),C(008) COLOR CLR_BLACK PIXEL OF _oDlg9
//@ C(015),C(040) Say "ou" Size C(008),C(008) COLOR CLR_BLACK PIXEL OF _oDlg9
//@ C(025),C(005) Say "Placa" Size C(014),C(008) COLOR CLR_BLACK PIXEL OF _oDlg9
@ C(002),C(024) MsGet oEdit1 Var cEdit1 Size C(054),C(010) COLOR CLR_BLACK PIXEL OF _oDlg9  F3 "ZFE"
//@ C(025),C(023) MsGet oEdit2 Var cEdit2 Size C(054),C(009) COLOR CLR_BLACK PIXEL OF _oDlg9  F3 "ZFE1"
@ C(045),C(018) BMPBUTTON TYPE 01 ACTION (RRPCP001IA(cEdit1,cEdit2),Close(_oDlg9))
@ C(045),C(067) BMPBUTTON TYPE 02 ACTION Close(_oDlg9)

ACTIVATE MSDIALOG _oDlg9 CENTERED

Return(.T.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRRPCP001  บAutor  ณMicrosiga           บ Data ณ  16/03/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
STATIC FUNCTION RRPCP001IA(_nNumGuia,_cVeiculo)
if !Empty(_nNumGuia)
	DbSelectArea("ZFE")
	DbSetOrder(1)
	If DbSeek(xFilial("ZFE")+_nNumGuia,.F.)
		_cTipGuia	:=	ZFE->ZFE_TIPO
		_dDtGuia	:=	ZFE->ZFE_DATA_1
		c_cPlaca	:=	_cVeiculo
	Else
		return
	EndIf
ElseIf !Empty(_cVeiculo)
	DbSelectArea("ZFE")
	DbSetOrder(2)
	DbSeek(xFilial("ZFE")+ALLTRIM(_cVeiculo)+"ZZZZZZ",.T.)
	DbSkip(-1)
	_cTipGuia	:=	ZFE->ZFE_TIPO
	_dDtGuia	:=	ZFE->ZFE_DATA_1
	c_cPlaca	:=	_cVeiculo
	_cGuia		:=	ZFE->ZFE_NUM
Else
	Return
EndIf

if _cTipGuia == "5"
	//RRPCP001D2("2")
	RRPCP001D3("2")
elseif _cTipGuia == "6"
	RRPCP001E3("2")
elseif _cTipGuia == "3"
	RRPCP001F3("2")
else
	RRPCP1G1A("2")
endif
//Close(_oDlg9)
_nPeso	:= 0

return
  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRRPCP001  บAutor  ณMicrosiga           บ Data ณ  16/03/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
STATIC FUNCTION GERAFRETE(_lFrete)
if	!_lFrete
	dbSelectArea("ZZE")  //TABELA DE VALORES DE FRETE GRANJA
	dbSetOrder(1)		//ZZE_FILIAL+ZZE_COD+ZZE_LOJA+ZZE_GRANJA+ZZE_ATE
	If dbSeek(xFilial("ZZE")+ZFE->ZFE_COD_R+ZFE->ZFE_LJGR_R+"01",.T.)
		while !eof() .and.	ZFE->ZFE_COD_R==ZZE_COD .and. ZFE->ZFE_LJGR_R== ZZE_LOJA .and. alltrim(ZZE_GRANJA) == "01"
			_nValor	:=	ZZE->ZZE_VALOR1
			_cOcor	:=	GETADVFVAL("ZZU","ZZU_DESCRI",(xFilial("ZZU")+"901"),1,"")
			dbSelectArea("ZZV")
			RecLock("ZZV",.T.)
			replace ZZV_FILIAL 	with	xFilial("ZZV")
			replace ZZV_DATA 	with	DDATABASE
			replace ZZV_PLACA 	with	_cPlaca
			replace ZZV_CODOCO	with	"901"
			replace	ZZV_OCORRE	with	_cOcor
			replace ZZV_VALOR	with	_nValor
			replace ZZV_RELAC	with	"Guia: "+ ZFE->ZFE_NUM
			replace ZZV_ROTA	with	ZFE->ZFE_NROCAR
			replace ZZV_MT1		with	ZZE->ZZE_COD + "-"+ZZE->ZZE_LOJA + "  " + ALLTRIM(ZZE->ZZE_NOME) + "- Granja: "+ ZZE->ZZE_GRANJA
			replace ZZV_MT2		with    "FRT-S"
			
			MsUnlock()
			exit
		end
	else
		MSGSTOP("NAO FOI GERADO O VALOR DE FRETE, FAVOR ANOTAR UMA OBSERVACAO!!! AV12")
		dbSelectArea("ZFE")
		RecLock("ZFE",.F.)
		ZFE->ZFE_OBS		+=	" NAO FOI GERADO O VALOR DE FRETE!!! AV12 "  
		MsUnLock()
	endif
endif
return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRRPCP001  บAutor  ณMicrosiga           บ Data ณ  16/03/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
STATIC FUNCTION CHECAORDEM(_nNum)
//FUNCAO AUXILIAR QUE CHEGA SE EXISTE A ORDEM DE CARREGAMENTO
dbSelectArea("ZZK")
dbSetOrder(4)
if dbSeek(xFilial("ZZK")+c_Ordem,.F.)
	return(.T.)
else
	cquery:=	"SELECT ZZK_NUM, D_E_L_E_T_ "+;
	"FROM "+retsqlname("ZZK")+" "+;
	"WHERE ZZK_NUM = '"+c_Ordem+"' AND ZZK_FILIAL='"+XFILIAL("ZZK")+"' "
	TCQUERY cQuery new alias "XPTP"
	dbSelectArea("XPTP")
	if !eof()
		MSGSTOP("ORDEM DE CARREGAMENTO EXCLUIDA!!!! ENTRE EM CONTADO COM O RESPONSAVEL")
		return(.F.)
	endif
	dbSelectArea("XPTP")
	dbCloseArea("XPTP")
endif

return(.T.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRRPCP001    บAutor  ณMicrosiga           บ Data ณ  16/03/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
STATIC FUNCTION GERALIBERA()
// funcao auxiliar que gera registro para que o veiculo possa ser liberado
// gerando registro no ZZ6
_cNFS	:=	""

DbSelectArea("DAI")
DBSETORDER(1)
If	DbSeek(xFilial("DAI")+_cRota,.f.)
	while !eof() .and. _cRota == DAI->DAI_COD
		_cNFS	+=	DAI->DAI_NFISCA+"/"
		dbskip()
	end
endif

DbSelectArea("ZZ6")
DBSETORDER(1)
//ZZ6_FILIAL+ZZ6_PLACA+ZZ6_DATA+ZZ6_SEQ
DbSeek(xFilial("ZZ6")+c_cPlaca+_cRota+"ZZ",.T.)
DbSkip(-1)
if c_cPlaca	==ZZ6_PLACA .and. _cRota	==	ZZ6_ROTA
	_cSeq	:=	PADL(ALLTRIM(STR(VAL(ZZ6->ZZ6_SEQ)+1)),2,"0")
else
	_cSeq	:=	"01"
endif
RecLock("ZZ6",.T.)
replace	ZZ6_FILIAL	with 	xFilial("ZZ6")
replace	ZZ6_PLACA	with	c_cPlaca
replace	ZZ6_ROTA	with	_cRota
replace	ZZ6_DATA	with	DDATABASE
replace	ZZ6_SEQ		with	_cSeq
replace	ZZ6_NFS		with	_cNFS
replace	ZZ6_PESONF	with	_nPesoRota
replace	ZZ6_PESOBA	with	_nPeso - ZFE->ZFE_PESO_T

MsUnLock()

return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณPrograma   ณ   C()   ณ Autores ณ Norbert/Ernani/Mansano ณ Data ณ10/05/2005ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao  ณ Funcao responsavel por manter o Layout independente da       ณฑฑ
ฑฑณ           ณ resolucao horizontal do Monitor do Usuario.                  ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function C(nTam)
Local nHRes	:=	oMainWnd:nClientWidth	// Resolucao horizontal do monitor
If nHRes == 640	// Resolucao 640x480 (soh o Ocean e o Classic aceitam 640)
	nTam *= 0.8
ElseIf (nHRes == 798).Or.(nHRes == 800)	// Resolucao 800x600
	nTam *= 1
Else	// Resolucao 1024x768 e acima
	nTam *= 1.28
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณTratamento para tema "Flat"ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If "P10" $ oApp:cVersion
	If (Alltrim(GetTheme()) == "FLAT") .Or. SetMdiChild()
		nTam *= 0.90
	EndIf
EndIf
Return Int(nTam)

STATIC FUNCTION RRPCP001V
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณPrograma  ณ  HH0207V ณ Autor ณ                       ณ Data ณ 30/01/07 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Tela auxiliar para escolha do roteiro pela portaria        ณฑฑ
ฑฑณ          ณ                                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ Balanca Br-Aves                                            ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑณ Arquivos ณ                                                            ณฑฑ
ฑฑณ em Uso   ณ                                                            ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑณ Manutencao :                                                          ณฑฑ
ฑฑณ                                                                       ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Opcao de acesso para o Modelo 2                              ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
// 3,4 Permitem alterar getdados e incluir linhas
// 6 So permite alterar getdados e nao incluir linhas
// Qualquer outro numero so visualiza
//Private aCols    := {}
Public _nPosLin
nOpcx:=1	// so visualiza
_cAlias	:=	alias()
_corder	:=	indexord()
_nrecno	:=	recno()
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Variaveis do Rodape do Modelo 2                              ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
nLinGetD:=0
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Titulo da Janela                                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cTitulo:="ROTEIROS ABERTOS PARA O VEICULO"
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Array com coordenadas da GetDados no modelo2                 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aCGD:={44,5,118,315}
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Validacoes na GetDados da Modelo 2                           ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cLinhaOk:="AllWaysTrue()"
cTudoOk:= "AllWaysTrue()"
aR:={}
aC:={}

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Chamada da Modelo2                                           ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

lRetMod2:=Modelo2(cTitulo,aC,aR,aCGD,nOpcx,cLinhaOk,cTudoOk)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Grava tabela                                                 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lRetMod2
	return(aCols[n][1]+aCols[n][2])
endif

RETURN()
                                  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRRPCP001    บAutor  ณMicrosiga           บ Data ณ  16/03/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
static function GERAPC(_nQtd,_cSilo)
// INICIO DA GERACAO DA ORDEM DE PRODUCAO
_cNum	:=	GETSXENUM("SC5")
lMsErroAuto := .F.
/*
Local aCab := {}
Local aItem:= {}

lMsErroAuto := .F.

aCab:= {		{"CJ_NUM",GetSxeNum("SCJ","CJ_NUM"),NIL},;
{"CJ_CLIENTE","000001",NIL},;
{"CJ_CONDPAG","001",NIL}}

Aadd(aItem, {	{"CK_PRODUTO","999999999999999",NIL},;
{"CK_PRCVEN",10,NIL},;
{"CK_VALOR",10,NIL},;
{"CK_TES","501",NIL},;
{"CK_QTDVEN",1,NIL}})

MSExecAuto({|x,y,z| mata415(x,y,z)},aCab,aItem,3) //Inclusao



aVetor:={ 		;
{"C5_NUM"		,_cNum	,NIL},;
{"C5_TIPO"		,"B"		,NIL},;  // UTILIZA FORNECEDOR
{"C5_CLIENTE"	,"001"		,NIL},;
{"C5_LOJA"	,ZZ1->ZZ1_RACAO		,NIL},;
{"C2_LOCAL"		,_cSilo				,NIL},;
{"C2_QUANT"		,_nQtd	,NIL},;
{"C2_EMISSAO"	,ddatabase	,NIL},;
{"C2_DATPRI"	,_dData	,NIL},;
{"C2_OBS"		,"APONTAMENTO RACAO",NIL},;
{"AUTEXPLODE"	,"S"		,NIL},;
{"C2_DATPRF"	,_dData	,NIL}}

MSExecAuto({|x,y| mata650(x,y)},aVetor,3) //Inclusao
If lMsErroAuto
Alert("Erro!!! Nao foi possivel gerar a ordem "+_cProd)
Mostraerro()
Return .f.
Else
CONFIRMSX8()
Endif

*/
return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRRPCP001    บAutor  ณMicrosiga           บ Data ณ  16/03/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
STATIC FUNCTION PEGAORDEM(_cProd)
_aNum	:={} //{(""),(0),(""),(""),("")} - alteracao 	para tratar erros de OP - Daniel 13/01/2010

cQuery := "SELECT C2_NUM, C2_LOCAL, C2_PRODUTO, C2_QUANT, C2_EMISSAO,C2_DATPRI  "
cQuery += "FROM "+ retsqlname("SC2") +" AS SC2 "
cQuery += "WHERE C2_QUANT > 0 "
cQuery += "AND C2_QUJE	=	0 "
cQuery += "AND C2_PRODUTO = '"+_cProd+"' "
cQuery += "AND D_E_L_E_T_ = '' "
cQuery += " AND C2_FILIAL='"+XFILIAL("SC2")+"' "
cQuery += "ORDER BY C2_NUM DESC, C2_PRODUTO, C2_LOCAL"

TCQUERY cQuery new alias "EST"

dbSelectArea("EST")
dbGoTop()
if	!EOF() .and. alltrim(EST->C2_PRODUTO) == alltrim(_cProd) //Incluํdo clausula !EOF() .and.
_aNum	:={(""),(0),(""),(""),("")}
	_aNum[1]	:=	EST->C2_NUM
	_aNum[2]	:=	EST->C2_QUANT
	_aNum[3]	:=	EST->C2_LOCAL
	_aNum[5]	:=	stod(EST->C2_DATPRI)
endif
dbSelectArea("EST")
dbCloseArea("EST")

RETURN(_aNum)           

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRRPCP001    บAutor  ณMicrosiga           บ Data ณ  16/03/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
STATIC FUNCTION AVISE

MSGSTOP("ษ OBRIGATORIO ESTORNAR A PRODUCAO, ANTES DE REFAZER A SEGUNDA PESAGEM!!!")
RETURN                    



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRRPCP001    บAutor  ณMicrosiga           บ Data ณ  16/03/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
STATIC FUNCTION CHECAFRETE(_nPeso)
//funcao auxiliar que verifica se houve algum frete para este veiculo no dia
// se houver serแ feita a pergunta se deve ou nใo gerar frete para esta carga

_nPsVei:= GetAdvFVal("DA3","DA3_CAPACM",xFilial("DA3")+_cPlaca,1,"")
_nTara:= ZFE->ZFE_PESO_T

	cGetx1	 := _nTara + _nPsVei
	cGetx2	 := _nPeso
	cGetx3	 := _cPlaca
	
	// Variaveis Private da Funcao
	Private oG_Frete				// Dialog Principal
	// Variaveis que definem a Acao do Formulario
	Private VISUAL := .F.
	Private INCLUI := .F.
	Private ALTERA := .F.
	Private DELETA := .F.
	
	DEFINE MSDIALOG oG_Frete TITLE "Confirma frete" FROM C(288),C(446) TO C(432),C(734) PIXEL
	
	@ C(004),C(004) Say "A capacidade de carga total do veiculo que ้: " Size C(088),C(008) COLOR CLR_BLACK PIXEL OF oG_Frete
	@ C(004),C(098) Say cGetx1 Size C(038),C(009) COLOR CLR_BLACK Picture "@E 999,999" PIXEL OF oG_Frete
	@ C(014),C(004) Say "nao foi completada nesta pesagem" Size C(084),C(008) COLOR CLR_BLACK PIXEL OF oG_Frete
	@ C(014),C(097) Say cGetx2 Size C(039),C(009) COLOR CLR_BLACK Picture "@E 999,999" PIXEL OF oG_Frete
	@ C(024),C(004) Say "O veiculo" Size C(029),C(008) COLOR CLR_BLACK PIXEL OF oG_Frete
	@ C(024),C(035) Say cGetx3 Size C(029),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oG_Frete
	@ C(024),C(068) Say "tera um carga complementar?" Size C(070),C(008) COLOR CLR_BLACK PIXEL OF oG_Frete
	@ C(034),C(004) Say "Informe se o frete sera gerado agora ou posteriormente." Size C(134),C(008) COLOR CLR_BLACK PIXEL OF oG_Frete
	@ C(056),C(013) Button "NAO gera frete" Size C(051),C(012) PIXEL OF oG_Frete ACTION (_lFrete	:=	.T.,GERAFRETE(_lFrete),Close(oG_Frete))
	@ C(056),C(068) Button "GERA frete agora" Size C(051),C(012) PIXEL OF oG_Frete ACTION (_lFrete	:=	.F.,GERAFRETE(_lFrete),Close(oG_Frete))
	
	ACTIVATE MSDIALOG oG_Frete CENTERED

RETURN  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRRPCP001  บAutor  ณMicrosiga           บ Data ณ  16/03/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function VALVEIC(_cCod,_nOpc)
_lRetorno	:=	.T.
if	empty(_cCod)
	MSGSTOP("DIGITE UMA PLACA DE VEICULO!!!")
	return(.F.)
endif
dbSelectArea("DA3")
dbSetOrder(1)
If dbSeek(xFilial("DA3")+_cCod,.F.)
	If _nOpc = 1
		if	DA3->DA3_CODGRU != "003"
			msgstop("ESTE VEICULO NAO ษ PARA TRANSPORTE DE RACAO")
			_lRetorno	:=	.F.
		endif              
		_PesoMaxVC := DA3->DA3_CAPACM
	EndIF	
else
	msgstop("VEICULO NรO CADASTRADO, CONSULTE A LOGISTICA!")
	_lRetorno	:=	.F.
endif

return(_lRetorno)
                  
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ VALPL    บAutor  ณMicrosiga           บ Data ณ  16/03/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function VALPL(_cCod)
_lRetorno	:=	.F.
if	empty(_cCod)
	MSGSTOP("DIGITE UMA PLACA DE VEICULO!!!")
	return(.F.)
endif

dbSelectArea("DA3")
dbSetOrder(1)
If dbSeek(xFilial("DA3")+_cCod,.F.)
  _lRetorno := .T.
ELSE
  msgstop("VEICULO NรO CADASTRADO, CONSULTE A LOGISTICA!")
  _lRetorno	:=	.F.
endif

_lContinua := _lRetorno                    

return(_lRetorno)

 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRRPCP001  บAutor  ณMicrosiga           บ Data ณ  16/03/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
//Posiciona no ZZ1 Daniel Pitthan Silveira 22/02/2010
Static Function PosicionaZZ1(cProd)
	BeginSQL Alias 'TZZ1'
		Select R_E_C_N_O_ AS RECNOX ,* from %table:ZZ1% as ZZ1 WHERE ZZ1_RACAO=%exp:cProd% and ZZ1.%notdel%  and ZZ1_DATA>=%exp:DTOS(DDATABASE)% AND ZZ1_FILIAL=%Exp:xFilial('ZZ1')%
	EndSql	
	            
	DbSelectArea('TZZ1');DbGotop() 
	DBSELECTAREA('ZZ1')
	DbGoto(TZZ1->RECNOX)
	TZZ1->(DbCloseArea())
	
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRICOMA06  บAutor  ณMicrosiga           บ Data ณ  08/18/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PrimeiroPeso(cPlaca,cTipo)
Local cNotas    := SPACE(50) 
Local nLin      := 0
Local lRet      := .T.
Local aAltera1  := {}
Local aAltera2  := {}
Local aAltera3  := {"FORNECE","PRODUTO","SILO","IMPOSTOS","FRETE"} 
Local cNotaDe   := SPACE(9)
Local cNotaAte  := SPACE(9)  
Local cSerieDe  := SPACE(3)
Local cSerieAte := SPACE(3)

Private aHeader1  := {}
Private aCols1    := {}
Private aHeader2  := {}
Private aCols2    := {}
Private aHeader3  := {}
Private aCols3    := {}

Private oDlgPes 
Private oLbl01 
Private oGet01 
Private oNf
Private oItNf
Private oItPeso

Private nPesOri	:= 0 //ษverson - 12/02/2016

Set Key 123 TO chamapar()
                                 
//definicoes de fontes
oFont16  := TFont():New("Ternimal",09,016,.T.,.F.,05,.T.,05,.T.,.F.)
oFont16n := TFont():New("Ternimal",00,016,.T.,.T.,05,.T.,05,.T.,.F.)

oDlgPes:= MSDIALOG():Create()
oDlgPes:cName     := "oDlgPes"
oDlgPes:cCaption  := "Entrada de materiais - 1a Pesagem"
oDlgPes:nLeft     := 34
oDlgPes:nTop      := 222
oDlgPes:nWidth    := 800
oDlgPes:nHeight   := 550
oDlgPes:lShowHint := .F.
oDlgPes:lCentered := .T.


aAdd(aHeader1,{"Serie"			,"SERIE"	,"@!"				,02,0,"","","C","",""})
aAdd(aHeader1,{"Nota Fiscal"	,"NOTAFIS"	,"@!"				,09,0,"","","C","",""})

aAdd(aHeader2,{"Fornecedor"		,"FORNECE"	,"@!"				,06,0,"","","C","",""})
aAdd(aHeader2,{"Loja Forn"		,"LJFOR"	,"@!"				,02,0,"","","C","",""})
aAdd(aHeader2,{"Item"			,"ITEM"		,"@!"				,04,0,"","","C","",""})
aAdd(aHeader2,{"Produto"		,"PRODUTO"	,"@!"				,15,0,"","","C","",""})
aAdd(aHeader2,{"Quant. NF"		,"QUANT_NF"	,"@E 9,999,999.99"	,12,2,"","","N","",""})
aAdd(aHeader2,{"Contrato"		,"CONTRATO"	,"@!"				,09,0,"","","C","",""})

aAdd(aHeader3,{"Fornecedor"		,"FORNECE"	,"@!"				,06,0,"","","C","",""})
aAdd(aHeader3,{"Loja Forn"		,"LJFOR"	,"@!"				,02,0,"","","C","",""})
aAdd(aHeader3,{"Serie"			,"SERIE"	,"@!"				,03,0,"","","C","",""})
aAdd(aHeader3,{"Nota"			,"NOTA"		,"@!"				,09,0,"","","C","",""})
aAdd(aHeader3,{"Item Nf"		,"ITEM"		,"@!"				,04,0,"","","C","",""})
aAdd(aHeader3,{"Pedido"			,"PEDIDO"	,"@!"				,06,0,"","","C","",""})
aAdd(aHeader3,{"Item Ped."		,"ITEMPED"	,"@!"				,04,0,"","","C","",""})
aAdd(aHeader3,{"Contrato"		,"CONTRATO"	,"@!"				,09,0,"","","C","",""})
aAdd(aHeader3,{"Quant. NF"		,"QUANT"	,"@E 9,999,999.99"	,12,2,"","","N","",""})
aAdd(aHeader3,{"Peso Entrada"	,"PESOBAL"	,"@E 9,999,999.99"	,12,2,"","","N","",""})      


c_cPlaca := cPlaca
nLin      := 5
nPulLinha := 17

//Pega as notas fiscais.
oLbl01  := TSay():New(nLin,005, {|| OEMTOANSI("Placa do Veiculo: ")}	, oDlgPes,,oFont16 ,,,, .T.,CLR_BLACK,010,150)
oGet01  := TGet():New(nLin,090,bSetGet(c_cPlaca),oDlgPes,045,008,"@!",{ || },,,,,,.T.,,,,,,) 
oGet01:cF3  := "XA3"

nLin += nPulLinha                         
//oLbl02  := TSay():New(nLin,005, {|| OEMTOANSI("Notas Fiscais: ")}	, oDlgPes,,oFont16 ,,,, .T.,CLR_BLACK,010,70)
//oGet02  := TGet():New(nLin,090,bSetGet(cNotas),oDlgPes,20,008,"@!",{ || },,,,,,.T.,,,,,,) 

nLin += nPulLinha
oLbl03  := TSay():New(nLin,005, {|| OEMTOANSI("Notas De: ")}	, oDlgPes,,oFont16 ,,,, .T.,CLR_BLACK,010,50)
oGet03  := TGet():New(nLin,090,bSetGet(cNotaDe),oDlgPes,20,008,"@!",{ || },,,,,,.T.,,,,,,) 
oGet03:cF3  := "SF1"

oLbl04  := TSay():New(nLin,150, {|| OEMTOANSI("At้ ")}	, oDlgPes,,oFont16 ,,,, .T.,CLR_BLACK,010,150)
oGet04  := TGet():New(nLin,180,bSetGet(cNotaAte),oDlgPes,20,008,"@!",{ || },,,,,,.T.,,,,,,) 
oGet04:cF3  := "SF1"

//ษverson - 12/02/2016. Campo para informar peso de origem.
oLbl05  := TSay():New(nLin,250, {|| OEMTOANSI("Peso origem ")}	, oDlgPes,,oFont16 ,,,, .T.,CLR_BLACK,010,150)
oGet05  := TGet():New(nLin,310,bSetGet(nPesOri),oDlgPes,55,008,"@E 999,999",{ || },,,,,,.T.,,,,,,) 
//

nLin += nPulLinha
oLbl05  := TSay():New(nLin,005, {|| OEMTOANSI("Serie De: ")}	, oDlgPes,,oFont16 ,,,, .T.,CLR_BLACK,010,50)
oGet05  := TGet():New(nLin,090,bSetGet(cSerieDe),oDlgPes,10,008,"@!",{ || },,,,,,.T.,,,,,,) 

oLbl06  := TSay():New(nLin,150, {|| OEMTOANSI("At้ ")}	, oDlgPes,,oFont16 ,,,, .T.,CLR_BLACK,010,50)
oGet06  := TGet():New(nLin,180,bSetGet(cSerieAte),oDlgPes,10,008,"@!",{ || },,,,,,.T.,,,,,,) 

oSBtn01:= SBUTTON():Create(oDlgPes)
oSBtn01:cName := "oSBtn01"
oSBtn01:cCaption := "Pesquisar"
oSBtn01:nLeft := 500
oSBtn01:nTop := 110
oSBtn01:nWidth := 50
oSBtn01:nHeight := 20
oSBtn01:lShowHint := .F.
oSBtn01:lReadOnly := .F.
oSBtn01:Align := 0
oSBtn01:lVisibleControl := .T.
oSBtn01:bAction := {|| MsAguarde( { || Dados(cNotaDe,cNotaAte,cSerieDe,cSerieAte,c_cPlaca) } , "Aguarde" , "Carregando..." , .t. ) }

oNf := MsNewGetDados():New(069,004,151,150,GD_INSERT+GD_UPDATE,"Allwaystrue()","Allwaystrue()","",aAltera1,Nil,999,Nil,Nil,Nil,oDlgPes,aHeader1,@aCols1) //ษverson - 18/11/2015. Alterado para nใo ser possํvel marcar linha como deletada (GD_DELETE).  
oNf:bChange := {|| PreencheDados(oNf:NAT,oNf:aCols,"1") } //ษverson - 19/11/2015
oNf:oBrowse:bLDblClick  := {||PreencheDados(oNf:NAT,oNf:aCols,"1") }

oItNf := MsNewGetDados():New(069,155,151,395,GD_INSERT+GD_UPDATE,"Allwaystrue()","Allwaystrue()","",aAltera2,Nil,999,Nil,Nil,Nil,oDlgPes,aHeader2,@aCols2)  //ษverson - 18/11/2015. Alterado para nใo ser possํvel marcar linha como deletada (GD_DELETE).  
oItNf :oBrowse:bLDblClick := {||PreencheDados(oItNf:NAT,oItNf:aCols,"2",oNf:aCols[oNf:nat][1]+oNf:aCols[oNf:nat][2]+oItNf:aCols[oItNf:nat][3])}

//itens das notas fiscais
oItPeso := MsNewGetDados():New(155,005,255,395,GD_INSERT+GD_DELETE+GD_UPDATE,"Allwaystrue()","Allwaystrue()","",aAltera3,Nil,999,Nil,Nil,Nil,oDlgPes,aHeader3,@aCols3)

oSBtn01:= SBUTTON():Create(oDlgPes)
oSBtn01:cName := "oSBtn01"
oSBtn01:cCaption := "OK"
oSBtn01:nLeft := 587
oSBtn01:nTop := 110
oSBtn01:nWidth := 50
oSBtn01:nHeight := 20
oSBtn01:lShowHint := .F.
oSBtn01:lReadOnly := .F.
oSBtn01:Align := 0
oSBtn01:lVisibleControl := .T.
oSBtn01:bAction := {|| MsgRun("Gravando Informa็๕es...","Aguarde",{|| GravaDados(cTipo) }) }

oSBtn02:= SBUTTON():Create(oDlgPes)
oSBtn02:cName := "oSBtn02"
oSBtn02:cCaption := "Cancelar"
oSBtn02:nLeft := 670
oSBtn02:nTop := 110
oSBtn02:nWidth := 50
oSBtn02:nHeight := 20
oSBtn02:lShowHint := .F.
oSBtn02:lReadOnly := .F.
oSBtn02:Align := 0
oSBtn02:lVisibleControl := .T.
oSBtn02:bAction := {|| oDlgPes:End() }

Activate MSDialog oDlgPes Centered 

Return(.T.)  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRICOMA06  บAutor  ณMicrosiga           บ Data ณ  08/19/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GravaDados(cVar)
Local nX       := 0
Local itnf     := 1
Local cCodFor  := ""
Local cLojaFor := ""
Local cNota    := ""
Local numnf    := ""
Local cProduto := ""
Local cLocPad  := ""
Local nQtdNf   := 0
Local nPrcUni  := 0
Local nTotNf   := 0
Local nImposto := 0
Local nFrete   := 0
Local cSeq     := ""
Local cPedido  := ""
Local cItemPed := ""

If Empty(oItPeso:aCols[1][1])
	MSGSTOP("Nao hแ itens a serem gravados.")
	Return()
Else	
	cSeq := PegaSequencia()
	For nX := 1 to Len(oItPeso:aCols)
	    if !oItPeso:aCols[nX][11]  
		    cSerie    := oItPeso:aCols[nX][Ascan(aHeader3,{|x| AllTrim(x[2]) == "SERIE"})]
			cCodFor   := oItPeso:aCols[nX][Ascan(aHeader3,{|x| AllTrim(x[2]) == "FORNECE"	})]
			cLojaFor  := oItPeso:aCols[nX][Ascan(aHeader3,{|x| AllTrim(x[2]) == "LJFOR"	})]
			cNota     := oItPeso:aCols[nX][Ascan(aHeader3,{|x| AllTrim(x[2]) == "NOTA" 	})]
			//cProduto  := BuscaProd(cNota,cSerie)
			nQtdNf    := oItPeso:aCols[nX][Ascan(aHeader3,{|x| AllTrim(x[2]) == "QUANT"	})]
			nPeso     := oItPeso:aCols[nX][Ascan(aHeader3,{|x| AllTrim(x[2]) == "PESOBAL"	})]
			nImposto  := 0
			nFrete    := 0
		    cContrato := oItPeso:aCols[nX][Ascan(aHeader3,{|x| AllTrim(x[2]) == "CONTRATO"})]
		    cPedido   := oItPeso:aCols[nX][Ascan(aHeader3,{|x| AllTrim(x[2]) == "PEDIDO"})]
		    cItemPed  := oItPeso:aCols[nX][Ascan(aHeader3,{|x| AllTrim(x[2]) == "ITEMPED"})]
		    cItem	  := oItPeso:aCols[nX][Ascan(aHeader3,{|x| AllTrim(x[2]) == "ITEM"})] 
		    if numnf = cNota
	          itnf++
	        endif
		    If !Empty(cPedido) .and. !Empty(cItemPed)
		        cProduto  := BuscaProd(cPedido,cItemPed)
			ElseIf !Empty(cNota) .and.  !Empty(cSerie) .and. !Empty(cCodFor) .and. !Empty(cLojaFor) .and. !Empty(cItem) // RICARDO LIMA - NOTA DE TRANSFERENCIA.
		        cProduto  :=  PrdNfIt(cNota,cSerie,cCodFor,cLojaFor,cItem)	
		    Else
		    	cProduto  := oItNf:aCols[itnf][Ascan(aHeader2,{|x| AllTrim(x[2]) == "PRODUTO"})]
		    EndIf
		    cPrcUni   := BuscaPrcUni(cNota,cSerie,cCodFor,cLojaFor,cProduto,cItem)		    
		    cLocPad   := POSICIONE("SB1",1,XFILIAL("SB1")+cProduto,"B1_LOCPAD")	
			numnf := cNota
		    
			If cVar != 1
				RRPCP001E1(cCodFor,cNota,cProduto,cLocPad,nQtdNf,nTotNf,cSeq,nPeso,cContrato,cPedido,cItemPed,cPrcUni,cSerie,nil,cLojaFor,cItem,nPesOri) //ษverson - 17/11/2015. Adicionada a variแvel cLojaFor e cItem.
			Else 
				_nPeso := oItNf:aCols[oItNf:NAT][5]
				nTotNf := oItNf:aCols[oItNf:NAT][5]
				RRPCP001E1(cCodFor,cNota,cProduto,cLocPad,nQtdNf,nTotNf,cSeq,nPeso,cContrato,cPedido,cItemPed,cPrcUni,cSerie,cVar,cLojaFor) //ษverson - 16/11/2015. Adicionada a variแvel cLojaFor.
				//GrvEntReal(cContrato,cPedido,cItemPed,cProduto,nTotNf)
				Alert("Guia gerada.")	
			EndIf	
			
	    EndIf
	Next nX
EndIf

_nPeso	:=	0
oDlgPes:End()

If cVar != 1
If MsgYesNo("Deseja imprimir a Guia Racao ?",FunName())
	RptStatus({|| RRPCP001E3()},"Imprimindo Guia Racao <Racao> ...")
	EndIf
EndIf

Return(.T.)                                   



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRICOMA06  บAutor  ณMicrosiga           บ Data ณ  08/26/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function BuscaProd(cPedido,cItemPed)
Local cRet := ""
Local cQuery := ""

cQuery := " SELECT SC7.C7_PRODUTO "+ cEOF
cQuery += " FROM "+RetSQLName("SC7") + " SC7 "+ cEOF
cQuery += " WHERE SC7.C7_FILIAL   = '" + xFilial("SC7") + "' " + cEOF
cQuery += " AND SC7.D_E_L_E_T_ = '" + Space(1) + "' " + cEOF
cQuery += " AND SC7.C7_NUM   = '"+cPedido+"' " + cEOF
cQuery += " AND SC7.C7_ITEM = '"+cItemPed+"' " + cEOF
//cQuery += " ORDER BY D1_DOC,D1_SERIE" + cEOF

cQuery := ChangeQuery(cQuery)
DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"qTmp",.T.,.T.)

DbSelectArea("qTmp")
cRet := qTmp->C7_PRODUTO

qTmp->(DbCloseArea())

Return(cRet)    

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ PrdNfIt  บAutor  ณ RICARDO LIMA       บ Data ณ  24/02/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ  BUSCA PRODUTO NA NOTA QUANDO EH TRANSFERENCIA             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ BALANCA                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PrdNfIt(cNota,cSerie,cCodFor,cLojaFor,cItem)
Local cRet := ""
Local cQuery := ""

cQuery := " SELECT * FROM "+RetSQLName("SD1")+" "
cQuery += " WHERE D1_DOC = '"+cNota+"' " 
cQuery += " AND D1_SERIE = '"+cSerie+"' "
cQuery += " AND D1_FORNECE = '"+cCodFor+"' " 
cQuery += " AND D1_LOJA = '"+cLojaFor+"' "
cQuery += " AND D1_ITEM = '"+cItem+"' "
cQuery += " AND D1_FILIAL = '"+xFilial("SD1")+"' "
cQuery += " AND D_E_L_E_T_ = '' " 

TCQUERY cQuery NEW Alias "qSd1"  

DbSelectArea("qSd1")
cRet := qSd1->D1_COD

qSd1->(DbCloseArea())

Return(cRet) 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRICOMA06  บAutor  ณMicrosiga           บ Data ณ  08/26/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function TDBTree(cPlaca,cSeq)
Local cBmp1   := "PMSEDT3"
Local cBmp2   := "PMSDOC"
Local cNivel  := "1"
Local cQuery  := ""
Local cGet1	  := ""
Local cGet2	  := ""
Local cGet3	  := ""
Local cGet4	  := ""
Local cGet5	  := ""
Local aTicket := {}
Local cGet6	  := 0
Local cGet7	  := 0
Local cGet8	  := 0
Local cGet9	  := 0
Local cGetC	  := 0

Private cCadastro := "Notas Relacionadas Na Pesagem"
Private oDlg
Private oDBTree      

DEFINE MSDIALOG oDlg TITLE cCadastro FROM 0,0 TO 240,500 PIXEL

oDBTree := dbTree():New(00,00,105,253,oDlg,,,.T.)

cQuery := " SELECT * "+ cEOF
cQuery += " FROM   "+RetSqlName("ZFE")+" ZFE"+ cEOF
cQuery += " WHERE  ZFE.D_E_L_E_T_ = ''"+ cEOF
cQuery += " AND    ZFE.ZFE_FILIAL = '"+xFilial("ZFE")+"'"+ cEOF
cQuery += " AND    ZFE.ZFE_VEICUL = '"+cPlaca+"'"+ cEOF
cQuery += " AND    ZFE.ZFE_SEQ    = '"+cSeq+"' "+ cEOF
cQuery += " ORDER BY ZFE.ZFE_NF"+ cEOF

cQuery := ChangeQuery(cQuery)
DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"qTmp",.T.,.T.)
	
DbSelectArea("qTmp")
While !qTmp->(Eof())
	aAdd(aTicket,qTmp->ZFE_NUM)
	oDBTree:AddTree("Nota: "+qTmp->ZFE_NF+Space(30),.T.,cBmp1,cBmp1,,,cNivel+".0")
        
		oDBTree:AddTreeItem("Numero Pesagem    : "+qTmp->ZFE_NUM													,cBmp2,,cNivel+".01")
		oDBTree:AddTreeItem("Placa do veiculo  : "+c_cPlaca															,cBmp2,,cNivel+".01")
		oDBTree:AddTreeItem("Fornecedor        : "+qTmp->ZFE_COD_R													,cBmp2,,cNivel+".02")
		oDBTree:AddTreeItem("Nro NF            : "+qTmp->ZFE_NF														,cBmp2,,cNivel+".03")
		oDBTree:AddTreeItem("Codigo do produto : "+qTmp->ZFE_PRODUT													,cBmp2,,cNivel+".04")
		oDBTree:AddTreeItem("Silo destino      : "+qTmp->ZFE_SILO													,cBmp2,,cNivel+".05")
		oDBTree:AddTreeItem("Qtd NF            : "+cValToChar(qTmp->ZFE_QTD_NF)	   							  		,cBmp2,,cNivel+".06")
		oDBTree:AddTreeItem("Pre็o Uni Nf      : "+cValToChar(qTmp->ZFE_PUN_NF )									,cBmp2,,cNivel+".07")
		oDBTree:AddTreeItem("Peso Produto      : "+cValToChar(qTmp->ZFE_PESO_1 - _nPeso)							,cBmp2,,cNivel+".08")
		
	oDBTree:EndTree() 
	cNivel := soma1(cNivel)

	qTmp->(DbSkip())
End 
qTmp->(DbCloseArea())
	
DEFINE SBUTTON FROM 107,190 TYPE 1 ACTION (RRPCP001E2(aTicket),oDlg:End()) ENABLE OF oDlg
DEFINE SBUTTON FROM 107,220 TYPE 2 ACTION (oDlg:End()) ENABLE OF oDlg

ACTIVATE MSDIALOG oDlg CENTER

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRICOMA06  บAutor  ณMicrosiga           บ Data ณ  08/27/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PegaSequencia()
Local cRet   := ""
Local cQuery := ""

cQuery := " SELECT MAX(ZFE_SEQ) AS NUMERO"+ cEOF
cQuery += " from "+RetSqlName("ZFE")+" ZFE"+ cEOF
cQuery += " WHERE ZFE.D_E_L_E_T_ = ''"+ cEOF
cQuery += " AND   ZFE.ZFE_FILIAL = '"+xFilial("ZFE")+"'"+ cEOF

cQuery := ChangeQuery(cQuery)
DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"qTmp",.T.,.T.)

DbSelectArea("qTmp")
cRet := Soma1(qTmp->NUMERO)

qTmp->(DbCloseArea())

Return(cRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRICOMA06  บAutor  ณMicrosiga           บ Data ณ  08/31/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PegaDoc(aDados)
Local cRet   := ""
Local cQuery := ""
Local nX     := 0
Local cNum   := ""

For nX := 1 to Len(aDados)
	cNum += aDados[nX]

	If nX <> Len(aDados)
		cNum += ","
	EndIf	
	 
Next nX                                        

cQuery := " SELECT MAX(ZFE.ZFE_NF) as NF"+cEOF
cQuery += " FROM "+RetSqlName("ZFE")+" ZFE"+cEOF
cQuery += " WHERE ZFE.D_E_L_E_T_ = ''"+cEOF
cQuery += " AND   ZFE.ZFE_FILIAL = '"+xFilial("ZFE")+"'"+cEOF
cQuery += " AND   ZFE.ZFE_NUM IN ("+cNum+")"+cEOF

cQuery := ChangeQuery(cQuery)
DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"qTmp",.T.,.T.)

DbSelectArea("qTmp")
cRet := qTmp->NF

qTmp->(DbCloseArea())

Return(cRet)



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRICOMA06  บAutor  ณMicrosiga           บ Data ณ  09/01/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PegaGuias(cGuia)
Local aRet := {}
Local cQuery := ""
Local nX     := 0

ZFE->(DbSetOrder(1))
ZFE->(DbSeek(xFilial("ZFE")+cGuia))

cQuery := " SELECT ZFE.ZFE_NUM,ZFE.ZFE_NF,ZFE.ZFE_SERIE"+cEOF
cQuery += " FROM "+RetSqlName("ZFE")+" ZFE"+cEOF
cQuery += " WHERE ZFE.D_E_L_E_T_ = ''"+cEOF
cQuery += " AND   ZFE.ZFE_FILIAL = '"+xFilial("ZFE")+"'"+cEOF
cQuery += " AND   ZFE.ZFE_SEQ = '"+ZFE->ZFE_SEQ+"'"+cEOF
cQuery += " ORDER BY ZFE.ZFE_NUM"+cEOF

cQuery := ChangeQuery(cQuery)
DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"qTmp",.T.,.T.)

DbSelectArea("qTmp")
While !qTmp->(Eof())
	aAdd(aRet, {Alltrim(qTmp->ZFE_NUM),Alltrim(qTmp->ZFE_NF),Alltrim(qTmp->ZFE_SERIE)})
    qTmp->(DbSkip())
End    
qTmp->(DbCloseArea())

Return(aRet)
//----------------------------------------------------------------------------------
/*
	ษverson - 20/11/2015.
*/
Static Function PegaSD1(cNumBl) 
	
	//Declara็ใo de variแveis.
	Local cQuery	:= ""
	Local aRet		:= {}
	
	cQuery += " SELECT  " 
	cQuery += " *  " 
	cQuery += " FROM  " 
	cQuery += " " + RetSqlName("SD1") + " SD1 " 
	cQuery += " WHERE " 
	cQuery += " SD1.D_E_L_E_T_ = '' " 
	cQuery += " AND D1_X_SEQBL = '" + Alltrim(cValToChar(cNumBl)) + "' " 
	
	If Select("SD1_DADOS") > 0
		SD1_DADOS->(DbCloseArea())
	EndIf
	
	TcQuery cQuery New Alias "SD1_DADOS"
	DbSelectArea("SD1_DADOS")
	SD1_DADOS->(DbGoTop())
	While !SD1_DADOS->(Eof())
		Aadd(aRet,{SD1_DADOS->D1_QUANT}) //1- Quantidade
		SD1_DADOS->(DbSkip())
	EndDo
	DbCloseArea("SD1_DADOS")
	
return aRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRICOMA06  บAutor  ณMicrosiga           บ Data ณ  09/05/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Seleciona(nLinha,aDados)
Local nX := 0

if aDados[nLinha][1]
	cQuery := " SELECT *"+cEOF
	cQuery += " FROM "+RetSqlName("SD1")+" SD1"+cEOF
	cQuery += " WHERE SD1.D_E_L_E_T_ = ''"+cEOF
	cQuery += " AND   SD1.D1_FILIAL  = '"+xFilial("SD1")+"'"+cEOF
	cQuery += " AND   SD1.D1_DOC     = '"+aDados[nLinha][3]+"'"+cEOF
	cQuery += " AND   SD1.D1_SERIE   = '"+aDados[nLinha][2]+"'"+cEOF
	cQuery += " ORDER BY D1_DOC,D1_SERIE,D1_ITEM"+cEOF
	
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"qTmp",.T.,.T.)
	
	DbSelectArea("qTmp")
	While !qTmp->(Eof())
	aAdd(oItNf:aCols , Array(Len(aHeader1)+1) )
		oItNf:aCols[Len(oItNf:aCols), Len(oItNf:aCols[1]) ] := .F.
		oItNf:aCols[Len(oItNf:aCols),Ascan(aHeader1,{|x| AllTrim(x[2]) == "FORNECE"	})] := qTmp->D1_FORNECE
		oItNf:aCols[Len(oItNf:aCols),Ascan(aHeader1,{|x| AllTrim(x[2]) == "LJFOR"		})] := qTmp->D1_LOJA
		oItNf:aCols[Len(oItNf:aCols),Ascan(aHeader1,{|x| AllTrim(x[2]) == "ITEM"		})] := qTmp->D1_ITEM			
		oItNf:aCols[Len(oItNf:aCols),Ascan(aHeader1,{|x| AllTrim(x[2]) == "PRODUTO"	})] := qTmp->D1_COD
		oItNf:aCols[Len(oItNf:aCols),Ascan(aHeader1,{|x| AllTrim(x[2]) == "QUANT"		})] := qTmp->D1_TOTAL
	    qTmp->(DbSkip())
	End    
	qTmp->(DbCloseArea())
EndIf
	    
oItNf:Refresh()
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMT160WF   บAutor  ณMicrosiga           บ Data ณ  07/15/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Dados(cDoc1,cDoc2,cSerie1,cSerie2,c_cPlaca)
Local cQuery   	:= ""
Local nRegs 	:= 0
Local nNrReg	:= 0
//Local cPlacavc := SUBSTR(c_cPlaca,1,3)+"-"+SUBSTR(c_cPlaca,4,3)

//cQuery := " SELECT SF1.F1_DOC,SF1.F1_SERIE,SF1.F1_VALBRUT,F1_FORNECE,F1_LOJA "+ cEOF
//cQuery += " FROM "+RetSQLName("SF1") + " SF1 "+ cEOF
//Incluido na query a placa do veiculo --> Bruno Rodrigues 12/07/12
cQuery := " SELECT DISTINCT SF1.F1_DOC,SF1.F1_SERIE,SF1.F1_VALBRUT,F1_FORNECE,F1_LOJA, SD1.D1_X_RRPLC " //ษverson - 18/11/2015 - retirado o campo SD1.D1_COD.
cQuery += " FROM "+RetSQLName("SF1") + " SF1 INNER JOIN "+RetSQLName("SD1") + " SD1 ON F1_FILIAL=D1_FILIAL AND F1_DOC=D1_DOC AND F1_SERIE=D1_SERIE AND F1_FORNECE=D1_FORNECE AND D1_X_RRPLC = '" + c_cPlaca + "' "
cQuery += " WHERE SF1.F1_FILIAL   = '" + xFilial("SF1") + "' " + cEOF
cQuery += " AND SF1.D_E_L_E_T_ = '" + Space(1) + "' " + cEOF
cQuery += " AND SF1.F1_DOC >= '" + cDoc1 + "' " + cEOF
cQuery += " AND SF1.F1_DOC <= '" + cDoc2 + "' " + cEOF  
cQuery += " AND SF1.F1_SERIE >= '" + cSerie1 + "' " + cEOF
cQuery += " AND SF1.F1_SERIE <= '" + cSerie2 + "' " + cEOF  
cQuery += " AND D1_X_ZZBAB = 'N' " //ษverson - 18/112015. 
cQuery += " ORDER BY F1_DOC,F1_SERIE" + cEOF
	
	If Select("qTmp") > 0
		qTmp->(DbCloseArea())
	EndIf
	
	TCQUERY cQuery NEW Alias "qTmp"  
	
	IF !EMPTY(qTmp->D1_X_RRPLC)
	  
	  IF SELECT("D1PLC")>0
       D1PLC->(DbCloseArea())
      ENDIF
	
      cQuery := " SELECT DISTINCT SF1.F1_DOC,SF1.F1_SERIE,SF1.F1_VALBRUT,F1_FORNECE,F1_LOJA, SD1.D1_X_RRPLC "
      cQuery += " FROM "+RetSQLName("SF1") + " SF1 INNER JOIN "+RetSQLName("SD1") + " SD1 ON F1_FILIAL=D1_FILIAL AND F1_DOC=D1_DOC AND F1_SERIE=D1_SERIE AND F1_FORNECE=D1_FORNECE "
      cQuery += " WHERE D1_X_RRPLC = '"+qTmp->D1_X_RRPLC+"' "
      cQuery += " AND D1_FORNECE = '"+qTmp->F1_FORNECE+"' "
//      cQuery += " AND D1_COD = '"+qTmp->D1_COD+"' "
      cQuery += " AND D1_X_ZZBAB = 'N' "
      cQuery += " AND D1_FILIAL = '"+xFilial("SF1")+"' "
      cQuery += " AND SF1.D_E_L_E_T_ = '' "
      cQuery += " AND SD1.D_E_L_E_T_ = '' "
      TCQUERY cQuery NEW Alias "D1PLC"
      Count to nRegs
      dbSelectArea("D1PLC")
      dbGotop()    
	ENDIF
	
	//ษverson - 19/11/2015.
	nNrReg := Contar("qTmp","!Eof()")
	If nNrReg == 0
		MsgInfo("Nใo hแ dados a serem exibidos.","Busca Nota Fiscal")
		Return
	EndIf
	//

oNf:aCols := {}

IF nRegs < 2

// RICARDO LIMA = 10/10/2011 - VALIDA SE A NF DE ENTRADA JA FOI APROVADA PELA QUALIDADE, SOH SERAO EXIBIDAS NF LIBERADAS.

DbSelectArea("qTmp")
qTmp->(DbGoTop())
While !qTmp->(Eof())

  cQuery := " SELECT D1_FILIAL, D1_DOC, D1_SERIE, D1_FORNECE, D1_LOJA, D1_LOCAL, B1_COD, B1_TIPOCQ "
  cQuery += " FROM "+RetSQLName("SD1") + " SD1, "+RetSQLName("SB1") + " SB1 " 
  cQuery += " WHERE D1_COD = B1_COD " 
  cQuery += " AND D1_DOC = '"+qTmp->F1_DOC+"' "
  cQuery += " AND D1_SERIE = '"+qTmp->F1_SERIE +"' " 
  cQuery += " AND D1_FORNECE = '"+qTmp->F1_FORNECE+"' "
  cQuery += " AND D1_LOJA = '"+qTmp->F1_LOJA+"' "
  cQuery += " AND D1_FILIAL = '" + xFilial("SD1") + "' "
  cQuery += " AND D1_X_ZZBAB = 'N' " //ษverson - 18/11/2015.
  cQuery += " AND SD1.D_E_L_E_T_ = '' "
  cQuery += " AND SB1.D_E_L_E_T_ = '' "

	TCQUERY cQuery NEW Alias "SD1QLD"  
	
  IF SD1QLD->B1_TIPOCQ = "M" .OR. SD1QLD->D1_LOCAL = "55"

	aAdd(oNf:aCols , Array(Len(aHeader1)+1) )
	oNf:aCols[Len(oNf:aCols), Len(oNf:aCols[1]) ] := .F.
	oNf:aCols[Len(oNf:aCols),Ascan(aHeader1,{|x| AllTrim(x[2]) == "SERIE"	   })] := qTmp->F1_SERIE
	oNf:aCols[Len(oNf:aCols),Ascan(aHeader1,{|x| AllTrim(x[2]) == "NOTAFIS"  })] := qTmp->F1_DOC

  ELSE   

   dbSelectArea("QEK")
   dbSetOrder(10) //QEK_FILIAL, QEK_FORNEC, QEK_LOJFOR, QEK_NTFISC, QEK_SERINF
   IF dbSeek(xFilial("QEK") + qTmp->F1_FORNECE + qTmp->F1_LOJA + qTmp->F1_DOC + qTmp->F1_SERIE )
    IF QEK->QEK_MOVEST = "S" 
      IF QEK->QEK_SITENT = "2" .OR. QEK->QEK_SITENT = "4" .OR. QEK->QEK_SITENT = "5" .OR. QEK->QEK_SITENT = "6"
     
	     aAdd(oNf:aCols , Array(Len(aHeader1)+1) )
	     oNf:aCols[Len(oNf:aCols), Len(oNf:aCols[1]) ] := .F.
	     oNf:aCols[Len(oNf:aCols),Ascan(aHeader1,{|x| AllTrim(x[2]) == "SERIE"	  })] := qTmp->F1_SERIE
	     oNf:aCols[Len(oNf:aCols),Ascan(aHeader1,{|x| AllTrim(x[2]) == "NOTAFIS"  })] := qTmp->F1_DOC
              
      ELSE
        ALERT("O Produto da(s) Nota(s) ainda nใo foram aprovados Pela Qualidade, Consulte a Qualidade.")
      ENDIF
    ELSE
      ALERT("O Produto da(s) Nota(s) ainda nใo foram aprovados Pela Qualidade, Consulte a Qualidade.")
    ENDIF
   ELSE
     ALERT("Nota Fiscal nใo estแ em Analise, Consulte o Setor de Qualidade.")
   ENDIF

  ENDIF

qTmp->(DbSkip())
  SD1QLD->(DbCloseArea())
End 

ELSE

MSGINFO("ATENวรO, Essa Pesagem tem mais de uma nota, NรO Esque็a de selecionar a outra Nota.","ATENวรO")

// RICARDO LIMA = 10/10/2011 - VALIDA SE A NF DE ENTRADA JA FOI APROVADA PELA QUALIDADE, SOH SERAO EXIBIDAS NF LIBERADAS.

DbSelectArea("qTmp") 
 While !D1PLC->(Eof())

  cQuery := " SELECT D1_FILIAL, D1_DOC, D1_SERIE, D1_FORNECE, D1_LOJA, D1_LOCAL, B1_COD, B1_TIPOCQ "
  cQuery += " FROM "+RetSQLName("SD1") + " SD1, "+RetSQLName("SB1") + " SB1 " 
  cQuery += " WHERE D1_COD = B1_COD " 
  cQuery += " AND D1_DOC = '"+D1PLC->F1_DOC+"' "
  cQuery += " AND D1_SERIE = '"+D1PLC->F1_SERIE +"' " 
  cQuery += " AND D1_FORNECE = '"+D1PLC->F1_FORNECE+"' "
  cQuery += " AND D1_LOJA = '"+D1PLC->F1_LOJA+"' "
  cQuery += " AND D1_FILIAL = '" + xFilial("SD1") + "' "
  cQuery += " AND D1_X_ZZBAB = 'N' " //ษverson - 18/11/2015.
  cQuery += " AND SD1.D_E_L_E_T_ = '' "
  cQuery += " AND SB1.D_E_L_E_T_ = '' "

	TCQUERY cQuery NEW Alias "SD1QLD"  
	
  IF SD1QLD->B1_TIPOCQ = "M" .OR. SD1QLD->D1_LOCAL = "60"

	   aAdd(oNf:aCols , Array(Len(aHeader1)+1) )
	   oNf:aCols[Len(oNf:aCols), Len(oNf:aCols[1]) ] := .F.
	   oNf:aCols[Len(oNf:aCols),Ascan(aHeader1,{|x| AllTrim(x[2]) == "SERIE"	  })] := D1PLC->F1_SERIE
	   oNf:aCols[Len(oNf:aCols),Ascan(aHeader1,{|x| AllTrim(x[2]) == "NOTAFIS"  })] := D1PLC->F1_DOC

  ELSE   

   dbSelectArea("QEK")
   dbSetOrder(10) //QEK_FILIAL, QEK_FORNEC, QEK_LOJFOR, QEK_NTFISC, QEK_SERINF
   IF dbSeek(xFilial("QEK") + qTmp->F1_FORNECE + qTmp->F1_LOJA + qTmp->F1_DOC + qTmp->F1_SERIE )
    IF QEK->QEK_MOVEST = "S" 
      IF QEK->QEK_SITENT = "2" .OR. QEK->QEK_SITENT = "4" .OR. QEK->QEK_SITENT = "5" .OR. QEK->QEK_SITENT = "6"
     
	     aAdd(oNf:aCols , Array(Len(aHeader1)+1) )
	     oNf:aCols[Len(oNf:aCols), Len(oNf:aCols[1]) ] := .F.
	     oNf:aCols[Len(oNf:aCols),Ascan(aHeader1,{|x| AllTrim(x[2]) == "SERIE"	  })] := D1PLC->F1_SERIE
	     oNf:aCols[Len(oNf:aCols),Ascan(aHeader1,{|x| AllTrim(x[2]) == "NOTAFIS"  })] := D1PLC->F1_DOC
              
      ELSE
        ALERT("O Produto da(s) Nota(s) ainda nใo foram aprovados Pela Qualidade, Consulte a Qualidade.")
      ENDIF
    ELSE
      ALERT("O Produto da(s) Nota(s) ainda nใo foram aprovados Pela Qualidade, Consulte a Qualidade.")
    ENDIF
   ELSE
     ALERT("Nota Fiscal nใo estแ em Analise, Consulte o Setor de Qualidade.")
   ENDIF

  ENDIF

  D1PLC->(DbSkip())
  SD1QLD->(DbCloseArea())
 End
 
D1PLC->(DbCloseArea())
ENDIF 

qTmp->(DbCloseArea())

	oNf:Refresh()
	
	//ษverson - 17/12/2015.
	If Len(oNf:aCols) == 0
		oItNf:aCols := {}
		oItNf:Refresh()
		oItPeso:aCols:={}
		oItPeso:Refresh()
	EndIf


Return()  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRICOMA06  บAutor  ณMicrosiga           บ Data ณ  08/17/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PreencheDados(nLinha,aDados,cTipo,cNota)
Local nX       := 0
Local cQuery   := ""
Local aPedidos := {}
Local cPedido  := ""
Local cItemPed := ""
   
	If cTipo == "1" 
		
		If Empty(oNf:aCols[1][2]) //ษverson - 19/11/2015.
			Return
		EndIf
		
		oItNf:aCols := {}
		
		cQuery := " SELECT *"+cEOF
		cQuery += " FROM "+RetSqlName("SD1")+" SD1"+cEOF
		cQuery += " WHERE SD1.D_E_L_E_T_ = ''"+cEOF
		cQuery += " AND   SD1.D1_FILIAL = '"+xFilial("SD1")+"'"+cEOF
		cQuery += " AND   SD1.D1_DOC   = '"+aDados[nLinha][2]+"'"+cEOF
		cQuery += " AND   SD1.D1_SERIE = '"+aDados[nLinha][1]+"'"+cEOF
		cQuery += " AND   SD1.D1_X_ZZBAB = 'N' " //ษverson - 18/11/2015.
		cQuery += " ORDER BY D1_DOC,D1_SERIE,D1_ITEM"+cEOF
		
		cQuery := ChangeQuery(cQuery)
		DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"qTmp",.T.,.T.)
		
		DbSelectArea("qTmp")
		While !qTmp->(Eof())

			aAdd(oItNf:aCols , Array(Len(aHeader2)+1) )
			oItNf:aCols[Len(oItNf:aCols), Len(oItNf:aCols[1]) ] := .F.
			oItNf:aCols[Len(oItNf:aCols),Ascan(aHeader2,{|x| AllTrim(x[2]) == "FORNECE"	})] := qTmp->D1_FORNECE
			oItNf:aCols[Len(oItNf:aCols),Ascan(aHeader2,{|x| AllTrim(x[2]) == "LJFOR" 		})] := qTmp->D1_LOJA
			oItNf:aCols[Len(oItNf:aCols),Ascan(aHeader2,{|x| AllTrim(x[2]) == "ITEM"	 	})] := qTmp->D1_ITEM			
			oItNf:aCols[Len(oItNf:aCols),Ascan(aHeader2,{|x| AllTrim(x[2]) == "PRODUTO" 	})] := qTmp->D1_COD
			oItNf:aCols[Len(oItNf:aCols),Ascan(aHeader2,{|x| AllTrim(x[2]) == "QUANT_NF" 	})] := qTmp->D1_QUANT
			oItNf:aCols[Len(oItNf:aCols),Ascan(aHeader2,{|x| AllTrim(x[2]) == "CONTRATO" 	})] := BuscaContrato(qTmp->D1_PEDIDO,qTmp->D1_ITEMPC)
		
		qTmp->(DbSkip())
		End 
		
		qTmp->(DbCloseArea())                   
	Else 
		
		lPode  := .F.
		lAchou := .F.
        For nnnn := 1 to len(aUsados)
        
        	If aUsados[nnnn] == cNota
        		lAchou := .T.
        	Endif		
        
        Next nnnn
        
        If !lAchou
        	lPode := .T.
        ElseIf lAchou 
	        For n1 := 1 to len(oItPeso:aCols)
	        
	        	If oItPeso:aCols[n1][3]+oItPeso:aCols[n1][4]+oItPeso:aCols[n1][5] == cNota
	        		if oItPeso:aCols[n1][11]
	        			lPode := .T.
	        		Else
	        			lPode := .F.
	        		Endif	
	        	Endif		
	        
	        Next nnnn
        	
       		//lPode := .T.
       	Else
       		lPode := .F.	
       	EndIf		
        //Iif(lAchou, lPode := .F.,lPode := .T.)
        
		If lPode
		
			SD1->(DbSetOrder(1))&&D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
			If SD1->(DbSeek(xFilial("SD1")+oNf:aCols[oNf:nat][2]+oNf:aCols[oNf:nat][1]+oItNf:aCols[oItNf:nat][1]+oItNf:aCols[oItNf:nat][2]+oItNf:aCols[oItNf:NAT][4]+oItNf:aCols[oItNf:nat][3]))
				If SD1->D1_X_ZZBAB == "N"
					
					//If Ascan(aUsados,{|x| AllTrim(x[1]) == cNota}) == 0
						aAdd(aUsados,cNota)
					//EndIf
						
		If Empty(oItPeso:aCols[Len(oItPeso:aCols),Ascan(aHeader3,{|x| AllTrim(x[2]) == "NOTA"})]) // 		If Empty(oItPeso:aCols[Len(oItPeso:aCols),Ascan(aHeader3,{|x| AllTrim(x[2]) == "SERIE"})])
			aPedidos := PegaPedido(oNf:aCols[oNf:nat][2],oNf:aCols[oNf:nat][1],aDados[nLinha][1],aDados[nLinha][2],aDados[nLinha][4],aDados[nLinha][3])
			cPedido  := aPedidos[1]
			cItemPed := aPedidos[2]
			
			oItPeso:aCols[Len(oItPeso:aCols), Len(oItPeso:aCols[1]) ] := .F.
			oItPeso:aCols[Len(oItPeso:aCols),Ascan(aHeader3,{|x| AllTrim(x[2]) == "SERIE"	 	})] := oNf:aCols[oNf:nat][1]
			oItPeso:aCols[Len(oItPeso:aCols),Ascan(aHeader3,{|x| AllTrim(x[2]) == "NOTA"		})] := oNf:aCols[oNf:nat][2]
			oItPeso:aCols[Len(oItPeso:aCols),Ascan(aHeader3,{|x| AllTrim(x[2]) == "ITEM"		})] := aDados[nLinha][3]
			oItPeso:aCols[Len(oItPeso:aCols),Ascan(aHeader3,{|x| AllTrim(x[2]) == "QUANT"		})] := aDados[nLinha][5]
			oItPeso:aCols[Len(oItPeso:aCols),Ascan(aHeader3,{|x| AllTrim(x[2]) == "FORNECE"	})] := aDados[nLinha][1]
			oItPeso:aCols[Len(oItPeso:aCols),Ascan(aHeader3,{|x| AllTrim(x[2]) == "LJFOR"		})] := aDados[nLinha][2]
			oItPeso:aCols[Len(oItPeso:aCols),Ascan(aHeader3,{|x| AllTrim(x[2]) == "PESOBAL"	})] := _nPeso
			oItPeso:aCols[Len(oItPeso:aCols),Ascan(aHeader3,{|x| AllTrim(x[2]) == "CONTRATO"	})] := aDados[nLinha][6] 
			oItPeso:aCols[Len(oItPeso:aCols),Ascan(aHeader3,{|x| AllTrim(x[2]) == "PEDIDO"		})] := cPedido
			oItPeso:aCols[Len(oItPeso:aCols),Ascan(aHeader3,{|x| AllTrim(x[2]) == "ITEMPED"	})] := cItemPed
			
		Else
			aPedidos := PegaPedido(oNf:aCols[oNf:nat][2],oNf:aCols[oNf:nat][1],aDados[nLinha][1],aDados[nLinha][2],aDados[nLinha][4],aDados[nLinha][3])
			cPedido  := aPedidos[1]
			cItemPed := aPedidos[2]

			            //If Len(oItPeso:aCols) > 1
							If Ascan(oItPeso:aCols,{|x| AllTrim(x[2]) == cItemPed}) == 0
							//If oItPeso:aCols[Len(oItPeso:aCols),Ascan(aHeader3,{|x| AllTrim(x[2]) == "ITEM"})] != oItPeso:aCols[Len(oItPeso:aCols)-1,Ascan(aHeader3,{|x| AllTrim(x[2]) == "ITEM"})]
			aAdd(oItPeso:aCols , Array(Len(aHeader3)+1) )
			oItPeso:aCols[Len(oItPeso:aCols), Len(oItPeso:aCols[1]) ] := .F.
			oItPeso:aCols[Len(oItPeso:aCols),Ascan(aHeader3,{|x| AllTrim(x[2]) == "SERIE"	 	})] := oNf:aCols[oNf:nat][1]
			oItPeso:aCols[Len(oItPeso:aCols),Ascan(aHeader3,{|x| AllTrim(x[2]) == "NOTA"		})] := oNf:aCols[oNf:nat][2] 
			oItPeso:aCols[Len(oItPeso:aCols),Ascan(aHeader3,{|x| AllTrim(x[2]) == "ITEM"		})] := aDados[nLinha][3]
			oItPeso:aCols[Len(oItPeso:aCols),Ascan(aHeader3,{|x| AllTrim(x[2]) == "QUANT"		})] := aDados[nLinha][5]
			oItPeso:aCols[Len(oItPeso:aCols),Ascan(aHeader3,{|x| AllTrim(x[2]) == "FORNECE"	})] := aDados[nLinha][1]
			oItPeso:aCols[Len(oItPeso:aCols),Ascan(aHeader3,{|x| AllTrim(x[2]) == "LJFOR"		})] := aDados[nLinha][2]
			oItPeso:aCols[Len(oItPeso:aCols),Ascan(aHeader3,{|x| AllTrim(x[2]) == "PESOBAL"	})] := _nPeso  
			oItPeso:aCols[Len(oItPeso:aCols),Ascan(aHeader3,{|x| AllTrim(x[2]) == "CONTRATO"	})] := aDados[nLinha][6]
			oItPeso:aCols[Len(oItPeso:aCols),Ascan(aHeader3,{|x| AllTrim(x[2]) == "PEDIDO"	})] := cPedido
			oItPeso:aCols[Len(oItPeso:aCols),Ascan(aHeader3,{|x| AllTrim(x[2]) == "ITEMPED"	})] := cItemPed
		EndIf	
						//EndIf	
					EndIf
						
				Else
					Alert("Esse produto ja foi usado anteriormente na balan็a, nao pode ser feito novamente.")	
				EndIf
			EndIf		
		EndIf	
    EndIf
    
oItPeso:Refresh()
oItNf:Refresh()
Return(.T.)                               



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRICOMA06  บAutor  ณMicrosiga           บ Data ณ  09/09/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GrvEntReal(cContra,cPedCom,cItemPed,cProduto,nQuant,cNumGuia)

RecLock("SZ9",.T.)
	SZ9->Z9_FILIAL  := xFilial("SZ9")
	SZ9->Z9_NUMCON  := cContra
	SZ9->Z9_PEDCOM  := cPedCom
	SZ9->Z9_ITEMPED := cItemPed
	SZ9->Z9_PRODUTO := cProduto
	SZ9->Z9_DTREAL  := dDataBase
	SZ9->Z9_QUANT   := nQuant
	SZ9->Z9_TIPO    := "R"
	SZ9->Z9_ULTREV  := "*"
	SZ9->Z9_NUMGUIA := cNumGuia
SZ9->(MsUnLock())

// verifica estatus do contrato

Return()
            


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRICOMA06  บAutor  ณMicrosiga           บ Data ณ  09/09/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function BuscaContrato(cPedido,cItemPed)
Local cRet := ""

	SC7->(DbSetOrder(1))
	If SC7->(Dbseek(xFilial("SC7")+cPedido+cItemPed))
		cRet := SC7->C7_X_CTFV //ษverson - 16/11/2015 substituido C7_ZFEUMCO por C7_X_CTFV.
	EndIf

Return(cRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRICOMA06  บAutor  ณMicrosiga           บ Data ณ  09/09/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PegaPedido(cDoc,cSerie,cForn,cLoja,cProd,cItem)
Local aRet := {}

	SD1->(DbSetOrder(1))
	If SD1->(Dbseek(xFilial("SD1")+cDoc+cSerie+cForn+cLoja+cProd+cItem))
		aAdd(aRet, SD1->D1_PEDIDO)
		aAdd(aRet, SD1->D1_ITEMPC)		
	EndIf

Return(aRet)



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRICOMA06  บAutor  ณMicrosiga           บ Data ณ  09/10/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function BuscaPrcUni(cDoc,cSerie,cForn,cLoja,cProduto,cItem)
Local nRet   := 0
Local cQuery := ""

SD1->(dbSetorder(1))
IF SD1->(Dbseek(xFilial("SD1")+cDoc+cSerie+cForn+cLoja+cProduto+cItem))
	nRet := SD1->D1_VUNIT
EndIf

Return(nRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRICOMA06  บAutor  ณMicrosiga           บ Data ณ  09/14/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function QuantNf(aDados)
cQuery := ""
nVal   := 0

For nX := 1 To Len(aDados)

	ZFE->(DbSetOrder(1))
	IF ZFE->(DbSeek(xFilial("ZFE")+aDados[nX][1]))
	
		cQuery := "SELECT SUM(SD1.D1_QUANT) AS D1_QUANT"+cEOF
		cQuery += "FROM "+RetSqlName("SD1")+" SD1"+cEOF
		cQuery += "WHERE SD1.D_E_L_E_T_ = ''"+cEOF
		cQuery += "AND   SD1.D1_DOC = "+ZFE->ZFE_NF+""+cEOF
		cQuery += "AND   SD1.D1_SERIE = '"+ZFE->ZFE_SERIE+"'+cEOF"+cEOF
				
		cQuery := ChangeQuery(cQuery)
		DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"qTmp",.T.,.T.)
		
		DbSelectArea("qTmp")
		nVal += qTmp->D1_QUANT
		qTmp->(DbCloseArea())                          
	EndIf
	
Next nX    
 
cVal := Alltrim(Str(nVal))

Return(cVal)




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHHR207    บAutor  ณMicrosiga           บ Data ณ  16/03/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
STATIC FUNCTION RRPCP001T() &&alterado por rodrigo sanches 16/03/2001
//STATIC FUNCTION HHR207E

Local cGet1	 := Space(08)	//placa
Local cGet2	 := Space(06)
Local cGet3	 := Space(10)
Local cGet4	 := Space(15)
Local cGet5	 := Space(02)

//Local cGet6	 := 0 &&alterado por rodrigo sanches 16/03/2011
//Local cGet8	 := 0 &&alterado por rodrigo sanches 16/03/2011
Local cGet9	 := 0
Local cGetC	 := 0
Local oGet1
Local oGet2
Local oGet3
Local oGet4
Local oGet5
Local oGet6
Local oGet7
Local oGet8
Local oGet9

Private cGet6	 := 0   && adicionado por rodrigo sahcnes 16/03/2011
Private cGet8    := _nPeso

cGetA	:=	space(40)
cGetB	:=	space(50)
cGet7	 := 0

_nPeso := 1
PEGAPLACA2()

if !empty(c_cPlaca)
	dbSelectArea("ZFE")
	dbSetOrder(2)
	dbSeek(xFilial("ZFE")+c_cPlaca+"ZZZZZZZ",.T.)
	dbSkip(-1)
	//if	(c_cPlaca == ZFE->ZFE_VEICUL .and. 	ZFE->ZFE_PESO_1 > 0 .and. ZFE->ZFE_PESO_T >0) .or. c_cPlaca <> ZFE->ZFE_VEICUL //abre uma nova guia
		Private _oInsumo
		Private VISUAL := .F.
		Private INCLUI := .F.
		Private ALTERA := .F.
		Private DELETA := .F.
		cGet1	:=	c_cPlaca
		
		PrimeiroPeso(c_cPlaca,1) && adicionado por Rodrigo Sanches 16/03/2011
	//endif
endif
return
//----------------------------------------------------------------------------------
/*
	ษverson - 09/12/2015.
*/
Static Function pegaLote(cCodProg)
	
	//Declara็ใo de variแveis.
	Local aArea	:= GetArea()
	Local cRet	:= ""
	
	cRet := Alltrim(cValToChar(Posicione("ZFF",1,xFilial("ZFF")+cCodProg+"001","ZFF_BPCOD")))
	RestArea(aArea)
	
Return cRet	
//----------------------------------------------------------------------------------
/*
	ษverson - 22/12/2015.
*/
Static Function pegaGalpao(cCodProg)
	
	//Declara็ใo de variแveis.
	Local aArea	:= GetArea()
	Local cRet	:= ""
	
	cRet := Alltrim(cValToChar(Posicione("ZFF",1,xFilial("ZFF")+cCodProg+"001","ZFF_GALPAO")))

	RestArea(aArea)
	
Return cRet