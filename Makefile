#!smake
# --------------------------------------------------------------------
#        Copyright (C) 1998 Nintendo. (Originated by SGI)
#        
#        $RCSfile: Makefile,v $
#        $Revision: 1.1.1.1 $
#        $Date: 2002/05/02 03:27:21 $
# --------------------------------------------------------------------
include $(N64_ROOT)/usr/include/n64/make/PRdefs

SKELATOOL64:=skelatool64/skeletool64
VTF2PNG:=vtf2png
SFZ2N64:=sfz2n64

$(SKELATOOL64):
	skelatool64/setup_dependencies.sh



	@$(MAKE) -C skelatool64

# Use tag name if the current commit is tagged, otherwise use commit hash
# If not in a git repo, fall back to exported version
GAME_VERSION		:=  $(shell \
	(git describe --tags HEAD 2>/dev/null || cat version.txt) | \
	awk -F '-' '{print (NF >= 3 ? substr($$3, 2) : $$1)}' \
)

OPTIMIZER		:= -Os
LCDEFS			:= -DDEBUG -DGAME_VERSION=\"$(GAME_VERSION)\" -g -Werror -Wall
N64LIB			:= -lultra_rom

ifeq ($(PORTAL64_WITH_DEBUGGER),1)
LCDEFS += -DPORTAL64_WITH_DEBUGGER
endif

ifeq ($(PORTAL64_WITH_RSP_PROFILER),1)
LCDEFS += -DPORTAL64_WITH_RSP_PROFILER
endif

BASE_TARGET_NAME = build/portal

LD_SCRIPT	= portal.ld
CP_LD_SCRIPT	= build/portal

SCENE_SCALE = 128

ASMFILES    =	$(shell find asm/ -type f -name '*.s')

ASMOBJECTS  =	$(patsubst %.s, build/%.o, $(ASMFILES))

CODEFILES = $(shell find src/ -type f -name '*.c' | sort)

ifeq ($(PORTAL64_WITH_GFX_VALIDATOR),1)
LCDEFS += -DPORTAL64_WITH_GFX_VALIDATOR
CODEFILES += gfxvalidator/validator.c gfxvalidator/error_printer.c gfxvalidator/command_printer.c
endif

CODESEGMENT =	build/codesegment

BOOT		=	$(N64_ROOT)/usr/lib/n64/PR/bootcode/boot.6102
BOOT_OBJ	=	build/boot.o

UCODE_RSP	=	$(N64_ROOT)/usr/lib/n64/PR/rspboot.o
RSP_OBJ		=	build/rspboot.o

UCODE_GSP	=	$(N64_ROOT)/usr/lib/n64/PR/gspF3DEX2.fifo.o
GSP_OBJ		=	build/gspMain.o

UCODE_ASP	=	$(N64_ROOT)/usr/lib/n64/PR/aspMain.o
ASP_OBJ		=	build/aspMain.o

UCODE_OBJS	=	$(RSP_OBJ) $(GSP_OBJ) $(ASP_OBJ)

OBJECTS		=	$(ASMOBJECTS) $(BOOT_OBJ) $(UCODE_OBJS)

DEPS = $(patsubst %.c, build/%.d, $(CODEFILES)) $(patsubst %.c, build/%.d, $(DATAFILES))

-include $(DEPS)

LCINCS =	-I$(N64_ROOT)/usr/include/n64/PR -Isrc/ -I$(N64_ROOT)/opt/crashsdk/mips64-elf/include
LCDEFS +=	-DF3DEX_GBI_2 -DSCENE_SCALE=${SCENE_SCALE}
#LCDEFS +=	-DF3DEX_GBI_2 -DFOG
#LCDEFS +=	-DF3DEX_GBI_2 -DFOG -DXBUS
#LCDEFS +=	-DF3DEX_GBI_2 -DFOG -DXBUS -DSTOP_AUDIO

LDIRT  =	$(BASE_TARGET_NAME).elf $(CP_LD_SCRIPT) $(BASE_TARGET_NAME).z64 $(BASE_TARGET_NAME)_no_debug.map $(ASMOBJECTS)

LDDIRS  =	-L$(N64_ROOT)/usr/lib/n64 -L$(N64_ROOT)/opt/crashsdk/mips64-elf/lib -L$(N64_LIBGCCDIR)
LDFLAGS =	$(N64LIB) -lc -lgcc

default:	english_audio

english_audio: build/src/audio/subtitles.h portal_pak_dir $(SKELATOOL64)
	@$(MAKE) -C skelatool64
	@$(MAKE) buildgame

all_languages: build/src/audio/subtitles.h portal_pak_dir german_audio french_audio russian_audio spanish_audio $(SKELATOOL64)
	@$(MAKE) -C skelatool64
	@$(MAKE) buildgame

