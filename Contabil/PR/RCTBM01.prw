#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "JPEG.CH"

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �teste     � Autor � Fernando Macieira     � Data �12/01/2009���
�������������������������������������������������������������������������Ĵ��
���Locacao   �                  �Contato �                                ���
�������������������������������������������������������������������������Ĵ��
���Descricao �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Aplicacao �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Uso       �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Analista Resp.�  Data  � Bops � Manutencao Efetuada                    ���
�������������������������������������������������������������������������Ĵ��
���              �  /  /  �      �                                        ���
���              �  /  /  �      �                                        ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/

User Function RCTBM01()

Local lConfirma := .f.

//Variaveis Locais da Funcao
Local cCod  	 := CriaVar( "CTS_CODPLA", .f. )
Local cCodDe	 := CriaVar( "CTS_CODPLA", .f. )
Local cCodAte	 := CriaVar( "CTS_CODPLA", .f. )
Local oEdit1
Local oEdit2
Local oEdit3

// Variaveis da Funcao de Controle e GertArea/RestArea
Local _aArea   		:= {}
Local _aAlias  		:= {}     

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

// Variaveis Private da Funcao
Private _oDlg				// Dialog Principal
Private INCLUI := .F.	// (na Enchoice) .T. Traz registro para Inclusao / .F. Traz registro para Alteracao/Visualizacao

DEFINE MSDIALOG _oDlg TITLE OemtoAnsi("Inclusao em lote das Visoes Gerenciais") FROM C(178),C(181) TO C(460),C(727) PIXEL

// Defina aqui a chamada dos Aliases para o GetArea
CtrlArea(1,@_aArea,@_aAlias,{"CTS","CTN"}) // GetArea

// Cria as Groups do Sistema
@ C(068),C(007) TO C(072),C(266) LABEL "" PIXEL OF _oDlg

// Cria Componentes Padroes do Sistema
@ C(013),C(047) Say "Este programa tem como objetivo REPLICAR as Vis�es Gerenciais existentes." Size C(173),C(008) COLOR CLR_BLACK PIXEL OF _oDlg
@ C(048),C(094) MsGet oEdit1 Var cCod F3 "CTS" Size C(016),C(011) COLOR CLR_BLACK Valid ( !Empty(cCod) .and. M01Check(cCod) ) PIXEL OF _oDlg
@ C(049),C(013) Say "Vis�o Gerencial a ser copiada:" Size C(074),C(008) COLOR CLR_BLUE PIXEL OF _oDlg
@ C(081),C(163) MsGet oEdit3 Var cCodDe Size C(016),C(011) COLOR CLR_BLACK Picture "999" Valid ( !Empty(cCodDe) .and. M01NotExist(cCodDe) ) PIXEL OF _oDlg
@ C(080),C(246) MsGet oEdit2 Var cCodAte Size C(016),C(011) COLOR CLR_BLACK Picture "999" Valid ( !Empty(cCodAte) .and. M01NotExist(cCodAte) ) PIXEL OF _oDlg
@ C(083),C(129) Say "C�digo de:" Size C(027),C(008) COLOR CLR_BLACK PIXEL OF _oDlg
@ C(082),C(207) Say "C�digo at�:" Size C(029),C(008) COLOR CLR_BLACK PIXEL OF _oDlg
@ C(114),C(095) Button OemtoAnsi("&Confirma") Size C(037),C(012) PIXEL OF _oDlg Action( lConfirma := .t., _oDlg:End() )
@ C(114),C(155) Button OemtoAnsi("&Sair") Size C(037),C(012) PIXEL OF _oDlg Action( _oDlg:End() )

CtrlArea(2,_aArea,_aAlias) // RestArea

ACTIVATE MSDIALOG _oDlg CENTERED

If lConfirma
	If msgYesNo("Confirma o in�cio das R�plicas?")
		Processa( { || M01Run(cCod, cCodDe, cCodAte) } )
	EndIf
EndIf

Return(.T.)

/*������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������Ŀ��
���Programa   �   C()      � Autor � Norbert Waage Junior  � Data �10/05/2005���
����������������������������������������������������������������������������Ĵ��
���Descricao  � Funcao responsavel por manter o Layout independente da       ���
���           � resolu��o horizontal do Monitor do Usuario.                  ���
�����������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������
������������������������������������������������������������������������������*/
Static Function C(nTam)

