#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*��������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � ADOA004  � Autor � Microsiga             � Data � 22/07/09 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Cadastro de Motivos.                                       ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Adoro - Cadastro espelho de ciente e aprovacao de credito  ���
�������������������������������������������������������������������������Ĵ��
���Analista  � Data/Bops/Ver �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �        �      �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/

User Function ADOA004()

Local aArea			:= GetArea()

Private cCadastro	:= "Cadastro de Motivos"
Private cString		:= "PB4"
Private aRotina		:=	{	{"Pesquisar"	,"AxPesqui"							,0,1} ,;
							{"Visualizar"	,"AxVisual(cString, RecNo(), 2)"	,0,2} ,;
							{"Incluir"		,"u_ADOACRUD(cString, RecNo(), 3)"	,0,3} ,;
							{"Alterar"		,"u_ADOACRUD(cString, RecNo(), 4)"	,0,4} ,;
							{"Excluir"		,"u_ADOA4EXC(cString, RecNo(), 5)"	,0,5} }

//							{"Incluir"		,"AxInclui(cString, RecNo(), 3)"	,0,3} ,;
//							{"Alterar"		,"AxAltera(cString, RecNo(), 4)"	,0,4} ,;
							

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Cadastro de Motivos')

dbSelectArea(cString)
dbSetOrder(1)
mBrowse( 6,1,22,75,cString)
RestArea( aArea )
Return Nil       

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � ADOA4EXC � Autor � Microsiga          � Data �  22/07/09   ���
�������������������������������������������������������������������������͹��
���Descricao � Rotina para validar a exclusao do motivo.                  ���
�������������������������������������������������������������������������͹��
���Uso       � Adoro - Cadastro espelho de ciente e aprovacao de credito  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/        

User Function ADOA4EXC(cString, nReg, nOpc)

Local lVal		:= .T.
Local aArea		:= GetArea()
Local aAreaPB4	:= PB4->( GetArea() )

