defmodule JaSerializer.Serializer do
  @moduledoc """
  Define a serialization schema.

  Provides `has_many/2`, `has_one/2`, `attributes\1` and `location\1` macros 
  to define how your model (struct or map) will be rendered in the 
  JSONAPI.org 1.0 format.

  Defines `format/1`, `format/2` and `format/3` used to convert models (and
  list of models) for encoding in your JSON library of choice.

  ## Example

      defmodule PostSerializer do
        use JaSerializer

        location "/posts/:id"
        attributes [:title, :body, :excerpt, :tags]
        has_many :comments, link: "/posts/:id/comments"
        has_one :author, include: PersonSerializer

        def excerpt(post, _conn) do
          [first | _ ] = String.split(post.body, ".")
          first
        end
      end

      post = %Post{
        id: 1,
        title: "jsonapi.org + Elixir = Awesome APIs",
        body: "so. much. awesome.",
        author: %Person{name: "Alan"}
      }

      post
      |> PostSerializer.format
      |> Poison.encode!

  """

  use Behaviour

  @type id :: String.t | Integer
  @type model :: Map

  @doc """
  The id to be used in the resource object.

  http://jsonapi.org/format/#document-resource-objects

  Default implimentation attempts to get the :id field from the model.

  To override simply define the id function:

      def id(model, _conn), do: model.slug
  """
  defcallback id(model, Plug.Conn.t) :: id


  @doc """
  The type to be used in the resource object.

  http://jsonapi.org/format/#document-resource-objects

  Default implimentation attempts to infer the type from the serializer
  module's name. For example:

      MyApp.UserView becomes "user"
      MyApp.V1.Serializers.Post becomes "post"
      MyApp.V1.CommentsSerializer becomes "comments"

  To override simply define the type function:

      def type, do: "category"
  """
  defcallback type() :: String.t

  @doc """
  Returns a map of attributes to be mapped.

  The default implimentation relies on the `attributes/1` macro to define
  which fields to be included in the map.

      defmodule UserSerializer do
        attributes [:email, :name, :is_admin]
      end

      UserSerializer.attributes(user, conn)
      # %{email: "...", name: "...", is_admin: "..."}

  You may override this method and use `super` to filter attributes:

      defmodule UserSerializer do
        attributes [:email, :name, :is_admin]

        def attributes(model, conn) do
          attrs = super(model, conn)
          if conn.assigns[:current_user].is_admin do
            attrs
          else
            Map.take(attrs, [:email, :name])
          end
        end
      end

      UserSerializer.attributes(user, conn)
      # %{email: "...", name: "..."}

  You may also skip using the `attributes/1` macro altogether in favor of
  just defining `attributes/2`.

      defmodule UserSerializer do
        def attributes(model, conn) do
          Map.take(model, [:email, :name])
        end
      end

      UserSerializer.attributes(user, conn)
      # %{email: "...", name: "..."}

  """
  defcallback attributes(model, Plug.Conn.t) :: map

  @doc false
  defmacro __using__(_) do
    quote do
      @behaviour JaSerializer.Serializer
      @attributes []
      @relations  []
      @location   nil

      import JaSerializer.Serializer, only: [
        serialize: 2, attributes: 1, location: 1,
        has_many: 2, has_one: 2, has_many: 1, has_one: 1
      ]

      unquote(define_default_type(__CALLER__.module))
      unquote(define_default_id)
      unquote(define_default_attributes)

      @before_compile JaSerializer.Serializer
    end
  end

  defp define_default_type(module) do
    type = module
            |> Atom.to_string
            |> String.split(".")
            |> List.last
            |> String.replace("Serializer", "")
            |> String.replace("View", "")
            |> String.downcase
    quote do
      def type, do: unquote(type)
      defoverridable [type: 0]
    end
  end

  defp define_default_id do
    quote do
      def id(m),    do: Map.get(m, :id)
      def id(m, _c), do: apply(__MODULE__, :id, [m])
      defoverridable [{:id, 2}, {:id, 1}]
    end
  end

  defp define_default_attributes do
    quote do
      def attributes(model, conn) do
        JaSerializer.Serializer.default_attributes(__MODULE__, model, conn)
      end
      defoverridable [attributes: 2]
    end
  end

  @doc false
  def default_attributes(serializer, model, conn) do
    Enum.reduce serializer.__attributes, %{}, fn(attr, acc) ->
      Map.put(acc, attr, apply(serializer, attr, [model, conn]))
    end
  end

  @doc false
  defmacro serialize(type, do: block) do
    IO.puts "serialize/2 is deprecated, please use `type/1` instead"
    quote do
      unquote(block)
      def type, do: unquote(type)
    end
  end

  @doc """
  Defines the canoical path for retrieving this resource.

  ## String Examples

  String may be either a full url or a relative path. Path segments begining
  with a colin are called as functions on the serializer with the model and
  conn passed in.

      defmodule PostSerializer do
        use JaSerializer

        location "/posts/:id"
      end

      defmodule CommentSerializer do
        use JaSerializer

        location "http://api.example.com/posts/:post_id/comments/:id"

        def post_id(comment, _conn), do: comment.post_id
      end

  ## Atom Example

  When an atom is passed in it is assumed it is a function that will return
  a relative or absolute path.

      defmodule PostSerializer do
        use JaSerializer
        import MyPhoenixApp.Router.Helpers

        location :post_url

        def post_url(post, conn) do
          #TODO: Verify conn can be used here instead of Endpoint
          post_path(conn, :show, post.id)
        end
      end

  """
  defmacro location(uri) do
    quote bind_quoted: [uri: uri] do
      @location uri
    end
  end

  @doc """
  Defines a list of attributes to be included in the payload.

  An overrideable function for each attribute is generated with the same name
  as the attribute. The function's default behavior is to retrieve a field with
  the same name from the model.

  For example, if you have `attributes [:body]` a function `body/2` is defined
  on the serializer with a default behavior of `Map.get(model, :body)`.
  """
  defmacro attributes(atts) do
    quote bind_quoted: [atts: atts] do
      # Save attributes
      @attributes @attributes ++ atts

      # Define default attribute function, make overridable
      for att <- atts do
        def unquote(att)(m),    do: Map.get(m, unquote(att))
        def unquote(att)(m, c), do: apply(__MODULE__, unquote(att), [m])
        defoverridable [{att, 2}, {att, 1}]
      end
    end
  end

  @doc """
  Add a has_many relationship to be serialized.

  Relationships may be included in any of three composeable ways:

  * Links
  * Resource Identifiers
  * Includes

  ## Relationship Source

  When you define a relationship, a function is defined of the same name in the
  serializer module. This function is overrideable but by default attempts to
  access a field of the same name as the relationship on the map/struct passed
  in. The field may be changed using the `field` option.

  For example if you `have_many :comments` a function `comments\2` is defined
  which calls `Dict.get(model, :comments)` by default.

  ## Link based relationships

  Specify a uri which responds with the related resources.
  See <a href='#location/1'>location/1</a> for defining uris.

  The relationship source is disregarded when linking.

      defmodule PostSerializer do
        use JaSerializer

        has_many :comments, link: "/posts/:id/comments"
      end

  ## Resource Identifier Relationships

  Adds a list of `id` and `type` pairs to the response with the assumption the
  API consumer can use them to retrieve the related resources as needed.

  The relationship source should return either a list of ids or maps/structs
  that have an `id` field.

      defmodule PostSerializer do
        use JaSerializer

        has_many :comments, type: "comments"

        def comments(post, _conn) do
          post |> PostModel.get_comments |> Enum.map(&(&1.id))
        end
      end

  ## Included Relationships

  Adds a list of `id` and `type` pairs, just like Resource Indentifier
  relationships, but also adds the full serialized resource to the response to
  be "sideloaded" as well.

  The relationship source should return a list of maps/structs.

  *WARNING: Currently sideloaded resources do not have thier own included
  resources included.*

      defmodule PostSerializer do
        use JaSerializer

        has_many :comments, include: CommentSerializer

        def comments(post, _conn) do
          post |> PostModel.get_comments
        end
      end

      defmodule CommentSerializer do
        use JaSerializer

        has_one :post, field: :post_id, type: "posts"
        attributes [:body]
      end

  """
  defmacro has_many(name, opts \\ []) do
    quote bind_quoted: [name: name, opts: opts] do
      @relations [{:has_many, name, opts} | @relations]
      # Define default relation function, make overridable
      def unquote(name)(m, c), do: apply(__MODULE__, unquote(name), [m])
      def unquote(name)(model) do
        Map.get(model, (unquote(opts)[:field] || unquote(name)))
      end
      defoverridable [{name, 2}, {name, 1}]
    end
  end

  @doc """
  See documentation for <a href='#has_many/2'>has_many/2</a>.

  API is the exact same.
  """
  defmacro has_one(name, opts \\ []) do
    #TODO: Dry up setting up relationships.
    quote bind_quoted: [name: name, opts: opts] do
      @relations [{:has_one, name, opts} | @relations]
      # Define default relation function, make overridable
      def unquote(name)(m, c), do: apply(__MODULE__, unquote(name), [m])
      def unquote(name)(model) do
        Map.get(model, (unquote(opts)[:field] || unquote(name)))
      end
      defoverridable [{name, 2}, {name, 1}]
    end
  end

  @doc false
  defmacro __before_compile__(_env) do
    quote do
      def __relations,  do: @relations
      def __location,   do: @location
      def __attributes, do: @attributes

      def format(model) do
        format(model, %{})
      end

      def format(model, conn) do
        format(model, conn, [])
      end

      def format(model, conn, opts) do
        %{model: model, conn: conn, serializer: __MODULE__, opts: opts}
        |> JaSerializer.Builder.build
        |> JaSerializer.Formatter.format
      end
    end
  end
end