Local nHRes	:=	oMainWnd:nClientWidth	//Resolucao horizontal do monitor
Do Case
	Case nHRes == 640	//Resolucao 640x480
		nTam *= 0.8
	Case nHRes == 800	//Resolucao 800x600
		nTam *= 1
	OtherWise			//Resolucao 1024x768 e acima
		nTam *= 1.28
EndCase
If "MP8" $ oApp:cVersion
	//���������������������������Ŀ
	//�Tratamento para tema "Flat"�
	//�����������������������������
	If (Alltrim(GetTheme()) == "FLAT").Or. SetMdiChild()
		nTam *= 0.90
	EndIf
EndIf
Return Int(nTam)

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � CtrlArea � Autor �                    � Data �             ���
�������������������������������������������������������������������������͹��
���Locacao   � Fab.Tradicional  �Contato �                                ���
�������������������������������������������������������������������������͹��
���Descricao � Static Function auxiliar no GetArea e ResArea retornando   ���
���          � o ponteiro nos Aliases descritos na chamada da Funcao.     ���
���          � Exemplo:                                                   ���
���          � Local _aArea  := {} // Array que contera o GetArea         ���
���          � Local _aAlias := {} // Array que contera o                 ���
���          �                     // Alias(), IndexOrd(), Recno()        ���
���          �                                                            ���
���          � // Chama a Funcao como GetArea                             ���
���          � P_CtrlArea(1,@_aArea,@_aAlias,{"SL1","SL2","SL4"})         ���
���          �                                                            ���
���          � // Chama a Funcao como RestArea                            ���
���          � P_CtrlArea(2,_aArea,_aAlias)                               ���
�������������������������������������������������������������������������͹��
���Parametros� nTipo   = 1=GetArea / 2=RestArea                           ���
���          � _aArea  = Array passado por referencia que contera GetArea ���
���          � _aAlias = Array passado por referencia que contera         ���
���          �           {Alias(), IndexOrd(), Recno()}                   ���
���          � _aArqs  = Array com Aliases que se deseja Salvar o GetArea ���
�������������������������������������������������������������������������͹��
���Aplicacao � Generica.                                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/

Static Function CtrlArea(_nTipo,_aArea,_aAlias,_aArqs)

Local _nN

// Tipo 1 = GetArea()
If _nTipo == 1
	_aArea   := GetArea()
	For _nN  := 1 To Len(_aArqs)
		DbSelectArea(_aArqs[_nN])
		AAdd(_aAlias,{ Alias(), IndexOrd(), Recno()})
	Next
	// Tipo 2 = RestArea()
Else
	For _nN := 1 To Len(_aAlias)
		DbSelectArea(_aAlias[_nN,1])
		DbSetOrder(_aAlias[_nN,2])
		DbGoto(_aAlias[_nN,3])
	Next
	RestArea(_aArea)
Endif

Return Nil


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �RCTBM01   �Autor  �Microsiga           � Data �  01/12/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function M01Run(cCod, cCodDe, cCodAte)

Local cQuery  := ""
Local cAlias  := GetNextAlias()
Local nCodDe  := Val(cCodDe)
Local nCodAte := Val(cCodAte)

