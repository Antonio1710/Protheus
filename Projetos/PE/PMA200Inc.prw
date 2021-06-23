#include "protheus.ch"
#include "topconn.ch"

Static cNovoVl	:= "" //Everson - 25/01/2018, chamado 046699.
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PMA200INC �Autor  �Fernando Macieira   � Data �  02/13/18   ���
�������������������������������������������������������������������������͹��
���Desc.     � Funcao para gerar o proximo codigo do projeto              ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Adoro                                                      ���
���versionamento:														  ���
���Everson - 25/01/2018, chamado 046699. Tratamento para fechar a janela  ���
���ao clicar no bot�o cancelar.											  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function PMA200Inc()

	//���������������������������������������������������������������������Ŀ
	//� Declara��o de vari�veis.
	//�����������������������������������������������������������������������
	Local aArea		:= GetArea()	
	Local lOKPrj  	:= .F.
	Local lSair		:= .F.
	
	Local oCmpPrj  := Array(01)
	Local oBtnPrj  := Array(02)
	Local cTpPrj   := Space(02)
	
	//
	DEFINE MSDIALOG oDlgPrj TITLE "Tipo Projeto" FROM 0,0 TO 100,350  OF oMainWnd PIXEL
	
		@ 003, 003 TO 050,165 PIXEL OF oDlgPrj
		
		@ 010,020 Say "Tp. Projeto:" of oDlgPrj PIXEL
		@ 005,060 MsGet oCmpPrj Var cTpPrj SIZE 70,12 of oDlgPrj PIXEL Valid ( Iif(!Empty(cTPPrj),ExistCpo("SX5","_M"+cTpPrj),.T.) ) F3 '_M' //Everson - 25/01/2018, chamado 046699.
		
		@ 030,015 BUTTON oBtnPrj[01] PROMPT "Confirma"     of oDlgPrj   SIZE 68,12 PIXEL ACTION (lOKPrj := nvCodigo(cTPPrj), oDlgPrj:End()) //Everson - 25/01/2018, chamado 046699.
		@ 030,089 BUTTON oBtnPrj[02] PROMPT "Cancela"      of oDlgPrj   SIZE 68,12 PIXEL ACTION (lSair  := .T., lOKPrj := .T., oDlgPrj:End()) //Everson - 25/01/2018, chamado 046699.
		
	ACTIVATE MSDIALOG oDlgPrj CENTERED

	//
	RestArea(aArea)
	
Return lOKPrj
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PMA200INC �Autor  �Fernando Macieira   � Data �  02/13/18   ���
�������������������������������������������������������������������������͹��
���Desc.     � Funcao para gerar o proximo codigo do projeto              ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Adoro                                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function nvCodigo(cTPPrj)

	//���������������������������������������������������������������������Ŀ
	//� Declara��o de vari�veis.
	//�����������������������������������������������������������������������
	Local aArea		:= GetArea()
	
	//
	If Empty(cTPPrj)
		MsgStop("Tp. Projeto vazio.","Fun��o PMA200Inc")
		RestArea(aArea)
		Return .T.
		
	EndIf
	
	// Gera c�digo automaticamente conf. regra
	// 	- C�digo do projeto ser�: Unidade (02) + Ano (02) + Tipo Projeto (02) + Sequencial (04)
	cNovoVl := GeraCodAF8(cTPPrj)
	
	Aviso(	"PMA200INC-01",;
	"Projeto inclu�do com c�digo " + cNovoVl,;
	{ "&OK" },,;
	"C�digo do Projeto: " + cNovoVl )
	
	//
	RestArea(aArea)

Return .F.
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PMA200INC �Autor  �Microsiga           � Data �  02/13/18   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function GeraCodAF8(cTPPrj)

	//���������������������������������������������������������������������Ŀ
	//� Declara��o de vari�veis.
	//�����������������������������������������������������������������������
	Local cQuery   := ""
	Local cNextCod := ""
	
	Local cUnidade := cFilAnt
	Local cAno     := Str(Year(msDate())-2000, 2)
	Local cSeq     := "001" // 28/03/2018 - Conf. diretriz equipe TI 
	//Local cSeq     := "0001"
	
	If Select("Work") > 0
		Work->( dbCloseArea() )
	EndIf
	
	cQuery := " SELECT TOP 1 AF8_PROJET, AF8_DESCRI "
	cQuery += " FROM " + RetSqlName("AF8")
	cQuery += " WHERE AF8_FILIAL='"+xFilial("AF8")+"' "
	cQuery += " AND AF8_PROJET LIKE '"+cUnidade+cAno+cTPPrj+"%' "
	cQuery += " AND D_E_L_E_T_='' "
	cQuery += " ORDER BY AF8_PROJET DESC "
	
	tcQuery cQuery New Alias "Work"
	
	Work->( dbGoTop() )
	
	If Work->( !EOF() )
		cNextCod := Soma1(AllTrim(Work->AF8_PROJET))
		
	Else
		cNextCod := cUnidade+cAno+cTPPrj+cSeq
		
	EndIf
	
	If Select("Work") > 0
		Work->( dbCloseArea() )
	EndIf

Return cNextCod
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �getNvPrj  �Autor  �Everson             � Data �  25/01/19   ���
�������������������������������������������������������������������������͹��
���Desc.     �Fun��o utilizada no inicializador padr�o do campo AF8_PROJET���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �Chamado 046699.                                             ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function PMANvPrj() //U_PMANvPrj()
Return cNovoVl