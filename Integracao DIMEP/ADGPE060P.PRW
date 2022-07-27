#Include "Protheus.ch"
#Include "TopConn.ch"

/*/{Protheus.doc} User Function ADGPE060P
	Consulta Especifica para a Tabela PESSOA DO DIMEP
	@type  Function
	@author William Costa
	@since 16/06/2020
	@version version
	@param cConsSQLM, Caracter, Consulta SQL                                                               
    @param cRetorM, Caracter, Campo que será retornado                                                     
    @param cAgrupM, Caracter, Group By do SQL                                                              
    @param cOrderM, Caracter, Order By do SQL
	@return lRetorn, retorno se a consulta foi confirmada ou não
	@example                                                                                               
    lOK := u_zConsSQL("SELECT B1_COD, B1_DESC FROM SB1010 WHERE D_E_L_E_T_ = ' ' ", "B1_COD", "", "B1_COD")
    u_zConsSQL("SELECT * FROM ZA0990", "ZA0_COD", "", "")                                                  
    @obs O retorno da consulta é pública (__cRetorno) para ser usada em consultas específicas              
    A consulta não pode ter ORDER BY, pois ele já é especificado em um parâmetro
	@history TICKET  224    - William Costa - 11/11/2020 - Alteração do Fonte na parte de Funcionários, trocar a integração do Protheus para a Integração do RM
	@history ticket  14365  - Fernando Macieir- 19/05/2021 - Novo Linked Server (de VPSRV17 para DIMEP)
	@history Ticket  77205 - Adriano Savoine  - 27/07/2022- Alterado o Link de dados de DIMEP para DMPACESSO
/*/

//Constantes
#Define STR_PULA        Chr(13)+ Chr(10)

User Function ADGPE060P()   

	Local cTexto := ''
	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Consulta Especifica para a Tabela PESSOA DO DIMEP')
	
	cTexto := u_ConsultEspecif("SELECT CONVERT(VARCHAR,NU_MATRICULA) AS NU_MATRICULA,NM_PESSOA,NM_ESTRUTURA FROM [DMPACESSO].[DMPACESSOII].[DBO].[PESSOA] PESSOA INNER JOIN [DMPACESSO].[DMPACESSOII].[DBO].[ESTRUTURA_ORGANIZACIONAL] ESTRUTURA_ORGANIZACIONAL ON ESTRUTURA_ORGANIZACIONAL.CD_ESTRUTURA_ORGANIZACIONAL = PESSOA.CD_ESTRUTURA_ORGANIZACIONAL AND CD_ESTRUTURA_RELACIONADA = 1223 WHERE CD_SITUACAO_PESSOA = 11", "NU_MATRICULA,NM_PESSOA,NM_ESTRUTURA","","NU_MATRICULA")                                   

RETURN(cTexto)

    