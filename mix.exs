defmodule Schedule.Mixfile do
  use Mix.Project

  def project do
    [app: :schedule,
     version: "0.1.0",
     elixir: "~> 1.0",
     deps: deps,
     name: "Schedule",
     source_url: "https://github.com/dvele55/schedule",
     docs: fn ->
        {ref, 0} = System.cmd("git", ["rev-parse", "--verify", "--quiet", "HEAD"])
        [source_ref: ref, readme: "README.md"]
     end,
     description: description,
     package: package]
  end

  def application do
    []
  end

  defp deps do
    [{:ex_doc, only: :dev},
     {:earmark, only: :dev},
     {:eqc_ex, "~> 1.2", only: :test},
     {:eqc, github: "rpt/eqcmini", only: :test, app: false, compile: false}]
  end

  defp description do
    """
    Basic operations with intervals for Elixir.
    """
  end

  defp package do
    [contributors: ["Marko Dvecko"],
     licenses: ["Apache 2.0"],
     links: %{"GitHub" => "https://github.com/dvele55/schedule"}]
  end
end
