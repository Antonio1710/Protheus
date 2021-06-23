#include "protheus.ch"

/*/{Protheus.doc} User Function MT120TEL
	(long_description)
	@type  Function
	@author FWNM
	@since 17/04/2020
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@chamado n. 057440 || OS 058919 || TECNOLOGIA || LUIZ || 8451 || HIST. APROVACAO
	@history Chamado 057827 - FWNM          - 30/04/2020 - || OS 059306 || SUPRIMENTOS || IARA_MOURA || 8415 || ERRO LOG
/*/
User Function MT120TEL()

	Local oNewDialog	:= PARAMIXB[1]
	Local aPosGet		:= PARAMIXB[2]
	Local aObj			:= PARAMIXB[3]
	Local nOpcx			:= PARAMIXB[4]
	Local nReg			:= PARAMIXB[5]
                                                                       
	SC7->( MsGoTo(nReg) )                    

	If IsInCallStack("A120Copia") // Chamado n. 057827 || OS 059306 || SUPRIMENTOS || IARA_MOURA || 8415 || ERRO LOG - FWNM - 30/04/2020

		If lSubsPC // Variável Pública inicializada no PE MT120CPE contido dentro do MT120F.PRW
																												
			@ 038,aPosGet[1,1]+22 SAY "(PC Substituição)" OF oNewDialog PIXEL SIZE 080,012

			@ 038,aPosGet[1,1]+132 SAY "PC Original" OF oNewDialog PIXEL SIZE 030,008
			@ 037,aPosGet[1,2]+087 MSGET SC7->C7_NUM WHEN .F. OF oNewDialog PIXEL SIZE 020,006
			
		EndIf

	EndIf

Return