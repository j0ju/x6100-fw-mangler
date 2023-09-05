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

%.img: %.rar
	$(E) "UNPACK $@ <-- $<"
	$(Q) ./bin/D6100 sh $(SHOPT) img-mangler/unrar-img.sh $< $@

%.img: %.zip
	$(E) "UNPACK $@ <--- $<"
	$(Q) ./bin/D6100 sh $(SHOPT) img-mangler/unzip-img.sh $< $@
	$(Q) touch $@

%.tar: %.img
	$(E) "TAR $@ <--- $<"
	$(Q) ./bin/D6100 -p -e COMPRESSOR=cat sh $(SHOPT) img-mangler/img-to-tar.sh $< $@

.deps/%.built: %.tar
	$(E) "IMAGE $@ <--- $<"
	$(Q) ./img-mangler/tar-import.sh $< $(NAME_PFX)$(NAME):$(<:.tar=)

clean-local:
	$(Q) rm -f *.zst *.img *.rar *.zip *.tar

# vim: ts=2 sw=2 noet ft=make foldmethod=marker foldmarker=#-,#}