german_audio: vpk/portal_sound_vo_german_dir.vpk vpk/portal_sound_vo_german_000.vpk portal_pak_dir
	rm -rf portal_pak_dir/locales/de/
	vpk -x portal_pak_dir/locales/de/ vpk/portal_sound_vo_german_dir.vpk
	cd portal_pak_dir/locales/de/sound/vo/aperture_ai/; ls | xargs -I {} mv {} de_{}
	rm -rf assets/locales/de/sound/vo/aperture_ai/
	@mkdir -p assets/locales/de/sound/vo/aperture_ai/
	cp assets/sound/vo/aperture_ai/*.sox assets/locales/de/sound/vo/aperture_ai/
	cd assets/locales/de/sound/vo/aperture_ai/; rm -f ding_off.sox ding_on.sox
	cd assets/locales/de/sound/vo/aperture_ai/; ls | xargs -I {} mv {} de_{}
	
french_audio: vpk/portal_sound_vo_french_dir.vpk vpk/portal_sound_vo_french_000.vpk portal_pak_dir
	rm -rf portal_pak_dir/locales/fr/
	vpk -x portal_pak_dir/locales/fr/ vpk/portal_sound_vo_french_dir.vpk
	cd portal_pak_dir/locales/fr/sound/vo/aperture_ai/; ls | xargs -I {} mv {} fr_{}
	rm -rf assets/locales/fr/sound/vo/aperture_ai/
	@mkdir -p assets/locales/fr/sound/vo/aperture_ai/
	cp assets/sound/vo/aperture_ai/*.sox assets/locales/fr/sound/vo/aperture_ai/
	cd assets/locales/fr/sound/vo/aperture_ai/; rm -f ding_off.sox ding_on.sox
	cd assets/locales/fr/sound/vo/aperture_ai/; ls | xargs -I {} mv {} fr_{}
	
russian_audio: vpk/portal_sound_vo_russian_dir.vpk vpk/portal_sound_vo_russian_000.vpk portal_pak_dir
	rm -rf portal_pak_dir/locales/ru/
	vpk -x portal_pak_dir/locales/ru/ vpk/portal_sound_vo_russian_dir.vpk
	cd portal_pak_dir/locales/ru/sound/vo/aperture_ai/; ls | xargs -I {} mv {} ru_{}
	rm -rf assets/locales/ru/sound/vo/aperture_ai/
	@mkdir -p assets/locales/ru/sound/vo/aperture_ai/
	cp assets/sound/vo/aperture_ai/*.sox assets/locales/ru/sound/vo/aperture_ai/
	cd assets/locales/ru/sound/vo/aperture_ai/; rm -f ding_off.sox ding_on.sox
	cd assets/locales/ru/sound/vo/aperture_ai/; ls | xargs -I {} mv {} ru_{}
	
spanish_audio: vpk/portal_sound_vo_spanish_dir.vpk vpk/portal_sound_vo_spanish_000.vpk portal_pak_dir
	rm -rf portal_pak_dir/locales/es/
	vpk -x portal_pak_dir/locales/es/ vpk/portal_sound_vo_spanish_dir.vpk
	cd portal_pak_dir/locales/es/sound/vo/aperture_ai/; ls | xargs -I {} mv {} es_{}
	rm -rf assets/locales/es/sound/vo/aperture_ai/
	@mkdir -p assets/locales/es/sound/vo/aperture_ai/
	cp assets/sound/vo/aperture_ai/*.sox assets/locales/es/sound/vo/aperture_ai/
	cd assets/locales/es/sound/vo/aperture_ai/; rm -f ding_off.sox ding_on.sox
	cd assets/locales/es/sound/vo/aperture_ai/; ls | xargs -I {} mv {} es_{}

buildgame: $(BASE_TARGET_NAME).z64

# Allow targets to depend on the GAME_VERSION variable via a file.
# Update the file only when it differs from the variable (triggers rebuild).
.PHONY: gameversion
build/version.txt: gameversion
ifneq ($(shell cat build/version.txt 2>/dev/null), $(GAME_VERSION))
	@mkdir -p $(@D)
	@echo -n $(GAME_VERSION) > $@
endif

include $(COMMONRULES)

.s.o:
	$(AS) -Wa,-Iasm -o $@ $<

build/%.o: %.c
	@mkdir -p $(@D)
	$(CC) $(CFLAGS) -MM $^ -MF "$(@:.o=.d)" -MT"$@"
	$(CC) $(CFLAGS) -c -o $@ $<

build/%.o: %.s
	@mkdir -p $(@D)
	$(AS) -Wa,-Iasm -o $@ $<

####################
## Assets
####################

src/models/shadow_caster.h src/models/shadow_caster_geo.inc.h: assets/fbx/ShadowCaster.fbx
	skeletool64 -s 100 -r 0,0,0 -n shadow_caster -o src/models/shadow_caster.h assets/fbx/ShadowCaster.fbx

src/models/ground.h src/models/ground_geo.inc.h: assets/fbx/Ground.fbx
	skeletool64 -s 100 -r 0,0,0 -n ground -o src/models/ground.h assets/fbx/Ground.fbx

src/models/subject.h src/models/subject_geo.inc.h: assets/fbx/Subject.fbx
	skeletool64 -s 100 -r 0,0,0 -n subject -o src/models/subject.h assets/fbx/Subject.fbx

src/models/sphere.h src/models/sphere_geo.inc.h: assets/fbx/Sphere.fbx
	skeletool64 -s 100 -r 0,0,0 -n sphere -o src/models/sphere.h assets/fbx/Sphere.fbx


####################
## vpk extraction
####################

portal_pak_dir: vpk/Portal/portal/portal_pak_dir.vpk
	vpk -x portal_pak_dir vpk/Portal/portal/portal_pak_dir.vpk
	vpk -x portal_pak_dir vpk/Portal/hl2/hl2_sound_misc_dir.vpk
	vpk -x portal_pak_dir vpk/Portal/hl2/hl2_misc_dir.vpk

TEXTURE_SCRIPTS = $(shell find assets/ -type f -name '*.ims')
TEXTURE_IMAGES = $(TEXTURE_SCRIPTS:assets/%.ims=portal_pak_modified/%.png) \
	portal_pak_dir/materials/signage/indicator_lights/indicator_lights_corner_floor.png
TEXTURE_VTF_SOURCES = $(TEXTURE_SCRIPTS:assets/%.ims=portal_pak_dir/%.vtf)

ALL_VTF_IMAGES = $(shell find portal_pak_dir/ -type f ! -wholename '* *' -name '*.vtf')
ALL_PNG_IMAGES = $(ALL_VTF_IMAGES:%.vtf=%.png) \
	portal_pak_dir/materials/signage/signage_doorstate_on.png \
	portal_pak_dir/materials/signage/indicator_lights/indicator_lights_corner_floor_on.png \
	portal_pak_dir/materials/signage/indicator_lights/indicator_lights_floor_on.png

$(TEXTURE_VTF_SOURCES): portal_pak_dir

%.png: %.vtf
	-$(VTF2PNG) $< $@

portal_pak_dir/materials/signage/signage_doorstate_on.png: portal_pak_dir/materials/signage/signage_doorstate.vtf
	$(VTF2PNG) -f 2 $< $@

portal_pak_dir/materials/signage/indicator_lights/indicator_lights_corner_floor_on.png: portal_pak_dir/materials/signage/indicator_lights/indicator_lights_corner_floor.vtf
	$(VTF2PNG) -f 2 $< $@

portal_pak_dir/materials/signage/indicator_lights/indicator_lights_floor_on.png: portal_pak_dir/materials/signage/indicator_lights/indicator_lights_floor.vtf
	$(VTF2PNG) -f 2 $< $@

portal_pak_dir/materials/effects/portal_1_particle_orange.png: portal_pak_dir/materials/effects/portal_1_particle.vtf
	$(VTF2PNG) -f 2 $< $@

portal_pak_dir/materials/signage/clock/countdown.png: portal_pak_dir/materials/signage/clock/countdown.vtf
	$(VTF2PNG) -f 60 $< $@
portal_pak_dir/materials/signage/clock/countdown_1.png: portal_pak_dir/materials/signage/clock/countdown.vtf
	$(VTF2PNG) -f 59 $< $@
portal_pak_dir/materials/signage/clock/countdown_2.png: portal_pak_dir/materials/signage/clock/countdown.vtf
	$(VTF2PNG) -f 58 $< $@
portal_pak_dir/materials/signage/clock/countdown_3.png: portal_pak_dir/materials/signage/clock/countdown.vtf
	$(VTF2PNG) -f 57 $< $@
portal_pak_dir/materials/signage/clock/countdown_4.png: portal_pak_dir/materials/signage/clock/countdown.vtf
	$(VTF2PNG) -f 56 $< $@
portal_pak_dir/materials/signage/clock/countdown_5.png: portal_pak_dir/materials/signage/clock/countdown.vtf
	$(VTF2PNG) -f 55 $< $@
portal_pak_dir/materials/signage/clock/countdown_6.png: portal_pak_dir/materials/signage/clock/countdown.vtf
	$(VTF2PNG) -f 54 $< $@
portal_pak_dir/materials/signage/clock/countdown_7.png: portal_pak_dir/materials/signage/clock/countdown.vtf
	$(VTF2PNG) -f 53 $< $@
portal_pak_dir/materials/signage/clock/countdown_8.png: portal_pak_dir/materials/signage/clock/countdown.vtf
	$(VTF2PNG) -f 52 $< $@
portal_pak_dir/materials/signage/clock/countdown_9.png: portal_pak_dir/materials/signage/clock/countdown.vtf
	$(VTF2PNG) -f 51 $< $@

portal_pak_dir/materials/signage/clock/countdown.png: portal_pak_dir/materials/signage/clock/countdown_1.png portal_pak_dir/materials/signage/clock/countdown_2.png portal_pak_dir/materials/signage/clock/countdown_3.png portal_pak_dir/materials/signage/clock/countdown_4.png portal_pak_dir/materials/signage/clock/countdown_5.png portal_pak_dir/materials/signage/clock/countdown_6.png portal_pak_dir/materials/signage/clock/countdown_7.png portal_pak_dir/materials/signage/clock/countdown_8.png portal_pak_dir/materials/signage/clock/countdown_9.png portal_pak_dir/materials/signage/clock/clock_dots.png
portal_pak_dir/materials/signage/signage_overlay_fling1.png: portal_pak_dir/materials/signage/signage_overlay_fling2.png portal_pak_dir/materials/signage/signage_overlay_dots1.png portal_pak_dir/materials/signage/signage_overlay_dots2.png portal_pak_dir/materials/signage/signage_overlay_dots3.png portal_pak_dir/materials/signage/signage_overlay_dots4.png portal_pak_dir/materials/signage/signage_overlay_toxic.png portal_pak_dir/materials/signage/signage_overlay_fountain.png
portal_pak_dir/materials/signage/signage_overlay_midair1.png: portal_pak_dir/materials/signage/signage_overlay_midair2.png
portal_pak_dir/materials/signage/signage_exit.png: portal_pak_dir/materials/signage/signage_overlay_arrow.png portal_pak_dir/materials/signage/signage_overlay_boxdispenser.png portal_pak_dir/materials/signage/signage_overlay_boxhurt.png portal_pak_dir/materials/signage/signage_overlay_energyball.png portal_pak_dir/materials/signage/signage_overlay_catcher.png portal_pak_dir/materials/signage/signage_overlay_toxic.png portal_pak_dir/materials/signage/signage_overlay_fountain.png
portal_pak_dir/materials/signage/indicator_lights/indicator_lights_floor.png: portal_pak_dir/materials/signage/indicator_lights/indicator_lights_corner_floor.png
portal_pak_dir/materials/signage/indicator_lights/indicator_lights_floor_on.png: portal_pak_dir/materials/signage/indicator_lights/indicator_lights_corner_floor_on.png
portal_pak_dir/materials/models/props/round_elevator_sheet_1.png: portal_pak_dir/materials/models/props/round_elevator_sheet_3.png

convert_all_png: $(ALL_PNG_IMAGES)

portal_pak_modified/%.png: portal_pak_dir/%.png assets/%.ims
	@mkdir -p $(@D)
	convert $< $(shell cat $(@:portal_pak_modified/%.png=assets/%.ims)) $@

VALVE_INTRO_VIDEO = vpk/Portal/hl2/media/valve.bik

# the macOS Portal version uses a .mov file, so if the .bik file doesn't exist, let's try that
ifeq ("$(wildcard $(VALVE_INTRO_VIDEO))","")
    VALVE_INTRO_VIDEO := $(subst .bik,.mov,$(VALVE_INTRO_VIDEO))
endif

portal_pak_modified/images/valve.png portal_pak_modified/images/valve-no-logo.png:
	@mkdir -p $(@D)
	ffmpeg -ss 00:00:04 -i $(VALVE_INTRO_VIDEO) -frames:v 1 -q:v 2 -y portal_pak_modified/images/valve-full.png
	ffmpeg -ss 00:00:01 -i $(VALVE_INTRO_VIDEO) -frames:v 1 -q:v 2 -y portal_pak_modified/images/valve-full-no-logo.png
	convert portal_pak_modified/images/valve-full.png -crop 491x369+265+202 -resize 160x120 portal_pak_modified/images/valve.png
	convert portal_pak_modified/images/valve-full-no-logo.png -crop 492x370+266+202 -resize 160x120 portal_pak_modified/images/valve-no-logo.png

####################
## Materials
####################

build/assets/materials/static.h build/assets/materials/static_mat.c: assets/materials/static.skm.yaml $(TEXTURE_IMAGES) $(SKELATOOL64)
	@mkdir -p $(@D)
	$(SKELATOOL64) --name static -m $< --material-output -o build/assets/materials/static.h

build/assets/materials/ui.h build/assets/materials/ui_mat.c: assets/materials/ui.skm.yaml $(TEXTURE_IMAGES) $(SKELATOOL64)
	@mkdir -p $(@D)
	$(SKELATOOL64) --name ui --default-material default_ui -m $< --material-output -o build/assets/materials/ui.h

build/assets/materials/images.h build/assets/materials/images_mat.c: assets/materials/images.skm.yaml $(TEXTURE_IMAGES) $(SKELATOOL64) portal_pak_modified/images/valve.png
	@mkdir -p $(@D)
	$(SKELATOOL64) --name images --default-material default_ui -m $< --material-output -o build/assets/materials/images.h

build/assets/materials/hud.h build/assets/materials/hud_mat.c: assets/materials/hud.skm.yaml $(TEXTURE_IMAGES) $(SKELATOOL64)
	@mkdir -p $(@D)
	$(SKELATOOL64) --name hud -m $< --material-output -o build/assets/materials/hud.h

src/levels/level_def_gen.h: build/assets/materials/static.h

build/src/scene/hud.o: build/assets/materials/hud.h build/src/audio/subtitles.h

build/src/scene/elevator.o: build/assets/models/props/round_elevator_collision.h \
	build/assets/models/props/round_elevator.h \
	build/assets/models/props/round_elevator_interior.h \
	build/assets/materials/static.h

####################
## Models
####################
#
# Source engine scale is 64x
#

MODEL_LIST = assets/models/player/chell.blend \
	assets/models/portal_gun/ball_trail.blend \
	assets/models/portal_gun/v_portalgun.blend \
	assets/models/portal_gun/w_portalgun.blend \
	assets/models/props/round_elevator.blend \
	assets/models/props/round_elevator_interior.blend \
	assets/models/props/round_elevator_collision.blend \
	assets/models/props/signage.blend \
	assets/models/portal/portal_blue.blend \
	assets/models/portal/portal_blue_filled.blend \
	assets/models/portal/portal_blue_face.blend \
	assets/models/portal/portal_collider.blend \
	assets/models/portal/portal_collider_vertical.blend \
	assets/models/portal/portal_orange.blend \
	assets/models/portal/portal_orange_filled.blend \
	assets/models/portal/portal_orange_face.blend \
	assets/models/grav_flare.blend \
	assets/models/fleck_ash2.blend

DYNAMIC_MODEL_LIST = assets/models/cube/cube.blend \
	assets/models/props/autoportal_frame/autoportal_frame.blend \
	assets/models/props/cylinder_test.blend \
	assets/models/props/lab_chair.blend \
	assets/models/props/lab_desk/lab_desk01.blend \
	assets/models/props/lab_desk/lab_desk02.blend \
	assets/models/props/lab_desk/lab_desk03.blend \
	assets/models/props/lab_desk/lab_desk04.blend \
	assets/models/props/lab_monitor.blend \
	assets/models/props/radio.blend \
	assets/models/signage/clock_digits.blend \
	assets/models/signage/clock.blend \
	assets/models/props/box_dropper_glass.blend \
	assets/models/props/portal_cleanser.blend \
	assets/models/props/light_rail_endcap.blend

DYNAMIC_ANIMATED_MODEL_LIST = assets/models/pedestal.blend \
	assets/models/props/box_dropper.blend \
	assets/models/props/button.blend \
	assets/models/props/combine_ball_catcher.blend \
	assets/models/props/combine_ball_launcher.blend \
	assets/models/props/door_01.blend \
	assets/models/props/door_02.blend \
	assets/models/props/security_camera.blend \
	assets/models/props/switch001.blend

ANIM_LIST = build/assets/models/pedestal_anim.o \
	build/assets/models/player/chell_anim.o \
	build/assets/models/portal_gun/v_portalgun_anim.o \
	build/assets/models/props/box_dropper_anim.o \
	build/assets/models/props/combine_ball_catcher_anim.o \
	build/assets/models/props/combine_ball_launcher_anim.o \
	build/assets/models/props/door_01_anim.o \
	build/assets/models/props/door_02_anim.o \
	build/assets/models/props/switch001_anim.o

MODEL_HEADERS = $(MODEL_LIST:%.blend=build/%.h)
MODEL_OBJECTS = $(MODEL_LIST:%.blend=build/%_geo.o) \
	build/assets/models/dynamic_model_list.o \
	build/assets/models/dynamic_animated_model_list.o

DYNAMIC_MODEL_HEADERS = $(DYNAMIC_MODEL_LIST:%.blend=build/%.h)
DYNAMIC_MODEL_OBJECTS = $(DYNAMIC_MODEL_LIST:%.blend=build/%_geo.o)

DYNAMIC_ANIMATED_MODEL_HEADERS = $(DYNAMIC_ANIMATED_MODEL_LIST:%.blend=build/%.h)
DYNAMIC_ANIMATED_MODEL_OBJECTS = $(DYNAMIC_ANIMATED_MODEL_LIST:%.blend=build/%_geo.o)

build/assets/models/%.h build/assets/models/%_geo.c build/assets/models/%_anim.c: build/assets/models/%.fbx assets/models/%.flags assets/materials/elevator.skm.yaml assets/materials/objects.skm.yaml assets/materials/static.skm.yaml $(TEXTURE_IMAGES) $(SKELATOOL64)
	$(SKELATOOL64) --fixed-point-scale ${SCENE_SCALE} --model-scale 0.01 --name $(<:build/assets/models/%.fbx=%) $(shell cat $(<:build/assets/models/%.fbx=assets/models/%.flags)) -o $(<:%.fbx=%.h) $<

build/assets/models/player/chell.h: assets/materials/chell.skm.yaml
build/assets/models/props/combine_ball_catcher.h: assets/materials/ball_catcher.skm.yaml
build/assets/models/props/combine_ball_launcher.h: assets/materials/ball_catcher.skm.yaml
build/src/audio/soundplayer.o: build/src/audio/subtitles.h
build/src/decor/decor_object_list.o: build/assets/models/dynamic_model_list.h build/assets/materials/static.h
build/src/effects/effect_definitions.o: build/assets/materials/static.h
build/src/effects/portal_trail.o: build/assets/materials/static.h build/assets/models/portal_gun/ball_trail.h
build/src/levels/level_definition.o: build/src/audio/subtitles.h
build/src/levels/level_definition.h: build/src/audio/subtitles.h
build/src/locales/locales.o: build/src/audio/clips.h build/src/audio/languages.h
build/src/menu/controls.o: build/assets/materials/ui.h build/src/audio/clips.h build/src/audio/subtitles.h
build/src/menu/game_menu.o: build/src/audio/clips.h build/assets/materials/ui.h build/assets/materials/images.h build/assets/test_chambers/test_chamber_00/test_chamber_00.h
build/src/menu/gameplay_options.o: build/assets/materials/ui.h build/src/audio/clips.h
build/src/menu/joystick_options.o: build/assets/materials/ui.h build/src/audio/clips.h
build/src/menu/landing_menu.o: build/assets/materials/ui.h build/src/audio/clips.h build/version.txt
build/src/menu/load_game.o: build/assets/materials/ui.h build/src/audio/clips.h build/src/audio/subtitles.h
build/src/menu/main_menu.o: build/src/audio/clips.h build/assets/materials/ui.h build/assets/materials/images.h build/assets/test_chambers/test_chamber_00/test_chamber_00.h
build/src/menu/new_game_menu.o: build/src/audio/clips.h build/assets/materials/ui.h build/assets/materials/images.h build/src/audio/subtitles.h build/assets/test_chambers/test_chamber_00/test_chamber_00.h
build/src/menu/options_menu.o: build/assets/materials/ui.h build/src/audio/clips.h build/src/audio/subtitles.h
build/src/menu/save_game_menu.o: build/src/audio/clips.h build/src/audio/subtitles.h
build/src/menu/text_manipulation.o: build/src/audio/subtitles.h
build/src/scene/scene_animator.o: build/src/audio/clips.h
build/src/menu/cheat_codes.o: build/src/audio/clips.h
build/src/levels/intro.o: build/src/audio/clips.h build/assets/materials/images.h
build/src/levels/credits.o: build/src/audio/clips.h build/assets/materials/ui.h
build/src/menu/savefile_list.o: build/assets/materials/ui.h build/src/audio/clips.h
build/src/font/dejavusans_images.o: build/assets/materials/ui.h
build/src/font/liberation_mono_images.o: build/assets/materials/ui.h
build/src/player/player.o: build/assets/models/player/chell.h build/assets/materials/static.h build/src/audio/subtitles.h
build/src/scene/ball_catcher.o: build/assets/models/props/combine_ball_catcher.h build/assets/materials/static.h build/assets/models/dynamic_animated_model_list.h
build/src/scene/ball_launcher.o: build/assets/models/props/combine_ball_launcher.h build/assets/materials/static.h build/assets/models/dynamic_animated_model_list.h
build/src/scene/ball.o: build/assets/models/grav_flare.h build/assets/models/fleck_ash2.h build/assets/materials/static.h
build/src/scene/box_dropper.o: build/assets/materials/static.h build/assets/models/props/box_dropper.h build/assets/models/dynamic_model_list.h build/assets/models/dynamic_animated_model_list.h
build/src/scene/button.o: build/assets/materials/static.h build/assets/models/props/button.h build/assets/models/dynamic_animated_model_list.h
build/src/scene/clock.o: build/assets/models/dynamic_model_list.h
build/src/scene/door.o: build/assets/materials/static.h build/assets/models/props/door_01.h build/assets/models/props/door_02.h build/assets/models/dynamic_animated_model_list.h
build/src/scene/fizzler.o: build/assets/models/dynamic_model_list.h
build/src/scene/pedestal.o: build/assets/materials/static.h build/assets/models/pedestal.h build/assets/models/dynamic_animated_model_list.h build/assets/models/portal_gun/w_portalgun.h
build/src/scene/portal_gun.o: build/assets/materials/static.h $(MODEL_HEADERS)
build/src/scene/portal_render.o: $(MODEL_HEADERS)
build/src/scene/portal.o: $(MODEL_HEADERS)
build/src/scene/render_plan.o: $(MODEL_HEADERS)
build/src/scene/security_camera.o: build/src/audio/clips.h build/assets/models/props/security_camera.h build/assets/models/dynamic_animated_model_list.h
build/src/scene/signage.o: $(MODEL_HEADERS)
build/src/scene/switch.o: build/assets/models/props/switch001.h build/assets/materials/static.h build/assets/models/dynamic_animated_model_list.h
build/src/util/dynamic_asset_loader.o: build/assets/models/dynamic_model_list.h build/assets/models/dynamic_animated_model_list.h
build/src/menu/audio_options.o: build/src/audio/subtitles.h
build/src/menu/video_options.o: build/src/audio/subtitles.h
build/src/scene/scene.o: build/src/audio/subtitles.h build/src/audio/clips.h
build/src/menu/main_menu.o: build/src/audio/subtitles.h


ANIM_TEST_CHAMBERS = build/assets/test_chambers/test_chamber_00/test_chamber_00_anim.o \
    build/assets/test_chambers/test_chamber_03/test_chamber_03_anim.o \
	build/assets/test_chambers/test_chamber_04/test_chamber_04_anim.o \
	build/assets/test_chambers/test_chamber_06/test_chamber_06_anim.o \
	build/assets/test_chambers/test_chamber_07/test_chamber_07_anim.o \
	build/assets/test_chambers/test_chamber_08/test_chamber_08_anim.o \
	build/assets/test_chambers/test_chamber_09/test_chamber_09_anim.o \
	build/assets/test_chambers/test_chamber_10/test_chamber_10_anim.o

build/anims.ld: $(ANIM_LIST) $(ANIM_TEST_CHAMBERS) tools/generate_animation_ld.js
	@mkdir -p $(@D)
	node tools/generate_animation_ld.js $@ $(ANIM_LIST) $(ANIM_TEST_CHAMBERS)

####################
## Test Chambers
####################

TEST_CHAMBERS = assets/test_chambers/test_chamber_00/test_chamber_00.blend \
	assets/test_chambers/test_chamber_01/test_chamber_01.blend \
	assets/test_chambers/test_chamber_02/test_chamber_02.blend \
	assets/test_chambers/test_chamber_03/test_chamber_03.blend \
	assets/test_chambers/test_chamber_04/test_chamber_04.blend \
	assets/test_chambers/test_chamber_05/test_chamber_05.blend \
	assets/test_chambers/test_chamber_06/test_chamber_06.blend \
	assets/test_chambers/test_chamber_07/test_chamber_07.blend \
	assets/test_chambers/test_chamber_08/test_chamber_08.blend \
	assets/test_chambers/test_chamber_09/test_chamber_09.blend \
	assets/test_chambers/test_chamber_10/test_chamber_10.blend

TEST_CHAMBER_HEADERS = $(TEST_CHAMBERS:%.blend=build/%.h)
TEST_CHAMBER_OBJECTS = $(TEST_CHAMBERS:%.blend=build/%_geo.o)

LUA_FILES = $(shell find tools/ -type f -name '*.lua')

build/%.fbx: %.blend
	@mkdir -p $(@D)
	$(BLENDER_3_6) $< --background --python tools/models/export_fbx.py -- $@

build/assets/test_chambers/%.h build/assets/test_chambers/%_geo.c build/assets/test_chambers/%_anim.c: build/assets/test_chambers/%.fbx assets/test_chambers/%.yaml build/assets/materials/static.h build/src/audio/subtitles.h $(SKELATOOL64) $(TEXTURE_IMAGES) $(LUA_FILES)
	$(SKELATOOL64) --script tools/level_scripts/export_level.lua --fixed-point-scale ${SCENE_SCALE} --model-scale 0.01 --name $(<:build/assets/test_chambers/%.fbx=%) -m assets/materials/static.skm.yaml -o $(<:%.fbx=%.h) $<

build/assets/test_chambers/%.o: build/assets/test_chambers/%.c build/assets/materials/static.h
	@mkdir -p $(@D)
	$(CC) $(CFLAGS) -MM $^ -MF "$(@:.o=.d)" -MT"$@"
	$(CC) $(CFLAGS) -c -o $@ $<
	
build/assets/materials/%_mat.o: build/assets/materials/%_mat.c
	@mkdir -p $(@D)
	$(CC) $(CFLAGS) -MM $^ -MF "$(@:.o=.d)" -MT"$@"
	$(CC) $(CFLAGS) -c -o $@ $<

levels: $(TEST_CHAMBER_HEADERS)
	echo $(TEST_CHAMBER_HEADERS)

build/assets/test_chambers/level_list.h: $(TEST_CHAMBER_HEADERS) tools/models/generate_level_list.js tools/models/model_list_utils.js
	@mkdir -p $(@D)
	node tools/models/generate_level_list.js $@ $(TEST_CHAMBER_HEADERS)

build/assets/models/dynamic_model_list.h build/assets/models/dynamic_model_list.c: $(DYNAMIC_MODEL_HEADERS) tools/models/generate_dynamic_model_list.js tools/models/model_list_utils.js build/assets/models/cube/cube.h
	@mkdir -p $(@D)
	node tools/models/generate_dynamic_model_list.js build/assets/models/dynamic_model_list.h $(DYNAMIC_MODEL_HEADERS)

build/assets/models/dynamic_animated_model_list.h build/assets/models/dynamic_animated_model_list.c: $(DYNAMIC_ANIMATED_MODEL_HEADERS) tools/models/generate_dynamic_animated_model_list.js tools/models/model_list_utils.js
	@mkdir -p $(@D)
	node tools/models/generate_dynamic_animated_model_list.js build/assets/models/dynamic_animated_model_list.h $(DYNAMIC_ANIMATED_MODEL_HEADERS)

build/levels.ld: $(TEST_CHAMBER_OBJECTS) tools/generate_level_ld.js
	@mkdir -p $(@D)
	node tools/generate_level_ld.js $@ 0x02000000 $(TEST_CHAMBER_OBJECTS)

build/dynamic_models.ld: $(DYNAMIC_MODEL_OBJECTS) $(DYNAMIC_ANIMATED_MODEL_OBJECTS) tools/generate_level_ld.js
	@mkdir -p $(@D)
	node tools/generate_level_ld.js $@ 0x03000000 $(DYNAMIC_MODEL_OBJECTS) $(DYNAMIC_ANIMATED_MODEL_OBJECTS)

build/src/levels/levels.o: build/assets/test_chambers/level_list.h build/assets/materials/static.h

.PHONY: levels

####################
## Sounds
####################

SOUND_ATTRIBUTES = $(shell find assets/ -type f -name '*.sox')
SOUND_JATTRIBUTES = $(shell find assets/ -type f -name '*.jsox')

MUSIC_ATTRIBUTES = $(shell find assets/sound/music/ -type f -name '*.msox')

INS_SOUNDS = $(shell find assets/ -type f -name '*.ins')

SOUND_CLIPS = $(SOUND_ATTRIBUTES:%.sox=build/%.aifc) $(SOUND_JATTRIBUTES:%.jsox=build/%.aifc) $(INS_SOUNDS) $(MUSIC_ATTRIBUTES:%.msox=build/%.aifc)

$(INS_SOUNDS): portal_pak_dir

portal_pak_dir/sound/music/%.wav: portal_pak_dir/sound/music/%.mp3

portal_pak_dir/sound/ambient/music/valve.wav:
	@mkdir -p $(@D)
	ffmpeg -i $(VALVE_INTRO_VIDEO) -vn -y $@

build/assets/sound/vehicles/tank_turret_loop1.wav: portal_pak_dir
	@mkdir -p $(@D)
	sox portal_pak_dir/sound/vehicles/tank_turret_loop1.wav -b 16 $@

build/assets/sound/ambient/atmosphere/ambience_base.wav: portal_pak_dir
	@mkdir -p $(@D)
	sox portal_pak_dir/sound/ambient/atmosphere/ambience_base.wav -c 1 -r 22050 $@

build/assets/%.aifc: assets/%.sox portal_pak_dir/%.wav
	@mkdir -p $(@D)
	sox $(<:assets/%.sox=portal_pak_dir/%.wav) $(shell cat $<) $(@:%.aifc=%.wav)
	$(SFZ2N64) -o $@ $(@:%.aifc=%.wav)

build/assets/%.aifc: assets/%.jsox tools/sound/jsox.js portal_pak_dir/%.wav
	@mkdir -p $(@D)
	node tools/sound/jsox.js sox $< $(<:assets/%.jsox=portal_pak_dir/%.wav) $(@:%.aifc=%.wav)
	$(SFZ2N64) -o $@ $(@:%.aifc=%.wav)

build/assets/%.aifc: assets/%.msox portal_pak_dir/%.mp3
	@mkdir -p $(@D)
	ffmpeg -y -i $(<:assets/%.msox=portal_pak_dir/%.mp3) $(<:assets/%.msox=portal_pak_dir/%.wav)
	sox $(<:assets/%.msox=portal_pak_dir/%.wav) $(shell cat $<) $(@:%.aifc=%.wav)
	$(SFZ2N64) -o $@ $(@:%.aifc=%.wav)

build/assets/sound/sounds.sounds build/assets/sound/sounds.sounds.tbl: $(SOUND_CLIPS) build/assets/sound/vehicles/tank_turret_loop1.wav build/assets/sound/ambient/atmosphere/ambience_base.wav
	@mkdir -p $(@D)
	$(SFZ2N64) -o $@ $^


build/asm/sound_data.o: build/assets/sound/sounds.sounds build/assets/sound/sounds.sounds.tbl

build/src/audio/clips.h build/src/audio/languages.h build/src/audio/languages.c: tools/sound/generate_sound_ids.js $(SOUND_CLIPS)
	@mkdir -p $(@D)
	node tools/sound/generate_sound_ids.js -o $(@D) -p SOUNDS_ $(SOUND_CLIPS)

build/src/audio/clips.o: build/src/audio/clips.h
build/src/decor/decor_object_list.o: build/src/audio/clips.h

####################
## Subtitles
####################

SUBTITLE_SOURCES = $(shell find build/src/audio/ -type f -name 'subtitles_*.c')
SUBTITLE_OBJECTS = $(patsubst %.c, %.o, $(SUBTITLE_SOURCES))
	
build/src/audio/subtitles_%.o: build/src/audio/subtitles_%.c
	@mkdir -p $(@D)
	$(CC) $(CFLAGS) -MM $^ -MF "$(@:.o=.d)" -MT"$@"
	$(CC) $(CFLAGS) -c -o $@ $<

build/src/audio/subtitles.h build/src/audio/subtitles.c build/subtitles.ld: vpk/Portal/portal/resource/closecaption_english.txt vpk/Portal/hl2/resource/gameui_english.txt vpk/Portal/hl2/resource/valve_english.txt assets/translations/extra_english.txt tools/subtitle_generate.py
	python3 tools/subtitle_generate.py
	
####################
## Linking
####################

$(BOOT_OBJ): $(BOOT)
	$(OBJCOPY) -I binary -B mips -O elf32-bigmips $< $@

$(RSP_OBJ): $(UCODE_RSP)
$(GSP_OBJ): $(UCODE_GSP)
$(ASP_OBJ): $(UCODE_ASP)
$(UCODE_OBJS):
	cp $< $@

# without debugger

CODEOBJECTS = $(patsubst %.c, build/%.o, $(CODEFILES)) \
	$(MODEL_OBJECTS) \
	build/assets/materials/static_mat.o \
	build/assets/materials/ui_mat.o \
	build/assets/materials/hud_mat.o \
	build/src/audio/subtitles.o \
	build/src/audio/languages.o

CODEOBJECTS_NO_DEBUG = $(CODEOBJECTS)

DATA_OBJECTS = build/assets/materials/images_mat.o

ifeq ($(PORTAL64_WITH_DEBUGGER),1)
CODEOBJECTS_NO_DEBUG += build/debugger/debugger_stub.o build/debugger/serial_stub.o 
endif

$(CODESEGMENT)_no_debug.o:	$(CODEOBJECTS_NO_DEBUG)
	$(LD) -o $(CODESEGMENT)_no_debug.o -r $(CODEOBJECTS_NO_DEBUG) $(LDDIRS) $(LDFLAGS)


$(CP_LD_SCRIPT)_no_debug.ld: $(LD_SCRIPT) build/levels.ld build/dynamic_models.ld build/anims.ld build/subtitles.ld
	cpp -P -Wno-trigraphs $(LCDEFS) -DCODE_SEGMENT=$(CODESEGMENT)_no_debug.o -o $@ $<

$(BASE_TARGET_NAME).z64: $(CODESEGMENT)_no_debug.o $(OBJECTS) $(DATA_OBJECTS) $(SUBTITLE_OBJECTS) $(CP_LD_SCRIPT)_no_debug.ld
	$(LD) -L. -T $(CP_LD_SCRIPT)_no_debug.ld -Map $(BASE_TARGET_NAME)_no_debug.map -o $(BASE_TARGET_NAME).elf
	$(OBJCOPY) --pad-to=0x100000 --gap-fill=0xFF $(BASE_TARGET_NAME).elf $(BASE_TARGET_NAME).z64 -O binary
	makemask $(BASE_TARGET_NAME).z64
	sh tools/romfix64.sh $(BASE_TARGET_NAME).z64

# with debugger
CODEOBJECTS_DEBUG = $(CODEOBJECTS) 

ifeq ($(PORTAL64_WITH_DEBUGGER),1)
CODEOBJECTS_DEBUG += build/debugger/debugger.o build/debugger/serial.o 
endif

$(CODESEGMENT)_debug.o:	$(CODEOBJECTS_DEBUG)
	$(LD) -o $(CODESEGMENT)_debug.o -r $(CODEOBJECTS_DEBUG $(LDDIRS) $(LDFLAGS)

$(CP_LD_SCRIPT)_debug.ld: $(LD_SCRIPT) build/levels.ld build/dynamic_models.ld build/anims.ld build/subtitles.ld
	cpp -P -Wno-trigraphs $(LCDEFS) -DCODE_SEGMENT=$(CODESEGMENT)_debug.o -o $@ $<

$(BASE_TARGET_NAME)_debug.z64: $(CODESEGMENT)_debug.o $(OBJECTS) $(DATA_OBJECTS) $(SUBTITLE_OBJECTS) $(CP_LD_SCRIPT)_debug.ld
	$(LD) -L. -T $(CP_LD_SCRIPT)_debug.ld -Map $(BASE_TARGET_NAME)_debug.map -o $(BASE_TARGET_NAME)_debug.elf
	$(OBJCOPY) --pad-to=0x100000 --gap-fill=0xFF $(BASE_TARGET_NAME)_debug.elf $(BASE_TARGET_NAME)_debug.z64 -O binary
	makemask $(BASE_TARGET_NAME)_debug.z64
	sh tools/romfix64.sh $(BASE_TARGET_NAME).z64

clean:
	rm -rf build
	rm -rf portal_pak_dir
	rm -rf portal_pak_modified
	rm -rf assets/locales
	@$(MAKE) -C skelatool64 clean

clean-src:
	rm -rf build/src
	rm -f $(CODESEGMENT)_debug.o
	rm -f $(CODESEGMENT)_no_debug.o
	rm -f $(BASE_TARGET_NAME)_debug.elf
	rm -f $(BASE_TARGET_NAME).elf
	rm -f $(BASE_TARGET_NAME).z64
	rm -f $(BASE_TARGET_NAME)_debug.z64

clean-assets:
	rm -rf build/assets
	rm -rf assets/locales/
	rm -f $(CODESEGMENT)_debug.o
	rm -f $(CODESEGMENT)_no_debug.o
	rm -f $(BASE_TARGET_NAME)_debug.elf
	rm -f $(BASE_TARGET_NAME).elf
	rm -f $(BASE_TARGET_NAME).z64
	rm -f $(BASE_TARGET_NAME)_debug.z64

.SECONDARY:
