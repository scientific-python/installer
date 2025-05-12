# Notes on installer mechanics

Fundamental engine is <https://github.com/conda/constructor>, a tool for
creating double-click installers from a collection of Conda packages.

The README above has:

> The constructor command takes an installer specification directory as its
argument. This directory needs to contain a file construct.yaml, which
specifies the name of the installer, the conda channels to pull packages from,
the conda packages included in the installer, etc.

In this repo, that file is `recipes/mne-python/construct.yaml`.  It specifies,
among other things, that `conda-forge` is the only `channel` for fetching packages to provide installer.

```yaml
channels:
  - conda-forge
```

Later, it specifies that `conda-forge` is the only channel for the provided environment:


```yaml
condarc:
  channels:
    - conda-forge
  channel_priority: strict
  allow_other_channels: false
  env_prompt: "(mne-1.9.0_0) "
```

From [the contructor README](https://github.com/conda/constructor):

> ## condarc
>
> If set, a .condarc file is written to the base environment containing the
contents of this value. The value can either be a string (likely a multi-line
string) or a dictionary, which will be converted to a YAML string for writing.
Note: if this option is used, then all other options related to the
construction of a .condarc file (write_condarc, conda_default_channels, etc.)
are ignored.

Mac (Intel, ARM) build instructions are in `.github/workflows/build.yaml`.

## Build recipes

These are all in `.github/workflows/build.yml`.

### Mac build recipe

Summary of steps:

* `tools/extract_version.sh`: this is a shell script that extracts information
  from the environment, and puts this information into environment variables.
  Within a Github action, it also sets Github environment for subsequent steps.
*  `tools/run_constructor.sh` runs the `constructor` executable to build the
   package from the recipe above.
