#include "TOTVS.CH"
#include "PROTHEUS.CH"
#Include "topconn.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ADFIN042P ³ Autor ³ Mauricio - MDS TEC    ³ Data ³22.09.17  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Rotina executada manualmente. Tem o objetivo de bloquear os ³±±
±±³ titulos no contas a pagar por lote conforme parametros                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Atendimento do  Chamado 037215                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
     
USER FUNCTION ADFIN042P()  

Private oOK 	:= LoadBitmap( GetResources(), "CHECKED" )
Private oNO 	:= LoadBitmap( GetResources(), "UNCHECKED" )
Private lMark   := .F.
Private lChk    := .F.
Private oDLG
Private _aTits	:= {}
Private _cPerg  := "BLQSE2"

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Rotina executada manualmente. Tem o objetivo de bloquear os titulos no contas a pagar por lote conforme parametros')

PutSx1(_cPerg,"01","Do Fornecedor          ?","Do Fornecedor          ?","Do Fornecedor          ?","mv_ch1","C",6 ,0,0,"G",""         ,"SA2","","","mv_par01",""      ,"","","","","","","","","","","","","","","")
PutSx1(_cPerg,"02","Ate Fornecedor         ?","Ate Fornecedor         ?","Ate Fornecedor         ?","mv_ch2","C",6 ,0,0,"G",""         ,"SA2","","","mv_par02",""      ,"","","","","","","","","","","","","","","")
PutSX1(_cPerg,"03","Titulo De" ,"Titulo De","Titulo De","mv_ch3","C",9,0,0,"G","","","","","mv_par03" ,"    "          ,"","","",""               ,"","",     "","","","","","","",""," ")
PutSX1(_cPerg,"04","Titulo Ate","Titulo Ate","Titulo Ate","mv_ch4","C",9,0,0,"G","","","","","mv_par04" ,"    "          ,"","","",""               ,"","",     "","","","","","","",""," ")
PutSX1(_cPerg,"05","Dt Emissao De "          ,"Dt Emissao De "      ,"Dt Emissao De "      ,"mv_ch5","D",08,0,0,"G",""         ,"","","","mv_par01" ,"","","","","","","","","","","","","","",""," ")
PutSX1(_cPerg,"06","Dt Emissao Ate "         ,"Dt Emissao Ate "     ,"Dt Emissao Ate "     ,"mv_ch6","D",08,0,0,"G",""         ,"","","","mv_par02" ,"","","","","","","","","","","","","","",""," ")

Pergunte(_cPerg,.T.)

DEFINE MSDIALOG oDlg TITLE OemToAnsi("Bloquear titulos Contas a Pagar") FROM 115,085 TO 620,1200 COLORS 0, 16777215 PIXEL   // 115,085  TO 850,1300
 
@ 004,014 CHECKBOX oChk VAR lChk PROMPT "Marca/Desmarca" SIZE 60,007 PIXEL OF oDlg ;
    ON CLICK(aEval(_aTits,{|x| x[1]:=lChk}), oTIT:Refresh()) 
                                                                                           
    oTIT := TWBrowse():New( 20 , 10, 500,200,,{OemToAnsi(" "),OemToAnsi("Prefixo       "),OemToAnsi("Numero    "),OemToAnsi("Parcela    "),OemToAnsi("Tipo   "),OemToAnsi("Codigo      "),;
                                             OemToAnsi("Loja "),OemToAnsi("Nome                                    "),OemToAnsi("Emissao          "),OemToAnsi("VencRea           "),;
                                             OemToAnsi("VALOR               "),OemToAnsi("SALDO               ")},;
                                             {15,10,20,10,10,10,10,30,30,30,40,40},;
                              oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, ) 
                              
                                                                                                                                                     
    MsAguarde( {|| AtuListBox( @_aTits) }, OemToAnsi( "Aguarde" ) )
                              
    oTIT:SetArray(_aTits)
    
    oTIT:bLine := { || { If(_aTits[oTIT:nAt][01],oOk,oNo),;
                           _aTits[oTIT:nAt][02],;
						   _aTits[oTIT:nAt][03],;
						   _aTits[oTIT:nAt][04],;
						   _aTits[oTIT:nAt][05],;
						   _aTits[oTIT:nAt][06],;
						   _aTits[oTIT:nAt][07],;
						   _aTits[oTIT:nAt][08],;
						   _aTits[oTIT:nAt][09],;
						   _aTits[oTIT:nAt][10],;
						   _aTits[oTIT:nAt][11],;						   
						   _aTits[oTIT:nAt][12]}}                
						       
    oTIT:bLDblClick := {|| _aTits[oTIT:nAt][1] := !_aTits[oTIT:nAt][1],;
                              oTIT:DrawSelect()} 
                                                                                             
    @ 230,050 BUTTON "BLOQUEAR"  SIZE 040,020 PIXEL OF oDlg Action (MsAguarde( {|| U_BLOQTIT() }, OemToAnsi( "Aguarde" ) ))
    
    @ 230,340 BUTTON "SAIR" SIZE 040,020 PIXEL OF oDlg Action oDlg:End()
    
    ACTIVATE DIALOG ODLG CENTERED                                                
                                         
Return()

