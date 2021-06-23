#INCLUDE "rwmake.ch"
#INCLUDE "Protheus.ch"

/*/
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北赏屯屯屯屯脱屯屯屯屯屯送屯屯屯淹屯屯屯屯屯屯屯屯屯退屯屯屯淹屯屯屯屯屯屯槐�
北篜rograma  矨DEST027P � Autor � WILLIAM COSTA      � Data �  17/04/2018 罕�
北掏屯屯屯屯拓屯屯屯屯屯释屯屯屯贤屯屯屯屯屯屯屯屯屯褪屯屯屯贤屯屯屯屯屯屯贡�
北篋escri噭o � Programa para alteracao do parametro MV_DBLQMOV            罕�
北�          �                                                            罕�
北掏屯屯屯屯拓屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡�
北篣so       �                                                            罕�
北韧屯屯屯屯拖屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯急�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌
/*/
User Function ADEST027P()

	Local aAreaAnt := GetArea()
	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Programa para alteracao do parametro MV_DBLQMOV')
	
	IF MsgBox("O per韔do atualmente esta fechado at� o dia: " + (DTOC(STOD(DTOS(GETMV("MV_DBLQMOV")))))+"."+ CHR(13)+ CHR(13)+ "Deseja alterar o par鈓etro?"," Altera par鈓etro MV_DBLQMOV ","YESNO")
	
		IF(PERGUNTE(PADR("ADEST027P",10,"")))
		
			PutMv("MV_DBLQMOV",	DTOC(MV_PAR01))
		 
		ENDIF
	
	ENDIF
	
	RestArea(aAreaAnt)

Return 