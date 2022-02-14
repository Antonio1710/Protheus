#Include "Protheus.ch"
/*/{Protheus.doc} User Function ADCOM039P
    Inicializador padrão de campo.
    @type  Function
    @author Everson
    @since 21/10/2020
    @version 01
    @history ticket TI, Everson, 11/05/2021 - Colocado tratamento para cópia.
    @history ticket TI, Sigoli,  12/05/2021 - Colocado tratamento Default lCopia := .F.
	/*/
User Function ADCOM039P(cCmp) // U_ADCOM039P()

    //Variáveis.
    Local aArea := GetArea()
    Local nPos  := 0
    Local cRet  := ""

    //
    Default cCmp   := "C7_OP"
	Default lCopia := .F.
	
    //
    cRet := Space(TamSX3(cCmp)[1])

    //
    If Type("aCols") == "A" .And. Type("aHeader") == "A" .And. Type("n") == "N" .And. cFilAnt $GetMv("MV_#OPCOMP",,"") .And. ! lCopia //ticket TI - Everson - 11/05/2021.

        //
        nPos := aScan( aHeader, { |x| AllTrim( x[2] ) == cCmp } )

        //
        If nPos > 0 .And. n > 1 .And.;
            Empty(Alltrim(aCols[n][nPos])) .And.;
            ! Empty(Alltrim(aCols[1][nPos])) .And.;
            ! aCols[1,Len(aHeader) + 1]
                
                //
                cRet := aCols[1][nPos]

        EndIf

    EndIf

    //
    RestArea(aArea)

    U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Inicializador padrão de campo')

Return cRet
