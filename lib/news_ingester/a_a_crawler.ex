defmodule NewsIngester.AACrawler do
  use GenServer
  @moduledoc false

  @doc """
  Crawler logic
  """
  def crawl() do
    _search_results = search(NewsIngester.AACrawler)
  end

  ## Client API

  @doc """
  Starts GenServer
  """
  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  @doc """
  Searches news and parses results
  """
  def search(server) do
    GenServer.call(server, :search)
  end

  ## Server Callbacks

  @doc """
  Initializes GenServer
  """
  def init(_opts) do
    {:ok, %{}}
  end

  def handle_call(:search, _from, state) do
    url = NewsIngester.AAHelper.generate_url(:a_a_search_path)
    filter = NewsIngester.AAHelper.generate_search_filter()
    header = NewsIngester.AAHelper.generate_auth_header()
    {:ok, response} = HTTPoison.post(url, filter, header)

    {:ok, body} =
      response.body
      |> Poison.Parser.parse()

    if body["response"]["success"] == false do
      {:reply, :error, state}
    else
      result =
        body["data"]["result"]
        |> Enum.map(fn r -> r["id"] end)

      {:reply, result, state}
    end
  end

  @doc """
  Default fallback for calls
  """
  def handle_call(_msg, _from, state) do
    {:reply, :ok, state}
  end

  @doc """
  Default fallback for casts
  """
  def handle_cast(_msg, state) do
    {:noreply, state}
  end
end
