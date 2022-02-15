/*/{Protheus.doc} User Function ADFIS048P
    (Programa para Reimpressão do XML das NFE de Saida para a Logistica)
    @type  Function
    @author ADRIANO SAVOINE
    @since 04/11/2021
    @version 01
    @history 
    /*/
    
User Function ADFIS048P()

    //Exportar XML no SPEDNFE
    SpedExport(1)

    //
    U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Reimpressão do XML das NFE de Saida para a Logistica')

    
Return ()
