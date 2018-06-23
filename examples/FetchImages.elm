module FetchImages exposing(..)

import Html exposing (Html, img, text)
import Html.Attributes exposing (src)
import Http
import Json.Decode exposing (Decoder, float, int, list, nullable, string)
import Json.Decode.Pipeline exposing (decode, hardcoded, optional, required)
import Reader exposing (Reader, run)

-- MODEL
type alias DogImages =
    { status : String
    , message : List String
    }

type alias Model =
    List String


init : ( Model, Cmd Msg )
init =
    ( [], send )

-- UPDATE

type Msg
    = LoadShibaImages (Result Http.Error DogImages)

decodeDogImages : Decoder DogImages
decodeDogImages =
    decode DogImages
        |> required "status" string
        |> required "message" (list string)
    
requestDogBreed : String -> Json.Decode.Decoder a -> Reader String (Http.Request a)
requestDogBreed apiPath decoder =
    Reader.Reader (\apiKey -> Http.get ("https://dog.ceo/api/breed/" ++ apiPath ++ "&apiKey=" ++ apiKey) decoder )


requestShibaImages : String -> Reader String (Http.Request DogImages)
requestShibaImages queryParameters =
    requestDogBreed ("shiba/images" ++ queryParameters) decodeDogImages


requestOneShibaImage : Reader String (Http.Request DogImages)
requestOneShibaImage =
    requestShibaImages "?limit=1"


send : Cmd Msg
send =
    Http.send LoadShibaImages <|
        run requestOneShibaImage "123456"

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        LoadShibaImages (Ok shibaImages) ->
            ( shibaImages.message, Cmd.none )

        LoadShibaImages (Err err) ->
            ( model, Cmd.none )


-- VIEW

view : Model -> Html Msg
view model =
    Maybe.withDefault (text "No Image!")
            <| Maybe.map (\imageUrl -> img [src imageUrl] [])
            <| List.head model

-- SUBSCRIPTIONS
subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


-- MAIN

main : Program Never Model Msg
main =
    Html.program
        { init = init
        , subscriptions = subscriptions
        , update = update
        , view = view
        }
