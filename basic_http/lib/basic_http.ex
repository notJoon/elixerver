defmodule BasicHttp do
# UuDgtWimMTMioJpo836kW9
  require Logger

  defmodule Request do
    defstruct uri: nil, method: :get, headers: %{}, body: []
    def new(url, method \\ :get, headers \\ %{}, body \\ []) do
      %Request {
        uri: URI.parse(url),
        method: method,
        headers: headers,
        body: body
      }
    end
  end

  defmodule Response do
    defstruct status_code: nil, headers: %{}, body: []
  end

  @crlf "\r\n"
  @http_version "HTTP/1.1"
  @space " "

  def request(%Request{} = request) do
    Logger.debug request: request
    {:ok, conn} =
      :gen_tcp.connect to_charlist(request.uri.host),
      request.uri.port, [:binary, {:active, false}]

    # Send Request
    uri = request.uri
    request_packet = "GET / HTTP/1.1\r\nHost: icanhazip.com\r\nAccept: */*\r\n\r\n"
    [
      request_method(request.method), @space, uri.path, @space, @http_version, @crlf,
      "host", ?:, @space, uri.host, @crlf,
      request_content_length_header(request.body),
      @crlf,
      request.body
    ]

    IO.puts ">> REQUEST"
    IO.puts request_packet |> :erlang.iolist_to_binary
    :ok = :gen_tcp.send(conn, request_packet)

    # Receive Response
    :inet.setopts(conn, [packet: :line])

    # parse status code
    {:ok, "HTTP/1.1 " <> << status_code_string :: binary-size(3) >> <> _ }
      = :gen_tcp.recv(conn, 0, 1000)

    # parse headers
    headers =
      Stream.cycle([0])
      |> Stream.map(fn _ ->
        {:ok, header_line} = :gen_tcp.recv(conn, 0, 1000)
        header_line
      end)
      |> Enum.take_while(fn line -> line != "\r\n" end)
      |> Enum.map(fn line ->
        [k, v] = String.split(line, ":", parts: 2)
        {String.downcase(k), String.trim(v)}
      end)
      |> Enum.into(%{})

    content_len = headers["content-length"] |> String.to_integer

    :ok = :inet.setopts(conn, [packet: :raw])
    {:ok, body} = :gen_tcp.recv(conn, content_len, 1000)

    %Response {
      status_code: String.to_integer(status_code_string),
      headers: headers,
      body: body,
    }
  end

  defp request_method(:get), do: "GET"
  defp request_method(:post), do: "POST"
  defp request_method(:head), do: "HEAD"

  defp request_content_length_header(body) do
    content_length = body |> :erlang.iolist_to_binary |> byte_size

    if content_length == 0 do
      []
    else
      ["content-length", ?;, @space, to_string(content_length), @crlf]
    end
  end
end
