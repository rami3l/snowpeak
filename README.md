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

- [asn2rflx] (`asn2rflx`): Used to generate `.rflx` declarations from `.asn` specifications.
- [RecordFlux] (`rflx`): Used to generate SPARK APIs from `.rflx` declarations.
- [pyexpander] (`expander.py`): Used to generate Ada source files from `.px` macros. A pre-commit hook is used to regenerate the Ada sources, so it is strongly discouraged to directly modify the generated sources.
- [Alire] (`alr`): Used to build the Ada project.

This project is known to build correctly in the following environment:

- [`asn2rflx cc8b733b9c`](https://github.com/rami3l/asn2rflx/tree/cc8b733b9c832a2561601b187fd7e5de9dcb26a3)
- [`rflx 0.5.1.dev436+gfca5f956`](https://github.com/Componolit/RecordFlux/tree/fca5f95693f0a37b582af4405ab366ebf1221b90)
- [`expander.py 2.1.1`](https://pypi.org/project/pyexpander/2.1.1/)
- [`alr 1.2.0`](https://github.com/alire-project/alire/releases/tag/v1.2.0)

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
