RAYLIB_BASEDIR := ./raylib
RAYLIB_SRC := $(RAYLIB_BASEDIR)/src
RAYLIB_REPO := https://github.com/raysan5/raylib.git
RAYLIB_LIB := libraylib.a

INCLUDE_DIR = include
BUILD_DIR = build
LIBS_DIR = libs

CC := clang
CFLAGS := -Wall -Wextra -g -I$(INCLUDE_DIR)
CFLAGS_RAYLIB := PLATFORM=PLATFORM_DESKTOP STATIC=1
LDFLAGS = -lm -lpthread -ldl -lrt -lX11

TARGET := $(BUILD_DIR)/tphone
SRC := $(wildcard src/*.c)
OBJ := $(SRC:.c=.o)
SRC_FILES = $(wildcard src/*.c)
OBJ_FILES = $(patsubst src/%.c,$(BUILD_DIR)/%.o,$(SRC_FILES))

all: $(TARGET)

$(LIBS_DIR):
	mkdir -p $(LIBS_DIR)

$(LIBS_DIR)/$(RAYLIB_LIB): | $(LIBS_DIR)
	@echo "Building raylib..."
	git clone --depth 1 $(RAYLIB_REPO) $(RAYLIB_BASEDIR)
	cd $(RAYLIB_SRC) && make $(CFLAGS_RAYLIB)
	cp -f $(RAYLIB_SRC)/$(RAYLIB_LIB) $(LIBS_DIR)
	rm -rf $(RAYLIB_BASEDIR)

$(TARGET): $(LIBS_DIR)/$(RAYLIB_LIB) $(OBJ_FILES)
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

.PHONY: all clean
