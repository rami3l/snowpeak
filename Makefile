# Define required macros here
SHELL = /bin/sh

RFLX = rflx
ASN2RFLX = asn2rflx
ASNS_DIR = ./share/snowpeak/asn
ASNS = $(shell find $(ASNS_DIR) -type f -name "*.asn")
SPECS_DIR = ./obj/asn2rflx
SPECS = $(shell find $(SPECS_DIR) -type f -name "*.rflx")
GENERATED_DIR = ./obj/rflx
GENERATED = $(shell find $(GENERATED_DIR) -type f -name "*.ad?")

# -include $(SPECS_DIR)
$(SPECS_DIR)/**: $(ASNS)
	mkdir -p $(SPECS_DIR)
	alr exec -- $(ASN2RFLX) -o $(SPECS_DIR) $(ASNS)

.PHONY: specs
specs: $(SPECS_DIR)/**

# -include $(GENERATED_DIR)
$(GENERATED_DIR)/**: $(SPECS_DIR)/**
	mkdir -p $(GENERATED_DIR)
    # HACK: --no-verification since it takes too long to verify.
	alr exec -- $(RFLX) --no-verification generate -d $(GENERATED_DIR) $(SPECS)

.PHONY: generate
generate: $(GENERATED_DIR)/**

.PHONY: expand
expand:
	sh -c 'for f in $$(find . -name "*.px"); do expander.py -af $$f > $$(dirname $$f)/$$(basename $$f .px); done'

.PHONY: clean
clean:
	rm -rf $(SPECS_DIR)
	rm -rf $(GENERATED_DIR)
	alr clean
