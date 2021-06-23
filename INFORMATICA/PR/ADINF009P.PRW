#include "TOTVS.CH"

/*/{Protheus.doc} User Function ADINF009P
  Grava histórico de execução de rotinas
  @type  Function
  @author Abel Babini
  @since 24/01/2020
  @version 1
  @history Chamado T.I - William Costa - 07/02/2020 - Adicionado consulta para gravar as rotinas somente uma vez por dia.
  @history Chamado T.I - William Costa - 12/02/2020 - Adicionado regra para deixar a variavel de fonte e função em maisculo antes de fazer o select de busca. Adicionado with (nolock) no sql
  /*/
  
User Function ADINF009P(cFonte,cFuncao,cInfCom)

  Local _lRgExec := GETMV("MV_#LGEXCU",,.F.) //Registra execução de rotinas customizadas
  Local _aAreaFX := GetArea()

  IF _lRgExec

    //log de alteração de data de entrega	

    cFonte  := UPPER(cFonte)
    cFuncao := UPPER(cFuncao)
    
    SqlBuscaFuncao(DTOS(DATE()),cFonte,cFuncao)
	    	
    IF TZZ->(EOF()) 
    
      DBSELECTAREA("ZFX")

      IF RECLOCK("ZFX",.T.) 

        ZFX->ZFX_FILIAL := FWxFilial("ZFX")
        ZFX->ZFX_DATA   := DATE()
        ZFX->ZFX_HORA   := TIME()
        ZFX->ZFX_USUARI := UPPER(Alltrim(cUserName))
        ZFX->ZFX_USURED := UPPER(Alltrim(LogUserName()))
        ZFX->ZFX_FONTE  := Alltrim(cFonte)
        ZFX->ZFX_FUNCAO := Alltrim(cFuncao)
        ZFX->ZFX_INFCOM := Alltrim(cInfCom)

        ZFX->(MSUNLOCK())    

      ENDIF
    ENDIF
    TZZ->(dbCloseArea())
  ENDIF

  RESTAREA(_aAreaFX)

RETURN(NIL)

Static Function SqlBuscaFuncao(cdata,cFonte,cFuncao)

  Local cFilAtu := FWxFilial("ZFX")

	BeginSQL Alias "TZZ"
			%NoPARSER% 
      SELECT TOP(1) ZFX_DATA,ZFX_FONTE,ZFX_FUNCAO
        FROM ZFX010 WITH (NOLOCK)
      WHERE ZFX_FILIAL  = %EXP:cFilAtu%
        AND ZFX_DATA    = %EXP:cdata%
        AND ZFX_FONTE   = %EXP:cFonte%
        AND ZFX_FUNCAO  = %EXP:cFuncao%
        AND D_E_L_E_T_ <> '*'
					
	EndSQl             
RETURN(NIL)   
