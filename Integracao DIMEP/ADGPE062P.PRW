#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TBICODE.CH"   
#INCLUDE "XMLXFUN.CH" 
#INCLUDE 'FWMVCDEF.CH' 

/*{Protheus.doc} User Function ADGPE062P
	Gatilho para preencher o campo ZG1_NMESTR
	@type  Function
	@author WILLIAM COSTA
	@since 10/06/2016
	@version 01
  @history TICKET  224    - William Costa - 11/11/2020 - Alteração do Fonte na parte de Funcionários, trocar a integração do Protheus para a Integração do RM
  @history ticket  14365  - Fernando Macieir- 19/05/2021 - Novo Linked Server (de VPSRV17 para DIMEP)
  @history Ticket  77205 - Adriano Savoine  - 27/07/2022- Alterado o Link de dados de DIMEP para DMPACESSO
*/	

User Function ADGPE062P()

    Local lRet      := .T.
    Local oModel    := FWModelActive()
    Local cMAt      := oModel:GetValue('ZG1MASTER','ZG1_MAT')
    Local cNmEstrut := ''

    U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Gatilho para preencher o campo ZG1_NMESTR')

    SqlPessoa(cMAt)
    While TRB->(!EOF())

        oModel:SetValue('ZG1MASTER','ZG1_NMESTR',TRB->NM_ESTRUTURA)
        cNmEstrut := TRB->NM_ESTRUTURA

        TRB->(dbSkip())
		
    ENDDO //FECHA WHILE DO TRC
    
    TRB->(dbCloseArea()) 

RETURN(cNmEstrut)

STATIC FUNCTION SqlPessoa(cMAt)

    BeginSQL Alias "TRB"
			%NoPARSER% 
             SELECT NM_ESTRUTURA
               FROM [DMPACESSO].[DMPACESSOII].[DBO].[PESSOA] PESSOA
         INNER JOIN [DMPACESSO].[DMPACESSOII].[DBO].[ESTRUTURA_ORGANIZACIONAL] ESTRUTURA_ORGANIZACIONAL
                 ON ESTRUTURA_ORGANIZACIONAL.CD_ESTRUTURA_ORGANIZACIONAL = PESSOA.CD_ESTRUTURA_ORGANIZACIONAL
                AND CD_ESTRUTURA_RELACIONADA = 1223
              WHERE CD_SITUACAO_PESSOA = 11
                AND NU_MATRICULA       = %EXP:cMAt%
		
	EndSQl          

RETURN(NIL)
