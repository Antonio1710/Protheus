// CALCULO DO DIGITO VERIFICAR DO BANCO ITAU, CARTEIRA 109
// CRIADO DAVI JESUS - DATA 02/07/07
// OBJETIVO: Busca faixa de nosso numero no cadastro de banco, somando 1 apos execucao 
// Recebe o parametro de tipo de calculo sendo:
//   1 = Nao devolve o DAC, apenas o nosso numero 
//   2 = Devolve o DAC com o nosso numero no formato CCC/NNNNNNNN-D
//   sendo que para CCC carteira, NNNNNNNNN faixa de nosso numero e D o digito calculado com modulo 10
//
// obs O banco Itau utiliza 8 posiçoes para a faixa de nosso numero
USER FUNCTION MODitau(cTipo)
Local x        := 0
Local _nFaxAtu := ""  
Local _Soma    := 0
Local _nX      := 0
Local _aConv
Local _aNum    := {2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1} 

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

If empty(cTipo)
   cTipo := "1"
EndIf

dbSelectArea("SEE")
dbSetOrder(1)         //EE_FILIAL+EE_CODIGO+EE_AGENCIA+EE_CONTA+EE_SUBCTA
If dbSeek(xFilial("SEE")+SE1->E1_PORTADO+SE1->E1_AGEDEP+SE1->E1_CONTA)
	RecLock("SEE",.f.)
	_nFaxAtu := SEE->EE_FAXATU
    _aConv   := alltrim(SE1->E1_AGEDEP)+alltrim(SE1->E1_CONTA)+"109"+_nFaxAtu                                   
	SEE->EE_FAXATU := STRZERO(VAL(SEE->EE_FAXATU)+1,8)        
    MsUnLock()
    If cTipo <> "1"
		FOR x := LEN(_aConv) TO 1 STEP -1
		    ++_nX
			_Soma += VAL( SUBSTR( _aConv, x, 1 ) ) * _aNum[_nX]
		NEXT
	
		_nX := 10-(((_Soma/10)-INT(_Soma/10))*10)
		_nX := "109/"+_nFaxAtu+"-"+str(_nX,1)
    Else
        _nX := _nFaxAtu
    Endif              
Else
    Alert("Parametro do banco nao Criado! Favor Corrigir.")
Endif

RETURN( _nX )