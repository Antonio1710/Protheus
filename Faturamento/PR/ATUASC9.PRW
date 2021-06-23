/*
DANIEL 30/10/06
------------------------------------------------------------------------
TENTEI FAZER A ATUALIZACAO POR UMA CONSULTA SQL MAS TIVE POUCO 
GANHO DE DESEMPENHO
ALTERADO TODO O FONTE POR DUAS QUERY DE ATUALIZACAO CONFORME 
PARAMETROS INICIAIS
------------------------------------------------------------------------


*/
#include "rwmake.ch"   
#INCLUDE "TOPCONN.CH"

User Function ATUASC9()

Local _cRet := ""        
local cQuery := ""
LOCAL _nTotalPedi := 0
LOCAL _nTotalCx   := 0
LOCAL _nTotalKg   := 0
LOCAL _nTotalBr   := 0


U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Atualizar sc9_roteiro e sc9_sequenc com itens do pedido')

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Programa ³ATUSC9    º Autor ³ Marcos Bido        º Data ³  07/08/2002 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Atualizar sc9_roteiro e sc9_sequenc com itens do pedido    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Espec¡fico Ad'oro                                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º                                                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAlteracoes³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ mv_par01             // Do Roteiro                           ³
//³ mv_par02             // Ate Roteiro                          ³
//³ mv_par03             // Da Data entrega                      ³
//³ mv_par04             // Ate Data entrega                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

cPerg   := "GERABO"
If !Pergunte(cPerg,.t.)
	Return(nil)
EndIf	

// posiocionando os arquivos
/*
DbSelectArea("SC9")
_SC9cAliasSC9 := Alias()
_SC9cOrderSC9 := IndexOrd()
_SC9cRecnoSC9 := Recno()
DbSetorder(1)

dbSelectArea("SC6")
_SC6cAliasSC6 := Alias()
_SC6cOrderSC6 := IndexOrd()
_SC6cRecnoSC6 := Recno()
dbSetOrder(1)

dbSelectArea("SC5")
dbSetOrder(9)
dbGoTop()
_SC5cAliasSC5 := Alias()
_SC5cOrderSC5 := IndexOrd()
_SC5cRecnoSC5 := Recno() */

  		//MONTA MINHAS MENSAGENS NA TELA COM A REGUA
		bBloco := {|lEnd|procsc9()}
		MsAguarde(bBloco,"Aguarde.....","Processando...",.F.)
		
RETURN

static function  procsc9()
  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºSC6010    ³ UPDATE DO SC6010 COM BASE NO SC5010                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
nPed := ""
_cQuery1:= ""
_cQuery1:= "SELECT C5_NUM FROM "+RETSQLNAME("SC5")+" WHERE C5_ROTEIRO BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' AND "
_cQuery1+= "C5_EMISSAO BETWEEN '"+DTOS(MV_PAR03)+"' AND '"+DTOS(MV_PAR04)+"' AND "
_cQuery1+= "C5_DTENTR = '"+DTOS(MV_PAR05)+"' AND C5_NOTA = '' AND C5_LIBEROK='S' AND "+RETSQLNAME("SC5")+".D_E_L_E_T_=' ' "
TcQuery _cQuery1 NEW ALIAS "QRYC5"
nPed := QRYC5->C5_NUM
dbSelectArea("QRYC5")
dbGoTop()
// Rotina que corrige o peso do pedido
While !Eof()
    
     msproctxt ("ATUALIZANDO PESO NA SC5")  
   	_nTotalCx := 0
	_nTotalKg := 0
	_nTotalBr := 0
	
	DBSELECTAREA("SC6")
	DBSETORDER(1)	
	IF DBSEEK(XFILIAL("SC6")+QRYC5->C5_NUM)
		
		While !Eof() .and. SC6->C6_NUM == QRYC5->C5_NUM
		
			//_nTotalPedi := _nTotalPedi + SC6->C6_VALOR
			_nTotalCx   := _nTotalCx   + SC6->C6_UNSVEN   // Soma qtd caixas (2a. UM)
			//_nTotalCx   := _nTotalCx   + SC9->C9_QTDLIB2   // Soma qtd caixas (2a. UM)
