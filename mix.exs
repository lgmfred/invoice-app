defmodule InvoiceApp.MixProject do
  use Mix.Project

  def project do
    [
      app: :invoice_app,
      version: "0.1.0",
      elixir: "~> 1.15",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      test_coverage: [tool: ExCoveralls, export: "cov"],
      preferred_cli_env: [
        ci: :test,
        "ci.code_quality": :test,
        "ci.deps": :test,
        "ci.formatting": :test,
        "ci.migrations": :test,
        "ci.security": :test,
        "ci.test": :test,
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.html": :test,
        credo: :test,
        dialyzer: :test,
        sobelow: :test
      ],
      compilers: [:yecc] ++ Mix.compilers(),
      compilers: [:leex] ++ Mix.compilers(),
      test_coverage: [tool: ExCoveralls],
      dialyzer: [
        ignore_warnings: ".dialyzer_ignore.exs",
        plt_add_apps: [:ex_unit, :mix],
        plt_file: {:no_warn, "priv/plts/dialyzer.plt"}
      ],

      # Docs
      name: "InvoiceGenerator",
      source_url: "https://github.com/kagure-nyakio/invoice_generator",
      docs: [
        extras: ["README.md"],
        main: "readme",
        source_ref: "main"
      ]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {InvoiceApp.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:bcrypt_elixir, "~> 3.0"},
      {:phoenix, "~> 1.7.10"},
      {:phoenix_ecto, "~> 4.4"},
      {:ecto_sql, "~> 3.10"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 3.3"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_view, "~> 0.20.1"},
      {:floki, ">= 0.30.0", only: :test},
      {:phoenix_live_dashboard, "~> 0.8.2"},
      {:esbuild, "~> 0.8", runtime: Mix.env() == :dev},
      {:tailwind, "~> 0.2.0", runtime: Mix.env() == :dev},
      {:swoosh, "~> 1.3"},
      {:finch, "~> 0.13"},
      {:telemetry_metrics, "~> 0.6"},
      {:telemetry_poller, "~> 1.0"},
      {:gettext, "~> 0.20"},
      {:jason, "~> 1.2"},
      {:dns_cluster, "~> 0.1.1"},
      {:plug_cowboy, "~> 2.5"},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:sobelow, "~> 0.13", only: [:dev, :test], runtime: false},
      {:mix_audit, "~> 2.1", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      {:excoveralls, "~> 0.18", only: :test},
      {:faker, "~> 0.17", only: [:dev, :test]},
      {:github_workflows_generator, "~> 0.1", only: :dev, runtime: false},
      {:countries, "~> 1.6"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "ecto.setup", "assets.setup", "assets.build"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
      "test.live": "test --only live",
      "assets.setup": ["tailwind.install --if-missing", "esbuild.install --if-missing"],
      "assets.build": ["tailwind default", "esbuild default"],
      "assets.deploy": ["tailwind default --minify", "esbuild default --minify", "phx.digest"],
      ci: [
        "ci.deps_and_security",
        "ci.formatting",
        "ci.code_quality",
        "ci.test"
        # "ci.migrations"
      ],
      "ci.code_quality": [
        "compile --force --warnings-as-errors",
        "credo --strict",
        "dialyzer"
      ],
      "ci.deps_and_security": [
        "deps.unlock --check-unused",
        "deps.audit",
        "sobelow --config .sobelow-conf"
      ],
      "ci.formatting": ["format --check-formatted", "cmd --cd assets npx prettier -c .."],
      "ci.migrations": [
        "ecto.create --quiet",
        "ecto.migrate --quiet",
        "ecto.rollback --all --quiet"
      ],
      "ci.test": [
        "ecto.create --quiet",
        "ecto.migrate --quiet",
        "test --cover --warnings-as-errors"
      ],
      prettier: ["cmd --cd assets npx prettier -w .."]
    ]
  end
end
