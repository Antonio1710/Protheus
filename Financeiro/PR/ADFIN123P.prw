#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'PARMTYPE.CH'
#INCLUDE 'FWCOMMAND.CH'
#INCLUDE 'TBICONN.CH'
#INCLUDE 'RPTDEF.CH'

/*/{Protheus.doc} ADFIN123P
	PixBradesco
	Classe que disponibiliza recursos para integracao com API do Banco Bradesco, com a finalidade de operacoes via PIX.
	@type function
	@version  
	@author Rodrigo Mello - Flek Solutions
	@since 11/01/2022
/*/
Function u_ADFIN123P(); Return 
//------------------------------------------------------------------------------
Class ADFIN123P
//------------------------------------------------------------------------------

    private data oRest
    private data cEndPoint  as String
    private data cBaseURL   as String
    private data cPathURL   as String
    private data cToken     as String
    private data aHeader    as Array
    private data cUser      as String
    private data cPassword  as String
    private data cQRCode    as String
    private data cUrlLib    as String

    private  data cEMV       as String

    public method new() Constructor

    private method setToken()
    private method logError(cDesc, cMessage)

    public method getPix(cIdPix, oRes)
    public method putPix(cIdPix, oReq, oRes )

    public method getEMV()
    public method setEMV()

    public method getQrCode()
    public method setQrCode()

    public method getUrlLib()
    public method setUrlLib()

    public method className()

endclass

//----------------------------------------------------------
method new() class ADFIN123P
//----------------------------------------------------------

    ::cUser     := GetNewPar("MV_#CLIBRA", "95bd11c5-e42b-4250-9fcd-3d9450050ca1")
    ::cPassword := GetNewPar("MV_#SRTBRA", "59539a45-0bee-410f-a08f-280f43381ddf") 
    ::aHeader   := Array(0)
    AAdd( ::aHeader, 'User-Agent: Mozilla/4.0 (compatible; Protheus ' + GetBuild() + ')' )
    AAdd( ::aHeader, "Content-Type: application/json")

    ::cBaseURL  :=  GetNewPar("MV_#URLPIX", "https://qrpix-h.bradesco.com.br")

    ::oRest := FWRest():new(::cBaseURL )

return self

//----------------------------------------------------------
method setToken() class ADFIN123P
//----------------------------------------------------------

    local oRes     
    local cParms    := ""
    local aHeader   := {}
    local nPos
    
    if ::cToken == Nil
        AAdd( aHeader, 'Authorization: Basic ' + Encode64(::cUser +":"+ ::cPassword) )
        AAdd( aHeader, 'Content-Type: application/x-www-form-urlencoded')

        cParms += 'grant_type=client_credentials'
        cParms += '&scope=cob.write cob.read pix.read pix.write webhook.read webhook.write'

        ::oRest:SetPath('/oauth/token')
        ::oRest:SetPostParams(cParms)
        ::oRest:Post(aHeader)

        if (lRet := ::oRest:GetHTTPCode() == "200")
            oRes := JsonObject():New()
            oRes:fromJson( ::oRest:GetResult() )
            ::cToken := oRes['access_token']
        else
            ::logError( "ERR Bradesco - setToken", cValToChar(::oRest:GetLastError()) + CRLF + cValToChar(::oRest:GetResult()) )
            return .f.
        endif

    endif

    if  ( nPos := AScan( ::aHeader , {|u| "Authorization: Bearer " $ u })) <= 0
        AAdd( ::aHeader, "Authorization: Bearer " + ::cToken )
    else 
        ::aHeader[nPos] := "Authorization: Bearer " + ::cToken
    endif
return .t.

