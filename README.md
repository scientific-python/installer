# Installers for core Scientific Python packages

Installers for the core Scientific Python packages for macOS, Windows, and Linux.

<img src="https://TODO.png" alt="Screenshot of installer running on macOS" width="450px">

Please visit [the installers tutorial (link TODO)](https://TODO) for instructions on how to use them.

## Development

Locally, installers can be built using `tools/build_local.sh`. Steps:

1. Set up and activate a `conda` env with a forked version of `constructor`:
   ```console
   $ conda env create -f environment.yml
   $ conda activate constructor-env
   ```
2. Run `./tools/build_local.sh`.
3. Install the environment for your platform.
4. Test it using the `tests/`.
