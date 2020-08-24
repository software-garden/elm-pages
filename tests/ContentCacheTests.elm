module ContentCacheTests exposing (..)

import Dict
import Expect exposing (Expectation)
import Json.Decode as Decode
import Pages.ContentCache as ContentCache
import Pages.Document as Document
import Test exposing (..)


all : Test
all =
    only <|
        describe "ContentCache"
            [ test "there is no content flash during hydration" <|
                \() ->
                    let
                        contentCache =
                            ContentCache.init document
                                [ ( [], { extension = "md", frontMatter = "123", body = Nothing } )
                                ]
                                (Just
                                    { contentJson =
                                        -- app is hydrated with this data
                                        { body = ""
                                        , staticData = Dict.empty
                                        }
                                    , initialUrl = { path = "" }
                                    }
                                )

                        document =
                            Document.fromList [ Document.parser { extension = "md", metadata = Decode.succeed (), body = \_ -> Ok () } ]
                    in
                    ContentCache.lookup ()
                        (contentCache |> Debug.log "contentCache")
                        { currentUrl = { path = "" }
                        , baseUrl = { path = "" }
                        }
                        |> expectPresent
            ]


expectPresent : Maybe a -> Expectation
expectPresent maybe =
    case maybe of
        Nothing ->
            Expect.fail "Got nothing"

        Just _ ->
            Expect.pass