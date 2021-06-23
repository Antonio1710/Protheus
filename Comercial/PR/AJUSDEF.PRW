#Include "Protheus.Ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAJUSDEF   บ Autor ณ Mauricio - MDS TEC บ Data ณ  12/09/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Tela para supervisores confirmarem/definirem seus 50 maio- บฑฑ
ฑฑบ          ณ res clientes                                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP6 IDE                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

/*
+----------------------------------------------------------------------------
| Parโmetros do MarkBrow()
+----------------------------------------------------------------------------
| MarkBrow( cAlias, cCampo, cCpo, aCampos, lInverte, cMarca, cCtrlM, uPar, 
|            cExpIni, cExpFim, cAval )
+----------------------------------------------------------------------------
| cAlias...: Alias do arquivo a ser exibido no browse 
| cCampo...: Campo do arquivo onde serแ feito o controle (grava็ใo) da marca
| cCpo.....: Campo onde serแ feita a valida็ใo para marca็ใo e exibi็ใo do bitmap de status
| aCampos..: Colunas a serem exibidas
| lInverte.: Inverte a marca็ใo
| cMarca...: String a ser gravada no campo especificado para marca็ใo
| cCtrlM...: Fun็ใo a ser executada caso deseje marcar todos elementos
| uPar.....: Parโmetro reservado
| cExpIni..: Fun็ใo que retorna o conte๚do inicial do filtro baseada na chave de ํndice selecionada
| cExpFim..: Fun็ใo que retorna o conte๚do final do filtro baseada na chave de ํndice selecionada
| cAval....: Fun็ใo a ser executada no duplo clique em um elemento no browse
+----------------------------------------------------------------------------
*/

User Function AJUSDEF()
//+----------------------------------------------------------------------------
//| Atribuicao de variaveis
//+----------------------------------------------------------------------------
Local aArea   := {}
Local nIndex  := 0
Local aSay    := {}
Local aButton := {}
Local nOpcao  := 0
Local cDesc1  := "Este programa tem o objetivo de definir/escolher os 50 maiores clientes os"
Local cDesc2  := "quais serao acompanhados atraves de relatorio durante o periodo."
Local cDesc3  := "Somente usuarios Supervisores pode utilizar esta rotina."
Local aCpos   := {}
Local aCampos := {}
Local cMsg    := ""

Private cFiltro := ""
Private cKey    := ""
Private cArq    := ""

Private aRotina     := {}
Private cMarca      := ""
Private cCadastro   := OemToAnsi("Cadastro Maiores Clientes")
//Private cPerg       := "MARK01"
Private nTotal      := 0
Private cArquivo    := ""
Private _dDatal     := GetMV("MV_XDATLIM")

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Tela para supervisores confirmarem/definirem seus 50 maiores clientes')

//+----------------------------------------------------------------------------
//| Monta tela de interacao com usuario
//+----------------------------------------------------------------------------
aAdd(aSay,cDesc1)
aAdd(aSay,cDesc2)
aAdd(aSay,cDesc3)

aAdd(aButton, { 1,.T.,{|| nOpcao := 1, FechaBatch() }})
aAdd(aButton, { 2,.T.,{|| FechaBatch()              }})

//FormBatch(<cTitulo>,<aMensagem>,<aBotoes>,<bValid>,nAltura,nLargura)
FormBatch(cCadastro,aSay,aButton)

//+----------------------------------------------------------------------------
//| Se cancelar sair
//+----------------------------------------------------------------------------
If nOpcao <> 1
   Return Nil
Endif

If date() >= _dDatal
   MsgInfo("Expirado prazo para escolha dos clientes.","Aten็ใo")
   Return Nil
Endif




/*
//+----------------------------------------------------------------------------
//| Cria as perguntas em SX1
//+----------------------------------------------------------------------------
CriaSX1()

//+----------------------------------------------------------------------------
//| Monta tela de paramentos para usuario, se cancelar sair
//+----------------------------------------------------------------------------
If !Pergunte(cPerg,.T.)
   Return Nil
Endif
*/
//+----------------------------------------------------------------------------
//| Atribui as variaveis de funcionalidades
//+---------------------------------------------------------------------------- 
 
//aAdd( aRotina ,{"Pesquisar" ,"AxPesqui()"   ,0,1})
aAdd( aRotina ,{"Selecionar" ,"u_SelZZY()",0,3})
aAdd( aRotina ,{"Contagem"   ,"u_ContZZY()" ,0,4})
             
