defmodule AditApi.DocumentView do
  use AditApi.Web, :view

  def render("show.json", %{doc: doc, info: info}) do
    document_json(doc, hd(info))
  end

  def document_json(doc, info) do
    %{
      ref: doc.ref,
      title: hd(info["http://purl.org/dc/terms/title"])["@value"],
      creator: hd(info["http://purl.org/dc/terms/creator"])["@value"],
      abstract: hd(info["http://purl.org/dc/terms/abstract"])["@value"]
    }
  end
end
