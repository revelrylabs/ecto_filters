defmodule EctoFiltersTest.WithFilters do
  use ExUnit.Case

  import Ecto.Query, warn: false
  use EctoFilters, add_defaults: false

  defmodule Post do
    use Ecto.Schema
    schema "post" do
      field(:name, :utc_datetime)
      has_many(:comments, Comment)
    end
  end

  defmodule Comment do
    use Ecto.Schema
    schema "comment" do
      field(:body, :string)
    end
  end

  defp query, do: from(post in Post)

  def filter({:comment_body, value}, query) do
    from(
      posts in query,
      join: comments in assoc(posts, :comments),
      where: ilike(comments.body, ^value)
    )
  end


  describe "apply_filters" do
    test "with comment body filter" do
      query = apply_filters(query(), %{"q" => %{"comment_body" => "some words"}})
      assert [%Ecto.Query.BooleanExpr{params: [{"some words", :string}]}] = query.wheres
    end
  end
end