//+----------------------------------------------------------------------------
//| Atribui as variaveis os campos que aparecerao no mBrowse()
//+----------------------------------------------------------------------------
aCpos := {"ZZY_OK","ZZY_RANK","ZZY_REDVAR","ZZY_CLIENTE","ZZY_LOJA","ZZY_NOME","ZZY_VEND","ZZY_IPM","ZZY_FATURA","ZZY_VOLUME"}

dbSelectArea("SX3")
dbSetOrder(2)
For nI := 1 To Len(aCpos)
   dbSeek(aCpos[nI])
   aAdd(aCampos,{X3_CAMPO,"",Iif(nI==1,"",Trim(X3_TITULO)),Trim(X3_PICTURE)})
Next

//+----------------------------------------------------------------------------
//| Monta o filtro especifico para MarkBrow()
//+----------------------------------------------------------------------------
dbSelectArea("ZZY")
aArea := GetArea()
cKey  := IndexKey()
cFiltro := "ZZY_CDUSSP = '"+__cUserID+"' "   &&Filtra somente registros do usuario(SUPERVISOR) logado
cArq := CriaTrab( Nil, .F. )
IndRegua("ZZY",cArq,cKey,,cFiltro)
nIndex := RetIndex("ZZY")
nIndex := nIndex + 1
dbSelectArea("ZZY")
#IFNDEF TOP
   dbSetIndex(cArq+OrdBagExt())
#ENDIF
dbSetOrder(nIndex)
dbGoTop()

//+----------------------------------------------------------------------------
//| Apresenta o MarkBrowse para o usuario
//+----------------------------------------------------------------------------
cMarca := GetMark(,"ZZY","ZZY_OK")	// GetMark()
MarkBrow("ZZY","ZZY_OK",,aCampos,,cMarca,"u_ALLZZY()",,,,"u_MarcZZY()")

//+----------------------------------------------------------------------------
//| Desfaz o indice e filtro temporario
//+----------------------------------------------------------------------------
dbSelectArea("ZZY")
RetIndex("ZZY")
Set Filter To
cArq += OrdBagExt()
FErase( cArq )
RestArea( aArea )
Return Nil