//			_nTotalKg   := _nTotalKg   + SC6->C6_QTDVEN   // Soma qtd peso   <1a. UM)
			_nTotalKg   := _nTotalKg   + iif(SC6->C6_SEGUM="BS",0,SC6->C6_QTDVEN)   // Soma qtd peso   <1a. UM) // alterado por Adriana, se bolsa nao soma 1a unidade como peso
			//_nTotalKg   := _nTotalKg   + SC9->C9_QTDLIB   // Soma qtd peso   <1a. UM)
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Posiciona Cadastro de Tara                                          ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DBSELECTAREA("SB1")
			DBSETORDER(1)
			
			IF DBSEEK(XFILIAL("SB1")+SC6->C6_PRODUTO)
			
				dbSelectArea("SZC")
				dbSetOrder(1)
				IF dbSeek( xFilial("SZC") + SB1->B1_SEGUM )
					_nTotalBr   := _nTotalBr + (SC6->C6_UNSVEN * SZC->ZC_TARA) // PESO BRUTO
				ELSE
					_nTotalBr   := _nTotalBr + (SC6->C6_UNSVEN  * 1) // PESO BRUTO
				ENDIF
		
			ENDIF
			
			dbSelectArea("SC6")
			dbSkip()
			
		ENDDO
	ENDIF
	
	DBSELECTAREA("QRYC5")
		
	dbselectarea("SC5")
	dbsetorder(1)
	If dbseek(xFilial("SC5")+QRYC5->C5_NUM)
		RecLock("SC5",.F.)
		&&Mauricio 26/04/10 - incluido tratamento para peso duplicado fiiais 03/04/05.
		Replace SC5->C5_PBRUTO  With _nTotalBr + Iif(!(XFILIAL("SC5")$'03/04/05'),_nTotalKg, 0)   //incluida condicao em 24/06/2008 pois em SC estava duplicando o peso 
		Replace SC5->C5_PESOL   With _nTotalKg
		Replace SC5->C5_VOLUME1 With _nTotalCx
		MsUnlock()
	EndIf
	
	QRYC5->(DBSKIP())
	
ENDDO
   
   // Rotina que atualiza as quantidades igual ao pedido de venda - Alex Borges / 15/08/11
   
QRYC5->(dbCloseArea())

if !Empty(nPed)                                                                                           


	
	_cQuery0:=""
	_cQuery0+=" UPDATE 	"+retsqlname("SC9")+" WITH(UPDLOCK) SET C9_QTDLIB=C6_QTDVEN, C9_QTDLIB2=C6_UNSVEN" 
	_cQuery0+=" FROM 	"+RETSQLNAME("SC6")+" "
	_cQuery0+=" WHERE C9_FILIAL=C6_FILIAL AND " 
	_cQuery0+=" C9_ITEM=C6_ITEM  AND "
	_cQuery0+=" C9_PEDIDO=C6_NUM  AND " 
	_cQuery0+=" C6_PRODUTO = C9_PRODUTO AND "
    _cQuery0+=" C9_FILIAL = '"+XFILIAL("SC9")+"' AND "
	_cQuery0+=" (C9_ROTEIRO BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"') AND 
	_cQuery0+=" C9_DTENTR = '"+DTOS(MV_PAR05)+"' AND 
	_cQuery0+=" C9_NFISCAL=' ' 	AND 	
	_cQuery0+=" "+retsqlname("SC9")+".D_E_L_E_T_=' ' AND   "
	_cQuery0+=" "+retsqlname("SC6")+".D_E_L_E_T_=' '"
	
	msproctxt ("ATUALIZANDO QUANTIDADE NA SC9")  
	If TCSQLExec(_cQuery0) != 0
		   Aviso(FunDesc(),TCSQLERROR(),{"OK"})  
		   RETURN 
	EndIf
	TcSqlExec("COMMIT")
	


   _cQuery1:=""
   _cQuery1:=" UPDATE 	"+retsqlname("SC6")+" WITH(UPDLOCK) SET C6_ROTEIRO=C5_ROTEIRO, C6_SEQUENC=C5_SEQUENC "
   _cQuery1+=" FROM 	"+RETSQLNAME("SC5")+" "
   _cQuery1+=" WHERE   "
   _cQuery1+=" C6_NUM=C5_NUM 	AND "
   _cQuery1+=" (C5_ROTEIRO BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"')  AND " 
   _cQuery1+=" (C5_EMISSAO BETWEEN '"+DTOS(MV_PAR03)+"' AND '"+DTOS(MV_PAR04)+"') AND "
   _cQuery1+=" C5_DTENTR = '"+DTOS(MV_PAR05)+"' AND "
   _cQuery1+=" C5_NOTA=' ' 	AND "
   _cQuery1+=" C5_LIBEROK='S'  "
   _cQuery1+=" AND "+retsqlname("SC6")+".D_E_L_E_T_=' ' "
   _cQuery1+=" AND "+RETSQLNAME("SC5")+".D_E_L_E_T_=' ' "
                             
   /*
   ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
   ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
   ±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
   ±±ºSC9010    ³ UPDATE DO SC9010 COM BASE NO SC5010                        º±±
   ±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
   ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
   ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
   */  

   _cQuery2:=""
   _cQuery2:=" UPDATE 	"+RETSQLNAME("SC9")+" WITH(UPDLOCK) SET C9_ROTEIRO=C5_ROTEIRO, C9_SEQUENC=C5_SEQUENC, C9_DTENTR=C5_DTENTR, C9_VEND1=C5_VEND1 "
   _cQuery2+=" FROM 	"+RETSQLNAME("SC5")+" "
   _cQuery2+=" WHERE        "
   _cQuery2+=" C9_PEDIDO=C5_NUM  AND "
   _cQuery2+=" (C5_ROTEIRO BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"') AND "
   _cQuery2+=" (C5_EMISSAO BETWEEN '"+DTOS(MV_PAR03)+"' AND '"+DTOS(MV_PAR04)+"') AND "
   _cQuery2+=" C5_DTENTR = '"+DTOS(MV_PAR05)+"' AND "
   _cQuery2+=" C5_NOTA=' ' 	AND "
   _cQuery2+=" C5_LIBEROK='S' 	"
   _cQuery2+=" AND "+RETSQLNAME("SC9")+".D_E_L_E_T_=' ' "
   _cQuery2+=" AND "+RETSQLNAME("SC5")+".D_E_L_E_T_=' ' "
 

   msproctxt ("ATUALIZANDO SC6")                  
   //UPADTE SC6010
   TCSQLExec(_cQuery1)   

   msproctxt ("ATUALIZANDO SC9")                  
   //UPADTE SC9010
   TCSQLExec(_cQuery2)
