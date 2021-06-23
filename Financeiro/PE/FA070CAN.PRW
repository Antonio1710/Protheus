#include "rwmake.ch"
#include "protheus.ch" 


/*/{Protheus.doc} User Function FA070CAN
    P.E O ponto de entrada FA070CAN sera executado apos gravacao dos dados de cancelamento no SE1 e    |
	antes de estornar os dados do SE5 e de comissao.
    @type Function
    @author Fernado Sigoli
    @since 19/12/2016
    @version version 027642
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    @history ticket 13678   - Leonardo P. Monteiro - 12/05/2021 - Tratamento dos cancelamentos de baixas dos títulos AB- para uma nova contabilização.
/*/     
User Function FA070CAN()    
    
Local aArea   := GetArea() 
Local cPrefx    := SE1->E1_PREFIXO
Local cTitulo   := SE1->E1_NUM
Local cParcel 	:= SE1->E1_PARCELA
Local cTipEsc	:= Alltrim(SupergetMV("MV_#070CAA",,"AB-"))

dbSelectArea("SE1")
DbSetOrder(1)
If dbSeek(xFilial("SE1")+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA)    
	While !Eof() .and. SE1->E1_PREFIXO = cPrefx .and. SE1->E1_NUM = cTitulo .and. SE1->E1_PARCELA = cParcel
		If  !EMPTY(SE1->E1_XDTDISP) .and. EMPTY(SE1->E1_BAIXA)
			RecLock("SE1",.F.)
			Replace E1_XDTDISP With Stod("") //CRIAR CAMPO  NA SE1 E1_XDTDISP

			//Ticket 13678   - Leonardo P. Monteiro - 12/05/2021 - Tratamento dos cancelamentos de baixas dos títulos AB- para uma nova contabilização.
			//Simula a limpeza do campo de contabilização como no parâmetro MV_CTBAPLA contidos no parâmetro V_#070CAA. Tratamento dos títulos AB-.
			IF Alltrim(SE1->E1_TIPO)$cTipEsc .and. Empty(SE1->E1_BAIXA)
				Replace E1_LA With "" // Libera o título AB- para uma nova contabilização.
			endif
			MsUnlock()
		EndIf	
  	DbSkip()
	Enddo
Endif

RestArea(aArea)

Return(.T.) 
