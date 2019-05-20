defmodule Post do
  use Ecto.Schema

  schema "post" do
    field(:name, :string)
    has_many(:comments, Comment)
  end
end

defmodule Comment do
  use Ecto.Schema

  schema "comment" do
    field(:body, :string)
  end
end

defmodule Posts.WithoutFilters do
  import Ecto.Query, warn: false
  use EctoFilters

  def query(params \\ %{}) do
    query = from(post in Post)
    apply_filters(query, params)
  end
end

defmodule Posts.WithFilters do
  import Ecto.Query, warn: false
  use EctoFilters, add_defaults: false

  def query(params \\ %{}) do
    query = from(post in Post)
    apply_filters(query, params)
  end

  def filter({:comment_body, value}, query) do
    query
    |> join(:left, [p], c in assoc(p, :comments), as: :comments)
    |> where([comments: comments], ilike(comments.body, ^value))
  end
end

defmodule EctoFiltersTest.WithoutFilters do
  use ExUnit.Case

  describe "apply_filters without filters" do
    test "with empty filters" do
      assert %Ecto.Query{} = Posts.WithoutFilters.query()
    end

    test "with name filter" do
      query = Posts.WithoutFilters.query(%{"q" => %{"name" => "Joe"}})
      assert [%Ecto.Query.BooleanExpr{params: [{"Joe", {0, :name}}]}] = query.wheres
    end
  end

  describe "apply_filters with filters declared" do
    test "with comment body filter" do
      query = Posts.WithFilters.query(%{"q" => %{"comment_body" => "some words"}})
      assert [%Ecto.Query.BooleanExpr{params: [{"some words", :string}]}] = query.wheres
    end

    test "name when add_defaults is false" do
      query = Posts.WithFilters.query(%{"q" => %{"name" => "post name"}})
      assert [] == query.wheres
    end
  end
end
