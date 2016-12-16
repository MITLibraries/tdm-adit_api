defmodule AditApi.CollectionView do
  use AditApi.Web, :view

  theses = "MIT Electronic Theses and Dissertations"

  def render("index.json", _) do
    [%{url: "/collections/1",
       name: unquote(theses)
    }]
  end

  def render("show.json", %{id: id}) do
    %{url: "/collections/#{id}",
      schema_url: "/collections/#{id}/schema",
      search_url: "/collections/#{id}/search",
      name: unquote(theses),
      description: "Digitized and born digital theses"
    }
  end

  def render("schema.json", %{id: id}) do
    %{"$schema" => "http://json-schema.org/draft-04/schema#",
      name: "EThesis Schema",
      description: "Fields in EThesis description",
      type: "object",
      properties: %{
        title: %{type: "string"},
        author: %{type: "string"},
        advisor: %{type: "string"},
        degree: %{type: "string"},
        issue_date: %{type: "string"},
        abstract: %{type: "string"},
        text: %{type: "string"}
      },
      required: ["title", "author", "degree", "advisor", "issue_date", "abstract"]
    }
  end

  def render("search.json", %{id: id, hits: hits}) do
    %{
      hits: hits
    }
  end

end
