.ONESHELL:

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

debian_pkgs := libx11-dev libglfw3-dev libxcursor-dev libxinerama-dev libxi-dev

define check_deb_pkg
	dpkg -s $(1) >/dev/null 2>&1 || missing_deb_pkgs += $(1)
endef

dependencies:
	@echo "checking dependencies..."
	@$(foreach pkg,$(debian_pkgs),$(call check_deb_pkg,$(pkg)))
	@if [ -n "$$missing_deb_pkgs" ]; then \
		echo "installing missing packages: $$missing_deb_pkgs"; \
		sudo apt -y install $$missing_deb_pkgs; \
	else \
		echo "all debian dependencies already installed"; \
	fi

$(libs_dir)/$(raylib_lib): dependencies # todo: handle git errors
	@mkdir -p $(libs_dir)
	@if [ ! -d "$(raylib_basedir)" ]; then \
  		echo "cloning from git..."
		git clone --depth 1 $(raylib_repo) $(raylib_basedir) > /dev/null 2>&1; \
		echo "cloned into $(raylib_basedir)"
	fi
#	cd $(raylib_src)
#	make $(cflags_raylib)
	@echo "building raylib library..."
	make -C $(raylib_src) $(cflags_raylib) #> /dev/null 2>&1
	@echo "built raylib, creating local dependencies..."
	@cp -f $(raylib_src)/$(raylib_lib) $(libs_dir)/
	@cp -f $(raylib_src)/$(raylib_header) $(libs_dir)/
	@rm -rf $(raylib_basedir)


$(target): $(obj_files) $(libs_dir)/$(raylib_lib)
	@mkdir -p $(dir $@)
	@echo "linking object files to create the executable..."
	@$(cc) -o $@ $^ $(ldflags)

$(build_dir)/%.o: src/%.c $(libs_dir)/$(raylib_lib)
	@mkdir -p $(build_dir)
	@echo "compiling $< to object file..."
	@$(cc) $(cflags) -c $< -o $@

run: all
	@echo "running the application..."
	./$(target)

clean:
	@echo "running clean..."
	@rm -f $(obj) $(target)
	@rm -rf $(build_dir)/
	@rm -rf $(libs_dir)/
	@rm -rf $(raylib_basedir)/

.phony: all clean run dependencies
