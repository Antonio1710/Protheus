//Bibliotecas
#Include "Protheus.ch"
#Include "Topconn.ch"

/*/{Protheus.doc} ADLOG037P
	Validação do campo CPF e Passaporte.
	@author Everson
	@since 22/04/2021
	@version 1.0
	@history Ticket T.I.   - Leonardo P. Monteiro - 22/04/2021 - Alteração no gatilho de validação do CPF e Passaporte no cadastro do veículo.
/*/
User Function ADLOG037P(cCampo) // U_ADLOG037P()
    Local aArea   	:= GetArea()
	Local lRet		:= .T.
	Local cNumCp	:= 0
	Local cValor	:= ""
	Local aCad		:= {}

	cCampo	:= Alltrim(cCampo)

	cNumCp	:= iif(Right(cCampo,1)$"123456789",Right(cCampo,1),"")

	cValor	:= &("M->"+cCampo)
	if Empty(Alltrim(cValor))
			&("M->ZV4_CPF"+cNumCp) 		:= ""
			&("M->ZV4_RG"+cNumCp) 		:= ""
			&("M->ZV4_PASPO"+cNumCp) 	:= ""
			IF Empty(cNumCp)
				M->ZV4_MOTORI 	:= ""
			else
				&("M->ZV4_MOTOR"+cNumCp) 	:= ""
			endif
	else
		if left(cCampo,7) == "ZV4_CPF"
			aCad := fConsZVC(cCampo, cValor)
		elseif left(cCampo,9) == "ZV4_PASPO"
			aCad := fConsZVC(cCampo, cValor)
		endif

		if Len(aCad) != 4
			lRet := .F.
			MsgAlert("Motorista não cadastro. Informe um valor válido!")
		else
			lRet := .T.
			&("M->ZV4_CPF"+cNumCp) 		:= aCad[01]
			&("M->ZV4_RG"+cNumCp) 		:= aCad[02]
			&("M->ZV4_PASPO"+cNumCp) 	:= aCad[03]
			if Empty(cNumCp)
				M->ZV4_MOTORI 	:= aCad[04]
			else
				&("M->ZV4_MOTOR"+cNumCp) 	:= aCad[04]
			endif
		endif
	endif

	restarea(aArea)
return lRet

Static function fConsZVC(cCampo, cValor)
	Local aRet 		:= {}
	Local cQuery 	:= ""

	cQuery := "SELECT ZVC_CPF, ZVC_RG, ZVC_PASPOR, ZVC_MOTORI "
	cQuery += "FROM "+ RetSqlName("ZVC") +" "
	cQuery += "WHERE D_E_L_E_T_='' AND ZVC_FILIAL='"+ xFilial("ZVC") +"' "

	if left(cCampo,7) == "ZV4_CPF"
		cQuery += " AND ZVC_CPF ='"+ Alltrim(cValor) +"' "
	elseif left(cCampo,9) == "ZV4_PASPO"
		cQuery += " AND ZVC_PASPOR ='"+ Alltrim(cValor) +"' "
	endif

	TcQuery cQuery ALIAS "QZVC" NEW

	if QZVC->(!EOF())
		aRet := Array(4)
		aRet[1]	:= QZVC->ZVC_CPF
		aRet[2]	:= QZVC->ZVC_RG
		aRet[3]	:= QZVC->ZVC_PASPOR
		aRet[4]	:= QZVC->ZVC_MOTORI
	endif
	
	QZVC->(DbCloseArea())

return aRet
