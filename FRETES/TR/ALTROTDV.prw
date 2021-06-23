#include "rwmake.ch"
#include "TOPCONN.CH"

/*
��������������������������������������������������������������������������
��������������������������������������������������������������������������
����������������������������������������������������������������������ͻ��
���MANUTENCAO|Autor  � ANA HELENA BARRETA         � Data �  23/12/13   ���
����������������������������������������������������������������������͹��
���Desc.     �ROTINA COM BASE NO PROGRAMA ALTEROTE. MAS APENAS PARA    ���
���          �ROTEIRIZAR PEDIDOS DIVERSOS (INTEGRACAO PROTHEUS X EDATA)���
����������������������������������������������������������������������͹��
���Uso       � AP                                                      ���
����������������������������������������������������������������������͹��
���Alteracao � William Costa 18/02/2019 047305 Retirado Caracter Especi���
���          � al da linha 36                                          ���
����������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������
��������������������������������������������������������������������������
*/

//��������������������������������������������������������������Ŀ
//� Variaveis utilizadas para parametros                         �
//� mv_par01             // Do Roteiro                           �
//� mv_par02             // Ate Roteiro                          �
//� mv_par03             // Da Emissao                           �
//� mv_par04             // Ate Emissao                          �
//����������������������������������������������������������������
//��������������������������������������Ŀ
//� Verifica as perguntas                �
//����������������������������������������

User Function ALTROTDV()

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')
	// Na linha 36 do fonte anterior existia um caracter especial foi retirado e o erro n�o aconteceu nos testes. William Costa 18/02/2019 047305 || OS 048556 || E || NATALIA || 8452 || ROTEIRIZACAO
	SetPrvt("CCADASTRO,AROTINA,")
	
	dbSelectArea("SC5")
	//dbSetOrder(06)
	SC5->(DBORDERNICKNAME("SC5_6")) //atualiza��o protheus 12 WILLIAM COSTA 28/12/2017 CHAMADO 036032
	
	cPerg   := "GERABO"                                   
	
	Pergunte(cPerg,.T.)
	Public _DtEntr := MV_PAR05
	
	// Filtra os pedidos que ja foram liberado pelo credito e n�o foram faturados
	
	//��������������������������������������������������������������������Ŀ
	//�FILTRO MICROSIGA                                                    �
	//����������������������������������������������������������������������
	
	Private _cCond := "C5_FILIAL == '" + xFilial("SC5") + "' .AND. DTOS(C5_DTENTR) >= '"+ALLTRIM(DTOS(MV_PAR03))+"' .AND. DTOS(C5_DTENTR) <= '"+ALLTRIM(DTOS(MV_PAR04))+"' .AND. "+; 
	                   "C5_ROTEIRO >= '" + ALLTRIM(MV_PAR01)+"' .AND. C5_ROTEIRO <= '" + ALLTRIM(MV_PAR02)+"' .AND. C5_LIBEROK == 'S' .AND. EMPTY(C5_NOTA) .AND. C5_BLQ <> '1' "+;
	                   " .AND. C5_XTIPO == '2' .AND. __CUSERID $ EMBARALHA(C5_USERLGI,1) "
	
	Private aIndSC5    := {}
	Private bFiltraBrw	:= {|| FilBrowse( "SC5", @aIndSC5, @_cCond ) }
	
	
	CCadastro := "Alteracao do Roteiro de Entrega "
	aRotina := {  { "Pesquisar  "      ,"AxPesqui"            , 0 , 1},;                                         
	              { "Visualizar  "     ,"axVisual"            , 0 , 2},;
	              { "Alterar Roteiro  ",'ExecBlock("ARote")'  , 0 , 5},;
	              { "Placa X Roteiro  ",'ExecBlock("AD0055")' , 0 , 6},;
	              { "Limp. Placa "     ,'ExecBlock("UnRote")' , 0 , 7},;
	              { "Insp. Sanitaria " ,'ExecBlock("ASIF")'   , 0 , 7}}
	
	dbSelectArea("SC9")
	Dbsetorder(1)
	
	dbSelectArea("SZC")
	dbSetOrder(1)
	
	Eval( bFiltraBrw )
	
	dbSelectArea("SC5")
	dbGoTop()
	
	mBrowse( 06, 01, 22, 75, "SC5" )
	
	EndFilBrw( "SC5", aIndSC5 )

Return