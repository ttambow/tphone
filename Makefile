raylib_basedir := ./raylib
raylib_src := $(raylib_basedir)/src
raylib_repo := https://github.com/raysan5/raylib.git
raylib_lib := libraylib.a
raylib_header := raylib.h

include_dir = include
build_dir = build
libs_dir = libs

cc := clang
cflags := -Wall -Wextra -g -I$(include_dir) -I$(libs_dir)
cflags_raylib := PLATFORM=PLATFORM_DESKTOP STATIC=1
ldflags = -lm -lpthread -ldl -lrt -lX11

target := $(build_dir)/tphone
src := $(wildcard src/*.c)
obj := $(src:.c=.o)
src_files = $(wildcard src/*.c)
obj_files = $(patsubst src/%.c,$(build_dir)/%.o,$(src_files))

all: $(target)

$(libs_dir):
	mkdir -p $(libs_dir)

$(libs_dir)/$(raylib_lib): | $(libs_dir)
	@echo "building raylib..."
	git clone --depth 1 $(raylib_repo) $(raylib_basedir)
	cd $(raylib_src) && make $(cflags_raylib)
	cp -f $(raylib_src)/$(raylib_lib) $(libs_dir)/
	cp -f $(raylib_src)/$(raylib_header) $(libs_dir)/
	rm -rf $(raylib_basedir)

$(target): $(obj_files) $(libs_dir)/$(raylib_lib)
	@mkdir -p $(dir $@)
	$(cc) -o $@ $^ $(ldflags)

$(build_dir)/%.o: src/%.c $(libs_dir)/$(raylib_lib)
	@mkdir -p $(build_dir)
	$(cc) $(cflags) -I$(include_dir) -I $(libs_dir) -c $< -o $@

%.o: %.c
	$(cc) $(cflags) -c $< -o $@

run:
	make && ./$(target)

clean:
	rm -f $(obj) $(target)
	rm -rf $(build_dir)/
	rm -rf $(libs_dir)/
	rm -rf $(raylib_basedir)/

.phony: all clean
