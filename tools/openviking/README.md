## OpenViking tool bundle

This bundle integrates the [OpenViking](https://github.com/volcengine/OpenViking)
context database into SWE-agent as a first–class tool bundle.

OpenViking provides a filesystem–style, multi–layered context store optimized for AI agents.
Here we expose a minimal set of commands that allow the agent to:

- Index the current repository into OpenViking
- Run high–level semantic search over the indexed context
- Retrieve L0/L1 abstracts and overviews for planning

### Commands

- `ov_init_repo [<path>] [--name <resource_name>] [--max_file_mb <mb>]`  
  Index the current repository (or a custom path) into OpenViking, wait for semantic
  processing to complete, and persist the resulting `viking://` root URI in the SWE-agent
  registry under `OPENVIKING_REPO_ROOT_URI`.

- `ov_search <query> [--uri=<viking_uri>] [--top_k=<k>]`  
  Perform a semantic search over the OpenViking context and print the top matches
  (URIs and short previews). By default it searches the repository URI stored by
  `ov_init_repo`.

- `ov_overview [--uri=<viking_uri>]`  
  Show a high–level overview for the repository or a specific sub–URI, using
  `client.overview` and falling back to a directory listing.

- `ov_abstract [--uri=<viking_uri>]`  
  Show the abstract (L0/L1) for the repository or a specific sub–URI, using
  `client.abstract`.

This bundle also exposes a state command `_ov_state` which returns a JSON object with
OpenViking–related state, currently:

- `openviking_repo_root_uri`
- `openviking_data_dir`

You can reference these fields in your templates (e.g. `instance_template`) if desired.

### Installation

The bundle uses a standard `install.sh` script:

```bash
tools/openviking/install.sh
```

This will install the `openviking` Python package into the SWE-agent environment.

> Note: If your `openviking` package is installed in a dedicated Python environment (e.g. conda),
> make sure SWE-agent runs under that same environment so the `ov_*` scripts can import it.

You must also configure OpenViking itself by providing a model configuration file and
pointing `OPENVIKING_CONFIG_FILE` to it, as described in the upstream OpenViking README.

Typical environment setup:

```bash
export OPENVIKING_CONFIG_FILE=/path/to/ov.conf
export OPENVIKING_DATA_DIR=/path/to/ov_data
```

### Enabling the bundle in a config

To enable the bundle for an agent, add it to the `bundles` list in your config. For example:

```yaml
agent:
  tools:
    bundles:
      - path: tools/registry        # keep registry first
      - path: tools/windowed
      - path: tools/search
      - path: tools/openviking      # enable OpenViking tools
```

Optionally, you can update your `instance_template` to gently remind the model when to use
the OpenViking tools, for example:

```yaml
agent:
  templates:
    instance_template: |-
      {{ problem_statement }}

      Use the tools as follows:
      - Use `ov_init_repo` once at the start (or after major refactors) to index the repository.
      - Use `ov_search` when you need semantic, cross–file understanding of the codebase.
      - Use `ov_overview` or `ov_abstract` when you want a high–level understanding of the repo
        or a specific component before editing.
```

