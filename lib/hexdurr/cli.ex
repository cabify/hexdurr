defmodule Hexdurr.CLI do
  @strict [dry_run: :boolean, organization: :string, file: :string, key: :string]

  def main(args) do
    {opts, argv} = OptionParser.parse!(args, strict: @strict)

    run(argv, opts)
  end

  def run(["generate"], opts) do
    config = hex_config(opts)
    {:ok, {200, _headers, body}} = :hex_api_organization_member.list(config)

    list =
      body
      |> Enum.sort_by(& &1["username"])
      |> Enum.map(&"\n  - username: #{&1["username"]}\n    role: #{&1["role"]}")

    string = "members:#{list}"
    puts_or_write(string, opts)
  end

  def run(["run"], opts) do
    config = hex_config(opts)
    {:ok, {200, _headers, body}} = :hex_api_organization_member.list(config)
    from = api_list_to_map(body)

    file = File.read!(opts[:file])
    [[{'members', members}]] = :yamerl.decode(file)
    to = yaml_list_to_map(members)

    diff = diff(from, to)
    print_diff(diff)

    unless opts[:dry_run] do
      execute_diff(diff, config)
    end
  end

  defp diff(from, to) do
    from_keys = Map.keys(from)
    to_keys = Map.keys(to)

    add_keys = to_keys -- from_keys
    remove_keys = from_keys -- to_keys

    update =
      Enum.filter(Map.drop(to, add_keys), fn {username, role} ->
        Map.get(from, username) != role
      end)

    %{
      add: Enum.to_list(Map.take(to, add_keys)),
      remove: Enum.to_list(Map.take(from, remove_keys)),
      update: update,
      old_size: Map.size(from),
      new_size: Map.size(to)
    }
  end

  defp execute_diff(%{add: add, remove: remove, update: update, old_size: old_size, new_size: new_size}, config) do
    Enum.each(remove, fn {username, _role} ->
      {:ok, {204, _headers, _body}} = :hex_api_organization_member.delete(config, username)
    end)

    if new_size != old_size do
      {:ok, {200, _headers, _body}} = :hex_api_organization.update(config, new_size)
    end

    Enum.each(add, fn {username, role} ->
      {:ok, {200, _headers, _body}} = :hex_api_organization_member.add(config, username, role)
    end)

    Enum.each(update, fn {username, role} ->
      {:ok, {200, _headers, _body}} = :hex_api_organization_member.update(config, username, role)
    end)
  end

  defp print_diff(%{add: add, remove: remove, update: update}) do
    IO.puts("Add:")
    print_list(add)
    IO.puts("Remove:")
    print_list(remove)
    IO.puts("Update:")
    print_list(update)
  end

  defp print_list([]), do: IO.puts("  No changes!")

  defp print_list(list) do
    Enum.each(list, fn {username, role} ->
      IO.puts("  Username: #{username} Role: #{role}")
    end)
  end

  defp yaml_list_to_map(list) do
    Map.new(list, fn member ->
      member = Map.new(member)
      {List.to_string(member['username']), List.to_string(member['role'])}
    end)
  end

  defp api_list_to_map(list) do
    Map.new(list, fn member ->
      member = Map.new(member)
      {member["username"], member["role"]}
    end)
  end

  defp puts_or_write(string, opts) do
    if file = opts[:file] do
      File.write!(file, string)
    else
      IO.puts(string)
    end
  end

  defp hex_config(opts) do
    %{
      :hex_core.default_config()
      | api_organization: opts[:organization],
        api_key: opts[:key]
    }
  end
end
