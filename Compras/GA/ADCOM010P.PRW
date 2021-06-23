#Include "Protheus.ch"
#Include "TopConn.ch"

//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
//ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
//ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
//ฑฑบPrograma  ณADCOM010P บAutor  ณWilliam Costa       บ Data ณ19/09/2017   บฑฑ
//ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
//ฑฑบDesc.     ณConsulta Especifica para a Tabela SD1 com compra Ordem      บฑฑ
//ฑฑบ          ณe Remessa Ordem                                             บฑฑ
//ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
//ฑฑบUso       ณ SIGACOM                                                    บฑฑ
//ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
//ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
//฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿


/*BEGINDOC
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤxฟ
//ณFun็ใo para consulta gen้rica                                                                              ณ
//ณ@author Daniel Atilio                                                                                      ณ
//ณ@since 15/12/2016                                                                                          ณ
//ณ@version 1.0                                                                                               ณ
//ณ    @param cConsSQLM, Caracter, Consulta SQL                                                               ณ
//ณ    @param cRetorM, Caracter, Campo que serแ retornado                                                     ณ
//ณ    @param cAgrupM, Caracter, Group By do SQL                                                              ณ
//ณ    @param cOrderM, Caracter, Order By do SQL                                                              ณ
//ณ    @return lRetorn, retorno se a consulta foi confirmada ou nใo                                           ณ
//ณ    @example                                                                                               ณ
//ณ    lOK := u_zConsSQL("SELECT B1_COD, B1_DESC FROM SB1010 WHERE D_E_L_E_T_ = ' ' ", "B1_COD", "", "B1_COD")ณ
//ณ    ...                                                                                                    ณ
//ณ    u_zConsSQL("SELECT * FROM ZA0990", "ZA0_COD", "", "")                                                  ณ
//ณ    ...                                                                                                    ณ
//ณ    @obs O retorno da consulta ้ p๚blica (__cRetorno) para ser usada em consultas especํficas              ณ
//ณ    A consulta nใo pode ter ORDER BY, pois ele jแ ้ especificado em um parโmetro                           ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤxู
ENDDOC*/

//Constantes
#Define STR_PULA        Chr(13)+ Chr(10)

User Function ADCOM010P()   

	Local cTexto := ''
	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')
	
	cTexto := u_ConsultEspecif("SELECT D1_FILIAL,D1_DOC,D1_SERIE,D1_ITEM,D1_FORNECE,D1_LOJA,D1_COD FROM SD1010 WHERE D_E_L_E_T_<>'*' AND D1_EMISSAO>=CONVERT(VARCHAR(8),(GETDATE()-60),112) AND D1_CF IN('2118','1118')", "D1_FILIAL,D1_DOC,D1_SERIE,D1_ITEM,D1_FORNECE,D1_LOJA","","D1_DOC")                                   

RETURN(cTexto)

    