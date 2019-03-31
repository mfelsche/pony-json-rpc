PACKAGE_DIR=jsonrpc
PONYC ?= ponyc
config ?= debug
ifdef config
  ifeq (,$(filter $(config),debug release))
    $(error Unknown configuration "$(config)")
  endif
endif

ifeq ($(config),debug)
	PONYC_FLAGS += --debug
endif

PONYC_FLAGS += -o build/$(config)


ALL: test

build/$(config)/test: .deps $(PACKAGE_DIR)/*.pony $(PACKAGE_DIR)/test/*.pony | build/$(config)
	stable env $(PONYC) ${PONYC_FLAGS} $(PACKAGE_DIR)/test

build/$(config):
	mkdir -p build/$(config)

.deps:
	stable fetch

test: build/$(config)/test
	build/$(config)/test

clean:
	rm -rf build

.PHONY: clean test
