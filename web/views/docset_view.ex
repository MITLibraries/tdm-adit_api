defmodule AditApi.DocsetView do
  use AditApi.Web, :view

  def render("index.json", %{docsets: docsets}) do
    %{
      docsets: Enum.map(docsets, &docset_json/1)
    }
  end

  def render("show.json", %{docset: docset}) do
    docset_json(docset)
  end

  def render("list.json", %{docset: docset}) do
    %{
      docset: docset_json(docset),
      members: Enum.map(docset.documents, &document_json/1)
    }
  end

  def render("catalog.json", %{docset: docset}) do
    %{
      docset: docset_json(docset),
      members: Enum.map(docset.documents, &document_json/1)
    }
  end

  def docset_json(docset) do
    %{
      url: "/docsets/#{docset.id}",
      name: docset.name,
      generator: docset.generator,
      owner: docset.owner
    }
  end

  def document_json(doc) do
    %{
      url: "/documents/#{doc.id}",
      ref: doc.ref
    }
  end
end
