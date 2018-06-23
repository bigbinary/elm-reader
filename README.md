# Reader

A ```Reader``` is a handy type that is used for providing a shared "environment" to computations.
It helps to solve the problem of passing around the same values or configurations to many functions.
It is also often used as a way of doing dependency injections. In such cases by using a Reader the concern of passing the relevant context is mostly handled at the very peripheri of the application


Consider the following

```elm

type alias DogImages =
    { status : String
    , message : List String
    }
    
requestDogBreed : String -> String -> Json.Decode.Decoder a -> Http.Request a
requestDogBreed apiKey apiPath decoder =
    Http.get ("https://dog.ceo/api/breed/" ++ apiPath ++ "&apiKey=" ++ apiKey) decoder


requestShibaImages :  String -> String -> Http.Request DogImages
requestShibaImages apiKey queryParameters =
    requestDogBreed apiKey ("shiba/images" ++ queryParameters) decodeDogImages


requestOneShibaImage : String -> Http.Request DogImages
requestOneShibaImage apiKey =
    requestShibaImages apiKey "?limit=10"

```

If you look at ```requestOneShibaImage``` you’ll see ```apiKey``` is not used, but is passed through to the other functions until it reaches ```requestDogBreed``` where it is actually used. Such kind of boilerplate can be avoided with the useage of a ```Reader``` type

Instead of ```apiKey``` being passed down to each function, we can use a ```Reader``` and rewrite this in such a way that the context will get passed implicitly.


```elm
requestDogBreed : String -> Json.Decode.Decoder a -> Reader String (Http.Request a)
requestDogBreed apiPath decoder =
    Reader (\apiKey -> Http.get ("https://dog.ceo/api/breed/" ++ apiPath ++ "&apiKey=" ++ apiKey) decoder )


requestShibaImages : String -> Reader String (Http.Request DogImages)
requestShibaImages queryParameters =
    requestDogBreed ("shiba/images" ++ queryParameters) decodeDogImages


requestOneShibaImage : Reader String (Http.Request DogImages)
requestOneShibaImage =
    requestShibaImages "?limit=1"

```

Now the intermediate functions ```requestShibaImages``` and ```requestOneShibaImage``` no longer have to take in and pass ```apiKey``` around.

When we finally want to send the Http Request we can use the ```run``` function to pass in the context to the Reader and retrive the value i.e the final Request

```elm
type Msg
    = LoadShibaImages (Result Http.Error DogImages)

send : Cmd Msg
send =
    Http.send LoadShibaImages <|
        run requestOneShibaImage "123456"

```
