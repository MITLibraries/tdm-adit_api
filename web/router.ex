defmodule AditApi.Router do
  use AditApi.Web, :router

  pipeline :api do
    plug :accepts, ["json", "pdf", "text", "zip"]
  end

  scope "/api", AditApi do
    pipe_through :api

    resources "/collections", CollectionController, only: [:index, :show]
    get "/collections/:id/schema", CollectionController, :schema
    # get "/collections/:id/dump", CollectionsController, :dump
    post "/collections/:id/search", CollectionController, :search
    post "/collections/:id/watch", CollectionController, :watch

    get "/documents/:id", DocumentController, :show
    get "/documents/:id/text", DocumentController, :text

    resources "/docsets", DocsetController, except: [:edit, :new]
    get "/docsets/:id/members", DocsetController, :list
    get "/docsets/:id/catalog", DocsetController, :catalog
    get "/docsets/:id/dump", DocsetController, :dump
  end
end
