#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � RASXBNEW �Autor  �Davi Jesus          � Data � 27/08/07    ���
�������������������������������������������������������������������������͹��
���Desc.     � Pesquisa SXB customizada para exibir o cadastro de funcio- ���
���          � narios sem as informacoes confidenciais                    ���
�������������������������������������������������������������������������͹��
���Uso       � MP8                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

USER Function RASXBNEW()

Local lRet	:= .F.

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Pesquisa SXB customizada para exibir o cadastro de funcionarios sem as informacoes confidenciais')

lRet := u_RASXBC()

Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � RASXBC   �Autor  �Davi Jesus          � Data �  26/08/07   ���
�������������������������������������������������������������������������͹��
���Desc.     � Pesquisa SXB customizada para exibir o cadastro de funcio- ���
���          � narios sem as informacoes confidenciais                    ���
�������������������������������������������������������������������������͹��
���Uso       � Adoro S.A.                                                 ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
user Function RASXBC()

Local oDlg, oBtOk, oBtCancel, oOrder, oChave, oSelect
Local nOpc		 := 0
Local cOrder	 := "Matr�cula"
Local cChave	 := PadR( &( ReadVar() ), TamSX3("RA_NOME")[1] )
Local aOrders	 := {"Matr�cula", "Centro de Custo", "Nome"}
Local aCpoBrw	 := {}
Local cFilter	 := ""
Local cTitle	 := "Sele��o de Funcion�rio"
Local cCampo     := ""
Local cChavePesq := ""
Local aMatPrf    := {}
Local nInd       := 0

U_ADINF009P('RASXBNEW' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Pesquisa SXB customizada para exibir o cadastro de funcionarios sem as informacoes confidenciais')
                                                                 
SRA->( dbSetOrder(1) )

SRA->( dbGoTop() )

SX3->( dbSetOrder(2) )
SX3->( dbSeek( "RA_MAT" ) )
aAdd( aCpoBrw, { RTrim( SX3->X3_CAMPO ),, X3Titulo(), Rtrim( SX3->X3_PICTURE ) } )

SX3->( dbSeek( "RA_NOME" ) )
aAdd( aCpoBrw, { RTrim( SX3->X3_CAMPO ),, X3Titulo(), Rtrim( SX3->X3_PICTURE ) } )

SX3->( dbSeek( "RA_CC" ) )
aAdd( aCpoBrw, { RTrim( SX3->X3_CAMPO ),, X3Titulo(), Rtrim( SX3->X3_PICTURE ) } )

SX3->( dbSeek( "RA_SITFOLH" ) )
aAdd( aCpoBrw, { RTrim( SX3->X3_CAMPO ),, X3Titulo(), Rtrim( SX3->X3_PICTURE ) } )

SX3->( dbSeek( "RA_ENDEREC" ) )
aAdd( aCpoBrw, { RTrim( SX3->X3_CAMPO ),, X3Titulo(), Rtrim( SX3->X3_PICTURE ) } )

define msDialog oDlg title cTitle from 000,000 to 300,400 pixel

oSelect := MsSelect():New("SRA",,,aCpoBrw,,,{ 003, 003, 117, 166 },,,oDlg)
oSelect:bAval := {|| nOpc := 1, oDlg:End() }
oSelect:oBrowse:Refresh()

@ 125,004 SAY "Ordenar por:" size 40,08 of oDlg pixel
@ 125,042 combobox oOrder var cOrder items aOrders size 125,08 of oDlg pixel valid ( SRA->( dbSetOrder( oOrder:nAt ) ), oSelect:oBrowse:Refresh(), .T. )
@ 137,004 SAY "Localizar:" size 40,08 of oDlg pixel
@ 137,042 GET oChave var cChave size 125,08 of oDlg pixel valid ( SRA->( dbSeek( xFilial("SRA")+RTrim( cChave ), .T. ) ), oSelect:oBrowse:Refresh(), .T. )
define sbutton oBtOk     from 003,170 type 1 enable action ( nOpc := 1, oDlg:End() ) of oDlg pixel
define sbutton oBtCancel from 017,170 type 2 enable action ( nOpc := 0, oDlg:End() ) of oDlg pixel

activate msDialog oDlg centered

if nOpc == 1
	cChave := SRA->RA_MAT
endif

SRA->( dbSetOrder(1) )
SRA->( dbSeek( xFilial("SRA")+cChave ) )

Return .T.