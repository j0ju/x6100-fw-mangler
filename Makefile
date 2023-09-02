# - Makefile -

include Makefile.Dockerfile.generic
NAME := x6100

# allow local config overrides, like in main Makefile used above
-include config

### generics ###

# override & disable push
DOCKER_IMAGES_PUSH_FLAGS :=

url download:
	$(Q) $(MAKE) $$( ls *.url | sed 's/.url$$//' )

# additional targets
build: $(WORK_FILES)

clean:
	$(E) CLEAN
	$(Q) rm -f *.zst *.img

# vim: ts=2 sw=2 noet ft=make foldmethod=marker foldmarker=#-,#}
