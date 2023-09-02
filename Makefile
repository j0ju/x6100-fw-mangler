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


%.update.img: %.update.rar
	$(E) UNPACK $@
	$(Q) docker run --rm -ti -v "$$PWD:/src" -w /src x6100:img-mangler sh $(SHOPT) img-mangler/unrar-img.sh $< $@

%.update.img: %.update.zip
	$(E) UNPACK $@
	$(Q) docker run --rm -ti -v "$$PWD:/src" -w /src x6100:img-mangler sh $(SHOPT) img-mangler/unzip-img.sh $< $@

%.update.tar: %.update.img
	$(E) TAR $@
	$(Q) docker run --privileged --rm -ti -v "$$PWD:/src" -e COMPRESSOR=cat -w /src x6100:img-mangler sh $(SHOPT) img-mangler/update-img-to-tar.sh $< $@

clean:
	$(E) CLEAN
	$(Q) rm -f *.zst *.img *.rar *.zip

# vim: ts=2 sw=2 noet ft=make foldmethod=marker foldmarker=#-,#}
