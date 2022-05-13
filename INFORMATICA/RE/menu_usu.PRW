#include "protheus.ch"

/*/{Protheus.doc} User Function TRAZMENU
    
    Chamado 
    @type  Function
    @author Adoro
    @since 99/99/9999
    @version 01
    @history Chamado n. TI - Leonardo P. Monteiro - 09/02/2022 - Retirada da função U_ADINF009P.

/*/
USER FUNCTION TRAZMENU()

	Local ex        := 0
	Local nZ        := 0
	Local nX        := 0
	LOCAL aAllUser	:= AllUsers()
	//LOCAL aGrupos	:= AllGroups() 
	


	cFileLog := ""
	cPath := GetSrvProfString("StartPath","")
	AutoGrLog("COD;USUARIO;EMPRESA;DEPARTAMENTO;EMAIL;DT.ULT.ALT.;PASTA IMPRESSÃO;MODULO;NIVEL;MENUS;MATRICULA;")
	lTemMenu:= .F.

	FOR nZ :=1 TO Len(aAllUser)

		aMenus	:= aAllUser[nz][3] 
		lLibBlq := aAllUser[nz][1][17] // Usuario Bloqueado

	IF !lLibBlq       

		cEmpresas := ""
		FOR ex := 1 TO len(aAllUser[NZ][2][6]) //empresas

			cEmpresas += alltrim(aAllUser[NZ][2][6][ex])+"/ "

		NEXT
		lTemMenu:= .F.

			FOR nX := 1 TO Len(aMenus)

				IF Subs(aMenus[nX],3,1)<>"X"
					lTemMenu:= .T.
					
					AutoGrLog(aAllUser[nz][1][1]+";"+aAllUser[nz][1][2]+";"+padr(cEmpresas,200)+";"+aAllUser[nz][1][12]+";"+aAllUser[nz][1][14]+";"+DTOC(aAllUser[nz][1][16])+";"+aAllUser[nz][2][3]+";"+Substr(aMenus[nX],1,2)+";"+Substr(aMenus[nX],3,1)+";"+Substr(aMenus[nX],4,100)+";"+ AALLUSER[nz][1][22]+";")
					cFileLog := "LOG_MENU.TXT"

				ENDIF
			NEXT nX 

			IF !lTemMenu

				//AutoGrLog(aAllUser[nz][1][1]+";"+aAllUser[nz][1][2]+";"+padr(cEmpresas,200)+";"+aAllUser[nz][1][12]+";"+aAllUser[nz][1][14]+";"+DTOC(aAllUser[nz][1][16])+";"+aAllUser[nz][2][3]+";;")
				  AutoGrLog(aAllUser[nz][1][1]+";"+aAllUser[nz][1][2]+";"+padr(cEmpresas,200)+";"+aAllUser[nz][1][12]+";"+aAllUser[nz][1][14]+";"+DTOC(aAllUser[nz][1][16])+";"+aAllUser[nz][2][3]+";"+Substr(aMenus[nX],1,2)+";"+Substr(aMenus[nX],3,1)+";"+Substr(aMenus[nX],4,100)+";"+ AALLUSER[nz][1][22]+";")
				cFileLog := "LOG_MENU.TXT" 

			ENDIF
		ENDIF
		
	NEXT NZ

	IF cFileLog <> ""

		MostraErro(cPath,cFileLog)

	ENDIF
		
	ALERT("Gerado log "+cpath+cfilelog)

RETURN(NIL)
