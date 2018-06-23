module Tests exposing (..)

import Reader exposing (..)
import Expect
import Fuzz exposing (Fuzzer, int, list, string)
import Test exposing (..)



constructing : Test
constructing =
    describe "Constructing a Reader"
        [ describe "# ask"
            [ fuzz string "returns a Reader that when run with a context value gives back the context value as is"
                <| (\str ->
                    expectReader str (\a -> a) <| ask)

            ]
        ]

running : Test
running =
    describe "Running a Reader"
        [ fuzz int "returns the result of the computation"
            <| \someInt ->
                Expect.equal
                    (someComputation someInt)
                    <| run (Reader.Reader someComputation) someInt
                
        ]

mapping : Test
mapping =
    describe "Mapping over a Reader"
        [ fuzz int "should apply a function to the result of a Reader" 
            <| \someInt ->
                Expect.equal
                    (someComputation <| someComputation someInt)
                    <| run (map someComputation (Reader.Reader someComputation)) someInt
        ]


chaining : Test
chaining =
    describe "Chaining over a Reader"
        [ fuzz int "should chain readers" 
            <| \someInt ->
                Expect.equal
                    ((+) someInt <| someComputation someInt)
                    <| run (andThen (\a -> Reader.Reader ((+) a))  (Reader.Reader someComputation)) someInt
        ]

expectReader : a -> (a -> b) -> Reader a b -> Expect.Expectation
expectReader ctx computation reader =
    run (Reader.Reader computation) ctx
        |> Expect.equal (run (reader) ctx)


someComputation : Int -> Int
someComputation someA = someA + (someA - 2) * 2
