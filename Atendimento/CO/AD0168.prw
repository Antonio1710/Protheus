#INCLUDE "rwmake.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AD0168    º Autor ³ Werner             º Data ³  27/03/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Consulta Observaçôes                                       º±±
±±º          ³ Tabela SZD010                                              º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6 IDE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function AD0168(_cObserv)

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Consulta Observaçôes')

//cPerg 	:= "AD0168"         	// AJUSTADO BY DGJR. 17/11/09
cPerg 	:= PADR("AD0168",10," ")
Pergunte	(cPerg,.T.)
                         

lQuebra := IIF(MV_PAR04==1,.F.,.T.)  // SE MOSTRA QUEBRA
// +-------------------------+
// | Guarda ambiente inicial |
// +-------------------------+
_cAlias := Alias()
_cIndex := IndexOrd()
_cRecno := Recno()
_cNomCli := ""

If _cAlias == 'SC5'
	_CLI	 := SC5->C5_CLIENTE
	_LOJA    := SC5->C5_LOJACLI
	DbSelectArea("SA1")
	DbSetOrder(1)	  
	DbSeek(xFilial("SA1")+_CLI+_LOJA)
	_cNomCli := SA1->A1_NOME	
	
	_cPedido :=	SC5->C5_NUM	
	_dData   := mv_par01 - 5  // Posiciono em data anterior
	// Posiciona na Devolucao em questao
	//Verifico se já Existe Ocorrencias
	DbSelectArea("SZD")
	DbSetOrder(3)
	//ZD_FILIAL + DTOS(ZD_DTDEV) + ZD_CODCLI + ZD_LOJA
	SET SOFTSEEK ON
	dbSeek(xfilial("SZD")+DTOS(_dData)+_CLI+_LOJA)
	SET SOFTSEEK OFF	
ELSE	
	_CLI     := SZD->ZD_CODCLI 
	_LOJA    := SZD->ZD_LOJA
	_cPedido :=	SZD->ZD_PEDIDO		
	_dData   := SZD->ZD_DTDEV 	// Parametro
ENDIF 
_dta	 :=DTOS(DDATABASE-15)
_zxfnd   :=.T.
_cObserv :=''
_cConOk  := "N"

