defmodule Issues.GithubIssues do
  require Logger

  @user_agent [ {"User-agent", "Elixir dave@pragprog.com"} ]
  @github_url Application.get_env(:issues, :github_url)

  def fetch(user, project) do
    Logger.info "Fetching user #{user}'s project #{project}"
    issues_url(user, project)
    |> HTTPoison.get(@user_agent)
    |> handle_response
  end

  def issues_url(user, project) do
    "#{@github_url}/repos/#{user}/#{project}/issues"
  end

  def handle_response({:ok, %HTTPoison.Response{status_code: 200, body: body}}) do
    Logger.info "Successful response"
    Logger.debug fn -> inspect(body) end

    { :ok, :jsx.decode(body) }
  end

  def handle_response({:ok, %HTTPoison.Response{status_code: 404}}) do
    Logger.error "Error status 404 returned"

    { :error, "404" }
  end

  def handle_response({:error, %HTTPoison.Error{reason: reason}}) do
    Logger.error "An error ocurred, reason: #{reason}"

    { :error, reason }
  end
end
