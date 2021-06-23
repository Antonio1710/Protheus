#INCLUDE "rwmake.ch"
#include "Protheus.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ          บ Autor ณ Everaldo Casaroli  บ Data ณ  14/07/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Programa para alteracao do parametro MV_DATAFIS            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAltera็ใo ณ Ch. 048912 - ABEL BABINI | DEJAIME | FISCAL | Cria Bloqueioบฑฑ
ฑฑบ          ณ por data de emissใo de documentos                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
User Function ADTFIS()
	Local aAreaAnt := GetArea() 
	  
	Static oDlg
	Static oRadMenu1
	Static nRadMenu1 := 1
	Static oSay1       

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Programa para alteracao do parametro MV_DATAFIS')   
	
	DEFINE MSDIALOG oDlg TITLE "Altera็ใo de Parametro" FROM 000, 000  TO 250, 300 COLORS 0, 16777215 PIXEL
	
	@ 036, 047 RADIO oRadMenu1 VAR nRadMenu1 ITEMS "Liberacao de Estoque","Data Fiscal","Data Emissใo" SIZE 064, 016 OF oDlg COLOR 0, 16777215 PIXEL
	@ 018, 022 SAY oSay1 PROMPT "Escolha o parametro que deseja alterar:" SIZE 103, 008 OF oDlg COLORS 0, 16777215 PIXEL
	@ 088, 026 BUTTON "Confirmar" SIZE 034, 018 OF oDlg PIXEL ACTION ( nOpc := 1, oDlg:End()) OF oDlg PIXEL
	@ 087, 087 BUTTON "Cancelar"  SIZE 034, 018 OF oDlg PIXEL ACTION ( nOpc := 0, oDlg:End()) OF oDlg PIXEL
	ACTIVATE MSDIALOG oDlg CENTERED
	                   
	If nOpc == 1
		If nRadMenu1 == 1  
	       if ALLTRIM(__cUserID) $ GETMV("MV_#USULIB")   //usuario liberacao de estoque 	                                     
		      If GETMV("MV_ESTNEG") == "N"	
			     IF MsgBox("O parametro de Estoque Negativo esta bloqueado"+ CHR(13)+ CHR(13)+ "Deseja liberar o parโmetro?"," Altera parโmetro MV_ESTNEG ","YESNO")    	
		    		PutMv("MV_ESTNEG","S")
				 Endif
			  Else
				 IF MsgBox("O parametro de Estoque Negativo esta desbloqueado"+ CHR(13)+ CHR(13)+ "Deseja bloquear o parโmetro?"," Altera parโmetro MV_ESTNEG ","YESNO")    	
		    		PutMv("MV_ESTNEG","N")
				 Endif	
			  Endif	
		   ELSE
		      ALERT("Usuario sem permissao para alterar o parametro de Estoque Negativo")
		      return
		   ENDIF
		//Else     	// ABEL BABINI 06/05/2019 CHAMADO 048912 | FISCAL | DEJAIME | Impede a entrada de documentos com data de emissใo anterior เ permitida
		Elseif nRadMenu1 == 2       
	       if ALLTRIM(__cUserID) $ GETMV("MV_#USUDTF")   //usuario ALTERA DATA DE FECHAMENTO DO ESTOQUE.	                                     	
	          IF MsgBox("O perํodo atualmente esta fechado at้ o dia: " + (DTOC(STOD(DTOS(GETMV("MV_DATAFIS")))))+"."+ CHR(13)+ CHR(13)+ "Deseja alterar o parโmetro?"," Altera parโmetro MV_DATAFIS ","YESNO")    		
			     IF(PERGUNTE("ADTFIS"))
					PutMv("MV_DATAFIS",	DTOS(MV_PAR01)) 
				 Endif
			  Endif	
		   else     
		      ALERT("Usuario sem permissao para alterar a data de fechamento de estoque")
		      return	   
		   endif
		// INICIO ABEL BABINI 06/05/2019 CHAMADO 048912 | FISCAL | DEJAIME | Impede a entrada de documentos com data de emissใo anterior เ permitida
		Elseif nRadMenu1 == 3
	       if ALLTRIM(__cUserID) $ GETMV("MV_#USUDTF")   //usuario ALTERA DATA DE FECHAMENTO DE DATA DE EMISSรO	                                     	
	          IF MsgBox("O perํodo atualmente esta fechado at้ o dia: " + (DTOC(GETMV("MV_#DTEMIS")))+"."+ CHR(13)+ CHR(13)+ "Deseja alterar o parโmetro?"," Altera parโmetro MV_#DTEMIS ","YESNO")    		
			     IF(PERGUNTE("ADTFIS"))
					PutMv("MV_#DTEMIS",	DTOS(MV_PAR01)) 
				 Endif
			  Endif	
		   else     
		      ALERT("Usuario sem permissao para alterar a data de fechamento de estoque")
		      return	   
		   endif
		// FIM ABEL BABINI 06/05/2019 CHAMADO 048912 | FISCAL | DEJAIME | Impede a entrada de documentos com data de emissใo anterior เ permitida
		Endif
	Endif	
	
	RestArea(aAreaAnt)

Return 