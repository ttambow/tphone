RAYLIB_BASEDIR := ./raylib
RAYLIB_SRC_DIR := $(RAYLIB_BASEDIR)/src
RAYLIB_REPO := https://github.com/raysan5/raylib.git
RAYLIB_LIB := libraylib.a

INCLUDE_DIR = include
BUILD_DIR = build
LIBS_DIR = libs

CC := clang
CFLAGS := -Wall -Wextra -g -I$(INCLUDE_DIR) -I$(RAYLIB_BASEDIR)/include
CFLAGS_RAYLIB := PLATFORM=PLATFORM_DESKTOP STATIC=1
LDFLAGS = -lm -lpthread -ldl -lrt -lX11

TARGET := $(BUILD_DIR)/tphone
SRC := $(wildcard src/*.c)
OBJ := $(SRC:.c=.o)
SRC_FILES = $(wildcard src/*.c)
OBJ_FILES = $(patsubst src/%.c,$(BUILD_DIR)/%.o,$(SRC_FILES))

all: $(TARGET)

build_raylib: # todo: handle git errors
	git clone --depth 1 $(RAYLIB_REPO) $(RAYLIB_BASEDIR)
	cd $(RAYLIB_SRC_DIR) && make $(CFLAGS_RAYLIB)
	cp -f $(RAYLIB_SRC_DIR)/$(RAYLIB_LIB) $(LIBS_DIR)
	rm -rf $(RAYLIB_BASEDIR)

$(TARGET): $(OBJ_FILES)
	$(CC) -v -o $@ $^ $(LIBS_DIR)/$(RAYLIB_LIB) $(LDFLAGS)

$(BUILD_DIR)/%.o: src/%.c
	@mkdir -p $(BUILD_DIR)
	$(CC) $(CFLAGS) -I$(INCLUDE_DIR) -I $(LIBS_DIR) -c $< -o $@

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

run:
	make && ./$(TARGET)

clean:
	rm -f $(OBJ) $(TARGET)
	rm -rf $(BUILD_DIR)
	#rm -rf $(RAYLIB_BASEDIR)
	#rm -f $(INCLUDE_DIR)/$(RAYLIB_LIB)

.PHONY: all clean