Static Function AtuListBox( _aTits)            
      
_aTits := {}

If Select("TSE2") > 0
   DbSelectArea("TSE2")
   DbCloseArea("TSE2")
Endif
	
cQuery:=" SELECT E2_FILIAL,E2_PREFIXO,E2_NUM,E2_PARCELA,E2_TIPO,E2_FORNECE,E2_LOJA,E2_NOMFOR,E2_VALOR, E2_SALDO, E2_EMISSAO, E2_VENCREA "
cQuery+=" FROM " + RetSqlName("SE2") + " WITH(NOLOCK) "
cQuery+=" WHERE D_E_L_E_T_ <> '*' AND E2_FILIAL = '"+cFilAnt+"' "    &&filial corrente somente
cQuery+=" AND E2_FORNECE BETWEEN '" + mv_par01 + "' AND '" + mv_par02 + "'"	
cQuery+=" AND E2_NUM BETWEEN '" + mv_par03 + "' AND '" + mv_par04 + "' "
cQuery+=" AND E2_EMISSAO BETWEEN '" + DTOS(mv_par05) + "' AND '" + DTOS(mv_par06) + "' "
cQuery+=" AND E2_DATALIB <> ' ' AND E2_SALDO > 0 "   &&Tras somente liberados e tras somente com saldo em aberto			
cQuery+=" ORDER BY E2_FILIAL,E2_FORNECE,E2_LOJA,E2_PREFIXO,E2_NUM,E2_PARCELA "
	
TCQUERY cQuery NEW ALIAS "TSE2"
	
dbselectArea("TSE2")
DbgoTop()
While TSE2->(!Eof())
      AADD( _aTits, {lMark,TSE2->E2_PREFIXO,TSE2->E2_NUM,TSE2->E2_PARCELA,TSE2->E2_TIPO,TSE2->E2_FORNECE,TSE2->E2_LOJA,TSE2->E2_NOMFOR,DTOC(STOD(TSE2->E2_EMISSAO)),DTOC(STOD(TSE2->E2_VENCREA)),transform(TSE2->E2_VALOR,"@E 99,999,999.99"),transform(TSE2->E2_SALDO,"@E 99,999,999.99")  } )
      TSE2->(dbSkip())
Enddo      
      
If Len(_aTits) <= 00    
	AADD(_aTits,{lMark,OemToAnsi("Nao existem dados" ),"","","","","","","","","",Transform(0,"@E 9,999,999,999.99" ),Transform(0,"@E 9,999,999,999.99" )})               
EndIf

Return(Nil)

User Function BLOQTIT()

For _n1 := 1 to Len(_aTits)   
	If _aTits[_n1][01]
		_cTIT   := _aTits[_n1][02]+_aTits[_n1][3]+_aTits[_n1][4]+_aTits[_n1][5]+_aTits[_n1][6]+_aTits[_n1][7]
		
		dbSelectArea("SE2")
		dbSetOrder(1)
		If  dbSeek(xfilial("SE2")+_cTIT)			
					
		   IF SE2->E2_RJ = ' '
		  	RecLock("SE2",.F.)
				Replace SE2->E2_RJ With 'X'
				Replace SE2->E2_HIST With 'BLOQUEADO DEPT.FINANCEIRO'
				Replace SE2->E2_DATALIB With CtoD('')
			MsUnlock()
			
			IF SE2->E2_TIPO = 'NF'
			
				cFil     := SE2->E2_FILIAL
				cSerie   := SE2->E2_PREFIXO
				cDoc     := SE2->E2_NUM
				cFornece := SE2->E2_FORNECE
				cLoja    := SE2->E2_LOJA
				SqlF050Bloq() 
			
				While TRB->(!EOF())
				   
				    DBSELECTAREA("SF1")
			        DbSetOrder(1)
			        IF DBSEEK(cFil+cDoc+cSerie+cFornece+cLoja,.T.)          
				    	RecLock("SF1",.F.)
				    	    SF1->F1_XANTSTA = SF1->F1_STATUS
							SF1->F1_STATUS = 'B'							 
						MsUnlock()  
					
			        ENDIF    
			        SF1->(dbCloseArea())	
			        
		         	TRB->(dbSkip())
				ENDDO
				TRB->(dbCloseArea())
				
				cFil     := ''
				cSerie   := ''
				cDoc     := ''
				cFornece := ''
				cLoja    := ''
			ENDIF	//fecha bloqueio no documento de entrada
		   ENDIF
		
		ENDIF
				
	EndIf
Next

oDlg:End()

Return()
        

STATIC FUNCTION SqlF050Bloq()  

	BeginSQL Alias "TRB"
			%NoPARSER% 
				SELECT F1_FILIAL,F1_DOC,F1_FORNECE,F1_LOJA,F1_TIPO,F1_STATUS
				  FROM %Table:SF1%
				 WHERE F1_FILIAL   = %exp:cFil%
				   AND F1_SERIE    = %exp:cSerie%
				   AND F1_DOC      = %exp:cDoc%
				   AND F1_FORNECE  = %exp:cFornece%
				   AND F1_LOJA     = %exp:cLoja%
				   AND D_E_L_E_T_ <> '*'
	EndSQl             

RETURN(NIL)