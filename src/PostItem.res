@module("nanoid") @val external nanoid: unit => string = "nanoid"
@val external window: {..} = "window" 

let s = React.string

@react.component

let make = (~post: Post.t, ~dispatch, ~clearTimeout) => {
  let (hidePost, setHidePost) = React.useState(() => false)

  let setDeletion = _ => {
      //let timeoutId = window["setTimeout"](() => {dispatch(PostFeed.DeleteNow(post))}, 10000)
      //dispatch(DeleteLater(post, timeoutId))
      setHidePost(_ => true)
  }

  let abortDeletion = _ => {
      clearTimeout(post)
      setHidePost(_ => false)
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
        <button className="mr-4 mt-4 bg-red-500 hover:bg-red-900 text-white py-2 px-4">
          {s("Delete Immediately")}
        </button>
      </div>
      <div className="bg-red-500 h-2 w-full absolute top-0 left-0 progress" />
    </div>
  }
}