User Function MarcZZY()

   U_ADINF009P('AJUSDEF' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Tela para supervisores confirmarem/definirem seus 50 maiores clientes')

	DbSelectArea('ZZY')
	If IsMark( 'ZZY_OK', cMarca )  
	    RecLock( 'ZZY', .F. )
		Replace ZZY_OK With Space(2)		
		MsUnLock()                 
		lInvert	:=.F.	
	Else
		RecLock( 'ZZY', .F. )
		Replace ZZY_OK With cMarca
		MsUnLock()   
		lInvert	:=.T.	
	EndIf 
	MarkBRefresh()
Return
Return .T.

USER Function AllZZY()

	Local nRecno := Recno()

   U_ADINF009P('AJUSDEF' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Tela para supervisores confirmarem/definirem seus 50 maiores clientes')
   
	dbSelectArea('ZZY')
	dbGotop()
	While ZZY->(!Eof())
	    If ZZY_VALIDO == "X"
	       	RecLock( 'ZZY', .F. )
			   Replace ZZY_OK With cMarca
			MsUnLock()
		Else			
			RecLock( 'ZZY', .F. )
			Replace ZZY_OK With Space(2)
			MsUnLock()
		EndIf 
		dbSkip()		
	End
	dbGoto( nRecno )
	MarkBRefresh()
Return

User Function SelZZY()

U_ADINF009P('AJUSDEF' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Tela para supervisores confirmarem/definirem seus 50 maiores clientes')

_lTrue := .T.
&&Primeiro conto total selecionado
dbSelectArea("ZZY")
IndRegua("ZZY",cArq,cKey,,cFiltro)
dbGoTop()
_nCount := 0
While ZZY->(!Eof())   
   If ZZY->ZZY_OK == cMarca
      _nCount++
   Endif 
   ZZY->(dbSkip())
End

&&conto todos os registros
dbSelectArea("ZZY")
dbGoTop()
_nContot := 0
While ZZY->(!Eof())      
   _nContot++   
   ZZY->(dbSkip())
End

If _nContot < 50           &&total de registros menor que 50
   If _nCount <> _nContot  &&neste caso deve selecionar todos os clientes possiveis
      _lTrue := .F.
   endif
Else                      &&Total de registros eh igual ou maior que 50
   If _nCount > 50       &&neste caso precisa selecionar 50
      _lTrue := .F.
   endif
Endif

//_lTrue := .T. &&Mauricio paliativo para Vagenr testar a rotina

If _lTrue
   dbSelectArea("ZZY")
   dbGoTop()
   While ZZY->(!Eof())
      If ZZY->ZZY_OK <> cMarca
         RecLock("ZZY",.F.)
            ZZY->ZZY_VALIDO := " "  
         MsUnlock() 
         ZZY->(dbSkip())
         Loop
      Endif
      RecLock("ZZY",.F.)
         ZZY->ZZY_VALIDO := "X"   &&flag de clientes que serao considerados e acompanhados em relatorio....
         &&verificar com Vagner se trava ou nao altera็๕es a partir de agora..;.
      MsUnlock()   
      ZZY->(dbSkip())
   End
   MSGINFO("Seus Clientes marcados foram selecionados.Saia da rotina ou selecione novamente para mudar","Aten็ao")
Else
   MSGINFO("Numero de clientes selecionados menor e/ou maior que o necessario(padrao ้ 50).","Aten็ao")
endif   
dbSelectArea("ZZY")
dbGoTop()
MarkBRefresh()
Return()

User Function ContZZY()

Local nRecno := Recno()

U_ADINF009P('AJUSDEF' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Tela para supervisores confirmarem/definirem seus 50 maiores clientes')
dbSelectArea("ZZY")
dbGoTop()
_nCount := 0
While ZZY->(!Eof())   
   If ZZY->ZZY_OK == cMarca
      _nCount++
   Endif 
   ZZY->(dbSkip())
End
MSGINFO("Selecionados "+Alltrim(STR(_nCount))+" registros.","Aten็ao")
dbSelectArea("ZZY")
dbGoTop()
MarkBRefresh()
Return() 

User Function LegZZY()
Local aCor := {}

U_ADINF009P('AJUSDEF' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Tela para supervisores confirmarem/definirem seus 50 maiores clientes')

aAdd(aCor,{"BR_VERDE"   ,"NF Nใo Transferida"})
aAdd(aCor,{"BR_VERMELHO","NF Transferida"    })

BrwLegenda(cCadastro,OemToAnsi("Registros"),aCor)

Return


Static Function CriaSx1()
Local nX := 0
Local nY := 0
Local aAreaAnt := GetArea()
Local aAreaSX1 := SX1->(GetArea())
Local aReg := {}

aAdd(aReg,{cPerg,"01","Emissao de ?        ","mv_ch1","D", 8,0,0,"G","","mv_par01","","","","","","","","","","","","","","",""})
aAdd(aReg,{cPerg,"02","Emissao ate ?       ","mv_ch2","D", 8,0,0,"G","(mv_par02>=mv_par01)","mv_par02","","","","","","","","","","","","","","",""})
aAdd(aReg,{cPerg,"03","Codigo de ?         ","mv_ch3","C", 6,0,0,"G","","mv_par03","","","","","","","","","","","","","","","SA2"})
aAdd(aReg,{cPerg,"04","Codigo ate ?        ","mv_ch4","C", 6,0,0,"G","(mv_par04>=mv_par03)","mv_par04","","","","","","","","","","","","","","","SA2"})
aAdd(aReg,{cPerg,"05","Mostrar Todos ?     ","mv_ch5","N", 1,0,0,"C","","mv_par05","Sim","","","Nao","","","","","","","","","","",""})
aAdd(aReg,{"X1_GRUPO","X1_ORDEM","X1_PERGUNT","X1_VARIAVL","X1_TIPO","X1_TAMANHO","X1_DECIMAL","X1_PRESEL","X1_GSC","X1_VALID","X1_VAR01","X1_DEF01","X1_CNT01","X1_VAR02","X1_DEF02","X1_CNT02","X1_VAR03","X1_DEF03","X1_CNT03","X1_VAR04","X1_DEF04","X1_CNT04","X1_VAR05","X1_DEF05","X1_CNT05","X1_F3"})

dbSelectArea("SX1")
dbSetOrder(1)
For ny:=1 to Len(aReg)-1
	If !dbSeek(aReg[ny,1]+aReg[ny,2])
		RecLock("SX1",.T.)
		For j:=1 to Len(aReg[ny])
			FieldPut(FieldPos(aReg[Len(aReg)][j]),aReg[ny,j])
		Next j
		MsUnlock()
	EndIf
Next ny
RestArea(aAreaSX1)
RestArea(aAreaAnt)
Return Nil