If M01Checa( cCodDe, cCodAte )
	cQuery := " SELECT * "
	cQuery += " FROM " +RetSqlName("CTS")
	cQuery += " WHERE CTS_FILIAL='"+xFilial("CTS")+"' "
	cQuery += " AND CTS_CODPLA='"+cCod+"' "
	cQuery += " AND D_E_L_E_T_=' ' "
	tcQuery cQuery New Alias (cAlias)
	
	ProcRegua(0)
	
	CTS->( dbSetOrder(1) ) // CTS_FILIAL+CTS_CODPLA+CTS_ORDEM+CTS_LINHA
	CTN->( dbSetOrder(1) ) // CTN_FILIAL+CTN_CODIGO
	
	(cAlias)->( dbGoTop() )
	
	For i:=nCodDe to nCodAte
		cVisao := AllTrim( StrZero(i,3) )
		Do While (cAlias)->( !EOF() )
			IncProc( "Incluindo... " + cVisao + " / " + (cAlias)->(CTS_ORDEM+CTS_LINHA) + " - " + (cAlias)->CTS_DESCCG )
			
			If CTS->( dbSeek( xFilial("CTS")+cVisao+(cAlias)->(CTS_ORDEM+CTS_LINHA) ) )
				Aviso(	"RCTBM01-04",;
				"Visao Gerencial ja cadastrada! Esta rotina ser� abortada...",;
				{"&Ok"},,;
				"Codigo Duplicado: " +cCod )
				Return
			Else
				// Popula CTS
				RecLock("CTS", .t.)
				
				For i2:=1 to (cAlias)->( fCount() )
					cNomCpo := (cAlias)->( FieldName( i2 ) )
					If AllTrim(cNomCpo) == "CTS_CODPLA"
						cVlrCpo := cVisao
					Else
						cVlrCpo := (cAlias)->( FieldGet( FieldPos( cNomCpo ) ) )
					EndIf
					CTS->( FieldPut( FieldPos( cNomCpo ), cVlrCpo ) )
				Next i2
				
				CTS->( msUnLock() )
				
				(cAlias)->( dbSkip() )
			EndIf
		EndDo
		
		// Popula CTN
		If CTN->( dbSeek( xFilial("CTN",1,xFilial("CTN")+cVisao) )	)
			
			RecLock("CTN", .t.)
			
			CTN_FILIAL := xFilial("CTN")
			CTN_CODIGO := cVisao
			CTN_PLAGER := cVisao
			CTN_DESC   := "VISAO REPLICADA PELA ROTINA AUTOMATICA"
			
			CTN->( msUnLock() )
			
		Else
			msgInfo("Configuracao Livro: (" +cVisao+ " ) ja cadastrada!!!")
			
		EndIf
		
		(cAlias)->( dbGoTop() )
	Next i
EndIf

(cAlias)->( dbCloseArea() )

msgInfo("Processamento concluido com sucesso!")

Return


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �RCTBM01   �Autor  �Microsiga           � Data �  01/12/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function M01Check(cCod)

Local lRet := .t.

CTS->( dbSetOrder(1) ) // CTS_FILIAL+CTS_CODPLA+CTS_ORDEM+CTS_LINHA
If CTS->( !dbSeek( xFilial("CTS")+cCod ) )
	lRet := .f.
	Aviso(	"RCTBM01-01",;
	"Visao Gerencial nao cadastrada! Verifique...",;
	{"&Ok"},,;
	"Codigo Invalido: " +cCod )
EndIf

Return lRet


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �RCTBM01   �Autor  �Microsiga           � Data �  01/12/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function M01NotExist(cCod)

Local lRet := .t.

CTS->( dbSetOrder(1) ) // CTS_FILIAL+CTS_CODPLA+CTS_ORDEM+CTS_LINHA
If CTS->( dbSeek( xFilial("CTS")+cCod ) )
	lRet := .f.
	Aviso(	"RCTBM01-02",;
	"Visao Gerencial ja cadastrada! Verifique...",;
	{"&Ok"},,;
	"Codigo Duplicado: " +cCod )
EndIf

Return lRet


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �RCTBM01   �Autor  �Microsiga           � Data �  02/09/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function M01Checa( cCodDe, cCodAte )

Local lRet := .t.
Local cQuery := ""
Local cAlias := GetNextAlias()

cQuery := " SELECT COUNT(1) TT_VIS "
cQuery += " FROM " +RetSqlName("CTS")
cQuery += " WHERE CTS_FILIAL='"+xFilial("CTS")+"' "
cQuery += " AND CTS_CODPLA BETWEEN '"+cCodDe+"' AND '"+cCodAte+"' "
cQuery += " AND D_E_L_E_T_=' ' " 
tcQuery cQuery New Alias (cAlias)

If (cAlias)->TT_VIS > 0
	lRet := .f.
	Aviso(	"RCTBM01-03",;
	"Existem Visoes Gerenciais ja cadastradas neste intervalo! Verifique...",;
	{"&Ok"},,;
	"Intervalo de: " +cCodDe+ " at�: " +cCodAte )
EndIf

(cAlias)->( dbCloseArea() )

Return lRet
