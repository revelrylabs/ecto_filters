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
  use Ecto.Filters, key: :search

  def query(params \\ %{}) do
    query = from(post in Post)
    apply_filters(query, params)
  end
end

defmodule Posts.WithFilters do
  import Ecto.Query, warn: false
  use Ecto.Filters, add_defaults: false

  def query(params \\ %{}) do
    query = from(post in Post)
    apply_filters(query, params)
  end

  add_filter(:comment_body, fn value, query ->
    query
    |> join(:left, [p], c in assoc(p, :comments), as: :comments)
    |> where([comments: comments], ilike(comments.body, ^value))
  end)
end

defmodule Ecto.FiltersTest.WithoutFilters do
  use ExUnit.Case

  describe "apply_filters without filters" do
    test "with empty filters" do
      assert %Ecto.Query{} = Posts.WithoutFilters.query()
    end

    test "with name filter" do
      query = Posts.WithoutFilters.query(%{"search" => %{"name" => "Joe"}})
      assert [%Ecto.Query.BooleanExpr{params: [{"Joe", {0, :name}}]}] = query.wheres
    end

    test "doesn't raise exception when the atom doesn't exist" do
      try do
        Posts.WithoutFilters.query(%{"search" => %{"apple" => true}})
      rescue
        _ -> refute true
      end
      assert true
    end
  end

  describe "apply_filters with filters declared" do
    test "with comment_body filter" do
      query = Posts.WithFilters.query(%{"q" => %{"comment_body" => "some words"}})
      assert [%Ecto.Query.BooleanExpr{params: [{"some words", :string}]}] = query.wheres
    end

    test "name when add_defaults is false" do
      query = Posts.WithFilters.query(%{"q" => %{"name" => "post name"}})
      assert [] == query.wheres
    end

    test "using with keyword lists" do
      query = Posts.WithFilters.query(q: [comment_body: "some words"], other_opts: true)
      assert [%Ecto.Query.BooleanExpr{params: [{"some words", :string}]}] = query.wheres
    end

    test "using with atomized map" do
      query = Posts.WithFilters.query(%{q: %{comment_body: "some words"}})
      assert [%Ecto.Query.BooleanExpr{params: [{"some words", :string}]}] = query.wheres
    end

    test "using with atomized map of keyword lists" do
      query = Posts.WithFilters.query(%{q: [comment_body: "some words"]})
      assert [%Ecto.Query.BooleanExpr{params: [{"some words", :string}]}] = query.wheres
    end
  end
end
