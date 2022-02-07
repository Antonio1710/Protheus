#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'PARMTYPE.CH'
#INCLUDE 'FWCOMMAND.CH'
#INCLUDE 'TBICONN.CH'

/*/{Protheus.doc} ADFIN124P
    SuperLink Cielo
    Classe que disponibiliza recursos para integracao com API da Cielo
    @type function
    @version  
    @author Rodrigo Mello - Flek Solutions
    @since 11/01/2022
    @return variant, return_description
/*/

Function u_ADFIN124P(); Return 
//------------------------------------------------------------------------------
Class ADFIN124P
//------------------------------------------------------------------------------

    private data oRest
    private data cEndPoint as String
    private data cBaseURL  as String
    private data cPathURL  as String
    private data cToken    as String
    private data aHeader   as Array

    public method new() Constructor

    private method setToken()
    private method logError(cDesc, cMessage)

    public method getLink(cIdLin, lPay, oRes)
    public method postLink(oReq, oRes )
    public method putLink(cIdLin, oReq, oRes )
    public method deleteLink(cIdLin, oRes )
    
    public method className()

endclass

//----------------------------------------------------------
method new() class ADFIN124P
//----------------------------------------------------------
    ::aHeader := Array(0)
    AAdd( ::aHeader, 'User-Agent: Mozilla/4.0 (compatible; Protheus ' + GetBuild() + ')' )
    AAdd( ::aHeader, 'Content-Type: application/json' )
    ::cBaseURL  :=  GetNewPar("MV_#URLLNK", "https://cieloecommerce.cielo.com.br/api/public")

    ::oRest   := FWRest():new(::cBaseURL)

return self

//----------------------------------------------------------
method setToken() class ADFIN124P
//----------------------------------------------------------

    local cUser     := GetNewPar("MV_#CLICIE", "20fd8ce1-76c1-4b4f-8146-37d652969e10")
    local cPassword := GetNewPar("MV_#SRTCIE", "TUgKsaQAlhNCHub9oDFPKMkvaXSk4bX1ZaUKUCyqnXU=") 
    local oReq      
    local oRes      
    local cPath     := GetNewPar("MV_#URLLNK", "https://cieloecommerce.cielo.com.br/api/public")
    local aHeader   := {}
    local nPos
    local lRet      := .F.
    
    if ::cToken == Nil
        oReq := FWRest():new(cPath)
        oReq:setPath('/v2/token')
        AAdd( aHeader, 'Content-Type: application/json' )
        AAdd( aHeader, 'Authorization: Basic ' + Encode64(cUser+":"+cPassword) )
        oReq:post(aHeader)

        if ( lRet := oReq:GetHTTPCode() == "201" )
            oRes := JsonObject():New()
            oRes:fromJson( oReq:GetResult() )
            ::cToken := oRes['access_token']
        else
            if !isblind()
                FWAlertWarning("ERR Cielo - setToken", oReq:GetLastError())
            else
                varinfo("ERR Cielo - setToken", oReq:GetLastError())
            endif
        endif

        FreeObj(oReq)
        FreeObj(oRes)
    endif

    if  ( nPos := AScan( ::aHeader , {|u| "Authorization: Bearer " $ u })) <= 0
        AAdd( ::aHeader, "Authorization: Bearer " + ::cToken )
    else 
        ::aHeader[nPos] := "Authorization: Bearer " + ::cToken
    endif
return

//----------------------------------------------------------
method getLink(cIdLin, lPay, oRes ) class ADFIN124P
//----------------------------------------------------------

    local lRet := .F.
    default cIdLin := ""
    default lPay := .F.
    default oRes := JsonObject():New()
    
    ::setToken()
    ::oRest:SetPath('/v1/products/'+alltrim(cIdLin) + IIF(lPay,"/payments",""))
    ::oRest:Get(::aHeader)

    if (lRet := ::oRest:GetHTTPCode() == "200")
        oRes := JsonObject():New()
        oRes:fromJson( ::oRest:GetResult() )
    else
        ::logError( "ERR Cielo - getLink", ::oRest:GetLastError() + CRLF + ::oRest:GetResult() )        
    endif

return lRet 

