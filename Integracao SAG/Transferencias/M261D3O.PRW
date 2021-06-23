#INCLUDE "rwmake.ch"
#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³M261D3O   ºAutor  ³Microsiga           º Data ³  10/2013    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Grava campos customizados no SD3 apos trasnferencia         º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ generico                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/


User Function M261D3O()
	
	Local aAreaAnt  := GetArea()
	
	If IsInCallStack("U_MSD2460") .or. IsInCallStack("U_MSD2520") .OR. IsInCallStack("U_M460FIM") .OR. IsInCallStack("U_FAT002")

		RecLock("SD3",.F.)	
		//Replace D3_XRECSD2 with ALLTRIM(STR(SD2->(Recno())))
		Replace D3_XRECSD2 with SD2->(Recno())
		Replace D3_XSD2KEY with SD2->(D2_FILIAL+ D2_DOC+ D2_SERIE+ D2_CLIENTE+ D2_LOJA+ D2_COD+ D2_ITEM)
		MsUnlock()
		
	EndIf 
	
	If IsInCallStack("U_MT103FIM") //chamado 036068 sigoli 25/07/2017
	   
		RecLock("SD3",.F.)	
		Replace D3_XRECSD2 with SD1->(Recno())
		Replace D3_XSD2KEY with SD1->(D1_FILIAL+ D1_DOC+ D1_SERIE+ D1_FORNECE+ D1_LOJA+ D1_COD+ D1_ITEM)
		MsUnlock()
	
	
	EndIf		
	RestArea(aAreaAnt)

Return

