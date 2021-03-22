@module("nanoid") @val external nanoid: unit => string = "nanoid"
@val external window: {..} = "window" 

let s = React.string

open Belt

type state = {posts: array<Post.t>, forDeletion: Map.String.t<Js.Global.timeoutId>}

type action =
  | DeleteLater(Post.t, Js.Global.timeoutId)
  | DeleteAbort(Post.t)
  | DeleteNow(Post.t)

let reducer = (state, action) =>
  switch action {
  | DeleteLater(post, timeoutId) => {
    ...state,
    forDeletion: state.forDeletion->Map.String.set(post.id, timeoutId)
  }
  | DeleteAbort(post) => {
    ...state,
    posts: state.posts->Js.Array2.concat([post])
  }
  | DeleteNow(post) => {
    ...state,
    posts: state.posts->Js.Array2.filter(arrPosts => post.id != arrPosts.id)
  }
  }

let initialState = {posts: Post.examples, forDeletion: Map.String.empty}

module PostItem = {
  @react.component

let make = (~post: Post.t, ~dispatch, ~clearTimeout) => {
  let (hidePost, setHidePost) = React.useState(() => false)

  let setDeletion = _ => {
      let timeoutId = window["setTimeout"](() => {dispatch(DeleteNow(post))}, 10000)
      Js.log(timeoutId)
      dispatch(DeleteLater(post, timeoutId))
      setHidePost(_ => true)
  }

  let abortDeletion = _ => {
      clearTimeout(post)
      setHidePost(_ => false)
  }

  let deleteImmediate = _ => {
    clearTimeout(post)
    dispatch(DeleteNow(post))
  }

  if !hidePost {
    <div
      className="bg-green-700 hover:bg-green-900 text-gray-300 hover:text-gray-100 px-8 py-4 mb-4">
      <h2 className="text-2xl mb-1"> {s(post.title)} </h2>
      <h3 className="mb-4"> {s(post.author)} </h3>
      {post.text
      ->Belt.Array.map(para => {
        <p className="mb-1 text-sm" key={nanoid()}> {s(para)} </p>
      })
      ->React.array}
      <button className="mr-4 mt-4 bg-red-500 hover:bg-red-900 text-white py-2 px-4" onClick={setDeletion}>
        {s("Remove this post")}
      </button>
    </div>
  }
   else {
    <div className="relative bg-yellow-100 px-8 py-4 mb-4 h-40">
      <p className="text-center white mb-1">
        {s(
          `This post from ${post.title} by ${post.author} will be permanently removed in 10 seconds.`,
        )}
      </p>
      <div className="flex justify-center">
        <button className="mr-4 mt-4 bg-yellow-500 hover:bg-yellow-900 text-white py-2 px-4" onClick={abortDeletion}>
          {s("Restore")}
        </button>
        <button className="mr-4 mt-4 bg-red-500 hover:bg-red-900 text-white py-2 px-4" onClick={deleteImmediate}>
          {s("Delete Immediately")}
        </button>
      </div>
      <div className="bg-red-500 h-2 w-full absolute top-0 left-0 progress" />
    </div>
  }
}

}

@react.component
let make = () => {
  let (state, dispatch) = React.useReducer(reducer, initialState)

  let clearTimeout = (post: Post.t) => {
    let _ = state.forDeletion->Map.String.get(post.id)->Option.map(window["clearTimeout"])
  }

  let posts = state.posts->Belt.Array.map(x => <PostItem key=x.id post=x dispatch clearTimeout />)->React.array

  <div className="max-w-3xl mx-auto mt-8 relative">
    <div> 
      {posts}
    </div>
  </div>
}