else
   MsgBox(OemToAnsi("Não foi localizado registros do pedido, verifique os parametros!!!"),OemToAnsi("Mensagem"),"INFO")
endif   
  

Return(nil)


//SET FILTER TO val(C5_ROTEIRO) >= val(MV_PAR01) .AND. val(C5_ROTEIRO) <= val(MV_PAR02) .AND.;
//            C5_DTENTR >= MV_PAR03 .AND. C5_DTENTR <= MV_PAR04 .AND.;
//            C5_LIBEROK == 'S' .and. empty(C5_NOTA)
                  

//tentativa com uma consta, ficou um pouco mais rapido
/*
_cQuery:=""
_cQuery:=" SELECT C5_NUM, C5_ROTEIRO,C5_SEQUENC,C5_DTENTR FROM "+RETSQLNAME("SC5")+" "
_cQuery+=" WHERE (C5_ROTEIRO BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"') AND (C5_DTENTR BETWEEN '"+DTOS(MV_PAR03)+"' AND '"+DTOS(MV_PAR04)+"')
_cQuery+=" AND C5_NOTA<>'' AND C5_LIBEROK='S'"
TcQuery _cQuery NEW ALIAS "TMP1"
DBSELECTAREA("TMP1")
DBGOTOP()


Do While !Eof() 
			            	
	 	msproctxt ("PED.: "+TMP1->C5_NUM)
	
        _NumPed    := TMP1->C5_NUM
        _Roteiro   := TMP1->C5_ROTEIRO
        _Sequencia := TMP1->C5_SEQUENC
        _DtEntr    := TMP1->C5_DTENTR 

        //IncProc(" Pedido : " + _NumPed + "Rot : "+ _Roteiro +" Seq."+_Sequencia)
        
        dbSelectArea("SC6")

        DBSeek(xfilial("SC6")+_NumPed)

        do while .not.eof().and. c6_num == _NumPed

                RecLock("SC6",.F.)
                REPLACE C6_ROTEIRO WITH _ROTEIRO
                REPLACE C6_SEQUENC WITH _SEQUENCIA
                MsUnlock()

                dbSkip()

        Enddo

        dbSelectArea("SC9")

        DBSeek(xfilial("SC9")+_NumPed)

        do while .not.eof().and. c9_pedido == _NumPed
                RecLock("SC9",.F.)
                REPLACE C9_ROTEIRO WITH _ROTEIRO
                REPLACE C9_SEQUENC WITH _SEQUENCIA
                REPLACE C9_DTENTR  WITH STOD(_DTENTR)
                REPLACE C9_BLEST   WITH "10"
                MsUnlock()
                dbSkip()
       Enddo
		
       dbSelectArea("TMP1")
       dbSkip()
Enddo

// Liberaçao Estoqueforçado pois cliente nao controla estoque via bloqueio microsiga
// o bloqueio gerava problemas no fauramento a menor pois o item nao estava disponivel para a geraçao a nf
// Marcvs Natel - NDM 03/11/09 



//SET FILTER TO

dbSelectArea(_SC6cAliasSC5)
dbSetOrder(_SC6cOrderSC5)
dbGoto(_SC6cRecnoSC5)

dbSelectArea(_SC6cAliasSC6)
dbSetOrder(_SC6cOrderSC6)
dbGoto(_SC6cRecnoSC6)

dbSelectArea(_SC9cAliasSC9)
dbSetOrder(_SC9cOrderSC9)
dbGoto(_SC9cRecnoSC9)


//MsgStop("Fim do Processamento")
                          

Return(nil)