//----------------------------------------------------------
method getPix(oPayLoad, oRes, lQRCode ) class ADFIN123P
//----------------------------------------------------------

    local lRet := .F.
    local oPayTmp
    default oRes := JsonObject():New()
    default lQrCode := .F.
    
    if !oPayLoad:hasProperty('cob')
        oPayTmp := JsonObject():New()
        oPayTmp['cob'] := oPayLoad
        oPayLoad := oPayTmp
        FreeObj(oPayTmp)
    endif

    if ::setToken()
        ::oRest:SetPath('/v2/cob/'+alltrim(oPayLoad['cob']['txid']))
        ::oRest:Get(::aHeader)

        if (lRet := ::oRest:GetHTTPCode() == "200")
            oRes := JsonObject():New()
            oRes:fromJson( ::oRest:GetResult() )
            ::setEMV(oPayLoad)
            if lQrCode  
                ::setQRCode(oPayLoad)
            endif
        else
            ::logError( "ERR Bradesco - getLink", ::oRest:GetLastError() + CRLF + ::oRest:GetResult() )        
        endif
    endif

return lRet 

//----------------------------------------------------------
method putPix(cIdPix, oReq, oRes) class ADFIN123P
//----------------------------------------------------------

    local lRet := .F.
    default oReq := JsonObject():New()
    default oRes := JsonObject():New()
    
    if ::setToken()
        ::oRest:SetPath('/v2/cob-emv/'+alltrim(cIdPix))
        ::oRest:Put(::aHeader, oReq:toJson())

        if (lRet := ::oRest:GetHTTPCode() == "201")
            oRes := JsonObject():New()
            oRes:fromJson( ::oRest:GetResult() )
            ::setEmv(oRes)
            ::setQrCode(oRes)
        else
            ::logError( "ERR Bradesco - putPIX", ::oRest:GetLastError() + CRLF + ::oRest:GetResult() )
        endif
    endif

return lRet 

//----------------------------------------------------------
method getEMV() class ADFIN123P
return ::cEMV

//----------------------------------------------------------
method setEMV( oPayLoad ) class ADFIN123P
//----------------------------------------------------------
    local lRet := .F.

    if oPayLoad:hasProperty('emv') 
        ::cEMV := oPayLoad['emv']
        lRet := .T.
    endif
return lRet

//----------------------------------------------------------
method logError( cDesc, cMessage ) class ADFIN123P
//----------------------------------------------------------

    if !isblind()
        FWAlertWarning(cDesc, cMessage )
    else
        varinfo( cDesc, cMessage )
    endif

    u_GrLogZBE (Date(),TIME(),cUserName, cDesc,"TI","ADFIN123P",cMessage,ComputerName(),LogUserName())

return

//----------------------------------------------------------
method getQRCode() class ADFIN123P
return ::cQRCode

//----------------------------------------------------------
method setQrCode(oPayLoad) class ADFIN123P
//----------------------------------------------------------
    local nMkDir
    local lRet := .F.

    if !ExistDir('/qrcode')
        nMkDir := MakeDir('/qrcode')
    endif

    if oPayLoad:hasProperty('base64') .and. ;
        oPayLoad:hasProperty('cob') .and. oPayLoad['cob']:hasProperty('txid')
        ::cQRCode := oPayLoad['base64']
        lRet := .T.
        cPng := Decode64( ::cQRCode )
        memowrite('/qrcode/'+alltrim(oPayLoad['cob']['txid'])+'.png', cPng)
    endif

return lRet

//----------------------------------------------------------
/*
method getUrlLib() class ADFIN123P
return ::cUrlLib
*/
//----------------------------------------------------------
method setUrlLib(cUrlLib) class ADFIN123P
    default cUrlLib := ''
    ::cUrlLib := cUrlLib
return 


User Function fTstPixBrad()
    local oPayLoad := JsonObject():new()
    private oReq
    private oRes
    private cDesc := ""

    PREPARE ENVIRONMENT EMPRESA '01' FILIAL '02'

        oPixBrad := ADFIN123P():New()
        oPixBrad:getPix(oPayLoad)

        FreeObj(oPixBrad)

    RESET ENVIRONMENT

return