//----------------------------------------------------------
method postLink(oReq, oRes) class ADFIN124P
//----------------------------------------------------------

    local lRet := .F.
    default oReq := JsonObject():New()
    default oRes := JsonObject():New()
    
    ::setToken()
    ::oRest:SetPath('/v1/products')
    ::oRest:SetPostParams( oReq:toJson() )
    ::oRest:Post(::aHeader)

    if (lRet := ::oRest:GetHTTPCode() == "201")
        oRes := JsonObject():New()
        oRes:fromJson( ::oRest:GetResult() )
    else
        ::logError( "ERR Cielo - postLink", ::oRest:GetLastError() + CRLF + ::oRest:GetResult() )        
    endif

return lRet 

//----------------------------------------------------------
method putLink(cIdLin, oReq, oRes) class ADFIN124P
//----------------------------------------------------------

    local lRet := .F.
    default oReq := JsonObject():New()
    default oRes := JsonObject():New()
    
    ::setToken()
    ::oRest:SetPath('/v1/products/'+alltrim(cIdLin))
    ::oRest:Put(::aHeader, oReq:toJson())

    oRes := JsonObject():New()
    oRes:fromJson( ::oRest:GetResult() )

    if (lRet := ::oRest:GetHTTPCode() != "200")
        ::logError( "ERR Cielo - putLink", ::oRest:GetLastError() + CRLF + ::oRest:GetResult() )
    endif
    oRes:fromJson( ::oRest:GetResult() )

return lRet 

//----------------------------------------------------------
method deleteLink(cIdLin, oRes) class ADFIN124P
//----------------------------------------------------------

    local lRet := .F.
    default oRes := JsonObject():New()
    
    ::setToken()
    ::oRest:SetPath('/v1/products/'+alltrim(cIdLin))
    ::oRest:Delete(::aHeader)

    if (lRet := ::oRest:GetHTTPCode() == "204")
        oRes := JsonObject():New()
        oRes:fromJson( ::oRest:GetResult() )
    else
        ::logError( "ERR Cielo - deleteLink", ::oRest:GetLastError() + CRLF + ::oRest:GetResult() )
    endif

return lRet 

//----------------------------------------------------------
method logError( cDesc, cMessage ) class ADFIN124P
//----------------------------------------------------------

    if !isblind()
        FWAlertWarning("ERR Cielo - deleteLink", )
    else
        varinfo( cDesc, cMessage )
    endif

return

Function u_fTstCielo()
    private oReq
    private oRes
    private cDesc := "" 

    PREPARE ENVIRONMENT EMPRESA '99' FILIAL '01'

        oCielo := ADFIN124P():New()
        //oCielo:getLink('1ab86407-b956-40e5-8b45-48cf343f4682', .f., @oRes)

        beginContent var cDesc
            Descricao dos itens do pedido | 1234567890123456789012345678901234567890 | 1234567890123456789012345678901234567890 | 1234567890123456789012345678901234567890 | 1234567890123456789012345678901234567890 | 1234567890123456789012345678901234567890 | 1234567890123456789012345678901234567890 | 1234567890123456789012345678901234567890 | 1234567890123456789012345678901234567890 | 1234567890123456789012345678901234567890 | 1234567890123456789012345678901234567890 | 1234567890123456789012345678901234567890
        endContent

        oReq := JsonObject():New()
        oReq['type'] := "Payment"
        oReq['name'] := "ADORO PED 012345" // SA1->A1_NOME
        oReq['showDescription'] := "true"
        oReq['description'] := cDesc
        oReq['price'] := cValToChar(123456)
        //oReq['weight'] := 0
        oReq['expirationDate'] := left( FWTimeStamp(3, Date()+30), 10 )
        oReq['maxNumberOfInstallments'] := "1"
        oReq['quantity'] := 1
        oReq['shipping'] := JsonObject():New()
        oReq['shipping']['name']    := "nameshipping"
        oReq['shipping']['price']   := "0"
        oReq['shipping']['type']    := "WithoutShipping"

        oCielo:postLink(oReq, @oRes)
        //oCielo:putLink('990bf5fe-c765-458b-9083-8776324a3575', oReq, @oRes)
        //oCielo:deleteLink('0de84b9b-d79a-49ba-afa5-4af30670568', oReq, @oRes)

    RESET ENVIRONMENT

return

/*
    https://cielolink.com.br/3iTRoJL

*/
