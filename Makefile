# - Makefile -
# (C) 2023 Joerg Jungermann, GPLv2 see LICENSE

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

#--- extract image from archive
%.img: %.rar img-mangler/unrar-img.sh
	$(E) "UNPACK $@ <--- $<"
	$(Q) ./bin/D6100 sh $(SHOPT) img-mangler/unrar-img.sh $< $@

%.img: %.zip img-mangler/unzip-img.sh
	$(E) "UNPACK $@ <--- $<"
	$(Q) ./bin/D6100 sh $(SHOPT) img-mangler/unzip-img.sh $< $@
	$(Q) touch $@

%.img: %.img.xz
	$(E) "UNPACK $@ <--- $<"
	$(Q) xz -cd < $< > $@

#--- extract filesystems from image
%.tar: %.img img-mangler/img-to-tar.sh
	$(E) "IMGtoTAR $@ <--- $<"
	$(Q) ./bin/D6100 -p -e COMPRESSOR=cat sh $(SHOPT) img-mangler/img-to-tar.sh $< $@

#---- import tar files into img-mangler image
.deps/%.built: %.tar Makefile ./img-mangler/tar-import.sh
	$(E) "IMPORT $(NAME_PFX)$(NAME):$(<:.tar=) <--- $<"
	$(Q) ./img-mangler/tar-import.sh $< $(NAME_PFX)$(NAME):$(<:.tar=)
	$(Q) : > "$@"

.deps/%.built: %.tgz Makefile ./img-mangler/tar-import.sh
	$(E) "IMPORT $(NAME_PFX)$(NAME):$(<:.tar=) <--- $<"
	$(Q) ./img-mangler/tar-import.sh $< $(NAME_PFX)$(NAME):$(<:.tgz=)
	$(Q) : > "$@"

#--- export mangled rootfs to tar
%.rootfs.tar.gz: .deps/%.built Makefile
	$(E) "ROOTFS $@"
	$(Q) ./bin/D6100 --image $(NAME_PFX)$(NAME):$(@:.rootfs.tar.gz=) tar czf - -C /target . >$@

#--- build a SDcard bootable image
%.sdcard.img: .deps/%.built Makefile ./img-mangler/docker-img-to-sdcard.sh uboot.img
	$(E) "IMG $@"
	$(Q) ./bin/D6100 -p --image $(NAME_PFX)$(NAME):$(@:.sdcard.img=) sh $(SHOPT) img-mangler/docker-img-to-sdcard.sh $@

#--- build an update image
%.update.img: .deps/%.built Makefile ./img-mangler/docker-img-to-sdcard.sh uboot.img
	$(E) "IMG $@"
	$(Q) ./bin/D6100 -p --image $(NAME_PFX)$(NAME):$(@:.update.img=) sh $(SHOPT) img-mangler/docker-img-to-sdcard.sh --update $@

#--- extract uboot from image
%.uboot.img: %.img
	$(E) "UBOOT $@"
	$(Q) dd if=$< of=$@ bs=1024 skip=8 count=640 status=none

#--- generate a known good uboot
uboot.img: Xiegu-1.1.7.1.update.uboot.img
	$(E) "UBOOT $@"
	$(Q) cat $< > $@

.deps/%.volume:
	$(E) "DOCKER VOLUME $(NAME_PFX)$(NAME)-$$( basename $(@:.volume=) )"
	$(Q) set $(SHOPT); \
		image="$(NAME_PFX)$(NAME)-$$( basename $(@:.volume=) )" ;\
		docker volume inspect $$image > $@ 2>/dev/null || \
		  docker volume create $$image > $@

.deps/%.built: %/workspace.sh .deps/img-mangler.built .deps/%.volume
	$(E) "WORKSPACE $(<:/workspace.sh=)"
	$(Q) ./bin/D6100 -v $(NAME_PFX)$(NAME)-buildroot:/workspace sh $< > $@

#--- extend clean-local target
clean-local: clean-volumes
	$(Q) rm -f *.zst *.img *.rar *.zip *.tar

clean-volumes:
	$(Q) docker volume ls -q | grep ^"$(NAME_PFX)$(NAME)-" | while read v; do \
		docker volume inspect "$$v" > /dev/null 2>&1 && \
		  docker volume rm "$$v" > /dev/null; \
		echo "DELETE VOLUME $$v" ;\
		rm -f "$$i";\
	done

# vim: ts=2 sw=2 noet ft=make
