module Main exposing (..)

import Html exposing (Html, button, div, h1, h2, li, ol, p, text)
import Html.Attributes exposing (attribute, class)
import Http
import List
import Xml exposing (Value(..))
import Xml.Encode exposing (null)
import Xml.Decode exposing (decode)
import Xml.Query exposing (collect, string, tag, tags)


main : Program Flags Model Msg
main =
    Html.programWithFlags
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- TYPES


type alias Flags =
    { citationId : String
    , citationNamespace : String
    , citationTitle : String
    }


type alias Model =
    { citationId : String
    , citationNamespace : String
    , citationTitle : String
    , postFeedbackUrl : String
    , entries : List Entry
    }


type Msg
    = InitFeedback (Result Http.Error String)


type alias Entry =
    { title : String
    , author : String
    , updated : String
    }



-- INIT


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( initModel flags
    , getFeedbackXml <| makeGetFeedbackUrl flags.citationId flags.citationNamespace
    )


initModel : Flags -> Model
initModel flags =
    { citationId = flags.citationId
    , citationNamespace = flags.citationNamespace
    , citationTitle = flags.citationTitle
    , postFeedbackUrl =
        (makePostFeedbackUrl
            flags.citationTitle
            flags.citationId
            flags.citationNamespace
        )
    , entries = []
    }


makePostFeedbackUrl : String -> String -> String -> String
makePostFeedbackUrl citationTitle citationId citationNamespace =
    "https://www.opengis.uab.cat/nimmbus/index.htm?"
        ++ "target_title="
        ++ citationTitle
        ++ "&target_code="
        ++ citationId
        ++ "&target_codespace="
        ++ citationNamespace
        ++ "&page=ADDFEEDBACK"
        ++ "&share_borrower_1=Anonymous"


makeGetFeedbackUrl : String -> String -> String
makeGetFeedbackUrl citationId citationNamespace =
    "https://www.opengis.uab.cat/cgi-bin/nimmbus/nimmbus.cgi?"
        ++ "SERVICE=WPS"
        ++ "&REQUEST=EXECUTE"
        ++ "&IDENTIFIER=NB_RESOURCE:ENUMERATE"
        ++ "&CONTENT=full"
        ++ "&LANGUAGE=eng"
        ++ "&STARTINDEX=1"
        ++ "&COUNT=100"
        ++ "&FORMAT=text/xml"
        ++ "&TYPE=FEEDBACK"
        ++ "&TRG_TYPE_1=CITATION"
        ++ "&TRG_FLD_1=CODE"
        ++ "&TRG_VL_1="
        ++ citationId
        ++ "&TRG_OPR_1=EQ"
        ++ "&TRG_NXS_1=AND"
        ++ "&TRG_TYPE_2=CITATION"
        ++ "&TRG_FLD_2=NAMESPACE"
        ++ "&TRG_VL_2="
        ++ citationNamespace
        ++ "&TRG_OPR_2=EQ"



-- UPDATE


update : Msg -> Model -> ( Model, Cmd msg )
update msg model =
    case msg of
        InitFeedback (Ok newXml) ->
            ( { model | entries = entries <| decodedXml newXml }
            , Cmd.none
            )

        InitFeedback (Err _) ->
            ( model, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    div [ class "nimmbus" ]
        [ h1 [] [ text "NiMMbus Feedback" ]
        , ol [] (listItems model.entries)
        , button
            [ attribute "onclick" (openNimmbusWindow model.postFeedbackUrl) ]
            [ text "Add Feedback" ]
        ]


listItem : Entry -> Html Msg
listItem item =
    li []
        [ h2 [] [ text item.title ]
        , p [] [ text ("by " ++ item.author ++ " on " ++ item.updated) ]
        ]


listItems listOfItems =
    List.map listItem listOfItems


{-| Open NiMMbus in a new window. Users need use NiMMbus itself to log in and
write feedback.
-}
openNimmbusWindow : String -> String
openNimmbusWindow postFeedbackUrl =
    "window.open('"
        ++ postFeedbackUrl
        ++ "', 'connectWindow', 'scrollbars=yes')"



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- HTTP


getFeedbackXml : String -> Cmd Msg
getFeedbackXml getFeedbackUrl =
    Http.send InitFeedback (Http.getString getFeedbackUrl)



-- XML


decodedXml : String -> Value
decodedXml encodedXml =
    encodedXml
        |> decode
        |> Result.toMaybe
        |> Maybe.withDefault null


entries : Value -> List Entry
entries decodedXml =
    tags "entry" decodedXml
        |> List.map entry


entry : Value -> Entry
entry value =
    { title = title value
    , author = author value
    , updated = updated value
    }


title : Value -> String
title value =
    tagWithDefaultString "title" "Title unavailable" value


author : Value -> String
author value =
    tagWithDefaultString "name" "Author unavailable" value


updated : Value -> String
updated value =
    tagWithDefaultString "updated" "Date unavailable" value


tagWithDefaultString : String -> String -> Value -> String
tagWithDefaultString tagName default value =
    Result.withDefault default <| tag tagName string value
