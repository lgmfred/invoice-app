defmodule GithubWorkflows do
  @moduledoc """
  Used by a custom tool to generate GitHub workflows.
  Reduces repetition.
  """

  def get do
    %{
      "main.yml" => main_workflow(),
      "pr.yml" => pr_workflow()
    }
  end

  defp main_workflow do
    [
      [
        name: "Main",
        on: [
          push: [
            branches: ["main"]
          ]
        ],
        jobs: [
          compile: compile_job(),
          credo: credo_job(),
          deps_audit: deps_audit_job(),
          dialyzer: dialyzer_job(),
          format: format_job(),
          hex_audit: hex_audit_job(),
          migrations: migrations_job(),
          prettier: prettier_job(),
          sobelow: sobelow_job(),
          test: test_job(),
          unused_deps: unused_deps_job()
        ]
      ]
    ]
  end

  defp pr_workflow() do
    [
      [
        name: "PR",
        on: [
          pull_request: [
            branches: ["main"],
            types: ["opened", "reopened", "synchronize"]
          ]
        ],
        jobs: [
          compile: compile_job(),
          credo: credo_job(),
          deps_audit: deps_audit_job(),
          dialyzer: dialyzer_job(),
          format: format_job(),
          hex_audit: hex_audit_job(),
          migrations: migrations_job(),
          prettier: prettier_job(),
          sobelow: sobelow_job(),
          test: test_job(),
          unused_deps: unused_deps_job()
        ]
      ]
    ]
  end

  defp checkout_step do
    [
      name: "Checkout",
      uses: "actions/checkout@v2"
    ]
  end

  defp compile_job do
    elixir_job("Install deps and compile",
      steps: [
        [
          name: "Install Elixir dependencies",
          env: [MIX_ENV: "test"],
          run: "mix deps.get"
        ],
        [
          name: "Compile",
          env: [MIX_ENV: "test"],
          run: "mix compile"
        ]
      ]
    )
  end

  defp credo_job do
    elixir_job("Credo",
      needs: :compile,
      steps: [
        [
          name: "Check code style",
          env: [MIX_ENV: "test"],
          run: "mix credo --strict"
        ]
      ]
    )
  end

  defp deps_audit_job do
    elixir_job("Deps audit",
      needs: :compile,
      steps: [
        [
          name: "Check for vulnerable Mix dependencies",
          env: [MIX_ENV: "test"],
          run: "mix deps.audit"
        ]
      ]
    )
  end

  defp dialyzer_job do
    elixir_job("Dialyzer",
      needs: :compile,
      steps: [
        [
          # Don't cache PLTs based on mix.lock hash, as Dialyzer can incrementally update even old ones
          # Cache key based on Elixir & Erlang version (also useful when running in matrix)
          name: "Restore PLT cache",
          uses: "actions/cache@v3",
          id: "plt_cache",
          with: [
            key: "${{ runner.os }}-${{ env.elixir-version }}-${{ env.otp-version }}-plt",
            "restore-keys":
              "${{ runner.os }}-${{ env.elixir-version }}-${{ env.otp-version }}-plt",
            path: "priv/plts"
          ]
        ],
        [
          # Create PLTs if no cache was found
          name: "Create PLTs",
          if: "steps.plt_cache.outputs.cache-hit != 'true'",
          env: [MIX_ENV: "test"],
          run: "mix dialyzer --plt"
        ],
        [
          name: "Run dialyzer",
          env: [MIX_ENV: "test"],
          run: "mix dialyzer --format short 2>&1"
        ]
      ]
    )
  end

  defp elixir_job(name, opts) do
    needs = Keyword.get(opts, :needs)
    steps = Keyword.get(opts, :steps, [])
    services = Keyword.get(opts, :services)

    job = [
      name: name,
      "runs-on": "ubuntu-latest",
      env: [
        "elixir-version": "1.16.2",
        "otp-version": "25.3.2.10"
      ],
      steps:
        [
          checkout_step(),
          [
            name: "Set up Elixir",
            uses: "erlef/setup-beam@v1",
            with: [
              "elixir-version": "${{ env.elixir-version }}",
              "otp-version": "${{ env.otp-version }}"
            ]
          ],
          [
            uses: "actions/cache@v3",
            with: [
              path: "_build\ndeps",
              key: "${{ runner.os }}-mix-${{ hashFiles('**/mix.lock') }}",
              "restore-keys": "${{ runner.os }}-mix"
            ]
          ]
        ] ++ steps
    ]

    job
    |> then(fn job ->
      if needs do
        Keyword.put(job, :needs, needs)
      else
        job
      end
    end)
    |> then(fn job ->
      if services do
        Keyword.put(job, :services, services)
      else
        job
      end
    end)
  end

  defp format_job do
    elixir_job("Format",
      needs: :compile,
      steps: [
        [
          name: "Check Elixir formatting",
          env: [MIX_ENV: "test"],
          run: "mix format --check-formatted"
        ]
      ]
    )
  end

  defp hex_audit_job do
    elixir_job("Hex audit",
      needs: :compile,
      steps: [
        [
          name: "Check for retired Hex packages",
          env: [MIX_ENV: "test"],
          run: "mix hex.audit"
        ]
      ]
    )
  end

  defp migrations_job do
    elixir_job("Migrations",
      needs: :compile,
      services: [
        db: db_service()
      ],
      steps: [
        [
          name: "Check if migrations are reversible",
          env: [MIX_ENV: "test"],
          run: "mix ci.migrations"
        ]
      ]
    )
  end

  defp prettier_job do
    [
      name: "Check formatting using Prettier",
      "runs-on": "ubuntu-latest",
      steps: [
        checkout_step(),
        [
          name: "Restore npm cache",
          uses: "actions/cache@v3",
          id: "npm-cache",
          with: [
            path: "~/.npm",
            key: "${{ runner.os }}-node",
            "restore-keys": "${{ runner.os }}-node"
          ]
        ],
        [
          name: "Install Prettier",
          if: "steps.npm-cache.outputs.cache-hit != 'true'",
          run: "npm i -g prettier"
        ],
        [
          name: "Run Prettier",
          run: "npx prettier -c ."
        ]
      ]
    ]
  end

  defp sobelow_job do
    elixir_job("Security check",
      needs: :compile,
      steps: [
        [
          name: "Check for security issues using sobelow",
          env: [MIX_ENV: "test"],
          run: "mix sobelow --config .sobelow-conf"
        ]
      ]
    )
  end

  defp test_job do
    elixir_job("Test",
      needs: :compile,
      services: [
        db: db_service()
      ],
      steps: [
        [
          name: "Run tests",
          env: [MIX_ENV: "test"],
          run: "mix test --cover --warnings-as-errors"
        ]
      ]
    )
  end

  defp unused_deps_job do
    elixir_job("Check unused deps",
      needs: :compile,
      steps: [
        [
          name: "Check for unused Mix dependencies",
          env: [MIX_ENV: "test"],
          run: "mix deps.unlock --check-unused"
        ]
      ]
    )
  end

  defp db_service do
    [
      image: "postgres:13",
      ports: ["5432:5432"],
      env: [POSTGRES_PASSWORD: "postgres"],
      options:
        "--health-cmd pg_isready --health-interval 10s --health-timeout 5s --health-retries 5"
    ]
  end
end