If DTOS(ZD_DTDEV) >= _dta
	
	WHILE !EOF() .AND.  DTOS(ZD_DTDEV) >= _dta
		If (SZD->ZD_CODCLI = _CLI) // .AND. (SZD->ZD_LOJA = _LOJA)
			_cConOk      := "S"
			_cCodRespons :=SZD->ZD_RESPONS  //responsavel
			_cNresp      :=SZD->ZD_RESPNOM	//NOME DO RESPONSAVEL
			_cMotivo     :=SZD->ZD_MOTIVO                      //ESTAVA BLOQUEADO..............********
			_cplac       :=SZD->ZD_PLACA    //placa
			_cUsuario    :=SZD->ZD_AUTNOME  //Autorisante
			_cNomCli     :=SZD->ZD_NOMECLI  //Cliente
			_cCodCli	 :=SZD->ZD_CODCLI   //CODIGO DO CLIENTE
			_Ped		 :=SZD->ZD_PEDIDO	 //PEDIDO
			_cNota       :=SZD->ZD_NUMNF
			_cSerie      :=SZD->ZD_SERIE
			_cObser		 :=SZD->ZD_OBSHST
			_cSeqRot     :=SZD->ZD_SEQUENC
			IF EMPTY(ALLTRIM(_cNresp))
				_cNresp:=""
			ENDIF
			
			/*MONTANDO CABECALHO*/
			_cObserv+=CHR(13)
			//_cObserv+="RESPONSAVEL: "+_cCodRespons+" - "+_cNresp+" PLACA: "+_cPlac
			_cObserv+="RESPONSAVEL: "+_cUsuario+" - "+_cNresp+" PLACA: "+_cPlac
			_cObserv+=" PEDIDO :"+_Ped + " SEQUENCIA: " + _cSeqRot
			_cObserv+=CHR(13)
			_cObserv+="Observação:"+_cObser
			_cObserv+=CHR(13)
			_cObserv+=CHR(13)  
			
			
			/*OBS*/
			_cObserv := _cObserv + SZD->ZD_OBSer 
   
			
			/*CABEC DO DETALHE*/
			_cObserv+=CHR(13)
			_cObserv+=CHR(13)
			_cObserv+="+------------------------------------------------------------------------------------+"
			_cObserv+=CHR(13)
			_cObserv+="|                                   DETALHE DA NOTA                                               |"
			_cObserv+=CHR(13)
			_cObserv+="+------------------------------------------------------------------------------------+"
			_cObserv+=CHR(13)
			_cObserv+=CHR(13)
		
			
			/*PROCURANDO OBS NOS DETALHES */
			DbSelectArea("SZX")
			DbsetOrder(1)
			IF dbSeek(xfilial("SZX")+alltrim(_cNota)+alltrim(_cSerie),.T.)
				
				WHILE !EOF() .AND. (ZX_NF=_cNota) .AND. (ZX_SERIE=_cSerie)
					
					_cObserv+=CHR(13)
					_cObserv+="PRODUTO: "+ZX_CODPROD+ZX_DESCRIC
					_cObserv+=CHR(13)
					_cObserv+="QUANTIDADE: "+STR(ZX_QTDE)+" "+ZX_UNIDADE+" QUANTIDADE DEVOLVIDA: "+STR(ZX_QTDEV1U)+" "+ZX_UNIDADE
				   
					IF lQuebra .and. ZX_QUEBRA > 0 .and. SZD->ZD_DEVTOT = "Q"	 
					_cObserv+= "  QUEBRA:"+TRANSFORM(ZX_QUEBRA,"@E 999.999,9999")
					endif
					
					_cObserv+=CHR(13)
					_cObserv+="OBS:"
					_cObserv+=CHR(13)
					_cObserv+=CHR(13)
					_cObserv+=ZX_OBSER
					_cObserv+=CHR(13)
					_zxfnd:=.T.
					DBSKIP()
				ENDDO
				
			ENDIF
		Endif
		dbselectarea("SZD")
		DBSKIP()
	ENDDO
Endif


If _cConOk  = "N"
	MSGBOX(" Pedido  "+ _cPedido +" "+" sem ocorrencias !!! ")
	Return
Endif

/*
if _zxfnd=.F.
_cObserv+=CHR(13)
_cObserv+="***SEM OCORRENCIA NOS DETALHES DESTA NF***"
_cObserv+=CHR(13)
endif
*/
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ VariaveL Memo                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

///****************
_cChar:=""+CHR(13)+CHR(10)
_cObserv:=STRTRAN(_cObserv,CHR(13),_cChar)
DbSelectArea("SZD")
DbSetOrder(3)
dbSeek(xfilial("SZD")+DTOS(_dData)+_CLI+_LOJA)
_cCodCli	 := SZD->ZD_CODCLI
_cCodRespons := SZD->ZD_RESPONS
_cMotivo     := SZD->ZD_MOTIVO
_cUsuario    := SZD->ZD_AUTNOME
_cNomCli     := SZD->ZD_NOMECLI
@ 116,090 To 426,707 Dialog oDlgMemo Title " * * * Ocorrencias * * * "
@ 003,002 To 040,305
@ 012,008 Say OemToAnsi("Ocorrencias do Cliente  "+_Cli+" "+_cNomCli)
@ 045,005 Say OemToAnsi("Atendente : "+_cUsuario+Space(100)) Object oNome
@ 055,002 Get _cObserv  Size 305,080  MEMO                    Object oMemo
oMemo:lReadOnly := .T.
@ 142,263 BmpButton Type 1 Action Retorno()

Activate Dialog oDlgMemo

//Volto a posição de chamada
dbSelectArea(_cAlias)
dbSetOrder(_cIndex)
dbGoto(_cRecno)


Return


Static Function Retorno() //GRAVA VARIAVEIS

Close(oDlgMemo)

Return
