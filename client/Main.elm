import Html exposing (..)
import Html.App as App
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Svg exposing (..)
import Svg.Attributes exposing (..)
import WebSocket
import Json.Decode exposing (..)
import Json.Encode exposing (..)
import String exposing (..)
import Debug exposing (..)
main =
  App.program
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }


-- MODEL

type alias Model = Int
type Action = MoveLeft | MoveRight
type alias ReduxAction = {
  rxType: Action
}

init : (Model, Cmd Msg)
init =
  (0, Cmd.none)


-- UPDATE

type Msg
  = Send ReduxAction
  | NewMessage Int

moveLeft = "moveLeft"
moveRight = "moveRight"

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Send rxAction ->
      case rxAction.rxType of
        MoveLeft ->
          (model, WebSocket.send "ws://localhost:8080" (Json.Encode.encode 0 (Json.Encode.object [("type", Json.Encode.string"moveLeft")])))
        MoveRight ->
          (model, WebSocket.send "ws://localhost:8080" (Json.Encode.encode 0 (Json.Encode.object [("type", Json.Encode.string "moveRight")])))
    NewMessage pos ->
      (pos, Cmd.none)


logError err =
  Debug.log "Err" err

just10 arg =
  10
-- SUBSCRIPTIONS

reduxToElm : String -> Msg
reduxToElm str =
  let
    valid =
      Json.Decode.decodeString ( "position" := Json.Decode.int) str
  in
    case valid of
      Ok val ->
        NewMessage val
      Err err ->
        NewMessage 10

subscriptions : Model -> Sub Msg
subscriptions model =
  WebSocket.listen "ws://localhost:8080" reduxToElm


-- VIEW

board : List (Svg msg) -> Svg msg
board children =
  Svg.node "svg" [ Svg.Attributes.width "100"
                 , Svg.Attributes.height "100"
                 , Svg.Attributes.color "black"
                 ] children

piece : Int -> Svg msg
piece x =
  Svg.node "rect" [ Svg.Attributes.width "10"
                  , Svg.Attributes.height "10"
                  , Svg.Attributes.color "black"
                  , Svg.Attributes.x (toString x)] []

view : Model -> Html Msg
view model =
  div []
    [  board [ piece model ]
    , button [ onClick (Send (ReduxAction MoveLeft))] [Html.text "Left"]
    , button [ onClick (Send (ReduxAction MoveRight))] [Html.text "Right"]
    ]
