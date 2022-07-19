#include "TOTVS.ch"
#Include "RwMake.ch"             
#Include "Protheus.ch"
#Include "Topconn.ch" 
#INCLUDE "MntTRCell.ch"

/*/{Protheus.doc} User Function EECAE100()
	Tornar obrigatorio o cpo DtDue qdo o Cpo DtEmbarque estiver preenchido
	@type  Function
	@author Antonio Domingos
	@since 18/07/2022
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@history ticket 073213 - Antonio Domingos - 18/07/2022 - Tornar obrigatorio o cpo DtDue qdo o Cpo DtEmbarque estiver preenchido
/*/ 
User Function EECAE100()
Local cParamIXB := ""
Local _lRetExp := .T.
Local _lMV_XAE100A := SuperGetMV("MV_XAE100A",.F.,.T.) //Ativa Validação do campo DtDue obrigatorio quando a Data de Embarque estiver preenchida

   If ValType(ParamIXB) == "A"
      cParamIXB:= ParamIXB[1]
   Else
      cParamIXB:= ParamIXB
   EndIf
 
   If _lMV_XAE100A //Se parametro de validação estiver ativo
      Do Case
             Case ALLTRIM(cParamIXB) == "EMB_LINOK" 
            If !Empty(M->EEC_DTEMBA) .And. Empty(M->EEC_DTDUE)
               Aviso("Atenção","Quando a Data de Embarque estiver preenchida o campo DtDue é obrigatório!", {"OK"}, 3)
               _fGetDtDue()
            EndIf
         
      EndCase
   EndIf

Return _lRetExp
/*/{Protheus.doc} Static Function _fGetDtDue()
	Digitação do Campo DtDue
	@type  Function
	@author Antonio Domingos
	@since 19/07/2022
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@history ticket 073213 - Antonio Domingos - 19/07/2022 - Tornar obrigatorio o cpo DtDue qdo o Cpo DtEmbarque estiver preenchido
/*/ 
Static Function _fGetDtDue()

   Local _dDtEmb  := M->EEC_DTEMBA
   Local _dDtDue   := M->EEC_DTDUE

While .T.


   DEFINE MSDIALOG oDlg FROM	18,1 TO 100,350 TITLE "Digite a Data Due " PIXEL  
	
   @  1, 3 	TO 38, 242 OF oDlg  PIXEL
   @ 005,037 Say "Data Emb." SIZE 70, 7 OF oDlg PIXEL
   @ 005,077 GET _dDtEmb   WHEN .F. SIZE 30, 9 OF oDlg PIXEL
   @ 015,037 Say "Data Due"         SIZE 30, 7 OF oDlg PIXEL
   @ 015,077 Get _dDtDue            SIZE 30, 9 OF oDlg PIXEL
   
   DEFINE SBUTTON FROM 26,126 TYPE 1 ACTION oDlg:End() ENABLE OF oDlg

   Activate Dialog oDlg CENTERED

      If !Empty(_dDtDue)
         M->EEC_DTDUE := _dDtDue
         Exit
      Else
         Aviso("Atenção","Quando a Data de Embarque estiver preenchida o campo DtDue é obrigatório!", {"OK"}, 3)
      EndIf

EndDo

Return

