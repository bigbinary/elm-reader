module Reader
    exposing
        ( Reader(Reader)
        , run
        , ask
        , map
        , andThen
        )

{-| A Reader helps in solving the problem of passing down the same values to many functions.
If there are computations that read value from a shared environment or configurations to be passed around,
a Reader can be used in all such cases. It is also often used as a way of doing dependency injections.


# Definition

@docs Reader


# Helpers

@docs run, ask


# Mapping

@docs map


# Chaining

@docs andThen

-}


{-| Represents a computation that expects a context that when run returns the result of the computation.
-}
type Reader context someA
    = Reader (context -> someA)


{-| Returns a Reader that when run with a context value gives back the context value as is
-}
ask : Reader context context
ask =
    Reader identity


{-| A Reader expects an environment or a context to run,
the run function takes in a Reader and the context it expects and returns the result of the computation.
-}
run : Reader context someA -> context -> someA
run (Reader f) context =
    f context


{-| Transform a Reader
-}
map : (someA -> someB) -> Reader context someA -> Reader context someB
map fn reader =
    Reader (\context -> fn (run reader context))


{-| Chain together Readers
-}
andThen : (someA -> Reader context someB) -> Reader context someA -> Reader context someB
andThen chainFn reader =
    Reader
        (\context ->
            run reader context
                |> chainFn
                |> (flip run) context
        )
