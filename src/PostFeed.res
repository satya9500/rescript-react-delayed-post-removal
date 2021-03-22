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
