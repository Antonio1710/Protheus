#include "rwmake.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ MTA920L  ³ HCCONSYS  			            ³ Data ³ 01/12/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Ponto de entrada para tratar a entrada de NF 			     ³±±
±±³          ³ Livros Fiscais                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function MTA920L()

local _cArea	:= GetArea()
local _cAreaSF1 := SF1->(GetArea())
local _cAreaSD1 := SD1->(GetArea())
local _cAreaSF4 := SF4->(GetArea())
local _cAreaSF3 := SF3->(GetArea()) 
Local _cEspNf := ""
Local _Lipi   := .T.     

_nD1ValCont := _nD1BasICM := _nD1ValICM := _nD1BasIPI := _nD1ValIPI := _nD1BasIm5 := _nD1BasIm6 := _nD1ValIm5 := 0
_nD1ValIm6 	:= _nD1ValDes := 0

//If ALLTRIM(SF1->F1_ORIGEM)   == "ADRANFIMP"   .and. Alltrim(FunName()) == "ADRANFIMP"
If Alltrim(FunName()) == "ADRANFIMP"

	dbselectarea("SD1")
	dbsetorder(1)
	SD1->(dbseek(xfilial("SD1") + SF3->F3_NFISCAL + SF3->F3_SERIE + SF3->F3_CLIEFOR + SF3->F3_LOJA,.t. ))

	while SD1->(!Eof())	.AND. SD1->D1_DOC == SF1->F1_DOC .AND. SD1->D1_SERIE == SF1->F1_SERIE .AND. ;
								SD1->D1_FORNECE == SF1->F1_FORNECE .AND. SD1->D1_LOJA == SF1->F1_LOJA
	
		    //If SF3->F3_ALIQICM == SD1->D1_PICM

				DbSelectArea("SF4")
				DbSetOrder(1)
				DbSeek(xfilial("SF4")+SD1->D1_TES )
				IF FOUND()          //&& Chamado 006475 - Mauricio. Tratamento para IPI isento.
				   if SF4->F4_LFIPI == "I"
				      _LIPI := .T.
				   ELSE
				      _LIPI := .F.
				   ENDIF   
				ENDIF     
				
			   /*
				IF SF4->F4_DESPICM == "1"         
					IF SF4->F4_BASEICM > 0  	&& Se tiver reducao de Base de ICMS
					   _nD1ValCont    += SD1->D1_TOTAL  + SD1->D1_DESPESA + SD1->D1_VALICM + SD1->D1_VALIPI + SD1->D1_VALIMP5 + SD1->D1_VALIMP6 
					Else                                               
						_nD1ValCont    += SD1->D1_BASEICM
					Endif
				Else
					If 	SF4->F4_BASEICM > 0  && Se tiver reducao de Base de ICMS
					   	_nD1ValCont    += SD1->D1_TOTAL  + SD1->D1_DESPESA + SD1->D1_VALICM + SD1->D1_VALIPI + SD1->D1_VALIMP5 + SD1->D1_VALIMP6 
					Else                                               
				   		_nD1ValCont    += SD1->D1_BASEICM  + SD1->D1_DESPESA
				 	Endif
				 	
				Endif
				*/                               
				_nD1ValCont    += SD1->D1_BASEICM
			   _nD1BasICM  	+= SD1->D1_BASEICM
			   _nD1ValICM 		+= SD1->D1_VALICM
			   _nD1BasIPI  	+= SD1->D1_BASEIPI
			   _nD1ValIPI 		+= SD1->D1_VALIPI
			   _nD1BasIm5		+= SD1->D1_BASIMP5
			   _nD1BasIm6 		+= SD1->D1_BASIMP6
			   _nD1ValIm5		+= SD1->D1_VALIMP5
			   _nD1ValIm6 		+= SD1->D1_VALIMP6
	         _nD1ValDes		+= SD1->D1_DESPESA

			SD1->(dbskip())

	EndDo
	
	If cfilant == "02" .OR. CFILANT == "03"
	   _cEspNf := "SPED"
	   
	   IF _LIPI
	     dbSelectArea("SF3")
	     Reclock("SF3",.F.)
		   SF3->F3_VALCONT 		:= _nD1ValCont
		   SF3->F3_BASEICM		:= 0.00                       //_nD1BasICM 
		   SF3->F3_OUTRICM 		:= _nD1ValCont - _nD1ValIPI   //  - _nD1BasICM
		   SF3->F3_OUTRIPI 		:= 0.00
		   SF3->F3_ISENIPI      := _nD1ValCont - _nD1ValIPI 	
		   SF3->F3_VALICM 		:= 0.00                       //_nD1ValICM
		   SF3->F3_ICMSCOM      := 0.00 
		   SF3->F3_BASEIPI		:= 0.00                       //_nD1BasIPI
		   SF3->F3_VALIPI   		:= 0.00                       //_nD1ValIPI
		   SF3->F3_BASIMP5		:= _nD1BasIm5
		   SF3->F3_BASIMP6		:= _nD1BasIm6
		   SF3->F3_VALIMP5		:= _nD1ValIm5
		   SF3->F3_VALIMP6		:= _nD1ValIm6
		   SF3->F3_DESPESA		:= _nD1ValDes
		   SF3->F3_REPROC			:= "N"
		   SF3->F3_ESPECIE		:= _cEspNf
	     MsUnlock("SF3")	   
	   ELSE 
	     dbSelectArea("SF3")
	     Reclock("SF3",.F.)
		   SF3->F3_VALCONT 		:= _nD1ValCont
		   SF3->F3_BASEICM		:= 0.00                       //_nD1BasICM 
		   SF3->F3_OUTRICM 		:= _nD1ValCont - _nD1ValIPI   //  - _nD1BasICM
		   SF3->F3_OUTRIPI 		:= _nD1ValCont - _nD1ValIPI 	
		   SF3->F3_VALICM 		:= 0.00                       //_nD1ValICM
		   SF3->F3_ICMSCOM      := 0.00 
		   SF3->F3_BASEIPI		:= 0.00                       //_nD1BasIPI
		   SF3->F3_VALIPI   		:= 0.00                       //_nD1ValIPI
		   SF3->F3_BASIMP5		:= _nD1BasIm5
		   SF3->F3_BASIMP6		:= _nD1BasIm6
		   SF3->F3_VALIMP5		:= _nD1ValIm5
		   SF3->F3_VALIMP6		:= _nD1ValIm6
		   SF3->F3_DESPESA		:= _nD1ValDes
		   SF3->F3_REPROC			:= "N"
		   SF3->F3_ESPECIE		:= _cEspNf
	     MsUnlock("SF3")
       ENDIF
   else
	   _cEspNf := "NF"
	   dbSelectArea("SF3")
	   Reclock("SF3",.F.)
		   SF3->F3_VALCONT 		:= _nD1ValCont
		   SF3->F3_BASEICM		:= _nD1BasICM 
		   SF3->F3_OUTRICM 		:= _nD1ValCont //  - _nD1BasICM	
		   SF3->F3_VALICM 		:= _nD1ValICM 
		   SF3->F3_BASEIPI		:= _nD1BasIPI
		   SF3->F3_VALIPI   		:= _nD1ValIPI
		   SF3->F3_BASIMP5		:= _nD1BasIm5
		   SF3->F3_BASIMP6		:= _nD1BasIm6
		   SF3->F3_VALIMP5		:= _nD1ValIm5
		   SF3->F3_VALIMP6		:= _nD1ValIm6
		   SF3->F3_DESPESA		:= _nD1ValDes
		   SF3->F3_REPROC			:= "N"
		   SF3->F3_ESPECIE		:= _cEspNf
	   MsUnlock("SF3")   
	endif      
Endif

RestArea(_cAreaSF1)
RestArea(_cAreaSD1)
RestArea(_cAreaSF4)
RestArea(_cAreaSF3)
RestArea(_cArea)

Return()
