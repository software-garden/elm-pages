module Route.BasicAuth exposing (Data, Model, Msg, route)

import Base64
import DataSource exposing (DataSource)
import Head
import Html exposing (div, text)
import Pages.PageUrl exposing (PageUrl)
import RouteBuilder exposing (StatelessRoute, StaticPayload)
import Server.Request as Request exposing (Request)
import Server.Response as Response exposing (Response)
import Shared
import View exposing (View)


type alias Model =
    {}


type alias Msg =
    ()


type alias RouteParams =
    {}


route : StatelessRoute RouteParams Data
route =
    RouteBuilder.serverRender
        { head = head
        , data = data
        }
        |> RouteBuilder.buildNoState { view = view }


type alias Data =
    { greeting : String
    }


data : RouteParams -> Request (DataSource (Response Data))
data routeParams =
    withBasicAuth
        (\{ username, password } ->
            (username == "asdf" && password == "qwer")
                |> DataSource.succeed
        )
        (Data "Login success!"
            |> Response.render
            |> DataSource.succeed
        )


head :
    StaticPayload Data RouteParams
    -> List Head.Tag
head static =
    []


view :
    Maybe PageUrl
    -> Shared.Model
    -> StaticPayload Data RouteParams
    -> View Msg
view maybeUrl sharedModel static =
    { title = "Basic Auth Test"
    , body =
        [ text "Basic Auth Test"
        , div []
            [ text static.data.greeting
            ]
        ]
    }


parseAuth : String -> Maybe { username : String, password : String }
parseAuth base64Auth =
    case
        base64Auth
            |> String.dropLeft 6
            |> Base64.toString
            |> Maybe.map (String.split ":")
    of
        Just [ username, password ] ->
            Just
                { username = username
                , password = password
                }

        _ ->
            Nothing


withBasicAuth :
    ({ username : String, password : String } -> DataSource Bool)
    -> DataSource (Response data)
    -> Request (DataSource (Response data))
withBasicAuth checkAuth successResponse =
    Request.optionalHeader "authorization"
        |> Request.map
            (\base64Auth ->
                case base64Auth |> Maybe.andThen parseAuth of
                    Just userPass ->
                        checkAuth userPass
                            |> DataSource.andThen
                                (\authSucceeded ->
                                    if authSucceeded then
                                        successResponse

                                    else
                                        requireBasicAuth |> DataSource.succeed
                                )

                    Nothing ->
                        requireBasicAuth
                            |> DataSource.succeed
            )


requireBasicAuth : Response data
requireBasicAuth =
    Response.customResponse
        { headers = []
        , body = Nothing
        , statusCode = 401
        , isBase64Encoded = False
        }
        |> Response.withHeader "WWW-Authenticate" "Basic"