U_ADINF009P('ADOA004' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Cadastro de Motivos')

//------------------------------------------
// Valida se o motivo pode ser excluido
//------------------------------------------
DbSelectArea("PB3") // Cadastro espelho de cliente
PB3->( DbSetorder(9)) //FILIAL + MOTIVO DE ACESSO
If DbSeek( xFilial("PB3") + PB4->PB4_CODIGO ) 
	lVal := .F.
EndIf
DbSelectArea("PB4")
RestArea( aAreaPB4 )
RestArea( aArea )

If !lVal
	MsgAlert('Este motivo est� sendo utilizado no cadastro pre-cliente. N�o pode ser exclu�do.')
	Return Nil
Else
	AxDeleta(cString,nReg,nOpc)
	Return Nil
EndIf

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ADOA4Inc  �Autor  �Vogas Junior        � Data �  20/08/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function ADOACRUD(cString, nReg, nOpc)

Local oDlg				
Local oListBox
Local oButton
Local oEnchoice
Local nx 		:= 0
Local aSize    	:= MsAdvSize()
Local aPosObj  	:= {}
Local aObjects 	:= {}
Local aInfo		:= {}
Local aCpos		:= {}
Local nOpcao	:= 0		
Local aListBox	:= {}
Local oTik		:= LoadBitMap(GetResources(), 'LBTIK')
Local oNo		:= LoadBitMap(GetResources(), 'LBNO' )
Local oMarca	:= LoadBitMap(GetResources(), 's4wb018n.png')
Local cCampos 	:= ''
Local lMarca	:= .F.
Local cLista    := MSMM(PB4->PB4_CODMEM)
Private aTela	[0][0]
Private aGets	[0]

U_ADINF009P('ADOA004' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Cadastro de Motivos')

//Tamanho da tela				  				  
aObjects := {}
aAdd( aObjects, {   0, 110, .t., .f. } )
aAdd( aObjects, { 100, 100, .t., .t. } )
aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
aPosObj := MsObjSize( aInfo, aObjects )

// Adiciona elementos ao Array da ListBox
dbSelectArea( 'SX3')
SX3->( dbSetOrder(1))
If SX3->( Dbseek('PB3'))
	While SX3->X3_ARQUIVO == 'PB3'
//		dbSelectArea( 'SXA')
//		SXA->( dbSetOrder(1))
		SXA->( Dbseek('PB3'+ SX3->X3_FOLDER ) )	
		
			If nOpc <> 3 .and.(( AllTrim(SX3->X3_CAMPO)) $ cLista)
				lMarca := .T.
			Else
				lMarca := .F.
			Endif
			
			aAdd( aListBox,{ lMarca,SX3->X3_TITULO, SXA->XA_DESCRIC, SX3->X3_FOLDER, SX3->X3_CAMPO })
//		Endif
		SX3->(DbSkip())
	Enddo
Endif
Asort( aListBox,,,{|x,y| x[4] < Y[4] })

// Cria Variaveis de Memoria da Enchoice
DbSelectArea( cString )

For nX := 1 To FCount()                                                	
	If nOpc == 3
		M->&(FieldName(nX)) := CriaVar(FieldName(nX))
	Else
	  	M->&(FieldName(nX)) := FieldGet(nX)
	EndIf
	Aadd(aCpos,FieldName(nX))
Next nX

DEFINE MSDIALOG oDlg TITLE "Cadastro de Motivos" FROM aSize[7],00 To aSize[6],aSize[5] OF oMainWnd PIXEL 
 	   
	oEnchoice:= MsMGet():New( cString ,nReg, nOpc, , , , , , , 3,,,'.T.', oDLG, .F., .T., .F.,'', .F.)
		
	oButton:= tButton():New( 77, 40, 'Marca Tudo',oDlg,{||aListBox = MarcDesm(aListBox,.T.)},35,15,,,,.T.)
    oButton:= tButton():New( 77, 80, 'Desmarca Tudo',oDlg,{||aListBox = MarcDesm(aListBox, .F.)},45,15,,,,.T.)        
        
	@ 95,040 ListBox oListBox Fields HEADER " ","Campos", "Pastas" Size 151 , 147/*207*/ Of oDlg Pixel;
	On DBLCLICK (aListBox[oListBox:nAt,1] := !aListBox[oListBox:nAt,1] , oListBox:Refresh())
	oListBox:SetArray(aListBox)
	oListBox:bLine := {|| {If( aListBox[oListBox:nAT,01], oTIK, oNO ),aListBox[oListBox:nAT,02],aListBox[oListBox:nAT,03]}}
			
ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{||nOpcao:=1, If( Obrigatorio( aGets, aTela).and.chklst(aListbox) ,oDlg:End(),Nil)},{||nOpcao:=0,oDlg:End()},.F.,)


If nOpcao == 1

	Reclock( 'PB4', If( nOpc == 3, .T., .F.) )
	
	PB4_FILIAL := xFilial( 'PB4' )
	PB4_CODIGO := M->PB4_CODIGO
	PB4_DESCRI := M->PB4_DESCRI                     	
	
//	PB4_TIPO   := M->PB4_TIPO
	
	cCampos	:= ' '
	// Gravacao do campo MEMO com todos os campos que poderao ser alterados.
	For nx:= 1 to len( aListBox )
		If aListBox[ nx,1 ]
			cCampos += AllTrim( aListBox[nx,5] ) + ", "
		Endif
	Next nx
	if len(cCampos) > 1
		cCampos := Alltrim(Left( cCampos, Len( cCampos ) - 2 ))
	Endif
	MSMM(,TamSx3("PB4_CAMPOS")[1],,cCampos,1,,,"PB4","PB4_CODMEM")	
	PB4->( MsUnlock())
	
Endif	
//PBRA LEITURA DE CAMPO MEMO
//ALERT(MSMM(PA4->PA4_CODMEM))

Return(.T.)

Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MarcDesm  �Autor  �Microsiga           � Data �  08/21/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function MarcDesm(aListBox, lMarca)

Local i :=0

For i:= 1 to Len( aListBox )
	If lMarca
		aListBox[i,1] := .T.
	Else
		aListBox[i,1] := .F.
	Endif	
Next i

Return (aListBox) 	 	



Static Function chklst(aListbox)
Local lRet := .T.

Private nContaR := 0

aeval(aListBox, { |x| iif(x[1],nContaR++,nContaR) })

If nContaR < 1
	lRet := .F.
Endif

If !lRet
	MsgAlert("� necess�rio marcar ao menos um campo","Aviso" )
Endif

Return lRet
