# snowpeak

[WIP] A PoC implementation of an SNMPv1 agent using [RecordFlux] and [asn2rflx].

---

## Contents

- [snowpeak](#snowpeak)
  - [Contents](#contents)
  - [Development](#development)

---

## Development

This project is built with GNU `make`. You will also need the following binaries installed in your `PATH`:

- Python build dependencies:
  - [asn2rflx] (`asn2rflx`): Used to generate `.rflx` declarations from `.asn` specifications.
  - [RecordFlux] (`rflx`): Used to generate SPARK APIs from `.rflx` declarations.
  - [pyexpander] (`expander.py`): Used to generate Ada source files from `.px` macros. A pre-commit hook is used to regenerate the Ada sources, so it is strongly discouraged to directly modify the generated sources.
- [Alire] (`alr`): Used to build the Ada project.
  - This project is known to build correctly with [`alr 1.2.0`](https://github.com/alire-project/alire/releases/tag/v1.2.0) and toolchain `gnat_native=12.1.1`.

To install all Python build dependencies in a quick way:

```bash
# Preferably executed in a virtual environment:
pip install -r requirements.txt
```

To build the project:

```bash
make build
```

It is also possible to execute the separate steps in the building process:

```bash
# Generate the `.rflx` declarations and the SPARK APIs.
make generate

# Expand the `.px` macros to Ada sources.
make expand
```

[alire]: https://github.com/alire-project/alire
[recordflux]: https://github.com/Componolit/RecordFlux
[asn2rflx]: https://github.com/rami3l/asn2rflx
[pyexpander]: https://pypi.org/project/pyexpander
